import {
  Award,
  BookOpen,
  Box,
  CircleCheck,
  Clapperboard,
  Code,
  Compass,
  Cpu,
  Flag,
  Flame,
  Footprints,
  Gamepad2,
  type LucideIcon,
  Palette,
  Sparkles,
  Target,
  Timer,
  TrendingUp,
  Waves,
} from 'lucide-react-native';

/**
 * Icon keys stored in the database (categories.icon, achievements.icon) mapped to the
 * app's icon set. Unknown keys fall back gracefully so admins can't break the UI.
 */
const registry: Record<string, LucideIcon> = {
  cpu: Cpu,
  code: Code,
  clapperboard: Clapperboard,
  box: Box,
  gamepad: Gamepad2,
  palette: Palette,
  sparkles: Sparkles,
  footprints: Footprints,
  compass: Compass,
  'book-open': BookOpen,
  waves: Waves,
  flame: Flame,
  'check-circle': CircleCheck,
  target: Target,
  flag: Flag,
  award: Award,
  timer: Timer,
  'trending-up': TrendingUp,
};

export function iconFor(key: string | null | undefined, fallback: LucideIcon = Sparkles): LucideIcon {
  return (key && registry[key]) || fallback;
}

export function DynamicIcon({ name, size = 20, color, strokeWidth = 1.75 }: { name: string | null | undefined; size?: number; color: string; strokeWidth?: number }) {
  const I = iconFor(name);
  return <I size={size} color={color} strokeWidth={strokeWidth} />;
}
