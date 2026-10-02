#!/usr/bin/env bun
/**
 * Dry-run or import founder amenity reports as `reported` (not reviews).
 *
 *   bun run import:amenities -- --file=data/marikina-amenities.json --dry-run
 *   bun run import:amenities -- --file=data/marikina-amenities.json
 *
 * Rows need source_row_key, shop_id, amenity_key, result, observed_at.
 * Blanks and fuzzy name matches are skipped; they never become unknown.
 */
import { readFileSync } from 'node:fs'
import { createHash } from 'node:crypto'

interface ImportRow {
  source_row_key?: string
  shop_id?: string
  name?: string
  address?: string
  amenity_key?: string
  result?: string
  observed_at?: string
  notes?: string
}

function parseArgs(argv: string[]) {
  let file = ''
  let dryRun = false
  let source = 'founder_seed'
  for (const arg of argv) {
    if (arg.startsWith('--file=')) file = arg.slice(7)
    if (arg === '--dry-run') dryRun = true
    if (arg.startsWith('--source=')) source = arg.slice(9)
  }
  if (!file) throw new Error('Pass --file=path.json')
  return { file, dryRun, source }
}

export function prepareAmenityImportRows(rows: ImportRow[]) {
  const ready: ImportRow[] = []
  const unmatched: ImportRow[] = []
  const invalid: ImportRow[] = []
  for (const row of rows) {
    if (!row.source_row_key || !row.amenity_key || !row.result || !row.observed_at) {
      invalid.push(row)
      continue
    }
    if (row.result !== 'available' && row.result !== 'unavailable') {
      invalid.push(row)
      continue
    }
    if (row.amenity_key !== 'wifi' && row.amenity_key !== 'outlets' && row.amenity_key !== 'long_stay_wifi') {
      invalid.push(row)
      continue
    }
    if (!row.shop_id) {
      unmatched.push(row)
      continue
    }
    ready.push(row)
  }
  return { ready, unmatched, invalid }
}

async function main() {
  const { file, dryRun, source } = parseArgs(process.argv.slice(2))
  const raw = JSON.parse(readFileSync(file, 'utf8')) as ImportRow[] | { rows: ImportRow[] }
  const rows = Array.isArray(raw) ? raw : raw.rows
  const checksum = createHash('sha256').update(readFileSync(file)).digest('hex')
  const prepared = prepareAmenityImportRows(rows)
  const report = {
    checksum,
    source,
    ready: prepared.ready.length,
    unmatched: prepared.unmatched.length,
    invalid: prepared.invalid.length,
    unmatchedKeys: prepared.unmatched.map((row) => row.source_row_key),
    invalidKeys: prepared.invalid.map((row) => row.source_row_key),
  }
  console.log(JSON.stringify(report, null, 2))
  if (dryRun) {
    console.log('Dry run only. No rows written.')
    return
  }
  const url = process.env.NUXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY
  if (!url || !key) {
    throw new Error('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY to import.')
  }
  throw new Error('Live import uses the admin RPC import_cafe_amenity_reports from a signed-in admin session. Use the dry-run here, then call the RPC from /admin.')
}

if (import.meta.main) {
  void main()
}
