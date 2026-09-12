import type { Cafe } from '../types/cafe'
import type { GeoBounds } from './geography'
import type {
  MarkerTier,
  ShopBusynessNowRow,
  ShopMarkerTierRow,
  ShopReviewPublicRow,
  ShopReviewRow,
  ShopReviewStatsRow,
  ShopRow,
} from '../types/shop'
import { mapPublicReview, matchaInsightFromStats, plugInsightFromStats, statsFromPublicReviews, wifiInsightFromStats } from './cafe-review'
import { mapShopToCafe, withCafeBusyness, withCafeReviews } from './shop-mapper'

export const APPROVED_SHOP_COLUMNS =
  'id,name,description,address,latitude,longitude,categories,hours,cover_photo_url,logo_object_key,contact_number,status,submitted_by,reviewed_by,reviewed_at,rejection_reason,created_at,updated_at'

const SHOP_ID_RE =
  /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i

export function isShopId(value: string): boolean {
  const trimmed = value.trim()
  return trimmed.length === 36 && SHOP_ID_RE.test(trimmed)
}

export function shopIdFromRoute(path: string, param?: unknown): string {
  const fromParam = typeof param === 'string'
    ? param
    : Array.isArray(param)
      ? String(param[0] || '')
      : ''
  if (isShopId(fromParam)) return fromParam.trim()
  const match = `${fromParam} ${path}`.match(SHOP_ID_RE)
  return match?.[0] ?? ''
}

function firstRow<T>(data: T | T[] | null | undefined): T | null {
  if (Array.isArray(data)) return data[0] ?? null
  return data ?? null
}

function sanitizeSearch(query: string): string {
  return query.replace(/[%_,()]/g, ' ').replace(/\s+/g, ' ').trim()
}

export async function fetchApprovedCafes(
  supabase: { from: (relation: string) => any },
  publicBase: string,
  options: {
    bounds?: GeoBounds
    query?: string
    limit?: number
  } = {},
): Promise<Cafe[]> {
  let request = supabase
    .from('shops')
    .select(APPROVED_SHOP_COLUMNS)
    .eq('status', 'approved')

  if (options.bounds) {
    request = request
      .gte('latitude', options.bounds.south)
      .lte('latitude', options.bounds.north)
      .gte('longitude', options.bounds.west)
      .lte('longitude', options.bounds.east)
  }

  const term = options.query ? sanitizeSearch(options.query) : ''
  if (term) {
    request = request.or(`name.ilike.%${term}%,address.ilike.%${term}%`)
  }

  request = request.order('name')
  if (options.limit) request = request.limit(options.limit)

  const { data: shops, error } = await request
  if (error) throw error

  const approved = ((shops ?? []) as ShopRow[]).filter((shop) => shop.status === 'approved')
  if (!approved.length) return []

  const ids = approved.map((shop) => shop.id)
  const [{ data: stats }, { data: tiers }] = await Promise.all([
    supabase.from('shop_review_stats').select('*').in('shop_id', ids),
    supabase.from('shop_marker_tiers').select('shop_id, marker_tier').in('shop_id', ids),
  ])

  const statsById = new Map(
    ((stats ?? []) as ShopReviewStatsRow[]).map((row) => [row.shop_id, row]),
  )
  const tierById = new Map(
    ((tiers ?? []) as ShopMarkerTierRow[]).map((row) => [row.shop_id, row.marker_tier as MarkerTier]),
  )

  return approved.map((shop) =>
    mapShopToCafe(shop, statsById.get(shop.id), publicBase, tierById.get(shop.id) ?? 'standard'),
  )
}

export async function fetchApprovedCafeById(
  supabase: { from: (relation: string) => any },
  publicBase: string,
  shopId: string,
): Promise<Cafe | null> {
  if (!isShopId(shopId)) return null

  const { data: shop, error } = await supabase
    .from('shops')
    .select(APPROVED_SHOP_COLUMNS)
    .eq('id', shopId)
    .eq('status', 'approved')
    .maybeSingle()

  if (error) throw error
  if (!shop) return null

  let stats: ShopReviewStatsRow | null = null
  let markerTier: MarkerTier = 'standard'
  try {
    const [statsResult, tiersResult] = await Promise.all([
      supabase.from('shop_review_stats').select('*').eq('shop_id', shopId).limit(1),
      supabase.from('shop_marker_tiers').select('shop_id, marker_tier').eq('shop_id', shopId).limit(1),
    ])
    stats = statsResult.error ? null : firstRow(statsResult.data as ShopReviewStatsRow[] | ShopReviewStatsRow | null)
    const tierRow = tiersResult.error ? null : firstRow(tiersResult.data as ShopMarkerTierRow[] | ShopMarkerTierRow | null)
    markerTier = (tierRow?.marker_tier as MarkerTier | undefined) ?? 'standard'
  } catch {
    stats = null
  }

  return mapShopToCafe(shop as ShopRow, stats, publicBase, markerTier)
}

