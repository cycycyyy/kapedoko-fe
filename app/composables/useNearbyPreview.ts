import type { Cafe } from '~/types/cafe'
import { fetchApprovedCafes } from '~/utils/approved-shops'
import {
  cafesInsideNearbyRadius,
  nearbyPreviewBounds,
} from '~/utils/nearby-preview'

export function useNearbyPreview() {
  const supabase = useSupabaseClient()
  const config = useRuntimeConfig()
  const { radiusKm, radiusMeters } = useNearbyRadius()
  const { status: locationStatus, location, usingFallback, requestLocation } = useDeviceLocation()

  const open = ref(false)
  const cafes = ref<Cafe[]>([])
  const status = ref<'idle' | 'loading' | 'ready' | 'error'>('idle')
  const error = ref('')
  const tilesFailed = ref(false)
  let loadSeq = 0

  const origin = computed(() => (
    locationStatus.value === 'granted' && location.value && !usingFallback.value
      ? location.value
      : null
  ))

  const accuracy = computed(() => origin.value?.accuracy ?? 0)

  const loadCafes = async () => {
    const center = origin.value
    if (!open.value || !center) {
      cafes.value = []
      if (!open.value) status.value = 'idle'
      return
    }

    const seq = ++loadSeq
    status.value = 'loading'
    error.value = ''
    try {
      const publicBase = String(config.public.r2PublicBaseUrl || '')
      const fetched = await fetchApprovedCafes(supabase, publicBase, {
        bounds: nearbyPreviewBounds(center, radiusMeters.value),
      })
      if (seq !== loadSeq) return
      cafes.value = cafesInsideNearbyRadius(fetched, center, radiusMeters.value)
      status.value = 'ready'
    } catch (err) {
      if (seq !== loadSeq) return
      cafes.value = []
      status.value = 'error'
      error.value = err instanceof Error ? err.message : 'Could not load cafes near you.'
    }
  }

  const toggle = async () => {
    if (open.value) {
      open.value = false
      tilesFailed.value = false
      status.value = 'idle'
      error.value = ''
      cafes.value = []
      return
    }

    open.value = true
    tilesFailed.value = false
    if (!origin.value) await requestLocation()
  }

  watch(
    [open, origin, radiusMeters],
    () => {
      if (!open.value) return
      if (!origin.value) {
        cafes.value = []
        status.value = 'idle'
        return
      }
      void loadCafes()
    },
  )

  return {
    open,
    cafes,
    status,
    error,
    tilesFailed,
    origin,
    accuracy,
    radiusKm,
    radiusMeters,
    locationStatus,
    toggle,
    requestLocation,
    loadCafes,
  }
}
