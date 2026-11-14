import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { ArrowDown, ArrowUp, ChevronRight, ExternalLink, Plus, Save } from 'lucide-react';
import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router';

import { CoverArt, type Pattern } from '../components/CoverArt';
import { PageHead } from '../components/Layout';
import { LocalePicker, TranslationEditor } from '../components/Translations';
import { targetLocales, translationStatus, type Locale, type Translations } from '../lib/translations';
import { Badge, Button, ConfirmButton, Empty, Field, Input, ListEditor, Loading, Modal, Select, StatusBadge, Switch, Tabs, Textarea, UploadButton, safeFileName, useToast } from '../components/ui';
import { useAuth } from '../lib/auth';
import { errMsg, fmtMinutes, LESSON_TYPES, LEVELS, PATTERNS, slugify, STATUSES } from '../lib/format';
import { renderMarkdown } from '../lib/markdown';
import { must, supabase } from '../lib/supabase';
import { useCategoriesFlat, useInstructors } from './Courses';

interface Course {
  id: string;
  slug: string;
  title: string;
  subtitle: string | null;
  description: string | null;
  category_id: string;
  subcategory_id: string | null;
  instructor_id: string | null;
  level: string;
  access_tier: 'free' | 'premium';
  status: string;
  language: string;
  cover_path: string | null;
  cover_style: { pattern?: Pattern; hue?: number };
  estimated_minutes: number | null;
  learning_outcomes: string[];
  prerequisites: string[];
  tags: string[];
  is_featured: boolean;
  content_complete: boolean;
  certificate_enabled: boolean;
  lesson_count: number;
  duration_seconds: number;
  enrollment_count: number;
  translations?: Translations;
}

interface LessonRow {
  id: string;
  title: string;
  type: string;
  status: string;
  position: number;
  duration_seconds: number;
  is_preview: boolean;
}
interface ModuleRow {
  id: string;
  title: string;
  description: string | null;
  position: number;
  status: string;
  lessons: LessonRow[];
}

const EDITABLE = ['slug', 'title', 'subtitle', 'description', 'category_id', 'subcategory_id', 'instructor_id', 'level', 'access_tier', 'language', 'cover_path', 'cover_style', 'estimated_minutes', 'learning_outcomes', 'prerequisites', 'tags', 'is_featured', 'content_complete', 'certificate_enabled'] as const;
/** Only author-editable columns are sent; counters, status and search data are server-owned. */
const editable = (c: Course) => Object.fromEntries(EDITABLE.map((k) => [k, c[k]])) as Partial<Course>;

/** Reorders a list and persists positions 0..n for every row. */
async function persistOrder(table: 'modules' | 'lessons', ids: string[]) {
  await Promise.all(ids.map((id, position) => supabase.from(table).update({ position }).eq('id', id)));
}

function moved<T>(list: T[], from: number, to: number) {
  const copy = [...list];
  const [x] = copy.splice(from, 1);
  copy.splice(to, 0, x);
  return copy;
}

