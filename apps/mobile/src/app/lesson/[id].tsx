import { router, useLocalSearchParams } from 'expo-router';
import * as WebBrowser from 'expo-web-browser';
import {
  Bookmark,
  BookmarkCheck,
  ChevronLeft,
  ChevronRight,
  CircleCheck,
  ClipboardList,
  Download,
  FileText,
  FolderKanban,
  Lock,
  MessageCircle,
  NotebookPen,
  Trash2,
  Video,
} from 'lucide-react-native';
import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { AppState, KeyboardAvoidingView, Platform, ScrollView, StyleSheet, View } from 'react-native';
import Animated, { FadeIn, FadeInDown } from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { lessonIcon } from '@/components/course/Curriculum';
import { Markdown } from '@/components/lesson/Markdown';
import { VideoPlayer } from '@/components/lesson/VideoPlayer';
import { Button } from '@/components/ui/Button';
import { BackButton, EmptyState, ErrorState, Glass, IconButton } from '@/components/ui/layout';
import { PressableScale } from '@/components/ui/PressableScale';
import { Badge, Card, ProgressBar, Skeleton } from '@/components/ui/primitives';
import { Sheet } from '@/components/ui/Sheet';
import { Text } from '@/components/ui/Text';
import { TextField } from '@/components/ui/TextField';
import { toast } from '@/components/ui/Toast';
import { api } from '@/data';
import { useAuth } from '@/data/auth';
import {
  useAddNote,
  useBookmarks,
  useCertificates,
  useCourseById,
  useCourseProgress,
  useDeleteNote,
  useEnrollments,
  useLessonContent,
  useLessonCourseId,
  useNotes,
  useQuiz,
  useRecordProgress,
  useToggleBookmark,
} from '@/data/hooks';
import { adjacentLessons } from '@/data/learning';
import type { Resource } from '@/data/types';
import { downloadResource, formatBytes } from '@/lib/downloads';
import { errorCode, errorMessageKey } from '@/lib/errors';
import { useI18n } from '@/i18n';
import { usePreferences } from '@/stores/preferences';
import { useTheme } from '@/theme/ThemeProvider';

const fmtTime = (s: number) => `${Math.floor(s / 60)}:${String(Math.floor(s % 60)).padStart(2, '0')}`;

/** Counts seconds the lesson is actually on screen with the app in the foreground. */
function useEngagedTime(enabled: boolean, onFlush: (seconds: number) => void) {
  const acc = useRef(0);
  const flushRef = useRef(onFlush);
  useEffect(() => {
    flushRef.current = onFlush;
  }, [onFlush]);
  useEffect(() => {
    if (!enabled) return;
    let active = AppState.currentState === 'active';
    const tick = setInterval(() => {
      if (!active) return;
      acc.current += 1;
      if (acc.current >= 30) {
        flushRef.current(acc.current);
        acc.current = 0;
      }
    }, 1000);
    const sub = AppState.addEventListener('change', (s) => {
      active = s === 'active';
      if (!active && acc.current > 0) {
        flushRef.current(acc.current);
        acc.current = 0;
      }
    });
    return () => {
      clearInterval(tick);
      sub.remove();
      if (acc.current > 0) flushRef.current(acc.current);
      acc.current = 0;
    };
  }, [enabled]);
}

