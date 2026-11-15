-- Seed helpers (dropped again by zz_cleanup.sql). Seeds are STARTER/DEMO content for
-- local development and staging. They are written from scratch by the Mahorat content
-- team and must be reviewed by subject-matter experts before a production launch.
create schema if not exists seed;

create or replace function seed.cat(p_slug text) returns uuid language sql as $$
  select id from public.categories where slug = p_slug;
$$;

create or replace function seed.course(p_slug text) returns uuid language sql as $$
  select id from public.courses where slug = p_slug;
$$;

create or replace function seed.module(p_course uuid, p_position int, p_title text, p_description text,
  p_status public.content_status default 'published') returns uuid language plpgsql as $$
declare v uuid;
begin
  insert into public.modules (course_id, title, description, position, status)
  values (p_course, p_title, p_description, p_position, p_status) returning id into v;
  return v;
end $$;

create or replace function seed.lesson(
  p_module uuid, p_position int, p_title text, p_type public.lesson_type, p_minutes int,
  p_summary text, p_body text,
  p_status public.content_status default 'published', p_preview boolean default false, p_xp int default 10
) returns uuid language plpgsql as $$
declare v uuid;
begin
  insert into public.lessons (module_id, course_id, title, summary, type, position, duration_seconds, is_preview, xp, status)
  values (p_module, (select course_id from public.modules where id = p_module), p_title, p_summary, p_type,
          p_position, p_minutes * 60, p_preview, p_xp, p_status)
  returning id into v;
  if p_body is not null then
    insert into public.lesson_contents (lesson_id, body_md) values (v, p_body);
  end if;
  return v;
end $$;

create or replace function seed.quiz(p_course uuid, p_module uuid, p_lesson uuid, p_title text,
  p_kind public.quiz_kind default 'knowledge_check', p_pass int default 70, p_xp int default 20) returns uuid
language plpgsql as $$
declare v uuid;
begin
  insert into public.quizzes (course_id, module_id, lesson_id, title, kind, pass_score_percent, xp, status)
  values (p_course, p_module, p_lesson, p_title, p_kind, p_pass, p_xp, 'published') returning id into v;
  return v;
end $$;

create or replace function seed.question(p_quiz uuid, p_position int, p_type public.question_type,
  p_prompt text, p_explanation text, p_code text default null) returns uuid language plpgsql as $$
declare v uuid;
begin
  insert into public.questions (quiz_id, position, type, prompt_md, explanation_md, code_snippet)
  values (p_quiz, p_position, p_type, p_prompt, p_explanation, p_code) returning id into v;
  return v;
end $$;

create or replace function seed.answer(p_question uuid, p_position int, p_label text, p_correct boolean,
  p_feedback text default null) returns void language sql as $$
  insert into public.answers (question_id, position, label_md, is_correct, feedback_md)
  values (p_question, p_position, p_label, p_correct, p_feedback);
$$;

-- ---------------------------------------------------------------------------------------
-- Translation overlays. They UPDATE existing rows (never insert), are keyed by stable
-- slugs / base-language titles / positions, and fail loudly when a key does not match —
-- so a translation can never silently attach to the wrong content or create new IDs.
create or replace function seed.tr(p_table text, p_id uuid, p_locale text, p_fields jsonb, p_key text, p_id_col text default 'id')
returns void language plpgsql as $$
begin
  if p_id is null then
    raise exception 'seed.tr: no % row matches %', p_table, p_key;
  end if;
  execute format(
    'update public.%I set translations = jsonb_set(translations, array[$1], coalesce(translations -> $1, ''{}''::jsonb) || $2) where %I = $3',
    p_table, p_id_col) using p_locale, jsonb_strip_nulls(p_fields), p_id;
end $$;

create or replace function seed.tr_category(p_slug text, p_locale text, p_title text, p_subtitle text default null, p_description text default null)
returns void language sql as $$
  select seed.tr('categories', (select id from public.categories where slug = p_slug), p_locale,
    jsonb_build_object('title', p_title, 'subtitle', p_subtitle, 'description', p_description), p_slug);
