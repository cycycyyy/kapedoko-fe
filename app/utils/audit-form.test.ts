import { describe, expect, test } from 'bun:test'
import {
  auditFormError,
  auditFormHasErrors,
  auditPhotoError,
  emptyAuditDraft,
  removeAuditAriaLabel,
  removeAuditConfirmCopy,
  removeAuditReasonPromptCopy,
  voidReasonError,
} from './audit-form'

describe('audit form', () => {
  test('requires cafe, both amenities, and a long-stay stance', () => {
    const errors = auditFormError(emptyAuditDraft())
    expect(errors.shop).toMatch(/cafe/)
    expect(errors.wifi).toMatch(/WiFi/)
    expect(errors.outlets).toBe('Choose an outlets result.')
    expect(errors.longStay).toMatch(/long-stay/)
    expect(errors.payment).toMatch(/QR, card, and cash/)
    expect(auditFormHasErrors(errors)).toBe(true)
  })

  test('requires a reason when an amenity is unknown', () => {
    const draft = emptyAuditDraft()
    draft.shopId = '11111111-1111-1111-1111-111111111111'
    draft.longStayStance = 'unknown'
    draft.wifi.result = 'unknown'
    draft.outlets.result = 'unavailable'
    expect(auditFormError(draft).wifi).toMatch(/unknown/)
    draft.wifi.notes = 'Router was unplugged for painting.'
    expect(auditFormError(draft).wifi).toBeNull()
  })

  test('requires outlet reliability when outlets are available', () => {
    const draft = emptyAuditDraft()
    draft.shopId = '11111111-1111-1111-1111-111111111111'
    draft.longStayStance = 'welcome'
    draft.wifi.result = 'unavailable'
    draft.outlets.result = 'available'
    expect(auditFormError(draft).outlets).toMatch(/reliability/)
    draft.outlets.reliability = 'easy'
    expect(auditFormError(draft).outlets).toBeNull()
  })

  test('requires QR, card, and cash on a visit', () => {
    const draft = emptyAuditDraft()
    draft.shopId = '11111111-1111-1111-1111-111111111111'
    draft.longStayStance = 'welcome'
    draft.wifi.result = 'unavailable'
    draft.outlets.result = 'unavailable'
    expect(auditFormError(draft).payment).toMatch(/QR, card, and cash/)
    draft.payment.qr = 'available'
    draft.payment.card = 'unavailable'
    expect(auditFormError(draft).payment).toMatch(/Cash/)
    draft.payment.cash = 'available'
    expect(auditFormError(draft).payment).toBeNull()
  })

  test('rejects negative speeds and short void reasons', () => {
    const draft = emptyAuditDraft()
    draft.shopId = '11111111-1111-1111-1111-111111111111'
    draft.longStayStance = 'welcome'
    draft.wifi.result = 'available'
    draft.wifi.downloadMbps = '-1'
    draft.outlets.result = 'unavailable'
    expect(auditFormError(draft).wifi).toMatch(/negative/)
    expect(voidReasonError('nope')).toMatch(/why/)
    expect(voidReasonError('Wrong cafe visit recorded.')).toBeNull()
    expect(removeAuditConfirmCopy('% Arabica')).toMatch(/does not delete the cafe/)
    expect(removeAuditConfirmCopy('% Arabica')).toMatch(/% Arabica/)
    expect(removeAuditReasonPromptCopy()).toMatch(/Why is this audit being removed/)
    expect(removeAuditAriaLabel('% Arabica')).toBe('Remove audit for % Arabica')
  })

  test('rejects the wrong photo type', () => {
    expect(auditPhotoError({ type: 'application/pdf', size: 1200 } as File)).toMatch(/JPG/)
  })
})
