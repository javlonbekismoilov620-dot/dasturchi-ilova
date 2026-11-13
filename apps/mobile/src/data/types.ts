/**
 * Domain types. Field names mirror the Postgres schema (supabase/migrations) so rows
 * from PostgREST can be used directly without mapping.
 */
export type DifficultyLevel = 'zero' | 'beginner' | 'intermediate' | 'advanced' | 'professional' | 'expert';
export const DIFFICULTY_LEVELS: DifficultyLevel[] = ['zero', 'beginner', 'intermediate', 'advanced', 'professional', 'expert'];
export type AccessTier = 'free' | 'premium';
export type ContentStatus = 'draft' | 'in_review' | 'published' | 'archived';
export type LessonType = 'video' | 'article' | 'exercise' | 'quiz' | 'assignment' | 'project';
export type QuestionType = 'single_choice' | 'multiple_choice' | 'true_false' | 'short_answer';
export type QuizKind = 'knowledge_check' | 'module_exam' | 'final_assessment';
export type ProgressStatus = 'not_started' | 'in_progress' | 'completed';
export type EnrollmentStatus = 'active' | 'completed' | 'dropped';
export type SubmissionStatus = 'submitted' | 'in_review' | 'approved' | 'changes_requested';
export type LearningGoal = 'career' | 'switch' | 'school' | 'business' | 'hobby';
export type AchievementTier = 'bronze' | 'silver' | 'gold' | 'platinum';
export type AppRole = 'student' | 'instructor' | 'editor' | 'admin';

export interface CoverStyle {
  pattern?: 'grid' | 'brackets' | 'waves' | 'isometric' | 'frames' | 'hex' | 'circles' | 'orbits';
  hue?: number;
}

export interface Category {
  id: string;
  parent_id: string | null;
  slug: string;
  title: string;
  subtitle: string | null;
  description: string | null;
  icon: string | null;
  color: string | null;
  position: number;
  is_featured: boolean;
  children?: Category[];
}

export interface Instructor {
  id: string;
  slug: string;
  name: string;
  headline: string | null;
  bio: string | null;
  avatar_path: string | null;
  is_verified: boolean;
}

export interface Course {
  id: string;
  slug: string;
  title: string;
  subtitle: string | null;
  description: string | null;
  category_id: string;
  subcategory_id: string | null;
  instructor_id: string | null;
  level: DifficultyLevel;
  access_tier: AccessTier;
  status: ContentStatus;
  language: string;
  cover_path: string | null;
  cover_style: CoverStyle;
  estimated_minutes: number | null;
  learning_outcomes: string[];
  prerequisites: string[];
  tags: string[];
  is_featured: boolean;
  content_complete: boolean;
  certificate_enabled: boolean;
  lesson_count: number;
  duration_seconds: number;
  enrollment_count: number;
  published_at: string | null;
  category?: Pick<Category, 'id' | 'slug' | 'title' | 'color' | 'icon'> | null;
  subcategory?: Pick<Category, 'id' | 'slug' | 'title'> | null;
  instructor?: Instructor | null;
}

export interface Lesson {
  id: string;
  module_id: string;
  course_id: string;
  title: string;
  summary: string | null;
  type: LessonType;
  position: number;
  duration_seconds: number;
  is_preview: boolean;
  is_required: boolean;
  xp: number;
}

export interface Module {
  id: string;
  course_id: string;
  title: string;
  description: string | null;
  position: number;
  lessons: Lesson[];
}

export interface CourseDetail extends Course {
  modules: Module[];
  prerequisite_courses: Pick<Course, 'id' | 'slug' | 'title'>[];
}

export interface VideoSourceInfo {
  uri: string;
  quality: string | null; // null = adaptive (HLS) or single file
}

export interface CaptionTrack {
  language: string;
  label: string;
  uri: string;
}

export interface LessonVideo {
  id: string;
  provider: 'storage' | 'mux' | 'cloudflare_stream' | 'external';
  sources: VideoSourceInfo[];
  captions: CaptionTrack[];
  posterUri: string | null;
  duration_seconds: number | null;
}

export interface Resource {
  id: string;
  course_id: string;
  lesson_id: string | null;
  title: string;
  description: string | null;
  kind: 'pdf' | 'archive' | 'image' | 'code' | 'link' | 'document' | 'other';
  storage_path: string | null;
  external_url: string | null;
  size_bytes: number | null;
  mime_type: string | null;
  allow_offline: boolean;
}

export interface LessonContent {
  lesson_id: string;
  body_md: string | null;
  video: LessonVideo | null;
  resources: Resource[];
  quiz_id: string | null;
  assignment: Assignment | null;
}

export interface QuizAnswerOption {
  id: string;
  label_md: string;
}

export interface QuizQuestion {
  id: string;
  type: QuestionType;
  prompt_md: string;
  code_snippet: string | null;
  points: number;
  answers: QuizAnswerOption[];
}

export interface Quiz {
  id: string;
  course_id: string;
  lesson_id: string | null;
  title: string;
  description: string | null;
  kind: QuizKind;
  pass_score_percent: number;
  time_limit_seconds: number | null;
  max_attempts: number | null;
  xp: number;
  attempts_used: number;
  best_score: number | null;
  passed: boolean;
  questions: QuizQuestion[];
}

export type QuizResponses = Record<string, string[] | string>;

export interface QuestionResult {
  question_id: string;
  correct: boolean;
  points: number;
  selected_answer_ids: string[];
  response_text: string | null;
  correct_answer_ids: string[];
  accepted_answers: string[];
  explanation_md: string | null;
  feedback: { answer_id: string; feedback_md: string }[];
}

