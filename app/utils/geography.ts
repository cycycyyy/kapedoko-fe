import type { LatLng } from '../types/cafe'
import metroManila from '../data/metro-manila.json'
import cebuCity from '../data/cebu-city.json'
import davaoCity from '../data/davao-city.json'

export interface GeoBounds {
  south: number
  north: number
  west: number
  east: number
}

export interface CoverageRegion {
  id: string
  name: string
  bounds: GeoBounds
  center: LatLng
  rings: [number, number][][]
}

interface CoverageFeature {
  properties: {
    id: string
    name: string
    bounds: GeoBounds
    center: LatLng
  }
  geometry: {
    type?: 'Polygon' | 'MultiPolygon'
    coordinates: [number, number][][] | [number, number][][][]
  }
}

function regionsFromFeature(feature: CoverageFeature): CoverageRegion[] {
  const polygons = feature.geometry.type === 'MultiPolygon'
    ? (feature.geometry.coordinates as [number, number][][][])
    : [feature.geometry.coordinates as [number, number][][]]
  return polygons.map((rings, index) => ({
    id: polygons.length > 1 ? `${feature.properties.id}-${index}` : feature.properties.id,
    name: feature.properties.name,
    bounds: feature.properties.bounds,
    center: feature.properties.center,
    rings,
  }))
}

const metroManilaFeature = metroManila as CoverageFeature
const cebuCityFeature = cebuCity as CoverageFeature
const davaoCityFeature = davaoCity as CoverageFeature

export const METRO_MANILA_REGIONS: CoverageRegion[] = regionsFromFeature(metroManilaFeature)
export const CEBU_CITY_REGIONS: CoverageRegion[] = regionsFromFeature(cebuCityFeature)
export const DAVAO_CITY_REGIONS: CoverageRegion[] = regionsFromFeature(davaoCityFeature)

export const METRO_MANILA_REGION: CoverageRegion = METRO_MANILA_REGIONS[0] ?? {
  id: metroManilaFeature.properties.id,
  name: metroManilaFeature.properties.name,
  bounds: metroManilaFeature.properties.bounds,
  center: metroManilaFeature.properties.center,
  rings: metroManilaFeature.geometry.coordinates as [number, number][][],
}

export const CATALOG_IMPORT_CITIES: Record<string, CoverageRegion[]> = {
  'metro-manila': METRO_MANILA_REGIONS,
  'cebu-city': CEBU_CITY_REGIONS,
  'davao-city': DAVAO_CITY_REGIONS,
}

export function catalogImportRegions(cityIds?: string[]): CoverageRegion[] {
  const ids = cityIds?.length ? cityIds : Object.keys(CATALOG_IMPORT_CITIES)
  return ids.flatMap((id) => CATALOG_IMPORT_CITIES[id] ?? [])
}

function rectangularRegion(
  id: string,
  name: string,
  south: number,
  north: number,
  west: number,
  east: number,
): CoverageRegion {
  return {
    id,
    name,
    bounds: { south, north, west, east },
    center: {
      lat: (south + north) / 2,
      lng: (west + east) / 2,
    },
    rings: [[
      [west, south],
      [east, south],
      [east, north],
      [west, north],
      [west, south],
    ]],
  }
}

/** Island boxes covering the Philippines. Keep these in sync with db/20260929_philippines_coverage.sql. */
export const PHILIPPINES_REGIONS: CoverageRegion[] = [
  rectangularRegion('luzon', 'Luzon', 12.05, 21.25, 119.75, 124.75),
  rectangularRegion('palawan', 'Palawan', 7.4, 12.4, 116.85, 121.5),
  rectangularRegion('visayas', 'Visayas', 8.95, 12.75, 121.25, 126.65),
  rectangularRegion('mindanao', 'Mindanao', 5.2, 10.55, 121.65, 126.75),
  rectangularRegion('sulu', 'Sulu', 4.55, 6.9, 119.15, 122.35),
]

/** Public cafe pins may land anywhere in the Philippines. */
export const ACTIVE_REGIONS: CoverageRegion[] = PHILIPPINES_REGIONS

