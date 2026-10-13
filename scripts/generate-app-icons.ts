/**
 * Composites the KapeDoko pin onto 1024×1024 masters for @capacitor/assets
 * and writes the website favicon set in public/.
 * Run: bun scripts/generate-app-icons.ts
 */
import { mkdir, readFile, writeFile } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import sharp from 'sharp'

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..')
const RESOURCES = join(ROOT, 'resources')
const PUBLIC = join(ROOT, 'public')
const PIN_SVG = join(RESOURCES, 'pin.svg')
const SIZE = 1024
const BACKGROUND = '#FAF8F5'
/** iOS / legacy Android: pin stays inside the squircle. */
const ICON_PIN_HEIGHT = Math.round(SIZE * 0.62)
/** Android adaptive XML insets 16.7%, so the mark can fill more of this canvas. */
const FOREGROUND_PIN_HEIGHT = Math.round(SIZE * 0.9)

async function pinBuffer(height: number) {
  return sharp(PIN_SVG, { density: 512 })
    .resize({ height, fit: 'inside' })
    .png()
    .toBuffer()
}

async function composePin(height: number, background: { r: number; g: number; b: number; alpha: number }) {
  const pin = await pinBuffer(height)
  const { width, height: pinHeight } = await sharp(pin).metadata()
  const left = Math.round((SIZE - (width ?? height)) / 2)
  const top = Math.round((SIZE - (pinHeight ?? height)) / 2)
  return sharp({
    create: {
      width: SIZE,
      height: SIZE,
      channels: 4,
      background,
    },
  })
    .composite([{ input: pin, left, top }])
    .png()
    .toBuffer()
}

const foreground = await composePin(FOREGROUND_PIN_HEIGHT, { r: 0, g: 0, b: 0, alpha: 0 })
const iconFace = await composePin(ICON_PIN_HEIGHT, { r: 250, g: 248, b: 245, alpha: 1 })

const background = await sharp({
  create: {
    width: SIZE,
    height: SIZE,
    channels: 3,
    background: BACKGROUND,
  },
})
  .png()
  .toBuffer()

const iconOnly = await sharp(iconFace)
  .flatten({ background: BACKGROUND })
  .removeAlpha()
  .png()
  .toBuffer()

await mkdir(RESOURCES, { recursive: true })
await mkdir(PUBLIC, { recursive: true })

const png32 = await sharp(iconOnly).resize(32, 32).png().toBuffer()
const png16 = await sharp(iconOnly).resize(16, 16).png().toBuffer()
const pinSource = await readFile(PIN_SVG, 'utf8')
const pinD = pinSource.match(/id="pin"\s+d="([^"]+)"/)?.[1]
const steamD = pinSource.match(/<path\s+d="(M18\.597[^"]+)"/)?.[1]
if (!pinD || !steamD) {
  throw new Error('Could not read pin/steam paths from resources/pin.svg')
}
// Favicon SVG engines often skip nested <svg>, <use href>, and clipPath.
const faviconSvg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="KapeDoko">
  <rect width="64" height="64" fill="${BACKGROUND}"/>
  <g transform="translate(9 2)">
    <path d="${pinD}" fill="#1F6F6B"/>
    <circle cx="23.0285" cy="22.7259" r="15.889" fill="#FFFFFF"/>
    <circle cx="23.0284" cy="22.7259" r="10.369" fill="#D9793B"/>
    <path d="${steamD}" fill="#1F6F6B"/>
  </g>
</svg>
`

await Promise.all([
  sharp(iconOnly).png().toFile(join(RESOURCES, 'icon-only.png')),
  sharp(foreground).png().toFile(join(RESOURCES, 'icon-foreground.png')),
  sharp(background).png().toFile(join(RESOURCES, 'icon-background.png')),
  sharp(png32).png().toFile(join(PUBLIC, 'favicon-32x32.png')),
  sharp(png16).png().toFile(join(PUBLIC, 'favicon-16x16.png')),
  sharp(iconOnly).resize(180, 180).png().toFile(join(PUBLIC, 'apple-touch-icon.png')),
  writeFile(join(PUBLIC, 'favicon.ico'), pngToIco([
    { size: 16, data: png16 },
    { size: 32, data: png32 },
  ])),
  writeFile(join(PUBLIC, 'favicon.svg'), faviconSvg),
])

console.log(`Wrote ${SIZE}×${SIZE} icon masters to resources/ and favicons to public/`)

function pngToIco(images: { size: number; data: Buffer }[]): Buffer {
  const header = Buffer.alloc(6)
  header.writeUInt16LE(0, 0)
  header.writeUInt16LE(1, 2)
  header.writeUInt16LE(images.length, 4)
  const dirs: Buffer[] = []
  let offset = 6 + 16 * images.length
  for (const image of images) {
    const dir = Buffer.alloc(16)
    dir.writeUInt8(image.size === 256 ? 0 : image.size, 0)
    dir.writeUInt8(image.size === 256 ? 0 : image.size, 1)
    dir.writeUInt8(0, 2)
    dir.writeUInt8(0, 3)
    dir.writeUInt16LE(1, 4)
    dir.writeUInt16LE(32, 6)
    dir.writeUInt32LE(image.data.length, 8)
    dir.writeUInt32LE(offset, 12)
    dirs.push(dir)
    offset += image.data.length
  }
  return Buffer.concat([header, ...dirs, ...images.map((image) => image.data)])
}
