import type { Cafe, LatLng } from '../types/cafe'
import { distanceMeters } from './geo'

const MAX_SUGGESTIONS = 8

export function cafeMatchesQuery(
  cafe: Pick<Cafe, 'name' | 'address'>,
  query: string,
): boolean {
  const term = query.trim().toLowerCase()
  if (!term) return false
  return cafe.name.toLowerCase().includes(term) || cafe.address.toLowerCase().includes(term)
}

export function suggestCafes(
  cafes: Cafe[],
  query: string,
  origin?: LatLng | null,
): Cafe[] {
  const term = query.trim().toLowerCase()
  if (!term) return []

  return cafes
    .map((cafe) => {
      const name = cafe.name.toLowerCase()
      const address = cafe.address.toLowerCase()
      let rank = -1
      if (name === term) rank = 0
      else if (name.startsWith(term)) rank = 1
      else if (name.includes(term)) rank = 2
      else if (address.includes(term)) rank = 3
      const distance = origin ? distanceMeters(origin, cafe) : Number.POSITIVE_INFINITY
      return { cafe, rank, distance }
    })
    .filter((row) => row.rank >= 0)
    .sort(
      (a, b) =>
        a.rank - b.rank
        || a.distance - b.distance
        || a.cafe.name.localeCompare(b.cafe.name),
    )
    .slice(0, MAX_SUGGESTIONS)
    .map((row) => row.cafe)
}
