<template>
  <IonPage>
    <AdminShell
      title="Add cafe"
      lede="Saved unpublished. Publish it from the cafe page when the listing is ready."
      :status="'ready'"
    >
      <p v-if="formError" class="admin-error" role="alert">{{ formError }}</p>
      <AdminCafeForm :saving="saving" submit-label="Save cafe" @save="onSave" />
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import AdminCafeForm from '~/components/admin/AdminCafeForm.vue'
import AdminShell from '~/components/admin/AdminShell.vue'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const admin = useAdminData()
const saving = ref(false)
const formError = ref('')

const onSave = async (payload: Parameters<typeof admin.createShop>[0]) => {
  saving.value = true
  formError.value = ''
  try {
    const created = await admin.createShop(payload)
    await navigateTo(`/admin/cafes/${created.id}`)
  } catch (err) {
    formError.value = err instanceof Error ? err.message : 'Could not save this cafe.'
  } finally {
    saving.value = false
  }
}
</script>
