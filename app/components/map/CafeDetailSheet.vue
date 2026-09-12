<template>
  <IonModal
    :is-open="open"
    :initial-breakpoint="PEEK"
    :breakpoints="BREAKPOINTS"
    handle-behavior="cycle"
    :backdrop-breakpoint="EXPANDED"
    :show-backdrop="false"
    class="cafe-detail-modal"
    @didPresent="onPresent"
    @didDismiss="onDismiss"
  >
    <div v-if="cafe" class="cafe-detail">
      <header class="cafe-detail__header">
        <div class="cafe-detail__title-row">
          <h2>{{ cafe.name }}</h2>
          <a
            class="cafe-detail__navigate"
            :href="mapsHref"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="Navigate to this cafe in Google Maps"
          >
            <span class="cafe-detail__action-face cafe-detail__action-face--primary">
              <Navigation :size="14" :stroke-width="2.25" aria-hidden="true" />
              Navigate to this Cafe
            </span>
          </a>
        </div>

        <p
          v-if="cafe.busyness"
          class="cafe-detail__crowd"
          :aria-label="`${cafe.busyness.label}, based on ${cafe.busyness.count} recent check-ins`"
        >
          {{ cafe.busyness.label }}
          <span>· {{ cafe.busyness.count }} check-ins</span>
        </p>

        <p v-if="hasWifi || hasPlug" class="cafe-detail__amenities-inline">
          <span v-if="hasWifi" class="cafe-detail__amenity">
            <Wifi :size="14" :stroke-width="2" aria-hidden="true" />
            WiFi
          </span>
          <span v-if="hasPlug" class="cafe-detail__amenity">
            <Plug :size="14" :stroke-width="2" aria-hidden="true" />
            Outlets
          </span>
        </p>

        <p v-if="cafe.reviews.length === 0" class="cafe-detail__prompt">
          Not yet reviewed, add your review?
        </p>

        <p class="cafe-detail__address">{{ cafe.address }}</p>

        <div class="cafe-detail__rating">
          <span class="cafe-detail__score">{{ cafe.ratingLabel }}</span>
          <span class="cafe-detail__stars" :aria-label="`Rating ${cafe.ratingLabel} out of 5`">
            <Star
              v-for="n in 5"
              :key="n"
              :size="12"
              :stroke-width="1.75"
              :fill="n <= cafe.rating ? 'currentColor' : 'none'"
            />
          </span>
          <span class="cafe-detail__rating-label">KapéBean ratings</span>
        </div>

        <div class="cafe-detail__actions">
          <div class="cafe-detail__status">
            <p
              class="cafe-detail__chip"
              :class="cafe.open ? 'is-open' : 'is-closed'"
            >
              {{ cafe.open ? 'Open' : 'Closed' }}
            </p>
            <p class="cafe-detail__hours">{{ cafe.hoursHint }}</p>
          </div>
          <a
            v-if="cafe.phone"
            class="cafe-detail__call"
            :href="`tel:${cafe.phone}`"
          >
            <span class="cafe-detail__action-face cafe-detail__action-face--quiet">
              <Phone :size="16" :stroke-width="2" aria-hidden="true" />
              Call this Cafe
            </span>
          </a>
        </div>
      </header>

      <div class="cafe-detail__scroll">
        <div class="cafe-detail__gallery">
          <div class="cafe-detail__hero" :class="{ 'is-mark': heroIsMark }">
            <img
              :src="heroSrc"
              :alt="heroIsMark ? '' : `${cafe.name} interior`"
              @error="onHeroError"
            />
          </div>
          <div v-if="photos.length > 1" class="cafe-detail__thumbs" role="group" aria-label="Cafe photos">
            <button
              v-for="(photo, index) in photos"
              :key="`${photo}-${index}`"
              type="button"
              class="cafe-detail__thumb"
              :class="{
                'is-broken': broken[`t${index}`],
                'is-active': index === activePhoto,
              }"
              :aria-label="`Show photo ${index + 1} of ${photos.length}`"
              :aria-current="index === activePhoto ? 'true' : undefined"
              @click="selectPhoto(index)"
            >
              <img
                :src="photo"
                alt=""
                @error="broken[`t${index}`] = true"
              />
            </button>
          </div>
        </div>

        <section v-if="cafe.wifiInsight" class="cafe-detail__insight" :aria-label="cafe.wifiInsight.title">
          <Wifi :size="24" :stroke-width="2" aria-hidden="true" />
          <div>
            <h3>
              <span class="cafe-detail__said">
                {{ cafe.wifiInsight.count }} of our KapéBeans said
              </span>
              {{ cafe.wifiInsight.title }}
            </h3>
            <p>{{ cafe.wifiInsight.body }}</p>
          </div>
        </section>

        <section v-if="cafe.plugInsight" class="cafe-detail__insight" :aria-label="cafe.plugInsight.title">
          <Plug :size="24" :stroke-width="2" aria-hidden="true" />
          <div>
            <h3>
              <span class="cafe-detail__said">
                {{ cafe.plugInsight.count }} of our KapéBeans said
              </span>
              {{ cafe.plugInsight.title }}
            </h3>
            <p>{{ cafe.plugInsight.body }}</p>
          </div>
        </section>

        <section v-if="cafe.matchaInsight" class="cafe-detail__insight" :aria-label="cafe.matchaInsight.title">
          <Leaf :size="24" :stroke-width="2" aria-hidden="true" />
          <div>
            <h3>
              <span class="cafe-detail__said">
                {{ cafe.matchaInsight.count }} of our KapéBeans said
              </span>
              {{ cafe.matchaInsight.title }}
            </h3>
            <p>{{ cafe.matchaInsight.body }}</p>
          </div>
        </section>

        <div class="cafe-detail__review-block">
          <button
            type="button"
            class="cafe-detail__leave"
            @click="onReview"
          >
            Leave a review
          </button>
        </div>

        <section class="cafe-detail__reviews" aria-label="KapéBean reviews">
          <h3>Reviews by our KapéBeans</h3>

          <div v-if="cafe.reviews.length === 0" class="cafe-detail__empty">
            <Coffee :size="24" :stroke-width="2" aria-hidden="true" />
            <p>Ready to be the first?</p>
          </div>

          <article
            v-for="review in cafe.reviews"
            :key="review.id"
            class="cafe-review"
          >
            <header class="cafe-review__meta">
              <span class="cafe-review__avatar" aria-hidden="true">
                {{ review.name.charAt(0) }}
              </span>
              <p class="cafe-review__name">{{ review.name }}</p>
              <span
                v-if="review.wifiVotes"
                class="cafe-review__vote"
                :aria-label="`${review.wifiVotes} WiFi ${review.wifiVotes === 1 ? 'vote' : 'votes'}`"
              >
                +{{ review.wifiVotes }}
                <Wifi :size="10" :stroke-width="2.5" aria-hidden="true" />
              </span>
              <span
                v-if="review.outletVotes"
                class="cafe-review__vote"
                :aria-label="`${review.outletVotes} outlet ${review.outletVotes === 1 ? 'vote' : 'votes'}`"
              >
                +{{ review.outletVotes }}
                <Plug :size="10" :stroke-width="2.5" aria-hidden="true" />
              </span>
            </header>
            <p>{{ review.quote }}</p>
          </article>
        </section>
      </div>
    </div>
  </IonModal>
