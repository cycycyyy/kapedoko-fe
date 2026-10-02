import { isVisibleIonPageClass } from '~/utils/app-tabs'

const tabFreePages = new Set<Element>()
let pendingTabFreeShells = 0

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

export function useHideAppTabs(shellEl: Ref<HTMLElement | null>, surface: string) {
  const { setLocked } = useAppTabsLock()
  let page: Element | null = null
  let observer: MutationObserver | null = null
  let pending = false

  const publish = () => {
    setLocked(tabFreePages.size > 0 || pendingTabFreeShells > 0)
  }

  const beginPending = () => {
    if (pending) return
    pending = true
    pendingTabFreeShells += 1
    publish()
  }

  const endPending = () => {
    if (!pending) return
    pending = false
    pendingTabFreeShells = Math.max(0, pendingTabFreeShells - 1)
    publish()
  }

  const bind = (el: HTMLElement) => {
    const nextPage = el.closest('.ion-page')
    if (!nextPage) return
    page = nextPage
    page.setAttribute('data-app-surface', surface)
    const syncPage = () => {
      if (!page) return
      if (isVisibleIonPageClass(page.className)) {
        tabFreePages.add(page)
        endPending()
      }
      else {
        tabFreePages.delete(page)
      }
      publish()
    }
    syncPage()
    observer?.disconnect()
    observer = new MutationObserver(syncPage)
    observer.observe(page, { attributes: true, attributeFilter: ['class'] })
  }

  const release = () => {
    observer?.disconnect()
    observer = null
    if (page) {
      tabFreePages.delete(page)
      page.removeAttribute('data-app-surface')
      page = null
    }
    endPending()
    publish()
  }

  if (import.meta.client) beginPending()

  watch(shellEl, (el) => {
    if (el) bind(el)
  }, { flush: 'post' })

  onMounted(() => {
    if (shellEl.value) bind(shellEl.value)
  })

  onBeforeUnmount(release)

  return { release }
}

export function useAdminPageTabLock(shellEl: Ref<HTMLElement | null>) {
  useHideAppTabs(shellEl, 'admin')
}
