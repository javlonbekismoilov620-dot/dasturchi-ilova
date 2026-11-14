// Exports the published starter catalog from a local Supabase (seeded via
// `npx supabase db reset`) into the bundle used by demo mode. Demo mode therefore
// shows exactly the same starter content as the real backend — nothing is invented here.
//   node apps/mobile/scripts/export-demo-catalog.mjs
import { execSync } from 'node:child_process';
import { writeFileSync } from 'node:fs';
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
const out = join(here, '../src/data/demo/catalog.json');
writeFileSync(out, JSON.stringify(catalog));
console.log(`wrote ${out}: ${courses.length} courses, ${lessons.length} lessons, ${quizzes.length} quizzes`);
