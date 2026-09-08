import type { Cafe } from '../types/cafe'
import type { GeoBounds } from './geography'
import type { MarkerTier, ShopMarkerTierRow, ShopReviewStatsRow, ShopRow } from '../types/shop'
import { mapShopToCafe } from './shop-mapper'

export const APPROVED_SHOP_COLUMNS =
  'id,name,description,address,latitude,longitude,categories,hours,cover_photo_url,logo_object_key,contact_number,status,submitted_by,reviewed_by,reviewed_at,rejection_reason,created_at,updated_at'

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
