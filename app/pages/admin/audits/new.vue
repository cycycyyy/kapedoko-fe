<template>
  <IonPage>
    <AdminShell
      title="New audit"
      lede="One visit, both amenities, under three minutes. Save still works after a weak signal."
      :status="pageStatus"
      :error="pageError"
      :nav-role="navRole"
    >
      <form class="admin-form" @submit.prevent="onSubmit">
        <div class="admin-panel">
          <label class="admin-label">Cafe</label>
          <AdminSearchPicker
            v-model="draft.shopId"
            title="Choose a cafe"
            placeholder="Search an approved cafe"
            search-placeholder="Cafe name or address"
            :options="options"
            :status="pickerStatus"
          />
          <p v-if="errors.shop" class="admin-error">{{ errors.shop }}</p>

          <label class="admin-label">WiFi</label>
          <div class="admin-row-actions">
            <button v-for="value in results" :key="`wifi-${value}`" type="button" class="admin-chip" :class="{ 'is-active': draft.wifi.result === value }" @click="draft.wifi.result = value">
              {{ value }}
            </button>
          </div>
          <input v-if="draft.wifi.result === 'available'" v-model="draft.wifi.downloadMbps" class="admin-search" inputmode="decimal" placeholder="Download Mbps">
          <input v-if="draft.wifi.result === 'available'" v-model="draft.wifi.uploadMbps" class="admin-search" inputmode="decimal" placeholder="Upload Mbps">
          <input v-if="draft.wifi.result === 'available'" v-model="draft.wifi.networkName" class="admin-search" placeholder="Network name (staff only)">
          <textarea v-model="draft.wifi.notes" class="admin-search" rows="2" placeholder="WiFi notes / why unknown" />
          <p v-if="errors.wifi" class="admin-error">{{ errors.wifi }}</p>

          <label class="admin-label">Outlets</label>
          <div class="admin-row-actions">
            <button v-for="value in results" :key="`outlets-${value}`" type="button" class="admin-chip" :class="{ 'is-active': draft.outlets.result === value }" @click="draft.outlets.result = value">
              {{ value }}
            </button>
          </div>
          <input v-if="draft.outlets.result === 'available'" v-model="draft.outlets.approxCount" class="admin-search" inputmode="numeric" placeholder="Approximate count">
          <div v-if="draft.outlets.result === 'available'" class="admin-row-actions">
            <button v-for="value in reliability" :key="value" type="button" class="admin-chip" :class="{ 'is-active': draft.outlets.reliability === value }" @click="draft.outlets.reliability = value">
              {{ value }}
            </button>
          </div>
          <textarea v-model="draft.outlets.seatingNearOutletNotes" class="admin-search" rows="2" placeholder="Seating near outlets" />
          <textarea v-model="draft.outlets.notes" class="admin-search" rows="2" placeholder="Outlet notes / why unknown" />
          <p v-if="errors.outlets" class="admin-error">{{ errors.outlets }}</p>

          <fieldset class="admin-pay">
            <legend class="admin-label">Payment</legend>
            <div v-for="method in paymentMethods" :key="method.id" class="admin-pay__row">
              <span class="admin-pay__name" :id="`pay-${method.id}`">{{ method.label }}</span>
              <div class="admin-row-actions" role="group" :aria-labelledby="`pay-${method.id}`">
                <button
                  v-for="choice in paymentChoices"
                  :key="`${method.id}-${choice.id}`"
                  type="button"
                  class="admin-chip"
                  :class="{ 'is-active': draft.payment[method.id] === choice.id }"
                  :aria-pressed="draft.payment[method.id] === choice.id"
                  @click="draft.payment[method.id] = choice.id"
                >
                  {{ choice.label }}
                </button>
              </div>
            </div>
          </fieldset>
          <p v-if="errors.payment" class="admin-error">{{ errors.payment }}</p>

          <label class="admin-label">Long-stay stance</label>
          <div class="admin-row-actions">
            <button v-for="value in stances" :key="value" type="button" class="admin-chip" :class="{ 'is-active': draft.longStayStance === value }" @click="draft.longStayStance = value">
              {{ value }}
            </button>
          </div>
          <label class="admin-meta">
            <input v-model="draft.staffConfirmedLongStay" type="checkbox"> Asked staff
          </label>
          <p v-if="errors.longStay" class="admin-error">{{ errors.longStay }}</p>

          <input v-model="draft.seatingCapacity" class="admin-search" inputmode="numeric" placeholder="Seating capacity estimate">
          <textarea v-model="draft.notes" class="admin-search" rows="3" placeholder="Visit notes" />
          <p v-if="queueNotice" class="admin-meta" role="status">{{ queueNotice }}</p>
        </div>
        <div class="admin-span admin-row-actions">
          <button type="submit" class="admin-btn" :disabled="saving">{{ saving ? 'Saving…' : 'Save audit' }}</button>
        </div>
      </form>
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import AdminSearchPicker from '~/components/admin/AdminSearchPicker.vue'
import AdminShell from '~/components/admin/AdminShell.vue'
import type { AdminPickerOption } from '~/utils/admin-picker'
import {
  auditFormError,
  auditFormHasErrors,
  emptyAuditDraft,
  PAYMENT_CHOICES,
  PAYMENT_METHODS,
  type AuditAmenityResult,
  type LongStayStance,
} from '~/utils/audit-form'
import { POWER_ACCESS } from '~/utils/cafe-review'

