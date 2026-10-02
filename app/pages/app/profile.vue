<template>
  <IonPage>
    <IonContent class="profile-content">
      <div class="profile">
        <header class="profile__hero">
          <img
            src="/assets/bean-pin.png"
            alt=""
            width="40"
            height="48"
          />
          <h1>{{ signedIn ? 'Your account' : 'Profile' }}</h1>
          <p v-if="!signedIn">
            Sign in to keep saved cafes, reviews, and the cafes you submit.
          </p>
        </header>

        <section class="profile__panel" aria-labelledby="nearby-radius-title">
          <h2 id="nearby-radius-title">Near You radius</h2>
          <p>Home only lists cafes within this distance of you. The default is 5 km.</p>
          <div
            class="profile__radius"
            role="radiogroup"
            aria-labelledby="nearby-radius-title"
          >
            <button
              v-for="km in radiusPresets"
              :key="km"
              type="button"
              role="radio"
              class="profile__radius-chip"
              :class="{ 'is-active': nearbyRadiusKm === km }"
              :aria-checked="nearbyRadiusKm === km"
              :aria-label="`${km} kilometers`"
              @click="setRadiusKm(km)"
            >
              {{ km }} km
            </button>
          </div>
          <button
            v-if="!previewOpen"
            type="button"
            class="profile__primary"
            :aria-expanded="false"
            @click="togglePreview"
          >
            View map
          </button>
          <div v-else id="nearby-preview" class="profile__map">
            <div class="profile__map-face">
              <div
                v-if="!previewOrigin"
                class="profile__map-empty"
                role="status"
                :aria-busy="locationStatus === 'requesting'"
              >
                <span v-if="locationStatus === 'requesting'" class="profile__map-you" aria-hidden="true">
                  <span class="profile__map-you-pulse" />
                  <span class="profile__map-you-pulse profile__map-you-pulse--late" />
                  <span class="profile__map-you-core" />
                </span>
                <span v-else class="profile__map-mark" aria-hidden="true">
                  <LocateOff :size="20" :stroke-width="2.25" />
                </span>
                <p class="profile__map-title">{{ locationTitle }}</p>
                <p class="profile__map-copy">{{ locationHelp }}</p>
                <button
                  v-if="locationStatus !== 'requesting'"
                  type="button"
                  class="profile__primary profile__map-action"
                  @click="requestLocation"
                >
                  Enable location
                </button>
              </div>
              <template v-else>
                <NearbyRadiusMap
                  v-if="!tilesFailed"
                  ref="previewMap"
                  :center="previewOrigin"
                  :accuracy="previewAccuracy"
                  :cafes="previewCafes"
                  :radius-meters="previewRadiusMeters"
                  @tiles-ready="tilesFailed = false"
                  @tiles-error="tilesFailed = true"
                />
                <div v-else class="profile__map-empty" role="alert">
                  <span class="profile__map-mark profile__map-mark--alert" aria-hidden="true">
                    <MapIcon :size="20" :stroke-width="2.25" />
                  </span>
                  <p class="profile__map-title">Map couldn’t load</p>
                  <p class="profile__map-copy">Check your connection, then try again.</p>
                  <button type="button" class="profile__primary profile__map-action" @click="retryTiles">
                    Retry map
                  </button>
                </div>
                <p
                  v-if="!tilesFailed"
                  class="profile__map-caption"
                  :aria-busy="previewStatus === 'loading' || previewStatus === 'idle'"
                >
                  <template v-if="previewStatus === 'error'">
                    {{ previewError || 'Could not load cafes near you.' }}
                    <button type="button" class="profile__text" @click="loadPreviewCafes">Try again</button>
                  </template>
                  <template v-else-if="previewStatus === 'loading' || previewStatus === 'idle'">
                    Loading cafes near you…
                  </template>
                  <template v-else>
                    {{ previewCountLabel }}
                  </template>
                </p>
              </template>
            </div>
            <button
              type="button"
              class="profile__map-hide"
              aria-expanded="true"
              aria-controls="nearby-preview"
              @click="togglePreview"
            >
              Hide map
            </button>
          </div>
        </section>

        <section class="profile__panel" aria-labelledby="analytics-title">
          <h2 id="analytics-title">Usage analytics</h2>
          <p>
            {{ analyticsOn
              ? 'Usage analytics is on. KapéDoko sends anonymous product events to our analytics provider (PostHog, EU). We do not send your email, precise GPS, or search text.'
              : 'Usage analytics is off. Turn it on to help us see whether Marikina cafés are easy to find. We do not send your email, precise GPS, or search text.'
            }}
          </p>
          <div class="profile__radius" role="group" aria-labelledby="analytics-title">
            <button
              type="button"
              class="profile__radius-chip"
              :class="{ 'is-active': analyticsOn }"
              @click="setAnalyticsConsent('granted')"
            >
              Allow
            </button>
            <button
              type="button"
              class="profile__radius-chip"
              :class="{ 'is-active': !analyticsOn }"
              @click="setAnalyticsConsent('declined')"
            >
              Stop
            </button>
          </div>
          <NuxtLink class="profile__text" to="/privacy">Privacy policy</NuxtLink>
        </section>

        <section v-if="!signedIn" class="profile__panel" aria-label="Account actions">
          <button type="button" class="profile__primary" @click="goLogin">Sign in</button>
          <button type="button" class="profile__outline" @click="goRegister">Create account</button>
        </section>

        <template v-else>
          <form class="profile__panel" @submit.prevent="saveName">
            <p class="profile__email">{{ email }}</p>
            <label class="profile__field" for="display-name">
              Name on reviews
              <input
                id="display-name"
                v-model="displayName"
                type="text"
                name="display-name"
                autocomplete="nickname"
                maxlength="40"
              />
            </label>
            <p v-if="nameError" class="profile__error" role="alert">{{ nameError }}</p>
            <button type="submit" class="profile__primary" :disabled="savingName">
              {{ savingName ? 'Saving…' : 'Save name' }}
            </button>
          </form>

          <section v-if="isAdmin || isAuditor" class="profile__panel" aria-label="Staff">
            <NuxtLink class="profile__primary" :to="isAdmin ? '/admin' : '/admin/audits'">
              {{ isAdmin ? 'Admin portal' : 'Cafe audits' }}
            </NuxtLink>
          </section>

          <section class="profile__submissions" aria-labelledby="owned-title">
            <h2 id="owned-title">Cafes you manage</h2>
            <p v-if="ownedStatus === 'loading'">Loading your cafes…</p>
            <p v-else-if="ownedStatus === 'error'" class="profile__error">
              {{ ownedError }}
              <button type="button" class="profile__text" @click="loadOwned">Try again</button>
            </p>
            <p v-else-if="ownedCafes.length === 0">No verified cafes yet. Claim a listing from its cafe page.</p>
            <article v-for="shop in ownedCafes" :key="shop.id" class="profile__shop">
              <h3>{{ shop.name }}</h3>
              <p>You can edit hours, contact, and the logo.</p>
              <NuxtLink class="profile__text" :to="`/app/cafes/${shop.id}/edit`">Edit listing</NuxtLink>
            </article>
          </section>

          <section class="profile__submissions" aria-labelledby="claims-title">
            <h2 id="claims-title">Ownership claims</h2>
            <p v-if="ownedStatus === 'loading'">Loading your claims…</p>
            <p v-else-if="ownedStatus === 'error'" class="profile__error">
              {{ ownedError }}
              <button type="button" class="profile__text" @click="loadOwned">Try again</button>
            </p>
            <p v-else-if="openClaims.length === 0 && isAdmin">
              You review other people’s claims in the
              <NuxtLink class="profile__text" to="/admin/claims">admin portal</NuxtLink>.
            </p>
            <p v-else-if="openClaims.length === 0">{{ profileClaimsEmptyCopy(false) }}</p>
            <article v-for="claim in openClaims" :key="claim.id" class="profile__shop">
              <h3>{{ shopNameForClaim(claim.shop_id) }}</h3>
              <p>{{ claimStatusCopy(claim.status, claim.rejection_reason) }}</p>
              <div class="profile__claim-actions">
                <NuxtLink class="profile__text" :to="`/app/cafes/${claim.shop_id}/claim`">
                  {{ claim.status === 'rejected' ? 'Send a new claim' : 'View claim' }}
                </NuxtLink>
                <button
                  v-if="canWithdrawClaim(claim.status)"
                  type="button"
                  class="profile__text"
                  :disabled="withdrawingId === claim.id"
                  :aria-label="`Withdraw claim for ${shopNameForClaim(claim.shop_id)}`"
                  @click="onWithdraw(claim.id)"
                >
                  {{ withdrawingId === claim.id ? 'Withdrawing…' : 'Withdraw claim' }}
                </button>
              </div>
              <p v-if="withdrawError && withdrawingId === claim.id" class="profile__error" role="alert">
                {{ withdrawError }}
              </p>
            </article>
          </section>

          <section class="profile__submissions" aria-labelledby="submissions-title">
            <h2 id="submissions-title">Cafes you submitted</h2>
            <p v-if="shopsStatus === 'loading'">Loading your submissions…</p>
            <p v-else-if="shopsStatus === 'error'" class="profile__error">
              {{ shopsError }}
              <button type="button" class="profile__text" @click="loadShops">Try again</button>
            </p>
            <p v-else-if="shops.length === 0">You have not submitted a cafe yet.</p>
            <article v-for="shop in shops" :key="shop.id" class="profile__shop">
              <h3>{{ shop.name }}</h3>
              <p>{{ statusCopy(shop) }}</p>
            </article>
          </section>

          <button type="button" class="profile__quiet" :disabled="signingOut" @click="onSignOut">
            {{ signingOut ? 'Signing out…' : 'Sign out' }}
          </button>
          <p v-if="signOutError" class="profile__error" role="alert">{{ signOutError }}</p>
        </template>
      </div>
    </IonContent>
    <AppTabBar active="profile" />
  </IonPage>
