/**
 * Composites the KapeDoko pin onto 1024×1024 masters for @capacitor/assets.
 * Run: bun scripts/generate-app-icons.ts
 */
import { mkdir } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import sharp from 'sharp'

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..')
const RESOURCES = join(ROOT, 'resources')
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
await Promise.all([
  sharp(iconOnly).png().toFile(join(RESOURCES, 'icon-only.png')),
  sharp(foreground).png().toFile(join(RESOURCES, 'icon-foreground.png')),
  sharp(background).png().toFile(join(RESOURCES, 'icon-background.png')),
])

console.log(`Wrote ${SIZE}×${SIZE} icon masters to resources/`)
