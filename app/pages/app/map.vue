<template>
  <IonPage>
    <IonContent :scroll-y="false" class="map-content">
      <div
        class="map-screen"
        :class="{
          'is-ready': mapReady,
          'is-sheet-open': sheetOpen || detailOpen,
        }"
      >
        <div class="map-placeholder" aria-hidden="true" />

        <KapeMap
          v-if="mapCenter"
          :key="mapEpoch"
          ref="mapRef"
          :center="mapCenter"
          :accuracy="accuracy"
          :cafes="visibleCafes"
          :selected-id="selectedId"
          :sheet-open="sheetOpen || detailOpen"
          :header-pad="headerPad"
          :bottom-pad="bottomPad"
          @tiles-ready="onTilesReady"
          @tiles-error="onTilesError"
          @select="onSelectCafe"
          @viewchange="onViewChange"
        />

        <div class="map-chrome">
          <header class="map-hero">
            <div class="map-hero__bar">
              <button type="button" class="map-back" aria-label="Go back" @click="goBack">
                <ChevronLeft :size="22" :stroke-width="2.25" />
              </button>

              <div class="map-brand">
                <img
                  src="/assets/kapedoko-logo_dark.png"
                  alt=""
                  width="23"
                  height="30"
                  class="map-brand__mark"
                />
                <img
                  src="/assets/kapedoko-horizontal-text_dark.png"
                  alt="kapé DOKO"
                  width="122"
                  height="28"
                  class="map-brand__wordmark"
                />
              </div>

              <h1 class="map-title">MAPS</h1>
            </div>

            <form class="map-search" @submit.prevent="submitSearch">
              <label class="map-search__field">
                <span class="sr-only">Search a coffee shop</span>
                <input
                  v-model="query"
                  type="search"
                  name="q"
                  role="combobox"
                  placeholder="Search a coffee shop"
                  autocomplete="off"
                  enterkeyhint="search"
                  aria-autocomplete="list"
                  :aria-expanded="showSuggestions"
                  aria-controls="map-search-list"
                  :aria-activedescendant="activeSuggestionId"
                  @focus="onSearchFocus"
                  @blur="onSearchBlur"
                  @keydown="onSearchKeydown"
                />
                <button type="submit" class="map-search__submit" aria-label="Search">
                  <Search :size="24" :stroke-width="2" />
                </button>
              </label>

              <ul
                v-if="showSuggestions"
                id="map-search-list"
                class="map-search__results"
                role="listbox"
                aria-label="Coffee shop suggestions"
              >
                <li v-if="suggestions.length === 0" class="map-search__empty" role="option" aria-disabled="true">
                  No matching coffee shops
                </li>
                <li
                  v-for="(cafe, index) in suggestions"
                  :id="`map-search-option-${cafe.id}`"
                  :key="cafe.id"
                  role="option"
                  :aria-selected="index === activeIndex"
                >
                  <button
                    type="button"
                    class="map-search__suggestion"
                    :class="{ 'is-active': index === activeIndex }"
                    @mousedown.prevent="pickSuggestion(cafe)"
                  >
                    <span class="map-search__suggestion-name">{{ cafe.name }}</span>
                    <span class="map-search__suggestion-meta">
                      {{ cafe.address }}
                      <template v-if="suggestionDistances[cafe.id]">
                        · {{ suggestionDistances[cafe.id] }}
                      </template>
                    </span>
                  </button>
                </li>
              </ul>
            </form>
          </header>

          <div v-if="usingFallback && locationStatus !== 'requesting'" class="map-banner" role="status">
            <p>Location is off. Enable it to see cafes near you.</p>
            <button type="button" class="map-banner__action" @click="requestLocation">
              Enable location
            </button>
          </div>

          <p
            v-else-if="locationStatus === 'requesting' && !mapSettled"
            class="map-banner map-banner--quiet"
            role="status"
          >
            Finding your location…
          </p>

          <div v-if="tilesFailed" class="map-error" role="alert">
            <p>Map tiles couldn’t load. Check your connection, then try again.</p>
            <button type="button" class="map-error__retry" @click="retryTiles">
              Retry map
            </button>
          </div>

          <button
            v-if="mapReady"
            type="button"
            class="map-locate"
            aria-label="Recenter map"
            @click="recenter"
          >
            <LocateFixed :size="20" :stroke-width="2" />
          </button>

          <button
            v-if="mapReady && !sheetOpen && !detailOpen"
            type="button"
            class="map-cta"
            @click="openSheet"
          >
            <Coffee :size="24" :stroke-width="2" aria-hidden="true" />
            Show cafes near me
          </button>
        </div>

        <Transition name="tabbar">
          <AppTabBar v-if="showTabBar" active="map" />
        </Transition>
      </div>
    </IonContent>

    <NearbyCafesSheet
      v-model:open="sheetOpen"
      :cafes="sheetCafes"
      :selected-id="selectedId"
      :distances="distances"
      @present="onSheetPresent"
      @select="onSelectCafe"
    />

    <CafeDetailSheet
      v-model:open="detailOpen"
      :cafe="selectedCafe || lastDetailCafe"
      @present="onSheetPresent"
    />
  </IonPage>
