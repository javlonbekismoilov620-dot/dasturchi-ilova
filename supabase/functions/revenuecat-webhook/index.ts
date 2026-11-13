// RevenueCat → Mahorat subscription sync.
// RevenueCat validates App Store / Google Play receipts and posts lifecycle events here.
// Configure the webhook in RevenueCat with header  Authorization: Bearer <REVENUECAT_WEBHOOK_SECRET>.
// The app identifies purchasers with Purchases.logIn(<supabase user id>), so
// event.app_user_id is our profile id. Entitlement checks read the resulting rows.
import { adminClient, env, json, safeEqual } from '../_shared/http.ts';

type RcEvent = {
  type: string;
  app_user_id?: string;
  original_app_user_id?: string;
  aliases?: string[];
  product_id?: string;
  store?: string;
  environment?: string;
  original_transaction_id?: string;
  transaction_id?: string;
  purchased_at_ms?: number | null;
  expiration_at_ms?: number | null;
  grace_period_expiration_at_ms?: number | null;
  cancel_reason?: string | null;
  entitlement_ids?: string[] | null;
};

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function platformFor(store?: string) {
  switch (store) {
    case 'APP_STORE':
    case 'MAC_APP_STORE':
      return 'app_store';
    case 'PLAY_STORE':
      return 'play_store';
    case 'STRIPE':
      return 'stripe';
    case 'PROMOTIONAL':
      return 'promotional';
    default:
      return 'manual';
  }
}

/** Maps a RevenueCat event to our subscription status and renewal flag. */
export function statusFor(e: RcEvent, now = Date.now()): { status: string; willRenew: boolean } | null {
  switch (e.type) {
    case 'INITIAL_PURCHASE':
    case 'RENEWAL':
    case 'UNCANCELLATION':
    case 'PRODUCT_CHANGE':
    case 'SUBSCRIPTION_EXTENDED':
    case 'TEMPORARY_ENTITLEMENT_GRANT':
      return { status: 'active', willRenew: true };
    case 'NON_RENEWING_PURCHASE':
      return { status: 'active', willRenew: false };
    case 'CANCELLATION':
      // Auto-renew turned off: access continues until expiration. Refunds end it now.
      return { status: e.cancel_reason === 'CUSTOMER_SUPPORT' ? 'refunded' : 'cancelled', willRenew: false };
    case 'BILLING_ISSUE':
      return { status: e.grace_period_expiration_at_ms && e.grace_period_expiration_at_ms > now ? 'in_grace_period' : 'in_billing_retry', willRenew: true };
    case 'SUBSCRIPTION_PAUSED':
      return { status: 'paused', willRenew: true };
    case 'EXPIRATION':
      return { status: 'expired', willRenew: false };
    default:
      return null; // TEST, TRANSFER and informational events need no row change
  }
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);
  const auth = (req.headers.get('Authorization') ?? '').replace(/^Bearer\s+/i, '');
  if (!safeEqual(auth, env('REVENUECAT_WEBHOOK_SECRET'))) return json({ error: 'unauthorized' }, 401);

  let event: RcEvent;
  try {
    event = ((await req.json()) as { event: RcEvent }).event;
  } catch {
    return json({ error: 'invalid_json' }, 400);
  }
  if (!event?.type) return json({ error: 'invalid_event' }, 400);

  const mapped = statusFor(event);
  if (!mapped) return json({ ok: true, ignored: event.type });

  // Anonymous RevenueCat ids ($RCAnonymousID:…) can't be linked to an account.
  const userId = [event.app_user_id, event.original_app_user_id, ...(event.aliases ?? [])].find((id) => id && UUID.test(id));
  if (!userId) return json({ ok: true, ignored: 'anonymous_user' });

  const now = new Date().toISOString();
  const periodEnd =
    mapped.status === 'refunded' ? now : event.expiration_at_ms ? new Date(event.expiration_at_ms).toISOString() : null;

  const { data, error } = await adminClient().rpc('apply_store_subscription_event', {
    p_user_id: userId,
    p_platform: platformFor(event.store),
    p_status: mapped.status,
    p_product_id: event.product_id ?? null,
    p_original_transaction_id: event.original_transaction_id ?? event.transaction_id ?? `rc:${userId}:${event.product_id}`,
    p_period_start: event.purchased_at_ms ? new Date(event.purchased_at_ms).toISOString() : null,
    p_period_end: periodEnd,
    p_will_renew: mapped.willRenew,
    p_environment: event.environment === 'SANDBOX' ? 'sandbox' : 'production',
    p_event: event,
  });
  if (error) {
    console.error('apply_store_subscription_event failed', error.message);
    // 5xx makes RevenueCat retry with backoff.
    return json({ error: 'apply_failed' }, error.message.includes('unknown_user') ? 200 : 500);
  }
  return json({ ok: true, subscription_id: (data as { id: string }).id, status: mapped.status });
});
