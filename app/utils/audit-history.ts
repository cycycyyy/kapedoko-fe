import { formatAdminDate } from './admin-nav'
import { longStayWord, paymentTone, paymentWord } from './audit-list'
import { POWER_ACCESS_OPTIONS } from './cafe-review'

export type AuditHistoryTone = 'ok' | 'no' | 'unknown'

export interface AuditHistoryFact {
  key: string
  label: string
  value: string
  tone: AuditHistoryTone
  detail: string | null
}

export interface AuditHistoryVisit {
  id: string
  number: number
  isLatest: boolean
  when: string
  relative: string
  voidReason: string | null
  correctsLabel: string | null
  stay: {
    stance: string
    tone: AuditHistoryTone
    askedStaff: boolean
    seating: string | null
  }
  pay: {
    word: string
    tone: AuditHistoryTone
  }
  connectivity: AuditHistoryFact[]
  notes: string | null
}

export interface AuditHistorySeedReport {
  id: string
  label: string
  result: string
  when: string
}

const AMENITY_ORDER = ['wifi', 'outlets', 'long_stay_wifi'] as const

export function historyAmenityLabel(key: string): string {
  if (key === 'wifi') return 'WiFi'
  if (key === 'outlets') return 'Outlets'
  if (key === 'long_stay_wifi') return 'Long-stay WiFi'
  return humanizeToken(key)
}

export function historyResultWord(result: string | null | undefined): string {
  if (result === 'available') return 'Available'
  if (result === 'unavailable') return 'Unavailable'
  if (result === 'unknown' || !result) return 'Unknown'
  return humanizeToken(result)
}

export function historyResultTone(result: string | null | undefined): AuditHistoryTone {
  if (result === 'available') return 'ok'
  if (result === 'unavailable') return 'no'
  return 'unknown'
}

export function outletReliabilityWord(value: string | null | undefined): string | null {
  if (!value) return null
  const option = POWER_ACCESS_OPTIONS.find((row) => row.value === value)
  return option?.label ?? humanizeToken(value)
}

export function wifiSpeedWord(download: number | null | undefined, upload: number | null | undefined): string | null {
  const down = Number.isFinite(download) ? `${download} Mbps down` : null
  const up = Number.isFinite(upload) ? `${upload} Mbps up` : null
  if (down && up) return `${down} · ${up}`
  return down || up
}

export function seatingWord(count: number | null | undefined): string | null {
  if (count == null || !Number.isFinite(count)) return null
  return count === 1 ? 'About 1 seat' : `About ${count} seats`
}

export function formatAuditRelative(value: string, now = new Date()): string {
  const date = new Date(value)
  if (!Number.isFinite(date.getTime())) return ''
  const diffSec = Math.round((date.getTime() - now.getTime()) / 1000)
  const abs = Math.abs(diffSec)
  const rtf = new Intl.RelativeTimeFormat('en-PH', { numeric: 'auto' })
  if (abs < 60) return rtf.format(0, 'second')
  if (abs < 3600) return rtf.format(Math.round(diffSec / 60), 'minute')
  if (abs < 86400) return rtf.format(Math.round(diffSec / 3600), 'hour')
  if (abs < 86400 * 28) return rtf.format(Math.round(diffSec / 86400), 'day')
  if (abs < 86400 * 365) return rtf.format(Math.round(diffSec / (86400 * 30)), 'month')
  return rtf.format(Math.round(diffSec / (86400 * 365)), 'year')
}

export function visitCountCopy(count: number): string {
  return count === 1 ? '1 visit' : `${count} visits`
}

