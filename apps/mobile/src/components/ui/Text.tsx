import { Text as RNText, type TextProps as RNTextProps } from 'react-native';

import { useTheme } from '@/theme/ThemeProvider';
import type { ThemeColors, TypographyVariant } from '@/theme/tokens';

export type TextTone = 'primary' | 'secondary' | 'tertiary' | 'accent' | 'success' | 'warning' | 'danger' | 'inverse' | 'onAccent';

const toneKey: Record<TextTone, keyof ThemeColors> = {
  primary: 'text',
  secondary: 'textSecondary',
  tertiary: 'textTertiary',
  accent: 'accent',
  success: 'success',
  warning: 'warning',
  danger: 'danger',
  inverse: 'textInverse',
  onAccent: 'onAccent',
};

export interface TextProps extends RNTextProps {
  variant?: TypographyVariant;
  tone?: TextTone;
  color?: string;
  align?: 'left' | 'center' | 'right';
}

export function Text({ variant = 'body', tone = 'primary', color, align, style, ...rest }: TextProps) {
  const t = useTheme();
  return (
    <RNText
      maxFontSizeMultiplier={1.6}
      {...rest}
      style={[t.typography[variant], { color: color ?? t.colors[toneKey[tone]], textAlign: align }, style]}
    />
  );
}
