import NetInfo from '@react-native-community/netinfo';
import { router } from 'expo-router';
import { FlaskConical, Languages, WifiOff } from 'lucide-react-native';
import { useEffect, useState } from 'react';
import { StyleSheet, View } from 'react-native';
import Animated, { FadeInUp, FadeOutUp } from 'react-native-reanimated';

import { PressableScale } from '@/components/ui/PressableScale';
import { Card } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { isDemoMode } from '@/lib/env';
import { Button } from '@/components/ui/Button';
import { useI18n } from '@/i18n';
import { usePreferences } from '@/stores/preferences';
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

/**
 * Shown when course content has no translation for the learner's language yet, so the
 * original text is displayed instead of silently mixing languages.
 */
export function UntranslatedNotice({ baseLanguage }: { baseLanguage?: string | null }) {
  const t = useTheme();
  const { t: tr } = useI18n();
  const lang = baseLanguage === 'uz' || baseLanguage === 'ru' ? baseLanguage : 'en';
  return (
    <View testID="untranslated-notice">
    <Card style={{ flexDirection: 'row', gap: 12, backgroundColor: t.colors.surface, borderColor: t.colors.border }}>
      <Languages size={18} color={t.colors.textSecondary} style={{ marginTop: 2 }} />
      <View style={{ flex: 1, gap: 4 }}>
        <Text variant="headline">{tr('content.untranslatedTitle')}</Text>
        <Text variant="footnote" tone="secondary">
          {tr('content.untranslatedBody', { language: tr(`content.inLanguage.${lang}`) })}
        </Text>
      </View>
    </Card>
    </View>
  );
}

/**
 * Russian is an interface language for now. Russian-speaking learners are told plainly,
 * once on Home, that lesson content is in English and Uzbek — English lessons are never
 * presented as Russian translations.
 */
export function RussianContentNotice() {
  const t = useTheme();
  const { t: tr, locale } = useI18n();
  const dismissed = usePreferences((s) => s.ruContentNoticeDismissed);
  const set = usePreferences((s) => s.set);
  if (locale !== 'ru' || dismissed) return null;
  return (
    <View style={{ marginHorizontal: t.spacing.gutter }} testID="ru-content-notice">
      <Card style={{ gap: 10, backgroundColor: t.colors.surface, borderColor: t.colors.border }}>
        <View style={{ flexDirection: 'row', gap: 10, alignItems: 'center' }}>
          <Languages size={18} color={t.colors.accent} />
          <Text variant="headline" style={{ flex: 1 }}>
            {tr('content.ruNoticeTitle')}
          </Text>
        </View>
        <Text variant="footnote" tone="secondary">
          {tr('content.ruNoticeBody')}
        </Text>
        <View style={{ alignSelf: 'flex-start' }}>
          <Button title={tr('content.gotIt')} size="sm" variant="secondary" onPress={() => set({ ruContentNoticeDismissed: true })} testID="ru-content-notice-dismiss" />
        </View>
      </Card>
    </View>
  );
}
