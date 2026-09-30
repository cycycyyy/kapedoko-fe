<template>
  <section class="onboarding-step" aria-labelledby="onboarding-step-1-title">
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
      <div class="teach-bag" aria-hidden="true">
        <p class="teach-bag__name">On each cafe</p>
        <div class="teach-bag__lines">
          <div class="teach-bag__line">
            <span class="teach-bag__key">
              <Wifi :size="15" :stroke-width="2.25" />
              <span>WiFi</span>
            </span>
            <span>Confirmed</span>
          </div>
          <div class="teach-bag__line">
            <span class="teach-bag__key">
              <Plug :size="15" :stroke-width="2.25" />
              <span>Outlets</span>
            </span>
            <span>Confirmed</span>
          </div>
        </div>
      </div>

      <p id="onboarding-step-1-title" class="onboarding-step__copy">
        Check if the coffee shop offers WiFi and power outlets by looking for the WiFi and power plug icons.
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
import { Plug, Wifi } from 'lucide-vue-next'
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
.teach-bag {
  padding: 16px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 34%, transparent);
  border-radius: 16px;
  background: #faf8f5;
  color: var(--kd-ink);
}

.teach-bag__name {
  margin: 0;
  font-size: 1.325rem;
  font-weight: 700;
  line-height: 1.05;
  letter-spacing: -0.03em;
}

.teach-bag__lines {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px solid color-mix(in srgb, var(--kd-ink) 12%, transparent);
}

.teach-bag__line {
  display: grid;
  grid-template-columns: 7rem max-content;
  column-gap: 8px;
  align-items: baseline;
  font-size: 0.7875rem;
  line-height: 1.3;
}

.teach-bag__key {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.teach-bag__key :deep(svg) {
  color: var(--kd-accent);
}

.teach-bag__line > span:last-child {
  font-weight: 700;
}
</style>
