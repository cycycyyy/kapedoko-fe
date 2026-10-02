import { Capacitor } from '@capacitor/core'
import { App } from '@capacitor/app'
import posthog from 'posthog-js'
import { APP_RESUME_MS } from '~/utils/analytics'
import { createAnalyticsController, createPostHogAdapter } from '~/utils/analytics-runtime'

export default defineNuxtPlugin({
  name: 'kapedoko-analytics',
  setup() {
    const runtime = useRuntimeConfig()
    const analyticsConfig = runtime.public.analytics
    const controller = createAnalyticsController({
      isClient: true,
      config: {
        enabled: Boolean(analyticsConfig?.enabled),
        key: String(analyticsConfig?.key || ''),
        host: String(analyticsConfig?.host || 'https://eu.i.posthog.com'),
        appVersion: String(analyticsConfig?.appVersion || '1.0.0'),
      },
    })

    if (analyticsConfig?.enabled && analyticsConfig?.key) {
      controller.attachAdapter(createPostHogAdapter({
        posthog,
        key: String(analyticsConfig.key),
        host: String(analyticsConfig.host || 'https://eu.i.posthog.com'),
      }))
    }

    const supabase = useSupabaseClient()
    let backgroundedAt: number | null = null
    let resumeBound = false

    const bindResume = () => {
      if (resumeBound || !Capacitor.isNativePlatform()) return
      resumeBound = true
      void App.addListener('appStateChange', ({ isActive }) => {
        if (!isActive) {
          backgroundedAt = Date.now()
          return
        }
        if (backgroundedAt && Date.now() - backgroundedAt >= APP_RESUME_MS) {
          controller.markAppOpened('resume')
        }
        backgroundedAt = null
      })
    }

    const syncUser = async () => {
      const { data } = await supabase.auth.getSession()
      controller.identifyUser(data.session?.user.id ?? null)
    }

    supabase.auth.onAuthStateChange((event, session) => {
      if (event === 'SIGNED_OUT') {
        controller.identifyUser(null)
        return
      }
      controller.identifyUser(session?.user.id ?? null)
    })

    const consentState = useState<'pending' | import('~/utils/analytics').ConsentState | null>('kd-analytics-consent', () => 'pending')

    void (async () => {
      try {
        const consent = await controller.hydrate()
        consentState.value = consent
        if (consent === 'granted') {
          await syncUser()
          bindResume()
          controller.markAppOpened('cold')
        }
      } catch {
        consentState.value = null
      }
    })()

    return {
      provide: {
        analytics: {
          controller,
          bindResume,
        },
      },
    }
  },
})
