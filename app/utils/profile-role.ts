import type { ProfileRole } from '../types/shop'

export const PROFILE_ROLES: ProfileRole[] = ['user', 'cafe-owner', 'admin', 'auditor']

export const PROFILE_ROLE_LABELS: Record<ProfileRole, string> = {
  user: 'User',
  'cafe-owner': 'Cafe owner',
  admin: 'Admin',
  auditor: 'Auditor',
}

export function parseProfileRole(value: unknown): ProfileRole {
  if (value === 'admin' || value === 'cafe-owner' || value === 'user' || value === 'auditor') return value
  return 'user'
}

export function isProfileRole(value: unknown): value is ProfileRole {
  return value === 'admin' || value === 'cafe-owner' || value === 'user' || value === 'auditor'
}

export function isStaffRole(value: unknown): boolean {
  return value === 'admin' || value === 'auditor'
}
