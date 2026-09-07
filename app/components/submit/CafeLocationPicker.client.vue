<template>
  <section class="picker" :class="{ 'is-overlay': overlay }" aria-labelledby="picker-title">
    <div class="picker__map">
      <div ref="root" class="picker__canvas" />
      <button
        type="button"
        class="picker__locate"
        aria-label="Use my location"
        @click="useMyLocation"
      >
        <LocateFixed :size="20" :stroke-width="2" />
      </button>
    </div>

    <div class="picker__search">
      <label class="picker__search-field">
        <span class="sr-only">Search an address in Marikina</span>
        <input
          v-model="query"
          type="search"
          name="address-search"
          placeholder="Search an address in Marikina"
          autocomplete="off"
          enterkeyhint="search"
          @keydown.enter.prevent="runSearch"
        />
        <button type="button" class="picker__icon-btn" aria-label="Search address" @click="runSearch">
          <Search :size="20" :stroke-width="2" />
        </button>
      </label>
    </div>

    <p v-if="searchError" class="picker__banner picker__banner--error" role="alert">
      {{ searchError }}
    </p>
    <p v-else-if="!inBounds" class="picker__banner picker__banner--error" role="alert">
      That pin is outside Marikina. Move it back into the city to continue.
    </p>

    <ul v-if="results.length" class="picker__results">
      <li v-for="result in results" :key="result.label">
        <button type="button" @click="chooseResult(result)">
          {{ result.label }}
        </button>
      </li>
    </ul>

    <div class="picker__peek">
      <div class="picker__copy">
        <h2 id="picker-title">Pin the cafe</h2>
        <p>Drag the pin or search so the marker sits on the shop, not the next street.</p>
      </div>

      <p v-if="locationNote" class="picker__banner" role="status">{{ locationNote }}</p>

      <label class="picker__field">
        <span>Address</span>
        <textarea
          :value="address"
          rows="2"
          name="address"
          autocomplete="street-address"
          placeholder="Street, barangay, Marikina"
          :aria-invalid="Boolean(addressIssue)"
          @input="emit('update:address', ($event.target as HTMLTextAreaElement).value)"
        />
      </label>
      <p v-if="addressIssue" class="picker__error" role="alert">{{ addressIssue }}</p>
    </div>
  </section>
</template>

<script lang="ts" setup>
import L from 'leaflet'
import type { Map as LeafletMap, Marker } from 'leaflet'
import 'leaflet/dist/leaflet.css'
import { LocateFixed, Search } from 'lucide-vue-next'
import type { LatLng } from '~/types/cafe'
import { reverseGeocode, searchMarikinaAddress } from '~/utils/geocode'
import { isInMarikina, MARIKINA_BOUNDS, MARIKINA_CENTER } from '~/utils/marikina'

const props = defineProps<{
  lat: number | null
  lng: number | null
  address: string
  addressIssue?: string | null
  overlay?: boolean
}>()

const emit = defineEmits<{
  'update:lat': [value: number]
  'update:lng': [value: number]
  'update:address': [value: string]
}>()

const { status: locationStatus, location, requestLocation } = useDeviceLocation()
const config = useRuntimeConfig()
const root = ref<HTMLElement | null>(null)
const query = ref('')
const searchError = ref('')
const locationNote = ref('')
const results = ref<{ label: string; point: LatLng }[]>([])
let previousLookup = ''
let map: LeafletMap | null = null
let marker: Marker | null = null

const point = computed<LatLng>(() => ({
  lat: props.lat ?? MARIKINA_CENTER.lat,
  lng: props.lng ?? MARIKINA_CENTER.lng,
}))

const inBounds = computed(() => isInMarikina(point.value))

const pinHtml = `<span class="kd-cafe-pin__mark kd-cafe-pin__mark--logo" aria-hidden="true">
  <img src="/assets/kapedoko-logo_dark.png" alt="" width="32" height="42" />
</span>`

const makeIcon = () =>
  L.divIcon({
    className: 'kd-cafe-pin is-selected',
    html: pinHtml,
    iconSize: [40, 52],
    iconAnchor: [20, 50],
  })

const setPoint = async (next: LatLng, lookup = true) => {
  emit('update:lat', next.lat)
  emit('update:lng', next.lng)
  marker?.setLatLng([next.lat, next.lng])
  map?.panTo([next.lat, next.lng])
  if (!lookup) return
  const label = await reverseGeocode(next)
  if (label && !props.address.trim()) emit('update:address', label)
  if (label && props.address.trim() && props.address === previousLookup) {
    emit('update:address', label)
  }
  previousLookup = label ?? previousLookup
}

const runSearch = async () => {
  searchError.value = ''
  results.value = []
  const found = await searchMarikinaAddress(query.value)
  if (!found.length) {
    searchError.value = 'No Marikina addresses matched that search. Move the pin instead.'
    return
  }
  results.value = found
}

