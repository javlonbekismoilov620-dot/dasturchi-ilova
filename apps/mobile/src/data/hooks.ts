import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { create } from 'zustand';

import { api } from '.';
import type { UploadableFile } from './api';
import { useAuth } from './auth';
import type { CourseFilters, EarnedAchievement, Profile, ProgressResult, QuizResponses, QuizResult } from './types';

export const qk = {
  settings: ['settings'] as const,
  categories: ['categories'] as const,
  search: (f: CourseFilters) => ['courses', 'search', f] as const,
  featured: ['courses', 'featured'] as const,
  popular: ['courses', 'popular'] as const,
  newest: ['courses', 'new'] as const,
  recommended: (uid: string | undefined) => ['courses', 'recommended', uid ?? 'guest'] as const,
  course: (slug: string) => ['course', slug] as const,
  courseById: (id: string) => ['course', 'id', id] as const,
  paths: ['paths'] as const,
  path: (slug: string) => ['path', slug] as const,
  achievementsCatalog: ['achievements', 'catalog'] as const,
  plans: ['plans'] as const,
  lesson: (id: string) => ['lesson', id] as const,
  quiz: (id: string) => ['quiz', id] as const,
  me: (uid: string | undefined) => ['me', uid ?? 'guest'] as const,
  profile: (uid?: string) => ['me', uid ?? 'guest', 'profile'] as const,
  entitlements: (uid?: string) => ['me', uid ?? 'guest', 'entitlements'] as const,
  stats: (uid?: string) => ['me', uid ?? 'guest', 'stats'] as const,
  enrollments: (uid?: string) => ['me', uid ?? 'guest', 'enrollments'] as const,
  progress: (uid: string | undefined, courseId: string) => ['me', uid ?? 'guest', 'progress', courseId] as const,
  recent: (uid?: string) => ['me', uid ?? 'guest', 'recent'] as const,
  earned: (uid?: string) => ['me', uid ?? 'guest', 'achievements'] as const,
  certificates: (uid?: string) => ['me', uid ?? 'guest', 'certificates'] as const,
  bookmarks: (uid?: string) => ['me', uid ?? 'guest', 'bookmarks'] as const,
  notes: (uid: string | undefined, lessonId: string) => ['me', uid ?? 'guest', 'notes', lessonId] as const,
  submissions: (uid: string | undefined, assignmentId: string) => ['me', uid ?? 'guest', 'submissions', assignmentId] as const,
  notifications: (uid?: string) => ['me', uid ?? 'guest', 'notifications'] as const,
};

const useUid = () => useAuth((s) => s.user?.id);
const useSignedIn = () => useAuth((s) => s.status === 'signedIn');

// ---------------------------------------------------------------------------
// Celebrations (lesson complete, achievements, certificates) — consumed by
// <CelebrationHost/>, fed by mutation results from the learning engine.
// ---------------------------------------------------------------------------
export type Celebration =
  | { kind: 'achievement'; achievement: EarnedAchievement }
  | { kind: 'certificate'; courseTitle: string; certificateId: string }
  | { kind: 'xp'; amount: number };

interface CelebrationState {
  queue: Celebration[];
  push: (...items: Celebration[]) => void;
  shift: () => void;
}

export const useCelebrations = create<CelebrationState>((set) => ({
  queue: [],
  push: (...items) => set((s) => ({ queue: [...s.queue, ...items] })),
  shift: () => set((s) => ({ queue: s.queue.slice(1) })),
}));

function celebrate(result: Pick<ProgressResult, 'new_achievements' | 'certificate' | 'xp_awarded'>, hadCertificate: boolean) {
  const items: Celebration[] = [];
  if (result.xp_awarded > 0) items.push({ kind: 'xp', amount: result.xp_awarded });
  for (const a of result.new_achievements ?? []) items.push({ kind: 'achievement', achievement: a });
  if (result.certificate && !hadCertificate) items.push({ kind: 'certificate', courseTitle: result.certificate.course_title, certificateId: result.certificate.id });
  if (items.length) useCelebrations.getState().push(...items);
}

// ---------------------------------------------------------------------------
// Catalog
// ---------------------------------------------------------------------------
export const useSettings = () => useQuery({ queryKey: qk.settings, queryFn: () => api.getSettings(), staleTime: 5 * 60_000 });
export const useCategories = () => useQuery({ queryKey: qk.categories, queryFn: () => api.getCategories(), staleTime: 30 * 60_000 });
export const useSearchCourses = (f: CourseFilters) =>
  useQuery({ queryKey: qk.search(f), queryFn: () => api.searchCourses(f, 40), placeholderData: keepPreviousData });
