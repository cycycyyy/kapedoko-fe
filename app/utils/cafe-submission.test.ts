import { describe, expect, test } from 'bun:test'
import { isInMarikina, MARIKINA_CENTER } from './marikina'
import {
  allDayEveryDay,
  isOpenNow,
  isValidClock,
  isValidWeeklyHours,
  sameHoursEveryDay,
  summarizeHours,
} from './hours'
import { isValidPhone, optionalPhone } from './phone'
import { cafeNameError, isValidAddress, isValidCafeName } from './identity'
import { amenitiesFromStats } from './shop-mapper'
import { logoFileError } from './logo'
import { formatShopStreet } from './geocode'
import { authUserId } from './auth'

describe('marikina bounds', () => {
  test('accepts city hall', () => {
    expect(isInMarikina(MARIKINA_CENTER)).toBe(true)
  })

  test('rejects Makati', () => {
    expect(isInMarikina({ lat: 14.5547, lng: 121.0244 })).toBe(false)
  })
})

describe('hours', () => {
  test('validates clock strings', () => {
    expect(isValidClock('09:00')).toBe(true)
    expect(isValidClock('24:00')).toBe(false)
    expect(isValidClock('9:00')).toBe(false)
  })

  test('same hours fill the week', () => {
    const hours = sameHoursEveryDay('08:00', '18:00')
    expect(isValidWeeklyHours(hours)).toBe(true)
    expect(summarizeHours(hours)).toBe('8:00am–6:00pm')
  })

  test('24 hours is always open', () => {
    expect(isOpenNow(allDayEveryDay(), new Date('2026-09-07T12:00:00+08:00'))).toBe(true)
  })

  test('overnight hours carry past midnight', () => {
    const hours = sameHoursEveryDay('22:00', '02:00')
    expect(isOpenNow(hours, new Date('2026-09-07T23:30:00+08:00'))).toBe(true)
    expect(isOpenNow(hours, new Date('2026-09-08T01:30:00+08:00'))).toBe(true)
    expect(isOpenNow(hours, new Date('2026-09-08T03:00:00+08:00'))).toBe(false)
  })
})

describe('phone and identity', () => {
  test('accepts PH mobile numbers', () => {
    expect(isValidPhone('+63 917 123 4567')).toBe(true)
    expect(isValidPhone('09171234567')).toBe(true)
    expect(isValidPhone('abc')).toBe(false)
    expect(optionalPhone('')).toBeNull()
  })

  test('validates cafe names and addresses', () => {
    expect(isValidCafeName('Yardstick')).toBe(true)
    expect(cafeNameError('')).toBe('Enter the cafe name.')
    expect(isValidAddress('Shoe Ave, Marikina')).toBe(true)
    expect(isValidAddress('Short')).toBe(false)
  })
})

describe('auth user id', () => {
  test('reads id from a user object or sub from JWT claims', () => {
    expect(authUserId({ id: 'user-1' })).toBe('user-1')
    expect(authUserId({ sub: 'user-2', email: 'a@b.com' })).toBe('user-2')
    expect(authUserId(null)).toBeNull()
  })
})

describe('shop street line', () => {
  test('prefers road and barangay over the Nominatim dump', () => {
    expect(formatShopStreet({
      display_name: 'Bayan-Bayanan Avenue, Amang Rodriguez Village, Concepcion Uno, District II, Marikina, Eastern Manila District, Metro Manila, 1807, Philippines',
      address: { road: 'Bayan-Bayanan Avenue', suburb: 'Concepcion Uno', city: 'Marikina' },
    })).toBe('Bayan-Bayanan Avenue, Concepcion Uno, Marikina')
  })

  test('strips region noise from a display name', () => {
    expect(formatShopStreet({
      display_name: 'Shoe Ave, San Roque, Marikina, Metro Manila, 1800, Philippines',
    })).toBe('Shoe Ave, San Roque, Marikina')
  })
})

describe('amenities from reviews', () => {
  test('stays unknown below the review threshold', () => {
    expect(amenitiesFromStats({
      shop_id: '1',
      total_reviews: 2,
      wifi_yes_count: 2,
      wifi_available_pct: 100,
      wifi_speed_mode: 'fast',
      wifi_time_limit_mode: 'unlimited',
      power_yes_count: 2,
      power_available_pct: 100,
      recommend_pct: 100,
    })).toEqual([])
  })

  test('requires enough reviews before claiming no amenities', () => {
    expect(amenitiesFromStats({
      shop_id: '1',
      total_reviews: 5,
      wifi_yes_count: 0,
      wifi_available_pct: 0,
      wifi_speed_mode: null,
      wifi_time_limit_mode: null,
      power_yes_count: 0,
      power_available_pct: 0,
      recommend_pct: 40,
    })).toBe('none')
  })
})

describe('logo files', () => {
  test('rejects oversized or wrong-type files', () => {
    const png = { type: 'image/png', size: 1200 } as File
    const pdf = { type: 'application/pdf', size: 1200 } as File
    const huge = { type: 'image/jpeg', size: 3 * 1024 * 1024 } as File
    expect(logoFileError(png)).toBeNull()
    expect(logoFileError(pdf)).toBe('Use a JPG, PNG, or WebP image.')
    expect(logoFileError(huge)).toBe('Keep the logo under 2 MB.')
  })
})
