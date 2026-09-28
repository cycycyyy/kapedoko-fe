<template>
  <AuthShell
    title="Confirming your email"
    lede="This only takes a moment."
  >
    <p v-if="status === 'checking'" class="auth-note" role="status">Checking your sign-in link…</p>
    <template v-else>
      <p class="auth-error" role="alert">This link expired or was already used.</p>
      <div class="auth-links">
        <NuxtLink to="/login">Back to sign in</NuxtLink>
        <NuxtLink to="/app">Continue without an account</NuxtLink>
      </div>
    </template>
  </AuthShell>
</template>

<script setup lang="ts">
import AuthShell from '~/components/auth/AuthShell.vue'
import { safeRedirectPath } from '~/utils/auth'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const route = useRoute()
const status = ref<'checking' | 'expired'>('checking')

const leave = async () => {
  const requested = Array.isArray(route.query.redirect) ? route.query.redirect[0] : route.query.redirect
  await navigateTo(safeRedirectPath(requested))
}

watch(user, (next) => {
  if (next) void leave()
}, { immediate: true })

onMounted(() => {
  void supabase.auth.getSession().then(({ data }) => {
    if (data.session) void leave()
  })
  window.setTimeout(() => {
    if (status.value === 'checking' && !user.value) status.value = 'expired'
  }, 5000)
})
</script>