$$;

create or replace function seed.tr_course(p_slug text, p_locale text, p_title text, p_subtitle text, p_description text,
  p_outcomes text[], p_prerequisites text[]) returns void language sql as $$
  select seed.tr('courses', seed.course(p_slug), p_locale, jsonb_build_object(
    'title', p_title, 'subtitle', p_subtitle, 'description', p_description,
    'learning_outcomes', to_jsonb(p_outcomes), 'prerequisites', to_jsonb(p_prerequisites)), p_slug);
$$;

create or replace function seed.tr_module(p_course text, p_title_base text, p_locale text, p_title text, p_description text)
returns void language sql as $$
  select seed.tr('modules', (select id from public.modules where course_id = seed.course(p_course) and title = p_title_base),
    p_locale, jsonb_build_object('title', p_title, 'description', p_description), p_course || ' / ' || p_title_base);
$$;

create or replace function seed.lesson_id(p_course text, p_title_base text) returns uuid language sql as $$
  select id from public.lessons where course_id = seed.course(p_course) and title = p_title_base;
$$;

create or replace function seed.tr_lesson(p_course text, p_title_base text, p_locale text, p_title text, p_summary text, p_body text)
returns void language plpgsql as $$
declare v uuid := seed.lesson_id(p_course, p_title_base);
begin
  perform seed.tr('lessons', v, p_locale, jsonb_build_object('title', p_title, 'summary', p_summary), p_course || ' / ' || p_title_base);
  if p_body is not null then
    perform seed.tr('lesson_contents', (select lesson_id from public.lesson_contents where lesson_id = v), p_locale,
      jsonb_build_object('body_md', p_body), p_course || ' / ' || p_title_base || ' (body)', 'lesson_id');
  end if;
end $$;

create or replace function seed.quiz_id(p_course text, p_title_base text) returns uuid language sql as $$
  select id from public.quizzes where course_id = seed.course(p_course) and title = p_title_base;
$$;

create or replace function seed.tr_quiz(p_course text, p_title_base text, p_locale text, p_title text, p_description text default null)
returns void language sql as $$
  select seed.tr('quizzes', seed.quiz_id(p_course, p_title_base), p_locale,
    jsonb_build_object('title', p_title, 'description', p_description), p_course || ' / ' || p_title_base);
$$;

-- One call per question: prompt, explanation, optional translated code snippet, then the
-- answer labels and feedback in answer-position order (null = keep the base text).
create or replace function seed.tr_question(p_course text, p_quiz_base text, p_position int, p_locale text,
  p_prompt text, p_explanation text, p_labels text[], p_feedback text[] default null, p_code text default null)
returns void language plpgsql as $$
declare
  v_q uuid := (select id from public.questions where quiz_id = seed.quiz_id(p_course, p_quiz_base) and position = p_position);
  v_key text := p_course || ' / ' || p_quiz_base || ' / Q' || p_position;
  a record;
  i int := 0;
begin
  perform seed.tr('questions', v_q, p_locale,
    jsonb_build_object('prompt_md', p_prompt, 'explanation_md', p_explanation, 'code_snippet', p_code), v_key);
  if cardinality(p_labels) <> (select count(*) from public.answers where question_id = v_q) then
    raise exception 'seed.tr_question: % has % answers, % labels given', v_key,
      (select count(*) from public.answers where question_id = v_q), cardinality(p_labels);
  end if;
  for a in select id from public.answers where question_id = v_q order by position, id loop
    i := i + 1;
    perform seed.tr('answers', a.id, p_locale,
      jsonb_build_object('label_md', p_labels[i], 'feedback_md', p_feedback[i]), v_key || ' / A' || i);
  end loop;
end $$;

