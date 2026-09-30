<template>
  <IonPage />
</template>

<script setup lang="ts">
import { IonPage } from '@ionic/vue'

definePageMeta({
  redirect: '/app',
})

onMounted(() => {
  void navigateTo('/app', { replace: true })
})
</script>
