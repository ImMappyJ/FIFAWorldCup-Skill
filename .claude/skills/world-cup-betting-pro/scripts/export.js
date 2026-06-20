// Node.js: HTML → PNG via Puppeteer (fullPage, mobile-optimized)
// Usage: node export.js analysis/report.html [analysis/report.png]
// Prerequisite: npx puppeteer browsers install chrome
// Width 750px @2x DPI → crisp full-page PNG for mobile viewing
// fullPage: true → auto-fits exact content height, no blank bottom

const puppeteer = require("puppeteer");
const path = require("path");
const fs = require("fs");

const htmlPath = process.argv[2];
if (!htmlPath) {
  console.error("Usage: node export.js <html-path> [png-path]");
  process.exit(1);
}

const pngPath = process.argv[3] || htmlPath.replace(/\.html$/, ".png");
const absHtml = path.resolve(htmlPath);
const absPng = path.resolve(pngPath);

// Ensure output directory exists
fs.mkdirSync(path.dirname(absPng), { recursive: true });

(async () => {
  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();

  await page.setViewport({ width: 750, height: 900, deviceScaleFactor: 2 });
  await page.goto(`file:///${absHtml.replace(/\\/g, "/")}`, {
    waitUntil: "networkidle0",
  });

  // fullPage: true — 自适应内容高度，无留白
  await page.screenshot({ path: absPng, type: "png", fullPage: true });
  await browser.close();

  console.log(`PNG saved: ${absPng} (750px@2x, fullPage auto-height)`);
})();
