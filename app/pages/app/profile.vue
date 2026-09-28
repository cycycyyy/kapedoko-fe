<template>
  <IonPage>
    <IonContent class="profile-content">
      <div class="profile">
        <header class="profile__hero">
          <img
            src="/assets/kapedoko-logo_dark.png"
            alt=""
            width="46"
            height="60"
          />
          <h1>{{ signedIn ? 'Your account' : 'Profile' }}</h1>
          <p v-if="!signedIn">
            Sign in to keep saved cafes, reviews, and the cafes you submit.
          </p>
        </header>

        <section v-if="!signedIn" class="profile__panel" aria-label="Account actions">
          <button type="button" class="profile__primary" @click="goLogin">Sign in</button>
          <button type="button" class="profile__secondary" @click="goRegister">Create account</button>
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

          <button type="button" class="profile__secondary" :disabled="signingOut" @click="onSignOut">
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
  --background: var(--kd-white);
  --padding-start: 0;
  --padding-end: 0;
  --padding-top: 0;
  --padding-bottom: 0;
}

.profile {
  min-height: 100%;
  padding: max(2.75rem, calc(env(safe-area-inset-top) + 16px)) 20px calc(8.5rem + env(safe-area-inset-bottom));
  background: var(--kd-white);
}

.profile__hero {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 8px;
  color: var(--kd-primary);
}

.profile__hero img {
  display: block;
  width: 46px;
  height: 60px;
  object-fit: contain;
}

.profile__hero h1,
.profile__submissions h2,
.profile__shop h3 {
  margin: 0;
  font-weight: 700;
  line-height: 1.2;
}

.profile__hero h1 {
  margin-top: 8px;
  font-size: 24px;
}

.profile__hero p,
.profile__email,
.profile__submissions p,
.profile__shop p {
  margin: 0;
  color: var(--kd-ink);
  font-size: 14px;
  line-height: 1.45;
}

.profile__panel,
.profile__submissions {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-top: 24px;
}

.profile__submissions h2 {
  color: var(--kd-primary);
  font-size: 20px;
}

.profile__shop {
  padding-top: 12px;
  border-top: 1px solid var(--kd-ink-10);
}

.profile__shop h3 {
  color: var(--kd-primary);
  font-size: 16px;
}

.profile__field {
  display: flex;
  flex-direction: column;
  gap: 6px;
  color: var(--kd-primary);
  font-size: 12px;
  font-weight: 700;
}

.profile__field input {
  height: 50px;
  padding: 0 16px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-secondary);
  color: var(--kd-ink);
  font-size: 16px;
  font-weight: 400;
  font-family: inherit;
  caret-color: var(--kd-primary);
}

.profile__field input:focus {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.profile__primary,
.profile__secondary,
.profile__text {
  font-family: inherit;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.profile__primary,
.profile__secondary {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 45px;
  padding: 0 20px;
  border-radius: 8px;
  border: 0;
  font-size: 16px;
  font-weight: 700;
}

.profile__primary {
  background: var(--kd-primary);
  color: var(--kd-white);
}

.profile__secondary {
  margin-top: 12px;
  background: var(--kd-white);
  color: var(--kd-primary);
  box-shadow: inset 0 0 0 1.5px var(--kd-primary);
}

.profile__text {
  display: inline;
  margin-left: 8px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-primary);
  font-size: 14px;
  font-weight: 700;
}

.profile__primary:disabled,
.profile__secondary:disabled {
  opacity: 0.55;
}

.profile__primary:focus-visible,
.profile__secondary:focus-visible,
.profile__text:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
}

.profile__error {
  color: var(--kd-closed);
  font-weight: 700;
}

@media (min-width: 540px) {
  .profile {
    max-width: 480px;
    margin-inline: auto;
  }
}

:root.is-android .profile__primary,
:root.is-android .profile__secondary {
  min-height: 48px;
}
</style>