</template>

<script lang="ts" setup>
import { Coffee, Leaf, Navigation, Phone, Plug, Star, Wifi } from 'lucide-vue-next'
import type { Cafe } from '~/types/cafe'
import { isKapedokoMark, KAPEDOKO_MARK_SRC } from '~/utils/logo'
import { googleMapsDirectionsUrl } from '~/utils/maps'

const SHEET_HEIGHT = 0.88
const PEEK_VIEWPORT = 0.62
const PEEK = PEEK_VIEWPORT / SHEET_HEIGHT
const EXPANDED = 1
const BREAKPOINTS = [0, PEEK, EXPANDED]

const props = defineProps<{
  open: boolean
  cafe: Cafe | null
}>()

const emit = defineEmits<{
  'update:open': [value: boolean]
  present: []
  dismissed: []
  review: []
}>()

const broken = ref<Record<string, boolean>>({})
const activePhoto = ref(0)

const photos = computed(() => {
  if (!props.cafe) return []
  const list = props.cafe.photos.length ? [...props.cafe.photos] : [props.cafe.image]
  const unique = [...new Set(list)]
  return unique.slice(0, 4)
})

const heroPhoto = computed(() => photos.value[activePhoto.value] ?? photos.value[0])
const heroIsMark = computed(() => Boolean(broken.value.hero) || isKapedokoMark(heroPhoto.value))
const heroSrc = computed(() => (heroIsMark.value ? KAPEDOKO_MARK_SRC : heroPhoto.value))

const onHeroError = () => {
  if (!isKapedokoMark(heroPhoto.value)) broken.value.hero = true
}

const hasWifi = computed(
  () => props.cafe && props.cafe.amenities !== 'none' && props.cafe.amenities.includes('wifi'),
)
const hasPlug = computed(
  () => props.cafe && props.cafe.amenities !== 'none' && props.cafe.amenities.includes('plug'),
)

const mapsHref = computed(() => {
  if (!props.cafe) return '#'
  return googleMapsDirectionsUrl(props.cafe.lat, props.cafe.lng)
})

watch(
  () => props.cafe?.id,
  () => {
    broken.value = {}
    activePhoto.value = 0
  },
)

