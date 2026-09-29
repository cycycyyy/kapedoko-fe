<template>
  <section class="identity" aria-labelledby="identity-title">
    <div class="identity__intro">
      <div class="identity__title">
        <Coffee class="identity__mark" :size="18" :stroke-width="2.25" aria-hidden="true" />
        <h2 id="identity-title">What’s the cafe called?</h2>
      </div>
      <p class="identity__lede">
        {{ lede }}
      </p>
    </div>

    <label class="identity__field">
      <span>Cafe name</span>
      <input
        :value="name"
        type="text"
        name="cafe-name"
        autocomplete="organization"
        maxlength="80"
        placeholder="e.g. Lamp Quarters Cafe"
        :aria-invalid="Boolean(nameIssue)"
        :aria-describedby="nameIssue ? 'identity-name-error' : undefined"
        @input="emit('update:name', ($event.target as HTMLInputElement).value)"
      />
    </label>
    <p v-if="nameIssue" id="identity-name-error" class="identity__error" role="alert">
      {{ nameIssue }}
    </p>

    <div class="identity__logo">
      <p class="identity__logo-label" id="logo-label">Logo</p>
      <p class="identity__hint" id="logo-hint">Optional. JPG, PNG, or WebP, under 2 MB.</p>

      <div class="identity__logo-row">
        <button
          type="button"
          class="identity__logo-btn"
          aria-labelledby="logo-label"
          :aria-describedby="localLogoIssue || logoIssue ? 'logo-hint identity-logo-error' : 'logo-hint'"
          @click="pick"
        >
          <img
            v-if="preview"
            :src="preview"
            alt=""
            class="identity__preview"
          />
          <span v-else class="identity__logo-empty">
            <Plus :size="18" :stroke-width="2.25" aria-hidden="true" />
            Add logo
          </span>
        </button>

        <div class="identity__logo-actions">
          <button type="button" class="identity__text-btn" @click="pick">
            {{ preview ? 'Replace logo' : 'Choose image' }}
          </button>
          <button
            v-if="preview"
            type="button"
            class="identity__text-btn identity__text-btn--quiet"
            @click="clear"
          >
            Remove
          </button>
        </div>
      </div>

      <p v-if="localLogoIssue || logoIssue" id="identity-logo-error" class="identity__error" role="alert">
        {{ localLogoIssue || logoIssue }}
      </p>
    </div>

    <input
      ref="fileRef"
      class="sr-only"
      type="file"
      accept="image/jpeg,image/png,image/webp"
      @change="onFile"
    />
  </section>
</template>

<script lang="ts" setup>
import { Coffee, Plus } from 'lucide-vue-next'
import { logoFileError } from '~/utils/logo'

const props = withDefaults(defineProps<{
  name: string
  logoFile: File | null
  nameIssue?: string | null
  logoIssue?: string | null
  lede?: string
}>(), {
  lede: 'This listing stays off the map until we review it. WiFi and outlets come from visitor reviews, not this form.',
})

const emit = defineEmits<{
  'update:name': [value: string]
  'update:logoFile': [value: File | null]
}>()

const fileRef = ref<HTMLInputElement | null>(null)
const preview = ref<string | null>(null)
const localLogoIssue = ref<string | null>(null)

const pick = () => {
  fileRef.value?.click()
}

const revoke = () => {
  if (preview.value) URL.revokeObjectURL(preview.value)
  preview.value = null
}

const clear = () => {
  revoke()
  localLogoIssue.value = null
  if (fileRef.value) fileRef.value.value = ''
  emit('update:logoFile', null)
}

const onFile = (event: Event) => {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0] ?? null
  if (!file) return

  const issue = logoFileError(file)
  if (issue) {
    input.value = ''
    localLogoIssue.value = issue
    return
  }

  localLogoIssue.value = null
  revoke()
  preview.value = URL.createObjectURL(file)
  emit('update:logoFile', file)
}

watch(
  () => props.logoFile,
  (file) => {
    if (!file && preview.value) revoke()
  },
)

onBeforeUnmount(revoke)
</script>

