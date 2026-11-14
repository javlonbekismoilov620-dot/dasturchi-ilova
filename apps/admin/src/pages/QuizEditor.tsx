import { useQuery, useQueryClient } from '@tanstack/react-query';
import { ArrowDown, ArrowUp, ChevronRight, Plus, Save } from 'lucide-react';
import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router';

import { PageHead } from '../components/Layout';
import { LocalePicker, TranslationEditor } from '../components/Translations';
import { targetLocales, type Locale, type Translations } from '../lib/translations';
import { Badge, Button, ConfirmButton, Empty, Field, Input, Loading, Select, StatusBadge, Tabs, Textarea, useToast } from '../components/ui';
import { useAuth } from '../lib/auth';
import { errMsg, STATUSES } from '../lib/format';
import { must, supabase } from '../lib/supabase';

interface Answer {
  id: string;
  label_md: string;
  is_correct: boolean;
  feedback_md: string | null;
  position: number;
  translations?: Translations;
}
interface Question {
  id: string;
  type: 'single_choice' | 'multiple_choice' | 'true_false' | 'short_answer';
  prompt_md: string;
  code_snippet: string | null;
  explanation_md: string | null;
  points: number;
  position: number;
  answers: Answer[];
  translations?: Translations;
}
interface Quiz {
  id: string;
  title: string;
  description: string | null;
  kind: string;
  pass_score_percent: number;
  time_limit_seconds: number | null;
  max_attempts: number | null;
  xp: number;
  status: string;
  course_id: string;
  lesson_id: string | null;
  questions: Question[];
  translations?: Translations;
  course?: { language: string } | null;
}

/** Server-side grading needs at least one correct answer (single choice: exactly one). */
export function questionProblems(q: Pick<Question, 'type' | 'answers'>) {
  const correct = q.answers.filter((a) => a.is_correct).length;
  if (q.type === 'short_answer') return correct === 0 ? 'Add at least one accepted answer.' : null;
  if (q.answers.length < 2) return 'Add at least two options.';
  if (correct === 0) return 'Mark the correct option.';
  if ((q.type === 'single_choice' || q.type === 'true_false') && correct > 1) return 'Only one option can be correct.';
  return null;
}

