<template>
  <AuthShell
    title="Choose a new password"
    lede="Use at least 8 characters. This replaces the password on your account."
  >
    <p v-if="status === 'checking'" class="auth-note">Checking your reset link…</p>
    <template v-else-if="status === 'ready'">
      <p v-if="error" class="auth-error" role="alert">{{ error }}</p>
      <form class="auth-form" @submit.prevent="onSubmit">
        <label class="auth-field" for="password">
          New password
          <input
            id="password"
            v-model="password"
            type="password"
            name="password"
            autocomplete="new-password"
            placeholder="At least 8 characters"
            minlength="8"
            required
          />
        </label>
        <button type="submit" class="auth-submit" :disabled="loading">
          {{ loading ? 'Saving…' : 'Save password' }}
        </button>
      </form>
    </template>
    <template v-else>
      <p class="auth-error" role="alert">This reset link expired or was already used.</p>
      <div class="auth-links">
        <NuxtLink to="/forgot-password">Request a new link</NuxtLink>
        <NuxtLink to="/login">Back to sign in</NuxtLink>
      </div>
    </template>
  </AuthShell>
</template>

<script setup lang="ts">
import AuthShell from '~/components/auth/AuthShell.vue'

const supabase = useSupabaseClient()
const { updatePassword } = useAuth()
const password = ref('')
const loading = ref(false)
const error = ref('')
const status = ref<'checking' | 'ready' | 'expired'>('checking')

let expiredTimer: ReturnType<typeof window.setTimeout> | null = null

const markReady = () => {
  status.value = 'ready'
  if (expiredTimer) window.clearTimeout(expiredTimer)
}

onMounted(() => {
  void supabase.auth.getSession().then(({ data }) => {
    if (data.session) markReady()
  })
  supabase.auth.onAuthStateChange((event, session) => {
    if ((event === 'PASSWORD_RECOVERY' || event === 'SIGNED_IN') && session) markReady()
  })
  expiredTimer = window.setTimeout(() => {
    if (status.value === 'checking') status.value = 'expired'
  }, 5000)
})

onBeforeUnmount(() => {
  if (expiredTimer) window.clearTimeout(expiredTimer)
})

const onSubmit = async () => {
  if (loading.value) return
  loading.value = true
  error.value = ''
  try {
    await updatePassword(password.value)
    await navigateTo('/app/profile')
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Could not save that password.'
  } finally {
    loading.value = false
  }
}
</script>
