import type { Session } from '@supabase/supabase-js';
import * as AppleAuthentication from 'expo-apple-authentication';
import * as Crypto from 'expo-crypto';
import * as Linking from 'expo-linking';
import * as WebBrowser from 'expo-web-browser';
import { Platform } from 'react-native';
import { create } from 'zustand';

import { isDemoMode } from '@/lib/env';
import { AppError } from '@/lib/errors';
import { queryClient } from '@/lib/queryClient';
import { getSupabase } from '@/lib/supabase';

import { DEMO_USER_ID, resetDemoState } from './demo/demoApi';
import type { AppRole } from './types';

WebBrowser.maybeCompleteAuthSession();

export type AuthStatus = 'loading' | 'signedOut' | 'signedIn';

export interface AuthUser {
  id: string;
  email: string | null;
  isDemo: boolean;
}

interface AuthState {
  status: AuthStatus;
  user: AuthUser | null;
  roles: AppRole[];
  init: () => () => void;
}

export const useAuth = create<AuthState>((set) => ({
  status: 'loading',
  user: null,
  roles: [],
  init: () => {
    if (isDemoMode) {
      // Demo learner is always "signed in" locally; no account exists anywhere.
      set({ status: 'signedIn', user: { id: DEMO_USER_ID, email: null, isDemo: true }, roles: ['student'] });
      return () => {};
    }
    const sb = getSupabase();
    const apply = async (session: Session | null) => {
      if (!session) {
        set({ status: 'signedOut', user: null, roles: [] });
        return;
      }
      set({ status: 'signedIn', user: { id: session.user.id, email: session.user.email ?? null, isDemo: false } });
      const { data } = await sb.from('user_roles').select('role');
      set({ roles: (data ?? []).map((r: { role: AppRole }) => r.role) });
    };
    sb.auth.getSession().then(({ data }) => apply(data.session));
    const { data: sub } = sb.auth.onAuthStateChange((event, session) => {
      if (event === 'SIGNED_OUT') queryClient.clear();
      if (event === 'SIGNED_IN' || event === 'USER_UPDATED') queryClient.invalidateQueries();
      void apply(session);
    });
    return () => sub.subscription.unsubscribe();
  },
}));

const redirectUrl = () => (Platform.OS === 'web' ? `${window.location.origin}/auth-callback` : Linking.createURL('auth-callback'));

function mapAuthError(message: string): AppError {
  if (/invalid login credentials/i.test(message)) return new AppError('invalid_credentials', message);
  if (/already registered|already exists/i.test(message)) return new AppError('email_taken', message);
  if (/rate limit|too many/i.test(message)) return new AppError('rate_limited', message);
  if (/password/i.test(message)) return new AppError('weak_password', message);
  return new AppError('auth_generic', message);
}

