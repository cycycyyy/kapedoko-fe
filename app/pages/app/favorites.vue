<template>
  <IonPage>
    <IonContent class="favorites-content">
      <div class="favorites">
        <header class="favorites-hero">
          <button
            type="button"
            class="favorites-back"
            aria-label="Back to Home"
            @click="goBack"
          >
            <ArrowLeft :size="24" :stroke-width="2" />
          </button>

          <div class="favorites-hero__stage">
            <img
              src="/assets/bean-pin.png"
              alt=""
              width="476"
              height="524"
              class="favorites-mark"
              draggable="false"
              aria-hidden="true"
            />

            <div class="favorites-heading">
              <Heart :size="28" :stroke-width="1.75" aria-hidden="true" />
              <h1>
                <span>{{ headingLead }}</span>
                <strong>{{ headingEmph }}</strong>
              </h1>
            </div>
          </div>
        </header>

        <div v-if="savedCafes.length > 0" class="favorites-toolbar">
          <div class="favorites-toggle" role="group" aria-label="Favorites layout">
            <button
              type="button"
              class="favorites-toggle__btn"
              :class="{ 'is-active': view === 'card' }"
              :aria-pressed="view === 'card'"
              aria-label="Card view"
              @click="view = 'card'"
            >
              <Columns2 :size="18" :stroke-width="2" />
            </button>
            <button
              type="button"
              class="favorites-toggle__btn"
              :class="{ 'is-active': view === 'list' }"
              :aria-pressed="view === 'list'"
              aria-label="List view"
              @click="view = 'list'"
            >
              <List :size="18" :stroke-width="2" />
            </button>
          </div>
        </div>

        <p v-if="!signedIn && savedCafes.length > 0" class="favorites-sync">
          These saves stay on this device.
          <button type="button" @click="goLogin">Sign in</button>
          to keep them on your other devices.
        </p>

        <p class="sr-only" aria-live="polite">{{ statusAnnouncement }}</p>

        <Transition name="favorites-view" mode="out-in">
          <section v-if="listStatus === 'loading'" key="loading" class="favorites-empty">
            <p>Loading saved cafes…</p>
          </section>
          <section v-else-if="listStatus === 'error'" key="error" class="favorites-empty">
            <p>{{ listError || 'Could not load saved cafes. Check your connection and try again.' }}</p>
            <button type="button" class="favorites-empty__action" @click="loadSaved">Try again</button>
          </section>
          <section
            v-else-if="savedCafes.length === 0"
            key="empty"
            class="favorites-empty"
            aria-label="No saved cafes"
          >
            <p>Save a cafe from Home when you find a place you can work from. It will show up here.</p>
            <button type="button" class="favorites-empty__action" @click="goBack">
              Find coffee shops
            </button>
          </section>

          <section
            v-else-if="view === 'card'"
            key="card"
            class="favorites-card-view"
            role="region"
            aria-roledescription="carousel"
            :aria-label="`Saved cafes, ${cardIndex + 1} of ${savedCafes.length}`"
            @pointerdown="onPointerDown"
            @pointerup="onPointerUp"
            @pointercancel="onPointerUp"
          >
            <article v-if="activeCafe" class="favorites-card">
              <div
                class="favorites-card__photo"
                :class="{ 'is-broken': brokenImages.has(activeCafe.id) }"
              >
                <img
                  :src="activeCafe.image"
                  :alt="activeCafe.name"
                  width="320"
                  height="240"
                  @error="markBroken(activeCafe.id)"
                />
              </div>

              <h2>{{ activeCafe.name }}</h2>
              <p>{{ activeCafe.address }}</p>
              <button type="button" class="favorites-card__open" @click="openCafe(activeCafe.id)">
                See this cafe
              </button>

              <div class="favorites-card__nav">
                <button
                  type="button"
                  class="favorites-card__arrow"
                  aria-label="Previous saved cafe"
                  :disabled="savedCafes.length < 2"
                  @click="goToCard(cardIndex - 1)"
                >
                  <ArrowLeft :size="18" :stroke-width="2" />
                </button>
                <button
                  type="button"
                  class="favorites-card__arrow"
                  aria-label="Next saved cafe"
                  :disabled="savedCafes.length < 2"
                  @click="goToCard(cardIndex + 1)"
                >
                  <ArrowRight :size="18" :stroke-width="2" />
                </button>
              </div>
            </article>
          </section>

          <section
            v-else
            key="list"
            class="favorites-list"
            aria-label="Saved cafes"
          >
            <article
              v-for="cafe in savedCafes"
              :key="cafe.id"
              class="favorites-row"
            >
              <div
                class="favorites-row__photo"
                :class="{ 'is-broken': brokenImages.has(cafe.id) }"
              >
                <img
                  :src="cafe.image"
                  alt=""
                  width="56"
                  height="56"
                  @error="markBroken(cafe.id)"
                />
              </div>

              <button type="button" class="favorites-row__body" @click="openCafe(cafe.id)">
                <h2>{{ cafe.name }}</h2>
                <p>{{ cafe.address }}</p>
              </button>

              <button
                type="button"
                class="favorites-row__heart"
                :aria-label="`Remove ${cafe.name} from favorites`"
                @click="unfavorite(cafe.id)"
              >
                <Heart :size="22" :stroke-width="1.75" />
              </button>
            </article>
          </section>
        </Transition>
      </div>
    </IonContent>
  </IonPage>
