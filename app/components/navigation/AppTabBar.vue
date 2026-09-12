<template>
  <nav class="app-tabbar" aria-label="Primary">
    <button
      type="button"
      class="app-tabbar__item"
      :class="{ 'is-active': active === 'home' }"
      :aria-current="active === 'home' ? 'page' : undefined"
      aria-label="Home"
      @click="go('/app')"
    >
      <span v-if="active === 'home'" class="app-tabbar__icon">
        <House :size="18" :stroke-width="2" />
      </span>
      <House v-else :size="24" :stroke-width="2" />
    </button>
    <button
      type="button"
      class="app-tabbar__item"
      :class="{ 'is-active': active === 'saved' }"
      :aria-current="active === 'saved' ? 'page' : undefined"
      aria-label="Saved cafes"
      @click="go('/app/favorites')"
    >
      <span v-if="active === 'saved'" class="app-tabbar__icon">
        <Heart :size="18" :stroke-width="2" />
      </span>
      <Heart v-else :size="24" :stroke-width="2" />
    </button>
    <button
      type="button"
      class="app-tabbar__item"
      :class="{ 'is-active': active === 'map' }"
      :aria-current="active === 'map' ? 'page' : undefined"
      aria-label="Map"
      @click="go('/app/map')"
    >
      <span v-if="active === 'map'" class="app-tabbar__icon">
        <MapIcon :size="18" :stroke-width="2" />
      </span>
      <MapIcon v-else :size="24" :stroke-width="2" />
    </button>
    <button
      type="button"
      class="app-tabbar__item"
      :class="{ 'is-active': active === 'profile' }"
      aria-label="Profile"
    >
      <UserRoundPen :size="24" :stroke-width="2" />
    </button>
  </nav>
</template>

<script lang="ts" setup>
import { Heart, House, Map as MapIcon, UserRoundPen } from 'lucide-vue-next'

type TabId = 'home' | 'saved' | 'map' | 'profile'

const props = defineProps<{
  active?: TabId
}>()

const route = useRoute()

const active = computed<TabId>(() => {
  if (props.active) return props.active
  if (route.path.includes('/map')) return 'map'
  if (route.path.includes('/favorites')) return 'saved'
  return 'home'
})

const go = async (path: string) => {
  if (route.path === path) return
  await navigateTo(path)
}
</script>

<style scoped>
.app-tabbar {
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 10;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  align-items: center;
  width: 100%;
  height: calc(100px + env(safe-area-inset-bottom));
  padding: 0 12px env(safe-area-inset-bottom);
  background: var(--kd-white-80);
  backdrop-filter: blur(4px);
}

.app-tabbar__item {
  display: grid;
  place-items: center;
  min-width: 48px;
  height: 48px;
  margin-inline: auto;
  border: 0;
  background: transparent;
  color: var(--kd-primary-25);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: color 180ms cubic-bezier(0.16, 1, 0.3, 1),
    transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.app-tabbar__item.is-active {
  color: var(--kd-white);
}

.app-tabbar__icon {
  position: relative;
  display: grid;
  place-items: center;
  width: 30px;
  height: 30px;
  border-radius: 5px;
  background: var(--kd-primary);
}

.app-tabbar__icon::after {
  content: '';
  position: absolute;
  left: 0;
  bottom: -18px;
  width: 30px;
  height: 5px;
  border-radius: 5px;
  background: var(--kd-primary);
}

.app-tabbar__item:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
  border-radius: 8px;
}

.app-tabbar__item:active {
  transform: scale(0.94);
}

@media (min-width: 540px) {
  .app-tabbar {
    max-width: 480px;
    margin-inline: auto;
  }
}

@media (prefers-reduced-motion: reduce) {
  .app-tabbar__item {
    transition-duration: 1ms;
  }

  .app-tabbar__item:active {
    transform: none;
  }
}
</style>
