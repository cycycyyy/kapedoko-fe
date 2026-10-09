import type { LatLng } from '../types/cafe'
import type { DayHours, DayKey, WeeklyHours } from '../types/shop'
import {
  CATALOG_IMPORT_CITIES,
  CEBU_CITY_REGIONS,
  DAVAO_CITY_REGIONS,
  METRO_MANILA_BOUNDS,
  METRO_MANILA_CENTER,
  coverageBounds,
  coverageCenter,
  isInCoverage,
  type GeoBounds,
} from './geography'
import { allDayEveryDay, isValidWeeklyHours } from './hours'
import { isValidAddress, isValidCafeName, normalizeAddress, normalizeCafeName } from './identity'
import { isValidPhone, normalizePhone } from './phone'

export const PLACES_CSV_COLUMNS = [
  'google_place_id',
  'name',
  'address',
  'latitude',
  'longitude',
  'hours_json',
  'contact_number',
  'wifi',
  'outlets',
  'accepts_qr',
  'accepts_card',
  'accepts_cash',
  'business_status',
  'types',
  'website',
  'import_ready',
  'skip_reason',
] as const

export type PlacesCsvColumn = (typeof PLACES_CSV_COLUMNS)[number]

export type PlacesSkipReason =
  | 'closed_permanently'
  | 'outside_region'
  | 'missing_place_id'
  | 'missing_name'
  | 'missing_address'
  | 'missing_pin'
  | 'missing_hours'
  | 'unsupported_hours'

export type PlacesHoursSkip = 'missing' | 'unsupported'

export type PlacesHoursResult =
  | { ok: true; hours: WeeklyHours }
  | { ok: false; reason: PlacesHoursSkip }

export type PlacesPaymentFlag = 'available' | 'unavailable' | ''

export interface PlacesCityConfig {
  id: string
  name: string
  bounds: GeoBounds
  center: LatLng
  nearbyRadiusMeters: number
  textQueries: string[]
  grid: { lats: number[]; lngs: number[] }
  coverageCityId?: keyof typeof CATALOG_IMPORT_CITIES
  localityNames?: string[]
}

export function placesGridQueries(
  bounds: GeoBounds,
  rows: number,
  cols: number,
  term = 'coffee shops',
): string[] {
  const queries: string[] = []
  const latStep = (bounds.north - bounds.south) / Math.max(rows, 1)
  const lngStep = (bounds.east - bounds.west) / Math.max(cols, 1)
  for (let row = 0; row < rows; row += 1) {
    for (let col = 0; col < cols; col += 1) {
      const lat = bounds.south + (row + 0.5) * latStep
      const lng = bounds.west + (col + 0.5) * lngStep
      queries.push(`${term} near ${lat.toFixed(4)}, ${lng.toFixed(4)}`)
    }
  }
  return queries
}

export function buildPlacesTextQueries(input: {
  areas: string[]
  brands?: string[]
  bounds: GeoBounds
  grid?: { rows: number; cols: number }
}): string[] {
  const queries = input.areas.map((area) => `coffee shops in ${area}`)
  for (const brand of input.brands ?? []) {
    const region = input.areas[0]
    if (region) queries.push(`${brand} ${region}`)
  }
  if (input.grid) {
    queries.push(...placesGridQueries(input.bounds, input.grid.rows, input.grid.cols))
  }
  return [...new Set(queries)]
}

export interface PlacesLatLng {
  latitude?: number
  longitude?: number
}

export interface PlacesAddressComponent {
  longText?: string
  shortText?: string
  types?: string[]
}

export interface PlacesOpeningPoint {
  day?: number
  hour?: number
  minute?: number
}

export interface PlacesOpeningPeriod {
  open?: PlacesOpeningPoint
  close?: PlacesOpeningPoint
}

export interface PlacesOpeningHours {
  periods?: PlacesOpeningPeriod[]
  weekdayDescriptions?: string[]
}

export interface PlacesPaymentOptions {
  acceptsCreditCards?: boolean
  acceptsDebitCards?: boolean
  acceptsCashOnly?: boolean
  acceptsNfc?: boolean
}

