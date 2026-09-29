import type { AdCampaignRow, AdminDashboardCounts, AdminUserRow, AdminUsersResponse } from '~/types/admin'
import type { ContentReportRow, MarkerTier, ProfileRole, ShopPlacementRow, ShopRow, ShopStatus, WeeklyHours } from '~/types/shop'
import { authUserId } from '~/utils/auth'
import { effectiveMarkerTier } from '~/utils/marker-tier'
import { edgeFunctionErrorMessage } from '~/utils/admin-users'

export async function requireAdminUserId(): Promise<string> {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  const session = useSupabaseSession()
  const { data } = await supabase.auth.getSession()
  const userId = data.session?.user?.id ?? session.value?.user?.id ?? authUserId(user.value)
  if (!userId) throw new Error('Sign in as an admin.')
  return userId
}

export async function uploadAdminAsset(file: File, purpose: 'shop-logo' | 'ad-banner'): Promise<string> {
  const supabase = useSupabaseClient()
  const form = new FormData()
  form.append('file', file)
  form.append('purpose', purpose)
  const { data, error } = await supabase.functions.invoke('presign-upload', { body: form })
  const payload = (data ?? null) as { objectKey?: string; error?: string } | null
  if (error || !payload?.objectKey) {
    throw new Error(payload?.error || 'Could not upload that file. Try again.')
  }
  return payload.objectKey
}

