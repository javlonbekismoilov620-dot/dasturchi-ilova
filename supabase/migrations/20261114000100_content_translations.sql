-- Content translations.
--
-- Course content is authored in a base language (courses.language, 'en' for the starter
-- library) and translated by adding per-locale overlays in a `translations` column on the
-- same row: { "uz": { "title": "…", "body_md": "…" }, "ru": { … } }.
--
-- Because translations live on the existing rows, translating content never creates new
-- courses, lessons, quizzes or answers: every ID, enrolment, progress record, quiz attempt,
-- bookmark, note and certificate stays attached to exactly the same content. Clients show
-- the overlay for the learner's language and fall back to the base text (with a notice)
-- when a translation does not exist yet.

create or replace function private.valid_translations(p jsonb)
returns boolean language sql immutable set search_path = '' as $$
  select jsonb_typeof(p) = 'object' and not exists (
    select 1 from jsonb_each(p) e
    where e.key not in ('en', 'uz', 'ru') or jsonb_typeof(e.value) <> 'object'
  );
$$;

-- Keeps only the given fields of every locale overlay (used to avoid revealing, e.g., a
-- translated explanation before the learner submits a quiz).
create or replace function private.pick_translations(p jsonb, p_fields text[])
returns jsonb language sql immutable set search_path = '' as $$
  select coalesce(jsonb_object_agg(e.key, (
    select coalesce(jsonb_object_agg(f.key, f.value), '{}'::jsonb)
    from jsonb_each(e.value) f where f.key = any (p_fields)
  )), '{}'::jsonb)
  from jsonb_each(coalesce(p, '{}'::jsonb)) e;
$$;

do $$
declare t text;
begin
  foreach t in array array[
    'categories', 'instructors', 'courses', 'learning_paths', 'modules', 'lessons', 'lesson_contents',
    'resources', 'quizzes', 'questions', 'answers', 'assignments', 'achievements', 'subscription_plans'
  ] loop
    execute format('alter table public.%I add column if not exists translations jsonb not null default ''{}''::jsonb', t);
    execute format('alter table public.%I add constraint %I check (private.valid_translations(translations))', t, t || '_translations_valid');
  end loop;
end $$;

-- Search also matches translated course titles and descriptions.
create or replace function private.guard_course()
returns trigger language plpgsql set search_path = '' as $$
begin
  -- counters are engine-owned
  if private.is_client_role() then
    if tg_op = 'UPDATE' then
      new.lesson_count := old.lesson_count;
      new.duration_seconds := old.duration_seconds;
      new.enrollment_count := old.enrollment_count;
      new.created_by := old.created_by;
    else
      new.lesson_count := 0;
      new.duration_seconds := 0;
      new.enrollment_count := 0;
      new.created_by := (select auth.uid());
    end if;
  end if;
  if new.subcategory_id is not null and not exists (
    select 1 from public.categories s where s.id = new.subcategory_id and s.parent_id = new.category_id
  ) then
    raise exception 'subcategory_must_belong_to_category' using errcode = '23514';
  end if;
  if new.status = 'published' and (tg_op = 'INSERT' or old.status is distinct from 'published') then
    new.published_at := coalesce(new.published_at, now());
  end if;
  new.search_vector :=
    setweight(to_tsvector('simple'::regconfig, coalesce(new.title, '')), 'A') ||
    setweight(to_tsvector('simple'::regconfig, coalesce(new.subtitle, '')), 'B') ||
    setweight(to_tsvector('simple'::regconfig, array_to_string(new.tags, ' ')), 'B') ||
    setweight(to_tsvector('simple'::regconfig, coalesce(left(new.description, 4000), '')), 'C') ||
    -- Translated titles/subtitles are searchable in every language.
    setweight(to_tsvector('simple'::regconfig, coalesce((
      select string_agg(concat_ws(' ', e.value ->> 'title', e.value ->> 'subtitle'), ' ')
      from jsonb_each(new.translations) e), '')), 'A') ||
    setweight(to_tsvector('simple'::regconfig, coalesce((
      select left(string_agg(e.value ->> 'description', ' '), 4000)
      from jsonb_each(new.translations) e), '')), 'C');
  return new;
end $$;

-- Quizzes carry their translations; answer keys and explanations stay hidden until submission.
create or replace function public.get_quiz(p_quiz_id uuid)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  v_quiz public.quizzes;
  v_user uuid := (select auth.uid());
