export const ONBOARDING_KEY = 'kapedoko-onboarding-done'

export function hasFinishedOnboarding(): boolean {
  if (!import.meta.client) return true
  try {
    return window.localStorage.getItem(ONBOARDING_KEY) === '1'
  } catch {
    return true
  }
}

export function markOnboardingDone(): void {
  if (!import.meta.client) return
  try {
    window.localStorage.setItem(ONBOARDING_KEY, '1')
  } catch {
    /* private mode still lets this visit continue */
  }
}

export function shouldShowOnboarding(path: string): boolean {
  if (hasFinishedOnboarding()) return false
  if (!path.startsWith('/app')) return false
  if (path.startsWith('/app/onboarding')) return false
  return true
}
