-- =========================================================
-- KapéDoko — Shop submission constraints (follow-up)
-- =========================================================
-- Run this in the Supabase SQL editor AFTER 20260902_initial_schema.
--
-- The initial schema already has the right submission model:
--   shops.status = pending | approved | rejected
--   guests see only approved shops
--   authenticated users insert as themselves with status = pending
--   WiFi / outlets live on reviews + shop_review_stats, not on shops
--
-- This follow-up adds launch-geography checks, identity/contact
-- validation, a logo object key (R2), and reviewed_at bookkeeping.
-- Do NOT introduce a separate shop_submissions table — shops is
-- the submission queue.
-- =========================================================

alter table shops
  add column if not exists logo_object_key text;

alter table shops
  add column if not exists reviewed_at timestamptz;

comment on column shops.logo_object_key is
  'Cloudflare R2 object key for the cafe logo. Never a client-supplied public URL.';

-- --- Identity ---
alter table shops drop constraint if exists shops_name_len;
alter table shops add constraint shops_name_len
  check (char_length(trim(name)) between 2 and 80);

alter table shops drop constraint if exists shops_address_len;
alter table shops add constraint shops_address_len
  check (char_length(trim(address)) between 8 and 200);

alter table shops drop constraint if exists shops_contact_number_format;
alter table shops add constraint shops_contact_number_format
  check (
    contact_number is null
    or contact_number ~ '^\+?[0-9][0-9[:space:]\-()]{6,18}$'
  );

alter table shops drop constraint if exists shops_logo_object_key_format;
alter table shops add constraint shops_logo_object_key_format
  check (
    logo_object_key is null
    or logo_object_key ~ '^[a-zA-Z0-9][a-zA-Z0-9/_.:-]*$'
  );

-- Marikina launch bounding box (slightly padded city limits).
-- Skip this constraint first if you already inserted out-of-area rows.
alter table shops drop constraint if exists shops_in_marikina;
alter table shops add constraint shops_in_marikina
  check (
    latitude between 14.618 and 14.678
    and longitude between 121.078 and 121.138
  );

-- --- Hours ---
create or replace function is_valid_shop_hours(hours jsonb)
returns boolean
language plpgsql
immutable
as $$
declare
  day text;
  days text[] := array['mon','tue','wed','thu','fri','sat','sun'];
  item jsonb;
  kind text;
  open_t text;
  close_t text;
begin
  if hours is null then
    return false;
  end if;

  if jsonb_typeof(hours) <> 'object' then
    return false;
  end if;

  foreach day in array days loop
    if not hours ? day then
      return false;
    end if;

    item := hours -> day;
    if jsonb_typeof(item) <> 'object' then
      return false;
    end if;

    kind := item ->> 'kind';

    if kind in ('closed', 'all_day') then
      continue;
    elsif kind = 'open' then
      open_t := item ->> 'open';
      close_t := item ->> 'close';
      if open_t is null or close_t is null then
        return false;
      end if;
      if open_t !~ '^[0-2][0-9]:[0-5][0-9]$' or close_t !~ '^[0-2][0-9]:[0-5][0-9]$' then
        return false;
      end if;
      if split_part(open_t, ':', 1)::int > 23 or split_part(close_t, ':', 1)::int > 23 then
        return false;
      end if;
    else
      return false;
    end if;
  end loop;

  return true;
end;
$$;

alter table shops drop constraint if exists shops_hours_shape;
alter table shops add constraint shops_hours_shape
  check (is_valid_shop_hours(hours));

-- --- Status bookkeeping ---
create or replace function shops_before_write()
returns trigger
language plpgsql
as $$
begin
  if TG_OP = 'INSERT' then
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

drop trigger if exists shops_before_write on shops;
create trigger shops_before_write
  before insert or update on shops
  for each row execute procedure shops_before_write();

-- Admins remain the only role that can change status (existing RLS).
-- Submitters still cannot set status away from pending.
