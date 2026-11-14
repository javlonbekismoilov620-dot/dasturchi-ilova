import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { ChevronRight, ClipboardList, FileText, Link2, Plus, Save, Trash2, Video } from 'lucide-react';
import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router';

import { PageHead } from '../components/Layout';
import { Badge, Button, ConfirmButton, Empty, Field, Input, Loading, Select, StatusBadge, Switch, Textarea, UploadButton, safeFileName, useToast } from '../components/ui';
import { useAuth } from '../lib/auth';
import { errMsg, LESSON_TYPES, STATUSES } from '../lib/format';
import { renderMarkdown } from '../lib/markdown';
import { must, supabase } from '../lib/supabase';

interface Lesson {
  id: string;
  module_id: string;
  course_id: string;
  title: string;
  summary: string | null;
  type: string;
  duration_seconds: number;
  is_preview: boolean;
  is_required: boolean;
  xp: number;
  status: string;
  course: { title: string } | null;
  module: { title: string } | null;
}
interface VideoRow {
  id: string;
  provider: 'storage' | 'mux' | 'cloudflare_stream' | 'external';
  storage_path: string | null;
  external_id: string | null;
  external_url: string | null;
  duration_seconds: number | null;
  video_sources: { id: string; quality: string; storage_path: string }[];
  video_captions: { id: string; language: string; label: string; storage_path: string }[];
}
interface Resource {
  id: string;
  title: string;
  kind: string;
  storage_path: string | null;
  external_url: string | null;
  size_bytes: number | null;
  allow_offline: boolean;
}

const kindFor = (mime: string, name: string) =>
  mime === 'application/pdf' ? 'pdf' : mime.startsWith('image/') ? 'image' : /zip|tar|rar|7z/.test(mime + name) ? 'archive' : /\.(py|js|ts|html|css|json|c|cpp|cs|java|kt|swift|blend)$/i.test(name) ? 'code' : /word|document|sheet|presentation/.test(mime) ? 'document' : 'other';

