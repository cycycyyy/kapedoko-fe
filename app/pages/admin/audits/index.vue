<template>
  <IonPage>
    <AdminShell
      title="Audits"
      lede="Needs-recheck first, then stale visits. Current team visits sit below."
      :status="pageStatus"
      :error="pageError"
      :nav-role="navRole"
    >
      <template #actions>
        <NuxtLink class="admin-btn" to="/admin/audits/new">New audit</NuxtLink>
      </template>

      <AdminPendingRail
        title="Needs a visit"
        :empty-copy="queueEmptyCopy"
        :tickets="queueTickets"
        :status="pageStatus"
      />

      <section class="admin-audited" aria-labelledby="audited-heading">
        <div class="admin-rail__head">
          <h2 id="audited-heading">Audited cafes</h2>
          <p v-if="auditedCountCopy">{{ auditedCountCopy }}</p>
        </div>

        <div v-if="audited.length" class="admin-toolbar">
          <input
            v-model="query"
            class="admin-search"
            type="search"
            placeholder="Search cafe name"
            aria-label="Search audited cafes"
          />
        </div>

        <p v-if="audited.length === 0" class="admin-rail__empty">No team visits yet. Start with New audit.</p>
        <p v-else-if="visible.length === 0" class="admin-rail__empty">No audited cafes match that search.</p>

        <div v-else class="admin-ledger">
          <div class="admin-table-wrap">
            <table class="admin-table">
              <thead>
                <tr>
                  <th>Cafe</th>
                  <th>Last visit</th>
                  <th>WiFi</th>
                  <th>Outlets</th>
                  <th>Pay</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in visible" :key="row.shopId">
                  <td>{{ row.name }}</td>
                  <td>{{ formatAdminDate(row.auditedAt) }}</td>
                  <td>
                    <span class="admin-status" :class="amenityStatusClass(row.wifi)">
                      {{ auditAmenityWord('wifi', row.wifi) }}
                    </span>
                  </td>
                  <td>
                    <span class="admin-status" :class="amenityStatusClass(row.outlets)">
                      {{ auditAmenityWord('outlets', row.outlets) }}
                    </span>
                  </td>
                  <td>
                    <span class="admin-status" :class="statusClass(paymentTone(row.qr, row.card, row.cash))">
                      {{ paymentWord(row.qr, row.card, row.cash) }}
                    </span>
                  </td>
                  <td>
                    <div class="admin-row-actions">
                      <NuxtLink class="admin-link" :to="`/admin/audits/${row.shopId}`">History</NuxtLink>
                      <NuxtLink class="admin-link" :to="`/admin/audits/new?shop=${row.shopId}`">Audit</NuxtLink>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="admin-cards">
            <article v-for="row in visible" :key="row.shopId" class="admin-card">
              <h2>{{ row.name }}</h2>
              <p>{{ formatAdminDate(row.auditedAt) }}</p>
              <p>
                <span class="admin-status" :class="amenityStatusClass(row.wifi)">
                  {{ auditAmenityCardWord('wifi', row.wifi) }}
                </span>
                ·
                <span class="admin-status" :class="amenityStatusClass(row.outlets)">
                  {{ auditAmenityCardWord('outlets', row.outlets) }}
                </span>
              </p>
              <p>Pay: {{ paymentWord(row.qr, row.card, row.cash) }}</p>
              <p>Long-stay: {{ longStayWord(row.longStayStance) }}</p>
              <div class="admin-row-actions">
                <NuxtLink class="admin-link" :to="`/admin/audits/${row.shopId}`">History</NuxtLink>
                <NuxtLink class="admin-link" :to="`/admin/audits/new?shop=${row.shopId}`">Audit</NuxtLink>
              </div>
            </article>
          </div>
        </div>
      </section>
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import AdminPendingRail from '~/components/admin/AdminPendingRail.vue'
import AdminShell from '~/components/admin/AdminShell.vue'
import type { AuditDeskCafe, AuditDeskQueueCafe } from '~/composables/useCafeAudits'
import { formatAdminDate } from '~/utils/admin-nav'
import {
  auditAmenityCardWord,
  auditAmenityTone,
  auditAmenityWord,
  filterAuditedCafes,
  longStayWord,
  paymentTone,
  paymentWord,
  queueTicketDetail,
} from '~/utils/audit-list'

definePageMeta({
  middleware: ['auth', 'auditor'],
})

const { navRole, status, error, load } = useStaffSession()
const audits = useCafeAudits()
const queueCafes = ref<AuditDeskQueueCafe[]>([])
const audited = ref<AuditDeskCafe[]>([])
const query = ref('')
const loadError = ref('')
const deskStatus = ref<'idle' | 'loading' | 'ready' | 'error'>('idle')

const pageStatus = computed(() => {
  if (status.value !== 'ready') return status.value
  if (deskStatus.value === 'error') return 'error'
  if (deskStatus.value !== 'ready') return 'loading'
  return 'ready'
})
const pageError = computed(() => error.value || loadError.value)

const queueTickets = computed(() =>
  queueCafes.value.map((cafe) => ({
    id: cafe.shopId,
    name: cafe.name,
    detail: queueTicketDetail(cafe),
    to: `/admin/audits/new?shop=${cafe.shopId}`,
  })),
)
const queueEmptyCopy = computed(() =>
  audited.value.length
    ? 'Catch-up visits are current.'
    : 'No cafes need a recheck or are stale.',
)

const visible = computed(() => filterAuditedCafes(audited.value, query.value).slice(0, 80))
const auditedCountCopy = computed(() => {
  if (!audited.value.length) return ''
  const shown = visible.value.length
  const total = audited.value.length
  if (query.value.trim() && shown !== total) {
    return `${shown} of ${total} cafes`
  }
  return total === 1 ? '1 cafe' : `${total} cafes`
})

const amenityStatusClass = (result: string | null) => statusClass(auditAmenityTone(result))

const statusClass = (tone: 'ok' | 'no' | 'unknown') => {
  if (tone === 'ok') return 'admin-status--approved'
  if (tone === 'no') return 'admin-status--rejected'
  return ''
}

onMounted(async () => {
  await load()
  if (status.value !== 'ready') return
  deskStatus.value = 'loading'
  try {
    const desk = await audits.loadDesk()
    queueCafes.value = desk.queueCafes
    audited.value = desk.audited
    deskStatus.value = 'ready'
  } catch (err) {
    deskStatus.value = 'error'
    loadError.value = err instanceof Error ? err.message : 'Could not load audits.'
  }
})
</script>