</template>

<script lang="ts" setup>
import { ChevronLeft, Coffee, LocateFixed, Search } from 'lucide-vue-next'
import { Capacitor } from '@capacitor/core'
import { useIonRouter } from '@ionic/vue'
import KapeMap from '~/components/map/KapeMap.client.vue'
import NearbyCafesSheet from '~/components/map/NearbyCafesSheet.vue'
import CafeDetailSheet from '~/components/map/CafeDetailSheet.vue'
import AppTabBar from '~/components/navigation/AppTabBar.vue'
import type { Cafe } from '~/types/cafe'
import type { GeoBounds } from '~/utils/geography'
import { cafeMatchesQuery } from '~/utils/cafe-search'
import { distanceMeters, formatDistance } from '~/utils/geo'

const ionRouter = useIonRouter()
const { status: locationStatus, location, usingFallback, center, requestLocation } =
  useDeviceLocation()
const {
  viewportCafes,
  nearbyCafes,
  suggestions,
  cafeById,
  remember,
  loadNearby,
  loadViewport,
  searchCafes,
} = useMapCafes()

const query = ref('')
const submittedQuery = ref('')
const searchFocused = ref(false)
const activeIndex = ref(-1)
const sheetOpen = ref(false)
const detailOpen = ref(false)
const listWasOpen = ref(false)
const selectedId = ref<string | null>(null)
const mapReady = ref(false)
const tilesFailed = ref(false)
const mapEpoch = ref(0)
const mapRef = ref<{
  recenter: () => void
  focusCafe: (cafe: { lat: number; lng: number }, extraBottom?: number) => void
  invalidate: () => void
} | null>(null)

const mapSettled = computed(() => mapReady.value || tilesFailed.value)
const showTabBar = computed(() => !mapSettled.value)
const mapCenter = computed(() => (location.value ? center.value : null))
const accuracy = computed(() => location.value?.accuracy ?? 0)

const sheetCafes = computed(() => {
  const term = submittedQuery.value.trim()
  if (!term) return nearbyCafes.value
  return nearbyCafes.value.filter((cafe) => cafeMatchesQuery(cafe, term))
})
const visibleCafes = computed(() => {
  const selected = cafeById(selectedId.value)
  if (selected && !viewportCafes.value.some((cafe) => cafe.id === selected.id)) {
    return [...viewportCafes.value, selected]
  }
  return viewportCafes.value
})
const showSuggestions = computed(
  () => searchFocused.value && query.value.trim().length > 0,
)
const activeSuggestionId = computed(() => {
  const cafe = suggestions.value[activeIndex.value]
  return cafe ? `map-search-option-${cafe.id}` : undefined
})
const suggestionDistances = computed(() => {
  const origin = mapCenter.value
  if (!origin) return {}
  return Object.fromEntries(
    suggestions.value.map((cafe) => [cafe.id, formatDistance(distanceMeters(origin, cafe))]),
  )
})
const selectedCafe = computed(() => cafeById(selectedId.value))
const lastDetailCafe = ref<Cafe | null>(null)
watch(selectedCafe, (cafe) => {
  if (cafe) lastDetailCafe.value = cafe
})
const distances = computed(() => {
  const origin = mapCenter.value
  if (!origin) return {}
  return Object.fromEntries(
    sheetCafes.value.map((cafe) => [cafe.id, formatDistance(distanceMeters(origin, cafe))]),
  )
})

