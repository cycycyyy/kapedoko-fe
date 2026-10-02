import type { User } from '@supabase/supabase-js'
import type { AnalyticsEventName, AnalyticsEventProps, ConsentState } from '~/utils/analytics'
import type { TrackOptions } from '~/utils/analytics-runtime'

export function useAnalytics() {
  const consent = useState<ConsentState | 'pending' | null>('kd-analytics-consent', () => 'pending')
  const nuxt = useNuxtApp()
  const user = useSupabaseUser()
  const provided = nuxt.$analytics as {
    controller?: {
      getConsent: () => ConsentState | null
      setConsent: (next: ConsentState) => Promise<void>
      identifyUser: (id: string | null) => void
      track: <E extends AnalyticsEventName>(event: E, props: AnalyticsEventProps[E], options?: TrackOptions) => void
      once: (key: string) => boolean
      markAppOpened: (entry: 'cold' | 'resume') => void
    }
    bindResume?: () => void
  } | undefined
  const controller = provided?.controller

  const setConsent = async (next: ConsentState) => {
    await controller?.setConsent(next)
    consent.value = next
    if (next !== 'granted') return
    controller?.identifyUser((user.value as User | null)?.id ?? null)
    provided?.bindResume?.()
    controller?.markAppOpened('cold')
  }

  const track = <E extends AnalyticsEventName>(
    event: E,
    props: AnalyticsEventProps[E],
    options?: TrackOptions,
  ) => {
    controller?.track(event, props, options)
  }

  return {
    consent,
    setConsent,
    track,
    once: (key: string) => controller?.once(key) ?? false,
    identifyUser: (id: string | null) => controller?.identifyUser(id),
    markAppOpened: (entry: 'cold' | 'resume') => controller?.markAppOpened(entry),
  }
}
