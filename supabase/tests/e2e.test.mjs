// End-to-end backend tests against a running local Supabase stack.
//   npx supabase start && npx supabase db reset
//   node --test supabase/tests/e2e.test.mjs
// Exercises Auth, PostgREST + RLS, RPCs and Storage policies as real users.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { execSync } from 'node:child_process';
import { createClient } from '@supabase/supabase-js';

const status = JSON.parse(execSync('npx supabase status -o json', { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }));
const URL = status.API_URL;
const ANON = status.ANON_KEY;
const SERVICE = status.SERVICE_ROLE_KEY;

const opts = { auth: { persistSession: false, autoRefreshToken: false } };
const admin = createClient(URL, SERVICE, opts); // service role: bypasses RLS (setup only)
const anon = createClient(URL, ANON, opts);
const run = Date.now().toString(36);
const PASSWORD = 'Test-pass-2026';

async function makeUser(label, roles = []) {
  const email = `${label}-${run}@test.mahorat.local`;
  const { data, error } = await admin.auth.admin.createUser({
    email, password: PASSWORD, email_confirm: true, user_metadata: { full_name: `${label} tester` },
  });
  assert.ifError(error);
  for (const role of roles) {
    const { error: e } = await admin.from('user_roles').insert({ user_id: data.user.id, role });
    assert.ifError(e);
  }
  const client = createClient(URL, ANON, opts);
  const { error: signInError } = await client.auth.signInWithPassword({ email, password: PASSWORD });
  assert.ifError(signInError);
  return { id: data.user.id, email, client };
}

const ids = {};
let student, student2, editor, instructor, adminUser;

before(async () => {
  const { data: courses } = await admin.from('courses').select('id, slug');
  for (const c of courses) ids[c.slug] = c.id;
  const { data: lessons } = await admin.from('lessons').select('id, title, course_id, type, status, is_preview');
  ids.lessons = lessons;
  student = await makeUser('student');
  student2 = await makeUser('student2');
  editor = await makeUser('editor', ['editor']);
  instructor = await makeUser('instructor', ['instructor']);
  adminUser = await makeUser('admin', ['admin']);
});

const lessonByTitle = (title) => {
  const l = ids.lessons.find((x) => x.title === title);
  assert.ok(l, `lesson "${title}" exists`);
  return l;
};

test('anonymous visitors see only published catalog', async () => {
  const { data, error } = await anon.from('courses').select('slug, status');
  assert.ifError(error);
  assert.equal(data.length, 8);
  assert.ok(data.every((c) => c.status === 'published'));
  const { data: lessons } = await anon.from('lessons').select('id, status');
  assert.ok(lessons.length > 0 && lessons.every((l) => l.status === 'published'));
  const { data: cats } = await anon.from('categories').select('id').is('parent_id', null);
  assert.equal(cats.length, 7);
});

test('lesson bodies follow entitlement (free / premium / preview)', async () => {
  const free = lessonByTitle('What is a computer?');
  const premiumPreview = lessonByTitle('What is programming?');
  const premiumLocked = lessonByTitle('Variables: giving names to values');
  const r1 = await anon.from('lesson_contents').select('body_md').eq('lesson_id', free.id);
  assert.equal(r1.data.length, 1);
  const r2 = await anon.from('lesson_contents').select('body_md').eq('lesson_id', premiumPreview.id);
  assert.equal(r2.data.length, 1, 'preview lesson readable');
  const r3 = await student.client.from('lesson_contents').select('body_md').eq('lesson_id', premiumLocked.id);
  assert.equal(r3.data.length, 0, 'premium lesson hidden from free student');
});

test('answer keys are never readable by learners', async () => {
  for (const c of [anon, student.client]) {
    const { data: a } = await c.from('answers').select('id, is_correct');
    assert.equal(a.length, 0);
    const { data: q } = await c.from('questions').select('id');
    assert.equal(q.length, 0);
  }
  const { data: quizzes } = await anon.from('quizzes').select('id, title').eq('title', 'Module 1 check');
  const { data: quiz, error } = await anon.rpc('get_quiz', { p_quiz_id: quizzes[0].id });
  assert.ifError(error);
  assert.equal(quiz.questions.length, 5);
  const json = JSON.stringify(quiz);
  assert.ok(!json.includes('is_correct') && !json.includes('feedback_md') && !json.includes('explanation_md'));
});

