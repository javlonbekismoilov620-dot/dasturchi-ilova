import { router } from 'expo-router';
import { Lock, Mail, User } from 'lucide-react-native';
import { useState } from 'react';
import { KeyboardAvoidingView, Platform, ScrollView, StyleSheet, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Button } from '@/components/ui/Button';
import { BackButton, Segmented } from '@/components/ui/layout';
import { Card } from '@/components/ui/primitives';
import { Text } from '@/components/ui/Text';
import { TextField } from '@/components/ui/TextField';
import { authActions, authErrorKey } from '@/data/auth';
import { errorCode } from '@/lib/errors';
import { isStrongPassword, isValidEmail } from '@/lib/validation';
import { useI18n } from '@/i18n';
import { useTheme } from '@/theme/ThemeProvider';


export default function EmailAuth() {
  const t = useTheme();
  const { t: tr, locale } = useI18n();
  const insets = useSafeAreaInsets();
  const [mode, setMode] = useState<'signin' | 'signup'>('signin');
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [touched, setTouched] = useState(false);
  const [busy, setBusy] = useState<null | 'submit' | 'magic' | 'reset'>(null);
  const [error, setError] = useState<string | null>(null);
  const [info, setInfo] = useState<string | null>(null);

  const emailErr = touched && !isValidEmail(email) ? tr('auth.errors.invalidEmail') : null;
  const pwErr = touched && mode === 'signup' && !isStrongPassword(password) ? tr('auth.errors.weakPassword') : null;
  const nameErr = touched && mode === 'signup' && !name.trim() ? tr('auth.errors.nameRequired') : null;

  const handle = async (kind: 'submit' | 'magic' | 'reset') => {
    setTouched(true);
    setError(null);
    setInfo(null);
    if (!isValidEmail(email)) return;
    if (kind === 'submit' && (mode === 'signin' ? !password : !isStrongPassword(password) || !name.trim())) return;
    setBusy(kind);
    try {
      if (kind === 'magic') {
        await authActions.sendMagicLink(email);
        setInfo(tr('auth.magicLinkSent', { email: email.trim() }));
      } else if (kind === 'reset') {
        await authActions.sendPasswordReset(email);
        setInfo(tr('auth.resetSent', { email: email.trim() }));
      } else if (mode === 'signin') {
        await authActions.signInWithPassword(email, password);
        router.dismissAll();
      } else {
        const needsConfirm = await authActions.signUp(name, email, password, locale);
        if (needsConfirm) setInfo(tr('auth.checkEmail'));
        else router.dismissAll();
      }
    } catch (e) {
      setError(tr(authErrorKey(errorCode(e) === 'generic' ? ((e as { code?: string }).code ?? 'auth_generic') : errorCode(e))));
    } finally {
      setBusy(null);
    }
  };

  return (
    <KeyboardAvoidingView style={[styles.flex, { backgroundColor: t.colors.background }]} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <ScrollView contentContainerStyle={[styles.content, { paddingTop: insets.top + 8, paddingBottom: insets.bottom + 32 }]} keyboardShouldPersistTaps="handled">
        <BackButton />
        <Text variant="display" accessibilityRole="header" style={{ marginTop: 12 }}>
          {tr('auth.emailTitle')}
        </Text>
        <Segmented
          value={mode}
          onChange={(m) => {
            setMode(m);
            setError(null);
            setInfo(null);
          }}
          options={[
            { value: 'signin', label: tr('auth.signInTab') },
            { value: 'signup', label: tr('auth.signUpTab') },
          ]}
        />
        <View style={{ gap: 14 }}>
          {mode === 'signup' && <TextField label={tr('auth.name')} icon={User} value={name} onChangeText={setName} autoComplete="name" textContentType="name" error={nameErr} maxLength={80} testID="auth-name" />}
          <TextField label={tr('auth.email')} icon={Mail} value={email} onChangeText={setEmail} autoCapitalize="none" autoComplete="email" keyboardType="email-address" textContentType="emailAddress" error={emailErr} testID="auth-email-input" />
          <TextField
            label={tr('auth.password')}
            icon={Lock}
            value={password}
            onChangeText={setPassword}
            secureTextEntry
            secureToggle
            autoComplete={mode === 'signup' ? 'new-password' : 'current-password'}
            textContentType={mode === 'signup' ? 'newPassword' : 'password'}
            hint={mode === 'signup' ? tr('auth.passwordHint') : undefined}
            error={pwErr}
            onSubmitEditing={() => handle('submit')}
            testID="auth-password"
          />
        </View>
        {error && (
          <Card style={{ backgroundColor: t.colors.dangerSoft, borderColor: 'transparent' }}>
            <Text variant="subhead" tone="danger" accessibilityLiveRegion="assertive">
              {error}
            </Text>
          </Card>
        )}
        {info && (
          <Card style={{ backgroundColor: t.colors.successSoft, borderColor: 'transparent' }}>
            <Text variant="subhead" tone="success" accessibilityLiveRegion="polite">
              {info}
            </Text>
          </Card>
        )}
        <Button title={mode === 'signin' ? tr('auth.signInTab') : tr('auth.signUpTab')} size="lg" fullWidth loading={busy === 'submit'} onPress={() => handle('submit')} testID="auth-submit" />
        <View style={{ gap: 4 }}>
          <Button title={tr('auth.magicLink')} variant="ghost" loading={busy === 'magic'} onPress={() => handle('magic')} />
          {mode === 'signin' && <Button title={tr('auth.forgotPassword')} variant="ghost" loading={busy === 'reset'} onPress={() => handle('reset')} />}
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  content: { paddingHorizontal: 24, gap: 18, maxWidth: 520, width: '100%', alignSelf: 'center' },
});
