-- =========================================================
-- KapéDoko — Structured cafe reviews and busyness check-ins
-- =========================================================
-- Run this in the Supabase SQL editor AFTER 20260909_shop_placements.sql.
--
-- WiFi, outlets, matcha, noise, and stay-fit live on reviews and
-- shop_review_stats — never on shops. One signed-in user may edit
-- one public review per approved cafe. Repeat visits append
-- timestamped busyness reports for heatmap-ready hourly aggregates.
-- Raw check-ins stay private; only rolled-up views are public.
-- =========================================================

alter table public.profiles
  add column if not exists display_name text;

comment on column public.profiles.display_name is
  'Public KapéBean name shown on reviews. Falls back to KapéBean when empty.';

-- The initial reviews table used boolean flags and enums such as
-- wifi_speed_rating. Convert those to text before CHECK constraints
-- and UPDATEs that write values like 'okay' or 'unsure'.
drop view if exists public.shop_reviews_public cascade;
drop view if exists public.shop_review_stats cascade;

do $$
begin
  if exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'shop_review_stats'
      and c.relkind = 'r'
  ) then
    drop table public.shop_review_stats;
  end if;
end $$;

-- --- Reviews ---
create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.shops(id) on delete cascade,
  user_id uuid not null,
  wifi_available text not null,
  wifi_speed text,
  wifi_time_limit text,
  power_available text not null,
  power_access text,
  serves_matcha text not null,
  noise text not null,
  stay_fit text not null,
  recommend boolean not null,
  visit_again boolean not null,
  comment text,
  flagged_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public._reviews_bool_to_tri(value boolean)
returns text
language sql
immutable
as $$
  select case
    when value is true then 'yes'
    when value is false then 'no'
    else 'unsure'
  end;
$$;

-- Convert boolean, enum, or missing columns to plain text. ADD COLUMN IF NOT
-- EXISTS is a no-op when wifi_speed already exists as wifi_speed_rating.
create or replace function public._reviews_ensure_text_column(col text)
returns void
language plpgsql
as $$
declare
  col_type text;
begin
  select t.typname into col_type
  from pg_attribute a
  join pg_class c on c.oid = a.attrelid
  join pg_namespace n on n.oid = c.relnamespace
  join pg_type t on t.oid = a.atttypid
  where n.nspname = 'public'
    and c.relname = 'reviews'
    and a.attname = col
    and a.attnum > 0
    and not a.attisdropped;

  if col_type is null then
    execute format('alter table public.reviews add column %I text', col);
    return;
  end if;

  if col_type in ('text', 'varchar', 'bpchar', 'citext') then
    if col_type <> 'text' then
      execute format(
        'alter table public.reviews alter column %I type text using %I::text',
        col,
        col
      );
    end if;
    return;
  end if;

  execute format('alter table public.reviews alter column %I drop default', col);
  execute format('alter table public.reviews alter column %I drop not null', col);

  if col_type in ('bool', 'boolean') then
    execute format(
      'alter table public.reviews alter column %I type text using public._reviews_bool_to_tri(%I)',
      col,
      col
    );
  else
    execute format(
      'alter table public.reviews alter column %I type text using %I::text',
      col,
      col
    );
  end if;
end;
$$;

alter table public.reviews drop constraint if exists reviews_wifi_available_check;
alter table public.reviews drop constraint if exists reviews_wifi_speed_check;
alter table public.reviews drop constraint if exists reviews_wifi_time_limit_check;
alter table public.reviews drop constraint if exists reviews_power_available_check;
alter table public.reviews drop constraint if exists reviews_power_access_check;
alter table public.reviews drop constraint if exists reviews_serves_matcha_check;
alter table public.reviews drop constraint if exists reviews_noise_check;
alter table public.reviews drop constraint if exists reviews_stay_fit_check;
alter table public.reviews drop constraint if exists reviews_comment_len;
alter table public.reviews drop constraint if exists reviews_wifi_dependents;
alter table public.reviews drop constraint if exists reviews_power_dependents;

