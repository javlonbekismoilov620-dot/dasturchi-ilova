// Web port of apps/mobile/src/components/brand/CourseCover.tsx so editors preview the
// exact generative cover learners will see.
import { publicUrl } from '../lib/supabase';

export type Pattern = 'grid' | 'brackets' | 'waves' | 'isometric' | 'frames' | 'hex' | 'circles' | 'orbits';

function PatternArt({ pattern, stroke }: { pattern: Pattern; stroke: string }) {
  const s = { stroke, strokeWidth: 1.2, fill: 'none' };
  switch (pattern) {
    case 'brackets':
      return (
        <g>
          <path d="M118 58 L82 100 L118 142" {...s} strokeWidth={9} strokeLinecap="round" strokeLinejoin="round" opacity={0.85} />
          <path d="M202 58 L238 100 L202 142" {...s} strokeWidth={9} strokeLinecap="round" strokeLinejoin="round" opacity={0.85} />
          <path d="M174 48 L146 152" {...s} strokeWidth={9} strokeLinecap="round" opacity={0.45} />
        </g>
      );
    case 'waves':
      return (
        <g>
          {Array.from({ length: 9 }, (_, i) => (
            <path key={i} d={`M-10 ${60 + i * 12} C 60 ${30 + i * 12}, 120 ${100 + i * 12}, 190 ${60 + i * 12} S 300 ${30 + i * 12}, 340 ${70 + i * 12}`} {...s} opacity={0.15 + (i % 3) * 0.18} />
          ))}
        </g>
      );
    case 'isometric': {
      const cube = (cx: number, cy: number, r: number, o: number) => (
        <g opacity={o} key={`${cx}-${cy}`}>
          <path d={`M${cx} ${cy - r} L${cx + r * 0.87} ${cy - r / 2} L${cx + r * 0.87} ${cy + r / 2} L${cx} ${cy + r} L${cx - r * 0.87} ${cy + r / 2} L${cx - r * 0.87} ${cy - r / 2} Z`} {...s} strokeWidth={2} />
          <path d={`M${cx - r * 0.87} ${cy - r / 2} L${cx} ${cy} L${cx + r * 0.87} ${cy - r / 2} M${cx} ${cy} L${cx} ${cy + r}`} {...s} strokeWidth={2} />
        </g>
      );
      return <g>{[cube(170, 100, 62, 0.9), cube(70, 60, 26, 0.35), cube(268, 150, 34, 0.4)]}</g>;
    }
    case 'frames':
      return (
        <g>
          {Array.from({ length: 5 }, (_, i) => (
            <rect key={i} x={24 + i * 58} y={64} width={50} height={72} rx={6} {...s} opacity={i === 2 ? 0.95 : 0.35} strokeWidth={i === 2 ? 2.5 : 1.2} />
          ))}
        </g>
      );
    case 'hex':
      return (
        <g>
          {Array.from({ length: 4 }, (_, row) =>
            Array.from({ length: 9 }, (_, col) => {
              const cx = col * 40 + (row % 2) * 20;
              const cy = 30 + row * 35;
              const d = Array.from({ length: 6 }, (_, k) => {
                const a = (Math.PI / 3) * k + Math.PI / 6;
                return `${k ? 'L' : 'M'}${cx + 20 * Math.cos(a)} ${cy + 20 * Math.sin(a)}`;
              }).join(' ');
              return <path key={`${row}-${col}`} d={`${d} Z`} {...s} opacity={row === 2 && col === 4 ? 0.95 : 0.16} strokeWidth={row === 2 && col === 4 ? 2.4 : 1.2} />;
            }),
          )}
        </g>
      );
    case 'circles':
      return (
        <g>
          <circle cx={130} cy={100} r={58} {...s} strokeWidth={2.4} opacity={0.9} />
          <circle cx={190} cy={100} r={58} {...s} strokeWidth={2.4} opacity={0.55} />
        </g>
      );
    case 'orbits':
      return (
        <g>
          <ellipse cx={160} cy={100} rx={120} ry={38} {...s} opacity={0.5} transform="rotate(-18 160 100)" />
          <ellipse cx={160} cy={100} rx={120} ry={38} {...s} opacity={0.35} transform="rotate(30 160 100)" />
          <circle cx={160} cy={100} r={14} fill={stroke} opacity={0.9} />
        </g>
      );
    default:
      return (
        <g>
          {Array.from({ length: 17 }, (_, i) => (
            <line key={`v${i}`} x1={i * 20} y1={0} x2={i * 20} y2={200} {...s} opacity={0.12} />
          ))}
          {Array.from({ length: 11 }, (_, i) => (
            <line key={`h${i}`} x1={0} y1={i * 20} x2={320} y2={i * 20} {...s} opacity={0.12} />
          ))}
          <rect x={120} y={60} width={80} height={80} rx={12} {...s} strokeWidth={2.4} opacity={0.95} />
          <rect x={140} y={80} width={40} height={40} rx={6} fill={stroke} opacity={0.35} />
        </g>
      );
  }
}

export function CoverArt({ pattern = 'grid', hue = 38, coverPath, width = 320, radius = 14 }: { pattern?: Pattern; hue?: number; coverPath?: string | null; width?: number; radius?: number }) {
  const id = `c${pattern}${Math.round(hue)}`;
  if (coverPath) return <img src={publicUrl('public-media', coverPath)} alt="" style={{ width, aspectRatio: '16/10', objectFit: 'cover', borderRadius: radius, display: 'block' }} />;
  return (
    <svg viewBox="0 0 320 200" style={{ width, height: 'auto', borderRadius: radius, display: 'block' }} preserveAspectRatio="xMidYMid slice" aria-hidden>
      <defs>
        <linearGradient id={`bg${id}`} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor={`hsl(${hue}, 38%, 13%)`} />
          <stop offset="1" stopColor={`hsl(${(hue + 28) % 360}, 46%, 24%)`} />
        </linearGradient>
        <radialGradient id={`gl${id}`} cx="72%" cy="22%" r="70%">
          <stop offset="0" stopColor={`hsl(${hue}, 85%, 70%)`} stopOpacity={0.42} />
          <stop offset="1" stopColor={`hsl(${hue}, 85%, 70%)`} stopOpacity={0} />
        </radialGradient>
      </defs>
      <rect width={320} height={200} fill={`url(#bg${id})`} />
      <rect width={320} height={200} fill={`url(#gl${id})`} />
      <PatternArt pattern={pattern} stroke={`hsl(${hue}, 80%, 82%)`} />
    </svg>
  );
}
