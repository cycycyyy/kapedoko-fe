-- =========================================================
-- KapéDoko — Admin cafe CSV import
-- =========================================================
-- Run AFTER 20260930_cafe_owners_catalog.sql.
-- Adds import_admin_shops: confirmed crate rows land as pending
-- admin-sourced shops. Coverage is bypassed; status stays pending
-- so they wait on the cafe rail until an admin publishes them.
-- Amenities are never written here.
-- =========================================================

create or replace function public.admin_catalog_import_enabled()
returns boolean
language sql
stable
as $$
  select current_setting('app.admin_catalog_import', true) = 'on'
    and public.is_admin();
$$;

create or replace function public.shops_require_coverage()
returns trigger
language plpgsql
as $$
begin
  if public.admin_shop_write_enabled() or public.admin_catalog_import_enabled() then
    return new;
  end if;
  if not is_in_active_coverage(new.latitude, new.longitude) then
    raise exception 'shops_in_coverage'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

create or replace function public.shops_before_write()
returns trigger
language plpgsql
as $$
begin
  if TG_OP = 'INSERT' then
    if public.admin_catalog_import_enabled() then
      new.status := 'pending'::public.shop_status;
      new.reviewed_at := null;
      new.reviewed_by := null;
      new.rejection_reason := null;
      new.source := coalesce(new.source, 'admin');
      new.imported_at := coalesce(new.imported_at, now());
      new.updated_at := now();
      return new;
    end if;
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
      'pending'::public.shop_status,
      'admin',
      now()
    )
    returning * into created;

    perform public.admin_write_audit(
      'import_shop',
      'shop',
      created.id::text,
      jsonb_build_object('name', created.name)
    );
    inserted := inserted + 1;
    return next created;
  end loop;

  if inserted = 0 then
    raise exception 'Confirm at least one cafe before importing.';
  end if;
end;
$$;

revoke all on function public.import_admin_shops(jsonb) from public, anon;
grant execute on function public.import_admin_shops(jsonb) to authenticated;

notify pgrst, 'reload schema';