select public._reviews_ensure_text_column('wifi_available');
select public._reviews_ensure_text_column('wifi_speed');
select public._reviews_ensure_text_column('wifi_time_limit');
select public._reviews_ensure_text_column('power_available');
select public._reviews_ensure_text_column('power_access');
select public._reviews_ensure_text_column('serves_matcha');
select public._reviews_ensure_text_column('noise');
select public._reviews_ensure_text_column('stay_fit');
select public._reviews_ensure_text_column('comment');

alter table public.reviews add column if not exists shop_id uuid;
alter table public.reviews add column if not exists user_id uuid;
alter table public.reviews add column if not exists recommend boolean;
alter table public.reviews add column if not exists visit_again boolean;
alter table public.reviews add column if not exists flagged_at timestamptz;
alter table public.reviews add column if not exists created_at timestamptz;
alter table public.reviews add column if not exists updated_at timestamptz;

update public.reviews
set
  wifi_available = coalesce(wifi_available, 'unsure'),
  wifi_speed = case
    when lower(coalesce(wifi_speed, '')) in ('slow', 'okay', 'fast') then lower(wifi_speed)
    when lower(coalesce(wifi_speed, '')) in ('medium', 'average', 'ok', 'moderate', 'normal', 'fair') then 'okay'
    else null
  end,
  wifi_time_limit = case
    when lower(coalesce(wifi_time_limit, '')) in ('unlimited', 'voucher', 'purchase', 'unsure') then lower(wifi_time_limit)
    when lower(coalesce(wifi_time_limit, '')) in ('capped', 'timed', 'limited', '2h', 'two_hours') then 'voucher'
    else null
  end,
  power_available = coalesce(power_available, 'unsure'),
  power_access = case
    when lower(coalesce(power_access, '')) in ('easy', 'limited', 'scarce') then lower(power_access)
    when lower(coalesce(power_access, '')) in ('plenty', 'many', 'available') then 'easy'
    when lower(coalesce(power_access, '')) in ('few', 'some') then 'limited'
    when lower(coalesce(power_access, '')) in ('none', 'hard') then 'scarce'
    else null
  end,
  serves_matcha = coalesce(serves_matcha, 'unsure'),
  noise = case
    when lower(coalesce(noise, '')) in ('quiet', 'mixed', 'loud') then lower(noise)
    when lower(coalesce(noise, '')) in ('moderate', 'medium', 'average', 'normal') then 'mixed'
    else 'mixed'
  end,
  stay_fit = case
    when lower(coalesce(stay_fit, '')) in ('long', 'short', 'unsure') then lower(stay_fit)
    when lower(coalesce(stay_fit, '')) in ('laptop', 'work', 'linger') then 'long'
    when lower(coalesce(stay_fit, '')) in ('quick', 'grab') then 'short'
    else 'unsure'
  end,
  recommend = coalesce(recommend, false),
  visit_again = coalesce(visit_again, false),
  created_at = coalesce(created_at, now()),
  updated_at = coalesce(updated_at, now());

update public.reviews
set
  wifi_speed = case when wifi_available = 'yes' then coalesce(wifi_speed, 'okay') else null end,
  wifi_time_limit = case when wifi_available = 'yes' then coalesce(wifi_time_limit, 'unsure') else null end,
  power_access = case when power_available = 'yes' then coalesce(power_access, 'limited') else null end;

alter table public.reviews alter column shop_id set not null;
alter table public.reviews alter column user_id set not null;
alter table public.reviews alter column wifi_available set not null;
alter table public.reviews alter column power_available set not null;
alter table public.reviews alter column serves_matcha set not null;
alter table public.reviews alter column noise set not null;
alter table public.reviews alter column stay_fit set not null;
alter table public.reviews alter column recommend set not null;
alter table public.reviews alter column visit_again set not null;
alter table public.reviews alter column created_at set not null;
alter table public.reviews alter column updated_at set not null;
alter table public.reviews alter column created_at set default now();
alter table public.reviews alter column updated_at set default now();

