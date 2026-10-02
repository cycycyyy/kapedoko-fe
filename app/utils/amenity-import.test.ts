import { describe, expect, test } from 'bun:test'
import { prepareAmenityImportRows } from '../../scripts/import-amenity-reports'

describe('amenity seed import matcher', () => {
  test('keeps explicit shop ids and leaves blanks unmatched', () => {
    const prepared = prepareAmenityImportRows([
      {
        source_row_key: 'a1',
        shop_id: '11111111-1111-1111-1111-111111111111',
        amenity_key: 'wifi',
        result: 'available',
        observed_at: '2026-01-01T00:00:00.000Z',
      },
      {
        source_row_key: 'a2',
        name: 'Unknown Cup',
        address: 'Marikina',
        amenity_key: 'outlets',
        result: 'unavailable',
        observed_at: '2026-01-01T00:00:00.000Z',
      },
      {
        source_row_key: 'a3',
        shop_id: '11111111-1111-1111-1111-111111111111',
        amenity_key: 'wifi',
        result: 'maybe',
        observed_at: '2026-01-01T00:00:00.000Z',
      },
    ])
    expect(prepared.ready.map((row) => row.source_row_key)).toEqual(['a1'])
    expect(prepared.unmatched.map((row) => row.source_row_key)).toEqual(['a2'])
    expect(prepared.invalid.map((row) => row.source_row_key)).toEqual(['a3'])
  })
})