test('signup creates profile + student role; privileged columns are protected', async () => {
  const { data: profile } = await student.client.from('profiles').select('*').eq('id', student.id).single();
  assert.equal(profile.display_name, 'student tester');
  const { data: roles } = await student.client.from('user_roles').select('role');
  assert.deepEqual(roles.map((r) => r.role), ['student']);

  const { error: upErr } = await student.client.from('profiles')
    .update({ display_name: 'Aziza', total_xp: 999999, current_streak: 500, interests: ['blender-3d', 'programming'], experience_level: 'zero' })
    .eq('id', student.id);
  assert.ifError(upErr);
  const { data: after } = await admin.from('profiles').select('display_name, total_xp, current_streak').eq('id', student.id).single();
  assert.equal(after.display_name, 'Aziza');
  assert.equal(after.total_xp, 0);
  assert.equal(after.current_streak, 0);

  const { error: tzErr } = await student.client.from('profiles').update({ timezone: 'Mars/Olympus' }).eq('id', student.id);
  assert.ok(tzErr, 'invalid timezone rejected');
  const { error: tzOk } = await student.client.from('profiles').update({ timezone: 'Asia/Tashkent' }).eq('id', student.id);
  assert.ifError(tzOk);

  const { data: others } = await student.client.from('profiles').select('id');
  assert.equal(others.length, 1, 'cannot read other profiles');
});

test('privilege escalation is blocked', async () => {
  const { error } = await student.client.from('user_roles').insert({ user_id: student.id, role: 'admin' });
  assert.ok(error);
  const { error: e2 } = await student.client.from('lesson_progress').insert({
    user_id: student.id, lesson_id: lessonByTitle('What is a computer?').id, course_id: ids['computer-fundamentals-from-zero'], status: 'completed',
  });
  assert.ok(e2);
  const { error: e3 } = await student.client.from('subscriptions').insert({ user_id: student.id, platform: 'manual', status: 'active' });
  assert.ok(e3);
  const { error: e4 } = await student.client.rpc('admin_dashboard_stats');
  assert.ok(e4);
  const { error: e5 } = await student.client.rpc('admin_grant_premium', { p_user_id: student.id, p_days: 30 });
  assert.ok(e5);
  const { error: e6 } = await student.client.from('courses').update({ title: 'hacked' }).eq('id', ids['html-from-absolute-zero']).select();
  const { data: c } = await admin.from('courses').select('title').eq('id', ids['html-from-absolute-zero']).single();
  assert.notEqual(c.title, 'hacked', `course not modified (${e6?.message ?? 'filtered by RLS'})`);
});

test('progress, XP, streak and achievements', async () => {
  const lesson = lessonByTitle('What is a computer?');
  const { data: r1, error } = await student.client.rpc('record_lesson_progress', {
    p_lesson_id: lesson.id, p_position_seconds: 0, p_seconds_spent: 240, p_completed: true,
  });
  assert.ifError(error);
  assert.equal(r1.newly_completed, true);
  assert.equal(r1.xp_awarded, 10);
  assert.ok(r1.new_achievements.some((a) => a.slug === 'first-step'));
  assert.ok(r1.enrollment.progress_percent > 0);

  const { data: r2 } = await student.client.rpc('record_lesson_progress', { p_lesson_id: lesson.id, p_completed: true });
  assert.equal(r2.newly_completed, false, 'idempotent');

  const { data: big } = await student.client.rpc('record_lesson_progress', { p_lesson_id: lesson.id, p_seconds_spent: 999999 });
  assert.ok(big);
  const { data: stats } = await student.client.rpc('my_learning_stats');
  assert.equal(stats.current_streak, 1);
  assert.equal(stats.lessons_completed, 1);
  assert.equal(stats.total_seconds, 240 + 600, 'heartbeat time is capped at 10 minutes');
  assert.equal(stats.last_7_days.length, 7);

  const { error: locked } = await student.client.rpc('record_lesson_progress', {
    p_lesson_id: lessonByTitle('Variables: giving names to values').id, p_completed: true,
  });
  assert.match(locked.message, /lesson_locked/);

  const quizLesson = ids.lessons.find((l) => l.course_id === ids['computer-fundamentals-from-zero'] && l.title === 'Check your understanding');
  const { error: viaQuiz } = await student.client.rpc('record_lesson_progress', { p_lesson_id: quizLesson.id, p_completed: true });
  assert.match(viaQuiz.message, /complete_via_quiz/);
});

