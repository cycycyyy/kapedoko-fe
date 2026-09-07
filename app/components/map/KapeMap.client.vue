<template>
  <div class="kape-map" :class="{ 'is-sheet-open': sheetOpen }">
    <div ref="root" class="kape-map__canvas" />
  </div>
</template>

<script lang="ts" setup>
import L from 'leaflet'
import type { Circle, Map as LeafletMap, Marker, TileLayer } from 'leaflet'
import 'leaflet/dist/leaflet.css'
import type { Cafe, LatLng } from '~/types/cafe'
import { SEARCH_RADIUS_M } from '~/utils/geo'

const props = defineProps<{
  center: LatLng
  accuracy: number
  cafes: Cafe[]
  selectedId: string | null
  sheetOpen: boolean
  headerPad: number
  bottomPad: number
}>()

const emit = defineEmits<{
  tilesReady: []
  tilesError: []
  select: [id: string]
}>()

const config = useRuntimeConfig()
const root = ref<HTMLElement | null>(null)

let map: LeafletMap | null = null
let tileLayer: TileLayer | null = null
let userMarker: Marker | null = null
let accuracyCircle: Circle | null = null
let radiusCircle: Circle | null = null
const cafeMarkers = new Map<string, Marker>()
let tilesSettled = false
let sizeTimer: ReturnType<typeof window.setInterval> | null = null

const prefersReducedMotion = () =>
  typeof window !== 'undefined' && window.matchMedia('(prefers-reduced-motion: reduce)').matches

const cafeIconHtml = (selected: boolean) => {
  if (selected) {
    return `<span class="kd-cafe-pin__mark kd-cafe-pin__mark--logo" aria-hidden="true">
      <img src="/assets/kapedoko-logo_dark.png" alt="" width="32" height="42" />
    </span>`
  }

  return `<span class="kd-cafe-pin__mark" aria-hidden="true">
    <svg viewBox="0 0 40 40" fill="none" aria-hidden="true">
      <circle
        cx="20"
        cy="20"
        r="16.2"
        fill="currentColor"
        stroke="var(--kd-white)"
        stroke-width="3.2"
        paint-order="stroke fill"
      />
      <path
        d="M15.6 10.8v3.8M21.4 10.3v4.2"
        stroke="var(--kd-white)"
        stroke-width="2.2"
        stroke-linecap="round"
      />
      <path
        d="M11.4 16.4h14.4v7.4a3.7 3.7 0 0 1-3.7 3.7h-7a3.7 3.7 0 0 1-3.7-3.7z"
        fill="var(--kd-white)"
      />
      <path
        d="M25.8 18.1c3.6.15 4.4 2.55 4.4 4s-1 3.9-4.45 4.05"
        stroke="var(--kd-white)"
        stroke-width="2.5"
        stroke-linecap="round"
      />
    </svg>
  </span>`
}

const makeCafeIcon = (selected: boolean) => {
  const width = selected ? 40 : 36
  const height = selected ? 52 : 36
  return L.divIcon({
    className: `kd-cafe-pin${selected ? ' is-selected' : ''}`,
    html: cafeIconHtml(selected),
    iconSize: [width, height],
    iconAnchor: selected ? [width / 2, height - 2] : [width / 2, height / 2],
  })
}

const makeUserIcon = () => {
  return L.divIcon({
    className: 'kd-user-dot',
    html: '<span class="kd-user-dot__pulse"></span><span class="kd-user-dot__core"></span>',
    iconSize: [22, 22],
    iconAnchor: [11, 11],
  })
}

const fitToRadius = (animate = true) => {
  if (!map) return
  const lat = props.center.lat
  const lng = props.center.lng
  const latDelta = SEARCH_RADIUS_M / 111_320
  const lngDelta = SEARCH_RADIUS_M / (111_320 * Math.cos((lat * Math.PI) / 180))
  const bounds = L.latLngBounds(
    [lat - latDelta, lng - lngDelta],
    [lat + latDelta, lng + lngDelta],
  )

  map.fitBounds(bounds, {
    paddingTopLeft: [20, props.headerPad],
    paddingBottomRight: [20, props.bottomPad],
    maxZoom: 15,
    animate: animate && !prefersReducedMotion(),
  })
}

