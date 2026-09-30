export const ADMIN_NAV = [
  { id: 'dashboard', label: 'Dashboard', href: '/admin' },
  { id: 'cafes', label: 'Cafes', href: '/admin/cafes' },
  { id: 'requests', label: 'Requests', href: '/admin/requests' },
  { id: 'claims', label: 'Claims', href: '/admin/claims' },
  { id: 'partnerships', label: 'Partnerships', href: '/admin/partnerships' },
  { id: 'ads', label: 'Ads', href: '/admin/ads' },
  { id: 'users', label: 'Users', href: '/admin/users' },
  { id: 'moderation', label: 'Moderation', href: '/admin/moderation' },
] as const

export function adminNavIdFromPath(path: string): (typeof ADMIN_NAV)[number]['id'] {
  if (path.startsWith('/admin/cafes')) return 'cafes'
  if (path.startsWith('/admin/requests')) return 'requests'
  if (path.startsWith('/admin/claims')) return 'claims'
  if (path.startsWith('/admin/partnerships')) return 'partnerships'
  if (path.startsWith('/admin/ads')) return 'ads'
  if (path.startsWith('/admin/users')) return 'users'
  if (path.startsWith('/admin/moderation')) return 'moderation'
  return 'dashboard'
}

export function padDatePart(value: number): string {
  return String(value).padStart(2, '0')
}

export function toLocalInput(date: Date): string {
  return `${date.getFullYear()}-${padDatePart(date.getMonth() + 1)}-${padDatePart(date.getDate())}T${padDatePart(date.getHours())}:${padDatePart(date.getMinutes())}`
}

export function fromLocalInput(value: string): string {
  const date = new Date(value)
  return date.toISOString()
}

export function formatAdminDate(value: string | null | undefined): string {
  if (!value) return '—'
  const date = new Date(value)
  if (!Number.isFinite(date.getTime())) return '—'
  return new Intl.DateTimeFormat('en-PH', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(date)
}
