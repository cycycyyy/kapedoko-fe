import type { Cafe, LatLng } from '../types/cafe'
import { distanceMeters } from './geo'

export type CafeFilterId =
  | 'near'
  | 'popular'
  | 'wifi'
  | 'plugs'
  | 'long-stay'
  | 'fast-wifi'
  | 'reliable-outlets'

export const CAFE_FILTERS: { id: CafeFilterId; label: string }[] = [
  { id: 'near', label: 'Near You' },
  { id: 'popular', label: 'Popular' },
  { id: 'wifi', label: 'WiFi' },
  { id: 'plugs', label: 'Plugs' },
  { id: 'long-stay', label: 'Long-stay WiFi' },
  { id: 'fast-wifi', label: 'Fast WiFi' },
  { id: 'reliable-outlets', label: 'Reliable outlets' },
]

export function cafeMatchesFilter(cafe: Cafe, filter: CafeFilterId): boolean {
  if (filter === 'near') return true
  if (filter === 'popular') return cafe.popular
  if (filter === 'wifi') return cafe.work.wifi === true
  if (filter === 'plugs') return cafe.work.plug === true
  if (filter === 'long-stay') return cafe.work.longStay === true
  if (filter === 'fast-wifi') return cafe.work.wifiSpeed === 'fast'
  if (filter === 'reliable-outlets') return cafe.work.outletReliability === 'easy'
  return true
}

export function sortCafes(cafes: Cafe[], filter: CafeFilterId, origin?: LatLng | null): Cafe[] {
  const next = [...cafes]
  if (filter === 'near' && origin) {
    next.sort((a, b) => distanceMeters(origin, a) - distanceMeters(origin, b) || a.name.localeCompare(b.name))
    return next
  }
  if (filter === 'popular') {
    next.sort((a, b) => Number(b.popular) - Number(a.popular) || b.rating - a.rating || a.name.localeCompare(b.name))
    return next
  }
  next.sort((a, b) => a.name.localeCompare(b.name))
  return next
}

export function filterCafes(
  cafes: Cafe[],
  options: { query?: string; filter?: CafeFilterId; origin?: LatLng | null },
): Cafe[] {
  const term = options.query?.trim().toLowerCase() ?? ''
  const filter = options.filter ?? 'near'
  const matched = cafes.filter((cafe) => {
    const matchesQuery =
      !term
      || cafe.name.toLowerCase().includes(term)
      || cafe.address.toLowerCase().includes(term)
    return matchesQuery && cafeMatchesFilter(cafe, filter)
  })
  return sortCafes(matched, filter, options.origin)
}
