import { describe, expect, test } from 'bun:test'
import {
  METRO_MANILA_CENTER,
  boundsContain,
  boundsFromRadius,
  clampQueryBounds,
  coverageBounds,
  isInCoverage,
  padBounds,
  pointInBounds,
} from './geography'
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
import { amenitiesFromStats, amenityGapCopy, mapShopToCafe, shopImageUrl, shopLogoUrl, UNKNOWN_WORK, workFactsFromStats } from './shop-mapper'
import { KAPEDOKO_MARK_SRC, logoFileError } from './logo'
import { formatShopStreet } from './geocode'
import { authUserId } from './auth'
import { suggestCafes } from './cafe-search'
import { googleMapsDirectionsUrl } from './maps'
import type { Cafe } from '../types/cafe'
import type { ShopRow } from '../types/shop'

describe('metro manila coverage', () => {
  test('accepts the fallback center', () => {
    expect(isInCoverage(METRO_MANILA_CENTER)).toBe(true)
  })

  test('accepts representative NCR cities', () => {
    expect(isInCoverage({ lat: 14.6507, lng: 121.1029 })).toBe(true) // Marikina
    expect(isInCoverage({ lat: 14.5547, lng: 121.0244 })).toBe(true) // Makati
    expect(isInCoverage({ lat: 14.619, lng: 121.051 })).toBe(true) // Quezon City
    expect(isInCoverage({ lat: 14.423, lng: 121.047 })).toBe(true) // Muntinlupa
    expect(isInCoverage({ lat: 14.5894, lng: 120.9842 })).toBe(true) // Manila
  })

  test('rejects points outside NCR', () => {
    expect(isInCoverage({ lat: 14.586, lng: 121.175 })).toBe(false) // Antipolo
    expect(isInCoverage({ lat: 14.359, lng: 121.056 })).toBe(false) // San Pedro
  })

  test('fallback sits inside the region bounds', () => {
    const bounds = coverageBounds()
    expect(METRO_MANILA_CENTER.lat).toBeGreaterThan(bounds.south)
    expect(METRO_MANILA_CENTER.lat).toBeLessThan(bounds.north)
    expect(METRO_MANILA_CENTER.lng).toBeGreaterThan(bounds.west)
    expect(METRO_MANILA_CENTER.lng).toBeLessThan(bounds.east)
  })

  test('viewport queries pad and clamp map bounds', () => {
    const origin = METRO_MANILA_CENTER
    const tight = boundsFromRadius(origin, 1_000)
    const padded = padBounds(tight, 0.3)
    expect(boundsContain(padded, tight)).toBe(true)
    expect(pointInBounds(origin, tight)).toBe(true)

    const city = boundsFromRadius(origin, 20_000)
    const clamped = clampQueryBounds(origin, city, 8_000)
    expect(clamped.north - clamped.south).toBeLessThan(city.north - city.south)
    expect(pointInBounds(origin, clamped)).toBe(true)
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

  test('keeps the Nominatim city instead of forcing Marikina', () => {
    expect(formatShopStreet({
      display_name: '26th Street, Bonifacio Global City, Taguig, Metro Manila, 1634, Philippines',
      address: { road: '26th Street', suburb: 'Bonifacio Global City', city: 'Taguig' },
    })).toBe('26th Street, Bonifacio Global City, Taguig')
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

  test('says when amenities are still unconfirmed', () => {
    expect(workFactsFromStats({
      shop_id: '1',
      total_reviews: 2,
      wifi_yes_count: 2,
      wifi_available_pct: 100,
      wifi_speed_mode: 'fast',
      wifi_time_limit_mode: 'unlimited',
      power_yes_count: 2,
      power_available_pct: 100,
      recommend_pct: 100,
    }).known).toBe(false)
    expect(amenityGapCopy(UNKNOWN_WORK, [])).toBe('WiFi and outlets not confirmed yet')
    expect(amenityGapCopy({
      ...UNKNOWN_WORK,
      known: true,
      wifi: false,
      plug: false,
    }, 'none')).toBe('No WiFi or power outlets')
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

describe('shop image urls', () => {
  const shop = {
    logo_object_key: 'shop-logos/user/logo.png',
    cover_photo_url: null as string | null,
  }

  test('builds a public r2.dev url', () => {
    expect(shopImageUrl(shop, 'https://pub-abc.r2.dev/')).toBe(
      'https://pub-abc.r2.dev/shop-logos/user/logo.png',
    )
  })

  test('ignores the private S3 API host', () => {
    expect(
      shopImageUrl(shop, 'https://80fe00aa3cade8afa8a9436eb980192f.r2.cloudflarestorage.com'),
    ).toBe(KAPEDOKO_MARK_SRC)
  })

  test('exposes a logo url only for public assets', () => {
    expect(shopLogoUrl(shop, 'https://pub-abc.r2.dev')).toBe(
      'https://pub-abc.r2.dev/shop-logos/user/logo.png',
    )
    expect(shopLogoUrl(shop, '')).toBeNull()
  })
})

describe('shop to cafe mapping', () => {
  const shop: ShopRow = {
    id: 'shop-1',
    name: 'Yardstick',
    description: null,
    address: 'Makati Avenue, Makati City',
    latitude: 14.5547,
    longitude: 121.0244,
    categories: [],
    hours: null,
    cover_photo_url: null,
    logo_object_key: 'shop-logos/user/logo.png',
    contact_number: null,
    status: 'approved',
    submitted_by: null,
    reviewed_by: null,
    reviewed_at: null,
    rejection_reason: null,
    created_at: '2026-09-09T00:00:00.000Z',
    updated_at: '2026-09-09T00:00:00.000Z',
  }

  test('carries the effective marker tier and public logo', () => {
    const cafe = mapShopToCafe(shop, null, 'https://pub-abc.r2.dev', 'promoted')
    expect(cafe.markerTier).toBe('promoted')
    expect(cafe.image).toBe('https://pub-abc.r2.dev/shop-logos/user/logo.png')
  })

  test('defaults unpaid shops to the standard pin', () => {
    expect(mapShopToCafe(shop).markerTier).toBe('standard')
  })
})

describe('cafe search suggestions', () => {
  const stub = (id: string, name: string, address: string, lat: number, lng: number): Cafe => ({
    id,
    name,
    address,
    image: '',
    photos: [],
    open: true,
    status: 'Open',
    hoursHint: '',
    amenities: [],
    work: { ...UNKNOWN_WORK },
    popular: false,
    rating: 0,
    ratingLabel: 'New',
    reviews: [],
    lat,
    lng,
    markerTier: 'standard',
  })

  test('ranks name prefix matches ahead of address hits', () => {
    const origin = { lat: 14.5547, lng: 121.0244 }
    const cafes = [
      stub('far', 'Other Cup', 'Makati Avenue, Makati', 14.6, 121.08),
      stub('near', 'Makati Cafe', 'Makati Avenue, Makati', 14.5547, 121.0244),
      stub('name', 'Makati Roasters', 'Poblacion, Makati', 14.57, 121.03),
    ]

    expect(suggestCafes(cafes, 'maka', origin).map((cafe) => cafe.id)).toEqual([
      'near',
      'name',
      'far',
    ])
  })
})

describe('google maps directions', () => {
  test('builds a free Google Maps directions url from coordinates', () => {
    expect(googleMapsDirectionsUrl(14.5547, 121.0244)).toBe(
      'https://www.google.com/maps/dir/?api=1&destination=14.5547%2C121.0244',
    )
  })
})
