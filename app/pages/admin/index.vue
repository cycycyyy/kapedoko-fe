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

            <form
              v-if="shop.status === 'approved'"
              class="admin__placement"
              @submit.prevent="onSavePin(shop)"
            >
              <p class="admin__meta">Live pin: {{ markerTierFor(shop.id) }}</p>
              <label class="admin__field">
                <span>Map pin</span>
                <select v-model="draftFor(shop).tier">
                  <option value="standard">Standard</option>
                  <option value="partner">Partner</option>
                  <option value="promoted">Promoted</option>
                </select>
              </label>
              <div v-if="draftFor(shop).tier !== 'standard'" class="admin__dates">
                <label class="admin__field">
                  <span>Starts</span>
                  <input v-model="draftFor(shop).startsAt" type="datetime-local" required />
                </label>
                <label class="admin__field">
                  <span>Ends</span>
                  <input v-model="draftFor(shop).endsAt" type="datetime-local" required />
                </label>
              </div>
              <button
                type="submit"
                class="admin__approve"
                :disabled="savingId === shop.id"
              >
                Save pin
              </button>
            </form>

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
import type { MarkerTier, ShopRow, ShopStatus } from '~/types/shop'
import { summarizeHours } from '~/utils/hours'
import { isKapedokoMark } from '~/utils/logo'
import { isPlacementActive } from '~/utils/marker-tier'
import { shopImageUrl } from '~/utils/shop-mapper'

type FilterId = ShopStatus

interface PlacementDraft {
  tier: MarkerTier
  startsAt: string
  endsAt: string
}

const { shops, status, error, savingId, moderate, markerTierFor, savePlacement, placementsByShop } =
  useAdminShops()
const config = useRuntimeConfig()
const publicBase = String(config.public.r2PublicBaseUrl || '')
const drafts = reactive<Record<string, PlacementDraft>>({})

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

const pad = (value: number) => String(value).padStart(2, '0')

const toLocalInput = (date: Date) =>
  `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`

const defaultDraft = (shop: ShopRow): PlacementDraft => {
  const now = new Date()
  const end = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000)
  const active = (placementsByShop.value.get(shop.id) ?? []).find((row) => isPlacementActive(row))
  return {
    tier: markerTierFor(shop.id),
    startsAt: toLocalInput(active ? new Date(active.starts_at) : now),
    endsAt: toLocalInput(active ? new Date(active.ends_at) : end),
  }
}

const draftFor = (shop: ShopRow) => {
  const current = drafts[shop.id]
  if (current) return current
  const next = defaultDraft(shop)
  drafts[shop.id] = next
  return next
}

watch(
  [shops, placementsByShop],
  () => {
    for (const shop of shops.value) {
      if (!drafts[shop.id]) drafts[shop.id] = defaultDraft(shop)
    }
  },
  { immediate: true },
)

const onApprove = async (shop: ShopRow) => {
  await moderate(shop, 'approved')
}

const onReject = async (shop: ShopRow) => {
  const reason = window.prompt('Why is this listing being rejected?', '')
  if (reason == null) return
  await moderate(shop, 'rejected', reason)
}

const onSavePin = async (shop: ShopRow) => {
  const draft = draftFor(shop)
  await savePlacement(shop, draft.tier, draft.startsAt, draft.endsAt)
  drafts[shop.id] = defaultDraft(shop)
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

.admin__placement {
  display: grid;
  gap: 10px;
  margin-top: 14px;
}

.admin__dates {
  display: grid;
  gap: 10px;
}

.admin__field {
  display: grid;
  gap: 4px;
  color: var(--kd-primary);
  font-size: 12px;
  font-weight: 700;
}

.admin__field select,
.admin__field input {
  height: 50px;
  padding: 0 12px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-secondary);
  color: var(--kd-ink);
  font-size: 12px;
  font-weight: 400;
  font-family: inherit;
}

.admin__field select:focus-visible,
.admin__field input:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.admin__placement .admin__approve {
  width: 100%;
}

@media (min-width: 540px) {
  .admin {
    max-width: 480px;
    margin-inline: auto;
  }
}
</style>
