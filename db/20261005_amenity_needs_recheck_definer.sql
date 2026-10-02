-- =========================================================
-- KapéDoko — amenity_needs_recheck must run as owner
-- =========================================================
-- Run AFTER 20261004_amenity_resolutions.sql. Safe to re-run.
-- shop_amenity_resolutions_public calls this function; a
-- SECURITY INVOKER function still reads review_amenity_votes as
-- the signed-in role, which is revoked. That shows up as
-- "permission denied for view review_amenity_votes".
-- =========================================================

create or replace function public.amenity_needs_recheck(
  p_shop_id uuid,
  p_amenity_key text,
  p_audit_result text,
  p_audited_at timestamptz,
  p_min integer,
  p_ratio numeric,
  p_window_days integer
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  with recent as (
    select
      coalesce(sum(vote_weight) filter (where vote in ('yes', 'no')), 0) as decided,
      coalesce(sum(vote_weight) filter (where vote = 'yes'), 0) as yes_count,
      coalesce(sum(vote_weight) filter (where vote = 'no'), 0) as no_count
    from public.review_amenity_votes
    where shop_id = p_shop_id
      and amenity_key = p_amenity_key
      and vote in ('yes', 'no')
      and voted_at > p_audited_at
      and voted_at >= now() - make_interval(days => p_window_days)
  )
  select
    p_audit_result in ('available', 'unavailable')
    and recent.decided >= p_min
    and recent.decided > 0
    and (
      (p_audit_result = 'available' and recent.no_count / recent.decided > p_ratio)
      or (p_audit_result = 'unavailable' and recent.yes_count / recent.decided > p_ratio)
    )
  from recent;
$$;

revoke all on function public.amenity_needs_recheck(uuid, text, text, timestamptz, integer, numeric, integer) from public;
grant execute on function public.amenity_needs_recheck(uuid, text, text, timestamptz, integer, numeric, integer) to anon, authenticated;

notify pgrst, 'reload schema';