export interface PlacesPlace {
  id?: string
  displayName?: { text?: string }
  formattedAddress?: string
  addressComponents?: PlacesAddressComponent[]
  location?: PlacesLatLng
  nationalPhoneNumber?: string
  internationalPhoneNumber?: string
  regularOpeningHours?: PlacesOpeningHours
  parsedHours?: PlacesHoursResult
  types?: string[]
  businessStatus?: string
  paymentOptions?: PlacesPaymentOptions
  websiteUri?: string
  wifi?: PlacesPaymentFlag
  outlets?: PlacesPaymentFlag
  acceptsQr?: PlacesPaymentFlag
}

export interface MapsScraperOption {
  name?: string
  enabled?: boolean
  values?: string[]
}

export interface MapsScraperAbout {
  id?: string
  name?: string
  options?: MapsScraperOption[]
}

export interface MapsScraperAddress {
  borough?: string
  street?: string
  city?: string
  postal_code?: string
  state?: string
  country?: string
}

export interface MapsScraperEntry {
  input_id?: string
  link?: string
  title?: string
  category?: string
  categories?: string[]
  address?: string
  open_hours?: Record<string, string[]>
  web_site?: string
  website?: string
  phone?: string
  latitude?: number
  longitude?: number
  longtitude?: number
  cid?: string
  status?: string
  data_id?: string
  place_id?: string
  complete_address?: MapsScraperAddress
  credit_cards_accepted?: string[]
  about?: MapsScraperAbout[]
}

export interface PlacesCsvRow {
  google_place_id: string
  name: string
  address: string
  latitude: string
  longitude: string
  hours_json: string
  contact_number: string
  wifi: string
  outlets: string
  accepts_qr: string
  accepts_card: PlacesPaymentFlag
  accepts_cash: PlacesPaymentFlag
  business_status: string
  types: string
  website: string
  import_ready: 'true' | 'false'
  skip_reason: string
}

export type PlacesNormalizeResult =
  | { keep: true; row: PlacesCsvRow }
  | { keep: false; reason: PlacesSkipReason }

export const MARIKINA_CITY: PlacesCityConfig = {
  id: 'marikina',
  name: 'Marikina',
  bounds: {
    south: 14.615,
    north: 14.685,
    west: 121.075,
    east: 121.130,
  },
  center: { lat: 14.6507, lng: 121.1029 },
  nearbyRadiusMeters: 8000,
  textQueries: [
    'coffee shops in Marikina, Philippines',
    'cafes in Marikina, Philippines',
    'coffee shops in Marikina Heights',
    'coffee shops in Concepcion Marikina',
    'coffee shops in Parang Marikina',
    'coffee shops in Nangka Marikina',
    'coffee shops in San Roque Marikina',
    'Starbucks Marikina',
    'ZUS Coffee Marikina',
  ],
  grid: {
    lats: [14.625, 14.645, 14.665, 14.680],
    lngs: [121.085, 121.105, 121.125],
  },
}

export const METRO_MANILA_CITY: PlacesCityConfig = {
  id: 'metro-manila',
  name: 'Metro Manila',
  bounds: METRO_MANILA_BOUNDS,
  center: METRO_MANILA_CENTER,
  nearbyRadiusMeters: 12_000,
  coverageCityId: 'metro-manila',
  localityNames: [
    'Metro Manila',
    'Manila',
    'Quezon City',
    'Makati',
    'Pasig',
    'Taguig',
    'Pasay',
    'Mandaluyong',
    'San Juan',
    'Marikina',
    'Caloocan',
    'Malabon',
    'Navotas',
    'Valenzuela',
    'Parañaque',
    'Paranaque',
    'Las Piñas',
    'Las Pinas',
    'Muntinlupa',
    'Pateros',
  ],
  textQueries: buildPlacesTextQueries({
    areas: [
      'Manila, Philippines',
      'Quezon City',
      'Makati',
      'Pasig',
      'Taguig',
      'Pasay',
      'Mandaluyong',
      'San Juan Metro Manila',
      'Marikina',
      'Caloocan',
      'Malabon',
      'Navotas',
      'Valenzuela',
      'Parañaque',
      'Las Piñas',
      'Muntinlupa',
      'Pateros',
      'BGC Taguig',
      'Ortigas',
      'Alabang',
      'Cubao',
      'Malate Manila',
      'Binondo',
      'Eastwood Quezon City',
      'Poblacion Makati',
      'Katipunan',
      'Tomas Morato',
      'Kapitolyo Pasig',
    ],
    brands: ['Starbucks', 'ZUS Coffee', 'Coffee Bean'],
    bounds: METRO_MANILA_BOUNDS,
    grid: { rows: 3, cols: 3 },
  }),
  grid: { lats: [], lngs: [] },
}

