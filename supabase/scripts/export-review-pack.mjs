// Generates the native-speaker review pack: every published course, lesson and quiz in
// English and Oʻzbekcha side by side, with the style guide's glossary and a checklist per
// lesson. Reviewers can read it in a browser, print it, or annotate a PDF of it; sign-off
// itself is recorded in Mahorat Studio (Course → Review & completion).
//   node supabase/scripts/export-review-pack.mjs [out.html]
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { marked } from 'marked';
import { loadLibrary, words } from '../tests/content-audit-lib.mjs';

const root = join(dirname(fileURLToPath(import.meta.url)), '../..');
const out = process.argv[2] ?? join(root, 'docs/review/uz-review-pack.html');
const lib = await loadLibrary();
const pub = (r) => r.status === 'published';
const esc = (s) => String(s ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[c]);
const md = (s) => marked.parse(s ?? '', { async: false });
const uz = (row, f) => row.translations?.uz?.[f];
const pair = (label, en, uzText, render = (x) => esc(x)) =>
  `<div class="pair"><div class="label">${label}</div><div class="en">${en ? render(en) : '<em>—</em>'}</div><div class="uz">${uzText ? render(uzText) : '<em class="missing">tarjima yoʻq</em>'}</div></div>`;
const list = (xs) => `<ul>${(xs ?? []).map((x) => `<li>${esc(x)}</li>`).join('')}</ul>`;

const guide = readFileSync(join(root, 'docs/i18n/uz-style-guide.md'), 'utf8');
const glossary = guide.slice(guide.indexOf('## 5. Technical glossary'), guide.indexOf('## 6.'));

let toc = '';
let body = '';
for (const c of lib.courses.filter(pub).sort((a, b) => a.title.localeCompare(b.title))) {
  const cid = `c-${c.slug}`;
  toc += `<li><a href="#${cid}">${esc(uz(c, 'title') ?? c.title)}</a> <span class="muted">— ${esc(c.title)}</span></li>`;
  body += `<section class="course" id="${cid}"><h2>${esc(uz(c, 'title') ?? c.title)}</h2><p class="muted">${esc(c.title)}</p>`;
  body += pair('Subtitle', c.subtitle, uz(c, 'subtitle'));
  body += pair('Description', c.description, uz(c, 'description'), md);
  body += pair('Outcomes', c.learning_outcomes, uz(c, 'learning_outcomes'), list);
  body += pair('Prerequisites', c.prerequisites, uz(c, 'prerequisites'), list);
  const modules = lib.modules.filter((m) => m.course_id === c.id && pub(m)).sort((a, b) => a.position - b.position);
  for (const m of modules) {
    body += `<h3>Modul: ${esc(uz(m, 'title') ?? m.title)} <span class="muted">(${esc(m.title)})</span></h3>`;
    body += pair('Module description', m.description, uz(m, 'description'));
    const lessons = lib.lessons.filter((l) => l.module_id === m.id && pub(l)).sort((a, b) => a.position - b.position);
    for (const l of lessons) {
      const content = lib.contents.find((x) => x.lesson_id === l.id);
      body += `<article class="lesson"><h4>${esc(uz(l, 'title') ?? l.title)} <span class="muted">— ${esc(l.title)} · ${l.type}${content?.body_md ? ` · ${words(content.body_md)} words` : ''}</span></h4>`;
      body += pair('Summary', l.summary, uz(l, 'summary'));
      if (content?.body_md) body += pair('Lesson text', content.body_md, uz(content, 'body_md'), md);
      for (const quiz of lib.quizzes.filter((q) => q.lesson_id === l.id && pub(q))) {
        body += `<div class="quiz"><h5>Test: ${esc(uz(quiz, 'title') ?? quiz.title)}</h5>`;
        for (const q of lib.questions.filter((x) => x.quiz_id === quiz.id).sort((a, b) => a.position - b.position)) {
          body += pair(`Q${q.position + 1}`, q.prompt_md, uz(q, 'prompt_md'), md);
          if (q.code_snippet) body += pair('Code', `\`\`\`\n${q.code_snippet}\n\`\`\``, uz(q, 'code_snippet') ? `\`\`\`\n${uz(q, 'code_snippet')}\n\`\`\`` : null, md);
          const answers = lib.answers.filter((a) => a.question_id === q.id).sort((a, b) => a.position - b.position);
          body += pair('Options', answers.map((a) => `${a.is_correct ? '✓ ' : ''}${a.label_md}${a.feedback_md ? ` — ${a.feedback_md}` : ''}`), answers.map((a) => `${a.is_correct ? '✓ ' : ''}${uz(a, 'label_md') ?? '—'}${uz(a, 'feedback_md') ? ` — ${uz(a, 'feedback_md')}` : ''}`), list);
          body += pair('Explanation', q.explanation_md, uz(q, 'explanation_md'), md);
        }
        body += '</div>';
      }
      for (const a of lib.assignments.filter((x) => x.lesson_id === l.id && pub(x))) {
        body += pair('Assignment brief', a.brief_md, uz(a, 'brief_md'), md);
        body += pair('Rubric', a.rubric_md, uz(a, 'rubric_md'), md);
      }
      body += `<div class="check"><strong>Tekshiruvchi uchun:</strong>
        <label><input type="checkbox"> Matn tabiiy va ravon</label>
        <label><input type="checkbox"> Atamalar uslub qoʻllanmasiga mos</label>
        <label><input type="checkbox"> Maʼno asl matnga toʻliq mos</label>
        <label><input type="checkbox"> Imlo va tinish belgilari toʻgʻri</label>
        <div class="notes">Izohlar:</div></div></article>`;
    }
  }
  body += '</section>';
}

