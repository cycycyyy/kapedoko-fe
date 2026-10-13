<template>
  <section class="onboarding-step" aria-labelledby="onboarding-step-2-title">
    <header class="onboarding-step__brand">
      <img
        src="/assets/kapedoko-horizontal-text_dark.png"
        alt="KapeDoko"
        width="120"
        height="26"
        class="onboarding-step__wordmark"
      />
    </header>

    <div class="onboarding-step__stage">
      <ClientOnly>
        <OnboardingTeachMap :active="activeStep === 1" />
        <template #fallback>
          <div class="teach-map-slot" aria-hidden="true" />
        </template>
      </ClientOnly>

      <p id="onboarding-step-2-title" class="onboarding-step__copy">
        Use our maps to find the exact location of coffee shops.
      </p>
    </div>

    <div class="onboarding-step__footer">
      <OnboardingTicks :active-step="activeStep" @go-to="emit('goTo', $event)" />
      <button type="button" class="onboarding-step__cta" @click="emit('next')">
        Next
      </button>
    </div>
  </section>
</template>

<script lang="ts" setup>
import OnboardingTeachMap from '~/components/onboarding/OnboardingTeachMap.client.vue'
import OnboardingTicks from '~/components/onboarding/OnboardingTicks.vue'
import './onboarding-step.css'

defineProps<{
  activeStep: number
}>()

const emit = defineEmits<{
  next: []
  goTo: [step: number]
}>()
</script>

<style scoped>
.teach-map-slot {
  height: min(42vh, 280px);
  min-height: 220px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 34%, transparent);
  border-radius: 16px;
  background: #faf8f5;
}
</style>
