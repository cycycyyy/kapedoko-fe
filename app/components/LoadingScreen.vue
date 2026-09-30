<template>
  <div class="splash" role="status" aria-live="polite" aria-label="Loading KapeDoko">
    <div class="splash__stack">
      <img
        :src="logo"
        alt=""
        class="splash__mark"
        width="140"
        height="97"
      />
      <span class="splash__rule" aria-hidden="true">
        <span class="splash__rule-fill" />
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
import logo from '~/assets/css/logos/kapedoko-logo-typography.svg'
</script>

<style scoped>
.splash {
  position: fixed;
  inset: 0;
  z-index: 10000;
  display: grid;
  place-items: center;
  width: 100%;
  min-height: 100dvh;
  height: 100dvh;
  padding:
    env(safe-area-inset-top)
    20px
    env(safe-area-inset-bottom);
  background: #faf8f5;
}

.splash__stack {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.splash__mark {
  display: block;
  width: min(168px, 52vw);
  height: auto;
}

.splash__rule {
  display: block;
  width: 72px;
  height: 3px;
  margin-top: 28px;
  overflow: hidden;
  border-radius: 999px;
  background: color-mix(in srgb, var(--kd-ink) 12%, transparent);
}

.splash__rule-fill {
  display: block;
  width: 42%;
  height: 100%;
  border-radius: inherit;
  background: var(--kd-accent);
  animation: splash-rule 1.15s cubic-bezier(0.16, 1, 0.3, 1) infinite;
}

@keyframes splash-rule {
  0% {
    transform: translateX(-130%);
  }

  100% {
    transform: translateX(250%);
  }
}

@media (prefers-reduced-motion: reduce) {
  .splash__rule-fill {
    width: 100%;
    animation: none;
    transform: none;
  }
}
</style>
