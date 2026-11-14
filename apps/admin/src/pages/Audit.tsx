import { useQuery } from '@tanstack/react-query';

import { PageHead } from '../components/Layout';
import { Badge, Empty, Loading } from '../components/ui';
import { fmtDateTime } from '../lib/format';
import { must, supabase } from '../lib/supabase';

interface Entry { id: number; action: string; entity: string; entity_id: string | null; details: Record<string, string>; created_at: string; actor: { display_name: string | null } | null }

export function Audit() {
  const log = useQuery({ queryKey: ['audit'], queryFn: async () => must(await supabase.from('audit_log').select('id, action, entity, entity_id, details, created_at, actor:profiles!audit_log_actor_id_fkey(display_name)').order('created_at', { ascending: false }).limit(200)) as unknown as Entry[] });
  return (
    <>
      <PageHead title="Audit log" subtitle="Every content and permission change made through the API, newest first." />
      <div className="card flush">
        {log.isLoading ? <Loading /> : !log.data?.length ? <Empty title="No activity yet" /> : (
          <table className="table">
            <thead><tr><th>When</th><th>Who</th><th>Action</th><th>What</th></tr></thead>
            <tbody>
              {log.data.map((e) => (
                <tr key={e.id}>
                  <td className="muted small">{fmtDateTime(e.created_at)}</td>
                  <td>{e.actor?.display_name ?? '—'}</td>
                  <td><Badge tone={e.action === 'delete' ? 'danger' : e.action === 'insert' ? 'success' : 'info'}>{e.action}</Badge></td>
                  <td><span className="mono small faint">{e.entity}</span> {e.details?.title ?? ''} {e.details?.previous_status && <span className="small muted">({e.details.previous_status} → {e.details.status})</span>}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </>
  );
}
