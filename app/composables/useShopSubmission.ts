import type { ShopInsert, ShopRow } from '~/types/shop'
import { normalizeAddress, normalizeCafeName } from '~/utils/identity'
import { optionalPhone } from '~/utils/phone'
import { isAllowedLogo } from '~/utils/logo'
import { authUserId } from '~/utils/auth'
import type { WeeklyHours } from '~/types/shop'

interface SubmitShopInput {
  name: string
  address: string
  lat: number
  lng: number
  phone: string
  hours: WeeklyHours
  logoFile: File | null
}

interface PresignResponse {
  uploadUrl?: string
  objectKey?: string
  publicUrl?: string | null
  error?: string
}

export function useShopSubmission() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  const session = useSupabaseSession()
  const submitting = ref(false)
  const error = ref('')

  const uploadLogo = async (file: File): Promise<string | null> => {
    if (!isAllowedLogo(file)) return null

    const { data, error: fnError } = await supabase.functions.invoke('presign-upload', {
      body: { contentType: file.type, size: file.size },
    })

    if (fnError || !data) {
      throw new Error('Logo upload isn’t available yet. Submit without a logo, or try again later.')
    }

    const payload = data as PresignResponse
    if (payload.error || !payload.uploadUrl || !payload.objectKey) {
      throw new Error(payload.error || 'Logo upload failed. Try a smaller JPG or PNG.')
    }

    const put = await fetch(payload.uploadUrl, {
      method: 'PUT',
      headers: { 'Content-Type': file.type },
      body: file,
    })

    if (!put.ok) {
      throw new Error('The logo didn’t upload. Check your connection and try again.')
    }

    return payload.objectKey
  }

  const submitShop = async (input: SubmitShopInput): Promise<ShopRow> => {
    error.value = ''
    const { data: liveSession } = await supabase.auth.getSession()
    const userId =
      liveSession.session?.user?.id ??
      session.value?.user?.id ??
      authUserId(user.value)

    if (!userId) {
      throw new Error('Sign in to add a cafe.')
    }

    submitting.value = true
    try {
      let logoObjectKey: string | null = null
      if (input.logoFile) {
        logoObjectKey = await uploadLogo(input.logoFile)
      }

      const row: ShopInsert = {
        name: normalizeCafeName(input.name),
        address: normalizeAddress(input.address),
        latitude: input.lat,
        longitude: input.lng,
        hours: input.hours,
        contact_number: optionalPhone(input.phone),
        logo_object_key: logoObjectKey,
        submitted_by: userId,
        status: 'pending',
      }

      const { data, error: insertError } = await supabase
        .from('shops')
        .insert(row)
        .select()
        .single()

      if (insertError || !data) {
        throw new Error(friendlyInsertError(insertError?.message))
      }

      return data as ShopRow
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Could not save this cafe. Try again.'
      error.value = message
      throw err instanceof Error ? err : new Error(message)
    } finally {
      submitting.value = false
    }
  }

  return { submitShop, submitting, error, uploadLogo }
}

function friendlyInsertError(message?: string): string {
  const text = (message ?? '').toLowerCase()
  if (text.includes('shops_in_marikina')) {
    return 'Pin the cafe inside Marikina before submitting.'
  }
  if (text.includes('shops_hours_shape')) {
    return 'Check the opening hours and try again.'
  }
  if (text.includes('shops_contact_number')) {
    return 'Use a phone number like 0917 123 4567.'
  }
  if (text.includes('shops_name_len')) {
    return 'Check the cafe name and try again.'
  }
  if (text.includes('row-level security') || text.includes('rls')) {
    return 'Sign in again, then submit the cafe.'
  }
  return 'Could not save this cafe. Check the details and try again.'
}
