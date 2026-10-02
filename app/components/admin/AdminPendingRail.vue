<template>
  <section v-if="status === 'ready'" class="admin-rail" :aria-label="title">
    <div class="admin-rail__head">
      <h2>{{ title }}</h2>
      <p v-if="countCopy">{{ countCopy }}</p>
    </div>
    <p v-if="items.length === 0" class="admin-rail__empty">{{ emptyCopy }}</p>
    <div v-else class="admin-rail__scroller">
      <NuxtLink
        v-for="item in items"
        :key="item.id"
        class="admin-ticket"
        :to="item.to"
      >
        <span class="admin-ticket__name">{{ item.name }}</span>
        <span class="admin-ticket__addr">{{ item.detail }}</span>
      </NuxtLink>
    </div>
  </section>
</template>

<script lang="ts" setup>
import type { ShopRow } from '~/types/shop'

interface AdminRailTicket {
  id: string
  name: string
  detail: string
  to: string
}

const props = withDefaults(defineProps<{
  shops?: ShopRow[]
  tickets?: AdminRailTicket[]
  status?: string
  title?: string
  emptyCopy?: string
  to?: (shop: ShopRow) => string
}>(), {
  shops: () => [],
  tickets: undefined,
  status: 'ready',
  title: 'Waiting to publish',
  emptyCopy: 'No requests waiting.',
  to: undefined,
})

const items = computed<AdminRailTicket[]>(() => {
  if (props.tickets) return props.tickets
  return props.shops.map((shop) => ({
    id: shop.id,
    name: shop.name,
    detail: shop.address,
    to: props.to?.(shop) ?? `/admin/requests?id=${shop.id}`,
  }))
})

const countCopy = computed(() => {
  const total = items.value.length
  if (total === 0) return ''
  return total === 1 ? '1 cafe' : `${total} cafes`
})
</script>
