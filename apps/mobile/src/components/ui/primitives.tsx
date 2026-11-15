import { LinearGradient } from 'expo-linear-gradient';
import type { LucideIcon } from 'lucide-react-native';
import { useEffect, type ReactNode } from 'react';
import { StyleSheet, View, type DimensionValue, type StyleProp, type ViewStyle } from 'react-native';
import Animated, {
  Easing,
  interpolate,
  useAnimatedProps,
  useAnimatedStyle,
  useSharedValue,
  withRepeat,
  withSpring,
  withTiming,
} from 'react-native-reanimated';
import Svg, { Circle, Defs, Stop, LinearGradient as SvgGradient } from 'react-native-svg';

import { useTheme } from '@/theme/ThemeProvider';
import { withAlpha } from '@/theme/tokens';

import { PressableScale } from './PressableScale';
import { Text } from './Text';

// ---------------------------------------------------------------------------
// Card
// ---------------------------------------------------------------------------
export function Card({ children, style, padded = true, elevated = false }: { children: ReactNode; style?: StyleProp<ViewStyle>; padded?: boolean; elevated?: boolean }) {
  const t = useTheme();
  return (
    <View
      style={[
        {
          backgroundColor: t.colors.surface,
          borderRadius: t.radii.lg,
          borderWidth: StyleSheet.hairlineWidth,
          borderColor: t.colors.border,
          padding: padded ? t.spacing.lg : 0,
        },
        elevated && t.elevation(1),
        style,
      ]}>
      {children}
    </View>
  );
}

// ---------------------------------------------------------------------------
// Badge
// ---------------------------------------------------------------------------
type BadgeTone = 'neutral' | 'accent' | 'success' | 'warning' | 'danger' | 'info' | 'custom' | 'cover' | 'coverAccent';

export function Badge({ label, tone = 'neutral', icon: Icon, color, solid = false }: { label: string; tone?: BadgeTone; icon?: LucideIcon; color?: string; solid?: boolean }) {
  const t = useTheme();
  const c = t.colors;
  const map = {
    neutral: [c.surfaceHigh, c.textSecondary],
    accent: [c.accentSoft, c.accent],
    success: [c.successSoft, c.success],
    warning: [c.warningSoft, c.warning],
    danger: [c.dangerSoft, c.danger],
    info: [c.infoSoft, c.info],
    custom: [withAlpha(color ?? c.accent, 0.16), color ?? c.accent],
    // On generative covers (always dark artwork) — independent of the app theme.
    cover: ['rgba(8,9,12,0.55)', '#FFFFFF'],
    coverAccent: ['rgba(8,9,12,0.62)', '#F2D49B'],
  } as const;
  const [bg, fg] = map[tone];
  return (
    <View style={[styles.badge, { backgroundColor: solid ? fg : bg, borderRadius: t.radii.pill }]}>
      {Icon && <Icon size={12} color={solid ? c.background : fg} strokeWidth={2.2} />}
      <Text variant="caption" color={solid ? c.background : fg} numberOfLines={1}>
        {label}
      </Text>
    </View>
  );
}

// ---------------------------------------------------------------------------
// Chip (selectable)
// ---------------------------------------------------------------------------
export function Chip({ label, selected, onPress, icon: Icon, color, accessibilityLabel }: { label: string; selected?: boolean; onPress?: () => void; icon?: LucideIcon; color?: string; accessibilityLabel?: string }) {
  const t = useTheme();
  const active = useSharedValue(selected ? 1 : 0);
  useEffect(() => {
    active.value = t.reduceMotion ? (selected ? 1 : 0) : withSpring(selected ? 1 : 0, t.motion.spring.snappy);
  }, [selected, active, t.reduceMotion, t.motion.spring.snappy]);
  const accent = color ?? t.colors.accent;
  const ring = useAnimatedStyle(() => ({ opacity: active.value, transform: [{ scale: 0.92 + active.value * 0.08 }] }));
  return (
    <PressableScale
      onPress={onPress}
      haptic="select"
      accessibilityRole="checkbox"
      accessibilityState={{ checked: !!selected }}
      accessibilityLabel={accessibilityLabel ?? label}
      style={[styles.chip, { borderRadius: t.radii.pill, backgroundColor: t.colors.surface, borderColor: t.colors.border }]}>
      <Animated.View pointerEvents="none" style={[StyleSheet.absoluteFill, { borderRadius: t.radii.pill, backgroundColor: withAlpha(accent, t.isDark ? 0.16 : 0.12), borderWidth: 1.5, borderColor: accent }, ring]} />
      {Icon && <Icon size={16} color={selected ? accent : t.colors.textSecondary} strokeWidth={1.9} />}
      <Text variant="subhead" color={selected ? (t.isDark ? t.colors.text : accent) : t.colors.textSecondary}>
        {label}
      </Text>
    </PressableScale>
  );
}

