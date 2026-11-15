import * as Print from 'expo-print';
import { useLocalSearchParams } from 'expo-router';
import * as Sharing from 'expo-sharing';
import { FileDown } from 'lucide-react-native';
import { Platform, StyleSheet, View } from 'react-native';

import { LogoMark } from '@/components/brand/Logo';
import { Button } from '@/components/ui/Button';
import { ErrorState, ScrollScreen } from '@/components/ui/layout';
import { Text } from '@/components/ui/Text';
import { toast } from '@/components/ui/Toast';
import { useCertificates } from '@/data/hooks';
import type { Certificate } from '@/data/types';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

const esc = (s: string) => s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]!);

function certificateHtml(c: Certificate, labels: { certifies: string; completed: string; issued: string; verify: string; level: string }) {
  return `<!doctype html><html><head><meta charset="utf-8"><style>
  @page { size: A4 landscape; margin: 0 }
  body { margin:0; font-family: Georgia, 'Times New Roman', serif; background:#0B0C10; }
  .page { width: 297mm; height: 210mm; box-sizing: border-box; padding: 18mm; background: radial-gradient(circle at 70% 10%, #2A2214 0%, #0E0F13 55%, #08090C 100%); color:#F5F2EC; position: relative; }
  .frame { position:absolute; inset: 10mm; border: 1px solid rgba(232,192,122,.55); border-radius: 6mm; }
  .inner { position:absolute; inset: 13mm; border: 1px solid rgba(232,192,122,.18); border-radius: 4mm; }
  .content { position: relative; height: 100%; display:flex; flex-direction:column; align-items:center; justify-content:center; text-align:center; gap: 6mm; }
  .brand { letter-spacing: .4em; font-size: 11pt; color:#E8C07A; text-transform: uppercase; font-family: Helvetica, Arial, sans-serif; }
  .label { font-size: 13pt; color:#ABA79F; font-style: italic; }
  .name { font-size: 40pt; line-height:1.1; }
  .course { font-size: 24pt; color:#E8C07A; }
  .meta { font-family: Helvetica, Arial, sans-serif; font-size: 9.5pt; color:#ABA79F; letter-spacing:.04em; }
  .rule { width: 60mm; height:1px; background: linear-gradient(90deg, transparent, #E8C07A, transparent); }
  </style></head><body><div class="page"><div class="frame"></div><div class="inner"></div><div class="content">
  <div class="brand">Mahorat</div>
  <div class="label">${esc(labels.certifies)}</div>
  <div class="name">${esc(c.recipient_name)}</div>
  <div class="label">${esc(labels.completed)}</div>
  <div class="course">${esc(c.course_title)}</div>
  <div class="rule"></div>
  <div class="meta">${esc(labels.level)} · ${esc(labels.issued)} · ${esc(c.serial)}</div>
  <div class="meta">${esc(labels.verify)}</div>
  </div></div></body></html>`;
}

export default function CertificateScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const t = useTheme();
  const { t: tr, date } = useI18n();
  const certs = useCertificates();
  const c = certs.data?.find((x) => x.id === id);

  const exportPdf = async () => {
    if (!c) return;
    const html = certificateHtml(c, {
      certifies: tr('certificates.certifies'),
      completed: tr('certificates.completed'),
      issued: tr('certificates.issued', { date: date(c.issued_at) }),
      verify: tr('certificates.verify', { code: c.verification_code }),
      level: tr(`levels.${c.course_level}`),
    });
    try {
      if (Platform.OS === 'web') return void (await Print.printAsync({ html }));
      const { uri } = await Print.printToFileAsync({ html, width: 842, height: 595 });
      await Sharing.shareAsync(uri, { mimeType: 'application/pdf', UTI: 'com.adobe.pdf', dialogTitle: c.course_title });
    } catch {
      toast.error(tr('errors.generic'));
    }
  };

  return (
    <ScrollScreen back title={tr('certificates.title')}>
      {!c && !certs.isLoading && <ErrorState message={tr('errors.notFound')} />}
      {c && (
        <View style={{ paddingHorizontal: t.spacing.gutter, gap: 20 }}>
          <View style={[styles.cert, { borderRadius: t.radii.xl }]} accessibilityLabel={`${tr('certificates.certifies')} ${c.recipient_name} ${tr('certificates.completed')} ${c.course_title}`}>
            <View style={[styles.frame, { borderRadius: t.radii.lg }]} />
            <LogoMark size={40} />
            <Text variant="overline" color="#E8C07A" style={{ letterSpacing: 4 }}>
              Mahorat
            </Text>
            <Text variant="footnote" color="#ABA79F" style={{ fontStyle: 'italic' }}>
              {tr('certificates.certifies')}
            </Text>
            <Text variant="display" color="#F5F2EC" align="center">
              {c.recipient_name}
            </Text>
            <Text variant="footnote" color="#ABA79F" style={{ fontStyle: 'italic' }}>
              {tr('certificates.completed')}
            </Text>
            <Text variant="title2" color="#E8C07A" align="center">
              {c.course_title}
            </Text>
            <View style={styles.rule} />
            <Text variant="caption" color="#ABA79F" align="center">
              {tr(`levels.${c.course_level}`)} · {tr('certificates.issued', { date: date(c.issued_at) })}
            </Text>
            <Text variant="caption" color="#7D7A74" align="center">
              {tr('certificates.serial', { serial: c.serial })}
            </Text>
          </View>
          <Text variant="footnote" tone="secondary" align="center" selectable>
            {tr('certificates.verify', { code: c.verification_code })}
          </Text>
          <Button title={tr('certificates.exportPdf')} icon={FileDown} onPress={exportPdf} size="lg" fullWidth />
        </View>
      )}
    </ScrollScreen>
  );
}

const styles = StyleSheet.create({
  cert: { backgroundColor: '#0E0F13', padding: 28, alignItems: 'center', gap: 10, overflow: 'hidden' },
  frame: { position: 'absolute', top: 10, left: 10, right: 10, bottom: 10, borderWidth: 1, borderColor: 'rgba(232,192,122,0.45)' },
  rule: { width: 120, height: 1, backgroundColor: 'rgba(232,192,122,0.6)', marginVertical: 6 },
});
