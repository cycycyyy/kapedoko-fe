import { describe, expect, test } from 'bun:test'
import {
  activeAppTab,
  isAppTabRoute,
  isForeignSurface,
  isOnboardingPath,
  isSameAppPath,
  isVisibleIonPageClass,
  normalizeAppPath,
  pathFromHref,
  resolveAppPath,
  shouldShowAppTabs,
} from './app-tabs'

describe('app tab paths', () => {
  test('does not treat profile as already being home', () => {
    expect(isSameAppPath('/app/profile', '/app')).toBe(false)
    expect(isSameAppPath('/app', '/app')).toBe(true)
    expect(isSameAppPath('/app/', '/app')).toBe(true)
    expect(isSameAppPath('/app/profile?tab=1', '/app/profile')).toBe(true)
  })

  test('reads the active tab without matching /app as a prefix of every page', () => {
    expect(activeAppTab('/app')).toBe('home')
    expect(activeAppTab('/app/')).toBe('home')
    expect(activeAppTab('/app/profile')).toBe('profile')
    expect(activeAppTab('/app/favorites')).toBe('saved')
    expect(activeAppTab('/app/map')).toBe('map')
    expect(activeAppTab('/app/cafes/abc')).toBe('home')
    expect(normalizeAppPath('/app/profile/')).toBe('/app/profile')
  })

  test('shows the shell tab bar only on the four tab roots', () => {
    expect(isAppTabRoute('/app')).toBe(true)
    expect(isAppTabRoute('/app/map')).toBe(true)
    expect(isAppTabRoute('/app/favorites')).toBe(true)
    expect(isAppTabRoute('/app/profile')).toBe(true)
    expect(isAppTabRoute('/app/cafes/abc')).toBe(false)
    expect(isAppTabRoute('/app/onboarding')).toBe(false)
    expect(isAppTabRoute('/login')).toBe(false)
    expect(isAppTabRoute('/admin')).toBe(false)
    expect(isAppTabRoute('/admin/cafes')).toBe(false)
    expect(isAppTabRoute('/admin/audits/new')).toBe(false)
  })

  test('reads Ionic hash paths from the browser location', () => {
    expect(pathFromHref('/#/admin')).toBe('/admin')
    expect(pathFromHref('/app/profile#/admin')).toBe('/admin')
    expect(pathFromHref('/app/profile#/admin/cafes')).toBe('/admin/cafes')
    expect(pathFromHref('http://localhost:3000/#/admin')).toBe('/admin')
    expect(pathFromHref('/app/profile')).toBe('/app/profile')
    expect(isForeignSurface('/admin/cafes')).toBe(true)
    expect(isForeignSurface('/#/admin')).toBe(true)
    expect(isForeignSurface('/app/profile')).toBe(false)
  })

  test('hides the app tab bar on admin even if Profile is still in the stack', () => {
    expect(shouldShowAppTabs('/admin')).toBe(false)
    expect(shouldShowAppTabs('/admin/cafes', '/app/profile')).toBe(false)
    expect(shouldShowAppTabs('/app/profile', '/admin')).toBe(false)
    expect(shouldShowAppTabs('/app/profile', '/#/admin')).toBe(false)
    expect(shouldShowAppTabs('/app/profile', '/app/profile#/admin')).toBe(false)
    expect(shouldShowAppTabs('/app/profile', '/app/map')).toBe(true)
    expect(shouldShowAppTabs('/app', '/app')).toBe(true)
  })

  test('hides the app tab bar on onboarding even if Home is still in the stack', () => {
    expect(isOnboardingPath('/app/onboarding')).toBe(true)
    expect(isOnboardingPath('/#/app/onboarding')).toBe(true)
    expect(shouldShowAppTabs('/app/onboarding')).toBe(false)
    expect(shouldShowAppTabs('/app', '/app/onboarding')).toBe(false)
    expect(shouldShowAppTabs('/app', '/#/app/onboarding')).toBe(false)
    expect(shouldShowAppTabs('/app/onboarding', '/app')).toBe(false)
  })

  test('treats hidden Ionic pages as not the visible admin surface', () => {
    expect(isVisibleIonPageClass('ion-page')).toBe(true)
    expect(isVisibleIonPageClass('ion-page ion-page-hidden')).toBe(false)
    expect(isVisibleIonPageClass('ion-page ion-page-invisible')).toBe(false)
  })

  test('prefers the browser path when Vue and Ionic disagree', () => {
    expect(resolveAppPath('/app/map', '/app/profile')).toBe('/app/profile')
    expect(resolveAppPath('/app/profile', '/app/profile')).toBe('/app/profile')
    expect(resolveAppPath('/app/profile', '')).toBe('/app/profile')
    expect(resolveAppPath('/app/profile', '/#/admin')).toBe('/admin')
  })
})
