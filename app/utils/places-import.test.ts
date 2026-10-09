import { describe, expect, test } from 'bun:test'
import { sameHoursEveryDay, allDayEveryDay } from './hours'
import {
  CEBU_CITY,
  DAVAO_CITY,
  MARIKINA_CITY,
  METRO_MANILA_CITY,
  PLACES_CITIES,
  collectPlacesRows,
  escapeCsvField,
  mapsScraperEntryToPlace,
  normalizePlacesCafe,
  parseMapsOpenHours,
  parsePlacesOpeningHours,
  placesCafeAddress,
  placesCafePhone,
  placesCardPayment,
  placesCashPayment,
  placesCsvFile,
  shouldKeepPlace,
  type PlacesPlace,
} from './places-import'

const marikinaPin = { latitude: 14.6507, longitude: 121.1029 }

function cafe(overrides: PlacesPlace = {}): PlacesPlace {
  return {
    id: 'places/ChIJmarikina1',
    displayName: { text: 'BM Street Cafe' },
    formattedAddress: '25 Bronze Street, Concepcion Dos, Marikina, Metro Manila, 1811, Philippines',
    addressComponents: [
      { longText: '25', types: ['street_number'] },
      { longText: 'Bronze Street', types: ['route'] },
      { longText: 'Concepcion Dos', types: ['sublocality_level_1', 'sublocality'] },
      { longText: 'Marikina', types: ['locality'] },
      { longText: 'Metro Manila', types: ['administrative_area_level_1'] },
      { longText: 'Philippines', types: ['country'] },
      { longText: '1811', types: ['postal_code'] },
    ],
    location: marikinaPin,
    nationalPhoneNumber: '0936 943 7956',
    regularOpeningHours: {
      periods: [
        { open: { day: 1, hour: 16, minute: 0 }, close: { day: 1, hour: 22, minute: 0 } },
        { open: { day: 2, hour: 16, minute: 0 }, close: { day: 2, hour: 22, minute: 0 } },
        { open: { day: 3, hour: 16, minute: 0 }, close: { day: 3, hour: 22, minute: 0 } },
        { open: { day: 4, hour: 16, minute: 0 }, close: { day: 4, hour: 22, minute: 0 } },
        { open: { day: 5, hour: 16, minute: 0 }, close: { day: 5, hour: 22, minute: 0 } },
        { open: { day: 6, hour: 16, minute: 0 }, close: { day: 6, hour: 22, minute: 0 } },
      ],
    },
    types: ['cafe', 'coffee_shop', 'point_of_interest'],
    businessStatus: 'OPERATIONAL',
    ...overrides,
  }
}

describe('Places opening hours', () => {
  test('maps a simple weekly window', () => {
    const periods = [1, 2, 3, 4, 5, 6, 0].map((day) => ({
      open: { day, hour: 8, minute: 0 },
      close: { day, hour: 20, minute: 0 },
    }))
    expect(parsePlacesOpeningHours({ periods })).toEqual({
      ok: true,
      hours: sameHoursEveryDay('08:00', '20:00'),
    })
  })

  test('maps overnight close onto the open day', () => {
    const parsed = parsePlacesOpeningHours({
      periods: [
        { open: { day: 5, hour: 18, minute: 0 }, close: { day: 6, hour: 2, minute: 0 } },
      ],
    })
    expect(parsed.ok).toBe(true)
    if (!parsed.ok) return
    expect(parsed.hours.fri).toEqual({ kind: 'open', open: '18:00', close: '02:00' })
    expect(parsed.hours.sat).toEqual({ kind: 'closed' })
  })

  test('maps 24/7 to all day', () => {
    expect(parsePlacesOpeningHours({
      periods: [{ open: { day: 0, hour: 0, minute: 0 } }],
    })).toEqual({ ok: true, hours: allDayEveryDay() })
  })

  test('skips missing and split-shift periods', () => {
    expect(parsePlacesOpeningHours(undefined)).toEqual({ ok: false, reason: 'missing' })
    expect(parsePlacesOpeningHours({ periods: [] })).toEqual({ ok: false, reason: 'missing' })
    expect(parsePlacesOpeningHours({
      periods: [
        { open: { day: 1, hour: 8, minute: 0 }, close: { day: 1, hour: 12, minute: 0 } },
        { open: { day: 1, hour: 13, minute: 0 }, close: { day: 1, hour: 17, minute: 0 } },
      ],
    })).toEqual({ ok: false, reason: 'unsupported' })
  })
})

