<template>
  <IonPage>
    <AdminShell
      :title="shopName ? `${shopName} audits` : 'Cafe audits'"
      lede="Append-only history. Correct by filing a new visit. Voiding needs an admin reason."
      :status="pageStatus"
      :error="pageError"
      :nav-role="navRole"
    >
      <template #actions>
        <NuxtLink class="admin-btn" :to="`/admin/audits/new?shop=${shopId}`">New audit</NuxtLink>
      </template>

      <p v-if="auditsList.length === 0" class="admin-meta">No audits yet.</p>
      <article v-for="audit in auditsList" :key="audit.id" class="admin-card">
        <h2>{{ formatAdminDate(audit.audited_at) }}</h2>
        <p class="admin-meta">{{ voided(audit.id) ? `Voided: ${voided(audit.id)}` : 'Valid' }}</p>
        <p v-if="audit.corrects_audit_id" class="admin-meta">Corrects {{ audit.corrects_audit_id }}</p>
        <p>Long-stay: {{ audit.long_stay_stance }}{{ audit.staff_confirmed_long_stay ? ' (asked staff)' : '' }}</p>
        <p>Pay: {{ paymentWord(audit.accepts_qr, audit.accepts_card, audit.accepts_cash) }}</p>
        <p v-for="result in resultsFor(audit.id)" :key="`${audit.id}-${result.amenity_key}`">
          {{ result.amenity_key }}: {{ result.result }}
          <span v-if="result.wifi_download_mbps != null"> · {{ result.wifi_download_mbps }} / {{ result.wifi_upload_mbps }} Mbps</span>
          <span v-if="result.outlet_reliability"> · {{ result.outlet_reliability }}</span>
        </p>
        <p v-if="audit.notes">{{ audit.notes }}</p>
        <div class="admin-row-actions">
          <NuxtLink class="admin-link" :to="`/admin/audits/new?shop=${shopId}&corrects=${audit.id}`">Correct</NuxtLink>
          <button v-if="isAdmin" type="button" class="admin-btn admin-btn--danger" @click="onVoid(audit.id)">Void</button>
        </div>
      </article>

      <section v-if="reports.length" class="admin-panel">
        <h2>Seed reports</h2>
        <p v-for="report in reports" :key="report.id" class="admin-meta">
          {{ report.amenity_key }} {{ report.result }} · {{ formatAdminDate(report.observed_at) }}
        </p>
      </section>
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import AdminShell from '~/components/admin/AdminShell.vue'
import { shopIdFromRoute } from '~/utils/approved-shops'
import { formatAdminDate } from '~/utils/admin-nav'
import { voidReasonError } from '~/utils/audit-form'
import { paymentWord } from '~/utils/audit-list'
import type { CafeAuditResultRow, CafeAuditRow } from '~/composables/useCafeAudits'

definePageMeta({
  middleware: ['auth', 'auditor'],
})

const route = useRoute()
const { navRole, status, error, isAdmin, load } = useStaffSession()
const api = useCafeAudits()
const shopId = computed(() => shopIdFromRoute(route.fullPath, route.params.shopId))
const shopName = ref('')
const auditsList = ref<CafeAuditRow[]>([])
const results = ref<CafeAuditResultRow[]>([])
const voids = ref<Array<{ audit_id: string; reason: string }>>([])
const reports = ref<Array<{ id: string; amenity_key: string; result: string; observed_at: string }>>([])
const loadError = ref('')

const pageStatus = computed(() => status.value)
const pageError = computed(() => error.value || loadError.value)

const resultsFor = (id: string) => results.value.filter((row) => row.audit_id === id)
const voided = (id: string) => voids.value.find((row) => row.audit_id === id)?.reason ?? null

onMounted(async () => {
  await load()
  if (!shopId.value) {
    loadError.value = 'That cafe was not found.'
    return
  }
  try {
    const supabase = useSupabaseClient()
    const { data } = await supabase.from('shops').select('name').eq('id', shopId.value).maybeSingle()
    shopName.value = (data as { name?: string } | null)?.name || ''
    const history = await api.loadHistory(shopId.value)
    auditsList.value = history.audits
    results.value = history.results.filter((row) => history.audits.some((audit) => audit.id === row.audit_id))
    voids.value = history.voids
    reports.value = history.reports as Array<{ id: string; amenity_key: string; result: string; observed_at: string }>
  } catch (err) {
    loadError.value = err instanceof Error ? err.message : 'Could not load audit history.'
  }
})

const onVoid = async (id: string) => {
  const reason = window.prompt('Why is this audit voided?') || ''
  const issue = voidReasonError(reason)
  if (issue) {
    loadError.value = issue
    return
  }
  try {
    await api.voidAudit(id, reason)
    voids.value = [...voids.value, { audit_id: id, reason }]
  } catch (err) {
    loadError.value = err instanceof Error ? err.message : 'Could not void that audit.'
  }
}
</script>
