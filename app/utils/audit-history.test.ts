import { describe, expect, test } from 'bun:test'
import {
  formatAuditRelative,
  historyAmenityLabel,
  historyResultWord,
  outletReliabilityWord,
  presentAuditHistory,
  presentSeedReports,
  seatingWord,
  visitCountCopy,
  wifiSpeedWord,
} from './audit-history'

describe('audit history presentation', () => {
  test('uses human labels instead of amenity keys', () => {
    expect(historyAmenityLabel('wifi')).toBe('WiFi')
    expect(historyAmenityLabel('outlets')).toBe('Outlets')
    expect(historyAmenityLabel('long_stay_wifi')).toBe('Long-stay WiFi')
    expect(historyAmenityLabel('mystery_key')).toBe('Mystery Key')
    expect(historyResultWord('available')).toBe('Available')
    expect(historyResultWord('unavailable')).toBe('Unavailable')
    expect(outletReliabilityWord('easy')).toBe('Easy to find')
    expect(outletReliabilityWord('scarce')).toBe('Hard to get')
    expect(wifiSpeedWord(20, 10)).toBe('20 Mbps down · 10 Mbps up')
    expect(seatingWord(24)).toBe('About 24 seats')
    expect(visitCountCopy(2)).toBe('2 visits')
  })

  test('turns filed visits into grouped history slips', () => {
    const now = new Date('2026-10-09T04:00:00.000Z')
    const visits = presentAuditHistory({
      now,
      audits: [
        {
          id: 'newer',
          audited_at: '2026-10-02T04:34:00.000Z',
          created_at: '2026-10-02T04:34:00.000Z',
          long_stay_stance: 'welcome',
          staff_confirmed_long_stay: true,
          seating_capacity_estimate: 18,
          notes: 'Busy but plenty of plugs.',
          corrects_audit_id: 'older',
          accepts_qr: 'available',
          accepts_card: 'available',
          accepts_cash: 'available',
        },
        {
          id: 'older',
          audited_at: '2026-10-02T04:16:00.000Z',
          created_at: '2026-10-02T04:16:00.000Z',
          long_stay_stance: 'welcome',
          staff_confirmed_long_stay: false,
          accepts_qr: 'unknown',
          accepts_card: 'unknown',
          accepts_cash: 'unknown',
        },
      ],
      results: [
        {
          audit_id: 'newer',
          amenity_key: 'long_stay_wifi',
          result: 'available',
        },
        {
          audit_id: 'newer',
          amenity_key: 'outlets',
          result: 'available',
          outlet_reliability: 'easy',
          outlet_approx_count: 12,
        },
        {
          audit_id: 'newer',
          amenity_key: 'wifi',
          result: 'available',
          wifi_download_mbps: 20,
          wifi_upload_mbps: 10,
          wifi_network_name: 'Arabica Guest',
          wifi_password_required: true,
        },
        {
          audit_id: 'older',
          amenity_key: 'wifi',
          result: 'available',
          wifi_download_mbps: 10,
          wifi_upload_mbps: 5,
        },
      ],
      voids: [{ audit_id: 'older', reason: 'Wrong cafe logged.' }],
    })

    expect(visits.map((visit) => visit.id)).toEqual(['newer', 'older'])
    expect(visits[0]).toMatchObject({
      number: 2,
      isLatest: true,
      voidReason: null,
      correctsLabel: expect.stringMatching(/^Corrects the .+ visit$/),
      stay: { stance: 'Welcome', tone: 'ok', askedStaff: true, seating: 'About 18 seats' },
      pay: { word: 'QR · Card · Cash', tone: 'ok' },
      notes: 'Busy but plenty of plugs.',
    })
    expect(visits[0]!.connectivity.map((fact) => fact.label)).toEqual(['WiFi', 'Outlets', 'Long-stay WiFi'])
    expect(visits[0]!.connectivity[0]).toMatchObject({
      value: '20 Mbps down · 10 Mbps up',
      tone: 'ok',
      detail: 'Arabica Guest · Password needed',
    })
    expect(visits[0]!.connectivity[1]).toMatchObject({
      value: 'Easy to find',
      detail: 'About 12 outlets',
    })
    expect(visits[1]).toMatchObject({
      number: 1,
      isLatest: false,
      voidReason: 'Wrong cafe logged.',
      pay: { word: 'Unknown', tone: 'unknown' },
    })
  })

  test('humanizes seed reports and relative time', () => {
    expect(formatAuditRelative('2026-10-02T04:34:00.000Z', new Date('2026-10-09T04:34:00.000Z'))).toBe('7 days ago')
    expect(presentSeedReports([
      { id: 'r1', amenity_key: 'long_stay_wifi', result: 'available', observed_at: '2026-09-01T00:00:00.000Z' },
    ])[0]).toMatchObject({
      label: 'Long-stay WiFi',
      result: 'Available',
    })
  })
})
