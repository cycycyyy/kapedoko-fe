export type ShopStatus = 'pending' | 'approved' | 'rejected'

export type DayKey = 'mon' | 'tue' | 'wed' | 'thu' | 'fri' | 'sat' | 'sun'

export type DayHours =
  | { kind: 'open'; open: string; close: string }
  | { kind: 'closed' }
  | { kind: 'all_day' }

export type WeeklyHours = Record<DayKey, DayHours>

export interface ShopRow {
  id: string
  name: string
  description: string | null
  address: string
  latitude: number
  longitude: number
  categories: string[]
  hours: WeeklyHours | null
  cover_photo_url: string | null
  logo_object_key: string | null
  contact_number: string | null
  status: ShopStatus
  submitted_by: string | null
  reviewed_by: string | null
  reviewed_at: string | null
  rejection_reason: string | null
  created_at: string
  updated_at: string
}

export interface ShopReviewStatsRow {
  shop_id: string
  total_reviews: number
  wifi_yes_count: number | null
  wifi_available_pct: number | null
  wifi_speed_mode: string | null
  wifi_time_limit_mode: string | null
  power_yes_count: number | null
  power_available_pct: number | null
  recommend_pct: number | null
}

export interface ShopInsert {
  name: string
  address: string
  latitude: number
  longitude: number
  hours: WeeklyHours
  contact_number: string | null
  logo_object_key: string | null
  submitted_by: string
  status: 'pending'
}

export const DAY_KEYS: DayKey[] = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']

export const DAY_LABELS: Record<DayKey, string> = {
  mon: 'Monday',
  tue: 'Tuesday',
  wed: 'Wednesday',
  thu: 'Thursday',
  fri: 'Friday',
  sat: 'Saturday',
  sun: 'Sunday',
}
