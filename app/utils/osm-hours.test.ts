import { describe, expect, test } from 'bun:test'
import { parseOsmOpeningHours } from './osm-hours'
import { allDayEveryDay, sameHoursEveryDay } from './hours'

describe('OSM opening_hours', () => {
  test('maps 24/7 to all day', () => {
    expect(parseOsmOpeningHours('24/7')).toEqual({ ok: true, hours: allDayEveryDay() })
  })

  test('maps a simple weekly window', () => {
    expect(parseOsmOpeningHours('Mo-Su 07:00-22:00')).toEqual({
      ok: true,
      hours: sameHoursEveryDay('07:00', '22:00'),
    })
  })

  test('treats 24:00 as midnight and overnight close as 00:00', () => {
    const parsed = parseOsmOpeningHours('Mo-Fr 08:00-24:00; Sa,Su off')
    expect(parsed.ok).toBe(true)
    if (!parsed.ok) return
    expect(parsed.hours.mon).toEqual({ kind: 'open', open: '08:00', close: '00:00' })
    expect(parsed.hours.sat).toEqual({ kind: 'closed' })
  })

  test('overrides Sunday after a full-week rule', () => {
    const parsed = parseOsmOpeningHours('Mo-Su 07:00-22:00; Su off')
    expect(parsed.ok).toBe(true)
    if (!parsed.ok) return
    expect(parsed.hours.sat).toEqual({ kind: 'open', open: '07:00', close: '22:00' })
    expect(parsed.hours.sun).toEqual({ kind: 'closed' })
  })

  test('skips missing, split-shift, and holiday rules', () => {
    expect(parseOsmOpeningHours('')).toEqual({ ok: false, reason: 'missing' })
    expect(parseOsmOpeningHours('Mo 08:00-12:00,13:00-17:00')).toEqual({ ok: false, reason: 'unsupported' })
    expect(parseOsmOpeningHours('Mo-Fr 08:00-17:00; PH off')).toEqual({ ok: false, reason: 'unsupported' })
  })
})