export function useAdminData() {
  const supabase = useSupabaseClient()
  const shops = ref<ShopRow[]>([])
  const placements = ref<ShopPlacementRow[]>([])
  const reports = ref<ContentReportRow[]>([])
  const ads = ref<AdCampaignRow[]>([])
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

  const counts = computed<AdminDashboardCounts>(() => {
    const now = Date.now()
    return {
      pending: shops.value.filter((shop) => shop.status === 'pending').length,
      approved: shops.value.filter((shop) => shop.status === 'approved').length,
      rejected: shops.value.filter((shop) => shop.status === 'rejected').length,
      openReports: reports.value.filter((report) => report.status === 'open').length,
      activePlacements: placements.value.filter((row) => new Date(row.starts_at).getTime() <= now && new Date(row.ends_at).getTime() > now).length,
      activeAds: ads.value.filter((row) => row.enabled && !row.cancelled_at && new Date(row.starts_at).getTime() <= now && new Date(row.ends_at).getTime() > now).length,
      users: 0,
    }
  })

  const loadPlacements = async () => {
    const { data, error: placementError } = await supabase
      .from('shop_placements')
      .select('*')
      .order('starts_at', { ascending: false })
    if (placementError) throw placementError
    placements.value = (data ?? []) as ShopPlacementRow[]
  }

  const loadReports = async () => {
    const { data, error: reportError } = await supabase
      .from('content_reports')
      .select('*')
      .order('created_at', { ascending: false })
    if (reportError) {
      reports.value = []
      return
    }
    reports.value = (data ?? []) as ContentReportRow[]
  }

  const loadAds = async () => {
    const { data, error: adsError } = await supabase
      .from('ad_campaigns')
      .select('*')
      .order('starts_at', { ascending: false })
    if (adsError) {
      ads.value = []
      return
    }
    ads.value = (data ?? []) as AdCampaignRow[]
  }

  const load = async () => {
    status.value = 'loading'
    error.value = ''
    try {
      const userId = await requireAdminUserId()
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle()
      if (profileError || profile?.role !== 'admin') {
        status.value = 'forbidden'
        return
      }
      const { data, error: shopsError } = await supabase
        .from('shops')
        .select('*')
        .order('created_at', { ascending: false })
      if (shopsError) throw shopsError
      shops.value = (data ?? []) as ShopRow[]
      await Promise.all([loadPlacements(), loadReports(), loadAds()])
      status.value = 'ready'
    } catch (err) {
      status.value = 'error'
      error.value = err instanceof Error ? err.message : 'Could not load the admin portal.'
    }
  }

  const fetchShop = async (shopId: string): Promise<ShopRow | null> => {
    const fromList = shops.value.find((row) => row.id === shopId)
    if (fromList) return fromList
    const { data, error: shopError } = await supabase
      .from('shops')
      .select('*')
      .eq('id', shopId)
      .maybeSingle()
    if (shopError) throw shopError
    const row = (data ?? null) as ShopRow | null
    if (row) {
      shops.value = shops.value.some((item) => item.id === row.id)
        ? shops.value.map((item) => (item.id === row.id ? row : item))
        : [row, ...shops.value]
    }
    return row
  }

  const markerTierFor = (shopId: string): MarkerTier =>
    effectiveMarkerTier(placementsByShop.value.get(shopId) ?? [])

  const moderate = async (
    shop: ShopRow,
    next: Extract<ShopStatus, 'approved' | 'rejected' | 'pending'>,
    rejectionReason = '',
  ) => {
    savingId.value = shop.id
    error.value = ''
    try {
      const { data, error: rpcError } = await supabase.rpc('moderate_admin_shop', {
        p_shop_id: shop.id,
        p_status: next,
        p_rejection_reason: next === 'rejected' ? rejectionReason : null,
      })
      const rpcRow = Array.isArray(data) ? data[0] : data
      let updated = rpcRow as ShopRow | null
      if (rpcError || !updated) {
        const reviewerId = await requireAdminUserId()
        const { data: row, error: updateError } = await supabase
          .from('shops')
          .update({
            status: next,
            rejection_reason: next === 'rejected' ? rejectionReason.trim() || 'Does not meet listing standards' : null,
            reviewed_by: reviewerId,
            reviewed_at: new Date().toISOString(),
          })
          .eq('id', shop.id)
          .select()
          .single()
        if (updateError || !row) {
          throw new Error(rpcError?.message || updateError?.message || 'Could not update this cafe.')
        }
        updated = row as ShopRow
      }
      shops.value = shops.value.map((item) => (item.id === shop.id ? updated : item))
      if (next !== 'approved') {
        const now = new Date().toISOString()
        placements.value = placements.value.map((row) =>
          row.shop_id === shop.id && row.ends_at > now ? { ...row, ends_at: now } : row,
        )
        ads.value = ads.value.map((row) =>
          row.shop_id === shop.id && !row.cancelled_at
            ? { ...row, cancelled_at: now, enabled: false, ends_at: row.ends_at > now ? now : row.ends_at }
            : row,
        )
      }
      return updated
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Could not update this cafe.'
      throw err
    } finally {
      savingId.value = null
    }
  }

  const savePlacement = async (shop: ShopRow, kind: 'standard' | 'partner' | 'sponsored', startsAt: string, endsAt: string) => {
    if (shop.status !== 'approved') throw new Error('Approve the cafe before setting a map pin.')
    savingId.value = shop.id
    error.value = ''
    try {
      const { error: rpcError } = await supabase.rpc('save_shop_placement', {
        p_shop_id: shop.id,
        p_kind: kind,
        p_starts_at: kind === 'standard' ? null : new Date(startsAt).toISOString(),
        p_ends_at: kind === 'standard' ? null : new Date(endsAt).toISOString(),
      })
      if (rpcError) throw new Error(rpcError.message)
      await loadPlacements()
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Could not save this map pin.'
      throw err
    } finally {
      savingId.value = null
    }
  }

  const endPlacement = async (placementId: string) => {
    savingId.value = placementId
    try {
      const { error: rpcError } = await supabase.rpc('end_shop_placement', { p_placement_id: placementId })
      if (rpcError) throw new Error(rpcError.message)
      await loadPlacements()
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Could not end this placement.'
      throw err
    } finally {
      savingId.value = null
    }
  }

  const createShop = async (input: {
    name: string
    address: string
    latitude: number
    longitude: number
    hours: WeeklyHours
    contact_number: string | null
    logoFile: File | null
  }) => {
    let logoKey: string | null = null
    if (input.logoFile) logoKey = await uploadAdminAsset(input.logoFile, 'shop-logo')
    const { data, error: rpcError } = await supabase.rpc('create_admin_shop', {
      p_name: input.name,
      p_address: input.address,
      p_latitude: input.latitude,
      p_longitude: input.longitude,
      p_hours: input.hours,
      p_contact_number: input.contact_number,
      p_logo_object_key: logoKey,
    })
    if (rpcError || !data) throw new Error(rpcError?.message || 'Could not create this cafe.')
    const created = (Array.isArray(data) ? data[0] : data) as ShopRow
    shops.value = [created, ...shops.value]
    return created
  }

  const updateShop = async (
    shopId: string,
    input: {
      name: string
      address: string
      latitude: number
      longitude: number
      hours: WeeklyHours
      contact_number: string | null
      logoFile: File | null
      logoObjectKey: string | null
    },
  ) => {
    let logoKey = input.logoObjectKey
    if (input.logoFile) logoKey = await uploadAdminAsset(input.logoFile, 'shop-logo')
    const { data, error: rpcError } = await supabase.rpc('update_admin_shop', {
      p_shop_id: shopId,
      p_name: input.name,
      p_address: input.address,
      p_latitude: input.latitude,
      p_longitude: input.longitude,
      p_hours: input.hours,
      p_contact_number: input.contact_number,
      p_logo_object_key: logoKey,
    })
    if (rpcError || !data) throw new Error(rpcError?.message || 'Could not save this cafe.')
    const updated = (Array.isArray(data) ? data[0] : data) as ShopRow
    shops.value = shops.value.map((item) => (item.id === shopId ? updated : item))
    return updated
  }

  const resolveReport = async (reportId: string, outcome: 'hidden' | 'dismissed') => {
    savingId.value = reportId
    try {
      const { error: rpcError } = await supabase.rpc('moderate_report', {
        p_report_id: reportId,
        p_outcome: outcome,
      })
      if (rpcError) throw rpcError
      reports.value = reports.value.map((report) =>
        report.id === reportId ? { ...report, status: outcome } : report,
      )
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Could not update this report.'
      throw err
    } finally {
      savingId.value = null
    }
  }

  const saveAd = async (payload: {
    id?: string
    shop_id: string
    bannerFile: File | null
    banner_object_key?: string | null
    starts_at: string
    ends_at: string
    label: string
    priority: number
    enabled: boolean
  }) => {
    let bannerKey = payload.banner_object_key ?? null
    if (payload.bannerFile) bannerKey = await uploadAdminAsset(payload.bannerFile, 'ad-banner')
    if (!bannerKey) throw new Error('Upload a banner image.')
    const row = {
      shop_id: payload.shop_id,
      banner_object_key: bannerKey,
      starts_at: new Date(payload.starts_at).toISOString(),
      ends_at: new Date(payload.ends_at).toISOString(),
      label: payload.label.trim() || null,
      priority: payload.priority,
      enabled: payload.enabled,
      cancelled_at: payload.enabled ? null : new Date().toISOString(),
    }
    if (payload.id) {
      const { data, error: updateError } = await supabase.from('ad_campaigns').update(row).eq('id', payload.id).select().single()
      if (updateError || !data) throw new Error(updateError?.message || 'Could not save this ad.')
      ads.value = ads.value.map((item) => (item.id === payload.id ? (data as AdCampaignRow) : item))
      return data as AdCampaignRow
    }
    const { data, error: insertError } = await supabase.from('ad_campaigns').insert(row).select().single()
    if (insertError || !data) throw new Error(insertError?.message || 'Could not save this ad.')
    ads.value = [data as AdCampaignRow, ...ads.value]
    return data as AdCampaignRow
  }

  const cancelAd = async (id: string) => {
    const now = new Date().toISOString()
    const { data, error: updateError } = await supabase
      .from('ad_campaigns')
      .update({ enabled: false, cancelled_at: now, ends_at: now })
      .eq('id', id)
      .select()
      .single()
    if (updateError || !data) throw new Error(updateError?.message || 'Could not end this ad.')
    ads.value = ads.value.map((item) => (item.id === id ? (data as AdCampaignRow) : item))
  }

  return {
    supabase,
    shops,
    placements,
    placementsByShop,
    reports,
    ads,
    counts,
    status,
    error,
    savingId,
    load,
    fetchShop,
    loadPlacements,
    loadAds,
    markerTierFor,
    moderate,
    savePlacement,
    endPlacement,
    createShop,
    updateShop,
    resolveReport,
    saveAd,
    cancelAd,
  }
}

