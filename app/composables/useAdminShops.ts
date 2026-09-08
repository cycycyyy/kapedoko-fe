import type { MarkerTier, ShopPlacementRow, ShopRow, ShopStatus } from '~/types/shop'
import { authUserId } from '~/utils/auth'
import { effectiveMarkerTier, markerTierToKind } from '~/utils/marker-tier'

export function useAdminShops() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  const session = useSupabaseSession()
  const shops = ref<ShopRow[]>([])
  const placements = ref<ShopPlacementRow[]>([])
  const isAdmin = ref(false)
  const status = ref<'idle' | 'loading' | 'ready' | 'forbidden' | 'error'>('idle')
  const error = ref('')
  const savingId = ref<string | null>(null)

  const placementsByShop = computed(() => {
    const grouped = new Map<string, ShopPlacementRow[]>()
    for (const row of placements.value) {
      const list = grouped.get(row.shop_id) ?? []
      list.push(row)
      grouped.set(row.shop_id, list)
    }
    return grouped
  })

  const loadPlacements = async (shopIds: string[]) => {
    if (!shopIds.length) {
      placements.value = []
      return
    }
    const { data, error: placementError } = await supabase
      .from('shop_placements')
      .select('*')
      .in('shop_id', shopIds)
      .order('starts_at', { ascending: false })

    if (placementError) throw placementError
    placements.value = (data ?? []) as ShopPlacementRow[]
  }

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
        placements.value = []
        status.value = 'forbidden'
        return
      }

      const { data, error: shopsError } = await supabase
        .from('shops')
        .select('*')
        .order('created_at', { ascending: false })

      if (shopsError) throw shopsError
      shops.value = (data ?? []) as ShopRow[]
      await loadPlacements(shops.value.map((shop) => shop.id))
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
      if (next !== 'approved') {
        const now = new Date().toISOString()
        placements.value = placements.value.map((row) =>
          row.shop_id === shop.id && row.ends_at > now ? { ...row, ends_at: now } : row,
        )
      }
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Could not update this submission.'
      throw err
    } finally {
      savingId.value = null
    }
  }

  const markerTierFor = (shopId: string): MarkerTier =>
    effectiveMarkerTier(placementsByShop.value.get(shopId) ?? [])

  const savePlacement = async (shop: ShopRow, tier: MarkerTier, startsAt: string, endsAt: string) => {
    if (shop.status !== 'approved') {
      throw new Error('Approve the cafe before setting a map pin.')
    }

    const start = new Date(startsAt)
    const end = new Date(endsAt)
    if (!Number.isFinite(start.getTime()) || !Number.isFinite(end.getTime()) || end <= start) {
      throw new Error('Choose an end date after the start date.')
    }

    savingId.value = shop.id
    error.value = ''
    try {
      const nowIso = new Date().toISOString()
      const { error: closeError } = await supabase
        .from('shop_placements')
        .update({ ends_at: nowIso })
        .eq('shop_id', shop.id)
        .lt('starts_at', nowIso)
        .gt('ends_at', nowIso)

      if (closeError) throw closeError

      const { error: deleteError } = await supabase
        .from('shop_placements')
        .delete()
        .eq('shop_id', shop.id)
        .gte('starts_at', nowIso)

      if (deleteError) throw deleteError

      const kind = markerTierToKind(tier)
      if (kind) {
        const { data, error: insertError } = await supabase
          .from('shop_placements')
          .insert({
            shop_id: shop.id,
            kind,
            starts_at: start.toISOString(),
            ends_at: end.toISOString(),
          })
          .select()
          .single()

        if (insertError || !data) {
          throw new Error(insertError?.message || 'Could not save this map pin.')
        }
      }

      await loadPlacements(shops.value.map((item) => item.id))
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Could not save this map pin.'
      throw err
    } finally {
      savingId.value = null
    }
  }

  onMounted(() => {
    void load()
  })

  return {
    shops,
    placements,
    placementsByShop,
    isAdmin,
    status,
    error,
    savingId,
    load,
    moderate,
    markerTierFor,
    savePlacement,
  }
}
