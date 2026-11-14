# Mahorat

**From zero to mastery.** Mahorat is a learning app for iOS and Android. It takes learners
from no prior knowledge through *Zero → Beginner → Intermediate → Advanced → Professional
→ Expert* in IT, programming, video production, Blender/3D, Unreal Engine and game
development, graphic design, and AI. The interface is available in English, Oʻzbekcha and
Русский.

| | |
| --- | --- |
| `apps/mobile` | Expo / React Native app (iOS, Android) |
| `apps/admin` | **Mahorat Studio**, a role-based CMS for categories, courses, lessons, quizzes, review, users and billing |
| `supabase` | Postgres schema with RLS, the learning engine (RPCs), storage, edge functions, seed content and tests |
| `store` | Store listing copy (en/uz/ru), privacy answers, screenshots and graphics |
| `qa` | Playwright journeys and store-asset generators |
| `docs` | [Architecture](docs/ARCHITECTURE.md) · [Progress report](docs/PROGRESS.md) · [Release runbook](docs/RELEASE.md) |

> **Status:** in development, and **not published** on the App Store or Google Play. See the
> [progress report](docs/PROGRESS.md) for what is verified, what still needs devices or
> store accounts, and what content remains to be produced.

## Quick start

Requirements: Node ≥ 20.19 and Docker (for the local Supabase stack).

```bash
npm install

# Backend: local Supabase with schema, seed content and edge functions
npm run db:start
npx supabase functions serve          # optional: delete-account, assistant, webhook
node supabase/scripts/create-dev-users.mjs   # admin/editor/instructor/student @mahorat.local

# Mobile app
cp apps/mobile/.env.example apps/mobile/.env.local   # paste values from `npx supabase status`
npm run mobile                         # Expo dev server; press i / a, or scan with a dev build

# Studio
cp apps/admin/.env.example apps/admin/.env.local
npm run admin                          # http://localhost:5173
```

**Demo mode.** If `EXPO_PUBLIC_SUPABASE_URL` is empty, the app runs on a bundled copy of the
seed catalog with on-device progress, and it is labelled *Demo mode* throughout. Production
builds refuse to build without Supabase credentials, so demo mode can never reach the stores.

The app uses native modules (video, purchases, Apple sign-in, secure storage), so on a
device use a **development build** (`npx eas-cli build --profile development`) rather than
Expo Go.

## Checks

```bash
npm run typecheck        # mobile + admin
npm run lint
npm test                 # mobile unit tests (Jest)
npm run db:test          # backend E2E: resets the local DB, then runs the RLS/engine/function tests
```

Journeys on the web build (they need the local stack and the dev users):

```bash
(cd apps/mobile && EXPO_OFFLINE=1 npx expo export --platform web)
node qa/serve.mjs apps/mobile/dist 8090 &
NODE_PATH=$(npm root -g) node qa/journey.cjs
```

## Security notes

- Apps contain only **public** keys: the Supabase anon key and the RevenueCat SDK keys.
  The service-role key, webhook secret and AI provider key exist only as edge function
  secrets.
- Every table has Row Level Security. State changes go through validated `SECURITY
  DEFINER` RPCs, quizzes are graded on the server, and premium access is decided in the
  database.
- Never commit `.env.local`, `apps/mobile/secrets/` or store credentials; they are
  git-ignored.