</template>

<script lang="ts" setup>
import { onIonViewDidEnter, onIonViewWillEnter } from '@ionic/vue'
import { LocateOff, Map as MapIcon } from 'lucide-vue-next'
import NearbyRadiusMap from '~/components/map/NearbyRadiusMap.client.vue'
import AppTabBar from '~/components/navigation/AppTabBar.vue'
import type { ShopRow } from '~/types/shop'
import { NEARBY_RADIUS_PRESETS_KM } from '~/utils/nearby-radius'
import { canWithdrawClaim, claimStatusCopy, profileClaimsEmptyCopy } from '~/utils/shop-claims'

const { user, currentUserId, loadProfile, updateDisplayName, signOut, goToLogin } = useAuth()
const { consent, setConsent: setAnalyticsConsent } = useAnalytics()
const analyticsOn = computed(() => consent.value === 'granted')
const {
  ownedShops,
  claims: ownerClaims,
  status: ownedStatus,
  error: ownedError,
  load: loadOwned,
  shopNameForClaim,
  withdrawClaim,
} = useShopOwnership()
const { radiusKm: nearbyRadiusKm, setRadiusKm } = useNearbyRadius()
const {
  open: previewOpen,
  cafes: previewCafes,
  status: previewStatus,
  error: previewError,
  tilesFailed,
  origin: previewOrigin,
  accuracy: previewAccuracy,
  radiusMeters: previewRadiusMeters,
  locationStatus,
  toggle: togglePreview,
  requestLocation,
  loadCafes: loadPreviewCafes,
} = useNearbyPreview()
const supabase = useSupabaseClient()

