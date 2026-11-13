import type {
  Achievement,
  Assignment,
  AppNotification,
  Bookmark,
  Category,
  Certificate,
  Course,
  CourseDetail,
  CourseFilters,
  Enrollment,
  Entitlements,
  LearningPath,
  LearningStats,
  Lesson,
  LessonContent,
  LessonNote,
  LessonProgress,
  ProgressResult,
  Profile,
  PublicSettings,
  Quiz,
  QuizResponses,
  QuizResult,
  Resource,
  Submission,
  SubscriptionPlan,
  UserAchievement,
} from './types';

export interface RecentLesson extends LessonProgress {
  lesson: Pick<Lesson, 'id' | 'title' | 'type' | 'duration_seconds'> & {
    course: Pick<Course, 'id' | 'slug' | 'title' | 'cover_style'> & { category?: { color: string | null } | null };
  };
}

export interface UploadableFile {
  uri: string;
  name: string;
  mimeType?: string | null;
}

/**
 * The single contract between UI and data. Implemented by the Supabase backend
 * (production) and by an on-device demo store (no backend configured).
 */
export interface LearningApi {
  readonly mode: 'supabase' | 'demo';

  // Catalog (public)
  getSettings(): Promise<PublicSettings>;
  getCategories(): Promise<Category[]>;
  searchCourses(filters: CourseFilters, limit?: number, offset?: number): Promise<Course[]>;
  getFeaturedCourses(limit?: number): Promise<Course[]>;
  getPopularCourses(limit?: number): Promise<Course[]>;
  getNewCourses(limit?: number): Promise<Course[]>;
  getRecommendedCourses(limit?: number): Promise<Course[]>;
  getCourse(slug: string): Promise<CourseDetail | null>;
  getCourseById(id: string): Promise<CourseDetail | null>;
  getPaths(): Promise<LearningPath[]>;
  getPath(slug: string): Promise<LearningPath | null>;
  getAchievementCatalog(): Promise<Achievement[]>;
  getPlans(): Promise<SubscriptionPlan[]>;

  // Learning material (entitlement-checked)
  getLessonCourseId(lessonId: string): Promise<string | null>;
  getAssignment(id: string): Promise<Assignment | null>;
  getLessonContent(lessonId: string): Promise<LessonContent>;
  getResourceUrl(resource: Resource): Promise<string>;
  getQuiz(quizId: string): Promise<Quiz>;
  submitQuiz(quizId: string, responses: QuizResponses, startedAt?: string): Promise<QuizResult>;

  // Learner (requires a signed-in user)
  getProfile(): Promise<Profile | null>;
  updateProfile(patch: Partial<Pick<Profile, 'display_name' | 'bio' | 'locale' | 'timezone' | 'experience_level' | 'interests' | 'learning_goal' | 'daily_goal_minutes' | 'onboarding_completed_at'>>): Promise<Profile>;
  getEntitlements(): Promise<Entitlements>;
  getStats(): Promise<LearningStats>;
  getEnrollments(): Promise<Enrollment[]>;
  enroll(courseId: string): Promise<Enrollment>;
  leaveCourse(courseId: string): Promise<void>;
  getCourseProgress(courseId: string): Promise<LessonProgress[]>;
  getRecentLessons(limit?: number): Promise<RecentLesson[]>;
  recordProgress(lessonId: string, input: { positionSeconds?: number; secondsSpent?: number; completed?: boolean }): Promise<ProgressResult>;
  getEarnedAchievements(): Promise<UserAchievement[]>;
  getCertificates(): Promise<Certificate[]>;
  claimCertificate(courseId: string): Promise<Certificate>;
  getBookmarks(): Promise<Bookmark[]>;
  addBookmark(lessonId: string, positionSeconds?: number | null, label?: string | null): Promise<Bookmark>;
  removeBookmark(id: string): Promise<void>;
  getNotes(lessonId: string): Promise<LessonNote[]>;
  addNote(lessonId: string, body: string, positionSeconds?: number | null): Promise<LessonNote>;
  deleteNote(id: string): Promise<void>;
  getSubmissions(assignmentId: string): Promise<Submission[]>;
  uploadSubmissionFile(assignmentId: string, file: UploadableFile): Promise<string>;
  submitAssignment(assignmentId: string, input: { body?: string; url?: string; filePaths?: string[] }): Promise<Submission>;
  getNotifications(): Promise<AppNotification[]>;
  markNotificationsRead(ids: string[]): Promise<void>;
  registerPushToken(token: string, platform: 'ios' | 'android' | 'web', deviceName?: string | null): Promise<void>;
}
