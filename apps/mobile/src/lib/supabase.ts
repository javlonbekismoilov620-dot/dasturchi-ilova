import 'react-native-url-polyfill/auto';

import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { AppState, Platform } from 'react-native';

import { env, isDemoMode } from './env';
import { sessionStorage } from './secureSessionStorage';

let client: SupabaseClient | null = null;

export function getSupabase(): SupabaseClient {
  if (isDemoMode) throw new Error('Supabase is not configured (demo mode).');
  if (!client) {
    client = createClient(env.supabaseUrl, env.supabaseAnonKey, {
      auth: {
        storage: sessionStorage,
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: Platform.OS === 'web',
        flowType: 'pkce',
      },
      global: { headers: { 'x-client-info': `mahorat-mobile/${env.appVersion}` } },
    });
    // Only refresh tokens while the app is in the foreground (Supabase guidance for RN).
    if (Platform.OS !== 'web') {
      AppState.addEventListener('change', (state) => {
        if (state === 'active') client?.auth.startAutoRefresh();
        else client?.auth.stopAutoRefresh();
      });
    }
  }
  return client;
}
