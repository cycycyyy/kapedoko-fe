<template>
  <section class="onboarding-step" aria-labelledby="onboarding-step-1-title">
    <header class="onboarding-step__brand">
      <img
        src="/assets/kapedoko-horizontal-text_dark.png"
        alt="KapeDoko"
        width="120"
        height="26"
        class="onboarding-step__wordmark"
      />
    </header>

    <div class="onboarding-step__stage">
      <div class="teach-bag" :class="{ 'is-on': activeStep === 0 }" aria-hidden="true">
        <div class="teach-bag__mast">
          <span class="teach-bag__logo">
            <img
              src="/assets/kapedoko-logo_dark.png"
              alt=""
              width="40"
              height="40"
              class="teach-bag__mark"
            />
          </span>
          <div class="teach-bag__copy">
            <p class="teach-bag__name">On each cafe</p>
          </div>
        </div>

        <div class="teach-bag__lines">
          <div class="teach-bag__marks">
            <span
              class="teach-bag__stamp"
              data-stamp="team"
              style="--tilt: -1.4deg; --i: 0"
            >
              <span class="teach-bag__noun">
                <Wifi :size="15" :stroke-width="2.25" />
                WiFi
              </span>
              <span class="teach-bag__word">Yes</span>
            </span>
            <span
              class="teach-bag__stamp"
              data-stamp="team"
              style="--tilt: 1.6deg; --i: 1"
            >
              <span class="teach-bag__noun">
                <Plug :size="15" :stroke-width="2.25" />
                Outlets
              </span>
              <span class="teach-bag__word">Yes</span>
            </span>
          </div>
        </div>
      </div>

      <p id="onboarding-step-1-title" class="onboarding-step__copy">
        Check if the coffee shop offers WiFi and power outlets by looking for the WiFi and power plug icons.
      </p>
    </div>

    <div class="onboarding-step__footer">
      <OnboardingTicks :active-step="activeStep" @go-to="emit('goTo', $event)" />
      <button type="button" class="onboarding-step__cta" @click="emit('next')">
        Next
      </button>
    </div>
  </section>
</template>

<script lang="ts" setup>
import { Plug, Wifi } from 'lucide-vue-next'
import OnboardingTicks from '~/components/onboarding/OnboardingTicks.vue'
import './onboarding-step.css'

defineProps<{
  activeStep: number
}>()

const emit = defineEmits<{
  next: []
  goTo: [step: number]
}>()
</script>

<style scoped>
.teach-bag {
  padding: 16px 16px 12px;
  overflow: hidden;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 34%, transparent);
  border-radius: 16px;
  background: #faf8f5;
  color: var(--kd-ink);
}

.teach-bag.is-on {
  animation: teach-bag-settle 460ms cubic-bezier(0.16, 1, 0.3, 1) both;
}

.teach-bag__mast {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
}

.teach-bag__logo {
  display: flex;
  flex: 0 0 auto;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  overflow: hidden;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 34%, transparent);
  border-radius: 8px;
  background: #faf8f5;
}

.teach-bag__mark {
  width: 100%;
  height: 100%;
  padding: 4px;
  object-fit: contain;
}

.teach-bag__copy {
  display: flex;
  flex-direction: column;
  gap: 1px;
  min-width: 0;
}

.teach-bag__name {
  margin: 0;
  font-size: 1.325rem;
  font-weight: 700;
  line-height: 1.05;
  letter-spacing: -0.03em;
}

.teach-bag__lines {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 8px;
  margin: 0;
  padding-top: 10px;
  overflow: visible;
  border-top: 1px solid color-mix(in srgb, var(--kd-ink) 12%, transparent);
}

.teach-bag.is-on .teach-bag__lines {
  animation: teach-bag-reprint 520ms cubic-bezier(0.16, 1, 0.3, 1) both;
}

.teach-bag__marks {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 10px;
  max-width: 100%;
  padding: 4px 4px 6px 0;
}

.teach-bag__stamp {
  display: grid;
  flex: 0 0 auto;
  gap: 2px;
  min-width: 120px;
  padding: 10px 12px 9px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 34%, transparent);
  border-radius: 8px;
  background: color-mix(in srgb, var(--kd-accent) 16%, #faf8f5);
  color: var(--kd-ink);
  transform: rotate(var(--tilt, -1.4deg));
  transform-origin: 30% 80%;
}

.teach-bag.is-on .teach-bag__stamp {
  animation: teach-stamp-press 640ms cubic-bezier(0.16, 1, 0.3, 1) both;
  animation-delay: calc(var(--i, 0) * 90ms);
}

.teach-bag__noun {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  font-size: 0.75rem;
  font-weight: 700;
  line-height: 1.2;
}

.teach-bag__noun :deep(svg) {
  color: var(--kd-accent);
}

.teach-bag__word {
  font-size: 0.95rem;
  font-weight: 700;
  line-height: 1.1;
  letter-spacing: -0.03em;
  white-space: nowrap;
}

@keyframes teach-bag-settle {
  from { transform: translateY(12px) rotate(0.35deg); }
  to { transform: none; }
}

@keyframes teach-bag-reprint {
  from { clip-path: inset(0 0 100% 0); }
  to { clip-path: inset(0 0 0 0); }
}

@keyframes teach-stamp-press {
  0% {
    opacity: 0.35;
    filter: blur(2px);
    clip-path: inset(-30% -30% 72% -30%);
    transform: rotate(calc(var(--tilt, 0deg) - 18deg)) scale(1.2) translateY(-12px);
  }
  58% {
    opacity: 1;
    filter: blur(0);
    clip-path: inset(-30%);
    transform: rotate(calc(var(--tilt, 0deg) + 1.8deg)) scale(0.97) translateY(1px);
  }
  100% {
    opacity: 1;
    filter: none;
    clip-path: inset(-30%);
    transform: rotate(var(--tilt, 0deg)) scale(1);
  }
}

@media (prefers-reduced-motion: reduce) {
  .teach-bag.is-on,
  .teach-bag.is-on .teach-bag__lines,
  .teach-bag.is-on .teach-bag__stamp {
    animation: none;
  }
}
</style>
