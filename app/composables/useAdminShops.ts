import type { MarkerTier, ShopRow } from '~/types/shop'

export function useAdminShops() {
  const admin = useAdminData()
  onMounted(() => {
    void admin.load()
  })
  return {
    shops: admin.shops,
    placements: admin.placements,
    placementsByShop: admin.placementsByShop,
    reports: admin.reports,
    isAdmin: computed(() => admin.status.value === 'ready'),
    status: admin.status,
    error: admin.error,
    reportsError: computed(() => ''),
    savingId: admin.savingId,
    load: admin.load,
    moderate: admin.moderate,
    markerTierFor: admin.markerTierFor,
    savePlacement: async (shop: ShopRow, tier: MarkerTier, startsAt: string, endsAt: string) => {
      const kind = tier === 'promoted' ? 'sponsored' : tier === 'partner' ? 'partner' : 'standard'
      await admin.savePlacement(shop, kind, startsAt, endsAt)
    },
    resolveReport: admin.resolveReport,
  }
}
