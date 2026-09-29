import type { MarkerTier, ShopPlacementKind, ShopPlacementRow } from '../types/shop'
import type { PlacementLifecycle } from '../types/admin'
import { isPlacementActive, markerTierToKind } from './marker-tier'

export function placementWindowError(startsAt: string, endsAt: string): string | null {
  const start = new Date(startsAt)
  const end = new Date(endsAt)
  if (!Number.isFinite(start.getTime()) || !Number.isFinite(end.getTime())) {
    return 'Choose a start and end time.'
  }
  if (end <= start) return 'Choose an end date after the start date.'
  return null
}

export function placementLifecycle(
  placement: Pick<ShopPlacementRow, 'starts_at' | 'ends_at'>,
  now = new Date(),
): PlacementLifecycle {
  const start = new Date(placement.starts_at).getTime()
  const end = new Date(placement.ends_at).getTime()
  const at = now.getTime()
  if (!Number.isFinite(start) || !Number.isFinite(end)) return 'ended'
  if (start > at) return 'scheduled'
  if (isPlacementActive(placement, now)) return 'current'
  return 'ended'
}

export function placementKindFromTier(tier: MarkerTier): ShopPlacementKind | 'standard' {
  return markerTierToKind(tier) ?? 'standard'
}
