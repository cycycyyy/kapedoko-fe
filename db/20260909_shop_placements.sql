-- =========================================================
-- KapéDoko — Shop placements and map marker tiers
-- =========================================================
-- Run this in the Supabase SQL editor AFTER 20260908_*.
--
-- Partnerships live beside shops, not on them. Organic ranking
-- (Popular, review stats) stays independent of paid pins.
-- =========================================================

do $$
begin
  if not exists (
    select 1 from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname = 'public' and t.typname = 'shop_placement_kind'
  ) then
    create type public.shop_placement_kind as enum ('partner', 'sponsored');
  end if;
end
$$;

create table if not exists public.shop_placements (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.shops(id) on delete cascade,
  kind public.shop_placement_kind not null,
  starts_at timestamptz not null default now(),
  ends_at timestamptz not null,
  created_by uuid,
  created_at timestamptz not null default now(),
  constraint shop_placements_window check (ends_at > starts_at)
);

comment on table public.shop_placements is
  'Dated partner and sponsored map placements. Expired rows fall back to the standard pin.';

create index if not exists shop_placements_shop_window_idx
  on public.shop_placements (shop_id, starts_at, ends_at);

create or replace function public.shop_placements_before_write()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  shop_status text;
begin
  select status into shop_status from public.shops where id = new.shop_id;
  if shop_status is null then
    raise exception 'Placement shop was not found';
  end if;
  if shop_status <> 'approved' then
    raise exception 'Only approved shops can receive map placements';
  end if;

  if new.created_by is null then
    new.created_by := auth.uid();
  end if;
  if new.created_at is null then
    new.created_at := now();
  end if;

  return new;
end;
$$;

drop trigger if exists shop_placements_before_write on public.shop_placements;
create trigger shop_placements_before_write
  before insert or update on public.shop_placements
  for each row execute procedure public.shop_placements_before_write();

create or replace function public.shop_placements_end_on_unapprove()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.status = 'approved' and new.status is distinct from 'approved' then
    update public.shop_placements
    set ends_at = now()
    where shop_id = new.id
      and ends_at > now();
  end if;
  return new;
end;
$$;

drop trigger if exists shop_placements_end_on_unapprove on public.shops;
create trigger shop_placements_end_on_unapprove
  after update of status on public.shops
  for each row execute procedure public.shop_placements_end_on_unapprove();

create or replace view public.shop_marker_tiers
with (security_invoker = true) as
select
  s.id as shop_id,
  case
    when exists (
      select 1
      from public.shop_placements p
      where p.shop_id = s.id
        and p.kind = 'sponsored'
        and p.starts_at <= now()
        and p.ends_at > now()
    ) then 'promoted'
    when exists (
      select 1
      from public.shop_placements p
      where p.shop_id = s.id
        and p.kind = 'partner'
        and p.starts_at <= now()
        and p.ends_at > now()
    ) then 'partner'
    else 'standard'
  end as marker_tier
from public.shops s
where s.status = 'approved';

comment on view public.shop_marker_tiers is
  'Effective map pin tier for approved shops. Expired placements resolve to standard.';

alter table public.shop_placements enable row level security;

drop policy if exists shop_placements_public_read on public.shop_placements;
create policy shop_placements_public_read
  on public.shop_placements
  for select
  to anon, authenticated
  using (starts_at <= now() and ends_at > now());

drop policy if exists shop_placements_admin_read on public.shop_placements;
create policy shop_placements_admin_read
  on public.shop_placements
  for select
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

drop policy if exists shop_placements_admin_write on public.shop_placements;
create policy shop_placements_admin_write
  on public.shop_placements
  for all
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  )
  with check (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

grant select on public.shop_marker_tiers to anon, authenticated;
grant select on public.shop_placements to anon, authenticated;
grant insert, update, delete on public.shop_placements to authenticated;
