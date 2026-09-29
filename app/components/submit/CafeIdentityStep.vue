<template>
  <section class="identity" aria-labelledby="identity-title">
    <div class="identity__intro">
      <div class="identity__title">
        <Coffee class="identity__mark" :size="24" :stroke-width="2" aria-hidden="true" />
        <h2 id="identity-title">What’s the cafe called?</h2>
      </div>
      <p class="identity__lede">
        This listing stays off the map until we review it. WiFi and outlets come from visitor reviews, not this form.
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
            <Plus :size="22" :stroke-width="2.25" aria-hidden="true" />
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

const props = defineProps<{
  name: string
  logoFile: File | null
  nameIssue?: string | null
  logoIssue?: string | null
}>()

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
  gap: 14px;
}

.identity__intro {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.identity__title {
  display: flex;
  align-items: flex-start;
  gap: 9px;
  color: var(--kd-ink);
}

.identity__mark {
  flex: 0 0 auto;
  margin-top: 2px;
  transform-origin: 50% 90%;
  animation: stamp-in 420ms cubic-bezier(0.16, 1, 0.3, 1) both;
}

#identity-title {
  margin: 0;
  min-width: 0;
  color: var(--kd-ink);
  font-size: 24px;
  font-weight: 700;
  line-height: 1.2;
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
  font-size: 12px;
  font-weight: 700;
  line-height: 1.35;
}

.identity__hint {
  margin: 0;
  color: var(--kd-ink);
  font-size: 12px;
  font-weight: 400;
  line-height: 1.35;
}

.identity__field {
  display: flex;
  flex-direction: column;
  gap: 8px;
  color: var(--kd-ink);
  font-size: 12px;
  font-weight: 700;
}

.identity__field input {
  height: 50px;
  padding: 0 16px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-secondary);
  color: var(--kd-ink);
  font-size: 16px;
  font-weight: 400;
  font-family: inherit;
  caret-color: var(--kd-primary);
}

.identity__field input::placeholder {
  color: #5c534c;
}

.identity__field input:focus {
  outline: none;
  box-shadow: 0 0 0 2px var(--kd-white), 0 0 0 4px var(--kd-primary);
}

.identity__error {
  margin: 0;
  color: var(--kd-closed);
  font-size: 12px;
  font-weight: 700;
}

.identity__logo {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.identity__logo-label {
  margin: 0;
  color: var(--kd-ink);
  font-size: 12px;
  font-weight: 700;
}

.identity__logo-row {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-top: 2px;
}

.identity__logo-btn {
  display: grid;
  place-items: center;
  width: 96px;
  height: 96px;
  padding: 0;
  overflow: hidden;
  border: 0;
  border-radius: 8px;
  background: var(--kd-secondary);
  color: var(--kd-ink);
  cursor: pointer;
  transition: transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.identity__logo-btn:active {
  transform: scale(0.96);
}

.identity__logo-empty {
  display: grid;
  justify-items: center;
  gap: 6px;
  font-size: 12px;
  font-weight: 700;
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
  gap: 8px;
}

.identity__text-btn {
  min-height: 44px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-ink);
  font-size: 12px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
}

.identity__text-btn--quiet {
  font-weight: 400;
}

.identity__logo-btn:focus-visible,
.identity__text-btn:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

@media (hover: hover) and (pointer: fine) {
  .identity__field:hover input:not(:focus) {
    box-shadow: 0 0 0 1px color-mix(in srgb, var(--kd-primary) 18%, transparent);
  }

  .identity__logo-btn:hover {
    filter: brightness(0.98);
  }

  .identity__text-btn:hover {
    opacity: 0.88;
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
</style>
