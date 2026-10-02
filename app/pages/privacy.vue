<template>
  <IonPage>
    <IonContent class="privacy-content">
      <div class="privacy">
        <header class="privacy__hero">
          <button type="button" class="privacy__back" aria-label="Go back" @click="goBack">
            <ChevronLeft :size="22" :stroke-width="2.25" />
          </button>
          <h1>Privacy</h1>
        </header>
        <p class="privacy__note">Draft for legal review. This page covers product analytics for the Marikina pilot.</p>
        <ol>
          <li>We use PostHog, hosted in the European Union, to understand how the KapéDoko app is used during the Marikina pilot.</li>
          <li>We only do this if you tap Allow on the first-launch notice or turn Usage analytics on in Profile.</li>
          <li>Events include which screens you open, which filters you use, and whether you tap directions or call on a café page.</li>
          <li>We do not send your email address, the text of reviews, café submission notes, Wi‑Fi network names, exact map coordinates, or the words you type into search.</li>
          <li>If you are not signed in, events are stored under a random identifier on your device. After you sign in, that identifier is replaced with your account id so we can see whether signed-in KapéBeans return.</li>
          <li>You can turn analytics off in Profile. We then stop sending events and forget the analytics identifier on this device.</li>
          <li>Session recordings, heatmaps, and advertising profiles are not used.</li>
          <li>Analytics data is kept on PostHog’s free-tier retention (currently one year) and is not sold.</li>
        </ol>
      </div>
    </IonContent>
  </IonPage>
</template>

<script lang="ts" setup>
import { ChevronLeft } from 'lucide-vue-next'
import { useIonRouter } from '@ionic/vue'

const ionRouter = useIonRouter()

const goBack = async () => {
  if (ionRouter.canGoBack()) {
    ionRouter.back()
    return
  }
  await navigateTo('/app/profile')
}
</script>

<style scoped>
.privacy-content {
  --background: #f2f2f2;
  --padding-start: 0;
  --padding-end: 0;
  --padding-top: 0;
  --padding-bottom: 0;
}

.privacy {
  max-width: 480px;
  margin-inline: auto;
  padding: max(2.75rem, calc(env(safe-area-inset-top) + 16px)) 20px calc(2rem + env(safe-area-inset-bottom));
  color: var(--kd-ink);
  font-family: 'Kumbh Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

.privacy__hero {
  display: flex;
  align-items: center;
  gap: 4px;
}

.privacy__back {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  margin-left: -10px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-ink);
  cursor: pointer;
}

.privacy__back:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
  border-radius: 8px;
}

.privacy h1 {
  margin: 0;
  font-size: 1.325rem;
  font-weight: 700;
  letter-spacing: -0.03em;
}

.privacy__note,
.privacy li {
  font-size: 0.9rem;
  line-height: 1.45;
}

.privacy__note {
  margin: 16px 0 0;
}

.privacy ol {
  margin: 16px 0 0;
  padding-left: 1.2rem;
}

.privacy li + li {
  margin-top: 10px;
}
</style>
