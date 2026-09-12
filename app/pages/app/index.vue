<template>
  <IonPage>
    <IonContent class="home-content">
      <div class="home">
        <header class="home-hero">
          <img
            src="/assets/home-watermark.png"
            alt=""
            class="home-hero__watermark"
          />

          <div class="home-hero__bar">
            <div class="home-hero__brand">
              <img
                src="/assets/kapedoko-logo_light.png"
                alt=""
                width="23"
                height="30"
                class="home-hero__mark"
              />
              <img
                src="/assets/kapedoko-horizontal-text_light.png"
                alt="kapé DOKO"
                width="122"
                height="28"
                class="home-hero__wordmark"
              />
            </div>

            <button type="button" class="home-hero__bell" aria-label="Notifications">
              <Bell :size="20" :stroke-width="2" />
            </button>
          </div>

          <form class="home-search" @submit.prevent="submitSearch">
            <label class="home-search__field">
              <Coffee :size="19" :stroke-width="2" aria-hidden="true" />
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

            <button type="submit" class="home-search__submit" aria-label="Search">
              <Search :size="24" :stroke-width="2" />
            </button>
          </form>
        </header>

        <div
          ref="featuredTrack"
          class="home-featured"
          tabindex="0"
          role="region"
          aria-roledescription="carousel"
          :aria-label="`Featured cafes, slide ${featuredIndex + 1} of ${featured.length}`"
          @scroll.passive="onFeaturedScroll"
        >
          <article
            v-for="slide in featured"
            :key="slide.id"
            class="home-featured__card"
          >
            <p class="home-featured__copy">
              <span>Visit</span>
              <strong>{{ slide.name }}</strong>
            </p>
            <div
              class="home-featured__media"
              :class="{ 'is-broken': brokenImages.has(slide.id) }"
            >
              <img
                :src="slide.image"
                :alt="slide.name"
                width="171"
                height="100"
                @error="markBroken(slide.id)"
              />
            </div>
          </article>
        </div>

        <div class="home-dots" role="tablist" aria-label="Featured cafes">
          <button
            v-for="(slide, index) in featured"
            :key="slide.id"
            type="button"
            role="tab"
            class="home-dots__dot"
            :class="{ 'is-active': featuredIndex === index }"
            :aria-selected="featuredIndex === index"
            :aria-label="`Show ${slide.name}`"
            @click="goToFeatured(index)"
          />
        </div>

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
            {{ filter.label }}
          </button>
        </div>

        <Transition name="cafe-list" mode="out-in">
          <section :key="listKey" class="home-list" aria-label="Cafes">
            <p v-if="visibleCafes.length === 0" class="home-empty">
              {{ cafes.length === 0 ? 'No coffee shops yet.' : 'No coffee shops match that search.' }}
            </p>

            <CafeCard
              v-for="cafe in visibleCafes"
              :key="cafe.id"
              :cafe="cafe"
            />
          </section>
        </Transition>
      </div>

      <button type="button" slot="fixed" class="home-fab" @click="addCafe">
        <span class="home-fab__mark" aria-hidden="true">
          <svg viewBox="0 0 24 24" fill="none">
            <path
              d="M8.2 3.2v3.2M13.2 2.8v3.6"
              stroke="currentColor"
              stroke-width="1.8"
              stroke-linecap="round"
            />
            <path
              d="M4.6 8.2h11.4v6.2a3.1 3.1 0 0 1-3.1 3.1H7.7a3.1 3.1 0 0 1-3.1-3.1z"
              fill="currentColor"
            />
            <path
              d="M16 9.8c3 .12 3.7 2.1 3.7 3.3s-.8 3.2-3.7 3.35"
              stroke="currentColor"
              stroke-width="1.8"
              stroke-linecap="round"
            />
          </svg>
        </span>
        Add a cafe
      </button>
    </IonContent>

    <AppTabBar active="home" />
  </IonPage>
</template>

<script lang="ts" setup>
import { Capacitor } from '@capacitor/core'
import {
  Bell,
  Coffee,
  Search,
} from 'lucide-vue-next'
import CafeCard from '~/components/cafe/CafeCard.vue'
import AppTabBar from '~/components/navigation/AppTabBar.vue'

