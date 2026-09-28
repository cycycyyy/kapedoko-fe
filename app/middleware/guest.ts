import { safeRedirectPath } from '~/utils/auth'

export default defineNuxtRouteMiddleware(async (to) => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  const sessionUser = user.value ?? (await supabase.auth.getSession()).data.session?.user
  if (!sessionUser) return

  const requested = Array.isArray(to.query.redirect) ? to.query.redirect[0] : to.query.redirect
  return navigateTo(safeRedirectPath(requested))
})