// ---------------------------------------------------------------------------
// Progress
// ---------------------------------------------------------------------------
export function ProgressBar({ value, height = 6, color, track, style }: { value: number; height?: number; color?: string; track?: string; style?: StyleProp<ViewStyle> }) {
  const t = useTheme();
  const v = useSharedValue(0);
  useEffect(() => {
    const clamped = Math.max(0, Math.min(1, value));
    v.value = t.reduceMotion ? clamped : withTiming(clamped, { duration: 700, easing: Easing.out(Easing.cubic) });
  }, [value, v, t.reduceMotion]);
  const fill = useAnimatedStyle(() => ({ width: `${v.value * 100}%` as DimensionValue }));
  return (
    <View
      accessibilityRole="progressbar"
      accessibilityValue={{ min: 0, max: 100, now: Math.round(value * 100) }}
      style={[{ height, borderRadius: height, backgroundColor: track ?? t.colors.surfaceHigh, overflow: 'hidden' }, style]}>
      <Animated.View style={[{ height, borderRadius: height, backgroundColor: color ?? t.colors.accent }, fill]} />
    </View>
  );
}

const AnimatedCircle = Animated.createAnimatedComponent(Circle);

export function ProgressRing({ value, size = 64, stroke = 6, children, color, track }: { value: number; size?: number; stroke?: number; children?: ReactNode; color?: string; track?: string }) {
  const t = useTheme();
  const r = (size - stroke) / 2;
  const circumference = 2 * Math.PI * r;
  const v = useSharedValue(0);
  useEffect(() => {
    const clamped = Math.max(0, Math.min(1, value));
    v.value = t.reduceMotion ? clamped : withTiming(clamped, { duration: 1100, easing: Easing.out(Easing.cubic) });
  }, [value, v, t.reduceMotion]);
  const props = useAnimatedProps(() => ({ strokeDashoffset: circumference * (1 - v.value) }));
  const accent = color ?? t.colors.accent;
  return (
    <View style={{ width: size, height: size, alignItems: 'center', justifyContent: 'center' }} accessibilityRole="progressbar" accessibilityValue={{ min: 0, max: 100, now: Math.round(value * 100) }}>
      <Svg width={size} height={size} style={StyleSheet.absoluteFill}>
        <Defs>
          <SvgGradient id="ring" x1="0" y1="0" x2="1" y2="1">
            <Stop offset="0" stopColor={t.isDark ? '#F8E3B6' : accent} />
            <Stop offset="1" stopColor={accent} />
          </SvgGradient>
        </Defs>
        <Circle cx={size / 2} cy={size / 2} r={r} stroke={track ?? t.colors.surfaceHigh} strokeWidth={stroke} fill="none" />
        <AnimatedCircle
          cx={size / 2}
          cy={size / 2}
          r={r}
          stroke={color ? accent : 'url(#ring)'}
          strokeWidth={stroke}
          strokeLinecap="round"
          fill="none"
          strokeDasharray={`${circumference} ${circumference}`}
          animatedProps={props}
          transform={`rotate(-90 ${size / 2} ${size / 2})`}
        />
      </Svg>
      {children}
    </View>
  );
}

// ---------------------------------------------------------------------------
// Skeleton (shimmer)
// ---------------------------------------------------------------------------
export function Skeleton({ width = '100%', height = 16, radius, style }: { width?: DimensionValue; height?: DimensionValue; radius?: number; style?: StyleProp<ViewStyle> }) {
  const t = useTheme();
  const x = useSharedValue(0);
  useEffect(() => {
    if (!t.reduceMotion) x.value = withRepeat(withTiming(1, { duration: 1300, easing: Easing.inOut(Easing.quad) }), -1, false);
  }, [x, t.reduceMotion]);
  const shimmer = useAnimatedStyle(() => ({ transform: [{ translateX: interpolate(x.value, [0, 1], [-260, 360]) }] }));
  return (
    <View
      accessibilityElementsHidden
      importantForAccessibility="no-hide-descendants"
      style={[{ width, height, borderRadius: radius ?? t.radii.sm, backgroundColor: t.colors.skeleton, overflow: 'hidden' }, style]}>
      <Animated.View style={[StyleSheet.absoluteFill, { width: 220 }, shimmer]}>
        <LinearGradient colors={['transparent', t.colors.skeletonHighlight, 'transparent']} start={{ x: 0, y: 0.5 }} end={{ x: 1, y: 0.5 }} style={StyleSheet.absoluteFill} />
      </Animated.View>
    </View>
  );
}

// ---------------------------------------------------------------------------
// Divider & spacing
// ---------------------------------------------------------------------------
export function Divider({ inset = 0, style }: { inset?: number; style?: StyleProp<ViewStyle> }) {
  const t = useTheme();
  return <View style={[{ height: StyleSheet.hairlineWidth, backgroundColor: t.colors.border, marginLeft: inset }, style]} />;
}

export function Spacer({ size = 16 }: { size?: number }) {
  return <View style={{ height: size, width: size }} />;
}

const styles = StyleSheet.create({
  badge: { flexDirection: 'row', alignItems: 'center', gap: 4, paddingHorizontal: 8, paddingVertical: 3, alignSelf: 'flex-start' },
  chip: { flexDirection: 'row', alignItems: 'center', gap: 8, paddingHorizontal: 16, height: 44, borderWidth: StyleSheet.hairlineWidth },
});
