-- =============================================================================
-- Mahorat — Row Level Security
-- Principles
--   * Catalog: published content is readable by everyone (guests can browse).
--   * Teaching material (lesson bodies, media, resources) follows entitlement.
--   * Learner state is private to its owner; engine-computed state is written
--     only by SECURITY DEFINER routines (no client insert/update policies).
--   * Editors/admins manage all content; instructors manage their own courses
--     but cannot publish (see private.guard_publish).
--   * Row-independent helper calls are wrapped in (select …) so Postgres
--     evaluates them once per statement instead of once per row.
-- =============================================================================

-- Extra helpers used only by policies --------------------------------------------
create or replace function private.can_edit_lesson(p_lesson_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.lessons l where l.id = p_lesson_id and private.can_edit_course(l.course_id));
$$;

create or replace function private.can_edit_quiz(p_quiz_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.quizzes q where q.id = p_quiz_id and private.can_edit_course(q.course_id));
$$;

create or replace function private.can_edit_question(p_question_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.questions qn join public.quizzes q on q.id = qn.quiz_id
    where qn.id = p_question_id and private.can_edit_course(q.course_id)
  );
$$;

create or replace function private.can_edit_video(p_video_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select private.is_editor() or exists (
    select 1 from public.videos v where v.id = p_video_id and v.course_id is not null and private.can_edit_course(v.course_id)
  );
$$;

create or replace function private.can_view_video(p_video_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select private.can_edit_video(p_video_id) or exists (
    select 1 from public.lesson_contents lc where lc.video_id = p_video_id and private.can_access_lesson(lc.lesson_id)
  );
$$;

create or replace function private.assignment_course(p_assignment_id uuid)
returns uuid language sql stable security definer set search_path = '' as $$
  select course_id from public.assignments where id = p_assignment_id;
$$;

create or replace function private.quiz_course(p_quiz_id uuid)
returns uuid language sql stable security definer set search_path = '' as $$
  select course_id from public.quizzes where id = p_quiz_id;
$$;

create or replace function private.my_instructor_ids()
returns setof uuid language sql stable security definer set search_path = '' as $$
  select id from public.instructors where profile_id = (select auth.uid());
$$;

-- Bookmarks carry course_id for fast filtering; derive it from the lesson.
create or replace function private.sync_course_from_lesson()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  select l.course_id into new.course_id from public.lessons l where l.id = new.lesson_id;
  if new.course_id is null then raise exception 'lesson_not_found' using errcode = '23503'; end if;
  return new;
end $$;
create trigger bookmarks_sync_course before insert or update of lesson_id on public.bookmarks
  for each row execute function private.sync_course_from_lesson();

-- Instructors may edit their public bio but not verification/ownership fields.
create or replace function private.guard_instructor()
returns trigger language plpgsql set search_path = '' as $$
begin
  if private.is_client_role() and not private.is_editor() then
    new.is_verified := old.is_verified;
    new.profile_id := old.profile_id;
    new.slug := old.slug;
  end if;
  return new;
end $$;
create trigger instructors_guard before update on public.instructors
  for each row execute function private.guard_instructor();

-- Enable RLS everywhere ------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.categories enable row level security;
alter table public.instructors enable row level security;
alter table public.courses enable row level security;
alter table public.course_prerequisites enable row level security;
alter table public.learning_paths enable row level security;
alter table public.learning_path_courses enable row level security;
alter table public.modules enable row level security;
alter table public.lessons enable row level security;
alter table public.videos enable row level security;
alter table public.video_sources enable row level security;
alter table public.video_captions enable row level security;
alter table public.lesson_contents enable row level security;
alter table public.resources enable row level security;
alter table public.quizzes enable row level security;
alter table public.questions enable row level security;
alter table public.answers enable row level security;
alter table public.quiz_attempts enable row level security;
alter table public.assignments enable row level security;
alter table public.submissions enable row level security;
alter table public.enrollments enable row level security;
alter table public.lesson_progress enable row level security;
alter table public.daily_activity enable row level security;
alter table public.bookmarks enable row level security;
alter table public.lesson_notes enable row level security;
alter table public.certificates enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;
alter table public.subscription_plans enable row level security;
alter table public.subscriptions enable row level security;
alter table public.app_settings enable row level security;
alter table public.notifications enable row level security;
alter table public.notification_reads enable row level security;
alter table public.push_tokens enable row level security;
alter table public.audit_log enable row level security;

-- Identity ----------------------------------------------------------------------
create policy "profiles: read own or staff" on public.profiles for select to authenticated
  using (id = (select auth.uid()) or (select private.is_staff()));
create policy "profiles: update own or admin" on public.profiles for update to authenticated
  using (id = (select auth.uid()) or (select private.is_admin()))
  with check (id = (select auth.uid()) or (select private.is_admin()));

create policy "roles: read own or admin" on public.user_roles for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_admin()));
create policy "roles: admin insert" on public.user_roles for insert to authenticated
  with check ((select private.is_admin()));
