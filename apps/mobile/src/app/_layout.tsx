import { PersistQueryClientProvider } from '@tanstack/react-query-persist-client';
import { useFonts } from 'expo-font';
import { DarkTheme, DefaultTheme, Stack, ThemeProvider as NavThemeProvider } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { StatusBar } from 'expo-status-bar';
import * as SystemUI from 'expo-system-ui';
import { useEffect, useMemo } from 'react';
import { StyleSheet, View } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { AnimatedSplash } from '@/components/brand/AnimatedSplash';
import { CelebrationHost } from '@/components/feedback/CelebrationHost';
import { ToastHost } from '@/components/ui/Toast';
import { useAuth } from '@/data/auth';
import { env } from '@/lib/env';
import { useNotificationSetup } from '@/lib/notifications';
import { queryClient, queryPersister } from '@/lib/queryClient';
import { usePreferences } from '@/stores/preferences';
import { fontAssets } from '@/theme/fonts';
import { ThemeProvider, useTheme } from '@/theme/ThemeProvider';

SplashScreen.preventAutoHideAsync().catch(() => {});

export { ErrorBoundary } from '@/components/feedback/ErrorBoundary';

function Navigation() {
  const t = useTheme();
  const onboarded = usePreferences((s) => s.onboardingCompleted);
  useNotificationSetup();

  const navTheme = useMemo(() => {
    const base = t.isDark ? DarkTheme : DefaultTheme;
    return {
      ...base,
      colors: { ...base.colors, background: t.colors.background, card: t.colors.background, text: t.colors.text, border: t.colors.border, primary: t.colors.accent },
    };
  }, [t]);

  useEffect(() => {
    SystemUI.setBackgroundColorAsync(t.colors.background).catch(() => {});
  }, [t.colors.background]);

  return (
    <NavThemeProvider value={navTheme}>
      <StatusBar style={t.isDark ? 'light' : 'dark'} />
      <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: t.colors.background }, animation: t.reduceMotion ? 'fade' : 'default' }}>
        <Stack.Protected guard={!onboarded} redirectTo="/">
          <Stack.Screen name="onboarding" options={{ animation: 'fade' }} />
        </Stack.Protected>
        <Stack.Protected guard={onboarded} redirectTo="/onboarding">
          <Stack.Screen name="(tabs)" options={{ animation: 'fade' }} />
          <Stack.Screen name="course/[slug]" />
          <Stack.Screen name="lesson/[id]" />
          <Stack.Screen name="quiz/[id]" options={{ presentation: 'fullScreenModal', animation: 'slide_from_bottom', gestureEnabled: false }} />
          <Stack.Screen name="assignment/[id]" options={{ presentation: 'modal' }} />
          <Stack.Screen name="category/[slug]" />
          <Stack.Screen name="path/[slug]" />
          <Stack.Screen name="achievements" />
          <Stack.Screen name="certificates/index" />
          <Stack.Screen name="certificates/[id]" />
          <Stack.Screen name="notifications" />
          <Stack.Screen name="settings/index" />
          <Stack.Screen name="settings/profile" options={{ presentation: 'modal' }} />
          <Stack.Screen name="paywall" options={{ presentation: 'modal' }} />
          <Stack.Screen name="assistant" options={{ presentation: 'modal' }} />
        </Stack.Protected>
        <Stack.Screen name="auth/index" options={{ presentation: 'modal' }} />
        <Stack.Screen name="auth/email" options={{ presentation: 'modal' }} />
        <Stack.Screen name="auth-callback" options={{ animation: 'fade' }} />
        <Stack.Screen name="legal/[doc]" options={{ presentation: 'modal' }} />
      </Stack>
    </NavThemeProvider>
  );
}

export default function RootLayout() {
  const [fontsLoaded, fontError] = useFonts(fontAssets);
  const hydrated = usePreferences((s) => s.hasHydrated);
  const authStatus = useAuth((s) => s.status);

  useEffect(() => useAuth.getState().init(), []);

  const fontsReady = fontsLoaded || !!fontError;
  const ready = fontsReady && hydrated && authStatus !== 'loading';

  return (
    <GestureHandlerRootView style={styles.flex}>
      <SafeAreaProvider>
        <PersistQueryClientProvider
          client={queryClient}
          persistOptions={{
            persister: queryPersister,
            maxAge: 1000 * 60 * 60 * 24,
            buster: env.appVersion,
            dehydrateOptions: {
              // Persist catalog and learner state for offline launches; never persist
              // quizzes (fresh attempt state) or lesson media (short-lived signed URLs).
              shouldDehydrateQuery: (q) => q.state.status === 'success' && !['quiz', 'lesson'].includes(String(q.queryKey[0])),
            },
          }}>
          <ThemeProvider>
            <View style={styles.flex}>
              {fontsReady && hydrated && <Navigation />}
              <ToastHost />
              <CelebrationHost />
              {fontsReady && <AnimatedSplash ready={ready} />}
            </View>
          </ThemeProvider>
        </PersistQueryClientProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({ flex: { flex: 1 } });
