import {
  DEFAULT_NEARBY_RADIUS_KM,
  nearbyRadiusMeters,
  normalizeNearbyRadiusKm,
  readNearbyRadiusKm,
  writeNearbyRadiusKm,
  type NearbyRadiusKm,
} from '~/utils/nearby-radius'

export function useNearbyRadius() {
  const radiusKm = useState<NearbyRadiusKm>('kd-nearby-radius-km', () => DEFAULT_NEARBY_RADIUS_KM)

  const hydrate = () => {
    radiusKm.value = readNearbyRadiusKm()
  }

  const setRadiusKm = (km: NearbyRadiusKm) => {
    radiusKm.value = normalizeNearbyRadiusKm(km)
    writeNearbyRadiusKm(radiusKm.value)
  }

  const radiusMeters = computed(() => nearbyRadiusMeters(radiusKm.value))

  onMounted(hydrate)

  return { radiusKm, radiusMeters, setRadiusKm, hydrate }
}
