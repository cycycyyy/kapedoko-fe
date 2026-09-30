import type { LatLng } from '../types/cafe'
import { coverageBounds, isInCoverage } from './geography'

const NOMINATIM = 'https://nominatim.openstreetmap.org'

interface NominatimPlace {
  display_name?: string
  lat?: string
  lon?: string
  address?: {
    road?: string
    pedestrian?: string
    residential?: string
    suburb?: string
    neighbourhood?: string
    village?: string
    city?: string
    town?: string
    municipality?: string
  }
}

const REGION_NOISE = /^(philippines|metro manila|national capital region|eastern manila( district)?|district( i{1,3})?|\d{4})$/i

export function formatShopStreet(place: Pick<NominatimPlace, 'display_name' | 'address'>): string {
  const street =
    place.address?.road ||
    place.address?.pedestrian ||
    place.address?.residential ||
    ''
  const barangay =
    place.address?.suburb ||
    place.address?.neighbourhood ||
    place.address?.village ||
    ''
  const city =
    place.address?.city ||
    place.address?.town ||
    place.address?.municipality ||
    ''
  const fromParts = [street, barangay, city].filter(Boolean)
  if (street) return [...new Set(fromParts)].join(', ')

  const kept = (place.display_name || '')
    .split(',')
    .map((part) => part.trim())
    .filter((part) => part && !REGION_NOISE.test(part))
    .slice(0, 3)

  return kept.join(', ')
}

async function nominatim<T>(path: string, signal?: AbortSignal): Promise<T | null> {
  try {
    const response = await fetch(`${NOMINATIM}${path}`, {
      headers: { Accept: 'application/json' },
      signal,
    })
    if (!response.ok) throw new Error(String(response.status))
    return (await response.json()) as T
  } catch (err) {
    if (signal?.aborted) return null
    throw err
  }
}

export async function reverseGeocode(point: LatLng): Promise<string | null> {
  try {
    const data = await nominatim<NominatimPlace>(
      `/reverse?lat=${encodeURIComponent(point.lat)}&lon=${encodeURIComponent(point.lng)}&format=jsonv2&addressdetails=1`,
    )
    if (!data) return null
    return formatShopStreet(data) || data.display_name?.trim() || null
  } catch {
    return null
  }
}

function toAddressHits(
  data: NominatimPlace[] | null,
  keep: (point: LatLng) => boolean,
): { label: string; point: LatLng }[] {
  if (!Array.isArray(data)) return []

  return data
    .map((place) => {
      const lat = Number.parseFloat(place.lat ?? '')
      const lng = Number.parseFloat(place.lon ?? '')
      if (!Number.isFinite(lat) || !Number.isFinite(lng) || !place.display_name) return null
      const point = { lat, lng }
      if (!keep(point)) return null
      const label = formatShopStreet(place) || place.display_name
      if (!label) return null
      return { label, point }
    })
    .filter((item): item is { label: string; point: LatLng } => Boolean(item))
}

export async function searchCoverageAddress(
  query: string,
  signal?: AbortSignal,
): Promise<{ label: string; point: LatLng }[]> {
  const term = query.trim()
  if (term.length < 3) return []

  const bounds = coverageBounds()
  const viewbox = [bounds.west, bounds.north, bounds.east, bounds.south].join(',')
  const data = await nominatim<NominatimPlace[]>(
    `/search?q=${encodeURIComponent(term)}&format=jsonv2&limit=5&addressdetails=1&countrycodes=ph&viewbox=${viewbox}`,
    signal,
  )
  if (signal?.aborted) return []

  return toAddressHits(data, (point) => isInCoverage(point))
}

export async function searchWorldAddress(
  query: string,
  signal?: AbortSignal,
): Promise<{ label: string; point: LatLng }[]> {
  const term = query.trim()
  if (term.length < 3) return []

  const data = await nominatim<NominatimPlace[]>(
    `/search?q=${encodeURIComponent(term)}&format=jsonv2&limit=5&addressdetails=1`,
    signal,
  )
  if (signal?.aborted) return []

  return toAddressHits(data, () => true)
}
