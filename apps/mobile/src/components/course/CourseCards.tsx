import { router } from 'expo-router';
import { ArrowRight, Crown, Hammer, Layers, Play } from 'lucide-react-native';
import { memo } from 'react';
import { StyleSheet, View } from 'react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';

import { CourseCover } from '@/components/brand/CourseCover';
import { DynamicIcon } from '@/components/ui/Icon';
import { PressableScale } from '@/components/ui/PressableScale';
import { Badge, ProgressBar } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import type { RecentLesson } from '@/data/api';
import type { Category, Course, DifficultyLevel, Enrollment, LearningPath } from '@/data/types';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';
import { withAlpha } from '@/theme/tokens';

const LEVEL_STEPS: DifficultyLevel[] = ['zero', 'beginner', 'intermediate', 'advanced', 'professional', 'expert'];

/** Six-step ladder visual: ZERO → EXPERT. */
export function LevelMeter({ level, color }: { level: DifficultyLevel; color?: string }) {
  const t = useTheme();
  const { t: tr } = useI18n();
  const idx = LEVEL_STEPS.indexOf(level);
  return (
    <View style={styles.levelRow} accessibilityLabel={tr(`levels.${level}`)}>
      <View style={styles.levelBars}>
        {LEVEL_STEPS.map((l, i) => (
          <View key={l} style={{ width: 3, height: 5 + i * 1.6, borderRadius: 1.5, backgroundColor: i <= idx ? color ?? t.colors.accent : t.colors.borderStrong }} />
        ))}
      </View>
      <Text variant="caption" tone="secondary">
        {tr(`levels.${level}`)}
      </Text>
    </View>
  );
}

export const CourseCard = memo(function CourseCard({ course, enrollment, width = 264, index = 0 }: { course: Course; enrollment?: Enrollment | null; width?: number; index?: number }) {
  const t = useTheme();
  const { t: tr, tp, duration } = useI18n();
  const color = course.category?.color ?? t.colors.accent;
  return (
    <Animated.View entering={t.reduceMotion ? undefined : FadeInDown.delay(Math.min(index, 6) * 60).springify().damping(18)} style={{ width }}>
      <PressableScale
        onPress={() => router.push({ pathname: '/course/[slug]', params: { slug: course.slug } })}
        accessibilityLabel={`${course.title}. ${tr(`levels.${course.level}`)}. ${tp('common.lessons', course.lesson_count)}`}
        style={{ gap: 12 }}>
        <CourseCover id={course.id} coverStyle={course.cover_style} categoryColor={course.category?.color} coverPath={course.cover_path} style={{ width, height: width * 0.62 }}>
          <View style={styles.coverBadges}>
            {course.access_tier === 'premium' ? (
              <Badge label={tr('common.premium')} icon={Crown} tone="coverAccent" />
            ) : (
              <Badge label={tr('common.free')} tone="cover" />
            )}
            {!course.content_complete && <Badge label={tr('course.inDevelopment')} icon={Hammer} tone="cover" />}
          </View>
          <View style={[styles.coverIcon, { backgroundColor: withAlpha('#000000', 0.28), borderColor: withAlpha('#FFFFFF', 0.14) }]}>
            <DynamicIcon name={course.category?.icon} size={16} color="#FFFFFF" />
          </View>
        </CourseCover>
        <View style={{ gap: 6, paddingHorizontal: 2 }}>
          <Text variant="overline" color={color} numberOfLines={1}>
            {course.subcategory?.title ?? course.category?.title}
          </Text>
          <Text variant="headline" numberOfLines={2}>
            {course.title}
          </Text>
          <View style={styles.meta}>
            <LevelMeter level={course.level} color={color} />
            <Text variant="caption" tone="tertiary">
              ·
            </Text>
            <Text variant="caption" tone="secondary">
              {tp('common.lessons', course.lesson_count)}
            </Text>
            {course.duration_seconds > 0 && (
              <>
                <Text variant="caption" tone="tertiary">
                  ·
                </Text>
                <Text variant="caption" tone="secondary">
                  {duration(course.duration_seconds)}
                </Text>
              </>
            )}
          </View>
          {enrollment && enrollment.progress_percent > 0 && <ProgressBar value={enrollment.progress_percent / 100} height={4} color={color} style={{ marginTop: 4 }} />}
        </View>
      </PressableScale>
    </Animated.View>
  );
});

