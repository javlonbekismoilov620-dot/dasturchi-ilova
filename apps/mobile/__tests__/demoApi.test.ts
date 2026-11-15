import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { createDemoApi, migrateLegacyIds, resetDemoState, setDemoPremium } from '@/data/demo/demoApi';
import catalog from '@/data/demo/catalog.json';
import { localizeContent, UNTRANSLATED } from '@/i18n/content';

type Q = { id: string; title: string; course_id: string; kind: string; questions: { id: string; type: string; answers: { id: string; label_md: string; is_correct: boolean }[] }[] };
const quizzes = (catalog as unknown as { quizzes: Q[] }).quizzes;
const keyFor = (title: string) => {
  const q = quizzes.find((x) => x.title === title)!;
  const correct: Record<string, string[] | string> = {};
  const wrong: Record<string, string[] | string> = {};
  for (const qq of q.questions) {
    if (qq.type === 'short_answer') {
      correct[qq.id] = qq.answers.find((a) => a.is_correct)!.label_md;
      wrong[qq.id] = 'nope';
    } else {
      correct[qq.id] = qq.answers.filter((a) => a.is_correct).map((a) => a.id);
      wrong[qq.id] = [qq.answers.find((a) => !a.is_correct)!.id];
    }
  }
  return { id: q.id, correct, wrong };
};

