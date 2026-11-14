import { useQuery, useQueryClient } from '@tanstack/react-query';
import { Crown, Search } from 'lucide-react';
import { useEffect, useState } from 'react';

import { PageHead } from '../components/Layout';
import { Badge, Button, Empty, Field, Input, Loading, Modal, useToast } from '../components/ui';
import { useAuth, type Role } from '../lib/auth';
import { fmtDate, fmtDateTime } from '../lib/format';
import { must, supabase } from '../lib/supabase';

interface UserRow { id: string; email: string; display_name: string | null; roles: Role[]; created_at: string; last_sign_in_at: string | null; is_premium: boolean; total_xp: number; enrollments: number }

export function Users() {
  const qc = useQueryClient();
  const toast = useToast();
  const { session } = useAuth();
  const [input, setInput] = useState('');
  const [q, setQ] = useState('');
  const [open, setOpen] = useState<UserRow | null>(null);
  const [days, setDays] = useState('30');
  useEffect(() => {
    const t = setTimeout(() => setQ(input.trim()), 300);
    return () => clearTimeout(t);
  }, [input]);
  const users = useQuery({ queryKey: ['users', q], queryFn: async () => must(await supabase.rpc('admin_list_users', { p_search: q || null, p_limit: 100, p_offset: 0 })) as UserRow[] });
  const refresh = () => qc.invalidateQueries({ queryKey: ['users'] });

  const toggleRole = async (u: UserRow, role: Role) => {
    const granted = !u.roles.includes(role);
    const { error } = await supabase.rpc('admin_set_role', { p_user_id: u.id, p_role: role, p_granted: granted });
    if (error) return toast('error', error.message.includes('last_admin') ? 'At least one admin must remain.' : error.message);
    const roles = granted ? [...u.roles, role] : u.roles.filter((r) => r !== role);
    setOpen({ ...u, roles });
    refresh();
  };

  return (
    <>
      <PageHead title="Users & roles" subtitle="Find learners, manage staff roles and grant complimentary Premium." />
      <div className="row" style={{ marginBottom: 16, maxWidth: 420 }}>
        <Search size={16} className="faint" />
        <Input placeholder="Search by email or name" value={input} onChange={(e) => setInput(e.target.value)} aria-label="Search users" />
      </div>
      <div className="card flush">
        {users.isLoading ? <Loading /> : !users.data?.length ? <Empty title="No users found" /> : (
          <table className="table">
            <thead><tr><th>User</th><th>Roles</th><th>Joined</th><th>Last sign-in</th><th>XP</th><th>Courses</th></tr></thead>
            <tbody>
              {users.data.map((u) => (
                <tr key={u.id} className="clickable" onClick={() => setOpen(u)}>
                  <td><div className="title">{u.display_name || '—'} {u.is_premium && <Crown size={13} style={{ color: 'var(--accent)', verticalAlign: -1 }} />}</div><div className="small faint">{u.email}</div></td>
                  <td><div className="pill-list">{u.roles.filter((r) => r !== 'student').map((r) => <Badge key={r} tone="accent">{r}</Badge>)}</div></td>
                  <td className="muted">{fmtDate(u.created_at)}</td>
                  <td className="muted">{fmtDateTime(u.last_sign_in_at)}</td>
                  <td>{u.total_xp}</td>
                  <td>{u.enrollments}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
      {open && (
        <Modal title={open.email} onClose={() => setOpen(null)}>
          <div className="stack">
            <div className="small faint mono">{open.id}</div>
            <div>
              <strong>Roles</strong>
              <div className="row wrap" style={{ marginTop: 8 }}>
                {(['instructor', 'editor', 'admin'] as Role[]).map((r) => (
                  <Button key={r} variant={open.roles.includes(r) ? 'primary' : 'outline'} size="sm" disabled={r === 'admin' && open.id === session?.user.id && open.roles.includes('admin')} onClick={() => toggleRole(open, r)}>
                    {open.roles.includes(r) ? '✓ ' : '+ '}{r}
                  </Button>
                ))}
              </div>
              <p className="small faint">Instructors draft their own courses; editors review and publish all content; admins also manage users, billing and settings.</p>
            </div>
            <div className="stack" style={{ gap: 8 }}>
              <strong>Complimentary Premium</strong>
              <p className="small muted" style={{ margin: 0 }}>{open.is_premium ? 'This user currently has Premium.' : 'For scholarships, partners or support goodwill. Store purchases are managed by Apple/Google.'}</p>
              <div className="row">
                <Field label="Days"><Input type="number" min={1} max={3650} value={days} onChange={(e) => setDays(e.target.value)} style={{ width: 120 }} /></Field>
                <Button icon={<Crown />} style={{ alignSelf: 'flex-end' }} onClick={async () => {
                  const { error } = await supabase.rpc('admin_grant_premium', { p_user_id: open.id, p_days: Number(days), p_note: 'Granted in Studio' });
                  if (error) return toast('error', error.message);
                  toast('success', `Premium granted for ${days} days`);
                  setOpen({ ...open, is_premium: true });
                  refresh();
                }}>Grant</Button>
              </div>
            </div>
          </div>
        </Modal>
      )}
    </>
  );
}
