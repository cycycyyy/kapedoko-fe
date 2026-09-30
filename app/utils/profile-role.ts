import type { ProfileRole } from '../types/shop'

export const PROFILE_ROLES: ProfileRole[] = ['user', 'cafe-owner', 'admin']

export const PROFILE_ROLE_LABELS: Record<ProfileRole, string> = {
  user: 'User',
  'cafe-owner': 'Cafe owner',
  admin: 'Admin',
}

export function parseProfileRole(value: unknown): ProfileRole {
  if (value === 'admin' || value === 'cafe-owner' || value === 'user') return value
  return 'user'
}

export function isProfileRole(value: unknown): value is ProfileRole {
  return value === 'admin' || value === 'cafe-owner' || value === 'user'
}
