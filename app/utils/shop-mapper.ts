import type { Amenity, Cafe, CafeReview } from '../types/cafe'
import type {
  CafeWorkFacts,
  MarkerTier,
  PowerAccess,
  ShopBusynessNowRow,
  ShopReviewStatsRow,
  ShopRow,
  WifiSpeed,
  WifiTimeLimit,
} from '../types/shop'
import {
  busynessLabel,
  isValidBusynessLevel,
  matchaInsightFromStats,
  plugInsightFromStats,
  wifiInsightFromStats,
} from './cafe-review'
import { formatHoursHint, isOpenNow } from './hours'
import { isKapedokoMark, KAPEDOKO_MARK_SRC } from './logo'

const REVIEW_THRESHOLD = 3
const AMENITY_YES_PCT = 50

export const UNKNOWN_WORK: CafeWorkFacts = {
  known: false,
  wifi: null,
  longStay: null,
  wifiSpeed: null,
  wifiTimeLimit: null,
  plug: null,
  outletReliability: null,
}

function asWifiSpeed(value: string | null | undefined): WifiSpeed | null {
  if (value === 'slow' || value === 'okay' || value === 'fast') return value
  return null
}

function asWifiCap(value: string | null | undefined): WifiTimeLimit | null {
  if (value === 'unlimited' || value === 'voucher' || value === 'purchase' || value === 'unsure') return value
  return null
}

function asPowerAccess(value: string | null | undefined): PowerAccess | null {
  if (value === 'easy' || value === 'limited' || value === 'scarce') return value
  return null
}

export function workFactsFromStats(stats?: ShopReviewStatsRow | null): CafeWorkFacts {
  if (!stats || stats.total_reviews < REVIEW_THRESHOLD) return { ...UNKNOWN_WORK }

  const wifi = (stats.wifi_available_pct ?? 0) >= AMENITY_YES_PCT
  const plug = (stats.power_available_pct ?? 0) >= AMENITY_YES_PCT
  const wifiSpeed = wifi ? asWifiSpeed(stats.wifi_speed_mode) : null
  const wifiTimeLimit = wifi ? asWifiCap(stats.wifi_time_limit_mode) : null

  return {
    known: true,
    wifi,
    longStay: wifi && wifiTimeLimit === 'unlimited',
    wifiSpeed,
    wifiTimeLimit,
    plug,
    outletReliability: plug ? asPowerAccess(stats.power_access_mode) : null,
  }
}

export function amenityGapCopy(work: CafeWorkFacts, amenities: Amenity[] | 'none'): string | null {
  if (!work.known) return 'WiFi and outlets not confirmed yet'
  if (amenities === 'none') return 'No WiFi or power outlets'
  return null
}

export function shopImageUrl(shop: Pick<ShopRow, 'logo_object_key' | 'cover_photo_url'>, publicBase?: string): string {
  const key = shop.logo_object_key?.replace(/^\/+/, '')
  const base = usablePublicBase(publicBase)
  if (key && base) {
    const path = key.split('/').filter(Boolean).map(encodeURIComponent).join('/')
    return `${base}/${path}`
  }
  if (shop.cover_photo_url) return shop.cover_photo_url
  return KAPEDOKO_MARK_SRC
}

function usablePublicBase(publicBase?: string): string | null {
  const base = publicBase?.trim().replace(/\/$/, '')
  if (!base) return null
  try {
    const host = new URL(base).hostname
    // Signed S3 API host — browsers cannot GET objects from it without a signature.
    if (host.endsWith('.r2.cloudflarestorage.com')) return null
  } catch {
    return null
  }
  return base
}

export function amenitiesFromStats(stats?: ShopReviewStatsRow | null): Amenity[] | 'none' {
  if (!stats || stats.total_reviews < REVIEW_THRESHOLD) return []

  const wifi = (stats.wifi_available_pct ?? 0) >= AMENITY_YES_PCT
  const plug = (stats.power_available_pct ?? 0) >= AMENITY_YES_PCT

  if (!wifi && !plug) return 'none'

  const amenities: Amenity[] = []
  if (wifi) amenities.push('wifi')
  if (plug) amenities.push('plug')
  return amenities
}

export function ratingFromStats(stats?: ShopReviewStatsRow | null): { rating: number; label: string } {
  if (!stats || stats.total_reviews === 0 || stats.recommend_pct == null) {
    return { rating: 0, label: 'New' }
  }

  const score = Math.max(1, Math.min(5, Math.round((stats.recommend_pct / 100) * 5)))
  return {
    rating: score,
    label: (stats.recommend_pct / 20).toFixed(1),
  }
}

export function shopLogoUrl(
  shop: Pick<ShopRow, 'logo_object_key' | 'cover_photo_url'>,
  publicBase?: string,
): string | null {
  const url = shopImageUrl(shop, publicBase)
  return isKapedokoMark(url) ? null : url
}

export function mapShopToCafe(
  shop: ShopRow,
  stats?: ShopReviewStatsRow | null,
  publicBase?: string,
  markerTier: MarkerTier = 'standard',
): Cafe {
  const image = shopImageUrl(shop, publicBase)
  const open = isOpenNow(shop.hours)
  const hoursHint = formatHoursHint(shop.hours)
  const { rating, label } = ratingFromStats(stats)
  const amenities = amenitiesFromStats(stats)
  const work = workFactsFromStats(stats)

  return {
    id: shop.id,
    name: shop.name,
    address: shop.address,
    image,
    photos: [image],
    open,
    status: open ? 'Open' : shop.hours ? 'Closed' : 'Hours to confirm',
    hoursHint,
    phone: shop.contact_number ?? undefined,
    amenities,
    work,
    popular: (stats?.total_reviews ?? 0) >= REVIEW_THRESHOLD && (stats?.recommend_pct ?? 0) >= 70,
    rating,
    ratingLabel: label,
    wifiInsight: wifiInsightFromStats(stats),
    plugInsight: plugInsightFromStats(stats),
    matchaInsight: matchaInsightFromStats(stats),
    busyness: null,
    reviews: [],
    lat: Number(shop.latitude),
    lng: Number(shop.longitude),
    markerTier,
  }
}

export function withCafeReviews(cafe: Cafe, reviews: CafeReview[]): Cafe {
  return { ...cafe, reviews }
}

export function withCafeBusyness(cafe: Cafe, row?: ShopBusynessNowRow | null): Cafe {
  if (!row || !isValidBusynessLevel(row.level)) return { ...cafe, busyness: null }
  return {
    ...cafe,
    busyness: {
      level: row.level,
      label: busynessLabel(row.level),
      count: row.report_count,
    },
  }
}
