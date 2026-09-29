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
import AppTabBar from '~/components/navigation/AppTabBar.vue'
import type { ShopRow } from '~/types/shop'

const { user, currentUserId, loadProfile, updateDisplayName, signOut, goToLogin } = useAuth()
const supabase = useSupabaseClient()

const displayName = ref('')
const email = ref('')
const nameError = ref('')
const savingName = ref(false)
const signingOut = ref(false)
const signOutError = ref('')
const shops = ref<Pick<ShopRow, 'id' | 'name' | 'status' | 'rejection_reason'>[]>([])
const shopsStatus = ref<'idle' | 'loading' | 'ready' | 'error'>('idle')
const shopsError = ref('')

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
  if (!user.value) return
  try {
    const profile = await loadProfile()
    displayName.value = profile?.display_name || ''
  } catch (err) {
    nameError.value = err instanceof Error ? err.message : 'Could not load your profile.'
  }
  await loadShops()
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

.profile__submissions h2 {
  margin-bottom: 0;
  color: var(--kd-ink);
  font-size: 0.95rem;
  letter-spacing: 0;
  line-height: 1.2;
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
.profile__quiet:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.profile__primary:focus-visible,
.profile__outline:focus-visible,
.profile__quiet:focus-visible,
.profile__text:focus-visible {
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
  .profile__primary {
    transition-duration: 1ms;
  }

  .profile__primary:active:not(:disabled) {
    transform: none;
  }
}

:root.is-android .profile__primary,
:root.is-android .profile__outline,
:root.is-android .profile__quiet {
  min-height: 48px;
}

::selection {
  background: var(--kd-accent);
  color: var(--kd-ink);
}
</style>
