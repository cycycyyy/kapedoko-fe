<template>
  <div class="flex flex-col items-center justify-center min-h-screen bg-background">
    <div class="w-full max-w-md p-6 rounded-lg shadow-md bg-secondary">
      <h1 class="text-2xl font-bold text-center mb-6 text-foreground">Login</h1>
      
      <div v-if="error" class="mb-4 p-3 bg-red-100 text-red-700 rounded-md">
        {{ error }}
      </div>

      <form @submit.prevent="handleLogin" class="space-y-4">
        <div>
          <label for="email" class="block text-sm font-medium text-foreground mb-1">Email</label>
          <input
            id="email"
            v-model="email"
            type="email"
            class="form-input"
            placeholder="your@email.com"
            required
          />
        </div>
        
        <div>
          <label for="password" class="block text-sm font-medium text-foreground mb-1">Password</label>
          <input
            id="password"
            v-model="password"
            type="password"
            class="form-input"
            placeholder="••••••••"
            required
          />
        </div>
        
        <div class="pt-4">
          <button
            type="submit"
            :disabled="loading"
            class="w-full py-2 px-4 bg-primary hover:bg-primary/90 text-primary-foreground font-medium rounded-md transition-colors disabled:opacity-50"
          >
            {{ loading ? 'Signing In...' : 'Sign In' }}
          </button>
        </div>
      </form>
      
      <div class="mt-4 text-center">
        <p class="text-sm text-foreground">
          Don't have an account? 
          <NuxtLink to="/register" class="text-primary hover:underline">
            Register
          </NuxtLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'default' // Using default layout
});

const supabase = useSupabaseClient();

const email = ref('');
const password = ref('');
const loading = ref(false);
const error = ref('');

const handleLogin = async () => {
  loading.value = true;
  error.value = '';

  try {
    const { error: signInError } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    });

    if (signInError) {
      error.value = signInError.message;
      return;
    }

    await navigateTo('/app');
  } catch (err: unknown) {
    error.value = err instanceof Error ? err.message : 'Unable to sign in.';
  } finally {
    loading.value = false;
  }
};
</script>