drop function if exists public._reviews_ensure_text_column(text);
drop function if exists public._reviews_convert_tri_column(text);
drop function if exists public._reviews_bool_to_tri(boolean);

comment on table public.reviews is
  'One structured KapéBean review per user and approved cafe. Amenities are voted here, not stored on shops.';

create unique index if not exists reviews_shop_user_uidx
  on public.reviews (shop_id, user_id);

create index if not exists reviews_shop_created_idx
  on public.reviews (shop_id, created_at desc);

alter table public.reviews drop constraint if exists reviews_wifi_available_check;
alter table public.reviews add constraint reviews_wifi_available_check
  check (wifi_available in ('yes', 'no', 'unsure'));

alter table public.reviews drop constraint if exists reviews_wifi_speed_check;
alter table public.reviews add constraint reviews_wifi_speed_check
  check (wifi_speed is null or wifi_speed in ('slow', 'okay', 'fast'));

alter table public.reviews drop constraint if exists reviews_wifi_time_limit_check;
alter table public.reviews add constraint reviews_wifi_time_limit_check
  check (wifi_time_limit is null or wifi_time_limit in ('unlimited', 'voucher', 'purchase', 'unsure'));

alter table public.reviews drop constraint if exists reviews_power_available_check;
alter table public.reviews add constraint reviews_power_available_check
  check (power_available in ('yes', 'no', 'unsure'));

alter table public.reviews drop constraint if exists reviews_power_access_check;
alter table public.reviews add constraint reviews_power_access_check
  check (power_access is null or power_access in ('easy', 'limited', 'scarce'));

alter table public.reviews drop constraint if exists reviews_serves_matcha_check;
alter table public.reviews add constraint reviews_serves_matcha_check
  check (serves_matcha in ('yes', 'no', 'unsure'));

alter table public.reviews drop constraint if exists reviews_noise_check;
alter table public.reviews add constraint reviews_noise_check
  check (noise in ('quiet', 'mixed', 'loud'));

alter table public.reviews drop constraint if exists reviews_stay_fit_check;
alter table public.reviews add constraint reviews_stay_fit_check
  check (stay_fit in ('long', 'short', 'unsure'));

alter table public.reviews drop constraint if exists reviews_comment_len;
alter table public.reviews add constraint reviews_comment_len
  check (comment is null or char_length(comment) <= 280);

alter table public.reviews drop constraint if exists reviews_wifi_dependents;
alter table public.reviews add constraint reviews_wifi_dependents
  check (
    (wifi_available = 'yes' and wifi_speed is not null and wifi_time_limit is not null)
    or (wifi_available <> 'yes' and wifi_speed is null and wifi_time_limit is null)
  );

alter table public.reviews drop constraint if exists reviews_power_dependents;
alter table public.reviews add constraint reviews_power_dependents
  check (
    (power_available = 'yes' and power_access is not null)
    or (power_available <> 'yes' and power_access is null)
  );

create or replace function public.reviews_before_write()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  shop_status text;
begin
  if new.user_id is null then
    new.user_id := auth.uid();
  end if;
  if new.user_id is null or new.user_id is distinct from auth.uid() then
    raise exception 'Review must belong to the signed-in user';
  end if;

  select status into shop_status from public.shops where id = new.shop_id;
  if shop_status is null then
    raise exception 'Review shop was not found';
  end if;
  if shop_status <> 'approved' then
    raise exception 'Only approved shops can be reviewed';
  end if;

  if new.wifi_available is distinct from 'yes' then
    new.wifi_speed := null;
    new.wifi_time_limit := null;
  end if;
  if new.power_available is distinct from 'yes' then
    new.power_access := null;
  end if;

  new.comment := nullif(btrim(coalesce(new.comment, '')), '');
  if new.created_at is null then
    new.created_at := now();
  end if;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists reviews_before_write on public.reviews;