async function answerKey(quizTitle) {
  const { data: quiz } = await admin.from('quizzes').select('id, questions(id, type, answers(id, label_md, is_correct))').eq('title', quizTitle).single();
  const correct = {};
  const wrong = {};
  const everything = quiz.questions.flatMap((q) => q.answers.map((a) => a.id));
  for (const q of quiz.questions) {
    if (q.type === 'short_answer') {
      correct[q.id] = q.answers.find((a) => a.is_correct).label_md.toUpperCase() + '  ';
      wrong[q.id] = 'definitely wrong';
    } else {
      correct[q.id] = q.answers.filter((a) => a.is_correct).map((a) => a.id);
      wrong[q.id] = [q.answers.find((a) => !a.is_correct).id];
    }
  }
  return { quizId: quiz.id, correct, wrong, everything };
}

test('quiz grading is server-side with explanations', async () => {
  const { quizId, correct, wrong, everything } = await answerKey('Module 1 check');
  const { data: fail, error } = await student.client.rpc('submit_quiz_attempt', { p_quiz_id: quizId, p_responses: wrong });
  assert.ifError(error);
  assert.equal(fail.passed, false);
  assert.equal(fail.score_percent, 0);
  assert.ok(fail.results.every((r) => r.explanation_md && r.correct === false && r.correct_answer_ids.length > 0));
  assert.ok(fail.results.some((r) => r.feedback.length > 0), 'per-answer feedback returned');

  // tampering: ticking every option (including other questions' ids) never scores
  const forged = Object.fromEntries(Object.keys(correct).map((k) => [k, everything]));
  const { data: forgedRes } = await student.client.rpc('submit_quiz_attempt', { p_quiz_id: quizId, p_responses: forged });
  assert.equal(forgedRes.score_percent, 0, 'selecting every option earns nothing');

  const { data: pass } = await student.client.rpc('submit_quiz_attempt', { p_quiz_id: quizId, p_responses: correct });
  assert.equal(pass.passed, true);
  assert.equal(pass.score_percent, 100);
  assert.equal(pass.lesson_completed, true);
  assert.ok(pass.new_achievements.some((a) => a.slug === 'quiz-perfect'));
  const { data: attempts } = await student.client.from('quiz_attempts').select('id').eq('quiz_id', quizId);
  assert.equal(attempts.length, 3);
});

