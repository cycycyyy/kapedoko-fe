-- =========================================================
-- KapéDoko — Admin portal (additive)
-- =========================================================
-- Run AFTER 20260928_favorites_profiles_moderation.sql.
-- Does not replace shops, shop_placements, or the public
-- approved-only read path. User submissions stay pending
-- and coverage-limited. Admin-only RPCs may create approved
-- cafes anywhere and schedule ads / placements / roles.
-- =========================================================

-- --- Audit ---
create table if not exists public.admin_audit_log (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid not null,
  action text not null,
  entity_type text not null,
  entity_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists admin_audit_log_created_idx
  on public.admin_audit_log (created_at desc);

create index if not exists admin_audit_log_entity_idx
  on public.admin_audit_log (entity_type, entity_id, created_at desc);

alter table public.admin_audit_log enable row level security;

drop policy if exists admin_audit_log_admin_read on public.admin_audit_log;
create policy admin_audit_log_admin_read
  on public.admin_audit_log
  for select
  to authenticated
  using (public.is_admin());

revoke all on public.admin_audit_log from anon, public;
grant select on public.admin_audit_log to authenticated;

create or replace function public.admin_write_audit(
  p_action text,
  p_entity_type text,
  p_entity_id text default null,
  p_metadata jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    return;
  end if;
  insert into public.admin_audit_log (actor_id, action, entity_type, entity_id, metadata)
  values (auth.uid(), p_action, p_entity_type, p_entity_id, coalesce(p_metadata, '{}'::jsonb));
end;
$$;

revoke all on function public.admin_write_audit(text, text, text, jsonb) from public, anon, authenticated;

create or replace function public.admin_shop_write_enabled()
returns boolean
language sql
stable
as $$
  select current_setting('app.admin_shop_write', true) = 'on'
    and public.is_admin();
$$;

-- --- Shop write triggers: allow verified admin RPC bypass ---
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
      new.updated_at := now();
      return new;
    end if;
    if new.status <> 'pending' then
      raise exception 'New shops must start as pending';
    end if;
    new.reviewed_at := null;
    new.reviewed_by := null;
    new.rejection_reason := null;
    new.updated_at := now();
    return new;
  end if;

  if new.status is distinct from old.status then
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

  new.updated_at := now();
  return new;
end;
$$;

create or replace function public.shops_require_coverage()
returns trigger
language plpgsql
as $$
begin
  if public.admin_shop_write_enabled() then
    return new;
  end if;
  if not is_in_active_coverage(new.latitude, new.longitude) then
    raise exception 'shops_in_coverage'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

create or replace function public.create_admin_shop(
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
  created public.shops;
  clean_name text := btrim(regexp_replace(coalesce(p_name, ''), '\s+', ' ', 'g'));
  clean_address text := btrim(regexp_replace(coalesce(p_address, ''), '\s+', ' ', 'g'));
  clean_phone text := nullif(btrim(coalesce(p_contact_number, '')), '');
begin
  if not public.is_admin() then
    raise exception 'Admin only';
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

  perform set_config('app.admin_shop_write', 'on', true);

  insert into public.shops (
    name,
    address,
    latitude,
    longitude,
    hours,
    contact_number,
    logo_object_key,
    submitted_by,
    status,
    reviewed_by,
    reviewed_at
  )
  values (
    clean_name,
    clean_address,
    p_latitude,
    p_longitude,
    p_hours,
    clean_phone,
    nullif(p_logo_object_key, ''),
    auth.uid(),
    'approved'::public.shop_status,
    auth.uid(),
    now()
  )
  returning * into created;

  perform public.admin_write_audit(
    'shop.create',
    'shop',
    created.id::text,
    jsonb_build_object('name', created.name, 'bypass_coverage', true)
  );

  return created;
end;
$$;

create or replace function public.update_admin_shop(
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
  if not public.is_admin() then
    raise exception 'Admin only';
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

  perform set_config('app.admin_shop_write', 'on', true);

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
  returning * into updated;

  if updated.id is null then
    raise exception 'Cafe was not found';
  end if;

  perform public.admin_write_audit('shop.update', 'shop', updated.id::text, jsonb_build_object('name', updated.name));
  return updated;
end;
$$;

create or replace function public.moderate_admin_shop(
  p_shop_id uuid,
  p_status text,
  p_rejection_reason text default null
)
returns public.shops
language plpgsql
security definer
set search_path = public
as $$
declare
  updated public.shops;
  reason text := nullif(btrim(coalesce(p_rejection_reason, '')), '');
  next_status public.shop_status;
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;
  if p_status not in ('approved', 'rejected', 'pending') then
    raise exception 'Unknown shop status';
  end if;

  next_status := p_status::public.shop_status;

  update public.shops
  set
    status = next_status,
    rejection_reason = case
      when next_status = 'rejected' then coalesce(reason, 'Does not meet listing standards')
      else null
    end,
    reviewed_by = case when next_status in ('approved', 'rejected') then auth.uid() else null end,
    reviewed_at = case when next_status in ('approved', 'rejected') then now() else null end
  where id = p_shop_id
  returning * into updated;

  if updated.id is null then
    raise exception 'Cafe was not found';
  end if;

  perform public.admin_write_audit(
    'shop.' || p_status,
    'shop',
    updated.id::text,
    jsonb_build_object('rejection_reason', updated.rejection_reason)
  );
  return updated;
end;
$$;

create or replace function public.save_shop_placement(
  p_shop_id uuid,
  p_kind text,
  p_starts_at timestamptz default null,
  p_ends_at timestamptz default null
)
returns public.shop_placements
language plpgsql
security definer
set search_path = public
as $$
declare
  shop_status text;
  created public.shop_placements;
  now_ts timestamptz := now();
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;

  select status into shop_status from public.shops where id = p_shop_id;
  if shop_status is null then
    raise exception 'Cafe was not found';
  end if;
  if shop_status <> 'approved' then
    raise exception 'Approve the cafe before setting a map pin.';
  end if;

  if p_kind is not null and p_kind not in ('partner', 'sponsored', 'standard') then
    raise exception 'Unknown placement kind';
  end if;

  update public.shop_placements
  set ends_at = now_ts
  where shop_id = p_shop_id
    and starts_at < now_ts
    and ends_at > now_ts;

  delete from public.shop_placements
  where shop_id = p_shop_id
    and starts_at >= now_ts;

  if p_kind is null or p_kind = 'standard' then
    perform public.admin_write_audit(
      'placement.clear',
      'shop',
      p_shop_id::text,
      jsonb_build_object('kind', 'standard')
    );
    return null;
  end if;

  if p_starts_at is null or p_ends_at is null or p_ends_at <= p_starts_at then
    raise exception 'Choose an end date after the start date.';
  end if;

  insert into public.shop_placements (shop_id, kind, starts_at, ends_at, created_by)
  values (p_shop_id, p_kind::public.shop_placement_kind, p_starts_at, p_ends_at, auth.uid())
  returning * into created;

  perform public.admin_write_audit(
    'placement.save',
    'shop_placement',
    created.id::text,
    jsonb_build_object('shop_id', p_shop_id, 'kind', p_kind, 'starts_at', p_starts_at, 'ends_at', p_ends_at)
  );

  return created;
end;
$$;

create or replace function public.end_shop_placement(p_placement_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  row public.shop_placements;
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;

  select * into row from public.shop_placements where id = p_placement_id;
  if row.id is null then
    raise exception 'Placement was not found';
  end if;

  update public.shop_placements
  set ends_at = least(ends_at, now())
  where id = p_placement_id
    and ends_at > now();

  perform public.admin_write_audit('placement.end', 'shop_placement', p_placement_id::text, jsonb_build_object('shop_id', row.shop_id));
end;
$$;

-- --- Banner ads ---
create table if not exists public.ad_campaigns (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.shops(id) on delete cascade,
  banner_object_key text not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  enabled boolean not null default true,
  cancelled_at timestamptz,
  label text,
  priority integer not null default 0,
  created_by uuid,
  updated_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint ad_campaigns_window check (ends_at > starts_at),
  constraint ad_campaigns_banner_key check (
    banner_object_key ~ '^[a-zA-Z0-9][a-zA-Z0-9/_.:-]*$'
  ),
  constraint ad_campaigns_label_len check (
    label is null or char_length(btrim(label)) between 1 and 80
  )
);

comment on table public.ad_campaigns is
  'Cafe-linked Home banners. Public reads only currently enabled, in-window rows.';

create index if not exists ad_campaigns_window_idx
  on public.ad_campaigns (starts_at, ends_at, enabled)
  where cancelled_at is null;

create or replace function public.ad_campaigns_before_write()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  shop_status text;
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;

  select status into shop_status from public.shops where id = new.shop_id;
  if shop_status is null then
    raise exception 'Cafe was not found';
  end if;
  if shop_status <> 'approved' then
    raise exception 'Only approved cafes can receive banners';
  end if;

  if TG_OP = 'INSERT' then
    new.created_by := coalesce(new.created_by, auth.uid());
    new.created_at := coalesce(new.created_at, now());
  end if;
  new.updated_by := auth.uid();
  new.updated_at := now();
  if new.cancelled_at is not null then
    new.enabled := false;
  end if;
  return new;
end;
$$;

drop trigger if exists ad_campaigns_before_write on public.ad_campaigns;
create trigger ad_campaigns_before_write
  before insert or update on public.ad_campaigns
  for each row execute procedure public.ad_campaigns_before_write();

create or replace function public.ad_campaigns_end_on_unapprove()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.status = 'approved' and new.status is distinct from 'approved' then
    update public.ad_campaigns
    set
      cancelled_at = coalesce(cancelled_at, now()),
      enabled = false,
      ends_at = least(ends_at, now()),
      updated_at = now()
    where shop_id = new.id
      and cancelled_at is null
      and ends_at > now();
  end if;
  return new;
end;
$$;

drop trigger if exists ad_campaigns_end_on_unapprove on public.shops;
create trigger ad_campaigns_end_on_unapprove
  after update of status on public.shops
  for each row execute procedure public.ad_campaigns_end_on_unapprove();

create or replace function public.ad_campaigns_after_write()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if TG_OP = 'DELETE' then
    perform public.admin_write_audit('ad.delete', 'ad_campaign', old.id::text, jsonb_build_object('shop_id', old.shop_id));
    return old;
  end if;
  perform public.admin_write_audit(
    case when TG_OP = 'INSERT' then 'ad.create' else 'ad.update' end,
    'ad_campaign',
    new.id::text,
    jsonb_build_object('shop_id', new.shop_id, 'enabled', new.enabled)
  );
  return new;
end;
$$;

drop trigger if exists ad_campaigns_after_write on public.ad_campaigns;
create trigger ad_campaigns_after_write
  after insert or update or delete on public.ad_campaigns
  for each row execute procedure public.ad_campaigns_after_write();

alter table public.ad_campaigns enable row level security;

drop policy if exists ad_campaigns_public_read on public.ad_campaigns;
create policy ad_campaigns_public_read
  on public.ad_campaigns
  for select
  to anon, authenticated
  using (
    enabled
    and cancelled_at is null
    and starts_at <= now()
    and ends_at > now()
    and exists (
      select 1 from public.shops s
      where s.id = shop_id and s.status = 'approved'
    )
  );

drop policy if exists ad_campaigns_admin_read on public.ad_campaigns;
create policy ad_campaigns_admin_read
  on public.ad_campaigns
  for select
  to authenticated
  using (public.is_admin());

drop policy if exists ad_campaigns_admin_write on public.ad_campaigns;
create policy ad_campaigns_admin_write
  on public.ad_campaigns
  for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create or replace view public.active_ad_campaigns
with (security_invoker = true) as
select
  id,
  shop_id,
  banner_object_key,
  starts_at,
  ends_at,
  priority,
  label
from public.ad_campaigns
where enabled
  and cancelled_at is null
  and starts_at <= now()
  and ends_at > now();

grant select on public.active_ad_campaigns to anon, authenticated;
grant select on public.ad_campaigns to anon, authenticated;
grant insert, update, delete on public.ad_campaigns to authenticated;

-- --- Roles ---
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
  if p_role not in ('user', 'admin') then
    raise exception 'Unknown role';
  end if;
  if p_user_id = auth.uid() then
    raise exception 'You cannot change your own role.';
  end if;

  if p_role = 'user' then
    select count(*) into remaining_admins
    from public.profiles
    where role = 'admin'
      and id <> p_user_id;
    if remaining_admins < 1 then
      raise exception 'Cannot demote the last admin.';
    end if;
  end if;

  update public.profiles
  set role = p_role
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

create or replace function public.admin_log_user_status(
  p_user_id uuid,
  p_action text
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
  if p_user_id = auth.uid() then
    raise exception 'You cannot suspend your own account.';
  end if;
  perform public.admin_write_audit(p_action, 'profile', p_user_id::text, '{}'::jsonb);
end;
$$;

-- Keep ordinary profile updates limited to the owner. Admins change
-- roles only through admin_set_profile_role.
drop policy if exists shops_admin_update on public.shops;
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
    execute $policy$
      create policy shops_admin_update
        on public.shops
        for update
        to authenticated
        using (public.is_admin())
        with check (public.is_admin())
    $policy$;
  end if;
end $$;

revoke all on function public.create_admin_shop(text, text, double precision, double precision, jsonb, text, text) from public, anon;
revoke all on function public.update_admin_shop(uuid, text, text, double precision, double precision, jsonb, text, text) from public, anon;
revoke all on function public.moderate_admin_shop(uuid, text, text) from public, anon;
revoke all on function public.save_shop_placement(uuid, text, timestamptz, timestamptz) from public, anon;
revoke all on function public.end_shop_placement(uuid) from public, anon;
revoke all on function public.admin_set_profile_role(uuid, text) from public, anon;
revoke all on function public.admin_log_user_status(uuid, text) from public, anon;

grant execute on function public.create_admin_shop(text, text, double precision, double precision, jsonb, text, text) to authenticated;
grant execute on function public.update_admin_shop(uuid, text, text, double precision, double precision, jsonb, text, text) to authenticated;
grant execute on function public.moderate_admin_shop(uuid, text, text) to authenticated;
grant execute on function public.save_shop_placement(uuid, text, timestamptz, timestamptz) to authenticated;
grant execute on function public.end_shop_placement(uuid) to authenticated;
grant execute on function public.admin_set_profile_role(uuid, text) to authenticated;
grant execute on function public.admin_log_user_status(uuid, text) to authenticated;
