<template>
  <div class="teach-map" aria-hidden="true">
    <div ref="root" class="teach-map__canvas" />

    <div v-if="tilesFailed" class="teach-map__fail">
      <p>Map didn’t load.</p>
    </div>
  </div>
</template>

<script lang="ts" setup>
import L from 'leaflet'
import type { Map as LeafletMap, Marker } from 'leaflet'
import 'leaflet/dist/leaflet.css'
import { KAPEDOKO_BEAN_PIN_SRC } from '~/utils/logo'
import { ONBOARDING_TEACH_MAP } from '~/utils/maps'
import { escapeHtml } from '~/utils/marker-tier'

const props = defineProps<{
  active: boolean
}>()

const config = useRuntimeConfig()
const root = ref<HTMLElement | null>(null)
const tilesFailed = ref(false)

let map: LeafletMap | null = null
let pin: Marker | null = null
let resizeObserver: ResizeObserver | null = null
let failTimer: ReturnType<typeof window.setTimeout> | null = null
let pinTimer: ReturnType<typeof window.setTimeout> | null = null
let played = false
let mapReady = false

const center = (): [number, number] => [ONBOARDING_TEACH_MAP.lat, ONBOARDING_TEACH_MAP.lng]

const prefersReducedMotion = () =>
  typeof window !== 'undefined' && window.matchMedia('(prefers-reduced-motion: reduce)').matches

const pinHtml = () =>
  `<span class="kd-teach-pin__stack">
    <span class="kd-teach-pin__mark">
      <img src="${KAPEDOKO_BEAN_PIN_SRC}" alt="" width="32" height="36" />
    </span>
    <span class="kd-teach-pin__label">${escapeHtml(ONBOARDING_TEACH_MAP.label)}</span>
  </span>`

const makeIcon = (entering: boolean) =>
  L.divIcon({
    className: `leaflet-div-icon kd-teach-pin${entering ? ' is-entering' : ''}`,
    html: pinHtml(),
    iconSize: [108, 72],
    iconAnchor: [54, 44],
  })

const placePin = (entering: boolean) => {
  if (!map || pin) return
  pin = L.marker(center(), {
    icon: makeIcon(entering),
    interactive: false,
    keyboard: false,
    zIndexOffset: 800,
  }).addTo(map)
  if (entering) {
    window.setTimeout(() => {
      pin?.getElement()?.classList.remove('is-entering')
    }, 520)
  }
}

const playEntrance = () => {
  if (!map || played) return
  played = true

  if (prefersReducedMotion()) {
    map.setView(center(), ONBOARDING_TEACH_MAP.endZoom, { animate: false })
    placePin(false)
    return
  }

  map.flyTo(center(), ONBOARDING_TEACH_MAP.endZoom, {
    duration: 1.35,
    easeLinearity: 0.22,
    animate: true,
  })
  pinTimer = window.setTimeout(() => placePin(true), 1600)
  map.once('moveend', () => {
    if (pinTimer) {
      window.clearTimeout(pinTimer)
      pinTimer = null
    }
    placePin(true)
  })
}

const destroy = () => {
  resizeObserver?.disconnect()
  resizeObserver = null
  if (failTimer) {
    window.clearTimeout(failTimer)
    failTimer = null
  }
  if (pinTimer) {
    window.clearTimeout(pinTimer)
    pinTimer = null
  }
  map?.remove()
  map = null
  pin = null
  mapReady = false
  played = false
}

const init = () => {
  if (!root.value || map) return
  tilesFailed.value = false
  mapReady = false
  played = false

  map = L.map(root.value, {
    zoomControl: false,
    attributionControl: true,
    dragging: false,
    scrollWheelZoom: false,
    doubleClickZoom: false,
    boxZoom: false,
    keyboard: false,
    touchZoom: false,
    fadeAnimation: !prefersReducedMotion(),
    zoomAnimation: !prefersReducedMotion(),
    markerZoomAnimation: !prefersReducedMotion(),
  })
  map.attributionControl?.setPrefix('')
  map.setView(
    center(),
    prefersReducedMotion() ? ONBOARDING_TEACH_MAP.endZoom : ONBOARDING_TEACH_MAP.startZoom,
    { animate: false },
  )

  const tiles = L.tileLayer(config.public.mapTiles.url, {
    attribution: config.public.mapTiles.attribution,
    maxZoom: 19,
  })

  const markReady = () => {
    if (mapReady) return
    mapReady = true
    if (failTimer) {
      window.clearTimeout(failTimer)
      failTimer = null
    }
    requestAnimationFrame(() => {
      map?.invalidateSize({ animate: false })
      window.setTimeout(playEntrance, prefersReducedMotion() ? 0 : 280)
    })
  }

  tiles.on('load', markReady)
  tiles.on('tileload', markReady)
  failTimer = window.setTimeout(() => {
    if (mapReady) return
    tilesFailed.value = true
    playEntrance()
  }, 8000)
  tiles.addTo(map)

  resizeObserver = new ResizeObserver(() => map?.invalidateSize({ animate: false }))
  resizeObserver.observe(root.value)
  requestAnimationFrame(() => map?.invalidateSize({ animate: false }))
}

