import { describe, expect, it } from '@jest/globals';

import { createDemoApi, resetDemoState } from '@/data/demo/demoApi';
import catalog from '@/data/demo/catalog.json';
import { localizeContent, UNTRANSLATED } from '@/i18n/content';

type Row = Record<string, unknown>;

const course = {
  id: 'c1',
  language: 'en',
  title: 'HTML from Absolute Zero',
  learning_outcomes: ['Write HTML'],
  translations: { uz: { title: 'HTML: mutlaq noldan', learning_outcomes: ['HTML yozasiz'], subtitle: '' } },
  modules: [
    {
      id: 'm1',
      title: 'How the web works',
      translations: { uz: { title: 'Internet qanday ishlaydi' } },
      lessons: [{ id: 'l1', title: 'What is HTML?', translations: {} }],
    },
  ],
};

describe('localizeContent', () => {
  it('shows the overlay for the learner’s language and keeps IDs untouched', () => {
    const uz = localizeContent(course, 'uz') as unknown as Row & { modules: Row[] };
    expect(uz.id).toBe('c1');
    expect(uz.title).toBe('HTML: mutlaq noldan');
    expect(uz.learning_outcomes).toEqual(['HTML yozasiz']);
    expect(uz.modules[0].title).toBe('Internet qanday ishlaydi');
    expect('translations' in uz).toBe(false);
    expect(uz[UNTRANSLATED]).toBeUndefined();
  });

  it('ignores empty overlay values instead of blanking the original', () => {
    const uz = localizeContent({ ...course, subtitle: 'Original subtitle' }, 'uz') as unknown as Row;
    expect(uz.subtitle).toBe('Original subtitle');
  });

  it('falls back to the original text and marks it when no translation exists', () => {
    const ru = localizeContent(course, 'ru') as unknown as Row & { modules: (Row & { lessons: Row[] })[] };
    expect(ru.title).toBe('HTML from Absolute Zero');
    expect(ru[UNTRANSLATED]).toBe(true);
    expect(ru.modules[0].lessons[0][UNTRANSLATED]).toBe(true);
  });

  it('never flags content shown in its own base language', () => {
    expect((localizeContent(course, 'en') as unknown as Row)[UNTRANSLATED]).toBeUndefined();
    const uzBase = { language: 'uz', title: 'Oʻzbekcha kurs', translations: {}, modules: [{ title: 'Modul', translations: {} }] };
    const shown = localizeContent(uzBase, 'uz') as unknown as Row & { modules: Row[] };
    expect(shown[UNTRANSLATED]).toBeUndefined();
    expect(shown.modules[0][UNTRANSLATED]).toBeUndefined();
  });

  it('leaves primitives, nulls and untranslatable objects alone', () => {
    expect(localizeContent(null, 'uz')).toBeNull();
    expect(localizeContent('text', 'uz')).toBe('text');
    expect(localizeContent({ a: 1, b: [1, 2] }, 'uz')).toEqual({ a: 1, b: [1, 2] });
  });
});

describe('Uzbek content in demo mode (the Expo Go preview)', () => {
  const api = createDemoApi();

  it('ships an Uzbek translation for every published course, lesson and quiz option', () => {
    const c = catalog as unknown as { courses: Row[]; lessons: Row[]; contents: Row[]; quizzes: { questions: { answers: Row[] }[] }[] };
    const hasUz = (r: Row) => !!(r.translations as Record<string, unknown> | undefined)?.uz;
    expect(c.courses.every(hasUz)).toBe(true);
    expect(c.lessons.every(hasUz)).toBe(true);
    expect(c.contents.filter((x) => x.body_md).every(hasUz)).toBe(true);
    expect(c.quizzes.flatMap((q) => q.questions.flatMap((qq) => qq.answers)).every(hasUz)).toBe(true);
  });

  it('localizes a course end to end', async () => {
    const detail = await api.getCourse('computer-fundamentals-from-zero');
    const uz = localizeContent(detail, 'uz')!;
    expect(uz.title).toBe('Kompyuter asoslari: noldan boshlab');
    expect(uz.modules[0].lessons[0].title).toBe('Kompyuter nima?');
  });

  it('serves translated lesson bodies with the course base language', async () => {
    resetDemoState();
    const detail = (await api.getCourse('computer-fundamentals-from-zero'))!;
    const content = await api.getLessonContent(detail.modules[0].lessons[0].id);
    expect(content.language).toBe('en');
    expect(localizeContent(content, 'uz').body_md).toMatch(/Koʻrsatmalarga amal qiladigan mashina/);
    const ru = localizeContent(content, 'ru');
    expect(ru.content_untranslated).toBe(true);
    expect(ru.body_md).toMatch(/A machine that follows instructions/);
  });

  it('hides translated explanations until the quiz is submitted, then returns them', async () => {
    resetDemoState();
    const quizMeta = (catalog as unknown as { quizzes: { id: string; title: string }[] }).quizzes.find((q) => q.title === 'Module 1 check')!;
    const quiz = await api.getQuiz(quizMeta.id);
    const json = JSON.stringify(quiz);
    expect(json).not.toContain('explanation_md');
    expect(json).not.toContain('feedback_md');
    expect(localizeContent(quiz, 'uz').questions[0].prompt_md).toMatch(/Yuborish/);

    const wrong = Object.fromEntries(quiz.questions.map((q) => [q.id, [q.answers[q.answers.length - 1].id]]));
    const result = localizeContent(await api.submitQuiz(quizMeta.id, wrong), 'uz');
    expect(result.results.every((r) => /[ʻʼ]|[a-z]/.test(r.explanation_md ?? ''))).toBe(true);
    expect(result.results[0].explanation_md).toMatch(/kiritish/);
  });
});
