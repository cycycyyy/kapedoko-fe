import type { LatLng } from '../types/cafe'
import type { OsmElementType, WeeklyHours } from '../types/shop'
import { isInRegion, PHILIPPINES_REGIONS, type CoverageRegion } from './geography'
import { isValidAddress, isValidCafeName, normalizeAddress, normalizeCafeName } from './identity'
import { isValidPhone, normalizePhone } from './phone'
import { parseOsmOpeningHours } from './osm-hours'

export const OSM_NEARBY_DEGREES = 0.00045

export type OsmSkipReason =
  | 'missing_name'
  | 'missing_address'
  | 'missing_hours'
  | 'unsupported_hours'
  | 'outside_region'
  | 'duplicate_osm'
  | 'duplicate_nearby'

export interface OsmCafeElement {
  type: OsmElementType | string
  id: number
  lat?: number
  lon?: number
  center?: { lat: number; lon: number }
  tags?: Record<string, string>
}

export interface CatalogShopDraft {
  name: string
  address: string
  latitude: number
  longitude: number
  hours: WeeklyHours
  contact_number: string | null
  source: 'openstreetmap'
  osm_type: OsmElementType
  osm_id: number
}

export interface ExistingCatalogShop {
  name: string
  latitude: number
  longitude: number
  source?: string | null
  osm_type?: string | null
  osm_id?: number | null
}

export type CatalogNormalizeResult =
  | { ok: true; draft: CatalogShopDraft }
  | { ok: false; reason: OsmSkipReason }

function osmPoint(element: OsmCafeElement): LatLng | null {
  const lat = element.lat ?? element.center?.lat
  const lng = element.lon ?? element.center?.lon
  if (typeof lat !== 'number' || typeof lng !== 'number') return null
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null
  return { lat, lng }
}

export function osmCafeName(tags: Record<string, string> | undefined): string {
  return normalizeCafeName(tags?.name || tags?.brand || tags?.['name:en'] || '')
}

export function osmCafeAddress(tags: Record<string, string> | undefined): string {
  const full = normalizeAddress(tags?.['addr:full'] || '')
  if (full) return full
  const street = [tags?.['addr:housenumber'], tags?.['addr:street']].filter(Boolean).join(' ').trim()
  const place = tags?.['addr:suburb'] || tags?.['addr:quarter'] || tags?.['addr:district'] || ''
  const city = tags?.['addr:city'] || tags?.['addr:municipality'] || ''
  return normalizeAddress([street, place, city].filter(Boolean).join(', '))
}

export function osmCafePhone(tags: Record<string, string> | undefined): string | null {
  const raw = normalizePhone(tags?.phone || tags?.['contact:phone'] || tags?.['phone:mobile'] || '')
  if (!raw) return null
  return isValidPhone(raw) ? raw : null
}

export function osmIdentityKey(type: string, id: number): string {
  return `${type}/${id}`
}

export function namesMatch(left: string, right: string): boolean {
  return normalizeCafeName(left).toLowerCase() === normalizeCafeName(right).toLowerCase()
}

export function isNearbyShop(
  point: LatLng,
  shop: Pick<ExistingCatalogShop, 'latitude' | 'longitude'>,
  degrees = OSM_NEARBY_DEGREES,
): boolean {
  return Math.abs(shop.latitude - point.lat) < degrees && Math.abs(shop.longitude - point.lng) < degrees
}

export function findDuplicateShop(
  draft: Pick<CatalogShopDraft, 'name' | 'latitude' | 'longitude' | 'osm_type' | 'osm_id'>,
  existing: ExistingCatalogShop[],
): OsmSkipReason | null {
  for (const shop of existing) {
    if (shop.source === 'openstreetmap' && shop.osm_type === draft.osm_type && shop.osm_id === draft.osm_id) {
      return 'duplicate_osm'
    }
    if (namesMatch(shop.name, draft.name) && isNearbyShop({ lat: draft.latitude, lng: draft.longitude }, shop)) {
      return 'duplicate_nearby'
    }
  }
  return null
}

export function normalizeOsmCafe(
  element: OsmCafeElement,
  regions: CoverageRegion[],
  existing: ExistingCatalogShop[] = [],
): CatalogNormalizeResult {
  const type = element.type
  if (type !== 'node' && type !== 'way' && type !== 'relation') {
    return { ok: false, reason: 'missing_name' }
  }
  const point = osmPoint(element)
  if (!point) return { ok: false, reason: 'outside_region' }
  if (!regions.some((region) => isInRegion(point, region))) {
    return { ok: false, reason: 'outside_region' }
  }

  const name = osmCafeName(element.tags)
  if (!isValidCafeName(name)) return { ok: false, reason: 'missing_name' }

  const address = osmCafeAddress(element.tags)
  if (!isValidAddress(address)) return { ok: false, reason: 'missing_address' }

  const hours = parseOsmOpeningHours(element.tags?.opening_hours)
  if (!hours.ok) {
    return { ok: false, reason: hours.reason === 'missing' ? 'missing_hours' : 'unsupported_hours' }
  }

  const draft: CatalogShopDraft = {
    name,
    address,
    latitude: point.lat,
    longitude: point.lng,
    hours: hours.hours,
    contact_number: osmCafePhone(element.tags),
    source: 'openstreetmap',
    osm_type: type,
    osm_id: element.id,
  }

  const duplicate = findDuplicateShop(draft, existing)
  if (duplicate) return { ok: false, reason: duplicate }
  return { ok: true, draft }
}