export const useFeaturedCourses = () => useQuery({ queryKey: qk.featured, queryFn: () => api.getFeaturedCourses(8) });
export const usePopularCourses = () => useQuery({ queryKey: qk.popular, queryFn: () => api.getPopularCourses(10) });
export const useNewCourses = () => useQuery({ queryKey: qk.newest, queryFn: () => api.getNewCourses(10) });
export function useRecommendedCourses() {
  const uid = useUid();
  return useQuery({ queryKey: qk.recommended(uid), queryFn: () => api.getRecommendedCourses(10) });
}
export const useCourse = (slug: string | undefined) =>
  useQuery({ queryKey: qk.course(slug ?? ''), queryFn: () => api.getCourse(slug!), enabled: !!slug });
export const useCourseById = (id: string | undefined) =>
  useQuery({ queryKey: qk.courseById(id ?? ''), queryFn: () => api.getCourseById(id!), enabled: !!id });
export const usePaths = () => useQuery({ queryKey: qk.paths, queryFn: () => api.getPaths() });
export const usePath = (slug: string | undefined) => useQuery({ queryKey: qk.path(slug ?? ''), queryFn: () => api.getPath(slug!), enabled: !!slug });
export const usePlans = () => useQuery({ queryKey: qk.plans, queryFn: () => api.getPlans(), staleTime: 10 * 60_000 });

export function useLessonContent(lessonId: string | undefined) {
  const uid = useUid();
  const premium = useEntitlements().data?.is_premium;
  return useQuery({
    queryKey: [...qk.lesson(lessonId ?? ''), uid ?? 'guest', premium ? 'p' : 'f'],
    queryFn: () => api.getLessonContent(lessonId!),
    enabled: !!lessonId,
    staleTime: 30 * 60_000, // signed media URLs live for 6h
  });
}

export const useLessonCourseId = (lessonId: string | undefined) =>
  useQuery({ queryKey: ['lessonCourse', lessonId ?? ''], queryFn: () => api.getLessonCourseId(lessonId!), enabled: !!lessonId, staleTime: Infinity });

export function useQuiz(quizId: string | null | undefined) {
  const uid = useUid();
  return useQuery({ queryKey: [...qk.quiz(quizId ?? ''), uid ?? 'guest'], queryFn: () => api.getQuiz(quizId!), enabled: !!quizId, staleTime: 0 });
}

// ---------------------------------------------------------------------------
// Learner
// ---------------------------------------------------------------------------
export function useProfile() {
  const uid = useUid();
  return useQuery({ queryKey: qk.profile(uid), queryFn: () => api.getProfile(), enabled: useSignedIn() });
}

export function useEntitlements() {
  const uid = useUid();
  return useQuery({ queryKey: qk.entitlements(uid), queryFn: () => api.getEntitlements(), enabled: useSignedIn(), staleTime: 60_000 });
}

export function useStats() {
  const uid = useUid();
  return useQuery({ queryKey: qk.stats(uid), queryFn: () => api.getStats(), enabled: useSignedIn() });
}

export function useEnrollments() {
  const uid = useUid();
  return useQuery({ queryKey: qk.enrollments(uid), queryFn: () => api.getEnrollments(), enabled: useSignedIn() });
}

export function useCourseProgress(courseId: string | undefined) {
  const uid = useUid();
  return useQuery({ queryKey: qk.progress(uid, courseId ?? ''), queryFn: () => api.getCourseProgress(courseId!), enabled: useSignedIn() && !!courseId });
}

export function useRecentLessons() {
  const uid = useUid();
  return useQuery({ queryKey: qk.recent(uid), queryFn: () => api.getRecentLessons(12), enabled: useSignedIn() });
}

export function useAchievements() {
  const uid = useUid();
  const catalog = useQuery({ queryKey: qk.achievementsCatalog, queryFn: () => api.getAchievementCatalog(), staleTime: 60 * 60_000 });
  const earned = useQuery({ queryKey: qk.earned(uid), queryFn: () => api.getEarnedAchievements(), enabled: useSignedIn() });
  return { catalog, earned };
}

export function useCertificates() {
  const uid = useUid();
  return useQuery({ queryKey: qk.certificates(uid), queryFn: () => api.getCertificates(), enabled: useSignedIn() });
}

export function useBookmarks() {
  const uid = useUid();
  return useQuery({ queryKey: qk.bookmarks(uid), queryFn: () => api.getBookmarks(), enabled: useSignedIn() });
}

export function useNotes(lessonId: string | undefined) {
  const uid = useUid();
  return useQuery({ queryKey: qk.notes(uid, lessonId ?? ''), queryFn: () => api.getNotes(lessonId!), enabled: useSignedIn() && !!lessonId });
}

export function useSubmissions(assignmentId: string | undefined) {
  const uid = useUid();
  return useQuery({ queryKey: qk.submissions(uid, assignmentId ?? ''), queryFn: () => api.getSubmissions(assignmentId!), enabled: useSignedIn() && !!assignmentId });
}

