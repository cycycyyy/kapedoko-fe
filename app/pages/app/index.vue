<template>
  <IonPage>
    <IonContent class="home-content">
      <div class="home">
        <div class="home-plate">
        <header class="home-chrome">
          <div class="home-chrome__greeting">
            <p class="home-chrome__hello">{{ greeting }}</p>
            <p v-if="firstName" class="home-chrome__name">{{ firstName }}</p>
          </div>
          <img
            src="/assets/kapedoko-horizontal-text_dark.png"
            alt="kapé DOKO"
            width="168"
            height="36"
            class="home-chrome__wordmark"
          />
        </header>

          <form class="home-search" @submit.prevent="submitSearch">
            <label class="home-search__field">
              <Search :size="18" :stroke-width="2.25" aria-hidden="true" />
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
          </form>

        <section
          v-if="homeAds.length > 0"
          class="home-partners"
          :aria-label="usingLiveAds ? 'Featured banners' : 'Featured cafes'"
        >
          <div class="home-partners__track" role="list">
            <button
              v-for="(ad, index) in homeAds"
              :key="ad.id"
              type="button"
              class="home-partners__card"
              :class="ad.kind === 'ad'
                ? 'home-partners__card--sponsored'
                : ad.kind === 'promoted'
                  ? 'home-partners__card--sponsored'
                  : 'home-partners__card--partner'"
              role="listitem"
              :aria-label="ad.ariaLabel"
              @click="openCafe(ad.shopId)"
            >
              <span class="home-partners__media">
                <img
                  class="home-partners__image"
                  :src="ad.image"
                  alt=""
                  width="108"
                  height="128"
                />
                <span class="home-partners__badge">{{ ad.badge }}</span>
              </span>
              <span class="home-partners__copy" aria-hidden="true">
                <span class="home-partners__name">{{ ad.name }}</span>
                <span v-if="ad.place" class="home-partners__place">{{ ad.place }}</span>
                <span v-if="homeAds.length > 1" class="home-partners__index">
                  {{ index + 1 }} of {{ homeAds.length }}
                </span>
              </span>
            </button>
          </div>
        </section>

        <div class="home-filters" role="tablist" aria-label="Cafe filters">
          <button
            v-for="filter in filters"
            :key="filter.id"
            type="button"
            role="tab"
            class="home-filters__chip"
            :class="{ 'is-active': activeFilter === filter.id }"
            :aria-selected="activeFilter === filter.id"
            @click="setFilter(filter.id)"
          >
            <component :is="filterIcons[filter.icon]" :size="14" :stroke-width="2.25" aria-hidden="true" />
            {{ filter.label }}
          </button>
        </div>

        <p v-if="status === 'ready'" class="home-state">
          <component :is="filterIcons[activeFilterMeta.icon]" :size="14" :stroke-width="2.25" aria-hidden="true" />
          <span>{{ activeFilterMeta.label }}</span>
          <span aria-hidden="true">·</span>
          <span>{{ shopCountLabel }}</span>
          <template v-if="locationNote">
            <span aria-hidden="true">·</span>
            <span>{{ locationNote }}</span>
          </template>
        </p>

        <Transition name="cafe-list" mode="out-in">
          <section :key="listKey" class="home-list" aria-label="Cafes">
            <div v-if="status === 'idle' || status === 'loading'" class="home-skeletons" aria-busy="true">
              <p class="sr-only">Loading coffee shops…</p>
              <span class="home-skeleton" />
              <span class="home-skeleton" />
              <span class="home-skeleton" />
            </div>
            <p v-else-if="status === 'error'" class="home-empty">
              <CircleAlert :size="18" :stroke-width="2.25" aria-hidden="true" />
              <span>{{ error || 'Could not load coffee shops.' }}</span>
              <button type="button" class="home-retry" @click="refresh">
                <RefreshCw :size="16" :stroke-width="2.25" aria-hidden="true" />
                Try again
              </button>
            </p>
            <p v-else-if="visibleCafes.length === 0" class="home-empty">
              <Coffee :size="18" :stroke-width="2.25" aria-hidden="true" />
              <span>{{ emptyCopy }}</span>
            </p>

            <CafeCard
              v-for="(cafe, index) in pagedCafes"
              :key="cafe.id"
              :cafe="cafe"
              :distance-label="distanceLabel(cafe)"
              :style="{ '--enter': String(index % 12) }"
              @select="openCafe"
            />
            <p v-if="hasMoreCafes" ref="moreCafes" class="home-more">Scroll for more</p>
          </section>
        </Transition>

        <button type="button" class="home-add" @click="addCafe">
          <Plus :size="18" :stroke-width="2.25" aria-hidden="true" />
          Add a cafe
        </button>
        </div>
      </div>
    </IonContent>

    <AppTabBar active="home" />
  </IonPage>
