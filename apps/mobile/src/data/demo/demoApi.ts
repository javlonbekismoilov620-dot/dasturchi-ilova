/**
 * DEMO MODE — on-device implementation of LearningApi used only when no backend is
 * configured. Catalog content is the seed content exported from the real database
 * (catalog.json); learner state lives in AsyncStorage on this device. The UI labels
 * this mode explicitly. Rules mirror the SQL engine (supabase/migrations/*_engine.sql).
 */
import AsyncStorage from '@react-native-async-storage/async-storage';

import { AppError } from '@/lib/errors';

import type { LearningApi, RecentLesson } from '../api';
import type {
  Achievement,
  AppNotification,
  Assignment,
  Bookmark,
  Category,
  Certificate,
  Course,
  CourseDetail,
  Enrollment,
  Instructor,
  LearningPath,
  LearningStats,
  Lesson,
  LessonNote,
  LessonProgress,
  Module,
  ProgressResult,
  Profile,
  PublicSettings,
  Quiz,
  QuizResult,
  QuestionResult,
  Submission,
  SubscriptionPlan,
  UserAchievement,
} from '../types';
import rawCatalog from './catalog.json';

type DemoAnswer = { id: string; label_md: string; is_correct: boolean; feedback_md: string | null; position: number };
type DemoQuestion = { id: string; type: Quiz['questions'][number]['type']; prompt_md: string; code_snippet: string | null; explanation_md: string | null; points: number; position: number; answers: DemoAnswer[] };
type DemoQuiz = Omit<Quiz, 'questions' | 'attempts_used' | 'best_score' | 'passed'> & { module_id: string | null; shuffle_questions: boolean; questions: DemoQuestion[] };

const catalog = rawCatalog as unknown as {
  settings: PublicSettings;
  categories: Category[];
  instructors: Instructor[];
  courses: Course[];
  prerequisites: { course_id: string; prerequisite_course_id: string }[];
  modules: Omit<Module, 'lessons'>[];
  lessons: Lesson[];
  contents: { lesson_id: string; body_md: string | null }[];
  quizzes: DemoQuiz[];
  assignments: (Assignment & { module_id: string | null })[];
  paths: (Omit<LearningPath, 'courses'> & { courses: { course_id: string; position: number }[] })[];
  achievements: Achievement[];
  plans: SubscriptionPlan[];
};

export const DEMO_USER_ID = '00000000-0000-4000-8000-00000000d3e0';
const STORAGE_KEY = 'mahorat.demo.state.v1';

interface DemoState {
  profile: Profile;
  premium: boolean;
  enrollments: Record<string, Enrollment>;
  progress: Record<string, LessonProgress>;
  attempts: { quiz_id: string; score_percent: number; passed: boolean; submitted_at: string }[];
  activity: Record<string, { seconds: number; lessons: number; xp: number }>;
  earned: UserAchievement[];
  certificates: Certificate[];
  bookmarks: Bookmark[];
  notes: LessonNote[];
  submissions: Submission[];
  notifications: AppNotification[];
}

const uid = () => {
  const h = () => Math.floor(Math.random() * 0x10000).toString(16).padStart(4, '0');
  return `${h()}${h()}-${h()}-4${h().slice(1)}-a${h().slice(1)}-${h()}${h()}${h()}`;
};
const now = () => new Date().toISOString();
const today = () => {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};
const dayOffset = (iso: string, days: number) => {
  const d = new Date(`${iso}T12:00:00`);
  d.setDate(d.getDate() + days);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};

function freshState(): DemoState {
  return {
    profile: {
      id: DEMO_USER_ID,
      display_name: null,
      username: null,
      avatar_path: null,
      bio: null,
      locale: 'en',
      timezone: 'UTC',
      experience_level: 'zero',
      interests: [],
      learning_goal: null,
      daily_goal_minutes: 15,
      onboarding_completed_at: null,
      total_xp: 0,
      current_streak: 0,
      longest_streak: 0,
      created_at: now(),
    },
    premium: false,
    enrollments: {},
    progress: {},
    attempts: [],
    activity: {},
    earned: [],
    certificates: [],
    bookmarks: [],
    notes: [],
    submissions: [],
    notifications: [],
  };
}

let state: DemoState | null = null;
let lastActive: string | null = null;

