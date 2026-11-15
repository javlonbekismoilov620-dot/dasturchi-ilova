import { useQuery } from '@tanstack/react-query';
import { router } from 'expo-router';
import { Check, Crown, X } from 'lucide-react-native';
import { useState } from 'react';
import { Platform, ScrollView, StyleSheet, View } from 'react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Aurora } from '@/components/brand/Aurora';
import { LogoMark } from '@/components/brand/Logo';
import { Button } from '@/components/ui/Button';
import { IconButton } from '@/components/ui/layout';
import { PressableScale } from '@/components/ui/PressableScale';
import { Badge, Card, Skeleton } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { toast } from '@/components/ui/Toast';
import { api } from '@/data';
import { useAuth } from '@/data/auth';
import { qk, useEntitlements, usePlans, useSettings } from '@/data/hooks';
import { billingAvailable, loadPackages, purchase, restore, type StorePackage } from '@/lib/billing';
import { isDemoMode } from '@/lib/env';
import { queryClient } from '@/lib/queryClient';
import { useI18n, type TKey } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

const FEATURES: TKey[] = ['paywall.features.library', 'paywall.features.paths', 'paywall.features.projects', 'paywall.features.certificates', 'paywall.features.resources'];

/** Entitlements are granted by the server after the store notifies RevenueCat → webhook. */
async function waitForPremium(userId: string, attempts = 10) {
  for (let i = 0; i < attempts; i++) {
    const e = await api.getEntitlements().catch(() => null);
    if (e?.is_premium) {
      queryClient.setQueryData(qk.entitlements(userId), e);
      return true;
    }
    await new Promise((r) => setTimeout(r, 1500));
  }
  return false;
}