const radiusPresets = NEARBY_RADIUS_PRESETS_KM

const locationTitle = computed(() => {
  if (locationStatus.value === 'requesting') return 'Finding you'
  if (locationStatus.value === 'denied') return 'Location is off'
  if (locationStatus.value === 'unavailable') return 'Location isn’t available'
  return 'Turn on location'
})

const locationHelp = computed(() => {
  const km = nearbyRadiusKm.value
  if (locationStatus.value === 'requesting') return `Looking for cafes within ${km} km.`
  if (locationStatus.value === 'denied') return `Turn it on to see how many cafes sit within ${km} km.`
  if (locationStatus.value === 'unavailable') return `Allow location to pin cafes within ${km} km.`
  return `The Near You map needs your position to pin cafes within ${km} km.`
})

const previewCountLabel = computed(() => {
  const count = previewCafes.value.length
  const km = nearbyRadiusKm.value
  if (count === 0) return `No coffee shops within ${km} km.`
  return `${count} ${count === 1 ? 'shop' : 'shops'} within ${km} km.`
})

const retryTiles = () => {
  tilesFailed.value = false
}

const previewMap = ref<{ invalidate: () => void } | null>(null)

onIonViewWillEnter(() => {
  void loadOwned()
})

onIonViewDidEnter(() => {
  previewMap.value?.invalidate()
})

