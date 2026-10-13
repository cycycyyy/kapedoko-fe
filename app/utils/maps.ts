/** Real Poblacion, Makati streets for first-run map teaching. Not a listed cafe. */
export const ONBOARDING_TEACH_MAP = {
  lat: 14.56525,
  lng: 121.02955,
  startZoom: 12.6,
  endZoom: 16.6,
  label: 'Exact location',
} as const

export function googleMapsDirectionsUrl(lat: number, lng: number): string {
  const params = new URLSearchParams({
    api: '1',
    destination: `${lat},${lng}`,
  })
  return `https://www.google.com/maps/dir/?${params.toString()}`
}

export function cafeHasMapPoint(lat: number, lng: number): boolean {
  const nextLat = Number(lat)
  const nextLng = Number(lng)
  return Number.isFinite(nextLat) && Number.isFinite(nextLng) && !(nextLat === 0 && nextLng === 0)
}

export function cafePlaceLine(address: string, name: string): string {
  const parts = address.split(',').map((part) => part.trim()).filter(Boolean)
  if (parts.length >= 2) return parts.slice(-2).join(', ')
  if (parts[0] && parts[0].toLowerCase() !== name.toLowerCase()) return parts[0]
  return name
}
