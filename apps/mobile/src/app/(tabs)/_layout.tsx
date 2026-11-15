import { Tabs } from 'expo-router/tabs';

import { TabBar } from '@/components/navigation/TabBar';
import { useTheme } from '@/theme/ThemeProvider';

export default function TabsLayout() {
  const t = useTheme();
  return (
    <Tabs
      tabBar={(props) => <TabBar {...props} />}
      screenOptions={{ headerShown: false, sceneStyle: { backgroundColor: t.colors.background }, animation: t.reduceMotion ? 'none' : 'shift' }}>
      <Tabs.Screen name="index" />
      <Tabs.Screen name="explore" />
      <Tabs.Screen name="learning" />
      <Tabs.Screen name="profile" />
    </Tabs>
  );
}
