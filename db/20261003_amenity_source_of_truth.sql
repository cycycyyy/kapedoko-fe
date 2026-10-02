-- =========================================================
-- KapéDoko — Amenity source of truth (tables, RPCs, RLS)
-- =========================================================
-- Run AFTER 20261002_user_role_auditor.sql (own query) so the
-- auditor enum label is committed. Additive: does not change
-- reviews or shop_review_stats. Apply views next from
-- 20261004_amenity_resolutions.sql.
-- =========================================================

-- --- Roles ---
create or replace function public.is_auditor()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role::text in ('admin', 'auditor')
  );
$$;

update public.profiles
set role = 'user'
where role is null
   or role::text not in ('user', 'cafe-owner', 'admin', 'auditor');

alter table public.profiles drop constraint if exists profiles_role_known;
do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'role'
      and data_type = 'text'
  ) then
    execute $c$
      alter table public.profiles add constraint profiles_role_known
        check (role in ('user', 'cafe-owner', 'admin', 'auditor'))
    $c$;
  end if;
end
$$;

create or replace function public.sync_cafe_owner_role(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_role text;
  has_verified boolean;
  next_role text;
begin
  select role::text into current_role from public.profiles where id = p_user_id;
  if current_role is null or current_role in ('admin', 'auditor') then
    return;
  end if;

  select exists (
    select 1 from public.shop_claims
    where claimant_id = p_user_id
      and status = 'verified'
  ) into has_verified;

  next_role := case when has_verified then 'cafe-owner' else 'user' end;

  update public.profiles
  set role = next_role::public.user_role
  where id = p_user_id
    and role::text is distinct from next_role;
end;
$$;

create or replace function public.admin_set_profile_role(
  p_user_id uuid,
  p_role text
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  updated public.profiles;
  remaining_admins integer;
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;
  if p_role not in ('user', 'cafe-owner', 'admin', 'auditor') then
    raise exception 'Unknown role';
  end if;
  if p_user_id = auth.uid() then
    raise exception 'You cannot change your own role.';
  end if;

  if p_role <> 'admin' then
    select count(*) into remaining_admins
    from public.profiles
    where role::text = 'admin'
      and id <> p_user_id;
    if remaining_admins < 1 then
      raise exception 'Cannot demote the last admin.';
    end if;
  end if;

  update public.profiles
  set role = p_role::public.user_role
  where id = p_user_id
  returning * into updated;

  if updated.id is null then
    raise exception 'User was not found';
  end if;

  perform public.admin_write_audit(
    'user.role',
    'profile',
    updated.id::text,
    jsonb_build_object('role', p_role)
  );
  return updated;
end;
$$;

-- --- Config ---
-- community_majority_ratio 0.5 is compared with STRICT greater-than
-- (yes_share > 0.5). For integer vote counts that is yes_count > no_count.
-- Do not change the view to >= or ties become availability.
create table if not exists public.amenity_resolution_config (
  amenity_key text primary key,
  enabled boolean not null default true,
  community_min_decided integer not null default 3,
  community_majority_ratio numeric not null default 0.5,
  contradiction_min_decided integer not null default 3,
  contradiction_window_days integer not null default 90,
  stale_after_days integer not null default 180,
  fast_download_mbps numeric not null default 25,
  updated_at timestamptz not null default now(),
  updated_by uuid,
  constraint amenity_resolution_config_key_check
    check (amenity_key in ('wifi', 'outlets', 'long_stay_wifi')),
  constraint amenity_resolution_config_min_check
    check (community_min_decided >= 1 and contradiction_min_decided >= 1),
  constraint amenity_resolution_config_ratio_check
    check (community_majority_ratio > 0 and community_majority_ratio < 1),
  constraint amenity_resolution_config_window_check
    check (contradiction_window_days >= 1 and stale_after_days >= 1),
  constraint amenity_resolution_config_fast_check
    check (fast_download_mbps >= 0)
);

insert into public.amenity_resolution_config (amenity_key)
values ('wifi'), ('outlets'), ('long_stay_wifi')
on conflict (amenity_key) do nothing;

comment on table public.amenity_resolution_config is
  'Thresholds for amenity resolution. Public clients read resolved views only.';

alter table public.amenity_resolution_config enable row level security;
alter table public.amenity_resolution_config force row level security;

drop policy if exists amenity_resolution_config_admin_all on public.amenity_resolution_config;
create policy amenity_resolution_config_admin_all
  on public.amenity_resolution_config
  for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

revoke all on public.amenity_resolution_config from anon, authenticated;
grant select, update on public.amenity_resolution_config to authenticated;

-- --- Audits (append-only) ---
create table if not exists public.cafe_audits (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.shops(id) on delete restrict,
  auditor_id uuid not null,
  audited_at timestamptz not null default now(),
  timezone text not null default 'Asia/Manila',
  time_of_day_local time,
  seating_capacity_estimate integer,
  long_stay_stance text not null,
  staff_confirmed_long_stay boolean not null default false,
  notes text,
  corrects_audit_id uuid references public.cafe_audits(id) on delete restrict,
  client_idempotency_key uuid not null,
  created_at timestamptz not null default now(),
  constraint cafe_audits_long_stay_stance_check
    check (long_stay_stance in ('welcome', 'discouraged', 'unknown')),
  constraint cafe_audits_capacity_check
    check (seating_capacity_estimate is null or seating_capacity_estimate >= 0),
  constraint cafe_audits_notes_len
    check (notes is null or char_length(notes) <= 2000),
  constraint cafe_audits_timezone_len
    check (char_length(timezone) between 1 and 64)
);

create unique index if not exists cafe_audits_idempotency_uidx
  on public.cafe_audits (client_idempotency_key);

create index if not exists cafe_audits_shop_audited_idx
  on public.cafe_audits (shop_id, audited_at desc, created_at desc);

comment on table public.cafe_audits is
  'Append-only KapeDoko on-site amenity audits. Corrections insert a new row.';

create table if not exists public.cafe_audit_amenity_results (
  audit_id uuid not null references public.cafe_audits(id) on delete restrict,
  amenity_key text not null,
  result text not null,
  wifi_download_mbps numeric,
  wifi_upload_mbps numeric,
  wifi_network_name text,
  wifi_password_required boolean,
  outlet_approx_count integer,
  outlet_reliability text,
  seating_near_outlet_notes text,
  reliability_notes text,
  amenity_notes text,
  primary key (audit_id, amenity_key),
  constraint cafe_audit_results_key_check
    check (amenity_key in ('wifi', 'outlets', 'long_stay_wifi')),
  constraint cafe_audit_results_result_check
    check (result in ('available', 'unavailable', 'unknown')),
  constraint cafe_audit_results_wifi_speed_check
    check (
      wifi_download_mbps is null or wifi_download_mbps >= 0
    ),
  constraint cafe_audit_results_wifi_upload_check
    check (
      wifi_upload_mbps is null or wifi_upload_mbps >= 0
    ),
  constraint cafe_audit_results_outlet_count_check
    check (outlet_approx_count is null or outlet_approx_count >= 0),
  constraint cafe_audit_results_reliability_check
    check (outlet_reliability is null or outlet_reliability in ('easy', 'limited', 'scarce')),
  constraint cafe_audit_results_wifi_fields_check
    check (
      amenity_key <> 'wifi'
      or (
        wifi_network_name is null or char_length(wifi_network_name) <= 80
      )
    ),
  constraint cafe_audit_results_outlet_when_available
    check (
      amenity_key <> 'outlets'
      or result <> 'available'
      or outlet_reliability is not null
    ),
  constraint cafe_audit_results_wifi_only_fields
    check (
      amenity_key = 'wifi'
      or (
        wifi_download_mbps is null
        and wifi_upload_mbps is null
        and wifi_network_name is null
        and wifi_password_required is null
      )
    ),
  constraint cafe_audit_results_outlet_only_fields
    check (
      amenity_key = 'outlets'
      or (
        outlet_approx_count is null
        and outlet_reliability is null
        and seating_near_outlet_notes is null
      )
    )
);

create table if not exists public.cafe_audit_photos (
  id uuid primary key default gen_random_uuid(),
  audit_id uuid not null references public.cafe_audits(id) on delete restrict,
  object_key text not null,
  content_type text,
  byte_size integer,
  caption text,
  created_by uuid not null,
  created_at timestamptz not null default now(),
  constraint cafe_audit_photos_key_format
    check (object_key ~ '^[a-zA-Z0-9][a-zA-Z0-9/_.:-]*$'),
  constraint cafe_audit_photos_key_prefix
    check (object_key like 'audit-photos/%'),
  constraint cafe_audit_photos_type_check
    check (content_type is null or content_type in ('image/jpeg', 'image/png', 'image/webp')),
  constraint cafe_audit_photos_size_check
    check (byte_size is null or (byte_size > 0 and byte_size <= 4194304)),
  constraint cafe_audit_photos_caption_len
    check (caption is null or char_length(caption) <= 140)
);

create index if not exists cafe_audit_photos_audit_idx
  on public.cafe_audit_photos (audit_id, created_at);

create table if not exists public.cafe_audit_voids (
  audit_id uuid primary key references public.cafe_audits(id) on delete restrict,
  actor_id uuid not null,
  reason text not null,
  created_at timestamptz not null default now(),
  constraint cafe_audit_voids_reason_len
    check (char_length(btrim(reason)) >= 8 and char_length(reason) <= 500)
);

create table if not exists public.cafe_amenity_reports (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.shops(id) on delete restrict,
  amenity_key text not null,
  result text not null,
  observed_at timestamptz not null,
  source text not null default 'founder_seed',
  import_batch_id uuid not null,
  source_row_key text not null,
  notes text,
  created_by uuid not null,
  created_at timestamptz not null default now(),
  constraint cafe_amenity_reports_key_check
    check (amenity_key in ('wifi', 'outlets', 'long_stay_wifi')),
  constraint cafe_amenity_reports_result_check
    check (result in ('available', 'unavailable')),
  constraint cafe_amenity_reports_source_len
    check (char_length(source) between 1 and 64),
  constraint cafe_amenity_reports_row_key_len
    check (char_length(source_row_key) between 1 and 120)
);

create unique index if not exists cafe_amenity_reports_source_row_uidx
  on public.cafe_amenity_reports (source, source_row_key);

create index if not exists cafe_amenity_reports_shop_idx
  on public.cafe_amenity_reports (shop_id, amenity_key, observed_at desc);

create table if not exists public.cafe_amenity_report_voids (
  report_id uuid primary key references public.cafe_amenity_reports(id) on delete restrict,
  actor_id uuid not null,
  reason text not null,
  created_at timestamptz not null default now(),
  constraint cafe_amenity_report_voids_reason_len
    check (char_length(btrim(reason)) >= 8 and char_length(reason) <= 500)
);

create index if not exists reviews_shop_updated_unflagged_idx
  on public.reviews (shop_id, updated_at desc)
  where flagged_at is null;

-- Immutability
create or replace function public.forbid_amenity_row_mutate()
returns trigger
language plpgsql
as $$
begin
  raise exception '% are append-only', tg_table_name;
end;
$$;

drop trigger if exists cafe_audits_forbid_mutate on public.cafe_audits;
create trigger cafe_audits_forbid_mutate
  before update or delete on public.cafe_audits
  for each row execute procedure public.forbid_amenity_row_mutate();

drop trigger if exists cafe_audit_amenity_results_forbid_mutate on public.cafe_audit_amenity_results;
create trigger cafe_audit_amenity_results_forbid_mutate
  before update or delete on public.cafe_audit_amenity_results
  for each row execute procedure public.forbid_amenity_row_mutate();

drop trigger if exists cafe_audit_photos_forbid_mutate on public.cafe_audit_photos;
create trigger cafe_audit_photos_forbid_mutate
  before update or delete on public.cafe_audit_photos
  for each row execute procedure public.forbid_amenity_row_mutate();

drop trigger if exists cafe_audit_voids_forbid_mutate on public.cafe_audit_voids;
create trigger cafe_audit_voids_forbid_mutate
  before update or delete on public.cafe_audit_voids
  for each row execute procedure public.forbid_amenity_row_mutate();

drop trigger if exists cafe_amenity_reports_forbid_mutate on public.cafe_amenity_reports;
create trigger cafe_amenity_reports_forbid_mutate
  before update or delete on public.cafe_amenity_reports
  for each row execute procedure public.forbid_amenity_row_mutate();

drop trigger if exists cafe_amenity_report_voids_forbid_mutate on public.cafe_amenity_report_voids;
create trigger cafe_amenity_report_voids_forbid_mutate
  before update or delete on public.cafe_amenity_report_voids
  for each row execute procedure public.forbid_amenity_row_mutate();

-- --- RLS ---
alter table public.cafe_audits enable row level security;
alter table public.cafe_audits force row level security;
alter table public.cafe_audit_amenity_results enable row level security;
alter table public.cafe_audit_amenity_results force row level security;
alter table public.cafe_audit_photos enable row level security;
alter table public.cafe_audit_photos force row level security;
alter table public.cafe_audit_voids enable row level security;
alter table public.cafe_audit_voids force row level security;
alter table public.cafe_amenity_reports enable row level security;
alter table public.cafe_amenity_reports force row level security;
alter table public.cafe_amenity_report_voids enable row level security;
alter table public.cafe_amenity_report_voids force row level security;

drop policy if exists cafe_audits_staff_select on public.cafe_audits;
create policy cafe_audits_staff_select
  on public.cafe_audits for select to authenticated
  using (public.is_auditor());

drop policy if exists cafe_audit_results_staff_select on public.cafe_audit_amenity_results;
create policy cafe_audit_results_staff_select
  on public.cafe_audit_amenity_results for select to authenticated
  using (public.is_auditor());

drop policy if exists cafe_audit_photos_staff_select on public.cafe_audit_photos;
create policy cafe_audit_photos_staff_select
  on public.cafe_audit_photos for select to authenticated
  using (public.is_auditor());

drop policy if exists cafe_audit_voids_staff_select on public.cafe_audit_voids;
create policy cafe_audit_voids_staff_select
  on public.cafe_audit_voids for select to authenticated
  using (public.is_auditor());

drop policy if exists cafe_amenity_reports_staff_select on public.cafe_amenity_reports;
create policy cafe_amenity_reports_staff_select
  on public.cafe_amenity_reports for select to authenticated
  using (public.is_auditor());

drop policy if exists cafe_amenity_report_voids_staff_select on public.cafe_amenity_report_voids;
create policy cafe_amenity_report_voids_staff_select
  on public.cafe_amenity_report_voids for select to authenticated
  using (public.is_auditor());

revoke all on public.cafe_audits from anon, authenticated;
revoke all on public.cafe_audit_amenity_results from anon, authenticated;
revoke all on public.cafe_audit_photos from anon, authenticated;
revoke all on public.cafe_audit_voids from anon, authenticated;
revoke all on public.cafe_amenity_reports from anon, authenticated;
revoke all on public.cafe_amenity_report_voids from anon, authenticated;
grant select on public.cafe_audits to authenticated;
grant select on public.cafe_audit_amenity_results to authenticated;
grant select on public.cafe_audit_photos to authenticated;
grant select on public.cafe_audit_voids to authenticated;
grant select on public.cafe_amenity_reports to authenticated;
grant select on public.cafe_amenity_report_voids to authenticated;

-- --- RPCs ---
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
  p_corrects_audit_id uuid default null
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
    client_idempotency_key
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
    p_idempotency_key
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
      'outlets', outlet_result
    )
  );

  return created;
