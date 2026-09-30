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
      <div class="teach-map" aria-hidden="true">
        <span class="teach-map__street teach-map__street--h" />
        <span class="teach-map__street teach-map__street--h2" />
        <span class="teach-map__street teach-map__street--v" />
        <span class="teach-map__street teach-map__street--v2" />
        <img
          src="/assets/bean-pin.png"
          alt=""
          width="36"
          height="48"
          class="teach-map__pin"
        />
        <span class="teach-map__label">Exact location</span>
      </div>

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
.teach-map {
  position: relative;
  height: 220px;
  overflow: hidden;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 34%, transparent);
  border-radius: 16px;
  background: #faf8f5;
}

.teach-map__street {
  position: absolute;
  background: color-mix(in srgb, var(--kd-ink) 12%, transparent);
}

.teach-map__street--h {
  top: 38%;
  left: 0;
  right: 0;
  height: 1px;
}

.teach-map__street--h2 {
  top: 68%;
  left: 0;
  right: 0;
  height: 1px;
}

.teach-map__street--v {
  top: 0;
  bottom: 0;
  left: 32%;
  width: 1px;
}

.teach-map__street--v2 {
  top: 0;
  bottom: 0;
  left: 71%;
  width: 1px;
}

.teach-map__pin {
  position: absolute;
  top: 42%;
  left: 32%;
  width: 36px;
  height: 48px;
  transform: translate(-50%, -88%);
  object-fit: contain;
}

.teach-map__label {
  position: absolute;
  top: 42%;
  left: calc(32% + 18px);
  padding: 6px 10px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 34%, transparent);
  border-radius: 8px;
  background: #faf8f5;
  color: var(--kd-ink);
  font-size: 0.75rem;
  font-weight: 700;
  line-height: 1.3;
  transform: translateY(-50%);
}
</style>
