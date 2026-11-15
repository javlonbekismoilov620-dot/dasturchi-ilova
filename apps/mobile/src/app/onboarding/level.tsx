import { useState } from 'react';
import { View } from 'react-native';

import { StepScreen } from '@/components/onboarding/StepScreen';
import { Segmented } from '@/components/ui/layout';
import { Text } from '@/components/ui/Text';
import { api } from '@/data';
import { useAuth } from '@/data/auth';
import type { DifficultyLevel } from '@/data/types';
import { useI18n } from '@/i18n';
import { queryClient } from '@/lib/queryClient';
import { usePreferences } from '@/stores/preferences';

import { OptionCard } from '@/components/onboarding/OptionCard';

const LEVELS: DifficultyLevel[] = ['zero', 'beginner', 'intermediate', 'advanced', 'professional'];
const GOAL_MINUTES = ['5', '15', '30', '60'] as const;

export default function Level() {
  const { t, locale } = useI18n();
  const prefs = usePreferences();
  const user = useAuth((s) => s.user);
  const [saving, setSaving] = useState(false);

  const finish = async () => {
    setSaving(true);
    try {
      if (user) {
        // Sync onboarding answers to the learner profile (drives server-side recommendations).
        await api
          .updateProfile({
            interests: prefs.interests,
            learning_goal: prefs.goal,
            experience_level: prefs.level ?? 'zero',
            daily_goal_minutes: prefs.dailyGoalMinutes,
            locale,
            timezone: Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC',
            onboarding_completed_at: new Date().toISOString(),
          })
          .catch(() => {});
        queryClient.invalidateQueries();
      }
    } finally {
      setSaving(false);
      // Protected routes switch to the tab navigator once this flag flips.
      prefs.set({ onboardingCompleted: true });
    }
  };

  return (
    <StepScreen step={3} total={3} title={t('onboarding.levelTitle')} body={t('onboarding.levelBody')} cta={t('onboarding.finish')} disabled={!prefs.level} loading={saving} onNext={finish}>
      <View style={{ gap: 10 }}>
        {LEVELS.map((l) => (
          <OptionCard key={l} title={t(`levels.${l}`)} subtitle={t(`levels.${l}Hint`)} selected={prefs.level === l} onPress={() => prefs.set({ level: l })} />
        ))}
      </View>
      <View style={{ gap: 12, marginTop: 32 }}>
        <Text variant="title3">{t('onboarding.dailyGoalTitle')}</Text>
        <Text variant="footnote" tone="secondary">
          {t('onboarding.dailyGoalBody')}
        </Text>
        <Segmented
          value={String(prefs.dailyGoalMinutes) as (typeof GOAL_MINUTES)[number]}
          onChange={(v) => prefs.set({ dailyGoalMinutes: Number(v) })}
          options={GOAL_MINUTES.map((m) => ({ value: m, label: t('common.minutesShort', { n: m }) }))}
        />
      </View>
    </StepScreen>
  );
}
