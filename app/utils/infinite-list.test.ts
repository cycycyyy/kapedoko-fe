import { describe, expect, test } from 'bun:test'
import { advanceWindow, windowItems } from './infinite-list'

describe('infinite list window', () => {
  test('advances one page and stops at the end', () => {
    expect(advanceWindow(12, 40, 12)).toBe(24)
    expect(advanceWindow(36, 40, 12)).toBe(40)
    expect(advanceWindow(40, 40, 12)).toBe(40)
  })

  test('slices only the revealed cafes', () => {
    expect(windowItems(['a', 'b', 'c', 'd'], 2)).toEqual(['a', 'b'])
    expect(windowItems(['a'], 12)).toEqual(['a'])
  })
})
