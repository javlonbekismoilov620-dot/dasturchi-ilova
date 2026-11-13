import { router } from 'expo-router';
import { useState } from 'react';
import { ActivityIndicator, StyleSheet, View } from 'react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { AppleButton, EmailButton, GoogleButton } from '@/components/auth/ProviderButtons';
import { Aurora } from '@/components/brand/Aurora';
import { LogoMark } from '@/components/brand/Logo';
import { Button } from '@/components/ui/Button';
import { BackButton } from '@/components/ui/layout';
import { Text } from '@/components/ui/Text';
import { toast } from '@/components/ui/Toast';
import { authActions, authErrorKey, useAuth } from '@/data/auth';
import { errorCode } from '@/lib/errors';
import { isDemoMode } from '@/lib/env';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

export default function AuthScreen() {
  const t = useTheme();
  const { t: tr } = useI18n();
  const insets = useSafeAreaInsets();
  const status = useAuth((s) => s.status);
  const [busy, setBusy] = useState(false);

  const run = async (fn: () => Promise<void>) => {
    setBusy(true);
    try {
      await fn();
      if (useAuth.getState().status === 'signedIn' || (await new Promise((r) => setTimeout(() => r(useAuth.getState().status === 'signedIn'), 600)))) {
        router.dismissAll();
      }
    } catch (e) {
      const code = errorCode(e) === 'generic' ? (e as { code?: string }).code ?? 'auth_generic' : errorCode(e);
      if (code !== 'cancelled') toast.error(tr(authErrorKey(code)));
    } finally {
      setBusy(false);
    }
  };

  return (
    <View style={[styles.flex, { backgroundColor: t.colors.background }]}>
      <Aurora hue={38} intensity={0.7} />
      <View style={{ paddingTop: insets.top + 8, paddingHorizontal: 12 }}>
        <BackButton />
      </View>
      <View style={[styles.body, { paddingBottom: insets.bottom + 24 }]}>
        <Animated.View entering={t.reduceMotion ? undefined : FadeInDown.duration(500)} style={styles.head}>
          <LogoMark size={64} animate />
          <Text variant="display" align="center" accessibilityRole="header">
            {tr('auth.title')}
          </Text>
          <Text variant="callout" tone="secondary" align="center" style={{ maxWidth: 360 }}>
            {isDemoMode ? tr('demo.accountsDisabled') : tr('auth.subtitle')}
          </Text>
        </Animated.View>

        {isDemoMode ? (
          <Button title={tr('demo.continueDemo')} size="lg" fullWidth onPress={() => router.back()} />
        ) : status === 'signedIn' ? (
          <Button title={tr('common.continue')} size="lg" fullWidth onPress={() => router.dismissAll()} />
        ) : (
          <View style={{ gap: 12, width: '100%' }}>
            <AppleButton label={tr('auth.continueApple')} onPress={() => run(authActions.signInWithApple)} />
            <GoogleButton label={tr('auth.continueGoogle')} onPress={() => run(authActions.signInWithGoogle)} />
            <EmailButton label={tr('auth.continueEmail')} onPress={() => router.push('/auth/email')} />
            {busy && <ActivityIndicator color={t.colors.accent} style={{ marginTop: 8 }} />}
            <Button title={tr('auth.continueGuest')} variant="ghost" onPress={() => router.back()} />
          </View>
        )}

        <Text variant="caption" tone="tertiary" align="center" style={{ maxWidth: 340 }}>
          {tr('auth.legal')}{' '}
          <Text variant="caption" tone="accent" onPress={() => router.push({ pathname: '/legal/[doc]', params: { doc: 'terms' } })}>
            {tr('auth.terms')}
          </Text>
          {' · '}
          <Text variant="caption" tone="accent" onPress={() => router.push({ pathname: '/legal/[doc]', params: { doc: 'privacy' } })}>
            {tr('auth.privacy')}
          </Text>
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  body: { flex: 1, justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 24, paddingTop: 16, maxWidth: 520, width: '100%', alignSelf: 'center' },
  head: { alignItems: 'center', gap: 14, marginTop: 24 },
});