create or replace function seed.tr_simple(p_table text, p_slug text, p_locale text, p_fields jsonb)
returns void language plpgsql as $$
declare v uuid;
begin
  execute format('select id from public.%I where slug = $1', p_table) into v using p_slug;
  perform seed.tr(p_table, v, p_locale, p_fields, p_table || ' / ' || p_slug);
end $$;

-- ---------------------------------------------------------------------------------------
-- Idempotent authoring helpers for content added after the first release (Sprint 1+).
-- They find rows by course slug + base-language title, UPDATE them when they exist and
-- INSERT only when missing — never delete — so re-running a content file on a live
-- database keeps every ID, enrolment, progress record and quiz attempt.
create or replace function seed.ensure_module(p_course text, p_title text, p_description text,
  p_status public.content_status default 'published') returns uuid language plpgsql as $$
declare v uuid; c uuid := seed.course(p_course);
begin
  if c is null then raise exception 'seed.ensure_module: course % not found', p_course; end if;
  select id into v from public.modules where course_id = c and title = p_title;
  if v is null then
    insert into public.modules (course_id, title, description, position, status)
    values (c, p_title, p_description, (select coalesce(max(position) + 1, 0) from public.modules where course_id = c), p_status)
    returning id into v;
  else
    update public.modules set description = p_description, status = p_status where id = v;
  end if;
  return v;
end $$;

-- Puts modules / lessons in the given order (by base title). Rows not listed keep their
-- relative order after the listed ones.
create or replace function seed.order_modules(p_course text, p_titles text[]) returns void language plpgsql as $$
declare c uuid := seed.course(p_course); i int;
begin
  for i in 1 .. cardinality(p_titles) loop
    if not exists (select 1 from public.modules where course_id = c and title = p_titles[i]) then
      raise exception 'seed.order_modules: % has no module %', p_course, p_titles[i];
    end if;
    update public.modules set position = i - 1 where course_id = c and title = p_titles[i];
  end loop;
end $$;

create or replace function seed.order_lessons(p_course text, p_module text, p_titles text[]) returns void language plpgsql as $$
declare m uuid := (select id from public.modules where course_id = seed.course(p_course) and title = p_module); i int;
begin
  if m is null then raise exception 'seed.order_lessons: % has no module %', p_course, p_module; end if;
  for i in 1 .. cardinality(p_titles) loop
    if not exists (select 1 from public.lessons where course_id = seed.course(p_course) and title = p_titles[i]) then
      raise exception 'seed.order_lessons: % has no lesson %', p_course, p_titles[i];
    end if;
    update public.lessons set module_id = m, position = i - 1 where course_id = seed.course(p_course) and title = p_titles[i];
  end loop;
end $$;

create or replace function seed.ensure_lesson(p_course text, p_module text, p_title text, p_type public.lesson_type,
  p_minutes int, p_summary text, p_body text, p_status public.content_status default 'published',
  p_preview boolean default false, p_xp int default 10) returns uuid language plpgsql as $$
declare
  c uuid := seed.course(p_course);
  m uuid := (select id from public.modules where course_id = seed.course(p_course) and title = p_module);
  v uuid;
begin
  if m is null then raise exception 'seed.ensure_lesson: % has no module %', p_course, p_module; end if;
  select id into v from public.lessons where course_id = c and title = p_title;
  if v is null then
    insert into public.lessons (module_id, course_id, title, summary, type, position, duration_seconds, is_preview, xp, status)
    values (m, c, p_title, p_summary, p_type, (select coalesce(max(position) + 1, 0) from public.lessons where module_id = m),
            p_minutes * 60, p_preview, p_xp, p_status)
    returning id into v;
  else
    update public.lessons set summary = p_summary, type = p_type, duration_seconds = p_minutes * 60,
      is_preview = p_preview, xp = p_xp, status = p_status where id = v;
  end if;
  if p_body is not null then
    insert into public.lesson_contents (lesson_id, body_md) values (v, p_body)
    on conflict (lesson_id) do update set body_md = excluded.body_md, updated_at = now();
  end if;
  return v;
end $$;