type FilterId = 'near' | 'popular' | 'wifi' | 'plugs'

const filters: { id: FilterId; label: string }[] = [
  { id: 'near', label: 'Near You' },
  { id: 'popular', label: 'Popular' },
  { id: 'wifi', label: 'WiFi Access' },
  { id: 'plugs', label: 'Plugs' },
]

const featured = [
  {
    id: 'f1',
    name: 'Yardstick Coffee',
    image: '/assets/cafes/yardstick.jpg',
  },
  {
    id: 'f2',
    name: 'The Coffee Academics',
    image: '/assets/cafes/academics.jpg',
  },
  {
    id: 'f3',
    name: 'Wildflour Cafe + Bakery',
    image: '/assets/cafes/wildflour.jpg',
  },
]

const { cafes: liveCafes } = useApprovedShops()
const cafes = computed(() => liveCafes.value)

const query = ref('')
const submittedQuery = ref('')
const activeFilter = ref<FilterId>('near')
const featuredIndex = ref(0)
const featuredTrack = ref<HTMLElement | null>(null)
const brokenImages = ref<Set<string>>(new Set())

const listKey = computed(() => `${activeFilter.value}|${submittedQuery.value}`)

const visibleCafes = computed(() => {
  const term = submittedQuery.value.trim().toLowerCase()

  return cafes.value.filter((cafe) => {
    const matchesQuery =
      !term ||
      cafe.name.toLowerCase().includes(term) ||
      cafe.address.toLowerCase().includes(term)

    const matchesFilter =
      activeFilter.value === 'near' ||
      (activeFilter.value === 'popular' && cafe.popular) ||
      (activeFilter.value === 'wifi' && cafe.amenities !== 'none' && cafe.amenities.includes('wifi')) ||
      (activeFilter.value === 'plugs' && cafe.amenities !== 'none' && cafe.amenities.includes('plug'))

    return matchesQuery && matchesFilter
  })
})

const prefersReducedMotion = () =>
  typeof window !== 'undefined' && window.matchMedia('(prefers-reduced-motion: reduce)').matches

const featuredStep = () => {
  const track = featuredTrack.value
  const card = track?.querySelector<HTMLElement>('.home-featured__card')
  if (!track || !card) return 0
  const styles = getComputedStyle(track)
  const gap = Number.parseFloat(styles.columnGap || styles.gap) || 20
  return card.offsetWidth + gap
}

const goToFeatured = (index: number) => {
  const track = featuredTrack.value
  const step = featuredStep()
  if (!track || !step) return

  const next = Math.max(0, Math.min(featured.length - 1, index))
  featuredIndex.value = next
  track.scrollTo({
    left: next * step,
    behavior: prefersReducedMotion() ? 'auto' : 'smooth',
  })
}

const onFeaturedScroll = () => {
  const track = featuredTrack.value
  const step = featuredStep()
  if (!track || !step) return

  const index = Math.round(track.scrollLeft / step)
  if (index !== featuredIndex.value) {
    featuredIndex.value = Math.max(0, Math.min(featured.length - 1, index))
  }
}

const submitSearch = async () => {
  const next = query.value.trim()
  const path = next ? `/app/search?q=${encodeURIComponent(next)}` : '/app/search'

  await navigateTo(path)
}

const setFilter = (id: FilterId) => {
  activeFilter.value = id
}

const markBroken = (id: string) => {
  const next = new Set(brokenImages.value)
  next.add(id)
  brokenImages.value = next
}

const addCafe = async () => {
  await navigateTo('/app/submit-cafe')
}

onMounted(() => {
  if (Capacitor.getPlatform() === 'android') {
    document.documentElement.classList.add('is-android')
  }
})
</script>

<style scoped>
.home-content {
  --background: var(--kd-white);
  --padding-start: 0;
  --padding-end: 0;
  --padding-top: 0;
  --padding-bottom: 0;
}

.home {
  min-height: 100%;
  background: var(--kd-white);
  padding-bottom: calc(11.5rem + env(safe-area-inset-bottom));
  container-type: inline-size;
  container-name: home;
}

.home-hero {
  position: relative;
  overflow: hidden;
  background: var(--kd-primary);
  color: var(--kd-white);
  padding: max(2.75rem, calc(env(safe-area-inset-top) + 16px)) 20px 71px;
}

