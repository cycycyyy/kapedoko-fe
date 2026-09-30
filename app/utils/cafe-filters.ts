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

export type CafeFilterIcon =
  | 'navigation'
  | 'flame'
  | 'wifi'
  | 'plug'
  | 'hourglass'
  | 'zap'
  | 'battery-charging'

export const CAFE_FILTERS: { id: CafeFilterId; label: string; icon: CafeFilterIcon }[] = [
  { id: 'near', label: 'Near You', icon: 'navigation' },
  { id: 'popular', label: 'Popular', icon: 'flame' },
  { id: 'wifi', label: 'WiFi', icon: 'wifi' },
  { id: 'plugs', label: 'Plugs', icon: 'plug' },
  { id: 'long-stay', label: 'Long-stay WiFi', icon: 'hourglass' },
  { id: 'fast-wifi', label: 'Fast WiFi', icon: 'zap' },
  { id: 'reliable-outlets', label: 'Reliable outlets', icon: 'battery-charging' },
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

export function cafeWithinRadius(
  cafe: Cafe,
  origin: LatLng | null | undefined,
  radiusMeters: number | null | undefined,
): boolean {
  if (!origin || radiusMeters == null || !Number.isFinite(radiusMeters)) return true
  return distanceMeters(origin, cafe) <= radiusMeters
}

export function filterCafes(
  cafes: Cafe[],
  options: {
    query?: string
    filter?: CafeFilterId
    origin?: LatLng | null
    radiusMeters?: number | null
  },
): Cafe[] {
  const term = options.query?.trim().toLowerCase() ?? ''
  const filter = options.filter ?? 'near'
  const origin = options.origin
  const radiusMeters = filter === 'near' ? options.radiusMeters : null
  const matched = cafes.filter((cafe) => {
    const matchesQuery =
      !term
      || cafe.name.toLowerCase().includes(term)
      || cafe.address.toLowerCase().includes(term)
    return matchesQuery
      && cafeMatchesFilter(cafe, filter)
      && cafeWithinRadius(cafe, origin, radiusMeters)
  })
  return sortCafes(matched, filter, origin)
}