export function useAdminUsers() {
  const supabase = useSupabaseClient()
  const users = ref<AdminUserRow[]>([])
  const total = ref(0)
  const status = ref<'idle' | 'loading' | 'ready' | 'error'>('idle')
  const error = ref('')
  const savingId = ref<string | null>(null)

  const loadFromProfiles = async (query = '', page = 1) => {
    const perPage = 20
    const from = (page - 1) * perPage
    const term = query.replace(/[%_,()]/g, ' ').replace(/\s+/g, ' ').trim()
    let request = supabase
      .from('profiles')
      .select('id, display_name, role, created_at', { count: 'exact' })
      .order('created_at', { ascending: false })
      .range(from, from + perPage - 1)
    if (term) request = request.ilike('display_name', `%${term}%`)
    const { data, error: profileError, count } = await request
    if (profileError) throw profileError
    const rows = (data ?? []) as Array<{ id: string; display_name: string | null; role: ProfileRole; created_at: string }>
    const ids = rows.map((row) => row.id)
    const shopCounts = new Map<string, number>()
    const reviewCounts = new Map<string, number>()
    if (ids.length) {
      const [{ data: shopRows }, { data: reviewRows }] = await Promise.all([
        supabase.from('shops').select('submitted_by').in('submitted_by', ids),
        supabase.from('reviews').select('user_id').in('user_id', ids),
      ])
      for (const row of shopRows ?? []) {
        const id = String((row as { submitted_by?: string }).submitted_by ?? '')
        if (id) shopCounts.set(id, (shopCounts.get(id) ?? 0) + 1)
      }
      for (const row of reviewRows ?? []) {
        const id = String((row as { user_id?: string }).user_id ?? '')
        if (id) reviewCounts.set(id, (reviewCounts.get(id) ?? 0) + 1)
      }
    }
    users.value = rows.map((row) => ({
      id: row.id,
      email: null,
      displayName: row.display_name,
      role: row.role === 'admin' ? 'admin' : 'user',
      banned: false,
      createdAt: row.created_at,
      lastSignInAt: null,
      shopCount: shopCounts.get(row.id) ?? 0,
      reviewCount: reviewCounts.get(row.id) ?? 0,
    }))
    total.value = count ?? rows.length
  }

  const load = async (query = '', page = 1) => {
    status.value = 'loading'
    error.value = ''
    try {
      const { data, error: fnError } = await supabase.functions.invoke('admin-users', {
        body: { action: 'list', query, page, perPage: 20 },
      })
      const payload = data as (AdminUsersResponse & { error?: string }) | null
      const fnMessage = edgeFunctionErrorMessage(fnError, payload)
      if (!fnError && payload && !payload.error) {
        users.value = payload.users ?? []
        total.value = payload.total ?? 0
        status.value = 'ready'
        return
      }
      await loadFromProfiles(query, page)
      status.value = 'ready'
      if (fnMessage && !/non-2xx/i.test(fnMessage)) {
        error.value = ''
      }
    } catch (err) {
      status.value = 'error'
      error.value = err instanceof Error ? err.message : 'Could not load users.'
    }
  }

  const setRole = async (userId: string, role: ProfileRole) => {
    savingId.value = userId
    try {
      const { error: rpcError } = await supabase.rpc('admin_set_profile_role', {
        p_user_id: userId,
        p_role: role,
      })
      if (rpcError) throw new Error(rpcError.message)
      users.value = users.value.map((row) => (row.id === userId ? { ...row, role } : row))
    } finally {
      savingId.value = null
    }
  }

  const setBanned = async (userId: string, banned: boolean) => {
    savingId.value = userId
    try {
      const { data, error: fnError } = await supabase.functions.invoke('admin-users', {
        body: { action: banned ? 'suspend' : 'reactivate', userId },
      })
      const payload = (data ?? null) as { error?: string } | null
      const message = edgeFunctionErrorMessage(fnError, payload)
      if (fnError || payload?.error) {
        throw new Error(message || 'Could not update this account. Redeploy the admin-users function.')
      }
      users.value = users.value.map((row) => (row.id === userId ? { ...row, banned } : row))
    } finally {
      savingId.value = null
    }
  }

  return { users, total, status, error, savingId, load, setRole, setBanned }
}
