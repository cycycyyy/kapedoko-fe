import type { WeeklyHours } from '../types/shop'
import { isValidLatitude, isValidLongitude } from './admin-shop'
import { isValidWeeklyHours } from './hours'
import { isValidAddress, isValidCafeName, normalizeAddress, normalizeCafeName } from './identity'
import { isNearbyShop, namesMatch, OSM_NEARBY_DEGREES, type ExistingCatalogShop } from './osm-import'
import { isValidPhone, normalizePhone } from './phone'

export type CrateDecision = 'undecided' | 'keep' | 'skip'

export type CrateBlockReason =
  | 'missing_name'
  | 'missing_address'
  | 'missing_pin'
  | 'missing_hours'
  | 'unsupported_hours'
  | 'duplicate_nearby'

export interface CrateTicket {
  key: string
  row: number
  name: string
  address: string
  latitude: number | null
  longitude: number | null
  hours: WeeklyHours | null
  contact_number: string | null
  google_place_id: string
  blockReason: CrateBlockReason | null
  matchName: string | null
  decision: CrateDecision
}

export interface CatalogImportDraft {
  name: string
  address: string
  latitude: number
  longitude: number
  hours: WeeklyHours
  contact_number: string | null
}

export interface CrateTally {
  total: number
  keep: number
  skip: number
  undecided: number
  blocked: number
  duplicates: number
}

const REQUIRED_HEADERS = ['name', 'address', 'latitude', 'longitude', 'hours_json'] as const

export function parseCsvRecords(raw: string): string[][] {
  const text = raw.replace(/^\uFEFF/, '')
  const rows: string[][] = []
  let row: string[] = []
  let field = ''
  let quoted = false

  for (let i = 0; i < text.length; i += 1) {
    const char = text[i]!
    if (quoted) {
      if (char === '"') {
        if (text[i + 1] === '"') {
          field += '"'
          i += 1
        } else {
          quoted = false
        }
      } else {
        field += char
      }
      continue
    }
    if (char === '"') {
      quoted = true
      continue
    }
    if (char === ',') {
      row.push(field)
      field = ''
      continue
    }
    if (char === '\n') {
      if (field.endsWith('\r')) field = field.slice(0, -1)
      row.push(field)
      if (row.some((value) => value.length > 0)) rows.push(row)
      row = []
      field = ''
      continue
    }
    field += char
  }

  if (quoted) throw new Error('That CSV has a quote that never closes.')
  if (field.endsWith('\r')) field = field.slice(0, -1)
  if (field.length > 0 || row.length > 0) {
    row.push(field)
    if (row.some((value) => value.length > 0)) rows.push(row)
  }
  return rows
}

function headerIndex(header: string[]): Record<string, number> {
  const map: Record<string, number> = {}
  header.forEach((name, index) => {
    map[name.trim().toLowerCase()] = index
  })
  return map
}

function cell(row: string[], index: Record<string, number>, name: string): string {
  const at = index[name]
  if (at == null) return ''
  return (row[at] ?? '').trim()
}

function parseHours(raw: string): { hours: WeeklyHours | null; reason: CrateBlockReason | null } {
  if (!raw) return { hours: null, reason: 'missing_hours' }
  try {
    const parsed = JSON.parse(raw) as WeeklyHours
    if (!isValidWeeklyHours(parsed)) return { hours: null, reason: 'unsupported_hours' }
    return { hours: parsed, reason: null }
  } catch {
    return { hours: null, reason: 'unsupported_hours' }
  }
}

function parsePin(latRaw: string, lngRaw: string): { lat: number | null; lng: number | null } {
  const lat = Number(latRaw)
  const lng = Number(lngRaw)
  return {
    lat: isValidLatitude(lat) ? lat : null,
    lng: isValidLongitude(lng) ? lng : null,
  }
}

export function crateBlockReason(input: {
  name: string
  address: string
  lat: number | null
  lng: number | null
  hours: WeeklyHours | null
  hoursReason: CrateBlockReason | null
}): CrateBlockReason | null {
  if (!isValidCafeName(input.name)) return 'missing_name'
  if (!isValidAddress(input.address)) return 'missing_address'
  if (input.lat == null || input.lng == null) return 'missing_pin'
  if (!input.hours) return input.hoursReason ?? 'missing_hours'
  return null
}

export function findNearbyCatalogMatch(
  draft: { name: string; latitude: number; longitude: number },
  existing: ExistingCatalogShop[],
): ExistingCatalogShop | null {
  for (const shop of existing) {
    if (!namesMatch(shop.name, draft.name)) continue
    if (isNearbyShop({ lat: draft.latitude, lng: draft.longitude }, shop, OSM_NEARBY_DEGREES)) {
      return shop
    }
  }
  return null
}

