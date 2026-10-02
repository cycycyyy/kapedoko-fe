import { onIonViewDidEnter, onIonViewWillEnter } from '@ionic/vue'
import {
  isForeignSurface,
  isVisibleIonPageClass,
  pathFromHref,
  resolveTabBarVisible,
  tabBarModeForPath,
  type AppTabBarMode,
} from '~/utils/app-tabs'

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

/**
 * Mark the page that is entering. Ionic can show the next view before Vue
 * Router or the browser URL catches up, so this claim updates the tab bar
 * on that first navigation. A later route change still wins until the next enter.
 */
export function useAppTabBar(mode: AppTabBarMode) {
  const pageMode = useState<AppTabBarMode | null>('kd-app-tab-page', () => null)
  const pageStamp = useState('kd-app-tab-page-stamp', () => 0)

  const claim = () => {
    pageStamp.value += 1
    pageMode.value = mode
  }

  if (import.meta.client) claim()
  onIonViewWillEnter(claim)
  onIonViewDidEnter(claim)
}

export function useAppTabBarVisibility() {
  const route = useRoute()
  const pageMode = useState<AppTabBarMode | null>('kd-app-tab-page', () => null)
  const pageStamp = useState('kd-app-tab-page-stamp', () => 0)
  const routeMode = useState<AppTabBarMode | null>('kd-app-tab-route', () => null)
  const routeStamp = useState('kd-app-tab-route-stamp', () => 0)
  const appliedPath = useState('kd-app-tab-applied', () => '')
  const locationPath = useState('kd-app-tab-location', () => '')

  const notePath = (path: string) => {
    const current = pathFromHref(path)
    if (!current || current === '/' || current === appliedPath.value) return
    appliedPath.value = current
    // A real path change is newer than any page already on screen, so the bar
    // follows the navigation immediately. The entering page can claim again after.
    routeStamp.value = pageStamp.value + 1
    routeMode.value = tabBarModeForPath(current)
  }

  watch(() => route.path, notePath, { immediate: true, flush: 'sync' })

  if (import.meta.client) {
    const onLocation = () => {
      const href = `${window.location.pathname}${window.location.hash}`
      locationPath.value = href
      notePath(href)
    }

    onMounted(() => {
      const href = `${window.location.pathname}${window.location.hash}`
      locationPath.value = href
      if (isForeignSurface(href)) notePath(href)
      window.addEventListener('popstate', onLocation)
      window.addEventListener('hashchange', onLocation)
    })

    onBeforeUnmount(() => {
      window.removeEventListener('popstate', onLocation)
      window.removeEventListener('hashchange', onLocation)
    })
  }

  const visible = computed(() => resolveTabBarVisible({
    pageMode: pageMode.value,
    pageStamp: pageStamp.value,
    routeMode: routeMode.value,
    routeStamp: routeStamp.value,
    foreign: isForeignSurface(route.path) || isForeignSurface(locationPath.value),
  }))

  return { visible }
}
