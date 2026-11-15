import { router, useLocalSearchParams } from 'expo-router';
import { Award, Check, Crown, Hammer, Share2, Users } from 'lucide-react-native';
import { useState } from 'react';
import { Share, StyleSheet, useWindowDimensions, View } from 'react-native';
import Animated, { interpolate, useAnimatedStyle, type SharedValue } from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { CourseCover } from '@/components/brand/CourseCover';
import { LevelMeter } from '@/components/course/CourseCards';
import { Curriculum } from '@/components/course/Curriculum';
import { UntranslatedNotice } from '@/components/feedback/Banners';
import { Markdown } from '@/components/lesson/Markdown';
import { Button } from '@/components/ui/Button';
import { ErrorState, Glass, IconButton, ScrollScreen } from '@/components/ui/layout';
import { PressableScale } from '@/components/ui/PressableScale';
import { Badge, Card, ProgressBar, Skeleton } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { toast } from '@/components/ui/Toast';
import { useAuth } from '@/data/auth';
import { useCourse, useCourseProgress, useEnroll, useEnrollments, useEntitlements, useSettings } from '@/data/hooks';
import { nextLesson } from '@/data/learning';
import { errorMessageKey } from '@/lib/errors';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

function Hero({ y, course }: { y: SharedValue<number>; course: NonNullable<ReturnType<typeof useCourse>['data']> }) {
  const t = useTheme();
  const { width } = useWindowDimensions();
  const insets = useSafeAreaInsets();
  const height = Math.min(width * 0.82, 420) + insets.top;
  const style = useAnimatedStyle(() => ({
    transform: [{ translateY: interpolate(y.value, [-200, 0, height], [-100, 0, height * 0.45], 'clamp') }, { scale: interpolate(y.value, [-200, 0], [1.4, 1], 'clamp') }],
    opacity: interpolate(y.value, [0, height * 0.8], [1, 0.3], 'clamp'),
  }));
  return (
    <View style={{ height, overflow: 'hidden' }}>
      <Animated.View style={[StyleSheet.absoluteFill, style]}>
        <CourseCover id={`hero${course.id}`} coverStyle={course.cover_style} categoryColor={course.category?.color} coverPath={course.cover_path} radius={0} style={StyleSheet.absoluteFill} />
      </Animated.View>
      <View style={[StyleSheet.absoluteFill, { backgroundColor: t.isDark ? 'rgba(8,9,12,0.15)' : 'rgba(0,0,0,0.05)' }]} />
    </View>
  );
}

