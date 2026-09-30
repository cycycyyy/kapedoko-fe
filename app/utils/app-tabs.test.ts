import { describe, expect, test } from 'bun:test'
import { activeAppTab, isSameAppPath, normalizeAppPath } from './app-tabs'

describe('app tab paths', () => {
  test('does not treat profile as already being home', () => {
    expect(isSameAppPath('/app/profile', '/app')).toBe(false)
    expect(isSameAppPath('/app', '/app')).toBe(true)
    expect(isSameAppPath('/app/', '/app')).toBe(true)
    expect(isSameAppPath('/app/profile?tab=1', '/app/profile')).toBe(true)
  })

  test('reads the active tab without matching /app as a prefix of every page', () => {
    expect(activeAppTab('/app')).toBe('home')
    expect(activeAppTab('/app/')).toBe('home')
    expect(activeAppTab('/app/profile')).toBe('profile')
    expect(activeAppTab('/app/favorites')).toBe('saved')
    expect(activeAppTab('/app/map')).toBe('map')
    expect(activeAppTab('/app/cafes/abc')).toBe('home')
    expect(normalizeAppPath('/app/profile/')).toBe('/app/profile')
  })
})
