import { LinearGradient } from 'expo-linear-gradient';
import { router } from 'expo-router';
import { Bell, Flame, Sparkles, Zap } from 'lucide-react-native';
import { useMemo } from 'react';
import { FlatList, StyleSheet, useWindowDimensions, View } from 'react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Aurora } from '@/components/brand/Aurora';
import { CategoryTile, ContinueCard, CourseCard, CourseRow, PathCard, RecentLessonCard } from '@/components/course/CourseCards';
import { DemoBadge, DemoNotice, OfflineBanner } from '@/components/feedback/Banners';
import { TAB_BAR_HEIGHT } from '@/components/navigation/TabBar';
import { Button } from '@/components/ui/Button';
import { IconButton, ScrollScreen, SectionHeader } from '@/components/ui/layout';
import { PressableScale } from '@/components/ui/PressableScale';
import { Card, ProgressRing, Skeleton } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { useAuth } from '@/data/auth';
import {
  useCategories,
  useCourseById,
  useCourseProgress,
  useEnrollments,
  useNewCourses,
  useNotifications,
  usePaths,
  usePopularCourses,
  useProfile,
  useRecentLessons,
  useRecommendedCourses,
  useStats,
} from '@/data/hooks';
import { greetingKey, nextLesson } from '@/data/learning';
import type { Course, Enrollment } from '@/data/types';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

function Carousel({ courses, loading, enrollments }: { courses?: Course[]; loading: boolean; enrollments?: Enrollment[] }) {
  const t = useTheme();
  const byCourse = useMemo(() => new Map(enrollments?.map((e) => [e.course_id, e])), [enrollments]);
  if (loading)
    return (
      <View style={{ flexDirection: 'row', gap: 16, paddingHorizontal: t.spacing.gutter }}>
        {[0, 1].map((i) => (
          <View key={i} style={{ width: 264, gap: 10 }}>
            <Skeleton height={164} radius={18} />
            <Skeleton width="40%" height={10} />
            <Skeleton width="85%" height={16} />
          </View>
        ))}
      </View>
    );
  return (
    <FlatList
      horizontal
      data={courses ?? []}
      keyExtractor={(c) => c.id}
      showsHorizontalScrollIndicator={false}
      contentContainerStyle={{ paddingHorizontal: t.spacing.gutter, gap: 16 }}
      snapToInterval={264 + 16}
      decelerationRate="fast"
      renderItem={({ item, index }) => <CourseCard course={item} index={index} enrollment={byCourse.get(item.id)} />}
    />
  );
}

function ContinueSection({ enrollment }: { enrollment: Enrollment }) {
  const { data: course } = useCourseById(enrollment.course_id);
  const { data: progress } = useCourseProgress(enrollment.course_id);
  const next = course && progress ? nextLesson(course, progress) : null;
  return (
    <ContinueCard
      enrollment={enrollment}
      nextLessonTitle={next?.title}
      onPress={() => (next ? router.push({ pathname: '/lesson/[id]', params: { id: next.id } }) : router.push({ pathname: '/course/[slug]', params: { slug: enrollment.course!.slug } }))}
    />
  );
}