export default function Paywall() {
  const t = useTheme();
  const { t: tr } = useI18n();
  const insets = useSafeAreaInsets();
  const user = useAuth((s) => s.user);
  const plans = usePlans();
  const settings = useSettings();
  const entitlements = useEntitlements();
  const [selected, setSelected] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const packages = useQuery({ queryKey: ['store-packages', user?.id], queryFn: () => loadPackages(user!.id), enabled: billingAvailable && !!user });

  const freeForAll = settings.data?.billing?.mode === 'free_for_all';
  const premium = entitlements.data?.is_premium;
  const pkgFor = (packageId: string | null): StorePackage | undefined => packages.data?.find((p) => p.identifier === packageId);
  const chosen = plans.data?.find((p) => p.slug === (selected ?? plans.data?.find((x) => x.is_highlighted)?.slug ?? plans.data?.[0]?.slug));
  const chosenPkg = chosen ? pkgFor(chosen.revenuecat_package_id) : undefined;
  const store = Platform.OS === 'ios' ? tr('paywall.appStore') : tr('paywall.playStore');

  const buy = async () => {
    if (!user) return router.push('/auth');
    if (!chosenPkg) return;
    setBusy(true);
    try {
      const done = await purchase(chosenPkg);
      if (done && (await waitForPremium(user.id))) {
        toast.success(tr('paywall.success'));
        router.back();
      }
    } catch {
      toast.error(tr('errors.generic'));
    } finally {
      setBusy(false);
    }
  };

  const doRestore = async () => {
    if (!user) return router.push('/auth');
    setBusy(true);
    try {
      const ok = await restore(user.id);
      if (ok && (await waitForPremium(user.id, 4))) toast.success(tr('paywall.restored'));
      else toast.info(tr('paywall.nothingToRestore'));
    } finally {
      setBusy(false);
    }
  };

  return (
    <View style={[styles.flex, { backgroundColor: t.colors.background }]}>
      <Aurora hue={38} intensity={1} />
      <ScrollView contentContainerStyle={[styles.content, { paddingTop: Platform.OS === 'ios' ? 20 : insets.top + 12, paddingBottom: insets.bottom + 40 }]}>
        <IconButton icon={X} label={tr('common.close')} onPress={() => router.back()} style={{ alignSelf: 'flex-end' }} />
        <Animated.View entering={t.reduceMotion ? undefined : FadeInDown.duration(500)} style={styles.head}>
          <View style={[styles.crown, { borderColor: t.colors.accent }]}>
            <LogoMark size={54} />
          </View>
          <Text variant="hero" align="center" accessibilityRole="header">
            {tr('paywall.title')}
          </Text>
          <Text variant="callout" tone="secondary" align="center">
            {tr('paywall.subtitle')}
          </Text>
        </Animated.View>

        <Card style={{ gap: 14 }}>
          {FEATURES.map((f) => (
            <View key={f} style={styles.feature}>
              <View style={[styles.check, { backgroundColor: t.colors.accent }]}>
                <Check size={13} color={t.colors.onAccent} strokeWidth={3} />
              </View>
              <Text variant="bodyStrong" style={{ flex: 1 }}>
                {tr(f)}
              </Text>
            </View>
          ))}
        </Card>

        {freeForAll ? (
          <Card style={{ backgroundColor: t.colors.successSoft, borderColor: 'transparent' }}>
            <Text variant="headline" tone="success" align="center">
              {tr('paywall.freeForAll')}
            </Text>
          </Card>
        ) : premium ? (
          <Card style={{ backgroundColor: t.colors.accentSoft, borderColor: t.colors.accent, flexDirection: 'row', gap: 10, alignItems: 'center' }}>
            <Crown size={20} color={t.colors.accent} />
            <Text variant="headline" tone="accent">
              {tr('paywall.alreadyPremium')}
            </Text>
          </Card>
        ) : (
          <>
            <View style={{ gap: 10 }}>
              {plans.isLoading && [0, 1].map((i) => <Skeleton key={i} height={84} radius={t.radii.lg} />)}
              {plans.data?.map((p) => {
                const isSel = chosen?.id === p.id;
                const pkg = pkgFor(p.revenuecat_package_id);
                const price = pkg?.priceString;
                const priceLabel = price ? (p.interval === 'month' ? tr('paywall.perMonth', { price }) : p.interval === 'year' ? tr('paywall.perYear', { price }) : tr('paywall.lifetime', { price })) : null;
                return (
                  <PressableScale
                    key={p.id}
                    onPress={() => setSelected(p.slug)}
                    haptic="select"
                    accessibilityRole="radio"
                    accessibilityState={{ selected: isSel }}
                    style={[styles.plan, { borderRadius: t.radii.lg, borderColor: isSel ? t.colors.accent : t.colors.border, backgroundColor: isSel ? t.colors.accentSoft : t.colors.surface }]}>
                    <View style={{ flex: 1, gap: 4 }}>
                      <View style={{ flexDirection: 'row', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
                        <Text variant="headline">{p.title}</Text>
                        {p.is_highlighted && <Badge label={tr('paywall.bestValue')} tone="accent" />}
                      </View>
                      {p.trial_days > 0 && (
                        <Text variant="footnote" tone="success">
                          {tr('paywall.trial', { n: p.trial_days })}
                        </Text>
                      )}
                      {p.description && (
                        <Text variant="footnote" tone="secondary">
                          {p.description}
                        </Text>
                      )}
                    </View>
                    <Text variant="headline" tone={priceLabel ? 'primary' : 'tertiary'}>
                      {priceLabel ?? '—'}
                    </Text>
                  </PressableScale>
                );
              })}
            </View>

            {!billingAvailable || isDemoMode ? (
              <Card style={{ backgroundColor: t.colors.surfaceHigh, borderColor: 'transparent' }}>
                <Text variant="footnote" tone="secondary" align="center">
                  {tr('paywall.unavailable')}
                </Text>
              </Card>
            ) : !user ? (
              <Button title={tr('common.signIn')} onPress={() => router.push('/auth')} size="lg" fullWidth />
            ) : (
              <>
                {packages.isLoading && (
                  <Text variant="footnote" tone="tertiary" align="center">
                    {tr('paywall.loadingPrices')}
                  </Text>
                )}
                <Button title={tr('paywall.subscribe')} icon={Crown} onPress={buy} loading={busy} disabled={!chosenPkg} size="lg" fullWidth />
                <Button title={tr('paywall.restore')} variant="ghost" onPress={doRestore} disabled={busy} />
              </>
            )}
            <Text variant="caption" tone="tertiary" align="center">
              {tr('paywall.legal', { store })}
            </Text>
          </>
        )}
        <View style={styles.links}>
          <Text variant="caption" tone="accent" onPress={() => router.push({ pathname: '/legal/[doc]', params: { doc: 'terms' } })}>
            {tr('settings.terms')}
          </Text>
          <Text variant="caption" tone="tertiary">
            ·
          </Text>
          <Text variant="caption" tone="accent" onPress={() => router.push({ pathname: '/legal/[doc]', params: { doc: 'privacy' } })}>
            {tr('settings.privacyPolicy')}
          </Text>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  content: { paddingHorizontal: 20, gap: 20, maxWidth: 560, width: '100%', alignSelf: 'center' },
  head: { alignItems: 'center', gap: 12 },
  crown: { width: 92, height: 92, borderRadius: 46, borderWidth: 1.5, alignItems: 'center', justifyContent: 'center', marginBottom: 4 },
  feature: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  check: { width: 22, height: 22, borderRadius: 11, alignItems: 'center', justifyContent: 'center' },
  plan: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 16, borderWidth: 1.5, minHeight: 84 },
  links: { flexDirection: 'row', gap: 8, justifyContent: 'center' },
});
