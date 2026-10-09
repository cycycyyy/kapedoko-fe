import { describe, expect, test } from 'bun:test'
import { allDayEveryDay, sameHoursEveryDay } from './hours'
import {
  bulkApproveCopy,
  bulkProgressCopy,
  bulkRejectCopy,
  matchesRequestSearch,
  requestHoursCopy,
  requestRejectionReasonError,
  requestsQueueEmptyCopy,
  requestStatusWord,
} from './cafe-requests'

describe('cafe request queue', () => {
  test('names statuses and empty slices', () => {
    expect(requestStatusWord('pending')).toBe('Pending')
    expect(requestStatusWord('approved')).toBe('Approved')
    expect(requestsQueueEmptyCopy('pending')).toMatch(/stamp/)
  })

  test('requires a rejection note under 280 characters', () => {
    expect(requestRejectionReasonError('')).toMatch(/why/)
    expect(requestRejectionReasonError('Duplicate of an existing listing.')).toBeNull()
    expect(requestRejectionReasonError('x'.repeat(281))).toMatch(/280/)
  })

  test('keeps mixed hours off the scan line', () => {
    expect(requestHoursCopy(sameHoursEveryDay('08:00', '20:00'))).toBe('8:00am–8:00pm')
    expect(requestHoursCopy(allDayEveryDay())).toMatch(/24/)
    const mixed = {
      ...sameHoursEveryDay('08:00', '17:00'),
      sun: { kind: 'closed' as const },
    }
    expect(requestHoursCopy(mixed)).toMatch(/Hours vary/)
  })

  test('labels bulk stamps and search', () => {
    expect(bulkApproveCopy(1)).toBe('Approve 1 cafe')
    expect(bulkApproveCopy(12)).toBe('Approve all 12')
    expect(bulkRejectCopy(12)).toBe('Reject all 12')
    expect(bulkProgressCopy('approved', 4, 12)).toBe('Approving 4 of 12…')
    expect(matchesRequestSearch({ name: '1821 Café', address: 'San Roque, Marikina' }, 'marikina')).toBe(true)
    expect(matchesRequestSearch({ name: '1821 Café', address: 'San Roque, Marikina' }, 'cainta')).toBe(false)
  })
})