export function CourseEditor() {
  const { id } = useParams<{ id: string }>();
  const nav = useNavigate();
  const qc = useQueryClient();
  const toast = useToast();
  const { isEditor } = useAuth();
  const [tab, setTab] = useState<'details' | 'curriculum' | 'translations'>('details');
  const [form, setForm] = useState<Course | null>(null);
  const categories = useCategoriesFlat();
  const instructors = useInstructors();

  const course = useQuery({ queryKey: ['course', id], queryFn: async () => must(await supabase.from('courses').select('*').eq('id', id!).single()) as Course });
  useEffect(() => {
    if (course.data) setForm(course.data);
  }, [course.data]);

  const save = useMutation({
    mutationFn: async (patch: Partial<Course>) =>
      must(await supabase.from('courses').update(patch).eq('id', id!).select('*').single()) as Course,
    onSuccess: (c) => {
      qc.setQueryData(['course', id], c);
      qc.invalidateQueries({ queryKey: ['courses'] });
      toast('success', 'Saved');
    },
    onError: (e) => toast('error', errMsg(e)),
  });

  if (course.isLoading || !form) return <Loading />;
  if (course.error) return <Empty title="Course not available" body={errMsg(course.error)} />;

  const set = <K extends keyof Course>(k: K, v: Course[K]) => setForm((f) => (f ? { ...f, [k]: v } : f));
  const top = categories.data?.filter((c) => !c.parent_id) ?? [];
  const subs = categories.data?.filter((c) => c.parent_id === form.category_id) ?? [];
  const dirty = JSON.stringify(editable(form)) !== JSON.stringify(editable(course.data!));
  const status = course.data!.status;

  const transition = (next: string) => save.mutate({ status: next });

  return (
    <>
      <PageHead
        crumbs={
          <>
            <Link to="/courses">Courses</Link> <ChevronRight size={14} /> <span>{course.data!.title}</span>
          </>
        }
        title={course.data!.title}
        subtitle={`${course.data!.lesson_count} published lessons · ${fmtMinutes(course.data!.duration_seconds)} · ${course.data!.enrollment_count} learners`}
        actions={
          <>
            <StatusBadge status={status} />
            {status === 'draft' && <Button onClick={() => transition('in_review')}>Submit for review</Button>}
            {status === 'in_review' && isEditor && (
              <Button variant="primary" onClick={() => transition('published')} data-testid="publish-course">
                Publish
              </Button>
            )}
            {status === 'in_review' && <Button variant="ghost" onClick={() => transition('draft')}>Back to draft</Button>}
            {status === 'published' && isEditor && <Button onClick={() => transition('draft')}>Unpublish</Button>}
            {status === 'published' && isEditor && <Button variant="ghost" onClick={() => transition('archived')}>Archive</Button>}
            {status === 'archived' && isEditor && <Button onClick={() => transition('draft')}>Restore to draft</Button>}
            {isEditor && (
              <ConfirmButton
                label="Delete"
                onConfirm={async () => {
                  const { error } = await supabase.from('courses').delete().eq('id', id!);
                  if (error) return toast('error', error.message);
                  qc.invalidateQueries({ queryKey: ['courses'] });
                  nav('/courses');
                }}
              />
            )}
          </>
        }
      />
      <Tabs
        value={tab}
        onChange={setTab}
        tabs={[
          { value: 'details', label: 'Details' },
          { value: 'curriculum', label: 'Curriculum' },
          { value: 'translations', label: 'Translations' },
        ]}
      />

      {tab === 'translations' && <CourseTranslations course={course.data!} onSaved={() => qc.invalidateQueries({ queryKey: ['course', id] })} />}

      {tab === 'translations' ? null : tab === 'details' ? (
        <div className="grid-2" style={{ gridTemplateColumns: 'minmax(0,1.6fr) minmax(0,1fr)', alignItems: 'start' }}>
          <div className="stack">
            <div className="card stack">
              <Field label="Title">
                <Input value={form.title} onChange={(e) => set('title', e.target.value)} maxLength={160} />
              </Field>
              <Field label="Slug" hint="Used in links. Lowercase letters, numbers and hyphens.">
                <div className="row">
                  <Input value={form.slug} onChange={(e) => set('slug', slugify(e.target.value))} />
                  <Button type="button" variant="ghost" size="sm" onClick={() => set('slug', slugify(form.title))}>
                    From title
                  </Button>
                </div>
              </Field>
              <Field label="Subtitle">
                <Input value={form.subtitle ?? ''} onChange={(e) => set('subtitle', e.target.value || null)} maxLength={240} />
              </Field>
              <Field label="Description (Markdown)">
                <Textarea value={form.description ?? ''} onChange={(e) => set('description', e.target.value || null)} rows={8} />
              </Field>
            </div>
            <div className="card stack">
              <h3 style={{ margin: 0 }}>Learning design</h3>
              <Field label="What learners will learn">
                <ListEditor value={form.learning_outcomes} onChange={(v) => set('learning_outcomes', v)} placeholder="Add an outcome and press Enter" />
              </Field>
              <Field label="Before you start (prerequisites)">
                <ListEditor value={form.prerequisites} onChange={(v) => set('prerequisites', v)} placeholder="e.g. Basic computer use" />
              </Field>
              <Field label="Tags">
                <ListEditor value={form.tags} onChange={(v) => set('tags', v.map((x) => x.toLowerCase()))} placeholder="e.g. python" />
              </Field>
            </div>
          </div>
          <div className="stack">
            <div className="card stack">
              <CoverArt pattern={form.cover_style?.pattern} hue={form.cover_style?.hue} coverPath={form.cover_path} width={360} />
              <Field label="Cover pattern">
                <Select value={form.cover_style?.pattern ?? 'grid'} onChange={(e) => set('cover_style', { ...form.cover_style, pattern: e.target.value as Pattern })}>
                  {PATTERNS.map((p) => (
                    <option key={p}>{p}</option>
                  ))}
                </Select>
              </Field>
              <Field label={`Hue · ${form.cover_style?.hue ?? 38}°`}>
                <input type="range" min={0} max={359} value={form.cover_style?.hue ?? 38} onChange={(e) => set('cover_style', { ...form.cover_style, hue: Number(e.target.value) })} />
              </Field>
              <div className="row wrap">
                <UploadButton bucket="public-media" accept="image/png,image/jpeg,image/webp" label="Upload image" path={(f) => `covers/${id}/${Date.now()}-${safeFileName(f.name)}`} onUploaded={(p) => set('cover_path', p)} />
                {form.cover_path && (
                  <Button variant="ghost" onClick={() => set('cover_path', null)}>
                    Use generated cover
                  </Button>
                )}
              </div>
            </div>
            <div className="card stack">
              <Field label="Category">
                <Select value={form.category_id} onChange={(e) => setForm({ ...form, category_id: e.target.value, subcategory_id: null })}>
                  {top.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.title}
                    </option>
                  ))}
                </Select>
              </Field>
              <Field label="Topic">
                <Select value={form.subcategory_id ?? ''} onChange={(e) => set('subcategory_id', e.target.value || null)}>
                  <option value="">—</option>
                  {subs.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.title}
                    </option>
                  ))}
                </Select>
              </Field>
              <Field label="Instructor">
                <Select value={form.instructor_id ?? ''} onChange={(e) => set('instructor_id', e.target.value || null)} disabled={!isEditor}>
                  <option value="">—</option>
                  {instructors.data?.map((i) => (
                    <option key={i.id} value={i.id}>
                      {i.name}
                    </option>
                  ))}
                </Select>
              </Field>
              <div className="grid-2">
                <Field label="Level">
                  <Select value={form.level} onChange={(e) => set('level', e.target.value)}>
                    {LEVELS.map((l) => (
                      <option key={l}>{l}</option>
                    ))}
                  </Select>
                </Field>
                <Field label="Language">
                  <Select value={form.language} onChange={(e) => set('language', e.target.value)}>
                    <option value="en">English</option>
                    <option value="uz">Oʻzbekcha</option>
                    <option value="ru">Русский</option>
                  </Select>
                </Field>
              </div>
              <Field label="Access">
                <Select value={form.access_tier} onChange={(e) => set('access_tier', e.target.value as Course['access_tier'])}>
                  <option value="free">Free</option>
                  <option value="premium">Premium</option>
                </Select>
              </Field>
              <Switch label="Featured on Home" checked={form.is_featured} onChange={(v) => set('is_featured', v)} />
              <Switch label="Curriculum complete" checked={form.content_complete} onChange={(v) => set('content_complete', v)} />
              <p className="small faint" style={{ margin: 0 }}>
                While off, learners see an “In development” notice. Turn on only when every planned lesson is published.
              </p>
              <Switch label="Issue certificates" checked={form.certificate_enabled} onChange={(v) => set('certificate_enabled', v)} />
            </div>
            <div className="row" style={{ position: 'sticky', bottom: 16 }}>
              <Button variant="primary" icon={<Save />} disabled={!dirty} loading={save.isPending} onClick={() => save.mutate(editable(form))} data-testid="save-course">
                Save changes
              </Button>
              {dirty && <span className="small faint">Unsaved changes</span>}
            </div>
          </div>
          {form.description && (
            <div className="card" style={{ gridColumn: '1 / -1' }}>
              <h3>Description preview</h3>
              <div className="prose" dangerouslySetInnerHTML={{ __html: renderMarkdown(form.description) }} />
            </div>
          )}
        </div>
      ) : (
        <Curriculum courseId={id!} />
      )}
    </>
  );
}

