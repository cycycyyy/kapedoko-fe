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
        <h2>Cafes near me</h2>
      </header>

      <div class="nearby-sheet__list" role="list" aria-label="Cafes near me">
        <p v-if="cafes.length === 0" class="nearby-sheet__empty">
          No coffee shops nearby.
        </p>

        <div
          v-for="cafe in cafes"
          :id="`nearby-cafe-${cafe.id}`"
          :key="cafe.id"
          class="nearby-sheet__item"
          role="listitem"
        >
          <CafeCard
            :cafe="cafe"
            :selected="cafe.id === selectedId"
            :distance-label="distances[cafe.id]"
            @select="emit('select', $event)"
          />
        </div>
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
  background: #f2f2f2;
  padding: 8px 0 calc(12px + env(safe-area-inset-bottom));
  font-family: 'Kumbh Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

.nearby-sheet__header {
  display: flex;
  align-items: center;
  gap: 9px;
  flex-shrink: 0;
  padding: 24px 20px 18px;
  color: var(--kd-ink);
}

.nearby-sheet__header :deep(svg) {
  color: var(--kd-accent);
}

.nearby-sheet__header h2 {
  margin: 0;
  color: var(--kd-ink);
  font-size: 1.05rem;
  font-weight: 700;
  line-height: 1.2;
}

.nearby-sheet__list {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 0;
  padding: 0 0 8px;
  -webkit-overflow-scrolling: touch;
}

.nearby-sheet__item {
  display: block;
  width: 100%;
}

.nearby-sheet__empty {
  margin: 1.5rem 0 0;
  text-align: center;
  color: var(--kd-ink);
  font-size: 0.7875rem;
}
</style>

<style>
ion-modal.nearby-modal {
  contain: none;
  pointer-events: none;
  --height: 78%;
  --border-radius: 16px;
  --background: #f2f2f2;
  --box-shadow: 0 -4px 20px color-mix(in srgb, #1c1917 12%, transparent);
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
  height: 5px;
  margin-top: 12px;
  border-radius: 999px;
  background: color-mix(in srgb, #1c1917 25%, transparent);
}
</style>
