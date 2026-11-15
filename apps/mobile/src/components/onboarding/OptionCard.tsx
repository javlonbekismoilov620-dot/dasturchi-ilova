import type { LucideIcon } from 'lucide-react-native';
import { StyleSheet, View } from 'react-native';

import { PressableScale } from '@/components/ui/PressableScale';
import { Text } from '@/components/ui/Text';
import { useTheme } from '@/theme/ThemeProvider';

export function OptionCard({ icon: Icon, title, subtitle, selected, onPress }: { icon?: LucideIcon; title: string; subtitle?: string; selected: boolean; onPress: () => void }) {
  const t = useTheme();
  return (
    <PressableScale
      onPress={onPress}
      haptic="select"
      accessibilityRole="radio"
      accessibilityState={{ selected }}
      accessibilityLabel={subtitle ? `${title}. ${subtitle}` : title}
      style={[styles.card, { borderRadius: t.radii.lg, backgroundColor: selected ? t.colors.accentSoft : t.colors.surface, borderColor: selected ? t.colors.accent : t.colors.border }]}>
      {Icon && (
        <View style={[styles.icon, { backgroundColor: selected ? t.colors.accent : t.colors.surfaceHigh }]}>
          <Icon size={20} color={selected ? t.colors.onAccent : t.colors.text} strokeWidth={1.9} />
        </View>
      )}
      <View style={{ flex: 1, gap: 2 }}>
        <Text variant="headline">{title}</Text>
        {subtitle && (
          <Text variant="footnote" tone="secondary">
            {subtitle}
          </Text>
        )}
      </View>
      <View style={[styles.radio, { borderColor: selected ? t.colors.accent : t.colors.borderStrong }]}>{selected && <View style={[styles.radioDot, { backgroundColor: t.colors.accent }]} />}</View>
    </PressableScale>
  );
}

const styles = StyleSheet.create({
  card: { flexDirection: 'row', alignItems: 'center', gap: 14, padding: 14, borderWidth: 1.25, minHeight: 68 },
  icon: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  radio: { width: 22, height: 22, borderRadius: 11, borderWidth: 2, alignItems: 'center', justifyContent: 'center' },
  radioDot: { width: 10, height: 10, borderRadius: 5 },
});
