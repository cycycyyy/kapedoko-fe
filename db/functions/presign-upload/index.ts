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

interface R2Config {
  accountId: string
  bucket: string
  accessKeyId: string
  secretAccessKey: string
  publicBase: string
}

function json(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

function r2Endpoint(config: R2Config, objectKey: string): string {
  return `https://${config.accountId}.r2.cloudflarestorage.com/${config.bucket}/${objectKey}`
}

function publicUrl(config: R2Config, objectKey: string): string | null {
  return config.publicBase
    ? `${config.publicBase.replace(/\/$/, '')}/${objectKey}`
    : null
}

function r2Client(config: R2Config): AwsClient {
  return new AwsClient({
    accessKeyId: config.accessKeyId,
    secretAccessKey: config.secretAccessKey,
    region: 'auto',
    service: 's3',
  })
}

function readR2Config(): R2Config | null {
  const accountId = Deno.env.get('R2_ACCOUNT_ID')
  const bucket = Deno.env.get('R2_BUCKET')
  const accessKeyId = Deno.env.get('R2_ACCESS_KEY_ID')
  const secretAccessKey = Deno.env.get('R2_SECRET_ACCESS_KEY')
  const publicBase = Deno.env.get('R2_PUBLIC_BASE_URL') ?? ''

  if (!accountId || !bucket || !accessKeyId || !secretAccessKey) {
    return null
  }

  return { accountId, bucket, accessKeyId, secretAccessKey, publicBase }
}

async function authenticate(req: Request): Promise<Response | string> {
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

  return user.id
}

function validateLogoMeta(
  contentType: string,
  size: number,
): { ext: string } | { error: string } {
  const ext = ALLOWED_TYPES[contentType]
  if (!ext) {
    return { error: 'Use a JPG, PNG, or WebP image.' }
  }
  if (!Number.isFinite(size) || size <= 0 || size > MAX_BYTES) {
    return { error: 'Keep the logo under 2 MB.' }
  }
  return { ext }
}

function r2UploadError(status: number): string {
  if (status === 403) {
    return 'Logo upload credentials are invalid. Check R2 secrets on presign-upload.'
  }
  if (status === 404) {
    return 'Logo upload bucket was not found. Check the R2_BUCKET secret.'
  }
  return 'The logo didn’t upload. Try again later.'
}

async function uploadToR2(
  config: R2Config,
  userId: string,
  contentType: string,
  ext: string,
  body: ArrayBuffer,
): Promise<Response> {
  const objectKey = `shop-logos/${userId}/${crypto.randomUUID()}.${ext}`
  const endpoint = r2Endpoint(config, objectKey)
  const client = r2Client(config)

  const signed = await client.sign(
    new Request(endpoint, {
      method: 'PUT',
      headers: { 'Content-Type': contentType },
    }),
    { aws: { signQuery: true } },
  )

  const upload = await fetch(signed.url, {
    method: 'PUT',
    headers: { 'Content-Type': contentType },
    body,
  })

  if (!upload.ok) {
    const detail = await upload.text().catch(() => '')
    console.error('R2 upload failed', upload.status, detail)
    return json(502, { error: r2UploadError(upload.status) })
  }

  return json(200, { objectKey, publicUrl: publicUrl(config, objectKey) })
}

async function handleMultipartUpload(
  req: Request,
  userId: string,
  config: R2Config,
): Promise<Response> {
  let form: FormData
  try {
    form = await req.formData()
  } catch {
    return json(400, { error: 'Expected multipart form with a file field.' })
  }

  const file = form.get('file')
  if (!(file instanceof File)) {
    return json(400, { error: 'Attach a logo image to upload.' })
  }

  const validation = validateLogoMeta(file.type, file.size)
  if ('error' in validation) {
    return json(400, { error: validation.error })
  }

  const body = await file.arrayBuffer()
  return uploadToR2(config, userId, file.type, validation.ext, body)
}

async function handlePresignRequest(
  req: Request,
  userId: string,
  config: R2Config,
): Promise<Response> {
  let payload: { contentType?: string; size?: number }
  try {
    payload = await req.json()
  } catch {
    return json(400, { error: 'Expected JSON with contentType and size.' })
  }

  const contentType = String(payload.contentType ?? '')
  const size = Number(payload.size ?? 0)
  const validation = validateLogoMeta(contentType, size)
  if ('error' in validation) {
    return json(400, { error: validation.error })
  }

  const objectKey = `shop-logos/${userId}/${crypto.randomUUID()}.${validation.ext}`
  const endpoint = r2Endpoint(config, objectKey)
  const signed = await r2Client(config).sign(
    new Request(endpoint, {
      method: 'PUT',
      headers: { 'Content-Type': contentType },
    }),
    { aws: { signQuery: true } },
  )

  return json(200, {
    uploadUrl: signed.url,
    objectKey,
    publicUrl: publicUrl(config, objectKey),
  })
}

Deno.serve(async (req): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return json(405, { error: 'Method not allowed' })
  }

  const auth = await authenticate(req)
  if (auth instanceof Response) return auth

  const config = readR2Config()
  if (!config) {
    return json(503, { error: 'Logo upload isn’t available yet.' })
  }

  const contentType = req.headers.get('content-type') ?? ''
  if (contentType.includes('multipart/form-data')) {
    return handleMultipartUpload(req, auth, config)
  }

  return handlePresignRequest(req, auth, config)
})
