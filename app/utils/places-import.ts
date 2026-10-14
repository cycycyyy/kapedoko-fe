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
  /** Drop these city names even when the pin sits inside `bounds`, unless locality is `name`. */
  excludeLocalityNames?: string[]
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

/** Province of Bulacan, from Obando/SJDM north through Malolos, Baliwag, and San Miguel. */
export const BULACAN_BOUNDS: GeoBounds = {
  south: 14.700,
  north: 15.270,
  west: 120.680,
  east: 121.200,
}

export const BULACAN_CITY: PlacesCityConfig = {
  id: 'bulacan',
  name: 'Bulacan',
  bounds: BULACAN_BOUNDS,
  center: { lat: 14.844, lng: 120.811 },
  nearbyRadiusMeters: 40_000,
  localityNames: [
    'Bulacan',
    'Malolos',
    'Meycauayan',
    'Marilao',
    'Bocaue',
    'Baliwag',
    'Baliuag',
    'Pulilan',
    'Plaridel',
    'Guiguinto',
    'Santa Maria',
    'San Jose del Monte',
    'Norzagaray',
    'Angat',
    'Calumpit',
    'Hagonoy',
    'Obando',
  ],
  textQueries: [
    ...buildPlacesTextQueries({
      areas: [
        'Malolos Bulacan',
        'San Jose del Monte Bulacan',
        'Meycauayan Bulacan',
        'Marilao Bulacan',
        'Bocaue Bulacan',
        'Baliwag Bulacan',
        'Baliuag Bulacan',
        'Santa Maria Bulacan',
        'Pulilan Bulacan',
        'Plaridel Bulacan',
        'Guiguinto Bulacan',
        'Calumpit Bulacan',
        'Hagonoy Bulacan',
        'Norzagaray Bulacan',
        'Angat Bulacan',
        'Obando Bulacan',
        'San Rafael Bulacan',
        'San Ildefonso Bulacan',
        'San Miguel Bulacan',
        'Pandi Bulacan',
        'SM City Marilao',
        'SM City Baliwag',
        'SM City Malolos',
        'SM City San Jose Del Monte',
        'Robinsons Malolos',
      ],
      brands: ['Starbucks', 'ZUS Coffee', 'Coffee Bean'],
      bounds: BULACAN_BOUNDS,
      grid: { rows: 4, cols: 3 },
    }),
    'cafes in Malolos Bulacan',
    'cafes in San Jose del Monte Bulacan',
    'cafes in Meycauayan Bulacan',
    'cafes in Baliwag Bulacan',
    'cafes in Marilao Bulacan',
  ],
  grid: {
    lats: [14.771, 14.914, 15.056, 15.199],
    lngs: [120.767, 120.940, 121.113],
  },
}

/** Province of Pampanga, including Angeles City and Clark. */
export const PAMPANGA_BOUNDS: GeoBounds = {
  south: 14.880,
  north: 15.320,
  west: 120.420,
  east: 120.950,
}

export const PAMPANGA_CITY: PlacesCityConfig = {
  id: 'pampanga',
  name: 'Pampanga',
  bounds: PAMPANGA_BOUNDS,
  center: { lat: 15.07, lng: 120.67 },
  nearbyRadiusMeters: 40_000,
  localityNames: [
    'Pampanga',
    'Angeles',
    'Clark',
    'Mabalacat',
    'Magalang',
    'Guagua',
    'Lubao',
    'Porac',
    'Floridablanca',
    'Apalit',
    'Arayat',
    'Candaba',
    'Bacolor',
    'Balibago',
  ],
  textQueries: [
    ...buildPlacesTextQueries({
      areas: [
        'Angeles City, Philippines',
        'Clark Freeport Pampanga',
        'San Fernando Pampanga',
        'Mabalacat Pampanga',
        'Magalang Pampanga',
        'Mexico Pampanga',
        'Guagua Pampanga',
        'Lubao Pampanga',
        'Porac Pampanga',
        'Floridablanca Pampanga',
        'Apalit Pampanga',
        'Arayat Pampanga',
        'Bacolor Pampanga',
        'Balibago Angeles',
        'Marquee Mall Angeles',
        'SM City Pampanga',
        'Fields Avenue Angeles',
        'Dau Mabalacat',
        'Friendship Highway Angeles',
        'Santo Tomas Pampanga',
      ],
      brands: ['Starbucks', 'ZUS Coffee', 'Coffee Bean'],
      bounds: PAMPANGA_BOUNDS,
      grid: { rows: 4, cols: 3 },
    }),
    'cafes in Angeles City Pampanga',
    'cafes in San Fernando Pampanga',
    'cafes in Clark Pampanga',
    'cafes in Mabalacat Pampanga',
  ],
  grid: {
    lats: [14.940, 15.050, 15.150, 15.250],
    lngs: [120.520, 120.670, 120.820],
  },
}

