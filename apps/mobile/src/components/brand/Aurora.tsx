import { useEffect } from 'react';
import { StyleSheet, useWindowDimensions, View } from 'react-native';
import Animated, { Easing, useAnimatedStyle, useSharedValue, withRepeat, withTiming } from 'react-native-reanimated';
import Svg, { Defs, RadialGradient, Rect, Stop } from 'react-native-svg';

import { useTheme } from '@/theme/ThemeProvider';

/**
 * Ambient light behind hero moments (splash, onboarding, paywall): two soft radial
 * glows that drift slowly. Deliberately subtle — atmosphere, not decoration.
 */
export function Aurora({ hue = 38, intensity = 1, secondaryHue }: { hue?: number; intensity?: number; secondaryHue?: number }) {
  const t = useTheme();
  const { width, height } = useWindowDimensions();
  const drift = useSharedValue(0);

  useEffect(() => {
    if (!t.reduceMotion) drift.value = withRepeat(withTiming(1, { duration: 9000, easing: Easing.inOut(Easing.sin) }), -1, true);
  }, [drift, t.reduceMotion]);

  const a = useAnimatedStyle(() => ({ transform: [{ translateX: -40 + drift.value * 80 }, { translateY: drift.value * 30 }, { scale: 1 + drift.value * 0.08 }] }));
  const b = useAnimatedStyle(() => ({ transform: [{ translateX: 30 - drift.value * 60 }, { translateY: -drift.value * 40 }] }));
  const alpha = (t.isDark ? 0.34 : 0.22) * intensity;
  const h2 = secondaryHue ?? (hue + 190) % 360;
  const size = Math.max(width, height) * 1.1;

  return (
    <View pointerEvents="none" style={StyleSheet.absoluteFill}>
      <Animated.View style={[{ position: 'absolute', top: -size * 0.35, left: -size * 0.25, width: size, height: size }, a]}>
        <Svg width={size} height={size}>
          <Defs>
            <RadialGradient id="ga" cx="50%" cy="50%" r="50%">
              <Stop offset="0" stopColor={`hsl(${hue}, 70%, 60%)`} stopOpacity={alpha} />
              <Stop offset="1" stopColor={`hsl(${hue}, 70%, 60%)`} stopOpacity={0} />
            </RadialGradient>
          </Defs>
          <Rect width={size} height={size} fill="url(#ga)" />
        </Svg>
      </Animated.View>
      <Animated.View style={[{ position: 'absolute', bottom: -size * 0.45, right: -size * 0.4, width: size, height: size }, b]}>
        <Svg width={size} height={size}>
          <Defs>
            <RadialGradient id="gb" cx="50%" cy="50%" r="50%">
              <Stop offset="0" stopColor={`hsl(${h2}, 60%, 55%)`} stopOpacity={alpha * 0.55} />
              <Stop offset="1" stopColor={`hsl(${h2}, 60%, 55%)`} stopOpacity={0} />
            </RadialGradient>
          </Defs>
          <Rect width={size} height={size} fill="url(#gb)" />
        </Svg>
      </Animated.View>
    </View>
  );
}
