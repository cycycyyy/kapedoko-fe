-- =========================================================
-- KapéDoko — QR / card / cash observed on a team visit
-- =========================================================
-- Run AFTER 20261003_amenity_source_of_truth.sql. Safe to re-run.
-- Adds payment facts to cafe_audits and submit_cafe_audit.
-- =========================================================

alter table public.cafe_audits
  add column if not exists accepts_qr text,
  add column if not exists accepts_card text,
  add column if not exists accepts_cash text;

alter table public.cafe_audits drop constraint if exists cafe_audits_accepts_qr_check;
alter table public.cafe_audits add constraint cafe_audits_accepts_qr_check
  check (accepts_qr is null or accepts_qr in ('available', 'unavailable', 'unknown'));

alter table public.cafe_audits drop constraint if exists cafe_audits_accepts_card_check;
alter table public.cafe_audits add constraint cafe_audits_accepts_card_check
  check (accepts_card is null or accepts_card in ('available', 'unavailable', 'unknown'));

alter table public.cafe_audits drop constraint if exists cafe_audits_accepts_cash_check;
alter table public.cafe_audits add constraint cafe_audits_accepts_cash_check
  check (accepts_cash is null or accepts_cash in ('available', 'unavailable', 'unknown'));

comment on column public.cafe_audits.accepts_qr is
  'QR / e-wallet payment observed on this visit: available, unavailable, or unknown.';
comment on column public.cafe_audits.accepts_card is
  'Card payment observed on this visit: available, unavailable, or unknown.';
comment on column public.cafe_audits.accepts_cash is
  'Cash payment observed on this visit: available, unavailable, or unknown.';

create or replace view public.current_valid_cafe_audits
with (security_invoker = false) as
select distinct on (a.shop_id)
  a.*
from public.cafe_audits a
left join public.cafe_audit_voids v on v.audit_id = a.id
where v.audit_id is null
order by a.shop_id, a.audited_at desc, a.created_at desc;

revoke all on public.current_valid_cafe_audits from anon, authenticated;

drop function if exists public.submit_cafe_audit(uuid, uuid, jsonb, jsonb, text, boolean, timestamptz, text, time, integer, text, uuid);

create or replace function public.submit_cafe_audit(
  p_shop_id uuid,
  p_idempotency_key uuid,
  p_wifi jsonb,
  p_outlets jsonb,
  p_long_stay_stance text,
  p_staff_confirmed_long_stay boolean default false,
  p_audited_at timestamptz default now(),
  p_timezone text default 'Asia/Manila',
  p_time_of_day_local time default null,
  p_seating_capacity_estimate integer default null,
  p_notes text default null,
  p_corrects_audit_id uuid default null,
  p_accepts_qr text default null,
  p_accepts_card text default null,
  p_accepts_cash text default null
)
returns public.cafe_audits
language plpgsql
security definer
set search_path = public
as $$
declare
  created public.cafe_audits;
  shop_status text;
  wifi_result text;
  outlet_result text;
  long_stay_result text;
  prior public.cafe_audits;
  prior_voided boolean;
