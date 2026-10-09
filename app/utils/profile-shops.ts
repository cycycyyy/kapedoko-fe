import type { ShopSource } from '../types/shop'

export type ProfileShopOrigin = {
  source?: ShopSource | null
  imported_at?: string | null
}

/**
 * System/catalog shops vs in-app user submissions.
 *
 * `shops.source` is the provenance column (`user` | `admin` | `openstreetmap`).
 * Admin portal creates, CSV crate imports, and OSM/Places imports set `admin`
 * or `openstreetmap` and still stamp `submitted_by` as the staff account — so
 * Profile must not treat those as “Cafes you submitted”.
 *
 * Heuristic for legacy rows (`source` null, per shops.source comment):
 * `imported_at` marks a catalog import; otherwise treat as a personal submission.
 */
export function isSystemAddedShop(shop: ProfileShopOrigin): boolean {
  if (shop.source === 'user') return false
  if (shop.source === 'admin' || shop.source === 'openstreetmap') return true
  return Boolean(shop.imported_at)
}

export function splitProfileShops<T extends ProfileShopOrigin>(shops: T[]): {
  submitted: T[]
  systemAdded: T[]
} {
  const submitted: T[] = []
  const systemAdded: T[] = []
  for (const shop of shops) {
    if (isSystemAddedShop(shop)) systemAdded.push(shop)
    else submitted.push(shop)
  }
  return { submitted, systemAdded }
}

export function profileSubmittedEmptyCopy(): string {
  return 'You have not submitted a cafe yet.'
}
