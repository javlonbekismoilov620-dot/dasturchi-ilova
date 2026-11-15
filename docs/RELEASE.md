# Release runbook

Steps to take Mahorat from this repository to TestFlight and Google Play internal testing,
then to public release. Do them in order. Anything in `[brackets]` is yours to fill in.

> The app is **not** published. Store review can reject a build, so treat "submitted" and
> "live" as separate milestones and record each one in [PROGRESS.md](PROGRESS.md).

## 0. Accounts you need

- Apple Developer Program (organisation account recommended, which needs a D-U-N-S number)
- Google Play Console (organisation account). New personal accounts must run a closed test
  before production access.
- Supabase (production project, Pro plan recommended for backups and point-in-time recovery)
- RevenueCat
- Expo account (EAS Build and Submit)
- A domain for `privacy`, `terms` and support, for example `mahorat.app`

## 1. Production Supabase

1. Create the project. Choose its region with the data-localisation note in PROGRESS.md in
   mind.
2. Link the project and push the schema:
   ```bash
   npx supabase link --project-ref [ref]
   npx supabase db push            # applies supabase/migrations in order
   ```
3. Load the platform seed (settings, categories, plans, achievements and the starter
   courses). Run `supabase/seeds/*.sql` in filename order with `psql` against the production
   connection string. Re-running them is safe because they use `on conflict do nothing`.
   Then edit `app_settings.support` with your real email and URLs.
4. **Auth settings** (Dashboard → Authentication):
   - Site URL: `https://[your-domain]`.
   - Redirect URLs: `mahorat://**` and the Studio URL.
   - Enable email confirmations and set up a custom SMTP sender.
   - **Google:** create OAuth clients (Web, iOS, Android) in Google Cloud and put the Web
     client ID and secret in Supabase.
   - **Apple:** create a Services ID and a Sign in with Apple key, then enter them in
     Supabase. Add the iOS bundle ID `uz.mahorat.app` to the authorised client IDs for
     native sign-in.
5. **Edge functions:**
   ```bash
   npx supabase functions deploy delete-account
   npx supabase functions deploy revenuecat-webhook --no-verify-jwt
   npx supabase functions deploy assistant
   npx supabase secrets set REVENUECAT_WEBHOOK_SECRET=[long random string]
   # Optional, only when enabling the learning assistant:
   npx supabase secrets set ANTHROPIC_API_KEY=[key] ASSISTANT_MODEL=[model id]
   ```
   Never put the service-role key or these secrets in the apps.
6. **First admin.** Sign up through the app or Studio, then in the SQL editor run:
   ```sql
   insert into public.user_roles (user_id, role)
   select id, 'admin' from auth.users where email = '[you@domain]';
   ```

## 2. Mahorat Studio

```bash
cp apps/admin/.env.example apps/admin/.env.production   # set VITE_SUPABASE_URL / _ANON_KEY
npm run build -w @mahorat/admin                          # output: apps/admin/dist
```

Host `apps/admin/dist` on any static host with SPA fallback to `index.html`, behind HTTPS.
Studio holds no secrets; access is enforced by roles and RLS.

## 3. Subscriptions

1. **App Store Connect:** create the app (bundle ID `uz.mahorat.app`), a subscription group
   *Mahorat Premium* and products `uz.mahorat.premium.monthly` and
   `uz.mahorat.premium.yearly`. Add localised names and the review screenshot.
2. **Play Console:** create subscription `mahorat_premium` with base plans `monthly` and
   `yearly`.
3. **RevenueCat:**
   - Add both apps and import the products.
   - Create the entitlement `premium`.
   - Create an offering whose packages are `$rc_monthly` and `$rc_annual`. These IDs are
     already in `subscription_plans`.
   - Add the webhook: URL `https://[ref].supabase.co/functions/v1/revenuecat-webhook`,
     Authorization header value `Bearer [REVENUECAT_WEBHOOK_SECRET]`.
   - Send a test event and confirm it returns 200.
4. Put the **public** SDK keys in EAS environment variables (step 4).
5. Run sandbox purchase, restore, cancel and refund tests on both platforms. Confirm that
   `subscriptions` updates and that premium lessons unlock and re-lock.

## 4. EAS Build

```bash
cd apps/mobile
npx eas-cli login
npx eas-cli init                 # creates the project; copy its id
```

Create EAS environment variables for `production` (and `preview`), with plain-text
visibility because they are public:

| Variable | Value |
| --- | --- |
| `EXPO_PUBLIC_SUPABASE_URL` | `https://[ref].supabase.co` |
| `EXPO_PUBLIC_SUPABASE_ANON_KEY` | Project anon / publishable key |
| `EXPO_PUBLIC_REVENUECAT_APPLE_KEY` | RevenueCat Apple public key |
| `EXPO_PUBLIC_REVENUECAT_GOOGLE_KEY` | RevenueCat Google public key |
| `EAS_PROJECT_ID` | From `eas init` |
| `EAS_OWNER` | Your Expo account or organisation |

`app.config.ts` stops a production build that has no Supabase credentials, so a
store build can never fall back to demo mode.

```bash
npx eas-cli build --profile preview --platform all      # internal testers (APK + ad-hoc iOS)
npx eas-cli build --profile production --platform all   # store binaries (AAB + IPA)
```

Build numbers are managed remotely and auto-increment in the `production` profile.

## 5. Device QA (blocking)

Test on at least one small iPhone, one large iPhone, one recent Android phone and one
low-end Android phone (2–3 GB RAM). Cover these:

- Onboarding, all sign-in methods, sign-out and account deletion
- Enrolling, the lesson player (video, picture-in-picture, captions, speed), notes,
  bookmarks and downloads in airplane mode
- Quizzes, assignment upload, certificate PDF export and sharing
- Purchase, restore and an expired subscription
- Reminders and push notifications
- Dark and light themes, all three languages, the largest Dynamic Type / font scale, and
  VoiceOver / TalkBack on the main flows
- Scrolling and transitions stay smooth (Perf Monitor), with no ANRs and no crashes

## 6. Submit

1. Fill in `eas.json → submit.production` (`ascAppId`, `appleTeamId`). For Google, create a
   Play service account and save its key at
   `apps/mobile/secrets/google-play-service-account.json`. This file is git-ignored.
2. `npx eas-cli submit --profile production --platform ios` (TestFlight), then
   `--platform android` (internal track, draft).
3. Store listing:
   - Copy text from `store/listing.md` and check lengths with `node store/check-listing.mjs`.
   - Screenshots are in `store/screenshots/app-store-6.9` and `store/screenshots/google-play-phone`.
   - The feature graphic and 1024 px icon are in `store/graphics`.
   - Regenerate screenshots after UI changes with `qa/store-screenshots.cjs`.
4. Privacy: answer App Privacy and Data safety from `store/privacy.md`.
5. Review information: create a dedicated reviewer account with some progress, and give
   the account details and the notes from `store/listing.md` to App Review and Play.
6. After internal testing passes, promote to external TestFlight or closed testing, then
   production with a staged rollout (Play: start at 10–20%).

## 7. After launch

- Watch Supabase logs, edge function errors and RevenueCat events.
- Use OTA updates (`eas update --channel production`) only for JS and asset fixes that
  comply with store rules. Native changes need a new build.
- Keep `content_complete` honest: set it per course only when the course is genuinely
  finished.
