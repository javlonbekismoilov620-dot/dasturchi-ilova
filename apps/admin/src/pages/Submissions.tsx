import { useQuery, useQueryClient } from '@tanstack/react-query';
import { ExternalLink, FileDown } from 'lucide-react';
import { useState } from 'react';

import { PageHead } from '../components/Layout';
import { Button, Empty, Field, Input, Loading, Modal, Select, StatusBadge, Textarea, useToast } from '../components/ui';
import { fmtDateTime } from '../lib/format';
import { renderMarkdown } from '../lib/markdown';
import { must, supabase } from '../lib/supabase';

interface Sub {
  id: string; body_md: string | null; url: string | null; file_paths: string[]; status: string; score: number | null; feedback_md: string | null; submitted_at: string; user_id: string;
  assignment: { title: string; max_score: number; rubric_md: string | null; course: { title: string } | null } | null;
}

export function Submissions() {
  const qc = useQueryClient();
  const toast = useToast();
  const [filter, setFilter] = useState('pending');
  const [open, setOpen] = useState<Sub | null>(null);
  const [score, setScore] = useState('');
  const [feedback, setFeedback] = useState('');
  const subs = useQuery({
    queryKey: ['submissions', filter],
    queryFn: async () => {
      let q = supabase.from('submissions').select('*, assignment:assignments(title, max_score, rubric_md, course:courses(title))').order('submitted_at', { ascending: filter === 'pending' });
      if (filter === 'pending') q = q.in('status', ['submitted', 'in_review']);
      else if (filter !== 'all') q = q.eq('status', filter);
      return must(await q.limit(200)) as unknown as Sub[];
    },
  });

  const review = async (status: 'approved' | 'changes_requested') => {
    if (!open) return;
    const s = score === '' ? null : Number(score);
    if (s !== null && (Number.isNaN(s) || s < 0 || s > (open.assignment?.max_score ?? 100))) return toast('error', 'Score is out of range.');
    const { error } = await supabase.from('submissions').update({ status, score: s, feedback_md: feedback || null }).eq('id', open.id);
    if (error) return toast('error', error.message);
    toast('success', status === 'approved' ? 'Approved' : 'Changes requested');
    setOpen(null);
    qc.invalidateQueries({ queryKey: ['submissions'] });
  };
  const fileUrl = async (path: string) => {
    const { data, error } = await supabase.storage.from('submissions').createSignedUrl(path, 300);
    if (error) return toast('error', error.message);
    window.open(data.signedUrl, '_blank', 'noopener');
  };

  return (
    <>
      <PageHead title="Submissions" subtitle="Review assignments and projects. Learners see your score and feedback in the app." actions={
        <Select value={filter} onChange={(e) => setFilter(e.target.value)} style={{ width: 200 }} aria-label="Filter">
          <option value="pending">Awaiting review</option><option value="approved">Approved</option><option value="changes_requested">Changes requested</option><option value="all">All</option>
        </Select>} />
      <div className="card flush">
        {subs.isLoading ? <Loading /> : !subs.data?.length ? <Empty title="Nothing to review" body="New submissions will appear here." /> : (
          <table className="table">
            <thead><tr><th>Assignment</th><th>Course</th><th>Submitted</th><th>Status</th><th>Score</th></tr></thead>
            <tbody>
              {subs.data.map((s) => (
                <tr key={s.id} className="clickable" onClick={() => { setOpen(s); setScore(s.score?.toString() ?? ''); setFeedback(s.feedback_md ?? ''); }}>
                  <td className="title">{s.assignment?.title}</td>
                  <td className="muted">{s.assignment?.course?.title}</td>
                  <td className="muted">{fmtDateTime(s.submitted_at)}</td>
                  <td><StatusBadge status={s.status} /></td>
                  <td>{s.score ?? '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
      {open && (
        <Modal wide title={open.assignment?.title ?? 'Submission'} onClose={() => setOpen(null)} footer={<>
          <Button onClick={() => review('changes_requested')}>Request changes</Button>
          <Button variant="primary" onClick={() => review('approved')} data-testid="approve">Approve</Button>
        </>}>
          <div className="grid-2" style={{ alignItems: 'start' }}>
            <div className="stack">
              {open.body_md && <pre className="card mono small" style={{ whiteSpace: 'pre-wrap', margin: 0, maxHeight: 360, overflow: 'auto' }}>{open.body_md}</pre>}
              {open.url && <a className="btn outline" href={open.url} target="_blank" rel="noopener noreferrer"><ExternalLink /> Open submitted link</a>}
              {open.file_paths.map((p) => <Button key={p} icon={<FileDown />} onClick={() => fileUrl(p)}>{p.split('/').pop()}</Button>)}
            </div>
            <div className="stack">
              {open.assignment?.rubric_md && <div className="card prose small" dangerouslySetInnerHTML={{ __html: renderMarkdown(open.assignment.rubric_md) }} />}
              <Field label={`Score (0–${open.assignment?.max_score ?? 100})`}><Input type="number" value={score} onChange={(e) => setScore(e.target.value)} /></Field>
              <Field label="Feedback (Markdown)"><Textarea value={feedback} onChange={(e) => setFeedback(e.target.value)} rows={6} /></Field>
            </div>
          </div>
        </Modal>
      )}
    </>
  );
}
