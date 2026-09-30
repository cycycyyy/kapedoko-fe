-- =========================================================
-- KapéDoko — Cafe owners, claims, and catalog provenance
-- =========================================================
-- Run AFTER 20260929_philippines_coverage.sql (and the admin
-- portal files). Adds a cafe-owner role, OSM source identity,
-- admin-reviewed ownership claims, and a scoped owner update
-- path. Admins stay the only role that can publish a cafe.
--
-- Live databases store profiles.role as enum public.user_role.
-- This label must be added as a top-level statement (not in a DO
-- block). Later statements compare role::text so they do not use
-- the new enum value until this run commits.
-- If user_role does not exist (role is text), skip this statement
-- and continue from the UPDATE below.
-- =========================================================

-- --- Roles ---
alter type public.user_role add value if not exists 'cafe-owner';

update public.profiles
set role = 'user'
where role is null
   or role::text not in ('user', 'cafe-owner', 'admin');

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
        check (role in ('user', 'cafe-owner', 'admin'))
    $c$;
  end if;
end
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
  if p_role not in ('user', 'cafe-owner', 'admin') then
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

-- --- Catalog provenance ---
alter table public.shops add column if not exists source text;
alter table public.shops add column if not exists osm_type text;
alter table public.shops add column if not exists osm_id bigint;
alter table public.shops add column if not exists imported_at timestamptz;

comment on column public.shops.source is
  'Origin of the listing: openstreetmap, user, or admin. Null on legacy rows.';
comment on column public.shops.osm_type is
  'OpenStreetMap element type when source is openstreetmap: node, way, or relation.';
comment on column public.shops.osm_id is
  'OpenStreetMap element id. Unique with source and osm_type for OSM imports.';
comment on column public.shops.imported_at is
  'When an OSM (or other catalog) import first inserted this row.';

alter table public.shops drop constraint if exists shops_source_known;
alter table public.shops add constraint shops_source_known
  check (source is null or source in ('openstreetmap', 'user', 'admin'));

alter table public.shops drop constraint if exists shops_osm_identity_complete;
alter table public.shops add constraint shops_osm_identity_complete
  check (
    (osm_id is null and osm_type is null)
    or (
      source = 'openstreetmap'
      and osm_type in ('node', 'way', 'relation')
      and osm_id is not null
    )
  );

create unique index if not exists shops_osm_identity_uidx
  on public.shops (source, osm_type, osm_id)
  where source = 'openstreetmap' and osm_id is not null;

update public.shops
set
  source = 'openstreetmap',
  imported_at = coalesce(imported_at, created_at)
where description = 'OpenStreetMap'
  and source is null;

update public.shops
set description = null
where description = 'OpenStreetMap';

-- Status changes stay admin-or-service-role. auth.uid() is null in
-- the SQL editor so documented bulk approvals still work.
create or replace function public.shops_before_write()
returns trigger
language plpgsql
as $$
begin
  if TG_OP = 'INSERT' then
    if public.admin_shop_write_enabled() then
      new.status := 'approved'::public.shop_status;
      new.reviewed_at := coalesce(new.reviewed_at, now());
      new.reviewed_by := coalesce(new.reviewed_by, auth.uid());
      new.rejection_reason := null;
      new.source := coalesce(new.source, 'admin');
      new.updated_at := now();
      return new;
    end if;
    if new.status <> 'pending' then
      raise exception 'New shops must start as pending';
    end if;
    new.reviewed_at := null;
    new.reviewed_by := null;
    new.rejection_reason := null;
    new.source := coalesce(new.source, 'user');
    new.updated_at := now();
    return new;
  end if;

  if new.status is distinct from old.status then
    if auth.uid() is not null and not public.is_admin() then
      raise exception 'Only an admin can change listing status';
    end if;
    if old.status = 'pending' and new.status in ('approved', 'rejected') then
      new.reviewed_at := coalesce(new.reviewed_at, now());
      if new.reviewed_by is null then
        new.reviewed_by := auth.uid();
      end if;
      if new.status = 'approved' then
        new.rejection_reason := null;
      end if;
    elsif old.status in ('approved', 'rejected') and new.status = 'pending' then
      new.reviewed_at := null;
      new.reviewed_by := null;
      new.rejection_reason := null;
    else
      raise exception 'Illegal shop status transition: % → %', old.status, new.status;
    end if;
  end if;

  new.source := coalesce(new.source, old.source);
  new.osm_type := coalesce(new.osm_type, old.osm_type);
  new.osm_id := coalesce(new.osm_id, old.osm_id);
  new.imported_at := coalesce(new.imported_at, old.imported_at);
  new.updated_at := now();
  return new;
end;
$$;

