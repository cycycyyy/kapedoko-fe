<template>
  <form class="admin-form" @submit.prevent="onSubmit">
    <div class="admin-panel">
      <CafeIdentityStep
        :name="draft.name"
        :logo-file="draft.logoFile"
        :name-issue="issues.name"
        :logo-issue="issues.logo"
        lede="This cafe is published as soon as you save it. It can sit anywhere, including outside Metro Manila."
        @update:name="draft.name = $event"
        @update:logoFile="draft.logoFile = $event"
      />
      <CafeDetailsStep
        :phone="draft.phone"
        :same-every-day="draft.sameEveryDay"
        :all-day="draft.allDay"
        :open-time="draft.openTime"
        :close-time="draft.closeTime"
        :weekly="draft.weekly"
        :phone-issue="issues.phone"
        :hours-issue="issues.hours"
        @update:phone="draft.phone = $event"
        @update:sameEveryDay="draft.sameEveryDay = $event"
        @update:allDay="draft.allDay = $event"
        @update:openTime="draft.openTime = $event"
        @update:closeTime="draft.closeTime = $event"
        @update:weekly="draft.weekly = $event"
      />
    </div>
    <div class="admin-panel admin-map">
      <ClientOnly>
        <CafeLocationPicker
          unrestricted
          :lat="draft.lat"
          :lng="draft.lng"
          :address="draft.address"
          :address-issue="issues.address || issues.pin"
          @update:lat="draft.lat = $event"
          @update:lng="draft.lng = $event"
          @update:address="draft.address = $event"
        />
      </ClientOnly>
    </div>
    <div class="admin-span admin-row-actions">
      <p v-if="issues.form" class="admin-error" role="alert">{{ issues.form }}</p>
      <button type="submit" class="admin-btn" :disabled="saving">
        {{ saving ? 'Saving…' : submitLabel }}
      </button>
    </div>
  </form>
</template>

<script lang="ts" setup>
import CafeIdentityStep from '~/components/submit/CafeIdentityStep.vue'
import CafeDetailsStep from '~/components/submit/CafeDetailsStep.vue'
import CafeLocationPicker from '~/components/submit/CafeLocationPicker.client.vue'
import type { ShopRow, WeeklyHours } from '~/types/shop'
import { adminCafeErrors } from '~/utils/admin-shop'
import { allDayEveryDay, isValidWeeklyHours, sameHoursEveryDay } from '~/utils/hours'
import { normalizeAddress, normalizeCafeName } from '~/utils/identity'
import { optionalPhone } from '~/utils/phone'
import { DAY_KEYS } from '~/types/shop'

const props = withDefaults(defineProps<{
  shop?: ShopRow | null
  saving?: boolean
  submitLabel?: string
}>(), {
  shop: null,
  saving: false,
  submitLabel: 'Save cafe',
})

const emit = defineEmits<{
  save: [payload: {
    name: string
    address: string
    latitude: number
    longitude: number
    hours: WeeklyHours
    contact_number: string | null
    logoFile: File | null
    logoObjectKey: string | null
  }]
}>()

const hoursFromShop = (hours: WeeklyHours | null | undefined): {
  sameEveryDay: boolean
  allDay: boolean
  openTime: string
  closeTime: string
  weekly: WeeklyHours
} => {
  const weekly = hours && isValidWeeklyHours(hours) ? hours : sameHoursEveryDay('08:00', '20:00')
  const allDay = DAY_KEYS.every((key) => weekly[key].kind === 'all_day')
  const first = weekly.mon
  const sameEveryDay = DAY_KEYS.every((key) => JSON.stringify(weekly[key]) === JSON.stringify(first))
  return {
    weekly,
    allDay,
    sameEveryDay,
    openTime: first.kind === 'open' ? first.open : '08:00',
    closeTime: first.kind === 'open' ? first.close : '20:00',
  }
}

const initial = hoursFromShop(props.shop?.hours)
const draft = reactive({
  name: props.shop?.name ?? '',
  logoFile: null as File | null,
  lat: props.shop?.latitude ?? null as number | null,
  lng: props.shop?.longitude ?? null as number | null,
  address: props.shop?.address ?? '',
  phone: props.shop?.contact_number ?? '',
  sameEveryDay: initial.sameEveryDay,
  allDay: initial.allDay,
  openTime: initial.openTime,
  closeTime: initial.closeTime,
  weekly: initial.weekly,
})

const issues = reactive({
  name: null as string | null,
  logo: null as string | null,
  address: null as string | null,
  pin: null as string | null,
  phone: null as string | null,
  hours: null as string | null,
  form: null as string | null,
})

const onSubmit = () => {
  if (draft.sameEveryDay) {
    draft.weekly = draft.allDay ? allDayEveryDay() : sameHoursEveryDay(draft.openTime, draft.closeTime)
  }
  const next = adminCafeErrors({
    name: draft.name,
    address: draft.address,
    lat: draft.lat,
    lng: draft.lng,
    phone: draft.phone,
    hours: draft.weekly,
    logoFile: draft.logoFile,
  })
  Object.assign(issues, { ...next, form: null })
  if (Object.values(next).some(Boolean) || draft.lat == null || draft.lng == null) return
  emit('save', {
    name: normalizeCafeName(draft.name),
    address: normalizeAddress(draft.address),
    latitude: draft.lat,
    longitude: draft.lng,
    hours: draft.weekly,
    contact_number: optionalPhone(draft.phone),
    logoFile: draft.logoFile,
    logoObjectKey: props.shop?.logo_object_key ?? null,
  })
}
</script>

<style scoped>
.admin-map {
  min-height: 420px;
}
</style>
