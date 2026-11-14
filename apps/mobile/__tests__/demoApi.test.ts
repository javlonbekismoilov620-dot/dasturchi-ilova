import { describe, it, expect, beforeEach } from '@jest/globals';
import { createDemoApi, resetDemoState, setDemoPremium } from '@/data/demo/demoApi';
import catalog from '@/data/demo/catalog.json';

type Q = { id: string; title: string; questions: { id: string; type: string; answers: { id: string; label_md: string; is_correct: boolean }[] }[] };
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
    for (const l of course.modules.flatMap((m) => m.lessons).filter((l) => l.type !== 'quiz')) {
      await api.recordProgress(l.id, { completed: true });
    }
    await api.submitQuiz(keyFor('Module 1 check').id, keyFor('Module 1 check').correct);
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
});