/** Province of Nueva Ecija, from Gapan north through Cabanatuan to Carranglan. */
export const NUEVA_ECIJA_BOUNDS: GeoBounds = {
  south: 15.150,
  north: 16.120,
  west: 120.520,
  east: 121.350,
}

export const NUEVA_ECIJA_CITY: PlacesCityConfig = {
  id: 'nueva-ecija',
  name: 'Nueva Ecija',
  bounds: NUEVA_ECIJA_BOUNDS,
  center: { lat: 15.49, lng: 120.97 },
  nearbyRadiusMeters: 50_000,
  localityNames: [
    'Nueva Ecija',
    'Cabanatuan',
    'Gapan',
    'Muñoz',
    'Munoz',
    'Palayan',
    'San Jose City',
    'Talavera',
    'Guimba',
    'Aliaga',
    'Jaen',
    'Cabiao',
    'Bongabon',
  ],
  textQueries: [
    ...buildPlacesTextQueries({
      areas: [
        'Cabanatuan Nueva Ecija',
        'Talavera Nueva Ecija',
        'Gapan Nueva Ecija',
        'Science City of Muñoz',
        'Muñoz Nueva Ecija',
        'San Jose City Nueva Ecija',
        'Palayan Nueva Ecija',
        'Guimba Nueva Ecija',
        'Aliaga Nueva Ecija',
        'Jaen Nueva Ecija',
        'Santa Rosa Nueva Ecija',
        'San Leonardo Nueva Ecija',
        'Cabiao Nueva Ecija',
        'San Isidro Nueva Ecija',
        'Zaragoza Nueva Ecija',
        'Bongabon Nueva Ecija',
        'General Tinio Nueva Ecija',
        'Peñaranda Nueva Ecija',
        'Santo Domingo Nueva Ecija',
        'Cuyapo Nueva Ecija',
        'Carranglan Nueva Ecija',
        'SM City Cabanatuan',
        'NE Pacific Mall Cabanatuan',
        'Maharlika Highway Cabanatuan',
      ],
      brands: ['Starbucks', 'ZUS Coffee', 'Coffee Bean'],
      bounds: NUEVA_ECIJA_BOUNDS,
      grid: { rows: 4, cols: 3 },
    }),
    'cafes in Cabanatuan',
    'cafes in Talavera',
    'cafes in Gapan Nueva Ecija',
    'cafes in San Jose City Nueva Ecija',
    'cafes in Muñoz Nueva Ecija',
    'cafes in Palayan',
    'cafes in Guimba',
  ],
  grid: {
    lats: [15.271, 15.514, 15.756, 15.999],
    lngs: [120.658, 120.935, 121.212],
  },
}

/** Corridor around Taft Avenue from UN Avenue / PGH down through Malate, Pasay, and Baclaran. */
export const TAFT_AVENUE_BOUNDS: GeoBounds = {
  south: 14.525,
  north: 14.592,
  west: 120.978,
  east: 121.010,
}

export const TAFT_AVENUE_CITY: PlacesCityConfig = {
  id: 'taft-avenue',
  name: 'Taft Avenue',
  bounds: TAFT_AVENUE_BOUNDS,
  center: { lat: 14.5585, lng: 120.994 },
  nearbyRadiusMeters: 4000,
  localityNames: [
    'Taft',
    'Malate',
    'Ermita',
    'Baclaran',
    'Vito Cruz',
  ],
  textQueries: [
    ...buildPlacesTextQueries({
      areas: [
        'Taft Avenue Manila',
        'Taft Avenue Pasay',
        'Malate Manila',
        'Ermita Manila',
        'Vito Cruz Manila',
        'Pedro Gil Manila',
        'UN Avenue Manila',
        'Padre Faura Manila',
        'Harrison Manila',
        'Baclaran Pasay',
        'Paco Manila',
        'Singalong Manila',
        'Adriatico Malate',
        'DLSU Manila',
      ],
      brands: ['Starbucks', 'ZUS Coffee', 'Coffee Bean'],
      bounds: TAFT_AVENUE_BOUNDS,
      grid: { rows: 4, cols: 2 },
    }),
    'cafes in Taft Avenue Manila',
    'cafes in Malate Manila',
    'cafes in Ermita Manila',
    'cafes in Pasay Taft',
  ],
  grid: {
    lats: [14.533, 14.548, 14.563, 14.578],
    lngs: [120.986, 121.000],
  },
}

export const MARIKINA_BOUNDS: GeoBounds = {
  south: 14.615,
  north: 14.685,
  west: 121.075,
  east: 121.130,
}