create or replace function seed.ensure_quiz(p_course text, p_lesson text, p_title text,
  p_kind public.quiz_kind default 'knowledge_check', p_pass int default 70, p_xp int default 20) returns uuid
language plpgsql as $$
declare
  l public.lessons := (select l from public.lessons l where course_id = seed.course(p_course) and title = p_lesson);
  v uuid;
begin
  if l.id is null then raise exception 'seed.ensure_quiz: % has no lesson %', p_course, p_lesson; end if;
  select id into v from public.quizzes where course_id = l.course_id and title = p_title;
  if v is null then
    insert into public.quizzes (course_id, module_id, lesson_id, title, kind, pass_score_percent, xp, status)
    values (l.course_id, l.module_id, l.id, p_title, p_kind, p_pass, p_xp, 'published') returning id into v;
  else
    update public.quizzes set module_id = l.module_id, lesson_id = l.id, kind = p_kind, pass_score_percent = p_pass, xp = p_xp, status = 'published' where id = v;
  end if;
  return v;
end $$;

-- A question with its options. Existing questions (same quiz + position) keep their IDs and
-- their answers' IDs; texts are updated. Options are given in order with their correctness.
create or replace function seed.ensure_question(p_quiz uuid, p_position int, p_type public.question_type,
  p_prompt text, p_explanation text, p_labels text[], p_correct boolean[], p_feedback text[] default null,
  p_code text default null) returns uuid language plpgsql as $$
declare v uuid; n int; a record; i int := 0;
begin
  if cardinality(p_labels) <> cardinality(p_correct) then raise exception 'labels/correct length mismatch'; end if;
  select id into v from public.questions where quiz_id = p_quiz and position = p_position;
  if v is null then
    insert into public.questions (quiz_id, position, type, prompt_md, explanation_md, code_snippet)
    values (p_quiz, p_position, p_type, p_prompt, p_explanation, p_code) returning id into v;
  else
    update public.questions set type = p_type, prompt_md = p_prompt, explanation_md = p_explanation, code_snippet = p_code where id = v;
  end if;
  select count(*) into n from public.answers where question_id = v;
  if n = 0 then
    for i in 1 .. cardinality(p_labels) loop
      insert into public.answers (question_id, position, label_md, is_correct, feedback_md)
      values (v, i - 1, p_labels[i], p_correct[i], p_feedback[i]);
    end loop;
  elsif n = cardinality(p_labels) then
    for a in select id from public.answers where question_id = v order by position, id loop
      i := i + 1;
      update public.answers set label_md = p_labels[i], is_correct = p_correct[i], feedback_md = p_feedback[i], position = i - 1 where id = a.id;
    end loop;
  else
    raise exception 'seed.ensure_question: quiz % Q% has % answers, % given', p_quiz, p_position, n, cardinality(p_labels);
  end if;
  return v;
end $$;

create or replace function seed.ensure_assignment(p_course text, p_lesson text, p_title text, p_brief text, p_rubric text,
  p_submission public.submission_type default 'any', p_project boolean default true, p_max int default 100) returns uuid
language plpgsql as $$
declare
  l public.lessons := (select l from public.lessons l where course_id = seed.course(p_course) and title = p_lesson);
  v uuid;
begin
  if l.id is null then raise exception 'seed.ensure_assignment: % has no lesson %', p_course, p_lesson; end if;
  select id into v from public.assignments where course_id = l.course_id and title = p_title;
  if v is null then
    insert into public.assignments (course_id, module_id, lesson_id, title, brief_md, rubric_md, submission_type, is_project, max_score, status)
    values (l.course_id, l.module_id, l.id, p_title, p_brief, p_rubric, p_submission, p_project, p_max, 'published') returning id into v;
  else
    update public.assignments set module_id = l.module_id, lesson_id = l.id, brief_md = p_brief, rubric_md = p_rubric,
      submission_type = p_submission, is_project = p_project, max_score = p_max, status = 'published' where id = v;
  end if;
  return v;
end $$;