create trigger reviews_before_write
  before insert or update on public.reviews
  for each row execute procedure public.reviews_before_write();

alter table public.reviews enable row level security;

drop policy if exists reviews_public_read on public.reviews;
create policy reviews_public_read
  on public.reviews
  for select
  to anon, authenticated
  using (
    flagged_at is null
    and exists (
      select 1 from public.shops s
      where s.id = reviews.shop_id and s.status = 'approved'
    )
  );

drop policy if exists reviews_owner_read on public.reviews;
create policy reviews_owner_read
  on public.reviews
  for select
  to authenticated
  using (user_id = auth.uid());

drop policy if exists reviews_owner_insert on public.reviews;
create policy reviews_owner_insert
  on public.reviews
  for insert
  to authenticated
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.shops s
      where s.id = shop_id and s.status = 'approved'
    )
  );

drop policy if exists reviews_owner_update on public.reviews;
create policy reviews_owner_update
  on public.reviews
  for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

grant select on public.reviews to anon, authenticated;
grant insert, update on public.reviews to authenticated;

create or replace view public.shop_reviews_public
with (security_invoker = false) as
select
  r.id,
  r.shop_id,
  r.created_at,
  r.updated_at,
  coalesce(nullif(btrim(p.display_name), ''), 'KapéBean') as author_name,
  r.wifi_available,
  r.wifi_speed,
  r.wifi_time_limit,
  r.power_available,
  r.power_access,
  r.serves_matcha,
  r.noise,
  r.stay_fit,
  r.recommend,
  r.visit_again,
  r.comment
from public.reviews r
left join public.profiles p on p.id = r.user_id
join public.shops s on s.id = r.shop_id
where s.status = 'approved'
  and r.flagged_at is null;

comment on view public.shop_reviews_public is
  'Publishable review cards. Runs as the view owner so display names resolve without exposing profiles. Omits reporter ids.';

grant select on public.shop_reviews_public to anon, authenticated;

-- --- Aggregates (preserve existing Home/Map contract) ---
drop view if exists public.shop_review_stats cascade;

do $$
begin
  if exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'shop_review_stats'
      and c.relkind = 'r'
  ) then
    drop table public.shop_review_stats;
  end if;
end $$;

create view public.shop_review_stats
with (security_invoker = true) as
select
  r.shop_id,
  count(*)::int as total_reviews,
  count(*) filter (where r.wifi_available = 'yes')::int as wifi_yes_count,
  round(
    100.0 * count(*) filter (where r.wifi_available = 'yes')
    / nullif(count(*) filter (where r.wifi_available in ('yes', 'no')), 0)
  ) as wifi_available_pct,
  mode() within group (order by r.wifi_speed) filter (where r.wifi_speed is not null) as wifi_speed_mode,
  mode() within group (order by r.wifi_time_limit) filter (where r.wifi_time_limit is not null) as wifi_time_limit_mode,
  count(*) filter (where r.power_available = 'yes')::int as power_yes_count,
  round(
    100.0 * count(*) filter (where r.power_available = 'yes')
    / nullif(count(*) filter (where r.power_available in ('yes', 'no')), 0)
  ) as power_available_pct,
  mode() within group (order by r.power_access) filter (where r.power_access is not null) as power_access_mode,
  round(100.0 * count(*) filter (where r.recommend) / nullif(count(*), 0)) as recommend_pct,
  round(100.0 * count(*) filter (where r.visit_again) / nullif(count(*), 0)) as visit_again_pct,
  count(*) filter (where r.serves_matcha = 'yes')::int as matcha_yes_count,
  round(
    100.0 * count(*) filter (where r.serves_matcha = 'yes')
    / nullif(count(*) filter (where r.serves_matcha in ('yes', 'no')), 0)
  ) as matcha_available_pct,
  mode() within group (order by r.noise) as noise_mode,
  mode() within group (order by r.stay_fit) filter (where r.stay_fit is not null) as stay_fit_mode
