import { safeRedirectPath } from '~/utils/auth'

export default defineNuxtRouteMiddleware(async (to) => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  if (user.value) return

  const { data } = await supabase.auth.getSession()
  if (data.session) return

  const redirect = safeRedirectPath(to.fullPath)
  return navigateTo({ path: '/login', query: { redirect } })
})