export interface EarnedAchievement {
  id: string;
  slug: string;
  title: string;
  tier: AchievementTier;
  icon: string;
}

export interface Enrollment {
  id: string;
  user_id: string;
  course_id: string;
  status: EnrollmentStatus;
  progress_percent: number;
  completed_lessons: number;
  total_lessons: number;
  last_lesson_id: string | null;
  last_accessed_at: string;
  enrolled_at: string;
  completed_at: string | null;
  course?: Course;
}

export interface Certificate {
  id: string;
  user_id: string;
  course_id: string;
  serial: string;
  verification_code: string;
  recipient_name: string;
  course_title: string;
  course_level: DifficultyLevel;
  issued_at: string;
  revoked_at: string | null;
  metadata: { lessons?: number; duration_seconds?: number };
}

export interface QuizResult {
  attempt_id: string;
  score_percent: number;
  passed: boolean;
  pass_score_percent: number;
  points_earned: number;
  points_possible: number;
  xp_awarded: number;
  lesson_completed: boolean;
  results: QuestionResult[];
  enrollment: Enrollment | null;
  certificate: Certificate | null;
  new_achievements: EarnedAchievement[];
}

export interface ProgressResult {
  lesson_id: string;
  newly_completed: boolean;
  xp_awarded: number;
  enrollment: Enrollment | null;
  certificate: Certificate | null;
  new_achievements: EarnedAchievement[];
}

export interface LessonProgress {
  lesson_id: string;
  course_id: string;
  status: ProgressStatus;
  position_seconds: number;
  completed_at: string | null;
  updated_at: string;
}

export interface Assignment {
  id: string;
  course_id: string;
  lesson_id: string | null;
  title: string;
  brief_md: string | null;
  rubric_md: string | null;
  submission_type: 'text' | 'url' | 'file' | 'any';
  is_project: boolean;
  max_score: number;
}

export interface Submission {
  id: string;
  assignment_id: string;
  body_md: string | null;
  url: string | null;
  file_paths: string[];
  status: SubmissionStatus;
  score: number | null;
  feedback_md: string | null;
  submitted_at: string;
  reviewed_at: string | null;
}

export interface Achievement {
  id: string;
  slug: string;
  title: string;
  description: string;
  icon: string;
  tier: AchievementTier;
  criteria: { metric: string; gte: number };
  xp: number;
  position: number;
}

export interface UserAchievement {
  achievement_id: string;
  earned_at: string;
}

export interface LearningStats {
  total_xp: number;
  current_streak: number;
  longest_streak: number;
  active_today: boolean;
  daily_goal_minutes: number;
  today_seconds: number;
  total_seconds: number;
  lessons_completed: number;
  courses_in_progress: number;
  courses_completed: number;
  quizzes_passed: number;
  certificates: number;
  achievements: number;
  is_premium: boolean;
  last_7_days: { date: string; seconds: number; lessons: number }[];
}

export interface Bookmark {
  id: string;
  lesson_id: string;
  course_id: string;
  position_seconds: number | null;
  label: string | null;
  created_at: string;
  lesson?: Pick<Lesson, 'id' | 'title' | 'type'> & { course?: Pick<Course, 'id' | 'slug' | 'title' | 'cover_style'> & { category?: Pick<Category, 'color'> | null } };
}

export interface LessonNote {
  id: string;
  lesson_id: string;
  body: string;
  position_seconds: number | null;
  created_at: string;
}

export interface AppNotification {
  id: string;
  user_id: string | null;
  type: 'system' | 'course' | 'achievement' | 'reminder' | 'announcement';
  title: string;
  body: string | null;
  data: Record<string, unknown>;
  created_at: string;
  read: boolean;
}

export interface LearningPath {
  id: string;
  slug: string;
  title: string;
  subtitle: string | null;
  description: string | null;
  category_id: string | null;
  level_from: DifficultyLevel;
  level_to: DifficultyLevel;
  access_tier: AccessTier;
  cover_style: CoverStyle;
  position: number;
  is_featured: boolean;
  courses: (Course & { path_position: number })[];
}

export interface SubscriptionPlan {
  id: string;
  slug: string;
  title: string;
  description: string | null;
  features: string[];
  interval: 'month' | 'year' | 'lifetime';
  price_hint: string | null;
  trial_days: number;
  apple_product_id: string | null;
  google_product_id: string | null;
  revenuecat_package_id: string | null;
  is_highlighted: boolean;
}

export interface Entitlements {
  is_premium: boolean;
  free_for_all: boolean;
  subscription: {
    platform: string;
    status: string;
    product_id: string | null;
    current_period_end: string | null;
    will_renew: boolean;
  } | null;
}

export interface Profile {
  id: string;
  display_name: string | null;
  username: string | null;
  avatar_path: string | null;
  bio: string | null;
  locale: 'en' | 'uz' | 'ru';
  timezone: string;
  experience_level: DifficultyLevel;
  interests: string[];
  learning_goal: LearningGoal | null;
  daily_goal_minutes: number;
  onboarding_completed_at: string | null;
  total_xp: number;
  current_streak: number;
  longest_streak: number;
  created_at: string;
}

export interface PublicSettings {
  billing?: { mode: 'subscriptions' | 'free_for_all'; paywall_enabled?: boolean };
  certificates?: { require_premium: boolean };
  free_tier?: { max_learning_paths: number };
  assistant?: { enabled: boolean; provider: string | null };
  support?: { email: string; privacy_url: string; terms_url: string };
}

export interface CourseFilters {
  query?: string;
  categorySlug?: string | null;
  levels?: DifficultyLevel[];
  tier?: AccessTier | null;
  sort?: 'relevance' | 'popular' | 'newest';
}
