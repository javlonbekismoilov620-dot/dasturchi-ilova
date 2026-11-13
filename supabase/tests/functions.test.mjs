// Edge function tests against the local stack (functions are served by `supabase start`).
// Requires supabase/functions/.env with REVENUECAT_WEBHOOK_SECRET=local-test-webhook-secret.
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { execSync } from 'node:child_process';
import { createClient } from '@supabase/supabase-js';

const status = JSON.parse(execSync('npx supabase status -o json', { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }));
const URL = status.API_URL;
const opts = { auth: { persistSession: false, autoRefreshToken: false } };
const admin = createClient(URL, status.SERVICE_ROLE_KEY, opts);
const SECRET = 'local-test-webhook-secret';
const run = Date.now().toString(36);

async function makeUser(label) {
  const email = `${label}-${run}@test.mahorat.local`;
  const { data, error } = await admin.auth.admin.createUser({ email, password: 'Test-pass-2026', email_confirm: true });
  assert.ifError(error);
  const client = createClient(URL, status.ANON_KEY, opts);
  const { data: s } = await client.auth.signInWithPassword({ email, password: 'Test-pass-2026' });
  return { id: data.user.id, client, token: s.session.access_token };
}

const webhook = (event, secret = SECRET) =>
  fetch(`${URL}/functions/v1/revenuecat-webhook`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${secret}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ api_version: '1.0', event }),
  });

before(async () => {
  // Warm the edge runtime (first invocation compiles the function).
  await fetch(`${URL}/functions/v1/revenuecat-webhook`, { method: 'POST', body: '{}' }).catch(() => {});
});

test('revenuecat webhook: rejects bad secret', async () => {
  const res = await webhook({ type: 'TEST' }, 'wrong');
  assert.equal(res.status, 401);
});

test('revenuecat webhook: purchase → premium → cancellation → expiration', async () => {
  const u = await makeUser('buyer');
  const base = {
    app_user_id: u.id,
    product_id: 'uz.mahorat.premium.yearly',
    store: 'APP_STORE',
    environment: 'SANDBOX',
    original_transaction_id: `txn-${run}`,
    purchased_at_ms: Date.now(),
    expiration_at_ms: Date.now() + 365 * 864e5,
  };
  let res = await webhook({ ...base, type: 'INITIAL_PURCHASE' });
  assert.equal(res.status, 200, await res.clone().text());
  let { data: ent } = await u.client.rpc('my_entitlements');
  assert.equal(ent.is_premium, true);
  assert.equal(ent.subscription.platform, 'app_store');

  const { data: subs } = await admin.from('subscriptions').select('plan_id, status, environment').eq('user_id', u.id);
  assert.equal(subs.length, 1);
  assert.ok(subs[0].plan_id, 'product mapped to plan');
  assert.equal(subs[0].environment, 'sandbox');

  res = await webhook({ ...base, type: 'CANCELLATION', cancel_reason: 'UNSUBSCRIBE' });
  assert.equal(res.status, 200);
  ({ data: ent } = await u.client.rpc('my_entitlements'));
  assert.equal(ent.is_premium, true, 'cancelled subscriptions keep access until expiry');
  assert.equal(ent.subscription.will_renew, false);

  res = await webhook({ ...base, type: 'EXPIRATION', expiration_at_ms: Date.now() - 1000 });
  assert.equal(res.status, 200);
  ({ data: ent } = await u.client.rpc('my_entitlements'));
  assert.equal(ent.is_premium, false);
  const { data: after } = await admin.from('subscriptions').select('id').eq('user_id', u.id);
  assert.equal(after.length, 1, 'events update one row per original transaction');
});

test('revenuecat webhook: refunds end access immediately; anonymous ids are ignored', async () => {
  const u = await makeUser('refund');
  const base = { app_user_id: u.id, product_id: 'uz.mahorat.premium.monthly', store: 'PLAY_STORE', original_transaction_id: `gpa-${run}`, expiration_at_ms: Date.now() + 30 * 864e5 };
  await webhook({ ...base, type: 'INITIAL_PURCHASE' });
  await webhook({ ...base, type: 'CANCELLATION', cancel_reason: 'CUSTOMER_SUPPORT' });
  const { data: ent } = await u.client.rpc('my_entitlements');
  assert.equal(ent.is_premium, false);
  const res = await webhook({ ...base, app_user_id: '$RCAnonymousID:abc', original_app_user_id: '$RCAnonymousID:abc', type: 'INITIAL_PURCHASE' });
  assert.equal((await res.json()).ignored, 'anonymous_user');
});

test('store events cannot be applied by app users', async () => {
  const u = await makeUser('forger');
  const { error } = await u.client.rpc('apply_store_subscription_event', {
    p_user_id: u.id, p_platform: 'app_store', p_status: 'active', p_product_id: 'x', p_original_transaction_id: 'x',
    p_period_start: null, p_period_end: null, p_will_renew: true, p_environment: 'production', p_event: {},
  });
  assert.ok(error, 'RPC is service-role only');
});

test('assistant: honest "not configured" without a provider key; quota respects admin switch', async () => {
  const u = await makeUser('asker');
  const res = await fetch(`${URL}/functions/v1/assistant`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${u.token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ messages: [{ role: 'user', content: 'What is HTML?' }] }),
  });
  assert.equal(res.status, 501);
  assert.equal((await res.json()).error, 'not_configured');
  const { data: allowed } = await u.client.rpc('assistant_consume_quota');
  assert.equal(allowed, false, 'disabled by default in app_settings');
  const unauth = await fetch(`${URL}/functions/v1/assistant`, { method: 'POST', body: '{}' });
  assert.equal(unauth.status, 401);
});

test('delete-account: removes files, auth user and all learner data', async () => {
  const u = await makeUser('leaver');
  await u.client.storage.from('avatars').upload(`${u.id}/me.png`, new Blob([Buffer.from('89504e47', 'hex')], { type: 'image/png' }));
  const { data: lesson } = await admin.from('lessons').select('id').eq('title', 'What is a computer?').single();
  await u.client.rpc('record_lesson_progress', { p_lesson_id: lesson.id, p_completed: true });
  const res = await fetch(`${URL}/functions/v1/delete-account`, { method: 'POST', headers: { Authorization: `Bearer ${u.token}` } });
  assert.equal(res.status, 200, await res.clone().text());
  const { data: authUser } = await admin.auth.admin.getUserById(u.id);
  assert.equal(authUser.user, null);
  for (const table of ['profiles', 'enrollments', 'lesson_progress', 'user_achievements', 'daily_activity']) {
    const { data } = await admin.from(table).select('*').eq(table === 'profiles' ? 'id' : 'user_id', u.id);
    assert.equal(data.length, 0, `${table} cleared`);
  }
  const { data: files } = await admin.storage.from('avatars').list(u.id);
  assert.equal(files.length, 0);
  const again = await fetch(`${URL}/functions/v1/delete-account`, { method: 'POST', headers: { Authorization: `Bearer ${u.token}` } });
  assert.equal(again.status, 401, 'token of a deleted user is rejected');
});