const syncUser = () => {
  if (!map) return
  const latlng: [number, number] = [props.center.lat, props.center.lng]

  if (!userMarker) {
    userMarker = L.marker(latlng, {
      icon: makeUserIcon(),
      zIndexOffset: 600,
      interactive: false,
      keyboard: false,
    }).addTo(map)
  } else {
    userMarker.setLatLng(latlng)
  }

  if (props.accuracy > 0) {
    const haloRadius = Math.min(Math.max(props.accuracy, 18), 220)
    if (!accuracyCircle) {
      accuracyCircle = L.circle(latlng, {
        radius: haloRadius,
        color: '#372d25',
        weight: 1,
        fillColor: '#372d25',
        fillOpacity: 0.08,
        interactive: false,
      }).addTo(map)
    } else {
      accuracyCircle.setLatLng(latlng)
      accuracyCircle.setRadius(haloRadius)
    }
  } else if (accuracyCircle) {
    map.removeLayer(accuracyCircle)
    accuracyCircle = null
  }

  if (!radiusCircle) {
    radiusCircle = L.circle(latlng, {
      radius: SEARCH_RADIUS_M,
      stroke: false,
      fill: false,
      interactive: false,
    }).addTo(map)
  } else {
    radiusCircle.setLatLng(latlng)
  }
}

const syncCafes = () => {
  if (!map) return
  const seen = new Set<string>()

  for (const cafe of props.cafes) {
    seen.add(cafe.id)
    const latlng: [number, number] = [cafe.lat, cafe.lng]
    const selected = cafe.id === props.selectedId
    const existing = cafeMarkers.get(cafe.id)

    if (!existing) {
      const marker = L.marker(latlng, {
        icon: makeCafeIcon(selected),
        title: cafe.name,
        keyboard: true,
        zIndexOffset: selected ? 500 : 200,
      })
      marker.on('click', () => emit('select', cafe.id))
      marker.addTo(map)
      cafeMarkers.set(cafe.id, marker)
    } else {
      existing.setLatLng(latlng)
      existing.setIcon(makeCafeIcon(selected))
      existing.setZIndexOffset(selected ? 500 : 200)
    }
  }

  for (const [id, marker] of cafeMarkers) {
    if (seen.has(id)) continue
    map.removeLayer(marker)
    cafeMarkers.delete(id)
  }
}

const focusCafe = (cafe: Cafe, extraBottom = 0) => {
  if (!map) return
  const target = map.project([cafe.lat, cafe.lng], map.getZoom())
  target.y += extraBottom / 2
  const latlng = map.unproject(target, map.getZoom())
  map.panTo(latlng, { animate: !prefersReducedMotion() })
}

const invalidate = () => {
  map?.invalidateSize({ animate: false })
}

const destroy = () => {
  if (sizeTimer) {
    window.clearInterval(sizeTimer)
    sizeTimer = null
  }
  if (!map) return
  map.remove()
  map = null
  tileLayer = null
  userMarker = null
  accuracyCircle = null
  radiusCircle = null
  cafeMarkers.clear()
}

const init = () => {
  if (!root.value) return

  destroy()
  tilesSettled = false

  map = L.map(root.value, {
    zoomControl: false,
    attributionControl: true,
    fadeAnimation: !prefersReducedMotion(),
    zoomAnimation: !prefersReducedMotion(),
    markerZoomAnimation: !prefersReducedMotion(),
  })

  map.attributionControl?.setPrefix('')
  map.setView([props.center.lat, props.center.lng], 14)

  tileLayer = L.tileLayer(config.public.mapTiles.url, {
    attribution: config.public.mapTiles.attribution,
    maxZoom: 19,
  })

  const markReady = () => {
    if (tilesSettled) return
    tilesSettled = true
    emit('tilesReady')
    requestAnimationFrame(() => invalidate())
  }

  tileLayer.on('load', markReady)
  tileLayer.on('tileload', markReady)

  tileLayer.on('tileerror', () => {
    window.setTimeout(() => {
      if (!tilesSettled) {
        tilesSettled = true
        emit('tilesError')
      }
    }, 8000)
  })

  tileLayer.addTo(map)
  syncUser()
  syncCafes()
  fitToRadius(false)
  requestAnimationFrame(() => invalidate())
  sizeTimer = window.setInterval(() => invalidate(), 250)
  window.setTimeout(() => {
    if (sizeTimer) {
      window.clearInterval(sizeTimer)
      sizeTimer = null
    }
  }, 1200)

  window.setTimeout(() => {
    if (!tilesSettled) {
      tilesSettled = true
      emit('tilesError')
    }
  }, 14000)
}

