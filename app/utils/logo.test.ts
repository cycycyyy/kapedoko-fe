import { describe, expect, test } from 'bun:test'
import {
  cafeDisplayLogo,
  KAPEDOKO_APP_LOGO_SRC,
  KAPEDOKO_BEAN_PIN_SRC,
  KAPEDOKO_MARK_SRC,
} from './logo'

describe('cafe display logo', () => {
  test('uses the app logo when a cafe has no assigned mark', () => {
    expect(cafeDisplayLogo(null)).toBe(KAPEDOKO_APP_LOGO_SRC)
    expect(cafeDisplayLogo('')).toBe(KAPEDOKO_APP_LOGO_SRC)
    expect(cafeDisplayLogo(KAPEDOKO_MARK_SRC)).toBe(KAPEDOKO_APP_LOGO_SRC)
    expect(cafeDisplayLogo(KAPEDOKO_BEAN_PIN_SRC)).toBe(KAPEDOKO_APP_LOGO_SRC)
  })

  test('keeps a real cafe logo', () => {
    expect(cafeDisplayLogo('https://pub-test.r2.dev/shop-logos/yardstick.webp'))
      .toBe('https://pub-test.r2.dev/shop-logos/yardstick.webp')
  })
})
