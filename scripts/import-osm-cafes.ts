#!/usr/bin/env bun
/**
 * Fetch cafe amenities from OpenStreetMap Overpass and emit a pending-shop
 * SQL seed. Does not invent Wi-Fi, plugs, photos, or logos.
 *
 *   bun run import:osm
 *   bun run import:osm -- --cities=cebu-city,davao-city --out=db/seed_osm_cafes.sql
 *
 * Queries city bounding-box tiles, caches each tile under .cache/osm-import/,
 * and fails over across public Overpass mirrors. Re-run after a 429/504 to
 * resume without refetching finished tiles.
 *
 * © OpenStreetMap contributors, ODbL. https://www.openstreetmap.org/copyright
 */
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { join } from 'node:path'
import {
  catalogImportRegions,
  CATALOG_IMPORT_CITIES,
  coverageBounds,
  type GeoBounds,
} from '../app/utils/geography'
import {
  catalogSqlFile,
  collectOsmCafes,
  osmIdentityKey,
  type OsmCafeElement,
} from '../app/utils/osm-import'

const ENDPOINTS = [
  'https://overpass.kumi.systems/api/interpreter',
  'https://overpass.private.coffee/api/interpreter',
  'https://overpass-api.de/api/interpreter',
]

const USER_AGENT = 'KapeDoko/1.0 (catalog-import; https://www.openstreetmap.org/copyright)'
const CACHE_DIR = '.cache/osm-import'
const PAUSE_MS = 10_000

const CITY_RELATIONS: Record<string, number> = {
  'metro-manila': 147488,
  'cebu-city': 12455830,
  'davao-city': 3936841,
}

const CITY_TILES: Record<string, { rows: number; cols: number }> = {
  'metro-manila': { rows: 2, cols: 2 },
  'cebu-city': { rows: 1, cols: 1 },
  'davao-city': { rows: 2, cols: 1 },
}

class OverpassError extends Error {
  constructor(
    readonly status: number,
    readonly endpoint: string,
    readonly retryAfterMs: number | null,
  ) {
    super(`Overpass failed (${status}) at ${endpoint}`)
  }
}

function parseArgs(argv: string[]) {
  const cities = Object.keys(CITY_RELATIONS)
  let selected = cities
  let out = 'db/seed_osm_cafes.sql'
  for (const arg of argv) {
    if (arg.startsWith('--cities=')) {
      selected = arg.slice(9).split(',').map((value) => value.trim()).filter(Boolean)
    }
    if (arg.startsWith('--out=')) out = arg.slice(6)
  }
  for (const id of selected) {
    if (!CITY_RELATIONS[id]) {
      throw new Error(`Unknown city '${id}'. Use ${cities.join(', ')}.`)
    }
  }
  return { selected, out }
}

function splitBounds(bounds: GeoBounds, rows: number, cols: number): GeoBounds[] {
  const tiles: GeoBounds[] = []
  const latStep = (bounds.north - bounds.south) / rows
  const lngStep = (bounds.east - bounds.west) / cols
  for (let row = 0; row < rows; row += 1) {
    for (let col = 0; col < cols; col += 1) {
      tiles.push({
        south: bounds.south + row * latStep,
        north: row === rows - 1 ? bounds.north : bounds.south + (row + 1) * latStep,
        west: bounds.west + col * lngStep,
        east: col === cols - 1 ? bounds.east : bounds.west + (col + 1) * lngStep,
      })
    }
  }
  return tiles
}

function bboxQuery(bounds: GeoBounds): string {
  const box = `${bounds.south},${bounds.west},${bounds.north},${bounds.east}`
  return `[out:json][timeout:60];
(
  node["amenity"="cafe"](${box});
  way["amenity"="cafe"](${box});
);
out center;`
}

function cachePath(city: string, index: number, bounds: GeoBounds): string {
  const id = [
    city,
    index,
    bounds.south.toFixed(4),
    bounds.west.toFixed(4),
    bounds.north.toFixed(4),
    bounds.east.toFixed(4),
  ].join('_')
  return join(CACHE_DIR, `${id}.nwr.json`)
}

function readCache(path: string): OsmCafeElement[] | null {
  try {
    const parsed = JSON.parse(readFileSync(path, 'utf8')) as { elements?: OsmCafeElement[] }
    return parsed.elements ?? null
  } catch {
    return null
  }
}

