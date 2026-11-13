// End-to-end UI journey for the web build of the mobile app against a live backend.
//   node qa/serve.mjs apps/mobile/dist 8090 &
//   node qa/journey.cjs <outDir> [width] [height] [scheme]
// Exercises real navigation, forms, auth, enrollment, progress, quizzes and settings.
const { chromium } = require('playwright');

const out = process.argv[2] ?? 'qa/screenshots';
const width = Number(process.argv[3] ?? 390);
const height = Number(process.argv[4] ?? 844);
const scheme = process.argv[5] ?? 'dark';
const BASE = process.env.QA_BASE ?? 'http://localhost:8090';
const email = `qa-${Date.now().toString(36)}@test.mahorat.local`;

(async () => {
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ viewport: { width, height }, colorScheme: scheme, deviceScaleFactor: 1 });
  const page = await ctx.newPage();
  const errors = [];
  page.on('console', (m) => {
    if (m.type() === 'error') errors.push(m.text().slice(0, 240));
  });
  page.on('pageerror', (e) => errors.push(`pageerror: ${e.message}`));
  let n = 0;
  const shot = async (name, full = false) => {
    n += 1;
    await page.waitForTimeout(700);
    await page.screenshot({ path: `${out}/${String(n).padStart(2, '0')}-${name}.png`, fullPage: full });
    console.log('✓', name);
  };
  // Pick the first match that is actually on top at its centre point (inactive tab
  // scenes stay mounted underneath on web, so plain visibility isn't enough).
  const hittable = (locator) => ({
    async pick() {
      const count = await locator.count();
      for (let i = 0; i < count; i++) {
        const el = locator.nth(i);
        const ok = await el
          .evaluate((node) => {
            const r = node.getBoundingClientRect();
            if (!r.width || !r.height) return false;
            const top = document.elementFromPoint(r.left + r.width / 2, Math.min(r.top + r.height / 2, window.innerHeight - 2));
            return !!top && (node.contains(top) || top.contains(node));
          })
          .catch(() => false);
        if (ok) return el;
      }
      return locator.first();
    },
    async click() {
      await page.waitForTimeout(150);
      const el = await this.pick();
      await el.scrollIntoViewIfNeeded().catch(() => {});
      const box = await el.boundingBox();
      if (box && box.y + box.height / 2 > height - 4) await el.evaluate((n) => n.scrollIntoView({ block: 'center' }));
      return el.click();
    },
    async fill(v) {
      return (await this.pick()).fill(v);
    },
    async waitFor(o) {
      return locator.filter({ visible: true }).first().waitFor(o);
    },
    locator: (sel) => hittable(locator.locator(sel)),
  });
  const tid = (id) => hittable(page.locator(`[data-testid="${id}"]`));
  const text = (s) => hittable(page.getByText(s, { exact: false }));
  const step = async (label, fn) => {
    try {
      await fn();
    } catch (e) {
      console.log('✗', label, '-', e.message.split('\n')[0]);
      await page.screenshot({ path: `${out}/FAIL-${label}.png` });
      throw e;
    }
  };

  await step('welcome', async () => {
    await page.goto(BASE, { waitUntil: 'networkidle' });
    await page.waitForTimeout(3200); // cinematic splash
    await shot('welcome');
    await tid('welcome-next').click();
    await page.waitForTimeout(500);
    await tid('welcome-next').click();
    await page.waitForTimeout(500);
    await shot('welcome-3');
    await tid('welcome-next').click();
  });

  await step('interests', async () => {
    await text('Programming & Software').click();
    await text('Blender & 3D Design').click();
    await text('AI & Emerging Tech').click();
    await shot('interests');
    await tid('onboarding-next').click();
  });

  await step('goal', async () => {
    await text('Start a new career').click();
    await shot('goal');
    await tid('onboarding-next').click();
  });

  await step('level', async () => {
    await text('completely new').click();
    await shot('level');
    await tid('onboarding-next').click();
    await page.waitForTimeout(1500);
  });

  await step('home-guest', async () => {
    await tid('home-greeting').waitFor();
    await shot('home-guest');
    await shot('home-guest-full', true);
  });

  await step('explore', async () => {
    await tid('tab-explore').click();
    await page.waitForTimeout(800);
    await shot('explore');
    await tid('explore-search').fill('pyth');
    await page.waitForTimeout(1200);
    await shot('explore-search');
  });

  await step('course-premium', async () => {
    await text('Python for Complete Beginners').click();
    await tid('course-title').waitFor();
    await shot('course-python');
    await shot('course-python-full', true);
  });

  await step('signup', async () => {
    await tid('course-cta').click();
    await page.waitForTimeout(800);
    await shot('auth');
    await tid('auth-email').click();
    await page.waitForTimeout(500);
    await text('Create account').click();
    await tid('auth-name').fill('Aziza');
    await tid('auth-email-input').fill(email);
    await tid('auth-password').fill('weak');
    await tid('auth-submit').click();
    await shot('signup-validation');
    await tid('auth-password').fill('Mahorat-2026');
    await tid('auth-submit').click();
    await page.waitForTimeout(2500);
  });

  await step('paywall', async () => {
    await page.goto(`${BASE}/course/python-for-complete-beginners`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2500);
    await tid('course-cta').click();
    await page.waitForTimeout(1200);
    await shot('paywall');
  });

  await step('free-course-enroll', async () => {
    await page.goto(`${BASE}/course/html-from-absolute-zero`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2500);
    await tid('course-cta').click();
    await tid('lesson-title').waitFor({ timeout: 15000 });
    await page.waitForTimeout(1200);
    await shot('lesson');
    await shot('lesson-full', true);
  });

  await step('complete-lesson', async () => {
    await tid('mark-complete').click();
    await page.waitForTimeout(400);
    await shot('lesson-completed-xp');
    await page.waitForTimeout(2600);
  });

  await step('quiz', async () => {
    await page.goto(`${BASE}/course/html-from-absolute-zero`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2500);
    await text('Your first web page').click();
    await tid('lesson-title').waitFor();
    await page.waitForTimeout(800);
    await tid('start-quiz').click();
    await page.waitForTimeout(1500);
    await shot('quiz-question');
    // Q1: <title>   Q2: overlap   Q3: alt
    await text('<title>').click();
    await tid('quiz-next').click();
    await page.waitForTimeout(500);
    await text('The tags overlap instead of nesting').click();
    await tid('quiz-next').click();
    await page.waitForTimeout(500);
    await text('href').click(); // deliberately wrong
    await shot('quiz-last');
    await tid('quiz-submit').click();
    await tid('quiz-result-title').waitFor({ timeout: 15000 });
    await page.waitForTimeout(1500);
    await shot('quiz-results');
    await shot('quiz-results-full', true);
  });

  await step('profile', async () => {
    await page.goto(`${BASE}/profile`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2500);
    await shot('profile');
    await shot('profile-full', true);
  });

  await step('learning', async () => {
    await page.goto(`${BASE}/learning`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2500);
    await shot('learning');
  });

  await step('achievements', async () => {
    await page.goto(`${BASE}/achievements`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2500);
    await shot('achievements');
  });

  await step('home-signed-in', async () => {
    await page.goto(BASE, { waitUntil: 'networkidle' });
    await page.waitForTimeout(3500);
    await shot('home');
    await shot('home-full', true);
  });

  await step('settings-theme-language', async () => {
    await page.goto(`${BASE}/settings`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2500);
    await shot('settings');
    await text('Theme').click();
    await page.waitForTimeout(600);
    await hittable(page.getByRole('radio', { name: 'Light' })).click();
    await page.waitForTimeout(800);
    await shot('settings-light');
    await text('Language').click();
    await page.waitForTimeout(600);
    await hittable(page.getByRole('radio', { name: 'Oʻzbekcha' })).click();
    await page.goto(BASE, { waitUntil: 'networkidle' });
    await page.waitForTimeout(3500);
    await shot('home-light-uz');
    await page.goto(`${BASE}/settings`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);
    await text('Til').click();
    await page.waitForTimeout(600);
    await hittable(page.getByRole('radio', { name: 'Русский' })).click();
    await page.goto(`${BASE}/course/html-from-absolute-zero`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(3000);
    await shot('course-light-ru');
  });

  console.log(`\naccount: ${email}`);
  console.log(errors.length ? `console errors (${errors.length}):\n` + [...new Set(errors)].slice(0, 25).join('\n') : 'no console errors');
  await browser.close();
})().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
