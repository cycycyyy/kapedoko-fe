<template>
  <IonPage>
    <IonContent class="admin-content">
      <div class="admin">
        <header class="admin__hero">
          <h1>Submissions</h1>
          <p>Approve listings that are in Metro Manila and ready to appear on the map.</p>
        </header>

        <p v-if="status === 'forbidden'" class="admin__state">
          This queue is for admins. Ask to have your account granted the admin role.
        </p>
        <p v-else-if="status === 'loading'" class="admin__state">Loading submissions…</p>
        <p v-else-if="status === 'error'" class="admin__state admin__state--error">{{ error }}</p>

        <template v-else-if="status === 'ready'">
          <div class="admin__filters" role="tablist" aria-label="Submission status">
            <button
              v-for="filter in filters"
              :key="filter.id"
              type="button"
              role="tab"
              class="admin__chip"
              :class="{ 'is-active': activeFilter === filter.id }"
              :aria-selected="activeFilter === filter.id"
              @click="activeFilter = filter.id"
            >
              {{ filter.label }}
            </button>
          </div>

          <p v-if="visible.length === 0" class="admin__state">No {{ activeFilter }} submissions.</p>

          <article v-for="shop in visible" :key="shop.id" class="admin__card">
            <div class="admin__card-top">
              <img
                v-if="logoSrc(shop)"
                class="admin__logo"
                :src="logoSrc(shop)"
                :alt="`${shop.name} logo`"
                width="48"
                height="48"
              />
              <div class="admin__card-heading">
                <h2>{{ shop.name }}</h2>
                <p class="admin__status">{{ shop.status }}</p>
              </div>
            </div>
            <p>{{ shop.address }}</p>
            <p>{{ summarizeHours(shop.hours) }}</p>
            <p v-if="shop.contact_number">{{ shop.contact_number }}</p>
            <p class="admin__meta">Pinned at {{ shop.latitude.toFixed(5) }}, {{ shop.longitude.toFixed(5) }}</p>
            <p v-if="shop.rejection_reason" class="admin__reason">{{ shop.rejection_reason }}</p>

            <div v-if="shop.status === 'pending'" class="admin__actions">
              <button
                type="button"
                class="admin__approve"
                :disabled="savingId === shop.id"
                @click="onApprove(shop)"
              >
                Approve
              </button>
              <button
                type="button"
                class="admin__reject"
                :disabled="savingId === shop.id"
                @click="onReject(shop)"
              >
                Reject
              </button>
            </div>
          </article>
        </template>
      </div>
    </IonContent>
  </IonPage>
</template>

<script lang="ts" setup>
import type { ShopRow, ShopStatus } from '~/types/shop'
import { summarizeHours } from '~/utils/hours'
import { isKapedokoMark } from '~/utils/logo'
import { shopImageUrl } from '~/utils/shop-mapper'

type FilterId = ShopStatus

const { shops, status, error, savingId, moderate } = useAdminShops()
const config = useRuntimeConfig()
const publicBase = String(config.public.r2PublicBaseUrl || '')

const logoSrc = (shop: ShopRow) => {
  const url = shopImageUrl(shop, publicBase)
  return isKapedokoMark(url) ? '' : url
}
const activeFilter = ref<FilterId>('pending')
const filters: { id: FilterId; label: string }[] = [
  { id: 'pending', label: 'Pending' },
  { id: 'approved', label: 'Approved' },
  { id: 'rejected', label: 'Rejected' },
]

const visible = computed(() => shops.value.filter((shop) => shop.status === activeFilter.value))

const onApprove = async (shop: ShopRow) => {
  await moderate(shop, 'approved')
}

const onReject = async (shop: ShopRow) => {
  const reason = window.prompt('Why is this listing being rejected?', '')
  if (reason == null) return
  await moderate(shop, 'rejected', reason)
}
</script>

<style scoped>
.admin-content {
  --background: var(--kd-white);
  --padding-start: 0;
  --padding-end: 0;
}

.admin {
  min-height: 100%;
  padding: max(2.75rem, calc(env(safe-area-inset-top) + 16px)) 20px calc(2rem + env(safe-area-inset-bottom));
  background: var(--kd-white);
}

.admin__hero {
  padding: 8px 0 18px;
  color: var(--kd-primary);
}

.admin__hero h1 {
  margin: 0;
  font-size: 20px;
  font-weight: 700;
}

.admin__hero p,
.admin__state,
.admin__card p,
.admin__meta {
  margin: 6px 0 0;
  color: var(--kd-ink);
  font-size: 12px;
  line-height: 1.35;
}

.admin__state--error,
.admin__reason {
  color: var(--kd-closed);
  font-weight: 700;
}

.admin__filters {
  display: flex;
  gap: 10px;
  margin: 8px 0 16px;
}

.admin__chip {
  height: 27px;
  min-width: 97px;
  padding: 0 12px;
  border: 0;
  border-radius: 4px;
  background: var(--kd-ink-10);
  color: var(--kd-primary);
  font-size: 12px;
  font-family: inherit;
  cursor: pointer;
}

.admin__chip.is-active {
  background: var(--kd-primary);
  color: var(--kd-white);
  font-weight: 700;
}

.admin__card {
  margin-bottom: 14px;
  padding: 14px;
  border-radius: 8px;
  background: var(--kd-white);
  box-shadow: 0 2px 8px var(--kd-shadow);
}

.admin__card-top {
  display: flex;
  align-items: flex-start;
  gap: 12px;
}

.admin__logo {
  width: 48px;
  height: 48px;
  flex-shrink: 0;
  object-fit: cover;
  border-radius: 8px;
  background: var(--kd-secondary);
}

.admin__card-heading {
  display: flex;
  flex: 1;
  align-items: baseline;
  justify-content: space-between;
  gap: 10px;
  min-width: 0;
}

.admin__card h2 {
  margin: 0;
  color: var(--kd-primary);
  font-size: 16px;
  font-weight: 700;
}

.admin__status {
  margin: 0;
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--kd-primary);
}

.admin__actions {
  display: flex;
  gap: 10px;
  margin-top: 14px;
}

.admin__approve,
.admin__reject {
  flex: 1;
  height: 45px;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
}

.admin__approve {
  border: 0;
  background: var(--kd-primary);
  color: var(--kd-white);
}

.admin__reject {
  border: 1px solid var(--kd-primary);
  background: var(--kd-white);
  color: var(--kd-primary);
}

.admin__approve:disabled,
.admin__reject:disabled {
  opacity: 0.55;
}

@media (min-width: 540px) {
  .admin {
    max-width: 480px;
    margin-inline: auto;
  }
}
</style>
