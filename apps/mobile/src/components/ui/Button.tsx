import { LinearGradient } from 'expo-linear-gradient';
import type { LucideIcon } from 'lucide-react-native';
import { ActivityIndicator, StyleSheet, View, type StyleProp, type ViewStyle } from 'react-native';

import { useTheme } from '@/theme/ThemeProvider';

import { PressableScale } from './PressableScale';
import { Text } from './Text';

type Variant = 'primary' | 'secondary' | 'ghost' | 'outline' | 'danger';
type Size = 'sm' | 'md' | 'lg';

export interface ButtonProps {
  title: string;
  onPress?: () => void;
  variant?: Variant;
  size?: Size;
  icon?: LucideIcon;
  iconRight?: LucideIcon;
  loading?: boolean;
  disabled?: boolean;
  fullWidth?: boolean;
  style?: StyleProp<ViewStyle>;
  accessibilityHint?: string;
  testID?: string;
}

const heights: Record<Size, number> = { sm: 36, md: 48, lg: 56 };

export function Button({ title, onPress, variant = 'primary', size = 'md', icon: Icon, iconRight: IconRight, loading, disabled, fullWidth, style, accessibilityHint, testID }: ButtonProps) {
  const t = useTheme();
  const c = t.colors;
  const fg = { primary: c.onAccent, secondary: c.text, ghost: c.text, outline: c.text, danger: '#FFFFFF' }[variant];
  const bg = { primary: 'transparent', secondary: c.surfaceHigh, ghost: 'transparent', outline: 'transparent', danger: c.danger }[variant];
  const iconSize = size === 'sm' ? 16 : 18;

  return (
    <PressableScale
      testID={testID}
      onPress={onPress}
      disabled={disabled || loading}
      accessibilityLabel={title}
      accessibilityHint={accessibilityHint}
      accessibilityState={{ disabled: !!(disabled || loading), busy: !!loading }}
      haptic={variant === 'primary' ? 'tap' : 'select'}
      style={[
        styles.base,
        {
          height: heights[size],
          paddingHorizontal: size === 'sm' ? 14 : size === 'md' ? 20 : 24,
          borderRadius: size === 'sm' ? t.radii.sm : t.radii.md,
          backgroundColor: bg,
          borderWidth: variant === 'outline' ? 1 : 0,
          borderColor: c.borderStrong,
          alignSelf: fullWidth ? 'stretch' : 'auto',
        },
        style,
      ]}>
      {variant === 'primary' && (
        <LinearGradient
          colors={t.isDark ? ['#F6DDAA', '#E8C07A', '#D4A35A'] : ['#B07D33', '#9A6A22', '#86591A']}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={[StyleSheet.absoluteFill, { borderRadius: size === 'sm' ? t.radii.sm : t.radii.md }]}
        />
      )}
      <View style={styles.row}>
        {loading ? (
          <ActivityIndicator color={fg} size="small" />
        ) : (
          <>
            {Icon && <Icon size={iconSize} color={fg} strokeWidth={2} />}
            <Text variant={size === 'sm' ? 'subhead' : 'headline'} color={fg} numberOfLines={1}>
              {title}
            </Text>
            {IconRight && <IconRight size={iconSize} color={fg} strokeWidth={2} />}
          </>
        )}
      </View>
    </PressableScale>
  );
}

const styles = StyleSheet.create({
  base: { alignItems: 'center', justifyContent: 'center', overflow: 'hidden' },
  row: { flexDirection: 'row', alignItems: 'center', gap: 8 },
});
