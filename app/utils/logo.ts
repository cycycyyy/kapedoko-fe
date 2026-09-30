const ALLOWED_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp'])
export const LOGO_MAX_BYTES = 2 * 1024 * 1024

/** App mark used in logo slots when a cafe has no assigned logo. */
export const KAPEDOKO_APP_LOGO_SRC = '/assets/kapedoko-logo_dark.png'
export const KAPEDOKO_APP_LOGO_LIGHT_SRC = '/assets/kapedoko-logo_light.png'

const LEGACY_MARKS = new Set([
  KAPEDOKO_APP_LOGO_SRC,
  KAPEDOKO_APP_LOGO_LIGHT_SRC,
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

export function cafeDisplayLogo(src?: string | null): string {
  if (!src || isKapedokoMark(src)) return KAPEDOKO_APP_LOGO_SRC
  return src
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
