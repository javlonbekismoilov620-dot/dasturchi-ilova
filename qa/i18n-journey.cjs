// Language-switching journey on the web build of the mobile app (demo mode or live backend).
// Starts in Uzbek, learns a lesson, then switches to Russian and English through the real
// Settings screen, checking content, honest fallback notices and that progress is kept.
//   node qa/serve.mjs <web build> 8095 &
//   QA_BASE=http://localhost:8095 node qa/i18n-journey.cjs <outDir>
const { chromium } = require('playwright');
const fs = require('node:fs');
const path = require('node:path');

const out = process.argv[2] ?? 'qa/screenshots/i18n';
const BASE = process.env.QA_BASE ?? 'http://localhost:8095';
const catalog = JSON.parse(fs.readFileSync(path.join(__dirname, '../apps/mobile/src/data/demo/catalog.json'), 'utf8'));
const lessonId = catalog.lessons.find((l) => l.title === 'What is a computer?').id;
const quizLessonId = catalog.lessons.find((l) => l.title === 'Check your understanding' && catalog.quizzes.some((q) => q.lesson_id === l.id && q.title === 'Module 1 check')).id;

(async () => {
  fs.mkdirSync(out, { recursive: true });
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ viewport: { width: 390, height: 844 }, colorScheme: 'dark', deviceScaleFactor: 1 });
  const page = await ctx.newPage();
  const errors = [];
  page.on('console', (m) => m.type() === 'error' && errors.push(m.text().slice(0, 240)));
  page.on('pageerror', (e) => errors.push(`pageerror: ${e.message}`));
  const results = [];
  const check = (name, ok, detail = '') => {
    results.push({ name, ok });
    console.log(`${ok ? '✓' : '✗'} ${name}${detail ? ` — ${detail}` : ''}`);
  };
  let n = 0;
  const shot = async (name) => page.screenshot({ path: `${out}/${String(++n).padStart(2, '0')}-${name}.png` });
  const go = async (url) => {
    await page.goto(BASE + url, { waitUntil: 'networkidle' });
    await page.waitForTimeout(1500);
  };
  // First match that is actually on top (inactive screens stay mounted underneath on web).
  const visibleText = async (text) =>
    page.evaluate((t) => {
      const els = [...document.querySelectorAll('div, span, h1, h2, h3, p')].filter((e) => e.childElementCount === 0 && e.textContent.includes(t));
      return els.some((e) => {
        const r = e.getBoundingClientRect();
        if (!r.width || !r.height || r.bottom < 0 || r.top > innerHeight) return false;
        const top = document.elementFromPoint(r.left + r.width / 2, r.top + r.height / 2);
        return !!top && (e.contains(top) || top.contains(e));
      });
    }, text);
  // Like visibleText, but scrolls each candidate into view first (for content below the fold).
  const textOnScroll = async (text) =>
    page.evaluate((t) => {
      const els = [...document.querySelectorAll('div, span, h1, h2, h3, p')].filter((e) => e.childElementCount === 0 && e.textContent.includes(t));
      return els.some((e) => {
        if (!e.getBoundingClientRect().width) return false;
        e.scrollIntoView({ block: 'center' });
        const r = e.getBoundingClientRect();
        const top = document.elementFromPoint(r.left + r.width / 2, r.top + r.height / 2);
        return !!top && (e.contains(top) || top.contains(e));
      });
    }, text);
  const onTop = async (testId) =>
    page.evaluate((id) => [...document.querySelectorAll(`[data-testid="${id}"]`)].some((e) => {
      const r = e.getBoundingClientRect();
      if (!r.width || !r.height) return false;
      const top = document.elementFromPoint(r.left + r.width / 2, Math.min(r.top + r.height / 2, innerHeight - 2));
      return !!top && (e.contains(top) || top.contains(e));
    }), testId);
  const clickTop = async (locator) => {
    const count = await locator.count();
    for (let i = count - 1; i >= 0; i--) {
      const el = locator.nth(i);
      if (await el.isVisible()) {
        await el.scrollIntoViewIfNeeded().catch(() => {});
        return el.click();
      }
    }
    throw new Error('nothing to click');
  };
  // Achievement and XP celebrations (shown in the learner's language) are dismissed like a learner would.
  const dismissCelebrations = async () => {
    for (let i = 0; i < 4; i++) {
      await page.waitForTimeout(900);
      const btn = page.getByText(/^(Davom etamiz|Продолжаем|Keep going)$/);
      if (!(await btn.count()) || !(await btn.last().isVisible())) return;
      await btn.last().click();
    }
  };
  const progressText = async () => page.evaluate(() => (document.body.innerText.match(/(\d+)\s?%/) ?? [])[1] ?? null);
  const switchLanguage = async (rowLabel, nativeName) => {
    await go('/settings');
    await clickTop(page.getByText(rowLabel, { exact: true }));
    await page.waitForTimeout(600);
    const sheet = await page.evaluate(() => document.body.innerText);
    check(`picker (${rowLabel}): Russian marked as interface-only`, /Interface only for now|Hozircha faqat interfeys|Пока только интерфейс/.test(sheet));
    await clickTop(page.getByText(nativeName, { exact: true }));
    await page.waitForTimeout(900);
  };

  // Uzbek, chosen during onboarding.
  await go('/');
  await page.evaluate(() =>
    localStorage.setItem('mahorat.preferences.v1', JSON.stringify({ state: { onboardingCompleted: true, locale: 'uz', interests: ['programming'], level: 'zero', goal: 'career', themeMode: 'dark', dailyGoalMinutes: 15 }, version: 0 })),
  );
  await go('/course/computer-fundamentals-from-zero');
  check('uz: course title in Uzbek', await visibleText('Kompyuter asoslari: noldan boshlab'));
  check('uz: no untranslated notice on a translated course', !(await onTop('untranslated-notice')));
  await shot('uz-course');

  await go(`/lesson/${lessonId}`);
  await dismissCelebrations();
  check('uz: lesson body in Uzbek', await visibleText('Koʻrsatmalarga amal qiladigan mashina'));
  await shot('uz-lesson');
  await clickTop(page.locator('[data-testid="mark-complete"]'));
  await dismissCelebrations();

  await go(`/lesson/${quizLessonId}`);
  await clickTop(page.locator('[data-testid="start-quiz"]'));
  await page.waitForTimeout(1200);
  check('uz: quiz question in Uzbek', await visibleText('Yuborish'));
  await clickTop(page.getByText('Kiritish', { exact: true }));
  await shot('uz-quiz');
  await dismissCelebrations();

  await go('/course/computer-fundamentals-from-zero');
  const uzProgress = await progressText();
  check('uz: lesson progress recorded', uzProgress !== null && Number(uzProgress) > 0, `${uzProgress}%`);

  // Switch to Russian through Settings: Russian UI, original content with an honest notice.
  await switchLanguage('Til', 'Русский');
  await go('/course/computer-fundamentals-from-zero');
  check('ru: interface in Russian', await visibleText('О курсе') || await visibleText('Программа курса') || await visibleText('Продолжить'));
  check('ru: content falls back to the original', await visibleText('Computer Fundamentals from Zero'));
  check('ru: fallback notice shown', await textOnScroll('Перевод готовится'));
  const ruProgress = await progressText();
  check('ru: progress unchanged after switching', ruProgress === uzProgress, `${ruProgress}% vs ${uzProgress}%`);
  await shot('ru-course');
  const bodyText = async () => page.evaluate(() => document.body.innerText);
  await go('/');
  check('ru: Home explains lessons are not in Russian yet', await visibleText('Уроки на русском готовятся'));
  check('ru: course cards name the lesson language', (await bodyText()).includes('Уроки: English'));
  await clickTop(page.locator('[data-testid="ru-content-notice-dismiss"]'));
  await page.waitForTimeout(600);
  check('ru: Home notice can be dismissed', !(await visibleText('Уроки на русском готовятся')));
  await go(`/lesson/${quizLessonId}`);
  await clickTop(page.locator('[data-testid="start-quiz"]'));
  await page.waitForTimeout(1200);
  check('ru: quiz shows the not-translated notice', await visibleText('Перевод готовится'));
  await go(`/lesson/${lessonId}`);
  check('ru: lesson notice + original text', (await visibleText('Перевод готовится')) && (await visibleText('A machine that follows instructions')));
  await shot('ru-lesson');

  // English: the base language, no notices.
  await switchLanguage('Язык', 'English');
  await go('/course/computer-fundamentals-from-zero');
  check('en: course title in English', await visibleText('Computer Fundamentals from Zero'));
  check('en: no fallback notice', !(await textOnScroll('Translation is being prepared')) && !(await onTop('untranslated-notice')));
  check('en: no lesson-language badges on English courses', !(await page.evaluate(() => document.body.innerText)).includes('Lessons: English'));
  check('en: progress unchanged', (await progressText()) === uzProgress);
  await shot('en-course');

  // And back to Uzbek.
  await switchLanguage('Language', 'Oʻzbekcha');
  await go('/course/computer-fundamentals-from-zero');
  check('uz again: course title in Uzbek', await visibleText('Kompyuter asoslari: noldan boshlab'));
  check('uz again: progress unchanged', (await progressText()) === uzProgress);

  const relevant = errors.filter((e) => !/favicon|DevTools/i.test(e));
  check('no console errors', relevant.length === 0, relevant.slice(0, 3).join(' | '));
  const failed = results.filter((r) => !r.ok).length;
  console.log(`\n${results.length - failed}/${results.length} checks passed`);
  await browser.close();
  process.exit(failed ? 1 : 0);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
