# Mahorat — Progress report

**As of:** 15 November 2026 · **Branch:** `claude/premium-education-app-yjg0v3`

This report separates what is **built and verified**, what is **built but only verifiable
with accounts or hardware we do not have here**, and what is **not done**. The app has
**not** been submitted to or published on the App Store or Google Play.

## Summary

| Phase | Scope | Status |
| --- | --- | --- |
| 1 · Audit | The repository contained only an initial README, so there was no existing code to preserve | Done |
| 2 · Architecture | Monorepo, Supabase design, data model, security model ([ARCHITECTURE.md](ARCHITECTURE.md)) | Done |
| 3 · Brand and design system | Name, logo mark, app icon, splash, palette, type scale, tokens, ~40 components, dark and light themes | Done |
| 4 · Navigation and core screens | Splash, onboarding (interests, goal, level), auth, 4-tab shell, home, explore, course, category, path | Done |
| 5 · Learning experience | Lesson player (video, written content, notes, bookmarks, resources, prev/next, auto-saved progress), quizzes, assignments, certificates | Done; see the content gaps below |
| 6 · Personalisation | Recommendations, daily goal, streaks, XP, achievements, reminders | Done |
| 7 · Backend and admin | Schema, RLS, RPC engine, storage, edge functions, Mahorat Studio CMS | Done |
| 8 · Monetisation and AI | RevenueCat purchase and restore flow, webhook sync, paywall, assistant edge function | Built; live purchases and the AI provider are not connected |
| 9 · Testing | Backend E2E, unit, type and lint, automated journeys, visual QA | Done for everything testable here |
| 10 · Store preparation | `eas.json`, listing copy (en/uz/ru), screenshots, feature graphic, privacy answers, release runbook | Done; store accounts and submission are not done |
| 11 · Educational foundation | Uzbek translation of all published content (translation layer that keeps every ID), content audit, Studio translation editing, curricula for all seven subjects | Done — see [CONTENT_AUDIT.md](CONTENT_AUDIT.md) and [curriculum/](curriculum/README.md) |
| 12 · Sprint 1 | Finish the eight published courses: 30 → 99 lessons, knowledge checks, projects and final assessments in English and Oʻzbekcha; Unreal lessons 2–3; review sign-offs in Studio; plain notice for Russian users | Written and verified ([curriculum/sprint-1.md](curriculum/sprint-1.md)). No course is marked complete until the expert and native-Uzbek reviews are approved |

## Verified in this environment

| Check | Result |
| --- | --- |
| Content audit + backend E2E on a fresh `supabase db reset` | **24/24 pass**: 7 content checks (including the course completion checklist) and 17 database tests, including a learner completing all eight courses. The 6 edge-function tests passed in phase 9 and that code has not changed; they were not re-run because the edge runtime was not running |
| Mobile unit tests (Jest) | **32/32 pass**, including all eight courses completed in the offline demo engine and progress carried over from older builds |
| TypeScript (mobile and admin) | Clean |
| ESLint (mobile), including React Compiler rules | 0 errors; 1 warning in the Jest setup file |
| oxlint (Studio) | 0 errors; 14 warnings (fast-refresh exports and one effect), unchanged from the original Studio build |
| `expo-doctor` | 18/20. The 2 failing checks need network access to Expo's API, which this sandbox blocks |
| `expo prebuild` for iOS and Android | Succeeds. Generated manifests inspected: Android requests only `INTERNET` and `VIBRATE` (camera, microphone and storage removed); the iOS Sign in with Apple entitlement, `mahorat://` scheme and privacy manifest are present |
| Learner journey, web build against local Supabase (`qa/journey.cjs`) | **31/31 steps**, no console errors |
| Studio journey (`qa/admin-journey.cjs`) | **19/19 steps**, including editing and saving translations |
| Language switching (`qa/i18n-journey.cjs`, the build used by the iPhone preview) | **24/24 checks**: uz → ru → en → uz, content, Russian notices, lesson-language badges and progress |
| Migration and Sprint 1 content on a database with existing learner data | IDs, progress, enrolments, attempts and achievements **identical** before and after |
| Expo Go preview (EAS Update, demo mode) | Republished with all Sprint 1 content (15 Nov). The live manifest was checked, and its bundle hash matches the inspected build. Testing on the iPhone is up to you |
| Visual QA | Screens checked in dark and light, en/uz/ru, at phone sizes; issues found were fixed |
| Store screenshots | Generated from the real app with real seeded progress (`qa/store-screenshots.cjs`) |

## Built but not verifiable here

These need a Mac, physical or emulated devices, or third-party accounts:

