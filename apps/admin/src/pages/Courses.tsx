import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Plus, Search } from 'lucide-react';
import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router';

import { CoverArt, type Pattern } from '../components/CoverArt';
import { PageHead } from '../components/Layout';
import { Badge, Button, Empty, Field, Input, Loading, Modal, Select, StatusBadge, useToast } from '../components/ui';
import { useAuth } from '../lib/auth';
import { errMsg, fmtMinutes, slugify, STATUSES } from '../lib/format';
import { must, supabase } from '../lib/supabase';

export interface CourseRow {
  id: string;
  slug: string;
  title: string;
  status: string;
  access_tier: string;
  level: string;
  lesson_count: number;
  duration_seconds: number;
  enrollment_count: number;
  content_complete: boolean;
  cover_style: { pattern?: Pattern; hue?: number };
  cover_path: string | null;
  updated_at: string;
  category: { title: string } | null;
}

export function useCategoriesFlat() {
  return useQuery({
    queryKey: ['categories'],
    queryFn: async () => must(await supabase.from('categories').select('id, parent_id, slug, title, color, icon, position, status, is_featured, subtitle, description').order('position')) as {
      id: string; parent_id: string | null; slug: string; title: string; color: string | null; icon: string | null; position: number; status: string; is_featured: boolean; subtitle: string | null; description: string | null;
    }[],
  });
}

export function useInstructors() {
  return useQuery({ queryKey: ['instructors'], queryFn: async () => must(await supabase.from('instructors').select('id, name, slug, profile_id').order('name')) as { id: string; name: string; slug: string; profile_id: string | null }[] });
}

export function Courses() {
  const nav = useNavigate();
  const qc = useQueryClient();
  const toast = useToast();
  const { isEditor, session } = useAuth();
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('');
  const [creating, setCreating] = useState(false);
  const [title, setTitle] = useState('');
  const [categoryId, setCategoryId] = useState('');
  const [instructorId, setInstructorId] = useState('');
  const categories = useCategoriesFlat();
  const instructors = useInstructors();

  const courses = useQuery({
    queryKey: ['courses'],
    queryFn: async () =>
      must(await supabase.from('courses').select('id, slug, title, status, access_tier, level, lesson_count, duration_seconds, enrollment_count, content_complete, cover_style, cover_path, updated_at, category:categories!courses_category_id_fkey(title)').order('updated_at', { ascending: false })) as unknown as CourseRow[],
  });

  const myInstructor = instructors.data?.find((i) => i.profile_id === session?.user.id);
  const create = useMutation({
    mutationFn: async () => {
      const row = must(
        await supabase
          .from('courses')
          .insert({
            title: title.trim(),
            slug: `${slugify(title)}-${Math.random().toString(36).slice(2, 6)}`,
            category_id: categoryId,
            instructor_id: instructorId || myInstructor?.id || null,
            status: 'draft',
            cover_style: { pattern: 'grid', hue: Math.floor(Math.random() * 360) },
          })
          .select('id')
          .single(),
      ) as { id: string };
      return row.id;
    },
    onSuccess: (id) => {
      qc.invalidateQueries({ queryKey: ['courses'] });
      nav(`/courses/${id}`);
    },
    onError: (e) => toast('error', errMsg(e)),
  });

  const rows = useMemo(
    () => (courses.data ?? []).filter((c) => (!status || c.status === status) && (!q || c.title.toLowerCase().includes(q.toLowerCase()))),
    [courses.data, q, status],
  );
  const topCategories = categories.data?.filter((c) => !c.parent_id) ?? [];

  return (
    <>
      <PageHead
        title="Courses"
        subtitle={isEditor ? 'Create, review and publish courses.' : 'Your courses. Editors review and publish them.'}
        actions={
          <Button variant="primary" icon={<Plus />} onClick={() => setCreating(true)} data-testid="new-course">
            New course
          </Button>
        }
      />
      <div className="row wrap" style={{ marginBottom: 16 }}>
        <div className="row grow" style={{ maxWidth: 360 }}>
          <Search size={16} className="faint" />
          <Input placeholder="Search courses" value={q} onChange={(e) => setQ(e.target.value)} aria-label="Search courses" />
        </div>
        <Select value={status} onChange={(e) => setStatus(e.target.value)} style={{ width: 180 }} aria-label="Filter by status">
          <option value="">All statuses</option>
          {STATUSES.map((s) => (
            <option key={s} value={s}>
              {s.replace('_', ' ')}
            </option>
          ))}
        </Select>
      </div>
      <div className="card flush">
        {courses.isLoading ? (
          <Loading />
        ) : rows.length === 0 ? (
          <Empty title="No courses found" body="Adjust the filters or create a new course." />
        ) : (
          <table className="table">
            <thead>
              <tr>
                <th>Course</th>
                <th>Status</th>
                <th>Access</th>
                <th>Lessons</th>
                <th>Learners</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((c) => (
                <tr key={c.id} className="clickable" onClick={() => nav(`/courses/${c.id}`)}>
                  <td>
                    <div className="row">
                      <CoverArt pattern={c.cover_style?.pattern} hue={c.cover_style?.hue} coverPath={c.cover_path} width={64} radius={8} />
                      <div>
                        <div className="title">{c.title}</div>
                        <div className="small faint">
                          {c.category?.title} · {c.level}
                          {!c.content_complete && c.status === 'published' && ' · in development'}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td>
                    <StatusBadge status={c.status} />
                  </td>
                  <td>{c.access_tier === 'premium' ? <Badge tone="accent">Premium</Badge> : <Badge>Free</Badge>}</td>
                  <td className="muted">
                    {c.lesson_count} · {fmtMinutes(c.duration_seconds)}
                  </td>
                  <td className="muted">{c.enrollment_count}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {creating && (
        <Modal
          title="New course"
          onClose={() => setCreating(false)}
          footer={
            <>
              <Button variant="ghost" onClick={() => setCreating(false)}>
                Cancel
              </Button>
              <Button variant="primary" disabled={!title.trim() || !categoryId || (!isEditor && !myInstructor)} loading={create.isPending} onClick={() => create.mutate()} data-testid="create-course">
                Create draft
              </Button>
            </>
          }>
          <div className="stack">
            <Field label="Title">
              <Input autoFocus value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g. CSS from Zero" data-testid="course-title-input" />
            </Field>
            <Field label="Category">
              <Select value={categoryId} onChange={(e) => setCategoryId(e.target.value)} data-testid="course-category">
                <option value="">Choose…</option>
                {topCategories.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.title}
                  </option>
                ))}
              </Select>
            </Field>
            {isEditor ? (
              <Field label="Instructor" hint="Optional — who is credited on the course page.">
                <Select value={instructorId} onChange={(e) => setInstructorId(e.target.value)}>
                  <option value="">None</option>
                  {instructors.data?.map((i) => (
                    <option key={i.id} value={i.id}>
                      {i.name}
                    </option>
                  ))}
                </Select>
              </Field>
            ) : (
              !myInstructor && <p className="badge danger">Your account isn’t linked to an instructor profile yet. Ask an editor to link it.</p>
            )}
          </div>
        </Modal>
      )}
    </>
  );
}
