import * as AppleAuthentication from 'expo-apple-authentication';
import { Mail } from 'lucide-react-native';
import { Platform, StyleSheet, View } from 'react-native';
import Svg, { Path } from 'react-native-svg';

import { PressableScale } from '@/components/ui/PressableScale';
import { Text } from '@/components/ui/Text';
import { useTheme } from '@/theme/ThemeProvider';

function GoogleGlyph() {
  return (
    <Svg width={18} height={18} viewBox="0 0 48 48" accessibilityElementsHidden>
      <Path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.7 29.2 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34 6.1 29.3 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.3-.1-2.4-.4-3.5z" />
      <Path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 15.1 19 12 24 12c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34 6.1 29.3 4 24 4 16.3 4 9.7 8.3 6.3 14.7z" />
      <Path fill="#4CAF50" d="M24 44c5.2 0 9.9-2 13.4-5.2l-6.2-5.2C29.2 35.1 26.7 36 24 36c-5.2 0-9.6-3.3-11.3-7.9l-6.5 5C9.5 39.6 16.2 44 24 44z" />
      <Path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.2-2.2 4.2-4.1 5.6l6.2 5.2C37 39.2 44 34 44 24c0-1.3-.1-2.4-.4-3.5z" />
    </Svg>
  );
}

function AppleGlyph({ color }: { color: string }) {
  return (
    <Svg width={18} height={18} viewBox="0 0 24 24" accessibilityElementsHidden>
      <Path fill={color} d="M16.37 12.6c-.02-2.1 1.72-3.11 1.8-3.16-.98-1.43-2.5-1.63-3.04-1.65-1.3-.13-2.53.76-3.19.76-.66 0-1.67-.74-2.75-.72-1.41.02-2.72.82-3.45 2.09-1.47 2.55-.38 6.33 1.06 8.4.7 1.01 1.53 2.15 2.62 2.11 1.05-.04 1.45-.68 2.72-.68 1.27 0 1.63.68 2.74.66 1.13-.02 1.85-1.03 2.54-2.05.8-1.17 1.13-2.3 1.15-2.36-.03-.01-2.2-.84-2.22-3.4zM14.3 6.43c.58-.7.97-1.68.86-2.65-.83.03-1.84.55-2.44 1.25-.53.62-1 1.61-.88 2.56.93.07 1.88-.47 2.46-1.16z" />
    </Svg>
  );
}

function ProviderButton({ label, icon, onPress, testID }: { label: string; icon: React.ReactNode; onPress: () => void; testID?: string }) {
  const t = useTheme();
  return (
    <PressableScale onPress={onPress} testID={testID} accessibilityLabel={label} style={[styles.btn, { backgroundColor: t.colors.surface, borderColor: t.colors.borderStrong, borderRadius: t.radii.md }]}>
      <View style={styles.icon}>{icon}</View>
      <Text variant="headline">{label}</Text>
      <View style={styles.icon} />
    </PressableScale>
  );
}

export function AppleButton({ label, onPress }: { label: string; onPress: () => void }) {
  const t = useTheme();
  if (Platform.OS === 'ios') {
    // Apple's own button — required styling for Sign in with Apple on iOS.
    return (
      <AppleAuthentication.AppleAuthenticationButton
        buttonType={AppleAuthentication.AppleAuthenticationButtonType.CONTINUE}
        buttonStyle={t.isDark ? AppleAuthentication.AppleAuthenticationButtonStyle.WHITE : AppleAuthentication.AppleAuthenticationButtonStyle.BLACK}
        cornerRadius={t.radii.md}
        style={{ width: '100%', height: 52 }}
        onPress={onPress}
      />
    );
  }
  return <ProviderButton label={label} icon={<AppleGlyph color={t.colors.text} />} onPress={onPress} testID="auth-apple" />;
}

export function GoogleButton({ label, onPress }: { label: string; onPress: () => void }) {
  return <ProviderButton label={label} icon={<GoogleGlyph />} onPress={onPress} testID="auth-google" />;
}

export function EmailButton({ label, onPress }: { label: string; onPress: () => void }) {
  const t = useTheme();
  return <ProviderButton label={label} icon={<Mail size={18} color={t.colors.text} />} onPress={onPress} testID="auth-email" />;
}

const styles = StyleSheet.create({
  btn: { height: 52, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: 18, borderWidth: 1, width: '100%' },
  icon: { width: 22, alignItems: 'center' },
});
