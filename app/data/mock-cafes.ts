import type { Amenity, Cafe, CafeReview, LatLng } from '~/types/cafe'
import { destinationPoint, distanceMeters, SEARCH_RADIUS_M } from '~/utils/geo'

interface CafeSeed {
  id: string
  name: string
  address: string
  image: string
  photos?: string[]
  open: boolean
  status: string
  hoursHint: string
  phone?: string
  amenities: Amenity[] | 'none'
  popular: boolean
  rating: number
  ratingLabel: string
  wifiCount?: number
  plugCount?: number
  reviews?: CafeReview[]
  distanceM: number
  bearing: number
}

const PHOTOS = {
  tobys: '/assets/cafes/tobys.jpg',
  commune: '/assets/cafes/commune.jpg',
  single: '/assets/cafes/single-origin.jpg',
  kapetayo: '/assets/cafes/kapetayo.jpg',
  yardstick: '/assets/cafes/yardstick.jpg',
  academics: '/assets/cafes/academics.jpg',
  wildflour: '/assets/cafes/wildflour.jpg',
}

const SAMPLE_REVIEWS: CafeReview[] = [
  {
    id: 'r1',
    name: 'Janelle R.',
    quote:
      'Quiet enough for a two-hour laptop stretch. WiFi held, and I found an outlet along the window ledge.',
    wifiVotes: 1,
    outletVotes: 1,
  },
  {
    id: 'r2',
    name: 'Marco T.',
    quote:
      'Tables are a bit tight at lunch, but the sockets by the bar saved the afternoon. Staff let me stay through a call.',
    wifiVotes: 1,
    outletVotes: 1,
  },
]

const CAFE_SEEDS: CafeSeed[] = [
  {
    id: 'c1',
    name: 'High Street Desk',
    address: 'BGC High Street, Taguig City',
    image: PHOTOS.tobys,
    photos: [PHOTOS.tobys, PHOTOS.yardstick, PHOTOS.commune, PHOTOS.academics],
    open: true,
    status: 'Open',
    hoursHint: 'Opens till 10pm',
    phone: '+63288881001',
    amenities: ['wifi', 'plug'],
    popular: true,
    rating: 5,
    ratingLabel: '4.8',
    wifiCount: 35,
    plugCount: 35,
    reviews: SAMPLE_REVIEWS,
    distanceM: 420,
    bearing: 38,
  },
  {
    id: 'c2',
    name: 'Poblacion Counter',
    address: 'Poblacion, Makati City',
    image: PHOTOS.commune,
    photos: [PHOTOS.commune, PHOTOS.tobys, PHOTOS.wildflour, PHOTOS.single],
    open: true,
    status: 'Open',
    hoursHint: 'Opens till 10pm',
    phone: '+63288881002',
    amenities: ['plug'],
    popular: true,
    rating: 4,
    ratingLabel: '4.2',
    plugCount: 18,
    reviews: [SAMPLE_REVIEWS[1]],
    distanceM: 890,
    bearing: 118,
  },
  {
    id: 'c3',
    name: 'Salcedo Quiet Table',
    address: 'Salcedo Village, Makati City',
    image: PHOTOS.single,
    photos: [PHOTOS.single, PHOTOS.academics, PHOTOS.kapetayo, PHOTOS.commune],
    open: false,
    status: 'Closed, opens at 9:00am',
    hoursHint: 'Opens at 9am',
    phone: '+63288881003',
    amenities: ['wifi', 'plug'],
    popular: false,
    rating: 4,
    ratingLabel: '4.1',
    reviews: [],
    distanceM: 1_460,
    bearing: 214,
  },
  {
    id: 'c4',
    name: 'Katipunan Corner',
    address: 'Katipunan Ave, Quezon City',
    image: PHOTOS.kapetayo,
    photos: [PHOTOS.kapetayo, PHOTOS.single, PHOTOS.tobys, PHOTOS.yardstick],
    open: true,
    status: 'Open',
    hoursHint: 'Opens till 9pm',
    amenities: 'none',
    popular: false,
    rating: 3,
    ratingLabel: '3.4',
    reviews: [],
    distanceM: 2_120,
    bearing: 286,
  },
  {
    id: 'c5',
    name: 'Legazpi Workroom',
    address: 'Poblacion, Makati City',
    image: PHOTOS.yardstick,
    photos: [PHOTOS.yardstick, PHOTOS.commune, PHOTOS.tobys, PHOTOS.wildflour],
    open: true,
    status: 'Open',
    hoursHint: 'Opens till 10pm',
    phone: '+63288881005',
    amenities: ['wifi', 'plug'],
    popular: true,
    rating: 5,
    ratingLabel: '4.9',
    wifiCount: 42,
    plugCount: 40,
    reviews: SAMPLE_REVIEWS,
    distanceM: 1_080,
    bearing: 62,
  },
  {
    id: 'c6',
    name: 'Ayala Quiet Cup',
    address: 'Salcedo Village, Makati City',
    image: PHOTOS.academics,
    photos: [PHOTOS.academics, PHOTOS.single, PHOTOS.yardstick, PHOTOS.kapetayo],
    open: true,
    status: 'Open',
    hoursHint: 'Opens till 8pm',
    phone: '+63288881006',
    amenities: ['wifi'],
    popular: true,
    rating: 4,
    ratingLabel: '4.3',
    wifiCount: 22,
    reviews: [SAMPLE_REVIEWS[0]],
    distanceM: 1_780,
    bearing: 164,
  },
  {
    id: 'c7',
    name: 'Fort Bakery Seat',
    address: 'BGC High Street, Taguig City',
    image: PHOTOS.wildflour,
    photos: [PHOTOS.wildflour, PHOTOS.tobys, PHOTOS.commune, PHOTOS.academics],
    open: false,
    status: 'Closed, opens at 8:00am',
    hoursHint: 'Opens at 8am',
    phone: '+63288881007',
    amenities: ['wifi', 'plug'],
    popular: true,
    rating: 5,
    ratingLabel: '4.7',
    reviews: [],
    distanceM: 2_540,
    bearing: 328,
  },
]

