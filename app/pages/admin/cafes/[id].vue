<template>
  <IonPage>
    <AdminShell
      layout="cafe"
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
      <div v-if="shop" class="cafe-editor">
        <p class="editor-status" :class="`editor-status--${shop.status}`">
          <span class="editor-status__mark" aria-hidden="true">
            <span class="editor-status__dot" />
          </span>
          <span class="editor-status__label">Status</span>
          <span class="editor-status__word">{{ statusWord(shop.status) }}</span>
        </p>
        <p v-if="formError" class="admin-error" role="alert">{{ formError }}</p>
        <AdminCafeForm
          :key="shop.id"
          :shop="shop"
          :saving="saving"
          submit-label="Save changes"
          @save="onSave"
        />
      </div>
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import { useIonRouter } from '@ionic/vue'
import AdminCafeForm from '~/components/admin/AdminCafeForm.vue'
import AdminShell from '~/components/admin/AdminShell.vue'
import type { ShopRow, ShopStatus } from '~/types/shop'
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

const statusWord = (value: ShopStatus) => {
  if (value === 'approved') return 'Approved'
  if (value === 'pending') return 'Pending'
  return 'Rejected'
}

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

<style scoped>
.cafe-editor {
  display: flex;
  flex-direction: column;
  gap: 20px;
  caret-color: var(--kd-primary);
}

.cafe-editor ::selection {
  background: var(--kd-accent);
  color: var(--kd-ink);
}

.editor-status {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  width: fit-content;
  max-width: 100%;
  min-height: 40px;
  margin: 0;
  padding: 6px 14px 6px 8px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 22%, transparent);
  border-radius: 16px;
  background: #faf8f5;
  color: var(--kd-ink);
  line-height: 1.2;
}

.editor-status__mark {
  display: grid;
  place-items: center;
  width: 22px;
  height: 22px;
  border: 1.5px solid currentColor;
  border-radius: 16px;
  flex: 0 0 auto;
}

.editor-status__dot {
  width: 8px;
  height: 8px;
  border-radius: 16px;
  background: currentColor;
}

.editor-status__label {
  color: var(--kd-ink);
  font-size: 0.75rem;
  font-weight: 700;
}

.editor-status__word {
  font-size: 0.95rem;
  font-weight: 700;
  letter-spacing: -0.02em;
}

.editor-status--approved {
  border-color: color-mix(in srgb, var(--kd-primary) 48%, #faf8f5);
  background: color-mix(in srgb, var(--kd-primary) 10%, #faf8f5);
  color: var(--kd-primary);
}

.editor-status--approved .editor-status__word {
  color: var(--kd-primary);
}

.editor-status--pending {
  border-color: color-mix(in srgb, var(--kd-accent) 62%, #faf8f5);
  background: color-mix(in srgb, var(--kd-accent) 16%, #faf8f5);
  color: var(--kd-accent);
}

.editor-status--pending .editor-status__word {
  color: var(--kd-ink);
}

.editor-status--rejected {
  border-color: color-mix(in srgb, var(--kd-destructive) 48%, #faf8f5);
  background: color-mix(in srgb, var(--kd-destructive) 10%, #faf8f5);
  color: var(--kd-destructive);
}

.editor-status--rejected .editor-status__word {
  color: var(--kd-destructive);
}

.cafe-editor :deep(.admin-form) {
  gap: 20px;
}

.cafe-editor :deep(.admin-form > .admin-panel) {
  padding: 20px;
}

.cafe-editor :deep(.admin-form > .admin-panel:not(.admin-map)) {
  display: flex;
  flex-direction: column;
}

.cafe-editor :deep(.details) {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid color-mix(in srgb, var(--kd-ink) 14%, transparent);
}

.cafe-editor :deep(.identity__logo) {
  gap: 8px;
}

.cafe-editor :deep(.identity__logo-row) {
  gap: 16px;
  margin-top: 4px;
}

.cafe-editor :deep(.identity__logo-actions) {
  gap: 10px;
}

.cafe-editor :deep(.details__hours) {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.cafe-editor :deep(.details__hours-label),
.cafe-editor :deep(.details__toggle),
.cafe-editor :deep(.details__times),
.cafe-editor :deep(.details__days) {
  margin-top: 0;
  margin-bottom: 0;
}

.cafe-editor :deep(.details__days) {
  gap: 16px;
}

.cafe-editor :deep(.details__day-name) {
  margin-bottom: 8px;
}

.cafe-editor :deep(.details__day-controls) {
  gap: 12px;
}

.cafe-editor :deep(.picker) {
  gap: 16px;
}

.cafe-editor :deep(.picker__copy p) {
  margin-top: 8px;
}

@media (min-width: 768px) {
  .cafe-editor :deep(.admin-form.admin-form) {
    grid-template-columns: minmax(0, 1.15fr) minmax(260px, 0.85fr);
    column-gap: 24px;
    row-gap: 20px;
  }
}

@media (max-width: 520px) {
  .cafe-editor :deep(.details__day-controls:has(input)) {
    grid-template-columns: 1fr 1fr;
  }

  .cafe-editor :deep(.details__day-controls select) {
    grid-column: 1 / -1;
  }
}
</style>