</template>

<script lang="ts" setup>
import { ArrowLeft, ArrowRight, Columns2, Heart, List } from 'lucide-vue-next'
import type { Cafe } from '~/types/cafe'
import { fetchApprovedCafesByIds } from '~/utils/approved-shops'

type FavoritesView = 'card' | 'list'

const VIEW_KEY = 'kapedoko-favorites-view'
const favorites = useFavorites()
const user = useSupabaseUser()
const supabase = useSupabaseClient()
const config = useRuntimeConfig()
const { goToLogin } = useAuth()

const view = ref<FavoritesView>('card')
const cardIndex = ref(0)
const brokenImages = ref<Set<string>>(new Set())
const swipeX = ref<number | null>(null)
const savedCafes = ref<Cafe[]>([])
const listStatus = ref<'loading' | 'ready' | 'error'>('loading')
const listError = ref('')
const signedIn = computed(() => Boolean(user.value))

let loadSeq = 0

const loadSaved = async () => {
  const ids = favorites.ids.value
  if (!ids.length) {
    savedCafes.value = []
    listError.value = ''
    listStatus.value = favorites.status.value === 'idle' || favorites.status.value === 'loading'
      ? 'loading'
      : 'ready'
    return
  }
  const seq = ++loadSeq
  listStatus.value = savedCafes.value.length ? 'ready' : 'loading'
  listError.value = ''
  try {
    const next = await fetchApprovedCafesByIds(supabase, String(config.public.r2PublicBaseUrl || ''), ids)
    if (seq !== loadSeq) return
    savedCafes.value = next
    listStatus.value = 'ready'
  } catch {
    if (seq !== loadSeq) return
    listStatus.value = 'error'
    listError.value = favorites.error.value || 'Could not load saved cafes.'
  }
}

const activeCafe = computed(() => savedCafes.value[cardIndex.value] ?? savedCafes.value[0] ?? null)

const headingLead = computed(() =>
  savedCafes.value.length === 0 ? 'No favorite' : 'Here are your favorite',
)

const headingEmph = 'coffee shops'

const statusAnnouncement = computed(() => {
  const count = savedCafes.value.length
  if (count === 0) return 'No favorite coffee shops yet.'
  if (view.value === 'card' && activeCafe.value) {
    return `${activeCafe.value.name}, ${cardIndex.value + 1} of ${count}.`
  }
  return count === 1 ? '1 saved coffee shop.' : `${count} saved coffee shops.`
})

const readStoredView = (): FavoritesView => {
  if (!import.meta.client) return 'card'
  return window.localStorage.getItem(VIEW_KEY) === 'list' ? 'list' : 'card'
}

onMounted(() => {
  view.value = readStoredView()
  void loadSaved()
})

watch(() => [favorites.ids.value.join(','), favorites.status.value], () => {
  void loadSaved()
})

watch(view, (next) => {
  if (import.meta.client) window.localStorage.setItem(VIEW_KEY, next)
})

watch(savedCafes, (cafes) => {
  if (cafes.length === 0) {
    cardIndex.value = 0
    return
  }
  if (cardIndex.value > cafes.length - 1) cardIndex.value = cafes.length - 1
})

const goToCard = (index: number) => {
  const total = savedCafes.value.length
  if (total < 1) return
  cardIndex.value = ((index % total) + total) % total
}

const onPointerDown = (event: PointerEvent) => {
  if (event.pointerType === 'mouse' && event.button !== 0) return
  swipeX.value = event.clientX
}

const onPointerUp = (event: PointerEvent) => {
  if (swipeX.value === null) return
  const delta = event.clientX - swipeX.value
  swipeX.value = null
  if (Math.abs(delta) < 48) return
  goToCard(cardIndex.value + (delta < 0 ? 1 : -1))
}

const unfavorite = (id: string) => {
  void favorites.toggle(id)
}

const openCafe = async (id: string) => {
  await navigateTo(`/app/cafes/${id}`)
}

const goLogin = () => goToLogin('/app/favorites')

const goBack = async () => {
  await navigateTo('/app')
}

