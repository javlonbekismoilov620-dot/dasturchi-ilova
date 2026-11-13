import { LinearGradient } from 'expo-linear-gradient';
import { router } from 'expo-router';
import { Award, Bell, BookOpen, ChevronRight, Clock, Crown, Flame, MessageCircle, Settings, Target, Trophy, Zap } from 'lucide-react-native';
import { StyleSheet, View } from 'react-native';
import Animated, { FadeInUp } from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Aurora } from '@/components/brand/Aurora';
import { DemoBadge } from '@/components/feedback/Banners';
import { TAB_BAR_HEIGHT } from '@/components/navigation/TabBar';
import { Button } from '@/components/ui/Button';
import { DynamicIcon } from '@/components/ui/Icon';
import { EmptyState, IconButton, ListGroup, ListItem, ScrollScreen } from '@/components/ui/layout';
import { PressableScale } from '@/components/ui/PressableScale';
import { Card, Divider, Skeleton } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { useAuth } from '@/data/auth';
import { useAchievements, useCertificates, useEntitlements, useProfile, useStats } from '@/data/hooks';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

function WeekChart({ days }: { days: { date: string; seconds: number }[] }) {
  const t = useTheme();
  const { locale } = useI18n();
  const max = Math.max(...days.map((d) => d.seconds), 60);
  const label = (iso: string) => {
    try {
      return new Intl.DateTimeFormat(locale === 'uz' ? 'uz-Latn' : locale, { weekday: 'narrow' }).format(new Date(`${iso}T12:00:00`));
    } catch {
      return iso.slice(8);
    }
  };
  return (
    <View style={styles.chart} accessibilityLabel={days.map((d) => `${d.date}: ${Math.round(d.seconds / 60)} min`).join(', ')}>
      {days.map((d, i) => {
        const h = Math.max(4, (d.seconds / max) * 84);
        const today = i === days.length - 1;
        return (
          <View key={d.date} style={styles.barCol}>
            <Animated.View entering={t.reduceMotion ? undefined : FadeInUp.delay(i * 50).springify()} style={[styles.bar, { height: h, backgroundColor: d.seconds ? (today ? t.colors.accent : t.colors.accentSoft) : t.colors.surfaceHigh, borderRadius: 6 }]} />
            <Text variant="caption" tone={today ? 'accent' : 'tertiary'}>
              {label(d.date)}
            </Text>
          </View>
        );
      })}
    </View>
  );
}