export default function LessonScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const t = useTheme();
  const { t: tr, duration } = useI18n();
  const insets = useSafeAreaInsets();
  const user = useAuth((s) => s.user);
  const autoplayNext = usePreferences((s) => s.autoplayNext);

  const content = useLessonContent(id);
  const courseId = useLessonCourseId(id).data ?? undefined;
  const course = useCourseById(courseId);
  const progress = useCourseProgress(courseId);
  const enrollments = useEnrollments();
  const certificates = useCertificates();
  const bookmarks = useBookmarks();
  const toggleBookmark = useToggleBookmark();
  const record = useRecordProgress();
  const quiz = useQuiz(content.data?.quiz_id);
  const [notesOpen, setNotesOpen] = useState(false);
  const positionRef = useRef(0);
  const [videoPosition, setVideoPosition] = useState(0);

  const nav = useMemo(() => (course.data && id ? adjacentLessons(course.data, id) : null), [course.data, id]);
  const lesson = nav?.lesson;
  const lp = progress.data?.find((p) => p.lesson_id === id);
  const isDone = lp?.status === 'completed';
  const enrollment = enrollments.data?.find((e) => e.course_id === courseId);
  const hadCertificate = !!certificates.data?.some((c) => c.course_id === courseId);
  const bookmark = bookmarks.data?.find((b) => b.lesson_id === id && b.position_seconds == null);
  const locked = content.error && errorCode(content.error) === 'lesson_locked';
  const canTrack = !!user && !!content.data;

  // Register the visit (drives "recently viewed" and "continue learning").
  useEffect(() => {
    if (canTrack && id) record.mutate({ lessonId: id, secondsSpent: 0 });
  }, [canTrack, id]); // eslint-disable-line react-hooks/exhaustive-deps

  const heartbeat = useCallback(
    (seconds: number, position?: number) => {
      if (!id || !user) return;
      void api.recordProgress(id, { secondsSpent: seconds, positionSeconds: position ?? positionRef.current }).catch(() => {});
    },
    [id, user],
  );
  useEngagedTime(canTrack && !content.data?.video, heartbeat);

  const complete = async () => {
    if (!user) return router.push('/auth');
    if (!id) return;
    try {
      await record.mutateAsync({ lessonId: id, completed: true, hadCertificate });
      if (autoplayNext && nav?.next) setTimeout(() => router.replace({ pathname: '/lesson/[id]', params: { id: nav.next!.id } }), 900);
    } catch (e) {
      toast.error(tr(errorMessageKey(e)));
    }
  };

  const go = (lessonId: string) => router.replace({ pathname: '/lesson/[id]', params: { id: lessonId } });

  const header = (
    <View style={[styles.header, { paddingTop: insets.top }]}>
      <Glass style={StyleSheet.absoluteFill} intensity={50} />
      <View style={styles.headerRow}>
        <BackButton />
        <View style={{ flex: 1, alignItems: 'center' }}>
          {nav && nav.index >= 0 && (
            <Text variant="caption" tone="secondary">
              {tr('lesson.lessonOf', { n: nav.index + 1, total: nav.total })}
            </Text>
          )}
          {course.data && (
            <Text variant="subhead" numberOfLines={1}>
              {course.data.title}
            </Text>
          )}
        </View>
        <View style={{ flexDirection: 'row', gap: 8 }}>
          {user && content.data && (
            <>
              <IconButton
                icon={bookmark ? BookmarkCheck : Bookmark}
                active={!!bookmark}
                label={bookmark ? tr('lesson.removeBookmark') : tr('lesson.bookmark')}
                onPress={() =>
                  toggleBookmark.mutate(
                    { lessonId: id!, existingId: bookmark?.id },
                    { onSuccess: (b) => b && toast.success(tr('lesson.bookmarked')) },
                  )
                }
              />
              <IconButton icon={NotebookPen} label={tr('lesson.notes')} onPress={() => setNotesOpen(true)} />
            </>
          )}
        </View>
      </View>
      {enrollment && <ProgressBar value={enrollment.progress_percent / 100} height={2} style={{ borderRadius: 0 }} />}
    </View>
  );

  if (content.isLoading) {
    return (
      <View style={[styles.flex, { backgroundColor: t.colors.background }]}>
        {header}
        <View style={{ padding: 20, gap: 14, paddingTop: insets.top + 90 }}>
          <Skeleton height={200} radius={t.radii.lg} />
          <Skeleton width="70%" height={28} />
          {[0, 1, 2, 3, 4].map((i) => (
            <Skeleton key={i} width={`${90 - i * 7}%`} height={14} />
          ))}
        </View>
      </View>
    );
  }

  if (locked || content.error) {
    return (
      <View style={[styles.flex, { backgroundColor: t.colors.background }]}>
        {header}
        <View style={[styles.flex, { justifyContent: 'center', paddingHorizontal: 24 }]}>
          {locked ? (
            <EmptyState icon={Lock} title={tr('lesson.lockedTitle')} body={tr('lesson.lockedBody')} action={tr('course.unlock')} onAction={() => router.push('/paywall')} />
          ) : (
            <ErrorState message={tr(errorMessageKey(content.error))} onRetry={() => content.refetch()} />
          )}
        </View>
      </View>
    );
  }

  const c = content.data!;
  const TypeIcon = lesson ? lessonIcon[lesson.type] : FileText;
  const isQuizLesson = lesson?.type === 'quiz';
  const isAssignmentLesson = !!c.assignment && (lesson?.type === 'assignment' || lesson?.type === 'project');

  return (
    <KeyboardAvoidingView style={[styles.flex, { backgroundColor: t.colors.background }]} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <ScrollView contentContainerStyle={{ paddingTop: insets.top + 76, paddingBottom: insets.bottom + 120 }} showsVerticalScrollIndicator={false}>
        <View style={styles.column}>
          {c.video ? (
            <Animated.View entering={FadeIn.duration(300)}>
              <VideoPlayer
                video={c.video}
                title={lesson?.title}
                startAt={lp?.position_seconds ?? 0}
                onHeartbeat={(pos, spent) => {
                  positionRef.current = pos;
                  setVideoPosition(pos);
                  heartbeat(spent, pos);
                }}
                onNearlyComplete={() => !isDone && user && complete()}
              />
            </Animated.View>
          ) : lesson?.type === 'video' ? (
            <Card style={{ flexDirection: 'row', gap: 12, alignItems: 'center' }}>
              <Video size={20} color={t.colors.textSecondary} />
              <Text variant="footnote" tone="secondary" style={{ flex: 1 }}>
                {tr('lesson.videoUnavailable')}
              </Text>
            </Card>
          ) : null}

          <Animated.View entering={t.reduceMotion ? undefined : FadeInDown.duration(380)} style={{ gap: 12, marginTop: 20 }}>
            <View style={{ flexDirection: 'row', gap: 6, flexWrap: 'wrap' }}>
              {lesson && <Badge label={tr(`lessonTypes.${lesson.type}`)} icon={TypeIcon} tone="accent" />}
              {lesson?.duration_seconds ? <Badge label={duration(lesson.duration_seconds)} /> : null}
              {isDone && <Badge label={tr('lesson.completed')} icon={CircleCheck} tone="success" />}
              {lesson?.is_preview && course.data?.access_tier === 'premium' && <Badge label={tr('course.preview')} tone="info" />}
            </View>
            <Text variant="title1" accessibilityRole="header" testID="lesson-title">
              {lesson?.title ?? ''}
            </Text>
            {lesson?.summary && (
              <Text variant="callout" tone="secondary">
                {lesson.summary}
              </Text>
            )}
          </Animated.View>

          {!user && (
            <PressableScale onPress={() => router.push('/auth')} style={[styles.guest, { backgroundColor: t.colors.accentSoft, borderRadius: t.radii.md }]}>
              <Text variant="subhead" tone="accent">
                {tr('lesson.signInToTrack')}
              </Text>
            </PressableScale>
          )}

          {c.body_md && (
            <View style={{ marginTop: 24 }}>
              <Markdown source={c.body_md} />
            </View>
          )}

          {!!c.resources.length && <Resources resources={c.resources} />}

          {c.assignment && (
            <Card style={[styles.blockCard, { borderColor: t.colors.accent }]}>
              <View style={styles.blockHead}>
                <FolderKanban size={20} color={t.colors.accent} />
                <Text variant="title3">{c.assignment.is_project ? tr('lesson.projectTitle') : tr('lesson.assignmentTitle')}</Text>
              </View>
              <Text variant="callout" tone="secondary">
                {c.assignment.title}
              </Text>
              <Button title={tr('lesson.openAssignment')} onPress={() => (user ? router.push({ pathname: '/assignment/[id]', params: { id: c.assignment!.id } }) : router.push('/auth'))} />
            </Card>
          )}

          {c.quiz_id && (
            <Card style={[styles.blockCard, { borderColor: quiz.data?.passed ? t.colors.success : t.colors.border }]}>
              <View style={styles.blockHead}>
                <ClipboardList size={20} color={quiz.data?.passed ? t.colors.success : t.colors.accent} />
                <Text variant="title3">{quiz.data?.title ?? tr('lesson.knowledgeCheck')}</Text>
              </View>
              <Text variant="callout" tone="secondary">
                {quiz.data?.passed ? tr('lesson.quizPassed', { score: Math.round(quiz.data.best_score ?? 0) }) : tr('lesson.knowledgeCheckBody')}
              </Text>
              <Button
                title={quiz.data?.passed ? tr('lesson.retakeQuiz') : tr('lesson.startQuiz')}
                variant={quiz.data?.passed ? 'secondary' : 'primary'}
                onPress={() => (user ? router.push({ pathname: '/quiz/[id]', params: { id: c.quiz_id! } }) : router.push('/auth'))}
                testID="start-quiz"
              />
            </Card>
          )}

          <PressableScale onPress={() => router.push({ pathname: '/assistant', params: { lessonId: id } })} style={[styles.assistant, { borderColor: t.colors.border, borderRadius: t.radii.md }]}>
            <MessageCircle size={18} color={t.colors.textSecondary} />
            <Text variant="subhead" tone="secondary" style={{ flex: 1 }}>
              {tr('assistant.placeholder')}
            </Text>
          </PressableScale>
        </View>
      </ScrollView>

      {header}

      <View style={[styles.footer, { paddingBottom: insets.bottom + 10 }]}>
        <Glass style={StyleSheet.absoluteFill} intensity={50} />
        <View style={[styles.hairline, { backgroundColor: t.colors.border }]} />
        <View style={styles.footerRow}>
          <IconButton icon={ChevronLeft} size={48} label={tr('lesson.previousLesson')} onPress={() => nav?.previous && go(nav.previous.id)} style={{ opacity: nav?.previous ? 1 : 0.35 }} />
          <View style={{ flex: 1 }}>
            {isQuizLesson && c.quiz_id ? (
              <Button title={quiz.data?.passed ? tr('lesson.retakeQuiz') : tr('lesson.startQuiz')} variant={isDone ? 'secondary' : 'primary'} onPress={() => (user ? router.push({ pathname: '/quiz/[id]', params: { id: c.quiz_id! } }) : router.push('/auth'))} fullWidth />
            ) : isAssignmentLesson ? (
              <Button title={tr('lesson.openAssignment')} variant={isDone ? 'secondary' : 'primary'} onPress={() => (user ? router.push({ pathname: '/assignment/[id]', params: { id: c.assignment!.id } }) : router.push('/auth'))} fullWidth />
            ) : isDone ? (
              nav?.next ? (
                <Button title={tr('lesson.nextLesson')} iconRight={ChevronRight} onPress={() => go(nav.next!.id)} fullWidth testID="next-lesson" />
              ) : (
                <Button title={tr('lesson.completed')} icon={CircleCheck} variant="secondary" onPress={() => course.data && router.replace({ pathname: '/course/[slug]', params: { slug: course.data.slug } })} fullWidth />
              )
            ) : (
              <Button title={tr('lesson.markComplete')} icon={CircleCheck} onPress={complete} loading={record.isPending && record.variables?.completed} fullWidth testID="mark-complete" />
            )}
          </View>
          <IconButton icon={ChevronRight} size={48} label={tr('lesson.nextLesson')} onPress={() => nav?.next && go(nav.next.id)} style={{ opacity: nav?.next ? 1 : 0.35 }} />
        </View>
      </View>

      <NotesSheet lessonId={id!} visible={notesOpen} onClose={() => setNotesOpen(false)} position={c.video ? videoPosition : null} />
    </KeyboardAvoidingView>
  );
}