describe('Places address, phone, and payments', () => {
  test('keeps street, barangay, and city without region noise', () => {
    expect(placesCafeAddress(cafe())).toBe('25 Bronze Street, Concepcion Dos, Marikina')
  })

  test('falls back to a trimmed formatted address', () => {
    expect(placesCafeAddress({
      formattedAddress: 'Shoe Ave, San Roque, Marikina, Metro Manila, 1800, Philippines',
    })).toBe('Shoe Ave, San Roque, Marikina')
  })

  test('keeps a valid PH phone and drops junk', () => {
    expect(placesCafePhone(cafe())).toBe('0936 943 7956')
    expect(placesCafePhone({ nationalPhoneNumber: 'call us' })).toBeNull()
  })

  test('fills card and cash only when Places returned them', () => {
    expect(placesCardPayment(undefined)).toBe('')
    expect(placesCashPayment(undefined)).toBe('')
    expect(placesCardPayment({ acceptsCreditCards: true })).toBe('available')
    expect(placesCardPayment({ acceptsCreditCards: false, acceptsDebitCards: false })).toBe('unavailable')
    expect(placesCashPayment({ acceptsCashOnly: true })).toBe('available')
    expect(placesCashPayment({ acceptsCashOnly: false })).toBe('')
  })
})

describe('Places catalog normalize', () => {
  test('keeps a complete Marikina cafe as import-ready', () => {
    const result = normalizePlacesCafe(cafe(), MARIKINA_CITY)
    expect(result.keep).toBe(true)
    if (!result.keep) return
    expect(result.row.import_ready).toBe('true')
    expect(result.row.skip_reason).toBe('')
    expect(result.row.wifi).toBe('')
    expect(result.row.outlets).toBe('')
    expect(result.row.accepts_qr).toBe('')
    expect(result.row.hours_json).toContain('"mon":{"kind":"open","open":"16:00","close":"22:00"}')
    expect(result.row.hours_json).toContain('"sun":{"kind":"closed"}')
  })

  test('keeps a Marikina-named shop just outside the box', () => {
    const result = normalizePlacesCafe(cafe({
      location: { latitude: 14.610, longitude: 121.1029 },
    }), MARIKINA_CITY)
    expect(result.keep).toBe(true)
  })

  test('keeps Metro Manila, Cebu City, and Davao City pins in their polygons', () => {
    expect(Object.keys(PLACES_CITIES)).toEqual(expect.arrayContaining([
      'metro-manila',
      'cebu-city',
      'davao-city',
    ]))
    expect(shouldKeepPlace(cafe({
      id: 'places/ChIJqc1',
      formattedAddress: 'Tomas Morato, Quezon City, Metro Manila, Philippines',
      addressComponents: [{ longText: 'Quezon City', types: ['locality'] }],
      location: { latitude: 14.634, longitude: 121.034 },
    }), METRO_MANILA_CITY)).toBeNull()
    expect(shouldKeepPlace(cafe({
      id: 'places/ChIJpasig1',
      formattedAddress: 'Ortigas Avenue, Pasig, Metro Manila, Philippines',
      addressComponents: [{ longText: 'Pasig', types: ['locality'] }],
      location: { latitude: 14.586, longitude: 121.061 },
    }), METRO_MANILA_CITY)).toBeNull()
    expect(shouldKeepPlace(cafe({
      id: 'places/ChIJtagaytay',
      formattedAddress: 'Tagaytay, Cavite, Philippines',
      addressComponents: [{ longText: 'Tagaytay', types: ['locality'] }],
      location: { latitude: 14.115, longitude: 120.962 },
    }), METRO_MANILA_CITY)).toBe('outside_region')
    expect(shouldKeepPlace(cafe({
      id: 'places/ChIJcebu1',
      formattedAddress: 'IT Park, Cebu City, Philippines',
      addressComponents: [{ longText: 'Cebu City', types: ['locality'] }],
      location: { latitude: 10.3157, longitude: 123.8854 },
    }), CEBU_CITY)).toBeNull()
    expect(shouldKeepPlace(cafe({
      id: 'places/ChIJdavao1',
      formattedAddress: 'JP Laurel Ave, Davao City, Philippines',
      addressComponents: [{ longText: 'Davao City', types: ['locality'] }],
      location: { latitude: 7.1907, longitude: 125.4553 },
    }), DAVAO_CITY)).toBeNull()
  })

  test('drops Pasig shops and permanently closed places', () => {
    expect(shouldKeepPlace(cafe({
      formattedAddress: 'Ortigas Avenue, Pasig, Metro Manila, Philippines',
      addressComponents: [
        { longText: 'Ortigas Avenue', types: ['route'] },
        { longText: 'Pasig', types: ['locality'] },
      ],
      location: { latitude: 14.586, longitude: 121.061 },
    }), MARIKINA_CITY)).toBe('outside_region')

    expect(shouldKeepPlace(cafe({
      businessStatus: 'CLOSED_PERMANENTLY',
    }), MARIKINA_CITY)).toBe('closed_permanently')
  })

  test('keeps rows that are missing hours so admins can still see them', () => {
    const result = normalizePlacesCafe(cafe({ regularOpeningHours: undefined }), MARIKINA_CITY)
    expect(result.keep).toBe(true)
    if (!result.keep) return
    expect(result.row.import_ready).toBe('false')
    expect(result.row.skip_reason).toBe('missing_hours')
    expect(result.row.hours_json).toBe('')
  })

  test('collect drops closed places and dedupes by Place ID', () => {
    const { rows, dropped } = collectPlacesRows([
      cafe(),
      cafe({ id: 'places/ChIJmarikina1', displayName: { text: 'Duplicate' } }),
      cafe({ id: 'places/closed', businessStatus: 'CLOSED_PERMANENTLY' }),
    ], MARIKINA_CITY)
    expect(rows).toHaveLength(1)
    expect(dropped.closed_permanently).toBe(1)
    expect(rows[0]?.name).toBe('BM Street Cafe')
  })

  test('quotes CSV cells that contain commas', () => {
    expect(escapeCsvField('25 Bronze Street, Concepcion Dos, Marikina')).toBe(
      '"25 Bronze Street, Concepcion Dos, Marikina"',
    )
    const result = normalizePlacesCafe(cafe(), MARIKINA_CITY)
    expect(result.keep).toBe(true)
    if (!result.keep) return
    const csv = placesCsvFile([result.row])
    expect(csv.startsWith('google_place_id,name,address,')).toBe(true)
    expect(csv).toContain('"25 Bronze Street, Concepcion Dos, Marikina"')
  })
})

