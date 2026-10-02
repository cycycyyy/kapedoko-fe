<template>
  <IonPage>
    <AdminShell
      title="Dashboard"
      lede="Queues, live promotions, and people — without leaving the app."
      :status="status"
      :error="error"
      :pending-count="counts.pending"
      :claim-count="counts.pendingClaims"
    >
      <p class="admin-facts" aria-label="Admin totals">
        <template v-for="(card, index) in cards" :key="card.label">
          {{ card.value }} <span>{{ card.label }}</span>
          <template v-if="index < cards.length - 1"> · </template>
        </template>
      </p>

      <AdminPendingRail :shops="pending" :status="status" />
      <AdminPendingRail
        :shops="claimShops"
        :status="status"
        title="Waiting to verify"
        empty-copy="No ownership claims waiting."
        :to="claimTo"
      />

      <div class="admin-grid dashboard-grid">
        <section class="admin-panel">
          <h2>Open reports</h2>
          <p v-if="openReports.length === 0" class="admin-meta">No open reports.</p>
          <div v-for="report in openReports.slice(0, 5)" :key="report.id">
            <h2>{{ report.target_type === 'review' ? 'Review' : 'Photo' }}</h2>
            <template v-if="reportedText(report)">
              <p class="admin-meta">Reported text</p>
              <blockquote class="report-quote">{{ reportedText(report) }}</blockquote>
            </template>
            <p class="admin-meta">{{ report.reason || 'No note from the reporter.' }}</p>
            <p><NuxtLink class="admin-link" to="/admin/moderation">Open moderation</NuxtLink></p>
          </div>
        </section>
      </div>
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import AdminPendingRail from '~/components/admin/AdminPendingRail.vue'
import AdminShell from '~/components/admin/AdminShell.vue'
import { reportedReviewCopy } from '~/utils/moderation'
import type { ContentReportRow } from '~/types/shop'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const admin = useAdminData()
const usersAdmin = useAdminUsers()
const { shops, reports, claims, counts, status, error, load } = admin
const pending = computed(() => shops.value.filter((shop) => shop.status === 'pending'))
const claimShops = computed(() => {
  const ids = new Set(claims.value.filter((claim) => claim.status === 'pending').map((claim) => claim.shop_id))
  return shops.value.filter((shop) => ids.has(shop.id))
})
const claimTo = () => '/admin/claims'
const openReports = computed(() => reports.value.filter((report) => report.status === 'open'))
const reportedText = (report: ContentReportRow) => reportedReviewCopy(report)
const userTotal = computed(() => usersAdmin.total.value)
const cards = computed(() => [
  { label: 'Pending', value: counts.value.pending },
  { label: 'Claims', value: counts.value.pendingClaims },
  { label: 'Approved', value: counts.value.approved },
  { label: 'Rejected', value: counts.value.rejected },
  { label: 'Reports', value: counts.value.openReports },
  { label: 'Live pins', value: counts.value.activePlacements },
  { label: 'Live ads', value: counts.value.activeAds },
  { label: 'Users', value: userTotal.value },
])

onMounted(async () => {
  await Promise.all([load(), usersAdmin.load('', 1)])
})
</script>

<style scoped>
.dashboard-grid {
  margin-top: 8px;
}
</style>
