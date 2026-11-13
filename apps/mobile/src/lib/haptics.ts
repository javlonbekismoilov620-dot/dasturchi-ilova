import * as Haptics from 'expo-haptics';
import { Platform } from 'react-native';

import { usePreferences } from '@/stores/preferences';

const enabled = () => Platform.OS !== 'web' && usePreferences.getState().hapticsEnabled;

export const haptics = {
  tap: () => enabled() && Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {}),
  select: () => enabled() && Haptics.selectionAsync().catch(() => {}),
  success: () => enabled() && Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(() => {}),
  warning: () => enabled() && Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning).catch(() => {}),
  error: () => enabled() && Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error).catch(() => {}),
  heavy: () => enabled() && Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium).catch(() => {}),
};
