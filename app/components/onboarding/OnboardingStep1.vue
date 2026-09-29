<template>
  <section class="onboarding-step" aria-labelledby="onboarding-step-1-title">
    <header class="onboarding-step__brand">
      <img
        src="/assets/kapedoko-logo_dark.png"
        alt="KapeDoko"
        width="46"
        height="60"
        class="onboarding-step__logo"
      />
    </header>

    <div class="onboarding-step__stage">
      <img
        src="/assets/onboarding_graphic-1.png"
        alt="Cafe cards showing ratings, WiFi, and power outlet icons"
        width="350"
        height="215"
        class="onboarding-step__graphic"
      />
    </div>

    <div class="onboarding-step__footer">
      <div class="onboarding-step__icons" aria-hidden="true">
        <Wifi :size="36" :stroke-width="2" />
        <Plug :size="36" :stroke-width="2" />
      </div>

      <p id="onboarding-step-1-title" class="onboarding-step__copy">
        Check if the coffee shop offers WiFi and power outlets by looking for the WiFi and power plug icons.
      </p>

      <div class="onboarding-step__dots" role="tablist" aria-label="Onboarding steps">
        <button
          v-for="step in 3"
          :key="step"
          type="button"
          role="tab"
          class="onboarding-step__dot"
          :class="{ 'is-active': activeStep === step - 1 }"
          :aria-selected="activeStep === step - 1"
          :aria-label="`Go to step ${step}`"
          @click="emit('goTo', step - 1)"
        />
      </div>

      <button type="button" class="onboarding-step__cta" @click="emit('next')">
        Next
      </button>
    </div>
  </section>
</template>

<script lang="ts" setup>
import { Plug, Wifi } from 'lucide-vue-next'

defineProps<{
  activeStep: number
}>()

const emit = defineEmits<{
  next: []
  goTo: [step: number]
}>()
</script>

<style scoped>
.onboarding-step {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 100%;
  background: var(--kd-white);
  color: var(--kd-black);
  padding: max(2.75rem, env(safe-area-inset-top)) 0 max(1.5rem, env(safe-area-inset-bottom));
}

.onboarding-step__brand {
  display: flex;
  justify-content: center;
  flex-shrink: 0;
}

.onboarding-step__logo {
  width: 46px;
  height: 60px;
  display: block;
  object-fit: contain;
}

.onboarding-step__stage {
  flex: 1 1 auto;
  display: flex;
  align-items: center;
  min-height: 0;
  overflow: hidden;
  padding-top: 1.5rem;
}

.onboarding-step__graphic {
  width: 89.75%;
  max-width: 350px;
  height: auto;
  margin-left: 29%;
  flex-shrink: 0;
  filter: drop-shadow(0 2px 8px var(--kd-shadow));
}

.onboarding-step__footer {
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0 20px;
}

.onboarding-step__icons {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  color: var(--kd-black);
  margin-bottom: 16px;
}

.onboarding-step__copy {
  margin: 0;
  max-width: 325px;
  text-align: center;
  font-size: 16px;
  font-weight: 700;
  line-height: 1.375;
  color: var(--kd-black);
}

.onboarding-step__dots {
  display: flex;
  justify-content: center;
  gap: 3.2px;
  margin: 22px 0 18px;
}

.onboarding-step__dot {
  width: 9.5px;
  height: 9.5px;
  padding: 0;
  border: 0;
  border-radius: 999px;
  background: var(--kd-ink-25);
  cursor: pointer;
  transition: background-color 180ms ease, transform 180ms ease;
}

.onboarding-step__dot.is-active {
  background: var(--kd-accent);
  transform: scale(1.08);
}

.onboarding-step__dot:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
}

.onboarding-step__cta {
  width: 100%;
  max-width: 350px;
  height: 45px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-accent);
  color: var(--kd-ink);
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: opacity 160ms ease, transform 160ms ease;
}

.onboarding-step__cta:hover {
  opacity: 0.92;
}

.onboarding-step__cta:active {
  transform: scale(0.985);
}

.onboarding-step__cta:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
}

@media (prefers-reduced-motion: reduce) {
  .onboarding-step__dot,
  .onboarding-step__cta {
    transition: none;
  }
}
</style>
