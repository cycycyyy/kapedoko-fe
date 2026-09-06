<template>
  <div class="flex flex-col items-center justify-center min-h-screen bg-background">
    <div class="w-full max-w-md p-6 rounded-lg shadow-md bg-secondary">
      <h1 class="text-2xl font-bold text-center mb-6 text-foreground">Create Account</h1>
      
      <form @submit.prevent="handleRegister" class="space-y-4">
        <div>
          <label for="name" class="block text-sm font-medium text-foreground mb-1">Full Name</label>
          <input
            id="name"
            v-model="name"
            type="text"
            class="form-input"
            placeholder="John Doe"
            required
          />
        </div>
        
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
            class="w-full py-2 px-4 bg-primary hover:bg-primary/90 text-primary-foreground font-medium rounded-md transition-colors"
          >
            Create Account
          </button>
        </div>
      </form>
      
      <div class="mt-4 text-center">
        <p class="text-sm text-foreground">
          Already have an account? 
          <NuxtLink to="/login" class="text-primary hover:underline">
            Login
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

const name = ref('');
const email = ref('');
const password = ref('');

const handleRegister = () => {
  // TODO: Implement actual registration logic
  console.log('Registration attempt with:', { name: name.value, email: email.value, password: password.value });
  // Redirect to dashboard or home after successful registration
  // await navigateTo('/dashboard');
};
</script>