export function QuizEditor() {
  const { id } = useParams<{ id: string }>();
  const nav = useNavigate();
  const qc = useQueryClient();
  const toast = useToast();
  const { isEditor } = useAuth();
  const key = ['quiz', id];
  const quiz = useQuery({
    queryKey: key,
    queryFn: async () => must(await supabase.from('quizzes').select('*, course:courses(language), questions(*, answers(*))').eq('id', id!).order('position', { referencedTable: 'questions' }).single()) as Quiz,
  });
  const [settings, setSettings] = useState<Quiz | null>(null);
  const [tab, setTab] = useState<'questions' | 'translations'>('questions');
  useEffect(() => {
    if (quiz.data) setSettings(quiz.data);
  }, [quiz.data]);
  const refresh = () => qc.invalidateQueries({ queryKey: key });
  const run = async (p: PromiseLike<{ error: { message: string } | null }>) => {
    const { error } = await p;
    if (error) toast('error', error.message);
    refresh();
  };

  if (quiz.isLoading || !settings) return <Loading />;
  if (quiz.error) return <Empty title="Quiz not available" body={errMsg(quiz.error)} />;
  const q = quiz.data!;
  const questions = [...q.questions].sort((a, b) => a.position - b.position);
  const problems = questions.map(questionProblems).filter(Boolean).length;

  return (
    <>
      <PageHead
        crumbs={
          <>
            <Link to={`/courses/${q.course_id}`}>Course</Link>
            {q.lesson_id && (
              <>
                <ChevronRight size={14} /> <Link to={`/lessons/${q.lesson_id}`}>Lesson</Link>
              </>
            )}
          </>
        }
        title={q.title}
        subtitle={`${questions.length} questions${problems ? ` · ${problems} need attention` : ''}`}
        actions={
          <>
            <StatusBadge status={q.status} />
            <ConfirmButton
              onConfirm={async () => {
                await run(supabase.from('quizzes').delete().eq('id', id!));
                nav(q.lesson_id ? `/lessons/${q.lesson_id}` : `/courses/${q.course_id}`);
              }}
            />
          </>
        }
      />
      <Tabs
        value={tab}
        onChange={setTab}
        tabs={[
          { value: 'questions', label: 'Questions' },
          { value: 'translations', label: 'Translations' },
        ]}
      />
      {tab === 'translations' ? (
        <QuizTranslations quiz={q} questions={questions} onSaved={refresh} />
      ) : (
      <div className="grid-2" style={{ gridTemplateColumns: 'minmax(0,1fr) 320px', alignItems: 'start' }}>
        <div className="stack">
          {questions.length === 0 && <Empty title="No questions yet" body="Add a question below." />}
          {questions.map((question, i) => (
            <QuestionCard
              key={question.id}
              index={i}
              total={questions.length}
              question={question}
              onChanged={refresh}
              onMove={async (dir) => {
                const order = [...questions];
                const [x] = order.splice(i, 1);
                order.splice(i + dir, 0, x);
                await Promise.all(order.map((qq, pos) => supabase.from('questions').update({ position: pos }).eq('id', qq.id)));
                refresh();
              }}
            />
          ))}
          <div className="row wrap">
            {(['single_choice', 'multiple_choice', 'true_false', 'short_answer'] as const).map((type) => (
              <Button
                key={type}
                icon={<Plus />}
                onClick={async () => {
                  const { data, error } = await supabase.from('questions').insert({ quiz_id: id, type, prompt_md: 'New question', position: questions.length }).select('id').single();
                  if (error) return toast('error', error.message);
                  if (type === 'true_false')
                    await supabase.from('answers').insert([
                      { question_id: data.id, label_md: 'True', is_correct: true, position: 0 },
                      { question_id: data.id, label_md: 'False', is_correct: false, position: 1 },
                    ]);
                  refresh();
                }}
                data-testid={`add-${type}`}>
                {type.replace('_', ' ')}
              </Button>
            ))}
          </div>
        </div>
        <div className="card stack" style={{ position: 'sticky', top: 16 }}>
          <Field label="Title">
            <Input value={settings.title} onChange={(e) => setSettings({ ...settings, title: e.target.value })} />
          </Field>
          <Field label="Kind">
            <Select value={settings.kind} onChange={(e) => setSettings({ ...settings, kind: e.target.value })}>
              <option value="knowledge_check">Knowledge check</option>
              <option value="module_exam">Module exam</option>
              <option value="final_assessment">Final assessment (required for certificate)</option>
            </Select>
          </Field>
          <div className="grid-2">
            <Field label="Pass mark %">
              <Input type="number" min={0} max={100} value={settings.pass_score_percent} onChange={(e) => setSettings({ ...settings, pass_score_percent: Number(e.target.value) })} />
            </Field>
            <Field label="XP on pass">
              <Input type="number" min={0} value={settings.xp} onChange={(e) => setSettings({ ...settings, xp: Number(e.target.value) })} />
            </Field>
          </div>
          <div className="grid-2">
            <Field label="Max attempts" hint="Empty = unlimited">
              <Input type="number" min={1} value={settings.max_attempts ?? ''} onChange={(e) => setSettings({ ...settings, max_attempts: e.target.value ? Number(e.target.value) : null })} />
            </Field>
            <Field label="Time limit (min)" hint="Empty = none">
              <Input type="number" min={1} value={settings.time_limit_seconds ? settings.time_limit_seconds / 60 : ''} onChange={(e) => setSettings({ ...settings, time_limit_seconds: e.target.value ? Number(e.target.value) * 60 : null })} />
            </Field>
          </div>
          <Field label="Status">
            <Select value={settings.status} onChange={(e) => setSettings({ ...settings, status: e.target.value })}>
              {(isEditor ? STATUSES : ['draft', 'in_review']).map((s) => (
                <option key={s} value={s}>
                  {s.replace('_', ' ')}
                </option>
              ))}
            </Select>
          </Field>
          {problems > 0 && settings.status === 'published' && <p className="badge warning">Fix question issues before publishing.</p>}
          <Button
            variant="primary"
            icon={<Save />}
            disabled={problems > 0 && settings.status === 'published'}
            onClick={() => {
              const { title, kind, pass_score_percent, xp, max_attempts, time_limit_seconds, status } = settings;
              void run(supabase.from('quizzes').update({ title, kind, pass_score_percent, xp, max_attempts, time_limit_seconds, status }).eq('id', id!));
              toast('success', 'Quiz saved');
            }}>
            Save settings
          </Button>
        </div>
      </div>
      )}
    </>
  );
}

