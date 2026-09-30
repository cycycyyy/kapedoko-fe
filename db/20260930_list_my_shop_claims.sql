-- =========================================================
-- KapéDoko — List the signed-in user's ownership claims
-- =========================================================
-- Profile was reading shop_claims through PostgREST with a
-- stale Ionic user id, so a real pending/rejected claim
-- looked empty. This RPC uses auth.uid() and returns cafe
-- names in the same round trip (security definer).
-- =========================================================

create or replace function public.list_my_shop_claims()
returns table (
  id uuid,
  shop_id uuid,
  shop_name text,
  claimant_id uuid,
  status text,
  evidence_note text,
  contact_email text,
  contact_phone text,
  rejection_reason text,
  reviewed_by uuid,
  reviewed_at timestamptz,
  created_at timestamptz,
  updated_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    c.id,
    c.shop_id,
    coalesce(s.name, 'This cafe') as shop_name,
    c.claimant_id,
    c.status,
    c.evidence_note,
    c.contact_email,
    c.contact_phone,
    c.rejection_reason,
    c.reviewed_by,
    c.reviewed_at,
    c.created_at,
    c.updated_at
  from public.shop_claims c
  left join public.shops s on s.id = c.shop_id
  where c.claimant_id = auth.uid()
  order by c.created_at desc;
$$;

revoke all on function public.list_my_shop_claims() from public, anon;
grant execute on function public.list_my_shop_claims() to authenticated;

notify pgrst, 'reload schema';
