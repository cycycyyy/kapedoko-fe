import type { ProfileRole } from '~/types/shop'
import { parseProfileRole } from '~/utils/profile-role'

export function useStaffSession() {
  const supabase = useSupabaseClient()
  const role = ref<ProfileRole | null>(null)
  const status = ref<'idle' | 'loading' | 'ready' | 'forbidden' | 'error'>('idle')
  const error = ref('')

  const load = async () => {
    status.value = 'loading'
    error.value = ''
    const { data: sessionData } = await supabase.auth.getSession()
    const userId = sessionData.session?.user?.id
    if (!userId) {
      status.value = 'forbidden'
      return
    }
    const { data, error: profileError } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', userId)
      .maybeSingle()
    if (profileError) {
      status.value = 'error'
      error.value = 'Could not load your staff profile.'
      return
    }
    const next = parseProfileRole(data?.role)
    if (next !== 'admin' && next !== 'auditor') {
      status.value = 'forbidden'
      return
    }
    role.value = next
    status.value = 'ready'
  }

  onMounted(() => {
    void load()
  })

  return {
    role,
    status,
    error,
    navRole: computed(() => (role.value === 'auditor' ? 'auditor' : 'admin')),
    isAdmin: computed(() => role.value === 'admin'),
    load,
  }
}
