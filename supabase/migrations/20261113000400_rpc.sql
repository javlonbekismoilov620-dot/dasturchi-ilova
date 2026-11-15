-- =============================================================================
-- Mahorat — client RPCs (PostgREST: POST /rest/v1/rpc/<name>)
-- Every routine validates the caller and its entitlement explicitly.
-- =============================================================================

create or replace function private.require_user()
returns uuid language plpgsql stable set search_path = '' as $$
declare
  v uuid := (select auth.uid());
begin
  if v is null then raise exception 'not_authenticated' using errcode = '28000'; end if;
  return v;
end $$;

-- ---------------------------------------------------------------------------
-- Enrollment
-- ---------------------------------------------------------------------------
create or replace function public.enroll_in_course(p_course_id uuid)
returns public.enrollments language plpgsql security definer set search_path = '' as $$
declare
  v_user uuid := private.require_user();
  v_course public.courses;
  v_enrollment public.enrollments;
begin
  select * into v_course from public.courses where id = p_course_id and status = 'published';
  if not found then raise exception 'course_not_found' using errcode = 'P0002'; end if;
  if v_course.access_tier = 'premium' and not private.has_premium(v_user) then
    raise exception 'premium_required' using errcode = '42501';
  end if;
  v_enrollment := private.ensure_enrollment(v_user, p_course_id);
  v_enrollment := private.recompute_enrollment(v_user, p_course_id);
  perform private.evaluate_achievements(v_user);
  return v_enrollment;
end $$;

create or replace function public.leave_course(p_course_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_user uuid := private.require_user();
begin
  update public.enrollments set status = 'dropped'
  where user_id = v_user and course_id = p_course_id and status = 'active';
end $$;

-- ---------------------------------------------------------------------------
-- Progress. Called periodically by the player (position, time spent) and when a
-- lesson is finished. Quiz and assignment lessons are completed by their own RPCs.
-- ---------------------------------------------------------------------------
create or replace function public.record_lesson_progress(
  p_lesson_id uuid,
  p_position_seconds integer default null,
  p_seconds_spent integer default 0,
  p_completed boolean default false
)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_user uuid := private.require_user();
  v_lesson public.lessons;
  v_newly boolean := false;
  v_spent integer := least(greatest(coalesce(p_seconds_spent, 0), 0), 600); -- max 10 min per heartbeat
  v_enrollment public.enrollments;
  v_cert public.certificates;
  v_new_achievements jsonb;
begin
  if not private.can_access_lesson(p_lesson_id) then
    raise exception 'lesson_locked' using errcode = '42501';
  end if;
  select * into v_lesson from public.lessons where id = p_lesson_id;

  perform private.ensure_enrollment(v_user, v_lesson.course_id);

  insert into public.lesson_progress as lp (user_id, lesson_id, course_id, status, position_seconds, seconds_spent)
  values (v_user, p_lesson_id, v_lesson.course_id, 'in_progress',
          greatest(coalesce(p_position_seconds, 0), 0), v_spent)
  on conflict (user_id, lesson_id) do update set
    position_seconds = coalesce(greatest(p_position_seconds, 0), lp.position_seconds),
    seconds_spent = lp.seconds_spent + v_spent,
    updated_at = now();

  update public.enrollments set last_lesson_id = p_lesson_id, last_accessed_at = now()
  where user_id = v_user and course_id = v_lesson.course_id;

  if v_spent > 0 then
    perform private.touch_activity(v_user, v_spent, 0, 0);
  end if;

  if p_completed then
    if v_lesson.type in ('quiz') then
      raise exception 'complete_via_quiz' using errcode = '22023';
    elsif v_lesson.type in ('assignment', 'project') and exists (
      select 1 from public.assignments a where a.lesson_id = p_lesson_id and a.status = 'published'
    ) then
      raise exception 'complete_via_submission' using errcode = '22023';
    end if;
    v_newly := private.complete_lesson(v_user, p_lesson_id);
  end if;

  select coalesce(jsonb_agg(jsonb_build_object('id', a.id, 'slug', a.slug, 'title', a.title, 'tier', a.tier, 'icon', a.icon)), '[]'::jsonb)
    into v_new_achievements from private.evaluate_achievements(v_user) a;

  select * into v_enrollment from public.enrollments where user_id = v_user and course_id = v_lesson.course_id;
  select * into v_cert from public.certificates where user_id = v_user and course_id = v_lesson.course_id;

  return jsonb_build_object(
    'lesson_id', p_lesson_id,
    'newly_completed', v_newly,
    'xp_awarded', case when v_newly then v_lesson.xp else 0 end,
    'enrollment', case when v_enrollment.id is null then null else to_jsonb(v_enrollment) end,
    'certificate', case when v_cert.id is null then null else to_jsonb(v_cert) end,
    'new_achievements', v_new_achievements
  );
end $$;

-- ---------------------------------------------------------------------------
-- Quizzes. get_quiz never returns correctness or feedback.
-- ---------------------------------------------------------------------------
create or replace function private.can_take_quiz(p_quiz public.quizzes)
returns boolean language sql stable security definer set search_path = '' as $$
  select private.can_edit_course(p_quiz.course_id) or (
    p_quiz.status = 'published' and (
      case when p_quiz.lesson_id is not null then private.can_access_lesson(p_quiz.lesson_id)
           else private.can_access_course(p_quiz.course_id) end
    )
  );
$$;

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
        'answers', case when q.type = 'short_answer' then '[]'::jsonb else coalesce((
          select jsonb_agg(jsonb_build_object('id', a.id, 'label_md', a.label_md) order by a.position, a.id)
          from public.answers a where a.question_id = q.id
        ), '[]'::jsonb) end
      ) order by case when v_quiz.shuffle_questions then random() else q.position end, q.id)
      from public.questions q where q.quiz_id = v_quiz.id
    ), '[]'::jsonb)
  );
