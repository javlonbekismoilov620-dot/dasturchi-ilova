import { Image } from 'expo-image';
import { memo, type ReactNode } from 'react';
import { StyleSheet, View, type StyleProp, type ViewStyle } from 'react-native';
import Svg, { Circle, Defs, Ellipse, G, Line, LinearGradient, Path, RadialGradient, Rect, Stop } from 'react-native-svg';

import type { CoverStyle } from '@/data/types';
import { env } from '@/lib/env';

/**
 * Generative cover art. Every course gets an original, on-brand cover derived from its
 * subject pattern and hue — no stock imagery, consistent at any size, ~0 bytes to ship.
 * Admin-uploaded cover images (public-media bucket) take precedence when present.
 */
function hueFromHex(hex?: string | null) {
  if (!hex) return 38;
  const n = parseInt(hex.replace('#', ''), 16);
  const r = ((n >> 16) & 255) / 255;
  const g = ((n >> 8) & 255) / 255;
  const b = (n & 255) / 255;
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const d = max - min;
  if (!d) return 38;
  let h = max === r ? ((g - b) / d) % 6 : max === g ? (b - r) / d + 2 : (r - g) / d + 4;
  h *= 60;
  return h < 0 ? h + 360 : h;
}

const W = 320;
const H = 200;

function Pattern({ pattern, stroke }: { pattern: NonNullable<CoverStyle['pattern']>; stroke: string }) {
  const s = { stroke, strokeWidth: 1.2, fill: 'none' as const };
  switch (pattern) {
    case 'brackets':
      return (
        <G>
          <Path d="M118 58 L82 100 L118 142" {...s} strokeWidth={9} strokeLinecap="round" strokeLinejoin="round" opacity={0.85} />
          <Path d="M202 58 L238 100 L202 142" {...s} strokeWidth={9} strokeLinecap="round" strokeLinejoin="round" opacity={0.85} />
          <Path d="M174 48 L146 152" {...s} strokeWidth={9} strokeLinecap="round" opacity={0.45} />
          {Array.from({ length: 9 }, (_, i) => (
            <Line key={i} x1={20} y1={24 + i * 20} x2={20 + ((i * 53) % 90) + 30} y2={24 + i * 20} {...s} opacity={0.18} strokeWidth={3} strokeLinecap="round" />
          ))}
        </G>
      );
    case 'waves':
      return (
        <G>
          {Array.from({ length: 9 }, (_, i) => (
            <Path key={i} d={`M-10 ${60 + i * 12} C 60 ${30 + i * 12}, 120 ${100 + i * 12}, 190 ${60 + i * 12} S 300 ${30 + i * 12}, 340 ${70 + i * 12}`} {...s} opacity={0.15 + (i % 3) * 0.18} />
          ))}
        </G>
      );
    case 'isometric': {
      const cube = (cx: number, cy: number, r: number, o: number) => (
        <G opacity={o} key={`${cx}-${cy}`}>
          <Path d={`M${cx} ${cy - r} L${cx + r * 0.87} ${cy - r / 2} L${cx + r * 0.87} ${cy + r / 2} L${cx} ${cy + r} L${cx - r * 0.87} ${cy + r / 2} L${cx - r * 0.87} ${cy - r / 2} Z`} {...s} strokeWidth={2} />
          <Path d={`M${cx - r * 0.87} ${cy - r / 2} L${cx} ${cy} L${cx + r * 0.87} ${cy - r / 2} M${cx} ${cy} L${cx} ${cy + r}`} {...s} strokeWidth={2} />
        </G>
      );
      return <G>{[cube(170, 100, 62, 0.9), cube(70, 60, 26, 0.35), cube(268, 150, 34, 0.4), cube(250, 44, 16, 0.3)]}</G>;
    }
    case 'frames':
      return (
        <G>
          {Array.from({ length: 5 }, (_, i) => (
            <Rect key={i} x={24 + i * 58} y={64} width={50} height={72} rx={6} {...s} opacity={i === 2 ? 0.95 : 0.35} strokeWidth={i === 2 ? 2.5 : 1.2} />
          ))}
          {Array.from({ length: 16 }, (_, i) => (
            <Rect key={`p${i}`} x={18 + i * 19} y={40} width={9} height={9} rx={2} fill={stroke} opacity={0.22} />
          ))}
          {Array.from({ length: 16 }, (_, i) => (
            <Rect key={`q${i}`} x={18 + i * 19} y={151} width={9} height={9} rx={2} fill={stroke} opacity={0.22} />
          ))}
        </G>
      );
    case 'hex': {
      const hexes = [];
      for (let row = 0; row < 6; row++)
        for (let col = 0; col < 9; col++) {
          const cx = col * 40 + (row % 2) * 20;
          const cy = row * 35;
          const r = 20;
          const d = Array.from({ length: 6 }, (_, k) => {
            const a = (Math.PI / 3) * k + Math.PI / 6;
            return `${k ? 'L' : 'M'}${cx + r * Math.cos(a)} ${cy + r * Math.sin(a)}`;
          }).join(' ');
          const highlight = (row === 2 && col === 4) || (row === 3 && col === 4) || (row === 2 && col === 5);
          hexes.push(<Path key={`${row}-${col}`} d={`${d} Z`} {...s} opacity={highlight ? 0.95 : 0.16} strokeWidth={highlight ? 2.4 : 1.2} />);
        }
      return <G>{hexes}</G>;
    }
    case 'circles':
      return (
        <G>
          <Circle cx={130} cy={100} r={58} {...s} strokeWidth={2.4} opacity={0.9} />
          <Circle cx={190} cy={100} r={58} {...s} strokeWidth={2.4} opacity={0.55} />
          {Array.from({ length: 5 }, (_, i) => (
            <Circle key={i} cx={160} cy={100} r={78 + i * 18} {...s} opacity={0.12} />
          ))}
        </G>
      );
    case 'orbits':
      return (
        <G>
          <Ellipse cx={160} cy={100} rx={120} ry={38} {...s} opacity={0.5} transform="rotate(-18 160 100)" />
          <Ellipse cx={160} cy={100} rx={120} ry={38} {...s} opacity={0.35} transform="rotate(30 160 100)" />
          <Ellipse cx={160} cy={100} rx={70} ry={70} {...s} opacity={0.2} />
          <Circle cx={160} cy={100} r={14} fill={stroke} opacity={0.9} />
          <Circle cx={262} cy={70} r={5} fill={stroke} opacity={0.85} />
          <Circle cx={74} cy={150} r={4} fill={stroke} opacity={0.7} />
          <Circle cx={212} cy={168} r={3} fill={stroke} opacity={0.6} />
        </G>
      );
    case 'grid':
    default:
      return (
        <G>
          {Array.from({ length: 17 }, (_, i) => (
            <Line key={`v${i}`} x1={i * 20} y1={0} x2={i * 20} y2={H} {...s} opacity={0.12} />
          ))}
          {Array.from({ length: 11 }, (_, i) => (
            <Line key={`h${i}`} x1={0} y1={i * 20} x2={W} y2={i * 20} {...s} opacity={0.12} />
          ))}
          <Rect x={120} y={60} width={80} height={80} rx={12} {...s} strokeWidth={2.4} opacity={0.95} />
          <Rect x={140} y={80} width={40} height={40} rx={6} fill={stroke} opacity={0.35} />
          {[0, 1, 2, 3].map((k) => (
            <G key={k}>
              <Line x1={130 + k * 20} y1={40} x2={130 + k * 20} y2={60} {...s} strokeWidth={2} opacity={0.6} />
              <Line x1={130 + k * 20} y1={140} x2={130 + k * 20} y2={160} {...s} strokeWidth={2} opacity={0.6} />
              <Line x1={100} y1={70 + k * 20} x2={120} y2={70 + k * 20} {...s} strokeWidth={2} opacity={0.6} />
              <Line x1={200} y1={70 + k * 20} x2={220} y2={70 + k * 20} {...s} strokeWidth={2} opacity={0.6} />
            </G>
          ))}
        </G>
      );
  }
}

