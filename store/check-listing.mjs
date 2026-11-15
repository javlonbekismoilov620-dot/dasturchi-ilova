// Verifies store listing field lengths in store/listing.md.
import { readFileSync } from 'node:fs';
const md = readFileSync(new URL('./listing.md', import.meta.url), 'utf8');
let fail = 0;
for (const line of md.split('\n')) {
  const m = /^\| (.+?) \((\d+)\) \| (.+) \|$/.exec(line);
  if (!m) continue;
  const [, field, limit, text] = m;
  const len = [...text.trim()].length;
  const ok = len <= Number(limit);
  if (!ok) fail++;
  console.log(`${ok ? '✓' : '✗'} ${field.padEnd(34)} ${String(len).padStart(3)}/${limit}`);
}
process.exit(fail ? 1 : 0);
