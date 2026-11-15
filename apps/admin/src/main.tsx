import './styles.css';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { createBrowserRouter, Navigate, RouterProvider } from 'react-router';

import { Layout } from './components/Layout';
import { Loading, ToastProvider } from './components/ui';
import { AuthProvider, useAuth } from './lib/auth';
import { Achievements } from './pages/Achievements';
import { Announcements } from './pages/Announcements';
import { Audit } from './pages/Audit';
import { Billing } from './pages/Billing';
import { Categories } from './pages/Categories';
import { CourseEditor } from './pages/CourseEditor';
import { Courses } from './pages/Courses';
import { Dashboard } from './pages/Dashboard';
import { Instructors } from './pages/Instructors';
import { LessonEditor } from './pages/LessonEditor';
import { Login } from './pages/Login';
import { Paths } from './pages/Paths';
import { QuizEditor } from './pages/QuizEditor';
import { Submissions } from './pages/Submissions';
import { Users } from './pages/Users';

const queryClient = new QueryClient({ defaultOptions: { queries: { staleTime: 15_000, retry: 1, refetchOnWindowFocus: false } } });

function Gate({ need = 'staff', children }: { need?: 'staff' | 'editor' | 'admin'; children: React.ReactNode }) {
  const { loading, session, isStaff, isEditor, isAdmin } = useAuth();
  if (loading) return <Loading />;
  if (!session || !isStaff) return <Login />;
  if ((need === 'editor' && !isEditor) || (need === 'admin' && !isAdmin)) return <Navigate to="/" replace />;
  return <>{children}</>;
}

const router = createBrowserRouter([
  {
    element: (
      <Gate>
        <Layout />
      </Gate>
    ),
    children: [
      { path: '/', element: <Dashboard /> },
      { path: '/courses', element: <Courses /> },
      { path: '/courses/:id', element: <CourseEditor /> },
      { path: '/lessons/:id', element: <LessonEditor /> },
      { path: '/quizzes/:id', element: <QuizEditor /> },
      { path: '/categories', element: <Gate need="editor"><Categories /></Gate> },
      { path: '/paths', element: <Gate need="editor"><Paths /></Gate> },
      { path: '/instructors', element: <Gate need="editor"><Instructors /></Gate> },
      { path: '/achievements', element: <Gate need="editor"><Achievements /></Gate> },
      { path: '/submissions', element: <Submissions /> },
      { path: '/users', element: <Gate need="admin"><Users /></Gate> },
      { path: '/billing', element: <Gate need="admin"><Billing /></Gate> },
      { path: '/announcements', element: <Gate need="admin"><Announcements /></Gate> },
      { path: '/audit', element: <Gate need="admin"><Audit /></Gate> },
      { path: '*', element: <Navigate to="/" replace /> },
    ],
  },
]);

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <ToastProvider>
          <RouterProvider router={router} />
        </ToastProvider>
      </AuthProvider>
    </QueryClientProvider>
  </StrictMode>,
);