export const MARIKINA_CITY: PlacesCityConfig = {
  id: 'marikina',
  name: 'Marikina',
  bounds: MARIKINA_BOUNDS,
  center: { lat: 14.6507, lng: 121.1029 },
  nearbyRadiusMeters: 8000,
  localityNames: ['Marikina'],
  textQueries: [
    ...buildPlacesTextQueries({
      areas: [
        'Marikina, Philippines',
        'Marikina Heights',
        'Concepcion Uno Marikina',
        'Concepcion Dos Marikina',
        'Parang Marikina',
        'Nangka Marikina',
        'San Roque Marikina',
        'Calumpang Marikina',
        'Malanday Marikina',
        'Tumana Marikina',
        'Fortune Marikina',
        'Barangka Marikina',
        'Tanong Marikina',
        'Santo Nino Marikina',
        'Santa Elena Marikina',
        'Industrial Valley Marikina',
        'Riverbanks Marikina',
        'Shoe Avenue Marikina',
        'Gil Fernando Avenue Marikina',
        'Sumulong Highway Marikina',
        'SM City Marikina',
        'SSS Village Marikina',
        'J.P. Rizal Marikina',
        'Dragon Street Marikina',
      ],
      brands: ['Starbucks', 'ZUS Coffee', 'Coffee Bean', "Bo's Coffee", 'Pickup Coffee'],
      bounds: MARIKINA_BOUNDS,
      grid: { rows: 4, cols: 3 },
    }),
    'cafes in Marikina, Philippines',
    'cafes in Marikina Heights',
    'cafes in Concepcion Marikina',
    'cafes in Parang Marikina',
    'cafes in Nangka Marikina',
    'cafes in San Roque Marikina',
    'cafes in Calumpang Marikina',
    'cafes in Tumana Marikina',
    'specialty coffee Marikina',
    'coffee roastery Marikina',
  ],
  grid: {
    lats: [14.625, 14.645, 14.665, 14.680],
    lngs: [121.085, 121.105, 121.125],
  },
}

/** Quezon City proper, from New Manila / Cubao north through Fairview and Novaliches. */
export const QUEZON_CITY_BOUNDS: GeoBounds = {
  south: 14.610,
  north: 14.775,
  west: 121.000,
  east: 121.125,
}

export const QUEZON_CITY: PlacesCityConfig = {
  id: 'quezon-city',
  name: 'Quezon City',
  bounds: QUEZON_CITY_BOUNDS,
  center: { lat: 14.676, lng: 121.044 },
  nearbyRadiusMeters: 12_000,
  localityNames: [
    'Quezon City',
    'Cubao',
    'Diliman',
    'Katipunan',
    'Maginhawa',
    'Fairview',
    'Novaliches',
    'Commonwealth',
    'Eastwood',
    'Kamuning',
    'Timog',
    'Tomas Morato',
    'Batasan',
    'Libis',
  ],
  excludeLocalityNames: [
    'Manila',
    'San Juan',
    'Marikina',
    'Caloocan',
    'Pasig',
    'Taguig',
    'Mandaluyong',
    'Valenzuela',
    'Antipolo',
  ],
  textQueries: [
    ...buildPlacesTextQueries({
      areas: [
        'Quezon City, Philippines',
        'Cubao Quezon City',
        'Diliman Quezon City',
        'Katipunan Quezon City',
        'Tomas Morato Quezon City',
        'Timog Quezon City',
        'Maginhawa Quezon City',
        "Teacher's Village Quezon City",
        'Fairview Quezon City',
        'Novaliches Quezon City',
        'Commonwealth Quezon City',
        'Batasan Quezon City',
        'Eastwood Quezon City',
        'Libis Quezon City',
        'Project 4 Quezon City',
        'Project 6 Quezon City',
        'Project 7 Quezon City',
        'Project 8 Quezon City',
        'Quezon Avenue Quezon City',
        'SM North EDSA Quezon City',
        'Trinoma Quezon City',
        'UP Diliman',
        'Quezon City Circle',
        'Banawe Quezon City',
        'Roosevelt Quezon City',
        'Muñoz Quezon City',
        'Kamuning Quezon City',
        'New Manila Quezon City',
        'Scout Area Quezon City',
        'Don Antonio Quezon City',
        'Holy Spirit Quezon City',
        'Pasong Tamo Quezon City',
        'Tandang Sora Quezon City',
        'Mindanao Avenue Quezon City',
        'North EDSA Quezon City',
      ],
      brands: ['Starbucks', 'ZUS Coffee', 'Coffee Bean'],
      bounds: QUEZON_CITY_BOUNDS,
      grid: { rows: 4, cols: 4 },
    }),
    'cafes in Cubao',
    'cafes in Maginhawa',
    'cafes in Katipunan',
    'cafes in Fairview',
    'cafes in Tomas Morato',
  ],
  grid: {
    lats: [14.631, 14.672, 14.713, 14.754],
    lngs: [121.016, 121.047, 121.078, 121.109],
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
  excludeLocalityNames: [
    'Tagum',
    'Panabo',
    'Digos',
    'Samal',
    'Island Garden City of Samal',
  ],
  textQueries: [
    ...buildPlacesTextQueries({
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
        'Poblacion Davao',
        'Agdao Davao',
        'Bunawan Davao',
        'Paquibato Davao',
        'Baguio District Davao',
        'Marilog Davao',
        'Tugbok Davao',
        'Talomo Davao',
        'Matina Aplaya Davao',
        'Matina Crossing Davao',
        'Matina Pangi Davao',
        'Bangkal Davao',
        'Ma-a Davao',
        'Catalunan Grande Davao',
        'Catalunan Pequeño Davao',
        'Mintal Davao',
        'Ulas Davao',
        'Sasa Davao',
        'Panacan Davao',
        'Tibungco Davao',
        'Cabantian Davao',
        'Indangan Davao',
        'Mandug Davao',
        'Magtuod Davao',
        'Riverside Davao',
        'Juna Subdivision Davao',
        'Quimpo Blvd Davao',
        'C.P. Garcia Davao',
        'F. Torres Davao',
        'Roxas Ave Davao',
        'San Pedro St Davao',
        'Bolton Davao',
        'Bankerohan Davao',
        'Gaisano Mall Davao',
        'Victoria Plaza Davao',
        'NCCC Mall Davao',
        'SM City Davao Ecoland',
        'Azuela Cove Davao',
        'Damosa Davao',
        'Maa Highway Davao',
        'Buhangin Road Davao',
        'Diversion Road Davao',
        'Davao Airport Sasa',
        'SM Lanang Premier',
        'Abreeza Mall Davao',
      ],
      brands: [
        'Starbucks',
        'ZUS Coffee',
        'Coffee Bean',
        "Bo's Coffee",
        'Tim Hortons',
        'Pickup Coffee',
        'Tomoro',
      ],
      bounds: coverageBounds(DAVAO_CITY_REGIONS),
      grid: { rows: 5, cols: 3 },
    }),
    'cafes in Poblacion Davao',
    'cafes in Matina Davao',
    'cafes in Buhangin Davao',
    'cafes in Lanang Davao',
    'cafes in Ecoland Davao',
    'cafes in Toril Davao',
    'cafes in Calinan Davao',
    'cafes in Talomo Davao',
    'cafes in Agdao Davao',
    'cafes in Sasa Davao',
    'specialty coffee Davao',
    'coffee roastery Davao',
  ],
  grid: { lats: [], lngs: [] },
}

