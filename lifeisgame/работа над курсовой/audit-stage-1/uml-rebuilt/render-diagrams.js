const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const OUT = __dirname;
const diagramFiles = fs.readdirSync(OUT).filter(name => /^\d{2}-.*\.svg$/.test(name)).sort();

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 3000, height: 1800 }, deviceScaleFactor: 1 });

  for (const svgName of diagramFiles) {
    const svgPath = path.join(OUT, svgName);
    await page.goto(`file://${svgPath}`);
    await page.screenshot({ path: svgPath.replace(/\.svg$/, '.png'), type: 'png', omitBackground: false });
  }

  const contactPath = path.join(OUT, 'contact-sheet.html');
  await page.setViewportSize({ width: 3600, height: 1000 });
  await page.goto(`file://${contactPath}`);
  await page.waitForFunction(() => Array.from(document.images).every(image => image.complete));
  await page.screenshot({ path: path.join(OUT, 'contact-sheet.png'), type: 'png', fullPage: true, omitBackground: false });

  await browser.close();
  console.log(`Rendered ${diagramFiles.length} PNG files and contact-sheet.png`);
})().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
