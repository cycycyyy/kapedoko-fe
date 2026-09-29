<template>
  <section class="onboarding-step" aria-labelledby="onboarding-step-3-title">
    <div class="onboarding-step__hero">
      <img
        src="/assets/kapedoko-logo_light.png"
        alt=""
        width="100"
        height="130"
        class="onboarding-step__logo"
      />
      <img
        src="/assets/kapedoko-text_light.png"
        alt="KapeDoko"
        width="153"
        height="106"
        class="onboarding-step__wordmark"
      />
    </div>

    <div class="onboarding-step__footer">
      <h1 id="onboarding-step-3-title" class="onboarding-step__copy">
        You’re all set!
      </h1>

      <button type="button" class="onboarding-step__cta" @click="emit('complete')">
        Let’s go!
      </button>
    </div>
  </section>
</template>

<script lang="ts" setup>
const emit = defineEmits<{
  complete: []
}>()
</script>

<style scoped>
.onboarding-step {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 100%;
  background: var(--kd-accent);
  color: var(--kd-ink);
  padding: max(2.75rem, env(safe-area-inset-top)) 0 max(1.5rem, env(safe-area-inset-bottom));
}

.onboarding-step__hero {
  flex: 1 1 auto;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 0;
  padding: 0 20px 1.5rem;
  gap: 18px;
}

.onboarding-step__logo {
  width: 100px;
  height: 130px;
  display: block;
  object-fit: contain;
}

.onboarding-step__wordmark {
  width: 153px;
  height: auto;
  display: block;
  object-fit: contain;
}

.onboarding-step__footer {
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0 20px;
}

.onboarding-step__copy {
  margin: 0 0 7.5rem;
  max-width: 325px;
  text-align: center;
  font-size: 24px;
  font-weight: 700;
  line-height: 1.2;
  color: var(--kd-ink);
}

.onboarding-step__cta {
  width: 100%;
  max-width: 350px;
  height: 45px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-white);
  color: var(--kd-ink);
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: opacity 160ms ease, transform 160ms ease;
}

.onboarding-step__cta:hover {
  opacity: 0.94;
}

.onboarding-step__cta:active {
  transform: scale(0.985);
}

.onboarding-step__cta:focus-visible {
  outline: 2px solid var(--kd-ink);
  outline-offset: 3px;
}

@media (prefers-reduced-motion: reduce) {
  .onboarding-step__cta {
    transition: none;
  }
}
</style>
