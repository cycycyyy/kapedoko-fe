import type { Cafe } from '~/types/cafe'
import { fetchApprovedCafes } from '~/utils/approved-shops'

export function useApprovedShops() {
  const supabase = useSupabaseClient()
  const config = useRuntimeConfig()
  const cafes = ref<Cafe[]>([])
  const source = ref<'live' | 'error'>('live')
  const status = ref<'idle' | 'loading' | 'ready' | 'error'>('idle')
  const error = ref('')

  const refresh = async () => {
    status.value = 'loading'
    error.value = ''

    try {
      const publicBase = String(config.public.r2PublicBaseUrl || '')
      cafes.value = await fetchApprovedCafes(supabase, publicBase)
      source.value = 'live'
      status.value = 'ready'
    } catch (err) {
      cafes.value = []
      source.value = 'error'
      status.value = 'error'
      error.value = err instanceof Error ? err.message : 'Could not load cafes.'
    }
  }

  onMounted(() => {
    void refresh()
  })

  return { cafes, source, status, error, refresh }
}