export const PLACES_CITIES: Record<string, PlacesCityConfig> = {
  marikina: MARIKINA_CITY,
  'taft-avenue': TAFT_AVENUE_CITY,
  bulacan: BULACAN_CITY,
  pampanga: PAMPANGA_CITY,
  'nueva-ecija': NUEVA_ECIJA_CITY,
  'quezon-city': QUEZON_CITY,
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

function normalizeLocalityToken(value: string): string {
  return value
    .toLowerCase()
    .replace(/metro manila/g, ' ')
    .replace(/\./g, '')
    .replace(/\s+/g, ' ')
    .trim()
}

function tokenMatchesCityName(token: string, name: string): boolean {
  const normalized = normalizeLocalityToken(token)
  const city = name.toLowerCase()
  return normalized === city || normalized === `${city} city` || normalized === `city of ${city}`
}

export function placeMentionsLocality(place: PlacesPlace, names: string[]): boolean {
  if (names.length === 0) return false
  const tokens = [placesLocality(place)]
  const formatted = (place.formattedAddress || '').replace(/metro manila/ig, ' ')
  for (const part of formatted.split(',')) tokens.push(part.trim())
  return names.some((name) => tokens.some((token) => token && tokenMatchesCityName(token, name)))
}

function placeInCityBox(place: PlacesPlace, city: PlacesCityConfig): boolean {
  const point = placesPoint(place)
  if (!point) return false
  if (city.coverageCityId) {
    const regions = CATALOG_IMPORT_CITIES[city.coverageCityId]
    return Boolean(regions?.length && isInCoverage(point, regions))
  }
  return isInBounds(point, city.bounds)
}

export function shouldKeepPlace(place: PlacesPlace, city: PlacesCityConfig): PlacesSkipReason | null {
  if (!place.id?.trim()) return 'missing_place_id'
  if ((place.businessStatus || '').toUpperCase() === 'CLOSED_PERMANENTLY') {
    return 'closed_permanently'
  }
  const inBox = placeInCityBox(place, city)
  if (city.excludeLocalityNames?.length) {
    const namedCity = isCityLocality(place, { localityNames: [city.name] })
    if (placeMentionsLocality(place, city.excludeLocalityNames) && !(inBox && namedCity)) {
      return 'outside_region'
    }
  }
  if (inBox) return null
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
