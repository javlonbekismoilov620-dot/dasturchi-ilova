import { useQuery, useQueryClient } from '@tanstack/react-query';
import { Megaphone } from 'lucide-react';
import { useState } from 'react';

import { PageHead } from '../components/Layout';
import { Button, Empty, Field, Input, Loading, Textarea, useToast } from '../components/ui';
import { fmtDateTime } from '../lib/format';
import { must, supabase } from '../lib/supabase';

export function Announcements() {
  const qc = useQueryClient();
  const toast = useToast();
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const list = useQuery({ queryKey: ['broadcasts'], queryFn: async () => must(await supabase.from('notifications').select('id, title, body, created_at').is('user_id', null).order('created_at', { ascending: false }).limit(50)) as { id: string; title: string; body: string | null; created_at: string }[] });
  return (
    <>
      <PageHead title="Announcements" subtitle="Send an in-app notification to every learner." />
      <div className="grid-2" style={{ alignItems: 'start' }}>
        <div className="card stack">
          <Field label="Title"><Input value={title} maxLength={160} onChange={(e) => setTitle(e.target.value)} /></Field>
          <Field label="Message"><Textarea value={body} maxLength={2000} onChange={(e) => setBody(e.target.value)} /></Field>
          <Button variant="primary" icon={<Megaphone />} disabled={!title.trim()} onClick={async () => {
            const { error } = await supabase.rpc('admin_broadcast', { p_title: title.trim(), p_body: body.trim() || null, p_type: 'announcement', p_data: {} });
            if (error) return toast('error', error.message);
            toast('success', 'Announcement sent');
            setTitle('');
            setBody('');
            qc.invalidateQueries({ queryKey: ['broadcasts'] });
          }}>Send to everyone</Button>
        </div>
        <div className="card flush">
          {list.isLoading ? <Loading /> : !list.data?.length ? <Empty title="No announcements yet" /> : (
            <table className="table"><tbody>{list.data.map((n) => <tr key={n.id}><td><div className="title">{n.title}</div><div className="small muted">{n.body}</div></td><td className="small faint">{fmtDateTime(n.created_at)}</td></tr>)}</tbody></table>
          )}
        </div>
      </div>
    </>
  );
}
