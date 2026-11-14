// Content audit for the published starter library: translation completeness, Uzbek
// orthography, Markdown structure parity with the base language, and quiz integrity.
// Used by content.test.mjs (CI) and scripts/content-report.mjs (human-readable report).
import { execSync } from 'node:child_process';
import { createClient } from '@supabase/supabase-js';

export const LOCALE = 'uz';

export async function loadLibrary() {
  const status = JSON.parse(execSync('npx supabase status -o json', { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }));
  const db = createClient(status.API_URL, status.SERVICE_ROLE_KEY, { auth: { persistSession: false } });
  const all = async (table, select = '*') => {
    const { data, error } = await db.from(table).select(select).limit(5000);
    if (error) throw new Error(`${table}: ${error.message}`);
    return data;
  };
  // The starter library is seeded by the platform (created_by is null); courses authored
  // later in Mahorat Studio are audited by their editors.
  const courses = (await all('courses')).filter((c) => c.created_by === null);
  const courseIds = new Set(courses.map((c) => c.id));
  const modules = (await all('modules')).filter((m) => courseIds.has(m.course_id));
  const lessons = (await all('lessons')).filter((l) => courseIds.has(l.course_id));
  const lessonIds = new Set(lessons.map((l) => l.id));
  const contents = (await all('lesson_contents', 'lesson_id, body_md, translations')).filter((c) => lessonIds.has(c.lesson_id));
  const quizzes = (await all('quizzes')).filter((q) => courseIds.has(q.course_id));
  const quizIds = new Set(quizzes.map((q) => q.id));
  const questions = (await all('questions')).filter((q) => quizIds.has(q.quiz_id));
  const questionIds = new Set(questions.map((q) => q.id));
  const answers = (await all('answers')).filter((a) => questionIds.has(a.question_id));
  const assignments = (await all('assignments')).filter((a) => courseIds.has(a.course_id));
  return {
    courses, modules, lessons, contents, quizzes, questions, answers, assignments,
    categories: await all('categories'),
    paths: await all('learning_paths'),
    achievements: await all('achievements'),
    plans: await all('subscription_plans'),
    instructors: (await all('instructors')).filter((i) => courses.some((c) => c.instructor_id === i.id)),
  };
}

// --- Text helpers --------------------------------------------------------------------
/** Prose only: removes fenced code blocks, inline code and URLs before language checks. */
export function prose(md) {
  return (md ?? '')
    .replace(/```[\s\S]*?```/g, ' ')
    .replace(/`[^`\n]*`/g, ' ')
    .replace(/https?:\/\/\S+/g, ' ');
}

export function words(md) {
  return prose(md).split(/\s+/).filter((w) => /\p{L}/u.test(w)).length;
}

/** Shape of a Markdown document that a faithful translation must keep. */
export function structure(md) {
  const text = md ?? '';
  return {
    codeBlocks: [...text.matchAll(/```(\w*)/g)].map((m) => m[1]).filter((_, i) => i % 2 === 0),
    headings: (text.match(/^#{1,6} /gm) ?? []).map((h) => h.trim()),
    callouts: [...text.matchAll(/^> \[!(\w+)\]/gm)].map((m) => m[1]),
    tableRows: (text.match(/^\|/gm) ?? []).length,
    listItems: (text.match(/^\s*(?:[-*]|\d+\.) /gm) ?? []).length,
  };
}

// Words that require the tutuq belgisi (ʼ) — written without it they are misspellings.
const NEEDS_TUTUQ = [
  ['malumot', 'maʼlumot'], ['taminot', 'taʼminot'], ['suniy', 'sunʼiy'], ['etibor', 'eʼtibor'],
  ['talim', 'taʼlim'], ['mano', 'maʼno'], ['masul', 'masʼul'], ['elon', 'eʼlon'],
  ['tasir', 'taʼsir'], ['qatiy', 'qatʼiy'], ['bazi', 'baʼzi'], ['yani', 'yaʼni'], ['sanat', 'sanʼat'],
];

/** Returns a list of orthography problems in an Uzbek (Latin) text. */
export function orthographyIssues(md) {
  const text = prose(md);
  const issues = [];
  const add = (re, why) => {
    for (const m of text.matchAll(re)) issues.push(`${why}: “…${text.slice(Math.max(0, m.index - 12), m.index + 14).replace(/\s+/g, ' ')}…”`);
  };
  add(/[oOgG]['‘’`ʼ´]/g, 'oʻ/gʻ must use ʻ (U+02BB)');
  add(/[^oOgG\s]ʻ/g, 'ʻ (U+02BB) is only for oʻ/gʻ — use ʼ (U+02BC) for the tutuq belgisi');
  add(/\p{L}'\p{L}/gu, 'ASCII apostrophe inside a word');
  add(/[Ѐ-ӿ]/g, 'Cyrillic letter in Uzbek Latin text');
  for (const [wrong, right] of NEEDS_TUTUQ) {
    add(new RegExp(`(?<![\\p{L}ʻʼ])${wrong}`, 'giu'), `“${wrong}” should be “${right}”`);
  }
  return issues;
}

export function tr(row, field) {
  const v = row?.translations?.[LOCALE]?.[field];
  return typeof v === 'string' ? v.trim() : v;
}