test('Uzbek translations: served with content, gated like the base text, graded in any language', async () => {
  // Catalog rows carry their overlays; IDs are the same rows learners already use.
  const { data: course } = await anon.from('courses').select('id, title, translations').eq('slug', 'html-from-absolute-zero').single();
  assert.equal(course.id, ids['html-from-absolute-zero']);
  assert.equal(course.title, 'HTML from Absolute Zero');
  assert.equal(course.translations.uz.title, 'HTML: mutlaq noldan');

  // Translated lesson bodies follow exactly the same entitlement rules as the original.
  const free = lessonByTitle('What is a computer?');
  const { data: freeBody } = await anon.from('lesson_contents').select('translations').eq('lesson_id', free.id).single();
  assert.match(freeBody.translations.uz.body_md, /Koʻrsatmalarga amal qiladigan mashina/);
  const locked = lessonByTitle('Variables: giving names to values');
  const { data: lockedBody } = await student2.client.from('lesson_contents').select('translations').eq('lesson_id', locked.id);
  assert.equal(lockedBody.length, 0, 'premium translation hidden from a free learner');

  // get_quiz: translated prompts and options, but no translated explanations or feedback before submitting.
  const { quizId, wrong } = await answerKey('Module 1 check');
  const { data: quiz } = await anon.rpc('get_quiz', { p_quiz_id: quizId });
  assert.equal(quiz.translations.uz.title, '1-modul boʻyicha test');
  assert.ok(quiz.questions.every((q) => q.translations.uz.prompt_md && !('explanation_md' in q.translations.uz)));
  assert.ok(quiz.questions.flatMap((q) => q.answers).every((a) => a.translations.uz.label_md && !('feedback_md' in a.translations.uz)));

  // Results include translated explanations and per-answer feedback.
  const { data: graded, error } = await student2.client.rpc('submit_quiz_attempt', { p_quiz_id: quizId, p_responses: wrong });
  assert.ifError(error);
  assert.ok(graded.results.every((r) => r.translations.uz.explanation_md));
  assert.ok(graded.results.some((r) => r.feedback.some((f) => f.translations.uz?.feedback_md)));

  // Short answers are accepted in the base language or any translation.
  const { data: fq } = await admin.from('quizzes').select('id, questions(id, type, answers(id, translations))').eq('title', 'Computer Fundamentals — final assessment').single();
  const short = fq.questions.find((q) => q.type === 'short_answer');
  const target = short.answers[0];
  await admin.from('answers').update({ translations: { uz: { label_md: 'mp4-video' } } }).eq('id', target.id);
  const { data: shortRes } = await student2.client.rpc('submit_quiz_attempt', { p_quiz_id: fq.id, p_responses: { [short.id]: '  MP4-Video ' } });
  assert.equal(shortRes.results.find((r) => r.question_id === short.id).correct, true, 'translated accepted answer is graded correct');
  await admin.from('answers').update({ translations: target.translations }).eq('id', target.id);

  // Search finds courses by their Uzbek title.
  const { data: found } = await anon.rpc('search_courses', { p_query: 'kompyuter asoslari' });
  assert.equal(found[0]?.slug, 'computer-fundamentals-from-zero');

  // Only supported locales, and only editors may change translations.
  const bad = await admin.from('courses').update({ translations: { de: { title: 'Kurs' } } }).eq('slug', 'css-from-zero');
  assert.ok(bad.error, 'unsupported locale rejected by the check constraint');
  const byStudent = await student.client.from('lessons').update({ translations: {} }).eq('id', free.id).select('id');
  assert.equal(byStudent.data?.length ?? 0, 0, 'learners cannot edit translations');
  const draft = ids.lessons.find((l) => l.title === 'Comparing values');
  const { data: edited, error: editError } = await editor.client.from('lessons')
    .update({ translations: { uz: { title: 'Qiymatlarni solishtirish' }, ru: { title: 'Сравнение значений' } } }).eq('id', draft.id).select('translations');
  assert.ifError(editError);
  assert.equal(edited[0].translations.ru.title, 'Сравнение значений');
});

test('course completion → certificate requires premium → verification', async () => {
  const course = ids['computer-fundamentals-from-zero'];
  const articles = ids.lessons.filter((l) => l.course_id === course && l.status === 'published' && l.type !== 'quiz');
  for (const l of articles) {
    const { error } = await student.client.rpc('record_lesson_progress', { p_lesson_id: l.id, p_completed: true });
    assert.ifError(error);
  }
  let { data: enr } = await student.client.from('enrollments').select('*').eq('course_id', course).single();
  assert.equal(enr.status, 'active', 'final assessment still required');

  const { quizId, correct } = await answerKey('Computer Fundamentals — final assessment');
  const { data: fin } = await student.client.rpc('submit_quiz_attempt', { p_quiz_id: quizId, p_responses: correct });
  assert.equal(fin.passed, true);
  assert.equal(fin.enrollment.status, 'completed');
  assert.equal(fin.enrollment.progress_percent, 100);
  assert.equal(fin.certificate, null, 'free user: no certificate yet');

  const { error: claimErr } = await student.client.rpc('claim_certificate', { p_course_id: course });
  assert.match(claimErr.message, /certificate_not_eligible/);

  const { error: grantErr } = await adminUser.client.rpc('admin_grant_premium', { p_user_id: student.id, p_days: 30, p_note: 'test' });
  assert.ifError(grantErr);
  const { data: ent } = await student.client.rpc('my_entitlements');
  assert.equal(ent.is_premium, true);

  const { data: cert, error: certErr } = await student.client.rpc('claim_certificate', { p_course_id: course });
  assert.ifError(certErr);
  assert.match(cert.serial, /^MHR-\d{4}-[0-9A-F]{8}$/);
  assert.equal(cert.recipient_name, 'Aziza');

  const { data: verified } = await anon.rpc('verify_certificate', { p_code: cert.verification_code.toLowerCase() });
  assert.equal(verified.valid, true);
  assert.equal(verified.course_title, 'Computer Fundamentals from Zero');
  const { data: bogus } = await anon.rpc('verify_certificate', { p_code: 'NOPE' });
  assert.equal(bogus.valid, false);

  const premium = lessonByTitle('Variables: giving names to values');
  const { data: body } = await student.client.from('lesson_contents').select('body_md').eq('lesson_id', premium.id);
  assert.equal(body.length, 1, 'premium unlocks content');

  const { data: notes } = await student.client.from('notifications').select('type, title');
  assert.ok(notes.some((n) => n.title === 'Certificate earned'));
});

