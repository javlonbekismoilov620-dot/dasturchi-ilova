import { BlurView } from 'expo-blur';
import { router } from 'expo-router';
import { ChevronLeft, ChevronRight, type LucideIcon } from 'lucide-react-native';
import type { ReactNode } from 'react';
import { Platform, RefreshControl, StyleSheet, View, type ScrollViewProps, type StyleProp, type ViewStyle } from 'react-native';
import Animated, { interpolate, useAnimatedRef, useAnimatedStyle, useScrollOffset, type SharedValue } from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

import { Button } from './Button';
import { PressableScale } from './PressableScale';
import { Text } from './Text';

// ---------------------------------------------------------------------------
// Glass surface: native blur on iOS/web; translucent fill on Android where
// real-time blur is costly.
// ---------------------------------------------------------------------------
export function Glass({ style, children, intensity = 40 }: { style?: StyleProp<ViewStyle>; children?: ReactNode; intensity?: number }) {
  const t = useTheme();
  if (Platform.OS === 'android') return <View style={[{ backgroundColor: t.colors.tabBar }, style]}>{children}</View>;
  return (
    <BlurView intensity={intensity} tint={t.isDark ? 'dark' : 'light'} style={[{ backgroundColor: t.isDark ? 'rgba(10,11,14,0.55)' : 'rgba(251,250,247,0.6)' }, style]}>
      {children}
    </BlurView>
  );
}

// ---------------------------------------------------------------------------
// IconButton
// ---------------------------------------------------------------------------
export function IconButton({ icon: Icon, onPress, label, size = 40, glass = false, color, active, style }: { icon: LucideIcon; onPress?: () => void; label: string; size?: number; glass?: boolean; color?: string; active?: boolean; style?: StyleProp<ViewStyle> }) {
  const t = useTheme();
  const inner = <Icon size={size * 0.48} color={color ?? (active ? t.colors.accent : t.colors.text)} strokeWidth={1.9} />;
  return (
    <PressableScale onPress={onPress} accessibilityLabel={label} haptic="select" hitSlop={6} style={[{ width: size, height: size, borderRadius: size / 2, overflow: 'hidden' }, style]}>
      {glass ? (
        <Glass intensity={30} style={[StyleSheet.absoluteFill, styles.center, { borderRadius: size / 2 }]}>{inner}</Glass>
      ) : (
        <View style={[StyleSheet.absoluteFill, styles.center, { backgroundColor: active ? t.colors.accentSoft : t.colors.surfaceHigh, borderRadius: size / 2 }]}>{inner}</View>
      )}
    </PressableScale>
  );
}

export function BackButton({ glass = false }: { glass?: boolean }) {
  const { t } = useI18n();
  return <IconButton icon={ChevronLeft} label={t('common.back')} glass={glass} onPress={() => (router.canGoBack() ? router.back() : router.replace('/'))} />;
}

// ---------------------------------------------------------------------------
// Screen with collapsing title header
// ---------------------------------------------------------------------------
interface ScrollScreenProps extends Omit<ScrollViewProps, 'children'> {
  title?: string;
  largeTitle?: boolean;
  back?: boolean;
  right?: ReactNode;
  children: ReactNode;
  refreshing?: boolean;
  onRefresh?: () => void;
  contentStyle?: StyleProp<ViewStyle>;
  bottomInset?: number;
  hero?: (scrollY: SharedValue<number>) => ReactNode;
}

