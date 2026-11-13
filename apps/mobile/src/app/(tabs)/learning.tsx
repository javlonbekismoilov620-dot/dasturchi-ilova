import { router, useFocusEffect } from 'expo-router';
import * as Sharing from 'expo-sharing';
import { Award, Bookmark, Download, FileText, GraduationCap, Trash2 } from 'lucide-react-native';
import { useCallback, useState } from 'react';
import { Platform, StyleSheet, View } from 'react-native';

import { CourseCover } from '@/components/brand/CourseCover';
import { CourseRow } from '@/components/course/CourseCards';
import { TAB_BAR_HEIGHT } from '@/components/navigation/TabBar';
import { EmptyState, IconButton, ScrollScreen, Segmented } from '@/components/ui/layout';
import { PressableScale } from '@/components/ui/PressableScale';
import { Card, Skeleton } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { useAuth } from '@/data/auth';
import { useBookmarks, useCertificates, useEnrollments, useToggleBookmark } from '@/data/hooks';
import { clearDownloads, formatBytes, listDownloads, removeDownload, type DownloadedResource } from '@/lib/downloads';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

type Tab = 'progress' | 'completed' | 'saved' | 'downloads';

export default function Learning() {
  const t = useTheme();
  const { t: tr, relativeTime } = useI18n();
  const user = useAuth((s) => s.user);
  const [tab, setTab] = useState<Tab>('progress');
  const enrollments = useEnrollments();
  const bookmarks = useBookmarks();
  const certificates = useCertificates();
  const toggle = useToggleBookmark();
  const [downloads, setDownloads] = useState<DownloadedResource[]>([]);

  useFocusEffect(
    useCallback(() => {
      listDownloads().then(setDownloads).catch(() => setDownloads([]));
    }, []),
  );

  const active = enrollments.data?.filter((e) => e.status === 'active') ?? [];
  const done = enrollments.data?.filter((e) => e.status === 'completed') ?? [];

  if (!user) {
    return (
      <ScrollScreen title={tr('learning.title')} bottomInset={TAB_BAR_HEIGHT}>
        <EmptyState icon={GraduationCap} title={tr('profile.guestTitle')} body={tr('profile.guestBody')} action={tr('common.signIn')} onAction={() => router.push('/auth')} />
      </ScrollScreen>
    );
  }

  const loading = enrollments.isLoading;

  return (
    <ScrollScreen title={tr('learning.title')} bottomInset={TAB_BAR_HEIGHT} refreshing={enrollments.isRefetching} onRefresh={() => void Promise.all([enrollments.refetch(), bookmarks.refetch()])}>
      <View style={{ paddingHorizontal: t.spacing.gutter }}>
        <Segmented
          value={tab}
          onChange={setTab}
          options={[
            { value: 'progress', label: tr('learning.inProgress') },
            { value: 'completed', label: tr('learning.completed') },
            { value: 'saved', label: tr('learning.saved') },
            { value: 'downloads', label: tr('learning.downloads') },
          ]}
        />
      </View>

      <View style={{ paddingHorizontal: t.spacing.gutter, gap: 18 }}>
        {loading && [0, 1, 2].map((i) => <Skeleton key={i} height={92} radius={14} />)}

        {tab === 'progress' &&
          !loading &&
          (active.length ? (
            active.map((e, i) => (
              <View key={e.id} style={{ gap: 6 }}>
                <CourseRow course={e.course!} enrollment={e} index={i} />
                <Text variant="caption" tone="tertiary" style={{ marginLeft: 106 }}>
                  {tr('learning.lastOpened', { time: relativeTime(e.last_accessed_at) })}
                </Text>
              </View>
            ))
          ) : (
            <EmptyState icon={GraduationCap} title={tr('learning.emptyTitle')} body={tr('learning.emptyInProgress')} action={tr('learning.browse')} onAction={() => router.push('/explore')} />
          ))}

        {tab === 'completed' &&
          !loading &&
          (done.length ? (
            done.map((e, i) => {
              const cert = certificates.data?.find((c) => c.course_id === e.course_id);
              return (
                <View key={e.id} style={{ gap: 10 }}>
                  <CourseRow course={e.course!} enrollment={e} index={i} />
                  {cert && (
                    <PressableScale onPress={() => router.push({ pathname: '/certificates/[id]', params: { id: cert.id } })} style={[styles.certLink, { backgroundColor: t.colors.accentSoft, borderRadius: t.radii.md }]}>
                      <Award size={16} color={t.colors.accent} />
                      <Text variant="subhead" tone="accent">
                        {tr('certificates.serial', { serial: cert.serial })}
                      </Text>
                    </PressableScale>
                  )}
                </View>
              );
            })
          ) : (
            <EmptyState icon={Award} title={tr('learning.emptyTitle')} body={tr('learning.emptyCompleted')} />
          ))}

        {tab === 'saved' &&
          (bookmarks.data?.length ? (
            bookmarks.data.map((b) => (
              <PressableScale key={b.id} onPress={() => router.push({ pathname: '/lesson/[id]', params: { id: b.lesson_id } })} scaleTo={0.985}>
                <Card style={styles.savedRow}>
                  {b.lesson?.course && <CourseCover id={`b${b.id}`} coverStyle={b.lesson.course.cover_style} categoryColor={b.lesson.course.category?.color} radius={10} style={{ width: 48, height: 48 }} />}
                  <View style={{ flex: 1, gap: 2 }}>
                    <Text variant="subhead" numberOfLines={2}>
                      {b.lesson?.title ?? ''}
                    </Text>
                    <Text variant="caption" tone="tertiary" numberOfLines={1}>
                      {b.lesson?.course?.title}
                    </Text>
                  </View>
                  <IconButton icon={Bookmark} active size={36} label={tr('lesson.removeBookmark')} onPress={() => toggle.mutate({ lessonId: b.lesson_id, existingId: b.id })} />
                </Card>
              </PressableScale>
            ))
          ) : (
            <EmptyState icon={Bookmark} title={tr('learning.emptyTitle')} body={tr('learning.emptySaved')} />
          ))}

        {tab === 'downloads' &&
          (downloads.length ? (
            <>
              {downloads.map((d) => (
                <Card key={d.id} style={styles.savedRow}>
                  <View style={[styles.fileIcon, { backgroundColor: t.colors.surfaceHigh }]}>
                    <FileText size={18} color={t.colors.text} />
                  </View>
                  <PressableScale style={{ flex: 1, gap: 2 }} onPress={() => Platform.OS !== 'web' && Sharing.shareAsync(d.uri).catch(() => {})}>
                    <Text variant="subhead" numberOfLines={1}>
                      {d.title}
                    </Text>
                    <Text variant="caption" tone="tertiary">
                      {d.kind.toUpperCase()} · {formatBytes(d.sizeBytes)}
                    </Text>
                  </PressableScale>
                  <IconButton
                    icon={Trash2}
                    size={36}
                    label={tr('common.delete')}
                    onPress={async () => {
                      await removeDownload(d.id);
                      setDownloads(await listDownloads());
                    }}
                  />
                </Card>
              ))}
              <PressableScale
                onPress={async () => {
                  await clearDownloads();
                  setDownloads([]);
                }}
                style={{ alignSelf: 'center', padding: 8 }}>
                <Text variant="subhead" tone="danger">
                  {tr('learning.clearDownloads')}
                </Text>
              </PressableScale>
            </>
          ) : (
            <EmptyState icon={Download} title={tr('learning.emptyTitle')} body={tr('learning.emptyDownloads')} />
          ))}
      </View>
    </ScrollScreen>
  );
}

const styles = StyleSheet.create({
  certLink: { flexDirection: 'row', alignItems: 'center', gap: 8, padding: 12 },
  savedRow: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 12 },
  fileIcon: { width: 44, height: 44, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
});
