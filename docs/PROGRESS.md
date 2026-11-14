# Mahorat — Progress report

**As of:** 14 November 2026 · **Branch:** `claude/premium-education-app-yjg0v3`

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

## Verified in this environment

| Check | Result |
| --- | --- |
| Content audit + backend E2E (`npm run db:test`) on a fresh `supabase db reset` | **22/22 pass**: 6 content checks and 16 database tests. The 6 edge-function tests passed in phase 9 and that code has not changed; they were not re-run in phase 11 because the edge runtime was not running |
| Mobile unit tests (Jest) | **30/30 pass** |
| TypeScript (mobile and admin) | Clean |
| ESLint, including React Compiler rules | Clean |
| `expo-doctor` | 18/20. The 2 failing checks need network access to Expo's API, which this sandbox blocks |
| `expo prebuild` for iOS and Android | Succeeds. Generated manifests inspected: Android requests only `INTERNET` and `VIBRATE` (camera, microphone and storage removed); the iOS Sign in with Apple entitlement, `mahorat://` scheme and privacy manifest are present |
| Learner journey, web build against local Supabase (`qa/journey.cjs`) | **31/31 steps**, no console errors |
| Studio journey (`qa/admin-journey.cjs`) | **19/19 steps**, including editing and saving translations |
| Language switching (`qa/i18n-journey.cjs`, the build used by the iPhone preview) | **16/16 checks**: uz → ru → en → uz, content, notices and progress |
| Migration on a database with existing learner data | IDs, progress, enrolments, attempts and achievements **identical** before and after |
| Expo Go preview (EAS Update, demo mode) | Republished with the Uzbek content; manifest and bundle checked. Opening it on an iPhone is up to you |
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
- **8 published starter courses with 30 lessons**, written in plain language for absolute
  beginners. Together they include 20 articles, 4 exercises, 6 quiz lessons and 1 project,
  and about 4,500 words of lesson text.
- **All of it in English and Oʻzbekcha.** Every lesson, quiz question, answer and piece of
  feedback has an Uzbek version, checked by the content audit. Category names,
  achievements, plans and learning paths are also in Русский.
- **9 quizzes** with explanations for every answer, **4 learning paths** and
  **13 achievements**.
- Draft and in-review courses that show the editorial workflow.

What does **not** exist yet, and what the app is honest about:

- **No course is complete.** Every course has `content_complete = false` and is labelled
  *In development*. The starter lessons are real teaching content, but each course needs
  many more modules before it reaches professional depth.
- **No video has been produced.** The player supports HLS/MP4 sources, captions, speed,
  quality and picture-in-picture, but no video sources are seeded.
- **No downloadable resources** (PDFs or project files) have been produced yet. The upload
  and download pipeline works.
- **No real instructors.** Courses are attributed to the "Mahorat Editorial Team".
- **Course content is not yet in Russian.** Russian learners see the original English text with a
  “translation is being prepared” notice.
- **A native-speaker review of the Uzbek is still needed.** It passes automated orthography
  and structure checks, but a native editor should review style and terminology.
- **Unreal Engine Fundamentals** is published with 1 of 3 lessons and no assessment. Deciding
  whether to finish or unpublish it is listed as an open finding in the content audit.
- **The next phase is depth.** [curriculum/](curriculum/README.md) defines every course from Zero to
  Professional for all seven subjects, a lesson standard and a definition of done. It
  starts with finishing the eight published courses (about 45 lessons).

## Remaining before a public release

1. **Accounts:** Apple Developer Program, Google Play Console, RevenueCat, a production
   Supabase project, an Expo/EAS account and a domain for the legal pages and support.
2. **Legal:** fill the placeholders in the Privacy Policy and Terms
   (`apps/mobile/src/content/legal.ts`), publish them at the configured URLs and have them
   reviewed by a lawyer. Uzbekistan's Law on Personal Data (ZRU-547) requires personal
   data of citizens of Uzbekistan to be stored in databases located in Uzbekistan. Choose
   hosting accordingly or obtain legal advice before launching there.
3. **Content production:** follow the curriculum. Sprint 1 completes the eight published
   courses; then record videos, add the Russian translations and arrange a native-speaker
   review. Set `content_complete` per course only when it meets the definition of done.
4. **Device QA** on a range of iPhones and Android phones, including low-end Android
   devices, plus TestFlight and Play internal testing rounds.
5. **Store submission:** follow [RELEASE.md](RELEASE.md). Use the listing copy and privacy
   answers in `store/`, and create a reviewer demo account.
6. Optional: connect an AI provider and enable the assistant; add crash reporting (no
   analytics or crash SDK is included, and none is declared in the privacy answers).

## Git

All work is committed on `claude/premium-education-app-yjg0v3`. Pushing to GitHub was
refused (HTTP 403) because this session has no write access to the repository. The commits
are local to the session until access is granted and the branch is pushed.