function QuizTranslations({ quiz, questions, onSaved }: { quiz: Quiz; questions: Question[]; onSaved: () => void }) {
  const base = quiz.course?.language ?? 'en';
  const [locale, setLocale] = useState<Locale>(targetLocales(base)[0].code);
  return (
    <div className="stack">
      <div className="card">
        <LocalePicker value={locale} onChange={setLocale} baseLanguage={base} />
        <p className="muted small" style={{ marginBottom: 0 }}>
          Translate the wording only — correct answers, order and scoring stay shared across languages. For short-answer questions, a translated accepted answer is also accepted when grading.
        </p>
      </div>
      <TranslationEditor table="quizzes" row={quiz as never} fields={[{ key: 'title', label: 'Quiz title' }, { key: 'description', label: 'Description' }]} locale={locale} title="Quiz" onSaved={onSaved} />
      {questions.map((qq, i) => (
        <div key={qq.id} className="stack" style={{ gap: 8 }}>
          <TranslationEditor
            table="questions"
            row={qq as never}
            fields={[
              { key: 'prompt_md', label: 'Question', kind: 'markdown' },
              { key: 'code_snippet', label: 'Code snippet (translate comments and on-screen text only)', kind: 'markdown' },
              { key: 'explanation_md', label: 'Explanation shown after answering', kind: 'markdown' },
            ]}
            locale={locale}
            title={`Question ${i + 1}`}
            onSaved={onSaved}
          />
          {[...qq.answers]
            .sort((a, b) => a.position - b.position)
            .map((a, j) => (
              <div key={a.id} style={{ marginLeft: 24 }}>
                <TranslationEditor
                  table="answers"
                  row={a as never}
                  fields={[
                    { key: 'label_md', label: qq.type === 'short_answer' ? 'Accepted answer' : 'Option' },
                    { key: 'feedback_md', label: 'Feedback' },
                  ]}
                  locale={locale}
                  title={`${a.is_correct ? '✓ ' : ''}Option ${j + 1}`}
                  onSaved={onSaved}
                />
              </div>
            ))}
        </div>
      ))}
    </div>
  );
}

