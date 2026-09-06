<template>
  <div class="loading-container">
    <div class="loading-content">
      <img
        :src="logo"
        alt="KapeDoko Logo"
        class="logo"
        width="140"
        height="97"
      />

      <!-- Animated Dots -->
      <div class="dots-container">
        <div class="dot"></div>
        <div class="dot"></div>
        <div class="dot"></div>
        <div class="dot"></div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import logo from '~/assets/css/logos/kapedoko-logo-typography.svg'
</script>

<style scoped>
.loading-container {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  min-height: 100dvh;
  height: 100dvh;
  background-color: var(--kd-white); /* White background as per design */
}

.loading-content {
  text-align: center;
}

.logo {
  margin: 0 auto 2rem; /* Space below the logo */
  display: block;
}

.dots-container {
  display: flex;
  justify-content: center;
  gap: 0.5rem; /* Space between dots */
}

.dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background-color: var(--kd-primary); /* Dark brown color */
  animation: pulse 1.5s infinite ease-in-out;
}

.dot:nth-child(2) {
  animation-delay: 0.2s;
}

.dot:nth-child(3) {
  animation-delay: 0.4s;
}

.dot:nth-child(4) {
  animation-delay: 0.6s;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.5;
    transform: scale(0.85);
  }
}
</style>