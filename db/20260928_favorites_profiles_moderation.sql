-- =========================================================
-- KapéDoko — Profiles, favorites, and content moderation
-- =========================================================
-- Run this in the Supabase SQL editor AFTER 20260909_cafe_reviews.sql.
-- Idempotent: it adds missing profile columns and does not replace
-- an existing profiles table or its rows.
-- =========================================================

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role text not null default 'user',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles add column if not exists display_name text;
alter table public.profiles add column if not exists role text;
alter table public.profiles add column if not exists created_at timestamptz default now();
alter table public.profiles add column if not exists updated_at timestamptz default now();

update public.profiles set role = 'user' where role is null;
update public.profiles set created_at = now() where created_at is null;
update public.profiles set updated_at = now() where updated_at is null;

alter table public.profiles alter column role set default 'user';
alter table public.profiles alter column created_at set default now();
alter table public.profiles alter column updated_at set default now();

insert into public.profiles (id, display_name)
select
  users.id,
  nullif(btrim(coalesce(users.raw_user_meta_data->>'display_name', '')), '')
from auth.users as users
on conflict (id) do nothing;

create or replace function public.is_admin()
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
      and role = 'admin'
  );
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    nullif(btrim(coalesce(new.raw_user_meta_data->>'display_name', '')), '')
  )
  on conflict (id) do update
    set display_name = coalesce(public.profiles.display_name, excluded.display_name),
        updated_at = now();
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create or replace function public.profiles_before_update()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.role is distinct from old.role and not public.is_admin() then
    new.role := old.role;
  end if;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists profiles_before_update on public.profiles;
create trigger profiles_before_update
  before update on public.profiles
  for each row execute procedure public.profiles_before_update();

alter table public.profiles enable row level security;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own
  on public.profiles
  for select
  to authenticated
  using (id = auth.uid() or public.is_admin());

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own
  on public.profiles
  for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

grant select, update on public.profiles to authenticated;

-- --- Favorites ---
create table if not exists public.favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  shop_id uuid not null references public.shops(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, shop_id)
);

create index if not exists favorites_user_created_idx
  on public.favorites (user_id, created_at desc);

alter table public.favorites enable row level security;

drop policy if exists favorites_select_own on public.favorites;
create policy favorites_select_own
  on public.favorites
  for select
  to authenticated
  using (user_id = auth.uid());

drop policy if exists favorites_insert_own on public.favorites;
create policy favorites_insert_own
  on public.favorites
  for insert
  to authenticated
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.shops
      where shops.id = shop_id
        and shops.status = 'approved'
    )
  );

drop policy if exists favorites_delete_own on public.favorites;
create policy favorites_delete_own
  on public.favorites
  for delete
  to authenticated
  using (user_id = auth.uid());

grant select, insert, delete on public.favorites to authenticated;

-- --- Review flags ---
alter table public.reviews add column if not exists flag_reason text;
alter table public.reviews add column if not exists flagged_by uuid;
alter table public.reviews add column if not exists moderated_at timestamptz;
alter table public.reviews add column if not exists moderation_outcome text;

drop policy if exists reviews_admin_read on public.reviews;
create policy reviews_admin_read
  on public.reviews
  for select
  to authenticated
  using (public.is_admin());

-- --- Reports ---
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

alter table public.content_reports drop constraint if exists content_reports_reason_len;
alter table public.content_reports add constraint content_reports_reason_len
  check (reason is null or char_length(reason) <= 280);

create unique index if not exists content_reports_review_uidx
  on public.content_reports (reporter_id, review_id)
  where target_type = 'review' and review_id is not null;

create unique index if not exists content_reports_photo_uidx
  on public.content_reports (reporter_id, shop_id)
  where target_type = 'shop_photo' and shop_id is not null;

create index if not exists content_reports_open_idx
  on public.content_reports (created_at desc)
  where status = 'open';

alter table public.content_reports enable row level security;

drop policy if exists content_reports_admin_all on public.content_reports;
create policy content_reports_admin_all
  on public.content_reports
  for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

grant select, update on public.content_reports to authenticated;

create or replace function public.report_content(
  p_target_type text,
  p_review_id uuid default null,
  p_shop_id uuid default null,
  p_reason text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  clean_reason text := nullif(left(btrim(coalesce(p_reason, '')), 280), '');
  report_id uuid;
begin
  if uid is null then
    raise exception 'Sign in to report this';
  end if;
  if p_target_type not in ('review', 'shop_photo') then
    raise exception 'Unknown report target';
  end if;
  if p_target_type = 'review' and p_review_id is null then
    raise exception 'Review was not found';
  end if;
  if p_target_type = 'shop_photo' and p_shop_id is null then
    raise exception 'Cafe was not found';
  end if;

  if p_target_type = 'review' then
    select id into report_id
    from public.content_reports
    where reporter_id = uid
      and target_type = 'review'
      and review_id = p_review_id
    limit 1;
  else
    select id into report_id
    from public.content_reports
    where reporter_id = uid
      and target_type = 'shop_photo'
      and shop_id = p_shop_id
    limit 1;
  end if;

  if report_id is null then
    insert into public.content_reports (reporter_id, target_type, review_id, shop_id, reason)
    values (uid, p_target_type, p_review_id, p_shop_id, clean_reason)
    returning id into report_id;
  end if;

  if p_target_type = 'review' then
    update public.reviews
    set
      flagged_at = coalesce(flagged_at, now()),
      flagged_by = coalesce(flagged_by, uid),
      flag_reason = coalesce(flag_reason, clean_reason)
    where id = p_review_id;
  end if;

  return report_id;
end;
$$;

create or replace function public.moderate_report(
  p_report_id uuid,
  p_outcome text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  report public.content_reports%rowtype;
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;
  if p_outcome not in ('hidden', 'dismissed') then
    raise exception 'Unknown moderation outcome';
  end if;

  select * into report from public.content_reports where id = p_report_id;
  if report.id is null then
    raise exception 'Report was not found';
  end if;

  update public.content_reports
  set
    status = p_outcome,
    resolved_at = now(),
    resolved_by = auth.uid()
  where id = p_report_id;

  if report.target_type = 'review' and report.review_id is not null then
    if p_outcome = 'hidden' then
      update public.reviews
      set
        flagged_at = coalesce(flagged_at, now()),
        moderated_at = now(),
        moderation_outcome = 'hidden'
      where id = report.review_id;
    else
      update public.reviews
      set
        flagged_at = null,
        moderated_at = now(),
        moderation_outcome = 'restored'
      where id = report.review_id;
    end if;
  end if;
end;
$$;

revoke all on function public.report_content(text, uuid, uuid, text) from public, anon;
revoke all on function public.moderate_report(uuid, text) from public, anon;
grant execute on function public.report_content(text, uuid, uuid, text) to authenticated;
grant execute on function public.moderate_report(uuid, text) to authenticated;

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
        using (submitted_by = auth.uid() or public.is_admin())
    $policy$;
  end if;
end $$;
