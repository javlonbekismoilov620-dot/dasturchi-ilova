/**
 * Mahorat design tokens.
 *
 * Visual direction: minimalist luxury on a deep "ink" canvas, a single champagne-gold
 * signature accent, editorial serif display type paired with a precise sans for UI.
 * Category hues (from the backend) tint covers and accents; they never replace the
 * brand accent for primary actions.
 */
import { Platform } from 'react-native';

export type ColorScheme = 'light' | 'dark';

export interface ThemeColors {
  background: string;
  backgroundElevated: string;
  surface: string;
  surfaceHigh: string;
  surfacePressed: string;
  border: string;
  borderStrong: string;
  text: string;
  textSecondary: string;
  textTertiary: string;
  textInverse: string;
  accent: string;
  accentStrong: string;
  accentSoft: string;
  onAccent: string;
  success: string;
  successSoft: string;
  warning: string;
  warningSoft: string;
  danger: string;
  dangerSoft: string;
  info: string;
  infoSoft: string;
  overlay: string;
  scrim: string;
  skeleton: string;
  skeletonHighlight: string;
  tabBar: string;
  codeBackground: string;
  codeText: string;
}

export const colors: Record<ColorScheme, ThemeColors> = {
  dark: {
    background: '#08090C',
    backgroundElevated: '#0E1014',
    surface: '#13151B',
    surfaceHigh: '#1A1D24',
    surfacePressed: '#20242C',
    border: 'rgba(255,255,255,0.07)',
    borderStrong: 'rgba(255,255,255,0.14)',
    text: '#F5F2EC',
    textSecondary: '#ABA79F',
    textTertiary: '#7D7A74',
    textInverse: '#15140F',
    accent: '#E8C07A',
    accentStrong: '#F4D7A1',
    accentSoft: 'rgba(232,192,122,0.13)',
    onAccent: '#1C1508',
    success: '#5FD39B',
    successSoft: 'rgba(95,211,155,0.13)',
    warning: '#F3B65A',
    warningSoft: 'rgba(243,182,90,0.13)',
    danger: '#FF7A7A',
    dangerSoft: 'rgba(255,122,122,0.13)',
    info: '#7DB8FF',
    infoSoft: 'rgba(125,184,255,0.13)',
    overlay: 'rgba(8,9,12,0.72)',
    scrim: 'rgba(0,0,0,0.55)',
    skeleton: '#16191F',
    skeletonHighlight: '#20242C',
    tabBar: 'rgba(14,16,20,0.78)',
    codeBackground: '#0C0E12',
    codeText: '#E7E3DA',
  },
  light: {
    background: '#F7F5F1',
    backgroundElevated: '#FBFAF7',
    surface: '#FFFFFF',
    surfaceHigh: '#F0EDE7',
    surfacePressed: '#E8E4DC',
    border: 'rgba(28,24,16,0.08)',
    borderStrong: 'rgba(28,24,16,0.16)',
    text: '#16140F',
    textSecondary: '#5C5850',
    textTertiary: '#77736A',
    textInverse: '#F5F2EC',
    accent: '#9A6A22',
    accentStrong: '#7E5517',
    accentSoft: 'rgba(154,106,34,0.10)',
    onAccent: '#FFFFFF',
    success: '#16865A',
    successSoft: 'rgba(22,134,90,0.10)',
    warning: '#A86A06',
    warningSoft: 'rgba(168,106,6,0.10)',
    danger: '#C93838',
    dangerSoft: 'rgba(201,56,56,0.09)',
    info: '#2563C9',
    infoSoft: 'rgba(37,99,201,0.09)',
    overlay: 'rgba(247,245,241,0.8)',
    scrim: 'rgba(16,14,10,0.35)',
    skeleton: '#ECE8E1',
    skeletonHighlight: '#F6F3EE',
    tabBar: 'rgba(251,250,247,0.82)',
    codeBackground: '#14161B',
    codeText: '#E7E3DA',
  },
};

export const spacing = {
  xxs: 2,
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
  huge: 48,
  gutter: 20,
} as const;

export const radii = {
  xs: 6,
  sm: 10,
  md: 14,
  lg: 18,
  xl: 24,
  xxl: 30,
  pill: 999,
} as const;

