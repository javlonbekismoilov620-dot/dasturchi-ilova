import { File as FSFile } from 'expo-file-system';
import { Platform } from 'react-native';

import { AppError, unwrap } from '@/lib/errors';
import { getSupabase } from '@/lib/supabase';

import type { LearningApi, RecentLesson, UploadableFile } from './api';
import type {
  Achievement,
  Assignment,
  AppNotification,
  Bookmark,
  Category,
  Certificate,
  Course,
  CourseDetail,
  Enrollment,
  Entitlements,
  LearningPath,
  LearningStats,
  LessonContent,
  LessonNote,
  LessonProgress,
  LessonVideo,
  ProgressResult,
  Profile,
  PublicSettings,
  Quiz,
  QuizResult,
  Resource,
  Submission,
  SubscriptionPlan,
  UserAchievement,
} from './types';

const COURSE_SELECT =
  '*, category:categories!courses_category_id_fkey(id, slug, title, color, icon, translations), subcategory:categories!courses_subcategory_id_fkey(id, slug, title, translations), instructor:instructors(*)';

const LESSON_COURSE_SELECT =
  'id, title, type, duration_seconds, translations, course:courses(id, slug, title, language, translations, cover_style, category:categories!courses_category_id_fkey(color))';

const SIGNED_URL_TTL = 60 * 60 * 6;

async function userId(): Promise<string> {
  const { data } = await getSupabase().auth.getSession();
  const id = data.session?.user.id;
  if (!id) throw new AppError('not_authenticated');
  return id;
}

async function optionalUserId(): Promise<string | null> {
  const { data } = await getSupabase().auth.getSession();
  return data.session?.user.id ?? null;
}

function nestCategories(rows: Category[]): Category[] {
  const top = rows.filter((c) => !c.parent_id).sort((a, b) => a.position - b.position);
  return top.map((c) => ({
    ...c,
    children: rows.filter((s) => s.parent_id === c.id).sort((a, b) => a.position - b.position),
  }));
}

async function signed(bucket: string, path: string) {
  const { data, error } = await getSupabase().storage.from(bucket).createSignedUrl(path, SIGNED_URL_TTL);
  if (error) throw new AppError('lesson_locked', error.message);
  return data.signedUrl;
}

type VideoRow = {
  id: string;
  provider: LessonVideo['provider'];
  storage_path: string | null;
  external_id: string | null;
  external_url: string | null;
  poster_path: string | null;
  duration_seconds: number | null;
  video_sources: { quality: string; storage_path: string }[];
  video_captions: { language: string; label: string; storage_path: string }[];
};

async function resolveVideo(v: VideoRow): Promise<LessonVideo> {
  const base = { id: v.id, provider: v.provider, duration_seconds: v.duration_seconds };
  const captions = await Promise.all(
    v.video_captions.map(async (c) => ({ language: c.language, label: c.label, uri: await signed('course-media', c.storage_path) })),
  );
  const posterUri = v.poster_path ? await signed('course-media', v.poster_path).catch(() => null) : null;
  switch (v.provider) {
    case 'mux':
      return { ...base, sources: [{ uri: `https://stream.mux.com/${v.external_id}.m3u8`, quality: null }], captions, posterUri: posterUri ?? `https://image.mux.com/${v.external_id}/thumbnail.jpg` };
    case 'cloudflare_stream':
      return { ...base, sources: [{ uri: `https://videodelivery.net/${v.external_id}/manifest/video.m3u8`, quality: null }], captions, posterUri };
    case 'external':
      return { ...base, sources: [{ uri: v.external_url!, quality: null }], captions, posterUri };
    default: {
      const renditions = [...v.video_sources].sort((a, b) => parseInt(b.quality, 10) - parseInt(a.quality, 10));
      const sources: LessonVideo['sources'] = await Promise.all(renditions.map(async (s) => ({ uri: await signed('course-media', s.storage_path), quality: s.quality })));
      if (v.storage_path) sources.unshift({ uri: await signed('course-media', v.storage_path), quality: null });
      return { ...base, sources, captions, posterUri };
    }
  }
}

