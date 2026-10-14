<template>
  <IonPage>
    <AdminShell
      title="Add cafe"
      lede="Saved unpublished. Publish it from the cafe page when the listing is ready."
      :status="'ready'"
    >
      <p v-if="formError" class="admin-error" role="alert">{{ formError }}</p>
      <AdminCafeForm
        :key="formEpoch"
        ref="formRef"
        :saving="saving"
        submit-label="Save cafe"
        @save="onSave"
      />
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import { onIonViewWillEnter } from '@ionic/vue'
import AdminCafeForm from '~/components/admin/AdminCafeForm.vue'
import AdminShell from '~/components/admin/AdminShell.vue'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const admin = useAdminData()
const saving = ref(false)
const formError = ref('')
const formRef = ref<{ reset: () => void } | null>(null)
const formEpoch = ref(0)
const resetAfterSave = ref(false)

const resetCreateForm = () => {
  formRef.value?.reset()
  formEpoch.value += 1
  formError.value = ''
}

const onSave = async (payload: Parameters<typeof admin.createShop>[0]) => {
  saving.value = true
  formError.value = ''
  try {
    await admin.createShop(payload)
    saving.value = false
    resetAfterSave.value = true
    resetCreateForm()
    await nextTick()
    await navigateTo('/admin/cafes')
  } catch (err) {
    formError.value = err instanceof Error ? err.message : 'Could not save this cafe.'
  } finally {
    saving.value = false
  }
}

onIonViewWillEnter(() => {
  if (!resetAfterSave.value) return
  resetCreateForm()
  resetAfterSave.value = false
})
</script>
