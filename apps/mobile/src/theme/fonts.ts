import { CormorantGaramond_500Medium_Italic } from '@expo-google-fonts/cormorant-garamond/500Medium_Italic';
import { CormorantGaramond_600SemiBold } from '@expo-google-fonts/cormorant-garamond/600SemiBold';
import { Inter_400Regular } from '@expo-google-fonts/inter/400Regular';
import { Inter_500Medium } from '@expo-google-fonts/inter/500Medium';
import { Inter_600SemiBold } from '@expo-google-fonts/inter/600SemiBold';
import { Inter_700Bold } from '@expo-google-fonts/inter/700Bold';
import { JetBrainsMono_400Regular } from '@expo-google-fonts/jetbrains-mono/400Regular';
import { JetBrainsMono_600SemiBold } from '@expo-google-fonts/jetbrains-mono/600SemiBold';

import { fonts } from './tokens';

/**
 * Each weight is registered as its own family so Android (which ignores fontWeight for
 * custom fonts) renders exactly the intended cut. All three families cover Latin,
 * Uzbek (incl. ʻ U+02BB) and Cyrillic — verified with fontTools during design.
 */
export const fontAssets = {
  [fonts.regular]: Inter_400Regular,
  [fonts.medium]: Inter_500Medium,
  [fonts.semibold]: Inter_600SemiBold,
  [fonts.bold]: Inter_700Bold,
  [fonts.display]: CormorantGaramond_600SemiBold,
  [fonts.displayItalic]: CormorantGaramond_500Medium_Italic,
  [fonts.mono]: JetBrainsMono_400Regular,
  [fonts.monoBold]: JetBrainsMono_600SemiBold,
};
