export function watchImpression(
  element: Element,
  options: {
    ratio: number
    dwellMs: number
    onView: () => void
  },
): () => void {
  if (typeof IntersectionObserver === 'undefined') return () => undefined

  let timer: ReturnType<typeof setTimeout> | undefined
  let done = false

  const clear = () => {
    if (timer) {
      clearTimeout(timer)
      timer = undefined
    }
  }

  const observer = new IntersectionObserver((entries) => {
    if (done) return
    const entry = entries[0]
    const visible = Boolean(entry?.isIntersecting && entry.intersectionRatio >= options.ratio)
    if (!visible) {
      clear()
      return
    }
    if (timer) return
    timer = setTimeout(() => {
      if (done) return
      done = true
      clear()
      observer.disconnect()
      options.onView()
    }, options.dwellMs)
  }, { threshold: [0, options.ratio, 1] })

  observer.observe(element)
  return () => {
    done = true
    clear()
    observer.disconnect()
  }
}
