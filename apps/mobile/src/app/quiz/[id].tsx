import { router, useLocalSearchParams } from 'expo-router';
import { Check, ChevronLeft, CircleCheck, CircleX, Clock, X } from 'lucide-react-native';
import { useEffect, useMemo, useRef, useState } from 'react';
import { ScrollView, StyleSheet, View } from 'react-native';
import Animated, { FadeIn, FadeInDown, SlideInLeft, SlideInRight, SlideOutLeft, SlideOutRight } from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Aurora } from '@/components/brand/Aurora';
import { CodeBlock } from '@/components/lesson/CodeBlock';
import { InlineMarkdown, Markdown } from '@/components/lesson/Markdown';
import { Button } from '@/components/ui/Button';
import { ErrorState, IconButton } from '@/components/ui/layout';
import { PressableScale } from '@/components/ui/PressableScale';
import { Badge, Card, ProgressBar, ProgressRing, Skeleton } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { TextField } from '@/components/ui/TextField';
import { toast } from '@/components/ui/Toast';
import { useCertificates, useQuiz, useSubmitQuiz } from '@/data/hooks';
import type { Quiz, QuizQuestion, QuizResponses, QuizResult } from '@/data/types';
import { haptics } from '@/lib/haptics';
import { errorMessageKey } from '@/lib/errors';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

function AnswerOption({ label, selected, multi, onPress }: { label: string; selected: boolean; multi: boolean; onPress: () => void }) {
  const t = useTheme();
  return (
    <PressableScale
      onPress={onPress}
      haptic="select"
      accessibilityRole={multi ? 'checkbox' : 'radio'}
      accessibilityState={{ checked: selected, selected }}
      scaleTo={0.98}
      style={[styles.option, { borderRadius: t.radii.lg, backgroundColor: selected ? t.colors.accentSoft : t.colors.surface, borderColor: selected ? t.colors.accent : t.colors.border }]}>
      <View style={[multi ? styles.box : styles.radio, { borderColor: selected ? t.colors.accent : t.colors.borderStrong, backgroundColor: selected && multi ? t.colors.accent : 'transparent' }]}>
        {selected && (multi ? <Check size={14} color={t.colors.onAccent} strokeWidth={3} /> : <View style={[styles.radioDot, { backgroundColor: t.colors.accent }]} />)}
      </View>
      <View style={{ flex: 1 }}>
        <InlineMarkdown source={label} />
      </View>
    </PressableScale>
  );
}

function QuestionView({ q, value, onChange }: { q: QuizQuestion; value: string[] | string | undefined; onChange: (v: string[] | string) => void }) {
  const { t: tr } = useI18n();
  const selected = Array.isArray(value) ? value : [];
  const multi = q.type === 'multiple_choice';
  return (
    <View style={{ gap: 18 }}>
      <Text variant="overline" tone="tertiary">
        {q.type === 'short_answer' ? tr('quiz.typeAnswer') : multi ? tr('quiz.selectAll') : tr('quiz.selectOne')}
      </Text>
      <InlineMarkdown source={q.prompt_md} style={{ fontSize: 21, lineHeight: 30, fontFamily: 'Inter-SemiBold' }} />
      {q.code_snippet && <CodeBlock code={q.code_snippet} lang={/^\s*</.test(q.code_snippet) ? 'html' : 'python'} />}
      {q.type === 'short_answer' ? (
        <TextField value={typeof value === 'string' ? value : ''} onChangeText={(v) => onChange(v)} placeholder={tr('quiz.typeAnswer')} autoCapitalize="none" autoCorrect={false} maxLength={200} />
      ) : (
        <View style={{ gap: 10 }}>
          {q.answers.map((a) => (
            <AnswerOption
              key={a.id}
              label={a.label_md}
              multi={multi}
              selected={selected.includes(a.id)}
              onPress={() => onChange(multi ? (selected.includes(a.id) ? selected.filter((x) => x !== a.id) : [...selected, a.id]) : [a.id])}
            />
          ))}
        </View>
      )}
    </View>
  );
}