function Resources({ resources }: { resources: Resource[] }) {
  const t = useTheme();
  const { t: tr } = useI18n();
  const [busy, setBusy] = useState<string | null>(null);
  const [done, setDone] = useState<Set<string>>(new Set());
  return (
    <View style={{ gap: 12, marginTop: 28 }}>
      <Text variant="title3">{tr('lesson.resources')}</Text>
      {resources.map((r) => (
        <Card key={r.id} style={{ flexDirection: 'row', alignItems: 'center', gap: 12, padding: 12 }}>
          <View style={[styles.resIcon, { backgroundColor: t.colors.surfaceHigh }]}>
            <FileText size={18} color={t.colors.text} />
          </View>
          <View style={{ flex: 1 }}>
            <Text variant="subhead" numberOfLines={1}>
              {r.title}
            </Text>
            <Text variant="caption" tone="tertiary">
              {r.kind.toUpperCase()}
              {r.size_bytes ? ` · ${formatBytes(r.size_bytes)}` : ''}
              {done.has(r.id) ? ` · ${tr('lesson.downloaded')}` : ''}
            </Text>
          </View>
          <IconButton
            icon={Download}
            label={busy === r.id ? tr('lesson.downloading') : r.allow_offline && Platform.OS !== 'web' ? tr('lesson.download') : tr('lesson.openResource')}
            onPress={async () => {
              setBusy(r.id);
              try {
                const url = await api.getResourceUrl(r);
                if (r.allow_offline && Platform.OS !== 'web' && !r.external_url) {
                  await downloadResource(r, url);
                  setDone((s) => new Set(s).add(r.id));
                  toast.success(tr('lesson.downloaded'));
                } else await WebBrowser.openBrowserAsync(url);
              } catch (e) {
                toast.error(tr(errorMessageKey(e)));
              } finally {
                setBusy(null);
              }
            }}
          />
        </Card>
      ))}
    </View>
  );
}