const displayName = ref('')
const email = ref('')
const nameError = ref('')
const savingName = ref(false)
const signingOut = ref(false)
const signOutError = ref('')
const shops = ref<Pick<ShopRow, 'id' | 'name' | 'status' | 'rejection_reason'>[]>([])
const shopsStatus = ref<'idle' | 'loading' | 'ready' | 'error'>('idle')
const shopsError = ref('')
const isAdmin = ref(false)
const isAuditor = ref(false)
const ownedCafes = computed(() => ownedShops.value)
const openClaims = computed(() => ownerClaims.value.filter((claim) => claim.status !== 'verified'))
const withdrawingId = ref<string | null>(null)
const withdrawError = ref('')

const signedIn = computed(() => Boolean(user.value))

const statusCopy = (shop: Pick<ShopRow, 'status' | 'rejection_reason'>) => {
  if (shop.status === 'approved') return 'On the map'
  if (shop.status === 'rejected') return shop.rejection_reason ? `Not listed. ${shop.rejection_reason}` : 'Not listed'
  return 'Pending review. It stays off Home and Map until an admin approves it.'
}

const loadShops = async () => {
  const userId = await currentUserId()
  if (!userId) {
    shops.value = []
    shopsStatus.value = 'ready'
    return
  }
  shopsStatus.value = 'loading'
  shopsError.value = ''
  const { data, error } = await supabase
    .from('shops')
    .select('id, name, status, rejection_reason')
    .eq('submitted_by', userId)
    .order('created_at', { ascending: false })

  if (error) {
    shopsStatus.value = 'error'
    shopsError.value = 'Could not load your submissions.'
    return
  }
  shops.value = (data ?? []) as Pick<ShopRow, 'id' | 'name' | 'status' | 'rejection_reason'>[]
  shopsStatus.value = 'ready'
}

const loadAccount = async () => {
  email.value = user.value?.email ?? ''
  if (!user.value) {
    isAdmin.value = false
    isAuditor.value = false
    return
  }
  try {
    const profile = await loadProfile()
    displayName.value = profile?.display_name || ''
    isAdmin.value = profile?.role === 'admin'
    isAuditor.value = profile?.role === 'auditor' || profile?.role === 'admin'
  } catch (err) {
    nameError.value = err instanceof Error ? err.message : 'Could not load your profile.'
  }
  await loadShops()
  await loadOwned()
}

watch(user, () => {
  void loadAccount()
}, { immediate: true })

const saveName = async () => {
  savingName.value = true
  nameError.value = ''
  try {
    await updateDisplayName(displayName.value)
  } catch (err) {
    nameError.value = err instanceof Error ? err.message : 'Could not save your name.'
  } finally {
    savingName.value = false
  }
}

const onSignOut = async () => {
  signingOut.value = true
  signOutError.value = ''
  try {
    await signOut()
    await navigateTo('/app')
  } catch (err) {
    signOutError.value = err instanceof Error ? err.message : 'Could not sign out.'
  } finally {
    signingOut.value = false
  }
}

const goLogin = () => goToLogin('/app/profile')
const goRegister = () => navigateTo({ path: '/register', query: { redirect: '/app/profile' } })

const onWithdraw = async (claimId: string) => {
  withdrawError.value = ''
  withdrawingId.value = claimId
  try {
    await withdrawClaim(claimId)
  } catch (err) {
    withdrawError.value = err instanceof Error ? err.message : 'Could not withdraw this claim.'
  } finally {
    withdrawingId.value = null
  }
}
</script>

<style scoped>
.profile-content {
  --background: #f2f2f2;
  --padding-start: 0;
  --padding-end: 0;
  --padding-top: 0;
  --padding-bottom: 0;
}

