const ALLOWED_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp'])
export const LOGO_MAX_BYTES = 2 * 1024 * 1024
export const KAPEDOKO_MARK_SRC = '/assets/kapedoko-logo_dark.png'

export function isKapedokoMark(src?: string | null): boolean {
  return !src || src === KAPEDOKO_MARK_SRC
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
