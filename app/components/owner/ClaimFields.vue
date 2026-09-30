<template>
  <div class="claim-fields">
    <label class="claim-fields__field">
      <span>How are you connected to this cafe?</span>
      <textarea
        :value="note"
        name="claim-note"
        rows="5"
        maxlength="500"
        placeholder="Example: I own this branch. Reach me on the cafe number or our Google Business email."
        :aria-invalid="Boolean(issues.note)"
        @input="emit('update:note', ($event.target as HTMLTextAreaElement).value)"
      />
    </label>
    <p v-if="issues.note" class="claim-fields__error" role="alert">{{ issues.note }}</p>
    <label class="claim-fields__field">
      <span>Email</span>
      <input
        :value="email"
        type="email"
        name="claim-email"
        autocomplete="email"
        placeholder="you@studio.ph"
        :aria-invalid="Boolean(issues.contact)"
        @input="emit('update:email', ($event.target as HTMLInputElement).value)"
      />
    </label>
    <label class="claim-fields__field">
      <span>Phone</span>
      <input
        :value="phone"
        type="tel"
        name="claim-phone"
        autocomplete="tel"
        placeholder="0917 123 4567"
        :aria-invalid="Boolean(issues.contact)"
        @input="emit('update:phone', ($event.target as HTMLInputElement).value)"
      />
    </label>
    <p v-if="issues.contact" class="claim-fields__error" role="alert">{{ issues.contact }}</p>
  </div>
</template>

<script lang="ts" setup>
defineProps<{
  note: string
  email: string
  phone: string
  issues: { note: string | null; contact: string | null }
}>()

const emit = defineEmits<{
  'update:note': [value: string]
  'update:email': [value: string]
  'update:phone': [value: string]
}>()
</script>

<style scoped>
.claim-fields {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.claim-fields__field {
  display: flex;
  flex-direction: column;
  gap: 6px;
  color: var(--kd-ink);
  font-size: 0.75rem;
  font-weight: 700;
}

.claim-fields__field input,
.claim-fields__field textarea {
  width: 100%;
  padding: 12px 16px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 22%, transparent);
  border-radius: 16px;
  background: #faf8f5;
  color: var(--kd-ink);
  font-family: inherit;
  font-size: 1rem;
  font-weight: 400;
}

.claim-fields__field input {
  min-height: 44px;
}

.claim-fields__field input:focus,
.claim-fields__field textarea:focus {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.claim-fields__error {
  margin: 0;
  color: var(--kd-destructive);
  font-size: 0.7875rem;
  font-weight: 700;
}
</style>