export function LessonEditor() {
  const { id } = useParams<{ id: string }>();
  const nav = useNavigate();
  const qc = useQueryClient();
  const toast = useToast();
  const { isEditor } = useAuth();
  const [meta, setMeta] = useState<Lesson | null>(null);
  const [body, setBody] = useState('');
  const [external, setExternal] = useState({ provider: 'mux', value: '' });
  const [link, setLink] = useState({ title: '', url: '' });

  const lesson = useQuery({ queryKey: ['lesson', id], queryFn: async () => must(await supabase.from('lessons').select('*, course:courses(title), module:modules(title)').eq('id', id!).single()) as unknown as Lesson });
  const content = useQuery({
    queryKey: ['lesson-content', id],
    queryFn: async () =>
      must(await supabase.from('lesson_contents').select('body_md, video:videos(id, provider, storage_path, external_id, external_url, duration_seconds, video_sources(id, quality, storage_path), video_captions(id, language, label, storage_path))').eq('lesson_id', id!).maybeSingle()) as unknown as { body_md: string | null; video: VideoRow | null } | null,
  });
  const resources = useQuery({ queryKey: ['resources', id], queryFn: async () => must(await supabase.from('resources').select('*').eq('lesson_id', id!).order('position')) as Resource[] });
  const quiz = useQuery({ queryKey: ['lesson-quiz', id], queryFn: async () => must(await supabase.from('quizzes').select('id, title, kind, status').eq('lesson_id', id!).maybeSingle()) as { id: string; title: string; kind: string; status: string } | null });
  const assignment = useQuery({ queryKey: ['lesson-assignment', id], queryFn: async () => must(await supabase.from('assignments').select('*').eq('lesson_id', id!).maybeSingle()) });

  useEffect(() => {
    if (lesson.data) setMeta(lesson.data);
  }, [lesson.data]);
  useEffect(() => {
    if (content.data !== undefined) setBody(content.data?.body_md ?? '');
  }, [content.data]);

  const refresh = () => {
    for (const k of ['lesson', 'lesson-content', 'resources', 'lesson-quiz', 'lesson-assignment']) qc.invalidateQueries({ queryKey: [k, id] });
    qc.invalidateQueries({ queryKey: ['curriculum'] });
  };

  const saveMeta = useMutation({
    mutationFn: async (m: Lesson) => {
      const { title, summary, type, duration_seconds, is_preview, is_required, xp, status } = m;
      must(await supabase.from('lessons').update({ title, summary, type, duration_seconds, is_preview, is_required, xp, status }).eq('id', id!).select('id'));
    },
    onSuccess: () => {
      toast('success', 'Lesson saved');
      refresh();
    },
    onError: (e) => toast('error', errMsg(e)),
  });
  const saveBody = useMutation({
    mutationFn: async () => must(await supabase.from('lesson_contents').upsert({ lesson_id: id!, body_md: body }).select('lesson_id')),
    onSuccess: () => {
      toast('success', 'Content saved');
      refresh();
    },
    onError: (e) => toast('error', errMsg(e)),
  });

  if (lesson.isLoading || !meta) return <Loading />;
  if (lesson.error) return <Empty title="Lesson not available" body={errMsg(lesson.error)} />;
  const l = lesson.data!;
  const video = content.data?.video ?? null;
  const base = `${l.course_id}/${l.id}`;

  const attachVideo = async (row: Partial<VideoRow>) => {
    const v = must(await supabase.from('videos').insert({ course_id: l.course_id, title: l.title, ...row }).select('id').single()) as { id: string };
    must(await supabase.from('lesson_contents').upsert({ lesson_id: id!, body_md: body, video_id: v.id }).select('lesson_id'));
    refresh();
  };

  return (
    <>
      <PageHead
        crumbs={
          <>
            <Link to="/courses">Courses</Link> <ChevronRight size={14} /> <Link to={`/courses/${l.course_id}`}>{l.course?.title}</Link> <ChevronRight size={14} /> <span>{l.module?.title}</span>
          </>
        }
        title={l.title}
        actions={
          <>
            <StatusBadge status={l.status} />
            <ConfirmButton
              onConfirm={async () => {
                const { error } = await supabase.from('lessons').delete().eq('id', id!);
                if (error) return toast('error', error.message);
                nav(`/courses/${l.course_id}`);
              }}
            />
          </>
        }
      />
      <div className="grid-2" style={{ gridTemplateColumns: 'minmax(0,1fr) 340px', alignItems: 'start' }}>
        <div className="stack">
          <div className="card stack">
            <div className="row" style={{ justifyContent: 'space-between' }}>
              <h3 style={{ margin: 0 }}>Lesson text (Markdown)</h3>
              <Button variant="primary" icon={<Save />} loading={saveBody.isPending} disabled={body === (content.data?.body_md ?? '')} onClick={() => saveBody.mutate()} data-testid="save-body">
                Save content
              </Button>
            </div>
            <p className="small faint" style={{ margin: 0 }}>
              Supports headings, lists, tables, fenced code (```python) and callouts: start a quote with [!NOTE], [!TIP] or [!WARNING].
            </p>
            <div className="editor-split">
              <Textarea code value={body} onChange={(e) => setBody(e.target.value)} aria-label="Lesson markdown" data-testid="lesson-body" />
              <div className="card preview prose" style={{ background: 'var(--bg-elev)' }} dangerouslySetInnerHTML={{ __html: body ? renderMarkdown(body) : '<p class="faint">Preview appears here.</p>' }} />
            </div>
          </div>

          <div className="card stack">
            <h3 style={{ margin: 0 }}>
              <Video size={16} style={{ verticalAlign: -3 }} /> Video
            </h3>
            {video ? (
              <>
                <div className="row wrap">
                  <Badge tone="accent">{video.provider}</Badge>
                  <span className="mono small muted">{video.storage_path ?? video.external_id ?? video.external_url}</span>
                  <Button size="sm" variant="ghost" icon={<Trash2 />} onClick={async () => { await supabase.from('lesson_contents').update({ video_id: null }).eq('lesson_id', id!); refresh(); }}>
                    Detach
                  </Button>
                </div>
                {video.provider === 'storage' && (
                  <div className="stack" style={{ gap: 10 }}>
                    <div className="small muted">Extra quality renditions: {video.video_sources.map((s) => s.quality).join(', ') || 'none'}</div>
                    <div className="row wrap">
                      {(['1080p', '720p', '480p'] as const).map((q) => (
                        <UploadButton
                          key={q}
                          bucket="course-media"
                          accept="video/mp4"
                          label={`Add ${q}`}
                          path={() => `${base}/video-${q}.mp4`}
                          onUploaded={async (p) => {
                            await supabase.from('video_sources').upsert({ video_id: video.id, quality: q, storage_path: p }, { onConflict: 'video_id,quality' });
                            refresh();
                          }}
                        />
                      ))}
                    </div>
                  </div>
                )}
                <div className="stack" style={{ gap: 10 }}>
                  <div className="small muted">Subtitles: {video.video_captions.map((c) => `${c.label} (${c.language})`).join(', ') || 'none'}</div>
                  <div className="row wrap">
                    {[
                      ['en', 'English'],
                      ['uz', 'Oʻzbekcha'],
                      ['ru', 'Русский'],
                    ].map(([lang, label]) => (
                      <UploadButton
                        key={lang}
                        bucket="course-media"
                        accept=".vtt,text/vtt"
                        label={`${label} .vtt`}
                        path={() => `${base}/captions-${lang}.vtt`}
                        onUploaded={async (p) => {
                          await supabase.from('video_captions').upsert({ video_id: video.id, language: lang, label, storage_path: p }, { onConflict: 'video_id,language' });
                          refresh();
                        }}
                      />
                    ))}
                  </div>
                </div>
              </>
            ) : (
              <div className="stack">
                <div className="row wrap">
                  <UploadButton bucket="course-media" accept="video/mp4,video/quicktime" label="Upload MP4 (faststart)" path={(f) => `${base}/video-${Date.now()}.${f.name.split('.').pop()}`} onUploaded={(p) => attachVideo({ provider: 'storage', storage_path: p })} />
                  <span className="faint small">or link a streaming provider</span>
                </div>
                <div className="row">
                  <Select value={external.provider} onChange={(e) => setExternal({ ...external, provider: e.target.value })} style={{ width: 190 }}>
                    <option value="mux">Mux playback ID</option>
                    <option value="cloudflare_stream">Cloudflare Stream ID</option>
                    <option value="external">HTTPS HLS/MP4 URL</option>
                  </Select>
                  <Input value={external.value} onChange={(e) => setExternal({ ...external, value: e.target.value })} placeholder={external.provider === 'external' ? 'https://…/master.m3u8' : 'Playback ID'} />
                  <Button
                    disabled={!external.value.trim()}
                    onClick={() =>
                      attachVideo(external.provider === 'external' ? { provider: 'external', external_url: external.value.trim() } : { provider: external.provider as VideoRow['provider'], external_id: external.value.trim() }).catch((e) => toast('error', errMsg(e)))
                    }>
                    Attach
                  </Button>
                </div>
                <p className="small faint" style={{ margin: 0 }}>
                  For large catalogues prefer a streaming provider (adaptive bitrate, global CDN). Uploaded files are served through signed URLs only to entitled learners.
                </p>
              </div>
            )}
          </div>

          <div className="card stack">
            <h3 style={{ margin: 0 }}>
              <FileText size={16} style={{ verticalAlign: -3 }} /> Downloadable resources
            </h3>
            {(resources.data ?? []).map((r) => (
              <div key={r.id} className="row">
                <Badge>{r.kind}</Badge>
                <span className="grow">{r.title}</span>
                <span className="small faint">{r.size_bytes ? `${(r.size_bytes / 1024 / 1024).toFixed(1)} MB` : r.external_url ? 'link' : ''}</span>
                <label className="check small">
                  <input type="checkbox" checked={r.allow_offline} onChange={async (e) => { await supabase.from('resources').update({ allow_offline: e.target.checked }).eq('id', r.id); refresh(); }} />
                  offline
                </label>
                <ConfirmButton
                  label="Remove"
                  onConfirm={async () => {
                    if (r.storage_path) await supabase.storage.from('resources').remove([r.storage_path]);
                    await supabase.from('resources').delete().eq('id', r.id);
                    refresh();
                  }}
                />
              </div>
            ))}
            <div className="row wrap">
              <UploadButton
                bucket="resources"
                label="Upload file"
                path={(f) => `${base}/${Date.now()}-${safeFileName(f.name)}`}
                onUploaded={async (p, f) => {
                  must(await supabase.from('resources').insert({ course_id: l.course_id, lesson_id: l.id, title: f.name, kind: kindFor(f.type, f.name), storage_path: p, size_bytes: f.size, mime_type: f.type || null, position: resources.data?.length ?? 0 }).select('id'));
                  refresh();
                }}
              />
            </div>
            <div className="row">
              <Input placeholder="Link title" value={link.title} onChange={(e) => setLink({ ...link, title: e.target.value })} />
              <Input placeholder="https://" value={link.url} onChange={(e) => setLink({ ...link, url: e.target.value })} />
              <Button
                icon={<Link2 />}
                disabled={!link.title.trim() || !/^https:\/\//.test(link.url)}
                onClick={async () => {
                  const { error } = await supabase.from('resources').insert({ course_id: l.course_id, lesson_id: l.id, title: link.title.trim(), kind: 'link', external_url: link.url.trim(), allow_offline: false });
                  if (error) return toast('error', error.message);
                  setLink({ title: '', url: '' });
                  refresh();
                }}>
                Add link
              </Button>
            </div>
          </div>
        </div>

        <div className="stack" style={{ position: 'sticky', top: 16 }}>
          <div className="card stack">
            <Field label="Title">
              <Input value={meta.title} onChange={(e) => setMeta({ ...meta, title: e.target.value })} />
            </Field>
            <Field label="Summary">
              <Textarea value={meta.summary ?? ''} onChange={(e) => setMeta({ ...meta, summary: e.target.value || null })} rows={3} />
            </Field>
            <div className="grid-2">
              <Field label="Type">
                <Select value={meta.type} onChange={(e) => setMeta({ ...meta, type: e.target.value })}>
                  {LESSON_TYPES.map((t) => (
                    <option key={t}>{t}</option>
                  ))}
                </Select>
              </Field>
              <Field label="Minutes">
                <Input type="number" min={0} max={600} value={Math.round(meta.duration_seconds / 60)} onChange={(e) => setMeta({ ...meta, duration_seconds: Math.max(0, Number(e.target.value)) * 60 })} />
              </Field>
            </div>
            <div className="grid-2">
              <Field label="XP">
                <Input type="number" min={0} max={1000} value={meta.xp} onChange={(e) => setMeta({ ...meta, xp: Number(e.target.value) })} />
              </Field>
              <Field label="Status">
                <Select value={meta.status} onChange={(e) => setMeta({ ...meta, status: e.target.value })} data-testid="lesson-status">
                  {(isEditor ? STATUSES : ['draft', 'in_review', ...(STATUSES.includes(meta.status as never) && !['draft', 'in_review'].includes(meta.status) ? [meta.status] : [])]).map((s) => (
                    <option key={s} value={s}>
                      {s.replace('_', ' ')}
                    </option>
                  ))}
                </Select>
              </Field>
            </div>
            <Switch label="Free preview (premium courses)" checked={meta.is_preview} onChange={(v) => setMeta({ ...meta, is_preview: v })} />
            <Switch label="Required for completion" checked={meta.is_required} onChange={(v) => setMeta({ ...meta, is_required: v })} />
            <Button variant="primary" icon={<Save />} loading={saveMeta.isPending} onClick={() => saveMeta.mutate(meta)} data-testid="save-lesson">
              Save lesson
            </Button>
          </div>

          <div className="card stack">
            <h3 style={{ margin: 0 }}>
              <ClipboardList size={16} style={{ verticalAlign: -3 }} /> Quiz
            </h3>
            {quiz.data ? (
              <div className="row">
                <Link to={`/quizzes/${quiz.data.id}`} className="grow title">
                  {quiz.data.title}
                </Link>
                <StatusBadge status={quiz.data.status} />
              </div>
            ) : (
              <>
                <p className="small muted" style={{ margin: 0 }}>
                  Attach a knowledge check. Passing it completes this lesson.
                </p>
                <Button
                  icon={<Plus />}
                  onClick={async () => {
                    const { data, error } = await supabase
                      .from('quizzes')
                      .insert({ course_id: l.course_id, module_id: l.module_id, lesson_id: l.id, title: `${l.title} — check`, kind: 'knowledge_check', status: 'draft' })
                      .select('id')
                      .single();
                    if (error) return toast('error', error.message);
                    nav(`/quizzes/${data.id}`);
                  }}>
                  Create quiz
                </Button>
              </>
            )}
          </div>

          <AssignmentCard lesson={l} assignment={assignment.data as AssignmentRow | null} onChange={refresh} />
        </div>
      </div>
    </>
  );
}

interface AssignmentRow {
  id: string;
  title: string;
  brief_md: string | null;
  rubric_md: string | null;
  submission_type: string;
  is_project: boolean;
  max_score: number;
  status: string;
}

function AssignmentCard({ lesson, assignment, onChange }: { lesson: Lesson; assignment: AssignmentRow | null; onChange: () => void }) {
  const toast = useToast();
  const { isEditor } = useAuth();
  const [a, setA] = useState<AssignmentRow | null>(assignment);
  useEffect(() => setA(assignment), [assignment]);
  if (!a) {
    return (
      <div className="card stack">
        <h3 style={{ margin: 0 }}>Assignment / project</h3>
        <Button
          icon={<Plus />}
          onClick={async () => {
            const { error } = await supabase.from('assignments').insert({ course_id: lesson.course_id, module_id: lesson.module_id, lesson_id: lesson.id, title: lesson.title, status: 'draft', is_project: lesson.type === 'project' });
            if (error) toast('error', error.message);
            onChange();
          }}>
          Add assignment
        </Button>
      </div>
    );
  }
  return (
    <div className="card stack">
      <div className="row" style={{ justifyContent: 'space-between' }}>
        <h3 style={{ margin: 0 }}>Assignment</h3>
        <StatusBadge status={a.status} />
      </div>
      <Field label="Title">
        <Input value={a.title} onChange={(e) => setA({ ...a, title: e.target.value })} />
      </Field>
      <Field label="Brief (Markdown)">
        <Textarea value={a.brief_md ?? ''} onChange={(e) => setA({ ...a, brief_md: e.target.value })} rows={4} />
      </Field>
      <Field label="Rubric (Markdown)">
        <Textarea value={a.rubric_md ?? ''} onChange={(e) => setA({ ...a, rubric_md: e.target.value })} rows={4} />
      </Field>
      <div className="grid-2">
        <Field label="Submission">
          <Select value={a.submission_type} onChange={(e) => setA({ ...a, submission_type: e.target.value })}>
            {['any', 'text', 'url', 'file'].map((x) => (
              <option key={x}>{x}</option>
            ))}
          </Select>
        </Field>
        <Field label="Max score">
          <Input type="number" min={1} value={a.max_score} onChange={(e) => setA({ ...a, max_score: Number(e.target.value) })} />
        </Field>
      </div>
      <Field label="Status">
        <Select value={a.status} onChange={(e) => setA({ ...a, status: e.target.value })}>
          {(isEditor ? STATUSES : ['draft', 'in_review']).map((s) => (
            <option key={s} value={s}>
              {s.replace('_', ' ')}
            </option>
          ))}
        </Select>
      </Field>
      <Switch label="Project (portfolio piece)" checked={a.is_project} onChange={(v) => setA({ ...a, is_project: v })} />
      <Button
        icon={<Save />}
        onClick={async () => {
          const { id, ...patch } = a;
          const { error } = await supabase.from('assignments').update(patch).eq('id', id);
          if (error) toast('error', error.message);
          else toast('success', 'Assignment saved');
          onChange();
        }}>
        Save assignment
      </Button>
    </div>
  );
}
