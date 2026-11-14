import { useCallback } from 'react';

import { type Locale, useLocale } from './index';

/**
 * Course content is authored in a base language (`courses.language`, English for the
 * starter library) and translated with per-locale overlays stored on the same row:
 * `translations: { uz: { title, summary, body_md, … }, ru: { … } }`.
 *
 * `localizeContent` walks API data and, for every object that carries `translations`,
 * shows the learner's language when a translation exists. Otherwise it keeps the
 * original text and marks the object `content_untranslated: true` so screens can say so
 * honestly. The query cache keeps the raw rows, so switching language re-renders
 * instantly (also offline) without refetching, and IDs and progress are never involved.
 */
export const UNTRANSLATED = 'content_untranslated';

const LANGUAGE_CODE = /^[a-z]{2}$/;

function isPlainObject(v: unknown): v is Record<string, unknown> {
  return v !== null && typeof v === 'object' && !Array.isArray(v);
}

function walk(value: unknown, locale: Locale, base: string): unknown {
  if (Array.isArray(value)) return value.map((v) => walk(v, locale, base));
  if (!isPlainObject(value)) return value;

  // A course (or lesson content) declares its base language; nested modules, lessons,
  // quizzes and answers inherit it.
  const ownBase = typeof value.language === 'string' && LANGUAGE_CODE.test(value.language) ? value.language : base;
  const out: Record<string, unknown> = {};
  for (const [key, v] of Object.entries(value)) {
    if (key !== 'translations') out[key] = walk(v, locale, ownBase);
  }

  if ('translations' in value && locale !== ownBase) {
    const overlay = isPlainObject(value.translations) ? value.translations[locale] : undefined;
    if (isPlainObject(overlay) && Object.keys(overlay).length > 0) {
      for (const [key, v] of Object.entries(overlay)) {
        if (typeof v === 'string' ? v.trim() !== '' : Array.isArray(v) && v.length > 0) out[key] = v;
      }
    } else {
      out[UNTRANSLATED] = true;
    }
  }
  return out;
}

export function localizeContent<T>(value: T, locale: Locale, baseLocale = 'en'): T {
  return walk(value, locale, baseLocale) as T;
}

/** Stable per-locale selector for React Query's `select` option and mutation results. */
export function useContentLocalizer() {
  const locale = useLocale();
  return useCallback(<T,>(data: T): T => localizeContent(data, locale), [locale]);
}