export default function CourseScreen() {
  const { slug } = useLocalSearchParams<{ slug: string }>();
  const t = useTheme();
  const { t: tr, tp, duration, number } = useI18n();
  const insets = useSafeAreaInsets();
  const user = useAuth((s) => s.user);
  const course = useCourse(slug);
  const progress = useCourseProgress(course.data?.id);
  const enrollments = useEnrollments();
  const entitlements = useEntitlements();
  const settings = useSettings();
  const enroll = useEnroll();
  const [expanded, setExpanded] = useState(false);

  const c = course.data;
  const enrollment = enrollments.data?.find((e) => e.course_id === c?.id);
  const isPremium = !!entitlements.data?.is_premium;
  const locked = c?.access_tier === 'premium' && !isPremium;
  const color = c?.category?.color ?? t.colors.accent;
  const next = c ? nextLesson(c, progress.data ?? []) : null;

  if (course.isLoading) {
    return (
      <View style={{ flex: 1, backgroundColor: t.colors.background, gap: 16 }}>
        <Skeleton height={320} radius={0} />
        <View style={{ padding: 20, gap: 12 }}>
          <Skeleton width="30%" height={12} />
          <Skeleton width="85%" height={30} />
          <Skeleton width="60%" height={16} />
        </View>
      </View>
    );
  }
  if (!c) {
    return (
      <ScrollScreen back title="">
        <ErrorState message={course.error ? tr(errorMessageKey(course.error)) : tr('course.notFound')} onRetry={() => course.refetch()} />
      </ScrollScreen>
    );
  }

  const goPaywall = () => router.push('/paywall');

  const primaryAction = async () => {
    if (!user) return router.push('/auth');
    if (locked) return goPaywall();
    try {
      if (!enrollment) await enroll.mutateAsync(c.id);
      if (next) router.push({ pathname: '/lesson/[id]', params: { id: next.id } });
    } catch (e) {
      toast.error(tr(errorMessageKey(e)));
    }
  };

  const cta = locked ? tr('course.unlock') : enrollment?.status === 'completed' ? tr('course.review') : enrollment ? tr('course.continue') : c.access_tier === 'free' ? tr('course.enrollFree') : tr('course.enroll');

  return (
    <View style={{ flex: 1, backgroundColor: t.colors.background }}>
      <ScrollScreen
        back
        title={c.title}
        largeTitle={false}
        bottomInset={96}
        hero={(y) => <Hero y={y} course={c} />}
        right={<IconButton icon={Share2} glass label={tr('course.share')} onPress={() => Share.share({ message: `${c.title} — Mahorat` })} />}>
        <View style={[styles.head, { paddingHorizontal: t.spacing.gutter }]}>
          <Text variant="overline" color={color}>
            {[c.category?.title, c.subcategory?.title].filter(Boolean).join(' · ')}
          </Text>
          <Text variant="display" accessibilityRole="header" testID="course-title">
            {c.title}
          </Text>
          {c.subtitle && (
            <Text variant="body" tone="secondary">
              {c.subtitle}
            </Text>
          )}
          <View style={styles.badges}>
            {c.access_tier === 'premium' ? <Badge label={tr('common.premium')} icon={Crown} tone="accent" /> : <Badge label={tr('common.free')} tone="success" />}
            {!c.content_complete && <Badge label={tr('course.inDevelopment')} icon={Hammer} tone="warning" />}
            {enrollment && <Badge label={enrollment.status === 'completed' ? tr('course.completed') : tr('course.enrolled')} icon={Check} tone="info" />}
          </View>
          <View style={[styles.stats, { borderColor: t.colors.border }]}>
            <Stat label={tr('course.level')}>
              <LevelMeter level={c.level} color={color} />
            </Stat>
            <Stat label={tr('course.lessons')}>
              <Text variant="headline">{c.lesson_count}</Text>
            </Stat>
            <Stat label={tr('course.duration')}>
              <Text variant="headline">{c.duration_seconds ? duration(c.duration_seconds) : '—'}</Text>
            </Stat>
          </View>
          {c.enrollment_count > 0 && (
            <View style={styles.inline}>
              <Users size={14} color={t.colors.textTertiary} />
              <Text variant="footnote" tone="tertiary">
                {tp('common.learners', c.enrollment_count)}
              </Text>
            </View>
          )}
          {enrollment && (
            <View style={{ gap: 8 }}>
              <ProgressBar value={enrollment.progress_percent / 100} color={color} />
              <Text variant="footnote" tone="secondary">
                {tr('course.lessonsDone', { done: enrollment.completed_lessons, total: enrollment.total_lessons })} · {tr('course.progress', { percent: Math.round(enrollment.progress_percent) })}
              </Text>
            </View>
          )}
        </View>

        {c.content_untranslated && (
          <View style={{ paddingHorizontal: t.spacing.gutter }}>
            <UntranslatedNotice baseLanguage={c.language} />
          </View>
        )}

        {!c.content_complete && (
          <View style={{ paddingHorizontal: t.spacing.gutter }}>
            <Card style={{ flexDirection: 'row', gap: 12, backgroundColor: t.colors.warningSoft, borderColor: 'transparent' }}>
              <Hammer size={18} color={t.colors.warning} style={{ marginTop: 2 }} />
              <View style={{ flex: 1, gap: 4 }}>
                <Text variant="headline" tone="warning">
                  {tr('course.inDevelopment')}
                </Text>
                <Text variant="footnote" tone="secondary">
                  {tr('course.inDevelopmentBody')}
                </Text>
              </View>
            </Card>
          </View>
        )}

        {c.description && (
          <Section title={tr('course.about')}>
            <View style={{ maxHeight: expanded ? undefined : 190, overflow: 'hidden' }}>
              <Markdown source={c.description} />
            </View>
            {c.description.length > 360 && (
              <PressableScale onPress={() => setExpanded((e) => !e)} haptic="select" style={{ alignSelf: 'flex-start' }}>
                <Text variant="subhead" tone="accent">
                  {expanded ? '−' : '+'} {tr('course.about')}
                </Text>
              </PressableScale>
            )}
          </Section>
        )}

        {!!c.learning_outcomes.length && (
          <Section title={tr('course.outcomes')}>
            <Card style={{ gap: 14 }}>
              {c.learning_outcomes.map((o) => (
                <View key={o} style={styles.outcome}>
                  <View style={[styles.check, { backgroundColor: t.colors.accentSoft }]}>
                    <Check size={13} color={t.colors.accent} strokeWidth={2.6} />
                  </View>
                  <Text variant="callout" style={{ flex: 1 }}>
                    {o}
                  </Text>
                </View>
              ))}
            </Card>
          </Section>
        )}

        {(!!c.prerequisites.length || !!c.prerequisite_courses.length) && (
          <Section title={tr('course.prerequisites')}>
            <View style={{ gap: 10 }}>
              {c.prerequisites.map((p) => (
                <Text key={p} variant="callout" tone="secondary">
                  • {p}
                </Text>
              ))}
              {c.prerequisite_courses.map((p) => (
                <PressableScale key={p.id} onPress={() => router.push({ pathname: '/course/[slug]', params: { slug: p.slug } })} style={[styles.prereq, { borderColor: t.colors.border, borderRadius: t.radii.md }]}>
                  <Text variant="caption" tone="tertiary">
                    {tr('course.requiredCourses')}
                  </Text>
                  <Text variant="headline" tone="accent">
                    {p.title}
                  </Text>
                </PressableScale>
              ))}
            </View>
          </Section>
        )}

        <Section title={tr('course.curriculum')} subtitle={`${tp('common.modules', c.modules.length)} · ${tp('common.lessons', c.lesson_count)}`}>
          <Curriculum course={c} progress={progress.data ?? []} isPremium={isPremium} onLocked={goPaywall} />
        </Section>

        {c.instructor && (
          <Section title={tr('course.instructor')}>
            <Card style={{ flexDirection: 'row', gap: 14, alignItems: 'center' }}>
              <View style={[styles.avatar, { backgroundColor: t.colors.accentSoft }]}>
                <Text variant="title3" tone="accent">
                  {c.instructor.name.charAt(0)}
                </Text>
              </View>
              <View style={{ flex: 1, gap: 2 }}>
                <Text variant="headline">{c.instructor.name}</Text>
                {c.instructor.headline && (
                  <Text variant="footnote" tone="secondary">
                    {c.instructor.headline}
                  </Text>
                )}
              </View>
            </Card>
          </Section>
        )}

        {c.certificate_enabled && (
          <View style={{ paddingHorizontal: t.spacing.gutter }}>
            <Card style={{ flexDirection: 'row', gap: 14, borderColor: t.colors.accent, backgroundColor: t.colors.accentSoft }}>
              <Award size={26} color={t.colors.accent} strokeWidth={1.6} />
              <View style={{ flex: 1, gap: 4 }}>
                <Text variant="headline">{tr('course.certificate')}</Text>
                <Text variant="footnote" tone="secondary">
                  {tr('course.certificateBody')}
                  {settings.data?.certificates?.require_premium !== false && !isPremium ? ` ${tr('course.certificatePremium')}` : ''}
                </Text>
              </View>
            </Card>
          </View>
        )}
        <Text variant="caption" tone="tertiary" align="center">
          {number(c.lesson_count)} · {c.language.toUpperCase()}
        </Text>
      </ScrollScreen>

      <View style={[styles.ctaBar, { paddingBottom: insets.bottom + 12 }]}>
        <Glass style={StyleSheet.absoluteFill} intensity={50} />
        <View style={[styles.hairline, { backgroundColor: t.colors.border }]} />
        <Button title={cta} icon={locked ? Crown : undefined} onPress={primaryAction} loading={enroll.isPending} size="lg" fullWidth testID="course-cta" />
      </View>
    </View>
  );
}

