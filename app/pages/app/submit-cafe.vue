<template>
  <IonPage>
    <IonContent :scroll-y="!isMapStep" class="submit-content">
      <div
        class="submit"
        :class="{ 'is-map': isMapStep, 'is-done': submitted }"
      >
        <div v-if="isMapStep" class="submit__ground" aria-hidden="true" />

        <header class="submit__chrome">
          <div class="submit__bar">
            <button type="button" class="submit__back" :aria-label="backLabel" @click="goBack">
              <ChevronLeft :size="22" :stroke-width="2.25" />
            </button>
            <div class="submit__heading">
              <h1>{{ submitted ? 'Pending review' : 'Add a cafe' }}</h1>
              <p v-if="!submitted">{{ stepLabel }}</p>
            </div>
            <div v-if="!submitted" class="submit__ticks" aria-hidden="true">
              <span v-for="n in 3" :key="n" :class="{ 'is-on': n <= displayStep }" />
            </div>
          </div>
        </header>

        <div v-if="submitted" class="submit__body">
          <section class="submit__sheet" aria-labelledby="done-title">
            <h2 id="done-title">{{ savedName }} is in the queue</h2>
            <p>
              It stays off Home and Map until an admin approves it. You can close this and keep looking for a place to sit.
            </p>
          </section>
          <div class="submit__dock">
            <button type="button" class="submit__cta" @click="goHome">Back to Home</button>
          </div>
        </div>

        <form v-else class="submit__form" @submit.prevent="onPrimary">
          <ClientOnly v-if="isMapStep">
            <CafeLocationPicker
              overlay
              :lat="draft.lat"
              :lng="draft.lng"
              :address="draft.address"
              :address-issue="issues.address"
              @update:lat="draft.lat = $event"
              @update:lng="draft.lng = $event"
              @update:address="draft.address = $event"
            />
          </ClientOnly>

          <div v-else class="submit__sheet">
            <CafeIdentityStep
              v-if="step === 1 && !reviewing"
              :name="draft.name"
              :logo-file="draft.logoFile"
              :name-issue="issues.name"
              :logo-issue="issues.logo"
              @update:name="draft.name = $event"
              @update:logoFile="draft.logoFile = $event"
            />

            <CafeDetailsStep
              v-else-if="step === 3 && !reviewing"
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

            <section v-else class="submit__review" aria-labelledby="review-title">
              <h2 id="review-title">Check this listing</h2>
              <p>
                Submit now to save it as pending. It will not show on Home or Map until it is approved.
              </p>
              <article class="submit__listing">
                <div class="submit__listing-mark">
                  <img
                    :src="logoPreview || '/assets/kapedoko-logo_dark.png'"
                    :alt="logoPreview ? '' : 'KapeDoko mark'"
                    :class="{ 'is-mark': !logoPreview }"
                    width="90"
                    height="100"
                  />
                </div>
                <div class="submit__listing-body">
                  <p class="submit__pending">Pending review</p>
                  <h3>{{ normalizeCafeName(draft.name) }}</h3>
                  <p>{{ normalizeAddress(draft.address) }}</p>
                  <p>{{ summarizeHours(draft.weekly) }}</p>
                  <p>{{ draft.phone.trim() || 'No phone added' }}</p>
                </div>
              </article>
            </section>
          </div>

          <p v-if="issues.form" class="submit__error" role="alert">{{ issues.form }}</p>

          <div class="submit__dock">
            <button type="submit" class="submit__cta" :disabled="submitting">
              {{ primaryLabel }}
            </button>
          </div>
        </form>
      </div>
    </IonContent>
  </IonPage>
</template>