export function collectOsmCafes(
  elements: OsmCafeElement[],
  regions: CoverageRegion[],
  existing: ExistingCatalogShop[] = [],
): { accepted: CatalogShopDraft[]; skipped: Record<OsmSkipReason, number> } {
  const skipped: Record<OsmSkipReason, number> = {
    missing_name: 0,
    missing_address: 0,
    missing_hours: 0,
    unsupported_hours: 0,
    outside_region: 0,
    duplicate_osm: 0,
    duplicate_nearby: 0,
  }
  const accepted: CatalogShopDraft[] = []
  const seen = [...existing]

  for (const element of elements) {
    const result = normalizeOsmCafe(element, regions, seen)
    if (!result.ok) {
      skipped[result.reason] += 1
      continue
    }
    accepted.push(result.draft)
    seen.push({
      name: result.draft.name,
      latitude: result.draft.latitude,
      longitude: result.draft.longitude,
      source: result.draft.source,
      osm_type: result.draft.osm_type,
      osm_id: result.draft.osm_id,
    })
  }

  return { accepted, skipped }
}

function sqlString(value: string, tag: string): string {
  return `$${tag}$${value}$${tag}$`
}

export function catalogDraftToSql(draft: CatalogShopDraft): string {
  const hours = JSON.stringify(draft.hours)
  const phone = draft.contact_number ? sqlString(draft.contact_number, 'ph') : 'null'
  return `-- ${draft.osm_type}/${draft.osm_id}
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  ${sqlString(draft.name, 'nm')},
  ${sqlString(draft.address, 'ad')},
  ${draft.latitude},
  ${draft.longitude},
  '{cafe}'::text[],
  ${sqlString(hours, 'hr')}::jsonb,
  ${phone},
  'pending',
  'openstreetmap',
  '${draft.osm_type}',
  ${draft.osm_id},
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = '${draft.osm_type}'
    and s.osm_id = ${draft.osm_id}
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim(${sqlString(draft.name, 'dn')}))
    and abs(s.latitude - ${draft.latitude}) < ${OSM_NEARBY_DEGREES}
    and abs(s.longitude - ${draft.longitude}) < ${OSM_NEARBY_DEGREES}
);`
}

/** Island boxes kept in sync with db/20260929_philippines_coverage.sql. */
export function philippinesCoverageSql(): string {
  const values = PHILIPPINES_REGIONS.map((region) => {
    const polygon = JSON.stringify({ type: 'Polygon', coordinates: region.rings })
    return `  (
    '${region.id}',
    '${region.name}',
    true,
    '${polygon}'::jsonb
  )`
  }).join(',\n')
  return `insert into public.coverage_regions (id, name, is_active, polygon)
values
${values}
on conflict (id) do update
set name = excluded.name,
    is_active = excluded.is_active,
    polygon = excluded.polygon;`
}

export function catalogSqlFile(drafts: CatalogShopDraft[], skipped: Record<OsmSkipReason, number>): string {
  const lines = [
    '-- KapéDoko seed: cafes from OpenStreetMap',
    '-- © OpenStreetMap contributors, ODbL. https://www.openstreetmap.org/copyright',
    `-- Inserted here: ${drafts.length}`,
    `-- Skipped, no usable name: ${skipped.missing_name}`,
    `-- Skipped, no usable address: ${skipped.missing_address}`,
    `-- Skipped, hours missing: ${skipped.missing_hours}`,
    `-- Skipped, hours unsupported: ${skipped.unsupported_hours}`,
    `-- Skipped, outside import regions: ${skipped.outside_region}`,
    `-- Skipped, duplicate OSM id: ${skipped.duplicate_osm}`,
    `-- Skipped, same name nearby: ${skipped.duplicate_nearby}`,
    '--',
    '-- Each row starts as pending. Do not use create_admin_shop.',
    '-- Safe to run again: OSM identity and name+~50m guards skip existing rows.',
    '-- Wi-Fi, plugs, photos, and reviews are not invented from the map data.',
    '--',
    '-- Cebu City and Davao City sit outside the Metro Manila polygon.',
    '-- The coverage insert below turns on the Philippines island boxes in',
    '-- this same transaction. shops_require_coverage then accepts those pins.',
    '-- Without the boxes, the first Cebu row raises shops_in_coverage and',
    '-- the transaction rolls back, so only cafes already stored remain.',
    '',
    'begin;',
    '',
    philippinesCoverageSql(),
    '',
    ...drafts.map(catalogDraftToSql),
    '',
    'commit;',
    '',
  ]
  return lines.join('\n')
}