function writeCache(path: string, elements: OsmCafeElement[]) {
  mkdirSync(CACHE_DIR, { recursive: true })
  writeFileSync(path, `${JSON.stringify({ elements }, null, 0)}\n`)
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

function retryAfterMs(response: Response, status: number): number | null {
  const header = response.headers.get('retry-after')
  if (header) {
    const seconds = Number(header)
    if (Number.isFinite(seconds) && seconds > 0) return seconds * 1000
  }
  if (status === 429) return 30_000
  return null
}

async function postOverpass(endpoint: string, query: string): Promise<OsmCafeElement[]> {
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      Accept: 'application/json',
      'User-Agent': USER_AGENT,
    },
    body: `data=${encodeURIComponent(query)}`,
    signal: AbortSignal.timeout(75_000),
  })
  if (!response.ok) {
    throw new OverpassError(response.status, endpoint, retryAfterMs(response, response.status))
  }
  const payload = await response.json() as { elements?: OsmCafeElement[] }
  return payload.elements ?? []
}

async function fetchQuery(query: string): Promise<OsmCafeElement[]> {
  let lastError: unknown
  for (let round = 0; round < 3; round += 1) {
    for (const endpoint of ENDPOINTS) {
      try {
        return await postOverpass(endpoint, query)
      } catch (err) {
        lastError = err
        const wait = err instanceof OverpassError && err.retryAfterMs
          ? err.retryAfterMs
          : err instanceof OverpassError && err.status === 504
            ? 1_000
            : 8_000 * (round + 1)
        console.error(`  ${err instanceof Error ? err.message : String(err)}; trying another mirror in ${Math.round(wait / 1000)}s`)
        await sleep(wait)
      }
    }
  }
  throw lastError instanceof Error ? lastError : new Error('Overpass failed')
}

async function fetchTile(city: string, index: number, bounds: GeoBounds): Promise<OsmCafeElement[]> {
  const path = cachePath(city, index, bounds)
  const cached = readCache(path)
  if (cached) {
    console.error(`  tile ${index + 1} cached (${cached.length} cafes)`)
    return cached
  }
  const elements = await fetchQuery(bboxQuery(bounds))
  writeCache(path, elements)
  return elements
}

function mergeElements(chunks: OsmCafeElement[][]): OsmCafeElement[] {
  const seen = new Set<string>()
  const merged: OsmCafeElement[] = []
  for (const chunk of chunks) {
    for (const element of chunk) {
      const key = osmIdentityKey(String(element.type), element.id)
      if (seen.has(key)) continue
      seen.add(key)
      merged.push(element)
    }
  }
  return merged
}

async function fetchCity(city: string): Promise<OsmCafeElement[]> {
  const regions = catalogImportRegions([city])
  const bounds = coverageBounds(regions.length ? regions : CATALOG_IMPORT_CITIES[city])
  const tiling = CITY_TILES[city] ?? { rows: 1, cols: 1 }
  const tiles = splitBounds(bounds, tiling.rows, tiling.cols)
  const chunks: OsmCafeElement[][] = []
  for (const [index, tile] of tiles.entries()) {
    console.error(`  tile ${index + 1}/${tiles.length}`)
    chunks.push(await fetchTile(city, index, tile))
    if (index < tiles.length - 1 && !readCache(cachePath(city, index + 1, tiles[index + 1]!))) {
      console.error(`  pausing ${PAUSE_MS / 1000}s so Overpass is not rate-limited`)
      await sleep(PAUSE_MS)
    }
  }
  return mergeElements(chunks)
}

const { selected, out } = parseArgs(process.argv.slice(2))
const existing: Parameters<typeof collectOsmCafes>[2] = []
const accepted = []
const skipped = {
  missing_name: 0,
  missing_address: 0,
  missing_hours: 0,
  unsupported_hours: 0,
  outside_region: 0,
  duplicate_osm: 0,
  duplicate_nearby: 0,
}

for (const city of selected) {
  const relationId = CITY_RELATIONS[city]!
  console.error(`Fetching ${city} (relation ${relationId})…`)
  const elements = await fetchCity(city)
  const regions = catalogImportRegions([city])
  const result = collectOsmCafes(elements, regions.length ? regions : CATALOG_IMPORT_CITIES[city] ?? [], existing)
  accepted.push(...result.accepted)
  for (const draft of result.accepted) {
    existing.push({
      name: draft.name,
      latitude: draft.latitude,
      longitude: draft.longitude,
      source: draft.source,
      osm_type: draft.osm_type,
      osm_id: draft.osm_id,
    })
  }
  for (const reason of Object.keys(skipped) as (keyof typeof skipped)[]) {
    skipped[reason] += result.skipped[reason]
  }
  console.error(`  kept ${result.accepted.length} of ${elements.length}`)
}

const sql = catalogSqlFile(accepted, skipped)
writeFileSync(out, sql)
console.error(`Wrote ${accepted.length} pending inserts to ${out}`)
