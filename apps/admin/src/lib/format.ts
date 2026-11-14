export const slugify = (s: string) =>
  s
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[ʻʼ'’]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 80);

export const fmtDate = (iso?: string | null) => (iso ? new Date(iso).toLocaleDateString(undefined, { day: 'numeric', month: 'short', year: 'numeric' }) : '—');
export const fmtDateTime = (iso?: string | null) => (iso ? new Date(iso).toLocaleString(undefined, { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' }) : '—');
export const fmtMinutes = (seconds: number) => {
  const m = Math.round(seconds / 60);
  return m < 60 ? `${m} min` : `${Math.floor(m / 60)} h ${m % 60} min`;
};
export const errMsg = (e: unknown) => (e instanceof Error ? e.message : String(e));

export const LEVELS = ['zero', 'beginner', 'intermediate', 'advanced', 'professional', 'expert'] as const;
export const STATUSES = ['draft', 'in_review', 'published', 'archived'] as const;
export const LESSON_TYPES = ['article', 'video', 'exercise', 'quiz', 'assignment', 'project'] as const;
export const PATTERNS = ['grid', 'brackets', 'waves', 'isometric', 'frames', 'hex', 'circles', 'orbits'] as const;
export type Status = (typeof STATUSES)[number];
