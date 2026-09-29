-- =========================================================
-- KapéDoko — Admin portal hotfix
-- =========================================================
-- Run AFTER 20260929_admin_portal.sql.
-- Fixes: shops.status is shop_status (enum), not text.
-- Also creates content_reports if 20260928 was skipped, then
-- reloads the PostgREST schema cache.
-- =========================================================

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

-- Reports table from 20260928, in case that file was not applied.
create table if not exists public.content_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references auth.users(id) on delete cascade,
  target_type text not null,
  review_id uuid references public.reviews(id) on delete cascade,
  shop_id uuid references public.shops(id) on delete cascade,
  reason text,
  status text not null default 'open',
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  resolved_by uuid
);

alter table public.content_reports drop constraint if exists content_reports_target_check;
alter table public.content_reports add constraint content_reports_target_check
  check (target_type in ('review', 'shop_photo'));

alter table public.content_reports drop constraint if exists content_reports_status_check;
alter table public.content_reports add constraint content_reports_status_check
  check (status in ('open', 'hidden', 'dismissed'));

alter table public.content_reports enable row level security;

drop policy if exists content_reports_admin_all on public.content_reports;
create policy content_reports_admin_all
  on public.content_reports
  for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

grant select, update on public.content_reports to authenticated;

notify pgrst, 'reload schema';
