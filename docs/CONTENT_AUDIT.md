# Content audit and Uzbek migration report

**Date:** 15 November 2026 (after Sprint 1) · **Scope:** the 8 published starter courses, their 99 published lessons, 31 quizzes (169 questions, 498 answer options), 10 project assignments, plus categories, learning paths, achievements, plans and the author profile.

*The first audit (14 November) covered the 30 original lessons. Sprint 1 ([curriculum/sprint-1.md](curriculum/sprint-1.md)) added 69 lessons, knowledge checks, projects and final assessments, all written in English and Oʻzbekcha and held to the same checks.*

## Summary

- **Uzbek migration: complete.** Every published text in the starter library now has an Uzbek (Latin script) version, including all lesson bodies, quiz questions, answer options, feedback and explanations.
- **IDs and progress preserved.** Translations are stored next to the original text in the same rows. No course, module, lesson, quiz, question or answer was created or replaced. This was verified on a database that already had learner progress (see “Progress preservation” below).
- **Three-language switching works.** Interface and content follow the app language. Content shows Uzbek when it exists and the original English otherwise, with a visible “translation is being prepared” notice. Russian course content is not translated yet; Russian category names, achievements, plans and learning paths are.
- **Automated checks now guard the content.** `npm run db:test` fails if any published text lacks Uzbek, if Uzbek orthography is wrong, if a translation changes a lesson's structure, or if a quiz cannot be answered or graded.
- **Honest size check:** the published library is now about 21,500 words of lesson text (excluding code). Each course is a complete beginner course with a knowledge check in every teaching module, a project and a final assessment. None is marked complete yet, because the expert and native-Uzbek reviews have not happened, so all of them are still labelled *In development*.

## Library at a glance

| Course | Level · access | Published lessons (unpublished) | Quizzes · questions | Projects | Words EN | Words UZ |
| --- | --- | --- | --- | --- | --- | --- |
| AI Fundamentals & Prompting | zero · free | 10 (0) | 3 · 16 | 1 | 2 483 | 2 199 |
| Blender: Your First Steps in 3D | zero · free | 13 (0) | 4 · 22 | 1 | 2 311 | 2 097 |
| Computer Fundamentals from Zero | zero · free | 15 (0) | 5 · 30 | 1 | 3 908 | 3 405 |
| Design Principles from Zero | zero · free | 10 (0) | 3 · 16 | 1 | 2 126 | 1 872 |
| HTML from Absolute Zero | zero · free | 17 (0) | 6 · 30 | 2 | 3 198 | 2 764 |
| Python for Complete Beginners | zero · premium | 18 (0) | 5 · 26 | 2 | 3 468 | 2 879 |
| Unreal Engine Fundamentals | beginner · premium | 6 (0) | 2 · 13 | 1 | 1 825 | 1 612 |
| Video Editing Fundamentals | zero · free | 10 (0) | 3 · 16 | 1 | 2 234 | 1 900 |
| **Total** | | **99** | **31 · 169** | **10** | **21 553** | **18 728** |

Word counts exclude code. Uzbek is agglutinative, so a faithful Uzbek text is typically 5–15% shorter in words than the English.

## How the audit was done

1. **Manual review of every lesson and quiz.** Each English lesson was read in full before it was translated. Each quiz question was traced to the lesson text that teaches it.
2. **Automated checks** (`supabase/tests/content.test.mjs`, run by `npm run db:test`):
   - **Completeness:** every published course, module, lesson, lesson body, quiz, question, answer, feedback text, assignment, category, path, achievement, plan and author has an Uzbek value.
   - **Orthography:** `oʻ`/`gʻ` use ʻ (U+02BB) and the tutuq belgisi uses ʼ (U+02BC). There are no ASCII apostrophes inside words, no Cyrillic letters in Uzbek Latin text, and no common words missing the tutuq belgisi (maʼlumot, taʼminot, sunʼiy, eʼtibor, taʼlim, …). The checker was itself tested against planted mistakes.
   - **Structure parity:** each translated lesson keeps the same code blocks (and languages), headings, callouts, table rows and list items as the original.
   - **Quiz integrity:** every question has an explanation and at least two options; single-choice and true/false questions have exactly one correct answer; translated option labels are not duplicated; every quiz lesson has a quiz.
   - **Honest status:** every published course has published lessons, every reading lesson has a body, counters match, and no course claims to be complete.
   - **Readiness checklist:** for each course: no unpublished lessons inside published modules, a knowledge check in every teaching module, a project with a rubric, a final assessment, and approved expert and native-Uzbek reviews. A database trigger refuses to mark a course complete without both review sign-offs.
   - **Completion journeys** (`supabase/tests/e2e.test.mjs`, `apps/mobile/__tests__/demoApi.test.ts`): a learner completes every course on the server and in the offline demo engine. No course completes before its final assessment, and wrong answers fail it.
