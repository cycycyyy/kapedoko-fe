import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.47.10'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

function json(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

interface AuthUser {
  id: string
  jwt: string
}

function adminClient() {
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  return createClient(supabaseUrl, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  })
}

async function authenticate(req: Request): Promise<Response | AuthUser> {
  const authHeader = req.headers.get('Authorization') ?? ''
  const jwt = authHeader.replace(/^Bearer\s+/i, '')
  if (!jwt) return json(401, { error: 'Sign in as an admin.' })

  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const supabaseAnon = Deno.env.get('SUPABASE_ANON_KEY')
  if (!supabaseUrl || !supabaseAnon) return json(500, { error: 'Admin users is not configured.' })

  const userRes = await fetch(`${supabaseUrl}/auth/v1/user`, {
    headers: {
      Authorization: `Bearer ${jwt}`,
      apikey: supabaseAnon,
    },
  })
  if (!userRes.ok) return json(401, { error: 'Sign in as an admin.' })
  const user = (await userRes.json()) as { id?: string }
  if (!user.id) return json(401, { error: 'Sign in as an admin.' })
  return { id: user.id, jwt }
}

async function requireAdmin(auth: AuthUser): Promise<Response | true> {
  const client = adminClient()
  const { data, error } = await client
    .from('profiles')
    .select('role')
    .eq('id', auth.id)
    .maybeSingle()
  if (error) return json(403, { error: 'Admin only' })
  if (data?.role !== 'admin') return json(403, { error: 'Admin only' })
  return true
}

interface AuthAdminUser {
  id: string
  email?: string | null
  banned_until?: string | null
  created_at?: string | null
  last_sign_in_at?: string | null
}

function isBanned(user: AuthAdminUser): boolean {
  if (!user.banned_until) return false
  const until = new Date(user.banned_until).getTime()
  return Number.isFinite(until) && until > Date.now()
}

async function loadProfiles(ids: string[]) {
  const map = new Map<string, { display_name: string | null; role: string; created_at: string | null }>()
  if (!ids.length) return map
  const { data } = await adminClient()
    .from('profiles')
    .select('id, display_name, role, created_at')
    .in('id', ids)
  for (const row of data ?? []) {
    map.set(row.id, row as { display_name: string | null; role: string; created_at: string | null })
  }
  return map
}

async function loadCounts(ids: string[]) {
  const shops = new Map<string, number>()
  const reviews = new Map<string, number>()
  if (!ids.length) return { shops, reviews }
  const client = adminClient()
  const [{ data: shopRows }, { data: reviewRows }] = await Promise.all([
    client.from('shops').select('submitted_by').in('submitted_by', ids),
    client.from('reviews').select('user_id').in('user_id', ids),
  ])
  for (const row of shopRows ?? []) {
    const id = row.submitted_by as string
    shops.set(id, (shops.get(id) ?? 0) + 1)
  }
  for (const row of reviewRows ?? []) {
    const id = row.user_id as string
    reviews.set(id, (reviews.get(id) ?? 0) + 1)
  }
  return { shops, reviews }
}

function matchesQuery(
  query: string,
  user: AuthAdminUser,
  profile?: { display_name: string | null },
): boolean {
  if (!query) return true
  const hay = `${user.email ?? ''} ${profile?.display_name ?? ''}`.toLowerCase()
  return hay.includes(query)
}

Deno.serve(async (req): Promise<Response> => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (req.method !== 'POST') return json(405, { error: 'Method not allowed' })

  try {
    if (!Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || !Deno.env.get('SUPABASE_URL')) {
      return json(500, { error: 'Admin users is not configured.' })
    }

    const auth = await authenticate(req)
    if (auth instanceof Response) return auth
    const admin = await requireAdmin(auth)
    if (admin instanceof Response) return admin

    let payload: { action?: string; query?: string; page?: number; perPage?: number; userId?: string }
    try {
      payload = await req.json()
    } catch {
      return json(400, { error: 'Expected JSON.' })
    }

    const action = payload.action ?? 'list'
    const client = adminClient()

    if (action === 'list') {
      const page = Math.max(1, Number(payload.page) || 1)
      const perPage = Math.min(50, Math.max(1, Number(payload.perPage) || 20))
      const query = String(payload.query ?? '').trim().toLowerCase()
      const { data, error } = await client.auth.admin.listUsers({ page, perPage })
      if (error) return json(500, { error: error.message || 'Could not list users.' })
      const listed = (data?.users ?? []) as AuthAdminUser[]
      const profiles = await loadProfiles(listed.map((user) => user.id))
      const filtered = listed.filter((user) => matchesQuery(query, user, profiles.get(user.id)))
      const counts = await loadCounts(filtered.map((user) => user.id))
      return json(200, {
        page,
        perPage,
        total: query ? filtered.length : Number(data?.total ?? listed.length),
        users: filtered.map((user) => {
          const profile = profiles.get(user.id)
          return {
            id: user.id,
            email: user.email ?? null,
            displayName: profile?.display_name ?? null,
            role: profile?.role === 'admin' ? 'admin' : profile?.role === 'cafe-owner' ? 'cafe-owner' : 'user',
            banned: isBanned(user),
            createdAt: user.created_at ?? profile?.created_at ?? null,
            lastSignInAt: user.last_sign_in_at ?? null,
            shopCount: counts.shops.get(user.id) ?? 0,
            reviewCount: counts.reviews.get(user.id) ?? 0,
          }
        }),
      })
    }

    if (action === 'suspend' || action === 'reactivate') {
      const userId = String(payload.userId ?? '')
      if (!userId) return json(400, { error: 'Choose a user.' })
      if (userId === auth.id) return json(400, { error: 'You cannot suspend your own account.' })
      const { error } = await client.auth.admin.updateUserById(userId, {
        ban_duration: action === 'suspend' ? '876000h' : 'none',
      })
      if (error) return json(500, { error: error.message || 'Could not update this account.' })
      await client.rpc('admin_log_user_status', {
        p_user_id: userId,
        p_action: action === 'suspend' ? 'user.suspend' : 'user.reactivate',
      })
      const { data } = await client.auth.admin.getUserById(userId)
      const user = data?.user as AuthAdminUser | undefined
      return json(200, { ok: true, banned: user ? isBanned(user) : action === 'suspend' })
    }

    return json(400, { error: 'Unknown action' })
  } catch (err) {
    console.error('admin-users failed', err)
    return json(500, { error: err instanceof Error ? err.message : 'Could not update users.' })
  }
})
