<template>
  <div class="audit-answers" :class="{ 'is-invalid': marked }">
    <fieldset
      class="audit-answers__set"
      :aria-invalid="marked || undefined"
      :aria-describedby="describedById"
    >
      <legend class="audit-answers__legend" :class="{ 'sr-only': hideLegend }">
        {{ legend }}
        <span v-if="needed" class="audit-answers__need">Needed</span>
      </legend>
      <div class="audit-answers__track">
        <label v-for="option in options" :key="option.value" class="audit-answers__option">
          <input
            type="radio"
            :name="groupName"
            :value="option.value"
            :checked="model === option.value"
            @change="model = option.value"
          >
          <span>{{ option.label }}</span>
        </label>
      </div>
    </fieldset>
    <p v-if="error" :id="errorId" class="audit-answers__error" role="alert">{{ error }}</p>
  </div>
</template>

<script lang="ts" setup generic="T extends string">
const model = defineModel<T | null>({ required: true })

const props = withDefaults(defineProps<{
  legend: string
  options: Array<{ value: T; label: string }>
  invalid?: boolean
  describedBy?: string
  error?: string | null
  hideLegend?: boolean
  needed?: boolean
}>(), {
  invalid: false,
  error: null,
  hideLegend: false,
  needed: false,
})

const errorId = `${useId()}-error`
const groupName = `${useId()}-choice`
const marked = computed(() => props.invalid || Boolean(props.error))
const describedById = computed(() => (props.error ? errorId : props.describedBy || undefined))
</script>

<style scoped>
.audit-answers {
  min-width: 0;
  container-type: inline-size;
}

.audit-answers__set {
  position: relative;
  margin: 0;
  padding: 0;
  border: 0;
  min-width: 0;
}

.audit-answers__legend {
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin: 0 0 8px;
  padding: 0;
  color: var(--kd-ink);
  font-size: 0.7875rem;
  font-weight: 700;
  line-height: 1.3;
}

.audit-answers__need {
  color: var(--kd-destructive);
  font-size: 0.75rem;
}

.audit-answers__track {
  display: flex;
  min-width: 0;
}

.audit-answers__option {
  position: relative;
  display: flex;
  flex: 1 1 0;
  align-items: center;
  justify-content: center;
  min-width: 0;
  min-height: 44px;
  padding: 8px 10px;
  overflow: hidden;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 22%, transparent);
  background: #f2f2f2;
  color: var(--kd-ink);
  font-size: 0.7875rem;
  font-weight: 400;
  line-height: 1.2;
  text-align: center;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.audit-answers__option + .audit-answers__option {
  margin-left: -1px;
}

.audit-answers__option:first-child {
  border-radius: 16px 0 0 16px;
}

.audit-answers__option:last-child {
  border-radius: 0 16px 16px 0;
}

.audit-answers__option:first-child:last-child {
  border-radius: 16px;
}

.audit-answers__option::before {
  content: '';
  position: absolute;
  inset: 0;
  background: var(--kd-accent);
  transform: scaleX(0);
  transform-origin: left center;
  transition: transform 180ms cubic-bezier(0.16, 1, 0.3, 1);
}

.audit-answers__option:has(:checked) {
  z-index: 1;
  border-color: var(--kd-accent);
  font-weight: 700;
}

.audit-answers__option:has(:checked)::before {
  transform: scaleX(1);
}

.audit-answers__option span {
  position: relative;
  z-index: 1;
}

.audit-answers__option input {
  position: absolute;
  inset: 0;
  z-index: 2;
  margin: 0;
  opacity: 0;
  cursor: pointer;
}

.audit-answers.is-invalid .audit-answers__option:not(:has(:checked)) {
  border-color: var(--kd-destructive);
}

.audit-answers__option:focus-within {
  z-index: 2;
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.audit-answers__error {
  margin: 8px 0 0;
  color: var(--kd-destructive);
  font-size: 0.7875rem;
  font-weight: 700;
  line-height: 1.3;
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

@container (max-width: 17rem) {
  .audit-answers__track {
    flex-direction: column;
  }

  .audit-answers__option,
  .audit-answers__option + .audit-answers__option {
    margin-left: 0;
  }

  .audit-answers__option + .audit-answers__option {
    margin-top: -1px;
  }

  .audit-answers__option:first-child {
    border-radius: 16px 16px 0 0;
  }

  .audit-answers__option:last-child {
    border-radius: 0 0 16px 16px;
  }
}

@media (hover: hover) and (pointer: fine) {
  .audit-answers__option:hover:not(:has(:checked)) {
    background: color-mix(in srgb, var(--kd-ink) 6%, #f2f2f2);
  }
}

@media (prefers-reduced-motion: reduce) {
  .audit-answers__option::before {
    display: none;
    transition: none;
  }

  .audit-answers__option:has(:checked) {
    background: var(--kd-accent);
  }
}

:root.is-android .audit-answers__option {
  min-height: 48px;
}
</style>