export async function fetchPublicCafeReviews(
  supabase: { from: (relation: string) => any },
  shopId: string,
  limit = 20,
): Promise<Cafe['reviews']> {
  const rows = await fetchPublicCafeReviewRows(supabase, shopId, limit)
  return rows.map(mapPublicReview)
}

export async function fetchPublicCafeReviewRows(
  supabase: { from: (relation: string) => any },
  shopId: string,
  limit = 20,
): Promise<ShopReviewPublicRow[]> {
  if (!isShopId(shopId)) return []

  const fromView = await supabase
    .from('shop_reviews_public')
    .select('*')
    .eq('shop_id', shopId)
    .order('created_at', { ascending: false })
    .limit(limit)

  if (!fromView.error) {
    const viewRows = (fromView.data ?? []) as ShopReviewPublicRow[]
    if (viewRows.length) return viewRows
  }

  const fromTable = await supabase
    .from('reviews')
    .select('id, shop_id, created_at, updated_at, wifi_available, wifi_speed, wifi_time_limit, power_available, power_access, serves_matcha, noise, stay_fit, recommend, visit_again, comment')
    .eq('shop_id', shopId)
    .is('flagged_at', null)
    .order('created_at', { ascending: false })
    .limit(limit)

  if (fromTable.error) return []
  return ((fromTable.data ?? []) as ShopReviewRow[]).map((row) => ({
    id: row.id,
    shop_id: row.shop_id,
    created_at: row.created_at,
    updated_at: row.updated_at,
    author_name: 'KapéBean',
    wifi_available: row.wifi_available,
    wifi_speed: row.wifi_speed,
    wifi_time_limit: row.wifi_time_limit,
    power_available: row.power_available,
    power_access: row.power_access,
    serves_matcha: row.serves_matcha,
    noise: row.noise,
    stay_fit: row.stay_fit,
    recommend: row.recommend,
    visit_again: row.visit_again,
    comment: row.comment,
  }))
}

export async function fetchShopBusynessNow(
  supabase: { from: (relation: string) => any },
  shopId: string,
): Promise<ShopBusynessNowRow | null> {
  if (!isShopId(shopId)) return null

  const { data, error } = await supabase
    .from('shop_busyness_now')
    .select('*')
    .eq('shop_id', shopId)
    .limit(1)

  if (error) return null
  return firstRow(data as ShopBusynessNowRow[] | ShopBusynessNowRow | null)
}

export async function hydrateCafeDetail(
  supabase: { from: (relation: string) => any },
  cafe: Cafe,
): Promise<Cafe> {
  const [rowsResult, busynessResult] = await Promise.allSettled([
    fetchPublicCafeReviewRows(supabase, cafe.id),
    fetchShopBusynessNow(supabase, cafe.id),
  ])
  const rows = rowsResult.status === 'fulfilled' ? rowsResult.value : []
  const derived = statsFromPublicReviews(rows)
  const reviewed: Cafe = {
    ...withCafeReviews(cafe, rows.map(mapPublicReview)),
    wifiInsight: cafe.wifiInsight ?? wifiInsightFromStats(derived),
    plugInsight: cafe.plugInsight ?? plugInsightFromStats(derived),
    matchaInsight: cafe.matchaInsight ?? matchaInsightFromStats(derived),
  }
  const busyness = busynessResult.status === 'fulfilled' ? busynessResult.value : null
  return withCafeBusyness(reviewed, busyness)
}

export async function fetchOwnShopReview(
  supabase: { from: (relation: string) => any },
  shopId: string,
  userId: string,
): Promise<ShopReviewRow | null> {
  if (!isShopId(shopId) || !isShopId(userId)) return null

  const { data, error } = await supabase
    .from('reviews')
    .select('*')
    .eq('shop_id', shopId)
    .eq('user_id', userId)
    .maybeSingle()

  if (error) throw error
  return (data ?? null) as ShopReviewRow | null
}
