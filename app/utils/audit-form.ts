import type { PowerAccess } from '../types/shop'

export const AUDIT_PHOTO_MAX_BYTES = 4 * 1024 * 1024
export const AUDIT_PHOTO_MAX_COUNT = 3
export const AUDIT_NOTES_MAX = 2000

export type AuditAmenityResult = 'available' | 'unavailable' | 'unknown'
export type LongStayStance = 'welcome' | 'discouraged' | 'unknown'
export type PaymentMethod = 'qr' | 'card' | 'cash'

export interface AuditPaymentDraft {
  qr: AuditAmenityResult | null
  card: AuditAmenityResult | null
  cash: AuditAmenityResult | null
}

export const PAYMENT_METHODS: Array<{ id: PaymentMethod; label: string }> = [
  { id: 'qr', label: 'QR' },
  { id: 'card', label: 'Card' },
  { id: 'cash', label: 'Cash' },
]

export const PAYMENT_CHOICES: Array<{ id: AuditAmenityResult; label: string }> = [
  { id: 'available', label: 'Yes' },
  { id: 'unavailable', label: 'No' },
  { id: 'unknown', label: 'Unknown' },
]

export interface AuditWifiDraft {
  result: AuditAmenityResult | null
  downloadMbps: string
  uploadMbps: string
  networkName: string
  passwordRequired: boolean | null
  notes: string
}

export interface AuditOutletsDraft {
  result: AuditAmenityResult | null
  approxCount: string
  reliability: PowerAccess | null
  seatingNearOutletNotes: string
  reliabilityNotes: string
  notes: string
}

export interface CafeAuditDraft {
  shopId: string
  auditedAt: string
  timezone: string
  timeOfDayLocal: string
  seatingCapacity: string
  longStayStance: LongStayStance | null
  staffConfirmedLongStay: boolean
  notes: string
  wifi: AuditWifiDraft
  outlets: AuditOutletsDraft
  payment: AuditPaymentDraft
  correctsAuditId: string | null
}

export interface CafeAuditFormErrors {
  shop: string | null
  wifi: string | null
  outlets: string | null
  longStay: string | null
  payment: string | null
  seating: string | null
  notes: string | null
  photos: string | null
}

export function emptyAuditDraft(): CafeAuditDraft {
  return {
    shopId: '',
    auditedAt: new Date().toISOString(),
    timezone: 'Asia/Manila',
    timeOfDayLocal: '',
    seatingCapacity: '',
    longStayStance: null,
    staffConfirmedLongStay: false,
    notes: '',
    wifi: {
      result: null,
      downloadMbps: '',
      uploadMbps: '',
      networkName: '',
      passwordRequired: null,
      notes: '',
    },
    outlets: {
      result: null,
      approxCount: '',
      reliability: null,
      seatingNearOutletNotes: '',
      reliabilityNotes: '',
      notes: '',
    },
    payment: {
      qr: null,
      card: null,
      cash: null,
    },
    correctsAuditId: null,
  }
}

export function auditFormError(draft: CafeAuditDraft, photoCount = 0): CafeAuditFormErrors {
  const seating = parseOptionalNonNegative(draft.seatingCapacity)
  return {
    shop: draft.shopId ? null : 'Choose a cafe.',
    wifi: amenityResultError('WiFi', draft.wifi.result, draft.wifi.notes, {
      download: draft.wifi.downloadMbps,
      upload: draft.wifi.uploadMbps,
    }),
    outlets: amenityResultError('Outlets', draft.outlets.result, draft.outlets.notes || draft.outlets.reliabilityNotes, {
      reliability: draft.outlets.result === 'available' ? draft.outlets.reliability : 'easy',
      count: draft.outlets.approxCount,
    }),
    longStay: draft.longStayStance ? null : 'Choose a long-stay stance.',
    payment: paymentError(draft.payment),
    seating: seating.error,
    notes: draft.notes.length > AUDIT_NOTES_MAX ? `Keep notes under ${AUDIT_NOTES_MAX} characters.` : null,
    photos: photoCount > AUDIT_PHOTO_MAX_COUNT ? 'Keep audit photos to three.' : null,
  }
}

export function auditFormHasErrors(errors: CafeAuditFormErrors): boolean {
  return Object.values(errors).some(Boolean)
}

export function auditPhotoError(file: File | null): string | null {
  if (!file) return null
  if (!['image/jpeg', 'image/png', 'image/webp'].includes(file.type)) {
    return 'Use a JPG, PNG, or WebP image.'
  }
  if (file.size > AUDIT_PHOTO_MAX_BYTES) return 'Keep each photo under 4 MB.'
  return null
}

export function auditWifiPayload(draft: AuditWifiDraft) {
  return {
    result: draft.result,
    download_mbps: optionalNumber(draft.downloadMbps),
    upload_mbps: optionalNumber(draft.uploadMbps),
    network_name: draft.networkName.trim() || null,
    password_required: draft.passwordRequired,
    notes: draft.notes.trim() || null,
  }
}

export function auditOutletsPayload(draft: AuditOutletsDraft) {
  return {
    result: draft.result,
    approx_count: optionalNumber(draft.approxCount),
    reliability: draft.result === 'available' ? draft.reliability : null,
    seating_near_outlet_notes: draft.seatingNearOutletNotes.trim() || null,
    reliability_notes: draft.reliabilityNotes.trim() || null,
    notes: draft.notes.trim() || null,
  }
}

export function voidReasonError(reason: string): string | null {
  if (reason.trim().length < 8) return 'Say why this audit is voided.'
  return null
}

function paymentError(payment: AuditPaymentDraft): string | null {
  const missing = PAYMENT_METHODS.filter((method) => !payment[method.id]).map((method) => method.label)
  if (!missing.length) return null
  if (missing.length === 3) return 'Choose QR, card, and cash for this visit.'
  if (missing.length === 1) return `Choose whether ${missing[0]} payment worked.`
  return `Choose whether ${missing.join(' and ')} payment worked.`
}

function amenityResultError(
  label: string,
  result: AuditAmenityResult | null,
  notes: string,
  extras: { download?: string; upload?: string; reliability?: string | null; count?: string },
): string | null {
  if (!result) return `Choose a ${label} result.`
  if (result === 'unknown' && notes.trim().length < 4) return `Say why ${label.toLowerCase()} is unknown.`
  if (extras.download != null && extras.download !== '' && !isNonNegativeNumber(extras.download)) {
    return 'Download speed cannot be negative.'
  }
  if (extras.upload != null && extras.upload !== '' && !isNonNegativeNumber(extras.upload)) {
    return 'Upload speed cannot be negative.'
  }
  if (result === 'available' && extras.reliability === null) return 'Choose outlet reliability.'
  if (extras.count != null && extras.count !== '' && !isNonNegativeNumber(extras.count)) {
    return 'Outlet count cannot be negative.'
  }
  if (result === 'available' && extras.download === '0' && extras.upload === '0') {
    return notes.trim() ? null : 'Add a note when measured speed is 0.'
  }
  return null
}

function parseOptionalNonNegative(value: string): { error: string | null } {
  if (!value.trim()) return { error: null }
  if (!isNonNegativeNumber(value)) return { error: 'Seating capacity cannot be negative.' }
  return { error: null }
}

function isNonNegativeNumber(value: string): boolean {
  const parsed = Number(value)
  return Number.isFinite(parsed) && parsed >= 0
}

function optionalNumber(value: string): number | null {
  if (!value.trim()) return null
  const parsed = Number(value)
  return Number.isFinite(parsed) ? parsed : null
}