export function presentAuditHistory(input: {
  audits: Array<{
    id: string
    audited_at: string
    created_at?: string
    long_stay_stance: string
    staff_confirmed_long_stay?: boolean
    seating_capacity_estimate?: number | null
    notes?: string | null
    corrects_audit_id?: string | null
    accepts_qr?: string | null
    accepts_card?: string | null
    accepts_cash?: string | null
  }>
  results: Array<{
    audit_id: string
    amenity_key: string
    result: string
    wifi_download_mbps?: number | null
    wifi_upload_mbps?: number | null
    wifi_network_name?: string | null
    wifi_password_required?: boolean | null
    outlet_approx_count?: number | null
    outlet_reliability?: string | null
    seating_near_outlet_notes?: string | null
    reliability_notes?: string | null
    amenity_notes?: string | null
  }>
  voids: Array<{ audit_id: string; reason: string }>
  now?: Date
}): AuditHistoryVisit[] {
  const now = input.now ?? new Date()
  const sorted = [...input.audits].sort((a, b) => {
    const byVisit = b.audited_at.localeCompare(a.audited_at)
    if (byVisit) return byVisit
    return (b.created_at || '').localeCompare(a.created_at || '')
  })
  const resultsByAudit = new Map<string, typeof input.results>()
  for (const result of input.results) {
    const list = resultsByAudit.get(result.audit_id) ?? []
    list.push(result)
    resultsByAudit.set(result.audit_id, list)
  }
  const voidByAudit = new Map(input.voids.map((row) => [row.audit_id, row.reason]))
  const whenById = new Map(sorted.map((audit) => [audit.id, formatAdminDate(audit.audited_at)]))
  const total = sorted.length

  return sorted.map((audit, index) => {
    const results = [...(resultsByAudit.get(audit.id) ?? [])].sort(sortAmenityResults)
    return {
      id: audit.id,
      number: total - index,
      isLatest: index === 0,
      when: whenById.get(audit.id) || formatAdminDate(audit.audited_at),
      relative: formatAuditRelative(audit.audited_at, now),
      voidReason: voidByAudit.get(audit.id)?.trim() || null,
      correctsLabel: correctsCopy(audit.corrects_audit_id, whenById),
      stay: {
        stance: longStayWord(audit.long_stay_stance),
        tone: stayTone(audit.long_stay_stance),
        askedStaff: Boolean(audit.staff_confirmed_long_stay),
        seating: seatingWord(audit.seating_capacity_estimate),
      },
      pay: {
        word: paymentWord(audit.accepts_qr, audit.accepts_card, audit.accepts_cash),
        tone: paymentTone(audit.accepts_qr, audit.accepts_card, audit.accepts_cash),
      },
      connectivity: results.map(presentConnectivityFact),
      notes: audit.notes?.trim() || null,
    }
  })
}

export function presentSeedReports(
  reports: Array<{ id: string; amenity_key: string; result: string; observed_at: string }>,
): AuditHistorySeedReport[] {
  return reports.map((report) => ({
    id: report.id,
    label: historyAmenityLabel(report.amenity_key),
    result: historyResultWord(report.result),
    when: formatAdminDate(report.observed_at),
  }))
}

function stayTone(stance: string | null | undefined): AuditHistoryTone {
  if (stance === 'welcome') return 'ok'
  if (stance === 'discouraged') return 'no'
  return 'unknown'
}

function presentConnectivityFact(result: {
  amenity_key: string
  result: string
  wifi_download_mbps?: number | null
  wifi_upload_mbps?: number | null
  wifi_network_name?: string | null
  wifi_password_required?: boolean | null
  outlet_approx_count?: number | null
  outlet_reliability?: string | null
  seating_near_outlet_notes?: string | null
  reliability_notes?: string | null
  amenity_notes?: string | null
}): AuditHistoryFact {
  const speed = result.amenity_key === 'wifi'
    ? wifiSpeedWord(result.wifi_download_mbps, result.wifi_upload_mbps)
    : null
  const reliability = result.amenity_key === 'outlets'
    ? outletReliabilityWord(result.outlet_reliability)
    : null
  const value = speed || reliability || historyResultWord(result.result)
  const password = passwordWord(result.wifi_password_required)
  const outlets = result.amenity_key === 'outlets' && result.outlet_approx_count != null
    ? seatingLikeCount(result.outlet_approx_count, 'outlet')
    : null

  return {
    key: result.amenity_key,
    label: historyAmenityLabel(result.amenity_key),
    value,
    tone: historyResultTone(result.result),
    detail: joinDetails([
      result.wifi_network_name,
      password,
      outlets,
      result.seating_near_outlet_notes,
      result.reliability_notes,
      result.amenity_notes,
    ]),
  }
}

function passwordWord(required: boolean | null | undefined): string | null {
  if (required === true) return 'Password needed'
  if (required === false) return 'Open network'
  return null
}

function seatingLikeCount(count: number, noun: 'outlet'): string | null {
  if (!Number.isFinite(count)) return null
  if (count === 1) return `About 1 ${noun}`
  return `About ${count} ${noun}s`
}

function correctsCopy(id: string | null | undefined, whenById: Map<string, string>): string | null {
  if (!id) return null
  const when = whenById.get(id)
  return when ? `Corrects the ${when} visit` : 'Corrects an earlier visit'
}

function sortAmenityResults(a: { amenity_key: string }, b: { amenity_key: string }): number {
  const ai = AMENITY_ORDER.indexOf(a.amenity_key as (typeof AMENITY_ORDER)[number])
  const bi = AMENITY_ORDER.indexOf(b.amenity_key as (typeof AMENITY_ORDER)[number])
  const av = ai === -1 ? AMENITY_ORDER.length : ai
  const bv = bi === -1 ? AMENITY_ORDER.length : bi
  if (av !== bv) return av - bv
  return a.amenity_key.localeCompare(b.amenity_key)
}

function joinDetails(parts: Array<string | null | undefined>): string | null {
  const clean = parts.map((part) => part?.trim()).filter((part): part is string => Boolean(part))
  return clean.length ? clean.join(' · ') : null
}

function humanizeToken(value: string): string {
  return value
    .replace(/[_-]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .replace(/\b\w/g, (letter) => letter.toUpperCase())
}
