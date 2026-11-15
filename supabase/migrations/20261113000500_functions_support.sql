-- =============================================================================
-- Support for Edge Functions: store subscription events (RevenueCat webhook) and
-- a per-learner daily quota for the AI learning assistant.
-- =============================================================================

-- Applies one verified store event. Called only by the `revenuecat-webhook` edge
-- function with the service role; never callable from the apps.
create or replace function public.apply_store_subscription_event(
  p_user_id uuid,
  p_platform public.store_platform,
  p_status public.subscription_status,
  p_product_id text,
  p_original_transaction_id text,
  p_period_start timestamptz,
  p_period_end timestamptz,
  p_will_renew boolean,
  p_environment text,
  p_event jsonb
)
returns public.subscriptions language plpgsql security definer set search_path = '' as $$
declare
  v_sub public.subscriptions;
  v_plan uuid;
begin
  if not exists (select 1 from public.profiles where id = p_user_id) then
    raise exception 'unknown_user' using errcode = 'P0002';
  end if;
  select id into v_plan from public.subscription_plans
  where apple_product_id = p_product_id or google_product_id = p_product_id
     or google_product_id || ':' || coalesce(google_base_plan_id, '') = p_product_id
  limit 1;

  update public.subscriptions set
    user_id = p_user_id,
    plan_id = coalesce(v_plan, plan_id),
    status = p_status,
    product_id = coalesce(p_product_id, product_id),
    current_period_start = coalesce(p_period_start, current_period_start),
    current_period_end = p_period_end,
    will_renew = p_will_renew,
    environment = p_environment,
    last_event = p_event
  where platform = p_platform and original_transaction_id = p_original_transaction_id
  returning * into v_sub;

  if not found then
    insert into public.subscriptions (user_id, plan_id, platform, status, product_id, original_transaction_id,
      current_period_start, current_period_end, will_renew, environment, last_event)
    values (p_user_id, v_plan, p_platform, p_status, p_product_id, p_original_transaction_id,
      p_period_start, p_period_end, p_will_renew, p_environment, p_event)
    returning * into v_sub;
  end if;
  return v_sub;
end $$;

revoke execute on function public.apply_store_subscription_event(uuid, public.store_platform, public.subscription_status, text, text, timestamptz, timestamptz, boolean, text, jsonb)
  from public, anon, authenticated;
grant execute on function public.apply_store_subscription_event(uuid, public.store_platform, public.subscription_status, text, text, timestamptz, timestamptz, boolean, text, jsonb)
  to service_role;

-- Assistant usage quota ------------------------------------------------------------
create table public.assistant_usage (
  user_id uuid not null references public.profiles (id) on delete cascade,
  usage_date date not null,
  requests integer not null default 0,
  primary key (user_id, usage_date)
);
alter table public.assistant_usage enable row level security;
create policy "assistant usage: read own" on public.assistant_usage for select to authenticated
  using (user_id = (select auth.uid()));
revoke insert, update, delete on public.assistant_usage from anon, authenticated;

-- Atomically consumes one request from today's allowance. Returns false when the
-- assistant is disabled or the learner reached the daily limit.
create or replace function public.assistant_consume_quota()
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  v_user uuid := private.require_user();
  v_cfg jsonb := coalesce(private.setting('assistant'), '{}'::jsonb);
  v_limit integer := coalesce((v_cfg ->> 'daily_limit')::integer, 30);
  v_used integer;
begin
  if not coalesce((v_cfg ->> 'enabled')::boolean, false) then
    return false;
  end if;
  insert into public.assistant_usage as u (user_id, usage_date, requests)
  values (v_user, private.local_today(v_user), 1)
  on conflict (user_id, usage_date) do update set requests = u.requests + 1
  returning requests into v_used;
  return v_used <= v_limit;
end $$;

revoke execute on function public.assistant_consume_quota() from public, anon;
grant execute on function public.assistant_consume_quota() to authenticated;
