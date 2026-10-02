export type AppTabId = 'home' | 'saved' | 'map' | 'profile'

export const APP_TAB_PATHS: Record<AppTabId, string> = {
  home: '/app',
  saved: '/app/favorites',
  map: '/app/map',
  profile: '/app/profile',
}

const FOREIGN_PREFIXES = ['/admin', '/login', '/register', '/privacy', '/confirm', '/forgot-password'] as const

export function normalizeAppPath(path: string): string {
  const trimmed = path.split(/[?#]/, 1)[0] ?? ''
  if (!trimmed) return '/'
  if (trimmed.length > 1 && trimmed.endsWith('/')) return trimmed.slice(0, -1)
  return trimmed
}

export function pathFromHref(value: string): string {
  const raw = value.trim()
  if (!raw) return ''
  const hashIndex = raw.indexOf('#')
  if (hashIndex >= 0) {
    const hashPath = (raw.slice(hashIndex + 1).split(/[?#]/, 1)[0] ?? '').trim()
    if (hashPath.startsWith('/')) return normalizeAppPath(hashPath)
  }
  const withoutHash = hashIndex >= 0 ? raw.slice(0, hashIndex) : raw
  try {
    if (/^[a-z][a-z0-9+.-]*:/i.test(withoutHash)) {
      return normalizeAppPath(new URL(withoutHash).pathname)
    }
  } catch {
    /* fall through to path parsing */
  }
  return normalizeAppPath(withoutHash.replace(/^https?:\/\/[^/]+/i, ''))
}

export function isSameAppPath(currentPath: string, targetPath: string): boolean {
  return normalizeAppPath(currentPath) === normalizeAppPath(targetPath)
}

/** Prefer the browser path when Ionic and Vue Router disagree. */
export function resolveAppPath(routePath: string, locationPath?: string | null): string {
  const fromRoute = normalizeAppPath(routePath)
  const fromLocation = locationPath ? pathFromHref(locationPath) : ''
  if (fromLocation && fromLocation !== '/' && fromLocation !== fromRoute) return fromLocation
  return fromLocation && fromLocation !== '/' ? fromLocation : fromRoute
}

export function isAppTabRoute(path: string): boolean {
  const current = normalizeAppPath(path)
  return current === APP_TAB_PATHS.home
    || current === APP_TAB_PATHS.saved
    || current === APP_TAB_PATHS.map
    || current === APP_TAB_PATHS.profile
}

export function isForeignSurface(path: string): boolean {
  const current = pathFromHref(path)
  return FOREIGN_PREFIXES.some((prefix) => current === prefix || current.startsWith(`${prefix}/`))
}

export function shouldShowAppTabs(...values: Array<string | null | undefined>): boolean {
  const paths = values
    .map((value) => (value ? pathFromHref(value) : ''))
    .filter((path) => path && path !== '/')
  if (paths.some(isForeignSurface)) return false
  const routePath = paths[0]
  return Boolean(routePath && isAppTabRoute(routePath))
}

export function isVisibleIonPageClass(className: string): boolean {
  const classes = new Set(className.split(/\s+/).filter(Boolean))
  return !classes.has('ion-page-hidden') && !classes.has('ion-page-invisible')
}

export function activeAppTab(path: string): AppTabId {
  const current = normalizeAppPath(path)
  if (current === APP_TAB_PATHS.map || current.startsWith(`${APP_TAB_PATHS.map}/`)) return 'map'
  if (current === APP_TAB_PATHS.saved || current.startsWith(`${APP_TAB_PATHS.saved}/`)) return 'saved'
  if (current === APP_TAB_PATHS.profile || current.startsWith(`${APP_TAB_PATHS.profile}/`)) return 'profile'
  return 'home'
}
