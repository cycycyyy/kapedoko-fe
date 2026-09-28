import { describe, expect, test } from 'bun:test'
import type { Cafe } from '../types/cafe'
import { UNKNOWN_WORK } from './shop-mapper'
import { cafeMatchesFilter, filterCafes } from './cafe-filters'

function cafe(partial: Partial<Cafe> & Pick<Cafe, 'id' | 'name'>): Cafe {
  return {
    address: 'Makati',
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
    lat: 14.55,
    lng: 121.02,
    markerTier: 'standard',
    ...partial,
  }
}

describe('live cafe filters', () => {
  const shops = [
    cafe({
      id: 'near',
      name: 'Near Cup',
      lat: 14.5547,
      lng: 121.0244,
      work: { ...UNKNOWN_WORK, known: true, wifi: true, longStay: true, wifiSpeed: 'fast', wifiTimeLimit: 'unlimited', plug: true, outletReliability: 'easy' },
      amenities: ['wifi', 'plug'],
      popular: true,
      rating: 5,
    }),
    cafe({
      id: 'far',
      name: 'Far Cup',
      lat: 14.7,
      lng: 121.1,
      work: { ...UNKNOWN_WORK, known: true, wifi: false, plug: true, outletReliability: 'scarce' },
      amenities: ['plug'],
    }),
    cafe({ id: 'new', name: 'New Cup' }),
  ]

  test('does not treat unconfirmed amenities as a match', () => {
    expect(cafeMatchesFilter(shops[2]!, 'wifi')).toBe(false)
    expect(cafeMatchesFilter(shops[2]!, 'plugs')).toBe(false)
    expect(cafeMatchesFilter(shops[2]!, 'long-stay')).toBe(false)
  })

  test('filters long-stay, fast wifi, and reliable outlets from aggregates', () => {
    expect(filterCafes(shops, { filter: 'long-stay' }).map((item) => item.id)).toEqual(['near'])
    expect(filterCafes(shops, { filter: 'fast-wifi' }).map((item) => item.id)).toEqual(['near'])
    expect(filterCafes(shops, { filter: 'reliable-outlets' }).map((item) => item.id)).toEqual(['near'])
    expect(filterCafes(shops, { filter: 'plugs' }).map((item) => item.id)).toEqual(['far', 'near'])
  })

  test('sorts Near You by real distance and leaves unknown shops in browse results', () => {
    const near = filterCafes(shops, { filter: 'near', origin: { lat: 14.5547, lng: 121.0244 } })
    expect(near.map((item) => item.id)[0]).toBe('near')
    expect(near.map((item) => item.id)).toContain('new')
  })
})