create policy "roles: admin delete" on public.user_roles for delete to authenticated
  using ((select private.is_admin()));

-- Catalog -----------------------------------------------------------------------
create policy "categories: read published" on public.categories for select to anon, authenticated
  using (status = 'published' or (select private.is_editor()));
create policy "categories: editors write" on public.categories for all to authenticated
  using ((select private.is_editor())) with check ((select private.is_editor()));

create policy "instructors: public read" on public.instructors for select to anon, authenticated
  using (true);
create policy "instructors: editors insert" on public.instructors for insert to authenticated
  with check ((select private.is_editor()));
create policy "instructors: editors or self update" on public.instructors for update to authenticated
  using ((select private.is_editor()) or profile_id = (select auth.uid()))
  with check ((select private.is_editor()) or profile_id = (select auth.uid()));
create policy "instructors: editors delete" on public.instructors for delete to authenticated
  using ((select private.is_editor()));

-- Ownership is checked against the row's own instructor_id (not a lookup by id) so the
-- policy also holds for rows being inserted/returned in the same statement.
create policy "courses: read published or editable" on public.courses for select to anon, authenticated
  using (
    status = 'published'
    or (select private.is_editor())
    or ((select private.has_any_role(array['instructor']::public.app_role[]))
        and instructor_id in (select private.my_instructor_ids()))
  );
create policy "courses: editors or own instructor insert" on public.courses for insert to authenticated
  with check (
    (select private.is_editor())
    or ((select private.has_any_role(array['instructor']::public.app_role[]))
        and instructor_id in (select private.my_instructor_ids()))
  );
create policy "courses: editable update" on public.courses for update to authenticated
  using (
    (select private.is_editor())
    or ((select private.has_any_role(array['instructor']::public.app_role[]))
        and instructor_id in (select private.my_instructor_ids()))
  )
  with check (
    (select private.is_editor())
    or ((select private.has_any_role(array['instructor']::public.app_role[]))
        and instructor_id in (select private.my_instructor_ids()))
  );
create policy "courses: editors delete" on public.courses for delete to authenticated
  using ((select private.is_editor()));

create policy "prerequisites: public read" on public.course_prerequisites for select to anon, authenticated
  using (private.course_is_public(course_id) or private.can_edit_course(course_id));
create policy "prerequisites: editable write" on public.course_prerequisites for all to authenticated
  using (private.can_edit_course(course_id)) with check (private.can_edit_course(course_id));

create policy "paths: read published" on public.learning_paths for select to anon, authenticated
  using (status = 'published' or (select private.is_editor()));
create policy "paths: editors write" on public.learning_paths for all to authenticated
  using ((select private.is_editor())) with check ((select private.is_editor()));

create policy "path courses: read published" on public.learning_path_courses for select to anon, authenticated
  using (
    (select private.is_editor())
    or exists (select 1 from public.learning_paths p where p.id = path_id and p.status = 'published')
  );
create policy "path courses: editors write" on public.learning_path_courses for all to authenticated
  using ((select private.is_editor())) with check ((select private.is_editor()));

create policy "modules: read published" on public.modules for select to anon, authenticated
  using ((status = 'published' and private.course_is_public(course_id)) or private.can_edit_course(course_id));