export const authActions = {
  async signInWithPassword(email: string, password: string) {
    const { error } = await getSupabase().auth.signInWithPassword({ email: email.trim(), password });
    if (error) throw mapAuthError(error.message);
  },

  /** Returns true when the project requires email confirmation before first sign-in. */
  async signUp(name: string, email: string, password: string, locale: string) {
    const { data, error } = await getSupabase().auth.signUp({
      email: email.trim(),
      password,
      options: { data: { display_name: name.trim(), locale }, emailRedirectTo: redirectUrl() },
    });
    if (error) throw mapAuthError(error.message);
    return !data.session;
  },

  async sendMagicLink(email: string) {
    const { error } = await getSupabase().auth.signInWithOtp({ email: email.trim(), options: { emailRedirectTo: redirectUrl(), shouldCreateUser: true } });
    if (error) throw mapAuthError(error.message);
  },

  async sendPasswordReset(email: string) {
    const { error } = await getSupabase().auth.resetPasswordForEmail(email.trim(), { redirectTo: redirectUrl() });
    if (error) throw mapAuthError(error.message);
  },

  /** Google (and any OAuth provider) through the system browser with PKCE. */
  async signInWithGoogle() {
    const sb = getSupabase();
    if (Platform.OS === 'web') {
      const { error } = await sb.auth.signInWithOAuth({ provider: 'google', options: { redirectTo: redirectUrl() } });
      if (error) throw mapAuthError(error.message);
      return;
    }
    const { data, error } = await sb.auth.signInWithOAuth({ provider: 'google', options: { redirectTo: redirectUrl(), skipBrowserRedirect: true } });
    if (error || !data.url) throw mapAuthError(error?.message ?? 'no_url');
    const result = await WebBrowser.openAuthSessionAsync(data.url, redirectUrl());
    if (result.type !== 'success') throw new AppError('cancelled');
    await authActions.completeFromUrl(result.url);
  },

  /** Native Sign in with Apple on iOS; OAuth web flow elsewhere. */
  async signInWithApple() {
    const sb = getSupabase();
    if (Platform.OS !== 'ios') {
      if (Platform.OS === 'web') {
        const { error } = await sb.auth.signInWithOAuth({ provider: 'apple', options: { redirectTo: redirectUrl() } });
        if (error) throw mapAuthError(error.message);
        return;
      }
      const { data, error } = await sb.auth.signInWithOAuth({ provider: 'apple', options: { redirectTo: redirectUrl(), skipBrowserRedirect: true } });
      if (error || !data.url) throw mapAuthError(error?.message ?? 'no_url');
      const result = await WebBrowser.openAuthSessionAsync(data.url, redirectUrl());
      if (result.type !== 'success') throw new AppError('cancelled');
      await authActions.completeFromUrl(result.url);
      return;
    }
    if (!(await AppleAuthentication.isAvailableAsync())) throw new AppError('provider_unavailable');
    const rawNonce = Array.from(Crypto.getRandomBytes(16), (b) => b.toString(16).padStart(2, '0')).join('');
    const hashedNonce = await Crypto.digestStringAsync(Crypto.CryptoDigestAlgorithm.SHA256, rawNonce);
    try {
      const credential = await AppleAuthentication.signInAsync({
        requestedScopes: [AppleAuthentication.AppleAuthenticationScope.FULL_NAME, AppleAuthentication.AppleAuthenticationScope.EMAIL],
        nonce: hashedNonce,
      });
      if (!credential.identityToken) throw new AppError('auth_generic');
      const { error } = await sb.auth.signInWithIdToken({ provider: 'apple', token: credential.identityToken, nonce: rawNonce });
      if (error) throw mapAuthError(error.message);
      // Apple only shares the name on the very first authorisation — store it then.
      const fullName = [credential.fullName?.givenName, credential.fullName?.familyName].filter(Boolean).join(' ');
      if (fullName) await sb.auth.updateUser({ data: { full_name: fullName } });
    } catch (e) {
      if (e && typeof e === 'object' && 'code' in e && (e as { code: string }).code === 'ERR_REQUEST_CANCELED') throw new AppError('cancelled');
      throw e;
    }
  },

  /** Completes PKCE / magic-link / recovery redirects (mahorat://auth-callback?code=…). */
  async completeFromUrl(url: string) {
    const parsed = Linking.parse(url);
    const params = { ...(parsed.queryParams ?? {}) } as Record<string, string | undefined>;
    const hash = url.includes('#') ? new URLSearchParams(url.split('#')[1]) : null;
    const errorDescription = params.error_description ?? hash?.get('error_description');
    if (errorDescription) throw new AppError('auth_generic', String(errorDescription));
    const sb = getSupabase();
    if (params.code) {
      const { error } = await sb.auth.exchangeCodeForSession(String(params.code));
      if (error) throw mapAuthError(error.message);
      return;
    }
    const access = hash?.get('access_token');
    const refresh = hash?.get('refresh_token');
    if (access && refresh) {
      const { error } = await sb.auth.setSession({ access_token: access, refresh_token: refresh });
      if (error) throw mapAuthError(error.message);
    }
  },

  async signOut() {
    if (isDemoMode) return;
    await getSupabase().auth.signOut();
  },

  /** Required by App Store Review Guideline 5.1.1(v): in-app account deletion. */
  async deleteAccount() {
    if (isDemoMode) {
      await resetDemoState();
      queryClient.clear();
      return;
    }
    const sb = getSupabase();
    const { error } = await sb.functions.invoke('delete-account', { method: 'POST' });
    if (error) throw new AppError('generic', error.message);
    await sb.auth.signOut();
    queryClient.clear();
  },
};

export const authErrorKey = (code: string) =>
  (
    {
      invalid_credentials: 'auth.errors.invalidCredentials',
      email_taken: 'auth.errors.emailTaken',
      rate_limited: 'auth.errors.rateLimited',
      weak_password: 'auth.errors.weakPassword',
      cancelled: 'auth.errors.cancelled',
      provider_unavailable: 'auth.errors.providerUnavailable',
    } as const
  )[code] ?? ('auth.errors.generic' as const);
