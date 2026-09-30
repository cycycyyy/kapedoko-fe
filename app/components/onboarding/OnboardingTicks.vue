<template>
  <div class="onboarding-ticks" role="tablist" aria-label="Onboarding steps">
    <button
      v-for="step in 3"
      :key="step"
      type="button"
      role="tab"
      class="onboarding-ticks__tick"
      :class="{ 'is-on': activeStep === step - 1 }"
      :aria-selected="activeStep === step - 1"
      :aria-label="`Go to step ${step}`"
      @click="emit('goTo', step - 1)"
    />
  </div>
</template>

<script lang="ts" setup>
defineProps<{
  activeStep: number
}>()

const emit = defineEmits<{
  goTo: [step: number]
}>()
</script>

<style scoped>
.onboarding-ticks {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  margin-top: 20px;
}

.onboarding-ticks__tick {
  width: 44px;
  height: 44px;
  padding: 0;
  border: 0;
  background: transparent;
  cursor: pointer;
}

.onboarding-ticks__tick::after {
  content: '';
  display: block;
  width: 16px;
  height: 4px;
  margin: 0 auto;
  border-radius: 0;
  background: color-mix(in srgb, var(--kd-ink) 22%, transparent);
}

.onboarding-ticks__tick.is-on::after {
  background: var(--kd-accent);
}

.onboarding-ticks__tick:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}
</style>
