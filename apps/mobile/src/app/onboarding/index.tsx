import { router } from 'expo-router';
import { useRef, useState } from 'react';
import { FlatList, StyleSheet, useWindowDimensions, View } from 'react-native';
import Animated, { FadeIn, useAnimatedStyle, withSpring } from 'react-native-reanimated';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Aurora } from '@/components/brand/Aurora';
import { Logo } from '@/components/brand/Logo';
import { LadderVignette, PracticeVignette, ProgressVignette } from '@/components/onboarding/Vignettes';
import { Button } from '@/components/ui/Button';
import { Text } from '@/components/ui/Text';
import { isDemoMode } from '@/lib/env';
import { useI18n, type TKey } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

const SLIDES: { title: TKey; body: TKey; Vignette: typeof LadderVignette }[] = [
  { title: 'onboarding.slide1Title', body: 'onboarding.slide1Body', Vignette: LadderVignette },
  { title: 'onboarding.slide2Title', body: 'onboarding.slide2Body', Vignette: PracticeVignette },
  { title: 'onboarding.slide3Title', body: 'onboarding.slide3Body', Vignette: ProgressVignette },
];

function Dot({ active }: { active: boolean }) {
  const t = useTheme();
  const style = useAnimatedStyle(() => ({
    width: withSpring(active ? 24 : 8, t.motion.spring.snappy),
    opacity: withSpring(active ? 1 : 0.35),
  }));
  return <Animated.View style={[styles.dot, { backgroundColor: t.colors.accent }, style]} />;
}

export default function Welcome() {
  const t = useTheme();
  const { t: tr } = useI18n();
  const insets = useSafeAreaInsets();
  const { width } = useWindowDimensions();
  const [index, setIndex] = useState(0);
  const listRef = useRef<FlatList>(null);
  const onViewable = useRef(({ viewableItems }: { viewableItems: { index?: number | null }[] }) => {
    if (viewableItems[0]?.index != null) setIndex(viewableItems[0].index);
  }).current;
  const last = index === SLIDES.length - 1;

  return (
    <View style={[styles.flex, { backgroundColor: t.colors.background }]}>
      <Aurora hue={38} intensity={0.8} />
      <View style={[styles.header, { paddingTop: insets.top + 16 }]}>
        <Logo size={24} />
      </View>
      <FlatList
        ref={listRef}
        data={SLIDES}
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        keyExtractor={(s) => s.title}
        onViewableItemsChanged={onViewable}
        viewabilityConfig={{ itemVisiblePercentThreshold: 60 }}
        renderItem={({ item, index: i }) => (
          <View style={[styles.slide, { width }]}>
            <View style={styles.vignette}>
              <item.Vignette active={i === index} />
            </View>
            <Animated.View key={`${i}-${i === index}`} entering={i === index && !t.reduceMotion ? FadeIn.duration(500) : undefined} style={styles.copy}>
              <Text variant="hero" align="center" accessibilityRole="header">
                {tr(item.title)}
              </Text>
              <Text variant="callout" tone="secondary" align="center" style={{ maxWidth: 340 }}>
                {tr(item.body)}
              </Text>
            </Animated.View>
          </View>
        )}
      />
      <View style={[styles.footer, { paddingBottom: insets.bottom + 20 }]}>
        <View style={styles.dots}>
          {SLIDES.map((s, i) => (
            <Dot key={s.title} active={i === index} />
          ))}
        </View>
        <Button
          testID="welcome-next"
          title={last ? tr('onboarding.getStarted') : tr('common.next')}
          size="lg"
          fullWidth
          onPress={() => (last ? router.push('/onboarding/interests') : listRef.current?.scrollToIndex({ index: index + 1, animated: !t.reduceMotion }))}
        />
        {!isDemoMode && <Button title={tr('onboarding.haveAccount')} variant="ghost" onPress={() => router.push('/auth')} fullWidth />}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  header: { alignItems: 'center', paddingBottom: 8 },
  slide: { flex: 1, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 28, gap: 36 },
  vignette: { height: 280, alignItems: 'center', justifyContent: 'center' },
  copy: { gap: 14, alignItems: 'center' },
  footer: { paddingHorizontal: 24, gap: 10, width: '100%', maxWidth: 560, alignSelf: 'center' },
  dots: { flexDirection: 'row', gap: 6, alignSelf: 'center', marginBottom: 12 },
  dot: { height: 8, borderRadius: 4 },
});