begin
  select * into v_quiz from public.quizzes where id = p_quiz_id;
  if not found or not private.can_take_quiz(v_quiz) then
    raise exception 'quiz_locked' using errcode = '42501';
  end if;

  return jsonb_build_object(
    'id', v_quiz.id,
    'course_id', v_quiz.course_id,
    'lesson_id', v_quiz.lesson_id,
    'title', v_quiz.title,
    'description', v_quiz.description,
    'translations', v_quiz.translations,
    'kind', v_quiz.kind,
    'pass_score_percent', v_quiz.pass_score_percent,
    'time_limit_seconds', v_quiz.time_limit_seconds,
    'max_attempts', v_quiz.max_attempts,
    'xp', v_quiz.xp,
    'attempts_used', (select count(*) from public.quiz_attempts a where a.quiz_id = v_quiz.id and a.user_id = v_user),
    'best_score', (select max(score_percent) from public.quiz_attempts a where a.quiz_id = v_quiz.id and a.user_id = v_user),
    'passed', coalesce((select bool_or(passed) from public.quiz_attempts a where a.quiz_id = v_quiz.id and a.user_id = v_user), false),
    'questions', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', q.id,
        'type', q.type,
        'prompt_md', q.prompt_md,
        'code_snippet', q.code_snippet,
        'points', q.points,
        'translations', private.pick_translations(q.translations, array['prompt_md', 'code_snippet']),
        'answers', case when q.type = 'short_answer' then '[]'::jsonb else coalesce((
          select jsonb_agg(jsonb_build_object('id', a.id, 'label_md', a.label_md, 'translations', private.pick_translations(a.translations, array['label_md'])) order by a.position, a.id)
          from public.answers a where a.question_id = q.id
        ), '[]'::jsonb) end
      ) order by case when v_quiz.shuffle_questions then random() else q.position end, q.id)
      from public.questions q where q.quiz_id = v_quiz.id
    ), '[]'::jsonb)
  );
end $$;

