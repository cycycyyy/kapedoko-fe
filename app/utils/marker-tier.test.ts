import { describe, expect, test } from 'bun:test'
import {
  effectiveMarkerTier,
  escapeHtml,
  markerTierToKind,
  pinLabel,
  standardPinIsDot,
} from './marker-tier'

describe('effective marker tiers', () => {
  const now = new Date('2026-09-09T04:00:00.000Z')

  test('expires promoted placements back to standard', () => {
    expect(
      effectiveMarkerTier(
        [
          {
            kind: 'sponsored',
            starts_at: '2026-08-01T00:00:00.000Z',
            ends_at: '2026-09-01T00:00:00.000Z',
          },
        ],
        now,
      ),
    ).toBe('standard')
  })

  test('keeps partner pins active inside the window', () => {
    expect(
      effectiveMarkerTier(
        [
          {
            kind: 'partner',
            starts_at: '2026-09-01T00:00:00.000Z',
            ends_at: '2026-10-01T00:00:00.000Z',
          },
        ],
        now,
      ),
    ).toBe('partner')
  })

  test('lets sponsored placements win over partner', () => {
    expect(
      effectiveMarkerTier(
        [
          {
            kind: 'partner',
            starts_at: '2026-09-01T00:00:00.000Z',
            ends_at: '2026-10-01T00:00:00.000Z',
          },
          {
            kind: 'sponsored',
            starts_at: '2026-09-08T00:00:00.000Z',
            ends_at: '2026-09-15T00:00:00.000Z',
          },
        ],
        now,
      ),
    ).toBe('promoted')
  })

  test('maps product tiers back to placement kinds', () => {
    expect(markerTierToKind('promoted')).toBe('sponsored')
    expect(markerTierToKind('partner')).toBe('partner')
    expect(markerTierToKind('standard')).toBeNull()
  })
})

describe('map pin copy', () => {
  test('truncates long cafe names', () => {
    expect(pinLabel('Yardstick Coffee Lab Marikina')).toBe('Yardstick Coffe…')
  })

  test('escapes marker html', () => {
    expect(escapeHtml(`A&B <Cafe> "Q"`)).toBe('A&amp;B &lt;Cafe&gt; &quot;Q&quot;')
  })

  test('uses dots below the cup zoom', () => {
    expect(standardPinIsDot(13)).toBe(true)
    expect(standardPinIsDot(14)).toBe(false)
  })
})
