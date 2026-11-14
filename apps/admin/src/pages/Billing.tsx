import { useQuery, useQueryClient } from '@tanstack/react-query';
import { Plus, Save } from 'lucide-react';
import { useEffect, useState } from 'react';

import { PageHead } from '../components/Layout';
import { Badge, Button, ConfirmButton, Field, Input, ListEditor, Loading, Modal, Select, Switch, useToast } from '../components/ui';
import { slugify } from '../lib/format';
import { must, supabase } from '../lib/supabase';

interface Plan { id: string; slug: string; title: string; description: string | null; features: string[]; interval: string; price_hint: string | null; trial_days: number; apple_product_id: string | null; google_product_id: string | null; google_base_plan_id: string | null; revenuecat_package_id: string | null; is_active: boolean; is_highlighted: boolean; position: number }
type Settings = Record<string, Record<string, unknown>>;

export function Billing() {
  const qc = useQueryClient();
  const toast = useToast();
  const [edit, setEdit] = useState<Partial<Plan> | null>(null);
  const plans = useQuery({ queryKey: ['plans'], queryFn: async () => must(await supabase.from('subscription_plans').select('*').order('position')) as Plan[] });
  const settings = useQuery({ queryKey: ['settings'], queryFn: async () => Object.fromEntries((must(await supabase.from('app_settings').select('key, value')) as { key: string; value: Record<string, unknown> }[]).map((r) => [r.key, r.value])) as Settings });
  const [s, setS] = useState<Settings | null>(null);
  useEffect(() => {
    if (settings.data) setS(settings.data);
  }, [settings.data]);
  if (plans.isLoading || !s) return <Loading />;

  const setKey = (key: string, patch: Record<string, unknown>) => setS({ ...s, [key]: { ...s[key], ...patch } });
  const saveSettings = async () => {
    for (const key of ['billing', 'certificates', 'free_tier', 'assistant', 'support']) {
      const { error } = await supabase.from('app_settings').update({ value: s[key] }).eq('key', key);
      if (error) return toast('error', `${key}: ${error.message}`);
    }
    toast('success', 'Settings saved — the apps pick them up on next refresh.');
    qc.invalidateQueries({ queryKey: ['settings'] });
  };
  const savePlan = async () => {
    if (!edit?.title?.trim() || !edit.interval) return;
    const row = { ...edit, slug: edit.slug || slugify(edit.title), title: edit.title.trim() };
    delete (row as Partial<Plan>).id;
    const { error } = edit.id ? await supabase.from('subscription_plans').update(row).eq('id', edit.id) : await supabase.from('subscription_plans').insert({ ...row, position: plans.data?.length ?? 0 });
    if (error) return toast('error', error.message);
    setEdit(null);
    qc.invalidateQueries({ queryKey: ['plans'] });
  };

  return (
    <>
      <PageHead title="Plans & settings" subtitle="Subscription plans and platform switches. Prices themselves are set in App Store Connect and Google Play Console." />
      <div className="grid-2" style={{ alignItems: 'start' }}>
        <div className="stack">
          <div className="row" style={{ justifyContent: 'space-between' }}><h3>Plans</h3><Button size="sm" icon={<Plus />} onClick={() => setEdit({ interval: 'month', features: [], is_active: true, trial_days: 0 })}>New plan</Button></div>
          {plans.data?.map((p) => (
            <button key={p.id} className="card stack" style={{ textAlign: 'left', color: 'inherit', font: 'inherit', cursor: 'pointer' }} onClick={() => setEdit(p)}>
              <div className="row"><strong className="grow">{p.title}</strong>{p.is_highlighted && <Badge tone="accent">highlighted</Badge>}{!p.is_active && <Badge tone="danger">inactive</Badge>}</div>
              <span className="small muted mono">iOS {p.apple_product_id ?? '—'} · Android {p.google_product_id ?? '—'}{p.google_base_plan_id ? `:${p.google_base_plan_id}` : ''} · RC {p.revenuecat_package_id ?? '—'}</span>
              <span className="small faint">{p.interval}{p.trial_days ? ` · ${p.trial_days}-day trial` : ''}</span>
            </button>
          ))}
        </div>
        <div className="card stack">
          <h3 style={{ margin: 0 }}>Platform settings</h3>
          <Field label="Access model">
            <Select value={String(s.billing?.mode ?? 'subscriptions')} onChange={(e) => setKey('billing', { mode: e.target.value })}>
              <option value="subscriptions">Free + Premium subscriptions</option>
              <option value="free_for_all">Everything free (e.g. launch period)</option>
            </Select>
          </Field>
          <Switch label="Show paywall in the apps" checked={!!s.billing?.paywall_enabled} onChange={(v) => setKey('billing', { paywall_enabled: v })} />
          <Switch label="Certificates require Premium" checked={!!s.certificates?.require_premium} onChange={(v) => setKey('certificates', { require_premium: v })} />
          <Field label="Free accounts: max learning paths"><Input type="number" min={0} value={Number(s.free_tier?.max_learning_paths ?? 2)} onChange={(e) => setKey('free_tier', { max_learning_paths: Number(e.target.value) })} /></Field>
          <hr style={{ border: 0, borderTop: '1px solid var(--border)', width: '100%' }} />
          <Switch label="Learning assistant enabled" checked={!!s.assistant?.enabled} onChange={(v) => setKey('assistant', { enabled: v })} />
          <Field label="Assistant requests per learner per day" hint="Also requires the ANTHROPIC_API_KEY secret on the assistant edge function."><Input type="number" min={1} value={Number(s.assistant?.daily_limit ?? 30)} onChange={(e) => setKey('assistant', { daily_limit: Number(e.target.value) })} /></Field>
          <hr style={{ border: 0, borderTop: '1px solid var(--border)', width: '100%' }} />
          <Field label="Support email"><Input value={String(s.support?.email ?? '')} onChange={(e) => setKey('support', { email: e.target.value })} /></Field>
          <Field label="Privacy policy URL"><Input value={String(s.support?.privacy_url ?? '')} onChange={(e) => setKey('support', { privacy_url: e.target.value })} /></Field>
          <Field label="Terms of service URL"><Input value={String(s.support?.terms_url ?? '')} onChange={(e) => setKey('support', { terms_url: e.target.value })} /></Field>
          <Button variant="primary" icon={<Save />} onClick={saveSettings} data-testid="save-settings">Save settings</Button>
        </div>
      </div>
      {edit && (
        <Modal title={edit.id ? 'Edit plan' : 'New plan'} onClose={() => setEdit(null)} footer={<>
          {edit.id && <ConfirmButton onConfirm={async () => { const { error } = await supabase.from('subscription_plans').delete().eq('id', edit.id!); if (error) toast('error', 'Plan is referenced by subscriptions — deactivate it instead.'); setEdit(null); qc.invalidateQueries({ queryKey: ['plans'] }); }} />}
          <Button variant="primary" onClick={savePlan}>Save plan</Button>
        </>}>
          <div className="stack">
            <Field label="Title"><Input value={edit.title ?? ''} onChange={(e) => setEdit({ ...edit, title: e.target.value })} /></Field>
            <Field label="Description"><Input value={edit.description ?? ''} onChange={(e) => setEdit({ ...edit, description: e.target.value })} /></Field>
            <div className="grid-2">
              <Field label="Billing interval"><Select value={edit.interval} onChange={(e) => setEdit({ ...edit, interval: e.target.value })}><option value="month">Monthly</option><option value="year">Yearly</option><option value="lifetime">Lifetime</option></Select></Field>
              <Field label="Trial days"><Input type="number" min={0} max={90} value={edit.trial_days ?? 0} onChange={(e) => setEdit({ ...edit, trial_days: Number(e.target.value) })} /></Field>
            </div>
            <Field label="App Store product ID"><Input className="mono" value={edit.apple_product_id ?? ''} onChange={(e) => setEdit({ ...edit, apple_product_id: e.target.value || null })} /></Field>
            <div className="grid-2">
              <Field label="Google Play product ID"><Input className="mono" value={edit.google_product_id ?? ''} onChange={(e) => setEdit({ ...edit, google_product_id: e.target.value || null })} /></Field>
              <Field label="Google base plan ID"><Input className="mono" value={edit.google_base_plan_id ?? ''} onChange={(e) => setEdit({ ...edit, google_base_plan_id: e.target.value || null })} /></Field>
            </div>
            <Field label="RevenueCat package ID" hint="e.g. $rc_monthly, $rc_annual"><Input className="mono" value={edit.revenuecat_package_id ?? ''} onChange={(e) => setEdit({ ...edit, revenuecat_package_id: e.target.value || null })} /></Field>
            <Field label="Features shown on the paywall"><ListEditor value={edit.features ?? []} onChange={(v) => setEdit({ ...edit, features: v })} placeholder="Add a feature" /></Field>
            <Switch label="Active" checked={edit.is_active ?? true} onChange={(v) => setEdit({ ...edit, is_active: v })} />
            <Switch label="Highlight as best value" checked={!!edit.is_highlighted} onChange={(v) => setEdit({ ...edit, is_highlighted: v })} />
          </div>
        </Modal>
      )}
    </>
  );
}
