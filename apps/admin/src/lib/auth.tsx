import type { Session } from '@supabase/supabase-js';
import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';

import { supabase } from './supabase';

export type Role = 'student' | 'instructor' | 'editor' | 'admin';

interface AuthState {
  loading: boolean;
  session: Session | null;
  roles: Role[];
  isAdmin: boolean;
  isEditor: boolean;
  isStaff: boolean;
  signOut: () => Promise<void>;
}

const Ctx = createContext<AuthState | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [roles, setRoles] = useState<Role[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async (s: Session | null) => {
      setSession(s);
      if (!s) {
        setRoles([]);
        setLoading(false);
        return;
      }
      const { data } = await supabase.from('user_roles').select('role').eq('user_id', s.user.id);
      setRoles((data ?? []).map((r: { role: Role }) => r.role));
      setLoading(false);
    };
    supabase.auth.getSession().then(({ data }) => load(data.session));
    const { data: sub } = supabase.auth.onAuthStateChange((_e, s) => void load(s));
    return () => sub.subscription.unsubscribe();
  }, []);

  const value = useMemo<AuthState>(() => {
    const isAdmin = roles.includes('admin');
    const isEditor = isAdmin || roles.includes('editor');
    return {
      loading,
      session,
      roles,
      isAdmin,
      isEditor,
      isStaff: isEditor || roles.includes('instructor'),
      signOut: async () => {
        await supabase.auth.signOut();
      },
    };
  }, [loading, session, roles]);

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useAuth() {
  const v = useContext(Ctx);
  if (!v) throw new Error('useAuth outside AuthProvider');
  return v;
}
