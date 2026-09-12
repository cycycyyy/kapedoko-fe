import type { LatLng } from '../types/cafe'
import metroManila from '../data/metro-manila.json'

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
    coordinates: [number, number][][]
  }
}

const feature = metroManila as CoverageFeature

export const METRO_MANILA_REGION: CoverageRegion = {
  id: feature.properties.id,
  name: feature.properties.name,
  bounds: feature.properties.bounds,
  center: feature.properties.center,
  rings: feature.geometry.coordinates,
}

/** Active launch regions. Add another region here (and in coverage_regions) to expand later. */
export const ACTIVE_REGIONS: CoverageRegion[] = [METRO_MANILA_REGION]

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
