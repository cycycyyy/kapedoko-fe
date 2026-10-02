import { Preferences } from '@capacitor/preferences'
import { normalizeAcquisitionSource, type AcquisitionSource, type ConsentState } from './analytics'

export const ANALYTICS_CONSENT_KEY = 'kapedoko-analytics-consent'
export const ANALYTICS_ACQUISITION_KEY = 'kapedoko-analytics-acquisition'

function isBrowser(): boolean {
  return typeof window !== 'undefined'
}

export function isConsentState(value: string | null | undefined): value is ConsentState {
  return value === 'granted' || value === 'declined'
}

export function isAcquisitionSource(value: string | null | undefined): value is AcquisitionSource {
  return value === 'organic'
    || value === 'direct'
    || value === 'referral'
    || value === 'instagram'
    || value === 'facebook'
    || value === 'tiktok'
    || value === 'google'
    || value === 'other'
}

async function readLegacy(key: string): Promise<string | null> {
  if (!isBrowser()) return null
  try {
    return window.localStorage.getItem(key)
  } catch {
    return null
  }
}

async function writeBoth(key: string, value: string): Promise<void> {
  if (!isBrowser()) return
  try {
    await Preferences.set({ key, value })
  } catch {
    /* Capacitor Preferences can fail in a browser */
  }
  try {
    window.localStorage.setItem(key, value)
  } catch {
    /* private mode cannot persist */
  }
}

async function removeBoth(key: string): Promise<void> {
  if (!isBrowser()) return
  try {
    await Preferences.remove({ key })
  } catch {
    /* ignore */
  }
  try {
    window.localStorage.removeItem(key)
  } catch {
    /* ignore */
  }
}

async function readFlag(key: string): Promise<string | null> {
  if (!isBrowser()) return null
  try {
    const { value } = await Preferences.get({ key })
    if (value) return value
  } catch {
    /* fall through to localStorage */
  }
  return readLegacy(key)
}

export async function readAnalyticsConsent(): Promise<ConsentState | null> {
  const value = await readFlag(ANALYTICS_CONSENT_KEY)
  return isConsentState(value) ? value : null
}

export async function writeAnalyticsConsent(value: ConsentState): Promise<void> {
  await writeBoth(ANALYTICS_CONSENT_KEY, value)
}

export async function readAcquisitionSource(): Promise<AcquisitionSource | null> {
  const value = await readFlag(ANALYTICS_ACQUISITION_KEY)
  return isAcquisitionSource(value) ? value : null
}

export async function writeAcquisitionSource(value: AcquisitionSource): Promise<void> {
  await writeBoth(ANALYTICS_ACQUISITION_KEY, value)
}

export async function clearAcquisitionSource(): Promise<void> {
  await removeBoth(ANALYTICS_ACQUISITION_KEY)
}

export function captureAcquisitionFromLocation(input: {
  search: string
  referrer: string
  native: boolean
}): AcquisitionSource {
  const params = new URLSearchParams(input.search.startsWith('?') ? input.search.slice(1) : input.search)
  let referrerHost = ''
  try {
    referrerHost = input.referrer ? new URL(input.referrer).hostname : ''
  } catch {
    referrerHost = ''
  }
  return normalizeAcquisitionSource({
    utmSource: params.get('utm_source'),
    ref: params.get('ref'),
    referrerHost,
    native: input.native,
  })
}