definePageMeta({
  middleware: ['auth', 'auditor'],
})

const route = useRoute()
const { navRole, status, error, load } = useStaffSession()
const audits = useCafeAudits()
const draft = reactive(emptyAuditDraft())
const options = ref<AdminPickerOption[]>([])
const pickerStatus = ref<'idle' | 'loading' | 'ready' | 'error'>('idle')
const saving = ref(false)
const queueNotice = ref('')
const formError = ref('')
const results: AuditAmenityResult[] = ['available', 'unavailable', 'unknown']
const stances: LongStayStance[] = ['welcome', 'discouraged', 'unknown']
const paymentMethods = PAYMENT_METHODS
const paymentChoices = PAYMENT_CHOICES
const reliability = POWER_ACCESS

const errors = computed(() => auditFormError(draft))
const pageStatus = computed(() => (status.value === 'ready' ? pickerStatus.value === 'error' ? 'error' : 'ready' : status.value))
const pageError = computed(() => error.value || formError.value)

onMounted(async () => {
  await load()
  pickerStatus.value = 'loading'
  try {
    options.value = await audits.loadApprovedOptions()
    pickerStatus.value = 'ready'
    const shop = typeof route.query.shop === 'string' ? route.query.shop : ''
    if (shop) draft.shopId = shop
    const corrects = typeof route.query.corrects === 'string' ? route.query.corrects : ''
    if (corrects) draft.correctsAuditId = corrects
  } catch (err) {
    pickerStatus.value = 'error'
    formError.value = err instanceof Error ? err.message : 'Could not load cafes.'
  }
})

const onSubmit = async () => {
  const issues = auditFormError(draft)
  if (auditFormHasErrors(issues)) {
    formError.value = issues.shop || issues.wifi || issues.outlets || issues.payment || issues.longStay || issues.seating || 'Check the form.'
    return
  }
  saving.value = true
  formError.value = ''
  const key = crypto.randomUUID()
  try {
    await audits.submitDraft(draft, key)
    queueNotice.value = 'Saved.'
    await navigateTo('/admin/audits')
  } catch (err) {
    queueNotice.value = 'Could not reach the server. Your answers are still on this screen — tap Save again.'
    formError.value = err instanceof Error ? err.message : 'Could not save that audit.'
  } finally {
    saving.value = false
  }
}
</script>