export const CEBU_CITY: PlacesCityConfig = {
  id: 'cebu-city',
  name: 'Cebu City',
  bounds: coverageBounds(CEBU_CITY_REGIONS),
  center: coverageCenter(CEBU_CITY_REGIONS),
  nearbyRadiusMeters: 8000,
  coverageCityId: 'cebu-city',
  localityNames: ['Cebu City'],
  textQueries: buildPlacesTextQueries({
    areas: [
      'Cebu City, Philippines',
      'IT Park Cebu',
      'Lahug Cebu',
      'Banilad Cebu',
      'Mabolo Cebu',
      'Cebu Business Park',
      'Fuente Osmena Cebu',
      'Colon Street Cebu',
      'Talamban Cebu',
      'Kasambagan Cebu',
      'Capitol Site Cebu',
      'Guadalupe Cebu',
    ],
    brands: ['Starbucks', 'ZUS Coffee'],
    bounds: coverageBounds(CEBU_CITY_REGIONS),
    grid: { rows: 2, cols: 2 },
  }),
  grid: { lats: [], lngs: [] },
}

export const DAVAO_CITY: PlacesCityConfig = {
  id: 'davao-city',
  name: 'Davao City',
  bounds: coverageBounds(DAVAO_CITY_REGIONS),
  center: coverageCenter(DAVAO_CITY_REGIONS),
  nearbyRadiusMeters: 12_000,
  coverageCityId: 'davao-city',
  localityNames: ['Davao City'],
  textQueries: buildPlacesTextQueries({
    areas: [
      'Davao City, Philippines',
      'Bajada Davao',
      'Matina Davao',
      'Lanang Davao',
      'Ecoland Davao',
      'Buhangin Davao',
      'JP Laurel Davao',
      'SM Lanang',
      'Abreeza Davao',
      'Toril Davao',
      'Calinan Davao',
      'Obrero Davao',
    ],
    brands: ['Starbucks', 'ZUS Coffee'],
    bounds: coverageBounds(DAVAO_CITY_REGIONS),
    grid: { rows: 3, cols: 2 },
  }),
  grid: { lats: [], lngs: [] },
}

export const PLACES_CITIES: Record<string, PlacesCityConfig> = {
  marikina: MARIKINA_CITY,
  'metro-manila': METRO_MANILA_CITY,
  'cebu-city': CEBU_CITY,
  'davao-city': DAVAO_CITY,
}

export const PLACES_CATALOG_CITY_IDS = ['metro-manila', 'cebu-city', 'davao-city'] as const

const REGION_NOISE = /^(philippines|metro manila|national capital region|eastern manila( district)?|district( i{1,3})?|\d{4})$/i
const GOOGLE_DAY_TO_KEY: DayKey[] = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
const MAPS_DAY_TO_KEY: Record<string, DayKey> = {
  monday: 'mon',
  tuesday: 'tue',
  wednesday: 'wed',
  thursday: 'thu',
  friday: 'fri',
  saturday: 'sat',
  sunday: 'sun',
}

function closedWeek(): WeeklyHours {
  return {
    mon: { kind: 'closed' },
    tue: { kind: 'closed' },
    wed: { kind: 'closed' },
    thu: { kind: 'closed' },
    fri: { kind: 'closed' },
    sat: { kind: 'closed' },
    sun: { kind: 'closed' },
  }
}

export function isInBounds(point: LatLng, bounds: GeoBounds): boolean {
  return (
    point.lat >= bounds.south
    && point.lat <= bounds.north
    && point.lng >= bounds.west
    && point.lng <= bounds.east
  )
}

export function placesPoint(place: PlacesPlace): LatLng | null {
  const lat = place.location?.latitude
  const lng = place.location?.longitude
  if (typeof lat !== 'number' || typeof lng !== 'number') return null
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null
  return { lat, lng }
}

function componentText(components: PlacesAddressComponent[] | undefined, type: string): string {
  const match = components?.find((component) => component.types?.includes(type))
  return normalizeAddress(match?.longText || match?.shortText || '')
}

export function placesLocality(place: PlacesPlace): string {
  return componentText(place.addressComponents, 'locality')
}

