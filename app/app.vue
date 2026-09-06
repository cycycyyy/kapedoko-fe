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
import { useSupabaseClient, useSupabaseUser } from '#imports'; // Import Supabase composables

const supabase = useSupabaseClient(); // Get the Supabase client instance
const user = useSupabaseUser();       // Get the reactive user object

const isLoading = ref(true);

onMounted(async () => {
  // Simulate a loading process (e.g., fetching initial data, initializing services)
  // Replace this timeout with actual logic if needed.
  setTimeout(() => {
    isLoading.value = false;
  }, 2000); // Simulate 2 seconds of loading

  // Log the current user state on app load
  console.log("Current User on App Load:", user.value);
  // The user object will automatically update when sessions change (login/logout)
  // You could perform checks here or in a watcher/computed property based on user.value
});
</script>