async function load(): Promise<DemoState> {
  if (state) return state;
  try {
    const raw = await AsyncStorage.getItem(STORAGE_KEY);
    const parsed = raw ? (JSON.parse(raw) as DemoState & { lastActive?: string | null }) : null;
    state = parsed ? { ...freshState(), ...parsed } : freshState();
    lastActive = parsed?.lastActive ?? null;
  } catch {
    state = freshState();
  }
  return state;
}

async function save() {
  if (state) await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify({ ...state, lastActive }));
}

export async function resetDemoState() {
  state = freshState();
  lastActive = null;
  await AsyncStorage.removeItem(STORAGE_KEY);
}

export async function setDemoPremium(on: boolean) {
  const s = await load();
  s.premium = on;
  await save();
}

// ---------------------------------------------------------------------------
// Catalog helpers
// ---------------------------------------------------------------------------
const categoryById = new Map(catalog.categories.map((c) => [c.id, c]));
const instructorById = new Map(catalog.instructors.map((i) => [i.id, i]));

function decorate(c: Course): Course {
  const cat = categoryById.get(c.category_id);
  const sub = c.subcategory_id ? categoryById.get(c.subcategory_id) : null;
  return {
    ...c,
    category: cat ? { id: cat.id, slug: cat.slug, title: cat.title, color: cat.color, icon: cat.icon } : null,
    subcategory: sub ? { id: sub.id, slug: sub.slug, title: sub.title } : null,
    instructor: c.instructor_id ? instructorById.get(c.instructor_id) ?? null : null,
  };
}

const courses = catalog.courses.map(decorate);
const courseById = new Map(courses.map((c) => [c.id, c]));
const lessonById = new Map(catalog.lessons.map((l) => [l.id, l]));
const LEVELS = ['zero', 'beginner', 'intermediate', 'advanced', 'professional', 'expert'];

function requiredLessons(courseId: string) {
  return catalog.lessons.filter((l) => l.course_id === courseId && l.is_required);
}

function canAccess(courseId: string, lesson?: Lesson) {
  const c = courseById.get(courseId);
  if (!c) return false;
  if (c.access_tier === 'free' || lesson?.is_preview) return true;
  return !!state?.premium || catalog.settings.billing?.mode === 'free_for_all';
}

// ---------------------------------------------------------------------------
// Engine (mirrors private.* SQL routines)
// ---------------------------------------------------------------------------
function touchActivity(s: DemoState, seconds: number, lessons: number, xp: number) {
  const d = today();
  const a = (s.activity[d] ??= { seconds: 0, lessons: 0, xp: 0 });
  a.seconds = Math.min(a.seconds + Math.max(0, seconds), 86400);
  a.lessons += Math.max(0, lessons);
  a.xp += Math.max(0, xp);
  if (!lastActive || lastActive < dayOffset(d, -1)) s.profile.current_streak = 1;
  else if (lastActive === dayOffset(d, -1)) s.profile.current_streak += 1;
  s.profile.longest_streak = Math.max(s.profile.longest_streak, s.profile.current_streak);
  lastActive = !lastActive || lastActive < d ? d : lastActive;
  s.profile.total_xp += Math.max(0, xp);
}

function ensureEnrollment(s: DemoState, courseId: string) {
  const existing = s.enrollments[courseId];
  if (existing) {
    existing.last_accessed_at = now();
    if (existing.status === 'dropped') existing.status = 'active';
    return existing;
  }
  const e: Enrollment = {
    id: uid(),
    user_id: DEMO_USER_ID,
    course_id: courseId,
    status: 'active',
    progress_percent: 0,
    completed_lessons: 0,
    total_lessons: requiredLessons(courseId).length,
    last_lesson_id: null,
    last_accessed_at: now(),
    enrolled_at: now(),
    completed_at: null,
  };
  s.enrollments[courseId] = e;
  return e;
}

function recompute(s: DemoState, courseId: string) {
  const e = s.enrollments[courseId];
  if (!e) return null;
  const req = requiredLessons(courseId);
  const done = req.filter((l) => s.progress[l.id]?.status === 'completed').length;
  const finalsOk = catalog.quizzes
    .filter((q) => q.course_id === courseId && q.kind === 'final_assessment')
    .every((q) => s.attempts.some((a) => a.quiz_id === q.id && a.passed));
  e.total_lessons = req.length;
  e.completed_lessons = done;
  e.progress_percent = req.length ? Math.round((done * 10000) / req.length) / 100 : 0;
  const complete = req.length > 0 && done >= req.length && finalsOk;
  e.status = complete ? 'completed' : e.status === 'completed' ? 'active' : e.status;
  e.completed_at = complete ? e.completed_at ?? now() : null;
  return e;
}

