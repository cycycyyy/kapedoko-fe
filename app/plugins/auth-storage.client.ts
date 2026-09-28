import { Capacitor } from '@capacitor/core'

const SESSION_KEY = 'kapedoko-auth-session'

interface StoredSession {
  access_token: string
  refresh_token: string
}

function readStoredSession(): StoredSession | null {
  try {
    const raw = window.localStorage.getItem(SESSION_KEY)
    if (!raw) return null
    const parsed = JSON.parse(raw) as Partial<StoredSession>
    if (!parsed.access_token || !parsed.refresh_token) return null
    return { access_token: parsed.access_token, refresh_token: parsed.refresh_token }
  } catch {
    return null
  }
}

export default defineNuxtPlugin({
  name: 'kapedoko-auth-storage',
  enforce: 'post',
  setup() {
    if (!Capacitor.isNativePlatform()) return

    const supabase = useSupabaseClient()
    void (async () => {
      const { data } = await supabase.auth.getSession()
      if (data.session) return
      const stored = readStoredSession()
      if (!stored) return
      await supabase.auth.setSession(stored)
    })()

    supabase.auth.onAuthStateChange((_event, session) => {
      try {
        if (!session) {
          window.localStorage.removeItem(SESSION_KEY)
          return
        }
        const stored: StoredSession = {
          access_token: session.access_token,
          refresh_token: session.refresh_token,
        }
        window.localStorage.setItem(SESSION_KEY, JSON.stringify(stored))
      } catch {
        /* private mode cannot persist the native session */
      }
    })
  },
})
