# Mahorat — Architecture

Mahorat is a premium learning ecosystem made of three deployable parts that share one
Supabase project:

```
┌──────────────────────────┐     ┌──────────────────────────┐
│  Mobile app (Expo / RN)  │     │  Mahorat Studio (admin)  │
│  iOS · Android · web*    │     │  Vite + React SPA        │
└─────────────┬────────────┘     └─────────────┬────────────┘
              │ anon key + user JWT (RLS)       │ anon key + staff JWT (RLS + roles)
              ▼                                 ▼
┌───────────────────────────────────────────────────────────────┐
│ Supabase                                                      │
│  Postgres 17 ─ tables · RLS · triggers · SECURITY DEFINER RPCs│
│  Auth ─ email/password, magic link, Google, Apple (PKCE)      │
│  Storage ─ public-media · avatars · course-media · resources  │
│            · submissions (path-based policies)                │
│  Edge functions ─ delete-account · assistant ·                │
│                   revenuecat-webhook                          │
└──────────────┬──────────────────────────────┬─────────────────┘
               │                              │
     RevenueCat webhook              AI provider (optional,
     (App Store / Google Play)       server-side key only)
```

\* The web build of the mobile app is used for automated QA and store screenshots. It is not a
product surface.

## Repository layout

| Path | What it is |
| --- | --- |
| `apps/mobile` | Expo SDK 58 app (`@mahorat/mobile`), Expo Router file-based routes in `src/app` |
| `apps/admin` | Mahorat Studio, the role-based CMS (`@mahorat/admin`) |
| `supabase/migrations` | Schema, learning engine, RLS, RPCs, function support (applied in order) |
| `supabase/seeds` | Platform settings, categories, achievements, plans and the starter course library |
| `supabase/functions` | Deno edge functions plus `_shared/http.ts` |
| `supabase/tests` | Backend end-to-end tests (`npm run db:test`) |
| `qa` | Playwright journeys, store screenshot and graphics generators |
| `store` | Store listing copy, privacy answers, generated screenshots and graphics |
| `docs` | This document, the progress report and the release runbook |

## Mobile app

**Stack.** Expo SDK 58, React Native 0.88, React 19 with the React Compiler, Expo Router
(typed routes, `Stack.Protected` guards), Reanimated 4 + Gesture Handler 3, TanStack Query
(persisted to AsyncStorage for offline reading), Zustand (preferences, auth), zod
(validation), expo-video (player and picture-in-picture), RevenueCat (`react-native-purchases`).

**Navigation.**

```
_layout (providers, splash, guards)
├─ onboarding/      welcome → interests → goal → level        (only until completed)
├─ (tabs)/          Home · Explore · Learning · Profile        (custom animated TabBar)
├─ auth/            provider choice · email (sign in / up / magic link / reset)
├─ course/[slug]    category/[slug] · path/[slug]
├─ lesson/[id]      video + written content, notes, bookmarks, resources, prev/next
├─ quiz/[id]        assignment/[id]
├─ achievements · certificates/ · notifications · paywall · assistant
└─ settings/        profile · legal/[doc]
```

**Data layer.** Every screen talks to the `LearningApi` interface (`src/data/api.ts`).
There are two implementations:

- `supabaseApi.ts` is production. It uses PostgREST reads under RLS and RPCs for every
  state change (enrolling, progress, quiz grading, certificates).
- `demo/demoApi.ts` is **demo mode**, selected only when no Supabase URL is configured. It
  serves a bundled export of the seed catalog (`demo/catalog.json`) and mirrors the SQL
  engine's rules on-device. The UI labels itself *Demo mode*, and production
  builds refuse to start without Supabase credentials (`app.config.ts`).

Hooks in `src/data/hooks.ts` wrap the API in React Query with stable query keys; mutations
invalidate exactly the keys they affect and push achievement/certificate events to the
celebration host.

