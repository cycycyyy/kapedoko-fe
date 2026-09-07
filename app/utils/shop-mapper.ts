import type { Amenity, Cafe } from '../types/cafe'
import type { ShopReviewStatsRow, ShopRow } from '../types/shop'
import { formatHoursHint, isOpenNow } from './hours'
import { KAPEDOKO_MARK_SRC } from './logo'

const REVIEW_THRESHOLD = 3
const AMENITY_YES_PCT = 50

export function shopImageUrl(shop: Pick<ShopRow, 'logo_object_key' | 'cover_photo_url'>, publicBase?: string): string {
  if (shop.logo_object_key && publicBase) {
    return `${publicBase.replace(/\/$/, '')}/${shop.logo_object_key}`
  }
  if (shop.cover_photo_url) return shop.cover_photo_url
  return KAPEDOKO_MARK_SRC
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

export function mapShopToCafe(
  shop: ShopRow,
  stats?: ShopReviewStatsRow | null,
  publicBase?: string,
): Cafe {
  const image = shopImageUrl(shop, publicBase)
  const open = isOpenNow(shop.hours)
  const hoursHint = formatHoursHint(shop.hours)
  const { rating, label } = ratingFromStats(stats)
  const amenities = amenitiesFromStats(stats)

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
    popular: (stats?.total_reviews ?? 0) >= REVIEW_THRESHOLD && (stats?.recommend_pct ?? 0) >= 70,
    rating,
    ratingLabel: label,
    reviews: [],
    lat: shop.latitude,
    lng: shop.longitude,
  }
}
