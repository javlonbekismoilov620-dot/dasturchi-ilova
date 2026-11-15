// Exports the published starter catalog from a local Supabase (seeded via
// `npx supabase db reset`) into the bundle used by demo mode. Demo mode therefore
// shows exactly the same starter content as the real backend — nothing is invented here.
//   node apps/mobile/scripts/export-demo-catalog.mjs [--legacy <older catalog.json>]
//
// IDs stay stable across exports. A fresh `db reset` gives every row a new random UUID, but
// demo progress on a device is keyed by these IDs, so every item that already exists in the
// current catalog keeps its ID (matched by a natural key such as course slug + lesson title).
// `--legacy` adds an older catalog's IDs to `legacyIds`, which demo mode uses to carry
// progress saved by an older build over to the current IDs.
import { execSync } from 'node:child_process';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createClient } from '@supabase/supabase-js';

const here = dirname(fileURLToPath(import.meta.url));
const status = JSON.parse(execSync('npx supabase status -o json', { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'], cwd: join(here, '../../..') }));
const db = createClient(status.API_URL, status.SERVICE_ROLE_KEY, { auth: { persistSession: false } });
const q = async (p) => { const { data, error } = await p; if (error) throw error; return data; };

const courses = await q(db.from('courses').select('*').eq('status', 'published').order('title'));
const courseIds = new Set(courses.map((c) => c.id));
const modules = (await q(db.from('modules').select('*').eq('status', 'published').order('position'))).filter((m) => courseIds.has(m.course_id));
const moduleIds = new Set(modules.map((m) => m.id));
const lessons = (await q(db.from('lessons').select('*').eq('status', 'published').order('position'))).filter((l) => moduleIds.has(l.module_id));
const lessonIds = new Set(lessons.map((l) => l.id));
const contents = (await q(db.from('lesson_contents').select('lesson_id, body_md, translations'))).filter((c) => lessonIds.has(c.lesson_id));
const quizzes = (await q(db.from('quizzes').select('*, questions(*, answers(*))').eq('status', 'published'))).filter((x) => courseIds.has(x.course_id) && (!x.lesson_id || lessonIds.has(x.lesson_id)));
const assignments = (await q(db.from('assignments').select('*').eq('status', 'published'))).filter((a) => courseIds.has(a.course_id));
const paths = await q(db.from('learning_paths').select('*, learning_path_courses(course_id, position)').eq('status', 'published').order('position'));

const strip = (o, keys) => Object.fromEntries(Object.entries(o).filter(([k]) => !keys.includes(k)));
const catalog = {
  _notice: 'DEMO CONTENT exported from supabase/seeds. Used only when no backend is configured. Regenerate with scripts/export-demo-catalog.mjs.',
  exportedAt: new Date().toISOString().slice(0, 10),
  settings: Object.fromEntries((await q(db.from('app_settings').select('key, value').eq('is_public', true))).map((r) => [r.key, r.value])),
  categories: await q(db.from('categories').select('*').eq('status', 'published').order('position')),
  instructors: await q(db.from('instructors').select('id, slug, name, headline, bio, avatar_path, is_verified')),
  courses: courses.map((c) => strip(c, ['search_vector', 'created_by', 'created_at', 'updated_at'])),
  prerequisites: (await q(db.from('course_prerequisites').select('*'))).filter((p) => courseIds.has(p.course_id) && courseIds.has(p.prerequisite_course_id)),
  modules: modules.map((m) => strip(m, ['created_at', 'updated_at', 'status'])),
  lessons: lessons.map((l) => strip(l, ['created_at', 'updated_at', 'status'])),
  contents,
  quizzes: quizzes.map((x) => ({
    ...strip(x, ['created_at', 'updated_at', 'status']),
    questions: x.questions.sort((a, b) => a.position - b.position).map((qq) => ({
      ...strip(qq, ['created_at', 'updated_at', 'quiz_id']),
      answers: qq.answers.sort((a, b) => a.position - b.position).map((a) => strip(a, ['question_id'])),
    })),
  })),
  assignments: assignments.map((a) => strip(a, ['created_at', 'updated_at', 'status'])),
  paths: paths.map((p) => ({ ...strip(p, ['created_at', 'updated_at', 'status']), courses: p.learning_path_courses.filter((x) => courseIds.has(x.course_id)) })).map((p) => strip(p, ['learning_path_courses'])),
  achievements: await q(db.from('achievements').select('*').eq('is_active', true).order('position')),
  plans: await q(db.from('subscription_plans').select('*').eq('is_active', true).order('position')),
};
// ---- Stable IDs ------------------------------------------------------------
// Natural keys for every entity that carries its own ID.
function naturalKeys(cat) {
  const keys = new Map(); // id -> natural key
  const slugOf = new Map(cat.courses.map((c) => [c.id, c.slug]));
  const put = (id, key) => id && keys.set(id, key);
  for (const x of cat.categories) put(x.id, `category|${x.slug}`);
  for (const x of cat.instructors) put(x.id, `instructor|${x.slug}`);
  for (const x of cat.courses) put(x.id, `course|${x.slug}`);
  for (const x of cat.modules) put(x.id, `module|${slugOf.get(x.course_id)}|${x.title}`);
  for (const x of cat.lessons) put(x.id, `lesson|${slugOf.get(x.course_id)}|${x.title}`);
  for (const x of cat.assignments) put(x.id, `assignment|${slugOf.get(x.course_id)}|${x.title}`);
  for (const x of cat.paths) put(x.id, `path|${x.slug}`);
  for (const x of cat.achievements) put(x.id, `achievement|${x.slug}`);
  for (const x of cat.plans) put(x.id, `plan|${x.slug}`);
  for (const quiz of cat.quizzes) {
    const qk = `quiz|${slugOf.get(quiz.course_id)}|${quiz.title}`;
    put(quiz.id, qk);
    for (const question of quiz.questions) {
      put(question.id, `${qk}|q${question.position}`);
      for (const answer of question.answers) put(answer.id, `${qk}|q${question.position}|a${answer.position}`);
    }
  }
  return keys;
}
const invert = (m) => new Map([...m].map(([id, key]) => [key, id]));
const UUID = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/g;
const remap = (json, map) => json.replace(UUID, (id) => map.get(id) ?? id);

const out = join(here, '../src/data/demo/catalog.json');
const previous = existsSync(out) ? JSON.parse(readFileSync(out, 'utf8')) : null;
let json = JSON.stringify(catalog);
let legacyIds = { ...(previous?.legacyIds ?? {}) };
if (previous) {
  const prevByKey = invert(naturalKeys(previous));
  const toPrevious = new Map();
  for (const [id, key] of naturalKeys(catalog)) if (prevByKey.has(key)) toPrevious.set(id, prevByKey.get(key));
  json = remap(json, toPrevious);
  const kept = new Set(toPrevious.values());
  const dropped = [...prevByKey].filter(([, id]) => !kept.has(id)).map(([key]) => key);
  console.log(`stable IDs: kept ${kept.size} of ${prevByKey.size} existing IDs${dropped.length ? `; no longer present: ${dropped.join(', ')}` : ''}`);
}
const legacyArg = process.argv.indexOf('--legacy');
if (legacyArg > 0) {
  const older = JSON.parse(readFileSync(process.argv[legacyArg + 1], 'utf8'));
  const currentByKey = invert(naturalKeys(JSON.parse(json)));
  let added = 0;
  for (const [oldId, key] of naturalKeys(older)) {
    const id = currentByKey.get(key);
    if (id && id !== oldId) { legacyIds[oldId] = id; added += 1; }
  }
  console.log(`legacy IDs: mapped ${added} IDs from ${process.argv[legacyArg + 1]}`);
}
const final = JSON.parse(json);
final.legacyIds = legacyIds;
writeFileSync(out, JSON.stringify(final));
console.log(`wrote ${out}: ${courses.length} courses, ${lessons.length} lessons, ${quizzes.length} quizzes`);
