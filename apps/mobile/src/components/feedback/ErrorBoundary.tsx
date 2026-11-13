import type { ErrorBoundaryProps } from 'expo-router';
import { RefreshCw } from 'lucide-react-native';
import { StyleSheet, View } from 'react-native';

import { colors, typography } from '@/theme/tokens';
import { Text as RNText, Pressable } from 'react-native';

/**
 * Route-level error boundary. Deliberately independent of providers (it can render
 * when they failed) — uses raw tokens instead of the theme context.
 */
export function ErrorBoundary({ error, retry }: ErrorBoundaryProps) {
  const c = colors.dark;
  return (
    <View style={[styles.root, { backgroundColor: c.background }]}>
      <RNText style={[typography.title2, { color: c.text, textAlign: 'center' }]}>Something went wrong</RNText>
      <RNText style={[typography.callout, { color: c.textSecondary, textAlign: 'center' }]}>
        {__DEV__ ? error.message : 'Please try again. If the problem continues, restart the app.'}
      </RNText>
      <Pressable onPress={retry} accessibilityRole="button" style={[styles.button, { backgroundColor: c.surfaceHigh }]}>
        <RefreshCw size={16} color={c.text} />
        <RNText style={[typography.headline, { color: c.text }]}>Try again</RNText>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 14, padding: 32 },
  button: { flexDirection: 'row', alignItems: 'center', gap: 8, paddingHorizontal: 20, height: 48, borderRadius: 14, marginTop: 8 },
});