</template>

<script lang="ts" setup>
import { Capacitor } from '@capacitor/core'
import { onIonViewWillEnter } from '@ionic/vue'
import { BatteryCharging, CircleAlert, Coffee, Flame, Hourglass, Navigation, Plug, Plus, RefreshCw, Search, Wifi, Zap } from 'lucide-vue-next'
import CafeCard from '~/components/cafe/CafeCard.vue'
import AppTabBar from '~/components/navigation/AppTabBar.vue'
import type { Cafe } from '~/types/cafe'
import { featuredAdCopy } from '~/utils/admin-ads'
import { CAFE_FILTERS, filterCafes, type CafeFilterIcon, type CafeFilterId } from '~/utils/cafe-filters'
import { distanceMeters, formatDistance } from '~/utils/geo'

const filterIcons: Record<CafeFilterIcon, typeof Navigation> = {
  navigation: Navigation,
  flame: Flame,
  wifi: Wifi,
  plug: Plug,
  hourglass: Hourglass,
  zap: Zap,
  'battery-charging': BatteryCharging,
}

const filters = CAFE_FILTERS

const { cafes: liveCafes, status, error, refresh } = useApprovedShops()
const { ads: liveAds } = useActiveAds()
const { status: locationStatus, location, usingFallback, requestLocation } = useDeviceLocation()
const { radiusKm: nearbyRadiusKm, radiusMeters, hydrate: hydrateNearbyRadius } = useNearbyRadius()
const { user, loadProfile } = useAuth()
const cafes = computed(() => liveCafes.value)

const query = ref('')
const submittedQuery = ref('')
const activeFilter = ref<CafeFilterId>('near')
const greeting = ref('Good morning')
const firstName = ref('')

const placementCafes = computed(() => {
  const promoted = cafes.value.filter((cafe) => cafe.markerTier === 'promoted')
  const partners = cafes.value.filter((cafe) => cafe.markerTier === 'partner')
  return [...promoted, ...partners]
})

const usingLiveAds = computed(() => liveAds.value.length > 0)

const homeAds = computed(() => {
  if (usingLiveAds.value) {
    return liveAds.value.map((ad, index) => {
      const copy = featuredAdCopy(ad.name, ad.label)
      return {
        id: ad.id,
        shopId: ad.shopId,
        name: copy.name,
        place: copy.place,
        image: ad.image,
        badge: 'Ad',
        kind: 'ad' as const,
        ariaLabel: copy.place
          ? `Ad: ${copy.name}, ${copy.place}, ${index + 1} of ${liveAds.value.length}`
          : `Ad: ${copy.name}, ${index + 1} of ${liveAds.value.length}`,
      }
    })
  }
  return placementCafes.value.map((cafe, index) => {
    const badge = cafe.markerTier === 'promoted' ? 'Sponsored' : 'Partner'
    return {
      id: cafe.id,
      shopId: cafe.id,
      name: cafe.name,
      place: cafe.address,
      image: '/assets/partner-ad-placeholder.svg',
      badge,
      kind: cafe.markerTier,
      ariaLabel: `${badge}: ${cafe.name}, ${index + 1} of ${placementCafes.value.length}`,
    }
  })
})

const firstNameFrom = (value: unknown): string => {
  if (typeof value !== 'string') return ''
  const trimmed = value.trim()
  if (!trimmed) return ''
  return trimmed.split(/\s+/)[0] ?? ''
}

