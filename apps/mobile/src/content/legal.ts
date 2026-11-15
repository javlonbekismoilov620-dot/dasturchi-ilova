/**
 * Legal documents bundled with the app (also published at the URLs in app_settings.support).
 * They describe the data practices actually implemented in this codebase.
 *
 * BEFORE RELEASE: replace every [bracketed placeholder] and have both documents reviewed
 * by a qualified lawyer for each market you launch in (including Uzbekistan's Law
 * "On Personal Data" No. ZRU-547 and its data-localisation requirements).
 */
const privacy = `## Privacy Policy

**Last updated:** [Date of publication]

Mahorat ("we", "us") is operated by **[Company legal name]**, [registered address] ("the Operator"). This policy explains what we collect when you use the Mahorat mobile apps and website, why, and the choices you have.

### What we collect

**Account information.** Your email address and the name you provide, or the name and email shared by Sign in with Apple or Google when you choose those options. If you use Sign in with Apple with "Hide My Email", we receive a relay address only.

**Learning activity.** Courses you enrol in, lessons you open and complete, time spent learning, quiz answers and scores, notes, bookmarks, achievements, certificates, and work you submit for assignments (text, links and files).

**Preferences.** Language, interests, learning goal, experience level, daily goal and timezone — used to personalise recommendations and streaks.

**Purchases.** If you subscribe, Apple or Google processes the payment. We receive the subscription status, product and expiry date through our subscription provider. **We never receive or store your card details.**

**Notifications.** If you allow notifications, a push token for your device. Daily reminders you schedule stay on your device.

**We do not** show ads, sell personal data, use third-party advertising or tracking SDKs, or track you across other companies' apps and websites.

### Why we use it

- To provide the service: your account, progress, certificates and subscription access.
- To personalise course recommendations from your interests and learning history.
- To review assignments you submit and send you feedback.
- To keep the service secure, prevent abuse and fix problems.
- To meet legal obligations.

### Service providers

We use carefully selected processors that act on our instructions:

| Provider | Purpose |
| --- | --- |
| Supabase | Database, authentication and file storage (hosting region: [region]) |
| RevenueCat | Verifying App Store / Google Play subscriptions |
| Apple, Google | Sign-in, payments and push notification delivery |
| Expo | Delivering push notifications |
| [AI provider, only if the learning assistant is enabled] | Answering questions you send to the assistant, together with the text of the lesson you are viewing |

### Retention and deletion

We keep your data while your account is active. You can **delete your account at any time in the app** (Settings → Account → Delete account). This permanently removes your profile, progress, notes, certificates and submitted files. Subscriptions purchased through Apple or Google must be cancelled in your store account. Backups are overwritten within [30] days.

### Your rights

Depending on where you live, you may have the right to access, correct, export or delete your personal data, and to object to or restrict certain processing. Contact us at **[privacy email]** and we will respond within [30] days. You may also complain to your local data protection authority.

### Children

Mahorat is intended for learners aged **[13]** and over. If you believe a younger child has created an account, contact us and we will delete it.

### Security

Data is encrypted in transit (TLS). Sessions on your device are stored encrypted with a key kept in the operating system's secure keychain/keystore. Access to learner data on our servers is restricted by row-level security so each learner can only access their own records.

### Changes

We will notify you in the app before material changes take effect.

### Contact

[Company legal name] · [address] · **[privacy email]**
`;

const terms = `## Terms of Service

**Last updated:** [Date of publication]

These terms govern your use of Mahorat, operated by **[Company legal name]** ("we"). By creating an account or using the service you agree to them.

### 1. Your account

You must provide accurate information and keep your sign-in credentials secure. You are responsible for activity on your account. You may delete your account at any time in Settings.

### 2. Learning content

Courses, lessons, quizzes and other materials are licensed to you for personal, non-commercial learning. You may not copy, redistribute or resell them. Some courses are marked **In development**: their published lessons are complete, and further lessons are added after editorial review.

### 3. Certificates

Certificates confirm that you completed a Mahorat course and its final assessment. They are **not** academic degrees or state-accredited qualifications unless explicitly stated. Each certificate has a verification code; we may revoke certificates obtained dishonestly.

### 4. Premium subscriptions

- Subscriptions are purchased through the Apple App Store or Google Play and billed to that account.
- **Subscriptions renew automatically** unless cancelled at least 24 hours before the end of the current period. You can manage or cancel them in your App Store or Google Play account settings.
- Free trials, where offered, convert to a paid subscription unless cancelled before the trial ends.
- Refunds are handled by Apple or Google under their policies.
- Prices are shown in the app before purchase and may vary by country.

### 5. Your submissions

You keep ownership of work you submit. You grant us a limited licence to store it, show it to reviewers and give you feedback. Do not submit content you do not have the right to share, or that is unlawful, harmful or infringes others' rights.

### 6. Acceptable use

Do not attempt to access other users' data, interfere with the service, reverse-engineer it, scrape content, or use it to break the law.

### 7. Learning assistant

If available, AI-generated answers may be inaccurate. Verify important information independently.

### 8. Availability and changes

We work to keep Mahorat available and accurate, but the service is provided "as is". We may update features and content, and will notify you of material changes to these terms.

### 9. Liability

To the extent permitted by law, we are not liable for indirect or consequential losses. Nothing in these terms limits rights you have under mandatory consumer law.

### 10. Termination

We may suspend accounts that seriously or repeatedly breach these terms. You may stop using the service at any time.

### 11. Governing law

These terms are governed by the laws of **[jurisdiction]**, without prejudice to mandatory consumer protections in your country of residence.

### Contact

[Company legal name] · [address] · **[support email]**
`;

export const legalDocs = { privacy, terms } as const;
