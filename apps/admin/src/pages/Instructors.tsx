import { useQuery, useQueryClient } from '@tanstack/react-query';
import { BadgeCheck, Plus } from 'lucide-react';
import { useState } from 'react';

import { PageHead } from '../components/Layout';
import { Button, ConfirmButton, Field, Input, Loading, Modal, Switch, Textarea, useToast } from '../components/ui';
import { slugify } from '../lib/format';
import { must, supabase } from '../lib/supabase';

interface Instructor { id: string; slug: string; name: string; headline: string | null; bio: string | null; website_url: string | null; is_verified: boolean; profile_id: string | null }

export function Instructors() {
  const qc = useQueryClient();
  const toast = useToast();
  const [edit, setEdit] = useState<Partial<Instructor> | null>(null);
  const list = useQuery({ queryKey: ['instructors-full'], queryFn: async () => must(await supabase.from('instructors').select('*').order('name')) as Instructor[] });
  if (list.isLoading) return <Loading />;
  const save = async () => {
    if (!edit?.name?.trim()) return;
    if (edit.profile_id && !/^[0-9a-f-]{36}$/i.test(edit.profile_id)) return toast('error', 'Account ID must be a user UUID (see Users & roles).');
    const row = { name: edit.name.trim(), slug: edit.slug || slugify(edit.name), headline: edit.headline || null, bio: edit.bio || null, website_url: edit.website_url || null, is_verified: !!edit.is_verified, profile_id: edit.profile_id || null };
    const { error } = edit.id ? await supabase.from('instructors').update(row).eq('id', edit.id) : await supabase.from('instructors').insert(row);
    if (error) return toast('error', error.message);
    toast('success', 'Instructor saved');
    setEdit(null);
    qc.invalidateQueries({ queryKey: ['instructors-full'] });
    qc.invalidateQueries({ queryKey: ['instructors'] });
  };
  return (
    <>
      <PageHead title="Instructors" subtitle="People credited on courses. Link an account so the instructor can draft their own courses." actions={<Button variant="primary" icon={<Plus />} onClick={() => setEdit({})}>New instructor</Button>} />
      <div className="card flush">
        <table className="table">
          <thead><tr><th>Name</th><th>Headline</th><th>Account</th><th /></tr></thead>
          <tbody>
            {list.data?.map((i) => (
              <tr key={i.id} className="clickable" onClick={() => setEdit(i)}>
                <td className="title">{i.name} {i.is_verified && <BadgeCheck size={14} style={{ color: 'var(--accent)', verticalAlign: -2 }} />}</td>
                <td className="muted">{i.headline}</td>
                <td className="mono small faint">{i.profile_id ? `${i.profile_id.slice(0, 8)}…` : '—'}</td>
                <td />
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {edit && (
        <Modal title={edit.id ? 'Edit instructor' : 'New instructor'} onClose={() => setEdit(null)} footer={<>
          {edit.id && <ConfirmButton onConfirm={async () => { await supabase.from('instructors').delete().eq('id', edit.id!); setEdit(null); qc.invalidateQueries({ queryKey: ['instructors-full'] }); }} />}
          <Button variant="primary" onClick={save}>Save</Button>
        </>}>
          <div className="stack">
            <Field label="Name"><Input value={edit.name ?? ''} onChange={(e) => setEdit({ ...edit, name: e.target.value })} autoFocus /></Field>
            <Field label="Headline"><Input value={edit.headline ?? ''} onChange={(e) => setEdit({ ...edit, headline: e.target.value })} /></Field>
            <Field label="Bio"><Textarea value={edit.bio ?? ''} onChange={(e) => setEdit({ ...edit, bio: e.target.value })} /></Field>
            <Field label="Website"><Input value={edit.website_url ?? ''} placeholder="https://" onChange={(e) => setEdit({ ...edit, website_url: e.target.value })} /></Field>
            <Field label="Linked account (user ID)" hint="Also grant the “instructor” role in Users & roles."><Input value={edit.profile_id ?? ''} onChange={(e) => setEdit({ ...edit, profile_id: e.target.value.trim() })} className="mono" /></Field>
            <Switch label="Verified expert" checked={!!edit.is_verified} onChange={(v) => setEdit({ ...edit, is_verified: v })} />
          </div>
        </Modal>
      )}
    </>
  );
}
