<template>
  <IonPage>
    <AdminShell
      title="Cafes"
      lede="Search, edit, or publish a cafe immediately. Location is not limited to Metro Manila."
      :status="status"
      :error="error"
      :pending-count="counts.pending"
    >
      <template #actions>
        <NuxtLink class="admin-btn" to="/admin/cafes/new">Add cafe</NuxtLink>
      </template>

      <div class="admin-toolbar">
        <input v-model="query" class="admin-search" type="search" placeholder="Search cafe name or address" />
        <button
          v-for="filter in filters"
          :key="filter.id"
          type="button"
          class="admin-chip"
          :class="{ 'is-active': statusFilter === filter.id }"
          @click="statusFilter = filter.id"
        >
          {{ filter.label }}
        </button>
      </div>

      <p v-if="visible.length === 0" class="admin-meta">No cafes match that search.</p>

      <div class="admin-table-wrap">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Cafe</th>
              <th>Status</th>
              <th>Address</th>
              <th>Updated</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="shop in paged" :key="shop.id">
              <td>{{ shop.name }}</td>
              <td><span class="admin-status" :class="`admin-status--${shop.status}`">{{ shop.status }}</span></td>
              <td>{{ shop.address }}</td>
              <td>{{ formatAdminDate(shop.updated_at) }}</td>
              <td>
                <div class="admin-row-actions">
                  <NuxtLink class="admin-link" :to="`/admin/cafes/${shop.id}`">Edit</NuxtLink>
                  <button
                    v-if="shop.status === 'approved'"
                    type="button"
                    class="admin-btn admin-btn--ghost"
                    :disabled="savingId === shop.id"
                    @click="unpublish(shop)"
                  >
                    Unpublish
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="admin-cards">
        <article v-for="shop in paged" :key="shop.id" class="admin-card">
          <h2>{{ shop.name }}</h2>
          <p>{{ shop.address }}</p>
          <p><span class="admin-status" :class="`admin-status--${shop.status}`">{{ shop.status }}</span></p>
          <div class="admin-row-actions">
            <NuxtLink class="admin-link" :to="`/admin/cafes/${shop.id}`">Edit</NuxtLink>
            <button
              v-if="shop.status === 'approved'"
              type="button"
              class="admin-btn admin-btn--ghost"
              :disabled="savingId === shop.id"
              @click="unpublish(shop)"
            >
              Unpublish
            </button>
          </div>
        </article>
      </div>
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import AdminShell from '~/components/admin/AdminShell.vue'
import type { ShopRow, ShopStatus } from '~/types/shop'
import { formatAdminDate } from '~/utils/admin-nav'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const admin = useAdminData()
const { shops, counts, status, error, savingId, load, moderate } = admin
const query = ref('')
const statusFilter = ref<'all' | ShopStatus>('all')
const filters = [
  { id: 'all' as const, label: 'All' },
  { id: 'approved' as const, label: 'Approved' },
  { id: 'pending' as const, label: 'Pending' },
  { id: 'rejected' as const, label: 'Rejected' },
]

const visible = computed(() => {
  const term = query.value.trim().toLowerCase()
  return shops.value.filter((shop) => {
    if (statusFilter.value !== 'all' && shop.status !== statusFilter.value) return false
    if (!term) return true
    return `${shop.name} ${shop.address}`.toLowerCase().includes(term)
  })
})
const paged = computed(() => visible.value.slice(0, 80))

const unpublish = async (shop: ShopRow) => {
  if (!window.confirm(`Unpublish ${shop.name}? It leaves Home and Map until it is approved again.`)) return
  try {
    await moderate(shop, 'pending')
  } catch {
    /* shown in the admin shell */
  }
}

onMounted(() => {
  void load()
})
</script>