function issueCertificate(s: DemoState, courseId: string): Certificate | null {
  const existing = s.certificates.find((c) => c.course_id === courseId);
  if (existing) return existing;
  const c = courseById.get(courseId);
  const e = s.enrollments[courseId];
  if (!c || !c.certificate_enabled || e?.status !== 'completed') return null;
  const requirePremium = catalog.settings.certificates?.require_premium ?? true;
  if (requirePremium && !s.premium) return null;
  const code = uid().replace(/-/g, '').slice(0, 12).toUpperCase();
  const cert: Certificate = {
    id: uid(),
    user_id: DEMO_USER_ID,
    course_id: courseId,
    serial: `DEMO-${new Date().getFullYear()}-${code.slice(0, 8)}`,
    verification_code: code,
    recipient_name: s.profile.display_name?.trim() || 'Demo learner',
    course_title: c.title,
    course_level: c.level,
    issued_at: now(),
    revoked_at: null,
    metadata: { lessons: e.total_lessons, duration_seconds: c.duration_seconds },
  };
  s.certificates.unshift(cert);
  s.notifications.unshift({ id: uid(), user_id: DEMO_USER_ID, type: 'course', title: 'Certificate earned', body: c.title, data: { certificate_id: cert.id }, created_at: now(), read: false });
  return cert;
}

function evaluateAchievements(s: DemoState) {
  const metrics: Record<string, number> = {
    lessons_completed: Object.values(s.progress).filter((p) => p.status === 'completed').length,
    courses_completed: Object.values(s.enrollments).filter((e) => e.status === 'completed').length,
    enrollments: Object.keys(s.enrollments).length,
    longest_streak: s.profile.longest_streak,
    quizzes_passed: new Set(s.attempts.filter((a) => a.passed).map((a) => a.quiz_id)).size,
    perfect_quizzes: new Set(s.attempts.filter((a) => a.score_percent >= 100).map((a) => a.quiz_id)).size,
    total_xp: s.profile.total_xp,
    certificates: s.certificates.length,
    minutes_learned: Math.floor(Object.values(s.activity).reduce((n, a) => n + a.seconds, 0) / 60),
  };
  const fresh: Achievement[] = [];
  for (const a of catalog.achievements) {
    if (s.earned.some((e) => e.achievement_id === a.id)) continue;
    if ((metrics[a.criteria.metric] ?? 0) >= a.criteria.gte) {
      s.earned.push({ achievement_id: a.id, earned_at: now() });
      s.profile.total_xp += a.xp;
      s.notifications.unshift({ id: uid(), user_id: DEMO_USER_ID, type: 'achievement', title: a.title, body: a.description, data: { slug: a.slug }, created_at: now(), read: false });
      fresh.push(a);
    }
  }
  return fresh.map((a) => ({ id: a.id, slug: a.slug, title: a.title, tier: a.tier, icon: a.icon }));
}

function completeLesson(s: DemoState, lessonId: string) {
  const lesson = lessonById.get(lessonId)!;
  const was = s.progress[lessonId]?.status === 'completed';
  s.progress[lessonId] = {
    ...(s.progress[lessonId] ?? { position_seconds: 0, lesson_id: lessonId, course_id: lesson.course_id }),
    status: 'completed',
    completed_at: s.progress[lessonId]?.completed_at ?? now(),
    updated_at: now(),
  };
  if (!was) touchActivity(s, 0, 1, lesson.xp);
  const e = ensureEnrollment(s, lesson.course_id);
  e.last_lesson_id = lessonId;
  recompute(s, lesson.course_id);
  issueCertificate(s, lesson.course_id);
  return !was;
}