from public.reviews r
join public.shops s on s.id = r.shop_id
where s.status = 'approved'
  and r.flagged_at is null
group by r.shop_id;

comment on view public.shop_review_stats is
  'KapéBean aggregates for approved shops. Unsure answers are excluded from amenity percentages.';

grant select on public.shop_review_stats to anon, authenticated;

-- --- Busyness check-ins (repeat visits; not part of the durable review) ---
create table if not exists public.shop_busyness_reports (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.shops(id) on delete cascade,
  user_id uuid not null,
  level text not null,
  created_at timestamptz not null default now(),
  constraint shop_busyness_level_check check (level in ('quiet', 'comfortable', 'busy', 'full'))
);

comment on table public.shop_busyness_reports is
  'Append-only crowd check-ins. Public clients read hourly and recent aggregates only.';

create index if not exists shop_busyness_reports_shop_created_idx
  on public.shop_busyness_reports (shop_id, created_at desc);

create index if not exists shop_busyness_reports_user_shop_created_idx
  on public.shop_busyness_reports (user_id, shop_id, created_at desc);

create or replace function public.shop_busyness_before_write()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  shop_status text;
begin
  if new.user_id is null then
    new.user_id := auth.uid();
  end if;
  if new.user_id is null or new.user_id is distinct from auth.uid() then
    raise exception 'Busyness check-in must belong to the signed-in user';
  end if;

  select status into shop_status from public.shops where id = new.shop_id;
  if shop_status is null or shop_status <> 'approved' then
    raise exception 'Only approved shops can receive busyness check-ins';
  end if;

  if exists (
    select 1
    from public.shop_busyness_reports existing
    where existing.shop_id = new.shop_id
      and existing.user_id = new.user_id
      and existing.created_at > now() - interval '30 minutes'
  ) then
    raise exception 'busyness_cooldown';
  end if;

  new.created_at := now();
  return new;
end;
$$;

drop trigger if exists shop_busyness_before_write on public.shop_busyness_reports;
create trigger shop_busyness_before_write
  before insert on public.shop_busyness_reports
  for each row execute procedure public.shop_busyness_before_write();

alter table public.shop_busyness_reports enable row level security;

drop policy if exists shop_busyness_owner_insert on public.shop_busyness_reports;
create policy shop_busyness_owner_insert
  on public.shop_busyness_reports
  for insert
  to authenticated
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.shops s
      where s.id = shop_id and s.status = 'approved'
    )
  );

revoke all on public.shop_busyness_reports from anon, authenticated;
grant insert on public.shop_busyness_reports to authenticated;

create or replace view public.shop_busyness_now
with (security_invoker = false) as
select
  shop_id,
  mode() within group (order by level) as level,
  count(*)::int as report_count,
  max(created_at) as last_reported_at
from public.shop_busyness_reports
where created_at > now() - interval '2 hours'
group by shop_id
having count(*) >= 1;

comment on view public.shop_busyness_now is
  'Privacy-safe current crowd level from check-ins in the last two hours. No reporter identities.';

create or replace view public.shop_busyness_hourly
with (security_invoker = false) as
select
  shop_id,
  date_trunc('hour', created_at) as hour_start,
  count(*) filter (where level = 'quiet')::int as quiet_count,
  count(*) filter (where level = 'comfortable')::int as comfortable_count,
  count(*) filter (where level = 'busy')::int as busy_count,
  count(*) filter (where level = 'full')::int as full_count,
  count(*)::int as report_count
from public.shop_busyness_reports
where created_at > now() - interval '14 days'
group by shop_id, date_trunc('hour', created_at);

comment on view public.shop_busyness_hourly is
  'Hourly crowd histogram for heatmap rendering. No reporter identities.';

grant select on public.shop_busyness_now to anon, authenticated;
grant select on public.shop_busyness_hourly to anon, authenticated;