export function useNotifications() {
  const uid = useUid();
  return useQuery({ queryKey: qk.notifications(uid), queryFn: () => api.getNotifications(), enabled: useSignedIn(), refetchInterval: 5 * 60_000 });
}

// ---------------------------------------------------------------------------
// Mutations
// ---------------------------------------------------------------------------
function useInvalidateLearner() {
  const qc = useQueryClient();
  const uid = useUid();
  return () => qc.invalidateQueries({ queryKey: qk.me(uid) });
}

export function useEnroll() {
  const invalidate = useInvalidateLearner();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (courseId: string) => api.enroll(courseId),
    onSuccess: () => {
      invalidate();
      qc.invalidateQueries({ queryKey: ['courses', 'recommended'] });
    },
  });
}

export function useLeaveCourse() {
  const invalidate = useInvalidateLearner();
  return useMutation({ mutationFn: (courseId: string) => api.leaveCourse(courseId), onSuccess: invalidate });
}

export function useRecordProgress() {
  const invalidate = useInvalidateLearner();
  return useMutation({
    mutationFn: (v: { lessonId: string; positionSeconds?: number; secondsSpent?: number; completed?: boolean; hadCertificate?: boolean }) =>
      api.recordProgress(v.lessonId, v),
    onSuccess: (result, v) => {
      if (v.completed) celebrate(result, !!v.hadCertificate);
      else if (result.new_achievements.length) celebrate({ ...result, xp_awarded: 0 }, true);
      invalidate();
    },
  });
}

export function useSubmitQuiz() {
  const invalidate = useInvalidateLearner();
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (v: { quizId: string; responses: QuizResponses; startedAt?: string; hadCertificate?: boolean }) => api.submitQuiz(v.quizId, v.responses, v.startedAt),
    onSuccess: (result: QuizResult, v) => {
      celebrate(result, !!v.hadCertificate);
      invalidate();
      qc.invalidateQueries({ queryKey: qk.quiz(v.quizId) });
    },
  });
}

export function useToggleBookmark() {
  const qc = useQueryClient();
  const uid = useUid();
  return useMutation({
    mutationFn: async (v: { lessonId: string; existingId?: string | null; positionSeconds?: number | null; label?: string | null }) => {
      if (v.existingId) {
        await api.removeBookmark(v.existingId);
        return null;
      }
      return api.addBookmark(v.lessonId, v.positionSeconds, v.label);
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: qk.bookmarks(uid) }),
  });
}

export function useAddNote(lessonId: string) {
  const qc = useQueryClient();
  const uid = useUid();
  return useMutation({
    mutationFn: (v: { body: string; positionSeconds?: number | null }) => api.addNote(lessonId, v.body, v.positionSeconds),
    onSuccess: () => qc.invalidateQueries({ queryKey: qk.notes(uid, lessonId) }),
  });
}

export function useDeleteNote(lessonId: string) {
  const qc = useQueryClient();
  const uid = useUid();
  return useMutation({ mutationFn: (id: string) => api.deleteNote(id), onSuccess: () => qc.invalidateQueries({ queryKey: qk.notes(uid, lessonId) }) });
}

export function useSubmitAssignment(assignmentId: string) {
  const invalidate = useInvalidateLearner();
  return useMutation({
    mutationFn: async (v: { body?: string; url?: string; files: UploadableFile[] }) => {
      const filePaths = [];
      for (const f of v.files) filePaths.push(await api.uploadSubmissionFile(assignmentId, f));
      return api.submitAssignment(assignmentId, { body: v.body, url: v.url, filePaths });
    },
    onSuccess: invalidate,
  });
}

export function useClaimCertificate() {
  const invalidate = useInvalidateLearner();
  return useMutation({
    mutationFn: (courseId: string) => api.claimCertificate(courseId),
    onSuccess: (cert) => {
      useCelebrations.getState().push({ kind: 'certificate', courseTitle: cert.course_title, certificateId: cert.id });
      invalidate();
    },
  });
}

export function useMarkNotificationsRead() {
  const qc = useQueryClient();
  const uid = useUid();
  return useMutation({ mutationFn: (ids: string[]) => api.markNotificationsRead(ids), onSuccess: () => qc.invalidateQueries({ queryKey: qk.notifications(uid) }) });
}

export function useUpdateProfile() {
  const qc = useQueryClient();
  const uid = useUid();
  return useMutation({
    mutationFn: (patch: Partial<Profile>) => api.updateProfile(patch),
    onSuccess: (p) => {
      qc.setQueryData(qk.profile(uid), p);
      qc.invalidateQueries({ queryKey: ['courses', 'recommended'] });
    },
  });
}
