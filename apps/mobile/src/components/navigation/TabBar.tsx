import type { BottomTabBarProps } from 'expo-router/tabs';
import { Compass, GraduationCap, House, type LucideIcon, User } from 'lucide-react-native';
import { useEffect, useState } from 'react';
import { Pressable, StyleSheet, View, type LayoutChangeEvent } from 'react-native';
import Animated, { useAnimatedStyle, useSharedValue, withSpring, withTiming } from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Glass } from '@/components/ui/layout';
import { Text } from '@/components/ui/Text';
import { haptics } from '@/lib/haptics';
import { useI18n, type TKey } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

const TABS: Record<string, { icon: LucideIcon; label: TKey }> = {
  index: { icon: House, label: 'tabs.home' },
  explore: { icon: Compass, label: 'tabs.explore' },
  learning: { icon: GraduationCap, label: 'tabs.learning' },
  profile: { icon: User, label: 'tabs.profile' },
};

export const TAB_BAR_HEIGHT = 64;

function TabItem({ name, focused, onPress, onLongPress }: { name: string; focused: boolean; onPress: () => void; onLongPress: () => void }) {
  const t = useTheme();
  const { t: tr } = useI18n();
  const cfg = TABS[name];
  const s = useSharedValue(focused ? 1 : 0);
  useEffect(() => {
    s.value = t.reduceMotion ? withTiming(focused ? 1 : 0, { duration: 120 }) : withSpring(focused ? 1 : 0, t.motion.spring.snappy);
  }, [focused, s, t.reduceMotion, t.motion.spring.snappy]);
  const iconStyle = useAnimatedStyle(() => ({ transform: [{ scale: 1 + s.value * 0.08 }, { translateY: -s.value * 1 }] }));
  if (!cfg) return null;
  const Icon = cfg.icon;
  const color = focused ? t.colors.accent : t.colors.textTertiary;
  return (
    <Pressable
      onPress={onPress}
      onLongPress={onLongPress}
      accessibilityRole="tab"
      accessibilityState={{ selected: focused }}
      accessibilityLabel={tr(cfg.label)}
      style={styles.item}
      testID={`tab-${name}`}>
      <Animated.View style={iconStyle}>
        <Icon size={22} color={color} strokeWidth={focused ? 2.2 : 1.8} />
      </Animated.View>
      <Text variant="caption" color={color} style={{ fontSize: 10.5, fontFamily: focused ? t.fonts.semibold : t.fonts.medium }} numberOfLines={1}>
        {tr(cfg.label)}
      </Text>
    </Pressable>
  );
}

export function TabBar({ state, descriptors, emitter, navigateToTab }: BottomTabBarProps) {
  const t = useTheme();
  const insets = useSafeAreaInsets();
  const [width, setWidth] = useState(0);
  const routes = state.routes.filter((r) => TABS[r.name]);
  const count = routes.length;
  const focusedIndex = Math.max(0, routes.findIndex((r) => r.key === state.routes[state.index]?.key));
  const x = useSharedValue(0);
  const itemWidth = width / Math.max(1, count);

  useEffect(() => {
    const target = focusedIndex * itemWidth;
    x.value = t.reduceMotion || !width ? target : withSpring(target, { damping: 20, stiffness: 220, mass: 0.8 });
  }, [focusedIndex, itemWidth, width, x, t.reduceMotion]);

  const indicator = useAnimatedStyle(() => ({ transform: [{ translateX: x.value }] }));

  return (
    <View pointerEvents="box-none" style={[styles.wrap, { paddingBottom: Math.max(insets.bottom, 12) }]}>
      <View style={[styles.bar, { borderColor: t.colors.border, borderRadius: t.radii.xxl }, t.elevation(2)]} onLayout={(e: LayoutChangeEvent) => setWidth(e.nativeEvent.layout.width - 12)} accessibilityRole="tablist">
        <Glass style={[StyleSheet.absoluteFill, { borderRadius: t.radii.xxl }]} intensity={60} />
        {width > 0 && (
          <Animated.View style={[styles.indicator, { width: itemWidth, backgroundColor: t.colors.accentSoft, borderRadius: t.radii.xl }, indicator]} />
        )}
        {routes.map((route) => {
          const focused = route.key === state.routes[state.index]?.key;
          return (
            <TabItem
              key={route.key}
              name={route.name}
              focused={focused}
              onPress={() => {
                haptics.select();
                const event = emitter.emit({ type: 'tabPress', target: route.key, canPreventDefault: true });
                if (!focused && !event.defaultPrevented) navigateToTab(route.key);
              }}
              onLongPress={() => emitter.emit({ type: 'tabLongPress', target: route.key })}
            />
          );
        })}
        {/* keep descriptors referenced for future per-tab options (badges) */}
        {descriptors ? null : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { position: 'absolute', left: 0, right: 0, bottom: 0, alignItems: 'center', paddingHorizontal: 16 },
  bar: { flexDirection: 'row', height: TAB_BAR_HEIGHT, width: '100%', maxWidth: 520, padding: 6, overflow: 'hidden', borderWidth: StyleSheet.hairlineWidth },
  indicator: { position: 'absolute', top: 6, bottom: 6, left: 6 },
  item: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 3 },
});
