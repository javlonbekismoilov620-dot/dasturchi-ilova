import type { TKey } from '@/i18n';

/** Error codes raised by the database RPCs (see supabase/migrations/*_rpc.sql). */
const KNOWN: Record<string, TKey> = {
  premium_required: 'errors.premiumRequired',
  lesson_locked: 'errors.lessonLocked',
  quiz_locked: 'errors.lessonLocked',
  assignment_locked: 'errors.lessonLocked',
  not_authenticated: 'errors.notAuthenticated',
  course_not_found: 'errors.notFound',
  lesson_not_found: 'errors.notFound',
  max_attempts_reached: 'errors.maxAttempts',
};

export class AppError extends Error {
  constructor(
    public code: string,
    message?: string,
  ) {
    super(message ?? code);
    this.name = 'AppError';
  }
}

export function errorCode(e: unknown): string {
  if (e instanceof AppError) return e.code;
  const msg = e instanceof Error ? e.message : typeof e === 'object' && e && 'message' in e ? String((e as { message: unknown }).message) : String(e);
  for (const code of Object.keys(KNOWN)) if (msg.includes(code)) return code;
  if (/network|fetch failed|Failed to fetch|timeout|ECONN/i.test(msg)) return 'network';
  return 'generic';
}

export function errorMessageKey(e: unknown): TKey {
  const code = errorCode(e);
  if (code === 'network') return 'errors.network';
  return KNOWN[code] ?? 'errors.generic';
}

/** Throw if a Supabase response carries an error. */
export function unwrap<T>(res: { data: T; error: { message: string; code?: string } | null }): T {
  if (res.error) throw new AppError(errorCode(res.error), res.error.message);
  return res.data;
}
