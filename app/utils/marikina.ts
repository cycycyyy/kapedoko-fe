import type { LatLng } from '../types/cafe'

/** Padded Marikina city limits for the launch geography. */
export const MARIKINA_BOUNDS = {
  south: 14.618,
  north: 14.678,
  west: 121.078,
  east: 121.138,
} as const

export const MARIKINA_CENTER: LatLng = {
  lat: 14.6507,
  lng: 121.1029,
}

export function isInMarikina(point: LatLng): boolean {
  return (
    point.lat >= MARIKINA_BOUNDS.south
    && point.lat <= MARIKINA_BOUNDS.north
    && point.lng >= MARIKINA_BOUNDS.west
    && point.lng <= MARIKINA_BOUNDS.east
  )
}

export function clampToMarikina(point: LatLng): LatLng {
  return {
    lat: Math.min(MARIKINA_BOUNDS.north, Math.max(MARIKINA_BOUNDS.south, point.lat)),
    lng: Math.min(MARIKINA_BOUNDS.east, Math.max(MARIKINA_BOUNDS.west, point.lng)),
  }
}
