export default defineNuxtRouteMiddleware(async (to) => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  const { data } = await supabase.auth.getSession()
  const userId = data.session?.user?.id ?? user.value?.id
  if (!userId) {
    return navigateTo({ path: '/login', query: { redirect: to.fullPath } })
  }

  const { data: profile, error } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', userId)
    .maybeSingle()

  if (error || profile?.role !== 'admin') {
    return navigateTo('/app')
  }
})
