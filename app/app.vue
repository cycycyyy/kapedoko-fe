<template>
  <IonApp>
    <NuxtRouteAnnouncer />
    <!-- Show LoadingScreen if still loading, otherwise show main content -->
    <LoadingScreen v-if="isLoading" />
    <IonRouterOutlet v-else />
  </IonApp>
</template>

<script setup lang="ts">
import { IonApp, IonRouterOutlet } from '@ionic/vue';
import LoadingScreen from '~/components/LoadingScreen.vue';

const isLoading = ref(true);

onMounted(() => {
  // Simulate a loading process (e.g., fetching initial data, initializing services)
  // Replace this timeout with actual logic if needed.
  setTimeout(() => {
    isLoading.value = false;
  }, 2000); // Simulate 2 seconds of loading
});
</script>