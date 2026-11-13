import { createContext, useContext, useMemo, type ReactNode } from 'react';
import { StyleSheet, useColorScheme, type ImageStyle, type TextStyle, type ViewStyle } from 'react-native';
import { useReducedMotion } from 'react-native-reanimated';

import { usePreferences } from '@/stores/preferences';

import { colors, elevation, fonts, layout, motion, radii, spacing, typography, type ColorScheme, type ThemeColors } from './tokens';

export interface Theme {
  scheme: ColorScheme;
  isDark: boolean;
  colors: ThemeColors;
  spacing: typeof spacing;
  radii: typeof radii;
  typography: typeof typography;
  fonts: typeof fonts;
  motion: typeof motion;
  layout: typeof layout;
  reduceMotion: boolean;
  elevation: (level?: 1 | 2 | 3) => object | undefined;
}

const ThemeContext = createContext<Theme | null>(null);

export function ThemeProvider({ children }: { children: ReactNode }) {
  const system = useColorScheme();
  const mode = usePreferences((s) => s.themeMode);
  const userReduceMotion = usePreferences((s) => s.reduceMotion);
  const osReduceMotion = useReducedMotion();
  const scheme: ColorScheme = mode === 'system' ? (system === 'light' ? 'light' : 'dark') : mode;

  const value = useMemo<Theme>(
    () => ({
      scheme,
      isDark: scheme === 'dark',
      colors: colors[scheme],
      spacing,
      radii,
      typography,
      fonts,
      motion,
      layout,
      reduceMotion: userReduceMotion || osReduceMotion,
      elevation: (level = 1) => elevation(scheme, level),
    }),
    [scheme, userReduceMotion, osReduceMotion],
  );

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export function useTheme(): Theme {
  const t = useContext(ThemeContext);
  if (!t) throw new Error('useTheme must be used inside ThemeProvider');
  return t;
}

/** Memoised, theme-aware StyleSheet factory. */
type NamedStyles = Record<string, ViewStyle | TextStyle | ImageStyle>;

export function makeStyles<T extends NamedStyles>(factory: (t: Theme) => T) {
  return function useStyles(): Readonly<T> {
    const theme = useTheme();
    return useMemo(() => StyleSheet.create(factory(theme)), [theme]);
  };
}
