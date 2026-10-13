import { describe, expect, test } from 'bun:test'
import type { ShopAmenityResolutionRow } from './amenity-status'
import {
  amenityRowMatchesFilter,
  cafeFeedMode,
  feedCountLabel,
  isPopularReviewStats,
  rankShopsByDistance,
  slicePage,
} from './cafe-feed'
import { destinationPoint } from './geo'

describe('cafe feed', () => {
  test('nearby mode waits for a location, otherwise the list is paged', () => {
    const origin = { lat: 14.55, lng: 121.02 }
    expect(cafeFeedMode({ filter: 'near', query: '', origin, nearby: false })).toBe('nearby')
    expect(cafeFeedMode({ filter: 'wifi', query: '', origin, nearby: true })).toBe('nearby')
    expect(cafeFeedMode({ filter: 'wifi', query: '', origin, nearby: false })).toBe('filter')
    expect(cafeFeedMode({ filter: 'near', query: '', origin: null, nearby: false })).toBe('browse')
    expect(cafeFeedMode({ filter: 'near', query: 'arabica', origin, nearby: false })).toBe('search')
  })

  test('count label shows how many of the list are loaded', () => {
    expect(feedCountLabel(12, 2466, true)).toBe('12 of 2466 shops')
    expect(feedCountLabel(2466, 2466, false)).toBe('2466 shops')
    expect(feedCountLabel(1, 1, false)).toBe('1 shop')
    expect(feedCountLabel(8, null, true)).toBe('8 shops')
  })

  test('pages an id list without skipping or repeating', () => {
    const ids = ['a', 'b', 'c', 'd', 'e']
    expect(slicePage(ids, 0, 2)).toEqual({ page: ['a', 'b'], hasMore: true, nextOffset: 2 })
    expect(slicePage(ids, 4, 2)).toEqual({ page: ['e'], hasMore: false, nextOffset: 5 })
  })

  test('ranks shops inside the radius and drops the rest', () => {
    const origin = { lat: 14.5547, lng: 121.0244 }
    const close = destinationPoint(origin, 400, 90)
    const edge = destinationPoint(origin, 4_900, 0)
    const outside = destinationPoint(origin, 8_000, 180)
    const ranked = rankShopsByDistance([
      { id: 'outside', name: 'Outside', ...outside },
      { id: 'edge', name: 'Edge', ...edge },
      { id: 'close', name: 'Close', ...close },
    ], origin, 5_000)
    expect(ranked.map((shop) => shop.id)).toEqual(['close', 'edge'])
  })

  test('amenity filters keep trusted matches only', () => {
    const wifi = amenity('wifi', 'available', 'team_verified', { wifi_speed: 'fast' })
    expect(amenityRowMatchesFilter(wifi, 'wifi')).toBe(true)
    expect(amenityRowMatchesFilter(wifi, 'fast-wifi')).toBe(true)
    expect(amenityRowMatchesFilter(wifi, 'plugs')).toBe(false)
    expect(amenityRowMatchesFilter(
      amenity('wifi', 'available', 'reported', { wifi_speed: 'fast' }),
      'fast-wifi',
    )).toBe(false)
    expect(amenityRowMatchesFilter(
      amenity('outlets', 'available', 'community_confirmed', { outlet_reliability: 'easy' }),
      'reliable-outlets',
    )).toBe(true)
    expect(amenityRowMatchesFilter(
      amenity('outlets', 'available', 'team_verified', { outlet_reliability: 'scarce' }),
      'reliable-outlets',
    )).toBe(false)
  })

  test('popular shops need enough recommendations', () => {
    expect(isPopularReviewStats({ total_reviews: 3, recommend_pct: 70 })).toBe(true)
    expect(isPopularReviewStats({ total_reviews: 2, recommend_pct: 100 })).toBe(false)
    expect(isPopularReviewStats({ total_reviews: 5, recommend_pct: 69 })).toBe(false)
  })
})

function amenity(
  key: 'wifi' | 'outlets' | 'long_stay_wifi',
  availability: 'available' | 'unavailable',
  confidence: 'team_verified' | 'community_confirmed' | 'reported',
  extra: Partial<ShopAmenityResolutionRow> = {},
): ShopAmenityResolutionRow {
  return {
    shop_id: '00000000-0000-4000-8000-000000000001',
    amenity_key: key,
    availability,
    confidence,
    source_at: '2026-10-02T00:00:00.000Z',
    decided_count: 3,
    yes_count: 3,
    no_count: 0,
    is_stale: false,
    needs_recheck: false,
    wifi_speed: null,
    wifi_time_limit: null,
    outlet_reliability: null,
    ...extra,
  }
}
