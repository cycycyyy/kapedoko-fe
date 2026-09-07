<template>
  <article
    class="cafe-card"
    :class="{ 'is-selected': selected }"
    :aria-current="selected ? 'true' : undefined"
  >
    <div class="cafe-card__photo" :class="{ 'is-broken': broken }">
      <img
        :src="cafe.image"
        :alt="cafe.name"
        width="90"
        height="100"
        @error="broken = true"
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

      <h3>{{ cafe.name }}</h3>
      <p class="cafe-card__address">{{ cafe.address }}</p>
      <p v-if="distanceLabel" class="cafe-card__distance">{{ distanceLabel }}</p>

      <p v-if="cafe.amenities === 'none'" class="cafe-card__none">
        <Ban :size="14" :stroke-width="2" aria-hidden="true" />
        No WiFi or Power Outlets
      </p>
      <p v-else class="cafe-card__amenities">
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
  </article>
</template>

<script lang="ts" setup>
import { Ban, Plug, Star, Wifi } from 'lucide-vue-next'
import type { Cafe } from '~/types/cafe'

defineProps<{
  cafe: Pick<Cafe, 'name' | 'address' | 'image' | 'open' | 'status' | 'amenities' | 'rating'>
  selected?: boolean
  distanceLabel?: string
}>()

const broken = ref(false)
</script>

<style scoped>
.cafe-card {
  display: flex;
  min-height: 100px;
  border-radius: 8px;
  background: var(--kd-white);
  box-shadow: 0 2px 8px var(--kd-shadow);
  transition: transform 140ms cubic-bezier(0.16, 1, 0.3, 1),
    box-shadow 180ms cubic-bezier(0.16, 1, 0.3, 1),
    background-color 180ms cubic-bezier(0.16, 1, 0.3, 1);
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

.cafe-card__photo img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.cafe-card__photo.is-broken img {
  display: none;
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

.cafe-card h3 {
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

.cafe-card:active {
  transform: scale(0.99);
}

@media (prefers-reduced-motion: reduce) {
  .cafe-card {
    transition-duration: 1ms;
  }

  .cafe-card:active {
    transform: none;
  }
}
</style>
