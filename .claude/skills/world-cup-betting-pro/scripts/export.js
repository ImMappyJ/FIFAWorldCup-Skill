// Node.js: HTML → Lossless PNG via Puppeteer (full-page, mobile-optimized)
// Usage: node export.js analysis/report.html [analysis/report.png]
// Prerequisite: npx puppeteer browsers install chrome
// Width 750px @2x → crisp full-page PNG for mobile viewing
// Auto-fits to exact content height — no blank bottom

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

  // Set viewport to target width with a reasonable initial height
  await page.setViewport({ width: 750, height: 1200, deviceScaleFactor: 2 });
  await page.goto(`file:///${absHtml.replace(/\\/g, '/')}`, { waitUntil: 'networkidle0' });

  // Get the true full-page height (content only, no extra blank space)
  const fullHeight = await page.evaluate(() => {
    return Math.max(
      document.body.scrollHeight,
      document.body.offsetHeight,
      document.documentElement.scrollHeight,
      document.documentElement.offsetHeight
    );
  });

  // Set viewport to exact content height for clean rendering
  await page.setViewport({ width: 750, height: fullHeight, deviceScaleFactor: 2 });

  // fullPage: true captures exactly the document content — no blank bottom
  await page.screenshot({ path: absPng, type: 'png', fullPage: true });
  await browser.close();

  const renderWidth = 750 * 2;
  const renderHeight = fullHeight * 2;
  console.log(`PNG saved: ${absPng}`);
  console.log(`  Content: ${750}x${fullHeight}px logical → ${renderWidth}x${renderHeight}px @2x`);
  console.log(`  Height: ${fullHeight}px (auto-fit — no blank bottom)`);
})();
