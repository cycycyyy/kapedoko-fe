<template>
  <section class="onboarding-step" aria-labelledby="onboarding-step-2-title">
    <header class="onboarding-step__brand">
      <img
        src="/assets/kapedoko-logo_dark.png"
        alt="KapeDoko"
        width="46"
        height="60"
        class="onboarding-step__logo"
      />
    </header>

    <div class="onboarding-step__stage" aria-hidden="true" />

    <div class="onboarding-step__footer">
      <p id="onboarding-step-2-title" class="onboarding-step__copy">
        Use our maps to find the exact location of coffee shops.
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
  background: #ffffff;
  color: #000000;
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
  min-height: 215px;
}

.onboarding-step__footer {
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0 20px;
}

.onboarding-step__copy {
  margin: 0;
  max-width: 325px;
  text-align: center;
  font-size: 16px;
  font-weight: 700;
  line-height: 1.375;
  color: #000000;
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
  background: rgb(30 30 30 / 0.25);
  cursor: pointer;
  transition: background-color 180ms ease, transform 180ms ease;
}

.onboarding-step__dot.is-active {
  background: #372d25;
  transform: scale(1.08);
}

.onboarding-step__dot:focus-visible {
  outline: 2px solid #372d25;
  outline-offset: 3px;
}

.onboarding-step__cta {
  width: 100%;
  max-width: 350px;
  height: 45px;
  border: 0;
  border-radius: 8px;
  background: #372d25;
  color: #ffffff;
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
  outline: 2px solid #372d25;
  outline-offset: 3px;
}

@media (prefers-reduced-motion: reduce) {
  .onboarding-step__dot,
  .onboarding-step__cta {
    transition: none;
  }
}
</style>
