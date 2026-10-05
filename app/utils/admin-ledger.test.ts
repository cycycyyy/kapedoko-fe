import { describe, expect, test } from 'bun:test'
import {
  ADMIN_LEDGER_PAGE_SIZE,
  ledgerPageCount,
  ledgerPageRange,
  ledgerPageSlice,
  ledgerPageTokens,
} from './admin-ledger'

const cafes = Array.from({ length: 25 }, (_, index) => `cafe-${index + 1}`)

describe('admin cafe ledger pages', () => {
  test('pages a loaded list ten cafes at a time', () => {
    expect(ADMIN_LEDGER_PAGE_SIZE).toBe(10)
    expect(ledgerPageCount(25)).toBe(3)
    expect(ledgerPageSlice(cafes, 1)).toEqual(cafes.slice(0, 10))
    expect(ledgerPageSlice(cafes, 2)).toEqual(cafes.slice(10, 20))
    expect(ledgerPageSlice(cafes, 3)).toEqual(cafes.slice(20))
    expect(ledgerPageRange(25, 2)).toEqual({ start: 11, end: 20, page: 2, pageCount: 3 })
  })

  test('keeps a short last page and clamps a page past the end', () => {
    expect(ledgerPageRange(25, 3)).toEqual({ start: 21, end: 25, page: 3, pageCount: 3 })
    expect(ledgerPageSlice(cafes, 9)).toEqual(cafes.slice(20))
    expect(ledgerPageSlice(['only'], 4)).toEqual(['only'])
  })

  test('treats an empty list as a single empty page', () => {
    expect(ledgerPageCount(0)).toBe(1)
    expect(ledgerPageRange(0, 3)).toEqual({ start: 0, end: 0, page: 1, pageCount: 1 })
    expect(ledgerPageSlice([], 2)).toEqual([])
  })

  test('marks the current page inside a short window', () => {
    expect(ledgerPageTokens(1, 1)).toEqual([1])
    expect(ledgerPageTokens(4, 7)).toEqual([1, 2, 3, 4, 5, 6, 7])
    expect(ledgerPageTokens(1, 12)).toEqual([1, 2, 'gap', 12])
    expect(ledgerPageTokens(6, 12)).toEqual([1, 'gap', 5, 6, 7, 'gap', 12])
    expect(ledgerPageTokens(12, 12)).toEqual([1, 'gap', 11, 12])
  })
})
