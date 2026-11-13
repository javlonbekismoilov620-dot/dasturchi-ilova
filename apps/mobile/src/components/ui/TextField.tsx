import { Eye, EyeOff, type LucideIcon } from 'lucide-react-native';
import { useState, type ComponentRef, type Ref } from 'react';
import { Pressable, StyleSheet, TextInput, View, type TextInputProps } from 'react-native';
import Animated, { useAnimatedStyle, withTiming } from 'react-native-reanimated';

import { useTheme } from '@/theme/ThemeProvider';

import { Text } from './Text';

export interface TextFieldProps extends TextInputProps {
  label?: string;
  hint?: string;
  error?: string | null;
  icon?: LucideIcon;
  secureToggle?: boolean;
  multilineHeight?: number;
  ref?: Ref<ComponentRef<typeof TextInput>>;
}

export function TextField({ label, hint, error, icon: Icon, secureToggle, secureTextEntry, multilineHeight, style, onFocus, onBlur, ref, ...rest }: TextFieldProps) {
  const t = useTheme();
  const [focused, setFocused] = useState(false);
  const [hidden, setHidden] = useState(!!secureTextEntry);
  const ring = useAnimatedStyle(() => ({
    borderColor: withTiming(error ? t.colors.danger : focused ? t.colors.accent : t.colors.border, { duration: 160 }),
  }));
  return (
    <View style={{ gap: 6 }}>
      {label && (
        <Text variant="subhead" tone="secondary">
          {label}
        </Text>
      )}
      <Animated.View
        style={[
          styles.box,
          { backgroundColor: t.colors.surface, borderRadius: t.radii.md, minHeight: multilineHeight ?? 52, alignItems: multilineHeight ? 'flex-start' : 'center' },
          ring,
        ]}>
        {Icon && <Icon size={18} color={t.colors.textTertiary} style={{ marginTop: multilineHeight ? 16 : 0 }} />}
        <TextInput
          ref={ref}
          placeholderTextColor={t.colors.textTertiary}
          selectionColor={t.colors.accent}
          secureTextEntry={hidden}
          accessibilityLabel={label}
          {...rest}
          onFocus={(e) => {
            setFocused(true);
            onFocus?.(e);
          }}
          onBlur={(e) => {
            setFocused(false);
            onBlur?.(e);
          }}
          style={[
            t.typography.body,
            { flex: 1, color: t.colors.text, paddingVertical: 14, minHeight: multilineHeight, textAlignVertical: multilineHeight ? 'top' : 'center' },
            style,
          ]}
        />
        {secureToggle && (
          <Pressable onPress={() => setHidden((h) => !h)} hitSlop={12} accessibilityRole="button" accessibilityLabel={hidden ? 'Show password' : 'Hide password'}>
            {hidden ? <Eye size={18} color={t.colors.textTertiary} /> : <EyeOff size={18} color={t.colors.textTertiary} />}
          </Pressable>
        )}
      </Animated.View>
      {(error || hint) && (
        <Text variant="footnote" tone={error ? 'danger' : 'tertiary'} accessibilityLiveRegion={error ? 'polite' : 'none'}>
          {error ?? hint}
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  box: { flexDirection: 'row', gap: 10, paddingHorizontal: 16, borderWidth: 1.25 },
});
