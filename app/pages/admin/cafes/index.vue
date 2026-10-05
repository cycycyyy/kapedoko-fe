<template>
  <IonPage>
    <AdminShell
      title="Cafes"
      lede="Search, edit, or publish a cafe immediately. Location is not limited to Metro Manila."
      :status="status"
      :error="error"
      :pending-count="counts.pending"
      :claim-count="counts.pendingClaims"
    >
      <template #actions>
        <NuxtLink class="admin-btn" to="/admin/cafes/new">Add cafe</NuxtLink>
      </template>

      <AdminPendingRail :shops="pending" :status="status" />

      <div class="admin-toolbar cafe-board">
        <input
          v-model="query"
          class="admin-search"
          type="search"
          placeholder="Search cafe name or address"
          aria-label="Search cafe name or address"
        />
        <div class="cafe-filters" role="group" aria-label="Filter by status">
          <button
            v-for="filter in filters"
            :key="filter.id"
            type="button"
            class="admin-chip"
            :class="{ 'is-active': statusFilter === filter.id }"
            :aria-pressed="statusFilter === filter.id"
            @click="statusFilter = filter.id"
          >
            <span
              v-if="filter.tone"
              class="cafe-pip"
              :class="`cafe-pip--${filter.tone}`"
              aria-hidden="true"
            />
            {{ filter.label }}
            <span class="cafe-count">{{ tally[filter.id] }}</span>
          </button>
        </div>
      </div>

      <p v-if="visible.length === 0" class="admin-meta">No cafes match that search.</p>

      <div v-else ref="ledgerEl" class="admin-ledger cafe-board">
        <div class="admin-table-wrap">
          <table class="admin-table">
            <thead>
              <tr>
                <th>Cafe</th>
                <th>Status</th>
                <th>Address</th>
                <th>Updated</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="shop in paged" :key="shop.id">
                <td>
                  <NuxtLink class="cafe-name" :to="`/admin/cafes/${shop.id}`">{{ shop.name }}</NuxtLink>
                </td>
                <td>
                  <span class="cafe-stamp" :class="`cafe-stamp--${shop.status}`">
                    <span class="cafe-stamp__mark" aria-hidden="true" />
                    {{ statusWord(shop.status) }}
                  </span>
                </td>
                <td>{{ shop.address }}</td>
                <td class="cafe-when">{{ formatAdminDate(shop.updated_at) }}</td>
                <td>
                  <div class="cafe-actions">
                    <NuxtLink class="cafe-edit" :to="`/admin/cafes/${shop.id}`">Edit</NuxtLink>
                    <button
                      v-if="shop.status === 'approved'"
                      type="button"
                      class="cafe-warn"
                      :disabled="savingId === shop.id"
                      :aria-label="`Unpublish ${shop.name}`"
                      @click="unpublish(shop)"
                    >
                      {{ savingId === shop.id ? 'Unpublishing…' : 'Unpublish' }}
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="admin-cards">
          <article v-for="shop in paged" :key="shop.id" class="admin-card">
            <h2>
              <NuxtLink class="cafe-name" :to="`/admin/cafes/${shop.id}`">{{ shop.name }}</NuxtLink>
            </h2>
            <p>
              <span class="cafe-stamp" :class="`cafe-stamp--${shop.status}`">
                <span class="cafe-stamp__mark" aria-hidden="true" />
                {{ statusWord(shop.status) }}
              </span>
            </p>
            <p>{{ shop.address }}</p>
            <div class="cafe-actions">
              <NuxtLink class="cafe-edit" :to="`/admin/cafes/${shop.id}`">Edit</NuxtLink>
              <button
                v-if="shop.status === 'approved'"
                type="button"
                class="cafe-warn"
                :disabled="savingId === shop.id"
                :aria-label="`Unpublish ${shop.name}`"
                @click="unpublish(shop)"
              >
                {{ savingId === shop.id ? 'Unpublishing…' : 'Unpublish' }}
              </button>
            </div>
          </article>
        </div>

        <div class="cafe-pages">
          <p class="cafe-pages__status" aria-live="polite">
            Showing {{ range.start }}–{{ range.end }} of {{ visible.length }}
          </p>
          <nav v-if="pageCount > 1" class="cafe-pages__nav" aria-label="Cafe pages">
            <button
              type="button"
              class="cafe-page cafe-page--step"
              :disabled="currentPage === 1"
              aria-label="Previous page"
              @click="goToPage(currentPage - 1)"
            >
              Previous
            </button>
            <template v-for="(token, index) in pageTokens" :key="`${token}-${index}`">
              <span v-if="token === 'gap'" class="cafe-page-gap" aria-hidden="true">…</span>
              <button
                v-else
                type="button"
                class="cafe-page"
                :class="{ 'is-current': token === currentPage }"
                :aria-current="token === currentPage ? 'page' : undefined"
                :aria-label="`Page ${token}`"
                @click="goToPage(token)"
              >
                {{ token }}
              </button>
            </template>
            <button
              type="button"
              class="cafe-page cafe-page--step"
              :disabled="currentPage === pageCount"
              aria-label="Next page"
              @click="goToPage(currentPage + 1)"
            >
              Next
            </button>
          </nav>
        </div>
      </div>
    </AdminShell>
  </IonPage>
