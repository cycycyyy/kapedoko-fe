import type { Cafe } from '~/types/cafe'
import type { ShopReviewStatsRow, ShopRow } from '~/types/shop'
import { mapShopToCafe } from '~/utils/shop-mapper'

export function useApprovedShops() {
  const supabase = useSupabaseClient()
  const config = useRuntimeConfig()
  const cafes = ref<Cafe[]>([])
  const source = ref<'live' | 'demo'>('demo')
  const status = ref<'idle' | 'loading' | 'ready' | 'error'>('idle')
  const error = ref('')

  const refresh = async () => {
    status.value = 'loading'
    error.value = ''

    try {
      const { data: shops, error: shopsError } = await supabase
        .from('shops')
        .select(
          'id,name,description,address,latitude,longitude,categories,hours,cover_photo_url,logo_object_key,contact_number,status,submitted_by,reviewed_by,reviewed_at,rejection_reason,created_at,updated_at',
        )
        .eq('status', 'approved')
        .order('name')

      if (shopsError) throw shopsError

      const approved = ((shops ?? []) as ShopRow[]).filter((shop) => shop.status === 'approved')

      if (!approved.length) {
        cafes.value = []
        source.value = 'demo'
        status.value = 'ready'
        return
      }

      const ids = approved.map((shop) => shop.id)
      const { data: stats } = await supabase
        .from('shop_review_stats')
        .select('*')
        .in('shop_id', ids)

      const publicBase = String(config.public.r2PublicBaseUrl || '')
      const statsById = new Map(
        ((stats ?? []) as ShopReviewStatsRow[]).map((row) => [row.shop_id, row]),
      )

      cafes.value = approved.map((shop) =>
        mapShopToCafe(shop, statsById.get(shop.id), publicBase),
      )
      source.value = 'live'
      status.value = 'ready'
    } catch (err) {
      cafes.value = []
      source.value = 'demo'
      status.value = 'error'
      error.value = err instanceof Error ? err.message : 'Could not load cafes.'
    }
  }

  onMounted(() => {
    void refresh()
  })

  return { cafes, source, status, error, refresh }
}