/** Font family keys registered in src/theme/fonts.ts */
export const fonts = {
  regular: 'Inter-Regular',
  medium: 'Inter-Medium',
  semibold: 'Inter-SemiBold',
  bold: 'Inter-Bold',
  display: 'Cormorant-SemiBold',
  displayItalic: 'Cormorant-MediumItalic',
  mono: 'JetBrainsMono-Regular',
  monoBold: 'JetBrainsMono-SemiBold',
} as const;

export const typography = {
  hero: { fontFamily: fonts.display, fontSize: 44, lineHeight: 46, letterSpacing: -0.6 },
  display: { fontFamily: fonts.display, fontSize: 36, lineHeight: 40, letterSpacing: -0.4 },
  title1: { fontFamily: fonts.display, fontSize: 30, lineHeight: 34, letterSpacing: -0.2 },
  title2: { fontFamily: fonts.semibold, fontSize: 22, lineHeight: 28, letterSpacing: -0.35 },
  title3: { fontFamily: fonts.semibold, fontSize: 18, lineHeight: 24, letterSpacing: -0.2 },
  headline: { fontFamily: fonts.semibold, fontSize: 16, lineHeight: 22, letterSpacing: -0.1 },
  body: { fontFamily: fonts.regular, fontSize: 16, lineHeight: 25, letterSpacing: -0.05 },
  bodyStrong: { fontFamily: fonts.medium, fontSize: 16, lineHeight: 24, letterSpacing: -0.05 },
  callout: { fontFamily: fonts.regular, fontSize: 15, lineHeight: 21, letterSpacing: -0.05 },
  subhead: { fontFamily: fonts.medium, fontSize: 14, lineHeight: 20, letterSpacing: 0 },
  footnote: { fontFamily: fonts.regular, fontSize: 13, lineHeight: 18, letterSpacing: 0 },
  caption: { fontFamily: fonts.medium, fontSize: 12, lineHeight: 16, letterSpacing: 0.1 },
  overline: { fontFamily: fonts.semibold, fontSize: 11, lineHeight: 14, letterSpacing: 1.3, textTransform: 'uppercase' as const },
  mono: { fontFamily: fonts.mono, fontSize: 13.5, lineHeight: 21, letterSpacing: 0 },
} as const;

export type TypographyVariant = keyof typeof typography;

export const motion = {
  duration: { instant: 90, fast: 160, base: 240, slow: 420, cinematic: 900 },
  spring: {
    snappy: { damping: 18, stiffness: 260, mass: 0.7 },
    gentle: { damping: 20, stiffness: 140, mass: 1 },
    bouncy: { damping: 12, stiffness: 180, mass: 0.8 },
  },
  pressScale: 0.97,
} as const;

export const layout = {
  maxContentWidth: 760,
  tabBarHeight: 64,
  hitSlop: { top: 10, bottom: 10, left: 10, right: 10 },
  minTouch: 44,
} as const;

export function elevation(scheme: ColorScheme, level: 1 | 2 | 3 = 1) {
  if (scheme === 'dark') {
    // Dark UIs read depth through luminance + hairlines, not drop shadows.
    return Platform.select({
      web: { boxShadow: `0 ${level * 6}px ${level * 18}px rgba(0,0,0,${0.25 + level * 0.1})` } as object,
      default: {
        shadowColor: '#000',
        shadowOpacity: 0.35 + level * 0.1,
        shadowRadius: level * 10,
        shadowOffset: { width: 0, height: level * 5 },
        elevation: level * 3,
      },
    });
  }
  return Platform.select({
    web: { boxShadow: `0 ${level * 4}px ${level * 16}px rgba(40,32,20,${0.05 + level * 0.025})` } as object,
    default: {
      shadowColor: '#3A2E1C',
      shadowOpacity: 0.06 + level * 0.025,
      shadowRadius: level * 9,
      shadowOffset: { width: 0, height: level * 4 },
      elevation: level * 2,
    },
  });
}

/** Turn a category hex (+ alpha) into rgba. */
export function withAlpha(hex: string, alpha: number) {
  const h = hex.replace('#', '');
  const n = parseInt(h.length === 3 ? h.split('').map((c) => c + c).join('') : h, 16);
  return `rgba(${(n >> 16) & 255},${(n >> 8) & 255},${n & 255},${alpha})`;
}

/** HSL helper for generative covers. */
export function hsl(h: number, s: number, l: number, a = 1) {
  return a === 1 ? `hsl(${Math.round(h)}, ${Math.round(s)}%, ${Math.round(l)}%)` : `hsla(${Math.round(h)}, ${Math.round(s)}%, ${Math.round(l)}%, ${a})`;
}
