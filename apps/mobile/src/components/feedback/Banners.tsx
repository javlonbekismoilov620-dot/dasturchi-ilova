import NetInfo from '@react-native-community/netinfo';
import { router } from 'expo-router';
import { FlaskConical, WifiOff } from 'lucide-react-native';
import { useEffect, useState } from 'react';
import { StyleSheet, View } from 'react-native';
import Animated, { FadeInUp, FadeOutUp } from 'react-native-reanimated';

import { PressableScale } from '@/components/ui/PressableScale';
import { Text } from '@/components/ui/Text';
import { isDemoMode } from '@/lib/env';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

/** Persistent, honest label shown whenever the app runs on bundled demo content. */
export function DemoBadge() {
  const t = useTheme();
  const { t: tr } = useI18n();
  if (!isDemoMode) return null;
  return (
    <PressableScale onPress={() => router.push('/settings')} haptic="select" accessibilityLabel={`${tr('demo.badge')}. ${tr('demo.banner')}`} style={[styles.demo, { backgroundColor: t.colors.warningSoft, borderColor: t.colors.warning }]}>
      <FlaskConical size={12} color={t.colors.warning} />
      <Text variant="caption" tone="warning">
        {tr('demo.badge')}
      </Text>
    </PressableScale>
  );
}

export function DemoNotice() {
  const t = useTheme();
  const { t: tr } = useI18n();
  if (!isDemoMode) return null;
  return (
    <View style={[styles.notice, { backgroundColor: t.colors.warningSoft, borderRadius: t.radii.md, marginHorizontal: t.spacing.gutter }]}>
      <FlaskConical size={16} color={t.colors.warning} />
      <Text variant="footnote" tone="warning" style={{ flex: 1 }}>
        {tr('demo.banner')}
      </Text>
    </View>
  );
}

export function useIsOffline() {
  const [offline, setOffline] = useState(false);
  useEffect(() => NetInfo.addEventListener((s) => setOffline(s.isConnected === false || s.isInternetReachable === false)), []);
  return offline;
}

export function OfflineBanner() {
  const t = useTheme();
  const { t: tr } = useI18n();
  const offline = useIsOffline();
  if (!offline) return null;
  return (
    <Animated.View entering={FadeInUp} exiting={FadeOutUp} style={[styles.notice, { backgroundColor: t.colors.surfaceHigh, borderRadius: t.radii.md, marginHorizontal: t.spacing.gutter }]} accessibilityLiveRegion="polite">
      <WifiOff size={16} color={t.colors.textSecondary} />
      <Text variant="footnote" tone="secondary" style={{ flex: 1 }}>
        {tr('common.offline')}
      </Text>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  demo: { flexDirection: 'row', alignItems: 'center', gap: 4, paddingHorizontal: 8, height: 24, borderRadius: 12, borderWidth: StyleSheet.hairlineWidth },
  notice: { flexDirection: 'row', alignItems: 'center', gap: 10, paddingHorizontal: 14, paddingVertical: 10 },
});
