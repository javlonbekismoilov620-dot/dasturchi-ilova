import { describe, it, expect } from '@jest/globals';
import { formatDate, pluralCategory, translate, translatePlural } from '@/i18n';
import en from '@/i18n/en';
import ru from '@/i18n/ru';
import uz from '@/i18n/uz';

function leaves(obj: unknown, prefix = ''): string[] {
  if (typeof obj === 'string') return [prefix];
  return Object.entries(obj as Record<string, unknown>).flatMap(([k, v]) => leaves(v, prefix ? `${prefix}.${k}` : k));
}

describe('dictionaries', () => {
  it('uz and ru translate every English key', () => {
    const keys = leaves(en).filter((k) => !/\.(few|many)$/.test(k));
    for (const dict of [uz, ru]) {
      const have = new Set(leaves(dict));
      expect(keys.filter((k) => !have.has(k))).toEqual([]);
    }
  });

  it('keeps placeholders consistent across languages', () => {
    const ph = (s: string) => (s.match(/\{\w+\}/g) ?? []).sort().join();
    for (const key of leaves(en).filter((k) => !/\.(one|few|many|other)$/.test(k))) {
      const e = translate('en', key as never);
      expect([key, ph(translate('uz', key as never))]).toEqual([key, ph(e)]);
      expect([key, ph(translate('ru', key as never))]).toEqual([key, ph(e)]);
    }
  });

  it('uses official Uzbek apostrophes, never ASCII quotes in letters', () => {
    const all = leaves(uz).map((k) => translate('uz', k as never)).join(' ');
    expect(all).not.toMatch(/[oOgG]['’`]/);
    expect(all).toContain('oʻ');
  });
});

describe('plurals', () => {
  it('applies Russian CLDR categories', () => {
    expect([1, 2, 5, 11, 21, 22, 25, 111].map((n) => pluralCategory('ru', n))).toEqual(['one', 'few', 'many', 'many', 'one', 'few', 'many', 'many']);
    expect(translatePlural('ru', 'common.lessons', 1)).toBe('1 урок');
    expect(translatePlural('ru', 'common.lessons', 3)).toBe('3 урока');
    expect(translatePlural('ru', 'common.lessons', 12)).toBe('12 уроков');
  });
  it('handles English and Uzbek', () => {
    expect(translatePlural('en', 'common.lessons', 1)).toBe('1 lesson');
    expect(translatePlural('en', 'common.lessons', 2)).toBe('2 lessons');
    expect(translatePlural('uz', 'common.lessons', 7)).toBe('7 ta dars');
  });
});

describe('formatting', () => {
  it('formats Uzbek dates explicitly (ICU data is unreliable on Android)', () => {
    expect(formatDate('uz', '2026-11-13T10:00:00Z')).toBe('2026-yil 13-noyabr');
    expect(formatDate('uz', '2026-11-13T10:00:00Z', 'short')).toBe('13.11.2026');
  });
  it('interpolates params', () => {
    expect(translate('en', 'course.progress', { percent: 40 })).toBe('40% complete');
  });
});