function Curriculum({ courseId }: { courseId: string }) {
  const qc = useQueryClient();
  const toast = useToast();
  const { isEditor } = useAuth();
  const [newModule, setNewModule] = useState('');
  const [lessonFor, setLessonFor] = useState<ModuleRow | null>(null);
  const [lessonTitle, setLessonTitle] = useState('');
  const [lessonType, setLessonType] = useState<string>('article');

  const key = ['curriculum', courseId];
  const modules = useQuery({
    queryKey: key,
    queryFn: async () => {
      const rows = must(
        await supabase.from('modules').select('id, title, description, position, status, lessons(id, title, type, status, position, duration_seconds, is_preview)').eq('course_id', courseId).order('position').order('position', { referencedTable: 'lessons' }),
      ) as ModuleRow[];
      return rows;
    },
  });
  const refresh = () => {
    qc.invalidateQueries({ queryKey: key });
    qc.invalidateQueries({ queryKey: ['course', courseId] });
  };
  const run = async (fn: () => PromiseLike<{ error: { message: string } | null }>) => {
    const { error } = await fn();
    if (error) toast('error', error.message);
    refresh();
  };

  if (modules.isLoading) return <Loading />;
  const list = modules.data ?? [];
  const statusOptions = isEditor ? STATUSES : (['draft', 'in_review'] as const);

  return (
    <div className="stack">
      {list.length === 0 && <Empty title="No modules yet" body="Modules group lessons into chapters. Add the first one below." />}
      {list.map((m, mi) => (
        <section key={m.id} className="module">
          <div className="module-head">
            <span className="badge">{mi + 1}</span>
            <Input defaultValue={m.title} onBlur={(e) => e.target.value.trim() && e.target.value !== m.title && run(() => supabase.from('modules').update({ title: e.target.value.trim() }).eq('id', m.id))} aria-label="Module title" style={{ fontWeight: 600 }} />
            <Select value={m.status} onChange={(e) => run(() => supabase.from('modules').update({ status: e.target.value }).eq('id', m.id))} style={{ width: 150 }} aria-label="Module status">
              {(statusOptions.includes(m.status as never) ? statusOptions : [...statusOptions, m.status]).map((s) => (
                <option key={s} value={s}>
                  {s.replace('_', ' ')}
                </option>
              ))}
            </Select>
            <Button size="sm" variant="ghost" icon={<ArrowUp />} disabled={mi === 0} aria-label="Move up" onClick={async () => { await persistOrder('modules', moved(list, mi, mi - 1).map((x) => x.id)); refresh(); }} />
            <Button size="sm" variant="ghost" icon={<ArrowDown />} disabled={mi === list.length - 1} aria-label="Move down" onClick={async () => { await persistOrder('modules', moved(list, mi, mi + 1).map((x) => x.id)); refresh(); }} />
            <ConfirmButton label="Delete" onConfirm={() => run(() => supabase.from('modules').delete().eq('id', m.id))} />
          </div>
          {m.lessons.map((l, li) => (
            <div key={l.id} className="lesson-row">
              <span className="faint small" style={{ width: 22 }}>
                {li + 1}
              </span>
              <Link to={`/lessons/${l.id}`} className="grow title">
                {l.title}
              </Link>
              <Badge>{l.type}</Badge>
              {l.is_preview && <Badge tone="info">preview</Badge>}
              <span className="faint small" style={{ width: 60 }}>
                {l.duration_seconds ? fmtMinutes(l.duration_seconds) : '—'}
              </span>
              <StatusBadge status={l.status} />
              <Button size="sm" variant="ghost" icon={<ArrowUp />} disabled={li === 0} aria-label="Move lesson up" onClick={async () => { await persistOrder('lessons', moved(m.lessons, li, li - 1).map((x) => x.id)); refresh(); }} />
              <Button size="sm" variant="ghost" icon={<ArrowDown />} disabled={li === m.lessons.length - 1} aria-label="Move lesson down" onClick={async () => { await persistOrder('lessons', moved(m.lessons, li, li + 1).map((x) => x.id)); refresh(); }} />
              <Link className="btn sm ghost" to={`/lessons/${l.id}`} aria-label={`Edit ${l.title}`}>
                <ExternalLink />
              </Link>
            </div>
          ))}
          <div className="lesson-row">
            <Button size="sm" icon={<Plus />} onClick={() => { setLessonFor(m); setLessonTitle(''); setLessonType('article'); }} data-testid={`add-lesson-${mi}`}>
              Add lesson
            </Button>
          </div>
        </section>
      ))}
      <div className="card row">
        <Input placeholder="New module title" value={newModule} onChange={(e) => setNewModule(e.target.value)} data-testid="new-module-title" />
        <Button
          icon={<Plus />}
          disabled={!newModule.trim()}
          onClick={async () => {
            await run(() => supabase.from('modules').insert({ course_id: courseId, title: newModule.trim(), position: list.length, status: 'draft' }));
            setNewModule('');
          }}
          data-testid="add-module">
          Add module
        </Button>
      </div>

      {lessonFor && (
        <Modal
          title={`New lesson in “${lessonFor.title}”`}
          onClose={() => setLessonFor(null)}
          footer={
            <Button
              variant="primary"
              disabled={!lessonTitle.trim()}
              onClick={async () => {
                const { data, error } = await supabase
                  .from('lessons')
                  .insert({ module_id: lessonFor.id, course_id: courseId, title: lessonTitle.trim(), type: lessonType, position: lessonFor.lessons.length, status: 'draft' })
                  .select('id')
                  .single();
                if (error) return toast('error', error.message);
                await supabase.from('lesson_contents').insert({ lesson_id: data.id, body_md: '' });
                setLessonFor(null);
                refresh();
              }}
              data-testid="create-lesson">
              Create lesson
            </Button>
          }>
          <div className="stack">
            <Field label="Title">
              <Input autoFocus value={lessonTitle} onChange={(e) => setLessonTitle(e.target.value)} data-testid="lesson-title-input" />
            </Field>
            <Field label="Type">
              <Select value={lessonType} onChange={(e) => setLessonType(e.target.value)}>
                {LESSON_TYPES.map((t) => (
                  <option key={t}>{t}</option>
                ))}
              </Select>
            </Field>
          </div>
        </Modal>
      )}
    </div>
  );
}