export function isMarikinaLocality(place: PlacesPlace, cityName = 'Marikina'): boolean {
  return isCityLocality(place, { localityNames: [cityName] })
}

export function isCityLocality(
  place: PlacesPlace,
  city: Pick<PlacesCityConfig, 'localityNames'> & { name?: string },
): boolean {
  const names = city.localityNames ?? (city.name ? [city.name] : [])
  const locality = placesLocality(place).toLowerCase()
  const address = (place.formattedAddress || '').toLowerCase()
  return names.some((name) => {
    const needle = name.toLowerCase()
    return locality.includes(needle) || address.includes(needle)
  })
}

export function shouldKeepPlace(place: PlacesPlace, city: PlacesCityConfig): PlacesSkipReason | null {
  if (!place.id?.trim()) return 'missing_place_id'
  if ((place.businessStatus || '').toUpperCase() === 'CLOSED_PERMANENTLY') {
    return 'closed_permanently'
  }
  const point = placesPoint(place)
  if (point) {
    if (city.coverageCityId) {
      const regions = CATALOG_IMPORT_CITIES[city.coverageCityId]
      if (regions?.length && isInCoverage(point, regions)) return null
    } else if (isInBounds(point, city.bounds)) {
      return null
    }
  }
  if (isCityLocality(place, city)) return null
  return 'outside_region'
}

export function placesCafeName(place: PlacesPlace): string {
  return normalizeCafeName(place.displayName?.text || '')
}

export function placesCafeAddress(place: PlacesPlace): string {
  const number = componentText(place.addressComponents, 'street_number')
  const route = componentText(place.addressComponents, 'route')
  const street = [number, route].filter(Boolean).join(' ')
  const barangay =
    componentText(place.addressComponents, 'sublocality_level_1')
    || componentText(place.addressComponents, 'sublocality')
    || componentText(place.addressComponents, 'neighborhood')
  const city =
    componentText(place.addressComponents, 'locality')
    || componentText(place.addressComponents, 'administrative_area_level_2')
  const fromParts = [street, barangay, city].filter(Boolean)
  if (street) return [...new Set(fromParts)].join(', ')

  const kept = (place.formattedAddress || '')
    .split(',')
    .map((part) => part.trim())
    .filter((part) => part && !REGION_NOISE.test(part))
    .slice(0, 3)

  return normalizeAddress(kept.join(', '))
}

export function placesCafePhone(place: PlacesPlace): string | null {
  const raw = normalizePhone(place.nationalPhoneNumber || place.internationalPhoneNumber || '')
  if (!raw) return null
  return isValidPhone(raw) ? raw : null
}

function padClock(hour: number, minute: number): string | null {
  if (!Number.isInteger(hour) || !Number.isInteger(minute)) return null
  if (hour === 24 && minute === 0) return '00:00'
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null
  return `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`
}

function pointClock(point: PlacesOpeningPoint | undefined): string | null {
  if (!point || typeof point.hour !== 'number' || typeof point.minute !== 'number') return null
  return padClock(point.hour, point.minute)
}

function googleDayKey(day: number | undefined): DayKey | null {
  if (typeof day !== 'number' || !Number.isInteger(day) || day < 0 || day > 6) return null
  return GOOGLE_DAY_TO_KEY[day] ?? null
}

function isAlwaysOpenPeriod(period: PlacesOpeningPeriod): boolean {
  return (
    period.close == null
    && period.open?.day === 0
    && period.open.hour === 0
    && period.open.minute === 0
  )
}

function dayHoursFromPeriod(period: PlacesOpeningPeriod): DayHours | 'unsupported' {
  const open = pointClock(period.open)
  if (!open) return 'unsupported'
  if (period.close == null) {
    return isAlwaysOpenPeriod(period) ? { kind: 'all_day' } : 'unsupported'
  }
  const close = pointClock(period.close)
  if (!close) return 'unsupported'
  const openDay = period.open?.day
  const closeDay = period.close.day
  if (typeof openDay !== 'number' || typeof closeDay !== 'number') return 'unsupported'
  if (open === close && (closeDay === openDay || closeDay === (openDay + 1) % 7)) {
    return { kind: 'all_day' }
  }
  return { kind: 'open', open, close }
}