<script lang="ts" setup>
import { ChevronLeft } from 'lucide-vue-next'
import { Capacitor } from '@capacitor/core'
import { useIonRouter } from '@ionic/vue'
import CafeIdentityStep from '~/components/submit/CafeIdentityStep.vue'
import CafeLocationPicker from '~/components/submit/CafeLocationPicker.client.vue'
import CafeDetailsStep from '~/components/submit/CafeDetailsStep.vue'
import { allDayEveryDay, isValidWeeklyHours, sameHoursEveryDay, summarizeHours } from '~/utils/hours'
import { addressError, cafeNameError, normalizeAddress, normalizeCafeName } from '~/utils/identity'
import { isInMarikina } from '~/utils/marikina'
import { isValidPhone } from '~/utils/phone'
import { logoFileError } from '~/utils/logo'
import type { WeeklyHours } from '~/types/shop'

const ionRouter = useIonRouter()
const { submitShop, submitting } = useShopSubmission()

const step = ref(1)
const reviewing = ref(false)
const submitted = ref(false)
const savedName = ref('')
const logoPreview = ref<string | null>(null)
const allowLeave = ref(false)

const onHardwareBack = (event: Event) => {
  const register = (event as CustomEvent<{ register: (priority: number, handler: () => void) => void }>).detail?.register
  if (!register) return
  register(20, () => {
    void goBack()
  })
}

const draft = reactive({
  name: '',
  logoFile: null as File | null,
  lat: null as number | null,
  lng: null as number | null,
  address: '',
  phone: '',
  sameEveryDay: true,
  allDay: false,
  openTime: '08:00',
  closeTime: '20:00',
  weekly: sameHoursEveryDay('08:00', '20:00') as WeeklyHours,
})

const issues = reactive({
  name: null as string | null,
  logo: null as string | null,
  address: null as string | null,
  phone: null as string | null,
  hours: null as string | null,
  form: null as string | null,
})

const isMapStep = computed(() => step.value === 2 && !reviewing.value && !submitted.value)
const displayStep = computed(() => (reviewing.value ? 3 : step.value))
const stepLabel = computed(() => {
  if (reviewing.value) return '4 of 4 · Check'
  if (step.value === 1) return '1 of 4 · Name'
  if (step.value === 2) return '2 of 4 · Pin'
  return '3 of 4 · Hours'
})
const backLabel = computed(() => (submitted.value ? 'Back to Home' : 'Go back'))
const primaryLabel = computed(() => {
  if (submitting.value) return 'Saving…'
  if (reviewing.value) return 'Submit cafe'
  if (step.value === 3) return 'Review'
  return 'Continue'
})

const clearIssues = () => {
  issues.name = null
  issues.logo = null
  issues.address = null
  issues.phone = null
  issues.hours = null
  issues.form = null
}

const validateIdentity = () => {
  issues.name = cafeNameError(draft.name)
  issues.logo = logoFileError(draft.logoFile)
  return !issues.name && !issues.logo
}

const validateLocation = () => {
  issues.address = addressError(draft.address)
  if (draft.lat == null || draft.lng == null || !isInMarikina({ lat: draft.lat, lng: draft.lng })) {
    issues.address = issues.address || 'Pin the cafe inside Marikina.'
  }
  return !issues.address
}

const validateDetails = () => {
  issues.phone = draft.phone.trim() && !isValidPhone(draft.phone)
    ? 'Use a phone number like 0917 123 4567.'
    : null
  if (draft.sameEveryDay) {
    draft.weekly = draft.allDay
      ? allDayEveryDay()
      : sameHoursEveryDay(draft.openTime, draft.closeTime)
  }
  issues.hours = isValidWeeklyHours(draft.weekly) ? null : 'Add opening and closing hours, or mark a day closed.'
  return !issues.phone && !issues.hours
}

const onPrimary = async () => {
  issues.form = null

  if (!reviewing.value && step.value === 1) {
    if (validateIdentity()) step.value = 2
    return
  }

  if (!reviewing.value && step.value === 2) {
    if (validateLocation()) step.value = 3
    return
  }

  if (!reviewing.value && step.value === 3) {
    if (validateDetails()) reviewing.value = true
    return
  }

  if (!validateIdentity() || !validateLocation() || !validateDetails()) {
    reviewing.value = false
    if (issues.name || issues.logo) step.value = 1
    else if (issues.address) step.value = 2
    else step.value = 3
    return
  }

  if (draft.lat == null || draft.lng == null) return

  try {
    const row = await submitShop({
      name: draft.name,
      address: draft.address,
      lat: draft.lat,
      lng: draft.lng,
      phone: draft.phone,
      hours: draft.weekly,
      logoFile: draft.logoFile,
    })
    savedName.value = row.name
    submitted.value = true
  } catch (err) {
    issues.form = err instanceof Error ? err.message : 'Could not save this cafe. Try again.'
  }
}

