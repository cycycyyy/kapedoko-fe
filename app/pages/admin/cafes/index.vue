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
        <NuxtLink class="admin-btn admin-btn--ghost" to="/admin/cafes/import">Import CSV</NuxtLink>
        <NuxtLink class="admin-btn" to="/admin/cafes/new">Add cafe</NuxtLink>
      </template>

      <p v-if="stampNotice || importedCopy" class="cafe-notice" role="status">{{ stampNotice || importedCopy }}</p>

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

      <AdminCafeLogoDialog
        class="cafe-stamp-pad"
        :shop="logoShop"
        :sources="logoSources"
        :status="logoSourcesStatus"
        :public-base="publicBase"
        :saving="busy"
        :selected-count="Math.max(selectedIds.size, logoShop ? 1 : 0)"
        @close="closeLogoPicker"
        @assign="assignLogo"
      >
        <template #ticks>
          <button type="button" class="admin-btn admin-btn--ghost" :disabled="busy" @click="tickPaged">
            This page
          </button>
          <button
            v-if="visible.length > 1"
            type="button"
            class="admin-btn"
            :disabled="busy"
            @click="tickVisible"
          >
            All {{ visible.length }} in this search
          </button>
          <button type="button" class="admin-btn admin-btn--quiet" :disabled="busy" @click="resetTicks">
            Clear extra ticks
          </button>
        </template>
      </AdminCafeLogoDialog>

      <p v-if="visible.length === 0" class="admin-meta">No cafes match that search.</p>

      <div v-else ref="ledgerEl" class="admin-ledger cafe-board" :class="{ 'is-stamping': Boolean(logoShop) }">
        <div class="admin-table-wrap">
          <table class="admin-table">
            <thead>
              <tr>
                <th>
                  <span class="cafe-heading">
                    <label v-if="logoShop" class="cafe-tick">
                      <input
                        ref="pageTickEl"
                        type="checkbox"
                        :checked="pageTick === 'all'"
                        :disabled="busy"
                        @change="onPageTick"
                      />
                      <span class="sr-only">Tick cafes on this page</span>
                    </label>
                    Cafe
                  </span>
                </th>
                <th>Status</th>
                <th>Address</th>
                <th>Updated</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="shop in paged" :key="shop.id" :class="{ 'is-ticked': selectedIds.has(shop.id) }">
                <td>
                  <div class="cafe-identity">
                    <label v-if="logoShop" class="cafe-tick">
                      <input
                        type="checkbox"
                        :checked="selectedIds.has(shop.id)"
                        :disabled="busy"
                        :aria-label="`Also stamp onto ${shop.name}`"
                        @change="toggleTick(shop.id, ($event.target as HTMLInputElement).checked)"
                      />
                    </label>
                    <AdminCafeLogoButton
                      :shop="shop"
                      :public-base="publicBase"
                      :saving="savingId === shop.id || savingId === 'logos'"
                      :expanded="logoShop?.id === shop.id"
                      @click="openLogoPicker(shop)"
                    />
                    <NuxtLink class="cafe-name" :to="`/admin/cafes/${shop.id}`">{{ shop.name }}</NuxtLink>
                  </div>
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
                    <button
                      v-else-if="shop.status === 'hidden'"
                      type="button"
                      class="cafe-edit"
                      :disabled="savingId === shop.id"
                      :aria-label="`Publish ${shop.name}`"
                      @click="publish(shop)"
                    >
                      {{ savingId === shop.id ? 'Publishing…' : 'Publish' }}
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="admin-cards">
          <article
            v-for="shop in paged"
            :key="shop.id"
            class="admin-card"
            :class="{ 'is-ticked': selectedIds.has(shop.id) }"
          >
            <div class="cafe-identity">
              <label v-if="logoShop" class="cafe-tick">
                <input
                  type="checkbox"
                  :checked="selectedIds.has(shop.id)"
                  :disabled="busy"
                  :aria-label="`Also stamp onto ${shop.name}`"
                  @change="toggleTick(shop.id, ($event.target as HTMLInputElement).checked)"
                />
              </label>
              <AdminCafeLogoButton
                :shop="shop"
                :public-base="publicBase"
                :saving="savingId === shop.id || savingId === 'logos'"
                :expanded="logoShop?.id === shop.id"
                @click="openLogoPicker(shop)"
              />
              <h2>
                <NuxtLink class="cafe-name" :to="`/admin/cafes/${shop.id}`">{{ shop.name }}</NuxtLink>
              </h2>
            </div>
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
              <button
                v-else-if="shop.status === 'hidden'"
                type="button"
                class="cafe-edit"
                :disabled="savingId === shop.id"
                :aria-label="`Publish ${shop.name}`"
                @click="publish(shop)"
              >
                {{ savingId === shop.id ? 'Publishing…' : 'Publish' }}
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
import { onIonViewWillEnter } from '@ionic/vue'
import AdminCafeLogoButton from '~/components/admin/AdminCafeLogoButton.vue'
import AdminCafeLogoDialog from '~/components/admin/AdminCafeLogoDialog.vue'
import AdminPendingRail from '~/components/admin/AdminPendingRail.vue'
import AdminShell from '~/components/admin/AdminShell.vue'
import type { ShopRow, ShopStatus } from '~/types/shop'
import {
  cafeLogoSources,
  logoOverwriteCount,
  logoTickState,
  stampLogoConfirmCopy,
  stampLogoDoneCopy,
} from '~/utils/admin-logos'
import { formatAdminDate } from '~/utils/admin-nav'
import { ledgerPageCount, ledgerPageRange, ledgerPageSlice, ledgerPageTokens } from '~/utils/admin-ledger'
import { shopStatusWord } from '~/utils/admin-shop'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const admin = useAdminData()
const route = useRoute()
const config = useRuntimeConfig()
const { shops, counts, status, error, savingId, load, moderate, updateShopLogos } = admin
const publicBase = String(config.public.r2PublicBaseUrl || '')
const query = ref('')
const logoShop = ref<ShopRow | null>(null)
const selectedIds = ref<Set<string>>(new Set())
const stampNotice = ref('')
const pageTickEl = ref<HTMLInputElement | null>(null)
const statusFilter = ref<'all' | ShopStatus>(Number(route.query.imported) > 0 ? 'hidden' : 'all')
const importedCopy = computed(() => {
  const count = Number(route.query.imported)
  if (!Number.isFinite(count) || count < 1) return ''
  return count === 1
    ? '1 cafe landed unpublished. Publish when the address looks right.'
    : `${count} cafes landed unpublished. Publish when the addresses look right.`
})
const page = ref(1)
const ledgerEl = ref<HTMLElement | null>(null)
const filters = [
  { id: 'all' as const, label: 'All', tone: '' },
  { id: 'approved' as const, label: 'Approved', tone: 'approved' },
  { id: 'hidden' as const, label: 'Hidden', tone: 'hidden' },
  { id: 'pending' as const, label: 'Pending', tone: 'pending' },
  { id: 'rejected' as const, label: 'Rejected', tone: 'rejected' },
]

