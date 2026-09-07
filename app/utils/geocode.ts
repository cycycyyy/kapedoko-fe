import type { LatLng } from '../types/cafe'
import { MARIKINA_BOUNDS } from './marikina'

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
  }
}

const REGION_NOISE = /^(philippines|metro manila|eastern manila( district)?|district( i{1,3})?|\d{4})$/i

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
  const fromParts = [street, barangay, 'Marikina'].filter(Boolean)
  if (street) return [...new Set(fromParts)].join(', ')

  const kept = (place.display_name || '')
    .split(',')
    .map((part) => part.trim())
    .filter((part) => part && !REGION_NOISE.test(part))
    .slice(0, 2)

  if (!kept.length) return ''
  if (!kept.some((part) => /marikina/i.test(part))) kept.push('Marikina')
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

export async function searchMarikinaAddress(query: string): Promise<{ label: string; point: LatLng }[]> {
  const term = query.trim()
  if (term.length < 3) return []

  const viewbox = [
    MARIKINA_BOUNDS.west,
    MARIKINA_BOUNDS.north,
    MARIKINA_BOUNDS.east,
    MARIKINA_BOUNDS.south,
  ].join(',')

  const data = await nominatim<NominatimPlace[]>(
    `/search?q=${encodeURIComponent(term)}&format=jsonv2&limit=5&addressdetails=1&viewbox=${viewbox}&bounded=1`,
  )

  if (!Array.isArray(data)) return []

  return data
    .map((place) => {
      const lat = Number.parseFloat(place.lat ?? '')
      const lng = Number.parseFloat(place.lon ?? '')
      if (!Number.isFinite(lat) || !Number.isFinite(lng) || !place.display_name) return null
      const label = formatShopStreet(place) || place.display_name
      return { label, point: { lat, lng } }
    })
    .filter((item): item is { label: string; point: LatLng } => Boolean(item))
}
