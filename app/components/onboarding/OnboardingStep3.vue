<template>
  <section class="onboarding-step" aria-labelledby="onboarding-step-3-title">
    <header class="onboarding-step__brand">
      <img
        src="/assets/kapedoko-horizontal-text_dark.png"
        alt="KapeDoko"
        width="120"
        height="26"
        class="onboarding-step__wordmark"
      />
    </header>

    <div class="onboarding-step__stage onboarding-step__stage--finish">
      <img
        src="/assets/kapedoko-logo_dark.png"
        alt=""
        width="46"
        height="60"
        class="onboarding-step__mark"
      />
      <h1 id="onboarding-step-3-title" class="onboarding-step__title">
        You’re all set!
      </h1>
    </div>

    <div class="onboarding-step__footer">
      <OnboardingTicks :active-step="activeStep" @go-to="emit('goTo', $event)" />
      <button type="button" class="onboarding-step__cta" @click="emit('complete')">
        Let’s go!
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
  complete: []
  goTo: [step: number]
}>()
</script>

<style scoped>
.onboarding-step__stage--finish {
  align-items: flex-start;
}

.onboarding-step__mark {
  display: block;
  width: 46px;
  height: 60px;
  object-fit: contain;
}

.onboarding-step__title {
  margin: 16px 0 0;
  max-width: 20rem;
  color: var(--kd-ink);
  font-size: 1.325rem;
  font-weight: 700;
  line-height: 1.05;
  letter-spacing: -0.03em;
}
</style>
