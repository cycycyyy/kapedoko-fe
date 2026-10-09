import type { ShopStatus, WeeklyHours } from '../types/shop'
import { formatHoursHint, isValidWeeklyHours, summarizeHours } from './hours'

export const REQUEST_REJECTION_MAX = 280

export function requestStatusWord(status: ShopStatus): string {
  if (status === 'approved') return 'Approved'
  if (status === 'pending') return 'Pending'
  return 'Rejected'
}

export function requestsQueueEmptyCopy(filter: ShopStatus): string {
  if (filter === 'pending') return 'Nothing waiting. New submissions and CSV imports land here to stamp.'
  if (filter === 'approved') return 'No approved cafes in this slice.'
  return 'No rejected cafes.'
}

export function requestRejectionReasonError(value: string): string | null {
  const reason = value.trim()
  if (!reason) return 'Say why this listing stays off Home and Map.'
  if (reason.length > REQUEST_REJECTION_MAX) return 'Keep this under 280 characters.'
  return null
}

export function requestHoursCopy(hours: WeeklyHours | null | undefined): string {
  if (!hours || !isValidWeeklyHours(hours)) return 'Hours to confirm'
  const summary = summarizeHours(hours)
  if (!summary.includes(' · ')) return summary
  return `${formatHoursHint(hours)} · Hours vary`
}

export function bulkApproveCopy(count: number): string {
  if (count === 1) return 'Approve 1 cafe'
  return `Approve all ${count}`
}

export function bulkRejectCopy(count: number): string {
  if (count === 1) return 'Reject 1 cafe'
  return `Reject all ${count}`
}

export function bulkProgressCopy(
  next: Extract<ShopStatus, 'approved' | 'rejected'>,
  done: number,
  total: number,
): string {
  const verb = next === 'approved' ? 'Approving' : 'Rejecting'
  return `${verb} ${done} of ${total}…`
}

export function matchesRequestSearch(
  shop: { name: string; address: string },
  term: string,
): boolean {
  const needle = term.trim().toLowerCase()
  if (!needle) return true
  return `${shop.name} ${shop.address}`.toLowerCase().includes(needle)
}