function Results({ quiz, result, responses, onRetry }: { quiz: Quiz; result: QuizResult; responses: QuizResponses; onRetry?: () => void }) {
  const t = useTheme();
  const { t: tr, tp } = useI18n();
  const insets = useSafeAreaInsets();
  const attemptsLeft = quiz.max_attempts ? quiz.max_attempts - quiz.attempts_used - 1 : null;
  useEffect(() => {
    if (result.passed) haptics.success();
    else haptics.warning();
  }, [result.passed]);
  return (
    <ScrollView contentContainerStyle={{ padding: 20, paddingTop: insets.top + 24, paddingBottom: insets.bottom + 40, gap: 24, maxWidth: 720, width: '100%', alignSelf: 'center' }}>
      <Animated.View entering={FadeInDown.springify().damping(16)} style={{ alignItems: 'center', gap: 14 }}>
        <ProgressRing value={result.score_percent / 100} size={150} stroke={11} color={result.passed ? t.colors.success : t.colors.warning}>
          <Text variant="display">{Math.round(result.score_percent)}%</Text>
        </ProgressRing>
        <Text variant="title1" align="center" accessibilityRole="header" testID="quiz-result-title">
          {result.passed ? tr('quiz.passed') : tr('quiz.failed')}
        </Text>
        <Text variant="callout" tone="secondary" align="center">
          {result.points_earned}/{result.points_possible} · {tr('quiz.passMark', { n: result.pass_score_percent })}
        </Text>
        {result.xp_awarded > 0 && <Badge label={tr('lesson.xpEarned', { n: result.xp_awarded })} tone="accent" />}
        {attemptsLeft !== null && !result.passed && (
          <Text variant="footnote" tone="tertiary">
            {attemptsLeft > 0 ? tp('quiz.attemptsLeft', attemptsLeft) : tr('quiz.noAttemptsLeft')}
          </Text>
        )}
      </Animated.View>

      <View style={{ gap: 10 }}>
        {!result.passed && onRetry && (attemptsLeft === null || attemptsLeft > 0) && <Button title={tr('quiz.tryAgain')} onPress={onRetry} size="lg" fullWidth testID="quiz-retry" />}
        <Button title={tr('quiz.backToLesson')} variant={result.passed ? 'primary' : 'secondary'} onPress={() => router.back()} size="lg" fullWidth testID="quiz-back" />
      </View>

      <Text variant="title3">{tr('quiz.reviewAnswers')}</Text>
      {quiz.questions.map((q, i) => {
        const r = result.results.find((x) => x.question_id === q.id);
        if (!r) return null;
        const label = (id: string) => q.answers.find((a) => a.id === id)?.label_md ?? '';
        const yours = q.type === 'short_answer' ? (typeof responses[q.id] === 'string' ? (responses[q.id] as string) : '—') : r.selected_answer_ids.map(label).join(', ') || '—';
        return (
          <Animated.View key={q.id} entering={FadeIn.delay(80 * i)}>
            <Card style={{ gap: 12, borderColor: r.correct ? t.colors.success : t.colors.danger, borderWidth: 1 }}>
              <View style={{ flexDirection: 'row', gap: 10, alignItems: 'flex-start' }}>
                {r.correct ? <CircleCheck size={20} color={t.colors.success} /> : <CircleX size={20} color={t.colors.danger} />}
                <View style={{ flex: 1 }}>
                  <InlineMarkdown source={q.prompt_md} style={{ fontFamily: 'Inter-SemiBold' }} />
                </View>
              </View>
              <View style={{ gap: 4 }}>
                <Text variant="caption" tone="tertiary">
                  {tr('quiz.yourAnswer')}
                </Text>
                <InlineMarkdown source={yours} style={{ color: r.correct ? t.colors.success : t.colors.danger }} />
              </View>
              {!r.correct && (
                <View style={{ gap: 4 }}>
                  <Text variant="caption" tone="tertiary">
                    {q.type === 'short_answer' ? tr('quiz.acceptedAnswers') : tr('quiz.correctAnswer')}
                  </Text>
                  <InlineMarkdown source={q.type === 'short_answer' ? r.accepted_answers.join(' / ') : r.correct_answer_ids.map(label).join(', ')} style={{ color: t.colors.success }} />
                </View>
              )}
              {r.feedback
                .filter((f) => r.selected_answer_ids.includes(f.answer_id) && !r.correct)
                .map((f) => (
                  <Text key={f.answer_id} variant="footnote" tone="secondary">
                    {f.feedback_md}
                  </Text>
                ))}
              {r.explanation_md && (
                <View style={[styles.explain, { backgroundColor: t.colors.surfaceHigh, borderRadius: t.radii.md }]}>
                  <Text variant="overline" tone="accent">
                    {tr('quiz.explanation')}
                  </Text>
                  <Markdown source={r.explanation_md} />
                </View>
              )}
            </Card>
          </Animated.View>
        );
      })}
    </ScrollView>
  );
}

