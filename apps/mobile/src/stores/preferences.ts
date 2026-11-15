import AsyncStorage from '@react-native-async-storage/async-storage';
import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';

import type { DifficultyLevel, LearningGoal } from '@/data/types';
import type { Locale } from '@/i18n';

export type ThemeMode = 'system' | 'light' | 'dark';

export interface PreferencesState {
  hasHydrated: boolean;
  themeMode: ThemeMode;
  /** null = follow the device language */
  locale: Locale | null;
  onboardingCompleted: boolean;
  interests: string[];
  goal: LearningGoal | null;
  level: DifficultyLevel | null;
  dailyGoalMinutes: number;
  remindersEnabled: boolean;
  reminderHour: number;
  reminderMinute: number;
  playbackRate: number;
  autoplayNext: boolean;
  captionsEnabled: boolean;
  reduceMotion: boolean;
  /** Russian UI: the “lessons are not in Russian yet” notice on Home was acknowledged. */
  ruContentNoticeDismissed: boolean;
  hapticsEnabled: boolean;
  downloadsWifiOnly: boolean;
  set: (patch: Partial<Omit<PreferencesState, 'set' | 'reset' | 'hasHydrated'>>) => void;
  reset: () => void;
}

const defaults = {
  themeMode: 'system' as ThemeMode,
  locale: null,
  onboardingCompleted: false,
  interests: [] as string[],
  goal: null,
  level: null,
  dailyGoalMinutes: 15,
  remindersEnabled: false,
  reminderHour: 19,
  reminderMinute: 0,
  playbackRate: 1,
  autoplayNext: true,
  captionsEnabled: false,
  reduceMotion: false,
  ruContentNoticeDismissed: false,
  hapticsEnabled: true,
  downloadsWifiOnly: true,
};

export const usePreferences = create<PreferencesState>()(
  persist(
    (set) => ({
      ...defaults,
      hasHydrated: false,
      set: (patch) => set(patch),
      reset: () => set({ ...defaults }),
    }),
    {
      name: 'mahorat.preferences.v1',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: ({ set: _s, reset: _r, hasHydrated: _h, ...rest }) => rest,
      onRehydrateStorage: () => () => usePreferences.setState({ hasHydrated: true }),
    },
  ),
);
