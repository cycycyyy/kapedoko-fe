<template>
  <IonPage>
    <AdminShell
      title="Dashboard"
      lede="Queues, live promotions, and people — without leaving the app."
      :status="status"
      :error="error"
      :pending-count="counts.pending"
    >
      <section class="admin-stats" aria-label="Admin totals">
        <article v-for="card in cards" :key="card.label" class="admin-card">
          <p class="admin-meta">{{ card.label }}</p>
          <h2>{{ card.value }}</h2>
        </article>
      </section>

      <div class="admin-grid dashboard-grid">
        <section class="admin-panel">
          <h2>Needs a decision</h2>
          <p v-if="pending.length === 0" class="admin-meta">No pending cafe requests.</p>
          <article v-for="shop in pending.slice(0, 5)" :key="shop.id" class="admin-card">
            <h2>{{ shop.name }}</h2>
            <p>{{ shop.address }}</p>
            <NuxtLink class="admin-link" :to="`/admin/requests?id=${shop.id}`">Review request</NuxtLink>
          </article>
          <NuxtLink v-if="pending.length" class="admin-link" to="/admin/requests">All requests</NuxtLink>
        </section>
        <section class="admin-panel">
          <h2>Open reports</h2>
          <p v-if="openReports.length === 0" class="admin-meta">No open reports.</p>
          <article v-for="report in openReports.slice(0, 5)" :key="report.id" class="admin-card">
            <h2>{{ report.target_type === 'review' ? 'Review' : 'Photo' }}</h2>
            <p>{{ report.reason || 'No note from the reporter.' }}</p>
            <NuxtLink class="admin-link" to="/admin/moderation">Open moderation</NuxtLink>
          </article>
        </section>
      </div>
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import AdminShell from '~/components/admin/AdminShell.vue'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const admin = useAdminData()
const usersAdmin = useAdminUsers()
const { shops, reports, counts, status, error, load } = admin
const pending = computed(() => shops.value.filter((shop) => shop.status === 'pending'))
const openReports = computed(() => reports.value.filter((report) => report.status === 'open'))
const userTotal = computed(() => usersAdmin.total.value)
const cards = computed(() => [
  { label: 'Pending', value: counts.value.pending },
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
  margin-top: 16px;
}

@media (min-width: 1024px) {
  .dashboard-grid {
    grid-template-columns: 1fr 1fr;
  }
}
</style>