export default function QuizScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const t = useTheme();
  const { t: tr } = useI18n();
  const insets = useSafeAreaInsets();
  const quiz = useQuiz(id);
  const submit = useSubmitQuiz();
  const certificates = useCertificates();
  const [index, setIndex] = useState(0);
  const [dir, setDir] = useState<1 | -1>(1);
  const [responses, setResponses] = useState<QuizResponses>({});
  const [result, setResult] = useState<QuizResult | null>(null);
  const startedAt = useRef(new Date().toISOString());
  const [remaining, setRemaining] = useState<number | null>(null);

  const q = quiz.data;
  const questions = useMemo(() => q?.questions ?? [], [q]);
  const current = questions[index];
  const answered = (qq: QuizQuestion) => {
    const v = responses[qq.id];
    return Array.isArray(v) ? v.length > 0 : typeof v === 'string' && v.trim().length > 0;
  };

  const doSubmit = async () => {
    if (!q) return;
    try {
      const r = await submit.mutateAsync({
        quizId: q.id,
        responses,
        startedAt: startedAt.current,
        hadCertificate: !!certificates.data?.some((c) => c.course_id === q.course_id),
      });
      setResult(r);
    } catch (e) {
      toast.error(tr(errorMessageKey(e)));
    }
  };

  // Optional time limit.
  useEffect(() => {
    if (!q?.time_limit_seconds || result) return;
    setRemaining(q.time_limit_seconds);
    const idTimer = setInterval(() => setRemaining((r) => (r === null ? r : r - 1)), 1000);
    return () => clearInterval(idTimer);
  }, [q?.time_limit_seconds, result]);
  useEffect(() => {
    if (remaining === 0 && !result && !submit.isPending) void doSubmit();
  }, [remaining]); // eslint-disable-line react-hooks/exhaustive-deps

  if (quiz.isLoading) {
    return (
      <View style={[styles.flex, { backgroundColor: t.colors.background, padding: 20, paddingTop: insets.top + 80, gap: 16 }]}>
        <Skeleton height={8} />
        <Skeleton width="80%" height={26} />
        {[0, 1, 2, 3].map((i) => (
          <Skeleton key={i} height={60} radius={18} />
        ))}
      </View>
    );
  }
  if (!q || quiz.error) {
    return (
      <View style={[styles.flex, { backgroundColor: t.colors.background, justifyContent: 'center' }]}>
        <ErrorState message={tr(errorMessageKey(quiz.error))} onRetry={() => router.back()} />
      </View>
    );
  }

  if (result) {
    return (
      <View style={[styles.flex, { backgroundColor: t.colors.background }]}>
        <Aurora hue={result.passed ? 150 : 38} intensity={0.5} />
        <Results
          quiz={q}
          result={result}
          responses={responses}
          onRetry={() => {
            setResult(null);
            setResponses({});
            setIndex(0);
            startedAt.current = new Date().toISOString();
            void quiz.refetch();
          }}
        />
      </View>
    );
  }

  const isLast = index === questions.length - 1;
  const allAnswered = questions.every(answered);

  return (
    <View style={[styles.flex, { backgroundColor: t.colors.background }]}>
      <View style={[styles.top, { paddingTop: insets.top + 8 }]}>
        <IconButton icon={X} label={tr('common.close')} onPress={() => router.back()} />
        <View style={{ flex: 1, gap: 6 }}>
          <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
            <Text variant="caption" tone="secondary">
              {tr('quiz.questionOf', { n: index + 1, total: questions.length })}
            </Text>
            {remaining !== null && (
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
                <Clock size={12} color={remaining < 30 ? t.colors.danger : t.colors.textSecondary} />
                <Text variant="caption" tone={remaining < 30 ? 'danger' : 'secondary'}>
                  {Math.floor(remaining / 60)}:{String(remaining % 60).padStart(2, '0')}
                </Text>
              </View>
            )}
          </View>
          <ProgressBar value={(index + 1) / questions.length} height={5} />
        </View>
      </View>

      <ScrollView contentContainerStyle={{ padding: 20, paddingBottom: insets.bottom + 140, maxWidth: 720, width: '100%', alignSelf: 'center' }} keyboardShouldPersistTaps="handled">
        <View style={{ gap: 6, marginBottom: 20 }}>
          {q.kind !== 'knowledge_check' && <Badge label={q.kind === 'final_assessment' ? tr('quiz.finalAssessment') : tr('quiz.moduleExam')} tone="accent" />}
          <Text variant="headline" tone="secondary">
            {q.title}
          </Text>
        </View>
        {current && (
          <Animated.View key={current.id} entering={t.reduceMotion ? undefined : dir === 1 ? SlideInRight.springify().damping(20) : SlideInLeft.springify().damping(20)} exiting={t.reduceMotion ? undefined : dir === 1 ? SlideOutLeft.duration(160) : SlideOutRight.duration(160)}>
            <QuestionView q={current} value={responses[current.id]} onChange={(v) => setResponses((r) => ({ ...r, [current.id]: v }))} />
          </Animated.View>
        )}
      </ScrollView>

      <View style={[styles.footer, { paddingBottom: insets.bottom + 12, backgroundColor: t.colors.background, borderTopColor: t.colors.border }]}>
        <IconButton
          icon={ChevronLeft}
          size={52}
          label={tr('common.back')}
          onPress={() => {
            setDir(-1);
            setIndex((i) => Math.max(0, i - 1));
          }}
          style={{ opacity: index === 0 ? 0.35 : 1 }}
        />
        <View style={{ flex: 1 }}>
          {isLast ? (
            <Button
              title={submit.isPending ? tr('quiz.submitting') : tr('quiz.check')}
              loading={submit.isPending}
              disabled={!allAnswered}
              onPress={doSubmit}
              size="lg"
              fullWidth
              testID="quiz-submit"
            />
          ) : (
            <Button
              title={tr('common.next')}
              disabled={!current || !answered(current)}
              onPress={() => {
                setDir(1);
                setIndex((i) => Math.min(questions.length - 1, i + 1));
              }}
              size="lg"
              fullWidth
              testID="quiz-next"
            />
          )}
        </View>
      </View>
      {isLast && !allAnswered && (
        <Text variant="caption" tone="tertiary" align="center" style={{ position: 'absolute', bottom: insets.bottom + 84, left: 0, right: 0 }}>
          {tr('quiz.unanswered')}
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  top: { flexDirection: 'row', alignItems: 'center', gap: 14, paddingHorizontal: 16, paddingBottom: 10 },
  option: { flexDirection: 'row', alignItems: 'center', gap: 14, padding: 16, borderWidth: 1.25, minHeight: 60 },
  radio: { width: 22, height: 22, borderRadius: 11, borderWidth: 2, alignItems: 'center', justifyContent: 'center' },
  radioDot: { width: 10, height: 10, borderRadius: 5 },
  box: { width: 22, height: 22, borderRadius: 6, borderWidth: 2, alignItems: 'center', justifyContent: 'center' },
  explain: { padding: 14, gap: 6 },
  footer: { position: 'absolute', left: 0, right: 0, bottom: 0, flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingTop: 12, borderTopWidth: StyleSheet.hairlineWidth },
});
