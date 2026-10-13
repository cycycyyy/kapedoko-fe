import type { ShopRow } from '../types/shop'
import { cafeDisplayLogo, KAPEDOKO_APP_LOGO_SRC } from './logo'
import { publicObjectUrl } from './shop-mapper'

export interface CafeLogoSource {
  shopId: string
  name: string
  address: string
  logoObjectKey: string
  logoUrl: string | null
}

export interface UniqueCafeLogoSource extends CafeLogoSource {
  cafeCount: number
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

export function searchCafeLogoSources<T extends CafeLogoSource>(sources: T[], query: string): T[] {
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

export function uniqueCafeLogoSources(sources: CafeLogoSource[]): UniqueCafeLogoSource[] {
  const byKey = new Map<string, UniqueCafeLogoSource>()
  for (const source of sources) {
    const existing = byKey.get(source.logoObjectKey)
    if (existing) {
      existing.cafeCount += 1
      continue
    }
    byKey.set(source.logoObjectKey, { ...source, cafeCount: 1 })
  }
  return [...byKey.values()]
}

export function logoTickState(ids: readonly string[], selected: ReadonlySet<string>): 'none' | 'some' | 'all' {
  if (ids.length === 0) return 'none'
  let hit = 0
  for (const id of ids) {
    if (selected.has(id)) hit += 1
  }
  if (hit === 0) return 'none'
  if (hit === ids.length) return 'all'
  return 'some'
}

export function logoOverwriteCount(
  shops: Pick<ShopRow, 'id' | 'logo_object_key'>[],
  selected: ReadonlySet<string>,
  nextKey: string | null,
  uploadingFile = false,
): number {
  const key = normalizeLogoObjectKey(nextKey)
  return shops.filter((shop) => {
    if (!selected.has(shop.id)) return false
    const current = normalizeLogoObjectKey(shop.logo_object_key)
    if (!current) return false
    if (uploadingFile) return true
    return current !== key
  }).length
}

export function stampLogoCopy(count: number): string {
  return count === 1 ? 'Stamp onto 1 cafe' : `Stamp onto ${count} cafes`
}

export function stampLogoConfirmCopy(count: number, overwriteCount: number): string {
  const base = count === 1
    ? 'Stamp this mark onto 1 cafe?'
    : `Stamp this mark onto ${count} cafes?`
  if (overwriteCount < 1) return base
  const extra = overwriteCount === 1
    ? '1 already has a different logo.'
    : `${overwriteCount} already have a different logo.`
  return `${base} ${extra}`
}

export function stampLogoProgressCopy(done: number, total: number): string {
  return `Stamping ${done} of ${total}…`
}

export function stampLogoDoneCopy(count: number): string {
  return count === 1
    ? '1 cafe now wears this mark.'
    : `${count} cafes now wear this mark.`
}

export function uniqueLogoSourceLabel(source: CafeLogoSource & { cafeCount?: number }): string {
  if ((source.cafeCount ?? 1) <= 1) return source.address
  return `${source.address} · ${source.cafeCount} cafes`
}

export function shopCafeLogoSrc(
  logoObjectKey: string | null | undefined,
  publicBase = '',
  broken = false,
): string {
  if (broken) return KAPEDOKO_APP_LOGO_SRC
  return cafeDisplayLogo(publicObjectUrl(normalizeLogoObjectKey(logoObjectKey), publicBase))
}

export function adminLogoPayload(input: {
  logoFile: File | null
  logoObjectKey: string | null
}): { shouldUpload: boolean; logoObjectKey: string | null } {
  const logoObjectKey = normalizeLogoObjectKey(input.logoObjectKey)
  if (input.logoFile) return { shouldUpload: true, logoObjectKey }
  return { shouldUpload: false, logoObjectKey }
}
