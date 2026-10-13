import { describe, expect, test } from 'bun:test'
import { isInCoverage } from './geography'
import {
  cafeHasMapPoint,
  cafePlaceLine,
  googleMapsDirectionsUrl,
  ONBOARDING_TEACH_MAP,
} from './maps'

describe('cafePlaceLine', () => {
  test('uses the last two address parts as the locality', () => {
    expect(
      cafePlaceLine('123 Shoe Ave, Barangka, Marikina City', 'Yardstick'),
    ).toBe('Barangka, Marikina City')
  })

  test('falls back to a single address part, then the cafe name', () => {
    expect(cafePlaceLine('Marikina City', 'Yardstick')).toBe('Marikina City')
    expect(cafePlaceLine('Yardstick', 'Yardstick')).toBe('Yardstick')
    expect(cafePlaceLine('', 'Yardstick')).toBe('Yardstick')
  })
})

describe('cafeHasMapPoint', () => {
  test('rejects missing or zeroed coordinates', () => {
    expect(cafeHasMapPoint(14.65, 121.1)).toBe(true)
    expect(cafeHasMapPoint(0, 0)).toBe(false)
    expect(cafeHasMapPoint(Number.NaN, 121)).toBe(false)
  })
})

describe('ONBOARDING_TEACH_MAP', () => {
  test('pins a real Metro Manila street, not a zeroed placeholder', () => {
    expect(isInCoverage({ lat: ONBOARDING_TEACH_MAP.lat, lng: ONBOARDING_TEACH_MAP.lng })).toBe(true)
    expect(ONBOARDING_TEACH_MAP.endZoom).toBeGreaterThan(ONBOARDING_TEACH_MAP.startZoom)
    expect(ONBOARDING_TEACH_MAP.label).toBe('Exact location')
  })
})

describe('googleMapsDirectionsUrl', () => {
  test('points Google Maps at the cafe', () => {
    expect(googleMapsDirectionsUrl(14.65, 121.1)).toContain('destination=14.65%2C121.1')
  })
})