const goHome = async () => {
  allowLeave.value = true
  await navigateTo('/app')
}

const goBack = async () => {
  if (submitted.value) {
    await goHome()
    return
  }
  if (reviewing.value) {
    reviewing.value = false
    return
  }
  if (step.value > 1) {
    step.value -= 1
    return
  }
  allowLeave.value = true
  if (ionRouter.canGoBack()) {
    ionRouter.back()
    return
  }
  await goHome()
}

onBeforeRouteLeave((_to, _from, next) => {
  if (allowLeave.value || submitted.value) {
    next()
    return
  }
  if (reviewing.value || step.value > 1) {
    void goBack()
    next(false)
    return
  }
  next()
})

watch(
  () => [draft.name, draft.logoFile, draft.address, draft.phone, draft.openTime, draft.closeTime, draft.weekly],
  () => clearIssues(),
)

watch(
  () => draft.logoFile,
  (file) => {
    if (logoPreview.value) URL.revokeObjectURL(logoPreview.value)
    logoPreview.value = file ? URL.createObjectURL(file) : null
  },
)

onBeforeUnmount(() => {
  if (logoPreview.value) URL.revokeObjectURL(logoPreview.value)
  document.removeEventListener('ionBackButton', onHardwareBack)
})

onMounted(() => {
  if (Capacitor.getPlatform() === 'android') {
    document.documentElement.classList.add('is-android')
  }
  document.addEventListener('ionBackButton', onHardwareBack)
})
</script>

<style scoped>
.submit-content {
  --background: var(--kd-secondary);
  --padding-start: 0;
  --padding-end: 0;
  --padding-top: 0;
  --padding-bottom: 0;
}

.submit-content :deep(.inner-scroll),
.submit-content :deep(.scroll-y) {
  height: 100%;
}

.submit {
  display: flex;
  flex-direction: column;
  min-height: 100%;
  background: var(--kd-secondary);
}

.submit.is-map {
  position: relative;
  height: 100%;
  min-height: 100%;
  overflow: hidden;
}

.submit__ground {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(circle at 18% 24%, color-mix(in srgb, var(--kd-white) 55%, transparent), transparent 36%),
    linear-gradient(180deg, var(--kd-white) 0%, var(--kd-secondary) 42%);
}

.submit__chrome {
  position: relative;
  z-index: 3;
  flex-shrink: 0;
  padding: max(2.75rem, calc(env(safe-area-inset-top) + 16px)) 20px 18px;
  background: linear-gradient(180deg, var(--kd-white) 0%, color-mix(in srgb, var(--kd-white) 0%, transparent) 100%);
}

.submit.is-map .submit__chrome {
  position: absolute;
  inset: 0 0 auto;
  pointer-events: none;
}

.submit.is-map .submit__back,
.submit.is-map .submit__heading,
.submit.is-map .submit__ticks {
  pointer-events: auto;
}

.submit__bar {
  display: flex;
  align-items: center;
  gap: 10px;
  min-height: 44px;
}

.submit__back {
  display: grid;
  place-items: center;
  flex: 0 0 44px;
  width: 44px;
  height: 44px;
  margin-left: -12px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-primary);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.submit__heading {
  min-width: 0;
  flex: 1;
}

.submit__heading h1 {
  margin: 0;
  color: var(--kd-primary);
  font-size: 16px;
  font-weight: 700;
  line-height: 1.2;
}