.profile {
  min-height: 100%;
  padding: max(2.75rem, calc(env(safe-area-inset-top) + 16px)) 20px calc(8.5rem + env(safe-area-inset-bottom));
  background: #f2f2f2;
  color: var(--kd-ink);
  font-family: 'Kumbh Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

.profile__hero {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 8px;
  color: var(--kd-ink);
}

.profile__hero img {
  display: block;
  width: 40px;
  height: 48px;
  object-fit: contain;
}

.profile__hero h1,
.profile__panel h2,
.profile__submissions h2,
.profile__shop h3 {
  margin: 0;
  font-weight: 700;
  line-height: 1.2;
  letter-spacing: -0.03em;
}

.profile__hero h1 {
  margin-top: 4px;
  font-size: 1.325rem;
  line-height: 1.05;
}

.profile__hero p,
.profile__email,
.profile__panel > p,
.profile__submissions > p,
.profile__shop p {
  margin: 0;
  color: var(--kd-ink);
  font-size: 0.7875rem;
  line-height: 1.3;
}

.profile__email {
  font-size: 0.85rem;
  line-height: 1.35;
}

.profile__panel,
.profile__submissions {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-top: 24px;
}

.profile__submissions {
  margin-top: 32px;
}

.profile__submissions h2,
.profile__panel h2 {
  margin-bottom: 0;
  color: var(--kd-ink);
  font-size: 0.95rem;
  letter-spacing: 0;
  line-height: 1.2;
}

.profile__radius {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.profile__radius-chip {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex: 0 0 auto;
  min-width: 44px;
  min-height: 44px;
  padding: 0 12px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 22%, transparent);
  border-radius: 16px;
  background: #faf8f5;
  color: var(--kd-ink);
  font-family: inherit;
  font-size: 0.75rem;
  font-weight: 400;
  letter-spacing: 0;
  white-space: nowrap;
  cursor: pointer;
  font-variant-numeric: tabular-nums;
  -webkit-tap-highlight-color: transparent;
}

.profile__radius-chip.is-active {
  background: var(--kd-accent);
  color: var(--kd-ink);
  border-color: var(--kd-accent);
  font-weight: 700;
}

.profile__radius-chip:active {
  box-shadow: inset 0 3px 0 color-mix(in srgb, var(--kd-ink) 22%, transparent);
}

.profile__radius-chip:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.profile__map {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.profile__map-face {
  position: relative;
  overflow: hidden;
  min-height: 220px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 22%, transparent);
  border-radius: 16px;
  background: #faf8f5;
}

.profile__map-empty {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: center;
  gap: 8px;
  min-height: 220px;
  padding: 24px 20px 20px;
}

.profile__map-you,
.profile__map-mark {
  position: relative;
  display: grid;
  place-items: center;
  flex: 0 0 40px;
  width: 40px;
  height: 40px;
}

.profile__map-mark {
  border-radius: 8px;
  background: #f2f2f2;
  color: var(--kd-ink);
}

.profile__map-mark--alert {
  background: color-mix(in srgb, #8c3a2f 16%, #faf8f5);
  color: #8c3a2f;
}

.profile__map-you-core {
  width: 14px;
  height: 14px;
  border-radius: 16px;
  background: var(--kd-accent);
  border: 2px solid #faf8f5;
  z-index: 1;
}

.profile__map-you-pulse {
  position: absolute;
  width: 14px;
  height: 14px;
  border-radius: 16px;
  border: 1.5px solid var(--kd-primary);
  background: color-mix(in srgb, var(--kd-accent) 18%, transparent);
  animation: profile-map-ping 1.8s cubic-bezier(0.16, 1, 0.3, 1) infinite;
}

.profile__map-you-pulse--late {
  animation-delay: 0.55s;
}

.profile__map-title,
.profile__map-copy {
  margin: 0;
  max-width: 28ch;
}

.profile__map-title {
  margin-top: 4px;
  font-size: 0.95rem;
  font-weight: 700;
  line-height: 1.2;
  letter-spacing: -0.03em;
}

.profile__map-copy {
  color: color-mix(in srgb, var(--kd-ink) 78%, #faf8f5);
  font-size: 0.7875rem;
  line-height: 1.3;
}

.profile__map-action {
  width: auto;
  margin-top: 8px;
  align-self: stretch;
}

.profile__map-caption {
  margin: 0;
  padding: 10px 14px 12px;
  border-top: 1px solid color-mix(in srgb, var(--kd-ink) 16%, transparent);
  background: #faf8f5;
  color: var(--kd-ink);
  font-size: 0.75rem;
  font-weight: 700;
  line-height: 1.3;
}

.profile__map-hide {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  padding: 0 16px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 22%, transparent);
  border-radius: 16px;
  background: transparent;
  color: var(--kd-ink);
  font-family: inherit;
  font-size: 0.95rem;
  font-weight: 400;
  line-height: 1.2;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.profile__map-hide:active {
  box-shadow: inset 0 3px 0 color-mix(in srgb, var(--kd-ink) 22%, transparent);
}

.profile__map-hide:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
}

.profile__shop {
  padding: 12px 16px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 22%, transparent);
  border-radius: 16px;
  background: #faf8f5;
}

.profile__shop h3 {
  color: var(--kd-ink);
  font-size: 0.95rem;
  letter-spacing: 0;
  line-height: 1.2;
}

.profile__shop p {
  margin-top: 4px;
  color: color-mix(in srgb, var(--kd-ink) 72%, transparent);
}

.profile__claim-actions {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px 16px;
  margin-top: 8px;
}

.profile__claim-actions .profile__text {
  margin-left: 0;
  min-height: 44px;
  display: inline-flex;
  align-items: center;
}

.profile__field {
  display: flex;
  flex-direction: column;
  gap: 6px;
  color: var(--kd-ink);
  font-size: 0.75rem;
  font-weight: 700;
  line-height: 1.3;
}

.profile__field input {
  min-height: 44px;
  height: 44px;
  padding: 0 16px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 22%, transparent);
  border-radius: 16px;
  background: #faf8f5;
  color: var(--kd-ink);
  font-size: 1rem;
  font-weight: 400;
  font-family: inherit;
  caret-color: var(--kd-primary);
}

