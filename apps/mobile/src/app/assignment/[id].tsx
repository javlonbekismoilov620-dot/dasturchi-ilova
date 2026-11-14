import * as DocumentPicker from 'expo-document-picker';
import { router, useLocalSearchParams } from 'expo-router';
import { Link2, Paperclip, Send, X } from 'lucide-react-native';
import { useState } from 'react';
import { KeyboardAvoidingView, Platform, ScrollView, StyleSheet, View } from 'react-native';
import { useQuery } from '@tanstack/react-query';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Markdown } from '@/components/lesson/Markdown';
import { Button } from '@/components/ui/Button';
import { ErrorState, IconButton } from '@/components/ui/layout';
import { Badge, Card, Skeleton } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { TextField } from '@/components/ui/TextField';
import { toast } from '@/components/ui/Toast';
import { api } from '@/data';
import type { UploadableFile } from '@/data/api';
import { useSubmissions, useSubmitAssignment } from '@/data/hooks';
import { errorMessageKey } from '@/lib/errors';
import { isHttpUrl } from '@/lib/validation';
import { useI18n } from '@/i18n';
import { useContentLocalizer } from '@/i18n/content';
import { useTheme } from '@/theme/ThemeProvider';

function useAssignment(id: string | undefined) {
  const select = useContentLocalizer();
  return useQuery({ queryKey: ['assignment', id], enabled: !!id, queryFn: () => api.getAssignment(id!), select });
}

export default function AssignmentScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const t = useTheme();
  const { t: tr, tp, relativeTime } = useI18n();
  const insets = useSafeAreaInsets();
  const assignment = useAssignment(id);
  const submissions = useSubmissions(id);
  const submit = useSubmitAssignment(id!);
  const [body, setBody] = useState('');
  const [url, setUrl] = useState('');
  const [files, setFiles] = useState<UploadableFile[]>([]);
  const a = assignment.data;

  const pick = async () => {
    const res = await DocumentPicker.getDocumentAsync({ multiple: true, copyToCacheDirectory: true });
    if (res.canceled) return;
    setFiles((f) => [...f, ...res.assets.map((x) => ({ uri: x.uri, name: x.name, mimeType: x.mimeType }))].slice(0, 10));
  };

  const send = async () => {
    if (!body.trim() && !url.trim() && !files.length) return toast.error(tr('assignment.needsContent'));
    if (url.trim() && !isHttpUrl(url)) return toast.error(tr('assignment.invalidUrl'));
    try {
      await submit.mutateAsync({ body: body.trim() || undefined, url: url.trim() || undefined, files });
      setBody('');
      setUrl('');
      setFiles([]);
      toast.success(tr('assignment.submitted'));
    } catch (e) {
      toast.error(tr(errorMessageKey(e)));
    }
  };

  return (
    <KeyboardAvoidingView style={{ flex: 1, backgroundColor: t.colors.background }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <View style={[styles.top, { paddingTop: Platform.OS === 'ios' ? 16 : insets.top + 8 }]}>
        <IconButton icon={X} label={tr('common.close')} onPress={() => router.back()} />
        <Text variant="headline" style={{ flex: 1 }} numberOfLines={1}>
          {tr('assignment.title')}
        </Text>
      </View>
      <ScrollView contentContainerStyle={[styles.content, { paddingBottom: insets.bottom + 40 }]} keyboardShouldPersistTaps="handled">
        {assignment.isLoading && <Skeleton height={160} radius={t.radii.lg} />}
        {!assignment.isLoading && !a && <ErrorState message={tr('errors.notFound')} onRetry={() => assignment.refetch()} />}
        {a && (
          <>
            <View style={{ gap: 8 }}>
              {a.is_project && <Badge label={tr('lesson.projectTitle')} tone="accent" />}
              <Text variant="title1">{a.title}</Text>
            </View>
            {a.brief_md && (
              <Card style={{ gap: 8 }}>
                <Text variant="overline" tone="tertiary">
                  {tr('assignment.brief')}
                </Text>
                <Markdown source={a.brief_md} />
              </Card>
            )}
            {a.rubric_md && (
              <View style={{ gap: 10 }}>
                <Text variant="title3">{tr('assignment.rubric')}</Text>
                <Markdown source={a.rubric_md} />
              </View>
            )}
            <View style={{ gap: 14 }}>
              <TextField label={tr('assignment.text')} placeholder={tr('assignment.textPlaceholder')} value={body} onChangeText={setBody} multiline multilineHeight={160} autoCapitalize="none" autoCorrect={false} style={{ fontFamily: t.fonts.mono, fontSize: 14 }} />
              <TextField label={tr('assignment.url')} placeholder={tr('assignment.urlPlaceholder')} icon={Link2} value={url} onChangeText={setUrl} autoCapitalize="none" keyboardType="url" />
              <Button title={tr('assignment.attach')} icon={Paperclip} variant="secondary" onPress={pick} />
              {files.length > 0 && (
                <View style={{ gap: 6 }}>
                  <Text variant="footnote" tone="secondary">
                    {tp('assignment.attached', files.length)}
                  </Text>
                  {files.map((f, i) => (
                    <View key={`${f.uri}-${i}`} style={[styles.file, { backgroundColor: t.colors.surface, borderRadius: t.radii.sm }]}>
                      <Text variant="footnote" numberOfLines={1} style={{ flex: 1 }}>
                        {f.name}
                      </Text>
                      <IconButton icon={X} size={28} label={tr('common.delete')} onPress={() => setFiles((x) => x.filter((_, k) => k !== i))} />
                    </View>
                  ))}
                </View>
              )}
              <Button title={submissions.data?.length ? tr('assignment.resubmit') : tr('assignment.submit')} icon={Send} size="lg" fullWidth loading={submit.isPending} onPress={send} testID="assignment-submit" />
            </View>
            {!!submissions.data?.length && (
              <View style={{ gap: 12 }}>
                <Text variant="title3">{tr('assignment.history')}</Text>
                {submissions.data.map((s) => (
                  <Card key={s.id} style={{ gap: 8 }}>
                    <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
                      <Badge
                        label={tr(`assignment.status.${s.status}`)}
                        tone={s.status === 'approved' ? 'success' : s.status === 'changes_requested' ? 'warning' : 'info'}
                      />
                      <Text variant="caption" tone="tertiary">
                        {relativeTime(s.submitted_at)}
                      </Text>
                    </View>
                    {s.score != null && <Text variant="headline">{tr('assignment.score', { score: s.score, max: a.max_score })}</Text>}
                    {s.feedback_md && (
                      <View style={{ gap: 4 }}>
                        <Text variant="overline" tone="tertiary">
                          {tr('assignment.feedback')}
                        </Text>
                        <Markdown source={s.feedback_md} />
                      </View>
                    )}
                  </Card>
                ))}
              </View>
            )}
          </>
        )}
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  top: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingBottom: 8 },
  content: { padding: 20, gap: 22, maxWidth: 720, width: '100%', alignSelf: 'center' },
  file: { flexDirection: 'row', alignItems: 'center', gap: 8, paddingLeft: 12, paddingVertical: 4 },
});