test('bookmarks and notes are private', async () => {
  const lesson = lessonByTitle('Hardware and software');
  const { data: b, error } = await student.client.from('bookmarks').insert({ lesson_id: lesson.id, user_id: student.id, position_seconds: 42, label: 'RAM table' }).select().single();
  assert.ifError(error);
  assert.equal(b.course_id, ids['computer-fundamentals-from-zero']);
  const { data: n } = await student.client.from('lesson_notes').insert({ lesson_id: lesson.id, user_id: student.id, body: 'RAM = worktable' }).select().single();
  assert.ok(n.id);
  const { data: theirs } = await student2.client.from('bookmarks').select('id');
  assert.equal(theirs.length, 0);
  const { error: spoof } = await student2.client.from('lesson_notes').insert({ lesson_id: lesson.id, user_id: student.id, body: 'spoof' });
  assert.ok(spoof);
  const draft = ids.lessons.find((l) => l.status === 'draft');
  const { error: draftBm } = await student.client.from('bookmarks').insert({ lesson_id: draft.id, user_id: student.id });
  assert.ok(draftBm, 'cannot bookmark unpublished lesson');
});

test('assignments: submission, file upload scoping, review workflow', async () => {
  const { data: asg } = await student2.client.from('assignments').select('id, lesson_id').eq('title', 'Personal profile page').single();
  const path = `${student2.id}/${asg.id}/index.html`;
  const up = await student2.client.storage.from('submissions').upload(path, new Blob(['<!DOCTYPE html><h1>Hi</h1>'], { type: 'text/html' }));
  assert.ifError(up.error);
  const bad = await student2.client.storage.from('submissions').upload(`${student.id}/${asg.id}/evil.html`, new Blob(['x'], { type: 'text/html' }));
  assert.ok(bad.error, 'cannot upload into another user folder');

  const { error: pathErr } = await student2.client.rpc('submit_assignment', { p_assignment_id: asg.id, p_file_paths: [`${student.id}/${asg.id}/x.html`] });
  assert.match(pathErr.message, /invalid_file_path/);

  const { data: sub, error } = await student2.client.rpc('submit_assignment', { p_assignment_id: asg.id, p_body_md: '<h1>Me</h1>', p_file_paths: [path] });
  assert.ifError(error);
  assert.equal(sub.status, 'submitted');
  const { data: prog } = await student2.client.from('lesson_progress').select('status').eq('lesson_id', asg.lesson_id).single();
  assert.equal(prog.status, 'completed');

  await student2.client.from('submissions').update({ score: 100, status: 'approved' }).eq('id', sub.id);
  const { data: s1 } = await admin.from('submissions').select('score, status').eq('id', sub.id).single();
  assert.equal(s1.score, null, 'learner cannot grade themselves');
  assert.equal(s1.status, 'submitted');

  const { error: revErr } = await editor.client.from('submissions').update({ score: 88, status: 'approved', feedback_md: 'Great outline!' }).eq('id', sub.id);
  assert.ifError(revErr);
  const { data: s2 } = await admin.from('submissions').select('score, status, reviewed_by').eq('id', sub.id).single();
  assert.equal(s2.score, 88);
  assert.equal(s2.reviewed_by, editor.id);
  const signed = await editor.client.storage.from('submissions').createSignedUrl(path, 60);
  assert.ifError(signed.error);

  const { error: lockedEdit } = await student2.client.from('submissions').update({ body_md: 'changed' }).eq('id', sub.id).select();
  assert.match(lockedEdit?.message ?? '', /submission_locked/);
});

