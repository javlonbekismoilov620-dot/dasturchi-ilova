import { router } from 'expo-router';
import { Compass } from 'lucide-react-native';
import { View } from 'react-native';

import { EmptyState } from '@/components/ui/layout';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

export default function NotFound() {
  const t = useTheme();
  const { t: tr } = useI18n();
  return (
    <View style={{ flex: 1, justifyContent: 'center', backgroundColor: t.colors.background }}>
      <EmptyState icon={Compass} title={tr('errors.notFound')} action={tr('tabs.home')} onAction={() => router.replace('/')} />
    </View>
  );
}