.submit__heading p {
  margin: 4px 0 0;
  color: var(--kd-ink);
  font-size: 12px;
  font-weight: 400;
  line-height: 1.2;
}

.submit__ticks {
  display: flex;
  flex: 0 0 auto;
  align-items: center;
  gap: 5px;
  width: 64px;
}

.submit__ticks span {
  flex: 1;
  height: 5px;
  border-radius: 999px;
  background: var(--kd-placeholder);
}

.submit__ticks span.is-on {
  background: var(--kd-primary);
}

.submit__form,
.submit__body {
  display: flex;
  flex-direction: column;
  flex: 1;
  min-height: 0;
}

.submit.is-map .submit__form {
  height: 100%;
}

.submit__sheet {
  margin: 0 20px;
  padding: 20px;
  overflow: auto;
  border-radius: 8px;
  background: var(--kd-white);
  box-shadow: 0 2px 8px var(--kd-shadow);
}

.submit__review h2,
.submit__sheet h2 {
  margin: 0;
  color: var(--kd-primary);
  font-size: 20px;
  font-weight: 700;
  line-height: 1.2;
}

.submit__review p,
.submit__sheet > p {
  margin: 8px 0 0;
  color: var(--kd-ink);
  font-size: 12px;
  line-height: 1.35;
}

.submit__listing {
  display: flex;
  gap: 12px;
  min-height: 100px;
  margin-top: 16px;
}

.submit__listing-mark {
  flex: 0 0 90px;
  width: 90px;
  height: 100px;
  overflow: hidden;
  border-radius: 8px;
  background:
    radial-gradient(
      circle at 50% 32%,
      color-mix(in srgb, var(--kd-white) 78%, transparent) 0%,
      transparent 58%
    ),
    var(--kd-secondary);
}

.submit__listing-mark img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.submit__listing-mark img.is-mark {
  object-fit: contain;
  padding: 10px;
}

.submit__listing-body {
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.submit__pending {
  margin: 0;
  color: var(--kd-primary);
  font-size: 12px;
  font-weight: 700;
  line-height: 1.2;
}

.submit__listing-body h3 {
  margin: 0;
  color: var(--kd-primary);
  font-size: 16px;
  font-weight: 700;
  line-height: 1.375;
}

.submit__listing-body p {
  margin: 0;
  color: var(--kd-ink);
  font-size: 12px;
  line-height: 1.35;
}

.submit__error {
  margin: 10px 20px 0;
  color: var(--kd-closed);
  font-size: 12px;
  font-weight: 700;
}

.submit.is-map .submit__error {
  position: relative;
  z-index: 3;
  margin: 0 20px 8px;
}

.submit__dock {
  margin-top: auto;
  padding: 16px 20px calc(16px + env(safe-area-inset-bottom));
}

.submit.is-map .submit__dock {
  position: relative;
  z-index: 3;
  margin-top: 0;
  padding: 4px 20px calc(16px + env(safe-area-inset-bottom));
  background: var(--kd-white);
}

.submit__cta {
  width: 100%;
  height: 45px;
  min-height: 45px;
  padding: 0 20px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-primary);
  color: var(--kd-white);
  font-size: 16px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.submit__cta:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.submit__back:focus-visible,
.submit__cta:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
  border-radius: 8px;
}

.submit__cta:focus-visible {
  outline-color: var(--kd-white);
  box-shadow: 0 0 0 4px var(--kd-primary);
}

.submit__back:active,
.submit__cta:active {
  transform: scale(0.96);
}

:root.is-android .submit__cta {
  height: 48px;
  min-height: 48px;
}

@media (min-width: 540px) {
  .submit {
    max-width: 480px;
    margin-inline: auto;
  }
}

@media (hover: hover) and (pointer: fine) {
  .submit__cta:hover:not(:disabled) {
    filter: brightness(1.06);
  }
}

@media (prefers-reduced-motion: reduce) {
  .submit__back:active,
  .submit__cta:active {
    transform: none;
  }
}

::selection {
  background: var(--kd-secondary);
  color: var(--kd-primary);
}
</style>
