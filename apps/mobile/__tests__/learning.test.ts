import { describe, it, expect } from '@jest/globals';
import { adjacentLessons, flattenLessons, greetingKey, isLessonLocked, nextLesson } from '@/data/learning';
import type { Lesson, LessonProgress, Module } from '@/data/types';

const lesson = (id: string, position: number, module_id = 'm1'): Lesson => ({ id, module_id, course_id: 'c', title: id, summary: null, type: 'article', position, duration_seconds: 60, is_preview: false, is_required: true, xp: 10 });
const course = {
  modules: [
    { id: 'm2', course_id: 'c', title: 'Two', description: null, position: 1, lessons: [lesson('c', 0, 'm2'), lesson('d', 1, 'm2')] },
    { id: 'm1', course_id: 'c', title: 'One', description: null, position: 0, lessons: [lesson('b', 1), lesson('a', 0)] },
  ] as Module[],
};
const done = (ids: string[]): LessonProgress[] => ids.map((id) => ({ lesson_id: id, course_id: 'c', status: 'completed', position_seconds: 0, completed_at: null, updated_at: '' }));

describe('learning helpers', () => {
  it('orders lessons by module then lesson position', () => {
    expect(flattenLessons(course).map((l) => l.id)).toEqual(['a', 'b', 'c', 'd']);
  });
  it('next lesson is the first incomplete one, or the last when all done', () => {
    expect(nextLesson(course, [])?.id).toBe('a');
    expect(nextLesson(course, done(['a', 'b']))?.id).toBe('c');
    expect(nextLesson(course, done(['a', 'b', 'c', 'd']))?.id).toBe('d');
    expect(nextLesson({ modules: [] }, [])).toBeNull();
  });
  it('finds previous and next across modules', () => {
    const nav = adjacentLessons(course, 'c');
    expect([nav.previous?.id, nav.next?.id, nav.index, nav.total]).toEqual(['b', 'd', 2, 4]);
    expect(adjacentLessons(course, 'a').previous).toBeNull();
  });
  it('mirrors server entitlement rules', () => {
    expect(isLessonLocked({ is_preview: false }, { access_tier: 'premium' }, false)).toBe(true);
    expect(isLessonLocked({ is_preview: true }, { access_tier: 'premium' }, false)).toBe(false);
    expect(isLessonLocked({ is_preview: false }, { access_tier: 'premium' }, true)).toBe(false);
    expect(isLessonLocked({ is_preview: false }, { access_tier: 'free' }, false)).toBe(false);
  });
  it('greets by time of day', () => {
    expect(greetingKey(new Date('2026-01-01T08:00:00'))).toBe('home.morning');
    expect(greetingKey(new Date('2026-01-01T14:00:00'))).toBe('home.afternoon');
    expect(greetingKey(new Date('2026-01-01T22:00:00'))).toBe('home.evening');
  });
});
