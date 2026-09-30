import { describe, expect, test } from 'bun:test'
import { CEBU_CITY_REGIONS, DAVAO_CITY_REGIONS, isInRegion } from './geography'
import { catalogSqlFile, collectOsmCafes, findDuplicateShop, normalizeOsmCafe, philippinesCoverageSql } from './osm-import'
import { sameHoursEveryDay } from './hours'

const cebu = { lat: 10.3157, lng: 123.8854 }
const davao = { lat: 7.1907, lng: 125.4553 }

describe('OSM catalog normalize', () => {
  test('keeps a complete Cebu cafe inside the city polygon', () => {
    const result = normalizeOsmCafe({
      type: 'node',
      id: 1,
      lat: cebu.lat,
      lon: cebu.lng,
      tags: {
        name: 'Yardstick Cebu',
        'addr:full': 'Osmena Boulevard, Cebu City',
        opening_hours: 'Mo-Su 08:00-20:00',
        phone: '0917 123 4567',
      },
    }, CEBU_CITY_REGIONS)
    expect(result.ok).toBe(true)
    if (!result.ok) return
    expect(result.draft.source).toBe('openstreetmap')
    expect(result.draft.osm_id).toBe(1)
    expect(result.draft.hours).toEqual(sameHoursEveryDay('08:00', '20:00'))
  })

  test('skips Mandaue and missing hours', () => {
    expect(normalizeOsmCafe({
      type: 'node',
      id: 2,
      lat: 10.332,
      lon: 123.942,
      tags: {
        name: 'Mandaue Brew',
        'addr:full': 'A.C. Cortes Avenue, Mandaue',
        opening_hours: 'Mo-Su 08:00-20:00',
      },
    }, CEBU_CITY_REGIONS)).toEqual({ ok: false, reason: 'outside_region' })

    expect(normalizeOsmCafe({
      type: 'node',
      id: 3,
      lat: davao.lat,
      lon: davao.lng,
      tags: {
        name: 'Davao Brew',
        'addr:full': 'CM Recto Street, Davao City',
      },
    }, DAVAO_CITY_REGIONS)).toEqual({ ok: false, reason: 'missing_hours' })
  })

  test('dedupes OSM identity then nearby names', () => {
    const draft = {
      name: 'Yardstick Cebu',
      latitude: cebu.lat,
      longitude: cebu.lng,
      osm_type: 'node' as const,
      osm_id: 1,
    }
    expect(findDuplicateShop(draft, [{
      name: 'Other',
      latitude: cebu.lat,
      longitude: cebu.lng,
      source: 'openstreetmap',
      osm_type: 'node',
      osm_id: 1,
    }])).toBe('duplicate_osm')
    expect(findDuplicateShop(draft, [{
      name: 'Yardstick Cebu',
      latitude: cebu.lat + 0.0001,
      longitude: cebu.lng,
    }])).toBe('duplicate_nearby')
  })

  test('collect is idempotent on a second pass of the same elements', () => {
    const elements = [{
      type: 'node' as const,
      id: 9,
      lat: davao.lat,
      lon: davao.lng,
      tags: {
        name: 'Poblacion Coffee',
        'addr:street': 'San Pedro Street',
        'addr:city': 'Davao City',
        opening_hours: '08:00-18:00',
      },
    }]
    const first = collectOsmCafes(elements, DAVAO_CITY_REGIONS)
    expect(first.accepted).toHaveLength(1)
    const second = collectOsmCafes(elements, DAVAO_CITY_REGIONS, first.accepted)
    expect(second.accepted).toHaveLength(0)
    expect(second.skipped.duplicate_osm).toBe(1)
  })

  test('seed SQL activates Visayas and Mindanao before cafe inserts', () => {
    const sql = philippinesCoverageSql()
    expect(sql).toContain("'visayas'")
    expect(sql).toContain("'mindanao'")
    const file = catalogSqlFile([], {
      missing_name: 0,
      missing_address: 0,
      missing_hours: 0,
      unsupported_hours: 0,
      outside_region: 0,
      duplicate_osm: 0,
      duplicate_nearby: 0,
    })
    expect(file.indexOf('coverage_regions')).toBeLessThan(file.indexOf('commit;'))
    expect(file.indexOf("'visayas'")).toBeLessThan(file.indexOf('commit;'))
  })
})
