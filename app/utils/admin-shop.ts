import { addressError, cafeNameError } from './identity'
import { isValidWeeklyHours } from './hours'
import { isValidPhone } from './phone'
import { logoFileError } from './logo'
import type { WeeklyHours } from '../types/shop'

export interface AdminCafeInput {
  name: string
  address: string
  lat: number | null
  lng: number | null
  phone: string
  hours: WeeklyHours | null
  logoFile: File | null
}

export function isValidLatitude(value: number | null | undefined): boolean {
  return typeof value === 'number' && Number.isFinite(value) && value >= -90 && value <= 90
}

export function isValidLongitude(value: number | null | undefined): boolean {
  return typeof value === 'number' && Number.isFinite(value) && value >= -180 && value <= 180
}

export function adminCafeErrors(input: AdminCafeInput): {
  name: string | null
  address: string | null
  pin: string | null
  phone: string | null
  hours: string | null
  logo: string | null
} {
  const phone = input.phone.trim()
  return {
    name: cafeNameError(input.name),
    address: addressError(input.address),
    pin: isValidLatitude(input.lat) && isValidLongitude(input.lng) ? null : 'Pin the cafe on the map.',
    phone: !phone || isValidPhone(phone) ? null : 'Use a phone number like 0917 123 4567.',
    hours: isValidWeeklyHours(input.hours) ? null : 'Check the opening hours and try again.',
    logo: logoFileError(input.logoFile),
  }
}

export function adminCafeHasErrors(input: AdminCafeInput): boolean {
  return Object.values(adminCafeErrors(input)).some(Boolean)
}
