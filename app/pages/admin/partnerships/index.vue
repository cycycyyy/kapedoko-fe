<template>
  <IonPage>
    <AdminShell
      title="Partnerships"
      lede="Partner and sponsored map pins stay beside cafe data. Ending a window returns the standard pin."
      :status="status"
      :error="error"
    >
      <form class="admin-panel admin-form" @submit.prevent="onCreate">
        <label class="admin-field">
          Cafe
          <select v-model="draft.shopId" required>
            <option value="" disabled>Choose an approved cafe</option>
            <option v-for="shop in approved" :key="shop.id" :value="shop.id">{{ shop.name }}</option>
          </select>
        </label>
        <label class="admin-field">
          Pin
          <select v-model="draft.kind">
            <option value="partner">Partner</option>
            <option value="sponsored">Sponsored</option>
            <option value="standard">Standard (clear paid pin)</option>
          </select>
        </label>
        <label v-if="draft.kind !== 'standard'" class="admin-field">
          Starts
          <input v-model="draft.startsAt" type="datetime-local" required />
        </label>
        <label v-if="draft.kind !== 'standard'" class="admin-field">
          Ends
          <input v-model="draft.endsAt" type="datetime-local" required />
        </label>
        <div class="admin-span admin-row-actions">
          <p v-if="formError" class="admin-error">{{ formError }}</p>
          <button class="admin-btn" type="submit" :disabled="Boolean(savingId)">Save placement</button>
        </div>
      </form>

      <div class="admin-toolbar">
        <button
          v-for="filter in filters"
          :key="filter.id"
          type="button"
          class="admin-chip"
          :class="{ 'is-active': lifecycle === filter.id }"
          @click="lifecycle = filter.id"
        >
          {{ filter.label }}
        </button>
      </div>

      <div class="admin-table-wrap">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Cafe</th>
              <th>Kind</th>
              <th>Window</th>
              <th>State</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in visible" :key="row.id">
              <td>{{ shopName(row.shop_id) }}</td>
              <td>{{ row.kind }}</td>
              <td>{{ formatAdminDate(row.starts_at) }} – {{ formatAdminDate(row.ends_at) }}</td>
              <td><span class="admin-status" :class="`admin-status--${row.life}`">{{ row.life }}</span></td>
              <td>
                <button
                  v-if="row.life !== 'ended'"
                  type="button"
                  class="admin-btn admin-btn--ghost"
                  :disabled="savingId === row.id"
                  @click="onEnd(row.id)"
                >
                  End now
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="admin-cards">
        <article v-for="row in visible" :key="row.id" class="admin-card">
          <h2>{{ shopName(row.shop_id) }}</h2>
          <p>{{ row.kind }} · {{ row.life }}</p>
          <p>{{ formatAdminDate(row.starts_at) }} – {{ formatAdminDate(row.ends_at) }}</p>
          <button
            v-if="row.life !== 'ended'"
            type="button"
            class="admin-btn admin-btn--ghost"
            :disabled="savingId === row.id"
            @click="onEnd(row.id)"
          >
            End now
          </button>
        </article>
      </div>
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import AdminShell from '~/components/admin/AdminShell.vue'
import type { PlacementLifecycle } from '~/types/admin'
import { formatAdminDate, toLocalInput } from '~/utils/admin-nav'
import { placementLifecycle, placementWindowError } from '~/utils/admin-placements'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const admin = useAdminData()
const { shops, placements, status, error, savingId, load, savePlacement, endPlacement } = admin
const now = new Date()
const later = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000)
const draft = reactive({
  shopId: '',
  kind: 'partner' as 'partner' | 'sponsored' | 'standard',
  startsAt: toLocalInput(now),
  endsAt: toLocalInput(later),
})
const formError = ref('')
const lifecycle = ref<PlacementLifecycle | 'all'>('current')
const filters = [
  { id: 'all' as const, label: 'All' },
  { id: 'current' as const, label: 'Current' },
  { id: 'scheduled' as const, label: 'Scheduled' },
  { id: 'ended' as const, label: 'Ended' },
]

const approved = computed(() => shops.value.filter((shop) => shop.status === 'approved'))
const shopName = (id: string) => shops.value.find((shop) => shop.id === id)?.name ?? id
const rows = computed(() =>
  placements.value.map((row) => ({ ...row, life: placementLifecycle(row) })),
)
const visible = computed(() =>
  lifecycle.value === 'all' ? rows.value : rows.value.filter((row) => row.life === lifecycle.value),
)

const onEnd = async (id: string) => {
  try {
    await endPlacement(id)
  } catch (err) {
    formError.value = err instanceof Error ? err.message : 'Could not end this placement.'
  }
}

const onCreate = async () => {
  formError.value = ''
  const shop = approved.value.find((item) => item.id === draft.shopId)
  if (!shop) {
    formError.value = 'Choose an approved cafe.'
    return
  }
  if (draft.kind !== 'standard') {
    const windowIssue = placementWindowError(draft.startsAt, draft.endsAt)
    if (windowIssue) {
      formError.value = windowIssue
      return
    }
  }
  try {
    await savePlacement(shop, draft.kind, draft.startsAt, draft.endsAt)
  } catch (err) {
    formError.value = err instanceof Error ? err.message : 'Could not save this placement.'
  }
}

onMounted(() => {
  void load()
})
</script>
