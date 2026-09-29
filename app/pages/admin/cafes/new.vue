<template>
  <IonPage>
    <AdminShell
      title="Add cafe"
      lede="Published immediately. Basic name, address, hours, and pin checks still apply."
      :status="'ready'"
    >
      <p v-if="formError" class="admin-error" role="alert">{{ formError }}</p>
      <AdminCafeForm :saving="saving" submit-label="Publish cafe" @save="onSave" />
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
    formError.value = err instanceof Error ? err.message : 'Could not publish this cafe.'
  } finally {
    saving.value = false
  }
}
</script>