end $$;

create or replace function private.normalize_answer(p text)
returns text language sql immutable set search_path = '' as $$
  select regexp_replace(lower(trim(coalesce(p, ''))), '\s+', ' ', 'g');
$$;

-- p_responses: { "<question_id>": ["<answer_id>", …] | "<free text>" }
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
          and private.normalize_answer(a.label_md) = private.normalize_answer(v_text)
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
      'feedback', (
        select coalesce(jsonb_agg(jsonb_build_object('answer_id', a.id, 'feedback_md', a.feedback_md)), '[]'::jsonb)
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

-- ---------------------------------------------------------------------------
-- Assignments / projects
-- ---------------------------------------------------------------------------
create or replace function public.submit_assignment(
  p_assignment_id uuid,
  p_body_md text default null,
  p_url text default null,
  p_file_paths text[] default '{}'
)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_user uuid := private.require_user();
  v_assignment public.assignments;
  v_submission public.submissions;
  v_path text;
begin
  select * into v_assignment from public.assignments where id = p_assignment_id and status = 'published';
  if not found or not private.can_access_course(v_assignment.course_id) then
    raise exception 'assignment_locked' using errcode = '42501';
  end if;
  if v_assignment.lesson_id is not null and not private.can_access_lesson(v_assignment.lesson_id) then
    raise exception 'assignment_locked' using errcode = '42501';
  end if;
  if p_url is not null and p_url !~ '^https?://' then
    raise exception 'invalid_url' using errcode = '22023';
  end if;
  foreach v_path in array coalesce(p_file_paths, '{}') loop
    if split_part(v_path, '/', 1) <> v_user::text or split_part(v_path, '/', 2) <> p_assignment_id::text then
      raise exception 'invalid_file_path' using errcode = '22023';
    end if;
  end loop;

  insert into public.submissions (assignment_id, user_id, body_md, url, file_paths)
  values (p_assignment_id, v_user, nullif(trim(p_body_md), ''), nullif(trim(p_url), ''), coalesce(p_file_paths, '{}'))
  returning * into v_submission;

  if v_assignment.lesson_id is not null then
    perform private.complete_lesson(v_user, v_assignment.lesson_id);
  end if;
  perform private.evaluate_achievements(v_user);
  return to_jsonb(v_submission);
end $$;

-- ---------------------------------------------------------------------------
-- Certificates
-- ---------------------------------------------------------------------------
create or replace function public.claim_certificate(p_course_id uuid)
returns public.certificates language plpgsql security definer set search_path = '' as $$
declare
  v_user uuid := private.require_user();
  v_cert public.certificates;
begin
  perform private.recompute_enrollment(v_user, p_course_id);
  v_cert := private.issue_certificate_if_eligible(v_user, p_course_id);
  if v_cert.id is null then
    raise exception 'certificate_not_eligible' using errcode = '42501';
  end if;
  perform private.evaluate_achievements(v_user);
  return v_cert;
end $$;

-- Public verification (anyone holding the code can confirm authenticity).
create or replace function public.verify_certificate(p_code text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce((
    select jsonb_build_object(
      'valid', c.revoked_at is null,
      'serial', c.serial,
      'recipient_name', c.recipient_name,
      'course_title', c.course_title,
      'course_level', c.course_level,
      'issued_at', c.issued_at,
      'revoked_at', c.revoked_at
    )
    from public.certificates c
    where c.verification_code = upper(trim(p_code)) or c.serial = upper(trim(p_code))
  ), jsonb_build_object('valid', false));
$$;

-- ---------------------------------------------------------------------------
-- Discovery
-- ---------------------------------------------------------------------------
create or replace function public.search_courses(
  p_query text default null,
  p_category_slug text default null,
  p_levels public.difficulty_level[] default null,
  p_tier public.access_tier default null,
  p_sort text default 'relevance',
  p_limit integer default 30,
  p_offset integer default 0
)
returns setof public.courses language plpgsql stable security invoker set search_path = '' as $$
declare
  v_q text := left(nullif(trim(coalesce(p_query, '')), ''), 200);
  v_tsq tsquery;
  v_prefix tsquery;
begin
  if v_q is not null then
    v_tsq := websearch_to_tsquery('simple'::regconfig, v_q);
    -- prefix query from alphanumeric tokens only ("pyth begi" → pyth:* & begi:*)
    select to_tsquery('simple'::regconfig, string_agg(w || ':*', ' & '))
      into v_prefix
    from regexp_split_to_table(lower(v_q), '[^[:alnum:]]+') w
    where w <> '';
  end if;
  return query
  select c.*
  from public.courses c
  left join public.categories cat on cat.id = c.category_id
  left join public.categories sub on sub.id = c.subcategory_id
  where c.status = 'published'
    and (p_category_slug is null or cat.slug = p_category_slug or sub.slug = p_category_slug)
    and (p_levels is null or c.level = any (p_levels))
    and (p_tier is null or c.access_tier = p_tier)
    and (
      v_q is null
      or c.search_vector @@ v_tsq
      or (v_prefix is not null and c.search_vector @@ v_prefix)
      or extensions.similarity(c.title, v_q) > 0.2
      or c.title ilike '%' || replace(replace(v_q, '%', ''), '_', '') || '%'
    )
  order by
    case when p_sort = 'popular' then c.enrollment_count end desc nulls last,
    case when p_sort = 'newest' then c.published_at end desc nulls last,
    case when p_sort = 'relevance' and v_q is not null then
      ts_rank(c.search_vector, coalesce(v_prefix, v_tsq)) + extensions.similarity(c.title, v_q) end desc nulls last,
    c.is_featured desc, c.enrollment_count desc, c.title
  limit least(greatest(p_limit, 1), 100) offset greatest(p_offset, 0);
end $$;

-- Personalised recommendations: interests, experience level proximity, popularity,
-- editorial features; excludes courses the learner already takes.
create or replace function public.recommended_courses(p_limit integer default 10)
returns setof public.courses language sql stable security definer set search_path = '' as $$
  with me as (
    select p.interests, p.experience_level
    from public.profiles p where p.id = (select auth.uid())
  ),
  levels as (
    select e.lvl, (row_number() over (order by e.ord))::int as rank
    from unnest(enum_range(null::public.difficulty_level)) with ordinality as e(lvl, ord)
  ),
  history as (
    -- categories of courses the learner engaged with recently
    select c.category_id, count(*) as n
    from public.enrollments en join public.courses c on c.id = en.course_id
    where en.user_id = (select auth.uid())
    group by c.category_id
  )
  select c.*
  from public.courses c
  join public.categories cat on cat.id = c.category_id
  left join public.categories sub on sub.id = c.subcategory_id
  left join me on true
  left join levels lc on lc.lvl = c.level
  left join levels lm on lm.lvl = me.experience_level
  left join history h on h.category_id = c.category_id
  where c.status = 'published'
    and not exists (
      select 1 from public.enrollments en
      where en.user_id = (select auth.uid()) and en.course_id = c.id and en.status <> 'dropped'
    )
  order by (
      case when me.interests is not null and (cat.slug = any (me.interests) or sub.slug = any (me.interests)) then 4 else 0 end
    + case when lm.rank is null then 0 else greatest(0, 3 - abs(lc.rank - lm.rank) * 1.5) end
    + least(coalesce(h.n, 0), 3) * 0.75
    + ln(1 + c.enrollment_count) * 0.5
    + case when c.is_featured then 1 else 0 end
    + case when c.access_tier = 'free' then 0.25 else 0 end
  ) desc, c.published_at desc nulls last
  limit least(greatest(p_limit, 1), 50);
$$;

-- ---------------------------------------------------------------------------
-- Learner statistics
-- ---------------------------------------------------------------------------
create or replace function public.my_learning_stats()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  v_user uuid := private.require_user();
  v_today date := private.local_today(v_user);
  v_profile public.profiles;
begin
  select * into v_profile from public.profiles where id = v_user;
  return jsonb_build_object(
    'total_xp', v_profile.total_xp,
    'current_streak', case when v_profile.last_active_date >= v_today - 1 then v_profile.current_streak else 0 end,
    'longest_streak', v_profile.longest_streak,
    'active_today', v_profile.last_active_date = v_today,
    'daily_goal_minutes', v_profile.daily_goal_minutes,
    'today_seconds', coalesce((select seconds_learned from public.daily_activity where user_id = v_user and activity_date = v_today), 0),
    'total_seconds', coalesce((select sum(seconds_learned) from public.daily_activity where user_id = v_user), 0),
    'lessons_completed', (select count(*) from public.lesson_progress where user_id = v_user and status = 'completed'),
    'courses_in_progress', (select count(*) from public.enrollments where user_id = v_user and status = 'active'),
    'courses_completed', (select count(*) from public.enrollments where user_id = v_user and status = 'completed'),
    'quizzes_passed', (select count(distinct quiz_id) from public.quiz_attempts where user_id = v_user and passed),
    'certificates', (select count(*) from public.certificates where user_id = v_user and revoked_at is null),
    'achievements', (select count(*) from public.user_achievements where user_id = v_user),
    'is_premium', private.has_premium(v_user),
    'last_7_days', (
      select jsonb_agg(jsonb_build_object(
        'date', d::date,
        'seconds', coalesce(a.seconds_learned, 0),
        'lessons', coalesce(a.lessons_completed, 0)
      ) order by d)
      from generate_series(v_today - 6, v_today, interval '1 day') d
      left join public.daily_activity a on a.user_id = v_user and a.activity_date = d::date
    )
  );
end $$;

create or replace function public.my_entitlements()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  v_user uuid := (select auth.uid());
  v_sub public.subscriptions;
begin
  select * into v_sub from public.subscriptions s
  where s.user_id = v_user and s.status in ('active', 'in_grace_period', 'cancelled')
    and (s.current_period_end is null or s.current_period_end > now())
  order by s.current_period_end desc nulls first limit 1;
  return jsonb_build_object(
    'is_premium', private.has_premium(v_user),
    'free_for_all', private.billing_free_for_all(),
    'subscription', case when v_sub.id is null then null else jsonb_build_object(
      'platform', v_sub.platform, 'status', v_sub.status, 'product_id', v_sub.product_id,
      'current_period_end', v_sub.current_period_end, 'will_renew', v_sub.will_renew) end
  );
end $$;

create or replace function public.mark_notifications_read(p_ids uuid[])
returns integer language plpgsql security definer set search_path = '' as $$
declare
  v_user uuid := private.require_user();
  v_count integer;
begin
  insert into public.notification_reads (user_id, notification_id)
  select v_user, n.id from public.notifications n
  where n.id = any (p_ids) and (n.user_id = v_user or n.user_id is null)
  on conflict do nothing;
  get diagnostics v_count = row_count;
  return v_count;
end $$;

-- ---------------------------------------------------------------------------
-- Administration (role-checked)
-- ---------------------------------------------------------------------------
create or replace function private.require_admin()
returns void language plpgsql stable security definer set search_path = '' as $$
begin
  if not private.is_admin() then raise exception 'admin_only' using errcode = '42501'; end if;
end $$;

create or replace function public.admin_dashboard_stats()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not private.is_editor() then raise exception 'editors_only' using errcode = '42501'; end if;
  return jsonb_build_object(
    'users', (select count(*) from public.profiles),
    'new_users_30d', (select count(*) from public.profiles where created_at > now() - interval '30 days'),
    'active_learners_7d', (select count(distinct user_id) from public.daily_activity where activity_date > current_date - 7),
    'premium_subscribers', (select count(distinct user_id) from public.subscriptions
                            where status in ('active', 'in_grace_period', 'cancelled')
                              and (current_period_end is null or current_period_end > now())),
    'courses', jsonb_build_object(
      'published', (select count(*) from public.courses where status = 'published'),
      'in_review', (select count(*) from public.courses where status = 'in_review'),
      'draft', (select count(*) from public.courses where status = 'draft')),
    'lessons', jsonb_build_object(
      'published', (select count(*) from public.lessons where status = 'published'),
      'in_review', (select count(*) from public.lessons where status = 'in_review'),
      'draft', (select count(*) from public.lessons where status = 'draft')),
    'enrollments', (select count(*) from public.enrollments),
    'completions', (select count(*) from public.enrollments where status = 'completed'),
    'certificates', (select count(*) from public.certificates where revoked_at is null),
    'pending_submissions', (select count(*) from public.submissions where status in ('submitted', 'in_review')),
    'quiz_attempts_30d', (select count(*) from public.quiz_attempts where submitted_at > now() - interval '30 days'),
    'signups_by_day', (
      select jsonb_agg(jsonb_build_object('date', d::date, 'count',
        (select count(*) from public.profiles p where p.created_at::date = d::date)) order by d)
      from generate_series(current_date - 29, current_date, interval '1 day') d),
    'learning_minutes_by_day', (
      select jsonb_agg(jsonb_build_object('date', d::date, 'minutes',
        coalesce((select sum(seconds_learned) / 60 from public.daily_activity a where a.activity_date = d::date), 0)) order by d)
      from generate_series(current_date - 29, current_date, interval '1 day') d),
    'top_courses', (
      select coalesce(jsonb_agg(t), '[]'::jsonb) from (
        select c.id, c.title, c.enrollment_count,
          (select count(*) from public.enrollments e where e.course_id = c.id and e.status = 'completed') as completions
        from public.courses c order by c.enrollment_count desc, c.title limit 8) t)
  );
end $$;

create or replace function public.admin_list_users(p_search text default null, p_limit integer default 50, p_offset integer default 0)
returns table (
  id uuid, email text, display_name text, roles public.app_role[], created_at timestamptz,
  last_sign_in_at timestamptz, is_premium boolean, total_xp integer, enrollments bigint
) language plpgsql stable security definer set search_path = '' as $$
begin
  perform private.require_admin();
  return query
  select p.id, u.email::text, p.display_name,
    coalesce((select array_agg(r.role order by r.role) from public.user_roles r where r.user_id = p.id), '{}'),
    p.created_at, u.last_sign_in_at, private.has_premium(p.id), p.total_xp,
    (select count(*) from public.enrollments e where e.user_id = p.id)
  from public.profiles p join auth.users u on u.id = p.id
  where p_search is null or u.email ilike '%' || p_search || '%' or p.display_name ilike '%' || p_search || '%'
  order by p.created_at desc
  limit least(greatest(p_limit, 1), 200) offset greatest(p_offset, 0);
end $$;

create or replace function public.admin_set_role(p_user_id uuid, p_role public.app_role, p_granted boolean)
returns void language plpgsql security definer set search_path = '' as $$
begin
  perform private.require_admin();
  if p_granted then
    insert into public.user_roles (user_id, role, granted_by) values (p_user_id, p_role, (select auth.uid()))
    on conflict do nothing;
  else
    delete from public.user_roles where user_id = p_user_id and role = p_role;
  end if;
  insert into public.audit_log (actor_id, action, entity, entity_id, details)
  values ((select auth.uid()), case when p_granted then 'grant_role' else 'revoke_role' end, 'user_roles', p_user_id,
          jsonb_build_object('role', p_role));
end $$;

-- Manual / promotional premium (e.g. scholarships, staff, support goodwill).
-- Store subscriptions are never created here; they come from the billing webhook.
create or replace function public.admin_grant_premium(p_user_id uuid, p_days integer, p_note text default null)
returns public.subscriptions language plpgsql security definer set search_path = '' as $$
declare
  v_sub public.subscriptions;
begin
  perform private.require_admin();
  if p_days is not null and (p_days < 1 or p_days > 3650) then
    raise exception 'invalid_days' using errcode = '22023';
  end if;
  insert into public.subscriptions (user_id, platform, status, entitlement, current_period_start, current_period_end, note)
  values (p_user_id, 'manual', 'active', 'premium', now(),
          case when p_days is null then null else now() + make_interval(days => p_days) end, p_note)
  returning * into v_sub;
  insert into public.audit_log (actor_id, action, entity, entity_id, details)
  values ((select auth.uid()), 'grant_premium', 'subscriptions', v_sub.id,
          jsonb_build_object('user_id', p_user_id, 'days', p_days));
  return v_sub;
end $$;

create or replace function public.admin_revoke_manual_premium(p_subscription_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  perform private.require_admin();
  update public.subscriptions set status = 'cancelled', current_period_end = now(), will_renew = false
  where id = p_subscription_id and platform in ('manual', 'promotional');
end $$;

create or replace function public.admin_broadcast(p_title text, p_body text, p_type public.notification_type default 'announcement', p_data jsonb default '{}')
returns public.notifications language plpgsql security definer set search_path = '' as $$
declare
  v_n public.notifications;
begin
  perform private.require_admin();
  insert into public.notifications (user_id, type, title, body, data, created_by)
  values (null, p_type, p_title, p_body, coalesce(p_data, '{}'), (select auth.uid()))
  returning * into v_n;
  return v_n;
end $$;

-- Lock down: everything is revoked from PUBLIC first, then granted explicitly.
revoke execute on all functions in schema public from public, anon;
grant execute on function public.search_courses(text, text, public.difficulty_level[], public.access_tier, text, integer, integer) to anon, authenticated;
grant execute on function public.recommended_courses(integer) to anon, authenticated;
grant execute on function public.get_quiz(uuid) to anon, authenticated;
grant execute on function public.verify_certificate(text) to anon, authenticated;
grant execute on function public.my_entitlements() to anon, authenticated;
grant execute on function
  public.enroll_in_course(uuid),
  public.leave_course(uuid),
  public.record_lesson_progress(uuid, integer, integer, boolean),
  public.submit_quiz_attempt(uuid, jsonb, timestamptz),
  public.submit_assignment(uuid, text, text, text[]),
  public.claim_certificate(uuid),
  public.my_learning_stats(),
  public.mark_notifications_read(uuid[]),
  public.admin_dashboard_stats(),
  public.admin_list_users(text, integer, integer),
  public.admin_set_role(uuid, public.app_role, boolean),
  public.admin_grant_premium(uuid, integer, text),
  public.admin_revoke_manual_premium(uuid),
  public.admin_broadcast(text, text, public.notification_type, jsonb)
  to authenticated;
