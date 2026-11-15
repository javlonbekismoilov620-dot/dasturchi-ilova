import { useEffect } from 'react';
import { View } from 'react-native';
import Animated, { Easing, useAnimatedProps, useSharedValue, withDelay, withSpring, withTiming } from 'react-native-reanimated';
import Svg, { Circle, Defs, LinearGradient, Path, Stop } from 'react-native-svg';

import { Text } from '@/components/ui/Text';
import { useTheme } from '@/theme/ThemeProvider';

// Must match scripts/generate-brand-assets.mjs
export const MARK_PATH = 'M12 51 L23 31 L32 43 L44 21 L52 35';
const MARK_LENGTH = 80;

const AnimatedPath = Animated.createAnimatedComponent(Path);
const AnimatedCircle = Animated.createAnimatedComponent(Circle);

export function LogoMark({ size = 40, animate = false, delay = 0, mono }: { size?: number; animate?: boolean; delay?: number; mono?: string }) {
  const t = useTheme();
  const draw = useSharedValue(animate ? 0 : 1);
  const dot = useSharedValue(animate ? 0 : 1);

  useEffect(() => {
    if (!animate) return;
    if (t.reduceMotion) {
      draw.value = 1;
      dot.value = 1;
      return;
    }
    draw.value = withDelay(delay, withTiming(1, { duration: 950, easing: Easing.bezier(0.65, 0, 0.35, 1) }));
    dot.value = withDelay(delay + 820, withSpring(1, { damping: 9, stiffness: 180 }));
  }, [animate, delay, draw, dot, t.reduceMotion]);

  const pathProps = useAnimatedProps(() => ({ strokeDashoffset: MARK_LENGTH * (1 - draw.value) }));
  const dotProps = useAnimatedProps(() => ({ r: 3.6 * dot.value }));
  const fill = mono ?? 'url(#mahoratGold)';

  return (
    <Svg width={size} height={size} viewBox="0 0 64 64" accessibilityLabel="Mahorat">
      <Defs>
        <LinearGradient id="mahoratGold" x1="0" y1="0" x2="0.35" y2="1">
          <Stop offset="0" stopColor="#FBE6BE" />
          <Stop offset="0.55" stopColor="#E8C07A" />
          <Stop offset="1" stopColor={t.isDark ? '#B98434' : '#9A6A22'} />
        </LinearGradient>
      </Defs>
      <AnimatedPath d={MARK_PATH} fill="none" stroke={fill} strokeWidth={6} strokeLinecap="round" strokeLinejoin="round" strokeDasharray={`${MARK_LENGTH} ${MARK_LENGTH}`} animatedProps={pathProps} />
      <AnimatedCircle cx={44} cy={11} fill={fill} animatedProps={dotProps} />
    </Svg>
  );
}

export function Wordmark({ size = 28, color }: { size?: number; color?: string }) {
  const t = useTheme();
  return (
    <Text style={{ fontFamily: t.fonts.display, fontSize: size, lineHeight: size * 1.1, letterSpacing: size * 0.01, color: color ?? t.colors.text }} accessibilityRole="header">
      Mahorat
    </Text>
  );
}

export function Logo({ size = 28 }: { size?: number }) {
  return (
    <View style={{ flexDirection: 'row', alignItems: 'center', gap: size * 0.28 }}>
      <LogoMark size={size * 1.25} />
      <Wordmark size={size} />
    </View>
  );
}