export const CourseRow = memo(function CourseRow({ course, enrollment, index = 0 }: { course: Course; enrollment?: Enrollment | null; index?: number }) {
  const t = useTheme();
  const { t: tr, tp, duration } = useI18n();
  const color = course.category?.color ?? t.colors.accent;
  return (
    <Animated.View entering={t.reduceMotion ? undefined : FadeInDown.delay(Math.min(index, 8) * 40).duration(320)}>
      <PressableScale
        scaleTo={0.985}
        onPress={() => router.push({ pathname: '/course/[slug]', params: { slug: course.slug } })}
        accessibilityLabel={`${course.title}. ${tr(`levels.${course.level}`)}`}
        style={styles.row}>
        <CourseCover id={`r${course.id}`} coverStyle={course.cover_style} categoryColor={course.category?.color} coverPath={course.cover_path} radius={14} style={{ width: 92, height: 92 }} />
        <View style={{ flex: 1, gap: 4 }}>
          <Text variant="overline" color={color} numberOfLines={1}>
            {course.subcategory?.title ?? course.category?.title}
          </Text>
          <Text variant="headline" numberOfLines={2}>
            {course.title}
          </Text>
          <View style={styles.meta}>
            <LevelMeter level={course.level} color={color} />
            <Text variant="caption" tone="tertiary">
              ·
            </Text>
            <Text variant="caption" tone="secondary">
              {course.duration_seconds ? duration(course.duration_seconds) : tp('common.lessons', course.lesson_count)}
            </Text>
            {course.access_tier === 'premium' && <Crown size={13} color={t.colors.accent} />}
          </View>
          {enrollment && <ProgressBar value={enrollment.progress_percent / 100} height={3} color={color} style={{ marginTop: 6 }} />}
        </View>
      </PressableScale>
    </Animated.View>
  );
});

/** Hero "continue learning" card with the next lesson. */
export function ContinueCard({ enrollment, nextLessonTitle, onPress }: { enrollment: Enrollment; nextLessonTitle?: string | null; onPress: () => void }) {
  const t = useTheme();
  const { t: tr } = useI18n();
  const course = enrollment.course!;
  const color = course.category?.color ?? t.colors.accent;
  return (
    <PressableScale onPress={onPress} scaleTo={0.98} accessibilityLabel={`${tr('home.resume')}: ${course.title}`} style={[styles.continue, { borderRadius: t.radii.xl, borderColor: t.colors.border }, t.elevation(2)]}>
      <CourseCover id={`cc${course.id}`} coverStyle={course.cover_style} categoryColor={course.category?.color} coverPath={course.cover_path} radius={0} style={StyleSheet.absoluteFill} />
      <View style={[StyleSheet.absoluteFill, { backgroundColor: 'rgba(5,6,8,0.38)' }]} />
      <View style={styles.continueBody}>
        <View style={{ gap: 6 }}>
          <Text variant="overline" color="rgba(255,255,255,0.75)">
            {tr('home.continueLearning')}
          </Text>
          <Text variant="title2" color="#FFFFFF" numberOfLines={2}>
            {course.title}
          </Text>
          {nextLessonTitle && (
            <Text variant="callout" color="rgba(255,255,255,0.8)" numberOfLines={1}>
              {tr('home.nextUp')}: {nextLessonTitle}
            </Text>
          )}
        </View>
        <View style={styles.continueFooter}>
          <View style={{ flex: 1, gap: 6 }}>
            <ProgressBar value={enrollment.progress_percent / 100} height={5} color={color} track="rgba(255,255,255,0.2)" />
            <Text variant="caption" color="rgba(255,255,255,0.8)">
              {tr('course.progress', { percent: Math.round(enrollment.progress_percent) })}
            </Text>
          </View>
          <View style={[styles.playBtn, { backgroundColor: '#FFFFFF' }]}>
            <Play size={20} color="#0B0C10" fill="#0B0C10" />
          </View>
        </View>
      </View>
    </PressableScale>
  );
}

export function RecentLessonCard({ item }: { item: RecentLesson }) {
  const t = useTheme();
  const { t: tr, relativeTime } = useI18n();
  return (
    <PressableScale
      onPress={() => router.push({ pathname: '/lesson/[id]', params: { id: item.lesson.id } })}
      style={[styles.recent, { backgroundColor: t.colors.surface, borderColor: t.colors.border, borderRadius: t.radii.lg }]}
      accessibilityLabel={item.lesson.title}>
      <CourseCover id={`rl${item.lesson_id}`} coverStyle={item.lesson.course.cover_style} categoryColor={item.lesson.course.category?.color} radius={10} style={{ width: 44, height: 44 }} />
      <View style={{ flex: 1, gap: 2 }}>
        <Text variant="subhead" numberOfLines={1}>
          {item.lesson.title}
        </Text>
        <Text variant="caption" tone="tertiary" numberOfLines={1}>
          {tr(`lessonTypes.${item.lesson.type}`)} · {relativeTime(item.updated_at)}
        </Text>
      </View>
    </PressableScale>
  );
}

