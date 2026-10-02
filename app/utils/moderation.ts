import type { ContentReportRow, ShopReviewPublicRow } from '../types/shop'
import { reviewQuote } from './cafe-review'

export type ReportedReviewSource = Pick<
  ShopReviewPublicRow,
  'id' | 'comment' | 'wifi_available' | 'wifi_speed' | 'power_available' | 'power_access' | 'recommend'
>

export function withReportedReviewText(
  reports: ContentReportRow[],
  reviews: ReportedReviewSource[],
): ContentReportRow[] {
  const byId = new Map(reviews.map((row) => [row.id, row]))
  return reports.map((report) => {
    if (report.target_type !== 'review' || !report.review_id) {
      return { ...report, review_text: null }
    }
    const row = byId.get(report.review_id)
    return {
      ...report,
      review_text: row ? reviewQuote(row) : null,
    }
  })
}

export function reportedReviewCopy(report: Pick<ContentReportRow, 'target_type' | 'review_text'>): string | null {
  if (report.target_type !== 'review') return null
  return report.review_text || 'This review is no longer available.'
}
