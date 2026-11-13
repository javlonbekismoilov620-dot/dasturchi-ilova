import type { CourseDetail, Lesson, LessonProgress } from './types';

/** Ordered list of every visible lesson in a course. */
export function flattenLessons(course: Pick<CourseDetail, 'modules'>): Lesson[] {
  return [...course.modules].sort((a, b) => a.position - b.position).flatMap((m) => [...m.lessons].sort((a, b) => a.position - b.position));
}

/** The lesson a learner should open next: first incomplete lesson, else the last one. */
export function nextLesson(course: Pick<CourseDetail, 'modules'>, progress: LessonProgress[]): Lesson | null {
  const lessons = flattenLessons(course);
  if (!lessons.length) return null;
  const done = new Set(progress.filter((p) => p.status === 'completed').map((p) => p.lesson_id));
  return lessons.find((l) => !done.has(l.id)) ?? lessons[lessons.length - 1];
}

export function adjacentLessons(course: Pick<CourseDetail, 'modules'>, lessonId: string) {
  const lessons = flattenLessons(course);
  const i = lessons.findIndex((l) => l.id === lessonId);
  return { index: i, total: lessons.length, previous: i > 0 ? lessons[i - 1] : null, next: i >= 0 && i < lessons.length - 1 ? lessons[i + 1] : null, lesson: lessons[i] ?? null };
}

/** Can the learner open this lesson's content? (mirrors private.can_access_lesson) */
export function isLessonLocked(lesson: Pick<Lesson, 'is_preview'>, course: { access_tier: 'free' | 'premium' }, isPremium: boolean) {
  return course.access_tier === 'premium' && !lesson.is_preview && !isPremium;
}

export function greetingKey(date = new Date()): 'home.morning' | 'home.afternoon' | 'home.evening' {
  const h = date.getHours();
  if (h >= 5 && h < 12) return 'home.morning';
  if (h >= 12 && h < 18) return 'home.afternoon';
  return 'home.evening';
}