function GoalCard() {
  const t = useTheme();
  const { t: tr, number } = useI18n();
  const { data: stats, isLoading } = useStats();
  if (isLoading || !stats)
    return (
      <View style={{ paddingHorizontal: t.spacing.gutter }}>
        <Skeleton height={112} radius={t.radii.xl} />
      </View>
    );
  const goal = stats.daily_goal_minutes;
  const done = Math.floor(stats.today_seconds / 60);
  const ratio = goal ? done / goal : 0;
  return (
    <Animated.View entering={t.reduceMotion ? undefined : FadeInDown.duration(400)} style={{ paddingHorizontal: t.spacing.gutter }}>
      <Card style={[styles.goal, { borderRadius: t.radii.xl }]}>
        <ProgressRing value={ratio} size={76} stroke={7}>
          <Text variant="headline">{Math.min(done, 999)}</Text>
          <Text variant="caption" tone="tertiary" style={{ marginTop: -2 }}>
            / {goal}
          </Text>
        </ProgressRing>
        <View style={{ flex: 1, gap: 4 }}>
          <Text variant="overline" tone="tertiary">
            {tr('home.dailyGoal')}
          </Text>
          <Text variant="headline">{ratio >= 1 ? tr('home.goalReached') : tr('home.dailyGoalProgress', { done, goal })}</Text>
          <View style={styles.statsRow}>
            <View style={styles.stat}>
              <Flame size={16} color={stats.current_streak ? t.colors.accent : t.colors.textTertiary} fill={stats.current_streak ? t.colors.accentSoft : 'transparent'} />
              <Text variant="subhead">{stats.current_streak}</Text>
              <Text variant="caption" tone="tertiary">
                {tr('home.streak')}
              </Text>
            </View>
            <View style={styles.stat}>
              <Zap size={16} color={t.colors.info} />
              <Text variant="subhead">{number(stats.total_xp)}</Text>
              <Text variant="caption" tone="tertiary">
                XP
              </Text>
            </View>
          </View>
        </View>
      </Card>
    </Animated.View>
  );
}

