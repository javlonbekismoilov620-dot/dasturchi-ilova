import Constants from 'expo-constants';
import * as WebBrowser from 'expo-web-browser';
import { router } from 'expo-router';
import {
  Accessibility,
  Bell,
  Clock,
  Crown,
  Download,
  FileText,
  FlaskConical,
  Gauge,
  Globe,
  HardDriveDownload,
  KeyRound,
  LifeBuoy,
  LogOut,
  Moon,
  PlayCircle,
  RotateCcw,
  Shield,
  Target,
  Trash2,
  Vibrate,
} from 'lucide-react-native';
import { useEffect, useState } from 'react';
import { Linking, Switch, View } from 'react-native';

import { OptionList } from '@/components/lesson/VideoPlayer';
import { Button } from '@/components/ui/Button';
import { ListGroup, ListItem, ScrollScreen } from '@/components/ui/layout';
import { Card, Divider } from '@/components/ui/primitives';
import { Sheet } from '@/components/ui/Sheet';
import { Text } from '@/components/ui/Text';
import { TextField } from '@/components/ui/TextField';
import { toast } from '@/components/ui/Toast';
import { api } from '@/data';
import { authActions, useAuth } from '@/data/auth';
import { resetDemoState, setDemoPremium } from '@/data/demo/demoApi';
import { useEntitlements, useSettings } from '@/data/hooks';
import { billingAvailable, openManageSubscriptions, restore, signOutBilling } from '@/lib/billing';
import { clearDownloads, formatBytes, listDownloads } from '@/lib/downloads';
import { env, isDemoMode } from '@/lib/env';
import { cancelDailyReminder, scheduleDailyReminder } from '@/lib/notifications';
import { queryClient } from '@/lib/queryClient';
import { LOCALES, useI18n } from '@/i18n';
import { usePreferences, type ThemeMode } from '@/stores/preferences';
import { useTheme } from '@/theme/ThemeProvider';

type SheetKind = null | 'theme' | 'language' | 'goal' | 'time' | 'speed' | 'delete';