end;
$$;

create or replace function public.attach_cafe_audit_photo(
  p_audit_id uuid,
  p_object_key text,
  p_content_type text default null,
  p_byte_size integer default null,
  p_caption text default null
)
returns public.cafe_audit_photos
language plpgsql
security definer
set search_path = public
as $$
declare
  audit public.cafe_audits;
  photo_count integer;
  created public.cafe_audit_photos;
  expected_prefix text;
begin
  if not public.is_auditor() then
    raise exception 'Auditor only';
  end if;

  select * into audit from public.cafe_audits where id = p_audit_id;
  if audit.id is null then
    raise exception 'That audit was not found.';
  end if;
  if not public.is_admin() and audit.auditor_id is distinct from auth.uid() then
    raise exception 'You can only attach photos to your own audit.';
  end if;

  expected_prefix := 'audit-photos/' || auth.uid()::text || '/';
  if p_object_key is null or p_object_key not like expected_prefix || '%' then
    raise exception 'That photo does not belong to this upload.';
  end if;

  select count(*) into photo_count from public.cafe_audit_photos where audit_id = p_audit_id;
  if photo_count >= 3 then
    raise exception 'Keep audit photos to three.';
  end if;

  insert into public.cafe_audit_photos (audit_id, object_key, content_type, byte_size, caption, created_by)
  values (
    p_audit_id,
    p_object_key,
    p_content_type,
    p_byte_size,
    nullif(btrim(coalesce(p_caption, '')), ''),
    auth.uid()
  )
  returning * into created;

  perform public.admin_write_audit(
    'audit.photo',
    'cafe_audit',
    p_audit_id::text,
    jsonb_build_object('photo_id', created.id, 'object_key', created.object_key)
  );

  return created;
