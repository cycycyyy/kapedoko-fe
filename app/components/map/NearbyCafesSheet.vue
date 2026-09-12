<template>
  <IonModal
    :is-open="open"
    :initial-breakpoint="PEEK"
    :breakpoints="BREAKPOINTS"
    handle-behavior="cycle"
    :backdrop-breakpoint="EXPANDED"
    :show-backdrop="false"
    class="nearby-modal"
    @didPresent="onPresent"
    @didDismiss="onDismiss"
  >
    <div class="nearby-sheet">
      <header class="nearby-sheet__header">
        <Coffee :size="24" :stroke-width="2" aria-hidden="true" />
        <h2>Demo cafes near me</h2>
      </header>

      <div class="nearby-sheet__list" role="list" aria-label="Cafes near me">
        <p v-if="cafes.length === 0" class="nearby-sheet__empty">
          No coffee shops match that search.
        </p>

        <button
          v-for="cafe in cafes"
          :id="`nearby-cafe-${cafe.id}`"
          :key="cafe.id"
          type="button"
          class="nearby-sheet__item"
          role="listitem"
          :aria-pressed="cafe.id === selectedId"
          @click="emit('select', cafe.id)"
        >
          <CafeCard
            :cafe="cafe"
            :selected="cafe.id === selectedId"
            :distance-label="distances[cafe.id]"
          />
        </button>
      </div>
    </div>
  </IonModal>
</template>

<script lang="ts" setup>
import { Coffee } from 'lucide-vue-next'
import type { Cafe } from '~/types/cafe'
import CafeCard from '~/components/cafe/CafeCard.vue'

const SHEET_HEIGHT = 0.78
const PEEK_VIEWPORT = 0.28
const PEEK = PEEK_VIEWPORT / SHEET_HEIGHT
const EXPANDED = 1
const BREAKPOINTS = [0, PEEK, EXPANDED]

defineProps<{
  open: boolean
  cafes: Cafe[]
  selectedId: string | null
  distances: Record<string, string>
}>()

const emit = defineEmits<{
  'update:open': [value: boolean]
  present: []
  select: [id: string]
}>()

const onPresent = () => {
  emit('present')
}

const onDismiss = () => {
  emit('update:open', false)
}
</script>

<style scoped>
.nearby-sheet {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: var(--kd-white);
  padding: 8px 0 calc(12px + env(safe-area-inset-bottom));
}

.nearby-sheet__header {
  display: flex;
  align-items: center;
  gap: 9px;
  flex-shrink: 0;
  padding: 24px 20px 18px;
  color: var(--kd-ink);
}

.nearby-sheet__header h2 {
  margin: 0;
  color: var(--kd-primary);
  font-size: 20px;
  font-weight: 700;
  line-height: 1.35;
}

.nearby-sheet__list {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 0 20px 8px;
  -webkit-overflow-scrolling: touch;
}

.nearby-sheet__item {
  display: block;
  width: 100%;
  padding: 0;
  border: 0;
  background: transparent;
  text-align: left;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.nearby-sheet__item:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
  border-radius: 8px;
}

.nearby-sheet__empty {
  margin: 1.5rem 0 0;
  text-align: center;
  color: var(--kd-ink);
  font-size: 14px;
}
</style>

<style>
ion-modal.nearby-modal {
  contain: none;
  pointer-events: none;
  --height: 78%;
  --border-radius: 8px;
  --background: var(--kd-white);
  --box-shadow: 0 -2px 16px var(--kd-shadow);
  --backdrop-opacity: 0;
}

ion-modal.nearby-modal::part(backdrop) {
  display: none;
  pointer-events: none;
}

ion-modal.nearby-modal::part(content) {
  pointer-events: auto;
}

ion-modal.nearby-modal::part(handle) {
  width: 50px;
  height: 8px;
  margin-top: 18px;
  border-radius: 5px;
  background: var(--kd-ink-25);
}
</style>
