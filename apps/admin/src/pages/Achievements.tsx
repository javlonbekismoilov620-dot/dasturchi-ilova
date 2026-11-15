import { useQuery, useQueryClient } from '@tanstack/react-query';
import { Plus } from 'lucide-react';
import { useState } from 'react';

import { PageHead } from '../components/Layout';
import { Badge, Button, ConfirmButton, Field, Input, Loading, Modal, Select, Switch, useToast } from '../components/ui';
import { slugify } from '../lib/format';
import { must, supabase } from '../lib/supabase';

interface Achievement { id: string; slug: string; title: string; description: string; icon: string; tier: string; criteria: { metric: string; gte: number }; xp: number; position: number; is_active: boolean }
const METRICS = ['lessons_completed', 'courses_completed', 'enrollments', 'longest_streak', 'quizzes_passed', 'perfect_quizzes', 'total_xp', 'certificates', 'minutes_learned'];

export function Achievements() {
  const qc = useQueryClient();
  const toast = useToast();
  const [edit, setEdit] = useState<Partial<Achievement> | null>(null);
  const list = useQuery({ queryKey: ['achievements'], queryFn: async () => must(await supabase.from('achievements').select('*').order('position')) as Achievement[] });
  if (list.isLoading) return <Loading />;
  const save = async () => {
    if (!edit?.title?.trim() || !edit.description?.trim()) return;
    const row = { title: edit.title.trim(), slug: edit.slug || slugify(edit.title), description: edit.description.trim(), icon: edit.icon || 'award', tier: edit.tier ?? 'bronze', criteria: edit.criteria ?? { metric: 'lessons_completed', gte: 1 }, xp: edit.xp ?? 0, is_active: edit.is_active ?? true, position: edit.position ?? list.data?.length ?? 0 };
    const { error } = edit.id ? await supabase.from('achievements').update(row).eq('id', edit.id) : await supabase.from('achievements').insert(row);
    if (error) return toast('error', error.message);
    setEdit(null);
    qc.invalidateQueries({ queryKey: ['achievements'] });
  };
  return (
    <>
      <PageHead title="Achievements" subtitle="Awarded automatically by the learning engine when a learner reaches the threshold." actions={<Button variant="primary" icon={<Plus />} onClick={() => setEdit({ tier: 'bronze', criteria: { metric: 'lessons_completed', gte: 1 }, is_active: true })}>New achievement</Button>} />
      <div className="card flush">
        <table className="table">
          <thead><tr><th>Achievement</th><th>Rule</th><th>Tier</th><th>XP</th><th>Active</th></tr></thead>
          <tbody>
            {list.data?.map((a) => (
              <tr key={a.id} className="clickable" onClick={() => setEdit(a)}>
                <td><div className="title">{a.title}</div><div className="small faint">{a.description}</div></td>
                <td className="mono small">{a.criteria.metric} ≥ {a.criteria.gte}</td>
                <td><Badge tone="accent">{a.tier}</Badge></td>
                <td>{a.xp}</td>
                <td>{a.is_active ? 'Yes' : 'No'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {edit && (
        <Modal title={edit.id ? 'Edit achievement' : 'New achievement'} onClose={() => setEdit(null)} footer={<>
          {edit.id && <ConfirmButton onConfirm={async () => { await supabase.from('achievements').delete().eq('id', edit.id!); setEdit(null); qc.invalidateQueries({ queryKey: ['achievements'] }); }} />}
          <Button variant="primary" onClick={save}>Save</Button>
        </>}>
          <div className="stack">
            <Field label="Title"><Input value={edit.title ?? ''} onChange={(e) => setEdit({ ...edit, title: e.target.value })} /></Field>
            <Field label="Description"><Input value={edit.description ?? ''} onChange={(e) => setEdit({ ...edit, description: e.target.value })} /></Field>
            <div className="grid-2">
              <Field label="Metric"><Select value={edit.criteria?.metric} onChange={(e) => setEdit({ ...edit, criteria: { metric: e.target.value, gte: edit.criteria?.gte ?? 1 } })}>{METRICS.map((m) => <option key={m}>{m}</option>)}</Select></Field>
              <Field label="At least"><Input type="number" min={1} value={edit.criteria?.gte ?? 1} onChange={(e) => setEdit({ ...edit, criteria: { metric: edit.criteria?.metric ?? 'lessons_completed', gte: Number(e.target.value) } })} /></Field>
            </div>
            <div className="grid-2">
              <Field label="Tier"><Select value={edit.tier} onChange={(e) => setEdit({ ...edit, tier: e.target.value })}>{['bronze', 'silver', 'gold', 'platinum'].map((t) => <option key={t}>{t}</option>)}</Select></Field>
              <Field label="Bonus XP"><Input type="number" min={0} value={edit.xp ?? 0} onChange={(e) => setEdit({ ...edit, xp: Number(e.target.value) })} /></Field>
            </div>
            <Field label="Icon key" hint="e.g. award, flame, target, book-open"><Input value={edit.icon ?? 'award'} onChange={(e) => setEdit({ ...edit, icon: e.target.value })} /></Field>
            <Switch label="Active" checked={edit.is_active ?? true} onChange={(v) => setEdit({ ...edit, is_active: v })} />
          </div>
        </Modal>
      )}
    </>
  );
}
