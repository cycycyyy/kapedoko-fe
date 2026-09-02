<template>
  <div class="flex flex-col items-center justify-center min-h-screen bg-background">
    <div class="w-full max-w-md p-6 rounded-lg shadow-md bg-secondary">
      <h1 class="text-2xl font-bold text-center mb-6 text-foreground">Login</h1>
      
      <form @submit.prevent="handleLogin" class="space-y-4">
        <div>
          <label for="email" class="block text-sm font-medium text-foreground mb-1">Email</label>
          <input
            id="email"
            v-model="email"
            type="email"
            class="w-full px-3 py-2 border border-gray rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
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
            class="w-full px-3 py-2 border border-gray rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
            placeholder="••••••••"
            required
          />
        </div>
        
        <div class="pt-4">
          <button
            type="submit"
            class="w-full py-2 px-4 bg-primary hover:bg-primary/90 text-primary-foreground font-medium rounded-md transition-colors"
          >
            Sign In
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

const email = ref('');
const password = ref('');

const handleLogin = () => {
  // TODO: Implement actual login logic
  console.log('Login attempt with:', { email: email.value, password: password.value });
  // Redirect to dashboard or home after successful login
  // await navigateTo('/dashboard');
};
</script>