const ALLOWED_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp'])
export const LOGO_MAX_BYTES = 2 * 1024 * 1024
const LEGACY_MARKS = new Set([
  '/assets/kapedoko-logo_dark.png',
  '/assets/kapedoko-logo_light.png',
])

/** Legacy yellow plate SVG — promo pin logo fallback only. */
export const KAPEDOKO_MARK_SRC = '/assets/kapedoko-mark.svg'

/** Coffee bean pin for selected map markers and photo placeholders. */
export const KAPEDOKO_BEAN_PIN_SRC = '/assets/bean-pin.png'

const PLACEHOLDER_MARKS = new Set([
  KAPEDOKO_MARK_SRC,
  KAPEDOKO_BEAN_PIN_SRC,
  ...LEGACY_MARKS,
])

export function isKapedokoMark(src?: string | null): boolean {
  return !src || PLACEHOLDER_MARKS.has(src)
}

export function logoFileError(file: File | null): string | null {
  if (!file) return null
  if (!ALLOWED_TYPES.has(file.type)) return 'Use a JPG, PNG, or WebP image.'
  if (file.size > LOGO_MAX_BYTES) return 'Keep the logo under 2 MB.'
  return null
}

export function isAllowedLogo(file: File): boolean {
  return logoFileError(file) === null
}
