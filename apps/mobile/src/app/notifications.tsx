import { router } from 'expo-router';
import { Award, Bell, BookOpen, Megaphone, Sparkles } from 'lucide-react-native';
import { useEffect } from 'react';
import { StyleSheet, View } from 'react-native';

import { EmptyState, ScrollScreen } from '@/components/ui/layout';
import { PressableScale } from '@/components/ui/PressableScale';
import { Card, Skeleton } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { useMarkNotificationsRead, useNotifications } from '@/data/hooks';
import type { AppNotification } from '@/data/types';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

const icons = { achievement: Sparkles, course: Award, announcement: Megaphone, reminder: Bell, system: BookOpen } as const;

export default function Notifications() {
  const t = useTheme();
  const { t: tr, relativeTime } = useI18n();
  const list = useNotifications();
  const markRead = useMarkNotificationsRead();
  const unread = list.data?.filter((n) => !n.read) ?? [];

  // Opening the inbox marks everything as read after a short delay (so the dots are seen).
  useEffect(() => {
    if (!unread.length) return;
    const id = setTimeout(() => markRead.mutate(unread.map((n) => n.id)), 1500);
    return () => clearTimeout(id);
  }, [unread.length]); // eslint-disable-line react-hooks/exhaustive-deps

  const open = (n: AppNotification) => {
    const d = n.data as { certificate_id?: string; course_slug?: string };
    if (d.certificate_id) router.push({ pathname: '/certificates/[id]', params: { id: d.certificate_id } });
    else if (n.type === 'achievement') router.push('/achievements');
  };

  return (
    <ScrollScreen back title={tr('notifications.title')} onRefresh={() => list.refetch()} refreshing={list.isRefetching}>
      <View style={{ paddingHorizontal: t.spacing.gutter, gap: 10 }}>
        {list.isLoading && [0, 1, 2].map((i) => <Skeleton key={i} height={72} radius={t.radii.lg} />)}
        {list.data?.length === 0 && <EmptyState icon={Bell} title={tr('notifications.empty')} />}
        {list.data?.map((n) => {
          const Icon = icons[n.type] ?? Bell;
          return (
            <PressableScale key={n.id} onPress={() => open(n)} scaleTo={0.985}>
              <Card style={styles.row}>
                <View style={[styles.icon, { backgroundColor: t.colors.accentSoft }]}>
                  <Icon size={18} color={t.colors.accent} />
                </View>
                <View style={{ flex: 1, gap: 2 }}>
                  <Text variant="headline">{n.title}</Text>
                  {n.body && (
                    <Text variant="footnote" tone="secondary">
                      {n.body}
                    </Text>
                  )}
                  <Text variant="caption" tone="tertiary">
                    {relativeTime(n.created_at)}
                  </Text>
                </View>
                {!n.read && <View style={[styles.dot, { backgroundColor: t.colors.accent }]} />}
              </Card>
            </PressableScale>
          );
        })}
      </View>
    </ScrollScreen>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', gap: 12, alignItems: 'flex-start' },
  icon: { width: 38, height: 38, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  dot: { width: 9, height: 9, borderRadius: 5, marginTop: 6 },
});