</template>

<script lang="ts" setup>
import AdminPendingRail from '~/components/admin/AdminPendingRail.vue'
import AdminShell from '~/components/admin/AdminShell.vue'
import type { ShopRow, ShopStatus } from '~/types/shop'
import { formatAdminDate } from '~/utils/admin-nav'
import { ledgerPageCount, ledgerPageRange, ledgerPageSlice, ledgerPageTokens } from '~/utils/admin-ledger'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const admin = useAdminData()
const { shops, counts, status, error, savingId, load, moderate } = admin
const query = ref('')
const statusFilter = ref<'all' | ShopStatus>('all')
const page = ref(1)
const ledgerEl = ref<HTMLElement | null>(null)
const filters = [
  { id: 'all' as const, label: 'All', tone: '' },
  { id: 'approved' as const, label: 'Approved', tone: 'approved' },
  { id: 'pending' as const, label: 'Pending', tone: 'pending' },
  { id: 'rejected' as const, label: 'Rejected', tone: 'rejected' },
]

const pending = computed(() => shops.value.filter((shop) => shop.status === 'pending'))
const tally = computed(() => ({
  all: shops.value.length,
  approved: shops.value.filter((shop) => shop.status === 'approved').length,
  pending: pending.value.length,
  rejected: shops.value.filter((shop) => shop.status === 'rejected').length,
}))
const visible = computed(() => {
  const term = query.value.trim().toLowerCase()
  return shops.value.filter((shop) => {
    if (statusFilter.value !== 'all' && shop.status !== statusFilter.value) return false
    if (!term) return true
    return `${shop.name} ${shop.address}`.toLowerCase().includes(term)
  })
})
const pageCount = computed(() => ledgerPageCount(visible.value.length))
const currentPage = computed(() => Math.min(page.value, pageCount.value))
const paged = computed(() => ledgerPageSlice(visible.value, currentPage.value))
const range = computed(() => ledgerPageRange(visible.value.length, currentPage.value))
const pageTokens = computed(() => ledgerPageTokens(currentPage.value, pageCount.value))

watch([query, statusFilter], () => {
  page.value = 1
})

watch(pageCount, (count) => {
  if (page.value > count) page.value = count
})

const scrollLedgerIntoView = async (el: HTMLElement) => {
  const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches
  const behavior: ScrollBehavior = reduce ? 'auto' : 'smooth'
  const content = el.closest('ion-content') as (HTMLElement & { getScrollElement?: () => Promise<HTMLElement> }) | null
  if (content?.getScrollElement) {
    const scroller = await content.getScrollElement()
    const top = el.getBoundingClientRect().top - scroller.getBoundingClientRect().top + scroller.scrollTop
    scroller.scrollTo({ top: Math.max(0, top - 8), behavior })
    return
  }
  el.scrollIntoView({ block: 'start', behavior })
}

const goToPage = (next: number) => {
  const target = Math.min(Math.max(1, next), pageCount.value)
  if (target === currentPage.value) return
  page.value = target
  void nextTick(() => {
    const el = ledgerEl.value
    if (el) void scrollLedgerIntoView(el)
  })
}

const statusWord = (value: ShopStatus) => {
  if (value === 'approved') return 'Approved'
  if (value === 'pending') return 'Pending'
  return 'Rejected'
}

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

<style scoped>
.cafe-board {
  caret-color: var(--kd-primary);
}

.cafe-board ::selection {
  background: var(--kd-accent);
  color: var(--kd-ink);
}

.cafe-filters {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
}

.cafe-filters .admin-chip {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  border-color: color-mix(in srgb, var(--kd-ink) 16%, transparent);
}

.cafe-filters .admin-chip.is-active {
  border-color: var(--kd-accent);
}

.cafe-pip {
  width: 8px;
  height: 8px;
  border-radius: 16px;
  flex: 0 0 auto;
}

.cafe-pip--approved {
  background: var(--kd-primary);
}

.cafe-pip--pending {
  background: var(--kd-accent);
}

.cafe-pip--rejected {
  background: var(--kd-destructive);
}

