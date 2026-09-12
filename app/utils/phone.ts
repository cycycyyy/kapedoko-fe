const PHONE_PATTERN = /^\+?[0-9][0-9\s\-()]{6,18}$/

export function normalizePhone(value: string): string {
  return value.trim().replace(/\s+/g, ' ')
}

export function isValidPhone(value: string): boolean {
  const phone = normalizePhone(value)
  if (!phone) return false
  const digits = phone.replace(/\D/g, '')
  return PHONE_PATTERN.test(phone) && digits.length >= 7 && digits.length <= 15
}

export function optionalPhone(value: string): string | null {
  const phone = normalizePhone(value)
  if (!phone) return null
  return phone
}
