import { useLocalSearchParams } from 'expo-router';
import { BookOpen } from 'lucide-react-native';
import { useState } from 'react';
import { FlatList, StyleSheet, View } from 'react-native';

import { CourseRow } from '@/components/course/CourseCards';
import { DynamicIcon } from '@/components/ui/Icon';
import { EmptyState, ErrorState, ScrollScreen } from '@/components/ui/layout';
import { Chip, Skeleton } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { useCategories, useEnrollments, useSearchCourses } from '@/data/hooks';
import { errorMessageKey } from '@/lib/errors';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';
import { withAlpha } from '@/theme/tokens';

export default function CategoryScreen() {
  const { slug } = useLocalSearchParams<{ slug: string }>();
  const t = useTheme();
  const { t: tr, tp } = useI18n();
  const categories = useCategories();
  const [sub, setSub] = useState<string | null>(null);
  const category = categories.data?.find((c) => c.slug === slug) ?? categories.data?.flatMap((c) => c.children ?? []).find((c) => c.slug === slug);
  const courses = useSearchCourses({ categorySlug: sub ?? slug, sort: 'popular' });
  const enrollments = useEnrollments();
  const color = category?.color ?? t.colors.accent;

  return (
    <ScrollScreen back title={category?.title ?? ''} onRefresh={() => courses.refetch()} refreshing={courses.isRefetching}>
      <View style={{ paddingHorizontal: t.spacing.gutter, gap: 14 }}>
        {category && (
          <View style={[styles.hero, { backgroundColor: withAlpha(color, t.isDark ? 0.12 : 0.08), borderRadius: t.radii.xl, borderColor: withAlpha(color, 0.3) }]}>
            <View style={[styles.icon, { backgroundColor: withAlpha(color, 0.2) }]}>
              <DynamicIcon name={category.icon} size={26} color={color} />
            </View>
            {category.subtitle && <Text variant="title3">{category.subtitle}</Text>}
            {category.description && (
              <Text variant="callout" tone="secondary">
                {category.description}
              </Text>
            )}
          </View>
        )}
      </View>
      {!!category?.children?.length && (
        <View style={{ gap: 10 }}>
          <Text variant="overline" tone="tertiary" style={{ paddingHorizontal: t.spacing.gutter }}>
            {tr('explore.topics')}
          </Text>
          <FlatList
            horizontal
            data={category.children}
            keyExtractor={(c) => c.id}
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ paddingHorizontal: t.spacing.gutter, gap: 8 }}
            renderItem={({ item }) => <Chip label={item.title} color={color} selected={sub === item.slug} onPress={() => setSub(sub === item.slug ? null : item.slug)} />}
          />
        </View>
      )}
      <View style={{ paddingHorizontal: t.spacing.gutter, gap: 16 }}>
        <Text variant="title3">{courses.data ? tp('explore.results', courses.data.length) : tr('explore.coursesInCategory')}</Text>
        {courses.isLoading && [0, 1].map((i) => <Skeleton key={i} height={92} radius={14} />)}
        {courses.error && <ErrorState message={tr(errorMessageKey(courses.error))} onRetry={() => courses.refetch()} />}
        {courses.data?.length === 0 && <EmptyState icon={BookOpen} title={tr('explore.noResults')} body={tr('explore.comingSoon')} />}
        {courses.data?.map((c, i) => (
          <CourseRow key={c.id} course={c} index={i} enrollment={enrollments.data?.find((e) => e.course_id === c.id)} />
        ))}
      </View>
    </ScrollScreen>
  );
}

const styles = StyleSheet.create({
  hero: { padding: 20, gap: 10, borderWidth: StyleSheet.hairlineWidth },
  icon: { width: 52, height: 52, borderRadius: 16, alignItems: 'center', justifyContent: 'center' },
});