const headerPad = 188
const bottomPad = computed(() => {
  if (showTabBar.value) return 108
  if (sheetOpen.value || detailOpen.value) {
    return Math.round(window.innerHeight * 0.52)
  }
  return 96
})

const goBack = async () => {
  if (showSuggestions.value) {
    searchFocused.value = false
    return
  }
  if (detailOpen.value) {
    detailOpen.value = false
    return
  }
  if (sheetOpen.value) {
    sheetOpen.value = false
    return
  }
  if (ionRouter.canGoBack()) {
    ionRouter.back()
    return
  }
  await navigateTo('/app')
}

const onSearchFocus = () => {
  searchFocused.value = true
}

const onSearchBlur = () => {
  window.setTimeout(() => {
    searchFocused.value = false
    activeIndex.value = -1
  }, 120)
}

const onSearchKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape') {
    searchFocused.value = false
    activeIndex.value = -1
    return
  }

  if (!showSuggestions.value || suggestions.value.length === 0) return

  if (event.key === 'ArrowDown') {
    event.preventDefault()
    activeIndex.value = (activeIndex.value + 1) % suggestions.value.length
    return
  }

  if (event.key === 'ArrowUp') {
    event.preventDefault()
    activeIndex.value =
      activeIndex.value <= 0 ? suggestions.value.length - 1 : activeIndex.value - 1
    return
  }

  if (event.key === 'Enter' && activeIndex.value >= 0) {
    const cafe = suggestions.value[activeIndex.value]
    if (!cafe) return
    event.preventDefault()
    pickSuggestion(cafe)
  }
}

const pickSuggestion = (cafe: Cafe) => {
  remember([cafe])
  query.value = cafe.name
  submittedQuery.value = ''
  searchFocused.value = false
  activeIndex.value = -1
  onSelectCafe(cafe.id)
}

const submitSearch = () => {
  searchFocused.value = false
  activeIndex.value = -1
  submittedQuery.value = query.value.trim()
  window.setTimeout(() => {
    const matches = sheetCafes.value
    if (matches.length === 1 && matches[0]) {
      onSelectCafe(matches[0].id)
      return
    }
    sheetOpen.value = true
    if (selectedId.value && !matches.some((cafe) => cafe.id === selectedId.value)) {
      selectedId.value = null
    }
  }, 0)
}

const openSheet = () => {
  sheetOpen.value = true
}

const onSelectCafe = (id: string) => {
  selectedId.value = id
  if (sheetOpen.value) listWasOpen.value = true
  sheetOpen.value = false
  detailOpen.value = true
  const cafe = cafeById(id)
  if (!cafe) return
  const extra = Math.round(window.innerHeight * 0.52)
  mapRef.value?.focusCafe(cafe, extra)
}

const onViewChange = (view: { bounds: GeoBounds; center: { lat: number; lng: number } }) => {
  loadViewport(view.bounds, view.center)
}

const onTilesReady = () => {
  tilesFailed.value = false
  mapReady.value = true
  requestAnimationFrame(() => mapRef.value?.invalidate())
}

const onTilesError = () => {
  if (mapReady.value) return
  tilesFailed.value = true
}

const retryTiles = () => {
  mapReady.value = false
  tilesFailed.value = false
  mapEpoch.value += 1
}

const recenter = () => {
  mapRef.value?.recenter()
}

const refreshMap = () => {
  mapRef.value?.invalidate()
  window.setTimeout(() => mapRef.value?.invalidate(), 80)
  window.setTimeout(() => mapRef.value?.invalidate(), 320)
}

const onSheetPresent = () => {
  refreshMap()
}

watch(query, (value) => {
  activeIndex.value = -1
  searchCafes(value, mapCenter.value)
})

