const NAME_MIN = 2
const NAME_MAX = 80
const ADDRESS_MIN = 8
const ADDRESS_MAX = 200

export function normalizeCafeName(value: string): string {
  return value.trim().replace(/\s+/g, ' ')
}

export function isValidCafeName(value: string): boolean {
  const name = normalizeCafeName(value)
  return name.length >= NAME_MIN && name.length <= NAME_MAX
}

export function cafeNameError(value: string): string | null {
  const name = normalizeCafeName(value)
  if (!name) return 'Enter the cafe name.'
  if (name.length < NAME_MIN) return 'Use at least 2 characters.'
  if (name.length > NAME_MAX) return 'Keep the name under 80 characters.'
  return null
}

export function normalizeAddress(value: string): string {
  return value.trim().replace(/\s+/g, ' ')
}

export function isValidAddress(value: string): boolean {
  const address = normalizeAddress(value)
  return address.length >= ADDRESS_MIN && address.length <= ADDRESS_MAX
}

export function addressError(value: string): string | null {
  const address = normalizeAddress(value)
  if (!address) return 'Confirm the street address.'
  if (address.length < ADDRESS_MIN) return 'Add a fuller street address.'
  if (address.length > ADDRESS_MAX) return 'Keep the address under 200 characters.'
  return null
}