test('content workflow: instructors draft, editors publish, audit log records it', async () => {
  const { data: inst } = await admin.from('instructors').insert({ slug: `inst-${run}`, name: 'Test Instructor', profile_id: instructor.id }).select().single();
  const { data: course, error } = await instructor.client.from('courses').insert({
    slug: `test-course-${run}`, title: 'Instructor course', category_id: (await admin.from('categories').select('id').eq('slug', 'programming').single()).data.id,
    instructor_id: inst.id, status: 'draft',
  }).select().single();
  assert.ifError(error);
  const { data: mod, error: mErr } = await instructor.client.from('modules').insert({ course_id: course.id, title: 'M1', status: 'in_review' }).select().single();
  assert.ifError(mErr);
  const { error: pubErr } = await instructor.client.from('courses').update({ status: 'published' }).eq('id', course.id);
  assert.match(pubErr.message, /only_editors_can_publish/);
  const { error: lpubErr } = await instructor.client.from('lessons').insert({ module_id: mod.id, course_id: course.id, title: 'L', status: 'published' });
  assert.match(lpubErr.message, /only_editors_can_publish/);
  const { error: otherErr, data: otherRows } = await instructor.client.from('courses').update({ title: 'x' }).eq('id', ids['html-from-absolute-zero']).select();
  assert.ok(otherErr || otherRows.length === 0, 'instructor cannot edit other courses');

  try {
    const { error: edErr } = await editor.client.from('courses').update({ status: 'published' }).eq('id', course.id);
    assert.ifError(edErr);
    const { data: log } = await adminUser.client.from('audit_log').select('action, entity, actor_id, details').eq('entity_id', course.id);
    assert.ok(log.some((r) => r.action === 'insert' && r.actor_id === instructor.id), 'instructor insert audited');
    assert.ok(log.some((r) => r.details.status === 'published' && r.details.previous_status === 'draft' && r.actor_id === editor.id));
    const { data: noise } = await admin.from('audit_log').select('id').eq('entity', 'courses').is('actor_id', null);
    assert.equal(noise.length, 0, 'engine counter updates are not audited as user edits');
  } finally {
    await admin.from('courses').delete().eq('id', course.id);
  }
});

test('storage: course media is gated by lesson entitlement', async () => {
  const course = ids['python-for-complete-beginners'];
  const locked = lessonByTitle('Variables: giving names to values');
  const preview = lessonByTitle('What is programming?');
  const lockedPath = `${course}/${locked.id}/poster.png`;
  const previewPath = `${course}/${preview.id}/poster.png`;
  const png = new Blob([Buffer.from('89504e470d0a1a0a', 'hex')], { type: 'image/png' });
  for (const p of [lockedPath, previewPath]) {
    const { error } = await editor.client.storage.from('course-media').upload(p, png, { upsert: true });
    assert.ifError(error);
  }
  const denied = await student.client.storage.from('course-media').upload(`${course}/x/evil.png`, png);
  assert.ok(denied.error, 'students cannot upload course media');
  const a1 = await anon.storage.from('course-media').createSignedUrl(previewPath, 60);
  assert.ifError(a1.error);
  const a2 = await anon.storage.from('course-media').createSignedUrl(lockedPath, 60);
  assert.ok(a2.error, 'premium media not signable by guests');
  const s = await student.client.storage.from('course-media').createSignedUrl(lockedPath, 60); // student is premium now
  assert.ifError(s.error);
  const res = await fetch(s.data.signedUrl);
  assert.equal(res.status, 200);
});

