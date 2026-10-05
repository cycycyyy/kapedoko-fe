import { describe, expect, test } from 'bun:test'
import { ADMIN_NAV, adminNavIdFromPath, staffNav } from './admin-nav'

describe('admin routes', () => {
  test('covers every portal section under /admin', () => {
    const hrefs = ADMIN_NAV.map((item) => item.href)
    expect(hrefs).toEqual([
      '/admin',
      '/admin/cafes',
      '/admin/audits',
      '/admin/requests',
      '/admin/claims',
      '/admin/partnerships',
      '/admin/ads',
      '/admin/users',
      '/admin/moderation',
    ])
    expect(ADMIN_NAV.every((item) => item.href === '/admin' || item.href.startsWith('/admin/'))).toBe(true)
  })

  test('keeps nested cafe routes on the cafes section', () => {
    expect(adminNavIdFromPath('/admin/cafes/abc-123')).toBe('cafes')
    expect(adminNavIdFromPath('/admin/audits/new')).toBe('audits')
    expect(adminNavIdFromPath('/admin/cafes/abc-123/audits')).toBe('audits')
    expect(adminNavIdFromPath('/admin/requests?id=1')).toBe('requests')
    expect(adminNavIdFromPath('/admin/claims')).toBe('claims')
    expect(adminNavIdFromPath('/admin/moderation')).toBe('moderation')
    expect(adminNavIdFromPath('/admin/users')).toBe('users')
    expect(adminNavIdFromPath('/admin')).toBe('dashboard')
  })

  test('auditors only see the audits section', () => {
    expect(staffNav('auditor').map((item) => item.id)).toEqual(['audits'])
    expect(staffNav('admin').map((item) => item.id)).toContain('cafes')
  })
})
