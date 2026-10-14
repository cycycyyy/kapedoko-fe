-- =========================================================
-- KapéDoko — Hidden cafe listings
-- =========================================================
-- Run AFTER 20261013_shop_status_enum_hidden.sql.
--
-- shops.status = pending | approved | rejected | hidden
--   pending  — non-admin / cafe-owner submissions waiting for review
--   hidden   — admin-created (or unpublished) listings, off Home and Map
--   approved — published
--   rejected — turned down
--
-- Admin create and CSV import default to hidden.
-- User submissions still default to pending.
-- Admins toggle approved ↔ hidden to publish / unpublish.
-- =========================================================

create or replace function public.shops_before_write()
returns trigger
language plpgsql
as $$
begin
  if TG_OP = 'INSERT' then
    if public.admin_catalog_import_enabled() then
      new.status := 'hidden'::public.shop_status;
      new.reviewed_at := null;
      new.reviewed_by := null;
      new.rejection_reason := null;
      new.source := coalesce(new.source, 'admin');
      new.imported_at := coalesce(new.imported_at, now());
      new.updated_at := now();
      return new;
    end if;
    if public.admin_shop_write_enabled() then
      new.status := 'hidden'::public.shop_status;
      new.reviewed_at := null;
      new.reviewed_by := null;
      new.rejection_reason := null;
      new.source := coalesce(new.source, 'admin');
      new.updated_at := now();
      return new;
    end if;
    -- SQL editor / service role may seed unpublished admin drafts.
    if auth.uid() is null and new.status = 'hidden' then
      new.reviewed_at := null;
      new.reviewed_by := null;
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
    elsif old.status = 'rejected' and new.status = 'pending' then
      new.reviewed_at := null;
      new.reviewed_by := null;
      new.rejection_reason := null;
    elsif old.status = 'approved' and new.status = 'hidden' then
      new.reviewed_at := old.reviewed_at;
      new.reviewed_by := old.reviewed_by;
      new.rejection_reason := null;
    elsif old.status = 'hidden' and new.status = 'approved' then
      new.reviewed_at := coalesce(new.reviewed_at, now());
      if new.reviewed_by is null then
        new.reviewed_by := auth.uid();
      end if;
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
    source
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
    'hidden'::public.shop_status,
    'admin'
  )
  returning * into created;

  perform public.admin_write_audit(
    'shop.create',
    'shop',
    created.id::text,
    jsonb_build_object('name', created.name, 'status', created.status, 'bypass_coverage', true)
  );

  return created;
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
  if p_status not in ('approved', 'rejected', 'pending', 'hidden') then
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
    reviewed_by = case
      when next_status in ('approved', 'rejected') then auth.uid()
      when next_status = 'hidden' then reviewed_by
      else null
    end,
    reviewed_at = case
      when next_status in ('approved', 'rejected') then now()
      when next_status = 'hidden' then reviewed_at
      else null
    end
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

create or replace function public.import_admin_shops(p_shops jsonb)
returns setof public.shops
language plpgsql
security definer
set search_path = public
as $$
declare
  item jsonb;
  created public.shops;
  clean_name text;
  clean_address text;
  clean_phone text;
  inserted integer := 0;
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;
  if p_shops is null or jsonb_typeof(p_shops) <> 'array' or jsonb_array_length(p_shops) = 0 then
    raise exception 'Confirm at least one cafe before importing.';
  end if;
  if jsonb_array_length(p_shops) > 200 then
    raise exception 'Import at most 200 cafes at a time.';
  end if;

  perform set_config('app.admin_catalog_import', 'on', true);

  for item in select value from jsonb_array_elements(p_shops)
  loop
    clean_name := btrim(regexp_replace(coalesce(item ->> 'name', ''), '\s+', ' ', 'g'));
    clean_address := btrim(regexp_replace(coalesce(item ->> 'address', ''), '\s+', ' ', 'g'));
    clean_phone := nullif(btrim(coalesce(item ->> 'contact_number', '')), '');

    if char_length(clean_name) < 2 or char_length(clean_name) > 80 then
      raise exception 'Check the cafe name and try again.';
    end if;
    if char_length(clean_address) < 8 or char_length(clean_address) > 200 then
      raise exception 'Check the cafe address and try again.';
    end if;
    if (item ->> 'latitude') is null or (item ->> 'longitude') is null
       or (item ->> 'latitude')::double precision < -90
       or (item ->> 'latitude')::double precision > 90
       or (item ->> 'longitude')::double precision < -180
       or (item ->> 'longitude')::double precision > 180 then
      raise exception 'Pin the cafe on the map.';
    end if;
    if not public.is_valid_shop_hours(item -> 'hours') then
      raise exception 'Check the opening hours and try again.';
    end if;

    insert into public.shops (
      name,
      address,
      latitude,
      longitude,
      hours,
      contact_number,
      categories,
      submitted_by,
      status,
      source,
      imported_at
    )
    values (
      clean_name,
      clean_address,
      (item ->> 'latitude')::double precision,
      (item ->> 'longitude')::double precision,
      item -> 'hours',
      clean_phone,
      array['cafe']::text[],
      auth.uid(),
      'hidden'::public.shop_status,
      'admin',
      now()
    )
    returning * into created;

    perform public.admin_write_audit(
      'import_shop',
      'shop',
      created.id::text,
      jsonb_build_object('name', created.name, 'status', created.status)
    );
    inserted := inserted + 1;
    return next created;
  end loop;

  if inserted = 0 then
    raise exception 'Confirm at least one cafe before importing.';
  end if;
end;
$$;

revoke all on function public.create_admin_shop(text, text, double precision, double precision, jsonb, text, text) from public, anon;
grant execute on function public.create_admin_shop(text, text, double precision, double precision, jsonb, text, text) to authenticated;

revoke all on function public.moderate_admin_shop(uuid, text, text) from public, anon;
grant execute on function public.moderate_admin_shop(uuid, text, text) to authenticated;

revoke all on function public.import_admin_shops(jsonb) from public, anon;
grant execute on function public.import_admin_shops(jsonb) to authenticated;

alter table public.shops enable trigger shops_before_write;
alter table public.shops enable trigger shops_require_coverage;
alter table public.shops enable trigger shop_placements_end_on_unapprove;
alter table public.shops enable trigger ad_campaigns_end_on_unapprove;

notify pgrst, 'reload schema';
