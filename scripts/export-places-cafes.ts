#!/usr/bin/env bun
/**
 * Fetch cafes with gosom/google-maps-scraper and emit a CSV seed for later
 * admin batch import. Does not invent Wi-Fi, plugs, or QR payments.
 *
 *   bun run export:places
 *   bun run export:places -- --city=marikina
 *   bun run export:places -- --cities=metro-manila,cebu-city,davao-city
 *   bun run export:places -- --from=.cache/places-import/marikina-raw.json
 *
 * Uses .cache/places-import/google-maps-scraper, or Docker if the binary is missing.
 * Caches scraper JSON under .cache/places-import/.
 */
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { dirname, join, resolve } from 'node:path'
import {
  PLACES_CATALOG_CITY_IDS,
  PLACES_CITIES,
  collectPlacesRows,
  mapsScraperEntryToPlace,
  parseMapsScraperResults,
  placesCsvFile,
  summarizePlacesRows,
  type PlacesCityConfig,
  type PlacesCsvRow,
} from '../app/utils/places-import'

const IMAGE = 'gosom/google-maps-scraper'
const CACHE_DIR = '.cache/places-import'
const LOCAL_BIN = join('.cache/places-import', 'google-maps-scraper')

function parseArgs(argv: string[]) {
  const known = Object.keys(PLACES_CITIES)
  let selected = ['marikina']
  let out = ''
  let from = ''
  let force = false
  let depth = 1
  for (const arg of argv) {
    if (arg.startsWith('--city=')) selected = [arg.slice(7).trim()]
    if (arg.startsWith('--cities=')) {
      selected = arg.slice(9).split(',').map((value) => value.trim()).filter(Boolean)
    }
    if (arg.startsWith('--out=')) out = arg.slice(6)
    if (arg.startsWith('--from=')) from = arg.slice(7)
    if (arg.startsWith('--depth=')) depth = Number(arg.slice(8)) || 1
    if (arg === '--force') force = true
  }
  if (selected.length === 1 && (selected[0] === 'catalog' || selected[0] === 'all')) {
    selected = [...PLACES_CATALOG_CITY_IDS]
  }
  for (const city of selected) {
    if (!PLACES_CITIES[city]) {
      throw new Error(`Unknown city '${city}'. Use ${known.join(', ')} or catalog.`)
    }
  }
  if (from && selected.length > 1) {
    throw new Error('Use --from with a single --city.')
  }
  return { selected, out, from, force, depth }
}

function writeQueries(city: string, config: PlacesCityConfig): string {
  mkdirSync(CACHE_DIR, { recursive: true })
  const path = join(CACHE_DIR, `${city}-queries.txt`)
  writeFileSync(path, `${config.textQueries.join('\n')}\n`)
  return path
}

function scraperArgs(input: {
  queriesPath: string
  rawPath: string
  depth: number
}): string[] {
  return [
    '-input',
    input.queriesPath,
    '-results',
    input.rawPath,
    '-json',
    '-lang',
    'en',
    '-depth',
    String(input.depth),
    '-c',
    '1',
    '-exit-on-inactivity',
    '3m',
  ]
}

function hasCachedRaw(path: string): boolean {
  if (!existsSync(path)) return false
  return readFileSync(path, 'utf8').trim().length > 0
}

function scraperBinary(): string | null {
  const fromEnv = process.env.GOOGLE_MAPS_SCRAPER?.trim()
  if (fromEnv && existsSync(fromEnv)) return fromEnv
  if (existsSync(LOCAL_BIN)) return LOCAL_BIN
  return null
}

async function dockerReady(): Promise<boolean> {
  const proc = Bun.spawn(['docker', 'info'], { stdout: 'ignore', stderr: 'ignore' })
  return (await proc.exited) === 0
}

async function runCommand(command: string, args: string[]) {
  const proc = Bun.spawn([command, ...args], {
    stdout: 'inherit',
    stderr: 'inherit',
  })
  const code = await proc.exited
  if (code !== 0) throw new Error(`${command} exited with code ${code}`)
}