test('discovery: search, filters and recommendations', async () => {
  const { data: r1 } = await anon.rpc('search_courses', { p_query: 'blender' });
  assert.equal(r1[0].slug, 'blender-first-steps-in-3d');
  const { data: r2 } = await anon.rpc('search_courses', { p_query: 'pyth' });
  assert.ok(r2.some((c) => c.slug === 'python-for-complete-beginners'), 'prefix match');
  const { data: r3 } = await anon.rpc('search_courses', { p_query: 'c++ !!' });
  assert.ok(Array.isArray(r3), 'punctuation-only queries do not error');
  const { data: r4 } = await anon.rpc('search_courses', { p_category_slug: 'programming' });
  assert.deepEqual(r4.map((c) => c.slug).sort(), ['html-from-absolute-zero', 'python-for-complete-beginners']);
  const { data: r5 } = await anon.rpc('search_courses', { p_tier: 'premium', p_levels: ['beginner'] });
  assert.deepEqual(r5.map((c) => c.slug), ['unreal-engine-fundamentals']);
  const { data: r6 } = await anon.rpc('search_courses', { p_query: 'html', p_sort: 'popular' }).select('slug, category:categories!courses_category_id_fkey(slug)');
  assert.equal(r6[0].category.slug, 'programming', 'RPC results support embedding');

  const { data: rec, error } = await student.client.rpc('recommended_courses', { p_limit: 5 });
  assert.ifError(error);
  assert.ok(!rec.some((c) => c.slug === 'computer-fundamentals-from-zero'), 'excludes enrolled courses');
  assert.ok(['blender-first-steps-in-3d', 'html-from-absolute-zero', 'python-for-complete-beginners'].includes(rec[0].slug),
    `interest-matched course first (got ${rec[0].slug})`);
  const { data: guestRec } = await anon.rpc('recommended_courses', { p_limit: 3 });
  assert.equal(guestRec.length, 3);
});

test('admin operations', async () => {
  const { data: stats, error } = await adminUser.client.rpc('admin_dashboard_stats');
  assert.ifError(error);
  assert.ok(stats.users >= 5);
  assert.equal(stats.signups_by_day.length, 30);
  const { data: users } = await adminUser.client.rpc('admin_list_users', { p_search: student.email });
  assert.equal(users.length, 1);
  assert.equal(users[0].is_premium, true);
  const { error: roleErr } = await adminUser.client.rpc('admin_set_role', { p_user_id: student2.id, p_role: 'editor', p_granted: true });
  assert.ifError(roleErr);
  const { data: r } = await student2.client.from('user_roles').select('role');
  assert.ok(r.some((x) => x.role === 'editor'));
  const { error: lastAdmin } = await adminUser.client.from('user_roles').delete().eq('user_id', adminUser.id).eq('role', 'admin');
  const { data: admins } = await admin.from('user_roles').select('user_id').eq('role', 'admin');
  assert.ok(admins.length >= 1, `last admin protected (${lastAdmin?.message ?? 'ok'})`);
  const { data: n } = await adminUser.client.rpc('admin_broadcast', { p_title: 'Welcome', p_body: 'New courses this week' });
  const { data: seen } = await student2.client.from('notifications').select('id').eq('id', n.id);
  assert.equal(seen.length, 1, 'broadcast visible to everyone');
  const { error: readErr } = await student2.client.rpc('mark_notifications_read', { p_ids: [n.id] });
  assert.ifError(readErr);
  const { error: setErr } = await editor.client.from('app_settings').update({ value: { mode: 'free_for_all' } }).eq('key', 'billing').select();
  const { data: billing } = await admin.from('app_settings').select('value').eq('key', 'billing').single();
  assert.equal(billing.value.mode, 'subscriptions', `editors cannot change billing (${setErr?.message ?? 'filtered'})`);
});

test('billing switch: "free_for_all" opens premium content', async () => {
  const learner = await makeUser('billing');
  const locked = lessonByTitle('Variables: giving names to values');
  const before1 = await learner.client.from('lesson_contents').select('lesson_id').eq('lesson_id', locked.id);
  assert.equal(before1.data.length, 0);
  await adminUser.client.from('app_settings').update({ value: { mode: 'free_for_all', paywall_enabled: false } }).eq('key', 'billing');
  const after1 = await learner.client.from('lesson_contents').select('lesson_id').eq('lesson_id', locked.id);
  assert.equal(after1.data.length, 1);
  await adminUser.client.from('app_settings').update({ value: { mode: 'subscriptions', paywall_enabled: true } }).eq('key', 'billing');
});
