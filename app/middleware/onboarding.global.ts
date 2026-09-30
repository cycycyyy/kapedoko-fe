import { hasFinishedOnboarding, shouldShowOnboarding } from '~/utils/onboarding'

export default defineNuxtRouteMiddleware(async (to) => {
  if (import.meta.server) return

  const finished = await hasFinishedOnboarding()
  if (shouldShowOnboarding(to.path, finished)) {
    return navigateTo('/app/onboarding')
  }
})
