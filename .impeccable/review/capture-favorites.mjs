import { spawn } from 'node:child_process'
import { mkdir, writeFile } from 'node:fs/promises'
import { join } from 'node:path'
import { setTimeout as delay } from 'node:timers/promises'

const chrome = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
const outDir = '/Users/loisejane/Documents/mine/kapedoko/kapedoko-fe/.impeccable/review'
await mkdir(outDir, { recursive: true })

const port = 9344
const chromeProc = spawn(
  chrome,
  [
    '--headless=new',
    '--disable-gpu',
    `--remote-debugging-port=${port}`,
    '--user-data-dir=/tmp/kapedoko-chrome-favorites-7',
    '--no-first-run',
    '--no-default-browser-check',
    '--window-size=390,844',
  ],
  { stdio: ['ignore', 'pipe', 'pipe'] },
)

await new Promise((resolve, reject) => {
  const timer = setTimeout(() => reject(new Error('Chrome did not start')), 15000)
  const onData = (buf) => {
    if (String(buf).includes('DevTools listening')) {
      clearTimeout(timer)
      resolve()
    }
  }
  chromeProc.stderr.on('data', onData)
  chromeProc.stdout.on('data', onData)
})

await delay(400)
const targets = await fetch(`http://127.0.0.1:${port}/json/list`).then((r) => r.json())
const pageTarget = targets.find((t) => t.type === 'page')
if (!pageTarget?.webSocketDebuggerUrl) {
  throw new Error(`No page target: ${JSON.stringify(targets)}`)
}

class Cdp {
  constructor(url) {
    this.url = url
    this.id = 0
    this.pending = new Map()
    this.events = new Map()
  }

  async connect() {
    this.ws = new WebSocket(this.url)
    await new Promise((resolve, reject) => {
      this.ws.addEventListener('open', resolve, { once: true })
      this.ws.addEventListener('error', reject, { once: true })
    })
    this.ws.addEventListener('message', (event) => {
      const msg = JSON.parse(String(event.data))
      if (msg.method && this.events.has(msg.method)) {
        this.events.get(msg.method).forEach((fn) => fn(msg.params))
      }
      const pending = this.pending.get(msg.id)
      if (!pending) return
      this.pending.delete(msg.id)
      if (msg.error) pending.reject(new Error(JSON.stringify(msg.error)))
      else pending.resolve(msg.result)
    })
  }

  send(method, params = {}) {
    const id = ++this.id
    return new Promise((resolve, reject) => {
      this.pending.set(id, { resolve, reject })
      this.ws.send(JSON.stringify({ id, method, params }))
    })
  }

  once(method) {
    return new Promise((resolve) => {
      const fn = (params) => {
        const list = this.events.get(method) || []
        this.events.set(
          method,
          list.filter((item) => item !== fn),
        )
        resolve(params)
      }
      const list = this.events.get(method) || []
      list.push(fn)
      this.events.set(method, list)
    })
  }

  close() {
    this.ws.close()
  }
}

const cdp = new Cdp(pageTarget.webSocketDebuggerUrl)
await cdp.connect()
await cdp.send('Page.enable')
await cdp.send('Runtime.enable')
await cdp.send('Emulation.setDeviceMetricsOverride', {
  width: 390,
  height: 844,
  deviceScaleFactor: 2,
  mobile: true,
})

async function goto(url) {
  const loaded = cdp.once('Page.loadEventFired')
  await cdp.send('Page.navigate', { url })
  await Promise.race([loaded, delay(8000)])
}

async function evalExpr(expression) {
  const result = await cdp.send('Runtime.evaluate', {
    expression,
    awaitPromise: true,
    returnByValue: true,
  })
  if (result.exceptionDetails) {
    throw new Error(result.exceptionDetails.text || 'evaluate failed')
  }
  return result.result?.value
}

const deepHelpers = `
  window.__deep = (selector) => {
    const search = (root) => {
      const found = root.querySelector(selector)
      if (found) return found
      for (const el of root.querySelectorAll('*')) {
        if (el.shadowRoot) {
          const inner = search(el.shadowRoot)
          if (inner) return inner
        }
      }
      return null
    }
    return search(document)
  }
  window.__deepAll = (selector) => {
    const out = []
    const search = (root) => {
      out.push(...root.querySelectorAll(selector))
      for (const el of root.querySelectorAll('*')) {
        if (el.shadowRoot) search(el.shadowRoot)
      }
    }
    search(document)
    return out
  }
`

async function waitFor(selector, timeout = 20000) {
  const start = Date.now()
  while (Date.now() - start < timeout) {
    const found = await evalExpr(`${deepHelpers}; !!window.__deep(${JSON.stringify(selector)})`)
    if (found) return true
    await delay(250)
  }
  throw new Error(`Timed out waiting for ${selector}`)
}

async function clickSel(selector) {
  await evalExpr(`${deepHelpers}; window.__deep(${JSON.stringify(selector)})?.click()`)
}

async function shot(name) {
  const { data } = await cdp.send('Page.captureScreenshot', {
    format: 'png',
    captureBeyondViewport: true,
    fromSurface: true,
  })
  await writeFile(join(outDir, `${name}.png`), Buffer.from(data, 'base64'))
}

await goto('http://localhost:3000/app')
await waitFor('.home-tabbar__item[aria-label="Saved cafes"]')
const homeHasHeart = true
await clickSel('.home-tabbar__item[aria-label="Saved cafes"]')
try {
  await waitFor('.favorites', 8000)
} catch {
  await goto('http://localhost:3000/app/favorites')
  await waitFor('.favorites')
}
const href = await evalExpr('location.pathname')
await waitFor('.favorites-card')
await delay(400)
await shot('mobile')

await cdp.send('Emulation.setDeviceMetricsOverride', {
  width: 1440,
  height: 900,
  deviceScaleFactor: 2,
  mobile: false,
})
await delay(400)
await shot('desktop')

await cdp.send('Emulation.setDeviceMetricsOverride', {
  width: 390,
  height: 844,
  deviceScaleFactor: 2,
  mobile: true,
})
await delay(200)

await clickSel('button[aria-label="List view"]')
await waitFor('.favorites-row')
await delay(200)
await shot('mobile-list')

await clickSel('button[aria-label="Card view"]')
await delay(400)
await clickSel('button[aria-label="Next saved cafe"]')
await delay(400)
const cardTitle = await evalExpr(`${deepHelpers}; window.__deep('.favorites-card h2')?.textContent`)
await clickSel('button[aria-label="Previous saved cafe"]')
await delay(300)

await clickSel('button[aria-label="List view"]')
await delay(400)
const listCount = await evalExpr(`${deepHelpers}; window.__deepAll('.favorites-row').length`)
await clickSel('button[aria-label^="Remove"]')
await delay(300)
const listCountAfterUnfavorite = await evalExpr(`${deepHelpers}; window.__deepAll('.favorites-row').length`)

await evalExpr(`localStorage.setItem('kapedoko-favorite-ids', '[]')`)
await evalExpr(`location.reload()`)
await waitFor('.favorites-empty')
await shot('mobile-empty')
const emptyCopy = await evalExpr(`${deepHelpers}; window.__deep('.favorites-empty p')?.textContent`)

await evalExpr(`localStorage.removeItem('kapedoko-favorite-ids')`)
await evalExpr(`localStorage.removeItem('kapedoko-favorites-view')`)

cdp.close()
chromeProc.kill('SIGTERM')

console.log(JSON.stringify({ homeHasHeart, href, cardTitle, listCount, listCountAfterUnfavorite, emptyCopy }, null, 2))
