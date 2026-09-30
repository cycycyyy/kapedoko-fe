export const NEARBY_RADIUS_PRESETS_KM = [1, 3, 5, 10, 20] as const

export type NearbyRadiusKm = (typeof NEARBY_RADIUS_PRESETS_KM)[number]

export const DEFAULT_NEARBY_RADIUS_KM: NearbyRadiusKm = 5

export const NEARBY_RADIUS_KEY = 'kapedoko-nearby-radius-km'

export function nearbyRadiusMeters(km: NearbyRadiusKm): number {
  return km * 1000
}

export function isNearbyRadiusKm(value: unknown): value is NearbyRadiusKm {
  return typeof value === 'number'
    && Number.isInteger(value)
    && (NEARBY_RADIUS_PRESETS_KM as readonly number[]).includes(value)
}

export function normalizeNearbyRadiusKm(value: unknown): NearbyRadiusKm {
  if (isNearbyRadiusKm(value)) return value
  if (typeof value === 'string' && value.trim()) {
    const parsed = Number(value)
    if (isNearbyRadiusKm(parsed)) return parsed
  }
  return DEFAULT_NEARBY_RADIUS_KM
}

export function readNearbyRadiusKm(): NearbyRadiusKm {
  if (!import.meta.client) return DEFAULT_NEARBY_RADIUS_KM
  try {
    return normalizeNearbyRadiusKm(window.localStorage.getItem(NEARBY_RADIUS_KEY))
  } catch {
    return DEFAULT_NEARBY_RADIUS_KM
  }
}

export function writeNearbyRadiusKm(km: NearbyRadiusKm): void {
  if (!import.meta.client) return
  try {
    window.localStorage.setItem(NEARBY_RADIUS_KEY, String(normalizeNearbyRadiusKm(km)))
  } catch {
    /* private mode still lets this visit continue */
  }
}
