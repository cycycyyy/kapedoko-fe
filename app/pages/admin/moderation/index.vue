<template>
  <IonPage>
    <AdminShell
      title="Moderation"
      lede="Open reports stay here until you hide the review or restore it."
      :status="status"
      :error="error"
    >
      <p v-if="openReports.length === 0" class="admin-meta">No open reports.</p>
      <article v-for="report in openReports" :key="report.id" class="admin-card">
        <h2>{{ report.target_type === 'review' ? 'Review report' : 'Photo report' }}</h2>
        <template v-if="reportedText(report)">
          <p class="admin-meta">Reported text</p>
          <blockquote class="report-quote">{{ reportedText(report) }}</blockquote>
        </template>
        <p>{{ report.reason || 'No note from the reporter.' }}</p>
        <p class="admin-meta">
          {{ report.review_id ? `Review ${report.review_id}` : `Cafe ${report.shop_id}` }}
          · {{ formatAdminDate(report.created_at) }}
        </p>
        <div class="admin-row-actions">
          <button
            type="button"
            class="admin-btn admin-btn--danger"
            :disabled="savingId === report.id"
            @click="onResolve(report.id, 'hidden')"
          >
            Keep hidden
          </button>
          <button
            type="button"
            class="admin-btn admin-btn--ghost"
            :disabled="savingId === report.id"
            @click="onResolve(report.id, 'dismissed')"
          >
            Restore
          </button>
        </div>
      </article>
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import AdminShell from '~/components/admin/AdminShell.vue'
import { formatAdminDate } from '~/utils/admin-nav'
import { reportedReviewCopy } from '~/utils/moderation'
import type { ContentReportRow } from '~/types/shop'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const admin = useAdminData()
const { reports, status, error, savingId, load, resolveReport } = admin
const openReports = computed(() => reports.value.filter((report) => report.status === 'open'))
const reportedText = (report: ContentReportRow) => reportedReviewCopy(report)

const onResolve = async (id: string, outcome: 'hidden' | 'dismissed') => {
  try {
    await resolveReport(id, outcome)
  } catch {
    /* shown in the admin shell */
  }
}

onMounted(() => {
  void load()
})
</script>
