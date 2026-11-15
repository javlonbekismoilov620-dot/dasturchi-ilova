// Shared helpers for editing per-locale content overlays (`translations` columns).
export type Locale = 'en' | 'uz' | 'ru';
export const CONTENT_LOCALES: { code: Locale; label: string }[] = [
  { code: 'uz', label: 'Oʻzbekcha' },
  { code: 'ru', label: 'Русский' },
  { code: 'en', label: 'English' },
];
export type Translations = Partial<Record<Locale, Record<string, unknown>>>;
export type TrField = { key: string; label: string; kind?: 'text' | 'markdown' | 'list' };
export type TrRow = { translations?: Translations | null } & Record<string, unknown>;

export const isFilled = (v: unknown) => (Array.isArray(v) ? v.some((x) => String(x).trim()) : typeof v === 'string' && v.trim() !== '');

/** Locales an editor can translate into, i.e. every supported locale except the source. */
export function targetLocales(baseLanguage: string) {
  return CONTENT_LOCALES.filter((l) => l.code !== baseLanguage);
}

/** Completion of one row in one locale, for the badge next to each editor. */
export function translationStatus(row: TrRow, fields: TrField[], locale: Locale) {
  const needed = fields.filter((f) => isFilled(row[f.key]));
  const done = needed.filter((f) => isFilled(row.translations?.[locale]?.[f.key]));
  return { done: done.length, total: needed.length, complete: done.length === needed.length };
}

