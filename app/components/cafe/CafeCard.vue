<template>
  <article class="bag" :class="{ 'is-selected': selected, 'is-saved': saved }">
    <button type="button" class="bag__open" @click="emit('select', cafe.id)">
      <span class="bag__mast">
        <span class="bag__logo" aria-hidden="true">
          <img
            v-if="showLogo"
            class="bag__mark"
            :src="photoSrc"
            alt=""
            width="40"
            height="40"
            @error="onPhotoError"
          />
        </span>
        <span class="bag__copy">
          <span class="bag__name">{{ cafe.name }}</span>
          <span v-if="closed" class="bag__closed">Closed</span>
          <span v-if="cafe.address" class="bag__origin">{{ cafe.address }}</span>
        </span>
      </span>
      <span class="bag__lines">
        <span v-if="hoursLine" class="bag__line">
          <span class="bag__key">
            <Clock :size="15" :stroke-width="2.25" aria-hidden="true" />
            <span>Hours</span>
          </span>
          <span>{{ hoursLine }}</span>
        </span>
        <span class="bag__line">
          <span class="bag__key">
            <component :is="wifiIcon" :size="15" :stroke-width="2.25" aria-hidden="true" />
            <span>WiFi</span>
          </span>
          <span>{{ wifiWords }}</span>
        </span>
        <span class="bag__line">
          <span class="bag__key">
            <component :is="outletIcon" :size="15" :stroke-width="2.25" aria-hidden="true" />
            <span>Outlets</span>
          </span>
          <span>{{ outletWords }}</span>
        </span>
        <span v-if="distanceLabel" class="bag__line">
          <span class="bag__key">
            <Navigation :size="15" :stroke-width="2.25" aria-hidden="true" />
            <span>Distance</span>
          </span>
          <span>{{ distanceLabel }}</span>
        </span>
      </span>
    </button>
    <button
      type="button"
      class="bag__save"
      :aria-pressed="saved"
      :aria-label="saved ? `Remove ${cafe.name} from saved cafes` : `Save ${cafe.name}`"
      @click="onSave"
    >
      <span class="bag__save-fill" aria-hidden="true" />
      <Heart
        class="bag__save-icon"
        :size="18"
        :stroke-width="2"
        :fill="saved ? 'currentColor' : 'none'"
      />
    </button>
  </article>
</template>

<script lang="ts" setup>
import { Clock, Heart, Navigation, Plug, Unplug, Wifi, WifiOff } from 'lucide-vue-next'
import type { Cafe } from '~/types/cafe'
import { isKapedokoMark } from '~/utils/logo'

const props = defineProps<{
  cafe: Pick<Cafe, 'id' | 'name' | 'address' | 'image' | 'open' | 'status' | 'amenities' | 'work' | 'rating' | 'hoursHint'>
  selected?: boolean
  distanceLabel?: string
}>()

const emit = defineEmits<{
  select: [id: string]
}>()

const favorites = useFavorites()
const broken = ref(false)
const saved = computed(() => favorites.isSaved(props.cafe.id))
const showLogo = computed(() => !broken.value && !isKapedokoMark(props.cafe.image))
const photoSrc = computed(() => (showLogo.value ? props.cafe.image : ''))
const closed = computed(() => props.cafe.status === 'Closed')

const wifiWords = computed(() => {
  if (!props.cafe.work?.known) return 'Not confirmed'
  return props.cafe.work.wifi ? 'Confirmed' : 'No WiFi'
})

const outletWords = computed(() => {
  if (!props.cafe.work?.known) return 'Not confirmed'
  return props.cafe.work.plug ? 'Confirmed' : 'No outlets'
})

const wifiIcon = computed(() => {
  if (props.cafe.work?.known && !props.cafe.work.wifi) return WifiOff
  return Wifi
})

const outletIcon = computed(() => {
  if (props.cafe.work?.known && !props.cafe.work.plug) return Unplug
  return Plug
})

const hoursLine = computed(() => {
  const hint = props.cafe.hoursHint
  if (!hint || hint === 'Hours to confirm' || hint === 'Closed today') return ''
  return hint.replace(/^Opens\s+/, '').replace(/:00/g, '')
})

