import { Check, Flame } from 'lucide-react-native';
import { useEffect } from 'react';
import { StyleSheet, View } from 'react-native';
import Animated, { Easing, FadeInDown, FadeInUp, useAnimatedStyle, useSharedValue, withDelay, withRepeat, withSequence, withSpring, withTiming } from 'react-native-reanimated';

import { LogoMark } from '@/components/brand/Logo';
import { ProgressRing } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';
import { withAlpha } from '@/theme/tokens';

const LEVELS = ['zero', 'beginner', 'intermediate', 'advanced', 'professional', 'expert'] as const;

/** Slide 1 — the learning ladder from Zero to Expert. */
export function LadderVignette({ active }: { active: boolean }) {
  const t = useTheme();
  const { t: tr } = useI18n();
  return (
    <View style={styles.ladder}>
      {LEVELS.map((l, i) => (
        <Step key={l} index={i} active={active} label={i === 0 || i === LEVELS.length - 1 ? tr(`levels.${l}`) : ''} color={t.colors.accent} />
      ))}
      <Animated.View entering={active && !t.reduceMotion ? FadeInDown.delay(900).springify() : undefined} style={styles.summit}>
        <LogoMark size={44} />
      </Animated.View>
    </View>
  );
}

function Step({ index, active, label, color }: { index: number; active: boolean; label: string; color: string }) {
  const t = useTheme();
  const h = useSharedValue(t.reduceMotion ? 1 : 0);
  useEffect(() => {
    if (active && !t.reduceMotion) h.value = withDelay(index * 110, withSpring(1, { damping: 14, stiffness: 120 }));
  }, [active, h, index, t.reduceMotion]);
  const style = useAnimatedStyle(() => ({ height: (34 + index * 22) * h.value, opacity: 0.25 + h.value * 0.75 }));
  return (
    <View style={styles.stepCol}>
      <Animated.View style={[styles.step, { backgroundColor: withAlpha(color, 0.12 + index * 0.13), borderColor: withAlpha(color, 0.5) }, style]} />
      <Text variant="caption" tone="secondary" numberOfLines={1} style={{ marginTop: 6, width: 80 }} align="center">
        {label}
      </Text>
    </View>
  );
}

/** Slide 2 — a lesson card with code and a quiz answer being checked. */
export function PracticeVignette({ active }: { active: boolean }) {
  const t = useTheme();
  const anim = active && !t.reduceMotion;
  return (
    <View style={{ width: 290, gap: 12 }}>
      <Animated.View entering={anim ? FadeInUp.delay(80).springify().damping(16) : undefined} style={[styles.card, { backgroundColor: t.colors.codeBackground, borderColor: t.colors.border }]}>
        <Text variant="mono" color="#7DB8FF">
          {'<h1>'}
          <Text variant="mono" color="#E7E3DA">
            Salom, dunyo!
          </Text>
          {'</h1>'}
        </Text>
        <Text variant="mono" color="#C9A0FF">
          print<Text variant="mono" color="#9FDB9A">(&quot;Hello&quot;)</Text>
        </Text>
      </Animated.View>
      {['Input', 'Processing', 'Output'].map((label, i) => (
        <Animated.View
          key={label}
          entering={anim ? FadeInUp.delay(260 + i * 120).springify().damping(16) : undefined}
          style={[styles.option, { backgroundColor: i === 0 ? t.colors.successSoft : t.colors.surface, borderColor: i === 0 ? t.colors.success : t.colors.border }]}>
          <Text variant="subhead" tone={i === 0 ? 'success' : 'secondary'}>
            {label}
          </Text>
          {i === 0 && (
            <View style={[styles.check, { backgroundColor: t.colors.success }]}>
              <Check size={12} color="#08090C" strokeWidth={3} />
            </View>
          )}
        </Animated.View>
      ))}
    </View>
  );
}

/** Slide 3 — daily goal ring, streak flame and an earned badge. */
export function ProgressVignette({ active }: { active: boolean }) {
  const t = useTheme();
  const flame = useSharedValue(1);
  useEffect(() => {
    if (active && !t.reduceMotion) flame.value = withRepeat(withSequence(withTiming(1.12, { duration: 700, easing: Easing.inOut(Easing.sin) }), withTiming(1, { duration: 700 })), -1);
  }, [active, flame, t.reduceMotion]);
  const flameStyle = useAnimatedStyle(() => ({ transform: [{ scale: flame.value }] }));
  return (
    <View style={{ alignItems: 'center', gap: 18 }}>
      <ProgressRing value={active ? 0.72 : 0} size={170} stroke={12}>
        <Animated.View style={flameStyle}>
          <Flame size={44} color={t.colors.accent} fill={withAlpha(t.colors.accent, 0.25)} strokeWidth={1.6} />
        </Animated.View>
        <Text variant="title1" style={{ marginTop: 2 }}>
          12
        </Text>
      </ProgressRing>
      <View style={{ flexDirection: 'row', gap: 6 }}>
        {[1, 1, 1, 1, 1, 0.4, 0.2].map((o, i) => (
          <View key={i} style={[styles.day, { backgroundColor: withAlpha(t.colors.accent, o) }]} />
        ))}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  ladder: { flexDirection: 'row', alignItems: 'flex-end', gap: 8, height: 230, paddingTop: 50 },
  stepCol: { width: 44, alignItems: 'center', justifyContent: 'flex-end', overflow: 'visible' },
  step: { width: 40, borderRadius: 10, borderWidth: 1 },
  summit: { position: 'absolute', right: 0, top: -6, width: 44, alignItems: 'center' },
  card: { borderRadius: 16, padding: 16, gap: 6, borderWidth: StyleSheet.hairlineWidth },
  option: { height: 48, borderRadius: 14, borderWidth: 1, paddingHorizontal: 16, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  check: { width: 22, height: 22, borderRadius: 11, alignItems: 'center', justifyContent: 'center' },
  day: { width: 26, height: 8, borderRadius: 4 },
});