watch(
  () => props.active,
  (active) => {
    if (!active) return
    if (!map) init()
    else requestAnimationFrame(() => map?.invalidateSize({ animate: false }))
  },
)

onMounted(() => {
  if (props.active) init()
})

onBeforeUnmount(destroy)
</script>

<style scoped>
.teach-map {
  position: relative;
  height: min(42vh, 280px);
  min-height: 220px;
  overflow: hidden;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 34%, transparent);
  border-radius: 16px;
  background: #faf8f5;
}

.teach-map__canvas {
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.teach-map :deep(.leaflet-container) {
  width: 100%;
  height: 100%;
  font-family: inherit;
  background: #faf8f5;
}

.teach-map :deep(img.leaflet-tile) {
  max-width: none !important;
  max-height: none !important;
}

.teach-map :deep(.leaflet-tile-pane) {
  filter: sepia(0.32) saturate(0.62) hue-rotate(-12deg) brightness(1.03);
}

.teach-map :deep(.leaflet-control-attribution) {
  pointer-events: auto;
  max-width: min(58vw, 220px);
  margin: 0 8px 8px 0;
  padding: 3px 7px;
  border-radius: 4px;
  background: color-mix(in srgb, #faf8f5 90%, transparent);
  color: var(--kd-ink);
  font-size: 10px;
  line-height: 1.3;
}

.teach-map :deep(.leaflet-control-attribution a) {
  color: var(--kd-ink);
}

.teach-map :deep(.leaflet-marker-pane) {
  filter: none;
}

.teach-map :deep(.leaflet-div-icon.kd-teach-pin) {
  background: transparent;
  border: 0;
}

.teach-map :deep(.kd-teach-pin) {
  display: grid;
  place-items: start center;
  color: var(--kd-ink);
}

.teach-map :deep(.kd-teach-pin__stack) {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 0;
}

.teach-map :deep(.kd-teach-pin__mark) {
  display: block;
  width: 40px;
  height: 44px;
  filter: drop-shadow(0 4px 8px color-mix(in srgb, #000 16%, transparent));
  transform-origin: center bottom;
}

.teach-map :deep(.kd-teach-pin.is-entering .kd-teach-pin__mark),
.teach-map :deep(.kd-teach-pin.is-entering .kd-teach-pin__label) {
  animation: teach-pin-drop 520ms cubic-bezier(0.16, 1, 0.3, 1) both;
}

.teach-map :deep(.kd-teach-pin.is-entering .kd-teach-pin__label) {
  animation-name: teach-ticket-stamp;
  animation-delay: 80ms;
}

.teach-map :deep(.kd-teach-pin__mark img) {
  display: block;
  width: 100% !important;
  height: 100% !important;
  max-width: none !important;
  max-height: none !important;
  object-fit: contain;
}

.teach-map :deep(.kd-teach-pin__label) {
  max-width: 108px;
  margin-top: 4px;
  padding: 3px 8px;
  overflow: hidden;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 22%, transparent);
  border-radius: 8px;
  background: #faf8f5;
  color: var(--kd-ink);
  font-size: 0.6875rem;
  font-weight: 700;
  line-height: 1.2;
  white-space: nowrap;
  text-overflow: ellipsis;
  box-shadow: 0 3px 8px color-mix(in srgb, #000 12%, transparent);
}

.teach-map__fail {
  position: absolute;
  inset: 0;
  z-index: 500;
  display: grid;
  place-content: center;
  padding: 20px;
  background: color-mix(in srgb, #faf8f5 92%, transparent);
  color: var(--kd-ink);
  text-align: center;
}

.teach-map__fail p {
  margin: 0;
  font-size: 0.7875rem;
  font-weight: 700;
}

@keyframes teach-pin-drop {
  from {
    opacity: 0;
    filter: blur(2px);
    transform: translateY(-18px) scale(1.12);
  }
  to {
    opacity: 1;
    filter: none;
    transform: translateY(0) scale(1);
  }
}

@keyframes teach-ticket-stamp {
  from {
    opacity: 0;
    filter: blur(2px);
    transform: translateY(-8px) rotate(-4deg) scale(0.92);
  }
  to {
    opacity: 1;
    filter: none;
    transform: translateY(0) rotate(0deg) scale(1);
  }
}

@media (prefers-reduced-motion: reduce) {
  .teach-map :deep(.kd-teach-pin.is-entering .kd-teach-pin__mark),
  .teach-map :deep(.kd-teach-pin.is-entering .kd-teach-pin__label) {
    animation: none;
  }
}
</style>
