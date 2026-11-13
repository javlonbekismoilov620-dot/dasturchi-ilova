import { Stack } from 'expo-router';

import { useTheme } from '@/theme/ThemeProvider';

export default function OnboardingLayout() {
  const t = useTheme();
  return <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: t.colors.background }, animation: t.reduceMotion ? 'fade' : 'slide_from_right' }} />;
}