// Translations ------------------------------------------------------------------------
const COURSE_TR_FIELDS = [
  { key: 'title', label: 'Title' },
  { key: 'subtitle', label: 'Subtitle' },
  { key: 'description', label: 'Description (Markdown)', kind: 'markdown' as const },
  { key: 'learning_outcomes', label: 'What learners will learn', kind: 'list' as const },
  { key: 'prerequisites', label: 'Before you start', kind: 'list' as const },
];
const MODULE_TR_FIELDS = [
  { key: 'title', label: 'Module title' },
  { key: 'description', label: 'Module description' },
];
const LESSON_TR_FIELDS = [
  { key: 'title', label: 'Title' },
  { key: 'summary', label: 'Summary' },
];

type TrModule = { id: string; title: string; description: string | null; translations: Translations; lessons: { id: string; title: string; summary: string | null; status: string; position: number; translations: Translations }[] };

function CourseTranslations({ course, onSaved }: { course: Course; onSaved: () => void }) {
  const [locale, setLocale] = useState<Locale>(targetLocales(course.language)[0].code);
  const modules = useQuery({
    queryKey: ['course-translations', course.id],
    queryFn: async () =>
      must(
        await supabase
          .from('modules')
          .select('id, title, description, translations, lessons(id, title, summary, status, position, translations)')
          .eq('course_id', course.id)
          .order('position')
          .order('position', { referencedTable: 'lessons' }),
      ) as unknown as TrModule[],
  });
  return (
    <div className="stack">
      <div className="card">
        <LocalePicker value={locale} onChange={setLocale} baseLanguage={course.language} />
        <p className="muted small" style={{ marginBottom: 0 }}>
          Learners see the translation for their app language. Anything left empty falls back to the original with a “translation is being prepared” notice. Lesson bodies and quizzes are translated in their own editors.
        </p>
      </div>
      <TranslationEditor table="courses" row={course as never} fields={COURSE_TR_FIELDS} locale={locale} title="Course" onSaved={onSaved} />
      {(modules.data ?? []).map((m) => (
        <div key={m.id} className="stack">
          <TranslationEditor table="modules" row={m as never} fields={MODULE_TR_FIELDS} locale={locale} title={`Module · ${m.title}`} onSaved={() => modules.refetch()} />
          <div className="card stack" style={{ gap: 6 }}>
            {m.lessons.map((l) => {
              const st = translationStatus(l as never, LESSON_TR_FIELDS, locale);
              return (
                <div key={l.id} className="row" style={{ justifyContent: 'space-between' }}>
                  <span>
                    {l.title} <StatusBadge status={l.status} />
                  </span>
                  <span className="row" style={{ gap: 8 }}>
                    <Badge tone={st.complete ? 'success' : 'warning'}>{st.complete ? 'Title translated' : 'Needs translation'}</Badge>
                    <Link to={`/lessons/${l.id}?tab=translations&locale=${locale}`}>Translate lesson</Link>
                  </span>
                </div>
              );
            })}
          </div>
        </div>
      ))}
    </div>
  );
}