export const METRO_MANILA_BOUNDS = METRO_MANILA_REGION.bounds
export const METRO_MANILA_CENTER = METRO_MANILA_REGION.center

function pointInRing(point: LatLng, ring: [number, number][]): boolean {
  const x = point.lng
  const y = point.lat
  let inside = false

  for (let i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    const xi = ring[i]?.[0]
    const yi = ring[i]?.[1]
    const xj = ring[j]?.[0]
    const yj = ring[j]?.[1]
    if (xi == null || yi == null || xj == null || yj == null) continue
    const intersect = (yi > y) !== (yj > y) && x < ((xj - xi) * (y - yi)) / (yj - yi) + xi
    if (intersect) inside = !inside
  }

  return inside
}

export function isInRegion(point: LatLng, region: CoverageRegion): boolean {
  const [outer, ...holes] = region.rings
  if (!outer || !pointInRing(point, outer)) return false
  return !holes.some((hole) => pointInRing(point, hole))
}

export function isInCoverage(point: LatLng, regions = ACTIVE_REGIONS): boolean {
  return regions.some((region) => isInRegion(point, region))
}

export function coverageBounds(regions = ACTIVE_REGIONS): GeoBounds {
  return regions.reduce(
    (acc, region) => ({
      south: Math.min(acc.south, region.bounds.south),
      north: Math.max(acc.north, region.bounds.north),
      west: Math.min(acc.west, region.bounds.west),
      east: Math.max(acc.east, region.bounds.east),
    }),
    regions[0]?.bounds ?? METRO_MANILA_BOUNDS,
  )
}

export function coverageCenter(regions = ACTIVE_REGIONS): LatLng {
  if (regions.length === 1 && regions[0]) return regions[0].center
  const bounds = coverageBounds(regions)
  return {
    lat: (bounds.south + bounds.north) / 2,
    lng: (bounds.west + bounds.east) / 2,
  }
}

export function coverageRings(regions = ACTIVE_REGIONS): [number, number][][] {
  return regions.flatMap((region) => region.rings)
}

export function clampToCoverage(point: LatLng, regions = ACTIVE_REGIONS): LatLng {
  if (isInCoverage(point, regions)) return point
  const bounds = coverageBounds(regions)
  return {
    lat: Math.min(bounds.north, Math.max(bounds.south, point.lat)),
    lng: Math.min(bounds.east, Math.max(bounds.west, point.lng)),
  }
}

export function boundsFromRadius(center: LatLng, radiusM: number): GeoBounds {
  const latDelta = radiusM / 111_320
  const lngDelta = radiusM / (111_320 * Math.cos((center.lat * Math.PI) / 180) || 1)
  return {
    south: center.lat - latDelta,
    north: center.lat + latDelta,
    west: center.lng - lngDelta,
    east: center.lng + lngDelta,
  }
}

export function padBounds(bounds: GeoBounds, factor = 0.3): GeoBounds {
  const latPad = Math.max(bounds.north - bounds.south, 0) * factor
  const lngPad = Math.max(bounds.east - bounds.west, 0) * factor
  return {
    south: bounds.south - latPad,
    north: bounds.north + latPad,
    west: bounds.west - lngPad,
    east: bounds.east + lngPad,
  }
}

export function boundsContain(outer: GeoBounds, inner: GeoBounds): boolean {
  return (
    outer.south <= inner.south
    && outer.north >= inner.north
    && outer.west <= inner.west
    && outer.east >= inner.east
  )
}

export function pointInBounds(point: LatLng, bounds: GeoBounds): boolean {
  return (
    point.lat >= bounds.south
    && point.lat <= bounds.north
    && point.lng >= bounds.west
    && point.lng <= bounds.east
  )
}

export function clampQueryBounds(center: LatLng, bounds: GeoBounds, maxRadiusM: number): GeoBounds {
  const cap = boundsFromRadius(center, maxRadiusM)
  const tooWide =
    bounds.north - bounds.south > cap.north - cap.south
    || bounds.east - bounds.west > cap.east - cap.west
  return tooWide ? cap : bounds
}
