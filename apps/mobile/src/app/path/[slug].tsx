import { router, useLocalSearchParams } from 'expo-router';
import { Check, Crown, Hammer } from 'lucide-react-native';
import { StyleSheet, useWindowDimensions, View } from 'react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';

import { CourseCover } from '@/components/brand/CourseCover';
import { LevelMeter } from '@/components/course/CourseCards';
import { ErrorState, ScrollScreen } from '@/components/ui/layout';
import { PressableScale } from '@/components/ui/PressableScale';
import { Badge, ProgressBar, Skeleton } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { useEnrollments, usePath } from '@/data/hooks';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

/** A learning path rendered as a vertical journey: Zero at the top, mastery at the end. */
export default function PathScreen() {
  const { slug } = useLocalSearchParams<{ slug: string }>();
  const t = useTheme();
  const { t: tr, tp, duration } = useI18n();
  const { width } = useWindowDimensions();
  const path = usePath(slug);
  const enrollments = useEnrollments();
  const p = path.data;

  return (
    <ScrollScreen back title={p?.title ?? ''}>
      {path.isLoading && <Skeleton height={200} radius={t.radii.xl} style={{ marginHorizontal: t.spacing.gutter, width: undefined }} />}
      {!path.isLoading && !p && <ErrorState message={tr('errors.notFound')} onRetry={() => path.refetch()} />}
      {p && (
        <>
          <View style={{ paddingHorizontal: t.spacing.gutter }}>
            <CourseCover id={`ph${p.id}`} coverStyle={p.cover_style} radius={t.radii.xl} style={{ height: Math.min(width * 0.5, 260) }}>
              <View style={styles.coverBody}>
                <Badge label={`${tr(`levels.${p.level_from}`)} → ${tr(`levels.${p.level_to}`)}`} tone="custom" color="#FFFFFF" />
                <Text variant="title2" color="#FFFFFF">
                  {p.subtitle}
                </Text>
              </View>
            </CourseCover>
          </View>
          {p.description && (
            <Text variant="body" tone="secondary" style={{ paddingHorizontal: t.spacing.gutter }}>
              {p.description}
            </Text>
          )}
          <View style={{ paddingHorizontal: t.spacing.gutter }}>
            <Text variant="title3" style={{ marginBottom: 16 }}>
              {tp('explore.results', p.courses.length)}
            </Text>
            {p.courses.map((c, i) => {
              const e = enrollments.data?.find((x) => x.course_id === c.id);
              const done = e?.status === 'completed';
              const color = c.category?.color ?? t.colors.accent;
              return (
                <Animated.View key={c.id} entering={t.reduceMotion ? undefined : FadeInDown.delay(i * 80)} style={styles.step}>
                  <View style={styles.rail}>
                    <View style={[styles.node, { borderColor: done ? t.colors.success : color, backgroundColor: done ? t.colors.success : t.colors.background }]}>
                      {done ? <Check size={14} color="#08090C" strokeWidth={3} /> : <Text variant="caption">{i + 1}</Text>}
                    </View>
                    {i < p.courses.length - 1 && <View style={[styles.line, { backgroundColor: t.colors.borderStrong }]} />}
                  </View>
                  <PressableScale onPress={() => router.push({ pathname: '/course/[slug]', params: { slug: c.slug } })} style={[styles.card, { backgroundColor: t.colors.surface, borderColor: t.colors.border, borderRadius: t.radii.lg }]}>
                    <CourseCover id={`pc${c.id}`} coverStyle={c.cover_style} categoryColor={c.category?.color} radius={12} style={{ width: 64, height: 64 }} />
                    <View style={{ flex: 1, gap: 4 }}>
                      <Text variant="headline" numberOfLines={2}>
                        {c.title}
                      </Text>
                      <View style={{ flexDirection: 'row', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
                        <LevelMeter level={c.level} color={color} />
                        <Text variant="caption" tone="tertiary">
                          {c.duration_seconds ? duration(c.duration_seconds) : tp('common.lessons', c.lesson_count)}
                        </Text>
                        {c.access_tier === 'premium' && <Crown size={13} color={t.colors.accent} />}
                        {!c.content_complete && <Hammer size={13} color={t.colors.warning} />}
                      </View>
                      {e && <ProgressBar value={e.progress_percent / 100} height={3} color={color} style={{ marginTop: 4 }} />}
                    </View>
                  </PressableScale>
                </Animated.View>
              );
            })}
          </View>
        </>
      )}
    </ScrollScreen>
  );
}

const styles = StyleSheet.create({
  coverBody: { flex: 1, padding: 20, justifyContent: 'space-between' },
  step: { flexDirection: 'row', gap: 14 },
  rail: { alignItems: 'center', width: 28 },
  node: { width: 28, height: 28, borderRadius: 14, borderWidth: 2, alignItems: 'center', justifyContent: 'center' },
  line: { width: 2, flex: 1, marginVertical: 4 },
  card: { flex: 1, flexDirection: 'row', gap: 12, padding: 12, marginBottom: 14, borderWidth: StyleSheet.hairlineWidth, alignItems: 'center' },
});