-- --- Claims ---
create table if not exists public.shop_claims (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.shops(id) on delete cascade,
  claimant_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending',
  evidence_note text not null,
  contact_email text,
  contact_phone text,
  rejection_reason text,
  reviewed_by uuid references auth.users(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.shop_claims is
  'Requests to manage an approved cafe. Admins verify; verified claimants may edit identity, hours, contact, and logo.';

alter table public.shop_claims drop constraint if exists shop_claims_status_known;
alter table public.shop_claims add constraint shop_claims_status_known
  check (status in ('pending', 'verified', 'rejected'));

alter table public.shop_claims drop constraint if exists shop_claims_evidence_len;
alter table public.shop_claims add constraint shop_claims_evidence_len
  check (char_length(btrim(evidence_note)) between 20 and 500);

alter table public.shop_claims drop constraint if exists shop_claims_email_len;
alter table public.shop_claims add constraint shop_claims_email_len
  check (
    contact_email is null
    or (
      char_length(btrim(contact_email)) between 5 and 120
      and contact_email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
    )
  );

alter table public.shop_claims drop constraint if exists shop_claims_phone_format;
alter table public.shop_claims add constraint shop_claims_phone_format
  check (
    contact_phone is null
    or contact_phone ~ '^\+?[0-9][0-9[:space:]\-()]{6,18}$'
  );

alter table public.shop_claims drop constraint if exists shop_claims_contact_present;
alter table public.shop_claims add constraint shop_claims_contact_present
  check (
    nullif(btrim(coalesce(contact_email, '')), '') is not null
    or nullif(btrim(coalesce(contact_phone, '')), '') is not null
  );

alter table public.shop_claims drop constraint if exists shop_claims_rejection_len;
alter table public.shop_claims add constraint shop_claims_rejection_len
  check (rejection_reason is null or char_length(btrim(rejection_reason)) between 1 and 280);

create unique index if not exists shop_claims_pending_uidx
  on public.shop_claims (shop_id, claimant_id)
  where status = 'pending';

create unique index if not exists shop_claims_verified_uidx
  on public.shop_claims (shop_id, claimant_id)
  where status = 'verified';

create index if not exists shop_claims_queue_idx
  on public.shop_claims (status, created_at desc);

create index if not exists shop_claims_claimant_idx
  on public.shop_claims (claimant_id, created_at desc);

alter table public.shop_claims enable row level security;
alter table public.shop_claims force row level security;

drop policy if exists shop_claims_select_own on public.shop_claims;
create policy shop_claims_select_own
  on public.shop_claims
  for select
  to authenticated
  using (claimant_id = auth.uid() or public.is_admin());

revoke all on public.shop_claims from anon, public;
grant select on public.shop_claims to authenticated;

create or replace function public.is_shop_owner(p_shop_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.shop_claims
    where shop_id = p_shop_id
      and claimant_id = auth.uid()
      and status = 'verified'
  );
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
  -- profiles.role is enum public.user_role on live; compare as text.
  select role::text into current_role from public.profiles where id = p_user_id;
  if current_role is null or current_role = 'admin' then
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

create or replace function public.submit_shop_claim(
  p_shop_id uuid,
  p_evidence_note text,
  p_contact_email text default null,
  p_contact_phone text default null
)
returns public.shop_claims
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  shop_status text;
  note text := btrim(regexp_replace(coalesce(p_evidence_note, ''), '\s+', ' ', 'g'));
  email text := nullif(lower(btrim(coalesce(p_contact_email, ''))), '');
  phone text := nullif(btrim(coalesce(p_contact_phone, '')), '');
  created public.shop_claims;
begin
  if uid is null then
    raise exception 'Sign in to claim this cafe.';
  end if;
  if char_length(note) < 20 or char_length(note) > 500 then
    raise exception 'Tell us how you are connected to this cafe in 20 to 500 characters.';
  end if;
  if email is null and phone is null then
    raise exception 'Add a phone number or email we can reach you on.';
  end if;

  select status into shop_status from public.shops where id = p_shop_id;
  if shop_status is null then
    raise exception 'Cafe was not found';
  end if;
  if shop_status <> 'approved' then
    raise exception 'Only listed cafes can be claimed.';
  end if;

  if exists (
    select 1 from public.shop_claims
    where shop_id = p_shop_id
      and claimant_id = uid
      and status = 'verified'
  ) then
    raise exception 'You already manage this cafe.';
  end if;

  if exists (
    select 1 from public.shop_claims
    where shop_id = p_shop_id
      and claimant_id = uid
      and status = 'pending'
  ) then
    raise exception 'Your claim is already waiting for review.';
  end if;

  insert into public.shop_claims (
    shop_id,
    claimant_id,
    status,
    evidence_note,
    contact_email,
    contact_phone
  )
  values (p_shop_id, uid, 'pending', note, email, phone)
  returning * into created;

  perform public.admin_write_audit(
    'claim.submit',
    'shop_claim',
    created.id::text,
    jsonb_build_object('shop_id', p_shop_id)
  );

  return created;
end;
$$;

create or replace function public.moderate_shop_claim(
  p_claim_id uuid,
  p_status text,
  p_rejection_reason text default null
)
returns public.shop_claims
language plpgsql
security definer
set search_path = public
as $$
declare
  updated public.shop_claims;
  reason text := nullif(btrim(coalesce(p_rejection_reason, '')), '');
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;
  if p_status not in ('verified', 'rejected') then
    raise exception 'Unknown claim status';
  end if;
  if p_status = 'rejected' and reason is null then
    raise exception 'Add a reason for rejecting this claim.';
  end if;

  update public.shop_claims
  set
    status = p_status,
    rejection_reason = case when p_status = 'rejected' then reason else null end,
    reviewed_by = auth.uid(),
    reviewed_at = now(),
    updated_at = now()
  where id = p_claim_id
    and status = 'pending'
  returning * into updated;

  if updated.id is null then
    raise exception 'Claim was not found or is no longer pending.';
  end if;

  perform public.sync_cafe_owner_role(updated.claimant_id);
  perform public.admin_write_audit(
    'claim.' || p_status,
    'shop_claim',
    updated.id::text,
    jsonb_build_object(
      'shop_id', updated.shop_id,
      'claimant_id', updated.claimant_id,
      'rejection_reason', updated.rejection_reason
    )
  );
  return updated;
end;
$$;

create or replace function public.update_owner_shop(
  p_shop_id uuid,
  p_name text,
  p_address text,
  p_latitude double precision,
  p_longitude double precision,
  p_hours jsonb,
  p_contact_number text default null,
  p_logo_object_key text default null
)
returns public.shops
language plpgsql
security definer
set search_path = public
as $$
declare
  updated public.shops;
  clean_name text := btrim(regexp_replace(coalesce(p_name, ''), '\s+', ' ', 'g'));
  clean_address text := btrim(regexp_replace(coalesce(p_address, ''), '\s+', ' ', 'g'));
  clean_phone text := nullif(btrim(coalesce(p_contact_number, '')), '');
begin
  if auth.uid() is null then
    raise exception 'Sign in to edit this cafe.';
  end if;
  if not public.is_shop_owner(p_shop_id) then
    raise exception 'You can only edit cafes you manage.';
  end if;
  if char_length(clean_name) < 2 or char_length(clean_name) > 80 then
    raise exception 'Check the cafe name and try again.';
  end if;
  if char_length(clean_address) < 8 or char_length(clean_address) > 200 then
    raise exception 'Check the cafe address and try again.';
  end if;
  if p_latitude is null or p_longitude is null
     or p_latitude < -90 or p_latitude > 90
     or p_longitude < -180 or p_longitude > 180 then
    raise exception 'Pin the cafe on the map.';
  end if;
  if not public.is_valid_shop_hours(p_hours) then
    raise exception 'Check the opening hours and try again.';
  end if;

  update public.shops
  set
    name = clean_name,
    address = clean_address,
    latitude = p_latitude,
    longitude = p_longitude,
    hours = p_hours,
    contact_number = clean_phone,
    logo_object_key = coalesce(nullif(p_logo_object_key, ''), logo_object_key)
  where id = p_shop_id
    and status = 'approved'::public.shop_status
  returning * into updated;

  if updated.id is null then
    raise exception 'Cafe was not found';
  end if;

  perform public.admin_write_audit(
    'shop.owner_update',
    'shop',
    updated.id::text,
    jsonb_build_object('name', updated.name)
  );
  return updated;
end;
$$;

do $$
begin
  if exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'shops'
      and c.relrowsecurity
  ) then
    execute 'drop policy if exists shops_owner_read on public.shops';
    execute $policy$
      create policy shops_owner_read
        on public.shops
        for select
        to authenticated
        using (
          submitted_by = auth.uid()
          or public.is_admin()
          or public.is_shop_owner(id)
        )
    $policy$;
  end if;
end $$;

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

revoke all on function public.is_shop_owner(uuid) from public, anon;
revoke all on function public.sync_cafe_owner_role(uuid) from public, anon, authenticated;
revoke all on function public.submit_shop_claim(uuid, text, text, text) from public, anon;
revoke all on function public.moderate_shop_claim(uuid, text, text) from public, anon;
revoke all on function public.update_owner_shop(uuid, text, text, double precision, double precision, jsonb, text, text) from public, anon;
revoke all on function public.list_my_shop_claims() from public, anon;

grant execute on function public.is_shop_owner(uuid) to authenticated;
grant execute on function public.submit_shop_claim(uuid, text, text, text) to authenticated;
grant execute on function public.moderate_shop_claim(uuid, text, text) to authenticated;
grant execute on function public.update_owner_shop(uuid, text, text, double precision, double precision, jsonb, text, text) to authenticated;
grant execute on function public.list_my_shop_claims() to authenticated;

notify pgrst, 'reload schema';
