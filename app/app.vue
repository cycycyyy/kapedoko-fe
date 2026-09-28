<template>
  <IonApp>
    <NuxtRouteAnnouncer />
    <LoadingScreen v-if="isLoading" />
    <IonRouterOutlet v-else />
  </IonApp>
</template>

<script setup lang="ts">
import { IonApp, IonRouterOutlet } from '@ionic/vue'
import LoadingScreen from '~/components/LoadingScreen.vue'
import { shouldShowOnboarding } from '~/utils/onboarding'

const supabase = useSupabaseClient()
const route = useRoute()
const isLoading = ref(true)

useFavorites()

const maybeOnboard = async () => {
  if (shouldShowOnboarding(route.path)) {
    await navigateTo('/app/onboarding')
  }
}

onMounted(async () => {
  const timeout = new Promise((resolve) => {
    window.setTimeout(resolve, 4000)
  })
  await Promise.race([supabase.auth.getSession(), timeout])
  isLoading.value = false
  await maybeOnboard()
})

watch(
  () => route.path,
  () => {
    if (!isLoading.value) void maybeOnboard()
  },
)
</script>
