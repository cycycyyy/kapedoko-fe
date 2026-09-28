<template>
  <IonPage>
    <IonContent class="auth-content">
      <div class="auth">
        <header class="auth__header">
          <img
            src="/assets/kapedoko-logo_dark.png"
            alt=""
            width="46"
            height="60"
            class="auth__mark"
          />
          <h1>{{ title }}</h1>
          <p v-if="lede">{{ lede }}</p>
        </header>
        <slot />
      </div>
    </IonContent>
  </IonPage>
</template>

<script lang="ts" setup>
defineProps<{
  title: string
  lede?: string
}>()
</script>

<style scoped>
.auth-content {
  --background: var(--kd-secondary);
  --padding-start: 0;
  --padding-end: 0;
  --padding-top: 0;
  --padding-bottom: 0;
}

.auth {
  display: flex;
  flex-direction: column;
  min-height: 100%;
  max-width: 480px;
  margin-inline: auto;
  padding: max(2.75rem, calc(env(safe-area-inset-top) + 16px)) 20px calc(2rem + env(safe-area-inset-bottom));
  background: var(--kd-secondary);
}

.auth__header {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 8px;
  margin-bottom: 24px;
  color: var(--kd-primary);
}

.auth__mark {
  display: block;
  width: 46px;
  height: 60px;
  object-fit: contain;
}

.auth__header h1 {
  margin: 8px 0 0;
  font-size: 24px;
  font-weight: 700;
  line-height: 1.2;
}

.auth__header p {
  margin: 0;
  max-width: 28rem;
  color: var(--kd-ink);
  font-size: 14px;
  line-height: 1.45;
}
</style>

<style>
.auth-form {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.auth-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
  color: var(--kd-primary);
  font-size: 12px;
  font-weight: 700;
}

.auth-field input {
  width: 100%;
  height: 50px;
  padding: 0 16px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-white);
  color: var(--kd-ink);
  font-size: 16px;
  font-weight: 400;
  font-family: inherit;
  caret-color: var(--kd-primary);
}

.auth-field input::placeholder {
  color: color-mix(in srgb, var(--kd-ink) 46%, var(--kd-white));
}

.auth-field input:focus {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.auth-error {
  margin: 0 0 14px;
  color: var(--kd-closed);
  font-size: 14px;
  font-weight: 700;
  line-height: 1.4;
}

.auth-submit {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  min-height: 45px;
  margin-top: 6px;
  padding: 0 20px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-primary);
  color: var(--kd-white);
  font-size: 16px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.auth-submit:disabled {
  opacity: 0.55;
  cursor: default;
}

.auth-submit:focus-visible,
.auth-links a:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
}

.auth-links {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 18px;
  color: var(--kd-ink);
  font-size: 14px;
  line-height: 1.4;
}

.auth-links a {
  color: var(--kd-primary);
  font-weight: 700;
}

.auth-note {
  margin: 0;
  color: var(--kd-ink);
  font-size: 14px;
  line-height: 1.45;
}

:root.is-android .auth-submit {
  min-height: 48px;
}

@media (prefers-reduced-motion: reduce) {
  .auth-submit:active {
    transform: none;
  }
}
</style>