export default function Home() {
  const t = useTheme();
  const { t: tr } = useI18n();
  const insets = useSafeAreaInsets();
  const { width } = useWindowDimensions();
  const user = useAuth((s) => s.user);
  const signedIn = !!user;
  const profile = useProfile();
  const enrollments = useEnrollments();
  const recommended = useRecommendedCourses();
  const popular = usePopularCourses();
  const fresh = useNewCourses();
  const paths = usePaths();
  const categories = useCategories();
  const recent = useRecentLessons();
  const notifications = useNotifications();
  const unread = notifications.data?.filter((n) => !n.read).length ?? 0;

  const active = enrollments.data?.find((e) => e.status === 'active');
  const name = signedIn ? profile.data?.display_name?.split(' ')[0] ?? tr('home.guestName') : tr('home.welcomeGuest');
  const tileWidth = Math.min((Math.min(width, 760) - t.spacing.gutter * 2 - 12) / 2, 340);
  const refreshing = recommended.isRefetching || enrollments.isRefetching;

  const refresh = () => {
    void Promise.all([recommended.refetch(), popular.refetch(), enrollments.refetch(), recent.refetch(), paths.refetch()]);
  };

  return (
    <ScrollScreen
      largeTitle={false}
      bottomInset={TAB_BAR_HEIGHT}
      refreshing={refreshing}
      onRefresh={refresh}
      hero={() => (
        <View style={[styles.hero, { paddingTop: insets.top + 64 }]}>
          <Aurora hue={38} intensity={0.55} />
          <LinearGradient pointerEvents="none" colors={['transparent', t.colors.background]} style={styles.heroFade} />
          <View style={{ paddingHorizontal: t.spacing.gutter, gap: 4 }}>
            <Text variant="overline" tone="accent">
              {tr(greetingKey())}
            </Text>
            <Text variant="hero" numberOfLines={2} accessibilityRole="header" testID="home-greeting">
              {name}
            </Text>
          </View>
        </View>
      )}
      right={
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
          <DemoBadge />
          {signedIn && (
            <View>
              <IconButton icon={Bell} label={tr('notifications.title')} glass onPress={() => router.push('/notifications')} />
              {unread > 0 && <View style={[styles.unread, { backgroundColor: t.colors.accent, borderColor: t.colors.background }]} />}
            </View>
          )}
        </View>
      }
      title="Mahorat">
      <View style={{ gap: 12 }}>
        <OfflineBanner />
        <DemoNotice />
      </View>

      {signedIn ? (
        <GoalCard />
      ) : (
        <View style={{ paddingHorizontal: t.spacing.gutter }}>
          <Card style={{ gap: 12, borderRadius: t.radii.xl }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
              <Sparkles size={18} color={t.colors.accent} />
              <Text variant="headline" style={{ flex: 1 }}>
                {tr('home.signInPrompt')}
              </Text>
            </View>
            <Button title={tr('common.signIn')} onPress={() => router.push('/auth')} size="sm" />
          </Card>
        </View>
      )}

      {active?.course && (
        <View style={{ paddingHorizontal: t.spacing.gutter }}>
          <ContinueSection enrollment={active} />
        </View>
      )}

      {!active && signedIn && !enrollments.isLoading && (
        <View style={{ paddingHorizontal: t.spacing.gutter }}>
          <PressableScale onPress={() => router.push('/explore')} style={[styles.startCard, { borderColor: t.colors.accent, borderRadius: t.radii.xl, backgroundColor: t.colors.accentSoft }]}>
            <Text variant="title3">{tr('home.startFirst')}</Text>
            <Text variant="callout" tone="secondary">
              {tr('home.startFirstBody')}
            </Text>
          </PressableScale>
        </View>
      )}

      <View>
        <SectionHeader title={tr('home.recommended')} action={tr('common.seeAll')} onAction={() => router.push('/explore')} />
        <Carousel courses={recommended.data} loading={recommended.isLoading} enrollments={enrollments.data} />
      </View>

      {!!paths.data?.length && (
        <View>
          <SectionHeader title={tr('home.paths')} />
          <FlatList
            horizontal
            data={paths.data}
            keyExtractor={(p) => p.id}
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ paddingHorizontal: t.spacing.gutter, gap: 14 }}
            snapToInterval={300 + 14}
            decelerationRate="fast"
            renderItem={({ item }) => <PathCard path={item} />}
          />
        </View>
      )}

      {!!recent.data?.length && (
        <View>
          <SectionHeader title={tr('home.recentlyViewed')} />
          <FlatList
            horizontal
            data={recent.data}
            keyExtractor={(r) => r.lesson_id}
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ paddingHorizontal: t.spacing.gutter, gap: 12 }}
            renderItem={({ item }) => <RecentLessonCard item={item} />}
          />
        </View>
      )}

      <View>
        <SectionHeader title={tr('home.popular')} />
        <Carousel courses={popular.data} loading={popular.isLoading} enrollments={enrollments.data} />
      </View>

      <View>
        <SectionHeader title={tr('home.categories')} />
        <View style={[styles.grid, { paddingHorizontal: t.spacing.gutter }]}>
          {(categories.data ?? []).map((c) => (
            <CategoryTile key={c.id} category={c} width={tileWidth} />
          ))}
          {categories.isLoading && [0, 1, 2, 3].map((i) => <Skeleton key={i} width={tileWidth} height={110} radius={t.radii.lg} />)}
        </View>
      </View>

      <View>
        <SectionHeader title={tr('home.newContent')} />
        <View style={{ paddingHorizontal: t.spacing.gutter, gap: 16 }}>
          {(fresh.data ?? []).slice(0, 5).map((c, i) => (
            <CourseRow key={c.id} course={c} index={i} enrollment={enrollments.data?.find((e) => e.course_id === c.id)} />
          ))}
        </View>
      </View>
    </ScrollScreen>
  );
}

const styles = StyleSheet.create({
  hero: { paddingBottom: 20, overflow: 'hidden' },
  heroFade: { position: 'absolute', left: 0, right: 0, bottom: 0, height: 90 },
  goal: { flexDirection: 'row', alignItems: 'center', gap: 18, padding: 18 },
  statsRow: { flexDirection: 'row', gap: 16, marginTop: 6 },
  stat: { flexDirection: 'row', alignItems: 'center', gap: 5 },
  startCard: { padding: 20, gap: 6, borderWidth: 1, borderStyle: 'dashed' },
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: 12 },
  unread: { position: 'absolute', top: 2, right: 2, width: 10, height: 10, borderRadius: 5, borderWidth: 2 },
});
