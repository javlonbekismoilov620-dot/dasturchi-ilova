import { router } from 'expo-router';
import { Briefcase, GraduationCap, Heart, Rocket, TrendingUp, type LucideIcon } from 'lucide-react-native';
import { View } from 'react-native';

import { OptionCard } from '@/components/onboarding/OptionCard';

import { StepScreen } from '@/components/onboarding/StepScreen';
import type { LearningGoal } from '@/data/types';
import { useI18n } from '@/i18n';
import { usePreferences } from '@/stores/preferences';

const GOALS: { value: LearningGoal; icon: LucideIcon }[] = [
  { value: 'career', icon: Rocket },
  { value: 'switch', icon: TrendingUp },
  { value: 'school', icon: GraduationCap },
  { value: 'business', icon: Briefcase },
  { value: 'hobby', icon: Heart },
];

export default function Goal() {
  const { t } = useI18n();
  const goal = usePreferences((s) => s.goal);
  const set = usePreferences((s) => s.set);
  return (
    <StepScreen step={2} total={3} title={t('onboarding.goalTitle')} body={t('onboarding.goalBody')} cta={t('common.continue')} disabled={!goal} onNext={() => router.push('/onboarding/level')}>
      <View style={{ gap: 10 }}>
        {GOALS.map((g) => (
          <OptionCard key={g.value} icon={g.icon} title={t(`onboarding.goals.${g.value}`)} selected={goal === g.value} onPress={() => set({ goal: g.value })} />
        ))}
      </View>
    </StepScreen>
  );
}
