export function googleMapsDirectionsUrl(lat: number, lng: number): string {
  const params = new URLSearchParams({
    api: '1',
    destination: `${lat},${lng}`,
  })
  return `https://www.google.com/maps/dir/?${params.toString()}`
}
