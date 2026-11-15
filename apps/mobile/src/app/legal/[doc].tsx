import { useLocalSearchParams } from 'expo-router';
import { View } from 'react-native';

import { Markdown } from '@/components/lesson/Markdown';
import { ScrollScreen } from '@/components/ui/layout';
import { legalDocs } from '@/content/legal';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

export default function LegalDoc() {
  const { doc } = useLocalSearchParams<{ doc: 'privacy' | 'terms' }>();
  const t = useTheme();
  const { t: tr } = useI18n();
  const d = legalDocs[doc === 'terms' ? 'terms' : 'privacy'];
  return (
    <ScrollScreen back title={doc === 'terms' ? tr('settings.terms') : tr('settings.privacyPolicy')}>
      <View style={{ paddingHorizontal: t.spacing.gutter }}>
        <Markdown source={d} />
      </View>
    </ScrollScreen>
  );
}
