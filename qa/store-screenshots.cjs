// Generates App Store / Google Play screenshots from the real app (web build) backed by
// the local Supabase stack. A learner account is created and given genuine progress via
// the same RPCs the app uses — no mocked UI.
//   node qa/serve.mjs apps/mobile/dist 8090 &
//   node qa/store-screenshots.cjs store/screenshots
const { chromium } = require('playwright');
const { execSync } = require('node:child_process');
const { createClient } = require('@supabase/supabase-js');
const fs = require('node:fs');
const path = require('node:path');

const OUT = process.argv[2] ?? 'store/screenshots';
const BASE = 'http://localhost:8090';
const status = JSON.parse(execSync('npx supabase status -o json', { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }));

const SHOTS = [
  { key: '01-welcome', title: 'From zero\nto mastery', sub: 'Programming, 3D, video, design and AI — every path starts at the very beginning.' },
  { key: '02-home', title: 'Your learning,\nbeautifully organised', sub: 'Daily goals, streaks and the next lesson waiting for you.' },
  { key: '03-course', title: 'Courses built\nfrom the first step', sub: 'Clear outcomes, honest progress, a curriculum you can see.' },
  { key: '04-lesson', title: 'Clear lessons,\nreal code', sub: 'Plain language, worked examples and code you can copy.' },
  { key: '05-quiz', title: 'Quizzes that\nexplain every answer', sub: 'Learn from mistakes with feedback on each question.' },
  { key: '06-profile', title: 'Progress\nyou can feel', sub: 'XP, streaks, achievements and verifiable certificates.' },
];

async function seedLearner() {
  const admin = createClient(status.API_URL, status.SERVICE_ROLE_KEY, { auth: { persistSession: false } });
  const email = `store-${Date.now().toString(36)}@mahorat.local`;
  const password = 'Mahorat-store-2026';
  const { data: created, error } = await admin.auth.admin.createUser({ email, password, email_confirm: true, user_metadata: { full_name: 'Aziza Karimova' } });
  if (error) throw error;
  const uid = created.user.id;
  const user = createClient(status.API_URL, status.ANON_KEY, { auth: { persistSession: false } });
  await user.auth.signInWithPassword({ email, password });
  await user.from('profiles').update({ interests: ['programming', 'blender-3d', 'ai-emerging'], experience_level: 'zero', daily_goal_minutes: 15, timezone: 'Asia/Tashkent' }).eq('id', uid);
  const { data: lessons } = await admin.from('lessons').select('id, title, type, course:courses(slug)').eq('status', 'published');
  const bySlug = (slug) => lessons.filter((l) => l.course?.slug === slug);
  // Genuine activity: completed lessons, time on task and a passed quiz.
  for (const l of bySlug('computer-fundamentals-from-zero').filter((x) => x.type !== 'quiz').slice(0, 2)) {
    await user.rpc('record_lesson_progress', { p_lesson_id: l.id, p_seconds_spent: 420, p_completed: true });
  }
  const html = bySlug('html-from-absolute-zero');
  await user.rpc('record_lesson_progress', { p_lesson_id: html[0].id, p_seconds_spent: 300, p_completed: true });
  await user.rpc('record_lesson_progress', { p_lesson_id: html[1].id, p_seconds_spent: 240, p_completed: false });
  const { data: quiz } = await admin.from('quizzes').select('id, questions(id, type, answers(id, is_correct, label_md))').eq('title', 'Module 1 check').single();
  const responses = Object.fromEntries(quiz.questions.map((q, i) => [q.id, i === 1 ? [q.answers.find((a) => !a.is_correct).id] : q.answers.filter((a) => a.is_correct).map((a) => a.id)]));
  await user.rpc('submit_quiz_attempt', { p_quiz_id: quiz.id, p_responses: responses });
  return { email, password, quizLessonId: lessons.find((l) => l.title === 'Your first web page').id };
}