const greetingForHour = (hour: number): string => {
  if (hour < 12) return 'Good morning'
  if (hour < 17) return 'Good afternoon'
  return 'Good evening'
}

const origin = computed(() => (
  locationStatus.value === 'granted' && location.value && !usingFallback.value
    ? location.value
    : null
))

const activeFilterMeta = computed(() => filters.find((filter) => filter.id === activeFilter.value) ?? filters[0]!)

const locationNote = computed(() => {
  if (activeFilter.value !== 'near') return ''
  if (locationStatus.value === 'denied') return 'Location is off, so this list is not sorted by distance.'
  if (locationStatus.value === 'unavailable') return 'Location is unavailable, so this list is not sorted by distance.'
  if (origin.value) return `within ${nearbyRadiusKm.value} km`
  return ''
})

const listKey = computed(() => (
  `${activeFilter.value}|${submittedQuery.value}|${status.value}|${nearbyRadiusKm.value}|${origin.value ? 'geo' : 'nogeo'}`
))

const visibleCafes = computed(() => filterCafes(cafes.value, {
  query: submittedQuery.value,
  filter: activeFilter.value,
  origin: origin.value,
  radiusMeters: radiusMeters.value,
}))

const shopCountLabel = computed(() => {
  const count = visibleCafes.value.length
  return `${count} ${count === 1 ? 'shop' : 'shops'}`
})

const emptyCopy = computed(() => {
  if (cafes.value.length === 0) return 'No coffee shops yet.'
  if (activeFilter.value === 'near' && origin.value) {
    return `No coffee shops within ${nearbyRadiusKm.value} km.`
  }
  return 'No coffee shops match that filter.'
})

const {
  slice: pagedCafes,
  hasMore: hasMoreCafes,
  sentinel: moreCafes,
} = useInfiniteWindow(visibleCafes, listKey)

const distanceLabel = (cafe: Cafe) => {
  if (!origin.value) return undefined
  return formatDistance(distanceMeters(origin.value, cafe))
}

const submitSearch = async () => {
  const next = query.value.trim()
  const path = next ? `/app/search?q=${encodeURIComponent(next)}` : '/app/search'

  await navigateTo(path)
}

const setFilter = (id: CafeFilterId) => {
  activeFilter.value = id
}

const openCafe = async (id: string) => {
  await navigateTo(`/app/cafes/${id}`)
}

const addCafe = async () => {
  await navigateTo('/app/submit-cafe')
}

onIonViewWillEnter(() => {
  hydrateNearbyRadius()
})

onMounted(() => {
  if (Capacitor.getPlatform() === 'android') {
    document.documentElement.classList.add('is-android')
  }
  greeting.value = greetingForHour(new Date().getHours())
  firstName.value = firstNameFrom(user.value?.user_metadata?.display_name)
  void requestLocation()
  void (async () => {
    if (!user.value) return
    try {
      const profile = await loadProfile()
      const fromProfile = firstNameFrom(profile?.display_name)
      if (fromProfile) firstName.value = fromProfile
    } catch {
      // Keep metadata name when the profile call fails.
    }
  })()
})
</script>

<style scoped>
.home-content {
  --background: #f2f2f2;
  --padding-start: 0;
  --padding-end: 0;
  --padding-top: 0;
  --padding-bottom: 0;
}

.home {
  min-height: 100%;
  background-color: #f2f2f2;
  padding: 0 0 calc(72px + env(safe-area-inset-bottom));
}

.home-plate {
  display: flex;
  flex-direction: column;
  min-height: 100%;
  background: transparent;
  color: var(--kd-ink);
  caret-color: var(--kd-primary);
}

.home-chrome {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  min-height: 72px;
  padding: max(16px, env(safe-area-inset-top)) 20px 12px;
  background: #f2f2f2;
}

.home-chrome__greeting {
  display: flex;
  flex-direction: column;
  gap: 0;
  min-width: 0;
  flex: 1 1 auto;
  color: #1c1917;
}

.home-chrome__hello,
.home-chrome__name {
  margin: 0;
  min-width: 0;
  overflow-wrap: anywhere;
}