watch(
  mapCenter,
  (origin) => {
    if (origin) void loadNearby(origin)
  },
  { immediate: true },
)

watch(usingFallback, (fallback, previous) => {
  if (previous && !fallback) mapRef.value?.recenter()
})

watch(sheetOpen, (open) => {
  if (!open && !detailOpen.value) selectedId.value = null
  refreshMap()
})

watch(detailOpen, (open) => {
  if (!open) {
    selectedId.value = null
    const restoreList = listWasOpen.value
    listWasOpen.value = false
    if (restoreList) {
      window.setTimeout(() => {
        sheetOpen.value = true
      }, 320)
    }
  }
  refreshMap()
})

watch(visibleCafes, (list) => {
  if (selectedId.value && !list.some((cafe) => cafe.id === selectedId.value)) {
    selectedId.value = null
  }
})

onMounted(() => {
  if (Capacitor.getPlatform() === 'android') {
    document.documentElement.classList.add('is-android')
  }
  void requestLocation()
})
</script>

<style scoped>
.map-content {
  --background: var(--kd-secondary);
  --overflow: hidden;
  --padding-start: 0;
  --padding-end: 0;
  --padding-top: 0;
  --padding-bottom: 0;
}

.map-screen {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
  background: var(--kd-secondary);
}

.map-placeholder {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(circle at 18% 24%, color-mix(in srgb, var(--kd-white) 55%, transparent), transparent 36%),
    linear-gradient(180deg, var(--kd-white) 0%, var(--kd-secondary) 42%);
}

.map-chrome {
  position: absolute;
  inset: 0;
  z-index: 2;
  pointer-events: none;
}

.map-hero,
.map-banner,
.map-error,
.map-locate,
.map-cta,
.map-back,
.map-search,
.map-search__results,
.map-search__suggestion,
.map-banner__action,
.map-error__retry {
  pointer-events: auto;
}

.map-hero {
  position: relative;
  padding: max(2.75rem, calc(env(safe-area-inset-top) + 16px)) 20px 18px;
  background: linear-gradient(180deg, var(--kd-white) 0%, color-mix(in srgb, var(--kd-white) 0%, transparent) 100%);
}

.map-hero__bar {
  display: flex;
  align-items: center;
  gap: 10px;
  min-height: 30px;
}

.map-back {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  margin-left: -12px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-primary);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.map-back:focus-visible,
.map-search__submit:focus-visible,
.map-search__suggestion:focus-visible,
.map-locate:focus-visible,
.map-cta:focus-visible,
.map-banner__action:focus-visible,
.map-error__retry:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
  border-radius: 8px;
}

.map-brand {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
  flex: 1;
}

.map-brand__mark,
.map-brand__wordmark {
  display: block;
  object-fit: contain;
}

.map-brand__mark {
  width: 23px;
  height: 30px;
}

.map-brand__wordmark {
  width: 122px;
  height: 28px;
  object-position: left center;
}

.map-title {
  margin: 0;
  color: var(--kd-primary);
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.02em;
}

.map-search {
  position: relative;
  z-index: 3;
  margin-top: 16px;
}

.map-search__field {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 50px;
  padding: 0 8px 0 16px;
  border-radius: 8px;
  background: var(--kd-white);
  box-shadow: 0 2px 8px var(--kd-shadow);
}

.map-search__field input {
  width: 100%;
  min-width: 0;
  border: 0;
  background: transparent;
  color: var(--kd-ink);
  font-size: 12px;
  font-family: inherit;
  caret-color: var(--kd-primary);
}

.map-search__field input::placeholder {
  color: #5c534c;
}

.map-search__field input:focus {
  outline: none;
}

.map-search__field:focus-within {
  box-shadow: 0 2px 8px var(--kd-shadow), 0 0 0 2px var(--kd-white), 0 0 0 4px var(--kd-primary);
}

.map-search__field input::-webkit-search-decoration,
.map-search__field input::-webkit-search-cancel-button {
  -webkit-appearance: none;
}

