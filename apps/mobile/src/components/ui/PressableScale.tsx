import type { ReactNode } from 'react';
import { Pressable, type PressableProps, type StyleProp, type ViewStyle } from 'react-native';
import Animated, { useAnimatedStyle, useSharedValue, withSpring, withTiming } from 'react-native-reanimated';

import { haptics } from '@/lib/haptics';
import { useTheme } from '@/theme/ThemeProvider';

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

export interface PressableScaleProps extends Omit<PressableProps, 'style' | 'children'> {
  children: ReactNode;
  style?: StyleProp<ViewStyle>;
  scaleTo?: number;
  haptic?: 'tap' | 'select' | false;
  dimOnPress?: boolean;
}

/** The app's tactile primitive: a spring-scaled pressable with optional haptics. */
export function PressableScale({ children, style, scaleTo, haptic = 'tap', dimOnPress = false, onPressIn, onPressOut, onPress, disabled, ...rest }: PressableScaleProps) {
  const t = useTheme();
  const pressed = useSharedValue(0);
  const target = scaleTo ?? t.motion.pressScale;

  const animated = useAnimatedStyle(() => ({
    transform: [{ scale: 1 - pressed.value * (1 - target) }],
    opacity: dimOnPress ? 1 - pressed.value * 0.25 : 1,
  }));

  return (
    <AnimatedPressable
      accessibilityRole="button"
      {...rest}
      disabled={disabled}
      onPressIn={(e) => {
        pressed.value = t.reduceMotion ? withTiming(1, { duration: 60 }) : withSpring(1, t.motion.spring.snappy);
        onPressIn?.(e);
      }}
      onPressOut={(e) => {
        pressed.value = t.reduceMotion ? withTiming(0, { duration: 90 }) : withSpring(0, t.motion.spring.snappy);
        onPressOut?.(e);
      }}
      onPress={(e) => {
        if (haptic) haptics[haptic]();
        onPress?.(e);
      }}
      style={[animated, disabled && { opacity: 0.45 }, style]}>
      {children}
    </AnimatedPressable>
  );
}
