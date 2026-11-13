// Generates every raster brand asset (app icons, adaptive icons, splash, favicon)
// from the vector mark below, so the identity stays pixel-consistent.
//   node scripts/generate-brand-assets.mjs
import { Resvg } from '@resvg/resvg-js';
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const out = (p) => join(root, p);

// Mahorat mark — an ascending "M": two peaks, the second higher, with a summit point.
// Designed on a 64×64 grid; stroke 6 with round caps/joins.
export const MARK_PATH = 'M12 51 L23 31 L32 43 L44 21 L52 35';
export const MARK_DOT = { cx: 44, cy: 11, r: 3.6 };

const GOLD = `<linearGradient id="gold" x1="0" y1="0" x2="0.35" y2="1">
  <stop offset="0" stop-color="#FBE6BE"/><stop offset="0.55" stop-color="#E8C07A"/><stop offset="1" stop-color="#B98434"/></linearGradient>`;

function mark({ size, scale = 1, color = 'url(#gold)', offsetY = 0 }) {
  const s = (size / 64) * scale;
  const t = (size - 64 * s) / 2;
  return `<g transform="translate(${t} ${t + offsetY * s}) scale(${s})">
    <path d="${MARK_PATH}" fill="none" stroke="${color}" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>
    <circle cx="${MARK_DOT.cx}" cy="${MARK_DOT.cy}" r="${MARK_DOT.r}" fill="${color}"/>
  </g>`;
}

const background = (size, rounded = 0) => `
  <defs>${GOLD}
    <radialGradient id="glow" cx="0.5" cy="0.32" r="0.75">
      <stop offset="0" stop-color="#2A2214"/><stop offset="0.45" stop-color="#121216"/><stop offset="1" stop-color="#07080B"/>
    </radialGradient>
    <linearGradient id="sheen" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#FFFFFF" stop-opacity="0.07"/><stop offset="0.5" stop-color="#FFFFFF" stop-opacity="0"/>
    </linearGradient>
  </defs>
  <rect width="${size}" height="${size}" rx="${rounded}" fill="url(#glow)"/>
  <rect width="${size}" height="${size}" rx="${rounded}" fill="url(#sheen)"/>`;

const svg = (size, body) => `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 ${size} ${size}">${body}</svg>`;

function png(path, svgText, width) {
  const r = new Resvg(svgText, { fitTo: { mode: 'width', value: width } });
  mkdirSync(dirname(out(path)), { recursive: true });
  writeFileSync(out(path), r.render().asPng());
  console.log('wrote', path);
}

// App Store / generic icon (no transparency, no rounded corners — the OS masks it).
png('assets/images/icon.png', svg(1024, background(1024) + mark({ size: 1024, scale: 0.62 })), 1024);
// Android adaptive icon layers (content must sit inside the central 66% safe zone).
png('assets/images/android-icon-background.png', svg(1024, background(1024)), 1024);
png('assets/images/android-icon-foreground.png', svg(1024, `<defs>${GOLD}</defs>` + mark({ size: 1024, scale: 0.42 })), 1024);
png('assets/images/android-icon-monochrome.png', svg(1024, mark({ size: 1024, scale: 0.42, color: '#FFFFFF' })), 1024);
// Native splash mark (shown before JS loads; the animated splash takes over seamlessly).
png('assets/images/splash-icon.png', svg(512, `<defs>${GOLD}</defs>` + mark({ size: 512, scale: 0.9 })), 512);
// Web favicon.
png('assets/images/favicon.png', svg(96, background(96, 22) + mark({ size: 96, scale: 0.66 })), 96);
// Vector sources for docs, store listing and the admin dashboard.
mkdirSync(out('assets/brand'), { recursive: true });
writeFileSync(out('assets/brand/mark.svg'), svg(64, `<defs>${GOLD}</defs>` + mark({ size: 64 })));
writeFileSync(out('assets/brand/app-icon.svg'), svg(1024, background(1024, 224) + mark({ size: 1024, scale: 0.62 })));
console.log('done');