begin
  if not public.is_auditor() then
    raise exception 'Auditor only';
  end if;
  if p_idempotency_key is null then
    raise exception 'Missing idempotency key';
  end if;

  select * into created
  from public.cafe_audits
  where client_idempotency_key = p_idempotency_key;
  if created.id is not null then
    return created;
  end if;

  select status::text into shop_status from public.shops where id = p_shop_id;
  if shop_status is null then
    raise exception 'Cafe was not found';
  end if;
  if shop_status <> 'approved' then
    raise exception 'Only approved cafes can be audited';
  end if;

  if p_long_stay_stance is null or p_long_stay_stance not in ('welcome', 'discouraged', 'unknown') then
    raise exception 'Choose a long-stay stance.';
  end if;
  if p_seating_capacity_estimate is not null and p_seating_capacity_estimate < 0 then
    raise exception 'Seating capacity cannot be negative.';
  end if;
  if p_accepts_qr is null or p_accepts_qr not in ('available', 'unavailable', 'unknown') then
    raise exception 'Choose whether QR payment worked.';
  end if;
  if p_accepts_card is null or p_accepts_card not in ('available', 'unavailable', 'unknown') then
    raise exception 'Choose whether card payment worked.';
  end if;
  if p_accepts_cash is null or p_accepts_cash not in ('available', 'unavailable', 'unknown') then
    raise exception 'Choose whether cash payment worked.';
  end if;

  wifi_result := coalesce(p_wifi->>'result', '');
  outlet_result := coalesce(p_outlets->>'result', '');
  if wifi_result not in ('available', 'unavailable', 'unknown') then
    raise exception 'Choose a WiFi result.';
  end if;
  if outlet_result not in ('available', 'unavailable', 'unknown') then
    raise exception 'Choose an outlet result.';
  end if;
  if wifi_result = 'unknown' and char_length(btrim(coalesce(p_wifi->>'notes', ''))) < 4 then
    raise exception 'Say why WiFi is unknown.';
  end if;
  if outlet_result = 'unknown' and char_length(btrim(coalesce(p_outlets->>'notes', p_outlets->>'reliability_notes', ''))) < 4 then
    raise exception 'Say why outlets are unknown.';
  end if;
  if outlet_result = 'available' and coalesce(p_outlets->>'reliability', '') not in ('easy', 'limited', 'scarce') then
    raise exception 'Choose outlet reliability.';
  end if;

  if p_corrects_audit_id is not null then
    select * into prior from public.cafe_audits where id = p_corrects_audit_id;
    if prior.id is null then
      raise exception 'That audit was not found.';
    end if;
    if prior.shop_id is distinct from p_shop_id then
      raise exception 'Corrections must stay on the same cafe.';
    end if;
    select exists (select 1 from public.cafe_audit_voids where audit_id = prior.id) into prior_voided;
    if prior_voided then
      raise exception 'Cannot correct a voided audit.';
    end if;
    if not public.is_admin() and prior.auditor_id is distinct from auth.uid() then
      raise exception 'You can only correct your own audit.';
    end if;
  end if;

  if wifi_result = 'available' and p_long_stay_stance = 'welcome' then
    long_stay_result := 'available';
  elsif wifi_result = 'unavailable' or (wifi_result = 'available' and p_long_stay_stance = 'discouraged') then
    long_stay_result := 'unavailable';
  else
    long_stay_result := 'unknown';
  end if;

  insert into public.cafe_audits (
    shop_id,
    auditor_id,
    audited_at,
    timezone,
    time_of_day_local,
    seating_capacity_estimate,
    long_stay_stance,
    staff_confirmed_long_stay,
    notes,
    corrects_audit_id,
    client_idempotency_key,
    accepts_qr,
    accepts_card,
    accepts_cash
  )
  values (
    p_shop_id,
    auth.uid(),
    coalesce(p_audited_at, now()),
    coalesce(nullif(btrim(p_timezone), ''), 'Asia/Manila'),
    p_time_of_day_local,
    p_seating_capacity_estimate,
    p_long_stay_stance,
    coalesce(p_staff_confirmed_long_stay, false),
    nullif(btrim(coalesce(p_notes, '')), ''),
    p_corrects_audit_id,
    p_idempotency_key,
    p_accepts_qr,
    p_accepts_card,
    p_accepts_cash
  )
  returning * into created;

  insert into public.cafe_audit_amenity_results (
    audit_id, amenity_key, result,
    wifi_download_mbps, wifi_upload_mbps, wifi_network_name, wifi_password_required,
    amenity_notes
  )
  values (
    created.id,
    'wifi',
    wifi_result,
    nullif(p_wifi->>'download_mbps', '')::numeric,
    nullif(p_wifi->>'upload_mbps', '')::numeric,
    nullif(btrim(coalesce(p_wifi->>'network_name', '')), ''),
    case when p_wifi ? 'password_required' then (p_wifi->>'password_required')::boolean else null end,
    nullif(btrim(coalesce(p_wifi->>'notes', '')), '')
  );

  insert into public.cafe_audit_amenity_results (
    audit_id, amenity_key, result,
    outlet_approx_count, outlet_reliability, seating_near_outlet_notes, reliability_notes, amenity_notes
  )
  values (
    created.id,
    'outlets',
    outlet_result,
    nullif(p_outlets->>'approx_count', '')::integer,
    nullif(p_outlets->>'reliability', ''),
    nullif(btrim(coalesce(p_outlets->>'seating_near_outlet_notes', '')), ''),
    nullif(btrim(coalesce(p_outlets->>'reliability_notes', '')), ''),
    nullif(btrim(coalesce(p_outlets->>'notes', '')), '')
  );

  insert into public.cafe_audit_amenity_results (audit_id, amenity_key, result)
  values (created.id, 'long_stay_wifi', long_stay_result);

  perform public.admin_write_audit(
    'audit.create',
    'cafe_audit',
    created.id::text,
    jsonb_build_object(
      'shop_id', created.shop_id,
      'corrects_audit_id', created.corrects_audit_id,
      'wifi', wifi_result,
      'outlets', outlet_result,
      'accepts_qr', p_accepts_qr,
      'accepts_card', p_accepts_card,
      'accepts_cash', p_accepts_cash
    )
  );

  return created;
end;
$$;

revoke all on function public.submit_cafe_audit(uuid, uuid, jsonb, jsonb, text, boolean, timestamptz, text, time, integer, text, uuid, text, text, text) from public, anon;
grant execute on function public.submit_cafe_audit(uuid, uuid, jsonb, jsonb, text, boolean, timestamptz, text, time, integer, text, uuid, text, text, text) to authenticated;

notify pgrst, 'reload schema';
