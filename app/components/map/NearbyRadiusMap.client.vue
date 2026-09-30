<template>
  <div class="nearby-preview-map" aria-hidden="true">
    <div ref="root" class="nearby-preview-map__canvas" />
  </div>
</template>

<script lang="ts" setup>
import L from 'leaflet'
import type { Circle, Map as LeafletMap, Marker, TileLayer } from 'leaflet'
import 'leaflet/dist/leaflet.css'
import type { Cafe, LatLng } from '~/types/cafe'

const props = defineProps<{
  center: LatLng
  accuracy: number
  cafes: Cafe[]
  radiusMeters: number
}>()

const emit = defineEmits<{
  tilesReady: []
  tilesError: []
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

const makeCafeIcon = () => L.divIcon({
  className: 'leaflet-div-icon kd-preview-pin',
  html: '<span class="kd-preview-pin__dot"></span>',
  iconSize: [14, 14],
  iconAnchor: [7, 7],
})

const makeUserIcon = () => L.divIcon({
  className: 'leaflet-div-icon kd-preview-you',
  html: '<span class="kd-preview-you__pulse"></span><span class="kd-preview-you__core"></span>',
  iconSize: [22, 22],
  iconAnchor: [11, 11],
})

const fitToRadius = () => {
  if (!map) return
  const lat = props.center.lat
  const lng = props.center.lng
  const radius = Math.max(props.radiusMeters, 250)
  const latDelta = radius / 111_320
  const lngDelta = radius / (111_320 * Math.cos((lat * Math.PI) / 180) || 1)
  map.fitBounds(
    L.latLngBounds(
      [lat - latDelta, lng - lngDelta],
      [lat + latDelta, lng + lngDelta],
    ),
    {
      padding: [18, 18],
      animate: false,
    },
  )
}

const syncUser = () => {
  if (!map) return
  const latlng: [number, number] = [props.center.lat, props.center.lng]

  if (!userMarker) {
    userMarker = L.marker(latlng, {
      icon: makeUserIcon(),
      zIndexOffset: 900,
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
        color: '#1c1917',
        weight: 1,
        fillColor: '#1c1917',
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
      radius: props.radiusMeters,
      color: '#1F6F6B',
      weight: 1.5,
      fillColor: '#1F6F6B',
      fillOpacity: 0.08,
      interactive: false,
    }).addTo(map)
  } else {
    radiusCircle.setLatLng(latlng)
    radiusCircle.setRadius(props.radiusMeters)
  }
}

const syncCafes = () => {
  if (!map) return
  const seen = new Set<string>()

  for (const cafe of props.cafes) {
    if (!Number.isFinite(cafe.lat) || !Number.isFinite(cafe.lng)) continue
    seen.add(cafe.id)
    const existing = cafeMarkers.get(cafe.id)
    const latlng: [number, number] = [cafe.lat, cafe.lng]
    if (!existing) {
      const marker = L.marker(latlng, {
        icon: makeCafeIcon(),
        title: cafe.name,
        interactive: false,
        keyboard: false,
        zIndexOffset: 400,
      }).addTo(map)
      cafeMarkers.set(cafe.id, marker)
    } else {
      const current = existing.getLatLng()
      if (current.lat !== latlng[0] || current.lng !== latlng[1]) {
        existing.setLatLng(latlng)
      }
    }
  }

  for (const [id, marker] of cafeMarkers) {
    if (seen.has(id)) continue
    map.removeLayer(marker)
    cafeMarkers.delete(id)
  }
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
    dragging: false,
    touchZoom: false,
    scrollWheelZoom: false,
    doubleClickZoom: false,
    boxZoom: false,
    keyboard: false,
    fadeAnimation: !prefersReducedMotion(),
    zoomAnimation: false,
    markerZoomAnimation: !prefersReducedMotion(),
  })

  map.attributionControl?.setPrefix('')
  map.setView([props.center.lat, props.center.lng], 13)

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
  fitToRadius()
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
  () => [props.center.lat, props.center.lng, props.accuracy, props.radiusMeters],
  () => {
    syncUser()
    fitToRadius()
    requestAnimationFrame(() => invalidate())
  },
)

watch(
  () => props.cafes.map((cafe) => `${cafe.id}:${cafe.lat}:${cafe.lng}`).join('|'),
  () => syncCafes(),
)

defineExpose({ invalidate })
</script>

<style scoped>
.nearby-preview-map {
  position: relative;
  overflow: hidden;
  width: 100%;
  height: 220px;
  background: #faf8f5;
  pointer-events: none;
  user-select: none;
}

.nearby-preview-map__canvas {
  width: 100%;
  height: 100%;
}

.nearby-preview-map :deep(.leaflet-container) {
  width: 100%;
  height: 100%;
  font-family: inherit;
  background: #faf8f5;
  cursor: default;
}

.nearby-preview-map :deep(img.leaflet-tile) {
  max-width: none !important;
  max-height: none !important;
}

.nearby-preview-map :deep(.leaflet-tile-pane) {
  filter: sepia(0.32) saturate(0.62) hue-rotate(-12deg) brightness(1.03);
}

.nearby-preview-map :deep(.leaflet-control-attribution) {
  max-width: min(72vw, 240px);
  margin: 0 8px 8px 0;
  padding: 3px 6px;
  border-radius: 4px;
  background: color-mix(in srgb, var(--kd-white) 88%, transparent);
  color: var(--kd-ink);
  font-size: 10px;
  line-height: 1.3;
}

.nearby-preview-map :deep(.leaflet-control-attribution a) {
  color: var(--kd-ink);
  pointer-events: none;
}

.nearby-preview-map :deep(.leaflet-div-icon.kd-preview-pin),
.nearby-preview-map :deep(.leaflet-div-icon.kd-preview-you) {
  background: transparent;
  border: 0;
}

.nearby-preview-map :deep(.kd-preview-pin),
.nearby-preview-map :deep(.kd-preview-you) {
  display: grid;
  place-items: center;
}

.nearby-preview-map :deep(.kd-preview-pin__dot) {
  display: block;
  width: 10px;
  height: 10px;
  border-radius: 16px;
  background: var(--kd-accent);
  border: 2px solid #faf8f5;
  box-shadow: 0 2px 6px color-mix(in srgb, var(--kd-ink) 22%, transparent);
}

.nearby-preview-map :deep(.kd-preview-you__core) {
  width: 14px;
  height: 14px;
  border-radius: 16px;
  background: var(--kd-accent);
  border: 2px solid #faf8f5;
  box-shadow: 0 2px 6px color-mix(in srgb, var(--kd-ink) 22%, transparent);
}

.nearby-preview-map :deep(.kd-preview-you__pulse) {
  position: absolute;
  width: 14px;
  height: 14px;
  border-radius: 16px;
  background: var(--kd-accent);
  animation: kd-preview-pulse 2.2s cubic-bezier(0.16, 1, 0.3, 1) infinite;
}

@keyframes kd-preview-pulse {
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
  .nearby-preview-map :deep(.kd-preview-you__pulse) {
    animation: none;
  }
}
</style>
