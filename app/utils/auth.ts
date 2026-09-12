export function authUserId(user: unknown): string | null {
  if (!user || typeof user !== 'object') return null
  const record = user as { id?: unknown; sub?: unknown }
  if (typeof record.id === 'string' && record.id) return record.id
  if (typeof record.sub === 'string' && record.sub) return record.sub
  return null
}