const pending = computed(() => shops.value.filter((shop) => shop.status === 'pending'))
const tally = computed(() => ({
  all: shops.value.length,
  approved: shops.value.filter((shop) => shop.status === 'approved').length,
  hidden: shops.value.filter((shop) => shop.status === 'hidden').length,
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
const logoSources = computed(() => cafeLogoSources(shops.value, publicBase))
const logoSourcesStatus = computed(() => {
  if (status.value === 'loading' || status.value === 'idle') return 'loading' as const
  if (status.value === 'error' || status.value === 'forbidden') return 'error' as const
  return 'ready' as const
})
const busy = computed(() => Boolean(savingId.value))
const pageTick = computed(() => logoTickState(paged.value.map((shop) => shop.id), selectedIds.value))
const selectedShops = computed(() => shops.value.filter((shop) => selectedIds.value.has(shop.id)))

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

const statusWord = shopStatusWord

const openLogoPicker = (shop: ShopRow) => {
  stampNotice.value = ''
  if (!logoShop.value) {
    selectedIds.value = new Set([shop.id])
  } else {
    const next = new Set(selectedIds.value)
    next.add(shop.id)
    selectedIds.value = next
  }
  logoShop.value = shop
}

const closeLogoPicker = () => {
  logoShop.value = null
  selectedIds.value = new Set()
}

const toggleTick = (id: string, on: boolean) => {
  const next = new Set(selectedIds.value)
  if (on) next.add(id)
  else next.delete(id)
  selectedIds.value = next
}

const tickPaged = () => {
  const next = new Set(selectedIds.value)
  for (const shop of paged.value) next.add(shop.id)
  selectedIds.value = next
}

const tickVisible = () => {
  selectedIds.value = new Set(visible.value.map((shop) => shop.id))
}

const resetTicks = () => {
  selectedIds.value = new Set(logoShop.value ? [logoShop.value.id] : [])
}

const onPageTick = (event: Event) => {
  const on = (event.target as HTMLInputElement).checked
  const next = new Set(selectedIds.value)
  for (const shop of paged.value) {
    if (on) next.add(shop.id)
    else next.delete(shop.id)
  }
  selectedIds.value = next
}

const assignLogo = async (payload: { logoFile: File | null; logoObjectKey: string | null }) => {
  const queue = selectedShops.value.length > 0
    ? selectedShops.value
    : logoShop.value
      ? [logoShop.value]
      : []
  if (queue.length === 0) return
  if (queue.length > 1) {
    const overwrite = logoOverwriteCount(
      queue,
      new Set(queue.map((shop) => shop.id)),
      payload.logoObjectKey,
      Boolean(payload.logoFile),
    )
    if (!window.confirm(stampLogoConfirmCopy(queue.length, overwrite))) return
  }
  try {
    const done = await updateShopLogos(queue, payload)
    stampNotice.value = stampLogoDoneCopy(done.length)
    closeLogoPicker()
  } catch {
    /* shown in the admin shell */
  }
}

watch(pageTick, (state) => {
  if (pageTickEl.value) pageTickEl.value.indeterminate = state === 'some'
})

const unpublish = async (shop: ShopRow) => {
  if (!window.confirm(`Unpublish ${shop.name}? It leaves Home and Map until you publish it again.`)) return
  try {
    await moderate(shop, 'hidden')
  } catch {
    /* shown in the admin shell */
  }
}

const publish = async (shop: ShopRow) => {
  if (!window.confirm(`Publish ${shop.name}? It goes live on Home and Map.`)) return
  try {
    await moderate(shop, 'approved')
  } catch {
    /* shown in the admin shell */
  }
}

onMounted(() => {
  void load()
})

onIonViewWillEnter(() => {
  if (status.value === 'ready') void load({ silent: true })
})
</script>

<style scoped>
.cafe-notice {
  margin: 0 0 16px;
  color: var(--kd-ink);
  font-size: 0.7875rem;
  font-weight: 700;
  line-height: 1.3;
}

.cafe-stamp-pad {
  position: sticky;
  top: 8px;
  z-index: 3;
  box-shadow: 0 8px 18px color-mix(in srgb, var(--kd-ink) 8%, transparent);
}

.cafe-stamp-pad :deep(.admin-btn) {
  transform: rotate(-1.25deg);
}

.cafe-stamp-pad :deep(.admin-btn--ghost),
.cafe-stamp-pad :deep(.admin-btn--quiet) {
  transform: none;
}

.cafe-heading {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.cafe-tick {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  margin: 0;
  flex: 0 0 auto;
  cursor: pointer;
}

.cafe-tick input {
  width: 18px;
  height: 18px;
  accent-color: var(--kd-primary);
  cursor: pointer;
}

.cafe-tick input:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.cafe-board.admin-ledger.is-stamping tr.is-ticked td,
.admin-card.is-ticked {
  background: color-mix(in srgb, var(--kd-accent) 12%, #faf8f5);
}

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

.cafe-pip--hidden {
  background: color-mix(in srgb, var(--kd-ink) 45%, #faf8f5);
}

.cafe-pip--rejected {
  background: var(--kd-destructive);
}

.cafe-count {
  font-variant-numeric: tabular-nums;
  font-weight: 700;
}

.cafe-identity {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
}

.cafe-identity h2 {
  min-width: 0;
}

.cafe-name {
  min-width: 0;
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

.cafe-stamp--hidden {
  background: color-mix(in srgb, var(--kd-ink) 10%, #faf8f5);
  color: color-mix(in srgb, var(--kd-ink) 78%, #faf8f5);
}

.cafe-stamp--hidden .cafe-stamp__mark {
  background: color-mix(in srgb, var(--kd-ink) 45%, #faf8f5);
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

  .cafe-stamp-pad :deep(.admin-btn) {
    flex: 1 1 0;
  }
}

@media (prefers-reduced-motion: reduce) {
  .cafe-edit:active,
  .cafe-warn:active:not(:disabled),
  .cafe-page:active:not(:disabled),
  .cafe-stamp-pad :deep(.admin-btn) {
    transform: none;
  }
}

.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
</style>
