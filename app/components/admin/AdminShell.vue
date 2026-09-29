<template>
  <IonContent class="admin-shell-content">
    <div class="admin-shell" :class="{ 'is-nav-open': navOpen }">
      <div
        v-if="navOpen"
        class="admin-shell__scrim"
        aria-hidden="true"
        @click="navOpen = false"
      />

      <aside class="admin-shell__nav" :aria-hidden="!desktop && !navOpen">
        <div class="admin-shell__brand">
          <img src="/assets/kapedoko-horizontal-text_dark.png" alt="kapé DOKO" width="132" height="28" />
          <p>Admin</p>
        </div>
        <nav aria-label="Admin">
          <NuxtLink
            v-for="item in items"
            :key="item.id"
            :to="item.href"
            class="admin-shell__link"
            :class="{ 'is-active': active === item.id }"
            @click="navOpen = false"
          >
            {{ item.label }}
            <span v-if="item.id === 'requests' && pendingCount > 0" class="admin-shell__badge">{{ pendingCount }}</span>
          </NuxtLink>
        </nav>
        <NuxtLink to="/app" class="admin-shell__back" @click="navOpen = false">Back to app</NuxtLink>
      </aside>

      <div class="admin-shell__main">
        <header class="admin-shell__top">
          <button
            type="button"
            class="admin-shell__menu"
            aria-label="Open admin navigation"
            @click="navOpen = true"
          >
            Menu
          </button>
          <div class="admin-shell__heading">
            <h1>{{ title }}</h1>
            <p v-if="lede">{{ lede }}</p>
          </div>
          <div v-if="$slots.actions" class="admin-shell__actions">
            <slot name="actions" />
          </div>
        </header>
        <div class="admin-shell__body">
          <p v-if="!status || status === 'idle' || status === 'loading'" class="admin-shell__state">Loading…</p>
          <p v-else-if="status === 'forbidden'" class="admin-shell__state">This portal is for admins.</p>
          <p v-else-if="status === 'error'" class="admin-shell__state admin-shell__state--error">{{ error }}</p>
          <template v-else>
            <p v-if="error" class="admin-shell__state admin-shell__state--error" role="alert">{{ error }}</p>
            <slot />
          </template>
        </div>
      </div>
    </div>
  </IonContent>
</template>

<script lang="ts" setup>
import { IonContent } from '@ionic/vue'
import { ADMIN_NAV, adminNavIdFromPath } from '~/utils/admin-nav'

const props = withDefaults(defineProps<{
  title: string
  lede?: string
  status?: 'idle' | 'loading' | 'ready' | 'forbidden' | 'error'
  error?: string
  pendingCount?: number
}>(), {
  pendingCount: 0,
})

const route = useRoute()
const navOpen = ref(false)
const desktop = ref(true)
const items = ADMIN_NAV
const active = computed(() => adminNavIdFromPath(route.path))

const onResize = () => {
  desktop.value = window.innerWidth >= 1024
  if (desktop.value) navOpen.value = false
}