export default function Settings() {
  const t = useTheme();
  const { t: tr, locale } = useI18n();
  const prefs = usePreferences();
  const user = useAuth((s) => s.user);
  const entitlements = useEntitlements();
  const settings = useSettings();
  const [sheet, setSheet] = useState<SheetKind>(null);
  const [storage, setStorage] = useState(0);
  const [confirm, setConfirm] = useState('');
  const [deleting, setDeleting] = useState(false);

  useEffect(() => {
    listDownloads().then((d) => setStorage(d.reduce((n, x) => n + x.sizeBytes, 0))).catch(() => {});
  }, []);

  const themeLabel = { system: tr('settings.themeSystem'), light: tr('settings.themeLight'), dark: tr('settings.themeDark') }[prefs.themeMode];
  const langLabel = prefs.locale ? LOCALES.find((l) => l.code === prefs.locale)?.nativeName : tr('settings.languageSystem');
  const reminderLabel = `${String(prefs.reminderHour).padStart(2, '0')}:${String(prefs.reminderMinute).padStart(2, '0')}`;
  const support = settings.data?.support;

  const syncProfile = (patch: Parameters<typeof api.updateProfile>[0]) => {
    if (user) void api.updateProfile(patch).then(() => queryClient.invalidateQueries({ queryKey: ['me'] })).catch(() => {});
  };

  const setReminders = async (on: boolean) => {
    if (!on) {
      await cancelDailyReminder();
      return prefs.set({ remindersEnabled: false });
    }
    const ok = await scheduleDailyReminder(prefs.reminderHour, prefs.reminderMinute, tr('settings.reminderTitle'), tr('settings.reminderBody'));
    if (!ok) toast.error(tr('settings.remindersDenied'));
    prefs.set({ remindersEnabled: ok });
  };

  const sw = (value: boolean, onChange: (v: boolean) => void, label: string) => (
    <Switch value={value} onValueChange={onChange} trackColor={{ true: t.colors.accent, false: t.colors.surfaceHigh }} thumbColor="#FFFFFF" accessibilityLabel={label} />
  );

  return (
    <ScrollScreen back title={tr('settings.title')}>
      {isDemoMode && (
        <View style={{ paddingHorizontal: t.spacing.gutter }}>
          <Card style={{ gap: 10, backgroundColor: t.colors.warningSoft, borderColor: t.colors.warning }}>
            <View style={{ flexDirection: 'row', gap: 8, alignItems: 'center' }}>
              <FlaskConical size={18} color={t.colors.warning} />
              <Text variant="headline" tone="warning">
                {tr('settings.demoMode')}
              </Text>
            </View>
            <Text variant="footnote" tone="secondary">
              {tr('settings.demoModeBody')}
            </Text>
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
              <Text variant="subhead">Premium (simulated)</Text>
              {sw(!!entitlements.data?.is_premium, async (v) => {
                await setDemoPremium(v);
                await queryClient.invalidateQueries();
              }, 'Simulate premium')}
            </View>
            <Button
              title="Reset demo data"
              variant="outline"
              size="sm"
              icon={RotateCcw}
              onPress={async () => {
                await resetDemoState();
                prefs.reset();
                queryClient.clear();
              }}
            />
          </Card>
        </View>
      )}

      <ListGroup title={tr('settings.appearance')}>
        <ListItem icon={Moon} title={tr('settings.theme')} value={themeLabel} onPress={() => setSheet('theme')} />
        <Divider inset={48} />
        <ListItem icon={Globe} title={tr('settings.language')} value={langLabel} onPress={() => setSheet('language')} />
      </ListGroup>

      <ListGroup title={tr('settings.learning')}>
        <ListItem icon={Target} title={tr('settings.dailyGoal')} value={tr('common.minutesShort', { n: prefs.dailyGoalMinutes })} onPress={() => setSheet('goal')} />
        <Divider inset={48} />
        <ListItem icon={Bell} title={tr('settings.reminders')} right={sw(prefs.remindersEnabled, setReminders, tr('settings.reminders'))} />
        {prefs.remindersEnabled && (
          <>
            <Divider inset={48} />
            <ListItem icon={Clock} title={tr('settings.reminderTime')} value={reminderLabel} onPress={() => setSheet('time')} />
          </>
        )}
        <Divider inset={48} />
        <ListItem icon={PlayCircle} title={tr('settings.autoplay')} right={sw(prefs.autoplayNext, (v) => prefs.set({ autoplayNext: v }), tr('settings.autoplay'))} />
        <Divider inset={48} />
        <ListItem icon={FileText} title={tr('settings.captions')} right={sw(prefs.captionsEnabled, (v) => prefs.set({ captionsEnabled: v }), tr('settings.captions'))} />
        <Divider inset={48} />
        <ListItem icon={Gauge} title={tr('settings.playback')} value={`${prefs.playbackRate}×`} onPress={() => setSheet('speed')} />
      </ListGroup>

      <ListGroup title={tr('settings.downloads')}>
        <ListItem icon={Download} title={tr('settings.wifiOnly')} right={sw(prefs.downloadsWifiOnly, (v) => prefs.set({ downloadsWifiOnly: v }), tr('settings.wifiOnly'))} />
        <Divider inset={48} />
        <ListItem
          icon={HardDriveDownload}
          title={tr('learning.clearDownloads')}
          value={tr('settings.storageUsed', { size: formatBytes(storage) })}
          onPress={async () => {
            await clearDownloads();
            setStorage(0);
          }}
        />
      </ListGroup>

      <ListGroup title={tr('settings.accessibility')}>
        <ListItem icon={Accessibility} title={tr('settings.reduceMotion')} right={sw(prefs.reduceMotion, (v) => prefs.set({ reduceMotion: v }), tr('settings.reduceMotion'))} />
        <Divider inset={48} />
        <ListItem icon={Vibrate} title={tr('settings.haptics')} right={sw(prefs.hapticsEnabled, (v) => prefs.set({ hapticsEnabled: v }), tr('settings.haptics'))} />
      </ListGroup>

      {!isDemoMode && user && (
        <ListGroup title={tr('settings.subscription')}>
          <ListItem icon={Crown} title={entitlements.data?.is_premium ? tr('profile.premiumActive') : tr('profile.goPremium')} onPress={() => router.push('/paywall')} />
          {billingAvailable && (
            <>
              <Divider inset={48} />
              <ListItem icon={Crown} title={tr('settings.manageSubscription')} onPress={openManageSubscriptions} />
              <Divider inset={48} />
              <ListItem
                icon={RotateCcw}
                title={tr('settings.restorePurchases')}
                onPress={async () => {
                  const ok = await restore(user.id).catch(() => false);
                  toast.info(ok ? tr('paywall.restored') : tr('paywall.nothingToRestore'));
                  void queryClient.invalidateQueries({ queryKey: ['me'] });
                }}
              />
            </>
          )}
        </ListGroup>
      )}

      <ListGroup title={tr('settings.privacySecurity')}>
        <ListItem icon={Shield} title={tr('settings.privacyPolicy')} onPress={() => router.push({ pathname: '/legal/[doc]', params: { doc: 'privacy' } })} />
        <Divider inset={48} />
        <ListItem icon={FileText} title={tr('settings.terms')} onPress={() => router.push({ pathname: '/legal/[doc]', params: { doc: 'terms' } })} />
        {!isDemoMode && user?.email && (
          <>
            <Divider inset={48} />
            <ListItem
              icon={KeyRound}
              title={tr('settings.changePassword')}
              onPress={async () => {
                await authActions.sendPasswordReset(user.email!).catch(() => {});
                toast.success(tr('settings.passwordResetSent', { email: user.email! }));
              }}
            />
          </>
        )}
      </ListGroup>

      {user && (
        <ListGroup title={tr('settings.account')}>
          {!isDemoMode && (
            <>
              <ListItem
                icon={LogOut}
                title={tr('common.signOut')}
                subtitle={user.email ? tr('auth.signedInAs', { email: user.email }) : undefined}
                onPress={async () => {
                  await signOutBilling();
                  await authActions.signOut();
                  router.replace('/');
                }}
              />
              <Divider inset={48} />
            </>
          )}
          <ListItem icon={Trash2} title={tr('settings.deleteAccount')} destructive onPress={() => setSheet('delete')} />
        </ListGroup>
      )}
      {!user && !isDemoMode && (
        <View style={{ paddingHorizontal: t.spacing.gutter }}>
          <Button title={tr('common.signIn')} onPress={() => router.push('/auth')} fullWidth />
        </View>
      )}

      <ListGroup title={tr('settings.about')}>
        <ListItem icon={LifeBuoy} title={tr('settings.support')} value={support?.email} onPress={() => support?.email && Linking.openURL(`mailto:${support.email}`)} />
        <Divider inset={48} />
        <ListItem
          icon={FileText}
          title="Mahorat"
          value={tr('settings.version', { version: `${env.appVersion}${Constants.expoConfig?.extra?.appEnv !== 'production' ? ` (${env.appEnv})` : ''}` })}
          chevron={false}
          onPress={() => support?.privacy_url && WebBrowser.openBrowserAsync(support.privacy_url.replace('/privacy', ''))}
        />
      </ListGroup>

      <Sheet visible={sheet === 'theme'} onClose={() => setSheet(null)} title={tr('settings.theme')}>
        <OptionList
          options={(['system', 'light', 'dark'] as ThemeMode[]).map((m) => ({ key: m, label: { system: tr('settings.themeSystem'), light: tr('settings.themeLight'), dark: tr('settings.themeDark') }[m] }))}
          selected={prefs.themeMode}
          onSelect={(k) => {
            prefs.set({ themeMode: k as ThemeMode });
            setSheet(null);
          }}
        />
      </Sheet>
      <Sheet visible={sheet === 'language'} onClose={() => setSheet(null)} title={tr('settings.language')}>
        <OptionList
          options={[
            { key: 'system', label: tr('settings.languageSystem') },
            // Russian is an interface language for now; say so before anyone picks it.
            ...LOCALES.map((l) => ({ key: l.code, label: l.nativeName, description: l.code === 'ru' ? tr('content.interfaceOnly') : undefined })),
          ]}
          selected={prefs.locale ?? 'system'}
          onSelect={(k) => {
            const next = k === 'system' ? null : (k as 'en' | 'uz' | 'ru');
            prefs.set({ locale: next });
            syncProfile({ locale: next ?? locale });
            setSheet(null);
          }}
        />
      </Sheet>
      <Sheet visible={sheet === 'goal'} onClose={() => setSheet(null)} title={tr('settings.dailyGoal')}>
        <OptionList
          options={[5, 10, 15, 30, 45, 60].map((m) => ({ key: String(m), label: tr('onboarding.dailyGoalOption', { n: m }) }))}
          selected={String(prefs.dailyGoalMinutes)}
          onSelect={(k) => {
            prefs.set({ dailyGoalMinutes: Number(k) });
            syncProfile({ daily_goal_minutes: Number(k) });
            setSheet(null);
          }}
        />
      </Sheet>
      <Sheet visible={sheet === 'time'} onClose={() => setSheet(null)} title={tr('settings.reminderTime')}>
        <OptionList
          options={[7, 8, 12, 17, 19, 20, 21].map((h) => ({ key: String(h), label: `${String(h).padStart(2, '0')}:00` }))}
          selected={String(prefs.reminderHour)}
          onSelect={async (k) => {
            prefs.set({ reminderHour: Number(k), reminderMinute: 0 });
            await scheduleDailyReminder(Number(k), 0, tr('settings.reminderTitle'), tr('settings.reminderBody'));
            setSheet(null);
          }}
        />
      </Sheet>
      <Sheet visible={sheet === 'speed'} onClose={() => setSheet(null)} title={tr('settings.playback')}>
        <OptionList
          options={[0.75, 1, 1.25, 1.5, 1.75, 2].map((s) => ({ key: String(s), label: `${s}×` }))}
          selected={String(prefs.playbackRate)}
          onSelect={(k) => {
            prefs.set({ playbackRate: Number(k) });
            setSheet(null);
          }}
        />
      </Sheet>
      <Sheet visible={sheet === 'delete'} onClose={() => setSheet(null)} title={tr('settings.deleteTitle')}>
        <View style={{ paddingHorizontal: 20, gap: 14 }}>
          <Text variant="callout" tone="secondary">
            {tr('settings.deleteBody')}
          </Text>
          <TextField value={confirm} onChangeText={setConfirm} placeholder="DELETE" autoCapitalize="characters" label={tr('settings.deleteTypeToConfirm')} />
          <Button
            title={tr('settings.deleteConfirm')}
            variant="danger"
            disabled={confirm !== 'DELETE'}
            loading={deleting}
            onPress={async () => {
              setDeleting(true);
              try {
                await signOutBilling();
                await authActions.deleteAccount();
                prefs.reset();
                setSheet(null);
                toast.success(tr('settings.deleted'));
                router.replace('/');
              } catch {
                toast.error(tr('errors.generic'));
              } finally {
                setDeleting(false);
              }
            }}
          />
        </View>
      </Sheet>
    </ScrollScreen>
  );
}
