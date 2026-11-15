// Renders the Google Play feature graphic (1024×500) from the brand mark.
//   node qa/store-graphics.cjs
const { chromium } = require('playwright');
const fs = require('node:fs');
const mark = fs.readFileSync('apps/mobile/assets/brand/mark.svg', 'utf8');
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 1024, height: 500 } });
  await p.setContent(`<!doctype html><html><head><link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600&family=Inter:wght@500&display=swap" rel="stylesheet">
  <style>body{margin:0;width:1024px;height:500px;overflow:hidden;background:radial-gradient(circle at 78% 30%,rgba(232,192,122,.30),transparent 45%),radial-gradient(circle at 5% 100%,rgba(125,184,255,.12),transparent 40%),#08090C;display:flex;align-items:center;gap:44px;padding:0 90px;box-sizing:border-box;font-family:Inter,sans-serif;color:#F5F2EC}
  .m svg{width:170px;height:170px}h1{font-family:'Cormorant Garamond',serif;font-weight:600;font-size:96px;margin:0;line-height:1}
  p{margin:14px 0 0;font-size:26px;color:#ABA79F}span{color:#E8C07A}</style></head>
  <body><div class="m">${mark}</div><div><h1>Mahorat</h1><p>From zero to <span>mastery</span> — tech, code, 3D, video &amp; AI</p></div></body></html>`, { waitUntil: 'networkidle' });
  await p.waitForTimeout(400);
  await p.screenshot({ path: 'store/graphics/google-play-feature-graphic.png' });
  await b.close();
  console.log('wrote store/graphics/google-play-feature-graphic.png');
})();
