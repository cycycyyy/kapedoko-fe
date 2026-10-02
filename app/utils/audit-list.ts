export interface AuditQueueCafe {
  shopId: string
  urgency: 'recheck' | 'stale'
  amenityKeys: string[]
  sourceAt: string | null
}

export interface AuditedCafeListRow {
  shopId: string
  auditId: string
  auditedAt: string
  longStayStance: string
  wifi: string | null
  outlets: string | null
  qr: string | null
  card: string | null
  cash: string | null
}

/** Collapse per-amenity queue rows into one cafe ticket, keeping recheck-first order. */
export function auditQueueCafes<T extends {
  shop_id: string
  amenity_key: string
  needs_recheck?: boolean | null
  is_stale?: boolean | null
  source_at?: string | null
}>(rows: T[]): AuditQueueCafe[] {
  const byShop = new Map<string, AuditQueueCafe>()
  const order: string[] = []
  for (const row of rows) {
    let cafe = byShop.get(row.shop_id)
    if (!cafe) {
      cafe = {
        shopId: row.shop_id,
        urgency: row.needs_recheck ? 'recheck' : 'stale',
        amenityKeys: [],
        sourceAt: row.source_at ?? null,
      }
      byShop.set(row.shop_id, cafe)
      order.push(row.shop_id)
    }
    if (row.needs_recheck) cafe.urgency = 'recheck'
    if (!cafe.amenityKeys.includes(row.amenity_key)) cafe.amenityKeys.push(row.amenity_key)
    if (row.source_at && (!cafe.sourceAt || row.source_at < cafe.sourceAt)) {
      cafe.sourceAt = row.source_at
    }
  }
  return order.map((id) => byShop.get(id)!)
}

/** Latest non-voided visit per cafe, newest first. */
export function auditedCafeRows(
  audits: Array<{
    id: string
    shop_id: string
    audited_at: string
    created_at: string
    long_stay_stance: string
    accepts_qr?: string | null
    accepts_card?: string | null
    accepts_cash?: string | null
  }>,
  results: Array<{ audit_id: string; amenity_key: string; result: string }>,
  voidedIds: Iterable<string>,
): AuditedCafeListRow[] {
  const voided = new Set(voidedIds)
  const sorted = [...audits].sort(
    (a, b) => b.audited_at.localeCompare(a.audited_at) || b.created_at.localeCompare(a.created_at),
  )
  const resultsByAudit = new Map<string, Array<{ amenity_key: string; result: string }>>()
  for (const result of results) {
    const list = resultsByAudit.get(result.audit_id) ?? []
    list.push(result)
    resultsByAudit.set(result.audit_id, list)
  }

  const seen = new Set<string>()
  const rows: AuditedCafeListRow[] = []
  for (const audit of sorted) {
    if (voided.has(audit.id) || seen.has(audit.shop_id)) continue
    seen.add(audit.shop_id)
    const amenity = resultsByAudit.get(audit.id) ?? []
    rows.push({
      shopId: audit.shop_id,
      auditId: audit.id,
      auditedAt: audit.audited_at,
      longStayStance: audit.long_stay_stance,
      wifi: amenity.find((row) => row.amenity_key === 'wifi')?.result ?? null,
      outlets: amenity.find((row) => row.amenity_key === 'outlets')?.result ?? null,
      qr: audit.accepts_qr ?? null,
      card: audit.accepts_card ?? null,
      cash: audit.accepts_cash ?? null,
    })
  }
  return rows
}

export function amenityKeyLabel(key: string): string {
  if (key === 'wifi') return 'WiFi'
  if (key === 'outlets') return 'Outlets'
  if (key === 'long_stay_wifi') return 'Long-stay'
  return key
}

export function queueTicketDetail(cafe: Pick<AuditQueueCafe, 'urgency' | 'amenityKeys'>): string {
  const urgency = cafe.urgency === 'recheck' ? 'Needs recheck' : 'Stale'
  const amenities = cafe.amenityKeys.map(amenityKeyLabel).join(', ')
  return amenities ? `${urgency} · ${amenities}` : urgency
}

export function auditAmenityWord(kind: 'wifi' | 'outlets', result: string | null | undefined): string {
  if (result === 'available') return 'Available'
  if (result === 'unavailable') return kind === 'wifi' ? 'No WiFi' : 'No outlets'
  return 'Unknown'
}

export function auditAmenityCardWord(kind: 'wifi' | 'outlets', result: string | null | undefined): string {
  if (result === 'available') return kind === 'wifi' ? 'WiFi' : 'Outlets'
  if (result === 'unavailable') return kind === 'wifi' ? 'No WiFi' : 'No outlets'
  return kind === 'wifi' ? 'WiFi unknown' : 'Outlets unknown'
}

export function auditAmenityTone(result: string | null | undefined): 'ok' | 'no' | 'unknown' {
  if (result === 'available') return 'ok'
  if (result === 'unavailable') return 'no'
  return 'unknown'
}

export function longStayWord(stance: string | null | undefined): string {
  if (stance === 'welcome') return 'Welcome'
  if (stance === 'discouraged') return 'Discouraged'
  return 'Unknown'
}

export function paymentWord(qr: string | null | undefined, card: string | null | undefined, cash: string | null | undefined): string {
  const accepted = [
    qr === 'available' ? 'QR' : null,
    card === 'available' ? 'Card' : null,
    cash === 'available' ? 'Cash' : null,
  ].filter((value): value is string => Boolean(value))
  if (accepted.length) return accepted.join(' · ')
  if (qr === 'unavailable' && card === 'unavailable' && cash === 'unavailable') {
    return 'No QR, card, or cash'
  }
  return 'Unknown'
}

export function paymentTone(qr: string | null | undefined, card: string | null | undefined, cash: string | null | undefined): 'ok' | 'no' | 'unknown' {
  if (qr === 'available' || card === 'available' || cash === 'available') return 'ok'
  if (qr === 'unavailable' && card === 'unavailable' && cash === 'unavailable') return 'no'
  return 'unknown'
}

export function filterAuditedCafes<T extends { name: string }>(rows: T[], query: string): T[] {
  const term = query.trim().toLowerCase()
  if (!term) return rows
  return rows.filter((row) => row.name.toLowerCase().includes(term))
}
