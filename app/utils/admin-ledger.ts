export const ADMIN_LEDGER_PAGE_SIZE = 10

export type LedgerPageToken = number | 'gap'

export function ledgerPageCount(total: number, pageSize = ADMIN_LEDGER_PAGE_SIZE): number {
  if (total <= 0) return 1
  const size = Math.max(1, pageSize)
  return Math.ceil(total / size)
}

export function ledgerPageRange(total: number, page: number, pageSize = ADMIN_LEDGER_PAGE_SIZE) {
  const pageCount = ledgerPageCount(total, pageSize)
  const current = Math.min(Math.max(1, Math.trunc(page) || 1), pageCount)
  if (total <= 0) return { start: 0, end: 0, page: 1, pageCount: 1 }
  const size = Math.max(1, pageSize)
  const start = (current - 1) * size + 1
  return { start, end: Math.min(total, current * size), page: current, pageCount }
}

export function ledgerPageSlice<T>(items: readonly T[], page: number, pageSize = ADMIN_LEDGER_PAGE_SIZE): T[] {
  const { start, end } = ledgerPageRange(items.length, page, pageSize)
  if (end === 0) return []
  return items.slice(start - 1, end)
}

export function ledgerPageTokens(page: number, pageCount: number): LedgerPageToken[] {
  const count = Math.max(1, Math.trunc(pageCount) || 1)
  const current = Math.min(Math.max(1, Math.trunc(page) || 1), count)
  if (count <= 7) return Array.from({ length: count }, (_, index) => index + 1)

  const tokens: LedgerPageToken[] = [1]
  const start = Math.max(2, current - 1)
  const end = Math.min(count - 1, current + 1)
  if (start > 2) tokens.push('gap')
  for (let number = start; number <= end; number += 1) tokens.push(number)
  if (end < count - 1) tokens.push('gap')
  tokens.push(count)
  return tokens
}
