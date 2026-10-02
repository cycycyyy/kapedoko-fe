<template>
  <IonApp>
    <NuxtRouteAnnouncer />
    <IonRouterOutlet />
    <LoadingScreen v-if="isLoading" />
    <AnalyticsConsentNotice />
  </IonApp>
</template>

<script setup lang="ts">
import { IonApp, IonRouterOutlet } from '@ionic/vue'
import AnalyticsConsentNotice from '~/components/analytics/AnalyticsConsentNotice.vue'
import LoadingScreen from '~/components/LoadingScreen.vue'
import { hasFinishedOnboarding, shouldShowOnboarding } from '~/utils/onboarding'

const supabase = useSupabaseClient()
const route = useRoute()
const isLoading = ref(true)

useFavorites()

const maybeOnboard = async () => {
  const finished = await hasFinishedOnboarding()
  if (shouldShowOnboarding(route.path, finished)) {
    await navigateTo('/app/onboarding')
  }
}

const SPLASH_LIMIT_MS = 3000
let hideSplash: ReturnType<typeof window.setTimeout> | undefined

onMounted(() => {
  hideSplash = window.setTimeout(() => {
    isLoading.value = false
  }, SPLASH_LIMIT_MS)

  void (async () => {
    try {
      await supabase.auth.getSession()
    } catch {
      /* the splash still closes if the session check fails */
    }
    await maybeOnboard()
    isLoading.value = false
    if (hideSplash) window.clearTimeout(hideSplash)
    await maybeOnboard()
  })()
})

onBeforeUnmount(() => {
  if (hideSplash) window.clearTimeout(hideSplash)
})

watch(
  () => route.path,
  () => {
    if (!isLoading.value) void maybeOnboard()
  },
)
</script>