create policy "modules: editable write" on public.modules for all to authenticated
  using (private.can_edit_course(course_id)) with check (private.can_edit_course(course_id));

create policy "lessons: read published" on public.lessons for select to anon, authenticated
  using (private.lesson_is_public(id) or private.can_edit_course(course_id));
create policy "lessons: editable write" on public.lessons for all to authenticated
  using (private.can_edit_course(course_id)) with check (private.can_edit_course(course_id));

-- Teaching material ---------------------------------------------------------------
create policy "lesson contents: entitled read" on public.lesson_contents for select to anon, authenticated
  using (private.can_access_lesson(lesson_id));
create policy "lesson contents: editable write" on public.lesson_contents for all to authenticated
  using (private.can_edit_lesson(lesson_id)) with check (private.can_edit_lesson(lesson_id));

create policy "videos: entitled read" on public.videos for select to anon, authenticated
  using (private.can_view_video(id));
create policy "videos: editable insert" on public.videos for insert to authenticated
  with check ((select private.is_editor()) or (course_id is not null and private.can_edit_course(course_id)));
create policy "videos: editable update" on public.videos for update to authenticated
  using (private.can_edit_video(id))
  with check ((select private.is_editor()) or (course_id is not null and private.can_edit_course(course_id)));
create policy "videos: editable delete" on public.videos for delete to authenticated
  using (private.can_edit_video(id));

create policy "video sources: entitled read" on public.video_sources for select to anon, authenticated
  using (private.can_view_video(video_id));
create policy "video sources: editable write" on public.video_sources for all to authenticated
  using (private.can_edit_video(video_id)) with check (private.can_edit_video(video_id));

create policy "captions: entitled read" on public.video_captions for select to anon, authenticated
  using (private.can_view_video(video_id));
create policy "captions: editable write" on public.video_captions for all to authenticated
  using (private.can_edit_video(video_id)) with check (private.can_edit_video(video_id));

create policy "resources: entitled read" on public.resources for select to anon, authenticated
  using (
    case when lesson_id is not null then private.can_access_lesson(lesson_id)
         else private.can_access_course(course_id) end
  );
create policy "resources: editable write" on public.resources for all to authenticated
  using (private.can_edit_course(course_id)) with check (private.can_edit_course(course_id));

-- Assessments ---------------------------------------------------------------------
create policy "quizzes: read published" on public.quizzes for select to anon, authenticated
  using ((status = 'published' and private.course_is_public(course_id)) or private.can_edit_course(course_id));
create policy "quizzes: editable write" on public.quizzes for all to authenticated
  using (private.can_edit_course(course_id)) with check (private.can_edit_course(course_id));

-- Students never read questions/answers directly (answer keys!). They use the
-- public.get_quiz / public.submit_quiz_attempt RPCs.
create policy "questions: editors only" on public.questions for all to authenticated
  using (private.can_edit_quiz(quiz_id)) with check (private.can_edit_quiz(quiz_id));
create policy "answers: editors only" on public.answers for all to authenticated
  using (private.can_edit_question(question_id)) with check (private.can_edit_question(question_id));

create policy "attempts: read own or course staff" on public.quiz_attempts for select to authenticated
  using (user_id = (select auth.uid()) or private.can_edit_course(private.quiz_course(quiz_id)));

create policy "assignments: read published" on public.assignments for select to anon, authenticated
  using ((status = 'published' and private.course_is_public(course_id)) or private.can_edit_course(course_id));
create policy "assignments: editable write" on public.assignments for all to authenticated
  using (private.can_edit_course(course_id)) with check (private.can_edit_course(course_id));

create policy "submissions: read own or course staff" on public.submissions for select to authenticated
  using (user_id = (select auth.uid()) or private.can_edit_course(private.assignment_course(assignment_id)));
create policy "submissions: insert own" on public.submissions for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.assignments a
      where a.id = assignment_id and a.status = 'published' and private.can_access_course(a.course_id)
    )
  );
create policy "submissions: update own or course staff" on public.submissions for update to authenticated
  using (user_id = (select auth.uid()) or private.can_edit_course(private.assignment_course(assignment_id)))
  with check (user_id = (select auth.uid()) or private.can_edit_course(private.assignment_course(assignment_id)));
