// End-to-end journey through Mahorat Studio (admin CMS) against the local backend.
//   (cd apps/admin && npx vite build && npx vite preview --port 4173 &)
//   node supabase/scripts/create-dev-users.mjs
//   node qa/admin-journey.cjs <outDir>
const { chromium } = require('playwright');

const out = process.argv[2] ?? 'qa/screenshots';
const BASE = process.env.QA_ADMIN ?? 'http://localhost:4173';
const stamp = Date.now().toString(36);

(async () => {
  const browser = await chromium.launch();
  const page = await (await browser.newContext({ viewport: { width: 1440, height: 900 }, colorScheme: 'dark' })).newPage();
  const errors = [];
  page.on('console', (m) => m.type() === 'error' && errors.push(m.text().slice(0, 200)));
  page.on('pageerror', (e) => errors.push(`pageerror: ${e.message}`));
  let n = 0;
  const shot = async (name) => {
    n += 1;
    await page.waitForTimeout(600);
    await page.screenshot({ path: `${out}/admin-${String(n).padStart(2, '0')}-${name}.png` });
    console.log('✓', name);
  };
  const tid = (id) => page.locator(`[data-testid="${id}"]`).first();
  const step = async (label, fn) => {
    try {
      await fn();
    } catch (e) {
      console.log('✗', label, '-', e.message.split('\n')[0]);
      await page.screenshot({ path: `${out}/admin-FAIL-${label}.png` });
      throw e;
    }
  };
  const login = async (email) => {
    await page.goto(BASE, { waitUntil: 'networkidle' });
    await tid('login-email').fill(email);
    await tid('login-password').fill('Mahorat-dev-2026');
    await tid('login-submit').click();
    await page.waitForTimeout(1500);
  };

  await step('student-blocked', async () => {
    await login('student@mahorat.local');
    await page.getByText('No access').waitFor();
    await shot('no-access');
    await page.getByRole('button', { name: 'Sign out' }).click();
    await page.waitForTimeout(800);
  });

  await step('login', async () => {
    await page.goto(BASE, { waitUntil: 'networkidle' });
    await shot('login');
    await login('admin@mahorat.local');
    await page.getByRole('heading', { name: 'Dashboard' }).waitFor();
    await shot('dashboard');
  });

  await step('courses', async () => {
    await page.getByRole('link', { name: 'Courses' }).click();
    await page.getByText('HTML from Absolute Zero').waitFor();
    await shot('courses');
  });

  await step('create-course', async () => {
    await tid('new-course').click();
    await tid('course-title-input').fill(`CSS Layout Basics ${stamp}`);
    await tid('course-category').selectOption({ label: 'Programming & Software' });
    await shot('new-course-modal');
    await tid('create-course').click();
    await page.getByRole('tab', { name: 'Details' }).waitFor();
    await shot('course-details');
  });

  await step('curriculum', async () => {
    await page.getByRole('tab', { name: 'Curriculum' }).click();
    await tid('new-module-title').fill('Getting started');
    await tid('add-module').click();
    await tid('add-lesson-0').click();
    await tid('lesson-title-input').fill('What is CSS?');
    await tid('create-lesson').click();
    await page.getByRole('link', { name: 'What is CSS?' }).first().waitFor();
    await shot('curriculum');
  });

  await step('lesson-editor', async () => {
    await page.getByRole('link', { name: 'What is CSS?' }).first().click();
    await tid('lesson-body').fill('## Styling the web\n\n**CSS** describes how HTML looks.\n\n```css\nh1 { color: gold; }\n```\n\n> [!TIP]\n> Start with one rule at a time.');
    await tid('save-body').click();
    await page.waitForTimeout(800);
    await tid('lesson-status').selectOption('published');
    await tid('save-lesson').click();
    await page.waitForTimeout(1000);
    await shot('lesson-editor');
    await page.getByRole('button', { name: 'Create quiz' }).click();
    await page.getByText('Pass mark %').waitFor();
    await tid('add-single_choice').click();
    await page.waitForTimeout(800);
    await shot('quiz-editor');
  });

  await step('publish-course', async () => {
    await page.goto(`${BASE}/courses`, { waitUntil: 'networkidle' });
    await page.getByText(`CSS Layout Basics ${stamp}`).click();
    await page.getByRole('tab', { name: 'Curriculum' }).click();
    await page.getByLabel('Module status').selectOption('published');
    await page.waitForTimeout(800);
    await page.getByRole('button', { name: 'Submit for review' }).click();
    await page.waitForTimeout(800);
    await tid('publish-course').click();
    await page.waitForTimeout(1200);
    await shot('course-published');
  });

  await step('translations', async () => {
    await page.getByRole('link', { name: 'Courses' }).first().click();
    await page.waitForTimeout(1200);
    await page.getByText('Computer Fundamentals from Zero', { exact: true }).first().click();
    await page.waitForTimeout(1500);
    await page.getByRole('tab', { name: 'Translations' }).click();
    await page.waitForTimeout(1200);
    const uzTitle = await tid('tr-courses-title').inputValue();
    if (uzTitle !== 'Kompyuter asoslari: noldan boshlab') throw new Error(`unexpected Uzbek title “${uzTitle}”`);
    await shot('translations-uz');
    await tid('locale-ru').click();
    await page.waitForTimeout(400);
    await tid('tr-courses-title').fill('Основы компьютера с нуля');
    await tid('tr-save-courses').click();
    await page.getByText('Translation saved').first().waitFor({ timeout: 5000 });
    await page.reload({ waitUntil: 'networkidle' });
    await page.getByRole('tab', { name: 'Translations' }).click();
    await tid('locale-ru').click();
    await page.waitForTimeout(600);
    if ((await tid('tr-courses-title').inputValue()) !== 'Основы компьютера с нуля') throw new Error('Russian title was not saved');
    await shot('translations-ru-saved');
    await page.getByRole('link', { name: 'Translate lesson' }).first().click();
    await page.waitForTimeout(1500);
    await shot('lesson-translations');
  });

  for (const [name, label] of [
    ['categories', 'Categories'],
    ['paths', 'Learning paths'],
    ['submissions', 'Submissions'],
    ['users', 'Users & roles'],
    ['billing', 'Plans & settings'],
    ['audit', 'Audit log'],
  ]) {
    await step(name, async () => {
      await page.getByRole('link', { name: label }).click();
      await page.waitForTimeout(1500);
      await shot(name);
    });
  }

  console.log(errors.length ? `console errors:\n${[...new Set(errors)].join('\n')}` : 'no console errors');
  await browser.close();
})().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
