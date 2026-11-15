import { useQuery, useQueryClient } from '@tanstack/react-query';
import { ArrowDown, ArrowUp, Plus } from 'lucide-react';
import { useState } from 'react';

import { CoverArt, type Pattern } from '../components/CoverArt';
import { PageHead } from '../components/Layout';
import { Badge, Button, ConfirmButton, Field, Input, Loading, Modal, Select, StatusBadge, Switch, Textarea, useToast } from '../components/ui';
import { LEVELS, PATTERNS, slugify, STATUSES } from '../lib/format';
import { must, supabase } from '../lib/supabase';

interface PathRow {
  id: string; slug: string; title: string; subtitle: string | null; description: string | null; level_from: string; level_to: string; access_tier: string; status: string; is_featured: boolean; position: number;
  cover_style: { pattern?: Pattern; hue?: number };
  learning_path_courses: { course_id: string; position: number; course: { title: string; status: string } | null }[];
}

export function Paths() {
  const qc = useQueryClient();
  const toast = useToast();
  const [edit, setEdit] = useState<Partial<PathRow> | null>(null);
  const [addCourse, setAddCourse] = useState('');
  const paths = useQuery({ queryKey: ['paths'], queryFn: async () => must(await supabase.from('learning_paths').select('*, learning_path_courses(course_id, position, course:courses(title, status))').order('position')) as unknown as PathRow[] });
  const courses = useQuery({ queryKey: ['course-options'], queryFn: async () => must(await supabase.from('courses').select('id, title').order('title')) as { id: string; title: string }[] });
  const refresh = () => qc.invalidateQueries({ queryKey: ['paths'] });
  if (paths.isLoading) return <Loading />;
  const current = edit?.id ? paths.data?.find((p) => p.id === edit.id) : null;
  const items = [...(current?.learning_path_courses ?? [])].sort((a, b) => a.position - b.position);

  const save = async () => {
    if (!edit?.title?.trim()) return;
    const row = { title: edit.title.trim(), slug: edit.slug || slugify(edit.title), subtitle: edit.subtitle || null, description: edit.description || null, level_from: edit.level_from ?? 'zero', level_to: edit.level_to ?? 'professional', access_tier: edit.access_tier ?? 'free', status: edit.status ?? 'draft', is_featured: !!edit.is_featured, cover_style: edit.cover_style ?? { pattern: 'grid', hue: 38 } };
    const res = edit.id ? await supabase.from('learning_paths').update(row).eq('id', edit.id).select('*').single() : await supabase.from('learning_paths').insert({ ...row, position: paths.data?.length ?? 0 }).select('*').single();
    if (res.error) return toast('error', res.error.message);
    toast('success', 'Path saved');
    setEdit({ ...edit, ...res.data });
    refresh();
  };
  const reorder = async (from: number, to: number) => {
    const order = [...items];
    const [x] = order.splice(from, 1);
    order.splice(to, 0, x);
    await Promise.all(order.map((it, pos) => supabase.from('learning_path_courses').update({ position: pos }).eq('path_id', current!.id).eq('course_id', it.course_id)));
    refresh();
  };

  return (
    <>
      <PageHead title="Learning paths" subtitle="Ordered journeys across courses, from zero to professional." actions={<Button variant="primary" icon={<Plus />} onClick={() => setEdit({ status: 'draft', level_from: 'zero', level_to: 'professional', access_tier: 'free', cover_style: { pattern: 'grid', hue: 38 } })}>New path</Button>} />
      <div className="grid-3">
        {paths.data?.map((p) => (
          <button key={p.id} className="card stack" style={{ textAlign: 'left', cursor: 'pointer', color: 'inherit', font: 'inherit' }} onClick={() => setEdit(p)}>
            <CoverArt pattern={p.cover_style?.pattern} hue={p.cover_style?.hue} width={320} />
            <div className="row"><strong className="grow">{p.title}</strong><StatusBadge status={p.status} /></div>
            <span className="small muted">{p.level_from} → {p.level_to} · {p.learning_path_courses.length} courses {p.access_tier === 'premium' && '· premium'}</span>
          </button>
        ))}
      </div>
      {edit && (
        <Modal wide title={edit.id ? edit.title ?? 'Path' : 'New path'} onClose={() => setEdit(null)} footer={<>
          {edit.id && <ConfirmButton onConfirm={async () => { await supabase.from('learning_paths').delete().eq('id', edit.id!); setEdit(null); refresh(); }} />}
          <Button variant="primary" onClick={save}>Save path</Button>
        </>}>
          <div className="grid-2">
            <div className="stack">
              <Field label="Title"><Input value={edit.title ?? ''} onChange={(e) => setEdit({ ...edit, title: e.target.value })} /></Field>
              <Field label="Subtitle"><Input value={edit.subtitle ?? ''} onChange={(e) => setEdit({ ...edit, subtitle: e.target.value })} /></Field>
              <Field label="Description"><Textarea value={edit.description ?? ''} onChange={(e) => setEdit({ ...edit, description: e.target.value })} /></Field>
              <div className="grid-2">
                <Field label="From level"><Select value={edit.level_from} onChange={(e) => setEdit({ ...edit, level_from: e.target.value })}>{LEVELS.map((l) => <option key={l}>{l}</option>)}</Select></Field>
                <Field label="To level"><Select value={edit.level_to} onChange={(e) => setEdit({ ...edit, level_to: e.target.value })}>{LEVELS.map((l) => <option key={l}>{l}</option>)}</Select></Field>
              </div>
              <div className="grid-2">
                <Field label="Access"><Select value={edit.access_tier} onChange={(e) => setEdit({ ...edit, access_tier: e.target.value })}><option value="free">Free</option><option value="premium">Premium</option></Select></Field>
                <Field label="Status"><Select value={edit.status} onChange={(e) => setEdit({ ...edit, status: e.target.value })}>{STATUSES.map((s) => <option key={s}>{s}</option>)}</Select></Field>
              </div>
              <Switch label="Featured" checked={!!edit.is_featured} onChange={(v) => setEdit({ ...edit, is_featured: v })} />
            </div>
            <div className="stack">
              <CoverArt pattern={edit.cover_style?.pattern} hue={edit.cover_style?.hue} width={400} />
              <div className="grid-2">
                <Field label="Pattern"><Select value={edit.cover_style?.pattern ?? 'grid'} onChange={(e) => setEdit({ ...edit, cover_style: { ...edit.cover_style, pattern: e.target.value as Pattern } })}>{PATTERNS.map((p) => <option key={p}>{p}</option>)}</Select></Field>
                <Field label="Hue"><input type="range" min={0} max={359} value={edit.cover_style?.hue ?? 38} onChange={(e) => setEdit({ ...edit, cover_style: { ...edit.cover_style, hue: Number(e.target.value) } })} /></Field>
              </div>
              {current && (
                <div className="stack" style={{ gap: 8 }}>
                  <strong>Courses in order</strong>
                  {items.map((it, i) => (
                    <div key={it.course_id} className="row">
                      <Badge>{i + 1}</Badge>
                      <span className="grow">{it.course?.title ?? '(unavailable)'}</span>
                      {it.course && it.course.status !== 'published' && <Badge tone="warning">{it.course.status}</Badge>}
                      <Button size="sm" variant="ghost" icon={<ArrowUp />} disabled={i === 0} onClick={() => reorder(i, i - 1)} aria-label="Up" />
                      <Button size="sm" variant="ghost" icon={<ArrowDown />} disabled={i === items.length - 1} onClick={() => reorder(i, i + 1)} aria-label="Down" />
                      <ConfirmButton label="×" confirmLabel="Remove?" onConfirm={async () => { await supabase.from('learning_path_courses').delete().eq('path_id', current.id).eq('course_id', it.course_id); refresh(); }} />
                    </div>
                  ))}
                  <div className="row">
                    <Select value={addCourse} onChange={(e) => setAddCourse(e.target.value)}><option value="">Add a course…</option>{courses.data?.filter((c) => !items.some((i) => i.course_id === c.id)).map((c) => <option key={c.id} value={c.id}>{c.title}</option>)}</Select>
                    <Button disabled={!addCourse} onClick={async () => { const { error } = await supabase.from('learning_path_courses').insert({ path_id: current.id, course_id: addCourse, position: items.length }); if (error) toast('error', error.message); setAddCourse(''); refresh(); }}>Add</Button>
                  </div>
                </div>
              )}
              {!current && <p className="small faint">Save the path to add courses.</p>}
            </div>
          </div>
        </Modal>
      )}
    </>
  );
}
