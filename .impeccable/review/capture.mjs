import { chromium } from 'playwright'
import { mkdir } from 'node:fs/promises'
import { join } from 'node:path'

const outDir = '/Users/loisejane/Documents/mine/kapedoko/kapedoko-fe/.impeccable/review'
await mkdir(outDir, { recursive: true })

const browser = await chromium.launch({ headless: true })

async function open(width, height) {
  const page = await browser.newPage({
    viewport: { width, height },
    deviceScaleFactor: 2,
  })
  await page.emulateMedia({ reducedMotion: 'reduce' })
  return page
}

async function waitForSearch(page) {
  await page.waitForSelector('.search-hero h1', { state: 'visible', timeout: 20000 })
  await page.waitForTimeout(500)
}

async function shot(page, name) {
  await page.screenshot({
    path: join(outDir, `${name}.png`),
    fullPage: true,
  })
}

const mobile = await open(390, 844)
await mobile.goto('http://localhost:3000/app/search?q=toby', { waitUntil: 'domcontentloaded' })
await waitForSearch(mobile)
const queryValue = await mobile.locator('.search-form input').inputValue()
const cardCount = await mobile.locator('.cafe-card').count()
const href = mobile.url()
await shot(mobile, 'mobile')
await mobile.close()

const desktop = await open(1440, 900)
await desktop.goto('http://localhost:3000/app/search?q=toby', { waitUntil: 'domcontentloaded' })
await waitForSearch(desktop)
await shot(desktop, 'desktop')
await desktop.close()

const empty = await open(390, 844)
await empty.goto('http://localhost:3000/app/search?q=bubbalab', { waitUntil: 'domcontentloaded' })
await waitForSearch(empty)
const emptyCount = await empty.locator('.cafe-card').count()
const emptyValue = await empty.locator('.search-form input').inputValue()
await shot(empty, 'mobile-empty')
await empty.close()

const all = await open(390, 844)
await all.goto('http://localhost:3000/app/search', { waitUntil: 'domcontentloaded' })
await waitForSearch(all)
await shot(all, 'mobile-all')
await all.close()

const home = await open(390, 844)
await home.goto('http://localhost:3000/app', { waitUntil: 'domcontentloaded' })
await home.waitForSelector('.home-search input', { state: 'visible', timeout: 20000 })
await home.locator('.home-search input').fill('commune')
await home.locator('.home-search__submit').click()
await waitForSearch(home)
const fromHomeValue = await home.locator('.search-form input').inputValue()
const fromHomeCount = await home.locator('.cafe-card').count()
await shot(home, 'from-home')
await home.close()

await browser.close()

console.log(JSON.stringify({
  href,
  queryValue,
  cardCount,
  emptyCount,
  emptyValue,
  fromHomeValue,
  fromHomeCount,
}, null, 2))