export function normalizeMapsHoursText(value: string): string {
  return value
    .normalize('NFKC')
    .replace(/[\u00A0\u2007\u2009\u202F]/g, ' ')
    .replace(/[–—−]/g, '-')
    .replace(/\s+/g, ' ')
    .trim()
}

function parseMapsClock(raw: string, fallbackMeridiem?: 'am' | 'pm'): string | null {
  const text = normalizeMapsHoursText(raw).toLowerCase()
  const match = text.match(/^(\d{1,2})(?::(\d{2}))?\s*(am|pm)?$/)
  if (!match) return null
  let hour = Number(match[1])
  const minute = Number(match[2] || '0')
  const meridiem = (match[3] as 'am' | 'pm' | undefined) || fallbackMeridiem
  if (!meridiem || hour < 1 || hour > 12 || minute > 59) return null
  if (meridiem === 'am') {
    if (hour === 12) hour = 0
  } else if (hour !== 12) {
    hour += 12
  }
  return `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`
}

function parseMapsDayRange(raw: string): DayHours | 'unsupported' {
  const text = normalizeMapsHoursText(raw)
  if (/^closed$/i.test(text)) return { kind: 'closed' }
  if (/24\s*hours|open 24/i.test(text)) return { kind: 'all_day' }
  const parts = text.split('-').map((part) => part.trim()).filter(Boolean)
  if (parts.length !== 2) return 'unsupported'
  const closeMeridiem = parts[1]!.match(/(am|pm)$/i)?.[1]?.toLowerCase() as 'am' | 'pm' | undefined
  const openMeridiem = parts[0]!.match(/(am|pm)$/i)?.[1]?.toLowerCase() as 'am' | 'pm' | undefined
  const open = parseMapsClock(parts[0]!, openMeridiem || closeMeridiem)
  const close = parseMapsClock(parts[1]!, closeMeridiem)
  if (!open || !close) return 'unsupported'
  if (open === close) return { kind: 'all_day' }
  return { kind: 'open', open, close }
}

export function parseMapsOpenHours(
  hours: Record<string, string[]> | null | undefined,
): PlacesHoursResult {
  if (!hours || Object.keys(hours).length === 0) return { ok: false, reason: 'missing' }
  const week = closedWeek()
  const assigned = new Set<DayKey>()
  for (const [dayName, ranges] of Object.entries(hours)) {
    const key = MAPS_DAY_TO_KEY[dayName.trim().toLowerCase()]
    if (!key) return { ok: false, reason: 'unsupported' }
    const slots = (ranges || []).map((range) => normalizeMapsHoursText(range)).filter(Boolean)
    if (slots.length === 0) continue
    if (slots.length > 1) return { ok: false, reason: 'unsupported' }
    const next = parseMapsDayRange(slots[0]!)
    if (next === 'unsupported') return { ok: false, reason: 'unsupported' }
    week[key] = next
    assigned.add(key)
  }
  if (assigned.size === 0) return { ok: false, reason: 'missing' }
  if (!isValidWeeklyHours(week)) return { ok: false, reason: 'unsupported' }
  return { ok: true, hours: week }
}

function flattenMapsOptions(about: MapsScraperAbout[] | undefined): MapsScraperOption[] {
  return (about || []).flatMap((section) => section.options || [])
}

function mapsOptionEnabled(about: MapsScraperAbout[] | undefined, names: string[]): boolean | null {
  const needles = names.map((name) => name.toLowerCase())
  for (const option of flattenMapsOptions(about)) {
    const label = (option.name || '').trim().toLowerCase()
    if (!needles.some((needle) => label === needle || label.includes(needle))) continue
    if (typeof option.enabled === 'boolean') return option.enabled
  }
  return null
}

function mapsFlag(value: boolean | null): PlacesPaymentFlag {
  if (value === true) return 'available'
  if (value === false) return 'unavailable'
  return ''
}

export function mapsScraperLongitude(entry: MapsScraperEntry): number | undefined {
  const value = entry.longitude ?? entry.longtitude
  return typeof value === 'number' && Number.isFinite(value) ? value : undefined
}

