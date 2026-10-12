-- =========================================================
-- KapéDoko — card sidecar RPC (amenities, pay, stats, tiers)
-- =========================================================
-- GET ?shop_id=in.(hundreds of uuids) 400s on PostgREST. Cafe
-- detail works because it uses shop_id=eq.<one>. This RPC takes
-- ids in the POST body and reads the public views as owner.
-- Run AFTER 20261007_shop_payment_public.sql. Safe to re-run.
-- =========================================================

create or replace function public.shop_card_sidecars(p_shop_ids uuid[])
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'amenities', coalesce((
      select jsonb_agg(to_jsonb(a))
      from public.shop_amenity_resolutions_public a
      where a.shop_id = any(p_shop_ids)
    ), '[]'::jsonb),
    'payments', coalesce((
      select jsonb_agg(to_jsonb(p))
      from public.shop_payment_public p
      where p.shop_id = any(p_shop_ids)
    ), '[]'::jsonb),
    'stats', coalesce((
      select jsonb_agg(to_jsonb(s))
      from public.shop_review_stats s
      where s.shop_id = any(p_shop_ids)
    ), '[]'::jsonb),
    'tiers', coalesce((
      select jsonb_agg(to_jsonb(t))
      from public.shop_marker_tiers t
      where t.shop_id = any(p_shop_ids)
    ), '[]'::jsonb)
  );
$$;

comment on function public.shop_card_sidecars(uuid[]) is
  'Card amenity, payment, stats, and pin tier for a shop id list. POST body, not a GET in() filter.';

revoke all on function public.shop_card_sidecars(uuid[]) from public;
grant execute on function public.shop_card_sidecars(uuid[]) to anon, authenticated;

notify pgrst, 'reload schema';
