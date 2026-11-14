# Privacy answers: App Store "App Privacy" and Google Play "Data safety"

These answers describe what this codebase actually does. Re-check them whenever you add an
SDK. Analytics, crash reporting and ads SDKs are **not** included, and adding one changes
these answers.

Data processed by service providers on our behalf (Supabase, RevenueCat, Expo push, and
the AI provider if the assistant is enabled) does not count as "sharing" under either
store's definition. It is listed in the Privacy Policy.

## App Store Connect → App Privacy

**Tracking:** *No.* We do not link data with third-party data for advertising, and we do
not share it with data brokers. No ATT prompt is needed.

None of the types below is used for tracking.

| Data type | Collected | Linked to user | Purposes |
| --- | --- | --- | --- |
| Contact Info → Name | Yes | Yes | App Functionality |
| Contact Info → Email Address | Yes | Yes | App Functionality |
| User Content → Photos or Videos | Yes, only if the learner uploads an avatar or assignment image | Yes | App Functionality |
| User Content → Other User Content | Yes: notes, assignment text, files and links, and assistant questions (when enabled) | Yes | App Functionality |
| Identifiers → User ID | Yes | Yes | App Functionality |
| Identifiers → Device ID | Yes: push notification token, only if notifications are allowed | Yes | App Functionality |
| Purchases → Purchase History | Yes: subscription status and expiry | Yes | App Functionality |
| Usage Data → Product Interaction | Yes: lessons opened and completed, time spent, quiz results | Yes | App Functionality, Product Personalization |
| Other Data | Yes: interests, goal, level, daily goal, timezone | Yes | Product Personalization |

Not collected: location, contacts, health, financial info (card details stay with
Apple), browsing history, search history (searches are not stored), sensitive info,
diagnostics, and advertising data.

Privacy Policy URL: `app_settings.support.privacy_url`. Set it to your published page.

## Google Play Console → Data safety

- **Does your app collect or share any of the required user data types?** Yes.
- **Is all of the user data collected by your app encrypted in transit?** Yes (TLS).
- **Do you provide a way for users to request that their data is deleted?** Yes. Users can
  delete their account in the app (Settings → Account → Delete account). Google Play also
  requires a **web link** where users can request deletion without the app. Publish a page
  at `[https://mahorat.app/delete-account]` that explains the in-app path and offers an
  email request route, and enter it in the console.

| Category → type | Collected | Shared | Optional? | Purposes |
| --- | --- | --- | --- | --- |
| Personal info → Name | Yes | No | Optional | App functionality, Account management |
| Personal info → Email address | Yes | No | Required | App functionality, Account management |
| Personal info → User IDs | Yes | No | Required | App functionality, Account management |
| Personal info → Other info (interests, goal, level) | Yes | No | Optional | Personalization |
| Financial info → Purchase history | Yes | No | Optional (subscribers only) | App functionality |
| Photos and videos → Photos | Yes | No | Optional | App functionality |
| Files and docs | Yes (assignment uploads) | No | Optional | App functionality |
| App activity → App interactions | Yes | No | Required | App functionality, Personalization |
| App activity → Other user-generated content (notes, assistant questions) | Yes | No | Optional | App functionality |
| Device or other IDs (push token) | Yes | No | Optional | App functionality |

Not collected: location, contacts, messages, audio, health and fitness, calendar, web
browsing, crash logs and diagnostics, and advertising ID. The Android manifest removes
`RECORD_AUDIO` and storage permissions and explicitly removes `com.google.android.gms.permission.AD_ID`
(`apps/mobile/app.config.ts → android.blockedPermissions`).

## Content rating and target audience

- **Apple age rating:** no objectionable content, no unrestricted web access and no
  user-to-user messaging, so the expected rating is **4+**.
- **Google Play target audience:** 13+ (the app is not designed for children). Do not
  select ages under 13 unless you complete the Families policy requirements.
