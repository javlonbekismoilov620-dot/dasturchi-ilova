import type { ReactNode } from 'react';
import { ScrollView, StyleSheet, View } from 'react-native';
import Animated, { FadeInDown } from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Aurora } from '@/components/brand/Aurora';
import { Button } from '@/components/ui/Button';
import { BackButton } from '@/components/ui/layout';
import { Text } from '@/components/ui/Text';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

export function StepScreen({ step, total, title, body, children, cta, onNext, disabled, loading }: { step: number; total: number; title: string; body?: string; children: ReactNode; cta: string; onNext: () => void; disabled?: boolean; loading?: boolean }) {
  const t = useTheme();
  const { t: tr } = useI18n();
  const insets = useSafeAreaInsets();
  return (
    <View style={[styles.flex, { backgroundColor: t.colors.background }]}>
      <Aurora hue={38} intensity={0.45} />
      <View style={[styles.top, { paddingTop: insets.top + 8 }]}>
        <BackButton />
        <View style={styles.dots} accessibilityLabel={tr('onboarding.stepOf', { step, total })}>
          {Array.from({ length: total }, (_, i) => (
            <View key={i} style={[styles.dot, { backgroundColor: i < step ? t.colors.accent : t.colors.borderStrong, width: i === step - 1 ? 22 : 8 }]} />
          ))}
        </View>
        <View style={{ width: 40 }} />
      </View>
      <ScrollView contentContainerStyle={[styles.content, { paddingBottom: 140 + insets.bottom }]} showsVerticalScrollIndicator={false}>
        <Animated.View entering={t.reduceMotion ? undefined : FadeInDown.duration(420)} style={{ gap: 10, marginBottom: 24 }}>
          <Text variant="display" accessibilityRole="header">
            {title}
          </Text>
          {body && (
            <Text variant="callout" tone="secondary">
              {body}
            </Text>
          )}
        </Animated.View>
        {children}
      </ScrollView>
      <View style={[styles.footer, { paddingBottom: insets.bottom + 16, backgroundColor: t.colors.background, borderTopColor: t.colors.border }]}>
        <Button title={cta} onPress={onNext} disabled={disabled} loading={loading} size="lg" fullWidth testID="onboarding-next" />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  top: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: 16 },
  dots: { flexDirection: 'row', gap: 6, alignItems: 'center' },
  dot: { height: 8, borderRadius: 4 },
  content: { paddingHorizontal: 24, paddingTop: 24, maxWidth: 640, width: '100%', alignSelf: 'center' },
  footer: { position: 'absolute', left: 0, right: 0, bottom: 0, paddingHorizontal: 24, paddingTop: 16, borderTopWidth: StyleSheet.hairlineWidth, alignItems: 'center' },
});
