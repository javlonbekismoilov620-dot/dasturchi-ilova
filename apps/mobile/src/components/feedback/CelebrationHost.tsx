import { router } from 'expo-router';
import { Award, Sparkles } from 'lucide-react-native';
import { useEffect, useMemo } from 'react';
import { StyleSheet, useWindowDimensions, View } from 'react-native';
import Animated, { Easing, FadeIn, FadeOut, useAnimatedStyle, useSharedValue, withDelay, withSequence, withSpring, withTiming, ZoomIn } from 'react-native-reanimated';

import { Button } from '@/components/ui/Button';
import { DynamicIcon } from '@/components/ui/Icon';
import { Text } from '@/components/ui/Text';
import { useCelebrations, type Celebration } from '@/data/hooks';
import { haptics } from '@/lib/haptics';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

const tierColor = { bronze: '#D89A6A', silver: '#C9CED6', gold: '#E8C07A', platinum: '#9FE3D6' } as const;

function Particle({ i, color }: { i: number; color: string }) {
  const { width, height } = useWindowDimensions();
  const p = useSharedValue(0);
  const angle = (i / 18) * Math.PI * 2 + (i % 3) * 0.2;
  const dist = Math.min(width, height) * (0.28 + (i % 4) * 0.05);
  useEffect(() => {
    p.value = withDelay(80 + (i % 5) * 20, withTiming(1, { duration: 1100, easing: Easing.out(Easing.cubic) }));
  }, [p, i]);
  const style = useAnimatedStyle(() => ({
    opacity: 1 - p.value,
    transform: [{ translateX: Math.cos(angle) * dist * p.value }, { translateY: Math.sin(angle) * dist * p.value + p.value * p.value * 60 }, { rotate: `${p.value * 260}deg` }, { scale: 1 - p.value * 0.4 }],
  }));
  return <Animated.View style={[styles.particle, { backgroundColor: color, width: i % 2 ? 6 : 10, height: i % 2 ? 10 : 6 }, style]} />;
}

function Content({ item, onDone }: { item: Celebration; onDone: () => void }) {
  const t = useTheme();
  const { t: tr } = useI18n();
  const glow = useSharedValue(0);
  useEffect(() => {
    haptics.success();
    glow.value = withSequence(withSpring(1, { damping: 8 }), withTiming(0.7, { duration: 600 }));
  }, [glow]);
  const glowStyle = useAnimatedStyle(() => ({ transform: [{ scale: 0.6 + glow.value * 0.6 }], opacity: glow.value * 0.9 }));
  const colors = useMemo(() => ['#E8C07A', '#F6DDAA', '#7DB8FF', '#5FD39B', '#E879F9'], []);

  if (item.kind === 'xp') return null;
  const isCert = item.kind === 'certificate';
  const accent = item.kind === 'achievement' ? tierColor[item.achievement.tier] : t.colors.accent;

  return (
    <Animated.View entering={FadeIn.duration(200)} exiting={FadeOut.duration(200)} style={[StyleSheet.absoluteFill, styles.center, { backgroundColor: t.colors.overlay }]}>
      {!t.reduceMotion && Array.from({ length: 18 }, (_, i) => <Particle key={i} i={i} color={colors[i % colors.length]} />)}
      <Animated.View entering={ZoomIn.springify().damping(14)} style={[styles.card, { backgroundColor: t.colors.backgroundElevated, borderColor: t.colors.borderStrong, borderRadius: t.radii.xxl }, t.elevation(3)]}>
        <View style={styles.badgeWrap}>
          <Animated.View style={[styles.glow, { backgroundColor: accent }, glowStyle]} />
          <View style={[styles.badge, { borderColor: accent, backgroundColor: t.colors.surface }]}>
            {isCert ? <Award size={40} color={accent} strokeWidth={1.6} /> : <DynamicIcon name={item.achievement.icon} size={40} color={accent} strokeWidth={1.6} />}
          </View>
        </View>
        <Text variant="overline" tone="accent" align="center">
          {isCert ? tr('certificates.earnedTitle') : tr('achievements.unlockedTitle')}
        </Text>
        <Text variant="title1" align="center">
          {isCert ? item.courseTitle : item.achievement.title}
        </Text>
        {!isCert && (
          <Text variant="subhead" tone="secondary" align="center">
            {tr(`achievements.tiers.${item.achievement.tier}`)}
          </Text>
        )}
        <View style={{ gap: 10, alignSelf: 'stretch', marginTop: 8 }}>
          {isCert && (
            <Button
              title={tr('common.open')}
              icon={Sparkles}
              onPress={() => {
                onDone();
                router.push({ pathname: '/certificates/[id]', params: { id: item.certificateId } });
              }}
            />
          )}
          <Button title={tr('celebrate.keepGoing')} variant={isCert ? 'ghost' : 'primary'} onPress={onDone} />
        </View>
      </Animated.View>
    </Animated.View>
  );
}

/** Lightweight "+XP" pill that floats up without interrupting. */
function XpToast({ amount, onDone }: { amount: number; onDone: () => void }) {
  const t = useTheme();
  const y = useSharedValue(0);
  useEffect(() => {
    haptics.success();
    y.value = withSequence(withSpring(1, { damping: 12 }), withDelay(1100, withTiming(2, { duration: 300 })));
    const id = setTimeout(onDone, 1700);
    return () => clearTimeout(id);
  }, [y, onDone]);
  const style = useAnimatedStyle(() => ({ opacity: y.value <= 1 ? y.value : 2 - y.value, transform: [{ translateY: 40 - Math.min(y.value, 1) * 40 - Math.max(0, y.value - 1) * 20 }] }));
  return (
    <View pointerEvents="none" style={[StyleSheet.absoluteFill, { alignItems: 'center', justifyContent: 'flex-end', paddingBottom: 140 }]}>
      <Animated.View style={[styles.xp, { backgroundColor: t.colors.accent }, style]} accessibilityLiveRegion="polite">
        <Sparkles size={16} color={t.colors.onAccent} />
        <Text variant="headline" color={t.colors.onAccent}>
          +{amount} XP
        </Text>
      </Animated.View>
    </View>
  );
}

export function CelebrationHost() {
  const queue = useCelebrations((s) => s.queue);
  const shift = useCelebrations((s) => s.shift);
  const current = queue[0];
  if (!current) return null;
  if (current.kind === 'xp') return <XpToast key={`xp-${queue.length}`} amount={current.amount} onDone={shift} />;
  return <Content key={`${current.kind}-${queue.length}`} item={current} onDone={shift} />;
}

const styles = StyleSheet.create({
  center: { alignItems: 'center', justifyContent: 'center', zIndex: 900, padding: 24 },
  card: { width: '100%', maxWidth: 380, padding: 28, alignItems: 'center', gap: 10, borderWidth: StyleSheet.hairlineWidth },
  badgeWrap: { width: 120, height: 120, alignItems: 'center', justifyContent: 'center', marginBottom: 8 },
  glow: { position: 'absolute', width: 120, height: 120, borderRadius: 60, opacity: 0.4 },
  badge: { width: 92, height: 92, borderRadius: 46, borderWidth: 2, alignItems: 'center', justifyContent: 'center' },
  particle: { position: 'absolute', borderRadius: 2 },
  xp: { flexDirection: 'row', alignItems: 'center', gap: 8, paddingHorizontal: 18, height: 44, borderRadius: 22 },
});
