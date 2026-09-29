export const CAFE_PAGE_SIZE = 12

export function advanceWindow(shown: number, total: number, pageSize = CAFE_PAGE_SIZE): number {
  if (shown >= total) return shown
  const size = Math.max(1, pageSize)
  return Math.min(total, shown + size)
}

export function windowItems<T>(items: readonly T[], shown: number): T[] {
  return items.slice(0, Math.max(0, shown))
}