export default function Profile() {
  const t = useTheme();
  const { t: tr, number, date } = useI18n();
  const insets = useSafeAreaInsets();
  const user = useAuth((s) => s.user);
  const profile = useProfile();
  const stats = useStats();
  const entitlements = useEntitlements();
  const { catalog, earned } = useAchievements();
  const certificates = useCertificates();

  if (!user) {
    return (
      <ScrollScreen title={tr('profile.title')} bottomInset={TAB_BAR_HEIGHT} right={<IconButton icon={Settings} label={tr('profile.settings')} onPress={() => router.push('/settings')} />}>
        <EmptyState icon={Trophy} title={tr('profile.guestTitle')} body={tr('profile.guestBody')} action={tr('common.signIn')} onAction={() => router.push('/auth')} />
      </ScrollScreen>
    );
  }

  const s = stats.data;
  const p = profile.data;
  const earnedIds = new Set(earned.data?.map((e) => e.achievement_id));
  const name = p?.display_name || user.email?.split('@')[0] || 'Learner';

  return (
    <ScrollScreen
      largeTitle={false}
      title={name}
      bottomInset={TAB_BAR_HEIGHT}
      onRefresh={() => void Promise.all([stats.refetch(), profile.refetch(), earned.refetch()])}
      refreshing={stats.isRefetching}
      right={
        <View style={{ flexDirection: 'row', gap: 8, alignItems: 'center' }}>
          <DemoBadge />
          <IconButton icon={Settings} glass label={tr('profile.settings')} onPress={() => router.push('/settings')} />
        </View>
      }
      hero={() => (
        <View style={[styles.hero, { paddingTop: insets.top + 64 }]}>
          <Aurora hue={38} intensity={0.6} />
          <LinearGradient pointerEvents="none" colors={['transparent', t.colors.background]} style={styles.heroFade} />
          <View style={[styles.avatar, { backgroundColor: t.colors.accentSoft, borderColor: t.colors.accent }]}>
            <Text variant="display" tone="accent">
              {name.charAt(0).toUpperCase()}
            </Text>
          </View>
          <Text variant="title1" align="center" accessibilityRole="header">
            {name}
          </Text>
          {p && (
            <Text variant="footnote" tone="secondary">
              {tr('profile.memberSince', { date: date(p.created_at, 'month') })}
            </Text>
          )}
          <Button title={tr('profile.editProfile')} variant="secondary" size="sm" onPress={() => router.push('/settings/profile')} style={{ marginTop: 6 }} />
        </View>
      )}>
      {entitlements.data?.is_premium ? (
        <View style={{ paddingHorizontal: t.spacing.gutter }}>
          <Card style={[styles.premium, { borderColor: t.colors.accent }]}>
            <Crown size={20} color={t.colors.accent} />
            <Text variant="headline" tone="accent" style={{ flex: 1 }}>
              {tr('profile.premiumActive')}
            </Text>
          </Card>
        </View>
      ) : (
        <View style={{ paddingHorizontal: t.spacing.gutter }}>
          <PressableScale onPress={() => router.push('/paywall')} style={[styles.premiumCta, { borderRadius: t.radii.xl, borderColor: t.colors.accent, backgroundColor: t.colors.accentSoft }]}>
            <Crown size={22} color={t.colors.accent} />
            <View style={{ flex: 1, gap: 2 }}>
              <Text variant="headline">{tr('profile.goPremium')}</Text>
              <Text variant="footnote" tone="secondary">
                {tr('profile.goPremiumBody')}
              </Text>
            </View>
            <ChevronRight size={20} color={t.colors.accent} />
          </PressableScale>
        </View>
      )}

      <View style={{ paddingHorizontal: t.spacing.gutter, gap: 12 }}>
        <Text variant="title3">{tr('profile.stats')}</Text>
        {s ? (
          <View style={styles.statsGrid}>
            {[
              { icon: Zap, label: tr('profile.xp'), value: number(s.total_xp), color: t.colors.info },
              { icon: Flame, label: tr('profile.streak'), value: `${s.current_streak}`, color: t.colors.accent },
              { icon: Target, label: tr('profile.bestStreak'), value: `${s.longest_streak}`, color: t.colors.warning },
              { icon: BookOpen, label: tr('profile.lessons'), value: number(s.lessons_completed), color: t.colors.success },
              { icon: Trophy, label: tr('profile.courses'), value: number(s.courses_completed), color: t.colors.accent },
              { icon: Clock, label: tr('profile.hours'), value: (s.total_seconds / 3600).toFixed(1), color: t.colors.info },
            ].map((x) => (
              <Card key={x.label} style={styles.stat}>
                <x.icon size={18} color={x.color} />
                <Text variant="title2">{x.value}</Text>
                <Text variant="caption" tone="tertiary" numberOfLines={1}>
                  {x.label}
                </Text>
              </Card>
            ))}
          </View>
        ) : (
          <Skeleton height={180} radius={t.radii.lg} />
        )}
        {s && (
          <Card style={{ gap: 12 }}>
            <Text variant="overline" tone="tertiary">
              {tr('profile.thisWeek')}
            </Text>
            <WeekChart days={s.last_7_days} />
          </Card>
        )}
      </View>

      <View style={{ paddingHorizontal: t.spacing.gutter, gap: 12 }}>
        <PressableScale onPress={() => router.push('/achievements')} haptic="select" style={styles.sectionLink}>
          <Text variant="title3">{tr('profile.achievements')}</Text>
          <Text variant="subhead" tone="secondary">
            {tr('achievements.summary', { earned: earnedIds.size, total: catalog.data?.length ?? 0 })}
          </Text>
        </PressableScale>
        <View style={styles.badges}>
          {(catalog.data ?? []).slice(0, 8).map((a) => {
            const got = earnedIds.has(a.id);
            return (
              <View key={a.id} style={[styles.badge, { backgroundColor: got ? t.colors.accentSoft : t.colors.surface, borderColor: got ? t.colors.accent : t.colors.border, opacity: got ? 1 : 0.5 }]} accessibilityLabel={`${a.title}${got ? '' : ` (${tr('achievements.locked')})`}`}>
                <DynamicIcon name={a.icon} size={22} color={got ? t.colors.accent : t.colors.textTertiary} />
              </View>
            );
          })}
        </View>
      </View>

      <ListGroup>
        <ListItem icon={Award} title={tr('profile.certificates')} value={String(certificates.data?.length ?? 0)} onPress={() => router.push('/certificates')} />
        <Divider inset={48} />
        <ListItem icon={Trophy} title={tr('profile.achievements')} onPress={() => router.push('/achievements')} />
        <Divider inset={48} />
        <ListItem icon={Bell} title={tr('profile.notifications')} onPress={() => router.push('/notifications')} />
        <Divider inset={48} />
        <ListItem icon={MessageCircle} title={tr('profile.assistant')} onPress={() => router.push('/assistant')} />
        <Divider inset={48} />
        <ListItem icon={Settings} title={tr('profile.settings')} onPress={() => router.push('/settings')} />
      </ListGroup>
    </ScrollScreen>
  );
}

const styles = StyleSheet.create({
  hero: { alignItems: 'center', gap: 8, paddingBottom: 24, overflow: 'hidden' },
  heroFade: { position: 'absolute', left: 0, right: 0, bottom: 0, height: 110 },
  avatar: { width: 96, height: 96, borderRadius: 48, alignItems: 'center', justifyContent: 'center', borderWidth: 2, marginBottom: 6 },
  premium: { flexDirection: 'row', alignItems: 'center', gap: 12, borderWidth: 1 },
  premiumCta: { flexDirection: 'row', alignItems: 'center', gap: 14, padding: 18, borderWidth: 1 },
  statsGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  stat: { flexBasis: '31%', flexGrow: 1, gap: 6, padding: 14 },
  chart: { flexDirection: 'row', alignItems: 'flex-end', justifyContent: 'space-between', height: 110 },
  barCol: { alignItems: 'center', gap: 6, flex: 1 },
  bar: { width: 18 },
  sectionLink: { flexDirection: 'row', alignItems: 'baseline', justifyContent: 'space-between' },
  badges: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  badge: { width: 56, height: 56, borderRadius: 28, alignItems: 'center', justifyContent: 'center', borderWidth: 1 },
});
