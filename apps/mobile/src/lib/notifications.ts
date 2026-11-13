import Constants from 'expo-constants';
import * as Device from 'expo-device';
import * as Notifications from 'expo-notifications';
import { router } from 'expo-router';
import { useEffect } from 'react';
import { Platform } from 'react-native';

import { api } from '@/data';
import { useAuth } from '@/data/auth';

import { isDemoMode } from './env';

const REMINDER_ID = 'mahorat-daily-reminder';
const supported = Platform.OS !== 'web';

if (supported) {
  Notifications.setNotificationHandler({
    handleNotification: async () => ({ shouldShowBanner: true, shouldShowList: true, shouldPlaySound: false, shouldSetBadge: false }),
  });
}

async function ensureChannel() {
  if (Platform.OS === 'android') {
    await Notifications.setNotificationChannelAsync('learning', {
      name: 'Learning reminders',
      importance: Notifications.AndroidImportance.DEFAULT,
      vibrationPattern: [0, 120],
      lightColor: '#E8C07A',
    });
  }
}

/** Ask permission only at the moment the learner turns reminders on. */
export async function scheduleDailyReminder(hour: number, minute: number, title: string, body: string): Promise<boolean> {
  if (!supported) return false;
  await ensureChannel();
  let { status } = await Notifications.getPermissionsAsync();
  if (status !== 'granted') status = (await Notifications.requestPermissionsAsync()).status;
  if (status !== 'granted') return false;
  await Notifications.cancelScheduledNotificationAsync(REMINDER_ID).catch(() => {});
  await Notifications.scheduleNotificationAsync({
    identifier: REMINDER_ID,
    content: { title, body, data: { url: '/' } },
    trigger: { type: Notifications.SchedulableTriggerInputTypes.DAILY, hour, minute, channelId: 'learning' },
  });
  return true;
}

export async function cancelDailyReminder() {
  if (!supported) return;
  await Notifications.cancelScheduledNotificationAsync(REMINDER_ID).catch(() => {});
}

/** Registers handlers and (when permitted and configured) the Expo push token. */
export function useNotificationSetup() {
  const userId = useAuth((s) => (s.user && !s.user.isDemo ? s.user.id : null));

  useEffect(() => {
    if (!supported) return;
    const sub = Notifications.addNotificationResponseReceivedListener((response) => {
      const url = response.notification.request.content.data?.url;
      if (typeof url === 'string' && url.startsWith('/')) router.push(url as never);
    });
    return () => sub.remove();
  }, []);

  useEffect(() => {
    const projectId = Constants.expoConfig?.extra?.eas?.projectId as string | undefined;
    if (!supported || !userId || isDemoMode || !projectId || !Device.isDevice) return;
    (async () => {
      const { status } = await Notifications.getPermissionsAsync();
      if (status !== 'granted') return; // never prompt on launch
      await ensureChannel();
      const { data: token } = await Notifications.getExpoPushTokenAsync({ projectId });
      await api.registerPushToken(token, Platform.OS as 'ios' | 'android', Device.deviceName);
    })().catch(() => {});
  }, [userId]);
}
