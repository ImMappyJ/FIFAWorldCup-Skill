// Node.js: HTML → Lossless PNG via Puppeteer (full-page, mobile-optimized)
// Usage: node export.js analysis/report.html [analysis/report.png]
// Prerequisite: npx puppeteer browsers install chrome
// Width 750px @2x → crisp full-page PNG for mobile viewing

const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const htmlPath = process.argv[2];
if (!htmlPath) {
  console.error('Usage: node export.js <html-path> [png-path]');
  process.exit(1);
}

const pngPath = process.argv[3] || htmlPath.replace(/\.html$/, '.png');
const absHtml = path.resolve(htmlPath);
const absPng = path.resolve(pngPath);

// Ensure output directory exists
fs.mkdirSync(path.dirname(absPng), { recursive: true });

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();

  // Mobile-optimized viewport: 750px max-width matches HTML body
  await page.setViewport({ width: 750, height: 900, deviceScaleFactor: 2 });
  await page.goto(`file:///${absHtml.replace(/\\/g, '/')}`, { waitUntil: 'networkidle0' });

  const fullHeight = await page.evaluate(() => document.body.scrollHeight);
  await page.setViewport({ width: 750, height: fullHeight, deviceScaleFactor: 2 });

  await page.screenshot({ path: absPng, type: 'png', fullPage: true });
  await browser.close();

  console.log(`PNG saved: ${absPng} (750px width, ${fullHeight}px height, 2x DPI → 1500px render)`);
})();