function frameHtml(shot, imgPath, w, h) {
  const img = fs.readFileSync(imgPath).toString('base64');
  const scale = w / 1290;
  return `<!doctype html><html><head><meta charset="utf-8">
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600&family=Inter:wght@400;500&display=swap" rel="stylesheet">
<style>
  html,body{margin:0;width:${w}px;height:${h}px;overflow:hidden}
  body{background:radial-gradient(circle at 75% 8%, rgba(232,192,122,.28), transparent 45%),radial-gradient(circle at 10% 95%, rgba(125,184,255,.12), transparent 40%),#08090C;font-family:Inter,sans-serif;color:#F5F2EC;display:flex;flex-direction:column;align-items:center}
  .copy{padding:${150 * scale}px ${100 * scale}px 0;text-align:center}
  h1{font-family:'Cormorant Garamond',serif;font-weight:600;font-size:${132 * scale}px;line-height:1.02;margin:0;white-space:pre-line;letter-spacing:-.01em}
  p{font-size:${44 * scale}px;line-height:1.35;color:#ABA79F;margin:${36 * scale}px auto 0;max-width:${1000 * scale}px}
  .device{margin-top:${90 * scale}px;width:${930 * scale}px;border-radius:${110 * scale}px;padding:${22 * scale}px;background:linear-gradient(160deg,#2a2b30,#121318);box-shadow:0 ${40 * scale}px ${120 * scale}px rgba(0,0,0,.55),inset 0 0 0 ${2 * scale}px rgba(255,255,255,.08)}
  .device img{display:block;width:100%;border-radius:${90 * scale}px}
  .brand{position:absolute;top:${70 * scale}px;left:0;right:0;text-align:center;font-size:${30 * scale}px;letter-spacing:.35em;text-transform:uppercase;color:#E8C07A}
</style></head><body>
<div class="brand">Mahorat</div>
<div class="copy"><h1>${shot.title}</h1><p>${shot.sub}</p></div>
<div class="device"><img src="data:image/png;base64,${img}"></div>
</body></html>`;
}

(async () => {
  const raw = path.join(OUT, 'raw');
  fs.mkdirSync(raw, { recursive: true });
  const learner = await seedLearner();
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ viewport: { width: 430, height: 932 }, deviceScaleFactor: 3, colorScheme: 'dark' });
  const page = await ctx.newPage();
  const go = async (url, wait = 2800) => {
    await page.goto(BASE + url, { waitUntil: 'networkidle' });
    await page.waitForTimeout(wait);
  };
  const snap = (key) => page.screenshot({ path: path.join(raw, `${key}.png`) });

  // Welcome (fresh install state)
  await go('/', 3600);
  await snap('01-welcome');

  // Sign in through the real UI, with onboarding already completed.
  await page.evaluate(() =>
    localStorage.setItem('mahorat.preferences.v1', JSON.stringify({ state: { onboardingCompleted: true, interests: ['programming', 'blender-3d', 'ai-emerging'], level: 'zero', goal: 'career', themeMode: 'system', locale: 'en', dailyGoalMinutes: 15, autoplayNext: false, hapticsEnabled: true, captionsEnabled: false, reduceMotion: false, playbackRate: 1, remindersEnabled: false, reminderHour: 19, reminderMinute: 0, downloadsWifiOnly: true }, version: 0 })),
  );
  await go('/auth/email', 2500);
  await page.locator('[data-testid="auth-email-input"]').last().fill(learner.email);
  await page.locator('[data-testid="auth-password"]').last().fill(learner.password);
  await page.locator('[data-testid="auth-submit"]').last().click();
  await page.waitForTimeout(2500);

  await go('/', 4000);
  await snap('02-home');
  await go('/course/html-from-absolute-zero', 3000);
  await snap('03-course');
  await go(`/lesson/${learner.quizLessonId}`, 3000);
  await page.mouse.wheel(0, 900);
  await page.waitForTimeout(1200);
  await snap('04-lesson');

  // Quiz: answer one question wrong on purpose to show explanations.
  await page.locator('[data-testid="start-quiz"]').last().click();
  await page.waitForTimeout(1500);
  const click = async (text) => {
    const loc = page.getByText(text, { exact: false });
    for (let i = (await loc.count()) - 1; i >= 0; i--) {
      if (await loc.nth(i).isVisible()) return loc.nth(i).click();
    }
  };
  await click('<title>');
  await page.locator('[data-testid="quiz-next"]').last().click();
  await page.waitForTimeout(500);
  await click('Nothing — it is valid');
  await page.locator('[data-testid="quiz-next"]').last().click();
  await page.waitForTimeout(500);
  await click('alt');
  await page.locator('[data-testid="quiz-submit"]').last().click();
  await page.waitForTimeout(3000);
  await page.mouse.wheel(0, 760);
  await page.waitForTimeout(1200);
  await snap('05-quiz');

  await go('/profile', 3500);
  await snap('06-profile');

  // Marketing frames: App Store 6.9" (1290×2796) and Google Play phone (1080×1920).
  const framePage = await (await browser.newContext({ viewport: { width: 1290, height: 2796 }, deviceScaleFactor: 1 })).newPage();
  for (const [dir, w, h] of [
    ['app-store-6.9', 1290, 2796],
    ['google-play-phone', 1080, 1920],
  ]) {
    fs.mkdirSync(path.join(OUT, dir), { recursive: true });
    await framePage.setViewportSize({ width: w, height: h });
    for (const s of SHOTS) {
      await framePage.setContent(frameHtml(s, path.join(raw, `${s.key}.png`), w, h), { waitUntil: 'networkidle' });
      await framePage.waitForTimeout(400);
      await framePage.screenshot({ path: path.join(OUT, dir, `${s.key}.png`) });
    }
  }
  console.log(`screenshots written to ${OUT}`);
  await browser.close();
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
