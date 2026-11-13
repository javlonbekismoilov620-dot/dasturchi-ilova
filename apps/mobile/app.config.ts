import type { ConfigContext, ExpoConfig } from 'expo/config';

/**
 * Environment-aware Expo configuration.
 *
 *   APP_ENV=development  → "Mahorat Dev", separate bundle id, demo mode allowed
 *   APP_ENV=preview      → internal testing builds (TestFlight / Play internal track)
 *   APP_ENV=production   → store builds; refuses to build without backend credentials
 *
 * Public runtime values come from EXPO_PUBLIC_* variables (see .env.example).
 * Never put secrets here: everything in this file ships inside the app binary.
 */
const APP_ENV = (process.env.APP_ENV ?? 'development') as 'development' | 'preview' | 'production';
const IS_PROD = APP_ENV === 'production';

const BUNDLE_ID = 'uz.mahorat.app';
const SCHEME = 'mahorat';
const INK = '#08090C';
const PAPER = '#F7F5F1';

if (IS_PROD) {
  const missing = ['EXPO_PUBLIC_SUPABASE_URL', 'EXPO_PUBLIC_SUPABASE_ANON_KEY'].filter((k) => !process.env[k]);
  if (missing.length) {
    throw new Error(`Production builds require ${missing.join(', ')}. Demo mode can never ship to the stores.`);
  }
}

const suffix = APP_ENV === 'production' ? '' : APP_ENV === 'preview' ? '.preview' : '.dev';
const easProjectId = process.env.EAS_PROJECT_ID;

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: APP_ENV === 'production' ? 'Mahorat' : APP_ENV === 'preview' ? 'Mahorat Preview' : 'Mahorat Dev',
  slug: 'mahorat',
  owner: process.env.EAS_OWNER,
  version: '1.0.0',
  orientation: 'portrait',
  scheme: SCHEME,
  icon: './assets/images/icon.png',
  userInterfaceStyle: 'automatic',
  backgroundColor: INK,
  description: 'Mahorat — learn technology, programming, 3D, video and design from zero to mastery.',
  runtimeVersion: { policy: 'appVersion' },
  updates: easProjectId ? { url: `https://u.expo.dev/${easProjectId}` } : undefined,
  ios: {
    bundleIdentifier: `${BUNDLE_ID}${suffix}`,
    supportsTablet: true,
    usesAppleSignIn: true,
    config: { usesNonExemptEncryption: false },
    infoPlist: {
      CFBundleAllowMixedLocalizations: true,
      CFBundleLocalizations: ['en', 'uz', 'ru'],
      UIBackgroundModes: [],
    },
    privacyManifests: {
      NSPrivacyTracking: false,
      NSPrivacyTrackingDomains: [],
      NSPrivacyCollectedDataTypes: [
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeEmailAddress',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: ['NSPrivacyCollectedDataTypePurposeAppFunctionality'],
        },
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeName',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: ['NSPrivacyCollectedDataTypePurposeAppFunctionality'],
        },
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeOtherUsageData',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: ['NSPrivacyCollectedDataTypePurposeAppFunctionality'],
        },
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypePurchaseHistory',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: ['NSPrivacyCollectedDataTypePurposeAppFunctionality'],
        },
      ],
    },
  },
  android: {
    package: `${BUNDLE_ID}${suffix}`,
    adaptiveIcon: {
      backgroundColor: INK,
      foregroundImage: './assets/images/android-icon-foreground.png',
      backgroundImage: './assets/images/android-icon-background.png',
      monochromeImage: './assets/images/android-icon-monochrome.png',
    },
    predictiveBackGestureEnabled: true,
    // Only what the app needs; libraries' unused permissions are stripped.
    blockedPermissions: [
      'android.permission.RECORD_AUDIO',
      'android.permission.READ_EXTERNAL_STORAGE',
      'android.permission.WRITE_EXTERNAL_STORAGE',
      'android.permission.SYSTEM_ALERT_WINDOW',
    ],
    intentFilters: [
      {
        action: 'VIEW',
        category: ['BROWSABLE', 'DEFAULT'],
        data: [{ scheme: SCHEME }],
      },
    ],
  },
  web: {
    output: 'single',
    favicon: './assets/images/favicon.png',
    bundler: 'metro',
  },
  plugins: [
    'expo-router',
    [
      'expo-splash-screen',
      {
        backgroundColor: INK,
        image: './assets/images/splash-icon.png',
        imageWidth: 112,
        dark: { backgroundColor: INK, image: './assets/images/splash-icon.png' },
      },
    ],
    'expo-secure-store',
    'expo-localization',
    'expo-apple-authentication',
    ['expo-video', { supportsPictureInPicture: true, supportsBackgroundPlayback: false }],
    [
      'expo-notifications',
      { icon: './assets/images/android-icon-monochrome.png', color: '#E8C07A', defaultChannel: 'learning' },
    ],
    [
      'expo-image-picker',
      {
        photosPermission: 'Mahorat uses your photo library only when you choose a new profile picture.',
        cameraPermission: false,
        microphonePermission: false,
      },
    ],
    'expo-font',
    'expo-web-browser',
  ],
  experiments: {
    typedRoutes: true,
    reactCompiler: true,
  },
  extra: {
    appEnv: APP_ENV,
    eas: easProjectId ? { projectId: easProjectId } : undefined,
    paper: PAPER,
  },
});
