import { Search, SlidersHorizontal, X } from 'lucide-react-native';
import { useEffect, useMemo, useState } from 'react';
import { FlatList, StyleSheet, TextInput, useWindowDimensions, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { CategoryTile, CourseRow } from '@/components/course/CourseCards';
import { DemoBadge } from '@/components/feedback/Banners';
import { TAB_BAR_HEIGHT } from '@/components/navigation/TabBar';
import { Button } from '@/components/ui/Button';
import { iconFor } from '@/components/ui/Icon';
import { EmptyState, ErrorState, IconButton, Segmented } from '@/components/ui/layout';
import { PressableScale } from '@/components/ui/PressableScale';
import { Chip, Skeleton } from '@/components/ui/primitives';
import { Sheet } from '@/components/ui/Sheet';
import { Text } from '@/components/ui/Text';
import { useCategories, useEnrollments, useSearchCourses } from '@/data/hooks';
import { DIFFICULTY_LEVELS, type AccessTier, type CourseFilters, type DifficultyLevel } from '@/data/types';
import { errorMessageKey } from '@/lib/errors';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

const TRENDING = ['HTML', 'Python', 'Blender', 'Prompt', 'Video', 'Design'];

export default function Explore() {
  const t = useTheme();
  const { t: tr, tp } = useI18n();
  const insets = useSafeAreaInsets();
  const { width } = useWindowDimensions();
  const [input, setInput] = useState('');
  const [query, setQuery] = useState('');
  const [category, setCategory] = useState<string | null>(null);
  const [levels, setLevels] = useState<DifficultyLevel[]>([]);
  const [tier, setTier] = useState<AccessTier | null>(null);
  const [sort, setSort] = useState<NonNullable<CourseFilters['sort']>>('relevance');
  const [filtersOpen, setFiltersOpen] = useState(false);

  // Debounce typing so we don't query on every keystroke.
  useEffect(() => {
    const id = setTimeout(() => setQuery(input.trim()), 280);
    return () => clearTimeout(id);
  }, [input]);

  const filters = useMemo<CourseFilters>(() => ({ query, categorySlug: category, levels, tier, sort }), [query, category, levels, tier, sort]);
  const results = useSearchCourses(filters);
  const categories = useCategories();
  const enrollments = useEnrollments();
  const activeFilters = levels.length + (tier ? 1 : 0) + (sort !== 'relevance' ? 1 : 0);
  const browsing = !query && !category && !activeFilters;
  const tileWidth = Math.min((Math.min(width, 760) - t.spacing.gutter * 2 - 12) / 2, 340);

  const header = (
    <View style={{ gap: 16, paddingBottom: 8 }}>
      <View style={[styles.titleRow, { paddingHorizontal: t.spacing.gutter }]}>
        <Text variant="display" accessibilityRole="header">
          {tr('explore.title')}
        </Text>
        <DemoBadge />
      </View>
      <View style={[styles.searchRow, { paddingHorizontal: t.spacing.gutter }]}>
        <View style={[styles.search, { backgroundColor: t.colors.surface, borderColor: t.colors.border, borderRadius: t.radii.md }]}>
          <Search size={18} color={t.colors.textTertiary} />
          <TextInput
            value={input}
            onChangeText={setInput}
            placeholder={tr('explore.searchPlaceholder')}
            placeholderTextColor={t.colors.textTertiary}
            selectionColor={t.colors.accent}
            returnKeyType="search"
            autoCorrect={false}
            accessibilityLabel={tr('explore.searchPlaceholder')}
            style={[t.typography.body, { flex: 1, color: t.colors.text, height: 48 }]}
            testID="explore-search"
          />
          {!!input && (
            <PressableScale onPress={() => setInput('')} hitSlop={10} accessibilityLabel={tr('explore.clear')}>
              <X size={18} color={t.colors.textTertiary} />
            </PressableScale>
          )}
        </View>
        <View>
          <IconButton icon={SlidersHorizontal} label={tr('explore.filters')} size={48} active={activeFilters > 0} onPress={() => setFiltersOpen(true)} />
          {activeFilters > 0 && (
            <View style={[styles.count, { backgroundColor: t.colors.accent }]}>
              <Text variant="caption" color={t.colors.onAccent} style={{ fontSize: 10 }}>
                {activeFilters}
              </Text>
            </View>
          )}
        </View>
      </View>
      <FlatList
        horizontal
        data={categories.data ?? []}
        keyExtractor={(c) => c.id}
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ paddingHorizontal: t.spacing.gutter, gap: 8 }}
        renderItem={({ item }) => (
          <Chip label={item.title} icon={iconFor(item.icon)} color={item.color ?? undefined} selected={category === item.slug} onPress={() => setCategory(category === item.slug ? null : item.slug)} />
        )}
      />
      {browsing && (
        <View style={{ gap: 12, paddingHorizontal: t.spacing.gutter, marginTop: 8 }}>
          <Text variant="overline" tone="tertiary">
            {tr('explore.trending')}
          </Text>
          <View style={styles.trending}>
            {TRENDING.map((q) => (
              <PressableScale key={q} onPress={() => setInput(q)} style={[styles.trend, { borderColor: t.colors.border, borderRadius: t.radii.pill }]} haptic="select">
                <Text variant="subhead" tone="secondary">
                  {q}
                </Text>
              </PressableScale>
            ))}
          </View>
        </View>
      )}
      {browsing && (
        <View style={{ gap: 12, marginTop: 12 }}>
          <Text variant="title3" style={{ paddingHorizontal: t.spacing.gutter }}>
            {tr('explore.categories')}
          </Text>
          <View style={[styles.grid, { paddingHorizontal: t.spacing.gutter }]}>
            {(categories.data ?? []).map((c) => (
              <CategoryTile key={c.id} category={c} width={tileWidth} />
            ))}
          </View>
        </View>
      )}
      <View style={[styles.resultsHeader, { paddingHorizontal: t.spacing.gutter }]}>
        <Text variant="title3">{browsing ? tr('explore.allCourses') : tp('explore.results', results.data?.length ?? 0)}</Text>
        {!browsing && (
          <PressableScale
            onPress={() => {
              setInput('');
              setCategory(null);
              setLevels([]);
              setTier(null);
              setSort('relevance');
            }}
            haptic="select">
            <Text variant="subhead" tone="accent">
              {tr('explore.clear')}
            </Text>
          </PressableScale>
        )}
      </View>
    </View>
  );

  return (
    <View style={[styles.flex, { backgroundColor: t.colors.background }]}>
      <FlatList
        data={results.data ?? []}
        keyExtractor={(c) => c.id}
        keyboardDismissMode="on-drag"
        keyboardShouldPersistTaps="handled"
        ListHeaderComponent={header}
        contentContainerStyle={{ paddingTop: insets.top + 16, paddingBottom: insets.bottom + TAB_BAR_HEIGHT + 32, gap: 16 }}
        renderItem={({ item, index }) => (
          <View style={{ paddingHorizontal: t.spacing.gutter }}>
            <CourseRow course={item} index={index} enrollment={enrollments.data?.find((e) => e.course_id === item.id)} />
          </View>
        )}
        ListEmptyComponent={
          results.isLoading ? (
            <View style={{ gap: 16, paddingHorizontal: t.spacing.gutter }}>
              {[0, 1, 2].map((i) => (
                <View key={i} style={{ flexDirection: 'row', gap: 14 }}>
                  <Skeleton width={92} height={92} radius={14} />
                  <View style={{ flex: 1, gap: 8, justifyContent: 'center' }}>
                    <Skeleton width="30%" height={10} />
                    <Skeleton width="80%" height={16} />
                    <Skeleton width="50%" height={12} />
                  </View>
                </View>
              ))}
            </View>
          ) : results.error ? (
            <ErrorState message={tr(errorMessageKey(results.error))} onRetry={() => results.refetch()} />
          ) : (
            <EmptyState icon={Search} title={tr('explore.noResults')} body={tr('explore.noResultsBody')} />
          )
        }
      />

      <Sheet visible={filtersOpen} onClose={() => setFiltersOpen(false)} title={tr('explore.filters')}>
        <View style={{ paddingHorizontal: 20, gap: 22 }}>
          <View style={{ gap: 10 }}>
            <Text variant="overline" tone="tertiary">
              {tr('explore.level')}
            </Text>
            <View style={styles.trending}>
              {DIFFICULTY_LEVELS.map((l) => (
                <Chip key={l} label={tr(`levels.${l}`)} selected={levels.includes(l)} onPress={() => setLevels(levels.includes(l) ? levels.filter((x) => x !== l) : [...levels, l])} />
              ))}
            </View>
          </View>
          <View style={{ gap: 10 }}>
            <Text variant="overline" tone="tertiary">
              {tr('explore.access')}
            </Text>
            <Segmented
              value={tier ?? 'any'}
              onChange={(v) => setTier(v === 'any' ? null : (v as AccessTier))}
              options={[
                { value: 'any', label: tr('explore.any') },
                { value: 'free', label: tr('common.free') },
                { value: 'premium', label: tr('common.premium') },
              ]}
            />
          </View>
          <View style={{ gap: 10 }}>
            <Text variant="overline" tone="tertiary">
              {tr('explore.sort')}
            </Text>
            <Segmented
              value={sort}
              onChange={setSort}
              options={[
                { value: 'relevance', label: tr('explore.sortRelevance') },
                { value: 'popular', label: tr('explore.sortPopular') },
                { value: 'newest', label: tr('explore.sortNewest') },
              ]}
            />
          </View>
          <Button title={tr('explore.apply')} onPress={() => setFiltersOpen(false)} fullWidth size="lg" />
        </View>
      </Sheet>
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  titleRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  searchRow: { flexDirection: 'row', gap: 10, alignItems: 'center' },
  search: { flex: 1, flexDirection: 'row', alignItems: 'center', gap: 10, paddingHorizontal: 14, borderWidth: StyleSheet.hairlineWidth },
  count: { position: 'absolute', top: -2, right: -2, minWidth: 18, height: 18, borderRadius: 9, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 4 },
  trending: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  trend: { paddingHorizontal: 14, height: 34, justifyContent: 'center', borderWidth: StyleSheet.hairlineWidth },
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: 12 },
  resultsHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: 16 },
});