function NotesSheet({ lessonId, visible, onClose, position }: { lessonId: string; visible: boolean; onClose: () => void; position: number | null }) {
  const t = useTheme();
  const { t: tr, relativeTime } = useI18n();
  const notes = useNotes(visible ? lessonId : undefined);
  const add = useAddNote(lessonId);
  const del = useDeleteNote(lessonId);
  const [text, setText] = useState('');
  return (
    <Sheet visible={visible} onClose={onClose} title={tr('lesson.notes')}>
      <View style={{ paddingHorizontal: 20, gap: 12 }}>
        <TextField
          value={text}
          onChangeText={setText}
          placeholder={tr('lesson.addNote')}
          multiline
          multilineHeight={90}
          maxLength={10000}
          accessibilityLabel={tr('lesson.addNote')}
        />
        <Button
          title={tr('common.save')}
          disabled={!text.trim()}
          loading={add.isPending}
          onPress={() =>
            add.mutate(
              { body: text, positionSeconds: position },
              { onSuccess: () => setText(''), onError: (e) => toast.error(tr(errorMessageKey(e))) },
            )
          }
        />
        <ScrollView style={{ maxHeight: 280 }} contentContainerStyle={{ gap: 10, paddingBottom: 12 }}>
          {(notes.data ?? []).length === 0 && !notes.isLoading && (
            <Text variant="footnote" tone="tertiary" align="center" style={{ paddingVertical: 16 }}>
              {tr('lesson.noNotes')}
            </Text>
          )}
          {(notes.data ?? []).map((n) => (
            <View key={n.id} style={[styles.note, { backgroundColor: t.colors.surface, borderColor: t.colors.border, borderRadius: t.radii.md }]}>
              <View style={{ flex: 1, gap: 4 }}>
                <Text variant="callout">{n.body}</Text>
                <Text variant="caption" tone="tertiary">
                  {relativeTime(n.created_at)}
                  {n.position_seconds != null ? ` · ${tr('lesson.noteAt', { time: fmtTime(n.position_seconds) })}` : ''}
                </Text>
              </View>
              <IconButton icon={Trash2} size={34} label={tr('common.delete')} onPress={() => del.mutate(n.id)} />
            </View>
          ))}
        </ScrollView>
      </View>
    </Sheet>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  header: { position: 'absolute', top: 0, left: 0, right: 0, zIndex: 5 },
  headerRow: { flexDirection: 'row', alignItems: 'center', gap: 8, paddingHorizontal: 12, height: 60 },
  column: { paddingHorizontal: 20, width: '100%', maxWidth: 760, alignSelf: 'center' },
  guest: { padding: 14, marginTop: 16, alignItems: 'center' },
  blockCard: { gap: 12, marginTop: 28, borderWidth: 1 },
  blockHead: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  assistant: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 14, borderWidth: StyleSheet.hairlineWidth, marginTop: 28, borderStyle: 'dashed' },
  resIcon: { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  footer: { position: 'absolute', left: 0, right: 0, bottom: 0, paddingTop: 10 },
  footerRow: { flexDirection: 'row', alignItems: 'center', gap: 10, paddingHorizontal: 16, maxWidth: 760, width: '100%', alignSelf: 'center' },
  hairline: { position: 'absolute', top: 0, left: 0, right: 0, height: StyleSheet.hairlineWidth },
  note: { flexDirection: 'row', gap: 10, padding: 12, borderWidth: StyleSheet.hairlineWidth, alignItems: 'flex-start' },
});