-- Short answers are accepted in any language; results include translated explanations/feedback.
create or replace function public.submit_quiz_attempt(p_quiz_id uuid, p_responses jsonb, p_started_at timestamptz default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_user uuid := private.require_user();
  v_quiz public.quizzes;
  v_q record;
  v_selected uuid[];
  v_correct uuid[];
  v_text text;
  v_is_correct boolean;
  v_earned integer := 0;
  v_possible integer := 0;
  v_results jsonb := '[]'::jsonb;
  v_score numeric(5, 2);
  v_passed boolean;
  v_previously_passed boolean;
  v_attempt_id uuid;
  v_newly_completed boolean := false;
  v_achievements jsonb;
  v_enrollment public.enrollments;
  v_cert public.certificates;
begin
  if jsonb_typeof(coalesce(p_responses, '{}'::jsonb)) <> 'object' then
    raise exception 'invalid_responses' using errcode = '22023';
  end if;
  select * into v_quiz from public.quizzes where id = p_quiz_id;
  if not found or not private.can_take_quiz(v_quiz) then
    raise exception 'quiz_locked' using errcode = '42501';
  end if;
  if v_quiz.max_attempts is not null and
     (select count(*) from public.quiz_attempts where quiz_id = p_quiz_id and user_id = v_user) >= v_quiz.max_attempts then
    raise exception 'max_attempts_reached' using errcode = '42501';
  end if;

  select coalesce(bool_or(passed), false) into v_previously_passed
  from public.quiz_attempts where quiz_id = p_quiz_id and user_id = v_user;

  for v_q in select * from public.questions where quiz_id = p_quiz_id order by position, id loop
    v_possible := v_possible + v_q.points;
    select coalesce(array_agg(a.id order by a.id), '{}') into v_correct
    from public.answers a where a.question_id = v_q.id and a.is_correct;

    if v_q.type = 'short_answer' then
      v_text := case when jsonb_typeof(p_responses -> v_q.id::text) = 'string' then p_responses ->> v_q.id::text end;
      v_selected := '{}';
      v_is_correct := v_text is not null and exists (
        select 1 from public.answers a
        where a.question_id = v_q.id and a.is_correct
          and (private.normalize_answer(a.label_md) = private.normalize_answer(v_text)
               or exists (select 1 from jsonb_each(a.translations) t
                          where private.normalize_answer(t.value ->> 'label_md') = private.normalize_answer(v_text)))
      );
    else
      v_text := null;
      select coalesce(array_agg(distinct x.id order by x.id), '{}') into v_selected
      from (
        select private.try_uuid(e) as id
        from jsonb_array_elements_text(
          case when jsonb_typeof(p_responses -> v_q.id::text) = 'array' then p_responses -> v_q.id::text else '[]'::jsonb end
        ) e
      ) x
      where x.id is not null and exists (select 1 from public.answers a where a.id = x.id and a.question_id = v_q.id);
      v_is_correct := cardinality(v_correct) > 0 and v_selected = v_correct
                      and (v_q.type = 'multiple_choice' or cardinality(v_selected) = 1);
    end if;

    if v_is_correct then v_earned := v_earned + v_q.points; end if;

    v_results := v_results || jsonb_build_object(
      'question_id', v_q.id,
      'correct', v_is_correct,
      'points', case when v_is_correct then v_q.points else 0 end,
      'selected_answer_ids', to_jsonb(v_selected),
      'response_text', v_text,
      'correct_answer_ids', case when v_q.type = 'short_answer' then '[]'::jsonb else to_jsonb(v_correct) end,
      'accepted_answers', case when v_q.type = 'short_answer' then (
        select coalesce(jsonb_agg(a.label_md), '[]'::jsonb) from public.answers a where a.question_id = v_q.id and a.is_correct
      ) else '[]'::jsonb end,
      'explanation_md', v_q.explanation_md,
      'translations', private.pick_translations(v_q.translations, array['explanation_md']),
      'feedback', (
        select coalesce(jsonb_agg(jsonb_build_object('answer_id', a.id, 'feedback_md', a.feedback_md, 'translations', private.pick_translations(a.translations, array['feedback_md']))), '[]'::jsonb)
        from public.answers a
        where a.question_id = v_q.id and a.feedback_md is not null
          and (a.id = any (v_selected) or a.is_correct)
      )
    );
  end loop;

  if v_possible = 0 then raise exception 'quiz_has_no_questions' using errcode = '22023'; end if;
  v_score := round(v_earned * 100.0 / v_possible, 2);
  v_passed := v_score >= v_quiz.pass_score_percent;

  insert into public.quiz_attempts (quiz_id, user_id, responses, results, points_earned, points_possible, score_percent, passed, started_at)
  values (p_quiz_id, v_user, p_responses, v_results, v_earned, v_possible, v_score, v_passed, p_started_at)
  returning id into v_attempt_id;

  perform private.ensure_enrollment(v_user, v_quiz.course_id);

  if v_passed and not v_previously_passed then
    perform private.touch_activity(v_user, 0, 0, v_quiz.xp);
  end if;
  if v_passed and v_quiz.lesson_id is not null then
    v_newly_completed := private.complete_lesson(v_user, v_quiz.lesson_id);
  else
    perform private.recompute_enrollment(v_user, v_quiz.course_id);
    perform private.issue_certificate_if_eligible(v_user, v_quiz.course_id);
  end if;

  select coalesce(jsonb_agg(jsonb_build_object('id', a.id, 'slug', a.slug, 'title', a.title, 'tier', a.tier, 'icon', a.icon)), '[]'::jsonb)
    into v_achievements from private.evaluate_achievements(v_user) a;
  select * into v_enrollment from public.enrollments where user_id = v_user and course_id = v_quiz.course_id;
  select * into v_cert from public.certificates where user_id = v_user and course_id = v_quiz.course_id;

  return jsonb_build_object(
    'attempt_id', v_attempt_id,
    'score_percent', v_score,
    'passed', v_passed,
    'pass_score_percent', v_quiz.pass_score_percent,
    'points_earned', v_earned,
    'points_possible', v_possible,
    'xp_awarded', case when v_passed and not v_previously_passed then v_quiz.xp else 0 end,
    'lesson_completed', v_newly_completed,
    'results', v_results,
    'enrollment', case when v_enrollment.id is null then null else to_jsonb(v_enrollment) end,
    'certificate', case when v_cert.id is null then null else to_jsonb(v_cert) end,
    'new_achievements', v_achievements
  );
end $$;
