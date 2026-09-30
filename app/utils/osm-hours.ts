import { DAY_KEYS, type DayHours, type DayKey, type WeeklyHours } from '../types/shop'
import { allDayEveryDay } from './hours'

const DAY_INDEX: Record<string, number> = {
  mo: 0,
  tu: 1,
  we: 2,
  th: 3,
  fr: 4,
  sa: 5,
  su: 6,
}

const DAY_FROM_INDEX: DayKey[] = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']

export type OsmHoursSkip = 'missing' | 'unsupported'

export type OsmHoursResult =
  | { ok: true; hours: WeeklyHours }
  | { ok: false; reason: OsmHoursSkip }

function closedWeek(): WeeklyHours {
  return {
    mon: { kind: 'closed' },
    tue: { kind: 'closed' },
    wed: { kind: 'closed' },
    thu: { kind: 'closed' },
    fri: { kind: 'closed' },
    sat: { kind: 'closed' },
    sun: { kind: 'closed' },
  }
}

function parseClock(raw: string): string | null {
  const value = raw.trim()
  const match = value.match(/^(\d{1,2}):(\d{2})(?::\d{2})?$/)
  if (!match) return null
  let hour = Number(match[1])
  const minute = Number(match[2])
  if (!Number.isInteger(hour) || !Number.isInteger(minute) || minute > 59) return null
  if (hour === 24 && minute === 0) return '00:00'
  if (hour > 23) return null
  return `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`
}

function parseDayToken(token: string): number | null {
  const key = token.trim().slice(0, 2).toLowerCase()
  return key in DAY_INDEX ? DAY_INDEX[key]! : null
}

function expandDays(spec: string): number[] | null {
  const trimmed = spec.trim()
  if (!trimmed) return DAY_KEYS.map((_, index) => index)
  const days = new Set<number>()
  for (const part of trimmed.split(',')) {
    const range = part.trim()
    if (!range) continue
    if (range.includes('-')) {
      const [startRaw, endRaw] = range.split('-')
      const start = parseDayToken(startRaw ?? '')
      const end = parseDayToken(endRaw ?? '')
      if (start == null || end == null) return null
      if (start <= end) {
        for (let i = start; i <= end; i += 1) days.add(i)
      } else {
        for (let i = start; i <= 6; i += 1) days.add(i)
        for (let i = 0; i <= end; i += 1) days.add(i)
      }
      continue
    }
    const day = parseDayToken(range)
    if (day == null) return null
    days.add(day)
  }
  return [...days]
}

function parseInterval(raw: string): DayHours | 'unsupported' | null {
  const value = raw.trim().toLowerCase()
  if (!value) return null
  if (value === 'off' || value === 'closed') return { kind: 'closed' }
  if (value === 'open' || value === '24/7') return { kind: 'all_day' }

  const times = value.split('-')
  if (times.length !== 2) return 'unsupported'
  const open = parseClock(times[0] ?? '')
  const close = parseClock(times[1] ?? '')
  if (!open || !close) return 'unsupported'
  if (open === close) return { kind: 'all_day' }
  return { kind: 'open', open, close }
}

function applyRule(hours: WeeklyHours, days: number[], next: DayHours): boolean {
  for (const index of days) {
    const key = DAY_FROM_INDEX[index]
    if (!key) return false
    hours[key] = { ...next }
  }
  return true
}

export function parseOsmOpeningHours(value: string | null | undefined): OsmHoursResult {
  const raw = value?.trim() ?? ''
  if (!raw) return { ok: false, reason: 'missing' }
  if (/24\/7/i.test(raw) && !raw.includes(';')) return { ok: true, hours: allDayEveryDay() }
  if (/\b(PH|SH|holiday|easter)\b/i.test(raw)) return { ok: false, reason: 'unsupported' }
  if (raw.includes('||') || raw.includes('[') || raw.includes('month')) {
    return { ok: false, reason: 'unsupported' }
  }

  const hours = closedWeek()
  const assigned = new Set<DayKey>()

  for (const chunk of raw.split(';')) {
    const rule = chunk.trim()
    if (!rule) continue
    if (/^\d{1,2}:\d{2}/.test(rule) && !/\b(Mo|Tu|We|Th|Fr|Sa|Su)\b/i.test(rule)) {
      const interval = parseInterval(rule)
      if (interval == null || interval === 'unsupported') return { ok: false, reason: 'unsupported' }
      if (!applyRule(hours, DAY_KEYS.map((_, index) => index), interval)) {
        return { ok: false, reason: 'unsupported' }
      }
      for (const key of DAY_KEYS) assigned.add(key)
      continue
    }

    const match = rule.match(/^(.*?)(?:\s+|:)(\d{1,2}:\d{2}.*|off|closed|open|24\/7)$/i)
    const daySpec = match ? match[1] : rule
    const timeSpec = match ? match[2] : ''
    if (timeSpec.includes(',') && /\d{1,2}:\d{2}.*,.*\d{1,2}:\d{2}/.test(timeSpec)) {
      return { ok: false, reason: 'unsupported' }
    }
    const days = expandDays(daySpec ?? '')
    if (!days) return { ok: false, reason: 'unsupported' }
    const interval = parseInterval(timeSpec)
    if (interval == null || interval === 'unsupported') return { ok: false, reason: 'unsupported' }
    if (!applyRule(hours, days, interval)) return { ok: false, reason: 'unsupported' }
    for (const index of days) {
      const key = DAY_FROM_INDEX[index]
      if (key) assigned.add(key)
    }
  }

  if (assigned.size === 0) return { ok: false, reason: 'missing' }
  return { ok: true, hours }
}
