import { advanceWindow, CAFE_PAGE_SIZE, windowItems } from '~/utils/infinite-list'

export function useInfiniteWindow<T>(source: ComputedRef<T[]>, resetKey: ComputedRef<string>, pageSize = CAFE_PAGE_SIZE) {
  const shown = ref(pageSize)
  const sentinel = ref<HTMLElement | null>(null)
  const slice = computed(() => windowItems(source.value, shown.value))
  const hasMore = computed(() => shown.value < source.value.length)

  const reset = () => {
    shown.value = Math.min(pageSize, source.value.length || pageSize)
  }

  watch(resetKey, reset)

  let observer: IntersectionObserver | null = null
  let filling = false

  const sentinelInView = () => {
    const el = sentinel.value
    if (!el) return false
    const rect = el.getBoundingClientRect()
    return rect.height > 0 && rect.top <= window.innerHeight + 140
  }

  const fill = async () => {
    if (filling || !hasMore.value) return
    filling = true
    let guard = 0
    let lastTop = Number.NEGATIVE_INFINITY
    while (guard < 6 && hasMore.value && sentinelInView()) {
      const top = sentinel.value?.getBoundingClientRect().top ?? lastTop
      if (guard > 0 && top <= lastTop) break
      lastTop = top
      shown.value = advanceWindow(shown.value, source.value.length, pageSize)
      guard += 1
      await nextTick()
    }
    filling = false
  }

  const attach = () => {
    observer?.disconnect()
    observer = null
    const el = sentinel.value
    if (!el || !import.meta.client) return
    observer = new IntersectionObserver((entries) => {
      if (entries.some(entry => entry.isIntersecting)) void fill()
    }, { rootMargin: '160px' })
    observer.observe(el)
  }

  watch(sentinel, attach)
  onBeforeUnmount(() => observer?.disconnect())

  return { slice, hasMore, shown, sentinel }
}
