export type AppTabId = 'home' | 'saved' | 'map' | 'profile'

export const APP_TAB_PATHS: Record<AppTabId, string> = {
  home: '/app',
  saved: '/app/favorites',
  map: '/app/map',
  profile: '/app/profile',
}

export function normalizeAppPath(path: string): string {
  const trimmed = path.split(/[?#]/, 1)[0] ?? ''
  if (!trimmed) return '/'
  if (trimmed.length > 1 && trimmed.endsWith('/')) return trimmed.slice(0, -1)
  return trimmed
}

export function isSameAppPath(currentPath: string, targetPath: string): boolean {
  return normalizeAppPath(currentPath) === normalizeAppPath(targetPath)
}

export function activeAppTab(path: string): AppTabId {
  const current = normalizeAppPath(path)
  if (current === APP_TAB_PATHS.map || current.startsWith(`${APP_TAB_PATHS.map}/`)) return 'map'
  if (current === APP_TAB_PATHS.saved || current.startsWith(`${APP_TAB_PATHS.saved}/`)) return 'saved'
  if (current === APP_TAB_PATHS.profile || current.startsWith(`${APP_TAB_PATHS.profile}/`)) return 'profile'
  return 'home'
}
