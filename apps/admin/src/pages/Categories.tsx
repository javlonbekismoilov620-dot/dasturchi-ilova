import { useQueryClient } from '@tanstack/react-query';
import { Plus } from 'lucide-react';
import { useState } from 'react';

import { PageHead } from '../components/Layout';
import { Badge, Button, ConfirmButton, Field, Input, Loading, Modal, Select, StatusBadge, Switch, Textarea, useToast } from '../components/ui';
import { slugify, STATUSES } from '../lib/format';
import { supabase } from '../lib/supabase';
import { useCategoriesFlat } from './Courses';

type Cat = NonNullable<ReturnType<typeof useCategoriesFlat>['data']>[number];
const ICONS = ['cpu', 'code', 'clapperboard', 'box', 'gamepad', 'palette', 'sparkles', 'book-open', 'compass', 'target', 'trending-up'];
const COLORS = ['#3BA8FF', '#8B7CFF', '#FF6B8B', '#FF9A3D', '#4FD1C5', '#E879F9', '#34D399', '#F3B65A', '#94A3B8'];

export function Categories() {
  const cats = useCategoriesFlat();
  const qc = useQueryClient();
  const toast = useToast();
  const [edit, setEdit] = useState<Partial<Cat> | null>(null);
  if (cats.isLoading) return <Loading />;
  const top = cats.data?.filter((c) => !c.parent_id) ?? [];
  const save = async () => {
    if (!edit?.title?.trim()) return;
    const row = { title: edit.title.trim(), slug: edit.slug || slugify(edit.title), parent_id: edit.parent_id ?? null, subtitle: edit.subtitle || null, description: edit.description || null, icon: edit.icon || null, color: edit.color || null, status: edit.status ?? 'published', is_featured: !!edit.is_featured, position: edit.position ?? (cats.data?.filter((c) => c.parent_id === (edit.parent_id ?? null)).length ?? 0) };
    const { error } = edit.id ? await supabase.from('categories').update(row).eq('id', edit.id) : await supabase.from('categories').insert(row);
    if (error) return toast('error', error.message);
    toast('success', 'Category saved');
    setEdit(null);
    qc.invalidateQueries({ queryKey: ['categories'] });
  };
  return (
    <>
      <PageHead title="Categories" subtitle="Subjects and topics. New categories appear in the apps immediately — no release needed." actions={<Button variant="primary" icon={<Plus />} onClick={() => setEdit({ status: 'published' })}>New category</Button>} />
      <div className="stack">
        {top.map((c) => (
          <div key={c.id} className="card">
            <div className="row" style={{ marginBottom: 12 }}>
              <span style={{ width: 14, height: 14, borderRadius: 4, background: c.color ?? 'var(--accent)' }} />
              <h3 style={{ margin: 0 }} className="grow">
                {c.title} <span className="faint small mono">/{c.slug}</span>
              </h3>
              <StatusBadge status={c.status} />
              <Button size="sm" onClick={() => setEdit(c)}>Edit</Button>
              <Button size="sm" icon={<Plus />} onClick={() => setEdit({ parent_id: c.id, status: 'published' })}>Topic</Button>
            </div>
            <div className="pill-list">
              {cats.data?.filter((s) => s.parent_id === c.id).map((s) => (
                <button key={s.id} className="pill" style={{ border: 0, cursor: 'pointer', paddingRight: 10 }} onClick={() => setEdit(s)}>
                  {s.title}
                  {s.status !== 'published' && <Badge tone="warning">{s.status}</Badge>}
                </button>
              ))}
            </div>
          </div>
        ))}
      </div>
      {edit && (
        <Modal title={edit.id ? 'Edit category' : edit.parent_id ? 'New topic' : 'New category'} onClose={() => setEdit(null)} footer={<>
          {edit.id && <ConfirmButton onConfirm={async () => { const { error } = await supabase.from('categories').delete().eq('id', edit.id!); if (error) toast('error', 'Cannot delete: courses still use this category.'); setEdit(null); qc.invalidateQueries({ queryKey: ['categories'] }); }} />}
          <Button variant="primary" onClick={save}>Save</Button>
        </>}>
          <div className="stack">
            <Field label="Title"><Input value={edit.title ?? ''} onChange={(e) => setEdit({ ...edit, title: e.target.value })} autoFocus /></Field>
            <Field label="Slug" hint="Leave empty to generate from the title."><Input value={edit.slug ?? ''} onChange={(e) => setEdit({ ...edit, slug: slugify(e.target.value) })} /></Field>
            {!edit.parent_id && (
              <>
                <Field label="Subtitle"><Input value={edit.subtitle ?? ''} onChange={(e) => setEdit({ ...edit, subtitle: e.target.value })} /></Field>
                <Field label="Description"><Textarea value={edit.description ?? ''} onChange={(e) => setEdit({ ...edit, description: e.target.value })} /></Field>
                <Field label="Icon"><Select value={edit.icon ?? ''} onChange={(e) => setEdit({ ...edit, icon: e.target.value })}><option value="">—</option>{ICONS.map((i) => <option key={i}>{i}</option>)}</Select></Field>
                <Field label="Colour"><div className="swatches">{COLORS.map((c) => <button key={c} type="button" aria-label={c} className={`swatch ${edit.color === c ? 'active' : ''}`} style={{ background: c }} onClick={() => setEdit({ ...edit, color: c })} />)}</div></Field>
                <Switch label="Featured" checked={!!edit.is_featured} onChange={(v) => setEdit({ ...edit, is_featured: v })} />
              </>
            )}
            <Field label="Parent"><Select value={edit.parent_id ?? ''} onChange={(e) => setEdit({ ...edit, parent_id: e.target.value || null })}><option value="">— top level —</option>{top.filter((t) => t.id !== edit.id).map((t) => <option key={t.id} value={t.id}>{t.title}</option>)}</Select></Field>
            <Field label="Status"><Select value={edit.status ?? 'published'} onChange={(e) => setEdit({ ...edit, status: e.target.value })}>{STATUSES.map((s) => <option key={s}>{s}</option>)}</Select></Field>
          </div>
        </Modal>
      )}
    </>
  );
}
