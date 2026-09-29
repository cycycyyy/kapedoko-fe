<template>
  <IonPage>
    <AdminShell
      title="Ads"
      lede="Upload a wide banner, set a window, and send taps to an approved cafe. Home falls back to partner pins if nothing is live."
      :status="status"
      :error="error"
    >
      <form class="admin-panel admin-form" @submit.prevent="onSave">
        <label class="admin-field">
          Cafe
          <select v-model="draft.shopId" required>
            <option value="" disabled>Choose an approved cafe</option>
            <option v-for="shop in approved" :key="shop.id" :value="shop.id">{{ shop.name }}</option>
          </select>
        </label>
        <label class="admin-field">
          Internal label
          <input v-model="draft.label" maxlength="80" placeholder="Optional" />
        </label>
        <label class="admin-field">
          Starts
          <input v-model="draft.startsAt" type="datetime-local" required />
        </label>
        <label class="admin-field">
          Ends
          <input v-model="draft.endsAt" type="datetime-local" required />
        </label>
        <label class="admin-field">
          Priority
          <input v-model.number="draft.priority" type="number" min="0" max="100" />
        </label>
        <label class="admin-field">
          Banner
          <input type="file" accept="image/jpeg,image/png,image/webp" @change="onFile" />
        </label>
        <p v-if="preview" class="admin-span">
          <img :src="preview" alt="Banner preview" width="640" height="200" class="ad-preview" />
        </p>
        <div class="admin-span admin-row-actions">
          <p v-if="formError" class="admin-error">{{ formError }}</p>
          <button class="admin-btn" type="submit" :disabled="saving">Schedule banner</button>
        </div>
      </form>

      <div class="admin-table-wrap">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Cafe</th>
              <th>Window</th>
              <th>State</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="ad in ads" :key="ad.id">
              <td>{{ shopName(ad.shop_id) }}</td>
              <td>{{ formatAdminDate(ad.starts_at) }} – {{ formatAdminDate(ad.ends_at) }}</td>
              <td>{{ adState(ad) }}</td>
              <td>
                <button
                  v-if="ad.enabled && !ad.cancelled_at"
                  type="button"
                  class="admin-btn admin-btn--ghost"
                  @click="cancelAd(ad.id)"
                >
                  End now
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="admin-cards">
        <article v-for="ad in ads" :key="ad.id" class="admin-card">
          <h2>{{ shopName(ad.shop_id) }}</h2>
          <p>{{ formatAdminDate(ad.starts_at) }} – {{ formatAdminDate(ad.ends_at) }}</p>
          <p>{{ adState(ad) }}</p>
          <button
            v-if="ad.enabled && !ad.cancelled_at"
            type="button"
            class="admin-btn admin-btn--ghost"
            @click="cancelAd(ad.id)"
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
import type { AdCampaignRow } from '~/types/admin'
import { bannerAspectError, bannerFileError, campaignWindowError, isAdCampaignActive } from '~/utils/admin-ads'
import { formatAdminDate, toLocalInput } from '~/utils/admin-nav'

definePageMeta({
  middleware: ['auth', 'admin'],
})

const admin = useAdminData()
const { shops, ads, status, error, load, saveAd, cancelAd } = admin
const now = new Date()
const later = new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000)
const draft = reactive({
  shopId: '',
  label: '',
  startsAt: toLocalInput(now),
  endsAt: toLocalInput(later),
  priority: 0,
  file: null as File | null,
})
const preview = ref('')
const formError = ref('')
const saving = ref(false)
const approved = computed(() => shops.value.filter((shop) => shop.status === 'approved'))
const shopName = (id: string) => shops.value.find((shop) => shop.id === id)?.name ?? id

const adState = (ad: AdCampaignRow) => {
  if (ad.cancelled_at || !ad.enabled) return 'ended'
  if (isAdCampaignActive(ad)) return 'live'
  if (new Date(ad.starts_at).getTime() > Date.now()) return 'scheduled'
  return 'ended'
}

const onFile = async (event: Event) => {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0] ?? null
  formError.value = bannerFileError(file)
  draft.file = formError.value ? null : file
  if (preview.value) URL.revokeObjectURL(preview.value)
  preview.value = file ? URL.createObjectURL(file) : ''
  if (file && !formError.value) {
    const image = new Image()
    image.src = preview.value
    await new Promise((resolve) => {
      image.onload = resolve
      image.onerror = resolve
    })
    formError.value = bannerAspectError(image.naturalWidth, image.naturalHeight) ?? ''
    if (formError.value) draft.file = null
  }
}

const onSave = async () => {
  formError.value = campaignWindowError(draft.startsAt, draft.endsAt) ?? bannerFileError(draft.file) ?? ''
  if (formError.value) return
  saving.value = true
  try {
    await saveAd({
      shop_id: draft.shopId,
      bannerFile: draft.file,
      starts_at: draft.startsAt,
      ends_at: draft.endsAt,
      label: draft.label,
      priority: Number(draft.priority) || 0,
      enabled: true,
    })
    draft.file = null
    if (preview.value) URL.revokeObjectURL(preview.value)
    preview.value = ''
  } catch (err) {
    formError.value = err instanceof Error ? err.message : 'Could not save this ad.'
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  void load()
})
</script>

<style scoped>
.ad-preview {
  display: block;
  width: min(640px, 100%);
  height: auto;
  border-radius: 8px;
  background: var(--kd-secondary);
}
</style>