3. **The 441 Uzbek interface strings** were run through the same orthography checker and read through for grammar.

## Findings and fixes

| # | Finding | Severity | Action |
| --- | --- | --- | --- |
| 1 | *Python → Installing Python*: “go to the folder with the file” never explains how, which blocks absolute beginners | Medium | **Fixed** in English and Uzbek: introduces `cd` (*change directory*) with an example |
| 2 | Interface grammar: “15 daqiqadan 0”, “Oʻtish bali”, “Bir oz”, “Ishonchim komil” (means “I am certain”), and suffixes hanging off times and dates (“{time} da”) | Low | **Fixed** (`apps/mobile/src/i18n/uz.ts`) |
| 3 | Topics named after products (HTML, Python, Figma…) had no Uzbek entry, so the app would have treated them as untranslated | Low | **Fixed**: recorded explicitly as identical names in Uzbek and Russian |
| 4 | Inconsistent handling of suffixes after English product names | Low | **Fixed (revised 15 Nov):** the style guide now follows Uzbek media practice — ’ (U+2019) after foreign names in original spelling (“Unreal Engine’ni”); the interim rephrasing (“Unreal Engine dvigatelini”) was redundant and was replaced. The audit enforces ’ vs ʼ |
| 5 | **Unreal Engine Fundamentals** was published with 1 of 3 lessons and no assessment | **High** | **Fixed (15 Nov, decision 1):** lessons 2–3 completed in place (same IDs), plus a knowledge check, a project and a final assessment. The course stays labelled *In development* until it passes the completion checklist, including both reviews |
| 6 | All courses were short introductions (161–888 words) | Expected | **Addressed by Sprint 1:** 1 825–3 908 words per course, each with knowledge checks, a project and a final assessment |
| 7 | No videos and no downloadable resources exist yet | Expected | Content production task; the player and downloads are ready |
| 8 | Sprint 1 editorial pass: new lessons checked for terminology (*lavha* = shot, *kadr* = frame, *modul*, *xatolarni tuzatish*), ’ after foreign names (Unreal’da), Cyrillic examples kept in inline code (Design → type basics) | Low | **Fixed** before publishing; enforced by the audit |
| 9 | Python examples: a floating-point result printed as `112000.00000000001` | Low | **Fixed:** the example uses `round()`; every Python example in the course was run to check its output |

No factual errors were found in the published lessons. Spot-checked facts: Blender shortcuts and Z-up axes; WCAG 4.5 : 1 contrast; 24/25/30/60 fps conventions; J-cut and L-cut definitions; Python `type()` output and float arithmetic; HTML document skeleton and nesting rules; DNS and HTTPS roles; byte multiples; Unreal Engine 5 Nanite and Lumen.

## Quiz ↔ lesson check

| Quiz | Questions | Every answer taught in | Notes |
| --- | --- | --- | --- |
| Computer Fundamentals · Module 1 check | 5 | What is a computer?; Hardware and software | — |
| Computer Fundamentals · Final assessment | 4 | All published lessons | “Scanning a document” (distractor) is inferable from the input definition |
| HTML · Knowledge check: HTML basics | 3 | What is HTML?; Your first web page | Code snippet translated (`Salom`) |
| HTML · How the web works | 4 | What happens when you open a website; What is HTML? | Feedback mentions TLS, which the lesson does not name (HTTPS is taught) |
| Python · Knowledge check: variables | 3 | Variables | Hyphen rule is in the feedback; the lesson lists allowed characters |
| AI · Knowledge check: prompting | 3 | All three lessons | “Fine-tuning” appears only as a distractor, with an explanation in its feedback |
| Blender · Blender basics quiz | 4 | What is 3D?; Navigating; Basic objects | Ctrl + A (Apply menu) is a distractor, explained in feedback |
| Video · Editing fundamentals quiz | 3 | The timeline, clips and cuts | — |
| Design · Design principles quiz | 3 | Visual hierarchy; Contrast, alignment and proximity | — |

