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
