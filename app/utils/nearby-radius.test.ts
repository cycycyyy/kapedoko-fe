import { describe, expect, test } from 'bun:test'
import {
  DEFAULT_NEARBY_RADIUS_KM,
  nearbyRadiusMeters,
  normalizeNearbyRadiusKm,
} from './nearby-radius'

describe('nearby radius preference', () => {
  test('defaults invalid values to 5 km', () => {
    expect(normalizeNearbyRadiusKm(undefined)).toBe(DEFAULT_NEARBY_RADIUS_KM)
    expect(normalizeNearbyRadiusKm(null)).toBe(5)
    expect(normalizeNearbyRadiusKm('')).toBe(5)
    expect(normalizeNearbyRadiusKm('7')).toBe(5)
    expect(normalizeNearbyRadiusKm(2)).toBe(5)
    expect(normalizeNearbyRadiusKm(4.9)).toBe(5)
  })

  test('accepts the allowed kilometer presets from numbers or strings', () => {
    expect(normalizeNearbyRadiusKm(1)).toBe(1)
    expect(normalizeNearbyRadiusKm(3)).toBe(3)
    expect(normalizeNearbyRadiusKm(5)).toBe(5)
    expect(normalizeNearbyRadiusKm(10)).toBe(10)
    expect(normalizeNearbyRadiusKm(20)).toBe(20)
    expect(normalizeNearbyRadiusKm('1')).toBe(1)
    expect(normalizeNearbyRadiusKm(' 10 ')).toBe(10)
  })

  test('converts kilometers to meters', () => {
    expect(nearbyRadiusMeters(5)).toBe(5_000)
    expect(nearbyRadiusMeters(1)).toBe(1_000)
    expect(nearbyRadiusMeters(20)).toBe(20_000)
  })
})