.home-hero__watermark {
  position: absolute;
  top: -15px;
  right: -9px;
  width: 199px;
  height: 259px;
  pointer-events: none;
  user-select: none;
}

.home-hero__bar {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 30px;
}

.home-hero__brand {
  display: flex;
  align-items: center;
  gap: 10px;
}

.home-hero__mark {
  display: block;
  width: 23px;
  height: 30px;
  object-fit: contain;
}

.home-hero__wordmark {
  display: block;
  width: 122px;
  height: 28px;
  object-fit: contain;
  object-position: left center;
  mix-blend-mode: lighten;
}

.home-hero__bell {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  margin-right: -10px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-white);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.home-hero__bell:focus-visible {
  outline: 2px solid var(--kd-white);
  outline-offset: 2px;
  border-radius: 8px;
}

.home-search {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: stretch;
  flex-wrap: nowrap;
  gap: 9px;
  margin-top: 21px;
}

.home-search__field {
  display: flex;
  align-items: center;
  gap: 11px;
  flex: 1;
  min-width: 0;
  height: 50px;
  padding: 0 16px;
  border-radius: 8px;
  background: var(--kd-white);
  color: var(--kd-ink-50);
}

.home-search__field input {
  width: 100%;
  border: 0;
  background: transparent;
  color: var(--kd-ink);
  font-size: 12px;
  font-family: inherit;
  caret-color: var(--kd-primary);
}

.home-search__field input::-webkit-search-decoration,
.home-search__field input::-webkit-search-cancel-button {
  -webkit-appearance: none;
}

.home-search__field input::placeholder {
  color: var(--kd-ink-50);
}

.home-search__field input:focus {
  outline: none;
}

.home-search__field:focus-within {
  box-shadow: 0 0 0 2px var(--kd-white), 0 0 0 4px var(--kd-primary);
}

.home-search__submit {
  display: grid;
  place-items: center;
  flex: 0 0 63px;
  width: 63px;
  height: 50px;
  padding: 0;
  border: 0;
  border-radius: 8px;
  background: var(--kd-white);
  color: var(--kd-primary);
  line-height: 0;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: opacity 140ms cubic-bezier(0.16, 1, 0.3, 1),
    transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.home-search__submit :deep(svg) {
  display: block;
}

.home-search__submit:focus-visible {
  outline: 2px solid var(--kd-white);
  outline-offset: 2px;
}

.home-featured {
  position: relative;
  z-index: 1;
  display: flex;
  gap: 20px;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  scroll-padding-inline: 20px;
  scrollbar-width: none;
  margin: -57px 0 0;
  padding: 0 20px;
  outline: none;
  -webkit-overflow-scrolling: touch;
}

.home-featured::-webkit-scrollbar {
  display: none;
}

.home-featured__card {
  flex: 0 0 calc(100cqi - 40px);
  width: calc(100cqi - 40px);
  height: 100px;
  display: flex;
  overflow: hidden;
  border-radius: 8px;
  background: var(--kd-white);
  box-shadow: 0 0 8px var(--kd-shadow);
  scroll-snap-align: start;
  scroll-snap-stop: always;
}

.home-featured__card:focus-visible {
  outline: 2px solid var(--kd-white);
  outline-offset: -4px;
}

.home-featured__copy {
  display: flex;
  flex-direction: column;
  justify-content: center;
  flex: 1;
  min-width: 0;
  margin: 0;
  padding: 0 22px;
  color: var(--kd-primary);
  font-size: 16px;
  line-height: 1.375;
}

.home-featured__copy span {
  font-weight: 400;
}

.home-featured__copy strong {
  display: -webkit-box;
  overflow: hidden;
  font-weight: 700;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
}

.home-featured__media {
  flex: 0 0 49%;
  width: 49%;
  max-width: 171px;
  height: 100%;
  background: var(--kd-secondary);
}

.home-featured__media img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.home-featured__media.is-broken img {
  display: none;
}

.home-dots {
  display: flex;
  justify-content: center;
  gap: 4px;
  padding: 11px 0 12px;
}

.home-dots__dot {
  width: 6.4px;
  height: 6.4px;
  padding: 0;
  border: 0;
  border-radius: 999px;
  background: var(--kd-placeholder);
  cursor: pointer;
  transition: background-color 180ms cubic-bezier(0.16, 1, 0.3, 1),
    transform 180ms cubic-bezier(0.16, 1, 0.3, 1);
}

.home-dots__dot.is-active {
  background: var(--kd-primary);
  transform: scale(1.12);
}

.home-dots__dot:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
}

