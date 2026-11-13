import { CircleAlert, CircleCheck, Info } from 'lucide-react-native';
import { useEffect } from 'react';
import { StyleSheet, View } from 'react-native';
import Animated, { FadeInUp, FadeOutUp } from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { create } from 'zustand';

import { haptics } from '@/lib/haptics';
import { useTheme } from '@/theme/ThemeProvider';

import { Text } from './Text';

type ToastKind = 'success' | 'error' | 'info';
interface ToastItem {
  id: number;
  kind: ToastKind;
  message: string;
}

const useToasts = create<{ items: ToastItem[]; show: (kind: ToastKind, message: string) => void; dismiss: (id: number) => void }>((set) => ({
  items: [],
  show: (kind, message) => set((s) => ({ items: [...s.items.slice(-2), { id: Date.now() + Math.random(), kind, message }] })),
  dismiss: (id) => set((s) => ({ items: s.items.filter((i) => i.id !== id) })),
}));

export const toast = {
  success: (m: string) => {
    haptics.success();
    useToasts.getState().show('success', m);
  },
  error: (m: string) => {
    haptics.error();
    useToasts.getState().show('error', m);
  },
  info: (m: string) => useToasts.getState().show('info', m),
};

function ToastView({ item }: { item: ToastItem }) {
  const t = useTheme();
  const dismiss = useToasts((s) => s.dismiss);
  useEffect(() => {
    const id = setTimeout(() => dismiss(item.id), 3600);
    return () => clearTimeout(id);
  }, [item.id, dismiss]);
  const Icon = item.kind === 'success' ? CircleCheck : item.kind === 'error' ? CircleAlert : Info;
  const color = item.kind === 'success' ? t.colors.success : item.kind === 'error' ? t.colors.danger : t.colors.info;
  return (
    <Animated.View
      entering={FadeInUp.springify().damping(18)}
      exiting={FadeOutUp.duration(180)}
      accessibilityLiveRegion="polite"
      accessibilityRole="alert"
      style={[styles.toast, { backgroundColor: t.colors.surfaceHigh, borderColor: t.colors.borderStrong, borderRadius: t.radii.lg }, t.elevation(3)]}>
      <Icon size={18} color={color} />
      <Text variant="subhead" style={{ flex: 1 }}>
        {item.message}
      </Text>
    </Animated.View>
  );
}

export function ToastHost() {
  const items = useToasts((s) => s.items);
  const insets = useSafeAreaInsets();
  return (
    <View pointerEvents="box-none" style={[styles.host, { top: insets.top + 8 }]}>
      {items.map((i) => (
        <ToastView key={i.id} item={i} />
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  host: { position: 'absolute', left: 16, right: 16, gap: 8, zIndex: 1000, alignItems: 'center' },
  toast: { flexDirection: 'row', alignItems: 'center', gap: 10, paddingHorizontal: 16, paddingVertical: 14, borderWidth: StyleSheet.hairlineWidth, width: '100%', maxWidth: 520 },
});