const selectPhoto = (index: number) => {
  activePhoto.value = index
  broken.value.hero = Boolean(broken.value[`t${index}`])
}

const onReview = () => {
  emit('review')
}

const onPresent = () => emit('present')
const onDismiss = () => {
  emit('update:open', false)
  emit('dismissed')
}
</script>

<style scoped>
.cafe-detail {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: var(--kd-white);
  padding: 8px 0 0;
}

.cafe-detail__header {
  flex-shrink: 0;
  padding: 20px 20px 14px;
}

.cafe-detail__title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.cafe-detail__header h2 {
  margin: 0;
  min-width: 0;
  flex: 1;
  color: var(--kd-primary);
  font-size: 20px;
  font-weight: 700;
  line-height: 1.2;
  overflow-wrap: anywhere;
}

.cafe-detail__navigate,
.cafe-detail__call {
  display: inline-flex;
  align-items: center;
  flex-shrink: 0;
  min-height: 44px;
  text-decoration: none;
  -webkit-tap-highlight-color: transparent;
}

.cafe-detail__action-face {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  min-height: 28px;
  padding: 0 10px;
  border-radius: 4px;
  font-size: 10px;
  font-weight: 700;
  line-height: 1.2;
  white-space: nowrap;
}

.cafe-detail__action-face--primary {
  background: var(--kd-primary);
  color: var(--kd-white);
}

.cafe-detail__action-face--quiet {
  background: var(--kd-ink-10);
  color: var(--kd-ink);
}

.cafe-detail__prompt,
.cafe-detail__amenities-inline,
.cafe-detail__crowd {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  margin: 8px 0 0;
  color: var(--kd-ink);
  font-size: 12px;
  font-weight: 700;
  line-height: 1.2;
}

.cafe-detail__prompt {
  color: var(--kd-primary);
  font-size: 10px;
}

.cafe-detail__crowd {
  margin-top: 8px;
  color: var(--kd-ink);
  font-size: 12px;
  font-weight: 700;
}

.cafe-detail__crowd span {
  font-weight: 400;
}

