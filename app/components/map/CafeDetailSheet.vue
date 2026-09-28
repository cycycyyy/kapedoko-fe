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
    <CafeDetailContent
      v-if="cafe"
      :cafe="cafe"
      variant="sheet"
      @review="emit('review')"
    />
  </IonModal>
</template>

<script lang="ts" setup>
import type { Cafe } from '~/types/cafe'
import CafeDetailContent from '~/components/cafe/CafeDetailContent.vue'

const SHEET_HEIGHT = 0.88
const PEEK_VIEWPORT = 0.62
const PEEK = PEEK_VIEWPORT / SHEET_HEIGHT
const EXPANDED = 1
const BREAKPOINTS = [0, PEEK, EXPANDED]

defineProps<{
  open: boolean
  cafe: Cafe | null
}>()

const emit = defineEmits<{
  'update:open': [value: boolean]
  present: []
  dismissed: []
  review: []
}>()

const onPresent = () => emit('present')
const onDismiss = () => {
  emit('update:open', false)
  emit('dismissed')
}
</script>

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
