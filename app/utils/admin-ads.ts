export function campaignWindowError(startsAt: string, endsAt: string, now = new Date()): string | null {
  const start = new Date(startsAt)
  const end = new Date(endsAt)
  if (!Number.isFinite(start.getTime()) || !Number.isFinite(end.getTime())) {
    return 'Choose a start and end time.'
  }
  if (end <= start) return 'Choose an end date after the start date.'
  if (end <= now) return 'Choose an end time in the future.'
  return null
}

export function isAdCampaignActive(
  campaign: {
    enabled?: boolean
    cancelled_at?: string | null
    starts_at: string
    ends_at: string
  },
  now = new Date(),
): boolean {
  if (campaign.enabled === false || campaign.cancelled_at) return false
  const start = new Date(campaign.starts_at).getTime()
  const end = new Date(campaign.ends_at).getTime()
  const at = now.getTime()
  return Number.isFinite(start) && Number.isFinite(end) && start <= at && end > at
}

export const BANNER_MAX_BYTES = 4 * 1024 * 1024
export const BANNER_MIN_WIDTH = 640
export const BANNER_MIN_RATIO = 2
export const BANNER_MAX_RATIO = 4.5

const BANNER_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp'])

export function bannerFileError(file: File | null, required = true): string | null {
  if (!file) return required ? 'Upload a banner image.' : null
  if (!BANNER_TYPES.has(file.type)) return 'Use a JPG, PNG, or WebP image.'
  if (file.size > BANNER_MAX_BYTES) return 'Keep the banner under 4 MB.'
  return null
}

export function bannerAspectError(width: number, height: number): string | null {
  if (!Number.isFinite(width) || !Number.isFinite(height) || width < 1 || height < 1) {
    return 'Could not read that image.'
  }
  if (width < BANNER_MIN_WIDTH) return 'Use a banner at least 640 pixels wide.'
  const ratio = width / height
  if (ratio < BANNER_MIN_RATIO || ratio > BANNER_MAX_RATIO) {
    return 'Use a wide banner, about 3:1.'
  }
  return null
}

export function sortActiveAds<T extends { priority?: number; starts_at: string }>(rows: T[]): T[] {
  return [...rows].sort((a, b) => {
    const priority = (b.priority ?? 0) - (a.priority ?? 0)
    if (priority) return priority
    return new Date(b.starts_at).getTime() - new Date(a.starts_at).getTime()
  })
}

export function featuredAdCopy(cafeName: string, label?: string | null): { name: string; place: string } {
  const campaign = label?.trim() ?? ''
  return {
    name: cafeName,
    place: campaign && campaign !== cafeName ? campaign : '',
  }
}
