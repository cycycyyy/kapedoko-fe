import { authUserId } from '~/utils/auth'
import { isShopId } from '~/utils/approved-shops'
import { favoriteIdsToInsert, mergeFavoriteIds, normalizeFavoriteIds } from '~/utils/favorites'

const GUEST_KEY = 'kapedoko-favorite-ids'
let clientBooted = false

function readStored(key: string): string[] {
  if (!import.meta.client) return []
  try {
    return normalizeFavoriteIds(JSON.parse(window.localStorage.getItem(key) || '[]'))
  } catch {
    return []
  }
}

function writeStored(key: string, ids: string[]) {
  if (!import.meta.client) return
  window.localStorage.setItem(key, JSON.stringify(normalizeFavoriteIds(ids)))
}

function userKey(userId: string) {
  return `${GUEST_KEY}:${userId}`
}

function isRetryableFavoriteError(message?: string) {
  const text = (message ?? '').toLowerCase()
  return text.includes('fetch') || text.includes('network') || text.includes('timeout') || text.includes('offline')
}

export function useFavorites() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  const session = useSupabaseSession()
  const ids = useState<string[]>('kd-favorite-ids', () => [])
  const status = useState<'idle' | 'loading' | 'ready' | 'error'>('kd-favorite-status', () => 'idle')
  const error = useState('kd-favorite-error', () => '')

  const currentUserId = async () => {
    const { data } = await supabase.auth.getSession()
    return data.session?.user?.id ?? session.value?.user?.id ?? authUserId(user.value)
  }

  const loadGuest = () => {
    ids.value = readStored(GUEST_KEY)
    status.value = 'ready'
    error.value = ''
  }

  const syncAccount = async (userId: string) => {
    status.value = 'loading'
    error.value = ''
    try {
      const { data, error: readError } = await supabase
        .from('favorites')
        .select('shop_id, created_at')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })

      if (readError) throw readError
      const remote = normalizeFavoriteIds((data ?? []).map((row) => String((row as { shop_id?: string }).shop_id ?? '')))
      const guest = readStored(GUEST_KEY)
      const cached = readStored(userKey(userId))
      const merged = mergeFavoriteIds([...guest, ...cached], remote)
      const pending = favoriteIdsToInsert(userId, remote, merged)
      const savedLocal: string[] = []
      const retryLater: string[] = []
      for (const row of pending) {
        const { error: writeError } = await supabase
          .from('favorites')
          .upsert(row, { onConflict: 'user_id,shop_id' })
        if (!writeError) savedLocal.push(row.shop_id)
        else if (isRetryableFavoriteError(writeError.message)) retryLater.push(row.shop_id)
      }
      const synced = normalizeFavoriteIds([...remote, ...savedLocal, ...retryLater])
      ids.value = synced
      writeStored(userKey(userId), normalizeFavoriteIds([...remote, ...savedLocal]))
      writeStored(GUEST_KEY, retryLater)
      if (retryLater.length) {
        status.value = 'error'
        error.value = 'Some saves stayed on this device. We will try again when you are back online.'
      } else {
        status.value = 'ready'
      }
    } catch (err) {
      ids.value = mergeFavoriteIds(readStored(GUEST_KEY), readStored(userKey(userId)))
      status.value = 'error'
      error.value = err instanceof Error ? err.message : 'Could not sync saved cafes.'
    }
  }

  const refresh = async () => {
    const userId = await currentUserId()
    if (userId) await syncAccount(userId)
    else loadGuest()
  }

  const toggle = async (shopId: string) => {
    if (!isShopId(shopId)) return
    const previous = [...ids.value]
    const had = previous.includes(shopId)
    ids.value = had ? previous.filter((id) => id !== shopId) : [shopId, ...previous]
    error.value = ''

    const userId = await currentUserId()
    const key = userId ? userKey(userId) : GUEST_KEY
    writeStored(key, ids.value)
    if (!userId) return

    try {
      if (had) {
        const { error: deleteError } = await supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('shop_id', shopId)
        if (deleteError) throw deleteError
      } else {
        const { error: insertError } = await supabase
          .from('favorites')
          .upsert({ user_id: userId, shop_id: shopId }, { onConflict: 'user_id,shop_id' })
        if (insertError) throw insertError
      }
      status.value = 'ready'
    } catch {
      ids.value = previous
      writeStored(key, previous)
      status.value = 'error'
      error.value = 'Could not update favorites. Check your connection and try again.'
    }
  }

  if (import.meta.client && !clientBooted) {
    clientBooted = true
    void refresh()
    watch(
      () => authUserId(user.value),
      (next, prev) => {
        if (next === prev) return
        void refresh()
      },
    )
  }

  return {
    ids,
    status,
    error,
    isSaved: (shopId: string) => ids.value.includes(shopId),
    toggle,
    refresh,
  }
}
