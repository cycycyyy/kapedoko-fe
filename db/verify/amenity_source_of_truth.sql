-- =========================================================
-- KapéDoko — Amenity source of truth RLS checks (manual)
-- =========================================================
-- Run after 20261002–20261007. Expected outcomes are in comments.
-- Repeat selected statements as anon, a normal user JWT, an
-- auditor JWT, and an admin JWT.
-- =========================================================

-- Anonymous / user cannot read raw audits.
-- select count(*) from public.cafe_audits;
-- Expected: 0 rows for anon/user; auditors and admins see rows.

-- Anonymous cannot read SSIDs.
-- select wifi_network_name from public.cafe_audit_amenity_results;
-- Expected: 0 rows / permission denied for anon.

-- Public resolution is visible and has no auditor_id column.
-- select * from public.shop_amenity_resolutions_public limit 1;
-- Expected: rows (not "permission denied for view review_amenity_votes").
-- Columns are shop_id, amenity_key, availability, confidence,
-- source_at, decided_count, yes_count, no_count, is_stale, needs_recheck,
-- wifi_speed, wifi_time_limit, outlet_reliability. No auditor_id, no SSID.

-- Public payment is visible and has no auditor id.
-- select * from public.shop_payment_public limit 1;
-- Expected: rows for approved cafes with a valid visit. Columns are
-- shop_id, accepts_qr, accepts_card, accepts_cash, source_at.

-- Direct read of the vote view stays closed.
-- select * from public.review_amenity_votes limit 1;
-- Expected: permission denied for anon/authenticated.

-- Direct insert into cafe_audits must fail.
-- insert into public.cafe_audits (shop_id, auditor_id, long_stay_stance, client_idempotency_key)
-- values ('00000000-0000-0000-0000-000000000000', auth.uid(), 'unknown', gen_random_uuid());
-- Expected: RLS / permission denied.

-- User cannot submit an audit.
-- select public.submit_cafe_audit(
--   '<approved-shop-id>', gen_random_uuid(),
--   '{"result":"available"}'::jsonb, '{"result":"unavailable"}'::jsonb, 'unknown'
-- );
-- Expected: Auditor only.

-- Auditor can submit; second call with the same idempotency key returns the same row.
-- Expected: one cafe_audits row.

-- Auditor void_cafe_audit → Admin only.

-- Admin void with a short reason → check constraint / 'Say why this audit is voided.'

-- Direct update cafe_audits set notes = 'x' → cafe_audits are append-only.

-- Direct delete cafe_audits → cafe_audits are append-only.

-- attach_cafe_audit_photo with a key that is not audit-photos/{caller}/...
-- Expected: That photo does not belong to this upload.

-- admin_set_profile_role(..., 'auditor') as admin → profiles.role = auditor.
-- is_admin() stays false for that user; is_auditor() is true.

-- sync_cafe_owner_role on an auditor with a verified claim
-- Expected: role remains auditor.

-- import_cafe_amenity_reports as a non-admin → Admin only.
-- Re-running the same source_row_key → skipped_existing increments, no extra row.