.cafe-detail__amenity {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.cafe-detail__address {
  margin: 10px 0 0;
  color: var(--kd-ink);
  font-size: 12px;
  line-height: 1.35;
}

.cafe-detail__rating {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 10px;
  color: var(--kd-ink);
}

.cafe-detail__score {
  font-size: 12px;
  font-weight: 700;
}

.cafe-detail__stars {
  display: flex;
  gap: 2px;
  color: var(--kd-black);
}

.cafe-detail__rating-label {
  color: var(--kd-primary);
  font-size: 10px;
  font-weight: 700;
}

.cafe-detail__actions {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 12px;
}

.cafe-detail__status {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
  flex: 1;
}

.cafe-detail__chip {
  margin: 0;
  padding: 6px 10px;
  border-radius: 4px;
  color: var(--kd-white);
  font-size: 12px;
  font-weight: 700;
  line-height: 1.2;
}

.cafe-detail__chip.is-open {
  background: var(--kd-open);
}

.cafe-detail__chip.is-closed {
  background: var(--kd-closed);
}

.cafe-detail__hours {
  margin: 0;
  min-width: 0;
  color: var(--kd-ink);
  font-size: 12px;
  font-weight: 700;
  line-height: 1.2;
}

.cafe-detail__scroll {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  padding: 0 20px calc(16px + env(safe-area-inset-bottom));
  -webkit-overflow-scrolling: touch;
  scrollbar-width: thin;
  scrollbar-color: var(--kd-ink-25) transparent;
}

.cafe-detail__hero {
  overflow: hidden;
  height: 175px;
  border-radius: 5px;
  background: var(--kd-secondary);
}

.cafe-detail__hero img,
.cafe-detail__thumb img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.cafe-detail__hero.is-mark {
  background:
    radial-gradient(
      circle at 50% 38%,
      color-mix(in srgb, var(--kd-white) 78%, transparent) 0%,
      transparent 62%
    ),
    var(--kd-secondary);
}

.cafe-detail__hero.is-mark img {
  object-fit: contain;
  padding: 36px 48px;
}

.cafe-detail__hero.is-broken,
.cafe-detail__thumb.is-broken {
  background: #5c534c;
}

.cafe-detail__hero.is-broken img,
.cafe-detail__thumb.is-broken img {
  display: none;
}

.cafe-detail__thumbs {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-top: 10px;
}

.cafe-detail__thumb {
  overflow: hidden;
  height: 71px;
  padding: 0;
  border: 0;
  border-radius: 5px;
  background: var(--kd-secondary);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.cafe-detail__thumb.is-active {
  box-shadow: 0 0 0 2px var(--kd-white), 0 0 0 4px var(--kd-primary);
}

.cafe-detail__insight {
  display: flex;
  gap: 12px;
  margin-top: 22px;
  color: var(--kd-ink);
}

.cafe-detail__insight > :first-child {
  flex-shrink: 0;
  margin-top: 2px;
}

.cafe-detail__insight h3 {
  margin: 0;
  font-size: 12px;
  font-weight: 700;
  line-height: 1.35;
}

.cafe-detail__said {
  display: block;
  margin-bottom: 2px;
  font-size: 10px;
  font-weight: 400;
}

.cafe-detail__insight p {
  margin: 6px 0 0;
  font-size: 12px;
  line-height: 1.35;
}

.cafe-detail__review-block {
  margin-top: 22px;
}

.cafe-detail__leave {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  min-height: 45px;
  margin: 0;
  padding: 0 20px;
  border: 1px solid var(--kd-primary);
  border-radius: 8px;
  background: var(--kd-white);
  color: var(--kd-primary);
  font-size: 16px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
}

.cafe-detail__notice {
  margin: 10px 0 0;
  color: var(--kd-primary);
  font-size: 12px;
  font-weight: 700;
  line-height: 1.35;
}

.cafe-detail__reviews {
  margin-top: 22px;
  padding-top: 18px;
  border-top: 1px solid var(--kd-primary);
}

.cafe-detail__reviews h3 {
  margin: 0 0 12px;
  color: var(--kd-ink);
  font-size: 16px;
  font-weight: 700;
}

.cafe-detail__empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 12px 20px 8px;
  color: var(--kd-primary);
  text-align: center;
}

.cafe-detail__empty p {
  margin: 0;
  font-size: 12px;
  font-weight: 700;
  line-height: 1.35;
}

.cafe-review {
  padding: 16px 0;
  border-bottom: 1px solid var(--kd-primary);
  color: var(--kd-ink);
}

.cafe-review:last-child {
  border-bottom: 0;
}

.cafe-review__meta {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
}

.cafe-review__avatar {
  display: grid;
  place-items: center;
  width: 28px;
  height: 28px;
  border-radius: 999px;
  background: var(--kd-primary);
  color: var(--kd-white);
  font-size: 12px;
  font-weight: 700;
}

.cafe-review__name {
  margin: 0;
  flex: 1;
  font-size: 12px;
  font-weight: 700;
}

.cafe-review__vote {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  min-height: 15px;
  padding: 2px 6px;
  border-radius: 4px;
  background: var(--kd-ink);
  color: var(--kd-white);
  font-size: 10px;
  font-weight: 700;
}

.cafe-review p {
  margin: 0;
  font-size: 12px;
  line-height: 1.4;
}

:root.is-android .cafe-detail__leave {
  min-height: 48px;
}

.cafe-detail__navigate:focus-visible,
.cafe-detail__call:focus-visible,
.cafe-detail__leave:focus-visible,
.cafe-detail__thumb:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.cafe-detail__thumb:focus-visible {
  border-radius: 5px;
}

.cafe-detail__action-face--primary:active,
.cafe-detail__action-face--quiet:active,
.cafe-detail__leave:active,
.cafe-detail__thumb:active {
  transform: scale(0.98);
}

@media (hover: hover) {
  .cafe-detail__navigate:hover .cafe-detail__action-face--primary {
    background: color-mix(in srgb, var(--kd-primary) 88%, var(--kd-white));
  }

  .cafe-detail__call:hover .cafe-detail__action-face--quiet {
    background: var(--kd-ink-25);
  }

  .cafe-detail__leave:hover {
    background: var(--kd-secondary);
  }
}

@media (prefers-reduced-motion: reduce) {
  .cafe-detail__action-face--primary:active,
  .cafe-detail__action-face--quiet:active,
  .cafe-detail__leave:active,
  .cafe-detail__thumb:active {
    transform: none;
  }
}
</style>

<style>
ion-modal.cafe-detail-modal {
  contain: none;
  pointer-events: none;
  --height: 88%;
  --width: 100%;
  --border-radius: 8px;
  --background: var(--kd-white);
  --box-shadow: 0 -2px 16px var(--kd-shadow);
  --backdrop-opacity: 0;
}

ion-modal.cafe-detail-modal::part(backdrop) {
  display: none;
  pointer-events: none;
}

ion-modal.cafe-detail-modal::part(content) {
  pointer-events: auto;
}

ion-modal.cafe-detail-modal::part(handle) {
  width: 50px;
  height: 8px;
  margin-top: 18px;
  border-radius: 5px;
  background: var(--kd-ink-25);
}

@media (min-width: 540px) {
  ion-modal.cafe-detail-modal {
    --width: 480px;
  }

  ion-modal.cafe-detail-modal::part(content) {
    margin-inline: auto;
  }
}
</style>