interface CourseCoverProps {
  style?: StyleProp<ViewStyle>;
  coverStyle?: CoverStyle | null;
  categoryColor?: string | null;
  coverPath?: string | null;
  radius?: number;
  children?: ReactNode;
  id?: string;
}

export const CourseCover = memo(function CourseCover({ style, coverStyle, categoryColor, coverPath, radius = 18, children, id = 'c' }: CourseCoverProps) {
  const hue = coverStyle?.hue ?? hueFromHex(categoryColor);
  const pattern = coverStyle?.pattern ?? 'grid';
  const gid = `${id}-${pattern}-${Math.round(hue)}`.replace(/[^a-zA-Z0-9-]/g, '');
  const imageUri = coverPath ? `${env.supabaseUrl}/storage/v1/object/public/public-media/${coverPath}` : null;

  return (
    <View style={[{ borderRadius: radius, overflow: 'hidden', backgroundColor: `hsl(${hue}, 30%, 10%)` }, style]}>
      {imageUri ? (
        <Image source={{ uri: imageUri }} style={StyleSheet.absoluteFill} contentFit="cover" transition={250} />
      ) : (
        <Svg width="100%" height="100%" viewBox={`0 0 ${W} ${H}`} preserveAspectRatio="xMidYMid slice" style={StyleSheet.absoluteFill}>
          <Defs>
            <LinearGradient id={`bg${gid}`} x1="0" y1="0" x2="1" y2="1">
              <Stop offset="0" stopColor={`hsl(${hue}, 38%, 13%)`} />
              <Stop offset="1" stopColor={`hsl(${(hue + 28) % 360}, 46%, 24%)`} />
            </LinearGradient>
            <RadialGradient id={`gl${gid}`} cx="72%" cy="22%" r="70%">
              <Stop offset="0" stopColor={`hsl(${hue}, 85%, 70%)`} stopOpacity={0.42} />
              <Stop offset="1" stopColor={`hsl(${hue}, 85%, 70%)`} stopOpacity={0} />
            </RadialGradient>
            <LinearGradient id={`vg${gid}`} x1="0" y1="0" x2="0" y2="1">
              <Stop offset="0.45" stopColor="#000" stopOpacity={0} />
              <Stop offset="1" stopColor="#000" stopOpacity={0.45} />
            </LinearGradient>
          </Defs>
          <Rect width={W} height={H} fill={`url(#bg${gid})`} />
          <Rect width={W} height={H} fill={`url(#gl${gid})`} />
          <Pattern pattern={pattern} stroke={`hsl(${hue}, 80%, 82%)`} />
          <Rect width={W} height={H} fill={`url(#vg${gid})`} />
        </Svg>
      )}
      {children}
    </View>
  );
});

export { hueFromHex };