describe('demo mode engine (mirrors the SQL engine)', () => {
  const api = createDemoApi();
  beforeEach(() => resetDemoState());

  it('never exposes answer keys through getQuiz', async () => {
    const q = await api.getQuiz(keyFor('Module 1 check').id);
    expect(JSON.stringify(q)).not.toContain('is_correct');
  });

  it('grades quizzes, awards XP once and completes the lesson', async () => {
    const { id, correct, wrong } = keyFor('Module 1 check');
    const fail = await api.submitQuiz(id, wrong);
    expect(fail.passed).toBe(false);
    expect(fail.results.every((r) => !r.correct && r.correct_answer_ids.length > 0)).toBe(true);
    const pass = await api.submitQuiz(id, correct);
    expect([pass.passed, pass.score_percent, pass.lesson_completed, pass.xp_awarded]).toEqual([true, 100, true, 20]);
    const again = await api.submitQuiz(id, correct);
    expect(again.xp_awarded).toBe(0);
  });

  it('locks premium lessons until premium, except previews', async () => {
    const course = await api.getCourse('python-for-complete-beginners');
    const lessons = course!.modules.flatMap((m) => m.lessons);
    const preview = lessons.find((l) => l.is_preview)!;
    const locked = lessons.find((l) => !l.is_preview)!;
    await expect(api.getLessonContent(preview.id)).resolves.toBeTruthy();
    await expect(api.getLessonContent(locked.id)).rejects.toThrow('lesson_locked');
    await setDemoPremium(true);
    await expect(api.getLessonContent(locked.id)).resolves.toBeTruthy();
  });

  it('completes a course only after the final assessment; certificate needs premium', async () => {
    const course = (await api.getCourse('computer-fundamentals-from-zero'))!;
    const lessons = course.modules.flatMap((m) => m.lessons);
    for (const l of lessons.filter((l) => !['quiz', 'project', 'assignment'].includes(l.type))) {
      await api.recordProgress(l.id, { completed: true });
    }
    const project = lessons.find((l) => l.type === 'project')!;
    await expect(api.recordProgress(project.id, { completed: true })).rejects.toThrow('complete_via_submission');
    const assignment = (catalog as unknown as { assignments: { id: string; lesson_id: string }[] }).assignments.find((a) => a.lesson_id === project.id)!;
    await api.submitAssignment(assignment.id, { body: 'My plan for a family computer' });
    for (const q of quizzes.filter((q) => q.course_id === course.id && q.kind === 'knowledge_check')) {
      const k = keyFor(q.title);
      expect((await api.submitQuiz(k.id, k.correct)).passed).toBe(true);
    }
    let [enr] = await api.getEnrollments();
    expect(enr.status).toBe('active');
    const fin = keyFor('Computer Fundamentals — final assessment');
    const res = await api.submitQuiz(fin.id, fin.correct);
    expect(res.enrollment?.status).toBe('completed');
    expect(res.certificate).toBeNull();
    await setDemoPremium(true);
    const cert = await api.claimCertificate(course.id);
    expect(cert.serial).toMatch(/^DEMO-/);
    [enr] = await api.getEnrollments();
    expect(enr.progress_percent).toBe(100);
    const stats = await api.getStats();
    expect(stats.current_streak).toBe(1);
    expect(stats.certificates).toBe(1);
  });
  it('every published course opens in Uzbek and completes end to end, only after its final assessment', async () => {
    await setDemoPremium(true);
    const all = catalog as unknown as { courses: { id: string; slug: string; status: string }[]; assignments: { id: string; lesson_id: string | null; course_id: string }[] };
    const published = all.courses.filter((c) => c.status === 'published');
    expect(published).toHaveLength(8);
    for (const { slug } of published) {
      const course = (await api.getCourse(slug))!;
      const lessons = course.modules.flatMap((m) => m.lessons);
      for (const l of lessons) {
        const content = await api.getLessonContent(l.id);
        if (content.body_md) {
          const uz = localizeContent(content, 'uz') as unknown as Record<string, unknown>;
          expect([slug, l.title, uz[UNTRANSLATED] ?? false]).toEqual([slug, l.title, false]);
        }
      }
      for (const l of lessons.filter((x) => !['quiz', 'project', 'assignment'].includes(x.type))) {
        await api.recordProgress(l.id, { completed: true });
      }
      for (const a of all.assignments.filter((x) => x.course_id === course.id)) {
        await api.submitAssignment(a.id, { body: 'My finished project', url: 'https://example.com/project' });
      }
      const courseQuizzes = quizzes.filter((q) => q.course_id === course.id);
      for (const q of courseQuizzes.filter((x) => x.kind !== 'final_assessment')) {
        const k = keyFor(q.title);
        expect([slug, q.title, (await api.submitQuiz(k.id, k.correct)).passed]).toEqual([slug, q.title, true]);
      }
      const before = (await api.getEnrollments()).find((e) => e.course_id === course.id)!;
      expect([slug, before.status]).toEqual([slug, 'active']);
      const finals = courseQuizzes.filter((x) => x.kind === 'final_assessment');
      expect(finals.length).toBeGreaterThan(0);
      for (const q of finals) {
        const k = keyFor(q.title);
        expect((await api.submitQuiz(k.id, k.wrong)).passed).toBe(false);
        expect((await api.submitQuiz(k.id, k.correct)).passed).toBe(true);
      }
      const after = (await api.getEnrollments()).find((e) => e.course_id === course.id)!;
      expect([slug, after.status, after.progress_percent]).toEqual([slug, 'completed', 100]);
    }
    const certs = await api.getCertificates();
    expect(certs).toHaveLength(8);
  }, 120_000);
  it('carries progress saved by an older build over to the current IDs', () => {
    const legacy = (catalog as unknown as { legacyIds: Record<string, string> }).legacyIds;
    const [oldId, newId] = Object.entries(legacy)[0];
    const lessonIds = new Set((catalog as unknown as { lessons: { id: string }[] }).lessons.map((l) => l.id));
    const oldLesson = Object.keys(legacy).find((k) => lessonIds.has(legacy[k]))!;
    const saved = JSON.stringify({ progress: { [oldLesson]: { lesson_id: oldLesson, status: 'completed' } }, attempts: [{ quiz_id: oldId }] });
    const migrated = JSON.parse(migrateLegacyIds(saved));
    expect(migrated.progress[legacy[oldLesson]].lesson_id).toBe(legacy[oldLesson]);
    expect(migrated.attempts[0].quiz_id).toBe(newId);
    const current = JSON.stringify({ progress: { [legacy[oldLesson]]: {} } });
    expect(migrateLegacyIds(current)).toBe(current);
  });
  it('ignores saved progress for lessons that are not in the catalog', async () => {
    const course = (await api.getCourse('computer-fundamentals-from-zero'))!;
    const lesson = course.modules[0].lessons[0];
    await api.recordProgress(lesson.id, { completed: true });
    const raw = JSON.parse((await AsyncStorage.getItem('mahorat.demo.state.v1'))!);
    raw.progress['00000000-0000-4000-8000-0000000000ff'] = { ...raw.progress[lesson.id], lesson_id: '00000000-0000-4000-8000-0000000000ff' };
    // A fresh engine (as after an app restart) loading that saved state.
    let recent: { lesson_id: string }[] = [];
    await jest.isolateModulesAsync(async () => {
      // eslint-disable-next-line @typescript-eslint/no-require-imports -- a fresh module instance is the point
      const mod = require('@react-native-async-storage/async-storage') as { default?: typeof AsyncStorage } & typeof AsyncStorage;
      await (mod.default ?? mod).setItem('mahorat.demo.state.v1', JSON.stringify(raw));
      // eslint-disable-next-line @typescript-eslint/no-require-imports -- loaded after the storage above is seeded
      const { createDemoApi: create } = require('@/data/demo/demoApi') as typeof import('@/data/demo/demoApi');
      recent = await create().getRecentLessons();
    });
    expect(recent.map((r) => r.lesson_id)).toEqual([lesson.id]);
  });
});