const onSave = () => {
  void favorites.toggle(props.cafe.id)
}

const onPhotoError = () => {
  broken.value = true
}
</script>

<style scoped>
.bag {
  position: relative;
  margin: 0 20px 12px;
  padding: 16px 40px 12px 16px;
  background-color: #faf8f5;
  color: #1c1917;
  border: 1px solid rgba(28, 25, 23, 0.34);
  border-radius: 16px;
  animation: bag-settle 460ms cubic-bezier(0.16, 1, 0.3, 1) both;
  animation-delay: calc(var(--enter, 0) * 32ms);
  overflow: hidden;
}

.bag.is-selected {
  border-color: #1f6f6b;
}

.bag__open {
  display: flex;
  flex-direction: column;
  gap: 8px;
  width: 100%;
  padding: 0;
  border: 0;
  background: transparent;
  color: inherit;
  font: inherit;
  text-align: left;
  cursor: pointer;
}

.bag__mast {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  min-width: 0;
}

.bag__logo {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  flex: 0 0 auto;
  overflow: hidden;
  background-color: #faf8f5;
  border: 1px solid rgba(28, 25, 23, 0.34);
  border-radius: 8px;
}

.bag__mark {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.bag__copy {
  display: flex;
  flex-direction: column;
  gap: 1px;
  min-width: 0;
}

.bag__name {
  color: #1c1917;
  font-size: 1.325rem;
  font-weight: 700;
  line-height: 1.05;
  letter-spacing: -0.03em;
}

.bag__origin,
.bag__closed {
  font-size: 0.75rem;
  line-height: 1.2;
}

.bag__origin {
  color: #1c1917;
}

.bag__closed {
  color: #8c3a2f;
  font-weight: 700;
}

.bag__lines {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin: 0;
  padding-top: 8px;
  border-top: 1px solid color-mix(in srgb, var(--kd-ink) 12%, transparent);
  animation: bag-reprint 520ms cubic-bezier(0.16, 1, 0.3, 1) both;
  animation-delay: calc(var(--enter, 0) * 32ms);
}

.bag__line {
  display: grid;
  grid-template-columns: 7rem max-content;
  column-gap: 8px;
  align-items: baseline;
  justify-content: start;
  width: max-content;
  max-width: 100%;
  font-size: 0.7875rem;
  line-height: 1.3;
}

.bag__key {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: #1c1917;
}

.bag__key :deep(svg) {
  color: #d9793b;
}

.bag__line > span:last-child {
  font-weight: 700;
  text-align: left;
}

.bag__save {
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  z-index: 2;
  display: flex;
  align-items: flex-start;
  justify-content: flex-end;
  width: 44px;
  min-height: 44px;
  padding: 14px 5px 0 0;
  border: 0;
  background: transparent;
  color: #d9793b;
  cursor: pointer;
  overflow: hidden;
}

.bag.is-saved .bag__save {
  color: #1c1917;
}

.bag__save-fill {
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  z-index: 0;
  width: 28px;
  background: #d9793b;
  clip-path: inset(0 0 100% 0);
  transition: clip-path 280ms cubic-bezier(0.16, 1, 0.3, 1);
  pointer-events: none;
}

.bag.is-saved .bag__save-fill {
  clip-path: inset(0 0 0 0);
  box-shadow: inset 1px 0 0 color-mix(in srgb, #1c1917 18%, transparent);
}

.bag__save-icon {
  position: relative;
  z-index: 1;
  flex: 0 0 auto;
}

.bag__open:focus-visible,
.bag__save:focus-visible {
  outline: 2px solid #1f6f6b;
  outline-offset: 2px;
}

.bag__open:active {
  opacity: 0.72;
}

@keyframes bag-settle {
  from { transform: translateY(12px) rotate(0.35deg); }
  to { transform: none; }
}

@keyframes bag-reprint {
  from { clip-path: inset(0 0 100% 0); }
  to { clip-path: inset(0 0 0 0); }
}

@media (prefers-reduced-motion: reduce) {
  .bag,
  .bag__lines {
    animation: none;
  }

  .bag__save-fill {
    transition: none;
  }
}
</style>