create policy "submissions: delete own pending" on public.submissions for delete to authenticated
  using (user_id = (select auth.uid()) and status = 'submitted');

-- Learner state -------------------------------------------------------------------
create policy "enrollments: read own or course staff" on public.enrollments for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_editor()) or private.owns_course(course_id));

create policy "progress: read own or editors" on public.lesson_progress for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_editor()));

create policy "activity: read own" on public.daily_activity for select to authenticated
  using (user_id = (select auth.uid()));

create policy "bookmarks: own" on public.bookmarks for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()) and private.lesson_is_public(lesson_id));

create policy "notes: own" on public.lesson_notes for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()) and private.lesson_is_public(lesson_id));

create policy "certificates: read own or editors" on public.certificates for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_editor()));
create policy "certificates: admins revoke" on public.certificates for update to authenticated
  using ((select private.is_admin())) with check ((select private.is_admin()));

create policy "achievements: read active" on public.achievements for select to anon, authenticated
  using (is_active or (select private.is_editor()));
create policy "achievements: editors write" on public.achievements for all to authenticated
  using ((select private.is_editor())) with check ((select private.is_editor()));

create policy "user achievements: read own" on public.user_achievements for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_editor()));

-- Billing -------------------------------------------------------------------------
create policy "plans: read active" on public.subscription_plans for select to anon, authenticated
  using (is_active or (select private.is_admin()));
create policy "plans: admins write" on public.subscription_plans for all to authenticated
  using ((select private.is_admin())) with check ((select private.is_admin()));

create policy "subscriptions: read own or admin" on public.subscriptions for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_admin()));

-- Operations ----------------------------------------------------------------------
create policy "settings: read public" on public.app_settings for select to anon, authenticated
  using (is_public or (select private.is_admin()));
create policy "settings: admins write" on public.app_settings for all to authenticated
  using ((select private.is_admin())) with check ((select private.is_admin()));

create policy "notifications: read own and broadcasts" on public.notifications for select to authenticated
  using (user_id = (select auth.uid()) or user_id is null or (select private.is_admin()));
create policy "notifications: admins write" on public.notifications for all to authenticated
  using ((select private.is_admin())) with check ((select private.is_admin()));

create policy "notification reads: own" on public.notification_reads for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy "push tokens: own" on public.push_tokens for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy "audit: admins read" on public.audit_log for select to authenticated
  using ((select private.is_admin()));

-- Table privileges ------------------------------------------------------------------
-- Supabase grants broad table privileges to anon/authenticated by default; RLS is
-- the gate. We additionally strip write privileges from anon entirely.
revoke insert, update, delete, truncate on all tables in schema public from anon;
revoke truncate on all tables in schema public from authenticated;
-- Engine-owned tables: no direct client writes at all.
revoke insert, update, delete on public.enrollments, public.lesson_progress, public.daily_activity,
  public.quiz_attempts, public.user_achievements, public.subscriptions, public.audit_log
  from authenticated;
revoke insert, delete on public.profiles, public.certificates from authenticated;

-- Internal engine routines are not callable by API roles.
revoke execute on function
  private.touch_activity(uuid, integer, integer, integer),
  private.evaluate_achievements(uuid),
  private.issue_certificate_if_eligible(uuid, uuid),
  private.recompute_enrollment(uuid, uuid),
  private.ensure_enrollment(uuid, uuid),
  private.complete_lesson(uuid, uuid),
  private.refresh_course_counters(uuid),
  private.handle_new_user()
  from public, anon, authenticated;

-- =============================================================================
-- Storage
--   public-media  (public)  covers/<course_id>/…, categories/…, instructors/…, paths/…
--   avatars       (public)  <user_id>/…
--   course-media  (private) <course_id>/<lesson_id|shared>/…  videos, captions, posters
--   resources     (private) <course_id>/<lesson_id|course>/…  PDFs, archives, project files
--   submissions   (private) <user_id>/<assignment_id>/…
-- =============================================================================
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('public-media', 'public-media', true, 10485760, array['image/png', 'image/jpeg', 'image/webp', 'image/avif', 'image/svg+xml']),
  ('avatars', 'avatars', true, 2097152, array['image/png', 'image/jpeg', 'image/webp']),
  ('course-media', 'course-media', false, 5368709120, array['video/mp4', 'video/quicktime', 'application/vnd.apple.mpegurl', 'application/x-mpegURL', 'video/mp2t', 'text/vtt', 'image/png', 'image/jpeg', 'image/webp']),
  ('resources', 'resources', false, 524288000, null),
  ('submissions', 'submissions', false, 52428800, null)
