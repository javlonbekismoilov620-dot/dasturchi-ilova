import { Award, BarChart3, BookOpen, ClipboardCheck, CreditCard, FolderTree, LogOut, Megaphone, Route as RouteIcon, ScrollText, UserRound, Users } from 'lucide-react';
import { NavLink, Outlet } from 'react-router';

import { useAuth } from '../lib/auth';

const nav = [
  { section: 'Overview', items: [{ to: '/', label: 'Dashboard', icon: BarChart3, role: 'staff' }] },
  {
    section: 'Content',
    items: [
      { to: '/courses', label: 'Courses', icon: BookOpen, role: 'staff' },
      { to: '/categories', label: 'Categories', icon: FolderTree, role: 'editor' },
      { to: '/paths', label: 'Learning paths', icon: RouteIcon, role: 'editor' },
      { to: '/instructors', label: 'Instructors', icon: UserRound, role: 'editor' },
      { to: '/achievements', label: 'Achievements', icon: Award, role: 'editor' },
    ],
  },
  { section: 'Learners', items: [{ to: '/submissions', label: 'Submissions', icon: ClipboardCheck, role: 'staff' }, { to: '/users', label: 'Users & roles', icon: Users, role: 'admin' }] },
  {
    section: 'Business',
    items: [
      { to: '/billing', label: 'Plans & settings', icon: CreditCard, role: 'admin' },
      { to: '/announcements', label: 'Announcements', icon: Megaphone, role: 'admin' },
      { to: '/audit', label: 'Audit log', icon: ScrollText, role: 'admin' },
    ],
  },
] as const;

export function Layout() {
  const { session, isAdmin, isEditor, roles, signOut } = useAuth();
  const allowed = (role: string) => role === 'staff' || (role === 'editor' && isEditor) || (role === 'admin' && isAdmin);
  return (
    <div className="shell">
      <aside className="sidebar" aria-label="Main navigation">
        <div className="brand">
          <img src="/mark.svg" alt="" />
          <div>
            <div className="name">Mahorat</div>
            <div className="tag">Studio</div>
          </div>
        </div>
        {nav.map((group) => {
          const items = group.items.filter((i) => allowed(i.role));
          if (!items.length) return null;
          return (
            <div key={group.section}>
              <div className="nav-label">{group.section}</div>
              {items.map(({ to, label, icon: Icon }) => (
                <NavLink key={to} to={to} end={to === '/'} className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}>
                  <Icon />
                  {label}
                </NavLink>
              ))}
            </div>
          );
        })}
        <div className="sidebar-foot">
          <div className="small faint" style={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
            {session?.user.email}
          </div>
          <div className="pill-list">
            {roles.filter((r) => r !== 'student').map((r) => (
              <span key={r} className="badge accent">
                {r}
              </span>
            ))}
          </div>
          <button className="btn ghost sm" onClick={signOut} style={{ justifyContent: 'flex-start' }}>
            <LogOut /> Sign out
          </button>
        </div>
      </aside>
      <main className="main">
        <Outlet />
      </main>
    </div>
  );
}

export function PageHead({ title, subtitle, actions, crumbs }: { title: string; subtitle?: string; actions?: React.ReactNode; crumbs?: React.ReactNode }) {
  return (
    <header className="page-head">
      <div>
        {crumbs && <nav className="crumbs">{crumbs}</nav>}
        <h1>{title}</h1>
        {subtitle && <p>{subtitle}</p>}
      </div>
      {actions && <div className="row wrap">{actions}</div>}
    </header>
  );
}
