<template>
  <section v-if="status === 'ready'" class="admin-rail" :aria-label="title">
    <div class="admin-rail__head">
      <h2>{{ title }}</h2>
      <p v-if="countCopy">{{ countCopy }}</p>
    </div>
    <p v-if="shops.length === 0" class="admin-rail__empty">{{ emptyCopy }}</p>
    <div v-else class="admin-rail__scroller">
      <NuxtLink
        v-for="shop in shops"
        :key="shop.id"
        class="admin-ticket"
        :to="toFor(shop)"
      >
        <span class="admin-ticket__name">{{ shop.name }}</span>
        <span class="admin-ticket__addr">{{ shop.address }}</span>
      </NuxtLink>
    </div>
  </section>
</template>

<script lang="ts" setup>
import type { ShopRow } from '~/types/shop'

const props = withDefaults(defineProps<{
  shops: ShopRow[]
  status?: string
  title?: string
  emptyCopy?: string
  to?: (shop: ShopRow) => string
}>(), {
  status: 'ready',
  title: 'Waiting to publish',
  emptyCopy: 'No requests waiting.',
  to: undefined,
})

const countCopy = computed(() => {
  const total = props.shops.length
  if (total === 0) return ''
  return total === 1 ? '1 cafe' : `${total} cafes`
})

const toFor = (shop: ShopRow) => props.to?.(shop) ?? `/admin/requests?id=${shop.id}`
</script>
