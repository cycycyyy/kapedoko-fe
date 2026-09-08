import type { MarkerTier } from './shop'

export type Amenity = 'wifi' | 'plug'

export interface LatLng {
  lat: number
  lng: number
}

export interface CafeReview {
  id: string
  name: string
  quote: string
  wifiVotes: number
  outletVotes: number
}

export interface CafeInsight {
  count: number
  title: string
  body: string
}

export interface Cafe {
  id: string
  name: string
  address: string
  image: string
  photos: string[]
  open: boolean
  status: string
  hoursHint: string
  phone?: string
  amenities: Amenity[] | 'none'
  popular: boolean
  rating: number
  ratingLabel: string
  wifiInsight?: CafeInsight
  plugInsight?: CafeInsight
  reviews: CafeReview[]
  lat: number
  lng: number
  markerTier: MarkerTier
}
