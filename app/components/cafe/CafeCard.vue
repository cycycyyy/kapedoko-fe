<template>
  <article
    class="cafe-card"
    :class="{ 'is-selected': selected }"
  >
    <button
      type="button"
      class="cafe-card__save"
      :aria-pressed="saved"
      :aria-label="saved ? `Remove ${cafe.name} from saved cafes` : `Save ${cafe.name}`"
      @click="onSave"
    >
      <Heart :size="18" :stroke-width="1.75" :fill="saved ? 'currentColor' : 'none'" />
    </button>
    <button
      type="button"
      class="cafe-card__open"
      :aria-current="selected ? 'true' : undefined"
      @click="emit('select', cafe.id)"
    >
    <div class="cafe-card__photo" :class="{ 'is-mark': useMark }">
      <img
        :src="photoSrc"
        alt=""
        width="90"
        height="100"
        @error="onPhotoError"
      />
    </div>

    <div class="cafe-card__body">
      <div class="cafe-card__meta">
        <div class="cafe-card__stars" :aria-label="`Rating ${cafe.rating} out of 5`">
          <Star
            v-for="n in 5"
            :key="n"
            :size="12"
            :stroke-width="1.75"
            :fill="n <= cafe.rating ? 'currentColor' : 'none'"
          />
        </div>
        <p
          class="cafe-card__status"
          :class="cafe.open ? 'is-open' : 'is-closed'"
        >
          {{ cafe.status }}
        </p>
      </div>

      <p class="cafe-card__name">{{ cafe.name }}</p>
      <p class="cafe-card__address">{{ cafe.address }}</p>
      <p v-if="distanceLabel" class="cafe-card__distance">{{ distanceLabel }}</p>

      <p v-if="amenityGap" class="cafe-card__none">
        <Ban :size="14" :stroke-width="2" aria-hidden="true" />
        {{ amenityGap }}
      </p>
      <p v-else-if="Array.isArray(cafe.amenities) && cafe.amenities.length" class="cafe-card__amenities">
        <span v-if="cafe.amenities.includes('wifi')" class="cafe-card__amenity">
          <Wifi :size="14" :stroke-width="2" aria-hidden="true" />
          WiFi
        </span>
        <span v-if="cafe.amenities.includes('plug')" class="cafe-card__amenity">
          <Plug :size="14" :stroke-width="2" aria-hidden="true" />
          Outlets
        </span>
      </p>
    </div>
    </button>
  </article>
</template>

<script lang="ts" setup>
import { Ban, Heart, Plug, Star, Wifi } from 'lucide-vue-next'
import type { Cafe } from '~/types/cafe'
import { isKapedokoMark, KAPEDOKO_MARK_SRC } from '~/utils/logo'
import { amenityGapCopy } from '~/utils/shop-mapper'

const props = defineProps<{
  cafe: Pick<Cafe, 'id' | 'name' | 'address' | 'image' | 'open' | 'status' | 'amenities' | 'work' | 'rating'>
  selected?: boolean
  distanceLabel?: string
}>()

const emit = defineEmits<{
  select: [id: string]
}>()

const favorites = useFavorites()
const broken = ref(false)
const useMark = computed(() => broken.value || isKapedokoMark(props.cafe.image))
const photoSrc = computed(() => (useMark.value ? KAPEDOKO_MARK_SRC : props.cafe.image))
const saved = computed(() => favorites.isSaved(props.cafe.id))
const amenityGap = computed(() => amenityGapCopy(props.cafe.work, props.cafe.amenities))

const onSave = () => {
  void favorites.toggle(props.cafe.id)
}

const onPhotoError = () => {
  if (!isKapedokoMark(props.cafe.image)) broken.value = true
}
</script>

<style scoped>
.cafe-card {
  position: relative;
  display: flex;
  width: 100%;
  min-height: 100px;
  border-radius: 8px;
  background: var(--kd-white);
  box-shadow: 0 2px 8px var(--kd-shadow);
  transition: box-shadow 180ms cubic-bezier(0.16, 1, 0.3, 1),
    background-color 180ms cubic-bezier(0.16, 1, 0.3, 1);
}

.cafe-card__open {
  display: flex;
  width: 100%;
  min-height: 100px;
  padding: 0;
  border: 0;
  border-radius: 8px;
  background: transparent;
  color: inherit;
  font: inherit;
  text-align: left;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.cafe-card__save {
  position: absolute;
  z-index: 1;
  top: 4px;
  left: 4px;
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  padding: 0;
  border: 0;
  border-radius: 8px;
  background: color-mix(in srgb, var(--kd-white) 92%, transparent);
  color: var(--kd-primary);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.cafe-card__open:focus-visible,
.cafe-card__save:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
}

.cafe-card.is-selected {
  background: var(--kd-secondary);
  box-shadow: 0 4px 12px var(--kd-shadow);
}

.cafe-card__photo {
  width: 90px;
  height: 100px;
  flex-shrink: 0;
  overflow: hidden;
  border-radius: 8px 0 0 8px;
  background: var(--kd-secondary);
}

.cafe-card__photo.is-mark {
  background-color: var(--kd-secondary);
  background-image: radial-gradient(
    circle at 50% 32%,
    color-mix(in srgb, var(--kd-white) 78%, transparent) 0%,
    transparent 58%
  );
}

.cafe-card__photo img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.cafe-card__photo.is-mark img {
  object-fit: contain;
  object-position: center 46%;
  padding: 14px 16px 12px;
}

.cafe-card.is-selected .cafe-card__photo.is-mark {
  background-color: color-mix(in srgb, var(--kd-primary) 7%, var(--kd-white));
  background-image: radial-gradient(
    circle at 50% 32%,
    color-mix(in srgb, var(--kd-white) 90%, transparent) 0%,
    transparent 58%
  );
}

.cafe-card__body {
  flex: 1;
  min-width: 0;
  padding: 11px 13px 10px 15px;
}

.cafe-card__meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.cafe-card__stars {
  display: flex;
  flex-shrink: 0;
  gap: 2px;
  color: var(--kd-black);
}

.cafe-card__status {
  margin: 0;
  min-width: 0;
  flex: 1 1 auto;
  overflow: hidden;
  font-size: 12px;
  font-weight: 700;
  line-height: 1.2;
  text-align: right;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.cafe-card__status.is-open {
  color: var(--kd-open);
}

.cafe-card__status.is-closed {
  color: var(--kd-closed);
}

.cafe-card__name {
  margin: 3px 0 0;
  color: var(--kd-primary);
  font-size: 16px;
  font-weight: 700;
  line-height: 1.375;
}

.cafe-card__address {
  margin: 0;
  overflow: hidden;
  color: var(--kd-ink);
  font-size: 12px;
  line-height: 1.35;
  white-space: nowrap;
  text-overflow: ellipsis;
}

.cafe-card__distance {
  margin: 2px 0 0;
  color: var(--kd-ink);
  font-size: 12px;
  line-height: 1.35;
}

.cafe-card__amenities,
.cafe-card__none {
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 8px 0 0;
  color: var(--kd-ink);
  font-size: 12px;
}

.cafe-card__amenity {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.cafe-card__none {
  gap: 4px;
  color: #5c5c5c;
  font-size: 12px;
  font-style: italic;
}

.cafe-card__open:active,
.cafe-card__save:active {
  transform: scale(0.98);
}

@media (prefers-reduced-motion: reduce) {
  .cafe-card,
  .cafe-card__open,
  .cafe-card__save {
    transition-duration: 1ms;
  }

  .cafe-card__open:active,
  .cafe-card__save:active {
    transform: none;
  }
}
</style>
