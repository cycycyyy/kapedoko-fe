<template>
  <IonPage>
    <IonContent class="search-content">
      <div class="search">
        <header class="search-hero">
          <img
            src="/assets/home-watermark.png"
            alt=""
            class="search-hero__watermark"
          />

          <div class="search-hero__bar">
            <button
              type="button"
              class="search-hero__back"
              aria-label="Back to Home"
              @click="goBack"
            >
              <ChevronLeft :size="24" :stroke-width="2" />
            </button>
            <h1>Search shops</h1>
          </div>

          <form class="search-form" @submit.prevent="submitSearch">
            <label class="search-form__field">
              <span class="sr-only">Search a coffee shop</span>
              <input
                v-model="query"
                type="search"
                name="q"
                placeholder="Search a coffee shop"
                autocomplete="off"
                enterkeyhint="search"
              />
            </label>

            <button type="submit" class="search-form__submit" aria-label="Search">
              <Search :size="24" :stroke-width="2" />
            </button>
          </form>
        </header>

        <p class="sr-only" aria-live="polite">
          {{ resultAnnouncement }}
        </p>

        <Transition name="search-list" mode="out-in">
          <section :key="listKey" class="search-results" aria-label="Search results">
            <p v-if="status === 'idle' || status === 'loading'" class="search-end">Loading coffee shops…</p>
            <p v-else-if="status === 'error'" class="search-end">
              {{ error || 'Could not load coffee shops.' }}
              <button type="button" class="search-retry" @click="refresh">Try again</button>
            </p>
            <CafeCard
              v-for="cafe in visibleCafes"
              v-else
              :key="cafe.id"
              :cafe="cafe"
              :distance-label="distanceLabel(cafe)"
              @select="openCafe"
            />

            <div
              v-if="status === 'ready'"
              class="search-end"
              :class="{ 'is-empty': visibleCafes.length === 0 }"
            >
              <Coffee :size="36" :stroke-width="1.5" aria-hidden="true" />
              <p>{{ endCopy }}</p>
            </div>
          </section>
        </Transition>
      </div>
    </IonContent>
  </IonPage>
</template>

<script lang="ts" setup>
import { onIonViewWillEnter } from '@ionic/vue'
import { ChevronLeft, Coffee, Search } from 'lucide-vue-next'
import CafeCard from '~/components/cafe/CafeCard.vue'
import type { Cafe } from '~/types/cafe'
import { filterCafes } from '~/utils/cafe-filters'
import { distanceMeters, formatDistance } from '~/utils/geo'

const { cafes, status, error, refresh } = useApprovedShops()
const { status: locationStatus, location, usingFallback, requestLocation } = useDeviceLocation()

const route = useRoute()
const requestURL = useRequestURL()
const query = ref('')
const submittedQuery = ref('')

const readQueryParam = (value: unknown) => {
  if (typeof value === 'string') return value
  if (Array.isArray(value) && typeof value[0] === 'string') return value[0]
  return ''
}

const queryFromLocation = () => {
  if (import.meta.client) {
    const fromWindow = new URLSearchParams(window.location.search).get('q')
    if (fromWindow) return fromWindow
  }

  try {
    const fromRequest = new URL(requestURL.href).searchParams.get('q')
    if (fromRequest) return fromRequest
  } catch {
    /* ignore invalid URL */
  }

  return readQueryParam(route.query.q)
}

const syncFromRoute = () => {
  const next = queryFromLocation()
  query.value = next
  submittedQuery.value = next
}

syncFromRoute()

watch(() => route.fullPath, syncFromRoute)
onIonViewWillEnter(syncFromRoute)
onMounted(syncFromRoute)

const listKey = computed(() => submittedQuery.value.trim().toLowerCase())

const origin = computed(() => (
  locationStatus.value === 'granted' && location.value && !usingFallback.value
    ? location.value
    : null
))

const visibleCafes = computed(() => filterCafes(cafes.value, {
  query: submittedQuery.value,
  origin: origin.value,
}))

const distanceLabel = (cafe: Cafe) => {
  if (!origin.value) return undefined
  return formatDistance(distanceMeters(origin.value, cafe))
}

const openCafe = async (id: string) => {
  await navigateTo(`/app/cafes/${id}`)
}

const resultAnnouncement = computed(() => {
  const count = visibleCafes.value.length
  if (count === 0) return 'No coffee shops match that search.'
  return count === 1 ? '1 coffee shop found.' : `${count} coffee shops found.`
})

const endCopy = 'No coffee beans left'

const submitSearch = async () => {
  const next = query.value.trim()
  submittedQuery.value = query.value

  const path = next ? `/app/search?q=${encodeURIComponent(next)}` : '/app/search'

  await navigateTo(path, { replace: true })
}

const goBack = async () => {
  await navigateTo('/app')
}

onMounted(() => {
  void requestLocation()
})
</script>

<style scoped>
.search-content {
  --background: var(--kd-white);
  --padding-start: 0;
  --padding-end: 0;
  --padding-top: 0;
  --padding-bottom: 0;
}

.search-content :deep(.inner-scroll) {
  display: flex;
  flex-direction: column;
  min-height: 100%;
}

.search {
  display: flex;
  flex: 1 1 auto;
  flex-direction: column;
  min-height: 100%;
  background: var(--kd-white);
  padding-bottom: calc(2rem + env(safe-area-inset-bottom));
  container-type: inline-size;
  container-name: search;
}

.search-hero {
  position: sticky;
  top: 0;
  z-index: 2;
  overflow: hidden;
  background: var(--kd-primary);
  color: var(--kd-white);
  padding: max(2.75rem, calc(env(safe-area-inset-top) + 16px)) 20px 20px;
}