.home-chrome__hello {
  font-size: clamp(0.875rem, 3.5vw, 0.975rem);
  font-weight: 700;
  line-height: 1.2;
  letter-spacing: -0.02em;
}

.home-chrome__name {
  font-size: 0.75rem;
  font-weight: 400;
  line-height: 1.3;
}

.home-chrome__wordmark {
  display: block;
  flex: 0 0 auto;
  width: min(120px, 34vw);
  height: 26px;
  object-fit: contain;
  object-position: right center;
}

.home-search {
  margin: 0 20px 8px;
  border-bottom: 1px solid color-mix(in srgb, var(--kd-ink) 28%, transparent);
}

.home-partners {
  margin: 0 0 4px;
}

.home-partners__track {
  display: flex;
  gap: 12px;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  scroll-padding-inline: 20px;
  scrollbar-width: none;
  padding: 4px 20px 8px;
  -webkit-overflow-scrolling: touch;
}

.home-partners__track::-webkit-scrollbar {
  display: none;
}

.home-partners__card {
  display: grid;
  grid-template-columns: 108px minmax(0, 1fr);
  align-items: stretch;
  flex: 0 0 calc(100% - 56px);
  scroll-snap-align: start;
  min-width: 0;
  min-height: 128px;
  padding: 0;
  overflow: hidden;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 28%, transparent);
  border-radius: 16px;
  background: #faf8f5;
  color: var(--kd-ink);
  font: inherit;
  text-align: left;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.home-partners__card:only-child {
  flex-basis: 100%;
}

.home-partners__card:active {
  background: color-mix(in srgb, var(--kd-ink) 6%, #faf8f5);
}

.home-partners__card:active .home-partners__image {
  filter: brightness(0.92);
}

.home-partners__card:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

@media (hover: hover) {
  .home-partners__card:hover {
    background: color-mix(in srgb, var(--kd-ink) 4%, #faf8f5);
  }
}

.home-partners__media {
  position: relative;
  display: block;
  min-height: 128px;
  background: var(--kd-primary);
}

.home-partners__card--sponsored .home-partners__media {
  background: var(--kd-accent);
}

.home-partners__image {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.home-partners__badge {
  position: absolute;
  left: 8px;
  bottom: 8px;
  padding: 2px 6px;
  border-radius: 8px;
  background: #faf8f5;
  color: var(--kd-primary);
  font-size: 0.75rem;
  font-weight: 700;
  line-height: 1.3;
}

.home-partners__card--sponsored .home-partners__badge {
  color: var(--kd-ink);
}

.home-partners__copy {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: center;
  gap: 2px;
  min-width: 0;
  padding: 12px 14px 12px 12px;
}

.home-partners__name {
  display: -webkit-box;
  overflow: hidden;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  font-size: 1.05rem;
  font-weight: 700;
  line-height: 1.15;
  letter-spacing: -0.02em;
}

.home-partners__place,
.home-partners__index {
  color: color-mix(in srgb, var(--kd-ink) 78%, #faf8f5);
}

.home-partners__place {
  display: -webkit-box;
  overflow: hidden;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  font-size: 0.75rem;
  font-weight: 400;
  line-height: 1.3;
}

.home-partners__index {
  margin-top: 4px;
  font-size: 0.75rem;
  font-weight: 700;
  line-height: 1.3;
}

.home-search__field {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 0 12px;
}

.home-search__field input {
  width: 100%;
  height: 46px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-ink);
  font-family: inherit;
  font-size: 0.95rem;
  font-weight: 700;
  text-align: left;
  caret-color: var(--kd-primary);
}

.home-search__field input::placeholder {
  color: var(--kd-ink-50);
  opacity: 1;
}

.home-search__field input:focus {
  outline: none;
}

.home-search__field:focus-within {
  box-shadow: inset 0 -1px 0 var(--kd-primary);
}

.home-search__field input::-webkit-search-decoration,
.home-search__field input::-webkit-search-cancel-button {
  -webkit-appearance: none;
}

.home-filters {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  scrollbar-width: none;
  padding: 8px 20px 12px;
}

.home-filters::-webkit-scrollbar {
  display: none;
}

.home-filters__chip {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  flex: 0 0 auto;
  min-width: 0;
  height: 44px;
  padding: 0 12px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 22%, transparent);
  border-radius: 16px;
  background: transparent;
  color: var(--kd-ink);
  font-family: inherit;
  font-size: 0.75rem;
  font-weight: 400;
  letter-spacing: 0;
  white-space: nowrap;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.home-filters__chip.is-active {
  background: var(--kd-accent);
  color: var(--kd-ink);
  border-color: var(--kd-accent);
  font-weight: 700;
}

.home-filters__chip:active {
  box-shadow: inset 0 3px 0 color-mix(in srgb, var(--kd-ink) 35%, transparent);
}

.home-filters__chip.is-active:active {
  box-shadow: inset 0 3px 0 color-mix(in srgb, var(--kd-ink) 22%, transparent);
}

.home-filters__chip:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: -4px;
}

.home-state,
.home-empty {
  margin: 0;
  padding: 4px 20px 12px;
  color: var(--kd-ink);
  font-size: 0.75rem;
  font-weight: 400;
  line-height: 1.3;
  text-align: left;
}

.home-state {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 6px;
  letter-spacing: 0;
}

.home-empty {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
}

.home-skeletons {
  display: flex;
  flex-direction: column;
}

.home-skeleton {
  display: block;
  height: 128px;
  margin: 0 20px 12px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 12%, transparent);
  border-radius: 16px;
  background: linear-gradient(
    90deg,
    var(--kd-white) 0%,
    color-mix(in srgb, var(--kd-ink) 8%, var(--kd-white)) 50%,
    var(--kd-white) 100%
  );
  background-size: 200% 100%;
  animation: bag-shimmer 1.1s ease-in-out infinite;
}

.home-skeleton:nth-child(3) {
  animation-delay: 120ms;
}

.home-skeleton:nth-child(4) {
  animation-delay: 240ms;
}

.home-retry {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  min-height: 44px;
  margin-left: auto;
  padding: 0 12px;
  border: 1px solid var(--kd-primary);
  background: transparent;
  color: var(--kd-primary);
  font-family: inherit;
  font-size: 0.85rem;
  font-weight: 700;
  cursor: pointer;
}

.home-retry:focus-visible,
.home-add:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
}

