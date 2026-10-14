import { describe, expect, test } from 'bun:test'
import { KAPEDOKO_APP_LOGO_SRC } from './logo'
import {
  adminLogoPayload,
  cafeLogoSources,
  findCafeLogoSource,
  normalizeLogoObjectKey,
  searchCafeLogoSources,
  logoOverwriteCount,
  logoTickState,
  shopCafeLogoSrc,
  stampLogoConfirmCopy,
  stampLogoCopy,
  stampLogoDoneCopy,
  uniqueCafeLogoSources,
  uniqueLogoSourceLabel,
} from './admin-logos'

const shops = [
  { id: 'a', name: 'Yardstick', address: 'Poblacion, Makati', logo_object_key: 'shop-logos/yardstick.webp' },
  { id: 'b', name: 'The Coffee Academics', address: 'BGC, Taguig', logo_object_key: ' /shop-logos/tca.webp ' },
  { id: 'c', name: 'No Mark Cafe', address: 'Quezon City', logo_object_key: null },
  { id: 'd', name: 'Blank Key', address: 'Pasig', logo_object_key: '   ' },
  { id: 'e', name: 'Yardstick BGC', address: 'BGC, Taguig', logo_object_key: 'shop-logos/yardstick.webp' },
]

describe('cafe logo sources', () => {
  test('normalizes object keys and drops empty values', () => {
    expect(normalizeLogoObjectKey(null)).toBeNull()
    expect(normalizeLogoObjectKey('')).toBeNull()
    expect(normalizeLogoObjectKey('  /shop-logos/a.webp  ')).toBe('shop-logos/a.webp')
  })

  test('lists only cafes with saved logos and can exclude the cafe being edited', () => {
    const sources = cafeLogoSources(shops, 'https://pub-test.r2.dev', { excludeShopId: 'a' })
    expect(sources.map((source) => source.shopId)).toEqual(['b', 'e'])
    expect(sources[1]).toEqual({
      shopId: 'e',
      name: 'Yardstick BGC',
      address: 'BGC, Taguig',
      logoObjectKey: 'shop-logos/yardstick.webp',
      logoUrl: 'https://pub-test.r2.dev/shop-logos/yardstick.webp',
    })
    expect(sources[0]?.logoObjectKey).toBe('shop-logos/tca.webp')
  })

  test('keeps one selectable row per cafe even when branches share a logo key', () => {
    const sources = cafeLogoSources(shops, 'https://pub-test.r2.dev')
    expect(sources.filter((source) => source.logoObjectKey === 'shop-logos/yardstick.webp').map((source) => source.shopId))
      .toEqual(['a', 'e'])
  })

  test('searches by cafe name or address', () => {
    const sources = cafeLogoSources(shops, 'https://pub-test.r2.dev')
    expect(searchCafeLogoSources(sources, '  bgc ').map((source) => source.shopId)).toEqual(['b', 'e'])
    expect(searchCafeLogoSources(sources, 'Academics').map((source) => source.shopId)).toEqual(['b'])
    expect(searchCafeLogoSources(sources, '')).toEqual(sources)
    expect(searchCafeLogoSources(sources, 'manila')).toEqual([])
  })

  test('finds the selected source from a stored key', () => {
    const sources = cafeLogoSources(shops, 'https://pub-test.r2.dev')
    expect(findCafeLogoSource(sources, ' /shop-logos/tca.webp')?.shopId).toBe('b')
    expect(findCafeLogoSource(sources, null)).toBeNull()
    expect(findCafeLogoSource(sources, 'missing')).toBeNull()
  })

  test('keeps one chooser row per uploaded logo file', () => {
    const sources = uniqueCafeLogoSources(cafeLogoSources(shops, 'https://pub-test.r2.dev'))
    expect(sources.map((source) => source.logoObjectKey)).toEqual([
      'shop-logos/tca.webp',
      'shop-logos/yardstick.webp',
    ])
    const yardstick = sources.find((source) => source.logoObjectKey === 'shop-logos/yardstick.webp')
    expect(yardstick?.shopId).toBe('a')
    expect(yardstick?.cafeCount).toBe(2)
    expect(uniqueLogoSourceLabel(yardstick!)).toBe('Poblacion, Makati · 2 cafes')
  })

  test('shows the app logo when a cafe has no stored mark', () => {
    expect(shopCafeLogoSrc(null, 'https://pub-test.r2.dev')).toBe(KAPEDOKO_APP_LOGO_SRC)
    expect(shopCafeLogoSrc('   ', 'https://pub-test.r2.dev')).toBe(KAPEDOKO_APP_LOGO_SRC)
    expect(shopCafeLogoSrc('shop-logos/yardstick.webp', 'https://pub-test.r2.dev', true)).toBe(KAPEDOKO_APP_LOGO_SRC)
    expect(shopCafeLogoSrc('shop-logos/yardstick.webp', 'https://pub-test.r2.dev'))
      .toBe('https://pub-test.r2.dev/shop-logos/yardstick.webp')
  })
})

describe('admin logo payloads', () => {
  test('reuses an existing object key without uploading', () => {
    expect(adminLogoPayload({
      logoFile: null,
      logoObjectKey: ' /shop-logos/yardstick.webp ',
    })).toEqual({
      shouldUpload: false,
      logoObjectKey: 'shop-logos/yardstick.webp',
    })
  })

  test('prefers a new file over a referenced key', () => {
    const logoFile = new File(['logo'], 'logo.png', { type: 'image/png' })
    expect(adminLogoPayload({
      logoFile,
      logoObjectKey: 'shop-logos/yardstick.webp',
    })).toEqual({
      shouldUpload: true,
      logoObjectKey: 'shop-logos/yardstick.webp',
    })
  })

  test('clears a blank reference when no file is chosen', () => {
    expect(adminLogoPayload({ logoFile: null, logoObjectKey: '  ' })).toEqual({
      shouldUpload: false,
      logoObjectKey: null,
    })
  })
})

describe('logo stamp ticks', () => {
  test('reads none, some, and all for the current page', () => {
    const selected = new Set(['a', 'e'])
    expect(logoTickState([], selected)).toBe('none')
    expect(logoTickState(['c'], selected)).toBe('none')
    expect(logoTickState(['a', 'c'], selected)).toBe('some')
    expect(logoTickState(['a', 'e'], selected)).toBe('all')
  })

  test('counts shops that would lose a different mark', () => {
    const selected = new Set(['a', 'c', 'e'])
    expect(logoOverwriteCount(shops, selected, 'shop-logos/yardstick.webp')).toBe(0)
    expect(logoOverwriteCount(shops, selected, 'shop-logos/new.webp')).toBe(2)
    expect(logoOverwriteCount(shops, selected, null, true)).toBe(2)
  })

  test('names the stamp press and overwrite warning', () => {
    expect(stampLogoCopy(1)).toBe('Stamp onto 1 cafe')
    expect(stampLogoCopy(47)).toBe('Stamp onto 47 cafes')
    expect(stampLogoConfirmCopy(47, 0)).toBe('Stamp this mark onto 47 cafes?')
    expect(stampLogoConfirmCopy(47, 12)).toBe('Stamp this mark onto 47 cafes? 12 already have a different logo.')
    expect(stampLogoDoneCopy(1)).toBe('1 cafe now wears this mark.')
    expect(stampLogoDoneCopy(47)).toBe('47 cafes now wear this mark.')
  })
})