**Sessions.** Supabase auth uses PKCE. The session is stored AES-encrypted in AsyncStorage,
and the AES key lives in SecureStore (Keychain / Keystore), which works around SecureStore's
value-size limit without storing tokens in plaintext. Native Sign in with Apple uses a
hashed nonce, and Google uses the system browser (`expo-web-browser`) with the `mahorat://`
redirect.

**Design system** (`src/theme`, `src/components`). Tokens cover a dark "ink" palette with
gold accents plus a full light theme, spacing, radii, elevation, motion springs and a type
scale. Inter is used for UI, Cormorant Garamond for display and JetBrains Mono for code.
All three fonts cover Latin, Cyrillic and the Uzbek ʻ/ʼ letters. Components are built only
on these tokens.
Motion respects the system *Reduce Motion* setting and an in-app override.

**Internationalisation.** `src/i18n` has typed dictionaries for English, Oʻzbekcha and
Русский, CLDR plural rules (including Russian one/few/many) and Uzbek date formatting. The
compiler rejects missing keys.

**Content translations.** Each course has a base language (`courses.language`). Translations
live next to the original text in a `translations` jsonb column on every content table,
for example `{ "uz": { "title": "…", "body_md": "…" } }`. Because they are stored on the
same rows, translating never changes IDs, progress, attempts or certificates.
`src/i18n/content.ts` applies the overlay for the app language in React Query's `select`.
The cache keeps the raw rows, so switching language is instant and works offline. When a
translation is missing, the original is shown with a notice. On the server:
- `get_quiz` returns translated prompts and options, but not translated explanations.
- `submit_quiz_attempt` returns translated explanations and feedback.
- Short answers are accepted in any language.
- Search covers translated titles.

Studio edits translations side by side with the source text, and
`supabase/tests/content.test.mjs` audits completeness, orthography and structure.

**Offline.** React Query's cache is persisted, so courses and lessons opened before stay
readable offline. Lesson resources can be downloaded to the app's document directory
(`src/lib/downloads.ts`, with an optional Wi-Fi-only setting). Progress writes need a
connection, and a banner shows when the device is offline.

## Backend

### Data model (summary)

| Area | Tables |
| --- | --- |
| People | `profiles`, `user_roles` (admin · editor · instructor · reviewer), `instructors` |
| Catalog | `categories` (self-referencing for topics), `courses`, `course_prerequisites`, `learning_paths`, `learning_path_courses` |
| Structure | `modules`, `lessons` (video · article · quiz · assignment · project · exam), `lesson_contents` (gated body), `videos`, `video_sources`, `video_captions`, `resources` |
| Assessment | `quizzes`, `questions`, `answers`, `quiz_attempts`, `assignments`, `submissions` |
| Learning state | `enrollments`, `lesson_progress`, `daily_activity`, `bookmarks`, `lesson_notes`, `certificates` |
| Motivation | `achievements`, `user_achievements` |
| Commerce | `subscription_plans`, `subscriptions` |
| Platform | `app_settings`, `notifications`, `notification_reads`, `push_tokens`, `audit_log`, `assistant_usage` |

Levels follow the ecosystem: `zero → beginner → intermediate → advanced → professional → expert`.

Each course carries a `content_complete` flag. While it is false, the app labels the course
*In development*, so an unfinished course is never presented as finished.

### Security model

- **RLS on every table.** Learners can read published content and their own learning
  state. Staff access is scoped by role, and instructors only see courses they own.
- **No direct writes to engine tables.** `lesson_progress`, `quiz_attempts`,
  `enrollments`, `certificates`, `user_achievements` and `subscriptions` are written only
  through `SECURITY DEFINER` RPCs that validate input (for example, progress is capped at
  600 seconds per heartbeat, and quiz and assignment lessons complete only through their
  own RPC).
- **Server-side grading.** `get_quiz` never returns answer keys. `submit_quiz_attempt`
  grades on the server and only then returns explanations.