export function mapsScraperEntryToPlace(entry: MapsScraperEntry): PlacesPlace {
  const street = normalizeAddress(entry.complete_address?.street || '')
  const barangay = normalizeAddress(entry.complete_address?.borough || '')
  const city = normalizeAddress(entry.complete_address?.city || '')
  const components: PlacesAddressComponent[] = []
  if (street) components.push({ longText: street, types: ['route'] })
  if (barangay) components.push({ longText: barangay, types: ['sublocality', 'sublocality_level_1'] })
  if (city) components.push({ longText: city, types: ['locality'] })

  const cards = entry.credit_cards_accepted?.filter(Boolean) ?? []
  const wifi = mapsOptionEnabled(entry.about, ['wi-fi', 'wifi', 'wireless'])
  const outlets = mapsOptionEnabled(entry.about, ['outlet', 'power outlet'])
  const qr = mapsOptionEnabled(entry.about, ['gcash', 'maya', 'qr', 'e-wallet', 'e wallet'])
  const cash = mapsOptionEnabled(entry.about, ['cash-only', 'cash only', 'cash'])
  const cardAbout = mapsOptionEnabled(entry.about, ['credit card', 'debit card'])
  const card = cards.length > 0 ? true : cardAbout

  const status = (entry.status || '').toLowerCase()
  let businessStatus = 'OPERATIONAL'
  if (status.includes('permanently closed')) businessStatus = 'CLOSED_PERMANENTLY'
  else if (status.includes('temporarily closed')) businessStatus = 'CLOSED_TEMPORARILY'

  return {
    id: (entry.place_id || entry.data_id || entry.cid || '').trim() || undefined,
    displayName: { text: entry.title },
    formattedAddress: entry.address,
    addressComponents: components,
    location: {
      latitude: entry.latitude,
      longitude: mapsScraperLongitude(entry),
    },
    nationalPhoneNumber: entry.phone,
    parsedHours: parseMapsOpenHours(entry.open_hours),
    types: [
      ...(entry.category ? [entry.category] : []),
      ...(entry.categories || []),
    ].filter(Boolean),
    businessStatus,
    paymentOptions: {
      acceptsCreditCards: card === true ? true : card === false ? false : undefined,
      acceptsCashOnly: cash === true ? true : undefined,
    },
    websiteUri: entry.web_site || entry.website,
    wifi: mapsFlag(wifi),
    outlets: mapsFlag(outlets),
    acceptsQr: mapsFlag(qr),
  }
}

export function parsePlacesOpeningHours(
  hours: PlacesOpeningHours | null | undefined,
): PlacesHoursResult {
  const periods = hours?.periods
  if (!periods?.length) return { ok: false, reason: 'missing' }

  if (periods.length === 1 && periods[0] && isAlwaysOpenPeriod(periods[0])) {
    return { ok: true, hours: allDayEveryDay() }
  }

  const week = closedWeek()
  const assigned = new Set<DayKey>()

  for (const period of periods) {
    const key = googleDayKey(period.open?.day)
    if (!key) return { ok: false, reason: 'unsupported' }
    if (assigned.has(key)) return { ok: false, reason: 'unsupported' }
    const next = dayHoursFromPeriod(period)
    if (next === 'unsupported') return { ok: false, reason: 'unsupported' }
    week[key] = next
    assigned.add(key)
  }

  if (assigned.size === 0) return { ok: false, reason: 'missing' }
  if (!isValidWeeklyHours(week)) return { ok: false, reason: 'unsupported' }
  return { ok: true, hours: week }
}

function paymentAvailable(value: boolean | undefined): boolean {
  return value === true
}

export function placesCardPayment(options: PlacesPaymentOptions | undefined): PlacesPaymentFlag {
  if (!options) return ''
  if (paymentAvailable(options.acceptsCreditCards) || paymentAvailable(options.acceptsDebitCards)) {
    return 'available'
  }
  if (options.acceptsCreditCards === false && options.acceptsDebitCards === false) {
    return 'unavailable'
  }
  return ''
}

export function placesCashPayment(options: PlacesPaymentOptions | undefined): PlacesPaymentFlag {
  if (options?.acceptsCashOnly === true) return 'available'
  return ''
}

function skipReasonForRow(input: {
  name: string
  address: string
  point: LatLng | null
  hours: PlacesHoursResult
}): PlacesSkipReason | '' {
  if (!isValidCafeName(input.name)) return 'missing_name'
  if (!isValidAddress(input.address)) return 'missing_address'
  if (!input.point) return 'missing_pin'
  if (!input.hours.ok) {
    return input.hours.reason === 'missing' ? 'missing_hours' : 'unsupported_hours'
  }
  return ''
}

