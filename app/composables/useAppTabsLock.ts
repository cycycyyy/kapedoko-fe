import { isVisibleIonPageClass } from '~/utils/app-tabs'

const visibleAdminPages = new Set<Element>()
let pendingAdminShells = 0

export function useAppTabsLock() {
  const locked = useState('kd-app-tabs-locked', () => false)

  const applyHtml = () => {
    if (!import.meta.client) return
    document.documentElement.classList.toggle('kd-hide-app-tabs', locked.value)
  }

  const setLocked = (value: boolean) => {
    locked.value = value
    applyHtml()
  }

  watch(locked, applyHtml, { immediate: true })

  return { locked, setLocked }
}

export function useAdminPageTabLock(shellEl: Ref<HTMLElement | null>) {
  const { setLocked } = useAppTabsLock()
  let page: Element | null = null
  let observer: MutationObserver | null = null
  let pending = false

  const publish = () => {
    setLocked(visibleAdminPages.size > 0 || pendingAdminShells > 0)
  }

  const beginPending = () => {
    if (pending) return
    pending = true
    pendingAdminShells += 1
    publish()
  }

  const endPending = () => {
    if (!pending) return
    pending = false
    pendingAdminShells = Math.max(0, pendingAdminShells - 1)
    publish()
  }

  const bind = (el: HTMLElement) => {
    const nextPage = el.closest('.ion-page')
    if (!nextPage) return
    page = nextPage
    page.setAttribute('data-app-surface', 'admin')
    const syncPage = () => {
      if (!page) return
      if (isVisibleIonPageClass(page.className)) {
        visibleAdminPages.add(page)
        endPending()
      }
      else {
        visibleAdminPages.delete(page)
      }
      publish()
    }
    syncPage()
    observer?.disconnect()
    observer = new MutationObserver(syncPage)
    observer.observe(page, { attributes: true, attributeFilter: ['class'] })
  }

  if (import.meta.client) beginPending()

  watch(shellEl, (el) => {
    if (el) bind(el)
  }, { flush: 'post' })

  onMounted(() => {
    if (shellEl.value) bind(shellEl.value)
  })

  onBeforeUnmount(() => {
    observer?.disconnect()
    observer = null
    if (page) {
      visibleAdminPages.delete(page)
      page.removeAttribute('data-app-surface')
      page = null
    }
    endPending()
    publish()
  })
}
