-- =========================================================
-- KapéDoko — Amenity resolution views
-- =========================================================
-- Run AFTER 20261003_amenity_source_of_truth.sql.
-- Postgres is the source of truth. Public clients read
-- shop_amenity_resolutions_public only.
-- Majority uses STRICT greater-than of community_majority_ratio
-- (default 0.5), i.e. yes_count > no_count for integer votes.
-- =========================================================

create or replace view public.review_amenity_votes
with (security_invoker = false) as
select
  r.shop_id,
  r.id as review_id,
  'wifi'::text as amenity_key,
  r.wifi_available as vote,
  1.0::numeric as vote_weight,
  r.updated_at as voted_at
from public.reviews r
join public.shops s on s.id = r.shop_id
where s.status = 'approved'
  and r.flagged_at is null

union all

select
  r.shop_id,
  r.id,
  'outlets',
  r.power_available,
  1.0,
  r.updated_at
from public.reviews r
join public.shops s on s.id = r.shop_id
where s.status = 'approved'
  and r.flagged_at is null

union all

select
  r.shop_id,
  r.id,
  'long_stay_wifi',
  case
    when r.wifi_available = 'yes' and r.wifi_time_limit = 'unlimited' and r.stay_fit = 'long' then 'yes'
    when r.wifi_available = 'no' then 'no'
    when r.wifi_available = 'yes' and r.wifi_time_limit in ('voucher', 'purchase') then 'no'
    when r.wifi_available = 'yes' and r.stay_fit = 'short' then 'no'
    else 'unsure'
  end,
  1.0,
  r.updated_at
from public.reviews r
join public.shops s on s.id = r.shop_id
where s.status = 'approved'
  and r.flagged_at is null;

comment on view public.review_amenity_votes is
  'Normalized amenity votes. vote_weight is the future weighting seam and stays 1.0.';

create or replace view public.community_amenity_rollups
with (security_invoker = false) as
select
  shop_id,
  amenity_key,
  coalesce(sum(vote_weight) filter (where vote in ('yes', 'no')), 0) as decided_count,
  coalesce(sum(vote_weight) filter (where vote = 'yes'), 0) as yes_count,
  coalesce(sum(vote_weight) filter (where vote = 'no'), 0) as no_count,
  max(voted_at) filter (where vote in ('yes', 'no')) as last_voted_at
from public.review_amenity_votes
group by shop_id, amenity_key;

create or replace view public.current_valid_cafe_audits
with (security_invoker = false) as
select distinct on (a.shop_id)
  a.*
from public.cafe_audits a
left join public.cafe_audit_voids v on v.audit_id = a.id
where v.audit_id is null
order by a.shop_id, a.audited_at desc, a.created_at desc;

create or replace view public.current_valid_amenity_reports
with (security_invoker = false) as
select distinct on (r.shop_id, r.amenity_key)
  r.*
from public.cafe_amenity_reports r
left join public.cafe_amenity_report_voids v on v.report_id = r.id
where v.report_id is null
order by r.shop_id, r.amenity_key, r.observed_at desc, r.created_at desc;

create or replace function public.amenity_majority_side(
  p_yes numeric,
  p_no numeric,
  p_ratio numeric
)
returns text
language sql
immutable
as $$
  select case
    when coalesce(p_yes, 0) + coalesce(p_no, 0) <= 0 then null
    when coalesce(p_yes, 0) / (coalesce(p_yes, 0) + coalesce(p_no, 0)) > p_ratio then 'available'
    when coalesce(p_no, 0) / (coalesce(p_yes, 0) + coalesce(p_no, 0)) > p_ratio then 'unavailable'
    else 'mixed'
  end;
$$;

-- SECURITY DEFINER is required: views with security_invoker = false still
-- invoke functions as the current role. Without definer, selecting
-- shop_amenity_resolutions_public fails with permission denied on
-- review_amenity_votes (revoked from anon/authenticated).
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

