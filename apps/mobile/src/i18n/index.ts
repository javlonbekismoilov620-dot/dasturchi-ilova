import { getLocales } from 'expo-localization';
import { useCallback, useMemo } from 'react';

import { usePreferences } from '@/stores/preferences';

import en, { type Dictionary, type PluralForms } from './en';
import ru from './ru';
import uz from './uz';

export type Locale = 'en' | 'uz' | 'ru';
export const LOCALES: { code: Locale; nativeName: string }[] = [
  { code: 'en', nativeName: 'English' },
  { code: 'uz', nativeName: 'Oʻzbekcha' },
  { code: 'ru', nativeName: 'Русский' },
];

const dictionaries: Record<Locale, Dictionary> = { en, uz, ru };

type En = typeof en;
type IsPlural<T> = T extends { one: string; other: string } ? true : false;
type Leaves<T, P extends string = ''> = {
  [K in keyof T & string]: T[K] extends string
    ? `${P}${K}`
    : IsPlural<T[K]> extends true
      ? never
      : Leaves<T[K], `${P}${K}.`>;
}[keyof T & string];
type PluralLeaves<T, P extends string = ''> = {
  [K in keyof T & string]: T[K] extends string
    ? never
    : IsPlural<T[K]> extends true
      ? `${P}${K}`
      : PluralLeaves<T[K], `${P}${K}.`>;
}[keyof T & string];

export type TKey = Leaves<En>;
export type TPluralKey = PluralLeaves<En>;
export type TParams = Record<string, string | number>;

export function deviceLocale(): Locale {
  for (const l of getLocales()) {
    const code = (l.languageCode ?? '').toLowerCase();
    if (code === 'uz' || code === 'ru' || code === 'en') return code;
  }
  return 'en';
}

function lookup(dict: Dictionary, key: string): unknown {
  return key.split('.').reduce<unknown>((node, part) => (node && typeof node === 'object' ? (node as Record<string, unknown>)[part] : undefined), dict);
}

function interpolate(template: string, params?: TParams) {
  if (!params) return template;
  return template.replace(/\{(\w+)\}/g, (m, k: string) => (k in params ? String(params[k]) : m));
}

/** CLDR plural category for the locales we ship. */
export function pluralCategory(locale: Locale, n: number): keyof PluralForms {
  const abs = Math.abs(n);
  if (locale === 'ru') {
    if (!Number.isInteger(abs)) return 'other';
    const m10 = abs % 10;
    const m100 = abs % 100;
    if (m10 === 1 && m100 !== 11) return 'one';
    if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) return 'few';
    return 'many';
  }
  return abs === 1 ? 'one' : 'other';
}

export function translate(locale: Locale, key: TKey, params?: TParams): string {
  const value = lookup(dictionaries[locale], key) ?? lookup(en, key);
  return typeof value === 'string' ? interpolate(value, params) : key;
}

export function translatePlural(locale: Locale, key: TPluralKey, n: number, params?: TParams): string {
  const forms = (lookup(dictionaries[locale], key) ?? lookup(en, key)) as PluralForms | undefined;
  if (!forms) return key;
  const cat = pluralCategory(locale, n);
  const template = forms[cat] ?? forms.other;
  return interpolate(template, { n: formatNumber(locale, n), ...params });
}

const intlLocale: Record<Locale, string> = { en: 'en-GB', uz: 'uz-Latn-UZ', ru: 'ru-RU' };

export function formatNumber(locale: Locale, n: number) {
  try {
    return new Intl.NumberFormat(intlLocale[locale]).format(n);
  } catch {
    return String(n);
  }
}

const uzMonths = ['yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun', 'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr'];

export function formatDate(locale: Locale, iso: string | Date, style: 'long' | 'short' | 'month' = 'long') {
  const d = typeof iso === 'string' ? new Date(iso) : iso;
  if (Number.isNaN(d.getTime())) return '';
  // ICU data for Uzbek is incomplete on some Android builds; format it explicitly.
  if (locale === 'uz') {
    if (style === 'month') return `${d.getFullYear()}-yil ${uzMonths[d.getMonth()]}`;
    if (style === 'short') return `${String(d.getDate()).padStart(2, '0')}.${String(d.getMonth() + 1).padStart(2, '0')}.${d.getFullYear()}`;
    return `${d.getFullYear()}-yil ${d.getDate()}-${uzMonths[d.getMonth()]}`;
  }
  try {
    const opts: Intl.DateTimeFormatOptions =
      style === 'month' ? { month: 'long', year: 'numeric' } : style === 'short' ? { day: '2-digit', month: '2-digit', year: 'numeric' } : { day: 'numeric', month: 'long', year: 'numeric' };
    return new Intl.DateTimeFormat(intlLocale[locale], opts).format(d);
  } catch {
    return d.toISOString().slice(0, 10);
  }
}

export function useLocale(): Locale {
  const pref = usePreferences((s) => s.locale);
  return pref ?? deviceLocale();
}

export function useI18n() {
  const locale = useLocale();
  const t = useCallback((key: TKey, params?: TParams) => translate(locale, key, params), [locale]);
  const tp = useCallback((key: TPluralKey, n: number, params?: TParams) => translatePlural(locale, key, n, params), [locale]);

  const duration = useCallback(
    (seconds: number) => {
      const mins = Math.max(1, Math.round(seconds / 60));
      if (mins < 60) return translate(locale, 'common.minutesShort', { n: mins });
      const h = Math.floor(mins / 60);
      const m = mins % 60;
      return m ? translate(locale, 'common.hoursMinutesShort', { h, m }) : translate(locale, 'common.hoursShort', { n: h });
    },
    [locale],
  );

  const relativeTime = useCallback(
    (iso: string) => {
      const diff = (Date.now() - new Date(iso).getTime()) / 1000;
      if (diff < 60) return translate(locale, 'time.justNow');
      if (diff < 3600) return translatePlural(locale, 'time.minutesAgo', Math.floor(diff / 60));
      if (diff < 86400) return translatePlural(locale, 'time.hoursAgo', Math.floor(diff / 3600));
      if (diff < 86400 * 14) return translatePlural(locale, 'time.daysAgo', Math.floor(diff / 86400));
      return formatDate(locale, iso, 'short');
    },
    [locale],
  );

  return useMemo(
    () => ({
      locale,
      t,
      tp,
      duration,
      relativeTime,
      date: (iso: string | Date, style?: 'long' | 'short' | 'month') => formatDate(locale, iso, style),
      number: (n: number) => formatNumber(locale, n),
    }),
    [locale, t, tp, duration, relativeTime],
  );
}
