import { Lock } from 'lucide-react-native';
import { StyleSheet, View } from 'react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';

import { DynamicIcon } from '@/components/ui/Icon';
import { ScrollScreen } from '@/components/ui/layout';
import { Card, ProgressBar, Skeleton } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { useAchievements, useStats } from '@/data/hooks';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

const tierColor = { bronze: '#D89A6A', silver: '#C9CED6', gold: '#E8C07A', platinum: '#9FE3D6' } as const;

export default function Achievements() {
  const t = useTheme();
  const { t: tr, date } = useI18n();
  const { catalog, earned } = useAchievements();
  const stats = useStats();
  const earnedMap = new Map(earned.data?.map((e) => [e.achievement_id, e.earned_at]));
  const s = stats.data;
  const metric = (m: string): number =>
    !s
      ? 0
      : ({
          lessons_completed: s.lessons_completed,
          courses_completed: s.courses_completed,
          longest_streak: s.longest_streak,
          quizzes_passed: s.quizzes_passed,
          total_xp: s.total_xp,
          certificates: s.certificates,
          minutes_learned: Math.floor(s.total_seconds / 60),
          enrollments: s.courses_in_progress + s.courses_completed,
        } as Record<string, number>)[m] ?? 0;

  return (
    <ScrollScreen back title={tr('achievements.title')}>
      <Text variant="callout" tone="secondary" style={{ paddingHorizontal: t.spacing.gutter }}>
        {tr('achievements.summary', { earned: earnedMap.size, total: catalog.data?.length ?? 0 })}
      </Text>
      <View style={[styles.grid, { paddingHorizontal: t.spacing.gutter }]}>
        {catalog.isLoading && [0, 1, 2, 3].map((i) => <Skeleton key={i} height={170} radius={t.radii.lg} style={{ flexBasis: '47%', flexGrow: 1 }} />)}
        {(catalog.data ?? []).map((a, i) => {
          const got = earnedMap.get(a.id);
          const c = tierColor[a.tier];
          const progress = Math.min(1, metric(a.criteria.metric) / a.criteria.gte);
          return (
            <Animated.View key={a.id} entering={t.reduceMotion ? undefined : FadeInDown.delay(i * 40)} style={{ flexBasis: '47%', flexGrow: 1 }}>
              <Card style={[styles.card, got && { borderColor: c }]}>
                <View style={[styles.medal, { borderColor: got ? c : t.colors.border, backgroundColor: got ? `${c}22` : t.colors.surfaceHigh }]}>
                  {got ? <DynamicIcon name={a.icon} size={28} color={c} /> : <Lock size={22} color={t.colors.textTertiary} />}
                </View>
                <Text variant="headline" align="center" numberOfLines={1}>
                  {a.title}
                </Text>
                <Text variant="caption" tone="secondary" align="center" numberOfLines={2} style={{ minHeight: 32 }}>
                  {a.description}
                </Text>
                {got ? (
                  <Text variant="caption" color={c} align="center">
                    {tr(`achievements.tiers.${a.tier}`)} · {date(got, 'short')}
                  </Text>
                ) : (
                  <ProgressBar value={progress} height={4} color={c} style={{ alignSelf: 'stretch' }} />
                )}
              </Card>
            </Animated.View>
          );
        })}
      </View>
    </ScrollScreen>
  );
}

const styles = StyleSheet.create({
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: 12 },
  card: { alignItems: 'center', gap: 8, paddingVertical: 20 },
  medal: { width: 64, height: 64, borderRadius: 32, borderWidth: 2, alignItems: 'center', justifyContent: 'center', marginBottom: 4 },
});