<style scoped>
.identity {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.identity__intro {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.identity__title {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  color: var(--kd-ink);
}

.identity__mark {
  flex: 0 0 auto;
  margin-top: 2px;
  color: var(--kd-accent);
  transform-origin: 50% 90%;
  animation: stamp-in 420ms cubic-bezier(0.16, 1, 0.3, 1) both;
}

#identity-title {
  margin: 0;
  min-width: 0;
  color: var(--kd-ink);
  font-size: 1.325rem;
  font-weight: 700;
  line-height: 1.05;
  letter-spacing: -0.03em;
}

@keyframes stamp-in {
  from {
    opacity: 0;
    filter: blur(2px);
    transform: scale(0.84) translateY(-5px);
  }
  to {
    opacity: 1;
    filter: none;
    transform: none;
  }
}

.identity__lede {
  margin: 0;
  color: var(--kd-ink);
  font-size: 0.7875rem;
  font-weight: 400;
  line-height: 1.3;
}

.identity__hint {
  margin: 0;
  color: var(--kd-ink);
  font-size: 0.75rem;
  font-weight: 400;
  line-height: 1.3;
}

.identity__field {
  display: flex;
  flex-direction: column;
  gap: 6px;
  color: var(--kd-ink);
  font-size: 0.75rem;
  font-weight: 700;
  line-height: 1.3;
}

.identity__field input {
  min-height: 44px;
  height: 44px;
  padding: 0 16px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 22%, transparent);
  border-radius: 16px;
  background: #f2f2f2;
  color: var(--kd-ink);
  font-size: 0.95rem;
  font-weight: 400;
  font-family: inherit;
  caret-color: var(--kd-primary);
}

.identity__field input::placeholder {
  color: color-mix(in srgb, var(--kd-ink) 45%, transparent);
}

.identity__field input:focus {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.identity__field input[aria-invalid='true'] {
  border-color: var(--kd-destructive);
}

.identity__error {
  margin: 0;
  color: var(--kd-destructive);
  font-size: 0.7875rem;
  font-weight: 700;
  line-height: 1.35;
}

.identity__logo {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.identity__logo-label {
  margin: 0;
  color: var(--kd-ink);
  font-size: 0.75rem;
  font-weight: 700;
  line-height: 1.3;
}

.identity__logo-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 2px;
}

.identity__logo-btn {
  display: grid;
  place-items: center;
  width: 96px;
  height: 96px;
  padding: 0;
  overflow: hidden;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 34%, transparent);
  border-radius: 8px;
  background: #f2f2f2;
  color: var(--kd-ink);
  cursor: pointer;
  transition: transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.identity__logo-btn:active {
  transform: scale(0.94);
}

.identity__logo-empty {
  display: grid;
  justify-items: center;
  gap: 6px;
  font-size: 0.75rem;
  font-weight: 700;
  line-height: 1.3;
}

.identity__preview {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.identity__logo-actions {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 4px;
}

.identity__text-btn {
  min-height: 44px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-primary);
  font-size: 0.7875rem;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
}

.identity__text-btn--quiet {
  color: var(--kd-ink);
  font-weight: 400;
}

.identity__logo-btn:focus-visible,
.identity__text-btn:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
  border-radius: 8px;
}

.identity__text-btn:focus-visible {
  border-radius: 8px;
}

@media (hover: hover) and (pointer: fine) {
  .identity__logo-btn:hover {
    background: color-mix(in srgb, var(--kd-ink) 4%, #f2f2f2);
  }

  .identity__text-btn:hover {
    text-decoration: underline;
    text-underline-offset: 3px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .identity__mark {
    animation: stamp-in-quiet 200ms ease both;
  }

  .identity__logo-btn {
    transition: none;
  }

  .identity__logo-btn:active {
    transform: none;
  }
}

@keyframes stamp-in-quiet {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

:root.is-android .identity__field input {
  min-height: 48px;
  height: 48px;
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

::selection {
  background: var(--kd-accent);
  color: var(--kd-ink);
}
</style>
