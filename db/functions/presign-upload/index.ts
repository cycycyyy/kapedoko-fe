import { AwsClient } from 'https://esm.sh/aws4fetch@1.0.18'

const ALLOWED_TYPES: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
}

const MAX_BYTES = 2 * 1024 * 1024

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
}

function json(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return json(405, { error: 'Method not allowed' })
  }

  const authHeader = req.headers.get('Authorization') ?? ''
  const jwt = authHeader.replace(/^Bearer\s+/i, '')
  if (!jwt) {
    return json(401, { error: 'Sign in to upload a logo.' })
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const supabaseAnon = Deno.env.get('SUPABASE_ANON_KEY')
  if (!supabaseUrl || !supabaseAnon) {
    return json(500, { error: 'Upload is not configured.' })
  }

  const userRes = await fetch(`${supabaseUrl}/auth/v1/user`, {
    headers: {
      Authorization: `Bearer ${jwt}`,
      apikey: supabaseAnon,
    },
  })

  if (!userRes.ok) {
    return json(401, { error: 'Sign in to upload a logo.' })
  }

  const user = (await userRes.json()) as { id?: string }
  if (!user.id) {
    return json(401, { error: 'Sign in to upload a logo.' })
  }

  let payload: { contentType?: string; size?: number }
  try {
    payload = await req.json()
  } catch {
    return json(400, { error: 'Expected JSON with contentType and size.' })
  }

  const contentType = String(payload.contentType ?? '')
  const size = Number(payload.size ?? 0)
  const ext = ALLOWED_TYPES[contentType]

  if (!ext) {
    return json(400, { error: 'Use a JPG, PNG, or WebP image.' })
  }

  if (!Number.isFinite(size) || size <= 0 || size > MAX_BYTES) {
    return json(400, { error: 'Keep the logo under 2 MB.' })
  }

  const accountId = Deno.env.get('R2_ACCOUNT_ID')
  const bucket = Deno.env.get('R2_BUCKET')
  const accessKeyId = Deno.env.get('R2_ACCESS_KEY_ID')
  const secretAccessKey = Deno.env.get('R2_SECRET_ACCESS_KEY')
  const publicBase = Deno.env.get('R2_PUBLIC_BASE_URL') ?? ''

  if (!accountId || !bucket || !accessKeyId || !secretAccessKey) {
    return json(503, { error: 'Logo upload isn’t available yet.' })
  }

  const objectKey = `shop-logos/${user.id}/${crypto.randomUUID()}.${ext}`
  const endpoint = `https://${accountId}.r2.cloudflarestorage.com/${bucket}/${objectKey}`

  const r2 = new AwsClient({
    accessKeyId,
    secretAccessKey,
    region: 'auto',
    service: 's3',
  })

  const signed = await r2.sign(
    new Request(endpoint, {
      method: 'PUT',
      headers: { 'Content-Type': contentType },
    }),
    { aws: { signQuery: true } },
  )

  return json(200, {
    uploadUrl: signed.url,
    objectKey,
    publicUrl: publicBase ? `${publicBase.replace(/\/$/, '')}/${objectKey}` : null,
  })
})