end;
$$;

create or replace function public.void_cafe_audit(
  p_audit_id uuid,
  p_reason text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;
  if not exists (select 1 from public.cafe_audits where id = p_audit_id) then
    raise exception 'That audit was not found.';
  end if;
  if exists (select 1 from public.cafe_audit_voids where audit_id = p_audit_id) then
    raise exception 'That audit is already voided.';
  end if;
  if char_length(btrim(coalesce(p_reason, ''))) < 8 then
    raise exception 'Say why this audit is voided.';
  end if;

  insert into public.cafe_audit_voids (audit_id, actor_id, reason)
  values (p_audit_id, auth.uid(), btrim(p_reason));

  perform public.admin_write_audit(
    'audit.void',
    'cafe_audit',
    p_audit_id::text,
    jsonb_build_object('reason', btrim(p_reason))
  );
end;
$$;

create or replace function public.void_cafe_amenity_report(
  p_report_id uuid,
  p_reason text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;
  if not exists (select 1 from public.cafe_amenity_reports where id = p_report_id) then
    raise exception 'That report was not found.';
  end if;
  if exists (select 1 from public.cafe_amenity_report_voids where report_id = p_report_id) then
    raise exception 'That report is already voided.';
  end if;
  if char_length(btrim(coalesce(p_reason, ''))) < 8 then
    raise exception 'Say why this report is voided.';
  end if;

  insert into public.cafe_amenity_report_voids (report_id, actor_id, reason)
  values (p_report_id, auth.uid(), btrim(p_reason));

  perform public.admin_write_audit(
    'amenity_report.void',
    'cafe_amenity_report',
    p_report_id::text,
    jsonb_build_object('reason', btrim(p_reason))
  );
end;
$$;

create or replace function public.import_cafe_amenity_reports(
  p_batch_id uuid,
  p_source text,
  p_rows jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  item jsonb;
  inserted integer := 0;
  skipped integer := 0;
  unmatched integer := 0;
  invalid integer := 0;
  shop_status text;
  amenity text;
  result_value text;
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;
  if p_batch_id is null or p_rows is null or jsonb_typeof(p_rows) <> 'array' then
    raise exception 'Provide a batch id and an array of rows.';
  end if;

  for item in select value from jsonb_array_elements(p_rows)
  loop
    amenity := item->>'amenity_key';
    result_value := item->>'result';
    if coalesce(item->>'source_row_key', '') = ''
       or amenity not in ('wifi', 'outlets', 'long_stay_wifi')
       or result_value not in ('available', 'unavailable')
       or item->>'shop_id' is null
       or item->>'observed_at' is null then
      invalid := invalid + 1;
      continue;
    end if;

    select status::text into shop_status from public.shops where id = (item->>'shop_id')::uuid;
    if shop_status is distinct from 'approved' then
      unmatched := unmatched + 1;
      continue;
    end if;

    insert into public.cafe_amenity_reports (
      shop_id, amenity_key, result, observed_at, source, import_batch_id, source_row_key, notes, created_by
    )
    values (
      (item->>'shop_id')::uuid,
      amenity,
      result_value,
      (item->>'observed_at')::timestamptz,
      coalesce(nullif(btrim(p_source), ''), 'founder_seed'),
      p_batch_id,
      item->>'source_row_key',
      nullif(btrim(coalesce(item->>'notes', '')), ''),
      auth.uid()
    )
    on conflict (source, source_row_key) do nothing;

    if found then
      inserted := inserted + 1;
    else
      skipped := skipped + 1;
    end if;
  end loop;

  perform public.admin_write_audit(
    'amenity_report.import',
    'cafe_amenity_report',
    p_batch_id::text,
    jsonb_build_object(
      'inserted', inserted,
      'skipped', skipped,
      'unmatched', unmatched,
      'invalid', invalid,
      'source', coalesce(nullif(btrim(p_source), ''), 'founder_seed')
    )
  );

  return jsonb_build_object(
    'inserted', inserted,
    'skipped_existing', skipped,
    'unmatched', unmatched,
    'invalid', invalid
  );
end;
$$;

revoke all on function public.submit_cafe_audit(uuid, uuid, jsonb, jsonb, text, boolean, timestamptz, text, time, integer, text, uuid) from public, anon;
grant execute on function public.submit_cafe_audit(uuid, uuid, jsonb, jsonb, text, boolean, timestamptz, text, time, integer, text, uuid) to authenticated;

revoke all on function public.attach_cafe_audit_photo(uuid, text, text, integer, text) from public, anon;
grant execute on function public.attach_cafe_audit_photo(uuid, text, text, integer, text) to authenticated;

revoke all on function public.void_cafe_audit(uuid, text) from public, anon;
grant execute on function public.void_cafe_audit(uuid, text) to authenticated;

revoke all on function public.void_cafe_amenity_report(uuid, text) from public, anon;
grant execute on function public.void_cafe_amenity_report(uuid, text) to authenticated;

revoke all on function public.import_cafe_amenity_reports(uuid, text, jsonb) from public, anon;
grant execute on function public.import_cafe_amenity_reports(uuid, text, jsonb) to authenticated;

notify pgrst, 'reload schema';
