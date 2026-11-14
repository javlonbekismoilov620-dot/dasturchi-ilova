import { useQuery } from '@tanstack/react-query';
import { Link } from 'react-router';

import { PageHead } from '../components/Layout';
import { Empty, Loading } from '../components/ui';
import { useAuth } from '../lib/auth';
import { must, supabase } from '../lib/supabase';

interface Stats {
  users: number;
  new_users_30d: number;
  active_learners_7d: number;
  premium_subscribers: number;
  courses: Record<'published' | 'in_review' | 'draft', number>;
  lessons: Record<'published' | 'in_review' | 'draft', number>;
  enrollments: number;
  completions: number;
  certificates: number;
  pending_submissions: number;
  quiz_attempts_30d: number;
  signups_by_day: { date: string; count: number }[];
  learning_minutes_by_day: { date: string; minutes: number }[];
  top_courses: { id: string; title: string; enrollment_count: number; completions: number }[];
}

function Bars({ data, label }: { data: { date: string; value: number }[]; label: string }) {
  const max = Math.max(1, ...data.map((d) => d.value));
  const total = data.reduce((n, d) => n + d.value, 0);
  return (
    <div className="card">
      <div className="row" style={{ justifyContent: 'space-between', marginBottom: 14 }}>
        <h3 style={{ margin: 0 }}>{label}</h3>
        <span className="muted small">{total.toLocaleString()} in 30 days</span>
      </div>
      <div className="bars" role="img" aria-label={`${label}: ${total} over 30 days`}>
        {data.map((d) => (
          <div key={d.date} style={{ height: `${(d.value / max) * 100}%` }} title={`${d.date}: ${d.value}`} />
        ))}
      </div>
    </div>
  );
}

const Kpi = ({ label, value, hint }: { label: string; value: number | string; hint?: string }) => (
  <div className="card kpi">
    <span className="label">{label}</span>
    <span className="value">{typeof value === 'number' ? value.toLocaleString() : value}</span>
    {hint && <span className="hint">{hint}</span>}
  </div>
);

export function Dashboard() {
  const { isEditor } = useAuth();
  const stats = useQuery({ queryKey: ['stats'], enabled: isEditor, queryFn: async () => must(await supabase.rpc('admin_dashboard_stats')) as Stats });

  if (!isEditor) {
    return (
      <>
        <PageHead title="Welcome" subtitle="As an instructor you can draft courses and lessons and send them for editorial review." />
        <Link className="btn primary" to="/courses">
          Open my courses
        </Link>
      </>
    );
  }
  if (stats.isLoading) return <Loading />;
  if (stats.error || !stats.data) return <Empty title="Could not load statistics" body={String(stats.error)} />;
  const s = stats.data;
  return (
    <>
      <PageHead title="Dashboard" subtitle="Learners, content pipeline and engagement at a glance." />
      <div className="stack">
        <div className="grid-4">
          <Kpi label="Learners" value={s.users} hint={`+${s.new_users_30d} in 30 days`} />
          <Kpi label="Active (7 days)" value={s.active_learners_7d} />
          <Kpi label="Premium" value={s.premium_subscribers} />
          <Kpi label="Pending reviews" value={s.pending_submissions} hint="Assignment submissions" />
        </div>
        <div className="grid-4">
          <Kpi label="Enrollments" value={s.enrollments} />
          <Kpi label="Completions" value={s.completions} hint={s.enrollments ? `${Math.round((s.completions / s.enrollments) * 100)}% completion rate` : undefined} />
          <Kpi label="Certificates" value={s.certificates} />
          <Kpi label="Quiz attempts" value={s.quiz_attempts_30d} hint="Last 30 days" />
        </div>
        <div className="grid-2">
          <Bars label="New learners" data={s.signups_by_day.map((d) => ({ date: d.date, value: d.count }))} />
          <Bars label="Learning minutes" data={s.learning_minutes_by_day.map((d) => ({ date: d.date, value: Number(d.minutes) }))} />
        </div>
        <div className="grid-2">
          <div className="card">
            <h3>Content pipeline</h3>
            <table className="table">
              <thead>
                <tr>
                  <th />
                  <th>Draft</th>
                  <th>In review</th>
                  <th>Published</th>
                </tr>
              </thead>
              <tbody>
                {(['courses', 'lessons'] as const).map((k) => (
                  <tr key={k}>
                    <td className="title" style={{ textTransform: 'capitalize' }}>
                      {k}
                    </td>
                    <td>{s[k].draft}</td>
                    <td>
                      <span className={s[k].in_review ? 'badge warning' : ''}>{s[k].in_review}</span>
                    </td>
                    <td>{s[k].published}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="card">
            <h3>Top courses</h3>
            <table className="table">
              <tbody>
                {s.top_courses.map((c) => (
                  <tr key={c.id}>
                    <td className="title">
                      <Link to={`/courses/${c.id}`}>{c.title}</Link>
                    </td>
                    <td className="muted small">{c.enrollment_count} enrolled</td>
                    <td className="muted small">{c.completions} completed</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </>
  );
}