export function ScrollScreen({ title, largeTitle = true, back, right, children, refreshing, onRefresh, contentStyle, bottomInset = 0, hero, ...rest }: ScrollScreenProps) {
  const t = useTheme();
  const insets = useSafeAreaInsets();
  const ref = useAnimatedRef<Animated.ScrollView>();
  const y = useScrollOffset(ref);
  const headerHeight = insets.top + 52;

  const barBg = useAnimatedStyle(() => ({ opacity: interpolate(y.value, [0, 40], [0, 1], 'clamp') }));
  const barTitle = useAnimatedStyle(() => ({
    opacity: largeTitle && !hero ? interpolate(y.value, [24, 56], [0, 1], 'clamp') : hero ? interpolate(y.value, [140, 200], [0, 1], 'clamp') : 1,
    transform: [{ translateY: largeTitle ? interpolate(y.value, [24, 56], [6, 0], 'clamp') : 0 }],
  }));
  const bigTitle = useAnimatedStyle(() => ({
    opacity: interpolate(y.value, [0, 40], [1, 0], 'clamp'),
    transform: [{ scale: interpolate(y.value, [-80, 0], [1.08, 1], 'clamp') }],
  }));

  return (
    <View style={[styles.flex, { backgroundColor: t.colors.background }]}>
      <Animated.ScrollView
        ref={ref}
        scrollEventThrottle={16}
        showsVerticalScrollIndicator={false}
        contentInsetAdjustmentBehavior="never"
        keyboardShouldPersistTaps="handled"
        refreshControl={onRefresh ? <RefreshControl refreshing={!!refreshing} onRefresh={onRefresh} tintColor={t.colors.accent} progressViewOffset={headerHeight} /> : undefined}
        {...rest}
        contentContainerStyle={[{ paddingTop: hero ? 0 : headerHeight, paddingBottom: insets.bottom + 32 + bottomInset }, contentStyle]}>
        {hero?.(y)}
        {largeTitle && title && !hero && (
          <Animated.View style={[{ paddingHorizontal: t.spacing.gutter, paddingTop: 4, paddingBottom: 12, transformOrigin: 'left' }, bigTitle]}>
            <Text variant="display" accessibilityRole="header">
              {title}
            </Text>
          </Animated.View>
        )}
        <View style={styles.inner}>{children}</View>
      </Animated.ScrollView>

      <View pointerEvents="box-none" style={[styles.bar, { height: headerHeight, paddingTop: insets.top }]}>
        <Animated.View pointerEvents="none" style={[StyleSheet.absoluteFill, barBg]}>
          <Glass style={StyleSheet.absoluteFill} intensity={50} />
          <View style={[styles.hairline, { backgroundColor: t.colors.border }]} />
        </Animated.View>
        <View style={styles.barRow} pointerEvents="box-none">
          <View style={styles.side}>{back && <BackButton glass={!!hero} />}</View>
          <Animated.View style={[styles.barTitle, barTitle]} pointerEvents="none">
            {title && (
              <Text variant="headline" numberOfLines={1}>
                {title}
              </Text>
            )}
          </Animated.View>
          <View style={[styles.side, { alignItems: 'flex-end' }]}>{right}</View>
        </View>
      </View>
    </View>
  );
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------
export function SectionHeader({ title, action, onAction, style, overline }: { title: string; action?: string; onAction?: () => void; style?: StyleProp<ViewStyle>; overline?: string }) {
  const t = useTheme();
  return (
    <View style={[styles.sectionHeader, { paddingHorizontal: t.spacing.gutter }, style]}>
      <View style={{ flex: 1, gap: 2 }}>
        {overline && (
          <Text variant="overline" tone="accent">
            {overline}
          </Text>
        )}
        <Text variant="title3" accessibilityRole="header" numberOfLines={1}>
          {title}
        </Text>
      </View>
      {action && onAction && (
        <PressableScale onPress={onAction} haptic="select" hitSlop={10} style={styles.sectionAction} accessibilityLabel={`${action}: ${title}`}>
          <Text variant="subhead" tone="secondary">
            {action}
          </Text>
          <ChevronRight size={16} color={t.colors.textSecondary} />
        </PressableScale>
      )}
    </View>
  );
}

// ---------------------------------------------------------------------------
// List row (settings, menus)
// ---------------------------------------------------------------------------
export function ListItem({ icon: Icon, title, subtitle, value, onPress, right, destructive, iconColor, chevron = true }: { icon?: LucideIcon; title: string; subtitle?: string; value?: string; onPress?: () => void; right?: ReactNode; destructive?: boolean; iconColor?: string; chevron?: boolean }) {
  const t = useTheme();
  const content = (
    <View style={styles.listItem}>
      {Icon && (
        <View style={[styles.listIcon, { backgroundColor: destructive ? t.colors.dangerSoft : t.colors.surfaceHigh }]}>
          <Icon size={18} color={destructive ? t.colors.danger : iconColor ?? t.colors.text} strokeWidth={1.8} />
        </View>
      )}
      <View style={{ flex: 1, gap: 2 }}>
        <Text variant="bodyStrong" tone={destructive ? 'danger' : 'primary'}>
          {title}
        </Text>
        {subtitle && (
          <Text variant="footnote" tone="secondary">
            {subtitle}
          </Text>
        )}
      </View>
      {value && (
        <Text variant="callout" tone="secondary" numberOfLines={1} style={{ maxWidth: 150 }}>
          {value}
        </Text>
      )}
      {right}
      {onPress && chevron && !right && <ChevronRight size={18} color={t.colors.textTertiary} />}
    </View>
  );
  if (!onPress) return content;
  return (
    <PressableScale onPress={onPress} scaleTo={0.985} haptic="select" accessibilityLabel={value ? `${title}, ${value}` : title}>
      {content}
    </PressableScale>
  );
}

export function ListGroup({ children, title }: { children: ReactNode; title?: string }) {
  const t = useTheme();
  return (
    <View style={{ gap: 8, paddingHorizontal: t.spacing.gutter }}>
      {title && (
        <Text variant="overline" tone="tertiary" style={{ paddingHorizontal: 4 }}>
          {title}
        </Text>
      )}
      <View style={{ backgroundColor: t.colors.surface, borderRadius: t.radii.lg, borderWidth: StyleSheet.hairlineWidth, borderColor: t.colors.border, paddingHorizontal: 14, paddingVertical: 4 }}>
        {children}
      </View>
    </View>
  );
}

// ---------------------------------------------------------------------------
// Segmented control
// ---------------------------------------------------------------------------
export function Segmented<T extends string>({ options, value, onChange }: { options: { value: T; label: string }[]; value: T; onChange: (v: T) => void }) {
  const t = useTheme();
  return (
    <View style={[styles.segmented, { backgroundColor: t.colors.surfaceHigh, borderRadius: t.radii.md }]} accessibilityRole="tablist">
      {options.map((o) => {
        const selected = o.value === value;
        return (
          <PressableScale
            key={o.value}
            onPress={() => onChange(o.value)}
            haptic="select"
            accessibilityRole="tab"
            accessibilityState={{ selected }}
            scaleTo={0.96}
            style={[styles.segment, { borderRadius: t.radii.sm, backgroundColor: selected ? t.colors.surface : 'transparent' }, selected && t.elevation(1)]}>
            <Text variant="subhead" tone={selected ? 'primary' : 'secondary'} numberOfLines={1}>
              {o.label}
            </Text>
          </PressableScale>
        );
      })}
    </View>
  );
}

// ---------------------------------------------------------------------------
// Empty / error states
// ---------------------------------------------------------------------------
export function EmptyState({ icon: Icon, title, body, action, onAction }: { icon: LucideIcon; title: string; body?: string; action?: string; onAction?: () => void }) {
  const t = useTheme();
  return (
    <View style={styles.empty}>
      <View style={[styles.emptyIcon, { backgroundColor: t.colors.accentSoft }]}>
        <Icon size={28} color={t.colors.accent} strokeWidth={1.6} />
      </View>
      <Text variant="title3" align="center">
        {title}
      </Text>
      {body && (
        <Text variant="callout" tone="secondary" align="center" style={{ maxWidth: 320 }}>
          {body}
        </Text>
      )}
      {action && onAction && <Button title={action} onPress={onAction} variant="secondary" style={{ marginTop: 8 }} />}
    </View>
  );
}

export function ErrorState({ message, onRetry }: { message: string; onRetry?: () => void }) {
  const { t } = useI18n();
  const theme = useTheme();
  return (
    <View style={styles.empty} accessibilityLiveRegion="polite">
      <View style={[styles.emptyIcon, { backgroundColor: theme.colors.dangerSoft }]}>
        <Text variant="title2" tone="danger">
          !
        </Text>
      </View>
      <Text variant="callout" tone="secondary" align="center" style={{ maxWidth: 320 }}>
        {message}
      </Text>
      {onRetry && <Button title={t('common.retry')} onPress={onRetry} variant="secondary" size="sm" />}
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  inner: { gap: 28 },
  center: { alignItems: 'center', justifyContent: 'center' },
  bar: { position: 'absolute', top: 0, left: 0, right: 0, zIndex: 10 },
  barRow: { flex: 1, flexDirection: 'row', alignItems: 'center', paddingHorizontal: 12 },
  side: { width: 88, flexDirection: 'row', gap: 8 },
  barTitle: { flex: 1, alignItems: 'center' },
  hairline: { position: 'absolute', left: 0, right: 0, bottom: 0, height: StyleSheet.hairlineWidth },
  sectionHeader: { flexDirection: 'row', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: 12 },
  sectionAction: { flexDirection: 'row', alignItems: 'center', gap: 2, paddingVertical: 4 },
  listItem: { flexDirection: 'row', alignItems: 'center', gap: 14, minHeight: 56, paddingVertical: 10 },
  listIcon: { width: 34, height: 34, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  segmented: { flexDirection: 'row', padding: 4, gap: 4 },
  segment: { flex: 1, height: 38, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 8 },
  empty: { alignItems: 'center', justifyContent: 'center', gap: 12, paddingVertical: 48, paddingHorizontal: 28 },
  emptyIcon: { width: 64, height: 64, borderRadius: 32, alignItems: 'center', justifyContent: 'center', marginBottom: 4 },
});
