// Content audit of the starter library (runs first in `npm run db:test`, right after the
// database is reset and seeded). It fails on any untranslated published text, any Uzbek
// orthography error, any translation that changes a lesson's structure, and any quiz that
// cannot be answered or graded correctly.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { loadLibrary, orthographyIssues, structure, tr } from './content-audit-lib.mjs';

let lib;
const published = (rows) => rows.filter((r) => r.status === 'published');
before(async () => {
  lib = await loadLibrary();
});

function requireFields(problems, label, row, fields) {
  for (const f of fields) {
    const base = row[f];
    if (base === null || base === undefined || (Array.isArray(base) && base.length === 0) || base === '') continue;
    const v = tr(row, f);
    if (v === undefined || v === null || v === '' || (Array.isArray(v) && v.length === 0)) problems.push(`${label}: missing uz.${f}`);
    else if (Array.isArray(base) && (!Array.isArray(v) || v.length !== base.length)) problems.push(`${label}: uz.${f} has ${v?.length} items, base has ${base.length}`);
  }
}

test('every published text in the starter library has an Uzbek translation', () => {
  const problems = [];
  const pubLessons = published(lib.lessons);
  const pubLessonIds = new Set(pubLessons.map((l) => l.id));
  for (const c of published(lib.courses)) requireFields(problems, `course ${c.slug}`, c, ['title', 'subtitle', 'description', 'learning_outcomes', 'prerequisites']);
  for (const m of published(lib.modules)) requireFields(problems, `module ${m.title}`, m, ['title', 'description']);
  for (const l of pubLessons) requireFields(problems, `lesson ${l.title}`, l, ['title', 'summary']);
  for (const c of lib.contents.filter((x) => pubLessonIds.has(x.lesson_id))) requireFields(problems, `lesson body ${c.lesson_id}`, c, ['body_md']);
  for (const q of published(lib.quizzes)) requireFields(problems, `quiz ${q.title}`, q, ['title', 'description']);
  const pubQuizIds = new Set(published(lib.quizzes).map((q) => q.id));
  const pubQuestions = lib.questions.filter((q) => pubQuizIds.has(q.quiz_id));
  for (const q of pubQuestions) requireFields(problems, `question ${q.prompt_md.slice(0, 40)}`, q, ['prompt_md', 'explanation_md']);
  const pubQuestionIds = new Set(pubQuestions.map((q) => q.id));
  for (const a of lib.answers.filter((x) => pubQuestionIds.has(x.question_id))) requireFields(problems, `answer ${a.label_md}`, a, ['label_md', 'feedback_md']);
  for (const a of published(lib.assignments)) requireFields(problems, `assignment ${a.title}`, a, ['title', 'brief_md', 'rubric_md']);
  for (const c of published(lib.categories)) requireFields(problems, `category ${c.slug}`, c, ['title', 'subtitle', 'description']);
  for (const p of published(lib.paths)) requireFields(problems, `path ${p.slug}`, p, ['title', 'subtitle', 'description']);
  for (const a of lib.achievements.filter((x) => x.is_active)) requireFields(problems, `achievement ${a.slug}`, a, ['title', 'description']);
  for (const p of lib.plans.filter((x) => x.is_active)) requireFields(problems, `plan ${p.slug}`, p, ['title', 'description', 'features']);
  for (const i of lib.instructors) requireFields(problems, `instructor ${i.slug}`, i, ['name', 'headline', 'bio']);
  assert.deepEqual(problems, []);
});

test('Uzbek text follows the Latin orthography (ʻ for oʻ/gʻ, ʼ for the tutuq belgisi, no Cyrillic)', () => {
  const problems = [];
  const check = (label, row) => {
    for (const [field, value] of Object.entries(row.translations?.uz ?? {})) {
      for (const v of Array.isArray(value) ? value : [value]) {
        if (typeof v !== 'string' || field === 'code_snippet') continue;
        for (const issue of orthographyIssues(v)) problems.push(`${label}.${field}: ${issue}`);
      }
    }
  };
  for (const [table, rows] of Object.entries(lib)) for (const r of rows) check(`${table}:${r.slug ?? r.title ?? r.id ?? r.lesson_id}`, r);
  assert.deepEqual(problems, []);
});

test('translated lessons keep the structure of the original (code, headings, callouts, tables, lists)', () => {
  const problems = [];
  for (const c of lib.contents) {
    const uz = tr(c, 'body_md');
    if (!c.body_md || !uz) continue;
    const a = structure(c.body_md);
    const b = structure(uz);
    const title = lib.lessons.find((l) => l.id === c.lesson_id)?.title;
    for (const k of Object.keys(a)) {
      if (JSON.stringify(a[k]) !== JSON.stringify(b[k])) problems.push(`${title}: ${k} differs — en ${JSON.stringify(a[k])} vs uz ${JSON.stringify(b[k])}`);
    }
  }
  assert.deepEqual(problems, []);
});

test('every quiz can be answered and graded, and every question explains its answer', () => {
  const problems = [];
  const lessonById = new Map(lib.lessons.map((l) => [l.id, l]));
  for (const quiz of published(lib.quizzes)) {
    const qs = lib.questions.filter((q) => q.quiz_id === quiz.id);
    if (!qs.length) problems.push(`${quiz.title}: no questions`);
    if (quiz.lesson_id && lessonById.get(quiz.lesson_id)?.status !== 'published') problems.push(`${quiz.title}: attached lesson is not published`);
    for (const q of qs) {
      const as = lib.answers.filter((a) => a.question_id === q.id);
      const correct = as.filter((a) => a.is_correct);
      const label = `${quiz.title} / Q${q.position}`;
      if (!q.explanation_md) problems.push(`${label}: no explanation`);
      if (q.type === 'short_answer') {
        if (!correct.length) problems.push(`${label}: no accepted answer`);
        continue;
      }
      if (as.length < 2) problems.push(`${label}: fewer than two options`);
      if (q.type === 'multiple_choice' ? correct.length < 1 : correct.length !== 1) problems.push(`${label}: ${correct.length} correct options for ${q.type}`);
      const labels = as.map((a) => tr(a, 'label_md') ?? a.label_md);
      if (new Set(labels).size !== labels.length) problems.push(`${label}: duplicate Uzbek option labels`);
    }
  }
  // Every published quiz-type lesson must have a quiz.
  for (const l of published(lib.lessons).filter((x) => x.type === 'quiz')) {
    if (!lib.quizzes.some((q) => q.lesson_id === l.id && q.status === 'published')) problems.push(`lesson ${l.title}: quiz lesson without a quiz`);
  }
  assert.deepEqual(problems, []);
});

test('published courses have published lessons, bodies for reading lessons and honest status flags', () => {
  const problems = [];
  for (const c of published(lib.courses)) {
    const ls = published(lib.lessons).filter((l) => l.course_id === c.id);
    if (!ls.length) problems.push(`${c.slug}: no published lessons`);
    if (c.lesson_count !== ls.length) problems.push(`${c.slug}: lesson_count ${c.lesson_count} ≠ ${ls.length} published lessons`);
    for (const l of ls.filter((x) => ['article', 'exercise', 'project'].includes(x.type))) {
      if (!lib.contents.find((x) => x.lesson_id === l.id)?.body_md) problems.push(`${c.slug} / ${l.title}: no body`);
    }
    if (c.content_complete) problems.push(`${c.slug}: marked content_complete — only set this when the course is genuinely finished`);
  }
  assert.deepEqual(problems, []);
});