const markBroken = (id: string) => {
  const next = new Set(brokenImages.value)
  next.add(id)
  brokenImages.value = next
}</script>

<style scoped>
.favorites-content {
  --background: var(--kd-white);
  --padding-start: 0;
  --padding-end: 0;
  --padding-top: 0;
  --padding-bottom: 0;
}

.favorites-content :deep(.inner-scroll) {
  display: flex;
  flex-direction: column;
  min-height: 100%;
}

.favorites {
  display: flex;
  flex: 1 1 auto;
  flex-direction: column;
  min-height: 100%;
  background: var(--kd-white);
  padding-bottom: calc(1.5rem + env(safe-area-inset-bottom));
  container-type: inline-size;
  container-name: favorites;
}

.favorites-hero {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: max(2.35rem, calc(env(safe-area-inset-top) + 10px)) 20px 0;
}

.favorites-hero__stage {
  position: relative;
  z-index: 0;
  display: grid;
  place-items: center;
  width: min(268px, 72cqi);
  overflow: visible;
}

.favorites-mark {
  position: absolute;
  z-index: 0;
  top: 0;
  left: 0;
  display: block;
  width: 100%;
  height: auto;
  pointer-events: none;
  user-select: none;
}

.favorites-back {
  position: absolute;
  top: max(2.15rem, calc(env(safe-area-inset-top) + 6px));
  left: 10px;
  z-index: 2;
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-primary);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.favorites-back:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
  border-radius: 8px;
}

.favorites-heading {
  position: relative;
  z-index: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  align-self: start;
  grid-area: 1 / 1;
  gap: 8px;
  padding-top: 18%;
  color: var(--kd-primary);
  text-align: center;
}

.favorites-heading h1 {
  display: flex;
  flex-direction: column;
  margin: 0;
  max-width: 14rem;
}

.favorites-heading h1 span {
  font-size: 16px;
  font-weight: 400;
  line-height: 1.35;
}

.favorites-heading h1 strong {
  font-size: 24px;
  font-weight: 700;
  line-height: 1.2;
}

.favorites-toolbar {
  position: relative;
  z-index: 2;
  display: flex;
  justify-content: flex-end;
  margin-top: 0;
  padding: 0 20px 12px;
}

.favorites-toggle {
  display: flex;
  align-items: center;
  gap: 6px;
}

.favorites-toggle__btn {
  display: grid;
  place-items: center;
  width: 36px;
  height: 36px;
  padding: 0;
  border: 0;
  border-radius: 8px;
  background: transparent;
  color: var(--kd-primary);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: background-color 180ms cubic-bezier(0.16, 1, 0.3, 1),
    color 180ms cubic-bezier(0.16, 1, 0.3, 1),
    transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.favorites-toggle__btn.is-active {
  background: var(--kd-primary);
  color: var(--kd-white);
}

.favorites-toggle__btn:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
}

.favorites-card-view {
  position: relative;
  z-index: 2;
  display: flex;
  flex: 1 1 auto;
  flex-direction: column;
  padding: 0 20px;
  touch-action: pan-y;
}

.favorites-card {
  display: flex;
  flex: 1 1 auto;
  flex-direction: column;
  min-height: 420px;
  padding: 16px 16px 22px;
  border-radius: 8px;
  background: var(--kd-primary);
  color: var(--kd-white);
  text-align: center;
}

.favorites-card__photo {
  position: relative;
  overflow: hidden;
  flex: 1 1 auto;
  min-height: 220px;
  max-height: 360px;
  border-radius: 8px;
  background: color-mix(in srgb, var(--kd-white) 12%, var(--kd-primary));
}

.favorites-card__photo img {
  position: absolute;
  inset: 0;
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.favorites-card__photo.is-broken img {
  display: none;
}

.favorites-card h2 {
  margin: 18px 0 0;
  font-size: 20px;
  font-weight: 700;
  line-height: 1.25;
}

.favorites-card p {
  margin: 6px auto 0;
  max-width: 16.5rem;
  font-size: 13px;
  font-weight: 400;
  line-height: 1.4;
}

.favorites-sync {
  position: relative;
  z-index: 2;
  margin: 0 20px 12px;
  color: var(--kd-ink);
  font-size: 13px;
  line-height: 1.4;
  text-align: center;
}

.favorites-sync button {
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-primary);
  font: inherit;
  font-weight: 700;
  cursor: pointer;
}

.favorites-card__open {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  margin: 14px auto 0;
  padding: 0 16px;
  border: 1.5px solid var(--kd-white);
  border-radius: 8px;
  background: transparent;
  color: var(--kd-white);
  font-size: 14px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
}

.favorites-card__nav {
  display: flex;
  justify-content: center;
  gap: 18px;
  margin-top: auto;
  padding-top: 22px;
}