export function normalizePlacesCafe(
  place: PlacesPlace,
  city: PlacesCityConfig,
): PlacesNormalizeResult {
  const drop = shouldKeepPlace(place, city)
  if (drop) return { keep: false, reason: drop }

  const name = placesCafeName(place)
  const address = placesCafeAddress(place)
  const point = placesPoint(place)
  const hours = place.parsedHours ?? parsePlacesOpeningHours(place.regularOpeningHours)
  const skipReason = skipReasonForRow({ name, address, point, hours })
  const importReady = skipReason === ''

  return {
    keep: true,
    row: {
      google_place_id: place.id?.trim() || '',
      name,
      address,
      latitude: point ? String(point.lat) : '',
      longitude: point ? String(point.lng) : '',
      hours_json: hours.ok ? JSON.stringify(hours.hours) : '',
      contact_number: placesCafePhone(place) ?? '',
      wifi: place.wifi ?? '',
      outlets: place.outlets ?? '',
      accepts_qr: place.acceptsQr ?? '',
      accepts_card: placesCardPayment(place.paymentOptions),
      accepts_cash: placesCashPayment(place.paymentOptions),
      business_status: place.businessStatus || '',
      types: (place.types || []).join('|'),
      website: place.websiteUri || '',
      import_ready: importReady ? 'true' : 'false',
      skip_reason: skipReason,
    },
  }
}

export function collectPlacesRows(
  places: PlacesPlace[],
  city: PlacesCityConfig,
): {
  rows: PlacesCsvRow[]
  dropped: Record<Extract<PlacesSkipReason, 'closed_permanently' | 'outside_region' | 'missing_place_id'>, number>
} {
  const rows: PlacesCsvRow[] = []
  const dropped = {
    closed_permanently: 0,
    outside_region: 0,
    missing_place_id: 0,
  }
  const seen = new Set<string>()

  for (const place of places) {
    const result = normalizePlacesCafe(place, city)
    if (!result.keep) {
      dropped[result.reason] += 1
      continue
    }
    if (seen.has(result.row.google_place_id)) continue
    seen.add(result.row.google_place_id)
    rows.push(result.row)
  }

  return { rows, dropped }
}

export function escapeCsvField(value: string): string {
  if (/[",\n\r]/.test(value)) return `"${value.replaceAll('"', '""')}"`
  return value
}

export function csvLine(values: readonly string[]): string {
  return values.map(escapeCsvField).join(',')
}

export function placesCsvFile(rows: PlacesCsvRow[]): string {
  const lines = [csvLine(PLACES_CSV_COLUMNS)]
  for (const row of rows) {
    lines.push(csvLine(PLACES_CSV_COLUMNS.map((column) => row[column])))
  }
  return `${lines.join('\n')}\n`
}

export function parseMapsScraperResults(raw: string): MapsScraperEntry[] {
  const text = raw.trim()
  if (!text) return []
  if (text.startsWith('[')) {
    const parsed = JSON.parse(text) as MapsScraperEntry[] | { results?: MapsScraperEntry[] }
    return Array.isArray(parsed) ? parsed : parsed.results ?? []
  }
  const rows: MapsScraperEntry[] = []
  for (const line of text.split(/\r?\n/)) {
    const item = line.trim()
    if (!item) continue
    rows.push(JSON.parse(item) as MapsScraperEntry)
  }
  return rows
}

export function summarizePlacesRows(rows: PlacesCsvRow[]) {
  const counts = {
    rows: rows.length,
    importReady: 0,
    missingHours: 0,
    missingAddress: 0,
    missingName: 0,
    missingPin: 0,
    unsupportedHours: 0,
    cardFilled: 0,
    cashFilled: 0,
  }
  for (const row of rows) {
    if (row.import_ready === 'true') counts.importReady += 1
    if (row.skip_reason === 'missing_hours') counts.missingHours += 1
    if (row.skip_reason === 'missing_address') counts.missingAddress += 1
    if (row.skip_reason === 'missing_name') counts.missingName += 1
    if (row.skip_reason === 'missing_pin') counts.missingPin += 1
    if (row.skip_reason === 'unsupported_hours') counts.unsupportedHours += 1
    if (row.accepts_card) counts.cardFilled += 1
    if (row.accepts_cash) counts.cashFilled += 1
  }
  return counts
}
