import { router } from 'expo-router';
import { StyleSheet, View } from 'react-native';

import { StepScreen } from '@/components/onboarding/StepScreen';
import { iconFor } from '@/components/ui/Icon';
import { ErrorState } from '@/components/ui/layout';
import { Chip, Skeleton } from '@/components/ui/primitives';
import { useCategories } from '@/data/hooks';
import { useI18n } from '@/i18n';
import { usePreferences } from '@/stores/preferences';

export default function Interests() {
  const { t } = useI18n();
  const { data, isLoading, error, refetch } = useCategories();
  const interests = usePreferences((s) => s.interests);
  const set = usePreferences((s) => s.set);

  const toggle = (slug: string) => set({ interests: interests.includes(slug) ? interests.filter((x) => x !== slug) : [...interests, slug] });

  return (
    <StepScreen step={1} total={3} title={t('onboarding.interestsTitle')} body={t('onboarding.interestsBody')} cta={t('common.continue')} disabled={!interests.length} onNext={() => router.push('/onboarding/goal')}>
      {isLoading ? (
        <View style={styles.wrap}>
          {Array.from({ length: 7 }, (_, i) => (
            <Skeleton key={i} width={120 + (i % 3) * 30} height={44} radius={22} />
          ))}
        </View>
      ) : error ? (
        <ErrorState message={t('errors.network')} onRetry={() => refetch()} />
      ) : (
        <View style={{ gap: 28 }}>
          <View style={styles.wrap}>
            {data?.map((c) => (
              <Chip key={c.id} label={c.title} icon={iconFor(c.icon)} color={c.color ?? undefined} selected={interests.includes(c.slug)} onPress={() => toggle(c.slug)} />
            ))}
          </View>
        </View>
      )}
    </StepScreen>
  );
}

const styles = StyleSheet.create({ wrap: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 } });
