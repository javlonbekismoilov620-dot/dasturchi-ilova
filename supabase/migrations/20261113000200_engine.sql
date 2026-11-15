-- =============================================================================
-- Mahorat — learning engine: helper functions, triggers and internal routines.
-- All functions use an empty search_path and fully-qualified names.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Generic helpers
-- ---------------------------------------------------------------------------
create or replace function private.set_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end $$;

create or replace function private.try_uuid(p text)
returns uuid language plpgsql immutable set search_path = '' as $$
begin
  return p::uuid;
exception when others then
  return null;
end $$;

-- Is the current database role an API client (as opposed to a trusted
-- SECURITY DEFINER routine, migration, or the service role)?
create or replace function private.is_client_role()
returns boolean language sql stable set search_path = '' as $$
  select current_user in ('anon', 'authenticated');
$$;

-- ---------------------------------------------------------------------------
-- Roles & entitlement helpers (used by RLS policies)
-- ---------------------------------------------------------------------------
create or replace function private.has_any_role(p_roles public.app_role[])
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.user_roles ur
    where ur.user_id = (select auth.uid()) and ur.role = any (p_roles)
  );
$$;

create or replace function private.is_admin()
returns boolean language sql stable security definer set search_path = '' as $$
  select private.has_any_role(array['admin']::public.app_role[]);
$$;

create or replace function private.is_editor()
returns boolean language sql stable security definer set search_path = '' as $$
  select private.has_any_role(array['editor', 'admin']::public.app_role[]);
$$;

create or replace function private.is_staff()
returns boolean language sql stable security definer set search_path = '' as $$
  select private.has_any_role(array['instructor', 'editor', 'admin']::public.app_role[]);
$$;

-- Instructor owns the course through instructors.profile_id.
create or replace function private.owns_course(p_course_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1
    from public.courses c
    join public.instructors i on i.id = c.instructor_id
    where c.id = p_course_id and i.profile_id = (select auth.uid())
  ) and private.has_any_role(array['instructor']::public.app_role[]);
$$;