async function runScraper(input: {
  city: string
  config: PlacesCityConfig
  queriesPath: string
  rawPath: string
  depth: number
}) {
  mkdirSync(dirname(input.rawPath), { recursive: true })
  const flags = scraperArgs({
    queriesPath: resolve(input.queriesPath),
    rawPath: resolve(input.rawPath),
    depth: input.depth,
  })

  const binary = scraperBinary()
  if (binary) {
    console.error(`Running ${binary} for ${input.city}…`)
    await runCommand(binary, flags)
    return
  }

  if (await dockerReady()) {
    const queriesAbs = resolve(input.queriesPath)
    const outDir = resolve(dirname(input.rawPath))
    const rawName = input.rawPath.split(/[/\\]/).at(-1) || `${input.city}-raw.json`
    console.error(`Running ${IMAGE} for ${input.city}…`)
    await runCommand('docker', [
      'run',
      '--rm',
      '-v',
      'gmaps-playwright-cache:/opt',
      '-v',
      `${queriesAbs}:/queries.txt:ro`,
      '-v',
      `${outDir}:/out`,
      IMAGE,
      ...scraperArgs({
        queriesPath: '/queries.txt',
        rawPath: `/out/${rawName}`,
        depth: input.depth,
      }),
    ])
    return
  }

  throw new Error(
    'google-maps-scraper not found and Docker is not running. Build the binary into .cache/places-import/google-maps-scraper or start Docker Desktop.',
  )
}

function sortRows(rows: PlacesCsvRow[]) {
  rows.sort((left, right) => {
    const name = left.name.localeCompare(right.name)
    return name !== 0 ? name : left.google_place_id.localeCompare(right.google_place_id)
  })
}

function logSummary(
  city: string,
  out: string,
  entries: number,
  dropped: { closed_permanently: number; outside_region: number; missing_place_id: number },
  rows: PlacesCsvRow[],
) {
  const summary = summarizePlacesRows(rows)
  console.error(`[${city}] Found ${entries} scraper rows`)
  console.error(`[${city}] Dropped: closed_permanently=${dropped.closed_permanently} outside_region=${dropped.outside_region} missing_place_id=${dropped.missing_place_id}`)
  console.error(`[${city}] Kept ${summary.rows} rows`)
  console.error(`[${city}] Import-ready: ${summary.importReady}`)
  console.error(`[${city}] Missing hours: ${summary.missingHours}`)
  console.error(`[${city}] Missing address: ${summary.missingAddress}`)
  console.error(`[${city}] Unsupported hours: ${summary.unsupportedHours}`)
  console.error(`[${city}] Wrote ${out}`)
}

async function exportCity(input: {
  city: string
  out: string
  from?: string
  force: boolean
  depth: number
}): Promise<PlacesCsvRow[]> {
  const config = PLACES_CITIES[input.city]!
  const rawPath = input.from || join(CACHE_DIR, `${input.city}-raw.json`)

  if (!input.force && hasCachedRaw(rawPath)) {
    console.error(`[${input.city}] Using cached scraper JSON ${rawPath}`)
  } else {
    const queriesPath = writeQueries(input.city, config)
    await runScraper({
      city: input.city,
      config,
      queriesPath,
      rawPath,
      depth: input.depth,
    })
  }

  if (!existsSync(rawPath)) {
    throw new Error(`Scraper output missing: ${rawPath}`)
  }

  const entries = parseMapsScraperResults(readFileSync(rawPath, 'utf8'))
  if (entries.length === 0) {
    throw new Error(`Scraper returned no places in ${rawPath}. Leaving ${input.out} unchanged.`)
  }

  const { rows, dropped } = collectPlacesRows(entries.map(mapsScraperEntryToPlace), config)
  sortRows(rows)
  mkdirSync(dirname(input.out), { recursive: true })
  writeFileSync(input.out, placesCsvFile(rows))
  logSummary(input.city, input.out, entries.length, dropped, rows)
  return rows
}

const { selected, out, from, force, depth } = parseArgs(process.argv.slice(2))
const combined: PlacesCsvRow[] = []
const seen = new Set<string>()

for (const city of selected) {
  const cityOut = selected.length === 1 && out
    ? out
    : `data/imports/${city}-places-cafes.csv`
  const rows = await exportCity({ city, out: cityOut, from, force, depth })
  for (const row of rows) {
    if (seen.has(row.google_place_id)) continue
    seen.add(row.google_place_id)
    combined.push(row)
  }
}

if (selected.length > 1) {
  sortRows(combined)
  const combinedOut = out || 'data/imports/catalog-places-cafes.csv'
  mkdirSync(dirname(combinedOut), { recursive: true })
  writeFileSync(combinedOut, placesCsvFile(combined))
  const summary = summarizePlacesRows(combined)
  console.error(`[catalog] Kept ${summary.rows} unique rows`)
  console.error(`[catalog] Import-ready: ${summary.importReady}`)
  console.error(`[catalog] Wrote ${combinedOut}`)
}
