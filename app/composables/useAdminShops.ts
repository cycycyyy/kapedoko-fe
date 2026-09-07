import type { ShopRow, ShopStatus } from '~/types/shop'
import { authUserId } from '~/utils/auth'

export function useAdminShops() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  const session = useSupabaseSession()
  const shops = ref<ShopRow[]>([])
  const isAdmin = ref(false)
  const status = ref<'idle' | 'loading' | 'ready' | 'forbidden' | 'error'>('idle')
  const error = ref('')
  const savingId = ref<string | null>(null)

  const load = async () => {
    status.value = 'loading'
    error.value = ''

    const userId = session.value?.user?.id ?? authUserId(user.value)
    if (!userId) {
      status.value = 'forbidden'
      return
    }

    try {
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single()

      if (profileError) throw profileError
      isAdmin.value = profile?.role === 'admin'

      if (!isAdmin.value) {
        shops.value = []
        status.value = 'forbidden'
        return
      }

      const { data, error: shopsError } = await supabase
        .from('shops')
        .select('*')
        .order('created_at', { ascending: false })

      if (shopsError) throw shopsError
      shops.value = (data ?? []) as ShopRow[]
      status.value = 'ready'
    } catch (err) {
      status.value = 'error'
      error.value = err instanceof Error ? err.message : 'Could not load submissions.'
    }
  }

  const moderate = async (
    shop: ShopRow,
    next: Extract<ShopStatus, 'approved' | 'rejected'>,
    rejectionReason = '',
  ) => {
    savingId.value = shop.id
    error.value = ''
    try {
      const { data, error: updateError } = await supabase
        .from('shops')
        .update({
          status: next,
          rejection_reason: next === 'rejected' ? rejectionReason.trim() || 'Does not meet listing standards' : null,
        })
        .eq('id', shop.id)
        .select()
        .single()

      if (updateError || !data) {
        throw new Error(updateError?.message || 'Could not update this submission.')
      }

      shops.value = shops.value.map((item) => (item.id === shop.id ? (data as ShopRow) : item))
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Could not update this submission.'
      throw err
    } finally {
      savingId.value = null
    }
  }

  onMounted(() => {
    void load()
  })

  return { shops, isAdmin, status, error, savingId, load, moderate }
}