The 22 quizzes added in Sprint 1 (one knowledge check per new module and a final assessment per course) were written from the lesson text: each question cites only what its module teaches, and each final assessment samples every module. The automated quiz-integrity check covers all 31 quizzes.

Short-answer questions (`mp4`, `body`) are language-neutral. As a safeguard, grading now also accepts any translated version of an accepted answer.

## Uzbek language standards used

- **Script and orthography:** Uzbek Latin, following the 2018 orthography rules. Suffixes attach directly to abbreviations (HTMLdagi, RAMdan). After a foreign name in its original spelling, the suffix is separated with ’ (U+2019): Unreal Engine’ni, Blender’da. This is distinct from the tutuq belgisi ʼ (U+02BC), and the audit checks both.
- **Interface names stay original:** Blender, Unreal Engine and editing apps have no Uzbek interface, so menu and panel names stay in English (**Edit → Preferences**) with an Uzbek explanation.
- **Code:** keywords, tags, commands and identifiers are unchanged. Comments and on-screen text inside examples are translated (`<h1>Salom, veb!</h1>`, `city = "Samarqand"`).
- **Terminology:** one term per concept, kept consistent across courses. On first use the English term is given in italics so learners can match it to tutorials and software:

| English | Uzbek |
| --- | --- |
| input / processing / storage / output | kiritish / qayta ishlash / saqlash / chiqarish |
| hardware / software | apparat taʼminoti / dasturiy taʼminot |
| RAM / storage | operativ xotira (RAM) / doimiy xotira |
| motherboard | ona plata (tizim platasi) |
| file extension / path / folder | fayl kengaytmasi / yoʻl / papka |
| element / tag / attribute | element / teg / atribut |
| heading / paragraph / list | sarlavha / xatboshi / roʻyxat |
| variable / value / string / integer | oʻzgaruvchi / qiymat / satr / butun son |
| comment / bug / debugging | izoh / xato (*bug*) / xatolarni tuzatish (*debugging*) |
| vertex / edge / face | uch / qirra / yoq |
| shot / cut / frame / frame rate | lavha / kesish / kadr / kadrlar chastotasi |
| aspect ratio / resolution | tomonlar nisbati / ruxsat |
| hierarchy / alignment / proximity | ierarxiya / tekislash / yaqinlik |
| machine learning / hallucination | mashinali oʻqitish / gallyutsinatsiya |
| game engine | oʻyin dvigateli |

## Language switching (verified)

`qa/i18n-journey.cjs` runs against the same build the iPhone preview uses. It starts in Uzbek, completes a lesson and answers a quiz question, then switches to Russian, to English and back to Uzbek through the real Settings screen. **24/24 checks pass** (15 November, after Sprint 1):

- Uzbek course, lesson and quiz text is shown.
- Russian shows a Russian interface with the original content and the notice.
- English shows no notice.
- Course progress stays the same across every switch.
- Russian users are told plainly, on Home, on course cards, in the language picker and on lessons and quizzes, that lessons are not available in Russian yet. English text is never presented as a Russian translation.
- There are no console errors.

Switching does not refetch anything: the app caches the original rows with all their translations and picks the language when it renders, so switching also works offline.

## Progress preservation (verified)

On a database that already contained learner activity (enrolments, lesson progress, quiz attempts, achievements), the translation migration and all translation seeds were applied without a reset. Before and after, these checksums were compared:

- every course, lesson and answer ID
- every progress record (learner, lesson, status, completion time)
- every enrolment and its progress percentage
- every quiz attempt and its score
- every earned achievement

They were **identical**.

The same check was repeated after loading all Sprint 1 content (15 November): the fingerprint was again **identical**, and none of the 40 earlier lesson IDs changed. Placeholder lessons were completed in place rather than replaced.

The offline demo catalog (used by the iPhone preview) now keeps its IDs across exports, and maps the IDs of the first preview build. Progress saved on a device therefore carries over to new builds.

## Recommended before launch

1. **Native-speaker review:** a second editorial pass (15 Nov) fixed terminology (*lavha* vs *kadr*, *modul*, *debugging*) and consistency; see [docs/i18n/uz-style-guide.md](i18n/uz-style-guide.md). A native Uzbek editor should now review with the generated pack (`docs/review/uz-review-pack.html`) and sign off per course in Studio.
2. **Expert review** of each course (subject accuracy) and sign-off in Studio.
3. Translate course content into Russian with the same process, when you decide to. The audit test can be extended to `ru` by changing one constant.
