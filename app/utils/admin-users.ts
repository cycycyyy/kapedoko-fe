import type { ProfileRole } from '../types/shop'

export function roleChangeError(input: {
  actorId: string | null
  targetId: string
  nextRole: ProfileRole
  adminCount: number
  targetRole: ProfileRole
}): string | null {
  if (!input.actorId) return 'Sign in as an admin to change roles.'
  if (input.actorId === input.targetId) return 'You cannot change your own role.'
  if (input.nextRole === input.targetRole) return null
  if (input.targetRole === 'admin' && input.nextRole !== 'admin' && input.adminCount <= 1) {
    return 'Cannot demote the last admin.'
  }
  return null
}

export function suspendError(input: { actorId: string | null; targetId: string; banned: boolean }): string | null {
  if (!input.actorId) return 'Sign in as an admin to update this account.'
  if (input.actorId === input.targetId) return 'You cannot suspend your own account.'
  if (input.banned) return null
  return null
}

export function edgeFunctionErrorMessage(fnError: unknown, data: unknown): string | null {
  if (data && typeof data === 'object' && 'error' in data) {
    const message = (data as { error?: unknown }).error
    if (typeof message === 'string' && message.trim()) return message
  }
  const context = (fnError as { context?: unknown })?.context
  if (context && typeof context === 'object' && context !== null && 'error' in context) {
    const message = (context as { error?: unknown }).error
    if (typeof message === 'string' && message.trim()) return message
  }
  if (fnError instanceof Error && fnError.message && !/non-2xx/i.test(fnError.message)) {
    return fnError.message
  }
  return null
}
