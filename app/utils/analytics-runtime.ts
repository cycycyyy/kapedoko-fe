import { Capacitor } from '@capacitor/core'
import type { PostHog, PostHogCaptureOptions } from 'posthog-js'
import {
  ANALYTICS_EVENTS,
  APP_RESUME_MS,
  createSessionDedupe,
  isAnalyticsEventName,
  scrubEventProperties,
  shouldCapture,
  type AcquisitionSource,
  type AnalyticsEventName,
  type AnalyticsEventProps,
  type AnalyticsPlatform,
  type CommonAnalyticsProperties,
  type ConsentState,
} from './analytics'
import {
  captureAcquisitionFromLocation,
  clearAcquisitionSource,
  readAcquisitionSource,
  readAnalyticsConsent,
  writeAcquisitionSource,
  writeAnalyticsConsent,
} from './analytics-consent'

export type TrackOptions = {
  instant?: boolean
}

export type AnalyticsRuntimeConfig = {
  enabled: boolean
  key: string
  host: string
  appVersion: string
}

type Adapter = {
  init: () => void
  capture: (event: string, props: Record<string, string | number | boolean>, instant?: boolean) => void
  identify: (id: string) => void
  reset: () => void
  register: (props: Record<string, string>) => void
  optIn: () => void
  optOut: () => void
  inited: () => boolean
}

const FORBIDDEN_SET_KEYS = new Set(['email', 'name', 'phone', 'distinct_id'])

export function createAnalyticsController(options: {
  config: AnalyticsRuntimeConfig
  isClient: boolean
  adapter?: Adapter
}) {
  const dedupe = createSessionDedupe()
  let consent: ConsentState | null = null
  let acquisition: AcquisitionSource | null = null
  let userId: string | null = null
  let adapter = options.adapter ?? null
  let coldOpened = false

  const platform = (): AnalyticsPlatform => {
    const value = Capacitor.getPlatform()
    if (value === 'ios' || value === 'android') return value
    return 'web'
  }

  const common = (): CommonAnalyticsProperties => ({
    app_version: options.config.appVersion,
    platform: platform(),
    auth_state: userId ? 'signed_in' : 'guest',
    acquisition_source: acquisition ?? (Capacitor.isNativePlatform() ? 'direct' : 'direct'),
  })

  const canCapture = () => shouldCapture({
    client: options.isClient,
    enabled: options.config.enabled,
    hasKey: Boolean(options.config.key),
    consent,
  })

  const ensureAdapter = () => {
    if (!adapter || adapter.inited() || !canCapture()) return
    adapter.init()
    adapter.optIn()
    adapter.register({
      app_version: common().app_version,
      platform: common().platform,
      auth_state: common().auth_state,
      acquisition_source: common().acquisition_source,
    })
    if (userId) adapter.identify(userId)
  }

  const track = <E extends AnalyticsEventName>(
    event: E,
    props: AnalyticsEventProps[E],
    trackOptions?: TrackOptions,
  ) => {
    if (!canCapture()) return
    ensureAdapter()
    if (!adapter?.inited()) return
    const payload = scrubEventProperties(event, { ...props }, common())
    if (!payload) return
    adapter.capture(event, payload, trackOptions?.instant)
  }

  return {
    getConsent: () => consent,
    getAcquisition: () => acquisition,
    hydrate: async () => {
      consent = await readAnalyticsConsent()
      if (consent === 'granted') {
        acquisition = await readAcquisitionSource()
        ensureAdapter()
      }
      return consent
    },
    setConsent: async (next: ConsentState) => {
      consent = next
      await writeAnalyticsConsent(next)
      if (next === 'declined') {
        adapter?.optOut()
        adapter?.reset()
        acquisition = null
        await clearAcquisitionSource()
        dedupe.clear()
        coldOpened = false
        return
      }
      if (!acquisition) {
        const captured = captureAcquisitionFromLocation({
          search: options.isClient && typeof window !== 'undefined' ? window.location.search : '',
          referrer: options.isClient && typeof document !== 'undefined' ? document.referrer : '',
          native: Capacitor.isNativePlatform(),
        })
        acquisition = captured
        await writeAcquisitionSource(captured)
      }
      ensureAdapter()
    },
    identifyUser: (id: string | null) => {
      const next = id?.trim() || null
      if (next === userId) return
      userId = next
      if (!canCapture()) return
      ensureAdapter()
      if (!adapter?.inited()) return
      if (next) {
        adapter.identify(next)
        adapter.register({ auth_state: 'signed_in' })
        return
      }
      adapter.reset()
      adapter.register({
        app_version: common().app_version,
        platform: common().platform,
        auth_state: 'guest',
        acquisition_source: common().acquisition_source,
      })
    },
    track,
    once: (key: string) => {
      if (!canCapture()) return false
      return dedupe.once(key)
    },
    markAppOpened: (entry: 'cold' | 'resume') => {
      if (entry === 'cold') {
        if (coldOpened) return
        if (!dedupe.once('app_opened:cold')) return
        coldOpened = true
      } else if (!dedupe.once(`app_opened:resume:${Math.floor(Date.now() / APP_RESUME_MS)}`)) {
        return
      }
      track(ANALYTICS_EVENTS.APP_OPENED, { entry })
    },
    attachAdapter: (next: Adapter) => {
      adapter = next
    },
  }
}