const chooseResult = async (result: { label: string; point: LatLng }) => {
  results.value = []
  query.value = result.label
  emit('update:address', result.label)
  previousLookup = result.label
  await setPoint(result.point, false)
}

const useMyLocation = async () => {
  locationNote.value = ''
  await requestLocation()
  if (!location.value || locationStatus.value !== 'granted') {
    locationNote.value = 'Location is off. Drag the pin onto the cafe instead.'
    return
  }
  if (!isInMarikina(location.value)) {
    locationNote.value = 'Your location is outside Marikina. Pin the cafe on the map instead.'
    return
  }
  await setPoint(location.value)
}

const marikinaBounds = () =>
  L.latLngBounds(
    [MARIKINA_BOUNDS.south, MARIKINA_BOUNDS.west],
    [MARIKINA_BOUNDS.north, MARIKINA_BOUNDS.east],
  )

const init = () => {
  if (!root.value) return

  map = L.map(root.value, {
    zoomControl: false,
    attributionControl: true,
    maxBounds: marikinaBounds().pad(0.18),
    maxBoundsViscosity: 0.85,
  })
  map.attributionControl?.setPrefix('')
  map.setView([point.value.lat, point.value.lng], 15)

  L.tileLayer(config.public.mapTiles.url, {
    attribution: config.public.mapTiles.attribution,
    maxZoom: 19,
  }).addTo(map)

  L.rectangle(marikinaBounds(), {
    color: '#372d25',
    weight: 1,
    fill: false,
    interactive: false,
  }).addTo(map)

  marker = L.marker([point.value.lat, point.value.lng], {
    icon: makeIcon(),
    draggable: true,
    autoPan: true,
    keyboard: true,
    title: 'Cafe location',
  }).addTo(map)

  marker.on('dragend', () => {
    const next = marker?.getLatLng()
    if (!next) return
    void setPoint({ lat: next.lat, lng: next.lng })
  })

  map.on('click', (event) => {
    void setPoint({ lat: event.latlng.lat, lng: event.latlng.lng })
  })

  if (props.lat == null || props.lng == null) {
    void setPoint(MARIKINA_CENTER)
  }

  requestAnimationFrame(() => map?.invalidateSize({ animate: false }))
  window.setTimeout(() => map?.invalidateSize({ animate: false }), 80)
  window.setTimeout(() => map?.invalidateSize({ animate: false }), 320)
}

onMounted(() => {
  try {
    init()
  } catch {
    searchError.value = 'The map couldn’t load. Check your connection, then try again.'
  }
})

onBeforeUnmount(() => {
  map?.remove()
  map = null
  marker = null
})
</script>

<style scoped>
.picker {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 0;
  flex: 1;
}

.picker.is-overlay {
  position: relative;
  z-index: 1;
  display: grid;
  grid-template-rows: 1fr auto;
  gap: 0;
  height: 100%;
  min-height: 0;
}

.picker__copy h2 {
  margin: 0;
  color: var(--kd-primary);
  font-size: 16px;
  font-weight: 700;
  line-height: 1.2;
}

.picker__copy p,
.picker__error {
  margin: 4px 0 0;
  color: var(--kd-ink);
  font-size: 12px;
  line-height: 1.35;
}

.picker__error {
  color: var(--kd-closed);
  font-weight: 700;
}

.picker__search {
  position: relative;
  z-index: 2;
}

.picker.is-overlay .picker__search {
  position: absolute;
  top: calc(max(2.75rem, env(safe-area-inset-top) + 16px) + 62px);
  left: 20px;
  right: 20px;
  grid-row: 1;
}

.picker__search-field {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 50px;
  padding: 0 8px 0 16px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-white);
  box-shadow: 0 2px 8px var(--kd-shadow);
}

.picker__search-field input,
.picker__field textarea {
  width: 100%;
  min-width: 0;
  border: 0;
  background: transparent;
  color: var(--kd-ink);
  font-size: 16px;
  font-weight: 400;
  font-family: inherit;
  caret-color: var(--kd-primary);
}

.picker__search-field input {
  font-size: 12px;
}

.picker__field textarea {
  font-size: 12px;
  line-height: 1.35;
}

.picker__search-field input::-webkit-search-decoration,
.picker__search-field input::-webkit-search-cancel-button {
  -webkit-appearance: none;
}

.picker__search-field input::placeholder,
.picker__field textarea::placeholder {
  color: #5c534c;
}

.picker__field textarea {
  display: block;
  min-height: 64px;
  max-height: 88px;
  padding: 12px 16px;
  overflow: auto;
  resize: none;
  border-radius: 8px;
  background: var(--kd-secondary);
}

.picker__search-field input:focus,
.picker__field textarea:focus {
  outline: none;
}

.picker__search-field:focus-within,
.picker__field textarea:focus {
  box-shadow: 0 2px 8px var(--kd-shadow), 0 0 0 2px var(--kd-white), 0 0 0 4px var(--kd-primary);
}

.picker__field textarea:focus {
  box-shadow: 0 0 0 2px var(--kd-white), 0 0 0 4px var(--kd-primary);
}

