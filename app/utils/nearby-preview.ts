import type { Cafe, LatLng } from '../types/cafe'
import { distanceMeters } from './geo'
import { boundsFromRadius, type GeoBounds } from './geography'

export function nearbyPreviewBounds(
  origin: LatLng,
  radiusMeters: number,
): GeoBounds {
  return boundsFromRadius(origin, radiusMeters)
}

export function cafesInsideNearbyRadius(
  cafes: Cafe[],
  origin: LatLng | null | undefined,
  radiusMeters: number | null | undefined,
): Cafe[] {
  if (!origin || radiusMeters == null || !Number.isFinite(radiusMeters) || radiusMeters < 0) {
    return []
  }

  return cafes
    .filter((cafe) => (
      Number.isFinite(cafe.lat)
      && Number.isFinite(cafe.lng)
      && distanceMeters(origin, cafe) <= radiusMeters
    ))
    .sort((a, b) => (
      distanceMeters(origin, a) - distanceMeters(origin, b)
      || a.name.localeCompare(b.name)
    ))
}