function grade(quiz: DemoQuiz, responses: Record<string, string[] | string>) {
  let earned = 0;
  let possible = 0;
  const results: QuestionResult[] = quiz.questions.map((q) => {
    possible += q.points;
    const correctIds = q.answers.filter((a) => a.is_correct).map((a) => a.id).sort();
    let selected: string[] = [];
    let text: string | null = null;
    let ok: boolean;
    const norm = (v: string) => v.trim().toLowerCase().replace(/\s+/g, ' ');
    if (q.type === 'short_answer') {
      text = typeof responses[q.id] === 'string' ? (responses[q.id] as string) : null;
      ok = text !== null && q.answers.some((a) => a.is_correct && norm(a.label_md) === norm(text!));
    } else {
      const raw = Array.isArray(responses[q.id]) ? (responses[q.id] as string[]) : [];
      selected = [...new Set(raw.filter((id) => q.answers.some((a) => a.id === id)))].sort();
      ok = correctIds.length > 0 && selected.join() === correctIds.join() && (q.type === 'multiple_choice' || selected.length === 1);
    }
    if (ok) earned += q.points;
    return {
      question_id: q.id,
      correct: ok,
      points: ok ? q.points : 0,
      selected_answer_ids: selected,
      response_text: text,
      correct_answer_ids: q.type === 'short_answer' ? [] : correctIds,
      accepted_answers: q.type === 'short_answer' ? q.answers.filter((a) => a.is_correct).map((a) => a.label_md) : [],
      explanation_md: q.explanation_md,
      feedback: q.answers.filter((a) => a.feedback_md && (selected.includes(a.id) || a.is_correct)).map((a) => ({ answer_id: a.id, feedback_md: a.feedback_md! })),
    };
  });
  return { earned, possible, results };
}

function toLearningPath(p: (typeof catalog.paths)[number]): LearningPath {
  return {
    ...p,
    courses: p.courses
      .map((x) => (courseById.get(x.course_id) ? { ...courseById.get(x.course_id)!, path_position: x.position } : null))
      .filter((c): c is Course & { path_position: number } => !!c)
      .sort((a, b) => a.path_position - b.path_position),
  };
}

function detail(c: Course | undefined): CourseDetail | null {
  if (!c) return null;
  const modules = catalog.modules
    .filter((m) => m.course_id === c.id)
    .sort((a, b) => a.position - b.position)
    .map((m) => ({ ...m, lessons: catalog.lessons.filter((l) => l.module_id === m.id).sort((a, b) => a.position - b.position) }))
    .filter((m) => m.lessons.length > 0);
  const prereqs = catalog.prerequisites.filter((p) => p.course_id === c.id).map((p) => courseById.get(p.prerequisite_course_id)).filter((x): x is Course => !!x);
  return { ...c, modules, prerequisite_courses: prereqs.map(({ id, slug, title }) => ({ id, slug, title })) };
}

const delay = <T,>(v: T) => new Promise<T>((r) => setTimeout(() => r(v), 120));

