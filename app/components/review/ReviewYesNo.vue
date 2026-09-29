<template>
  <fieldset class="yesno" :disabled="disabled">
    <legend v-if="legend" class="sr-only">{{ legend }}</legend>
    <div class="yesno__row" role="radiogroup" :aria-label="legend">
      <button
        type="button"
        class="yesno__card"
        :class="{ 'is-on': modelValue === true }"
        role="radio"
        :aria-checked="modelValue === true ? 'true' : 'false'"
        @click="emit('update:modelValue', true)"
      >
        Yes
      </button>
      <button
        type="button"
        class="yesno__card"
        :class="{ 'is-on': modelValue === false }"
        role="radio"
        :aria-checked="modelValue === false ? 'true' : 'false'"
        @click="emit('update:modelValue', false)"
      >
        No
      </button>
    </div>
  </fieldset>
</template>

<script lang="ts" setup>
defineProps<{
  modelValue: boolean | null
  legend: string
  disabled?: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
}>()
</script>

<style scoped>
.yesno {
  margin: 0;
  padding: 0;
  border: 0;
}

.yesno__row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.yesno__card {
  position: relative;
  isolation: isolate;
  display: grid;
  place-items: center;
  min-height: 100px;
  overflow: hidden;
  padding: 0 16px;
  border: 1px solid var(--kd-primary);
  border-radius: 5px;
  background: var(--kd-white);
  color: var(--kd-ink);
  font-size: 20px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: color 180ms cubic-bezier(0.16, 1, 0.3, 1);
}

.yesno__card::before {
  content: '';
  position: absolute;
  inset: 0;
  z-index: -1;
  background: var(--kd-accent);
  transform: scale(0.72);
  opacity: 0;
  filter: blur(4px);
  transition:
    transform 240ms cubic-bezier(0.16, 1, 0.3, 1),
    opacity 180ms cubic-bezier(0.16, 1, 0.3, 1),
    filter 240ms cubic-bezier(0.16, 1, 0.3, 1);
}

.yesno__card.is-on {
  color: var(--kd-ink);
  border-color: var(--kd-accent);
}

.yesno__card.is-on::before {
  opacity: 1;
  filter: none;
  transform: scale(1);
}

.yesno__card:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.yesno__card.is-on:focus-visible {
  outline-color: var(--kd-ink);
  box-shadow: 0 0 0 4px var(--kd-primary);
}

.yesno__card:active {
  transform: scale(0.98);
}

.yesno:disabled .yesno__card {
  opacity: 0.55;
  cursor: not-allowed;
}

.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

@media (hover: hover) and (pointer: fine) {
  .yesno__card:hover:not(.is-on) {
    background: var(--kd-secondary);
  }
}

@media (prefers-reduced-motion: reduce) {
  .yesno__card,
  .yesno__card::before {
    transition: none;
  }

  .yesno__card:active {
    transform: none;
  }
}
</style>