export function PathCard({ path, width = 300 }: { path: LearningPath; width?: number }) {
  const t = useTheme();
  const { t: tr, tp } = useI18n();
  return (
    <PressableScale onPress={() => router.push({ pathname: '/path/[slug]', params: { slug: path.slug } })} style={{ width }} accessibilityLabel={path.title}>
      <CourseCover id={`p${path.id}`} coverStyle={path.cover_style} radius={t.radii.xl} style={{ width, height: 168 }}>
        <View style={styles.pathBody}>
          <View style={{ flexDirection: 'row', gap: 6 }}>
            <Badge label={`${tr(`levels.${path.level_from}`)} → ${tr(`levels.${path.level_to}`)}`} tone="cover" />
            {path.access_tier === 'premium' && <Badge label={tr('common.premium')} icon={Crown} tone="coverAccent" />}
          </View>
          <View style={{ gap: 4 }}>
            <Text variant="title2" color="#FFFFFF" numberOfLines={1}>
              {path.title}
            </Text>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
              <Layers size={14} color="rgba(255,255,255,0.8)" />
              <Text variant="caption" color="rgba(255,255,255,0.85)">
                {tp('explore.results', path.courses.length)}
              </Text>
              <ArrowRight size={14} color="rgba(255,255,255,0.8)" />
            </View>
          </View>
        </View>
      </CourseCover>
    </PressableScale>
  );
}

export function CategoryTile({ category, width }: { category: Category; width: number }) {
  const t = useTheme();
  const color = category.color ?? t.colors.accent;
  return (
    <PressableScale
      onPress={() => router.push({ pathname: '/category/[slug]', params: { slug: category.slug } })}
      accessibilityLabel={category.title}
      style={[styles.tile, { width, backgroundColor: t.colors.surface, borderColor: t.colors.border, borderRadius: t.radii.lg }]}>
      <View style={[styles.tileGlow, { backgroundColor: withAlpha(color, t.isDark ? 0.18 : 0.12) }]} />
      <View style={[styles.tileIcon, { backgroundColor: withAlpha(color, 0.16) }]}>
        <DynamicIcon name={category.icon} size={20} color={color} strokeWidth={1.8} />
      </View>
      <Text variant="headline" numberOfLines={2} style={{ minHeight: 44 }}>
        {category.title}
      </Text>
    </PressableScale>
  );
}

const styles = StyleSheet.create({
  coverBadges: { position: 'absolute', top: 12, left: 12, flexDirection: 'row', gap: 6, flexWrap: 'wrap', right: 52 },
  coverIcon: { position: 'absolute', top: 10, right: 10, width: 32, height: 32, borderRadius: 16, alignItems: 'center', justifyContent: 'center', borderWidth: StyleSheet.hairlineWidth },
  meta: { flexDirection: 'row', alignItems: 'center', gap: 6, flexWrap: 'wrap' },
  levelRow: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  levelBars: { flexDirection: 'row', alignItems: 'flex-end', gap: 2, height: 14 },
  row: { flexDirection: 'row', gap: 14, alignItems: 'center' },
  continue: { height: 220, overflow: 'hidden', borderWidth: StyleSheet.hairlineWidth },
  continueBody: { flex: 1, padding: 20, justifyContent: 'space-between' },
  continueFooter: { flexDirection: 'row', alignItems: 'flex-end', gap: 16 },
  playBtn: { width: 52, height: 52, borderRadius: 26, alignItems: 'center', justifyContent: 'center', paddingLeft: 3 },
  recent: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 10, borderWidth: StyleSheet.hairlineWidth, width: 248 },
  pathBody: { flex: 1, padding: 18, justifyContent: 'space-between' },
  tile: { padding: 16, gap: 14, borderWidth: StyleSheet.hairlineWidth, overflow: 'hidden' },
  tileGlow: { position: 'absolute', width: 120, height: 120, borderRadius: 60, top: -50, right: -40 },
  tileIcon: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
});