.cafe-count {
  font-variant-numeric: tabular-nums;
  font-weight: 700;
}

.cafe-name {
  color: var(--kd-ink);
  font-weight: 700;
  text-decoration: none;
}

.cafe-name:hover {
  color: var(--kd-primary);
}

.cafe-name:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.cafe-stamp {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  min-height: 28px;
  padding: 0 10px;
  border-radius: 16px;
  font-size: 0.75rem;
  font-weight: 700;
  line-height: 1;
  white-space: nowrap;
}

.cafe-stamp__mark {
  width: 8px;
  height: 8px;
  border-radius: 16px;
  flex: 0 0 auto;
}

.cafe-stamp--approved {
  background: color-mix(in srgb, var(--kd-primary) 16%, #faf8f5);
  color: var(--kd-primary);
}

.cafe-stamp--approved .cafe-stamp__mark {
  background: var(--kd-primary);
}

.cafe-stamp--pending {
  background: color-mix(in srgb, var(--kd-accent) 28%, #faf8f5);
  color: var(--kd-ink);
}

.cafe-stamp--pending .cafe-stamp__mark {
  background: var(--kd-accent);
}

.cafe-stamp--rejected {
  background: color-mix(in srgb, var(--kd-destructive) 14%, #faf8f5);
  color: var(--kd-destructive);
}

.cafe-stamp--rejected .cafe-stamp__mark {
  background: var(--kd-destructive);
}

.cafe-when {
  white-space: nowrap;
  font-variant-numeric: tabular-nums;
}

.cafe-board.admin-ledger th,
.cafe-board.admin-ledger td {
  vertical-align: middle;
}

.cafe-board.admin-ledger th:last-child,
.cafe-board.admin-ledger td:last-child {
  width: 1%;
  white-space: nowrap;
}

.cafe-actions {
  display: flex;
  flex-wrap: nowrap;
  justify-content: flex-end;
  align-items: center;
  gap: 8px;
}

.cafe-edit,
.cafe-warn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  padding: 0 14px;
  border-radius: 16px;
  font: inherit;
  font-size: 0.7875rem;
  font-weight: 700;
  text-decoration: none;
  cursor: pointer;
}

.cafe-edit {
  border: 1px solid var(--kd-primary);
  background: transparent;
  color: var(--kd-primary);
}

.cafe-warn {
  border: 1px solid var(--kd-destructive);
  background: var(--kd-destructive);
  color: var(--kd-white);
}

.cafe-edit:hover {
  background: color-mix(in srgb, var(--kd-primary) 10%, #faf8f5);
}

.cafe-warn:hover:not(:disabled) {
  background: color-mix(in srgb, var(--kd-destructive) 88%, #1c1917);
}

.cafe-edit:focus-visible,
.cafe-warn:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.cafe-edit:active,
.cafe-warn:active:not(:disabled) {
  transform: translateY(1px);
}

.cafe-warn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.cafe-pages {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 8px 16px;
  padding: 8px 0 12px;
}

.cafe-pages__status {
  margin: 0;
  color: color-mix(in srgb, var(--kd-ink) 72%, #faf8f5);
  font-size: 0.75rem;
  font-variant-numeric: tabular-nums;
}

.cafe-pages__nav {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 4px;
}

.cafe-page {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 44px;
  min-height: 44px;
  padding: 0 8px;
  border: 1px solid transparent;
  border-radius: 16px;
  background: transparent;
  color: var(--kd-ink);
  font: inherit;
  font-size: 0.7875rem;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
  cursor: pointer;
}

.cafe-page--step {
  padding: 0 14px;
  border-color: var(--kd-primary);
  color: var(--kd-primary);
}

.cafe-page.is-current {
  background: color-mix(in srgb, var(--kd-primary) 16%, #faf8f5);
  color: var(--kd-primary);
}

.cafe-page-gap {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 24px;
  min-height: 44px;
  color: color-mix(in srgb, var(--kd-ink) 72%, #faf8f5);
  font-variant-numeric: tabular-nums;
}

.cafe-page:hover:not(:disabled):not(.is-current) {
  background: color-mix(in srgb, var(--kd-primary) 10%, #faf8f5);
}

.cafe-page:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.cafe-page:active:not(:disabled) {
  transform: translateY(1px);
}

.cafe-page:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

@media (max-width: 767px) {
  .cafe-actions {
    justify-content: flex-start;
  }

  .cafe-edit,
  .cafe-warn {
    flex: 1 1 0;
  }
}

@media (prefers-reduced-motion: reduce) {
  .cafe-edit:active,
  .cafe-warn:active:not(:disabled),
  .cafe-page:active:not(:disabled) {
    transform: none;
  }
}
</style>
