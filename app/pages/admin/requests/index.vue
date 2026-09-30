<template>
  <IonPage>
    <AdminShell
      title="Cafe requests"
      lede="Approve listings that are ready for Home and Map. Rejected cafes stay off the public app."
      :status="status"
      :error="error"
      :pending-count="pending.length"
      :claim-count="pendingClaims.length"
    >
      <div class="admin-toolbar" role="tablist" aria-label="Request status">
        <button
          v-for="filter in filters"
          :key="filter.id"
          type="button"
          class="admin-chip"
          :class="{ 'is-active': activeFilter === filter.id }"
          @click="activeFilter = filter.id"
        >
          {{ filter.label }}
        </button>
      </div>

      <p v-if="visible.length === 0" class="admin-meta">No {{ activeFilter }} requests.</p>

      <article v-for="shop in visible" :key="shop.id" class="admin-card">
        <div class="request-top">
          <img v-if="logoSrc(shop)" class="request-logo" :src="logoSrc(shop)" :alt="`${shop.name} logo`" width="48" height="48" />
          <div>
            <h2>{{ shop.name }}</h2>
            <p class="admin-status" :class="`admin-status--${shop.status}`">{{ shop.status }}</p>
          </div>
        </div>
        <p>{{ shop.address }}</p>
        <p>{{ summarizeHours(shop.hours) }}</p>
        <p v-if="shop.contact_number">{{ shop.contact_number }}</p>
        <p class="admin-meta">Pinned at {{ shop.latitude.toFixed(5) }}, {{ shop.longitude.toFixed(5) }}</p>
        <p v-if="shop.source === 'openstreetmap'" class="admin-meta">OpenStreetMap {{ shop.osm_type && shop.osm_id ? `${shop.osm_type}/${shop.osm_id}` : 'import' }}</p>
        <p v-if="shop.reviewed_at" class="admin-meta">Reviewed {{ formatAdminDate(shop.reviewed_at) }}</p>
        <p v-if="shop.rejection_reason" class="admin-error">{{ shop.rejection_reason }}</p>
        <div v-if="shop.status === 'pending'" class="admin-row-actions">
          <button type="button" class="admin-btn" :disabled="savingId === shop.id" @click="onApprove(shop)">Approve</button>
          <button type="button" class="admin-btn admin-btn--ghost" :disabled="savingId === shop.id" @click="onReject(shop)">Reject</button>
        </div>
      </article>
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import AdminShell from '~/components/admin/AdminShell.vue'
import type { ShopRow, ShopStatus } from '~/types/shop'
import { formatAdminDate } from '~/utils/admin-nav'
import { summarizeHours } from '~/utils/hours'
import { isKapedokoMark } from '~/utils/logo'
import { shopImageUrl } from '~/utils/shop-mapper'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const admin = useAdminData()
const { shops, claims, status, error, savingId, load, moderate } = admin
const config = useRuntimeConfig()
const publicBase = String(config.public.r2PublicBaseUrl || '')
const route = useRoute()
const activeFilter = ref<ShopStatus>('pending')
const filters = [
  { id: 'pending' as const, label: 'Pending' },
  { id: 'approved' as const, label: 'Approved' },
  { id: 'rejected' as const, label: 'Rejected' },
]

const logoSrc = (shop: ShopRow) => {
  const url = shopImageUrl(shop, publicBase)
  return isKapedokoMark(url) ? '' : url
}

const visible = computed(() => shops.value.filter((shop) => shop.status === activeFilter.value))
const pending = computed(() => shops.value.filter((shop) => shop.status === 'pending'))
const pendingClaims = computed(() => claims.value.filter((claim) => claim.status === 'pending'))

const onApprove = async (shop: ShopRow) => {
  try {
    await moderate(shop, 'approved')
  } catch {
    /* shown in the admin shell */
  }
}

const onReject = async (shop: ShopRow) => {
  const reason = window.prompt('Why is this listing being rejected?', '')
  if (reason == null || !reason.trim()) return
  try {
    await moderate(shop, 'rejected', reason.trim())
  } catch {
    /* shown in the admin shell */
  }
}

onMounted(() => {
  const focus = typeof route.query.id === 'string' ? route.query.id : ''
  void load().then(() => {
    if (focus && shops.value.some((shop) => shop.id === focus && shop.status !== 'pending')) {
      const found = shops.value.find((shop) => shop.id === focus)
      if (found) activeFilter.value = found.status
    }
  })
})
</script>

<style scoped>
.request-top {
  display: flex;
  gap: 12px;
  align-items: flex-start;
}

.request-logo {
  width: 48px;
  height: 48px;
  object-fit: cover;
  border-radius: 8px;
  background: var(--kd-secondary);
}
</style>
