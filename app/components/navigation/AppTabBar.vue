<template>
  <nav class="app-tabbar" aria-label="Primary">
    <span
      class="app-tabbar__mark"
      aria-hidden="true"
      :style="{ '--tab-index': String(activeIndex) }"
    />
    <button
      v-for="tab in tabs"
      :key="tab.id"
      type="button"
      class="app-tabbar__item"
      :class="{ 'is-active': active === tab.id }"
      :aria-current="active === tab.id ? 'page' : undefined"
      :aria-label="tab.aria"
      @click="go(tab.path)"
    >
      <component
        :is="tab.icon"
        class="app-tabbar__icon"
        :size="18"
        :stroke-width="2.25"
        aria-hidden="true"
      />
      <span class="app-tabbar__label">{{ tab.label }}</span>
    </button>
  </nav>
</template>

<script lang="ts" setup>
import { Heart, House, Map as MapIcon, User } from 'lucide-vue-next'

type TabId = 'home' | 'saved' | 'map' | 'profile'

const props = defineProps<{
  active?: TabId
}>()

const route = useRoute()

const tabs: {
  id: TabId
  label: string
  aria: string
  path: string
  icon: typeof House
}[] = [
  { id: 'home', label: 'Home', aria: 'Home', path: '/app', icon: House },
  { id: 'saved', label: 'Saved', aria: 'Saved cafes', path: '/app/favorites', icon: Heart },
  { id: 'map', label: 'Map', aria: 'Map', path: '/app/map', icon: MapIcon },
  { id: 'profile', label: 'Profile', aria: 'Profile', path: '/app/profile', icon: User },
]

const active = computed<TabId>(() => {
  if (props.active) return props.active
  if (route.path.includes('/map')) return 'map'
  if (route.path.includes('/favorites')) return 'saved'
  if (route.path.includes('/profile')) return 'profile'
  return 'home'
})

const activeIndex = computed(() => {
  const index = tabs.findIndex((tab) => tab.id === active.value)
  return index >= 0 ? index : 0
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
  z-index: 30;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  align-items: stretch;
  width: 100%;
  height: calc(72px + env(safe-area-inset-bottom));
  padding: 0 8px env(safe-area-inset-bottom);
  background-color: #f2f2f2;
  border-top: 1px solid color-mix(in srgb, var(--kd-ink) 16%, transparent);
}

.app-tabbar__mark {
  position: absolute;
  top: 6px;
  left: 8px;
  z-index: 1;
  width: calc((100% - 16px) / 4);
  height: 2px;
  background-color: var(--kd-accent);
  border-radius: 1px;
  transform: translateX(calc(var(--tab-index, 0) * 100%));
  transition: transform 220ms cubic-bezier(0.16, 1, 0.3, 1);
  pointer-events: none;
}

.app-tabbar__item {
  position: relative;
  z-index: 2;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  min-width: 48px;
  min-height: 44px;
  border: 0;
  background: transparent;
  color: var(--kd-ink);
  cursor: pointer;
  transition:
    color 160ms cubic-bezier(0.16, 1, 0.3, 1),
    transform 120ms cubic-bezier(0.16, 1, 0.3, 1),
    box-shadow 120ms cubic-bezier(0.16, 1, 0.3, 1);
}

.app-tabbar__icon {
  display: block;
  flex-shrink: 0;
}

.app-tabbar__label {
  font-size: 0.6875rem;
  font-weight: 400;
  line-height: 1;
}

.app-tabbar__item.is-active {
  color: var(--kd-primary);
}

.app-tabbar__item.is-active .app-tabbar__label {
  font-weight: 700;
}

.app-tabbar__item:active {
  transform: translateY(1px) scaleY(0.94);
  box-shadow: inset 0 3px 0 color-mix(in srgb, var(--kd-accent) 22%, transparent);
}

.app-tabbar__item:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: -4px;
}

@media (min-width: 540px) {
  .app-tabbar {
    left: 50%;
    right: auto;
    width: min(480px, 100%);
    transform: translateX(-50%);
  }
}

@media (prefers-reduced-motion: reduce) {
  .app-tabbar__mark {
    transition: none;
  }

  .app-tabbar__item {
    transition: none;
  }

  .app-tabbar__item:active {
    transform: none;
    box-shadow: none;
  }
}
</style>
