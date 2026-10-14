-- KapéDoko seed: unpublished admin draft so Hidden status renders in /admin/cafes.
-- Safe to run again. Does not appear on Home or Map until an admin publishes it.
-- Requires db/20261013_shop_status_enum_hidden.sql and
-- db/20261013_shop_status_hidden.sql.

insert into public.shops (
  name,
  address,
  latitude,
  longitude,
  categories,
  hours,
  status,
  source
)
select
  'KapeDoko Unpublished Sample',
  '123 Sample Street, San Roque, Marikina',
  14.6507,
  121.1029,
  '{cafe}'::text[],
  '{"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}'::jsonb,
  'hidden',
  'admin'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim('KapeDoko Unpublished Sample'))
    and abs(s.latitude - 14.6507) < 0.00045
    and abs(s.longitude - 121.1029) < 0.00045
);
