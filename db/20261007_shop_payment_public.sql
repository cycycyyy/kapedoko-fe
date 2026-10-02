-- =========================================================
-- KapéDoko — public QR / card / cash from the latest visit
-- =========================================================
-- Run AFTER 20261006_audit_payment_methods.sql. Safe to re-run.
-- Public clients must not read cafe_audits; this view is the
-- safe payment contract for cards and cafe detail.
-- =========================================================

create or replace view public.shop_payment_public
with (security_invoker = false) as
select
  a.shop_id,
  a.accepts_qr,
  a.accepts_card,
  a.accepts_cash,
  a.audited_at as source_at
from public.current_valid_cafe_audits a
join public.shops s on s.id = a.shop_id
where s.status = 'approved';

comment on view public.shop_payment_public is
  'Latest team-visit payment facts for approved cafes. No auditor ids or notes.';

revoke all on public.shop_payment_public from anon, authenticated;
grant select on public.shop_payment_public to anon, authenticated;
revoke all on public.current_valid_cafe_audits from anon, authenticated;

notify pgrst, 'reload schema';