.picker__icon-btn,
.picker__locate {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  padding: 0;
  border: 0;
  border-radius: 8px;
  background: transparent;
  color: var(--kd-primary);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.picker__locate {
  position: absolute;
  z-index: 500;
  right: 20px;
  bottom: 16px;
  width: 48px;
  height: 48px;
  background: var(--kd-white);
  box-shadow: 0 2px 8px var(--kd-shadow);
}

.picker__banner {
  position: relative;
  z-index: 2;
  margin: 0;
  padding: 10px 12px;
  border-radius: 8px;
  background: color-mix(in srgb, var(--kd-white) 92%, transparent);
  box-shadow: 0 2px 8px var(--kd-shadow);
  color: var(--kd-ink);
  font-size: 12px;
}

.picker.is-overlay .picker__banner {
  position: absolute;
  top: calc(max(2.75rem, env(safe-area-inset-top) + 16px) + 122px);
  left: 20px;
  right: 20px;
  grid-row: 1;
}

.picker.is-overlay .picker__peek .picker__banner {
  position: static;
  top: auto;
  left: auto;
  right: auto;
  margin: 8px 0 0;
}

.picker__banner--error {
  color: var(--kd-closed);
  font-weight: 700;
}

.picker__results {
  position: relative;
  z-index: 2;
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin: 0;
  padding: 0;
  list-style: none;
}

.picker.is-overlay .picker__results {
  position: absolute;
  top: calc(max(2.75rem, env(safe-area-inset-top) + 16px) + 122px);
  left: 20px;
  right: 20px;
  grid-row: 1;
  max-height: 36vh;
  overflow: auto;
}

.picker__results button {
  width: 100%;
  min-height: 44px;
  padding: 10px 12px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-white);
  box-shadow: 0 2px 8px var(--kd-shadow);
  color: var(--kd-ink);
  font-size: 12px;
  text-align: left;
  font-family: inherit;
  cursor: pointer;
}

.picker__map {
  position: relative;
  flex: 1;
  min-height: 240px;
  overflow: hidden;
  border-radius: 8px;
  background: var(--kd-secondary);
}

.picker.is-overlay .picker__map {
  position: relative;
  z-index: 0;
  grid-row: 1;
  flex: none;
  min-height: 0;
  height: 100%;
  border-radius: 0;
}

.picker__canvas {
  width: 100%;
  height: 100%;
  min-height: 240px;
}

.picker.is-overlay .picker__canvas {
  min-height: 0;
}

.picker__peek {
  position: relative;
  z-index: 2;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.picker.is-overlay .picker__peek {
  grid-row: 2;
  margin-top: auto;
  padding: 16px 20px 8px;
  border-radius: 8px 8px 0 0;
  background: var(--kd-white);
  box-shadow: 0 -2px 16px var(--kd-shadow);
  animation: submit-peek 220ms cubic-bezier(0.16, 1, 0.3, 1) both;
}

@keyframes submit-peek {
  from {
    opacity: 0;
    transform: translateY(16px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.picker__field {
  display: flex;
  flex-direction: column;
  gap: 8px;
  color: var(--kd-primary);
  font-size: 12px;
  font-weight: 700;
}

.picker :deep(.leaflet-container) {
  width: 100%;
  height: 100%;
  font-family: inherit;
  background: var(--kd-secondary);
}

.picker :deep(.leaflet-tile-pane) {
  filter: sepia(0.32) saturate(0.62) hue-rotate(-12deg) brightness(1.03);
}

.picker :deep(.leaflet-control-attribution) {
  max-width: min(72vw, 280px);
  margin: 0 12px 10px 0;
  padding: 4px 8px;
  border-radius: 4px;
  background: color-mix(in srgb, var(--kd-white) 88%, transparent);
  color: var(--kd-ink);
  font-size: 10px;
}

.picker.is-overlay :deep(.leaflet-control-attribution) {
  margin-bottom: 12px;
}

.picker :deep(.kd-cafe-pin) {
  display: grid;
  place-items: end center;
  filter: drop-shadow(0 4px 8px var(--kd-shadow));
}

.picker :deep(.kd-cafe-pin__mark--logo img) {
  display: block;
  width: 40px;
  height: 52px;
  object-fit: contain;
}

.picker__icon-btn:focus-visible,
.picker__locate:focus-visible,
.picker__results button:focus-visible,
.picker__search-field:focus-within,
.picker__field textarea:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.picker__search-field:focus-within,
.picker__field textarea:focus-visible {
  outline: none;
}

.picker__icon-btn:active,
.picker__locate:active,
.picker__results button:active {
  transform: scale(0.96);
}

@media (prefers-reduced-motion: reduce) {
  .picker.is-overlay .picker__peek {
    animation: none;
  }

  .picker__icon-btn:active,
  .picker__locate:active,
  .picker__results button:active {
    transform: none;
  }
}

::selection {
  background: var(--kd-secondary);
  color: var(--kd-primary);
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
</style>
