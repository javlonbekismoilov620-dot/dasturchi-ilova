import { useEffect, useState, type ReactNode } from 'react';
import { Modal, Pressable, StyleSheet, useWindowDimensions, View } from 'react-native';
import { Gesture, GestureDetector, GestureHandlerRootView } from 'react-native-gesture-handler';
import Animated, { runOnJS, useAnimatedStyle, useSharedValue, withSpring, withTiming } from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { useTheme } from '@/theme/ThemeProvider';

import { Text } from './Text';

/**
 * Bottom sheet with spring entrance, drag-to-dismiss and a dimmed backdrop.
 * Rendered in a transparent Modal so it layers above tabs and native headers.
 */
export function Sheet({ visible, onClose, title, children, maxHeightRatio = 0.86 }: { visible: boolean; onClose: () => void; title?: string; children: ReactNode; maxHeightRatio?: number }) {
  const t = useTheme();
  const insets = useSafeAreaInsets();
  const { height } = useWindowDimensions();
  // Stay mounted while the exit animation runs ("adjust state when a prop changes").
  const [mounted, setMounted] = useState(visible);
  if (visible && !mounted) setMounted(true);
  const y = useSharedValue(height);
  const backdrop = useSharedValue(0);

  useEffect(() => {
    if (visible) {
      y.set(height);
      y.set(t.reduceMotion ? withTiming(0, { duration: 160 }) : withSpring(0, { damping: 22, stiffness: 220, mass: 0.9 }));
      backdrop.set(withTiming(1, { duration: 220 }));
    } else {
      backdrop.set(withTiming(0, { duration: 180 }));
      y.set(
        withTiming(height, { duration: 220 }, (done) => {
          if (done) runOnJS(setMounted)(false);
        }),
      );
    }
  }, [visible]); // eslint-disable-line react-hooks/exhaustive-deps

  const pan = Gesture.Pan()
    .onUpdate((e) => {
      y.set(Math.max(0, e.translationY));
    })
    .onEnd((e) => {
      if (e.translationY > 120 || e.velocityY > 900) runOnJS(onClose)();
      else y.set(withSpring(0, { damping: 22, stiffness: 240 }));
    });

  const sheetStyle = useAnimatedStyle(() => ({ transform: [{ translateY: y.value }] }));
  const backdropStyle = useAnimatedStyle(() => ({ opacity: backdrop.value }));

  if (!mounted) return null;
  return (
    <Modal transparent visible animationType="none" onRequestClose={onClose} statusBarTranslucent navigationBarTranslucent>
      <GestureHandlerRootView style={styles.flex}>
        <Animated.View style={[StyleSheet.absoluteFill, { backgroundColor: t.colors.scrim }, backdropStyle]}>
          <Pressable style={styles.flex} onPress={onClose} accessibilityRole="button" accessibilityLabel="Close" />
        </Animated.View>
        <Animated.View
          accessibilityViewIsModal
          style={[
            styles.sheet,
            {
              backgroundColor: t.colors.backgroundElevated,
              borderTopLeftRadius: t.radii.xxl,
              borderTopRightRadius: t.radii.xxl,
              paddingBottom: insets.bottom + 16,
              maxHeight: height * maxHeightRatio,
              borderColor: t.colors.border,
            },
            sheetStyle,
          ]}>
          <GestureDetector gesture={pan}>
            <View style={styles.handleArea}>
              <View style={[styles.handle, { backgroundColor: t.colors.borderStrong }]} />
              {title && (
                <Text variant="title3" align="center" accessibilityRole="header" style={{ marginTop: 10 }}>
                  {title}
                </Text>
              )}
            </View>
          </GestureDetector>
          {children}
        </Animated.View>
      </GestureHandlerRootView>
    </Modal>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  sheet: { position: 'absolute', left: 0, right: 0, bottom: 0, borderWidth: StyleSheet.hairlineWidth, borderBottomWidth: 0, width: '100%', maxWidth: 720, alignSelf: 'center' },
  handleArea: { alignItems: 'center', paddingTop: 10, paddingBottom: 12, paddingHorizontal: 20 },
  handle: { width: 38, height: 5, borderRadius: 3 },
});