function QuestionCard({ question, index, total, onChanged, onMove }: { question: Question; index: number; total: number; onChanged: () => void; onMove: (dir: -1 | 1) => void }) {
  const toast = useToast();
  const [q, setQ] = useState(question);
  useEffect(() => setQ(question), [question]);
  const answers = [...q.answers].sort((a, b) => a.position - b.position);
  const problem = questionProblems(q);
  const save = async () => {
    const { error } = await supabase.from('questions').update({ prompt_md: q.prompt_md, code_snippet: q.code_snippet || null, explanation_md: q.explanation_md || null, points: q.points }).eq('id', q.id);
    if (error) toast('error', error.message);
    await Promise.all(answers.map((a) => supabase.from('answers').update({ label_md: a.label_md, is_correct: a.is_correct, feedback_md: a.feedback_md || null }).eq('id', a.id)));
    toast('success', `Question ${index + 1} saved`);
    onChanged();
  };
  const setAnswer = (id: string, patch: Partial<Answer>) =>
    setQ({ ...q, answers: q.answers.map((a) => (a.id === id ? { ...a, ...patch } : q.type !== 'multiple_choice' && q.type !== 'short_answer' && patch.is_correct ? { ...a, is_correct: false } : a)) });

  return (
    <section className="card stack">
      <div className="row">
        <Badge tone="accent">Q{index + 1}</Badge>
        <Badge>{q.type.replace('_', ' ')}</Badge>
        {problem && <Badge tone="warning">{problem}</Badge>}
        <span className="grow" />
        <Button size="sm" variant="ghost" icon={<ArrowUp />} disabled={index === 0} onClick={() => onMove(-1)} aria-label="Move up" />
        <Button size="sm" variant="ghost" icon={<ArrowDown />} disabled={index === total - 1} onClick={() => onMove(1)} aria-label="Move down" />
        <ConfirmButton onConfirm={async () => { await supabase.from('questions').delete().eq('id', q.id); onChanged(); }} />
      </div>
      <Field label="Prompt (Markdown)">
        <Textarea value={q.prompt_md} onChange={(e) => setQ({ ...q, prompt_md: e.target.value })} rows={2} />
      </Field>
      <Field label="Code snippet (optional)">
        <Textarea code style={{ minHeight: 60 }} value={q.code_snippet ?? ''} onChange={(e) => setQ({ ...q, code_snippet: e.target.value })} />
      </Field>
      <div className="stack" style={{ gap: 8 }}>
        <span className="small muted">{q.type === 'short_answer' ? 'Accepted answers (case and spacing are ignored)' : 'Options — tick the correct one(s)'}</span>
        {answers.map((a) => (
          <div key={a.id} className="row" style={{ alignItems: 'flex-start' }}>
            {q.type !== 'short_answer' && (
              <input type={q.type === 'multiple_choice' ? 'checkbox' : 'radio'} name={`q-${q.id}`} checked={a.is_correct} onChange={(e) => setAnswer(a.id, { is_correct: e.target.checked })} style={{ marginTop: 12, accentColor: 'var(--accent)' }} aria-label="Correct" />
            )}
            <div className="grow stack" style={{ gap: 6 }}>
              <Input value={a.label_md} onChange={(e) => setAnswer(a.id, { label_md: e.target.value })} />
              {q.type !== 'short_answer' && <Input value={a.feedback_md ?? ''} placeholder="Feedback shown if chosen (why it’s right or wrong)" onChange={(e) => setAnswer(a.id, { feedback_md: e.target.value })} />}
            </div>
            <ConfirmButton label="×" confirmLabel="Remove?" onConfirm={async () => { await supabase.from('answers').delete().eq('id', a.id); onChanged(); }} />
          </div>
        ))}
        {q.type !== 'true_false' && (
          <Button
            size="sm"
            icon={<Plus />}
            onClick={async () => {
              await supabase.from('answers').insert({ question_id: q.id, label_md: q.type === 'short_answer' ? 'accepted answer' : 'New option', is_correct: q.type === 'short_answer', position: answers.length });
              onChanged();
            }}>
            {q.type === 'short_answer' ? 'Add accepted answer' : 'Add option'}
          </Button>
        )}
      </div>
      <Field label="Explanation shown after answering (Markdown)">
        <Textarea value={q.explanation_md ?? ''} onChange={(e) => setQ({ ...q, explanation_md: e.target.value })} rows={2} />
      </Field>
      <div className="row">
        <Field label="Points">
          <Input type="number" min={1} max={100} value={q.points} onChange={(e) => setQ({ ...q, points: Number(e.target.value) })} style={{ width: 90 }} />
        </Field>
        <span className="grow" />
        <Button variant="primary" icon={<Save />} onClick={save}>
          Save question
        </Button>
      </div>
    </section>
  );
}