.home-filters {
  display: flex;
  gap: 10px;
  overflow-x: auto;
  scrollbar-width: none;
  padding: 0 20px 14px;
  -webkit-overflow-scrolling: touch;
}

.home-filters::-webkit-scrollbar {
  display: none;
}

.home-filters__chip {
  flex: 0 0 97px;
  width: 97px;
  height: 27px;
  padding: 0;
  border: 0;
  border-radius: 4px;
  background: var(--kd-ink-10);
  color: var(--kd-primary);
  font-size: 12px;
  font-weight: 400;
  font-family: inherit;
  cursor: pointer;
  white-space: nowrap;
  -webkit-tap-highlight-color: transparent;
  transition: background-color 180ms cubic-bezier(0.16, 1, 0.3, 1),
    color 180ms cubic-bezier(0.16, 1, 0.3, 1),
    transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.home-filters__chip.is-active {
  background: var(--kd-primary);
  color: var(--kd-white);
  font-weight: 700;
}

.home-filters__chip:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.home-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
  padding: 0 20px;
}

.home-empty {
  margin: 1.5rem 0 0;
  text-align: center;
  color: var(--kd-ink);
  font-size: 14px;
}

.home-fab {
  position: fixed;
  right: 20px;
  bottom: calc(100px + env(safe-area-inset-bottom) + 12px);
  z-index: 12;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  height: 45px;
  min-height: 45px;
  padding: 0 16px 0 12px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-primary);
  color: var(--kd-white);
  box-shadow: 0 4px 12px var(--kd-shadow);
  font-size: 16px;
  font-weight: 700;
  font-family: inherit;
  line-height: 1;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  animation: home-fab-rise 560ms cubic-bezier(0.16, 1, 0.3, 1) both;
}

.home-fab__mark {
  display: grid;
  place-items: center;
  width: 22px;
  height: 22px;
  flex-shrink: 0;
}

.home-fab__mark svg {
  display: block;
  width: 22px;
  height: 22px;
}

.home-fab:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
}

.home-fab:active {
  transform: scale(0.96);
}

@keyframes home-fab-rise {
  from {
    opacity: 0;
    transform: translateY(14px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.home-hero__bell:active,
.home-search__submit:active,
.home-filters__chip:active {
  transform: scale(0.94);
}

.cafe-list-enter-active,
.cafe-list-leave-active {
  transition: opacity 160ms cubic-bezier(0.16, 1, 0.3, 1);
}

.cafe-list-enter-from,
.cafe-list-leave-to {
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
  .home-search__submit:hover {
    opacity: 0.92;
  }

  .home-filters__chip:hover:not(.is-active) {
    background: color-mix(in srgb, var(--kd-ink) 16%, transparent);
  }

  .home-fab:hover {
    box-shadow: 0 6px 16px var(--kd-shadow);
  }
}

@media (min-width: 540px) {
  .home {
    max-width: 480px;
    margin-inline: auto;
  }

  .home-fab {
    right: calc(50% - 240px + 20px);
  }
}

:root.is-android .home-fab {
  height: 48px;
  min-height: 48px;
}

@media (prefers-reduced-motion: reduce) {
  .home-featured {
    scroll-behavior: auto;
    scroll-snap-type: x proximity;
  }

  .home-hero__bell,
  .home-search__submit,
  .home-dots__dot,
  .home-filters__chip,
  .home-fab,
  .cafe-list-enter-active,
  .cafe-list-leave-active {
    animation: none;
    transition-duration: 1ms;
  }

  .home-dots__dot.is-active,
  .home-hero__bell:active,
  .home-search__submit:active,
  .home-filters__chip:active,
  .home-fab:active {
    transform: none;
  }
}

::selection {
  background: var(--kd-secondary);
  color: var(--kd-primary);
}
</style>
