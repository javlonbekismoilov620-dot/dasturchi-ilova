-- =============================================================================
-- Mahorat — core schema
-- Educational ecosystem: catalog (categories → courses → modules → lessons),
-- assessments (quizzes, assignments), learner state (enrollments, progress,
-- streaks, achievements, certificates), billing (plans, subscriptions) and
-- operations (notifications, settings, audit log).
--
-- Conventions
--   * public  schema: tables + client-callable RPCs exposed through PostgREST.
--   * private schema: helper/trigger functions. NOT exposed through the API.
--   * Every table has RLS enabled (see 20261113000300_rls.sql).
-- =============================================================================

create extension if not exists pg_trgm with schema extensions;

create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Enumerations
-- ---------------------------------------------------------------------------
create type public.app_role as enum ('student', 'instructor', 'editor', 'admin');
create type public.content_status as enum ('draft', 'in_review', 'published', 'archived');
-- The learning ladder: ZERO → BEGINNER → INTERMEDIATE → ADVANCED → PROFESSIONAL → EXPERT
create type public.difficulty_level as enum ('zero', 'beginner', 'intermediate', 'advanced', 'professional', 'expert');
create type public.access_tier as enum ('free', 'premium');
create type public.lesson_type as enum ('video', 'article', 'exercise', 'quiz', 'assignment', 'project');
create type public.question_type as enum ('single_choice', 'multiple_choice', 'true_false', 'short_answer');
create type public.quiz_kind as enum ('knowledge_check', 'module_exam', 'final_assessment');
create type public.progress_status as enum ('not_started', 'in_progress', 'completed');
create type public.enrollment_status as enum ('active', 'completed', 'dropped');
create type public.submission_status as enum ('submitted', 'in_review', 'approved', 'changes_requested');
create type public.submission_type as enum ('text', 'url', 'file', 'any');
create type public.subscription_status as enum ('active', 'in_grace_period', 'in_billing_retry', 'paused', 'cancelled', 'expired', 'refunded');
create type public.store_platform as enum ('app_store', 'play_store', 'stripe', 'promotional', 'manual');
create type public.billing_interval as enum ('month', 'year', 'lifetime');
create type public.media_provider as enum ('storage', 'mux', 'cloudflare_stream', 'external');
create type public.media_status as enum ('processing', 'ready', 'failed');
create type public.resource_kind as enum ('pdf', 'archive', 'image', 'code', 'link', 'document', 'other');
create type public.notification_type as enum ('system', 'course', 'achievement', 'reminder', 'announcement');
create type public.achievement_tier as enum ('bronze', 'silver', 'gold', 'platinum');

-- ---------------------------------------------------------------------------
-- Identity
-- ---------------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text check (char_length(display_name) <= 80),
  username text unique check (username ~ '^[a-z0-9_]{3,30}$'),
  avatar_path text check (char_length(avatar_path) <= 300),
  bio text check (char_length(bio) <= 500),
  locale text not null default 'en' check (locale in ('en', 'uz', 'ru')),
  timezone text not null default 'UTC' check (char_length(timezone) <= 64),
  experience_level public.difficulty_level not null default 'zero',
  interests text[] not null default '{}' check (cardinality(interests) <= 30),
  learning_goal text check (learning_goal in ('career', 'switch', 'school', 'business', 'hobby')),
  daily_goal_minutes integer not null default 15 check (daily_goal_minutes between 5 and 240),
  onboarding_completed_at timestamptz,
  -- Computed by the learning engine (clients cannot write these; see guard trigger).
  total_xp integer not null default 0 check (total_xp >= 0),
  current_streak integer not null default 0 check (current_streak >= 0),
  longest_streak integer not null default 0 check (longest_streak >= 0),
  last_active_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.profiles is 'Public learner profile, 1:1 with auth.users.';

