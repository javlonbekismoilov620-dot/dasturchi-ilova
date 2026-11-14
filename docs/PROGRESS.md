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

## Verified in this environment

| Check | Result |
| --- | --- |
| Backend E2E (`npm run db:test`) on a fresh `supabase db reset` | **21/21 pass** (15 database + 6 edge function) |
| Mobile unit tests (Jest) | **21/21 pass** |
| TypeScript (mobile and admin) | Clean |
| ESLint, including React Compiler rules | Clean |
| `expo-doctor` | 18/20. The 2 failing checks need network access to Expo's API, which this sandbox blocks |
| `expo prebuild` for iOS and Android | Succeeds. Generated manifests inspected: Android requests only `INTERNET` and `VIBRATE` (camera, microphone and storage removed); the iOS Sign in with Apple entitlement, `mahorat://` scheme and privacy manifest are present |
| Learner journey, web build against local Supabase (`qa/journey.cjs`) | **31/31 steps**, no console errors |
| Studio journey (`qa/admin-journey.cjs`) | **16/16 steps** |
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
  beginners. Together they include 20 articles, 4 exercises, 6 quiz lessons and 1 project.
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
- **Course text is in English only.** The interface is fully translated into Oʻzbekcha and
  Русский; course content in uz/ru is a content-production task.

## Remaining before a public release

1. **Accounts:** Apple Developer Program, Google Play Console, RevenueCat, a production
   Supabase project, an Expo/EAS account and a domain for the legal pages and support.
2. **Legal:** fill the placeholders in the Privacy Policy and Terms
   (`apps/mobile/src/content/legal.ts`), publish them at the configured URLs and have them
   reviewed by a lawyer. Uzbekistan's Law on Personal Data (ZRU-547) requires personal
   data of citizens of Uzbekistan to be stored in databases located in Uzbekistan. Choose
   hosting accordingly or obtain legal advice before launching there.
3. **Content production:** complete the starter courses, record videos, write uz/ru
   versions, and then set `content_complete` per course.
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
