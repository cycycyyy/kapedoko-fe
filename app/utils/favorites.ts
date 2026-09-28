import { isShopId } from './approved-shops'

export function normalizeFavoriteIds(ids: unknown): string[] {
  if (!Array.isArray(ids)) return []
  const seen = new Set<string>()
  const next: string[] = []
  for (const id of ids) {
    if (typeof id !== 'string') continue
    const trimmed = id.trim()
    if (!isShopId(trimmed) || seen.has(trimmed)) continue
    seen.add(trimmed)
    next.push(trimmed)
  }
  return next
}

export function mergeFavoriteIds(localIds: unknown, remoteIds: unknown): string[] {
  const remote = normalizeFavoriteIds(remoteIds)
  const local = normalizeFavoriteIds(localIds)
  return normalizeFavoriteIds([...remote, ...local])
}

export function favoriteIdsToInsert(userId: string, remoteIds: unknown, mergedIds: unknown): { user_id: string; shop_id: string }[] {
  const remote = new Set(normalizeFavoriteIds(remoteIds))
  return normalizeFavoriteIds(mergedIds)
    .filter((shopId) => !remote.has(shopId))
    .map((shopId) => ({ user_id: userId, shop_id: shopId }))
}