export function createDemoApi(): LearningApi {
  return {
    mode: 'demo',

    getSettings: () => delay(catalog.settings),
    getCategories: () =>
      delay(
        catalog.categories
          .filter((c) => !c.parent_id)
          .sort((a, b) => a.position - b.position)
          .map((c) => ({ ...c, children: catalog.categories.filter((s) => s.parent_id === c.id).sort((a, b) => a.position - b.position) })),
      ),

    async searchCourses(f, limit = 30, offset = 0) {
      const q = f.query?.trim().toLowerCase();
      const cat = f.categorySlug ? catalog.categories.find((c) => c.slug === f.categorySlug) : null;
      let rows = courses.filter(
        (c) =>
          (!cat || c.category_id === cat.id || c.subcategory_id === cat.id) &&
          (!f.levels?.length || f.levels.includes(c.level)) &&
          (!f.tier || c.access_tier === f.tier) &&
          (!q || [c.title, c.subtitle, c.description, c.tags.join(' ')].join(' ').toLowerCase().split(/[^\p{L}\p{N}]+/u).some((w) => q.split(/\s+/).every((t) => w.startsWith(t) || c.title.toLowerCase().includes(t)))),
      );
      if (f.sort === 'popular') rows = rows.sort((a, b) => b.enrollment_count - a.enrollment_count);
      else if (f.sort === 'newest') rows = rows.sort((a, b) => (b.published_at ?? '').localeCompare(a.published_at ?? ''));
      else rows = rows.sort((a, b) => Number(b.is_featured) - Number(a.is_featured) || a.title.localeCompare(b.title));
      return delay(rows.slice(offset, offset + limit));
    },

    getFeaturedCourses: (limit = 8) => delay(courses.filter((c) => c.is_featured).slice(0, limit)),
    getPopularCourses: (limit = 10) => delay([...courses].sort((a, b) => b.enrollment_count - a.enrollment_count || a.title.localeCompare(b.title)).slice(0, limit)),
    getNewCourses: (limit = 10) => delay([...courses].sort((a, b) => (b.published_at ?? '').localeCompare(a.published_at ?? '')).slice(0, limit)),

    async getRecommendedCourses(limit = 10) {
      const s = await load();
      const lvl = LEVELS.indexOf(s.profile.experience_level);
      const scored = courses
        .filter((c) => !s.enrollments[c.id] || s.enrollments[c.id].status === 'dropped')
        .map((c) => {
          const cat = categoryById.get(c.category_id);
          const sub = c.subcategory_id ? categoryById.get(c.subcategory_id) : null;
          const interest = s.profile.interests.some((i) => i === cat?.slug || i === sub?.slug) ? 4 : 0;
          const level = Math.max(0, 3 - Math.abs(LEVELS.indexOf(c.level) - lvl) * 1.5);
          return { c, score: interest + level + (c.is_featured ? 1 : 0) + (c.access_tier === 'free' ? 0.25 : 0) };
        })
        .sort((a, b) => b.score - a.score);
      return delay(scored.slice(0, limit).map((x) => x.c));
    },

    getCourse: (slug) => delay(detail(courses.find((c) => c.slug === slug))),
    getCourseById: (id) => delay(detail(courseById.get(id))),
    getPaths: () => delay(catalog.paths.map(toLearningPath)),
    getPath: (slug) => delay(catalog.paths.map(toLearningPath).find((p) => p.slug === slug) ?? null),
    getAchievementCatalog: () => delay(catalog.achievements),
    getPlans: () => delay(catalog.plans),

    getAssignment: async (id) => catalog.assignments.find((a) => a.id === id) ?? null,
    getLessonCourseId: async (lessonId) => lessonById.get(lessonId)?.course_id ?? null,

    async getLessonContent(lessonId) {
      await load();
      const lesson = lessonById.get(lessonId);
      if (!lesson) throw new AppError('lesson_not_found');
      if (!canAccess(lesson.course_id, lesson)) throw new AppError('lesson_locked');
      const quiz = catalog.quizzes.find((q) => q.lesson_id === lessonId);
      const assignment = catalog.assignments.find((a) => a.lesson_id === lessonId) ?? null;
      return delay({
        lesson_id: lessonId,
        body_md: catalog.contents.find((c) => c.lesson_id === lessonId)?.body_md ?? null,
        video: null,
        resources: [],
        quiz_id: quiz?.id ?? null,
        assignment,
      });
    },

    getResourceUrl: async (r) => r.external_url ?? '',

    async getQuiz(quizId) {
      const s = await load();
      const q = catalog.quizzes.find((x) => x.id === quizId);
      if (!q) throw new AppError('quiz_locked');
      const lesson = q.lesson_id ? lessonById.get(q.lesson_id) : undefined;
      if (!canAccess(q.course_id, lesson)) throw new AppError('quiz_locked');
      const mine = s.attempts.filter((a) => a.quiz_id === quizId);
      return delay({
        ...q,
        attempts_used: mine.length,
        best_score: mine.length ? Math.max(...mine.map((a) => a.score_percent)) : null,
        passed: mine.some((a) => a.passed),
        questions: q.questions.map(({ explanation_md: _e, answers, ...rest }) => ({
          ...rest,
          answers: rest.type === 'short_answer' ? [] : answers.map(({ id, label_md }) => ({ id, label_md })),
        })),
      });
    },

    async submitQuiz(quizId, responses) {
      const s = await load();
      const q = catalog.quizzes.find((x) => x.id === quizId);
      if (!q) throw new AppError('quiz_locked');
      const prevPassed = s.attempts.some((a) => a.quiz_id === quizId && a.passed);
      if (q.max_attempts && s.attempts.filter((a) => a.quiz_id === quizId).length >= q.max_attempts) throw new AppError('max_attempts_reached');
      const { earned, possible, results } = grade(q, responses);
      const score = Math.round((earned * 10000) / possible) / 100;
      const passed = score >= q.pass_score_percent;
      s.attempts.push({ quiz_id: quizId, score_percent: score, passed, submitted_at: now() });
      ensureEnrollment(s, q.course_id);
      if (passed && !prevPassed) touchActivity(s, 0, 0, q.xp);
      let lessonCompleted = false;
      if (passed && q.lesson_id) lessonCompleted = completeLesson(s, q.lesson_id);
      else {
        recompute(s, q.course_id);
        issueCertificate(s, q.course_id);
      }
      const newAchievements = evaluateAchievements(s);
      await save();
      const result: QuizResult = {
        attempt_id: uid(),
        score_percent: score,
        passed,
        pass_score_percent: q.pass_score_percent,
        points_earned: earned,
        points_possible: possible,
        xp_awarded: passed && !prevPassed ? q.xp : 0,
        lesson_completed: lessonCompleted,
        results,
        enrollment: s.enrollments[q.course_id] ?? null,
        certificate: s.certificates.find((c) => c.course_id === q.course_id) ?? null,
        new_achievements: newAchievements,
      };
      return delay(result);
    },

    getProfile: async () => (await load()).profile,
    async updateProfile(patch) {
      const s = await load();
      s.profile = { ...s.profile, ...patch };
      await save();
      return s.profile;
    },

    async getEntitlements() {
      const s = await load();
      return { is_premium: s.premium, free_for_all: false, subscription: s.premium ? { platform: 'demo', status: 'active', product_id: 'demo', current_period_end: null, will_renew: false } : null };
    },

    async getStats(): Promise<LearningStats> {
      const s = await load();
      const d = today();
      const streakAlive = lastActive !== null && lastActive >= dayOffset(d, -1);
      return {
        total_xp: s.profile.total_xp,
        current_streak: streakAlive ? s.profile.current_streak : 0,
        longest_streak: s.profile.longest_streak,
        active_today: lastActive === d,
        daily_goal_minutes: s.profile.daily_goal_minutes,
        today_seconds: s.activity[d]?.seconds ?? 0,
        total_seconds: Object.values(s.activity).reduce((n, a) => n + a.seconds, 0),
        lessons_completed: Object.values(s.progress).filter((p) => p.status === 'completed').length,
        courses_in_progress: Object.values(s.enrollments).filter((e) => e.status === 'active').length,
        courses_completed: Object.values(s.enrollments).filter((e) => e.status === 'completed').length,
        quizzes_passed: new Set(s.attempts.filter((a) => a.passed).map((a) => a.quiz_id)).size,
        certificates: s.certificates.length,
        achievements: s.earned.length,
        is_premium: s.premium,
        last_7_days: Array.from({ length: 7 }, (_, i) => {
          const day = dayOffset(d, i - 6);
          return { date: day, seconds: s.activity[day]?.seconds ?? 0, lessons: s.activity[day]?.lessons ?? 0 };
        }),
      };
    },

    async getEnrollments() {
      const s = await load();
      return Object.values(s.enrollments)
        .filter((e) => e.status !== 'dropped' && courseById.has(e.course_id))
        .sort((a, b) => b.last_accessed_at.localeCompare(a.last_accessed_at))
        .map((e) => ({ ...e, course: courseById.get(e.course_id) }));
    },

    async enroll(courseId) {
      const s = await load();
      const c = courseById.get(courseId);
      if (!c) throw new AppError('course_not_found');
      if (c.access_tier === 'premium' && !s.premium) throw new AppError('premium_required');
      ensureEnrollment(s, courseId);
      recompute(s, courseId);
      evaluateAchievements(s);
      await save();
      return s.enrollments[courseId];
    },

    async leaveCourse(courseId) {
      const s = await load();
      if (s.enrollments[courseId]?.status === 'active') s.enrollments[courseId].status = 'dropped';
      await save();
    },

    async getCourseProgress(courseId) {
      const s = await load();
      return Object.values(s.progress).filter((p) => p.course_id === courseId);
    },

    async getRecentLessons(limit = 10) {
      const s = await load();
      return Object.values(s.progress)
        .sort((a, b) => b.updated_at.localeCompare(a.updated_at))
        .slice(0, limit)
        .map((p) => {
          const l = lessonById.get(p.lesson_id)!;
          const c = courseById.get(l.course_id)!;
          return { ...p, lesson: { id: l.id, title: l.title, type: l.type, duration_seconds: l.duration_seconds, course: { id: c.id, slug: c.slug, title: c.title, cover_style: c.cover_style, category: c.category ? { color: c.category.color } : null } } } as RecentLesson;
        });
    },

    async recordProgress(lessonId, input): Promise<ProgressResult> {
      const s = await load();
      const lesson = lessonById.get(lessonId);
      if (!lesson || !canAccess(lesson.course_id, lesson)) throw new AppError('lesson_locked');
      const spent = Math.min(Math.max(Math.round(input.secondsSpent ?? 0), 0), 600);
      ensureEnrollment(s, lesson.course_id).last_lesson_id = lessonId;
      const p = s.progress[lessonId];
      s.progress[lessonId] = {
        lesson_id: lessonId,
        course_id: lesson.course_id,
        status: p?.status === 'completed' ? 'completed' : 'in_progress',
        position_seconds: input.positionSeconds ?? p?.position_seconds ?? 0,
        completed_at: p?.completed_at ?? null,
        updated_at: now(),
      };
      if (spent > 0) touchActivity(s, spent, 0, 0);
      let newly = false;
      if (input.completed) {
        if (lesson.type === 'quiz') throw new AppError('complete_via_quiz');
        newly = completeLesson(s, lessonId);
      }
      const ach = evaluateAchievements(s);
      await save();
      return {
        lesson_id: lessonId,
        newly_completed: newly,
        xp_awarded: newly ? lesson.xp : 0,
        enrollment: s.enrollments[lesson.course_id] ?? null,
        certificate: s.certificates.find((c) => c.course_id === lesson.course_id) ?? null,
        new_achievements: ach,
      };
    },

    getEarnedAchievements: async () => (await load()).earned,
    getCertificates: async () => (await load()).certificates,

    async claimCertificate(courseId) {
      const s = await load();
      recompute(s, courseId);
      const cert = issueCertificate(s, courseId);
      if (!cert) throw new AppError('certificate_not_eligible');
      evaluateAchievements(s);
      await save();
      return cert;
    },

    async getBookmarks() {
      const s = await load();
      return s.bookmarks.map((b) => {
        const l = lessonById.get(b.lesson_id);
        const c = l ? courseById.get(l.course_id) : undefined;
        return { ...b, lesson: l && c ? { id: l.id, title: l.title, type: l.type, course: { id: c.id, slug: c.slug, title: c.title, cover_style: c.cover_style, category: c.category ? { color: c.category.color } : null } } : undefined };
      });
    },
    async addBookmark(lessonId, positionSeconds, label) {
      const s = await load();
      const l = lessonById.get(lessonId)!;
      const b: Bookmark = { id: uid(), lesson_id: lessonId, course_id: l.course_id, position_seconds: positionSeconds ?? null, label: label ?? null, created_at: now() };
      s.bookmarks.unshift(b);
      await save();
      return b;
    },
    async removeBookmark(id) {
      const s = await load();
      s.bookmarks = s.bookmarks.filter((b) => b.id !== id);
      await save();
    },

    getNotes: async (lessonId) => (await load()).notes.filter((n) => n.lesson_id === lessonId),
    async addNote(lessonId, body, positionSeconds) {
      const s = await load();
      const n: LessonNote = { id: uid(), lesson_id: lessonId, body: body.trim(), position_seconds: positionSeconds ?? null, created_at: now() };
      s.notes.push(n);
      await save();
      return n;
    },
    async deleteNote(id) {
      const s = await load();
      s.notes = s.notes.filter((n) => n.id !== id);
      await save();
    },

    getSubmissions: async (assignmentId) => (await load()).submissions.filter((x) => x.assignment_id === assignmentId),
    uploadSubmissionFile: async (_a, file) => `demo/${file.name}`,
    async submitAssignment(assignmentId, input) {
      const s = await load();
      const a = catalog.assignments.find((x) => x.id === assignmentId);
      if (!a) throw new AppError('assignment_locked');
      const sub: Submission = { id: uid(), assignment_id: assignmentId, body_md: input.body ?? null, url: input.url ?? null, file_paths: input.filePaths ?? [], status: 'submitted', score: null, feedback_md: null, submitted_at: now(), reviewed_at: null };
      s.submissions.unshift(sub);
      if (a.lesson_id) completeLesson(s, a.lesson_id);
      evaluateAchievements(s);
      await save();
      return sub;
    },

    getNotifications: async () => (await load()).notifications,
    async markNotificationsRead(ids) {
      const s = await load();
      s.notifications = s.notifications.map((n) => (ids.includes(n.id) ? { ...n, read: true } : n));
      await save();
    },
    registerPushToken: async () => {},
  };
}