export function parseCafeImportCsv(
  raw: string,
  existing: ExistingCatalogShop[] = [],
): CrateTicket[] {
  const records = parseCsvRecords(raw)
  if (records.length < 2) throw new Error('That file has no cafe rows.')
  const index = headerIndex(records[0] ?? [])
  for (const name of REQUIRED_HEADERS) {
    if (index[name] == null) {
      throw new Error('Use the KapeDoko cafe CSV (name, address, latitude, longitude, hours_json).')
    }
  }

  const tickets: CrateTicket[] = []
  const seen: ExistingCatalogShop[] = [...existing]

  for (const [rowIndex, row] of records.slice(1).entries()) {
    const name = normalizeCafeName(cell(row, index, 'name'))
    const address = normalizeAddress(cell(row, index, 'address'))
    const { lat, lng } = parsePin(cell(row, index, 'latitude'), cell(row, index, 'longitude'))
    const { hours, reason: hoursReason } = parseHours(cell(row, index, 'hours_json'))
    const phoneRaw = normalizePhone(cell(row, index, 'contact_number'))
    const googlePlaceId = cell(row, index, 'google_place_id')
    let blockReason = crateBlockReason({ name, address, lat, lng, hours, hoursReason })
    let matchName: string | null = null

    if (!blockReason && lat != null && lng != null) {
      const match = findNearbyCatalogMatch({ name, latitude: lat, longitude: lng }, seen)
      if (match) {
        blockReason = 'duplicate_nearby'
        matchName = match.name
      }
    }

    const ticket: CrateTicket = {
      key: googlePlaceId ? `${googlePlaceId}:${rowIndex + 1}` : `row-${rowIndex + 1}`,
      row: rowIndex + 1,
      name,
      address,
      latitude: lat,
      longitude: lng,
      hours,
      contact_number: phoneRaw && isValidPhone(phoneRaw) ? phoneRaw : null,
      google_place_id: googlePlaceId,
      blockReason,
      matchName,
      decision: isHardBlock(blockReason) ? 'skip' : 'undecided',
    }
    tickets.push(ticket)
    if (lat != null && lng != null && name) {
      seen.push({ name, latitude: lat, longitude: lng })
    }
  }

  if (tickets.length === 0) throw new Error('That file has no cafe rows.')
  return tickets
}

export function isHardBlock(reason: CrateBlockReason | null): boolean {
  return reason != null && reason !== 'duplicate_nearby'
}

export function canKeepTicket(ticket: CrateTicket): boolean {
  return !isHardBlock(ticket.blockReason)
}

export function crateTally(tickets: CrateTicket[]): CrateTally {
  const tally: CrateTally = {
    total: tickets.length,
    keep: 0,
    skip: 0,
    undecided: 0,
    blocked: 0,
    duplicates: 0,
  }
  for (const ticket of tickets) {
    if (ticket.decision === 'keep') tally.keep += 1
    else if (ticket.decision === 'skip') tally.skip += 1
    else tally.undecided += 1
    if (isHardBlock(ticket.blockReason)) tally.blocked += 1
    if (ticket.blockReason === 'duplicate_nearby') tally.duplicates += 1
  }
  return tally
}

export function canCommitCrate(tickets: CrateTicket[]): boolean {
  const tally = crateTally(tickets)
  return tally.undecided === 0 && tally.keep > 0
}

export function stampTicket(
  tickets: CrateTicket[],
  key: string,
  decision: Exclude<CrateDecision, 'undecided'>,
): CrateTicket[] {
  return tickets.map((ticket) => {
    if (ticket.key !== key) return ticket
    if (decision === 'keep' && !canKeepTicket(ticket)) return ticket
    return { ...ticket, decision }
  })
}

export function stampReadyTickets(tickets: CrateTicket[]): CrateTicket[] {
  return tickets.map((ticket) => {
    if (ticket.decision !== 'undecided') return ticket
    if (ticket.blockReason) return ticket
    return { ...ticket, decision: 'keep' }
  })
}

export function stampDuplicateTickets(tickets: CrateTicket[], decision: 'keep' | 'skip'): CrateTicket[] {
  return tickets.map((ticket) => {
    if (ticket.blockReason !== 'duplicate_nearby') return ticket
    return { ...ticket, decision }
  })
}

export function keptImportDrafts(tickets: CrateTicket[]): CatalogImportDraft[] {
  return tickets.flatMap((ticket) => {
    if (ticket.decision !== 'keep') return []
    if (!ticket.hours || ticket.latitude == null || ticket.longitude == null) return []
    if (!canKeepTicket(ticket)) return []
    return [{
      name: ticket.name,
      address: ticket.address,
      latitude: ticket.latitude,
      longitude: ticket.longitude,
      hours: ticket.hours,
      contact_number: ticket.contact_number,
    }]
  })
}

export function crateReasonCopy(ticket: CrateTicket): string {
  if (ticket.blockReason === 'duplicate_nearby') {
    return ticket.matchName ? `Already listed as ${ticket.matchName}` : 'Already listed nearby'
  }
  if (ticket.blockReason === 'missing_hours' || ticket.blockReason === 'unsupported_hours') {
    return 'Needs hours before it can land'
  }
  if (ticket.blockReason === 'missing_address') return 'Needs a fuller street address'
  if (ticket.blockReason === 'missing_pin') return 'Needs a map pin'
  if (ticket.blockReason === 'missing_name') return 'Needs a cafe name'
  return ''
}