create table public.user_roles (
  user_id uuid not null references public.profiles (id) on delete cascade,
  role public.app_role not null,
  granted_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (user_id, role)
);
comment on table public.user_roles is 'Role assignments. Only admins may write. Every user gets "student" on signup.';

-- ---------------------------------------------------------------------------
-- Catalog
-- ---------------------------------------------------------------------------
create table public.categories (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid references public.categories (id) on delete cascade,
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' and char_length(slug) <= 80),
  title text not null check (char_length(title) between 1 and 120),
  subtitle text check (char_length(subtitle) <= 200),
  description text check (char_length(description) <= 4000),
  icon text check (char_length(icon) <= 60),            -- icon key understood by clients
  color text check (color ~ '^#[0-9A-Fa-f]{6}$'),        -- signature hue for covers/accents
  position integer not null default 0 check (position >= 0),
  is_featured boolean not null default false,
  status public.content_status not null default 'published',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (parent_id is null or parent_id <> id)
);
comment on table public.categories is 'Top-level categories (parent_id null) and subcategories (parent_id set). Admin-extensible.';
create index categories_parent_idx on public.categories (parent_id, position);

create table public.instructors (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid unique references public.profiles (id) on delete set null,
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  name text not null check (char_length(name) between 1 and 120),
  headline text check (char_length(headline) <= 200),
  bio text check (char_length(bio) <= 4000),
  avatar_path text,
  website_url text check (website_url ~ '^https?://'),
  socials jsonb not null default '{}'::jsonb,
  is_verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.courses (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' and char_length(slug) <= 100),
  title text not null check (char_length(title) between 1 and 160),
  subtitle text check (char_length(subtitle) <= 240),
  description text check (char_length(description) <= 20000),
  category_id uuid not null references public.categories (id) on delete restrict,
  subcategory_id uuid references public.categories (id) on delete set null,
  instructor_id uuid references public.instructors (id) on delete set null,
  level public.difficulty_level not null default 'zero',
  access_tier public.access_tier not null default 'free',
  status public.content_status not null default 'draft',
  language text not null default 'en' check (language in ('en', 'uz', 'ru')),
  cover_path text,
  -- Parameters for the generative cover art rendered by clients when no image exists.
  cover_style jsonb not null default '{}'::jsonb,
  estimated_minutes integer check (estimated_minutes between 0 and 100000),
  learning_outcomes text[] not null default '{}' check (cardinality(learning_outcomes) <= 30),
  prerequisites text[] not null default '{}' check (cardinality(prerequisites) <= 20),
  tags text[] not null default '{}' check (cardinality(tags) <= 20),
  is_featured boolean not null default false,
  -- Honesty flag: false while the curriculum is still being produced.
  content_complete boolean not null default false,
  certificate_enabled boolean not null default true,
  -- Maintained by triggers.
  lesson_count integer not null default 0,
  duration_seconds integer not null default 0,
  enrollment_count integer not null default 0,
  search_vector tsvector,
  published_at timestamptz,
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index courses_category_idx on public.courses (category_id, status);
create index courses_subcategory_idx on public.courses (subcategory_id);
create index courses_instructor_idx on public.courses (instructor_id);
create index courses_status_featured_idx on public.courses (status, is_featured, enrollment_count desc);
create index courses_search_idx on public.courses using gin (search_vector);
create index courses_title_trgm_idx on public.courses using gin (title extensions.gin_trgm_ops);

create table public.course_prerequisites (
  course_id uuid not null references public.courses (id) on delete cascade,
  prerequisite_course_id uuid not null references public.courses (id) on delete cascade,
  primary key (course_id, prerequisite_course_id),
  check (course_id <> prerequisite_course_id)
);

create table public.learning_paths (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  title text not null check (char_length(title) between 1 and 160),
  subtitle text check (char_length(subtitle) <= 240),
  description text check (char_length(description) <= 10000),
  category_id uuid references public.categories (id) on delete set null,
  level_from public.difficulty_level not null default 'zero',
  level_to public.difficulty_level not null default 'professional',
  access_tier public.access_tier not null default 'free',
  status public.content_status not null default 'draft',
  cover_style jsonb not null default '{}'::jsonb,
  position integer not null default 0,
  is_featured boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.learning_path_courses (
  path_id uuid not null references public.learning_paths (id) on delete cascade,
  course_id uuid not null references public.courses (id) on delete cascade,
  position integer not null default 0,
  primary key (path_id, course_id)
);
create index learning_path_courses_course_idx on public.learning_path_courses (course_id);

create table public.modules (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses (id) on delete cascade,
  title text not null check (char_length(title) between 1 and 160),
  description text check (char_length(description) <= 4000),
  position integer not null default 0 check (position >= 0),
  status public.content_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index modules_course_idx on public.modules (course_id, position);

create table public.lessons (
  id uuid primary key default gen_random_uuid(),
  module_id uuid not null references public.modules (id) on delete cascade,
  course_id uuid not null references public.courses (id) on delete cascade, -- denormalised by trigger
  title text not null check (char_length(title) between 1 and 160),
  summary text check (char_length(summary) <= 1000),
  type public.lesson_type not null default 'article',
  position integer not null default 0 check (position >= 0),
  duration_seconds integer not null default 0 check (duration_seconds between 0 and 86400),
  is_preview boolean not null default false,   -- free preview inside a premium course
  is_required boolean not null default true,   -- counts toward completion
  xp integer not null default 10 check (xp between 0 and 1000),
  status public.content_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index lessons_module_idx on public.lessons (module_id, position);
create index lessons_course_idx on public.lessons (course_id, status);

-- Media -----------------------------------------------------------------------
create table public.videos (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references public.courses (id) on delete cascade,
  title text check (char_length(title) <= 200),
  provider public.media_provider not null default 'storage',
  storage_path text,        -- provider=storage: object key in the private "course-media" bucket
  external_id text,         -- provider=mux|cloudflare_stream: playback id
  external_url text check (external_url ~ '^https://'), -- provider=external: HTTPS HLS/MP4 URL
  poster_path text,
  duration_seconds integer check (duration_seconds >= 0),
  width integer,
  height integer,
  status public.media_status not null default 'ready',
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (
    (provider = 'storage' and storage_path is not null) or
    (provider in ('mux', 'cloudflare_stream') and external_id is not null) or
    (provider = 'external' and external_url is not null)
  )
);
create index videos_course_idx on public.videos (course_id);

-- Optional progressive renditions for quality selection when HLS is not used.
create table public.video_sources (
  id uuid primary key default gen_random_uuid(),
  video_id uuid not null references public.videos (id) on delete cascade,
  quality text not null check (quality ~ '^[0-9]{3,4}p$'),
  storage_path text not null,
  bitrate_kbps integer,
  unique (video_id, quality)
);

create table public.video_captions (
  id uuid primary key default gen_random_uuid(),
  video_id uuid not null references public.videos (id) on delete cascade,
  language text not null check (char_length(language) between 2 and 10),
  label text not null check (char_length(label) <= 60),
  storage_path text not null, -- WebVTT file in "course-media"
  unique (video_id, language)
);

-- Gated lesson body: split from public lesson metadata so the curriculum can be
-- shown to everyone while the teaching material itself follows entitlement rules.
create table public.lesson_contents (
  lesson_id uuid primary key references public.lessons (id) on delete cascade,
  body_md text check (char_length(body_md) <= 200000),
  video_id uuid references public.videos (id) on delete set null,
  transcript_md text check (char_length(transcript_md) <= 400000),
  updated_at timestamptz not null default now()
);
create index lesson_contents_video_idx on public.lesson_contents (video_id);

create table public.resources (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses (id) on delete cascade,
  lesson_id uuid references public.lessons (id) on delete cascade,
  title text not null check (char_length(title) between 1 and 200),
  description text check (char_length(description) <= 1000),
  kind public.resource_kind not null default 'other',
  storage_path text,   -- object key in private "resources" bucket
  external_url text check (external_url ~ '^https://'),
  size_bytes bigint check (size_bytes >= 0),
  mime_type text,
  allow_offline boolean not null default true,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  check (storage_path is not null or external_url is not null)
);
create index resources_course_idx on public.resources (course_id);
create index resources_lesson_idx on public.resources (lesson_id);

-- ---------------------------------------------------------------------------
-- Assessments
-- ---------------------------------------------------------------------------
create table public.quizzes (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses (id) on delete cascade,
  module_id uuid references public.modules (id) on delete cascade,
  lesson_id uuid references public.lessons (id) on delete cascade,
  title text not null check (char_length(title) between 1 and 160),
  description text check (char_length(description) <= 4000),
  kind public.quiz_kind not null default 'knowledge_check',
  pass_score_percent integer not null default 70 check (pass_score_percent between 0 and 100),
  time_limit_seconds integer check (time_limit_seconds > 0),
  max_attempts integer check (max_attempts > 0),
  shuffle_questions boolean not null default false,
  xp integer not null default 20 check (xp between 0 and 1000),
  status public.content_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index quizzes_course_idx on public.quizzes (course_id, kind);
create index quizzes_lesson_idx on public.quizzes (lesson_id);
create index quizzes_module_idx on public.quizzes (module_id);

create table public.questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.quizzes (id) on delete cascade,
  type public.question_type not null default 'single_choice',
  prompt_md text not null check (char_length(prompt_md) between 1 and 8000),
  code_snippet text check (char_length(code_snippet) <= 8000),
  explanation_md text check (char_length(explanation_md) <= 8000),
  points integer not null default 1 check (points between 1 and 100),
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index questions_quiz_idx on public.questions (quiz_id, position);

-- Answer options. For short_answer questions, rows with is_correct = true are the
-- accepted answers (compared case/whitespace-insensitively).
create table public.answers (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions (id) on delete cascade,
  label_md text not null check (char_length(label_md) between 1 and 2000),
  is_correct boolean not null default false,
  feedback_md text check (char_length(feedback_md) <= 4000), -- why this option is right/wrong
  position integer not null default 0
);
create index answers_question_idx on public.answers (question_id, position);

create table public.quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.quizzes (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  responses jsonb not null default '{}'::jsonb,
  results jsonb not null default '[]'::jsonb,
  points_earned integer not null default 0,
  points_possible integer not null default 0,
  score_percent numeric(5, 2) not null default 0,
  passed boolean not null default false,
  started_at timestamptz,
  submitted_at timestamptz not null default now()
);
create index quiz_attempts_user_quiz_idx on public.quiz_attempts (user_id, quiz_id, submitted_at desc);
create index quiz_attempts_quiz_idx on public.quiz_attempts (quiz_id);

create table public.assignments (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses (id) on delete cascade,
  module_id uuid references public.modules (id) on delete cascade,
  lesson_id uuid references public.lessons (id) on delete cascade,
  title text not null check (char_length(title) between 1 and 160),
  brief_md text check (char_length(brief_md) <= 20000),
  rubric_md text check (char_length(rubric_md) <= 20000),
  submission_type public.submission_type not null default 'any',
  is_project boolean not null default false,
  max_score integer not null default 100 check (max_score between 1 and 1000),
  status public.content_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index assignments_course_idx on public.assignments (course_id);
create index assignments_lesson_idx on public.assignments (lesson_id);
create index assignments_module_idx on public.assignments (module_id);

create table public.submissions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid not null references public.assignments (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  body_md text check (char_length(body_md) <= 50000),
  url text check (url ~ '^https?://' and char_length(url) <= 2000),
  file_paths text[] not null default '{}' check (cardinality(file_paths) <= 10),
  status public.submission_status not null default 'submitted',
  score integer check (score >= 0),
  feedback_md text check (char_length(feedback_md) <= 20000),
  reviewed_by uuid references public.profiles (id) on delete set null,
  reviewed_at timestamptz,
  submitted_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (body_md is not null or url is not null or cardinality(file_paths) > 0)
);
create index submissions_assignment_idx on public.submissions (assignment_id, status);
create index submissions_user_idx on public.submissions (user_id, submitted_at desc);
create index submissions_status_idx on public.submissions (status, submitted_at);

-- ---------------------------------------------------------------------------
-- Learner state
-- ---------------------------------------------------------------------------
create table public.enrollments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  course_id uuid not null references public.courses (id) on delete cascade,
  status public.enrollment_status not null default 'active',
  progress_percent numeric(5, 2) not null default 0 check (progress_percent between 0 and 100),
  completed_lessons integer not null default 0,
  total_lessons integer not null default 0,
  last_lesson_id uuid references public.lessons (id) on delete set null,
  last_accessed_at timestamptz not null default now(),
  enrolled_at timestamptz not null default now(),
  completed_at timestamptz,
  unique (user_id, course_id)
);
create index enrollments_course_idx on public.enrollments (course_id);
create index enrollments_user_recent_idx on public.enrollments (user_id, last_accessed_at desc);

create table public.lesson_progress (
  user_id uuid not null references public.profiles (id) on delete cascade,
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  course_id uuid not null references public.courses (id) on delete cascade,
  status public.progress_status not null default 'in_progress',
  position_seconds integer not null default 0 check (position_seconds >= 0),
  seconds_spent integer not null default 0 check (seconds_spent >= 0),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, lesson_id)
);
create index lesson_progress_user_recent_idx on public.lesson_progress (user_id, updated_at desc);
create index lesson_progress_course_idx on public.lesson_progress (user_id, course_id);
create index lesson_progress_lesson_idx on public.lesson_progress (lesson_id);

create table public.daily_activity (
  user_id uuid not null references public.profiles (id) on delete cascade,
  activity_date date not null,
  seconds_learned integer not null default 0 check (seconds_learned between 0 and 86400),
  lessons_completed integer not null default 0,
  xp_earned integer not null default 0,
  primary key (user_id, activity_date)
);

create table public.bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  course_id uuid not null references public.courses (id) on delete cascade,
  position_seconds integer check (position_seconds >= 0),
  label text check (char_length(label) <= 200),
  created_at timestamptz not null default now()
);
create unique index bookmarks_unique_idx on public.bookmarks (user_id, lesson_id, coalesce(position_seconds, -1));
create index bookmarks_user_idx on public.bookmarks (user_id, created_at desc);
create index bookmarks_lesson_idx on public.bookmarks (lesson_id);

create table public.lesson_notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  body text not null check (char_length(body) between 1 and 10000),
  position_seconds integer check (position_seconds >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index lesson_notes_user_lesson_idx on public.lesson_notes (user_id, lesson_id, created_at);
create index lesson_notes_lesson_idx on public.lesson_notes (lesson_id);

create table public.certificates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  course_id uuid not null references public.courses (id) on delete cascade,
  serial text not null unique,
  verification_code text not null unique,
  recipient_name text not null,
  course_title text not null,
  course_level public.difficulty_level not null,
  issued_at timestamptz not null default now(),
  revoked_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  unique (user_id, course_id)
);
create index certificates_course_idx on public.certificates (course_id);

create table public.achievements (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  title text not null check (char_length(title) between 1 and 120),
  description text not null check (char_length(description) <= 500),
  icon text not null default 'award',
  tier public.achievement_tier not null default 'bronze',
  -- {"metric": "lessons_completed" | "courses_completed" | "longest_streak" | "quizzes_passed"
  --            | "perfect_quizzes" | "total_xp" | "certificates" | "minutes_learned" | "enrollments",
  --  "gte": <integer>}
  criteria jsonb not null check (criteria ? 'metric' and criteria ? 'gte'),
  xp integer not null default 0 check (xp between 0 and 10000),
  position integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.user_achievements (
  user_id uuid not null references public.profiles (id) on delete cascade,
  achievement_id uuid not null references public.achievements (id) on delete cascade,
  earned_at timestamptz not null default now(),
  primary key (user_id, achievement_id)
);
create index user_achievements_achievement_idx on public.user_achievements (achievement_id);

-- ---------------------------------------------------------------------------
-- Billing (store purchases are verified by RevenueCat → webhook → this table)
-- ---------------------------------------------------------------------------
create table public.subscription_plans (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  title text not null check (char_length(title) between 1 and 80),
  description text check (char_length(description) <= 1000),
  features text[] not null default '{}',
  interval public.billing_interval not null,
  -- Display only; the authoritative localized price always comes from the store at runtime.
  price_hint text check (char_length(price_hint) <= 40),
  trial_days integer not null default 0 check (trial_days between 0 and 90),
  apple_product_id text,
  google_product_id text,
  google_base_plan_id text,
  revenuecat_package_id text,           -- e.g. "$rc_monthly"
  entitlement text not null default 'premium',
  is_active boolean not null default true,
  is_highlighted boolean not null default false,
  position integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  plan_id uuid references public.subscription_plans (id) on delete set null,
  platform public.store_platform not null,
  status public.subscription_status not null,
  product_id text,
  entitlement text not null default 'premium',
  original_transaction_id text,
  current_period_start timestamptz,
  current_period_end timestamptz,     -- null = non-expiring (lifetime / manual grant)
  will_renew boolean not null default false,
  environment text not null default 'production' check (environment in ('production', 'sandbox')),
  note text check (char_length(note) <= 500),
  last_event jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index subscriptions_store_txn_idx on public.subscriptions (platform, original_transaction_id)
  where original_transaction_id is not null;
create index subscriptions_user_idx on public.subscriptions (user_id, status, current_period_end desc);
create index subscriptions_plan_idx on public.subscriptions (plan_id);

-- ---------------------------------------------------------------------------
-- Operations
-- ---------------------------------------------------------------------------
create table public.app_settings (
  key text primary key check (key ~ '^[a-z0-9_.]+$'),
  value jsonb not null,
  description text,
  is_public boolean not null default false,
  updated_by uuid references public.profiles (id) on delete set null,
  updated_at timestamptz not null default now()
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles (id) on delete cascade, -- null = broadcast to everyone
  type public.notification_type not null default 'system',
  title text not null check (char_length(title) between 1 and 160),
  body text check (char_length(body) <= 2000),
  data jsonb not null default '{}'::jsonb,
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now()
);
create index notifications_user_idx on public.notifications (user_id, created_at desc);

create table public.notification_reads (
  user_id uuid not null references public.profiles (id) on delete cascade,
  notification_id uuid not null references public.notifications (id) on delete cascade,
  read_at timestamptz not null default now(),
  primary key (user_id, notification_id)
);
create index notification_reads_notification_idx on public.notification_reads (notification_id);

create table public.push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  token text not null unique check (char_length(token) <= 300),
  platform text not null check (platform in ('ios', 'android', 'web')),
  device_name text check (char_length(device_name) <= 120),
  created_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now()
);
create index push_tokens_user_idx on public.push_tokens (user_id);

create table public.audit_log (
  id bigint generated always as identity primary key,
  actor_id uuid references public.profiles (id) on delete set null,
  action text not null,
  entity text not null,
  entity_id uuid,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index audit_log_entity_idx on public.audit_log (entity, entity_id, created_at desc);
create index audit_log_actor_idx on public.audit_log (actor_id, created_at desc);
