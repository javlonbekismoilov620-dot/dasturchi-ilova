import { createClient } from '@supabase/supabase-js';

const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const key = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;

export const configured = !!url && !!key;

/**
 * Browser client using the public anon key. Everything this dashboard can do is
 * decided server-side by the signed-in user's roles (RLS + role-checked RPCs).
 */
export const supabase = createClient(url ?? 'http://localhost', key ?? 'missing', {
  auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true, flowType: 'pkce' },
  global: { headers: { 'x-client-info': 'mahorat-studio/1.0' } },
});

/** Throws on Supabase errors so react-query surfaces them. */
export function must<T>(res: { data: T; error: { message: string } | null }): T {
  if (res.error) throw new Error(res.error.message);
  return res.data;
}

export const publicUrl = (bucket: string, path: string) => supabase.storage.from(bucket).getPublicUrl(path).data.publicUrl;