.profile__field input::placeholder {
  color: color-mix(in srgb, var(--kd-ink) 45%, transparent);
}

.profile__field input:focus {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.profile__primary,
.profile__outline,
.profile__quiet,
.profile__text {
  font-family: inherit;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  text-decoration: none;
}

.profile__primary,
.profile__outline,
.profile__quiet {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  padding: 0 16px;
  border-radius: 16px;
  font-size: 0.95rem;
  font-weight: 700;
  line-height: 1.2;
}

.profile__primary {
  border: 1px solid var(--kd-accent);
  background: var(--kd-accent);
  color: var(--kd-ink);
  transition: box-shadow 160ms ease,
    transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.profile__primary:hover:not(:disabled) {
  box-shadow: inset 0 3px 0 color-mix(in srgb, var(--kd-ink) 22%, transparent);
}

.profile__primary:active:not(:disabled) {
  box-shadow: inset 0 3px 0 color-mix(in srgb, var(--kd-ink) 22%, transparent);
  transform: scale(0.94);
}

.profile__outline {
  border: 1px solid var(--kd-primary);
  background: transparent;
  color: var(--kd-primary);
}

.profile__quiet {
  margin-top: 20px;
  border: 1px solid color-mix(in srgb, var(--kd-ink) 22%, transparent);
  background: transparent;
  color: var(--kd-ink);
  font-weight: 400;
}

.profile__text {
  display: inline;
  margin-left: 8px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-primary);
  font-size: 0.7875rem;
  font-weight: 700;
}

.profile__primary:disabled,
.profile__outline:disabled,
.profile__quiet:disabled,
.profile__text:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.profile__primary:focus-visible,
.profile__outline:focus-visible,
.profile__quiet:focus-visible,
.profile__text:focus-visible,
.profile__map-hide:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
}

.profile__error {
  margin: 0;
  color: var(--kd-destructive);
  font-size: 0.7875rem;
  font-weight: 700;
  line-height: 1.35;
}

@media (min-width: 540px) {
  .profile {
    max-width: 480px;
    margin-inline: auto;
  }
}

@media (prefers-reduced-motion: reduce) {
  .profile__primary,
  .profile__radius-chip,
  .profile__map-hide {
    transition-duration: 1ms;
  }

  .profile__primary:active:not(:disabled),
  .profile__radius-chip:active,
  .profile__map-hide:active {
    transform: none;
    box-shadow: none;
  }

  .profile__map-you-pulse,
  .profile__map-you-pulse--late {
    animation: none;
  }
}

:root.is-android .profile__primary,
:root.is-android .profile__outline,
:root.is-android .profile__quiet,
:root.is-android .profile__radius-chip,
:root.is-android .profile__map-hide,
:root.is-android .profile__map-action {
  min-height: 48px;
}

@keyframes profile-map-ping {
  0% {
    transform: scale(1);
    opacity: 0.55;
  }
  70% {
    transform: scale(2.8);
    opacity: 0;
  }
  100% {
    transform: scale(2.8);
    opacity: 0;
  }
}

::selection {
  background: var(--kd-accent);
  color: var(--kd-ink);
}
</style>
