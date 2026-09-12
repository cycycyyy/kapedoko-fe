import { DAY_KEYS, DAY_LABELS, type DayHours, type DayKey, type WeeklyHours } from '../types/shop'

const TIME_PATTERN = /^([01]\d|2[0-3]):[0-5]\d$/

export function isValidClock(value: string): boolean {
  return TIME_PATTERN.test(value)
}

export function minutesFromClock(value: string): number {
  const [hours, minutes] = value.split(':').map(Number)
  return hours * 60 + minutes
}

export function formatClockLabel(value: string): string {
  if (!isValidClock(value)) return value
  const [hourRaw, minute] = value.split(':')
  const hour = Number(hourRaw)
  const suffix = hour >= 12 ? 'pm' : 'am'
  const hour12 = hour % 12 === 0 ? 12 : hour % 12
  return `${hour12}:${minute}${suffix}`
}

export function sameHoursEveryDay(open: string, close: string): WeeklyHours {
  const day: DayHours = { kind: 'open', open, close }
  return {
    mon: { ...day },
    tue: { ...day },
    wed: { ...day },
    thu: { ...day },
    fri: { ...day },
    sat: { ...day },
    sun: { ...day },
  }
}

export function allDayEveryDay(): WeeklyHours {
  return {
    mon: { kind: 'all_day' },
    tue: { kind: 'all_day' },
    wed: { kind: 'all_day' },
    thu: { kind: 'all_day' },
    fri: { kind: 'all_day' },
    sat: { kind: 'all_day' },
    sun: { kind: 'all_day' },
  }
}

export function isValidDayHours(day: DayHours | null | undefined): boolean {
  if (!day) return false
  if (day.kind === 'closed' || day.kind === 'all_day') return true
  if (day.kind !== 'open') return false
  return isValidClock(day.open) && isValidClock(day.close)
}

export function isValidWeeklyHours(hours: WeeklyHours | null | undefined): boolean {
  if (!hours) return false
  return DAY_KEYS.every((key) => isValidDayHours(hours[key]))
}

export function summarizeHours(hours: WeeklyHours | null | undefined): string {
  if (!hours || !isValidWeeklyHours(hours)) return 'Hours to confirm'

  const first = hours.mon
  const allSame = DAY_KEYS.every((key) => dayEquals(hours[key], first))
  if (allSame) return formatDayHours(first)

  return DAY_KEYS
    .map((key) => `${DAY_LABELS[key].slice(0, 3)} ${formatDayHours(hours[key])}`)
    .join(' · ')
}

export function formatHoursHint(hours: WeeklyHours | null | undefined): string {
  if (!hours) return 'Hours to confirm'
  const today = hours[currentDayKey()]
  if (!today) return 'Hours to confirm'
  if (today.kind === 'all_day') return 'Open 24 hours'
  if (today.kind === 'closed') return 'Closed today'
  return `Opens ${formatClockLabel(today.open)}–${formatClockLabel(today.close)}`
}

export function isOpenNow(
  hours: WeeklyHours | null | undefined,
  now = new Date(),
): boolean {
  if (!hours) return false
  const { day, minutes } = manilaParts(now)
  const today = hours[day]
  if (!today) return false
  if (today.kind === 'all_day') return true
  if (today.kind === 'closed') {
    return isOvernightCarry(hours, now)
  }

  const open = minutesFromClock(today.open)
  const close = minutesFromClock(today.close)

  if (open === close) return true
  if (close > open) return minutes >= open && minutes < close

  if (minutes >= open) return true
  return isOvernightCarry(hours, now)
}

function isOvernightCarry(hours: WeeklyHours, now: Date): boolean {
  const yesterday = hours[manilaParts(new Date(now.getTime() - 86_400_000)).day]
  if (!yesterday || yesterday.kind !== 'open') return false
  const open = minutesFromClock(yesterday.open)
  const close = minutesFromClock(yesterday.close)
  if (close >= open) return false
  return manilaParts(now).minutes < close
}

export function currentDayKey(now = new Date()): DayKey {
  return manilaParts(now).day
}

function manilaParts(date: Date): { day: DayKey; minutes: number } {
  const parts = Object.fromEntries(
    new Intl.DateTimeFormat('en-US', {
      timeZone: 'Asia/Manila',
      weekday: 'short',
      hour: '2-digit',
      minute: '2-digit',
      hourCycle: 'h23',
    })
      .formatToParts(date)
      .map((part) => [part.type, part.value]),
  )

  const weekday = String(parts.weekday ?? 'Mon').slice(0, 3).toLowerCase()
  const day = (['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'].includes(weekday)
    ? weekday
    : 'mon') as DayKey
  const hour = Number.parseInt(parts.hour ?? '0', 10)
  const minute = Number.parseInt(parts.minute ?? '0', 10)
  return { day, minutes: hour * 60 + minute }
}

function formatDayHours(day: DayHours): string {
  if (day.kind === 'all_day') return 'Open 24 hours'
  if (day.kind === 'closed') return 'Closed'
  return `${formatClockLabel(day.open)}–${formatClockLabel(day.close)}`
}

function dayEquals(a: DayHours, b: DayHours): boolean {
  if (a.kind !== b.kind) return false
  if (a.kind === 'open' && b.kind === 'open') {
    return a.open === b.open && a.close === b.close
  }
  return true
}