const html = `<!doctype html><html lang="uz"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Mahorat — Oʻzbekcha tarjima tekshiruvi</title>
<style>
  :root { --bg:#fff; --fg:#1b1b1f; --muted:#6b6b76; --line:#e4e4ea; --accent:#9a6b1f; --soft:#faf6ee; }
  body { margin:0; font: 15px/1.55 system-ui, -apple-system, "Segoe UI", sans-serif; color:var(--fg); background:var(--bg); }
  main { max-width: 1200px; margin: 0 auto; padding: 24px 16px 80px; }
  h1 { font-size: 28px; margin: 0 0 4px; } h2 { margin-top: 48px; border-bottom: 2px solid var(--accent); padding-bottom: 6px; }
  h3 { margin-top: 28px; color: var(--accent); } h4 { margin: 0 0 8px; } h5 { margin: 12px 0 6px; }
  .muted { color: var(--muted); font-weight: 400; font-size: .9em; }
  .pair { display: grid; grid-template-columns: 120px 1fr 1fr; gap: 12px; padding: 8px 0; border-top: 1px solid var(--line); }
  .pair .label { color: var(--muted); font-size: 13px; } .pair .uz { background: var(--soft); padding: 0 10px; border-radius: 6px; }
  .pair pre { white-space: pre-wrap; background: #f3f3f6; padding: 8px; border-radius: 6px; font-size: 13px; }
  .pair table { border-collapse: collapse; font-size: 13px; } .pair td, .pair th { border: 1px solid var(--line); padding: 3px 6px; }
  .lesson { border: 1px solid var(--line); border-radius: 10px; padding: 14px; margin: 16px 0; page-break-inside: avoid; }
  .quiz { margin-top: 10px; padding-left: 10px; border-left: 3px solid var(--line); }
  .check { margin-top: 12px; display: flex; flex-wrap: wrap; gap: 6px 18px; font-size: 14px; }
  .check .notes { flex-basis: 100%; min-height: 48px; border: 1px dashed var(--line); border-radius: 6px; padding: 6px; color: var(--muted); }
  .missing { color: #b42318; } blockquote { margin: 6px 0; padding-left: 10px; border-left: 3px solid var(--accent); color: var(--muted); }
  @media (max-width: 760px) { .pair { grid-template-columns: 1fr; } }
  @media print { .pair { grid-template-columns: 90px 1fr 1fr; font-size: 11px; } h2 { page-break-before: always; } }
</style></head><body><main>
<h1>Oʻzbekcha tarjima tekshiruvi</h1>
<p class="muted">Mahorat · ${new Date().toISOString().slice(0, 10)} · ${lib.courses.filter(pub).length} kurs, ${lib.lessons.filter(pub).length} dars</p>
<p><strong>Native-speaker review pack.</strong> English is on the left, Oʻzbekcha on the right. Please check natural phrasing, terminology (glossary below), meaning and orthography, and note any change in the box under each lesson. When a course is done, record the sign-off in Mahorat Studio (Course → Review &amp; completion → Native Uzbek reviewer).</p>
<details><summary><strong>Glossary (from the style guide)</strong></summary>${md(glossary)}</details>
<h2 style="margin-top:24px">Kurslar</h2><ul>${toc}</ul>
${body}
</main></body></html>`;
mkdirSync(dirname(out), { recursive: true });
writeFileSync(out, html);
console.log(`wrote ${out} (${(html.length / 1024).toFixed(0)} KB)`);