.home-list {
  display: flex;
  flex-direction: column;
}

.home-more {
  margin: 0;
  padding: 12px 12px 14px;
  color: var(--kd-ink);
  font-size: 0.8rem;
  font-weight: 700;
  text-align: center;
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

.home-add {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin: 8px 20px 16px;
  width: calc(100% - 40px);
  min-height: 44px;
  padding: 0 16px;
  border: 1px solid var(--kd-accent);
  border-radius: 16px;
  background: var(--kd-accent);
  color: var(--kd-ink);
  font-family: inherit;
  font-size: 0.95rem;
  font-weight: 700;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.home-add:active {
  box-shadow: inset 0 3px 0 color-mix(in srgb, var(--kd-ink) 22%, transparent);
}

.cafe-list-enter-active,
.cafe-list-leave-active {
  transition: opacity 220ms cubic-bezier(0.16, 1, 0.3, 1), transform 220ms cubic-bezier(0.16, 1, 0.3, 1);
}

.cafe-list-enter-from,
.cafe-list-leave-to {
  opacity: 0;
  transform: translateY(8px);
}

@keyframes bag-shimmer {
  from { background-position: 100% 0; }
  to { background-position: -100% 0; }
}

.home-plate ::selection {
  background: var(--kd-accent);
  color: var(--kd-ink);
}

@media (min-width: 540px) {
  .home {
    max-width: 480px;
    margin-inline: auto;
  }
}

@media (prefers-reduced-motion: reduce) {
  .home-filters__chip,
  .home-add,
  .home-retry,
  .cafe-list-enter-active,
  .cafe-list-leave-active {
    transition: none;
  }

  .home-skeleton,
  .home-filters__chip:active,
  .home-add:active {
    animation: none;
    box-shadow: none;
  }
}
</style>