- **Running on real iOS and Android devices or simulators.** The sandbox has no macOS and
  no KVM. The native projects generate correctly, but they have not been compiled with
  Xcode or Gradle and no device test has been run. Gesture feel, haptics, picture-in-picture
  and 60 fps animation performance must be checked on hardware.
- **Purchases.** The RevenueCat SDK flow, products and webhook handler are implemented and
  the webhook is tested with signed sample events. Real StoreKit or Play Billing sandbox
  purchases need App Store Connect, Play Console and RevenueCat projects.
- **Google and Apple sign-in.** The code paths are implemented, and email sign-in works end
  to end. OAuth needs real client IDs, Apple Services ID and keys.
- **Push notifications.** Local daily reminders are implemented. Remote push needs an EAS
  project ID plus APNs and FCM credentials.
- **Learning assistant.** The edge function is implemented and tested for auth, validation,
  quota and the disabled state. No AI provider key is configured, so it is **off**, and the
  app says so.

## Content status

What exists:

- **7 categories and 100 topics** across IT, programming, video, Blender/3D,
  Unreal/games, design and AI.
- **8 published courses with 99 lessons** for absolute beginners: 51 articles, 10 exercises, 10 projects and 28 quiz lessons. They hold about 21,500 words of lesson text, excluding code. Every teaching module ends with a knowledge check, and every course has a project with a rubric and a final assessment.
- **All of it in English and Oʻzbekcha.** Every lesson, quiz question, answer and piece of
  feedback has an Uzbek version, checked by the content audit. Category names,
  achievements, plans and learning paths are also in Русский.
- **31 quizzes** (169 questions) with explanations for every answer, **10 projects**, **4 learning paths** and
  **13 achievements**.
- Draft and in-review courses that show the editorial workflow.

What does **not** exist yet, and what the app is honest about:

- **No course is marked complete.** Every course has `content_complete = false` and is labelled
  *In development*. Each course now passes every automated readiness check. What remains is
  the **expert review** and the **native-Uzbek review**, which are recorded in Studio. The
  database refuses to mark a course complete until both are approved. The courses are
  beginner level; the curriculum describes the later levels.
- **No video has been produced.** The player supports HLS/MP4 sources, captions, speed,
  quality and picture-in-picture, but no video sources are seeded.
- **No downloadable resources** (PDFs or project files) have been produced yet. The upload
  and download pipeline works.
- **No real instructors.** Courses are attributed to the "Mahorat Editorial Team".
- **Course content is not yet in Russian (by decision).** Russian learners are told this plainly:
  on Home, on every course card (“Уроки: English”), in the language picker and on lessons and
  quizzes. English text is never presented as a Russian translation.
- **A native-speaker review of the Uzbek is still needed.** It passes automated orthography
  and structure checks and a second editorial pass. A native editor should now review it with
  `docs/review/uz-review-pack.html` (English and Uzbek side by side, with a glossary).
- **Unreal Engine Fundamentals** now has its three getting-started lessons, a knowledge check, a
  project and a final assessment (decision 1). The rest of the Unreal curriculum (scene
  building, look and feel, gameplay) is planned, not written.
- **None of the seven new curricula is opened as an app course.** That waits until Sprint 1 is
  reviewed and you approve the next step.

## Remaining before a public release

1. **Accounts:** Apple Developer Program, Google Play Console, RevenueCat, a production
   Supabase project, an Expo/EAS account and a domain for the legal pages and support.
2. **Legal:** fill the placeholders in the Privacy Policy and Terms
   (`apps/mobile/src/content/legal.ts`), publish them at the configured URLs and have them
   reviewed by a lawyer. Uzbekistan's Law on Personal Data (ZRU-547) requires personal
   data of citizens of Uzbekistan to be stored in databases located in Uzbekistan. Choose
   hosting accordingly or obtain legal advice before launching there.
3. **Content production:** the expert and native-Uzbek reviews of the eight courses, then record
   videos, then the Russian translations when you decide. Set `content_complete` per course only
   when it meets the definition of done; Studio enforces the review sign-offs.
4. **Device QA** on a range of iPhones and Android phones, including low-end Android
   devices, plus TestFlight and Play internal testing rounds.
5. **Store submission:** follow [RELEASE.md](RELEASE.md). Use the listing copy and privacy
   answers in `store/`, and create a reviewer demo account.
6. Optional: connect an AI provider and enable the assistant; add crash reporting (no
   analytics or crash SDK is included, and none is declared in the privacy answers).

## Git

All work is committed on `claude/premium-education-app-yjg0v3`. Pushing to GitHub was
refused (HTTP 403) because this session has no write access to the repository. The commits
are local to the session. Once you confirm GitHub access is restored, the branch will be pushed and the
remote checked commit by commit.
