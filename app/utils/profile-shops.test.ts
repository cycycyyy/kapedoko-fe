import { describe, expect, test } from 'bun:test'
import { isSystemAddedShop, profileSubmittedEmptyCopy, splitProfileShops } from './profile-shops'

describe('profile shop groups', () => {
  test('treats in-app submissions as personal, admin and OSM as system', () => {
    expect(isSystemAddedShop({ source: 'user' })).toBe(false)
    expect(isSystemAddedShop({ source: 'admin' })).toBe(true)
    expect(isSystemAddedShop({ source: 'openstreetmap' })).toBe(true)
  })

  test('keeps legacy null source as a user submission unless imported_at is set', () => {
    expect(isSystemAddedShop({ source: null })).toBe(false)
    expect(isSystemAddedShop({})).toBe(false)
    expect(isSystemAddedShop({ source: null, imported_at: '2026-10-08T00:00:00.000Z' })).toBe(true)
    expect(isSystemAddedShop({ source: 'user', imported_at: '2026-10-08T00:00:00.000Z' })).toBe(false)
  })

  test('splits a mixed list without reordering within each group', () => {
    const rows = [
      { id: 'csv', name: 'Starbucks SM Davao Expansion Wing', source: 'admin' as const },
      { id: 'mine', name: 'Top Spatula', source: 'user' as const },
      { id: 'osm', name: 'Clutch Cafe', source: 'openstreetmap' as const },
      { id: 'legacy', name: 'Neighborhood shop', source: null },
    ]
    expect(splitProfileShops(rows)).toEqual({
      submitted: [rows[1], rows[3]],
      systemAdded: [rows[0], rows[2]],
    })
  })

  test('leaves both groups empty when the signed-in user has no shops', () => {
    expect(splitProfileShops([])).toEqual({ submitted: [], systemAdded: [] })
  })

  test('keeps the submitted empty copy', () => {
    expect(profileSubmittedEmptyCopy()).toBe('You have not submitted a cafe yet.')
  })
})