describe('Maps scraper hours and entries', () => {
  test('maps weekday 12-hour windows, closed days, and inherited meridiem', () => {
    const parsed = parseMapsOpenHours({
      Monday: ['Closed'],
      Tuesday: ['8 AM-8 PM'],
      Wednesday: ['8 AM-8 PM'],
      Thursday: ['8 AM-8 PM'],
      Friday: ['8 AM-8 PM'],
      Saturday: ['4–7:30 PM'],
      Sunday: ['Closed'],
    })
    expect(parsed.ok).toBe(true)
    if (!parsed.ok) return
    expect(parsed.hours.mon).toEqual({ kind: 'closed' })
    expect(parsed.hours.tue).toEqual({ kind: 'open', open: '08:00', close: '20:00' })
    expect(parsed.hours.sat).toEqual({ kind: 'open', open: '16:00', close: '19:30' })
  })

  test('maps overnight close and 24 hours', () => {
    const overnight = parseMapsOpenHours({ Friday: ['6 PM-2 AM'] })
    expect(overnight.ok).toBe(true)
    if (overnight.ok) {
      expect(overnight.hours.fri).toEqual({ kind: 'open', open: '18:00', close: '02:00' })
    }
    expect(parseMapsOpenHours({ Monday: ['Open 24 hours'] }).ok).toBe(true)
  })

  test('skips split shifts', () => {
    expect(parseMapsOpenHours({
      Monday: ['8 AM-12 PM', '1 PM-5 PM'],
    })).toEqual({ ok: false, reason: 'unsupported' })
  })

  test('normalizes a scraper cafe into an import-ready row', () => {
    const place = mapsScraperEntryToPlace({
      place_id: 'ChIJmarikina1',
      title: 'BM Street Cafe',
      address: '25 Bronze Street, Concepcion Dos, Marikina, Metro Manila, Philippines',
      complete_address: {
        street: '25 Bronze Street',
        borough: 'Concepcion Dos',
        city: 'Marikina',
      },
      latitude: 14.6507,
      longtitude: 121.1029,
      phone: '0936 943 7956',
      category: 'Cafe',
      open_hours: {
        Tuesday: ['4 PM-10 PM'],
        Wednesday: ['4 PM-10 PM'],
        Thursday: ['4 PM-10 PM'],
        Friday: ['4 PM-10 PM'],
        Saturday: ['4 PM-10 PM'],
        Sunday: ['4 PM-10 PM'],
      },
      credit_cards_accepted: ['Visa'],
      about: [{
        name: 'Amenities',
        options: [{ name: 'Wi-Fi', enabled: true }],
      }],
    })
    const result = normalizePlacesCafe(place, MARIKINA_CITY)
    expect(result.keep).toBe(true)
    if (!result.keep) return
    expect(result.row.import_ready).toBe('true')
    expect(result.row.wifi).toBe('available')
    expect(result.row.accepts_card).toBe('available')
    expect(result.row.outlets).toBe('')
  })
})
