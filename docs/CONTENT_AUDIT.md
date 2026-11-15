# Content audit and Uzbek migration report

**Date:** 14 November 2026 · **Scope:** the 8 published starter courses, their 30 published lessons, 9 quizzes (32 questions, 95 answer options), 1 project assignment, plus categories, learning paths, achievements, plans and the author profile.

## Summary

- **Uzbek migration: complete.** Every published text in the starter library now has an Uzbek (Latin script) version, including all lesson bodies, quiz questions, answer options, feedback and explanations.
- **IDs and progress preserved.** Translations are stored next to the original text in the same rows. No course, module, lesson, quiz, question or answer was created or replaced. This was verified on a database that already had learner progress (see “Progress preservation” below).
- **Three-language switching works.** Interface and content follow the app language. Content shows Uzbek when it exists and the original English otherwise, with a visible “translation is being prepared” notice. Russian course content is not translated yet; Russian category names, achievements, plans and learning paths are.
- **Automated checks now guard the content.** `npm run db:test` fails if any published text lacks Uzbek, if Uzbek orthography is wrong, if a translation changes a lesson's structure, or if a quiz cannot be answered or graded.
- **Honest size check:** the published library is about 4,500 words. Every course is a short, accurate introduction, which is why all of them are labelled *In development*. The next phase ([curriculum](curriculum/README.md)) is about depth.

## Library at a glance

| Course | Level · access | Published lessons (unpublished) | Quizzes · questions | Words EN | Words UZ |
| --- | --- | --- | --- | --- | --- |
| AI Fundamentals & Prompting | zero · free | 3 (0) | 1 · 3 | 516 | 475 |
| Blender: Your First Steps in 3D | zero · free | 6 (2) | 1 · 4 | 822 | 801 |
| Computer Fundamentals from Zero | zero · free | 5 (2) | 2 · 9 | 872 | 748 |
| Design Principles from Zero | zero · free | 3 (0) | 1 · 3 | 322 | 308 |
| HTML from Absolute Zero | zero · free | 6 (2) | 2 · 7 | 888 | 796 |
| Python for Complete Beginners | zero · premium | 3 (2) | 1 · 3 | 518 | 492 |
| Unreal Engine Fundamentals | beginner · premium | 1 (2) | 0 · 0 | 167 | 161 |
| Video Editing Fundamentals | zero · free | 3 (0) | 1 · 3 | 405 | 374 |
| **Total** | | **30** | **32 questions** | **4 510** | **4 155** |

Word counts exclude code. Uzbek is agglutinative, so a faithful Uzbek text is typically 5–15% shorter in words than the English.

## How the audit was done

1. **Manual review of every lesson and quiz.** Each English lesson was read in full before it was translated. Each quiz question was traced to the lesson text that teaches it.
2. **Automated checks** (`supabase/tests/content.test.mjs`, run by `npm run db:test`):
   - **Completeness:** every published course, module, lesson, lesson body, quiz, question, answer, feedback text, assignment, category, path, achievement, plan and author has an Uzbek value.
   - **Orthography:** `oʻ`/`gʻ` use ʻ (U+02BB) and the tutuq belgisi uses ʼ (U+02BC). There are no ASCII apostrophes inside words, no Cyrillic letters in Uzbek Latin text, and no common words missing the tutuq belgisi (maʼlumot, taʼminot, sunʼiy, eʼtibor, taʼlim, …). The checker was itself tested against planted mistakes.
   - **Structure parity:** each translated lesson keeps the same code blocks (and languages), headings, callouts, table rows and list items as the original.
   - **Quiz integrity:** every question has an explanation and at least two options; single-choice and true/false questions have exactly one correct answer; translated option labels are not duplicated; every quiz lesson has a quiz.
   - **Honest status:** every published course has published lessons, every reading lesson has a body, counters match, and no course claims to be complete.
3. **The 441 Uzbek interface strings** were run through the same orthography checker and read through for grammar.

## Findings and fixes

| # | Finding | Severity | Action |
| --- | --- | --- | --- |
| 1 | *Python → Installing Python*: “go to the folder with the file” never explains how, which blocks absolute beginners | Medium | **Fixed** in English and Uzbek: introduces `cd` (*change directory*) with an example |
| 2 | Interface grammar: “15 daqiqadan 0”, “Oʻtish bali”, “Bir oz”, “Ishonchim komil” (means “I am certain”), and suffixes hanging off times and dates (“{time} da”) | Low | **Fixed** (`apps/mobile/src/i18n/uz.ts`) |
| 3 | Topics named after products (HTML, Python, Figma…) had no Uzbek entry, so the app would have treated them as untranslated | Low | **Fixed**: recorded explicitly as identical names in Uzbek and Russian |
| 4 | Inconsistent handling of suffixes after English product names | Low | **Fixed (revised 15 Nov):** the style guide now follows Uzbek media practice — ’ (U+2019) after foreign names in original spelling (“Unreal Engine’ni”); the interim rephrasing (“Unreal Engine dvigatelini”) was redundant and was replaced. The audit enforces ’ vs ʼ |
| 5 | **Unreal Engine Fundamentals** is published with 1 of 3 lessons and no assessment (lessons 2–3 are *in review* / *draft*) | **High** | **Open — decision needed.** Recommended: finish lessons 2–3 and a module quiz in the next content sprint (they are specified in [curriculum/unreal-engine.md](curriculum/unreal-engine.md)). Until then it is labelled *In development*. If you prefer, unpublish it in Studio; learner progress is kept either way |
| 6 | All courses are short introductions (161–888 words) | Expected | Accurate *In development* labels; addressed by the curriculum plan |
| 7 | No videos and no downloadable resources exist yet | Expected | Content production task; the player and downloads are ready |

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

Short-answer questions (`mp4`, `body`) are language-neutral. As a safeguard, grading now also accepts any translated version of an accepted answer.

## Uzbek language standards used

- **Script and orthography:** Uzbek Latin, following the 2018 orthography rules. Suffixes attach directly to abbreviations (HTMLdagi, RAMdan). Suffixes are not split from foreign names with apostrophes; those sentences are rephrased.
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

`qa/i18n-journey.cjs` runs against the same build the iPhone preview uses. It starts in Uzbek, completes a lesson and answers a quiz question, then switches to Russian, to English and back to Uzbek through the real Settings screen. **16/16 checks pass**:

- Uzbek course, lesson and quiz text is shown.
- Russian shows a Russian interface with the original content and the notice.
- English shows no notice.
- Course progress stays the same (20%) across every switch.
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

## Recommended before launch

1. **Native-speaker review:** a second editorial pass (15 Nov) fixed terminology (*lavha* vs *kadr*, *modul*, *debugging*) and consistency; see [docs/i18n/uz-style-guide.md](i18n/uz-style-guide.md). A native Uzbek editor should now review with the generated pack (`docs/review/uz-review-pack.html`) and sign off per course in Studio.
2. Decide on **Unreal Engine Fundamentals** (finding 5).
3. Translate course content into Russian with the same process. The audit test can be extended to `ru` by changing one constant.
