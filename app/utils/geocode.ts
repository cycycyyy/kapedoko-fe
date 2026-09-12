import type { LatLng } from '../types/cafe'
import { coverageBounds, isInCoverage } from './geography'

const NOMINATIM = 'https://nominatim.openstreetmap.org'
const USER_AGENT = 'KapeDoko/1.0 (cafe directory; https://kapedoko.app)'

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

async function nominatim<T>(path: string): Promise<T | null> {
  try {
    const response = await fetch(`${NOMINATIM}${path}`, {
      headers: { Accept: 'application/json', 'User-Agent': USER_AGENT },
    })
    if (!response.ok) return null
    return (await response.json()) as T
  } catch {
    return null
  }
}

export async function reverseGeocode(point: LatLng): Promise<string | null> {
  const data = await nominatim<NominatimPlace>(
    `/reverse?lat=${encodeURIComponent(point.lat)}&lon=${encodeURIComponent(point.lng)}&format=jsonv2&addressdetails=1`,
  )
  if (!data) return null
  return formatShopStreet(data) || data.display_name?.trim() || null
}

export async function searchCoverageAddress(query: string): Promise<{ label: string; point: LatLng }[]> {
  const term = query.trim()
  if (term.length < 3) return []

  const bounds = coverageBounds()
  const viewbox = [bounds.west, bounds.north, bounds.east, bounds.south].join(',')

  const data = await nominatim<NominatimPlace[]>(
    `/search?q=${encodeURIComponent(term)}&format=jsonv2&limit=5&addressdetails=1&viewbox=${viewbox}&bounded=1`,
  )

  if (!Array.isArray(data)) return []

  return data
    .map((place) => {
      const lat = Number.parseFloat(place.lat ?? '')
      const lng = Number.parseFloat(place.lon ?? '')
      if (!Number.isFinite(lat) || !Number.isFinite(lng) || !place.display_name) return null
      const point = { lat, lng }
      if (!isInCoverage(point)) return null
      const label = formatShopStreet(place) || place.display_name
      return { label, point }
    })
    .filter((item): item is { label: string; point: LatLng } => Boolean(item))
}
