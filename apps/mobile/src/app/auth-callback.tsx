import * as Linking from 'expo-linking';
import { router } from 'expo-router';
import { useEffect, useState } from 'react';
import { ActivityIndicator, View } from 'react-native';

import { Button } from '@/components/ui/Button';
import { Text } from '@/components/ui/Text';
import { authActions } from '@/data/auth';
import { isDemoMode } from '@/lib/env';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';

/** Landing route for email confirmation, magic links, OAuth and password recovery. */
export default function AuthCallback() {
  const t = useTheme();
  const { t: tr } = useI18n();
  const url = Linking.useLinkingURL();
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    if (isDemoMode) return router.replace('/');
    if (!url) return;
    authActions
      .completeFromUrl(url)
      .then(() => router.replace('/'))
      .catch(() => setFailed(true));
  }, [url]);

  return (
    <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', gap: 16, backgroundColor: t.colors.background, padding: 24 }}>
      {failed ? (
        <>
          <Text variant="callout" tone="secondary" align="center">
            {tr('auth.errors.generic')}
          </Text>
          <Button title={tr('common.continue')} onPress={() => router.replace('/auth')} />
        </>
      ) : (
        <ActivityIndicator color={t.colors.accent} />
      )}
    </View>
  );
}
