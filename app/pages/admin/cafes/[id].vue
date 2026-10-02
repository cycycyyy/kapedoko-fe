<template>
  <IonPage>
    <AdminShell
      :title="shop?.name || 'Edit cafe'"
      lede="Changes go live for approved cafes. Unpublish to take a listing off Home and Map."
      :status="pageStatus"
      :error="pageError"
    >
      <template v-if="shop" #actions>
        <NuxtLink v-if="shop.status === 'approved'" class="admin-btn admin-btn--ghost" :to="`/admin/audits/${shop.id}`">
          Audits
        </NuxtLink>
        <button
          v-if="shop.status === 'approved'"
          type="button"
          class="admin-btn admin-btn--ghost"
          :disabled="saving"
          @click="unpublish"
        >
          Unpublish
        </button>
      </template>
      <p v-if="shop" class="admin-meta">Status: {{ shop.status }}</p>
      <p v-if="formError" class="admin-error" role="alert">{{ formError }}</p>
      <AdminCafeForm
        v-if="shop"
        :key="shop.id"
        :shop="shop"
        :saving="saving"
        submit-label="Save changes"
        @save="onSave"
      />
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import { useIonRouter } from '@ionic/vue'
import AdminCafeForm from '~/components/admin/AdminCafeForm.vue'
import AdminShell from '~/components/admin/AdminShell.vue'
import type { ShopRow } from '~/types/shop'
import { shopIdFromRoute } from '~/utils/approved-shops'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const route = useRoute()
const ionRouter = useIonRouter()
const admin = useAdminData()
const { error, updateShop, moderate } = admin
const saving = ref(false)
const formError = ref('')
const shop = ref<ShopRow | null>(null)
const lookingUp = ref(true)

function resolveShopId(): string {
  const param = route.params.id
  const href = import.meta.client
    ? `${window.location.pathname}${window.location.hash}${window.location.search}`
    : ''
  return (
    shopIdFromRoute(route.fullPath, param)
    || shopIdFromRoute(route.path, param)
    || shopIdFromRoute(String(ionRouter.routeInfo?.pathname || ''), param)
    || shopIdFromRoute(href, param)
  )
}

const pageStatus = computed(() => {
  if (lookingUp.value) return 'loading'
  if (!shop.value) return 'error'
  return 'ready'
})

const pageError = computed(() => {
  if (shop.value) return error.value
  if (lookingUp.value) return ''
  return error.value || 'That cafe was not found.'
})

const loadCurrent = async () => {
  lookingUp.value = true
  error.value = ''
  let id = resolveShopId()
  if (!id && import.meta.client) {
    await nextTick()
    id = resolveShopId()
  }
  if (!id) {
    shop.value = null
    lookingUp.value = false
    return
  }
  try {
    shop.value = await admin.fetchShop(id)
  } catch (err) {
    shop.value = null
    error.value = err instanceof Error ? err.message : 'Could not load this cafe.'
  } finally {
    lookingUp.value = false
  }
}

const onSave = async (payload: Parameters<typeof updateShop>[1]) => {
  if (!shop.value) return
  saving.value = true
  formError.value = ''
  try {
    shop.value = await updateShop(shop.value.id, payload)
  } catch (err) {
    formError.value = err instanceof Error ? err.message : 'Could not save this cafe.'
  } finally {
    saving.value = false
  }
}

const unpublish = async () => {
  if (!shop.value) return
  if (!window.confirm(`Unpublish ${shop.value.name}?`)) return
  try {
    shop.value = await moderate(shop.value, 'pending')
  } catch {
    /* shown in the admin shell */
  }
}

onMounted(() => {
  void loadCurrent()
})

watch(
  () => [route.fullPath, route.path, route.params.id],
  () => {
    void loadCurrent()
  },
)
</script>