- **Premium gating in the database.** `private.can_access_lesson()` decides whether the
  gated lesson body (`lesson_contents`), video sources and premium resources are readable.
  The client never decides entitlement.
- **Column guards.** Triggers stop clients from changing protected columns (roles, counters,
  publish state for non-editors, submission grades) and from removing the last admin.
- **Audit.** Every write that a client role makes to content tables is recorded in
  `audit_log`, which is shown in Studio.
- **Helpers** live in a non-exposed `private` schema with an empty `search_path`.
- **Storage** policies derive the owning course or user from the object path.
- **Secrets** (service role, RevenueCat webhook secret, AI provider key) exist only as edge
  function secrets. Apps ship only the public anon key and public RevenueCat SDK keys.

### Learning engine (SQL)

`record_lesson_progress`, `complete_lesson` and `recompute_enrollment` drive progress. Then:

- `touch_activity` maintains daily minutes and streaks in the learner's timezone.
- `evaluate_achievements` awards achievements from data-driven criteria.
- `issue_certificate_if_eligible` issues a certificate once every required lesson and final
  assessment is passed, subject to `app_settings.certificates.require_premium`. Serials look
  like `MHR-YYYY-XXXXXXXX` and can be checked publicly through `verify_certificate`.

### Subscriptions

The stores are the source of truth. The flow is: purchase in the app (RevenueCat, using
StoreKit or Play Billing), then RevenueCat sends a webhook to `revenuecat-webhook`, which
checks a shared secret in constant time and calls `apply_store_subscription_event`. That
writes `subscriptions`, and `private.has_premium()` reads from it. Refunds and expirations
end access. Admins can also grant time-boxed manual premium, which is recorded separately
and audited.
`app_settings.billing.mode = "free_for_all"` opens the whole library without a release.

### Learning assistant

`assistant` is an edge function. It validates the conversation, enforces a per-user daily
quota (`assistant_consume_quota`) and loads the current lesson with the user's own JWT, so
RLS still applies. It then calls the AI provider with a server-side key. The feature is off
until two things are true: `app_settings.assistant.enabled` is set and `ANTHROPIC_API_KEY`
is configured. Until then the app explains that the assistant is not connected and sends
nothing.

## Mahorat Studio (admin)

Studio is a Vite + React Router + TanStack Query SPA that uses the same anon key; roles and
RLS enforce authorisation. It has these pages:

- Dashboard: stats from `admin_dashboard_stats`.
- Courses, plus course, lesson and quiz editors. Markdown preview is sanitised with
  DOMPurify, and uploads go to Storage.
- Categories, Learning paths, Instructors and Achievements.
- Submissions review.
- Users: roles and manual premium.
- Billing and settings.
- Announcements: broadcast notifications.
- Audit log.

Publishing is restricted to editors and admins. The database rejects anything else
(`only_editors_can_publish`).

## Testing and QA

| Suite | Command | Covers |
| --- | --- | --- |
| Content audit | `npm run db:test` | Uzbek completeness, orthography (ʻ/ʼ), structure parity with the source, quiz integrity, honest status flags |
| Backend E2E | `npm run db:test` | RLS isolation, enrolment, progress caps, server grading, forged answers, translations, certificates, premium gating, admin RPCs, edge functions |
| Mobile unit | `npm test -w @mahorat/mobile` | i18n plurals and formatting, learning helpers, validation, demo engine |
| Type and lint | `npm run typecheck`, `npm run lint` | Both apps, including React Compiler rules |
| Mobile journey | `node qa/journey.cjs` | Full learner journey on the web build against local Supabase |
| Studio journey | `node qa/admin-journey.cjs` | Admin sign-in, CRUD, publishing and translation editing |
| Language journey | `node qa/i18n-journey.cjs` | Switching uz/ru/en in Settings: content, fallback notices, progress kept |