function insightsFor(seed: CafeSeed) {
  const wifiInsight =
    seed.amenities !== 'none' && seed.amenities.includes('wifi') && seed.wifiCount
      ? {
          count: seed.wifiCount,
          title: 'WiFi connection is available',
          body: 'WiFi connection is available in this coffee shop, with fast speed (Internet speed may vary).',
        }
      : undefined

  const plugInsight =
    seed.amenities !== 'none' && seed.amenities.includes('plug') && seed.plugCount
      ? {
          count: seed.plugCount,
          title: 'Power sockets are available',
          body: 'You may use the power sockets you find in the coffee shop. Availability may vary.',
        }
      : undefined

  return { wifiInsight, plugInsight }
}

export function cafesNear(center: LatLng): Cafe[] {
  return CAFE_SEEDS.map((seed) => {
    const point = destinationPoint(center, seed.distanceM, seed.bearing)
    const { wifiInsight, plugInsight } = insightsFor(seed)
    return {
      id: seed.id,
      name: seed.name,
      address: seed.address,
      image: seed.image,
      photos: seed.photos ?? [seed.image],
      open: seed.open,
      status: seed.status,
      hoursHint: seed.hoursHint,
      phone: seed.phone,
      amenities: seed.amenities,
      popular: seed.popular,
      rating: seed.rating,
      ratingLabel: seed.ratingLabel,
      wifiInsight,
      plugInsight,
      reviews: seed.reviews ?? [],
      lat: point.lat,
      lng: point.lng,
    }
  }).filter((cafe) => distanceMeters(center, cafe) <= SEARCH_RADIUS_M)
}

export function filterCafes(cafes: Cafe[], query: string): Cafe[] {
  const term = query.trim().toLowerCase()
  if (!term) return cafes

  return cafes.filter(
    (cafe) =>
      cafe.name.toLowerCase().includes(term)
      || cafe.address.toLowerCase().includes(term),
  )
}