create or replace function private.can_edit_course(p_course_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select private.is_editor() or private.owns_course(p_course_id);
$$;

create or replace function private.setting(p_key text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select value from public.app_settings where key = p_key;
$$;

-- Administrators can open the whole library ("free_for_all") e.g. during launch.
create or replace function private.billing_free_for_all()
returns boolean language sql stable security definer set search_path = '' as $$
  select coalesce(private.setting('billing') ->> 'mode', 'subscriptions') = 'free_for_all';
$$;

create or replace function private.has_premium(p_user uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select p_user is not null and (
    private.billing_free_for_all()
    or exists (
      select 1 from public.subscriptions s
      where s.user_id = p_user
        and s.entitlement = 'premium'
        and s.status in ('active', 'in_grace_period', 'cancelled')
        and (s.current_period_end is null or s.current_period_end > now())
    )
  );
$$;

create or replace function private.can_access_course(p_course_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
      select 1 from public.courses c
      where c.id = p_course_id
        and c.status = 'published'
        and (c.access_tier = 'free' or private.has_premium((select auth.uid())))
    )
    or private.can_edit_course(p_course_id);
$$;

create or replace function private.can_access_lesson(p_lesson_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
      select 1
      from public.lessons l
      join public.modules m on m.id = l.module_id
      join public.courses c on c.id = l.course_id
      where l.id = p_lesson_id
        and l.status = 'published' and m.status = 'published' and c.status = 'published'
        and (l.is_preview or c.access_tier = 'free' or private.has_premium((select auth.uid())))
    )
    or exists (
      select 1 from public.lessons l
      where l.id = p_lesson_id and private.can_edit_course(l.course_id)
    );
$$;

-- Lesson metadata is visible when the lesson, its module and course are all published.
create or replace function private.lesson_is_public(p_lesson_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1
    from public.lessons l
    join public.modules m on m.id = l.module_id
    join public.courses c on c.id = l.course_id
    where l.id = p_lesson_id
      and l.status = 'published' and m.status = 'published' and c.status = 'published'
  );
$$;

create or replace function private.course_is_public(p_course_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.courses c where c.id = p_course_id and c.status = 'published');
$$;

-- Local calendar date for a learner (streaks are day-based in the learner's timezone).
create or replace function private.local_today(p_user uuid)
returns date language plpgsql stable security definer set search_path = '' as $$
declare
  v_tz text;
begin
  select timezone into v_tz from public.profiles where id = p_user;
  return (now() at time zone coalesce(v_tz, 'UTC'))::date;
exception when others then
  return (now() at time zone 'UTC')::date;
end $$;

-- ---------------------------------------------------------------------------
-- Signup: create profile + default role
-- ---------------------------------------------------------------------------
create or replace function private.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  v_name text;
begin
  v_name := nullif(trim(coalesce(
    new.raw_user_meta_data ->> 'display_name',
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'name',
    split_part(coalesce(new.email, ''), '@', 1)
  )), '');
  insert into public.profiles (id, display_name, locale)
  values (
    new.id,
    left(v_name, 80),
    case when new.raw_user_meta_data ->> 'locale' in ('en', 'uz', 'ru')
         then new.raw_user_meta_data ->> 'locale' else 'en' end
  )
  on conflict (id) do nothing;
  insert into public.user_roles (user_id, role) values (new.id, 'student') on conflict do nothing;
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

-- ---------------------------------------------------------------------------
-- Guards: clients may not write engine-computed or privileged columns
-- ---------------------------------------------------------------------------
create or replace function private.guard_profile()
returns trigger language plpgsql set search_path = '' as $$
begin
  if private.is_client_role() then
    new.total_xp := old.total_xp;
    new.current_streak := old.current_streak;
    new.longest_streak := old.longest_streak;
    new.last_active_date := old.last_active_date;
    new.created_at := old.created_at;
    if new.timezone is distinct from old.timezone
       and not exists (select 1 from pg_catalog.pg_timezone_names where name = new.timezone) then
      raise exception 'invalid_timezone' using errcode = '22023';
    end if;
  end if;
  return new;
end $$;

create trigger profiles_guard before update on public.profiles
  for each row execute function private.guard_profile();

-- Only editors/admins can publish. Instructors can draft and submit for review.
create or replace function private.guard_publish()
returns trigger language plpgsql set search_path = '' as $$
begin
  if private.is_client_role() and not private.is_editor() then
    if new.status in ('published', 'archived')
       and (tg_op = 'INSERT' or new.status is distinct from old.status) then
      raise exception 'only_editors_can_publish' using errcode = '42501';
    end if;
  end if;
  return new;
end $$;

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
    setweight(to_tsvector('simple'::regconfig, coalesce(left(new.description, 4000), '')), 'C');
  return new;
end $$;

create or replace function private.sync_lesson_course()
returns trigger language plpgsql set search_path = '' as $$
begin
  select m.course_id into new.course_id from public.modules m where m.id = new.module_id;
  if new.course_id is null then
    raise exception 'module_not_found' using errcode = '23503';
  end if;
  return new;
end $$;

create or replace function private.guard_submission()
returns trigger language plpgsql set search_path = '' as $$
begin
  if private.is_client_role() and not private.is_staff() then
    if tg_op = 'INSERT' then
      new.user_id := (select auth.uid());
      new.status := 'submitted';
      new.score := null; new.feedback_md := null; new.reviewed_by := null; new.reviewed_at := null;
      new.submitted_at := now();
    else
      if old.status not in ('submitted', 'changes_requested') then
        raise exception 'submission_locked' using errcode = '42501';
      end if;
      new.user_id := old.user_id;
      new.assignment_id := old.assignment_id;
      new.status := 'submitted';
      new.score := old.score; new.feedback_md := old.feedback_md;
      new.reviewed_by := old.reviewed_by; new.reviewed_at := old.reviewed_at;
      new.submitted_at := now();
    end if;
  elsif tg_op = 'UPDATE' and private.is_client_role() and private.is_staff()
        and new.status is distinct from old.status and new.status in ('approved', 'changes_requested') then
    new.reviewed_by := (select auth.uid());
    new.reviewed_at := now();
  end if;
  return new;
end $$;

-- Last admin protection.
create or replace function private.guard_user_roles()
returns trigger language plpgsql set search_path = '' as $$
begin
  if old.role = 'admin' and (select count(*) from public.user_roles where role = 'admin') <= 1 then
    raise exception 'cannot_remove_last_admin' using errcode = '42501';
  end if;
  return old;
end $$;

-- ---------------------------------------------------------------------------
-- Counters
-- ---------------------------------------------------------------------------
create or replace function private.refresh_course_counters(p_course_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  update public.courses c set
    lesson_count = coalesce(s.cnt, 0),
    duration_seconds = coalesce(s.dur, 0)
  from (
    select count(*)::int as cnt, sum(l.duration_seconds)::int as dur
    from public.lessons l join public.modules m on m.id = l.module_id
    where l.course_id = p_course_id and l.status = 'published' and m.status = 'published'
  ) s
  where c.id = p_course_id
    and (c.lesson_count, c.duration_seconds) is distinct from (coalesce(s.cnt, 0), coalesce(s.dur, 0));
end $$;

create or replace function private.on_lesson_change()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if tg_op in ('UPDATE', 'DELETE') then
    perform private.refresh_course_counters(old.course_id);
  end if;
  if tg_op in ('INSERT', 'UPDATE') and (tg_op = 'INSERT' or new.course_id is distinct from old.course_id) then
    perform private.refresh_course_counters(new.course_id);
  end if;
  return null;
end $$;

create or replace function private.on_module_change()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  perform private.refresh_course_counters(coalesce(new.course_id, old.course_id));
  return null;
end $$;

create or replace function private.on_enrollment_change()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' then
    update public.courses set enrollment_count = enrollment_count + 1 where id = new.course_id;
  elsif tg_op = 'DELETE' then
    update public.courses set enrollment_count = greatest(enrollment_count - 1, 0) where id = old.course_id;
  end if;
  return null;
end $$;

-- ---------------------------------------------------------------------------
-- Audit log for direct content edits made through the API
-- ---------------------------------------------------------------------------
-- The trigger function runs as the invoker so private.is_client_role() reflects the
-- API caller; writing the row is delegated to a SECURITY DEFINER helper because
-- clients have no privileges on audit_log.
create or replace function private.write_audit(p_action text, p_entity text, p_row jsonb, p_old jsonb)
returns void language plpgsql security definer set search_path = '' as $$
begin
  insert into public.audit_log (actor_id, action, entity, entity_id, details)
  values (
    (select auth.uid()),
    p_action,
    p_entity,
    private.try_uuid(p_row ->> 'id'),
    jsonb_strip_nulls(jsonb_build_object(
      'title', p_row ->> 'title',
      'status', p_row ->> 'status',
      'previous_status', p_old ->> 'status'
    ))
  );
end $$;

create or replace function private.audit()
returns trigger language plpgsql set search_path = '' as $$
begin
  if private.is_client_role() then
    perform private.write_audit(
      lower(tg_op),
      tg_table_name,
      case when tg_op = 'DELETE' then to_jsonb(old) else to_jsonb(new) end,
      case when tg_op = 'UPDATE' then to_jsonb(old) else null end
    );
  end if;
  return null;
end $$;

-- ---------------------------------------------------------------------------
-- Learning engine internals
-- ---------------------------------------------------------------------------

-- Record learning time / XP for today and advance the streak.
create or replace function private.touch_activity(p_user uuid, p_seconds integer, p_lessons integer, p_xp integer)
returns void language plpgsql security definer set search_path = '' as $$
declare
  v_today date := private.local_today(p_user);
  v_last date;
  v_streak integer;
begin
  insert into public.daily_activity as d (user_id, activity_date, seconds_learned, lessons_completed, xp_earned)
  values (p_user, v_today, least(greatest(p_seconds, 0), 86400), greatest(p_lessons, 0), greatest(p_xp, 0))
  on conflict (user_id, activity_date) do update set
    seconds_learned = least(d.seconds_learned + excluded.seconds_learned, 86400),
    lessons_completed = d.lessons_completed + excluded.lessons_completed,
    xp_earned = d.xp_earned + excluded.xp_earned;

  select last_active_date, current_streak into v_last, v_streak from public.profiles where id = p_user for update;
  if v_last is null or v_last < v_today - 1 then
    v_streak := 1;
  elsif v_last = v_today - 1 then
    v_streak := v_streak + 1;
  end if; -- same day: unchanged

  update public.profiles set
    current_streak = v_streak,
    longest_streak = greatest(longest_streak, v_streak),
    last_active_date = greatest(coalesce(last_active_date, v_today), v_today),
    total_xp = total_xp + greatest(p_xp, 0)
  where id = p_user;
end $$;

create or replace function private.evaluate_achievements(p_user uuid)
returns setof public.achievements language plpgsql security definer set search_path = '' as $$
declare
  v_metrics jsonb;
  v_ach public.achievements;
  v_bonus integer := 0;
begin
  select jsonb_build_object(
    'lessons_completed', (select count(*) from public.lesson_progress where user_id = p_user and status = 'completed'),
    'courses_completed', (select count(*) from public.enrollments where user_id = p_user and status = 'completed'),
    'enrollments', (select count(*) from public.enrollments where user_id = p_user),
    'longest_streak', (select longest_streak from public.profiles where id = p_user),
    'quizzes_passed', (select count(distinct quiz_id) from public.quiz_attempts where user_id = p_user and passed),
    'perfect_quizzes', (select count(distinct quiz_id) from public.quiz_attempts where user_id = p_user and score_percent >= 100),
    'total_xp', (select total_xp from public.profiles where id = p_user),
    'certificates', (select count(*) from public.certificates where user_id = p_user and revoked_at is null),
    'minutes_learned', (select coalesce(sum(seconds_learned), 0) / 60 from public.daily_activity where user_id = p_user)
  ) into v_metrics;

  for v_ach in
    select a.* from public.achievements a
    where a.is_active
      and coalesce((v_metrics ->> (a.criteria ->> 'metric'))::numeric, 0) >= (a.criteria ->> 'gte')::numeric
      and not exists (select 1 from public.user_achievements ua where ua.user_id = p_user and ua.achievement_id = a.id)
    order by a.position
  loop
    insert into public.user_achievements (user_id, achievement_id) values (p_user, v_ach.id) on conflict do nothing;
    if found then
      v_bonus := v_bonus + v_ach.xp;
      insert into public.notifications (user_id, type, title, body, data)
      values (p_user, 'achievement', v_ach.title, v_ach.description,
              jsonb_build_object('achievement_id', v_ach.id, 'slug', v_ach.slug, 'tier', v_ach.tier));
      return next v_ach;
    end if;
  end loop;

  if v_bonus > 0 then
    update public.profiles set total_xp = total_xp + v_bonus where id = p_user;
  end if;
end $$;

-- Certificate issuance. Returns the certificate (existing or new) or null when not eligible.
create or replace function private.issue_certificate_if_eligible(p_user uuid, p_course uuid)
returns public.certificates language plpgsql security definer set search_path = '' as $$
declare
  v_course public.courses;
  v_cert public.certificates;
  v_enrollment public.enrollments;
  v_requires_premium boolean;
  v_name text;
  v_code text;
begin
  select * into v_cert from public.certificates where user_id = p_user and course_id = p_course;
  if found then return v_cert; end if;

  select * into v_course from public.courses where id = p_course;
  if not found or not v_course.certificate_enabled or v_course.status <> 'published' then return null; end if;

  select * into v_enrollment from public.enrollments where user_id = p_user and course_id = p_course;
  if not found or v_enrollment.status <> 'completed' then return null; end if;

  v_requires_premium := coalesce((private.setting('certificates') ->> 'require_premium')::boolean, true);
  if v_requires_premium and not private.has_premium(p_user) then return null; end if;

  select coalesce(nullif(trim(display_name), ''), 'Learner') into v_name from public.profiles where id = p_user;
  v_code := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12));

  insert into public.certificates (user_id, course_id, serial, verification_code, recipient_name, course_title, course_level, metadata)
  values (
    p_user, p_course,
    'MHR-' || to_char(now(), 'YYYY') || '-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8)),
    v_code, v_name, v_course.title, v_course.level,
    jsonb_build_object('lessons', v_enrollment.total_lessons, 'duration_seconds', v_course.duration_seconds)
  )
  on conflict (user_id, course_id) do nothing
  returning * into v_cert;

  if v_cert.id is not null then
    insert into public.notifications (user_id, type, title, body, data)
    values (p_user, 'course', 'Certificate earned', v_course.title,
            jsonb_build_object('certificate_id', v_cert.id, 'course_id', p_course));
  end if;
  return v_cert;
end $$;

-- Recalculate enrollment progress from lesson_progress. Completion also requires
-- passing every published final assessment of the course.
create or replace function private.recompute_enrollment(p_user uuid, p_course uuid)
returns public.enrollments language plpgsql security definer set search_path = '' as $$
declare
  v_total integer;
  v_done integer;
  v_finals_ok boolean;
  v_enrollment public.enrollments;
begin
  select count(*) into v_total
  from public.lessons l join public.modules m on m.id = l.module_id
  where l.course_id = p_course and l.status = 'published' and m.status = 'published' and l.is_required;

  select count(*) into v_done
  from public.lessons l
  join public.modules m on m.id = l.module_id
  join public.lesson_progress lp on lp.lesson_id = l.id and lp.user_id = p_user and lp.status = 'completed'
  where l.course_id = p_course and l.status = 'published' and m.status = 'published' and l.is_required;

  select not exists (
    select 1 from public.quizzes q
    where q.course_id = p_course and q.kind = 'final_assessment' and q.status = 'published'
      and not exists (select 1 from public.quiz_attempts a where a.quiz_id = q.id and a.user_id = p_user and a.passed)
  ) into v_finals_ok;

  update public.enrollments e set
    total_lessons = v_total,
    completed_lessons = v_done,
    progress_percent = case when v_total = 0 then 0 else round(v_done * 100.0 / v_total, 2) end,
    status = case
      when v_total > 0 and v_done >= v_total and v_finals_ok then 'completed'::public.enrollment_status
      when e.status = 'completed' then 'active'::public.enrollment_status -- new lessons were published
      else e.status end,
    completed_at = case
      when v_total > 0 and v_done >= v_total and v_finals_ok then coalesce(e.completed_at, now())
      else null end
  where e.user_id = p_user and e.course_id = p_course
  returning * into v_enrollment;

  return v_enrollment;
end $$;

create or replace function private.ensure_enrollment(p_user uuid, p_course uuid)
returns public.enrollments language plpgsql security definer set search_path = '' as $$
declare
  v_enrollment public.enrollments;
begin
  insert into public.enrollments (user_id, course_id)
  values (p_user, p_course)
  on conflict (user_id, course_id) do update set
    last_accessed_at = now(),
    status = case when public.enrollments.status = 'dropped' then 'active'::public.enrollment_status
                  else public.enrollments.status end
  returning * into v_enrollment;
  return v_enrollment;
end $$;

-- Mark a lesson complete for a user (idempotent). Returns true if newly completed.
create or replace function private.complete_lesson(p_user uuid, p_lesson uuid)
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  v_lesson public.lessons;
  v_was_completed boolean;
begin
  select * into v_lesson from public.lessons where id = p_lesson;
  if not found then raise exception 'lesson_not_found' using errcode = 'P0002'; end if;

  select coalesce(status = 'completed', false) into v_was_completed
  from public.lesson_progress where user_id = p_user and lesson_id = p_lesson;
  v_was_completed := coalesce(v_was_completed, false);

  insert into public.lesson_progress as lp (user_id, lesson_id, course_id, status, completed_at)
  values (p_user, p_lesson, v_lesson.course_id, 'completed', now())
  on conflict (user_id, lesson_id) do update set
    status = 'completed',
    completed_at = coalesce(lp.completed_at, now()),
    updated_at = now();

  if not v_was_completed then
    perform private.touch_activity(p_user, 0, 1, v_lesson.xp);
  end if;

  perform private.ensure_enrollment(p_user, v_lesson.course_id);
  update public.enrollments set last_lesson_id = p_lesson, last_accessed_at = now()
  where user_id = p_user and course_id = v_lesson.course_id;
  perform private.recompute_enrollment(p_user, v_lesson.course_id);
  perform private.issue_certificate_if_eligible(p_user, v_lesson.course_id);
  return not v_was_completed;
end $$;

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------
create trigger set_updated_at before update on public.profiles for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.categories for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.instructors for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.courses for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.learning_paths for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.modules for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.lessons for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.lesson_contents for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.videos for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.quizzes for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.questions for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.assignments for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.submissions for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.lesson_notes for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.subscription_plans for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.subscriptions for each row execute function private.set_updated_at();
create trigger set_updated_at before update on public.app_settings for each row execute function private.set_updated_at();

create trigger courses_guard before insert or update on public.courses for each row execute function private.guard_course();
create trigger lessons_sync_course before insert or update of module_id on public.lessons for each row execute function private.sync_lesson_course();
create trigger submissions_guard before insert or update on public.submissions for each row execute function private.guard_submission();
create trigger user_roles_guard before delete on public.user_roles for each row execute function private.guard_user_roles();

create trigger categories_publish_guard before insert or update of status on public.categories for each row execute function private.guard_publish();
create trigger courses_publish_guard before insert or update of status on public.courses for each row execute function private.guard_publish();
create trigger modules_publish_guard before insert or update of status on public.modules for each row execute function private.guard_publish();
create trigger lessons_publish_guard before insert or update of status on public.lessons for each row execute function private.guard_publish();
create trigger quizzes_publish_guard before insert or update of status on public.quizzes for each row execute function private.guard_publish();
create trigger assignments_publish_guard before insert or update of status on public.assignments for each row execute function private.guard_publish();
create trigger learning_paths_publish_guard before insert or update of status on public.learning_paths for each row execute function private.guard_publish();

create trigger lessons_counters after insert or update or delete on public.lessons for each row execute function private.on_lesson_change();
create trigger modules_counters after update of status or delete on public.modules for each row execute function private.on_module_change();
create trigger enrollments_counters after insert or delete on public.enrollments for each row execute function private.on_enrollment_change();

create trigger audit after insert or update or delete on public.categories for each row execute function private.audit();
create trigger audit after insert or update or delete on public.courses for each row execute function private.audit();
create trigger audit after insert or update or delete on public.modules for each row execute function private.audit();
create trigger audit after insert or update or delete on public.lessons for each row execute function private.audit();
create trigger audit after insert or update or delete on public.quizzes for each row execute function private.audit();
create trigger audit after insert or update or delete on public.assignments for each row execute function private.audit();
create trigger audit after insert or update or delete on public.subscription_plans for each row execute function private.audit();
create trigger audit after insert or update or delete on public.learning_paths for each row execute function private.audit();