.map-search__submit {
  display: grid;
  place-items: center;
  flex: 0 0 44px;
  width: 44px;
  height: 44px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-primary);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.map-search__results {
  position: absolute;
  top: calc(100% + 8px);
  left: 0;
  right: 0;
  z-index: 4;
  margin: 0;
  padding: 6px;
  max-height: min(42vh, 320px);
  overflow-y: auto;
  list-style: none;
  border-radius: 8px;
  background: var(--kd-white);
  box-shadow: 0 8px 24px var(--kd-shadow);
}

.map-search__empty {
  padding: 14px 12px;
  color: var(--kd-ink);
  font-size: 12px;
}

.map-search__suggestion {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 2px;
  width: 100%;
  min-height: 48px;
  padding: 10px 12px;
  border: 0;
  border-radius: 8px;
  background: transparent;
  text-align: left;
  font-family: inherit;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.map-search__suggestion.is-active,
.map-search__suggestion:hover {
  background: var(--kd-secondary);
}

.map-search__suggestion-name {
  color: var(--kd-primary);
  font-size: 14px;
  font-weight: 700;
  line-height: 1.3;
}

.map-search__suggestion-meta {
  color: var(--kd-ink);
  font-size: 12px;
  line-height: 1.35;
}

.map-banner,
.map-error {
  margin: 0 20px;
  padding: 10px 12px;
  border-radius: 8px;
  background: color-mix(in srgb, var(--kd-white) 92%, transparent);
  box-shadow: 0 2px 8px var(--kd-shadow);
  color: var(--kd-ink);
}

.map-banner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
}

.map-banner p,
.map-error p {
  margin: 0;
  font-size: 12px;
  line-height: 1.35;
}

.map-banner--quiet {
  display: block;
}

.map-banner__action,
.map-error__retry {
  flex-shrink: 0;
  min-height: 48px;
  height: 48px;
  padding: 0 12px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-primary);
  color: var(--kd-white);
  font-size: 12px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
}

.map-error {
  margin-top: 10px;
}

.map-error__retry {
  margin-top: 10px;
}

.map-locate {
  position: absolute;
  right: 20px;
  bottom: calc(env(safe-area-inset-bottom) + 76px);
  display: grid;
  place-items: center;
  width: 48px;
  height: 48px;
  padding: 0;
  border: 0;
  border-radius: 8px;
  background: var(--kd-white);
  color: var(--kd-primary);
  box-shadow: 0 2px 8px var(--kd-shadow);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  animation: map-rise 520ms cubic-bezier(0.16, 1, 0.3, 1) both;
}

.map-screen.is-sheet-open .map-locate {
  bottom: calc(52vh + 16px);
}

.map-cta {
  position: absolute;
  left: 20px;
  right: 20px;
  bottom: calc(env(safe-area-inset-bottom) + 16px);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
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
  animation: map-rise 560ms cubic-bezier(0.16, 1, 0.3, 1) both;
}

:root.is-android .map-cta {
  height: 48px;
  min-height: 48px;
}

.map-back:active,
.map-search__submit:active,
.map-search__suggestion:active,
.map-locate:active,
.map-cta:active,
.map-banner__action:active,
.map-error__retry:active {
  transform: scale(0.96);
}

.tabbar-enter-active,
.tabbar-leave-active {
  transition: opacity 280ms cubic-bezier(0.16, 1, 0.3, 1),
    transform 280ms cubic-bezier(0.16, 1, 0.3, 1);
}

.tabbar-enter-from,
.tabbar-leave-to {
  opacity: 0;
  transform: translateY(12px);
}

@keyframes map-rise {
  from {
    opacity: 0;
    transform: translateY(14px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
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

@media (min-width: 540px) {
  .map-screen {
    max-width: 480px;
    margin-inline: auto;
  }
}

@media (prefers-reduced-motion: reduce) {
  .map-cta,
  .map-locate,
  .tabbar-enter-active,
  .tabbar-leave-active {
    animation: none;
    transition-duration: 1ms;
  }

  .map-back:active,
  .map-search__submit:active,
  .map-search__suggestion:active,
  .map-locate:active,
  .map-cta:active {
    transform: none;
  }
}

::selection {
  background: var(--kd-secondary);
  color: var(--kd-primary);
}
</style>