function Stat({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <View style={{ flex: 1, gap: 6 }}>
      <Text variant="caption" tone="tertiary">
        {label}
      </Text>
      {children}
    </View>
  );
}

function Section({ title, subtitle, children }: { title: string; subtitle?: string; children: React.ReactNode }) {
  const t = useTheme();
  return (
    <View style={{ paddingHorizontal: t.spacing.gutter, gap: 14 }}>
      <View style={{ gap: 2 }}>
        <Text variant="title3" accessibilityRole="header">
          {title}
        </Text>
        {subtitle && (
          <Text variant="footnote" tone="tertiary">
            {subtitle}
          </Text>
        )}
      </View>
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  head: { gap: 12, marginTop: 20 },
  badges: { flexDirection: 'row', gap: 6, flexWrap: 'wrap' },
  stats: { flexDirection: 'row', paddingVertical: 14, borderTopWidth: StyleSheet.hairlineWidth, borderBottomWidth: StyleSheet.hairlineWidth, marginTop: 4 },
  inline: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  outcome: { flexDirection: 'row', gap: 12, alignItems: 'flex-start' },
  check: { width: 22, height: 22, borderRadius: 11, alignItems: 'center', justifyContent: 'center', marginTop: 1 },
  prereq: { padding: 14, gap: 2, borderWidth: StyleSheet.hairlineWidth },
  avatar: { width: 48, height: 48, borderRadius: 24, alignItems: 'center', justifyContent: 'center' },
  ctaBar: { position: 'absolute', left: 0, right: 0, bottom: 0, paddingHorizontal: 20, paddingTop: 12, alignItems: 'center' },
  hairline: { position: 'absolute', top: 0, left: 0, right: 0, height: StyleSheet.hairlineWidth },
});
