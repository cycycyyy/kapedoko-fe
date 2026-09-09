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
              No coffee shops match that search.
            </p>

            <article
              v-for="cafe in visibleCafes"
              :key="cafe.id"
              class="cafe-card"
            >
              <div
                class="cafe-card__photo"
                :class="{ 'is-broken': brokenImages.has(cafe.id) }"
              >
                <img
                  :src="cafe.image"
                  :alt="cafe.name"
                  width="90"
                  height="100"
                  @error="markBroken(cafe.id)"
                />
              </div>

              <div class="cafe-card__body">
                <div class="cafe-card__meta">
                  <div class="cafe-card__stars" aria-label="Rating 5 out of 5">
                    <Star
                      v-for="n in 5"
                      :key="n"
                      :size="12"
                      :stroke-width="1.75"
                      fill="currentColor"
                    />
                  </div>
                  <p
                    class="cafe-card__status"
                    :class="cafe.open ? 'is-open' : 'is-closed'"
                  >
                    {{ cafe.status }}
                  </p>
                </div>

                <h2>{{ cafe.name }}</h2>
                <p class="cafe-card__address">{{ cafe.address }}</p>

                <p v-if="cafe.amenities === 'none'" class="cafe-card__none">
                  <Ban :size="14" :stroke-width="2" aria-hidden="true" />
                  No WiFi or Power Outlets
                </p>
                <p v-else class="cafe-card__amenities">
                  <Wifi v-if="cafe.amenities.includes('wifi')" :size="14" :stroke-width="2" aria-label="WiFi" />
                  <Plug v-if="cafe.amenities.includes('plug')" :size="14" :stroke-width="2" aria-label="Power outlets" />
                </p>
              </div>
            </article>
          </section>
        </Transition>
      </div>
    </IonContent>

    <nav class="home-tabbar" aria-label="Primary">
      <button type="button" class="home-tabbar__item is-active" aria-current="page">
        <span class="home-tabbar__icon">
          <House :size="18" :stroke-width="2" />
        </span>
        <span class="sr-only">Home</span>
      </button>
      <button type="button" class="home-tabbar__item" aria-label="Saved cafes" @click="goToFavorites">
        <Heart :size="24" :stroke-width="2" />
      </button>
      <button type="button" class="home-tabbar__item" aria-label="Map">
        <Map :size="24" :stroke-width="2" />
      </button>
      <button type="button" class="home-tabbar__item" aria-label="Profile">
        <UserRoundPen :size="24" :stroke-width="2" />
      </button>
    </nav>
  </IonPage>
</template>

<script lang="ts" setup>
import {
  Ban,
  Bell,
  Coffee,
  Heart,
  House,
  Map,
  Plug,
  Search,
  Star,
  UserRoundPen,
  Wifi,
} from 'lucide-vue-next'

type FilterId = 'near' | 'popular' | 'wifi' | 'plugs'
type Amenity = 'wifi' | 'plug'

interface Cafe {
  id: string
  name: string
  address: string
  image: string
  open: boolean
  status: string
  amenities: Amenity[] | 'none'
  popular: boolean
}

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

const cafes: Cafe[] = [
  {
    id: 'c1',
    name: 'Toby’s Estate',
    address: 'BGC High Street, Taguig City',
    image: '/assets/cafes/tobys.jpg',
    open: true,
    status: 'Open',
    amenities: ['wifi', 'plug'],
    popular: true,
  },
  {
    id: 'c2',
    name: 'Commune Cafe + Bar',
    address: 'Poblacion, Makati City',
    image: '/assets/cafes/commune.jpg',
    open: true,
    status: 'Open',
    amenities: ['plug'],
    popular: true,
  },
  {
    id: 'c3',
    name: 'Single Origin',
    address: 'Salcedo Village, Makati City',
    image: '/assets/cafes/single-origin.jpg',
    open: false,
    status: 'Closed, opens at 9:00am',
    amenities: ['wifi', 'plug'],
    popular: false,
  },
  {
    id: 'c4',
    name: 'KapeTayo',
    address: 'Katipunan Ave, Quezon City',
    image: '/assets/cafes/kapetayo.jpg',
    open: true,
    status: 'Open',
    amenities: 'none',
    popular: false,
  },
]

const query = ref('')
const submittedQuery = ref('')
const activeFilter = ref<FilterId>('near')
const featuredIndex = ref(0)
const featuredTrack = ref<HTMLElement | null>(null)
const brokenImages = ref<Set<string>>(new Set())

const listKey = computed(() => `${activeFilter.value}|${submittedQuery.value}`)

const visibleCafes = computed(() => {
  const term = submittedQuery.value.trim().toLowerCase()

  return cafes.filter((cafe) => {
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

const goToFavorites = async () => {
  await navigateTo('/app/favorites')
}

const setFilter = (id: FilterId) => {
  activeFilter.value = id
}

const markBroken = (id: string) => {
  const next = new Set(brokenImages.value)
  next.add(id)
  brokenImages.value = next
}
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
  padding-bottom: calc(7.25rem + env(safe-area-inset-bottom));
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
  color: var(--kd-primary);
  font-size: 16px;
  font-weight: 700;
  line-height: 1.375;
}

.cafe-card__address {
  margin: 0;
  overflow: hidden;
  color: var(--kd-ink);
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

.home-tabbar {
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 10;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  align-items: center;
  width: 100%;
  height: calc(100px + env(safe-area-inset-bottom));
  padding: 0 12px env(safe-area-inset-bottom);
  background: var(--kd-white-80);
  backdrop-filter: blur(4px);
}

.home-tabbar__item {
  display: grid;
  place-items: center;
  height: 48px;
  border: 0;
  background: transparent;
  color: var(--kd-primary-25);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: color 180ms cubic-bezier(0.16, 1, 0.3, 1),
    transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.home-tabbar__item.is-active {
  color: var(--kd-white);
}

.home-tabbar__icon {
  position: relative;
  display: grid;
  place-items: center;
  width: 30px;
  height: 30px;
  border-radius: 5px;
  background: var(--kd-primary);
}

.home-tabbar__icon::after {
  content: '';
  position: absolute;
  left: 0;
  bottom: -18px;
  width: 30px;
  height: 5px;
  border-radius: 5px;
  background: var(--kd-primary);
}

.home-tabbar__item:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
  border-radius: 8px;
}

.home-hero__bell:active,
.home-search__submit:active,
.home-filters__chip:active,
.home-tabbar__item:active {
  transform: scale(0.94);
}

.cafe-card:active {
  transform: scale(0.99);
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
}

@media (min-width: 540px) {
  .home,
  .home-tabbar {
    max-width: 480px;
    margin-inline: auto;
  }
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
  .cafe-card,
  .home-tabbar__item,
  .cafe-list-enter-active,
  .cafe-list-leave-active {
    transition-duration: 1ms;
  }

  .home-dots__dot.is-active,
  .home-hero__bell:active,
  .home-search__submit:active,
  .home-filters__chip:active,
  .home-tabbar__item:active,
  .cafe-card:active {
    transform: none;
  }
}

::selection {
  background: var(--kd-secondary);
  color: var(--kd-primary);
}
</style>
