import Constants from 'expo-constants';

/**
 * Public runtime configuration. EXPO_PUBLIC_* values are inlined at build time, so they
 * must be referenced statically. Only publishable values belong here — the Supabase
 * anon/publishable key is designed to be public; Row Level Security protects data.
 */
export const env = {
  supabaseUrl: process.env.EXPO_PUBLIC_SUPABASE_URL ?? '',
  supabaseAnonKey: process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? '',
  revenueCatAppleKey: process.env.EXPO_PUBLIC_REVENUECAT_APPLE_KEY ?? '',
  revenueCatGoogleKey: process.env.EXPO_PUBLIC_REVENUECAT_GOOGLE_KEY ?? '',
  appEnv: (Constants.expoConfig?.extra?.appEnv as string | undefined) ?? 'development',
  appVersion: Constants.expoConfig?.version ?? '1.0.0',
  scheme: 'mahorat',
};

/**
 * Demo mode: no backend configured. The app runs on bundled starter content stored on
 * the device and labels itself clearly as a demo. Production builds cannot be produced
 * without backend credentials (see app.config.ts), so demo mode never reaches the stores.
 */
export const isDemoMode = !env.supabaseUrl || !env.supabaseAnonKey;