.favorites-card__arrow {
  display: grid;
  place-items: center;
  width: 40px;
  height: 40px;
  padding: 0;
  border: 1.5px solid var(--kd-white);
  border-radius: 999px;
  background: transparent;
  color: var(--kd-white);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: opacity 140ms cubic-bezier(0.16, 1, 0.3, 1),
    transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.favorites-card__arrow:disabled {
  opacity: 0.35;
  cursor: default;
}

.favorites-card__arrow:focus-visible {
  outline: 2px solid var(--kd-white);
  outline-offset: 3px;
}

.favorites-list {
  position: relative;
  z-index: 2;
  display: flex;
  flex-direction: column;
  gap: 24px;
  padding: 4px 20px 0;
}

.favorites-row {
  display: flex;
  align-items: center;
  gap: 14px;
}

.favorites-row__photo {
  flex: 0 0 56px;
  width: 56px;
  height: 56px;
  overflow: hidden;
  border-radius: 999px;
  background: var(--kd-secondary);
}

.favorites-row__photo img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.favorites-row__photo.is-broken img {
  display: none;
}

.favorites-row__body {
  flex: 1;
  min-width: 0;
  padding: 0;
  border: 0;
  background: transparent;
  color: inherit;
  font: inherit;
  text-align: left;
  cursor: pointer;
}

.favorites-row h2 {
  margin: 0;
  color: var(--kd-primary);
  font-size: 16px;
  font-weight: 700;
  line-height: 1.375;
}

.favorites-row p {
  display: -webkit-box;
  margin: 2px 0 0;
  overflow: hidden;
  color: color-mix(in srgb, var(--kd-ink) 66%, var(--kd-white));
  font-size: 12px;
  line-height: 1.35;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
}

.favorites-row__heart {
  display: grid;
  place-items: center;
  flex: 0 0 44px;
  width: 44px;
  height: 44px;
  margin-right: -8px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--kd-primary);
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: transform 140ms cubic-bezier(0.16, 1, 0.3, 1),
    color 180ms cubic-bezier(0.16, 1, 0.3, 1);
}

.favorites-row__heart:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 2px;
  border-radius: 8px;
}

.favorites-empty {
  position: relative;
  z-index: 2;
  display: flex;
  flex: 1 1 auto;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  gap: 20px;
  padding: 8px 32px 48px;
  text-align: center;
}

.favorites-empty p {
  margin: 0;
  max-width: 16rem;
  color: color-mix(in srgb, var(--kd-ink) 72%, var(--kd-white));
  font-size: 14px;
  line-height: 1.45;
}

.favorites-empty__action {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 180px;
  height: 45px;
  padding: 0 20px;
  border: 0;
  border-radius: 8px;
  background: var(--kd-primary);
  color: var(--kd-white);
  font-size: 16px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: opacity 140ms cubic-bezier(0.16, 1, 0.3, 1),
    transform 140ms cubic-bezier(0.16, 1, 0.3, 1);
}

.favorites-empty__action:focus-visible {
  outline: 2px solid var(--kd-primary);
  outline-offset: 3px;
}

.favorites-back:active,
.favorites-toggle__btn:active,
.favorites-card__arrow:active:not(:disabled),
.favorites-row__heart:active,
.favorites-empty__action:active {
  transform: scale(0.94);
}

.favorites-view-enter-active,
.favorites-view-leave-active {
  transition: opacity 180ms cubic-bezier(0.16, 1, 0.3, 1);
}

.favorites-view-enter-from,
.favorites-view-leave-to {
  opacity: 0;
}

.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

@media (hover: hover) {
  .favorites-toggle__btn:hover:not(.is-active) {
    background: var(--kd-ink-10);
  }

  .favorites-row__heart:hover {
    color: var(--kd-destructive);
  }

  .favorites-empty__action:hover,
  .favorites-card__arrow:hover:not(:disabled) {
    opacity: 0.92;
  }
}

@media (min-width: 540px) {
  .favorites {
    max-width: 480px;
    margin-inline: auto;
  }
}

@media (min-width: 900px) {
  .favorites-card {
    min-height: 520px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .favorites-back,
  .favorites-toggle__btn,
  .favorites-card__arrow,
  .favorites-row__heart,
  .favorites-empty__action,
  .favorites-view-enter-active,
  .favorites-view-leave-active {
    transition-duration: 1ms;
  }

  .favorites-back:active,
  .favorites-toggle__btn:active,
  .favorites-card__arrow:active:not(:disabled),
  .favorites-row__heart:active,
  .favorites-empty__action:active {
    transform: none;
  }
}

::selection {
  background: var(--kd-secondary);
  color: var(--kd-primary);
}
</style>
