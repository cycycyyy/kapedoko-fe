import { beforeEach, describe, expect, mock, test } from 'bun:test'

mock.module('@capacitor/core', () => ({
  Capacitor: {
    getPlatform: () => 'web',
    isNativePlatform: () => false,
  },
}))

mock.module('@capacitor/preferences', () => ({
  Preferences: {
    async get() {
      return { value: null }
    },
    async set() {},
    async remove() {},
  },
}))

const { ANALYTICS_EVENTS } = await import('./analytics')
const { createAnalyticsController } = await import('./analytics-runtime')

describe('analytics controller', () => {
  const captured: Array<{ event: string; props: Record<string, unknown> }> = []

  beforeEach(() => {
    captured.length = 0
  })

  const make = (consent: 'granted' | 'declined' | null = null) => {
    const adapter = {
      inited: () => true,
      init: () => undefined,
      capture: (event: string, props: Record<string, string | number | boolean>) => {
        captured.push({ event, props })
      },
      identify: () => undefined,
      reset: () => undefined,
      register: () => undefined,
      optIn: () => undefined,
      optOut: () => undefined,
    }
    const controller = createAnalyticsController({
      isClient: true,
      config: {
        enabled: true,
        key: 'phc_test',
        host: 'https://eu.i.posthog.com',
        appVersion: '1.0.0',
      },
      adapter,
    })
    if (consent) void controller.setConsent(consent)
    return controller
  }

  test('does not capture before consent', () => {
    const controller = make()
    controller.track(ANALYTICS_EVENTS.MAP_OPENED, {})
    expect(captured).toEqual([])
  })

  test('captures after grant and strips extra properties', async () => {
    const controller = make()
    await controller.setConsent('granted')
    controller.track(ANALYTICS_EVENTS.LOCATION_PERMISSION, { result: 'granted' })
    expect(captured).toHaveLength(1)
    expect(captured[0]?.event).toBe('location_permission')
    expect(captured[0]?.props).toMatchObject({
      result: 'granted',
      platform: 'web',
      auth_state: 'guest',
    })
    expect(captured[0]?.props).not.toHaveProperty('query')
  })

  test('does not consume session keys before consent', async () => {
    const controller = make()
    expect(controller.once('card:home:a')).toBe(false)
    await controller.setConsent('granted')
    expect(controller.once('card:home:a')).toBe(true)
    expect(controller.once('card:home:a')).toBe(false)
  })

  test('stops capture after decline', async () => {
    const controller = make()
    await controller.setConsent('granted')
    await controller.setConsent('declined')
    controller.track(ANALYTICS_EVENTS.MAP_OPENED, {})
    expect(captured).toEqual([])
  })
})