export function createSupabaseApi(): LearningApi {
  const sb = () => getSupabase();

  const api: LearningApi = {
    mode: 'supabase',

    async getSettings() {
      const rows = unwrap(await sb().from('app_settings').select('key, value')) ?? [];
      return Object.fromEntries(rows.map((r: { key: string; value: unknown }) => [r.key, r.value])) as PublicSettings;
    },

    async getCategories() {
      const rows = unwrap(await sb().from('categories').select('*').order('position'));
      return nestCategories(rows as Category[]);
    },

    async searchCourses(f, limit = 30, offset = 0) {
      const rows = unwrap(
        await sb()
          .rpc('search_courses', {
            p_query: f.query || null,
            p_category_slug: f.categorySlug || null,
            p_levels: f.levels?.length ? f.levels : null,
            p_tier: f.tier || null,
            p_sort: f.sort ?? 'relevance',
            p_limit: limit,
            p_offset: offset,
          })
          .select(COURSE_SELECT),
      );
      return rows as Course[];
    },

    async getFeaturedCourses(limit = 8) {
      return unwrap(
        await sb().from('courses').select(COURSE_SELECT).eq('status', 'published').eq('is_featured', true).order('published_at', { ascending: false }).limit(limit),
      ) as Course[];
    },

    async getPopularCourses(limit = 10) {
      return unwrap(
        await sb().from('courses').select(COURSE_SELECT).eq('status', 'published').order('enrollment_count', { ascending: false }).order('title').limit(limit),
      ) as Course[];
    },

    async getNewCourses(limit = 10) {
      return unwrap(
        await sb().from('courses').select(COURSE_SELECT).eq('status', 'published').order('published_at', { ascending: false }).limit(limit),
      ) as Course[];
    },

    async getRecommendedCourses(limit = 10) {
      return unwrap(await sb().rpc('recommended_courses', { p_limit: limit }).select(COURSE_SELECT)) as Course[];
    },

    async getCourse(slug) {
      return loadCourse('slug', slug);
    },

    async getCourseById(id) {
      return loadCourse('id', id);
    },

    async getPaths() {
      const rows = unwrap(
        await sb()
          .from('learning_paths')
          .select(`*, learning_path_courses(position, course:courses(${COURSE_SELECT}))`)
          .order('position'),
      );
      return (rows as RawPath[]).map(mapPath);
    },

    async getPath(slug) {
      const row = unwrap(
        await sb()
          .from('learning_paths')
          .select(`*, learning_path_courses(position, course:courses(${COURSE_SELECT}))`)
          .eq('slug', slug)
          .maybeSingle(),
      );
      return row ? mapPath(row as RawPath) : null;
    },

    async getAchievementCatalog() {
      return unwrap(await sb().from('achievements').select('*').order('position')) as Achievement[];
    },

    async getPlans() {
      return unwrap(await sb().from('subscription_plans').select('*').eq('is_active', true).order('position')) as SubscriptionPlan[];
    },

    async getLessonCourseId(lessonId) {
      const row = unwrap(await sb().from('lessons').select('course_id').eq('id', lessonId).maybeSingle()) as { course_id: string } | null;
      return row?.course_id ?? null;
    },

    async getAssignment(id) {
      return unwrap(await sb().from('assignments').select('*').eq('id', id).maybeSingle()) as Assignment | null;
    },

    async getLessonContent(lessonId) {
      const lesson = unwrap(
        await sb().from('lessons').select('id, is_preview, course:courses(access_tier, language)').eq('id', lessonId).maybeSingle(),
      ) as { id: string; is_preview: boolean; course: { access_tier: string; language: string } | null } | null;
      if (!lesson) throw new AppError('lesson_not_found');

      const [content, resources, quiz, assignment] = await Promise.all([
        sb()
          .from('lesson_contents')
          .select('lesson_id, body_md, translations, video:videos(id, provider, storage_path, external_id, external_url, poster_path, duration_seconds, video_sources(quality, storage_path), video_captions(language, label, storage_path))')
          .eq('lesson_id', lessonId)
          .maybeSingle(),
        sb().from('resources').select('*').eq('lesson_id', lessonId).order('position'),
        sb().from('quizzes').select('id').eq('lesson_id', lessonId).eq('status', 'published').maybeSingle(),
        sb().from('assignments').select('*').eq('lesson_id', lessonId).eq('status', 'published').maybeSingle(),
      ]);
      const row = unwrap(content) as { body_md: string | null; translations: Record<string, unknown>; video: VideoRow | null } | null;
      if (!row && lesson.course?.access_tier === 'premium' && !lesson.is_preview) {
        const ent = await api.getEntitlements().catch(() => null);
        if (!ent?.is_premium) throw new AppError('lesson_locked');
      }
      return {
        lesson_id: lessonId,
        language: lesson.course?.language ?? 'en',
        body_md: row?.body_md ?? null,
        ...(row ? { translations: row.translations } : {}),
        video: row?.video ? await resolveVideo(row.video) : null,
        resources: (unwrap(resources) ?? []) as Resource[],
        quiz_id: (unwrap(quiz) as { id: string } | null)?.id ?? null,
        assignment: (unwrap(assignment) as LessonContent['assignment']) ?? null,
      };
    },

    async getResourceUrl(resource) {
      if (resource.external_url) return resource.external_url;
      return signed('resources', resource.storage_path!);
    },

    async getQuiz(quizId) {
      return unwrap(await sb().rpc('get_quiz', { p_quiz_id: quizId })) as Quiz;
    },

    async submitQuiz(quizId, responses, startedAt) {
      return unwrap(await sb().rpc('submit_quiz_attempt', { p_quiz_id: quizId, p_responses: responses, p_started_at: startedAt ?? null })) as QuizResult;
    },

    async getProfile() {
      const id = await optionalUserId();
      if (!id) return null;
      return unwrap(await sb().from('profiles').select('*').eq('id', id).maybeSingle()) as Profile | null;
    },

    async updateProfile(patch) {
      const id = await userId();
      return unwrap(await sb().from('profiles').update(patch).eq('id', id).select('*').single()) as Profile;
    },

    async getEntitlements() {
      return unwrap(await sb().rpc('my_entitlements')) as Entitlements;
    },

    async getStats() {
      return unwrap(await sb().rpc('my_learning_stats')) as LearningStats;
    },

    async getEnrollments() {
      const id = await optionalUserId();
      if (!id) return [];
      return unwrap(
        await sb().from('enrollments').select(`*, course:courses(${COURSE_SELECT})`).eq('user_id', id).neq('status', 'dropped').order('last_accessed_at', { ascending: false }),
      ) as Enrollment[];
    },

    async enroll(courseId) {
      return unwrap(await sb().rpc('enroll_in_course', { p_course_id: courseId })) as Enrollment;
    },

    async leaveCourse(courseId) {
      unwrap(await sb().rpc('leave_course', { p_course_id: courseId }));
    },

    async getCourseProgress(courseId) {
      const id = await optionalUserId();
      if (!id) return [];
      return unwrap(await sb().from('lesson_progress').select('*').eq('user_id', id).eq('course_id', courseId)) as LessonProgress[];
    },

    async getRecentLessons(limit = 10) {
      const id = await optionalUserId();
      if (!id) return [];
      return unwrap(
        await sb().from('lesson_progress').select(`*, lesson:lessons(${LESSON_COURSE_SELECT})`).eq('user_id', id).order('updated_at', { ascending: false }).limit(limit),
      ) as RecentLesson[];
    },

    async recordProgress(lessonId, input) {
      return unwrap(
        await sb().rpc('record_lesson_progress', {
          p_lesson_id: lessonId,
          p_position_seconds: input.positionSeconds ?? null,
          p_seconds_spent: Math.round(input.secondsSpent ?? 0),
          p_completed: input.completed ?? false,
        }),
      ) as ProgressResult;
    },

    async getEarnedAchievements() {
      const id = await optionalUserId();
      if (!id) return [];
      return unwrap(await sb().from('user_achievements').select('achievement_id, earned_at').eq('user_id', id)) as UserAchievement[];
    },

    async getCertificates() {
      const id = await optionalUserId();
      if (!id) return [];
      return unwrap(await sb().from('certificates').select('*').eq('user_id', id).order('issued_at', { ascending: false })) as Certificate[];
    },

    async claimCertificate(courseId) {
      return unwrap(await sb().rpc('claim_certificate', { p_course_id: courseId })) as Certificate;
    },

    async getBookmarks() {
      const id = await optionalUserId();
      if (!id) return [];
      return unwrap(
        await sb().from('bookmarks').select(`*, lesson:lessons(${LESSON_COURSE_SELECT})`).eq('user_id', id).order('created_at', { ascending: false }),
      ) as Bookmark[];
    },

    async addBookmark(lessonId, positionSeconds, label) {
      const id = await userId();
      return unwrap(
        await sb().from('bookmarks').insert({ user_id: id, lesson_id: lessonId, position_seconds: positionSeconds ?? null, label: label ?? null }).select('*').single(),
      ) as Bookmark;
    },

    async removeBookmark(id) {
      unwrap(await sb().from('bookmarks').delete().eq('id', id));
    },

    async getNotes(lessonId) {
      const id = await optionalUserId();
      if (!id) return [];
      return unwrap(await sb().from('lesson_notes').select('*').eq('user_id', id).eq('lesson_id', lessonId).order('created_at')) as LessonNote[];
    },

    async addNote(lessonId, body, positionSeconds) {
      const id = await userId();
      return unwrap(
        await sb().from('lesson_notes').insert({ user_id: id, lesson_id: lessonId, body: body.trim(), position_seconds: positionSeconds ?? null }).select('*').single(),
      ) as LessonNote;
    },

    async deleteNote(id) {
      unwrap(await sb().from('lesson_notes').delete().eq('id', id));
    },

    async getSubmissions(assignmentId) {
      const id = await optionalUserId();
      if (!id) return [];
      return unwrap(
        await sb().from('submissions').select('*').eq('user_id', id).eq('assignment_id', assignmentId).order('submitted_at', { ascending: false }),
      ) as Submission[];
    },

    async uploadSubmissionFile(assignmentId, file: UploadableFile) {
      const id = await userId();
      const safeName = file.name.replace(/[^A-Za-z0-9._-]+/g, '_').slice(-80) || 'file';
      const path = `${id}/${assignmentId}/${Date.now()}-${safeName}`;
      const body = Platform.OS === 'web' ? await (await fetch(file.uri)).blob() : await new FSFile(file.uri).arrayBuffer();
      unwrap(
        await sb().storage.from('submissions').upload(path, body, { contentType: file.mimeType ?? 'application/octet-stream', upsert: false }),
      );
      return path;
    },

    async submitAssignment(assignmentId, input) {
      return unwrap(
        await sb().rpc('submit_assignment', {
          p_assignment_id: assignmentId,
          p_body_md: input.body ?? null,
          p_url: input.url ?? null,
          p_file_paths: input.filePaths ?? [],
        }),
      ) as Submission;
    },

    async getNotifications() {
      const id = await optionalUserId();
      if (!id) return [];
      const rows = unwrap(
        await sb().from('notifications').select('*, notification_reads(read_at)').order('created_at', { ascending: false }).limit(50),
      ) as (Omit<AppNotification, 'read'> & { notification_reads: { read_at: string }[] })[];
      return rows.map(({ notification_reads, ...n }) => ({ ...n, read: notification_reads.length > 0 }));
    },

    async markNotificationsRead(ids) {
      if (!ids.length) return;
      unwrap(await sb().rpc('mark_notifications_read', { p_ids: ids }));
    },

    async registerPushToken(token, platform, deviceName) {
      const id = await userId();
      unwrap(
        await sb()
          .from('push_tokens')
          .upsert({ user_id: id, token, platform, device_name: deviceName ?? null, last_seen_at: new Date().toISOString() }, { onConflict: 'token' }),
      );
    },
  };

  async function loadCourse(field: 'slug' | 'id', value: string): Promise<CourseDetail | null> {
    const row = unwrap(
      await sb()
        .from('courses')
        .select(
          `${COURSE_SELECT}, modules(*, lessons(id, module_id, course_id, title, summary, type, position, duration_seconds, is_preview, is_required, xp, translations)), prereqs:course_prerequisites!course_prerequisites_course_id_fkey(prerequisite:courses!course_prerequisites_prerequisite_course_id_fkey(id, slug, title, language, translations))`,
        )
        .eq(field, value)
        .order('position', { referencedTable: 'modules' })
        .order('position', { referencedTable: 'modules.lessons' })
        .maybeSingle(),
    ) as (CourseDetail & { prereqs: { prerequisite: { id: string; slug: string; title: string } | null }[] }) | null;
    if (!row) return null;
    const { prereqs, ...course } = row;
    return {
      ...course,
      modules: course.modules.filter((m) => m.lessons.length > 0),
      prerequisite_courses: prereqs.map((p) => p.prerequisite).filter((p): p is { id: string; slug: string; title: string } => !!p),
    };
  }

  return api;
}

type RawPath = Omit<LearningPath, 'courses'> & { learning_path_courses: { position: number; course: Course | null }[] };

function mapPath(p: RawPath): LearningPath {
  const { learning_path_courses, ...rest } = p;
  return {
    ...rest,
    courses: learning_path_courses
      .filter((x) => x.course)
      .map((x) => ({ ...(x.course as Course), path_position: x.position }))
      .sort((a, b) => a.path_position - b.path_position),
  };
}

export type { Entitlements, LearningStats, PublicSettings };
