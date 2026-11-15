import * as SplashScreen from 'expo-splash-screen';
import { useEffect, useState } from 'react';
import { StyleSheet, View } from 'react-native';
import Animated, { Easing, runOnJS, useAnimatedStyle, useSharedValue, withDelay, withTiming } from 'react-native-reanimated';

import { Text } from '@/components/ui/Text';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';
import { colors } from '@/theme/tokens';

import { Aurora } from './Aurora';
import { LogoMark } from './Logo';

/**
 * Cinematic launch: the native splash (static mark on ink) hands over to this overlay,
 * which draws the mark, reveals the wordmark and tagline, then dissolves into the app.
 * It waits for `ready` (fonts + session + preferences) and never blocks longer than
 * needed; with Reduce Motion it becomes a short cross-fade.
 */
export function AnimatedSplash({ ready }: { ready: boolean }) {
  const t = useTheme();
  const { t: tr } = useI18n();
  const [visible, setVisible] = useState(true);
  const [introDone, setIntroDone] = useState(t.reduceMotion);
  const word = useSharedValue(0);
  const exit = useSharedValue(0);

  useEffect(() => {
    // Swap native splash → JS splash on the first frame (identical ink background).
    SplashScreen.hideAsync().catch(() => {});
    if (t.reduceMotion) {
      word.value = 1;
      return;
    }
    word.value = withDelay(650, withTiming(1, { duration: 700, easing: Easing.out(Easing.cubic) }));
    const id = setTimeout(() => setIntroDone(true), 1650);
    return () => clearTimeout(id);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (ready && introDone) {
      exit.value = withTiming(1, { duration: t.reduceMotion ? 200 : 520, easing: Easing.inOut(Easing.cubic) }, (done) => {
        if (done) runOnJS(setVisible)(false);
      });
    }
  }, [ready, introDone, exit, t.reduceMotion]);

  const container = useAnimatedStyle(() => ({ opacity: 1 - exit.value, transform: [{ scale: 1 + exit.value * 0.06 }] }));
  const wordStyle = useAnimatedStyle(() => ({ opacity: word.value, transform: [{ translateY: (1 - word.value) * 10 }], letterSpacing: 6 - word.value * 5.5 }));
  const tagStyle = useAnimatedStyle(() => ({ opacity: word.value * 0.8 }));

  if (!visible) return null;
  return (
    <Animated.View pointerEvents={ready && introDone ? 'none' : 'auto'} style={[StyleSheet.absoluteFill, styles.root, { backgroundColor: colors.dark.background }, container]}>
      <Aurora hue={38} intensity={0.9} />
      <View style={styles.center}>
        <LogoMark size={92} animate delay={120} />
        <Animated.Text style={[{ fontFamily: t.fonts.display, fontSize: 44, color: colors.dark.text, marginTop: 18 }, wordStyle]}>Mahorat</Animated.Text>
        <Animated.View style={tagStyle}>
          <Text variant="overline" color={colors.dark.accent} style={{ marginTop: 10, letterSpacing: 3 }}>
            {tr('splash.tagline')}
          </Text>
        </Animated.View>
      </View>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  root: { zIndex: 999, alignItems: 'center', justifyContent: 'center' },
  center: { alignItems: 'center' },
});