.search-hero__watermark {
  position: absolute;
  top: -15px;
  right: -9px;
  width: 199px;
  height: 259px;
  pointer-events: none;
  user-select: none;
}

.search-hero__bar {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  gap: 10px;
  min-height: 30px;
}

.search-hero__back {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  margin-left: -10px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-white);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.search-hero__back:focus-visible {
  outline: 2px solid var(--kd-white);
  outline-offset: 2px;
  border-radius: 8px;
}

.search-hero h1 {
  margin: 0;
  color: var(--kd-white);
  font-size: 24px;
  font-weight: 700;
  line-height: 1.2;
}

.search-form {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: stretch;
  flex-wrap: nowrap;
  gap: 9px;
  margin-top: 21px;
}

.search-form__field {
  display: flex;
  align-items: center;
  flex: 1;
  min-width: 0;
  height: 50px;
  padding: 0 16px;
  border-radius: 8px;
  background: var(--kd-white);
  color: var(--kd-ink);
}

.search-form__field input {
  width: 100%;
  border: 0;
  background: transparent;
  color: var(--kd-ink);
  font-size: 12px;
  font-family: inherit;
  caret-color: var(--kd-primary);
}

.search-form__field input::-webkit-search-decoration,
.search-form__field input::-webkit-search-cancel-button {
  -webkit-appearance: none;
}

.search-form__field input::placeholder {
  color: var(--kd-ink-50);
}

.search-form__field input:focus {
  outline: none;
}

.search-form__field:focus-within {
  box-shadow: 0 0 0 2px var(--kd-white), 0 0 0 4px var(--kd-primary);
}

.search-form__submit {
  display: grid;
  place-items: center;
  flex: 0 0 63px;
  width: 63px;
  height: 50px;
  padding: 0;
  border: 0;
  border-radius: 8px;
  background: var(--kd-white);
  color: var(--kd-black);
  line-height: 0;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: opacity 140ms cubic-bezier(0.16, 1, 0.3, 1),
    transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.search-form__submit :deep(svg) {
  display: block;
}

.search-form__submit:focus-visible {
  outline: 2px solid var(--kd-white);
  outline-offset: 2px;
}

.search-results {
  display: flex;
  flex-direction: column;
  flex: 1 1 auto;
  gap: 14px;
  padding: 20px 20px 0;
}

.cafe-card {
  display: flex;
  min-height: 100px;
  border-radius: 8px;
  background: var(--kd-white);
  box-shadow: 0 0 8px var(--kd-shadow);
  transition: transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.cafe-card__photo {
  width: 90px;
  height: 100px;
  flex-shrink: 0;
  overflow: hidden;
  border-radius: 8px 0 0 8px;
  background: var(--kd-secondary);
}

.cafe-card__photo img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.cafe-card__photo.is-broken img {
  display: none;
}

.cafe-card__body {
  flex: 1;
  min-width: 0;
  padding: 11px 13px 10px 15px;
}

.cafe-card__meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.cafe-card__stars {
  display: flex;
  flex-shrink: 0;
  gap: 2px;
  color: var(--kd-black);
}

.cafe-card__status {
  margin: 0;
  min-width: 0;
  flex: 1 1 auto;
  overflow: hidden;
  font-size: 10px;
  font-weight: 700;
  line-height: 1.2;
  text-align: right;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.cafe-card__status.is-open {
  color: var(--kd-success);
}

.cafe-card__status.is-closed {
  color: var(--kd-destructive);
}

.cafe-card h2 {
  margin: 3px 0 0;
  overflow: hidden;
  color: var(--kd-ink);
  font-size: 16px;
  font-weight: 700;
  line-height: 1.375;
  white-space: nowrap;
  text-overflow: ellipsis;
}

.cafe-card__address {
  margin: 0;
  overflow: hidden;
  color: var(--kd-ink-50);
  font-size: 12px;
  line-height: 1.35;
  white-space: nowrap;
  text-overflow: ellipsis;
}

.cafe-card__amenities,
.cafe-card__none {
  display: flex;
  align-items: center;
  gap: 3px;
  margin: 8px 0 0;
  color: var(--kd-ink);
}

.cafe-card__none {
  color: var(--kd-ink-25);
  font-size: 10px;
  font-style: italic;
}

.search-end {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 28px 12px 12px;
  color: var(--kd-gray);
}

.search-end.is-empty {
  flex: 1 1 auto;
  justify-content: center;
  padding: 12px;
}

.search-retry {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  margin-top: 8px;
  padding: 0 16px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-primary);
  color: var(--kd-white);
  font-size: 14px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
}

.search-end p {
  margin: 0;
  font-size: 12px;
  line-height: 1.35;
  text-align: center;
}

.search-hero__back:active,
.search-form__submit:active {
  transform: scale(0.94);
}

.cafe-card:active {
  transform: scale(0.99);
}

.search-list-enter-active,
.search-list-leave-active {
  transition: opacity 160ms cubic-bezier(0.16, 1, 0.3, 1);
}

.search-list-enter-from,
.search-list-leave-to {
  opacity: 0;
}

.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

@media (hover: hover) {
  .search-form__submit:hover {
    opacity: 0.92;
  }
}

@media (min-width: 540px) {
  .search {
    max-width: 480px;
    margin-inline: auto;
  }
}

@media (prefers-reduced-motion: reduce) {
  .search-hero__back,
  .search-form__submit,
  .cafe-card,
  .search-list-enter-active,
  .search-list-leave-active {
    transition-duration: 1ms;
  }

  .search-hero__back:active,
  .search-form__submit:active,
  .cafe-card:active {
    transform: none;
  }
}

::selection {
  background: var(--kd-secondary);
  color: var(--kd-primary);
}
</style>
