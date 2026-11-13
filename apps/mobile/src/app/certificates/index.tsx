import { router } from 'expo-router';
import { Award, ChevronRight } from 'lucide-react-native';
import { View } from 'react-native';

import { EmptyState, ScrollScreen } from '@/components/ui/layout';
import { PressableScale } from '@/components/ui/PressableScale';
import { Card } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { useCertificates } from '@/data/hooks';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

export default function Certificates() {
  const t = useTheme();
  const { t: tr, date } = useI18n();
  const certs = useCertificates();
  return (
    <ScrollScreen back title={tr('certificates.title')}>
      <View style={{ paddingHorizontal: t.spacing.gutter, gap: 12 }}>
        {certs.data?.length === 0 && <EmptyState icon={Award} title={tr('certificates.title')} body={tr('certificates.empty')} action={tr('learning.browse')} onAction={() => router.push('/explore')} />}
        {certs.data?.map((c) => (
          <PressableScale key={c.id} onPress={() => router.push({ pathname: '/certificates/[id]', params: { id: c.id } })}>
            <Card style={{ flexDirection: 'row', alignItems: 'center', gap: 14, borderColor: t.colors.accent }}>
              <Award size={28} color={t.colors.accent} strokeWidth={1.5} />
              <View style={{ flex: 1, gap: 2 }}>
                <Text variant="headline">{c.course_title}</Text>
                <Text variant="caption" tone="tertiary">
                  {tr('certificates.issued', { date: date(c.issued_at) })} · {c.serial}
                </Text>
              </View>
              <ChevronRight size={18} color={t.colors.textTertiary} />
            </Card>
          </PressableScale>
        ))}
      </View>
    </ScrollScreen>
  );
}
