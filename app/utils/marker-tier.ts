import type { MarkerTier, ShopPlacementKind, ShopPlacementRow } from '../types/shop'

export const STANDARD_CUP_MIN_ZOOM = 14
export const PIN_LABEL_MAX = 16

export function isPlacementActive(
  placement: Pick<ShopPlacementRow, 'starts_at' | 'ends_at'>,
  now = new Date(),
): boolean {
  const start = new Date(placement.starts_at).getTime()
  const end = new Date(placement.ends_at).getTime()
  const at = now.getTime()
  return Number.isFinite(start) && Number.isFinite(end) && start <= at && end > at
}

export function effectiveMarkerTier(
  placements: Array<Pick<ShopPlacementRow, 'kind' | 'starts_at' | 'ends_at'>>,
  now = new Date(),
): MarkerTier {
  const active = placements.filter((placement) => isPlacementActive(placement, now))
  if (active.some((placement) => placement.kind === 'sponsored')) return 'promoted'
  if (active.some((placement) => placement.kind === 'partner')) return 'partner'
  return 'standard'
}

export function markerTierToKind(tier: MarkerTier): ShopPlacementKind | null {
  if (tier === 'promoted') return 'sponsored'
  if (tier === 'partner') return 'partner'
  return null
}

export function pinLabel(name: string, max = PIN_LABEL_MAX): string {
  const trimmed = name.replace(/\s+/g, ' ').trim()
  if (trimmed.length <= max) return trimmed
  return `${trimmed.slice(0, Math.max(1, max - 1)).trimEnd()}…`
}

export function escapeHtml(value: string): string {
  return value.replace(/[&<>"']/g, (char) => {
    if (char === '&') return '&amp;'
    if (char === '<') return '&lt;'
    if (char === '>') return '&gt;'
    if (char === '"') return '&quot;'
    return '&#39;'
  })
}

export function standardPinIsDot(zoom: number): boolean {
  return zoom < STANDARD_CUP_MIN_ZOOM
}
