<template>
  <IonApp>
    <NuxtRouteAnnouncer />
    <IonRouterOutlet />
    <Teleport to="body">
      <AppTabBar v-if="showAppTabs && !tabsLocked" />
    </Teleport>
    <LoadingScreen v-if="isLoading" />
    <AnalyticsConsentNotice />
  </IonApp>
</template>

<script setup lang="ts">
import { IonApp, IonRouterOutlet } from '@ionic/vue'
import AnalyticsConsentNotice from '~/components/analytics/AnalyticsConsentNotice.vue'
import LoadingScreen from '~/components/LoadingScreen.vue'
import AppTabBar from '~/components/navigation/AppTabBar.vue'
import { resolveAppPath, shouldShowAppTabs } from '~/utils/app-tabs'
import { hasFinishedOnboarding, shouldShowOnboarding } from '~/utils/onboarding'

const supabase = useSupabaseClient()
const route = useRoute()
const { locked: tabsLocked } = useAppTabsLock()
const isLoading = ref(true)
const locationHint = ref('')

const syncLocationHint = () => {
  if (!import.meta.client) return
  locationHint.value = `${window.location.pathname}${window.location.hash}${window.location.search}`
}

const showAppTabs = computed(() => {
  if (isLoading.value) return false
  void route.fullPath
  const locationPath = import.meta.client
    ? `${window.location.pathname}${window.location.hash}`
    : locationHint.value
  const resolved = resolveAppPath(route.path, locationPath)
  return shouldShowAppTabs(resolved, locationPath, locationHint.value)
})

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
  syncLocationHint()
  window.addEventListener('popstate', syncLocationHint)
  window.addEventListener('hashchange', syncLocationHint)

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
  if (!import.meta.client) return
  window.removeEventListener('popstate', syncLocationHint)
  window.removeEventListener('hashchange', syncLocationHint)
})

watch(
  () => route.fullPath,
  () => {
    syncLocationHint()
    if (!isLoading.value) void maybeOnboard()
  },
)
</script>
