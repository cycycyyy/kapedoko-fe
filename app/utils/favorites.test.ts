import { describe, expect, test } from 'bun:test'
import { favoriteIdsToInsert, mergeFavoriteIds, normalizeFavoriteIds } from './favorites'

const LOCAL = '11111111-1111-4111-8111-111111111111'
const REMOTE = '22222222-2222-4222-8222-222222222222'
const SHARED = '33333333-3333-4333-8333-333333333333'

describe('favorite merge', () => {
  test('drops mock ids and duplicates', () => {
    expect(normalizeFavoriteIds(['bubbalab', LOCAL, LOCAL, 'c1', ` ${REMOTE} `])).toEqual([LOCAL, REMOTE])
    expect(normalizeFavoriteIds(null)).toEqual([])
  })

  test('keeps remote order and appends new local saves once', () => {
    expect(mergeFavoriteIds([LOCAL, SHARED, 'not-a-shop'], [REMOTE, SHARED])).toEqual([
      REMOTE,
      SHARED,
      LOCAL,
    ])
  })

  test('inserts only ids the account does not already have', () => {
    const merged = mergeFavoriteIds([LOCAL, SHARED], [REMOTE, SHARED])
    expect(favoriteIdsToInsert('user-1', [REMOTE, SHARED], merged)).toEqual([
      { user_id: 'user-1', shop_id: LOCAL },
    ])
  })
})