onMounted(() => {
  try {
    init()
  } catch {
    emit('tilesError')
  }
  window.addEventListener('resize', invalidate)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', invalidate)
  destroy()
})

watch(
  () => [props.center.lat, props.center.lng, props.accuracy],
  () => {
    syncUser()
    fitToRadius()
  },
)

watch(
  () => [props.cafes, props.selectedId],
  () => syncCafes(),
  { deep: true },
)

watch(
  () => [props.headerPad, props.bottomPad],
  () => invalidate(),
)

defineExpose({
  recenter: () => fitToRadius(),
  focusCafe,
  invalidate,
})
</script>

<style scoped>
.kape-map {
  position: absolute;
  inset: 0;
  z-index: 0;
  background: var(--kd-secondary);
}

.kape-map__canvas {
  width: 100%;
  height: 100%;
}

.kape-map :deep(.leaflet-container) {
  width: 100%;
  height: 100%;
  font-family: inherit;
  background: var(--kd-secondary);
}

.kape-map :deep(img.leaflet-tile) {
  max-width: none !important;
  max-height: none !important;
}

.kape-map :deep(.leaflet-tile-pane) {
  filter: sepia(0.32) saturate(0.62) hue-rotate(-12deg) brightness(1.03);
}

.kape-map :deep(.leaflet-control-attribution) {
  max-width: min(72vw, 280px);
  margin: 0 12px 10px 0;
  padding: 4px 8px;
  border-radius: 4px;
  background: color-mix(in srgb, var(--kd-white) 88%, transparent);
  color: var(--kd-ink);
  font-size: 10px;
  line-height: 1.3;
}

.kape-map :deep(.leaflet-control-attribution a) {
  color: var(--kd-primary);
}

.kape-map :deep(.leaflet-bottom) {
  bottom: calc(env(safe-area-inset-bottom) + 72px);
  z-index: 1;
  pointer-events: auto;
}

.kape-map.is-sheet-open :deep(.leaflet-bottom) {
  bottom: calc(52vh + 12px);
}

.kape-map :deep(.kd-cafe-pin) {
  display: grid;
  place-items: center;
  color: var(--kd-primary);
  filter: drop-shadow(0 3px 5px var(--kd-shadow));
  transform-origin: center center;
  animation: kd-pin-in 420ms cubic-bezier(0.16, 1, 0.3, 1) both;
}

.kape-map :deep(.kd-cafe-pin.is-selected) {
  place-items: end center;
  transform-origin: center bottom;
  filter: drop-shadow(0 4px 8px var(--kd-shadow));
}

.kape-map :deep(.kd-cafe-pin:focus-visible) {
  outline: 2px solid var(--kd-white);
  outline-offset: 2px;
  border-radius: 999px;
}

.kape-map :deep(.kd-cafe-pin.is-selected:focus-visible) {
  border-radius: 8px;
}

.kape-map :deep(.kd-cafe-pin__mark),
.kape-map :deep(.kd-cafe-pin svg) {
  display: block;
  width: 100%;
  height: 100%;
}

.kape-map :deep(.kd-cafe-pin__mark--logo img) {
  display: block;
  width: 100%;
  height: 100%;
  max-width: none;
  object-fit: contain;
}

.kape-map :deep(.kd-user-dot) {
  display: grid;
  place-items: center;
}

.kape-map :deep(.kd-user-dot__core) {
  width: 14px;
  height: 14px;
  border-radius: 999px;
  background: var(--kd-primary);
  border: 2px solid var(--kd-white);
  box-shadow: 0 2px 6px var(--kd-shadow);
}

.kape-map :deep(.kd-user-dot__pulse) {
  position: absolute;
  width: 14px;
  height: 14px;
  border-radius: 999px;
  background: var(--kd-primary);
  animation: kd-user-pulse 2.2s cubic-bezier(0.16, 1, 0.3, 1) infinite;
}

@keyframes kd-pin-in {
  from {
    opacity: 0;
    transform: translateY(8px) scale(0.86);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

@keyframes kd-user-pulse {
  0% {
    transform: scale(1);
    opacity: 0.45;
  }
  70% {
    transform: scale(2.6);
    opacity: 0;
  }
  100% {
    transform: scale(2.6);
    opacity: 0;
  }
}

@media (prefers-reduced-motion: reduce) {
  .kape-map :deep(.kd-cafe-pin),
  .kape-map :deep(.kd-user-dot__pulse) {
    animation: none;
  }
}
</style>
