import type { ShopRow } from '../types/shop'
import { publicObjectUrl } from './shop-mapper'

export interface CafeLogoSource {
  shopId: string
  name: string
  address: string
  logoObjectKey: string
  logoUrl: string | null
}

export function normalizeLogoObjectKey(value: string | null | undefined): string | null {
  const key = value?.trim().replace(/^\/+/, '') ?? ''
  return key || null
}

export function cafeLogoSources(
  shops: Pick<ShopRow, 'id' | 'name' | 'address' | 'logo_object_key'>[],
  publicBase = '',
  options: { excludeShopId?: string | null } = {},
): CafeLogoSource[] {
  const exclude = options.excludeShopId ?? ''
  return shops.flatMap((shop) => {
    const logoObjectKey = normalizeLogoObjectKey(shop.logo_object_key)
    if (!logoObjectKey || shop.id === exclude) return []
    return [{
      shopId: shop.id,
      name: shop.name,
      address: shop.address,
      logoObjectKey,
      logoUrl: publicObjectUrl(logoObjectKey, publicBase),
    }]
  }).sort((a, b) => a.name.localeCompare(b.name))
}

export function searchCafeLogoSources(sources: CafeLogoSource[], query: string): CafeLogoSource[] {
  const term = query.trim().toLowerCase()
  if (!term) return sources
  return sources.filter((source) => (
    source.name.toLowerCase().includes(term)
    || source.address.toLowerCase().includes(term)
  ))
}

export function findCafeLogoSource(
  sources: CafeLogoSource[],
  logoObjectKey: string | null | undefined,
): CafeLogoSource | null {
  const key = normalizeLogoObjectKey(logoObjectKey)
  if (!key) return null
  return sources.find((source) => source.logoObjectKey === key) ?? null
}

export function adminLogoPayload(input: {
  logoFile: File | null
  logoObjectKey: string | null
}): { shouldUpload: boolean; logoObjectKey: string | null } {
  const logoObjectKey = normalizeLogoObjectKey(input.logoObjectKey)
  if (input.logoFile) return { shouldUpload: true, logoObjectKey }
  return { shouldUpload: false, logoObjectKey }
}