onMounted(() => {
  onResize()
  window.addEventListener('resize', onResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', onResize)
})
</script>

<style scoped>
.admin-shell-content {
  --background: var(--kd-enamel);
  --padding-start: 0;
  --padding-end: 0;
  --padding-top: 0;
  --padding-bottom: 0;
}

.admin-shell {
  display: grid;
  min-height: 100%;
  background: var(--kd-enamel);
  color: var(--kd-ink);
}

.admin-shell__scrim {
  display: none;
}

.admin-shell__nav {
  display: none;
  flex-direction: column;
  gap: 18px;
  padding: 24px 18px;
  background: var(--kd-white);
  border-right: 1px solid var(--kd-ink-10);
}

.admin-shell__brand {
  display: grid;
  gap: 4px;
}

.admin-shell__brand img {
  display: block;
  width: 132px;
  height: auto;
}

.admin-shell__brand p,
.admin-shell__back {
  margin: 0;
  color: var(--kd-ink-50);
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.admin-shell__nav nav {
  display: grid;
  gap: 4px;
}

.admin-shell__link,
.admin-shell__back,
.admin-shell__menu,
.admin-btn,
.admin-chip {
  font-family: inherit;
}

.admin-shell__link {
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 40px;
  padding: 0 12px;
  border-radius: 8px;
  color: var(--kd-ink);
  font-size: 14px;
  font-weight: 600;
  text-decoration: none;
}

.admin-shell__link.is-active,
.admin-shell__link:hover {
  background: var(--kd-primary-5);
  color: var(--kd-primary);
}

.admin-shell__badge {
  min-width: 20px;
  padding: 0 6px;
  border-radius: 999px;
  background: var(--kd-accent);
  color: var(--kd-ink);
  font-size: 11px;
  font-weight: 700;
  text-align: center;
}

.admin-shell__back {
  margin-top: auto;
  color: var(--kd-primary);
  text-decoration: none;
  letter-spacing: 0;
  text-transform: none;
  font-size: 13px;
}

.admin-shell__main {
  min-width: 0;
}

.admin-shell__top {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-start;
  gap: 12px 16px;
  padding: max(16px, env(safe-area-inset-top)) 16px 12px;
  border-bottom: 1px solid var(--kd-ink-10);
  background: var(--kd-white);
}

.admin-shell__heading {
  flex: 1;
  min-width: 0;
}

.admin-shell__heading h1 {
  margin: 0;
  font-size: 22px;
  font-weight: 700;
  letter-spacing: -0.03em;
}

.admin-shell__heading p,
.admin-shell__state {
  margin: 4px 0 0;
  color: var(--kd-ink-50);
  font-size: 13px;
  line-height: 1.4;
}

.admin-shell__state--error {
  color: var(--kd-destructive);
  font-weight: 700;
}

.admin-shell__menu {
  min-height: 40px;
  padding: 0 12px;
  border: 1px solid var(--kd-ink-10);
  border-radius: 8px;
  background: var(--kd-white);
  color: var(--kd-ink);
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
}

.admin-shell__actions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.admin-shell__body {
  padding: 16px;
}

.admin-shell :deep(.admin-grid) {
  display: grid;
  gap: 12px;
}

.admin-shell :deep(.admin-stats) {
  display: grid;
  gap: 12px;
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.admin-shell :deep(.admin-card),
.admin-shell :deep(.admin-panel) {
  padding: 16px;
  border-radius: 12px;
  background: var(--kd-white);
  box-shadow: 0 2px 8px var(--kd-shadow);
}

.admin-shell :deep(.admin-card h2),
.admin-shell :deep(.admin-panel h2) {
  margin: 0;
  font-size: 16px;
}

.admin-shell :deep(.admin-card p),
.admin-shell :deep(.admin-meta) {
  margin: 6px 0 0;
  color: var(--kd-ink-50);
  font-size: 13px;
  line-height: 1.4;
}

.admin-shell :deep(.admin-toolbar) {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 14px;
}

.admin-shell :deep(.admin-search),
.admin-shell :deep(.admin-field input),
.admin-shell :deep(.admin-field select),
.admin-shell :deep(.admin-field textarea) {
  min-height: 44px;
  width: 100%;
  padding: 0 12px;
  border: 1px solid var(--kd-ink-10);
  border-radius: 8px;
  background: var(--kd-white);
  color: var(--kd-ink);
  font: inherit;
  font-size: 14px;
}

.admin-shell :deep(.admin-search) {
  flex: 1;
  min-width: 180px;
}

.admin-shell :deep(.admin-chip) {
  min-height: 36px;
  padding: 0 12px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-ink-10);
  color: var(--kd-ink);
  cursor: pointer;
}

.admin-shell :deep(.admin-chip.is-active) {
  background: var(--kd-accent);
  font-weight: 700;
}

.admin-shell :deep(.admin-btn) {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  padding: 0 14px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-accent);
  color: var(--kd-ink);
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
}

.admin-shell :deep(.admin-btn--ghost) {
  border: 1px solid var(--kd-primary);
  background: transparent;
}

.admin-shell :deep(.admin-btn--danger) {
  background: var(--kd-destructive);
  color: var(--kd-white);
}

.admin-shell :deep(.admin-btn:disabled) {
  opacity: 0.55;
  cursor: not-allowed;
}

.admin-shell :deep(.admin-table-wrap) {
  overflow-x: auto;
}

.admin-shell :deep(.admin-table) {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}

.admin-shell :deep(.admin-table th),
.admin-shell :deep(.admin-table td) {
  padding: 10px 12px;
  border-bottom: 1px solid var(--kd-ink-10);
  text-align: left;
  vertical-align: top;
}

.admin-shell :deep(.admin-table th) {
  color: var(--kd-ink-50);
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}

.admin-shell :deep(.admin-status) {
  display: inline-flex;
  align-items: center;
  min-height: 22px;
  padding: 0 8px;
  border-radius: 999px;
  background: var(--kd-ink-10);
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
}

.admin-shell :deep(.admin-status--approved),
.admin-shell :deep(.admin-status--current),
.admin-shell :deep(.admin-status--admin) {
  background: var(--kd-primary-25);
}

.admin-shell :deep(.admin-status--pending),
.admin-shell :deep(.admin-status--scheduled) {
  background: var(--kd-accent-25);
}

.admin-shell :deep(.admin-status--rejected),
.admin-shell :deep(.admin-status--ended),
.admin-shell :deep(.admin-status--banned) {
  background: color-mix(in srgb, var(--kd-destructive) 18%, transparent);
}

.admin-shell :deep(.admin-cards) {
  display: none;
}

.admin-shell :deep(.admin-form) {
  display: grid;
  gap: 16px;
}

.admin-shell :deep(.admin-field) {
  display: grid;
  gap: 6px;
  font-size: 13px;
  font-weight: 700;
}

.admin-shell :deep(.admin-error) {
  margin: 0;
  color: var(--kd-destructive);
  font-size: 13px;
  font-weight: 700;
}

.admin-shell :deep(.admin-row-actions) {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.admin-shell :deep(.admin-link) {
  color: var(--kd-primary);
  font-weight: 700;
  text-decoration: none;
}

@media (max-width: 767px) {
  .admin-shell :deep(.admin-table-wrap) {
    display: none;
  }

  .admin-shell :deep(.admin-cards) {
    display: grid;
    gap: 12px;
  }
}

@media (min-width: 768px) {
  .admin-shell :deep(.admin-stats) {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }

  .admin-shell :deep(.admin-form) {
    grid-template-columns: 1fr 1fr;
    align-items: start;
  }

  .admin-shell :deep(.admin-form > .admin-span) {
    grid-column: 1 / -1;
  }
}

@media (min-width: 1024px) {
  .admin-shell {
    grid-template-columns: 224px minmax(0, 1fr);
  }

  .admin-shell__nav {
    display: flex;
    position: sticky;
    top: 0;
    height: 100vh;
  }

  .admin-shell__menu {
    display: none;
  }

  .admin-shell__body {
    padding: 24px 28px 40px;
    max-width: 1280px;
  }

  .admin-shell :deep(.admin-stats) {
    grid-template-columns: repeat(7, minmax(0, 1fr));
  }
}

@media (max-width: 1023px) {
  .admin-shell.is-nav-open .admin-shell__scrim {
    display: block;
    position: fixed;
    inset: 0;
    z-index: 20;
    background: color-mix(in srgb, var(--kd-ink) 40%, transparent);
  }

  .admin-shell.is-nav-open .admin-shell__nav {
    display: flex;
    position: fixed;
    inset: 0 auto 0 0;
    z-index: 21;
    width: min(280px, 86vw);
    height: 100%;
  }
}

.admin-shell :deep(.admin-btn:focus-visible),
.admin-shell :deep(.admin-chip:focus-visible),
.admin-shell :deep(.admin-search:focus-visible),
.admin-shell :deep(.admin-field input:focus-visible),
.admin-shell :deep(.admin-field select:focus-visible),
.admin-shell__link:focus-visible,
.admin-shell__menu:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}
</style>