on conflict (id) do nothing;

create or replace function private.storage_course_id(p_name text)
returns uuid language sql stable set search_path = '' as $$
  select private.try_uuid((storage.foldername(p_name))[1]);
$$;

create or replace function private.storage_second_segment(p_name text)
returns text language sql stable set search_path = '' as $$
  select (storage.foldername(p_name))[2];
$$;

-- public-media: anyone reads (public bucket); editors write everything, instructors write their course covers.
create policy "public-media: editors write" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'public-media' and (
      (select private.is_editor())
      or ((storage.foldername(name))[1] = 'covers' and private.owns_course(private.try_uuid((storage.foldername(name))[2])))
    )
  );
create policy "public-media: editors update" on storage.objects for update to authenticated
  using (bucket_id = 'public-media' and (select private.is_editor()));
create policy "public-media: editors delete" on storage.objects for delete to authenticated
  using (bucket_id = 'public-media' and (select private.is_editor()));

-- avatars: users manage files in their own folder.
create policy "avatars: own write" on storage.objects for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "avatars: own update" on storage.objects for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "avatars: own delete" on storage.objects for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- course-media: entitled learners can read (e.g. create signed URLs); course editors write.
create policy "course-media: entitled read" on storage.objects for select to anon, authenticated
  using (
    bucket_id = 'course-media' and (
      private.can_edit_course(private.storage_course_id(name))
      or (private.storage_second_segment(name) = 'shared' and private.can_access_course(private.storage_course_id(name)))
      or private.can_access_lesson(private.try_uuid(private.storage_second_segment(name)))
    )
  );
create policy "course-media: editors write" on storage.objects for insert to authenticated
  with check (bucket_id = 'course-media' and private.can_edit_course(private.storage_course_id(name)));
create policy "course-media: editors update" on storage.objects for update to authenticated
  using (bucket_id = 'course-media' and private.can_edit_course(private.storage_course_id(name)));
create policy "course-media: editors delete" on storage.objects for delete to authenticated
  using (bucket_id = 'course-media' and private.can_edit_course(private.storage_course_id(name)));

create policy "resources: entitled read" on storage.objects for select to anon, authenticated
  using (
    bucket_id = 'resources' and (
      private.can_edit_course(private.storage_course_id(name))
      or (private.storage_second_segment(name) = 'course' and private.can_access_course(private.storage_course_id(name)))
      or private.can_access_lesson(private.try_uuid(private.storage_second_segment(name)))
    )
  );
create policy "resources: editors write" on storage.objects for insert to authenticated
  with check (bucket_id = 'resources' and private.can_edit_course(private.storage_course_id(name)));
create policy "resources: editors update" on storage.objects for update to authenticated
  using (bucket_id = 'resources' and private.can_edit_course(private.storage_course_id(name)));
create policy "resources: editors delete" on storage.objects for delete to authenticated
  using (bucket_id = 'resources' and private.can_edit_course(private.storage_course_id(name)));

-- submissions: learners upload into their own folder; course staff can read.
create policy "submissions: own write" on storage.objects for insert to authenticated
  with check (bucket_id = 'submissions' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "submissions: own or staff read" on storage.objects for select to authenticated
  using (
    bucket_id = 'submissions' and (
      (storage.foldername(name))[1] = (select auth.uid())::text
      or private.can_edit_course(private.assignment_course(private.try_uuid((storage.foldername(name))[2])))
    )
  );
create policy "submissions: own delete" on storage.objects for delete to authenticated
  using (bucket_id = 'submissions' and (storage.foldername(name))[1] = (select auth.uid())::text);
