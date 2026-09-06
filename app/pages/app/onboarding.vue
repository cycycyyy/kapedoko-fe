<template>
  <IonPage>
    <IonContent :scroll-y="false" class="onboarding-content">
      <div class="onboarding">
        <div
          ref="trackRef"
          class="onboarding__track"
          tabindex="0"
          role="region"
          aria-roledescription="carousel"
          :aria-label="`Onboarding, step ${activeStep + 1} of 3`"
          @scroll.passive="onScroll"
          @keydown="onKeydown"
        >
          <OnboardingStep1
            class="onboarding__slide"
            :active-step="activeStep"
            @next="goTo(1)"
            @go-to="goTo"
          />
          <OnboardingStep2
            class="onboarding__slide"
            :active-step="activeStep"
            @next="goTo(2)"
            @go-to="goTo"
          />
          <OnboardingStep3
            class="onboarding__slide"
            @complete="finish"
          />
        </div>
      </div>
    </IonContent>
  </IonPage>
</template>

<script lang="ts" setup>
import OnboardingStep1 from '~/components/onboarding/OnboardingStep1.vue'
import OnboardingStep2 from '~/components/onboarding/OnboardingStep2.vue'
import OnboardingStep3 from '~/components/onboarding/OnboardingStep3.vue'

const STEP_COUNT = 3

const trackRef = ref<HTMLElement | null>(null)
const activeStep = ref(0)

const prefersReducedMotion = () =>
  typeof window !== 'undefined' && window.matchMedia('(prefers-reduced-motion: reduce)').matches

const goTo = (index: number) => {
  const track = trackRef.value
  if (!track) return

  const next = Math.max(0, Math.min(STEP_COUNT - 1, index))
  activeStep.value = next
  track.scrollTo({
    left: next * track.clientWidth,
    behavior: prefersReducedMotion() ? 'auto' : 'smooth',
  })
}

const onScroll = () => {
  const track = trackRef.value
  if (!track || track.clientWidth === 0) return

  const index = Math.round(track.scrollLeft / track.clientWidth)
  if (index !== activeStep.value) {
    activeStep.value = Math.max(0, Math.min(STEP_COUNT - 1, index))
  }
}

const onKeydown = (event: KeyboardEvent) => {
  if (event.key === 'ArrowRight') {
    event.preventDefault()
    goTo(activeStep.value + 1)
  }

  if (event.key === 'ArrowLeft') {
    event.preventDefault()
    goTo(activeStep.value - 1)
  }
}

const finish = async () => {
  await navigateTo('/app')
}
</script>

<style scoped>
.onboarding-content {
  --background: #ffffff;
  --overflow: hidden;
}

.onboarding-content :deep(.inner-scroll),
.onboarding-content :deep(.scroll-y),
.onboarding-content :deep(.overscroll) {
  position: absolute;
  inset: 0;
  height: 100%;
  overflow: hidden;
}

.onboarding {
  height: 100%;
  min-height: 100%;
  background: #ffffff;
}

.onboarding__track {
  display: flex;
  height: 100%;
  min-height: 100%;
  overflow-x: auto;
  overflow-y: hidden;
  scroll-snap-type: x mandatory;
  scroll-behavior: smooth;
  overscroll-behavior-x: contain;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  outline: none;
}

.onboarding__track:focus-visible {
  box-shadow: inset 0 0 0 2px #372d25;
}

.onboarding__track::-webkit-scrollbar {
  display: none;
}

.onboarding__slide {
  flex: 0 0 100%;
  width: 100%;
  height: 100%;
  scroll-snap-align: start;
  scroll-snap-stop: always;
}

@media (prefers-reduced-motion: reduce) {
  .onboarding__track {
    scroll-behavior: auto;
  }
}
</style>
