import { router } from 'expo-router';
import { BookOpen, ChevronDown, CircleCheck, ClipboardList, FolderKanban, Lock, PenLine, PlayCircle, type LucideIcon } from 'lucide-react-native';
import { useState } from 'react';
import { StyleSheet, View } from 'react-native';
import Animated, { FadeIn, LinearTransition, useAnimatedStyle, withSpring } from 'react-native-reanimated';

import { PressableScale } from '@/components/ui/PressableScale';
import { Badge } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { flattenLessons, isLessonLocked } from '@/data/learning';
import type { CourseDetail, LessonProgress, LessonType } from '@/data/types';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

export const lessonIcon: Record<LessonType, LucideIcon> = {
  video: PlayCircle,
  article: BookOpen,
  exercise: PenLine,
  quiz: ClipboardList,
  assignment: FolderKanban,
  project: FolderKanban,
};

export function Curriculum({ course, progress, isPremium, onLocked }: { course: CourseDetail; progress: LessonProgress[]; isPremium: boolean; onLocked: () => void }) {
  const t = useTheme();
  const { t: tr, tp, duration } = useI18n();
  const done = new Set(progress.filter((p) => p.status === 'completed').map((p) => p.lesson_id));
  const firstOpen = course.modules.findIndex((m) => m.lessons.some((l) => !done.has(l.id)));
  const [open, setOpen] = useState<Set<string>>(() => new Set(course.modules[Math.max(0, firstOpen)] ? [course.modules[Math.max(0, firstOpen)].id] : []));
  const numbers = new Map(flattenLessons(course).map((l, i) => [l.id, i + 1]));

  return (
    <View style={{ gap: 12 }}>
      {course.modules.map((m, mi) => {
        const isOpen = open.has(m.id);
        const completed = m.lessons.filter((l) => done.has(l.id)).length;
        return (
          <Animated.View key={m.id} layout={t.reduceMotion ? undefined : LinearTransition.springify().damping(20)} style={[styles.module, { backgroundColor: t.colors.surface, borderColor: t.colors.border, borderRadius: t.radii.lg }]}>
            <PressableScale
              scaleTo={0.99}
              haptic="select"
              accessibilityRole="button"
              accessibilityState={{ expanded: isOpen }}
              accessibilityLabel={`${m.title}. ${tp('common.lessons', m.lessons.length)}`}
              onPress={() => setOpen((s) => {
                const n = new Set(s);
                if (n.has(m.id)) n.delete(m.id);
                else n.add(m.id);
                return n;
              })}
              style={styles.moduleHeader}>
              <View style={[styles.moduleIndex, { backgroundColor: completed === m.lessons.length ? t.colors.successSoft : t.colors.surfaceHigh }]}>
                {completed === m.lessons.length && completed > 0 ? <CircleCheck size={16} color={t.colors.success} /> : <Text variant="subhead">{mi + 1}</Text>}
              </View>
              <View style={{ flex: 1, gap: 2 }}>
                <Text variant="headline">{m.title}</Text>
                <Text variant="caption" tone="tertiary">
                  {tp('common.lessons', m.lessons.length)} · {completed}/{m.lessons.length}
                </Text>
              </View>
              <Chevron open={isOpen} />
            </PressableScale>
            {isOpen && (
              <Animated.View entering={t.reduceMotion ? undefined : FadeIn.duration(220)} style={{ paddingBottom: 6 }}>
                {m.lessons.map((l) => {
                  const locked = isLessonLocked(l, course, isPremium);
                  const isDone = done.has(l.id);
                  const Icon = locked ? Lock : isDone ? CircleCheck : lessonIcon[l.type];
                  return (
                    <PressableScale
                      key={l.id}
                      scaleTo={0.985}
                      haptic="select"
                      testID={`lesson-row-${l.id}`}
                      accessibilityLabel={`${tr('lesson.lessonOf', { n: numbers.get(l.id) ?? 0, total: numbers.size })}: ${l.title}. ${tr(`lessonTypes.${l.type}`)}${isDone ? `. ${tr('lesson.completed')}` : ''}${locked ? `. ${tr('course.locked')}` : ''}`}
                      onPress={() => (locked ? onLocked() : router.push({ pathname: '/lesson/[id]', params: { id: l.id } }))}
                      style={[styles.lesson, { borderTopColor: t.colors.border }]}>
                      <Icon size={18} color={isDone ? t.colors.success : locked ? t.colors.textTertiary : t.colors.accent} strokeWidth={1.9} />
                      <View style={{ flex: 1, gap: 2 }}>
                        <Text variant="callout" tone={locked ? 'secondary' : 'primary'} numberOfLines={2}>
                          {l.title}
                        </Text>
                        <Text variant="caption" tone="tertiary">
                          {tr(`lessonTypes.${l.type}`)}
                          {l.duration_seconds ? ` · ${duration(l.duration_seconds)}` : ''}
                        </Text>
                      </View>
                      {l.is_preview && course.access_tier === 'premium' && !isPremium && <Badge label={tr('course.preview')} tone="success" />}
                    </PressableScale>
                  );
                })}
              </Animated.View>
            )}
          </Animated.View>
        );
      })}
    </View>
  );
}

function Chevron({ open }: { open: boolean }) {
  const t = useTheme();
  const style = useAnimatedStyle(() => ({ transform: [{ rotate: withSpring(open ? '180deg' : '0deg', t.motion.spring.snappy) }] }));
  return (
    <Animated.View style={style}>
      <ChevronDown size={20} color={t.colors.textSecondary} />
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  module: { borderWidth: StyleSheet.hairlineWidth, overflow: 'hidden' },
  moduleHeader: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 14 },
  moduleIndex: { width: 32, height: 32, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  lesson: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingVertical: 12, paddingHorizontal: 16, marginHorizontal: 0, borderTopWidth: StyleSheet.hairlineWidth },
});