create or replace view public.shop_amenity_resolutions
with (security_invoker = false) as
select
  s.id as shop_id,
  cfg.amenity_key,
  case
    when not cfg.enabled then 'unknown'
    when ar.result in ('available', 'unavailable') then ar.result
    when public.amenity_majority_side(c.yes_count, c.no_count, cfg.community_majority_ratio) is not null
      then public.amenity_majority_side(c.yes_count, c.no_count, cfg.community_majority_ratio)
    when seed.result in ('available', 'unavailable') then seed.result
    else 'unknown'
  end as availability,
  case
    when not cfg.enabled then 'unknown'
    when ar.result in ('available', 'unavailable') then 'team_verified'
    when coalesce(c.decided_count, 0) >= cfg.community_min_decided then 'community_confirmed'
    when coalesce(c.decided_count, 0) >= 1 then 'reported'
    when seed.result is not null then 'reported'
    else 'unknown'
  end as confidence,
  case
    when not cfg.enabled then null
    when ar.result in ('available', 'unavailable') then a.audited_at
    when coalesce(c.decided_count, 0) >= 1 then c.last_voted_at
    when seed.result is not null then seed.observed_at
    else null
  end as source_at,
  coalesce(c.decided_count, 0)::int as decided_count,
  coalesce(c.yes_count, 0)::int as yes_count,
  coalesce(c.no_count, 0)::int as no_count,
  (
    ar.result in ('available', 'unavailable')
    and a.audited_at < now() - make_interval(days => cfg.stale_after_days)
  ) as is_stale,
  coalesce(
    public.amenity_needs_recheck(
      s.id,
      cfg.amenity_key,
      ar.result,
      a.audited_at,
      cfg.contradiction_min_decided,
      cfg.community_majority_ratio,
      cfg.contradiction_window_days
    ),
    false
  ) as needs_recheck,
  case
    when cfg.amenity_key = 'wifi' and ar.result = 'available' and ar.wifi_download_mbps is not null then
      case
        when ar.wifi_download_mbps >= cfg.fast_download_mbps then 'fast'
        when ar.wifi_download_mbps >= 10 then 'okay'
        else 'slow'
      end
    when cfg.amenity_key = 'wifi' and ar.result in ('available', 'unavailable') then null
    when cfg.amenity_key = 'wifi' then stats.wifi_speed_mode
    else null
  end as wifi_speed,
  case
    when cfg.amenity_key = 'wifi' and ar.result = 'available' and a.long_stay_stance = 'welcome' then 'unlimited'
    when cfg.amenity_key = 'wifi' and ar.result in ('available', 'unavailable') then null
    when cfg.amenity_key = 'wifi' then stats.wifi_time_limit_mode
    else null
  end as wifi_time_limit,
  case
    when cfg.amenity_key = 'outlets' and ar.result = 'available' then ar.outlet_reliability
    when cfg.amenity_key = 'outlets' and ar.result in ('available', 'unavailable') then null
    when cfg.amenity_key = 'outlets' then stats.power_access_mode
    else null
  end as outlet_reliability,
  a.id as audit_id,
  a.auditor_id,
  a.audited_at
from public.shops s
cross join public.amenity_resolution_config cfg
left join public.current_valid_cafe_audits a on a.shop_id = s.id
left join public.cafe_audit_amenity_results ar
  on ar.audit_id = a.id and ar.amenity_key = cfg.amenity_key
left join public.community_amenity_rollups c
  on c.shop_id = s.id and c.amenity_key = cfg.amenity_key
left join public.current_valid_amenity_reports seed
  on seed.shop_id = s.id and seed.amenity_key = cfg.amenity_key
left join public.shop_review_stats stats on stats.shop_id = s.id
where s.status = 'approved';

comment on view public.shop_amenity_resolutions is
  'Internal amenity resolver including staff ids. Do not grant to anon.';

create or replace view public.shop_amenity_resolutions_public
with (security_invoker = false) as
select
  shop_id,
  amenity_key,
  availability,
  confidence,
  source_at,
  decided_count,
  yes_count,
  no_count,
  is_stale,
  needs_recheck,
  wifi_speed,
  wifi_time_limit,
  outlet_reliability
from public.shop_amenity_resolutions;

comment on view public.shop_amenity_resolutions_public is
  'Safe amenity status for cards, filters, and cafe detail. No auditor ids, SSIDs, or notes.';

revoke all on public.review_amenity_votes from anon, authenticated;
revoke all on public.community_amenity_rollups from anon, authenticated;
revoke all on public.current_valid_cafe_audits from anon, authenticated;
revoke all on public.current_valid_amenity_reports from anon, authenticated;
revoke all on public.shop_amenity_resolutions from anon, authenticated;

grant select on public.shop_amenity_resolutions_public to anon, authenticated;

revoke all on function public.amenity_needs_recheck(uuid, text, text, timestamptz, integer, numeric, integer) from public;
grant execute on function public.amenity_needs_recheck(uuid, text, text, timestamptz, integer, numeric, integer) to anon, authenticated;

notify pgrst, 'reload schema';
