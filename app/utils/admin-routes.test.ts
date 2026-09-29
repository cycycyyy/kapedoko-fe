import { describe, expect, test } from 'bun:test'
import { ADMIN_NAV, adminNavIdFromPath } from './admin-nav'

describe('admin routes', () => {
  test('covers every portal section under /admin', () => {
    const hrefs = ADMIN_NAV.map((item) => item.href)
    expect(hrefs).toEqual([
      '/admin',
      '/admin/cafes',
      '/admin/requests',
      '/admin/partnerships',
      '/admin/ads',
      '/admin/users',
      '/admin/moderation',
    ])
    expect(ADMIN_NAV.every((item) => item.href === '/admin' || item.href.startsWith('/admin/'))).toBe(true)
  })

  test('keeps nested cafe routes on the cafes section', () => {
    expect(adminNavIdFromPath('/admin/cafes/abc-123')).toBe('cafes')
    expect(adminNavIdFromPath('/admin/requests?id=1')).toBe('requests')
  })
})