type CapturePayload = {
  event?: string
  properties?: Record<string, unknown>
}

function scrubCapture(event: CapturePayload | CapturePayload[] | null) {
  const scrubOne = (item: CapturePayload | null) => {
    if (!item) return null
    const name = item.event
    if (
      name
      && !isAnalyticsEventName(name)
      && name !== '$identify'
      && name !== '$set'
    ) {
      return null
    }
    const properties = item.properties
    if (properties) {
      delete properties.$ip
      for (const key of Object.keys(properties)) {
        if (key.startsWith('$geoip_')) delete properties[key]
      }
      const assigned = properties.$set
      if (assigned && typeof assigned === 'object') {
        for (const key of Object.keys(assigned)) {
          if (FORBIDDEN_SET_KEYS.has(key)) delete (assigned as Record<string, unknown>)[key]
        }
      }
    }
    return item
  }

  if (Array.isArray(event)) {
    const next = event.map((item) => scrubOne(item)).filter((item): item is CapturePayload => Boolean(item))
    return next.length ? next : null
  }
  return scrubOne(event)
}

export function createPostHogAdapter(input: {
  posthog: PostHog
  key: string
  host: string
}): Adapter {
  let inited = false
  let ready = false
  type Queued =
    | { kind: 'capture'; event: string; props: Record<string, string | number | boolean>; instant?: boolean }
    | { kind: 'identify'; id: string }
    | { kind: 'register'; props: Record<string, string> }
    | { kind: 'reset' }
  const queued: Queued[] = []

  const extra = (instant?: boolean): PostHogCaptureOptions => ({
    transport: instant ? 'sendBeacon' : undefined,
    send_instantly: true,
  })

  const apply = (item: Queued) => {
    if (item.kind === 'capture') {
      input.posthog.capture(item.event, item.props, extra(item.instant))
      return
    }
    if (item.kind === 'identify') {
      input.posthog.identify(item.id)
      return
    }
    if (item.kind === 'register') {
      input.posthog.register(item.props)
      return
    }
    input.posthog.reset()
  }

  const markReady = () => {
    input.posthog.opt_in_capturing()
    if (ready) return
    ready = true
    for (const item of queued) apply(item)
    queued.length = 0
  }

  const enqueue = (item: Queued) => {
    if (!ready) {
      queued.push(item)
      return
    }
    apply(item)
  }

  return {
    inited: () => inited,
    init: () => {
      if (inited) return
      inited = true
      input.posthog.init(input.key, {
        api_host: input.host,
        ui_host: 'https://eu.posthog.com',
        autocapture: false,
        capture_pageview: false,
        capture_pageleave: false,
        disable_session_recording: true,
        disable_surveys: true,
        advanced_disable_feature_flags: true,
        opt_out_capturing_by_default: true,
        persistence: 'localStorage',
        person_profiles: 'identified_only',
        request_batching: false,
        before_send: (event) => scrubCapture(event as CapturePayload | CapturePayload[] | null) as typeof event,
        loaded: () => markReady(),
      })
      markReady()
    },
    capture: (event, props, instant) => {
      enqueue({ kind: 'capture', event, props, instant })
    },
    identify: (id) => {
      enqueue({ kind: 'identify', id })
    },
    reset: () => {
      enqueue({ kind: 'reset' })
    },
    register: (props) => {
      enqueue({ kind: 'register', props })
    },
    optIn: () => {
      if (inited) markReady()
    },
    optOut: () => {
      ready = false
      queued.length = 0
      input.posthog.opt_out_capturing()
    },
  }
}
