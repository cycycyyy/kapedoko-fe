import { describe, expect, test } from 'bun:test'
import {
  amenityKeyLabel,
  auditAmenityCardWord,
  auditAmenityTone,
  auditAmenityWord,
  auditQueueCafes,
  auditedCafeRows,
  filterAuditedCafes,
  longStayWord,
  paymentTone,
  paymentWord,
  queueTicketDetail,
} from './audit-list'

describe('audit list', () => {
  test('groups queue amenities onto one cafe and keeps recheck first', () => {
    const cafes = auditQueueCafes([
      { shop_id: 'recheck', amenity_key: 'wifi', needs_recheck: true, is_stale: false, source_at: '2026-09-01T00:00:00.000Z' },
      { shop_id: 'recheck', amenity_key: 'outlets', needs_recheck: false, is_stale: true, source_at: '2026-01-01T00:00:00.000Z' },
      { shop_id: 'stale', amenity_key: 'wifi', needs_recheck: false, is_stale: true, source_at: '2025-06-01T00:00:00.000Z' },
    ])
    expect(cafes.map((row) => row.shopId)).toEqual(['recheck', 'stale'])
    expect(cafes[0]).toMatchObject({
      urgency: 'recheck',
      amenityKeys: ['wifi', 'outlets'],
      sourceAt: '2026-01-01T00:00:00.000Z',
    })
    expect(queueTicketDetail(cafes[0]!)).toBe('Needs recheck · WiFi, Outlets')
    expect(queueTicketDetail(cafes[1]!)).toBe('Stale · WiFi')
  })

  test('lists the latest valid visit per cafe and skips voided ones', () => {
    const rows = auditedCafeRows(
      [
        { id: 'old', shop_id: 'a', audited_at: '2026-01-01T00:00:00.000Z', created_at: '2026-01-01T00:00:00.000Z', long_stay_stance: 'welcome' },
        { id: 'new', shop_id: 'a', audited_at: '2026-09-01T00:00:00.000Z', created_at: '2026-09-01T00:00:00.000Z', long_stay_stance: 'discouraged', accepts_qr: 'available', accepts_card: 'unavailable', accepts_cash: 'available' },
        { id: 'voided', shop_id: 'b', audited_at: '2026-10-01T00:00:00.000Z', created_at: '2026-10-01T00:00:00.000Z', long_stay_stance: 'welcome' },
        { id: 'kept', shop_id: 'b', audited_at: '2026-08-01T00:00:00.000Z', created_at: '2026-08-01T00:00:00.000Z', long_stay_stance: 'unknown' },
        { id: 'c', shop_id: 'c', audited_at: '2026-07-01T00:00:00.000Z', created_at: '2026-07-01T00:00:00.000Z', long_stay_stance: 'welcome' },
      ],
      [
        { audit_id: 'new', amenity_key: 'wifi', result: 'available' },
        { audit_id: 'new', amenity_key: 'outlets', result: 'unavailable' },
        { audit_id: 'kept', amenity_key: 'wifi', result: 'unknown' },
        { audit_id: 'c', amenity_key: 'outlets', result: 'available' },
      ],
      ['voided'],
    )
    expect(rows.map((row) => row.shopId)).toEqual(['a', 'b', 'c'])
    expect(rows[0]).toMatchObject({
      auditId: 'new',
      wifi: 'available',
      outlets: 'unavailable',
      longStayStance: 'discouraged',
      qr: 'available',
      card: 'unavailable',
      cash: 'available',
    })
    expect(rows[1]).toMatchObject({ auditId: 'kept', wifi: 'unknown', outlets: null })
  })

  test('labels amenities and search for the desk', () => {
    expect(amenityKeyLabel('wifi')).toBe('WiFi')
    expect(amenityKeyLabel('outlets')).toBe('Outlets')
    expect(auditAmenityWord('wifi', 'available')).toBe('Available')
    expect(auditAmenityWord('outlets', 'unavailable')).toBe('No outlets')
    expect(auditAmenityCardWord('wifi', 'available')).toBe('WiFi')
    expect(auditAmenityCardWord('outlets', 'unavailable')).toBe('No outlets')
    expect(auditAmenityCardWord('wifi', null)).toBe('WiFi unknown')
    expect(auditAmenityTone('available')).toBe('ok')
    expect(auditAmenityTone(null)).toBe('unknown')
    expect(longStayWord('welcome')).toBe('Welcome')
    expect(paymentWord('available', 'unavailable', 'available')).toBe('QR · Cash')
    expect(paymentWord('unavailable', 'unavailable', 'unavailable')).toBe('No QR, card, or cash')
    expect(paymentWord(null, null, null)).toBe('Unknown')
    expect(paymentTone('available', 'unavailable', 'unknown')).toBe('ok')
    expect(paymentTone('unavailable', 'unavailable', 'unavailable')).toBe('no')
    expect(filterAuditedCafes([{ name: 'Tobys' }, { name: 'Yardstick' }], 'tob')).toEqual([{ name: 'Tobys' }])
    expect(filterAuditedCafes([{ name: 'Tobys' }], '  ')).toHaveLength(1)
  })
})
