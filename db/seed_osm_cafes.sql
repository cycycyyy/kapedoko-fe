-- KapéDoko seed: cafes from OpenStreetMap
-- © OpenStreetMap contributors, ODbL. https://www.openstreetmap.org/copyright
-- Inserted here: 304
-- Skipped, no usable name: 69
-- Skipped, no usable address: 1368
-- Skipped, hours missing: 890
-- Skipped, hours unsupported: 33
-- Skipped, outside import regions: 389
-- Skipped, duplicate OSM id: 0
-- Skipped, same name nearby: 0
--
-- Each row starts as pending. Do not use create_admin_shop.
-- Safe to run again: OSM identity and name+~50m guards skip existing rows.
-- Wi-Fi, plugs, photos, and reviews are not invented from the map data.
--
-- Cebu City and Davao City sit outside the Metro Manila polygon.
-- The coverage insert below turns on the Philippines island boxes in
-- this same transaction. shops_require_coverage then accepts those pins.
-- Without the boxes, the first Cebu row raises shops_in_coverage and
-- the transaction rolls back, so only cafes already stored remain.

begin;

insert into public.coverage_regions (id, name, is_active, polygon)
values
  (
    'luzon',
    'Luzon',
    true,
    '{"type":"Polygon","coordinates":[[[119.75,12.05],[124.75,12.05],[124.75,21.25],[119.75,21.25],[119.75,12.05]]]}'::jsonb
  ),
  (
    'palawan',
    'Palawan',
    true,
    '{"type":"Polygon","coordinates":[[[116.85,7.4],[121.5,7.4],[121.5,12.4],[116.85,12.4],[116.85,7.4]]]}'::jsonb
  ),
  (
    'visayas',
    'Visayas',
    true,
    '{"type":"Polygon","coordinates":[[[121.25,8.95],[126.65,8.95],[126.65,12.75],[121.25,12.75],[121.25,8.95]]]}'::jsonb
  ),
  (
    'mindanao',
    'Mindanao',
    true,
    '{"type":"Polygon","coordinates":[[[121.65,5.2],[126.75,5.2],[126.75,10.55],[121.65,10.55],[121.65,5.2]]]}'::jsonb
  ),
  (
    'sulu',
    'Sulu',
    true,
    '{"type":"Polygon","coordinates":[[[119.15,4.55],[122.35,4.55],[122.35,6.9],[119.15,6.9],[119.15,4.55]]]}'::jsonb
  )
on conflict (id) do update
set name = excluded.name,
    is_active = excluded.is_active,
    polygon = excluded.polygon;

-- node/444395107
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Senator Gil J. Puyat Avenue, Makati$ad$,
  14.5611547,
  121.0272048,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:30","close":"20:00"},"tue":{"kind":"open","open":"06:30","close":"20:00"},"wed":{"kind":"open","open":"06:30","close":"20:00"},"thu":{"kind":"open","open":"06:30","close":"20:00"},"fri":{"kind":"open","open":"06:30","close":"20:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+63 2 8670 7648$ph$,
  'pending',
  'openstreetmap',
  'node',
  444395107,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 444395107
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5611547) < 0.00045
    and abs(s.longitude - 121.0272048) < 0.00045
);
-- node/655184597
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Taft Avenue, Manila$ad$,
  14.562763,
  120.9949152,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"00:00"},"tue":{"kind":"open","open":"06:00","close":"00:00"},"wed":{"kind":"open","open":"06:00","close":"00:00"},"thu":{"kind":"open","open":"06:00","close":"00:00"},"fri":{"kind":"open","open":"06:00","close":"00:00"},"sat":{"kind":"open","open":"06:30","close":"00:00"},"sun":{"kind":"open","open":"06:30","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  655184597,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 655184597
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.562763) < 0.00045
    and abs(s.longitude - 120.9949152) < 0.00045
);
-- node/655184647
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$ZUS Coffee$nm$,
  $ad$Taft Avenue, Manila$ad$,
  14.5631444,
  120.9946482,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"21:45"},"tue":{"kind":"open","open":"06:00","close":"21:45"},"wed":{"kind":"open","open":"06:00","close":"21:45"},"thu":{"kind":"open","open":"06:00","close":"21:45"},"fri":{"kind":"open","open":"06:00","close":"21:45"},"sat":{"kind":"open","open":"06:00","close":"21:45"},"sun":{"kind":"open","open":"06:00","close":"21:45"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  655184647,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 655184647
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$ZUS Coffee$dn$))
    and abs(s.latitude - 14.5631444) < 0.00045
    and abs(s.longitude - 120.9946482) < 0.00045
);
-- node/683285920
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Alabang-Zapote Road, Las Piñas$ad$,
  14.4517477,
  120.9772429,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"00:00"},"tue":{"kind":"open","open":"08:00","close":"00:00"},"wed":{"kind":"open","open":"08:00","close":"00:00"},"thu":{"kind":"open","open":"08:00","close":"00:00"},"fri":{"kind":"open","open":"08:00","close":"00:00"},"sat":{"kind":"open","open":"08:00","close":"00:00"},"sun":{"kind":"open","open":"08:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  683285920,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 683285920
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.4517477) < 0.00045
    and abs(s.longitude - 120.9772429) < 0.00045
);
-- node/1068757292
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Common Man Coffee Roasters$nm$,
  $ad$Makati Avenue, Makati$ad$,
  14.5565372,
  121.0235931,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 927 139 5304$ph$,
  'pending',
  'openstreetmap',
  'node',
  1068757292,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1068757292
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Common Man Coffee Roasters$dn$))
    and abs(s.latitude - 14.5565372) < 0.00045
    and abs(s.longitude - 121.0235931) < 0.00045
);
-- node/1236157657
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cafe Bonjour$nm$,
  $ad$Commerce Avenue, Muntinlupa$ad$,
  14.4212866,
  121.0334873,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  1236157657,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1236157657
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cafe Bonjour$dn$))
    and abs(s.latitude - 14.4212866) < 0.00045
    and abs(s.longitude - 121.0334873) < 0.00045
);
-- node/1243320289
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$143 Dela Rosa Street, Makati$ad$,
  14.5585898,
  121.0149221,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  1243320289,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1243320289
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5585898) < 0.00045
    and abs(s.longitude - 121.0149221) < 0.00045
);
-- node/1324283411
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Bistro Ravioli$nm$,
  $ad$Ocean Drive, Pasay$ad$,
  14.5363466,
  120.9812592,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 2 8040577$ph$,
  'pending',
  'openstreetmap',
  'node',
  1324283411,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1324283411
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Bistro Ravioli$dn$))
    and abs(s.latitude - 14.5363466) < 0.00045
    and abs(s.longitude - 120.9812592) < 0.00045
);
-- node/1324283503
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Ocean Drive, Pasay$ad$,
  14.5362478,
  120.9807446,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"23:00"},"tue":{"kind":"open","open":"11:00","close":"23:00"},"wed":{"kind":"open","open":"11:00","close":"23:00"},"thu":{"kind":"open","open":"11:00","close":"23:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  1324283503,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1324283503
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5362478) < 0.00045
    and abs(s.longitude - 120.9807446) < 0.00045
);
-- node/1398950211
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cassalu$nm$,
  $ad$262 Alabang-Zapote Road, Las Piñas$ad$,
  14.4481059,
  120.984144,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"23:00"},"tue":{"kind":"open","open":"08:00","close":"23:00"},"wed":{"kind":"open","open":"08:00","close":"23:00"},"thu":{"kind":"open","open":"08:00","close":"23:00"},"fri":{"kind":"open","open":"08:00","close":"23:00"},"sat":{"kind":"open","open":"08:00","close":"23:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  1398950211,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1398950211
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cassalu$dn$))
    and abs(s.latitude - 14.4481059) < 0.00045
    and abs(s.longitude - 120.984144) < 0.00045
);
-- node/1728952937
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Alabang-Zapote Road, Las Piñas$ad$,
  14.449243,
  120.9809741,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  1728952937,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1728952937
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.449243) < 0.00045
    and abs(s.longitude - 120.9809741) < 0.00045
);
-- node/1740306401
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Taft Avenue, Manila$ad$,
  14.5642099,
  120.9946136,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"01:00"},"tue":{"kind":"open","open":"07:00","close":"01:00"},"wed":{"kind":"open","open":"07:00","close":"01:00"},"thu":{"kind":"open","open":"07:00","close":"01:00"},"fri":{"kind":"open","open":"07:00","close":"01:00"},"sat":{"kind":"open","open":"08:00","close":"00:00"},"sun":{"kind":"open","open":"08:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  1740306401,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1740306401
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5642099) < 0.00045
    and abs(s.longitude - 120.9946136) < 0.00045
);
-- node/2139050708
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$5th Avenue, Taguig$ad$,
  14.5481436,
  121.0463648,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"20:00"},"tue":{"kind":"open","open":"06:00","close":"20:00"},"wed":{"kind":"open","open":"06:00","close":"20:00"},"thu":{"kind":"open","open":"06:00","close":"20:00"},"fri":{"kind":"open","open":"06:00","close":"20:00"},"sat":{"kind":"open","open":"06:00","close":"20:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  2139050708,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 2139050708
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5481436) < 0.00045
    and abs(s.longitude - 121.0463648) < 0.00045
);
-- node/2187192141
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Larry's Café Bar$nm$,
  $ad$11th Avenue, Taguig$ad$,
  14.5497937,
  121.0538987,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"23:00"},"tue":{"kind":"open","open":"07:00","close":"23:00"},"wed":{"kind":"open","open":"07:00","close":"23:00"},"thu":{"kind":"open","open":"07:00","close":"23:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  2187192141,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 2187192141
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Larry's Café Bar$dn$))
    and abs(s.latitude - 14.5497937) < 0.00045
    and abs(s.longitude - 121.0538987) < 0.00045
);
-- node/2189235012
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Daang Hari, Las Piñas$ad$,
  14.3761615,
  121.0125265,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"00:00"},"tue":{"kind":"open","open":"06:00","close":"00:00"},"wed":{"kind":"open","open":"06:00","close":"00:00"},"thu":{"kind":"open","open":"06:00","close":"00:00"},"fri":{"kind":"open","open":"06:00","close":"00:00"},"sat":{"kind":"open","open":"06:00","close":"00:00"},"sun":{"kind":"open","open":"06:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  2189235012,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 2189235012
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.3761615) < 0.00045
    and abs(s.longitude - 121.0125265) < 0.00045
);
-- node/2440067731
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Harlan + Holden Coffee$nm$,
  $ad$Alabang-Zapote Road, Muntinlupa$ad$,
  14.4229662,
  121.0294739,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"23:00"},"tue":{"kind":"open","open":"07:00","close":"23:00"},"wed":{"kind":"open","open":"07:00","close":"23:00"},"thu":{"kind":"open","open":"07:00","close":"23:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  2440067731,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 2440067731
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Harlan + Holden Coffee$dn$))
    and abs(s.latitude - 14.4229662) < 0.00045
    and abs(s.longitude - 121.0294739) < 0.00045
);
-- node/2930421999
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Campus Avenue, Taguig$ad$,
  14.5306457,
  121.0527215,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"01:30"},"tue":{"kind":"open","open":"07:00","close":"01:30"},"wed":{"kind":"open","open":"07:00","close":"01:30"},"thu":{"kind":"open","open":"07:00","close":"01:30"},"fri":{"kind":"open","open":"07:00","close":"01:30"},"sat":{"kind":"open","open":"07:00","close":"01:30"},"sun":{"kind":"open","open":"07:00","close":"01:30"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  2930421999,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 2930421999
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5306457) < 0.00045
    and abs(s.longitude - 121.0527215) < 0.00045
);
-- node/3361731193
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Black Scoop Cafe$nm$,
  $ad$BF Resort Drive, Las Piñas$ad$,
  14.4328061,
  120.9901463,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"00:00"},"tue":{"kind":"open","open":"10:00","close":"00:00"},"wed":{"kind":"open","open":"10:00","close":"00:00"},"thu":{"kind":"open","open":"10:00","close":"00:00"},"fri":{"kind":"open","open":"10:00","close":"00:00"},"sat":{"kind":"open","open":"10:00","close":"00:00"},"sun":{"kind":"open","open":"10:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  3361731193,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 3361731193
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Black Scoop Cafe$dn$))
    and abs(s.latitude - 14.4328061) < 0.00045
    and abs(s.longitude - 120.9901463) < 0.00045
);
-- node/3591122817
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$FILC Coffee + Pastries$nm$,
  $ad$Sunrise Drive, Pasay$ad$,
  14.5344071,
  120.9858326,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"23:00"},"tue":{"kind":"open","open":"06:00","close":"23:00"},"wed":{"kind":"open","open":"06:00","close":"23:00"},"thu":{"kind":"open","open":"06:00","close":"23:00"},"fri":{"kind":"open","open":"06:00","close":"23:00"},"sat":{"kind":"open","open":"06:00","close":"23:00"},"sun":{"kind":"open","open":"06:00","close":"23:00"}}$hr$::jsonb,
  $ph$+639674398673$ph$,
  'pending',
  'openstreetmap',
  'node',
  3591122817,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 3591122817
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$FILC Coffee + Pastries$dn$))
    and abs(s.latitude - 14.5344071) < 0.00045
    and abs(s.longitude - 120.9858326) < 0.00045
);
-- node/3711963875
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Martabak Cafe$nm$,
  $ad$Pacific Drive, Pasay$ad$,
  14.5363456,
  120.9826402,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 (917) 5300875$ph$,
  'pending',
  'openstreetmap',
  'node',
  3711963875,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 3711963875
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Martabak Cafe$dn$))
    and abs(s.latitude - 14.5363456) < 0.00045
    and abs(s.longitude - 120.9826402) < 0.00045
);
-- node/3711963878
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Rivera Cafe$nm$,
  $ad$EDSA, Pasay$ad$,
  14.5367896,
  120.9937559,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"23:00"},"tue":{"kind":"open","open":"06:00","close":"23:00"},"wed":{"kind":"open","open":"06:00","close":"23:00"},"thu":{"kind":"open","open":"06:00","close":"23:00"},"fri":{"kind":"open","open":"06:00","close":"23:00"},"sat":{"kind":"open","open":"06:00","close":"23:00"},"sun":{"kind":"open","open":"06:00","close":"23:00"}}$hr$::jsonb,
  $ph$+63 2 854 8888$ph$,
  'pending',
  'openstreetmap',
  'node',
  3711963878,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 3711963878
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Rivera Cafe$dn$))
    and abs(s.latitude - 14.5367896) < 0.00045
    and abs(s.longitude - 120.9937559) < 0.00045
);
-- node/3909460065
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Nono's$nm$,
  $ad$117 Gamboa Street, Makati$ad$,
  14.5534787,
  121.0168339,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"22:00"},"tue":{"kind":"open","open":"06:00","close":"22:00"},"wed":{"kind":"open","open":"06:00","close":"22:00"},"thu":{"kind":"open","open":"06:00","close":"22:00"},"fri":{"kind":"open","open":"06:00","close":"22:00"},"sat":{"kind":"open","open":"06:00","close":"22:00"},"sun":{"kind":"open","open":"06:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 955-451-6373$ph$,
  'pending',
  'openstreetmap',
  'node',
  3909460065,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 3909460065
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Nono's$dn$))
    and abs(s.latitude - 14.5534787) < 0.00045
    and abs(s.longitude - 121.0168339) < 0.00045
);
-- node/4140147322
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$I Love Milktea$nm$,
  $ad$Greenheights Avenue$ad$,
  14.468104,
  121.0143889,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4140147322,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4140147322
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$I Love Milktea$dn$))
    and abs(s.latitude - 14.468104) < 0.00045
    and abs(s.longitude - 121.0143889) < 0.00045
);
-- node/4435497559
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Harbor Drive, Pasay$ad$,
  14.5398731,
  120.9824605,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4435497559,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4435497559
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5398731) < 0.00045
    and abs(s.longitude - 120.9824605) < 0.00045
);
-- node/4435497560
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Coffee Bean & Tea Leaf$nm$,
  $ad$Coral Way, Pasay$ad$,
  14.5310438,
  120.9836621,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"00:00"},"tue":{"kind":"open","open":"10:00","close":"00:00"},"wed":{"kind":"open","open":"10:00","close":"00:00"},"thu":{"kind":"open","open":"10:00","close":"00:00"},"fri":{"kind":"open","open":"10:00","close":"00:00"},"sat":{"kind":"open","open":"10:00","close":"00:00"},"sun":{"kind":"open","open":"10:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4435497560,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4435497560
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Coffee Bean & Tea Leaf$dn$))
    and abs(s.latitude - 14.5310438) < 0.00045
    and abs(s.longitude - 120.9836621) < 0.00045
);
-- node/4463061289
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Claudine's Homemade Classics$nm$,
  $ad$33 Hamburg$ad$,
  14.4916239,
  121.0233406,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"09:00","close":"22:00"},"sun":{"kind":"open","open":"09:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 917 532 2300$ph$,
  'pending',
  'openstreetmap',
  'node',
  4463061289,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4463061289
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Claudine's Homemade Classics$dn$))
    and abs(s.latitude - 14.4916239) < 0.00045
    and abs(s.longitude - 121.0233406) < 0.00045
);
-- node/4524696230
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$EDSA, Makati$ad$,
  14.541127,
  121.0191042,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:30","close":"22:30"},"tue":{"kind":"open","open":"06:30","close":"22:30"},"wed":{"kind":"open","open":"06:30","close":"22:30"},"thu":{"kind":"open","open":"06:30","close":"22:30"},"fri":{"kind":"open","open":"06:30","close":"22:30"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4524696230,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4524696230
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.541127) < 0.00045
    and abs(s.longitude - 121.0191042) < 0.00045
);
-- node/4707778190
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$14 Jupiter Street, Makati$ad$,
  14.5572875,
  121.0341054,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"00:00"},"tue":{"kind":"open","open":"06:00","close":"00:00"},"wed":{"kind":"open","open":"06:00","close":"00:00"},"thu":{"kind":"open","open":"06:00","close":"00:00"},"fri":{"kind":"open","open":"06:00","close":"00:00"},"sat":{"kind":"open","open":"06:00","close":"00:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+63 2 8896 2755$ph$,
  'pending',
  'openstreetmap',
  'node',
  4707778190,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4707778190
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5572875) < 0.00045
    and abs(s.longitude - 121.0341054) < 0.00045
);
-- node/4742597544
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Coffee Bean & Tea Leaf$nm$,
  $ad$National Road, Muntinlupa$ad$,
  14.4118382,
  121.0466842,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4742597544,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4742597544
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Coffee Bean & Tea Leaf$dn$))
    and abs(s.latitude - 14.4118382) < 0.00045
    and abs(s.longitude - 121.0466842) < 0.00045
);
-- node/4755621644
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Dakasi$nm$,
  $ad$Leon Guinto Street$ad$,
  14.5651517,
  120.9950889,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:00"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"11:00","close":"21:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"open","open":"11:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4755621644,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4755621644
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Dakasi$dn$))
    and abs(s.latitude - 14.5651517) < 0.00045
    and abs(s.longitude - 120.9950889) < 0.00045
);
-- node/5040106327
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$communeph$nm$,
  $ad$36 Polaris Street, Makati$ad$,
  14.5626377,
  121.0301249,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"00:00"},"tue":{"kind":"open","open":"08:00","close":"00:00"},"wed":{"kind":"open","open":"08:00","close":"00:00"},"thu":{"kind":"open","open":"08:00","close":"00:00"},"fri":{"kind":"open","open":"08:00","close":"01:00"},"sat":{"kind":"open","open":"08:00","close":"01:00"},"sun":{"kind":"open","open":"09:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 9198595848$ph$,
  'pending',
  'openstreetmap',
  'node',
  5040106327,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5040106327
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$communeph$dn$))
    and abs(s.latitude - 14.5626377) < 0.00045
    and abs(s.longitude - 121.0301249) < 0.00045
);
-- node/5313870163
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$CoCo Fresh Tea & Juice$nm$,
  $ad$Madrigal Avenue, Muntinlupa$ad$,
  14.4242796,
  121.0266918,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  5313870163,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5313870163
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$CoCo Fresh Tea & Juice$dn$))
    and abs(s.latitude - 14.4242796) < 0.00045
    and abs(s.longitude - 121.0266918) < 0.00045
);
-- node/5480890050
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Toby's Estate$nm$,
  $ad$Legazpi Street, Makati$ad$,
  14.5546813,
  121.0168619,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"20:00"},"tue":{"kind":"open","open":"07:00","close":"20:00"},"wed":{"kind":"open","open":"07:00","close":"20:00"},"thu":{"kind":"open","open":"07:00","close":"20:00"},"fri":{"kind":"open","open":"07:00","close":"20:00"},"sat":{"kind":"open","open":"07:00","close":"20:00"},"sun":{"kind":"open","open":"07:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  5480890050,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5480890050
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Toby's Estate$dn$))
    and abs(s.latitude - 14.5546813) < 0.00045
    and abs(s.longitude - 121.0168619) < 0.00045
);
-- node/5552580597
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Seaside Drive, Parañaque$ad$,
  14.5121877,
  120.9801539,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"00:00"},"tue":{"kind":"open","open":"08:00","close":"00:00"},"wed":{"kind":"open","open":"08:00","close":"00:00"},"thu":{"kind":"open","open":"08:00","close":"00:00"},"fri":{"kind":"open","open":"08:00","close":"00:00"},"sat":{"kind":"open","open":"08:00","close":"00:00"},"sun":{"kind":"open","open":"08:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  5552580597,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5552580597
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5121877) < 0.00045
    and abs(s.longitude - 120.9801539) < 0.00045
);
-- node/5807612430
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Tim Hortons$nm$,
  $ad$11th Drive, Taguig$ad$,
  14.5558262,
  121.054276,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  5807612430,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5807612430
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Tim Hortons$dn$))
    and abs(s.latitude - 14.5558262) < 0.00045
    and abs(s.longitude - 121.054276) < 0.00045
);
-- node/5981243991
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Doña Soledad Avenue$ad$,
  14.4858814,
  121.0425927,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  5981243991,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5981243991
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.4858814) < 0.00045
    and abs(s.longitude - 121.0425927) < 0.00045
);
-- node/6000718206
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Coffee Project$nm$,
  $ad$East Service Road, Muntinlupa$ad$,
  14.456818,
  121.0457712,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  $ph$+639099416381$ph$,
  'pending',
  'openstreetmap',
  'node',
  6000718206,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6000718206
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Coffee Project$dn$))
    and abs(s.latitude - 14.456818) < 0.00045
    and abs(s.longitude - 121.0457712) < 0.00045
);
-- node/6006451997
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Habitual Coffee$nm$,
  $ad$136 L. P. Leviste Street, Makati$ad$,
  14.559398,
  121.0226688,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"open","open":"11:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  6006451997,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6006451997
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Habitual Coffee$dn$))
    and abs(s.latitude - 14.559398) < 0.00045
    and abs(s.longitude - 121.0226688) < 0.00045
);
-- node/6494164485
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Savoy Cafe$nm$,
  $ad$101 Andrews Avenue$ad$,
  14.5237537,
  121.0125853,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"22:00"},"tue":{"kind":"open","open":"06:00","close":"22:00"},"wed":{"kind":"open","open":"06:00","close":"22:00"},"thu":{"kind":"open","open":"06:00","close":"22:00"},"fri":{"kind":"open","open":"06:00","close":"22:00"},"sat":{"kind":"open","open":"06:00","close":"22:00"},"sun":{"kind":"open","open":"06:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  6494164485,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6494164485
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Savoy Cafe$dn$))
    and abs(s.latitude - 14.5237537) < 0.00045
    and abs(s.longitude - 121.0125853) < 0.00045
);
-- node/6583366543
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Sekretong hardin$nm$,
  $ad$8760 Santol Street, Makati$ad$,
  14.5639584,
  121.007971,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  $ph$02 86711978$ph$,
  'pending',
  'openstreetmap',
  'node',
  6583366543,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6583366543
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Sekretong hardin$dn$))
    and abs(s.latitude - 14.5639584) < 0.00045
    and abs(s.longitude - 121.007971) < 0.00045
);
-- node/7798186085
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Tim Hortons$nm$,
  $ad$Burgos Circle, Taguig$ad$,
  14.552386,
  121.0440129,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"18:00"},"tue":{"kind":"open","open":"09:00","close":"18:00"},"wed":{"kind":"open","open":"09:00","close":"18:00"},"thu":{"kind":"open","open":"09:00","close":"18:00"},"fri":{"kind":"open","open":"09:00","close":"18:00"},"sat":{"kind":"open","open":"09:00","close":"18:00"},"sun":{"kind":"open","open":"09:00","close":"18:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  7798186085,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 7798186085
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Tim Hortons$dn$))
    and abs(s.latitude - 14.552386) < 0.00045
    and abs(s.longitude - 121.0440129) < 0.00045
);
-- node/7801248349
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Tim Hortons$nm$,
  $ad$Upper McKinley Road, Taguig$ad$,
  14.534558,
  121.0502969,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  7801248349,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 7801248349
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Tim Hortons$dn$))
    and abs(s.latitude - 14.534558) < 0.00045
    and abs(s.longitude - 121.0502969) < 0.00045
);
-- node/7866991828
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Chachago$nm$,
  $ad$330 Aguirre Avenue$ad$,
  14.4563107,
  121.0083931,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:30"},"tue":{"kind":"open","open":"11:00","close":"21:30"},"wed":{"kind":"open","open":"11:00","close":"21:30"},"thu":{"kind":"open","open":"11:00","close":"21:30"},"fri":{"kind":"open","open":"11:00","close":"21:30"},"sat":{"kind":"open","open":"11:00","close":"21:30"},"sun":{"kind":"open","open":"11:00","close":"21:30"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  7866991828,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 7866991828
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Chachago$dn$))
    and abs(s.latitude - 14.4563107) < 0.00045
    and abs(s.longitude - 121.0083931) < 0.00045
);
-- node/7895964285
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Tim Hortons$nm$,
  $ad$Taft Avenue$ad$,
  14.5623907,
  120.9953994,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"open","open":"07:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  7895964285,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 7895964285
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Tim Hortons$dn$))
    and abs(s.latitude - 14.5623907) < 0.00045
    and abs(s.longitude - 120.9953994) < 0.00045
);
-- node/8326628617
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Fat Seed$nm$,
  $ad$1 27th Street$ad$,
  14.5489376,
  121.0502061,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  $ph$0270011862$ph$,
  'pending',
  'openstreetmap',
  'node',
  8326628617,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 8326628617
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Fat Seed$dn$))
    and abs(s.latitude - 14.5489376) < 0.00045
    and abs(s.longitude - 121.0502061) < 0.00045
);
-- node/9126140120
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$8065 Coffee$nm$,
  $ad$7700 Saint Paul Road$ad$,
  14.5644767,
  121.0108821,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"23:00"},"tue":{"kind":"open","open":"09:00","close":"23:00"},"wed":{"kind":"open","open":"09:00","close":"23:00"},"thu":{"kind":"open","open":"09:00","close":"23:00"},"fri":{"kind":"open","open":"09:00","close":"23:00"},"sat":{"kind":"open","open":"09:00","close":"23:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  9126140120,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9126140120
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$8065 Coffee$dn$))
    and abs(s.latitude - 14.5644767) < 0.00045
    and abs(s.longitude - 121.0108821) < 0.00045
);
-- node/9591509511
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Sentro Fortis Café$nm$,
  $ad$Victoria Avenue, Muntinlupa$ad$,
  14.3533661,
  121.0098598,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:30","close":"20:00"},"tue":{"kind":"open","open":"07:30","close":"20:00"},"wed":{"kind":"open","open":"07:30","close":"20:00"},"thu":{"kind":"open","open":"07:30","close":"20:00"},"fri":{"kind":"open","open":"07:30","close":"20:00"},"sat":{"kind":"open","open":"07:30","close":"20:00"},"sun":{"kind":"open","open":"07:30","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  9591509511,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9591509511
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Sentro Fortis Café$dn$))
    and abs(s.latitude - 14.3533661) < 0.00045
    and abs(s.longitude - 121.0098598) < 0.00045
);
-- node/9685460904
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Macao Imperial Tea$nm$,
  $ad$Daang Hari, Las Piñas$ad$,
  14.4136273,
  121.0165535,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  9685460904,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9685460904
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Macao Imperial Tea$dn$))
    and abs(s.latitude - 14.4136273) < 0.00045
    and abs(s.longitude - 121.0165535) < 0.00045
);
-- node/9776257231
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Coffee Tonya$nm$,
  $ad$4970 P. Guanzon Street, Makati City$ad$,
  14.5657635,
  121.0305475,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"21:00"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"00:00"},"sat":{"kind":"open","open":"10:00","close":"00:00"},"sun":{"kind":"open","open":"11:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63288995410$ph$,
  'pending',
  'openstreetmap',
  'node',
  9776257231,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9776257231
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Coffee Tonya$dn$))
    and abs(s.latitude - 14.5657635) < 0.00045
    and abs(s.longitude - 121.0305475) < 0.00045
);
-- node/10075888065
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$GoodGood$nm$,
  $ad$Vatican City Drive, Las Piñas$ad$,
  14.4301586,
  120.9897609,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:00","close":"20:30"},"tue":{"kind":"open","open":"12:00","close":"20:30"},"wed":{"kind":"open","open":"12:00","close":"20:30"},"thu":{"kind":"open","open":"12:00","close":"20:30"},"fri":{"kind":"open","open":"12:00","close":"21:00"},"sat":{"kind":"open","open":"12:00","close":"21:00"},"sun":{"kind":"open","open":"12:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63 977 655 9513$ph$,
  'pending',
  'openstreetmap',
  'node',
  10075888065,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10075888065
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$GoodGood$dn$))
    and abs(s.latitude - 14.4301586) < 0.00045
    and abs(s.longitude - 120.9897609) < 0.00045
);
-- node/10078637168
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Wallflower Café$nm$,
  $ad$Alabang-Zapote Road, Muntinlupa$ad$,
  14.4233625,
  121.0298278,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:00"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"11:00","close":"21:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"10:00","close":"21:00"},"sun":{"kind":"open","open":"10:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10078637168,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10078637168
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Wallflower Café$dn$))
    and abs(s.latitude - 14.4233625) < 0.00045
    and abs(s.longitude - 121.0298278) < 0.00045
);
-- node/10121140046
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cafe Oasis$nm$,
  $ad$Pasig Boulevard Extension, Pasig$ad$,
  14.5661772,
  121.07635,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"23:00"},"tue":{"kind":"open","open":"11:00","close":"23:00"},"wed":{"kind":"open","open":"11:00","close":"23:00"},"thu":{"kind":"open","open":"11:00","close":"23:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  $ph$+63 9763197146$ph$,
  'pending',
  'openstreetmap',
  'node',
  10121140046,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10121140046
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cafe Oasis$dn$))
    and abs(s.latitude - 14.5661772) < 0.00045
    and abs(s.longitude - 121.07635) < 0.00045
);
-- node/10170284060
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Founders Donut$nm$,
  $ad$Zobel Roxas Street, Makati$ad$,
  14.5646854,
  121.00192,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"20:00"},"tue":{"kind":"open","open":"09:00","close":"20:00"},"wed":{"kind":"open","open":"09:00","close":"20:00"},"thu":{"kind":"open","open":"09:00","close":"20:00"},"fri":{"kind":"open","open":"09:00","close":"20:00"},"sat":{"kind":"open","open":"09:00","close":"20:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+63945 882 5167$ph$,
  'pending',
  'openstreetmap',
  'node',
  10170284060,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10170284060
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Founders Donut$dn$))
    and abs(s.latitude - 14.5646854) < 0.00045
    and abs(s.longitude - 121.00192) < 0.00045
);
-- node/10177462917
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Projuice$nm$,
  $ad$Taft Avenue$ad$,
  14.5653511,
  120.9947375,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"00:00"},"tue":{"kind":"open","open":"08:00","close":"00:00"},"wed":{"kind":"open","open":"08:00","close":"00:00"},"thu":{"kind":"open","open":"08:00","close":"00:00"},"fri":{"kind":"open","open":"08:00","close":"00:00"},"sat":{"kind":"open","open":"08:00","close":"00:00"},"sun":{"kind":"open","open":"08:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10177462917,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10177462917
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Projuice$dn$))
    and abs(s.latitude - 14.5653511) < 0.00045
    and abs(s.longitude - 120.9947375) < 0.00045
);
-- node/10196122994
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Yani Café$nm$,
  $ad$9 A. Mabini Street$ad$,
  14.564808,
  121.0756667,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:00","close":"21:00"},"tue":{"kind":"open","open":"12:00","close":"21:00"},"wed":{"kind":"open","open":"12:00","close":"21:00"},"thu":{"kind":"open","open":"12:00","close":"21:00"},"fri":{"kind":"open","open":"12:00","close":"21:00"},"sat":{"kind":"open","open":"12:00","close":"21:00"},"sun":{"kind":"open","open":"12:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63277527533$ph$,
  'pending',
  'openstreetmap',
  'node',
  10196122994,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10196122994
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Yani Café$dn$))
    and abs(s.latitude - 14.564808) < 0.00045
    and abs(s.longitude - 121.0756667) < 0.00045
);
-- node/10201106917
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Good Sh*t Coffee$nm$,
  $ad$5872 Enriquez Street$ad$,
  14.5642082,
  121.0319094,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"22:00"},"tue":{"kind":"open","open":"06:00","close":"22:00"},"wed":{"kind":"open","open":"06:00","close":"22:00"},"thu":{"kind":"open","open":"06:00","close":"22:00"},"fri":{"kind":"open","open":"06:00","close":"00:00"},"sat":{"kind":"open","open":"06:00","close":"00:00"},"sun":{"kind":"open","open":"06:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10201106917,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10201106917
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Good Sh*t Coffee$dn$))
    and abs(s.latitude - 14.5642082) < 0.00045
    and abs(s.longitude - 121.0319094) < 0.00045
);
-- node/10239331309
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$RebecCafé$nm$,
  $ad$Blk8 Lot13 Iris Street$ad$,
  14.3962753,
  121.0350962,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"15:00","close":"22:00"},"tue":{"kind":"open","open":"15:00","close":"22:00"},"wed":{"kind":"open","open":"15:00","close":"22:00"},"thu":{"kind":"open","open":"15:00","close":"22:00"},"fri":{"kind":"open","open":"15:00","close":"22:00"},"sat":{"kind":"open","open":"15:00","close":"22:00"},"sun":{"kind":"open","open":"15:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10239331309,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10239331309
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$RebecCafé$dn$))
    and abs(s.latitude - 14.3962753) < 0.00045
    and abs(s.longitude - 121.0350962) < 0.00045
);
-- node/10752396505
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Nitro 7 Coffee Bar$nm$,
  $ad$Fidel A. Reyes Street$ad$,
  14.5658193,
  120.9930943,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"20:00"},"tue":{"kind":"open","open":"07:00","close":"20:00"},"wed":{"kind":"open","open":"07:00","close":"20:00"},"thu":{"kind":"open","open":"07:00","close":"20:00"},"fri":{"kind":"open","open":"07:00","close":"20:00"},"sat":{"kind":"open","open":"07:00","close":"20:00"},"sun":{"kind":"open","open":"07:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10752396505,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10752396505
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Nitro 7 Coffee Bar$dn$))
    and abs(s.latitude - 14.5658193) < 0.00045
    and abs(s.longitude - 120.9930943) < 0.00045
);
-- node/10951681908
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Coffee Spot$nm$,
  $ad$BF Resort Drive, Las Piñas$ad$,
  14.4431138,
  120.9925055,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"23:00"},"tue":{"kind":"open","open":"08:00","close":"23:00"},"wed":{"kind":"open","open":"08:00","close":"23:00"},"thu":{"kind":"open","open":"08:00","close":"23:00"},"fri":{"kind":"open","open":"08:00","close":"23:00"},"sat":{"kind":"open","open":"08:00","close":"23:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  $ph$+63 2 7005 8347$ph$,
  'pending',
  'openstreetmap',
  'node',
  10951681908,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10951681908
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Coffee Spot$dn$))
    and abs(s.latitude - 14.4431138) < 0.00045
    and abs(s.longitude - 120.9925055) < 0.00045
);
-- node/10983530498
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$8680 Coffee$nm$,
  $ad$Finlandia Street$ad$,
  14.5562059,
  121.0056771,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"11:30"},"tue":{"kind":"open","open":"08:00","close":"11:30"},"wed":{"kind":"open","open":"08:00","close":"11:30"},"thu":{"kind":"open","open":"08:00","close":"11:30"},"fri":{"kind":"open","open":"08:00","close":"11:30"},"sat":{"kind":"open","open":"08:00","close":"11:30"},"sun":{"kind":"open","open":"08:00","close":"11:30"}}$hr$::jsonb,
  $ph$+63917 463 4131$ph$,
  'pending',
  'openstreetmap',
  'node',
  10983530498,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10983530498
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$8680 Coffee$dn$))
    and abs(s.latitude - 14.5562059) < 0.00045
    and abs(s.longitude - 121.0056771) < 0.00045
);
-- node/11365940489
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Drip Kofi$nm$,
  $ad$Taft Avenue$ad$,
  14.565191,
  120.9943866,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"00:00"},"tue":{"kind":"open","open":"08:00","close":"00:00"},"wed":{"kind":"open","open":"08:00","close":"00:00"},"thu":{"kind":"open","open":"08:00","close":"00:00"},"fri":{"kind":"open","open":"08:00","close":"00:00"},"sat":{"kind":"open","open":"08:00","close":"00:00"},"sun":{"kind":"open","open":"08:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11365940489,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11365940489
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Drip Kofi$dn$))
    and abs(s.latitude - 14.565191) < 0.00045
    and abs(s.longitude - 120.9943866) < 0.00045
);
-- node/11747395869
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Brioso Coffee$nm$,
  $ad$A. Arnaiz Avenue, Makati City$ad$,
  14.5516534,
  121.0138417,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:30","close":"00:30"},"tue":{"kind":"open","open":"08:30","close":"00:30"},"wed":{"kind":"open","open":"08:30","close":"00:30"},"thu":{"kind":"open","open":"08:30","close":"00:30"},"fri":{"kind":"open","open":"08:30","close":"00:30"},"sat":{"kind":"open","open":"08:30","close":"00:30"},"sun":{"kind":"open","open":"08:30","close":"00:30"}}$hr$::jsonb,
  $ph$+63 927 365 1307$ph$,
  'pending',
  'openstreetmap',
  'node',
  11747395869,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11747395869
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Brioso Coffee$dn$))
    and abs(s.latitude - 14.5516534) < 0.00045
    and abs(s.longitude - 121.0138417) < 0.00045
);
-- node/11757381694
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Mixue$nm$,
  $ad$2024-2032 Taft Avenue$ad$,
  14.5552741,
  120.9970254,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"09:00","close":"22:00"},"sun":{"kind":"open","open":"09:00","close":"22:00"}}$hr$::jsonb,
  $ph$09156536208$ph$,
  'pending',
  'openstreetmap',
  'node',
  11757381694,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11757381694
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Mixue$dn$))
    and abs(s.latitude - 14.5552741) < 0.00045
    and abs(s.longitude - 120.9970254) < 0.00045
);
-- node/11757381698
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Unnie Cafe$nm$,
  $ad$1768-C Taft Avenue$ad$,
  14.5593277,
  120.9960653,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"20:00"},"tue":{"kind":"open","open":"10:00","close":"20:00"},"wed":{"kind":"open","open":"10:00","close":"20:00"},"thu":{"kind":"open","open":"10:00","close":"20:00"},"fri":{"kind":"open","open":"10:00","close":"20:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11757381698,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11757381698
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Unnie Cafe$dn$))
    and abs(s.latitude - 14.5593277) < 0.00045
    and abs(s.longitude - 120.9960653) < 0.00045
);
-- node/11803939644
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Nihon Cafe$nm$,
  $ad$Estrella Street$ad$,
  14.5603382,
  121.0401542,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  $ph$+63995 447 1107$ph$,
  'pending',
  'openstreetmap',
  'node',
  11803939644,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11803939644
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Nihon Cafe$dn$))
    and abs(s.latitude - 14.5603382) < 0.00045
    and abs(s.longitude - 121.0401542) < 0.00045
);
-- node/11850186369
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Kāffēī Diàn$nm$,
  $ad$Gladiola Street$ad$,
  14.4611117,
  121.0385167,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"open","open":"07:00","close":"21:00"}}$hr$::jsonb,
  $ph$+639625581886$ph$,
  'pending',
  'openstreetmap',
  'node',
  11850186369,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11850186369
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Kāffēī Diàn$dn$))
    and abs(s.latitude - 14.4611117) < 0.00045
    and abs(s.longitude - 121.0385167) < 0.00045
);
-- node/11971794118
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$6754 Ayala Avenue, Makati$ad$,
  14.5552605,
  121.0230457,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"06:30","close":"02:00"},"fri":{"kind":"open","open":"06:30","close":"02:00"},"sat":{"kind":"open","open":"06:30","close":"02:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11971794118,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11971794118
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5552605) < 0.00045
    and abs(s.longitude - 121.0230457) < 0.00045
);
-- node/12079464090
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$BF Resort Drive, Las Piñas$ad$,
  14.4406582,
  120.9910129,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12079464090,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12079464090
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.4406582) < 0.00045
    and abs(s.longitude - 120.9910129) < 0.00045
);
-- node/12185993775
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Curious Coffee Co$nm$,
  $ad$2nd Floor 330 Aguirre Avenue$ad$,
  14.4564003,
  121.0080899,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"09:00","close":"22:00"},"sun":{"kind":"open","open":"09:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12185993775,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12185993775
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Curious Coffee Co$dn$))
    and abs(s.latitude - 14.4564003) < 0.00045
    and abs(s.longitude - 121.0080899) < 0.00045
);
-- node/12366464426
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$My Dream of Flavors$nm$,
  $ad$340 Aguirre Avenue$ad$,
  14.4565547,
  121.0073628,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12366464426,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12366464426
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$My Dream of Flavors$dn$))
    and abs(s.latitude - 14.4565547) < 0.00045
    and abs(s.longitude - 121.0073628) < 0.00045
);
-- node/12450696952
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$ASEAN Avenue$ad$,
  14.5236134,
  120.991957,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"03:00"},"tue":{"kind":"open","open":"06:00","close":"03:00"},"wed":{"kind":"open","open":"06:00","close":"03:00"},"thu":{"kind":"open","open":"06:00","close":"03:00"},"fri":{"kind":"open","open":"06:00","close":"03:00"},"sat":{"kind":"open","open":"07:00","close":"02:00"},"sun":{"kind":"open","open":"07:00","close":"02:00"}}$hr$::jsonb,
  $ph$+63 279788900$ph$,
  'pending',
  'openstreetmap',
  'node',
  12450696952,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12450696952
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5236134) < 0.00045
    and abs(s.longitude - 120.991957) < 0.00045
);
-- node/12453122775
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Hills & Valleys Cafe$nm$,
  $ad$Taguig City$ad$,
  14.4892352,
  121.0530327,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"00:00"},"tue":{"kind":"open","open":"11:00","close":"00:00"},"wed":{"kind":"open","open":"11:00","close":"00:00"},"thu":{"kind":"open","open":"11:00","close":"00:00"},"fri":{"kind":"open","open":"11:00","close":"00:00"},"sat":{"kind":"open","open":"13:00","close":"00:00"},"sun":{"kind":"open","open":"13:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12453122775,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12453122775
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Hills & Valleys Cafe$dn$))
    and abs(s.latitude - 14.4892352) < 0.00045
    and abs(s.longitude - 121.0530327) < 0.00045
);
-- node/12498371768
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Tealive$nm$,
  $ad$Ayala Malls Manila Bay$ad$,
  14.5222786,
  120.9885602,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12498371768,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12498371768
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Tealive$dn$))
    and abs(s.latitude - 14.5222786) < 0.00045
    and abs(s.longitude - 120.9885602) < 0.00045
);
-- node/12663629207
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Café Arabella$nm$,
  $ad$27 Alcalde Jose Street$ad$,
  14.5615192,
  121.0745754,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"09:00","close":"22:00"},"sun":{"kind":"open","open":"09:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12663629207,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12663629207
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Café Arabella$dn$))
    and abs(s.latitude - 14.5615192) < 0.00045
    and abs(s.longitude - 121.0745754) < 0.00045
);
-- node/12690311039
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$éllatte coffee$nm$,
  $ad$Taft Avenue$ad$,
  14.5652746,
  120.9943778,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"23:00"},"tue":{"kind":"open","open":"08:00","close":"23:00"},"wed":{"kind":"open","open":"08:00","close":"23:00"},"thu":{"kind":"open","open":"08:00","close":"23:00"},"fri":{"kind":"open","open":"08:00","close":"23:00"},"sat":{"kind":"open","open":"08:00","close":"23:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12690311039,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12690311039
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$éllatte coffee$dn$))
    and abs(s.latitude - 14.5652746) < 0.00045
    and abs(s.longitude - 120.9943778) < 0.00045
);
-- node/13023110090
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Tealive$nm$,
  $ad$C. V. Starr Avenue, Las Piñas$ad$,
  14.4507081,
  120.9787946,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13023110090,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13023110090
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Tealive$dn$))
    and abs(s.latitude - 14.4507081) < 0.00045
    and abs(s.longitude - 120.9787946) < 0.00045
);
-- node/13282377194
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Lobby Cafe$nm$,
  $ad$Amorsolo Street, Makati$ad$,
  14.5598318,
  121.0151124,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"21:00"},"sun":{"kind":"open","open":"08:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63 917 875 1871$ph$,
  'pending',
  'openstreetmap',
  'node',
  13282377194,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13282377194
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Lobby Cafe$dn$))
    and abs(s.latitude - 14.5598318) < 0.00045
    and abs(s.longitude - 121.0151124) < 0.00045
);
-- node/13385968567
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Ice Cream Shop ni Dors$nm$,
  $ad$ML. Quezon corner General Luna Street, 2, Taguig$ad$,
  14.5025288,
  121.0527021,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"17:00"},"tue":{"kind":"open","open":"09:00","close":"17:00"},"wed":{"kind":"open","open":"09:00","close":"17:00"},"thu":{"kind":"open","open":"09:00","close":"17:00"},"fri":{"kind":"open","open":"09:00","close":"17:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13385968567,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13385968567
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Ice Cream Shop ni Dors$dn$))
    and abs(s.latitude - 14.5025288) < 0.00045
    and abs(s.longitude - 121.0527021) < 0.00045
);
-- node/13461706510
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Single Origin$nm$,
  $ad$Legazpi Street$ad$,
  14.5531619,
  121.0223198,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13461706510,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13461706510
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Single Origin$dn$))
    and abs(s.latitude - 14.5531619) < 0.00045
    and abs(s.longitude - 121.0223198) < 0.00045
);
-- node/13469837233
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Lazy Cat$nm$,
  $ad$3425 General V. Lim Street, Makati$ad$,
  14.5437789,
  121.0116143,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"11:00","close":"21:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"open","open":"11:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13469837233,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13469837233
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Lazy Cat$dn$))
    and abs(s.latitude - 14.5437789) < 0.00045
    and abs(s.longitude - 121.0116143) < 0.00045
);
-- node/13575302301
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Auro Chocolate Café$nm$,
  $ad$27th Street$ad$,
  14.548995,
  121.0500372,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"01:00"},"fri":{"kind":"open","open":"07:00","close":"01:00"},"sat":{"kind":"open","open":"07:00","close":"01:00"},"sun":{"kind":"open","open":"07:00","close":"01:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13575302301,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13575302301
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Auro Chocolate Café$dn$))
    and abs(s.latitude - 14.548995) < 0.00045
    and abs(s.longitude - 121.0500372) < 0.00045
);
-- node/13666251287
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$BoardBrew$nm$,
  $ad$2353 Taft Avenue, Manila$ad$,
  14.565842,
  120.9932047,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"02:00"},"tue":{"kind":"open","open":"09:00","close":"02:00"},"wed":{"kind":"open","open":"09:00","close":"02:00"},"thu":{"kind":"open","open":"09:00","close":"02:00"},"fri":{"kind":"open","open":"09:00","close":"02:00"},"sat":{"kind":"open","open":"09:00","close":"02:00"},"sun":{"kind":"open","open":"09:00","close":"02:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13666251287,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13666251287
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$BoardBrew$dn$))
    and abs(s.latitude - 14.565842) < 0.00045
    and abs(s.longitude - 120.9932047) < 0.00045
);
-- node/13666254015
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Asterisko$nm$,
  $ad$2339 Taft Avenue$ad$,
  14.5661241,
  120.9929937,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13666254015,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13666254015
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Asterisko$dn$))
    and abs(s.latitude - 14.5661241) < 0.00045
    and abs(s.longitude - 120.9929937) < 0.00045
);
-- node/13666254846
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cha Tien Tang$nm$,
  $ad$2339 Taft Avenue$ad$,
  14.5660199,
  120.9931085,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:00"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"11:00","close":"21:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13666254846,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13666254846
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cha Tien Tang$dn$))
    and abs(s.latitude - 14.5660199) < 0.00045
    and abs(s.longitude - 120.9931085) < 0.00045
);
-- node/13681259558
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Dunkin’$nm$,
  $ad$Evacom Plaza, Samuel St, Parañaque, 1700 Metro Manila Angelina Canaynay Avenue$ad$,
  14.4747285,
  121.0004116,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13681259558,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13681259558
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Dunkin’$dn$))
    and abs(s.latitude - 14.4747285) < 0.00045
    and abs(s.longitude - 121.0004116) < 0.00045
);
-- node/13722481514
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Pancho Cafe$nm$,
  $ad$102 Benavidez Street, Makati$ad$,
  14.5517733,
  121.0184415,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13722481514,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13722481514
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Pancho Cafe$dn$))
    and abs(s.latitude - 14.5517733) < 0.00045
    and abs(s.longitude - 121.0184415) < 0.00045
);
-- node/13738956561
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Narrafé$nm$,
  $ad$2156 Narra Street$ad$,
  14.5022485,
  121.0386537,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13738956561,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13738956561
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Narrafé$dn$))
    and abs(s.latitude - 14.5022485) < 0.00045
    and abs(s.longitude - 121.0386537) < 0.00045
);
-- way/165297828
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Seattle's Best Coffee$nm$,
  $ad$Alabang-Zapote Road, Las Piñas$ad$,
  14.4473733,
  120.9859936,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  165297828,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 165297828
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Seattle's Best Coffee$dn$))
    and abs(s.latitude - 14.4473733) < 0.00045
    and abs(s.longitude - 120.9859936) < 0.00045
);
-- way/315599050
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Estratto Manila Coffee Shop$nm$,
  $ad$811 G. de Borja Street, Pateros$ad$,
  14.5420588,
  121.063057,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:00","close":"21:00"},"tue":{"kind":"open","open":"12:00","close":"21:00"},"wed":{"kind":"open","open":"12:00","close":"21:00"},"thu":{"kind":"open","open":"12:00","close":"21:00"},"fri":{"kind":"open","open":"12:00","close":"21:00"},"sat":{"kind":"open","open":"12:00","close":"21:00"},"sun":{"kind":"open","open":"12:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  315599050,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 315599050
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Estratto Manila Coffee Shop$dn$))
    and abs(s.latitude - 14.5420588) < 0.00045
    and abs(s.longitude - 121.063057) < 0.00045
);
-- way/613886957
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$9th Avenue, Bonifacio Global City, Taguig$ad$,
  14.5567565,
  121.0541309,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  613886957,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 613886957
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5567565) < 0.00045
    and abs(s.longitude - 121.0541309) < 0.00045
);
-- way/979775042
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Baba's Cups and Bites$nm$,
  $ad$Victoria Avenue, Muntinlupa$ad$,
  14.3534374,
  121.0090686,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"18:00"},"tue":{"kind":"open","open":"06:00","close":"18:00"},"wed":{"kind":"open","open":"06:00","close":"18:00"},"thu":{"kind":"open","open":"06:00","close":"18:00"},"fri":{"kind":"open","open":"06:00","close":"18:00"},"sat":{"kind":"open","open":"06:00","close":"18:00"},"sun":{"kind":"open","open":"06:00","close":"18:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  979775042,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 979775042
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Baba's Cups and Bites$dn$))
    and abs(s.latitude - 14.3534374) < 0.00045
    and abs(s.longitude - 121.0090686) < 0.00045
);
-- way/1086829026
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cafe 1911$nm$,
  $ad$1911 Captain M. Reyes Street, Makati$ad$,
  14.5420104,
  121.010968,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  1086829026,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 1086829026
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cafe 1911$dn$))
    and abs(s.latitude - 14.5420104) < 0.00045
    and abs(s.longitude - 121.010968) < 0.00045
);
-- node/6581321331
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Gong Thai$nm$,
  $ad$69 M. H. del Pilar Road, Valenzuela$ad$,
  14.7158662,
  120.9533301,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 905 513 2572$ph$,
  'pending',
  'openstreetmap',
  'node',
  6581321331,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6581321331
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Gong Thai$dn$))
    and abs(s.latitude - 14.7158662) < 0.00045
    and abs(s.longitude - 120.9533301) < 0.00045
);
-- node/12193962243
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Big Brew Malabon$nm$,
  $ad$Rizal Avenue Extension, Malabon$ad$,
  14.658738,
  120.9524701,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12193962243,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12193962243
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Big Brew Malabon$dn$))
    and abs(s.latitude - 14.658738) < 0.00045
    and abs(s.longitude - 120.9524701) < 0.00045
);
-- node/457315783
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Timog Avenue, Quezon City$ad$,
  14.6351832,
  121.0356066,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:30","close":"23:00"},"tue":{"kind":"open","open":"06:30","close":"23:00"},"wed":{"kind":"open","open":"06:30","close":"23:00"},"thu":{"kind":"open","open":"06:30","close":"23:00"},"fri":{"kind":"open","open":"06:30","close":"02:00"},"sat":{"kind":"open","open":"07:00","close":"02:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  457315783,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 457315783
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.6351832) < 0.00045
    and abs(s.longitude - 121.0356066) < 0.00045
);
-- node/746921285
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Meralco Avenue, Pasig$ad$,
  14.587683,
  121.0641887,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  746921285,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 746921285
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.587683) < 0.00045
    and abs(s.longitude - 121.0641887) < 0.00045
);
-- node/748626037
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$23 ADB Avenue, Pasig$ad$,
  14.5861656,
  121.0599638,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"21:00"},"tue":{"kind":"open","open":"06:00","close":"21:00"},"wed":{"kind":"open","open":"06:00","close":"21:00"},"thu":{"kind":"open","open":"06:00","close":"21:00"},"fri":{"kind":"open","open":"06:00","close":"21:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  748626037,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 748626037
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5861656) < 0.00045
    and abs(s.longitude - 121.0599638) < 0.00045
);
-- node/795816573
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Coffee Bean & Tea Leaf$nm$,
  $ad$Orchard Road, Quezon City$ad$,
  14.6096674,
  121.0797462,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:30","close":"20:00"},"tue":{"kind":"open","open":"08:30","close":"20:00"},"wed":{"kind":"open","open":"08:30","close":"20:00"},"thu":{"kind":"open","open":"08:30","close":"20:00"},"fri":{"kind":"open","open":"08:30","close":"20:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  795816573,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 795816573
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Coffee Bean & Tea Leaf$dn$))
    and abs(s.latitude - 14.6096674) < 0.00045
    and abs(s.longitude - 121.0797462) < 0.00045
);
-- node/1074549761
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$KopiRoti$nm$,
  $ad$Katipunan Avenue, Quezon City$ad$,
  14.6205474,
  121.0730451,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"01:00"},"tue":{"kind":"open","open":"07:00","close":"01:00"},"wed":{"kind":"open","open":"07:00","close":"01:00"},"thu":{"kind":"open","open":"07:00","close":"01:00"},"fri":{"kind":"open","open":"07:00","close":"01:00"},"sat":{"kind":"open","open":"07:00","close":"01:00"},"sun":{"kind":"open","open":"07:00","close":"01:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  1074549761,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1074549761
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$KopiRoti$dn$))
    and abs(s.latitude - 14.6205474) < 0.00045
    and abs(s.longitude - 121.0730451) < 0.00045
);
-- node/1413649980
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$17 San Miguel Avenue, Pasig$ad$,
  14.5795139,
  121.0586435,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  1413649980,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1413649980
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5795139) < 0.00045
    and abs(s.longitude - 121.0586435) < 0.00045
);
-- node/1618316700
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Pioneer Street, Pasig$ad$,
  14.5739989,
  121.0575405,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"open","open":"07:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  1618316700,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1618316700
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5739989) < 0.00045
    and abs(s.longitude - 121.0575405) < 0.00045
);
-- node/1682598400
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Tokyo Bubble Tea$nm$,
  $ad$229 Wilson Street$ad$,
  14.597538,
  121.0412306,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"21:00"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"21:00"},"sat":{"kind":"open","open":"10:00","close":"21:00"},"sun":{"kind":"open","open":"10:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63 2 8584 1998$ph$,
  'pending',
  'openstreetmap',
  'node',
  1682598400,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1682598400
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Tokyo Bubble Tea$dn$))
    and abs(s.latitude - 14.597538) < 0.00045
    and abs(s.longitude - 121.0412306) < 0.00045
);
-- node/1707923384
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$UCC Coffee Vienna Cafe$nm$,
  $ad$Temple Drive, Quezon City$ad$,
  14.5998934,
  121.0691495,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  1707923384,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1707923384
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$UCC Coffee Vienna Cafe$dn$))
    and abs(s.latitude - 14.5998934) < 0.00045
    and abs(s.longitude - 121.0691495) < 0.00045
);
-- node/1707927638
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Missouri Street, San Juan$ad$,
  14.6018768,
  121.0529427,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:30","close":"00:00"},"tue":{"kind":"open","open":"06:30","close":"00:00"},"wed":{"kind":"open","open":"06:30","close":"00:00"},"thu":{"kind":"open","open":"06:30","close":"00:00"},"fri":{"kind":"open","open":"06:30","close":"00:00"},"sat":{"kind":"open","open":"06:30","close":"00:00"},"sun":{"kind":"open","open":"06:30","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  1707927638,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 1707927638
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.6018768) < 0.00045
    and abs(s.longitude - 121.0529427) < 0.00045
);
-- node/2025925072
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Tealive$nm$,
  $ad$United Street, Mandaluyong$ad$,
  14.5789536,
  121.0525872,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  2025925072,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 2025925072
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Tealive$dn$))
    and abs(s.latitude - 14.5789536) < 0.00045
    and abs(s.longitude - 121.0525872) < 0.00045
);
-- node/2794011157
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cool Beans Café$nm$,
  $ad$67-A Maginhawa Street$ad$,
  14.647719,
  121.0573901,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"23:00"},"tue":{"kind":"open","open":"11:00","close":"23:00"},"wed":{"kind":"open","open":"11:00","close":"23:00"},"thu":{"kind":"open","open":"11:00","close":"23:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  $ph$+639177064711$ph$,
  'pending',
  'openstreetmap',
  'node',
  2794011157,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 2794011157
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cool Beans Café$dn$))
    and abs(s.latitude - 14.647719) < 0.00045
    and abs(s.longitude - 121.0573901) < 0.00045
);
-- node/3084081180
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Figaro$nm$,
  $ad$847 Banawe Street$ad$,
  14.6375291,
  121.0009309,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  3084081180,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 3084081180
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Figaro$dn$))
    and abs(s.latitude - 14.6375291) < 0.00045
    and abs(s.longitude - 121.0009309) < 0.00045
);
-- node/3239090332
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Chemistea Milk Tea + Cafe$nm$,
  $ad$44 Short Horn Street, Quezon City$ad$,
  14.6669941,
  121.0212523,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 2 455 2541$ph$,
  'pending',
  'openstreetmap',
  'node',
  3239090332,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 3239090332
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Chemistea Milk Tea + Cafe$dn$))
    and abs(s.latitude - 14.6669941) < 0.00045
    and abs(s.longitude - 121.0212523) < 0.00045
);
-- node/3506924047
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Jipan Café and Bakeshop$nm$,
  $ad$Pilar Street$ad$,
  14.5907951,
  121.0411927,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"18:00"},"tue":{"kind":"open","open":"06:00","close":"18:00"},"wed":{"kind":"open","open":"06:00","close":"18:00"},"thu":{"kind":"open","open":"06:00","close":"18:00"},"fri":{"kind":"open","open":"06:00","close":"18:00"},"sat":{"kind":"open","open":"06:00","close":"18:00"},"sun":{"kind":"open","open":"06:00","close":"18:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  3506924047,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 3506924047
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Jipan Café and Bakeshop$dn$))
    and abs(s.latitude - 14.5907951) < 0.00045
    and abs(s.longitude - 121.0411927) < 0.00045
);
-- node/3610397239
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Pegi Waffles$nm$,
  $ad$P. Guevarra Street$ad$,
  14.5978949,
  121.0377445,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"19:00"},"tue":{"kind":"open","open":"10:00","close":"19:00"},"wed":{"kind":"open","open":"10:00","close":"19:00"},"thu":{"kind":"open","open":"10:00","close":"19:00"},"fri":{"kind":"open","open":"10:00","close":"19:00"},"sat":{"kind":"open","open":"10:00","close":"19:00"},"sun":{"kind":"open","open":"10:00","close":"19:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  3610397239,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 3610397239
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Pegi Waffles$dn$))
    and abs(s.latitude - 14.5978949) < 0.00045
    and abs(s.longitude - 121.0377445) < 0.00045
);
-- node/3661058051
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Vanilla Bakery and Cafe$nm$,
  $ad$Ascencion Avenue, Quezon City$ad$,
  14.7239211,
  121.0672092,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  3661058051,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 3661058051
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Vanilla Bakery and Cafe$dn$))
    and abs(s.latitude - 14.7239211) < 0.00045
    and abs(s.longitude - 121.0672092) < 0.00045
);
-- node/3868535670
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Toby's Estate$nm$,
  $ad$Ruby Road, Pasig$ad$,
  14.5879381,
  121.0608845,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"17:00"},"tue":{"kind":"open","open":"07:00","close":"17:00"},"wed":{"kind":"open","open":"07:00","close":"17:00"},"thu":{"kind":"open","open":"07:00","close":"17:00"},"fri":{"kind":"open","open":"07:00","close":"17:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  3868535670,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 3868535670
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Toby's Estate$dn$))
    and abs(s.latitude - 14.5879381) < 0.00045
    and abs(s.longitude - 121.0608845) < 0.00045
);
-- node/4158776089
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Amo Yamie Crib$nm$,
  $ad$Third Floor, DB Building 1250, Padre Noval Street Corner España Boulevard, Sampaloc, Manila$ad$,
  14.6064279,
  120.9898192,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63 9178335017$ph$,
  'pending',
  'openstreetmap',
  'node',
  4158776089,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4158776089
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Amo Yamie Crib$dn$))
    and abs(s.latitude - 14.6064279) < 0.00045
    and abs(s.longitude - 120.9898192) < 0.00045
);
-- node/4212325392
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cristopiy$nm$,
  $ad$1100 R. S. Cristobal Street$ad$,
  14.6145351,
  120.9934886,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:00","close":"23:00"},"tue":{"kind":"open","open":"12:00","close":"23:00"},"wed":{"kind":"open","open":"12:00","close":"23:00"},"thu":{"kind":"open","open":"12:00","close":"23:00"},"fri":{"kind":"open","open":"12:00","close":"23:00"},"sat":{"kind":"open","open":"12:00","close":"23:00"},"sun":{"kind":"open","open":"12:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4212325392,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4212325392
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cristopiy$dn$))
    and abs(s.latitude - 14.6145351) < 0.00045
    and abs(s.longitude - 120.9934886) < 0.00045
);
-- node/4260451394
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Net Galore$nm$,
  $ad$133 Sampaloc Street$ad$,
  14.6933604,
  121.0577438,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:30","close":"22:00"},"tue":{"kind":"open","open":"08:30","close":"22:00"},"wed":{"kind":"open","open":"08:30","close":"22:00"},"thu":{"kind":"open","open":"08:30","close":"22:00"},"fri":{"kind":"open","open":"08:30","close":"22:00"},"sat":{"kind":"open","open":"08:30","close":"22:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+63 922 370 8616$ph$,
  'pending',
  'openstreetmap',
  'node',
  4260451394,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4260451394
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Net Galore$dn$))
    and abs(s.latitude - 14.6933604) < 0.00045
    and abs(s.longitude - 121.0577438) < 0.00045
);
-- node/4314383089
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Infinitea$nm$,
  $ad$F. P. Felix Avenue$ad$,
  14.6050387,
  121.104716,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"23:00"},"tue":{"kind":"open","open":"10:00","close":"23:00"},"wed":{"kind":"open","open":"10:00","close":"23:00"},"thu":{"kind":"open","open":"10:00","close":"23:00"},"fri":{"kind":"open","open":"10:00","close":"23:00"},"sat":{"kind":"open","open":"10:00","close":"23:00"},"sun":{"kind":"open","open":"10:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4314383089,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4314383089
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Infinitea$dn$))
    and abs(s.latitude - 14.6050387) < 0.00045
    and abs(s.longitude - 121.104716) < 0.00045
);
-- node/4352511505
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Smynoshery$nm$,
  $ad$863 Galicia Street$ad$,
  14.6066775,
  120.990337,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:30","close":"22:00"},"tue":{"kind":"open","open":"10:30","close":"22:00"},"wed":{"kind":"open","open":"10:30","close":"22:00"},"thu":{"kind":"open","open":"10:30","close":"22:00"},"fri":{"kind":"open","open":"10:30","close":"22:00"},"sat":{"kind":"open","open":"10:30","close":"22:00"},"sun":{"kind":"open","open":"10:30","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4352511505,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4352511505
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Smynoshery$dn$))
    and abs(s.latitude - 14.6066775) < 0.00045
    and abs(s.longitude - 120.990337) < 0.00045
);
-- node/4420026882
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Chatime$nm$,
  $ad$Marcos Highway, Calumpang, Marikina$ad$,
  14.6259237,
  121.0840797,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"21:00"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"21:00"},"sat":{"kind":"open","open":"10:00","close":"21:00"},"sun":{"kind":"open","open":"10:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4420026882,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4420026882
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Chatime$dn$))
    and abs(s.latitude - 14.6259237) < 0.00045
    and abs(s.longitude - 121.0840797) < 0.00045
);
-- node/4551155224
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Coffee Bean & Tea Leaf$nm$,
  $ad$EDSA, Mandaluyong$ad$,
  14.5812895,
  121.0552592,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"11:00"},"tue":{"kind":"open","open":"07:00","close":"11:00"},"wed":{"kind":"open","open":"07:00","close":"11:00"},"thu":{"kind":"open","open":"07:00","close":"11:00"},"fri":{"kind":"open","open":"07:00","close":"11:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4551155224,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4551155224
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Coffee Bean & Tea Leaf$dn$))
    and abs(s.latitude - 14.5812895) < 0.00045
    and abs(s.longitude - 121.0552592) < 0.00045
);
-- node/5558725558
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Den$nm$,
  $ad$413 Escolta Street, Binondo, Manila$ad$,
  14.5987907,
  120.9792011,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"11:00","close":"21:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"open","open":"11:00","close":"19:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  5558725558,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5558725558
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Den$dn$))
    and abs(s.latitude - 14.5987907) < 0.00045
    and abs(s.longitude - 120.9792011) < 0.00045
);
-- node/5625878631
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Meralco Avenue, Pasig$ad$,
  14.580386,
  121.0640604,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:30","close":"22:30"},"tue":{"kind":"open","open":"06:30","close":"22:30"},"wed":{"kind":"open","open":"06:30","close":"22:30"},"thu":{"kind":"open","open":"06:30","close":"22:30"},"fri":{"kind":"open","open":"06:30","close":"22:30"},"sat":{"kind":"open","open":"08:00","close":"22:30"},"sun":{"kind":"open","open":"08:00","close":"22:30"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  5625878631,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5625878631
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.580386) < 0.00045
    and abs(s.longitude - 121.0640604) < 0.00045
);
-- node/5625878661
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Costa Coffee$nm$,
  $ad$2447 ADB Avenue, Quezon City$ad$,
  14.590274,
  121.06049,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"23:00"},"tue":{"kind":"open","open":"08:00","close":"23:00"},"wed":{"kind":"open","open":"08:00","close":"23:00"},"thu":{"kind":"open","open":"08:00","close":"23:00"},"fri":{"kind":"open","open":"08:00","close":"23:00"},"sat":{"kind":"open","open":"08:00","close":"23:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  $ph$+63 2 631 8604$ph$,
  'pending',
  'openstreetmap',
  'node',
  5625878661,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5625878661
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Costa Coffee$dn$))
    and abs(s.latitude - 14.590274) < 0.00045
    and abs(s.longitude - 121.06049) < 0.00045
);
-- node/5784147226
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$TNC$nm$,
  $ad$41 Aurora Boulevard, Quezon City$ad$,
  14.6086728,
  121.0213555,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  5784147226,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5784147226
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$TNC$dn$))
    and abs(s.latitude - 14.6086728) < 0.00045
    and abs(s.longitude - 121.0213555) < 0.00045
);
-- node/5805323853
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Coffee Project$nm$,
  $ad$Sergeant Esguerra Avenue, Quezon City$ad$,
  14.6340159,
  121.0415444,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"open","open":"07:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  5805323853,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5805323853
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Coffee Project$dn$))
    and abs(s.latitude - 14.6340159) < 0.00045
    and abs(s.longitude - 121.0415444) < 0.00045
);
-- node/5869715985
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cafe Oley$nm$,
  $ad$Malakas Street$ad$,
  14.6384116,
  121.0484412,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"20:00"},"sun":{"kind":"open","open":"11:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  5869715985,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5869715985
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cafe Oley$dn$))
    and abs(s.latitude - 14.6384116) < 0.00045
    and abs(s.longitude - 121.0484412) < 0.00045
);
-- node/6130332285
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Northern Coffee Experience$nm$,
  $ad$General Araneta Avenue$ad$,
  14.618846,
  121.052422,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"18:00"},"tue":{"kind":"open","open":"09:00","close":"18:00"},"wed":{"kind":"open","open":"09:00","close":"18:00"},"thu":{"kind":"open","open":"09:00","close":"18:00"},"fri":{"kind":"open","open":"09:00","close":"18:00"},"sat":{"kind":"open","open":"09:00","close":"18:00"},"sun":{"kind":"open","open":"09:00","close":"18:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  6130332285,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6130332285
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Northern Coffee Experience$dn$))
    and abs(s.latitude - 14.618846) < 0.00045
    and abs(s.longitude - 121.052422) < 0.00045
);
-- node/6148928387
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cool-In Coffee Shop$nm$,
  $ad$287 San Vicente Street$ad$,
  14.5980411,
  120.9776668,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:30","close":"18:00"},"tue":{"kind":"open","open":"07:30","close":"18:00"},"wed":{"kind":"open","open":"07:30","close":"18:00"},"thu":{"kind":"open","open":"07:30","close":"18:00"},"fri":{"kind":"open","open":"07:30","close":"18:00"},"sat":{"kind":"open","open":"07:30","close":"18:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  6148928387,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6148928387
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cool-In Coffee Shop$dn$))
    and abs(s.latitude - 14.5980411) < 0.00045
    and abs(s.longitude - 120.9776668) < 0.00045
);
-- node/6212730482
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Muralla Street, Intramuros, Manila$ad$,
  14.5929756,
  120.977702,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"21:00"},"tue":{"kind":"open","open":"06:00","close":"21:00"},"wed":{"kind":"open","open":"06:00","close":"21:00"},"thu":{"kind":"open","open":"06:00","close":"21:00"},"fri":{"kind":"open","open":"06:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"20:00"},"sun":{"kind":"open","open":"07:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  6212730482,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6212730482
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5929756) < 0.00045
    and abs(s.longitude - 120.977702) < 0.00045
);
-- node/6215504585
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Coffee Spot$nm$,
  $ad$144 Ilocos Norte Street$ad$,
  14.6608838,
  121.0249723,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  6215504585,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6215504585
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Coffee Spot$dn$))
    and abs(s.latitude - 14.6608838) < 0.00045
    and abs(s.longitude - 121.0249723) < 0.00045
);
-- node/6267552208
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Giving Café$nm$,
  $ad$Sheridan Street$ad$,
  14.573233,
  121.0519403,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  6267552208,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6267552208
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Giving Café$dn$))
    and abs(s.latitude - 14.573233) < 0.00045
    and abs(s.longitude - 121.0519403) < 0.00045
);
-- node/6539218605
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Kuya Orlee Computer Shop$nm$,
  $ad$536 Calbayog Street, Mandaluyong$ad$,
  14.5772993,
  121.0479239,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"20:00"},"tue":{"kind":"open","open":"08:00","close":"20:00"},"wed":{"kind":"open","open":"08:00","close":"20:00"},"thu":{"kind":"open","open":"08:00","close":"20:00"},"fri":{"kind":"open","open":"08:00","close":"20:00"},"sat":{"kind":"open","open":"08:00","close":"20:00"},"sun":{"kind":"open","open":"08:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  6539218605,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6539218605
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Kuya Orlee Computer Shop$dn$))
    and abs(s.latitude - 14.5772993) < 0.00045
    and abs(s.longitude - 121.0479239) < 0.00045
);
-- node/6560111002
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Balai Pandesal$nm$,
  $ad$Escriva Drive$ad$,
  14.5789877,
  121.0607089,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  6560111002,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6560111002
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Balai Pandesal$dn$))
    and abs(s.latitude - 14.5789877) < 0.00045
    and abs(s.longitude - 121.0607089) < 0.00045
);
-- node/6585457387
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Café France$nm$,
  $ad$United Nations Avenue$ad$,
  14.5835668,
  120.9872371,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"open","open":"07:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  6585457387,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6585457387
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Café France$dn$))
    and abs(s.latitude - 14.5835668) < 0.00045
    and abs(s.longitude - 120.9872371) < 0.00045
);
-- node/6639869086
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Quezon City$ad$,
  14.6563689,
  121.033064,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  6639869086,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 6639869086
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.6563689) < 0.00045
    and abs(s.longitude - 121.033064) < 0.00045
);
-- node/7057748985
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Red Monster Cafe$nm$,
  $ad$107 Maginhawa Street$ad$,
  14.646248,
  121.0605021,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:00"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"closed"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"open","open":"11:00","close":"21:00"}}$hr$::jsonb,
  $ph$+639178580987$ph$,
  'pending',
  'openstreetmap',
  'node',
  7057748985,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 7057748985
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Red Monster Cafe$dn$))
    and abs(s.latitude - 14.646248) < 0.00045
    and abs(s.longitude - 121.0605021) < 0.00045
);
-- node/7466528447
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$I Love Milktea$nm$,
  $ad$Victoneta Avenue$ad$,
  14.6704254,
  120.9992825,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"18:00"},"tue":{"kind":"open","open":"09:00","close":"18:00"},"wed":{"kind":"open","open":"09:00","close":"18:00"},"thu":{"kind":"open","open":"09:00","close":"18:00"},"fri":{"kind":"open","open":"09:00","close":"18:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  7466528447,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 7466528447
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$I Love Milktea$dn$))
    and abs(s.latitude - 14.6704254) < 0.00045
    and abs(s.longitude - 120.9992825) < 0.00045
);
-- node/7502513070
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$9th Street, Caloocan$ad$,
  14.6493153,
  120.990772,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"23:00"},"tue":{"kind":"open","open":"07:00","close":"23:00"},"wed":{"kind":"open","open":"07:00","close":"23:00"},"thu":{"kind":"open","open":"07:00","close":"23:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:30","close":"23:00"},"sun":{"kind":"open","open":"07:30","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  7502513070,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 7502513070
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.6493153) < 0.00045
    and abs(s.longitude - 120.990772) < 0.00045
);
-- node/7574592374
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Eng Ho Cafe & Deli$nm$,
  $ad$629 T. Alonzo Street$ad$,
  14.6023647,
  120.9787674,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"19:00"},"tue":{"kind":"open","open":"08:00","close":"19:00"},"wed":{"kind":"open","open":"08:00","close":"19:00"},"thu":{"kind":"open","open":"08:00","close":"19:00"},"fri":{"kind":"open","open":"08:00","close":"19:00"},"sat":{"kind":"open","open":"08:00","close":"19:00"},"sun":{"kind":"open","open":"08:00","close":"19:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  7574592374,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 7574592374
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Eng Ho Cafe & Deli$dn$))
    and abs(s.latitude - 14.6023647) < 0.00045
    and abs(s.longitude - 120.9787674) < 0.00045
);
-- node/7878520308
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$2445 Pedro Gil Street, Santa Ana, Manila$ad$,
  14.5818947,
  121.0126915,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"23:00"},"tue":{"kind":"open","open":"06:00","close":"23:00"},"wed":{"kind":"open","open":"06:00","close":"23:00"},"thu":{"kind":"open","open":"06:00","close":"23:00"},"fri":{"kind":"open","open":"06:00","close":"23:00"},"sat":{"kind":"open","open":"06:00","close":"23:00"},"sun":{"kind":"open","open":"06:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  7878520308,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 7878520308
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5818947) < 0.00045
    and abs(s.longitude - 121.0126915) < 0.00045
);
-- node/8354027252
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Dough Days$nm$,
  $ad$344 Tullahan Road, Santa Quiteria/Talipapa$ad$,
  14.6835228,
  121.0059665,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"14:00","close":"17:00"},"tue":{"kind":"open","open":"14:00","close":"17:00"},"wed":{"kind":"open","open":"14:00","close":"17:00"},"thu":{"kind":"open","open":"14:00","close":"17:00"},"fri":{"kind":"open","open":"14:00","close":"17:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  8354027252,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 8354027252
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Dough Days$dn$))
    and abs(s.latitude - 14.6835228) < 0.00045
    and abs(s.longitude - 121.0059665) < 0.00045
);
-- node/8366928603
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$MA+D Manila$nm$,
  $ad$118 Matahimik Street, Quezon City$ad$,
  14.6453584,
  121.0539248,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"02:00"},"tue":{"kind":"open","open":"10:00","close":"02:00"},"wed":{"kind":"open","open":"10:00","close":"02:00"},"thu":{"kind":"open","open":"10:00","close":"02:00"},"fri":{"kind":"open","open":"10:00","close":"02:00"},"sat":{"kind":"open","open":"10:00","close":"02:00"},"sun":{"kind":"open","open":"10:00","close":"02:00"}}$hr$::jsonb,
  $ph$+639179942479$ph$,
  'pending',
  'openstreetmap',
  'node',
  8366928603,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 8366928603
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$MA+D Manila$dn$))
    and abs(s.latitude - 14.6453584) < 0.00045
    and abs(s.longitude - 121.0539248) < 0.00045
);
-- node/8370321692
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Basta Cafe$nm$,
  $ad$50 T. Gener Street, Quezon City$ad$,
  14.6273176,
  121.0364347,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"23:00"},"sat":{"kind":"open","open":"10:00","close":"23:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  8370321692,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 8370321692
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Basta Cafe$dn$))
    and abs(s.latitude - 14.6273176) < 0.00045
    and abs(s.longitude - 121.0364347) < 0.00045
);
-- node/8620447455
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$TSA-GA Pinoy Milk Tea$nm$,
  $ad$2979 Jenny's Avenue, Pasig$ad$,
  14.5899998,
  121.091152,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"18:00"},"tue":{"kind":"open","open":"10:00","close":"18:00"},"wed":{"kind":"open","open":"10:00","close":"18:00"},"thu":{"kind":"open","open":"10:00","close":"18:00"},"fri":{"kind":"open","open":"10:00","close":"18:00"},"sat":{"kind":"open","open":"10:00","close":"18:00"},"sun":{"kind":"open","open":"10:00","close":"18:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  8620447455,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 8620447455
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$TSA-GA Pinoy Milk Tea$dn$))
    and abs(s.latitude - 14.5899998) < 0.00045
    and abs(s.longitude - 121.091152) < 0.00045
);
-- node/8633822972
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Sicilian Roast$nm$,
  $ad$Katipunan Avenue$ad$,
  14.6209861,
  121.0733703,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  8633822972,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 8633822972
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Sicilian Roast$dn$))
    and abs(s.latitude - 14.6209861) < 0.00045
    and abs(s.longitude - 121.0733703) < 0.00045
);
-- node/8633822978
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Katipunan Avenue$ad$,
  14.6208331,
  121.0732864,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"22:00"},"tue":{"kind":"open","open":"06:00","close":"22:00"},"wed":{"kind":"open","open":"06:00","close":"22:00"},"thu":{"kind":"open","open":"06:00","close":"22:00"},"fri":{"kind":"open","open":"06:00","close":"22:00"},"sat":{"kind":"open","open":"06:00","close":"22:00"},"sun":{"kind":"open","open":"06:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  8633822978,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 8633822978
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.6208331) < 0.00045
    and abs(s.longitude - 121.0732864) < 0.00045
);
-- node/8911345746
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Café Mabini$nm$,
  $ad$A. Mabini Street$ad$,
  14.5929125,
  121.0412249,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"21:00"},"sun":{"kind":"open","open":"08:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  8911345746,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 8911345746
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Café Mabini$dn$))
    and abs(s.latitude - 14.5929125) < 0.00045
    and abs(s.longitude - 121.0412249) < 0.00045
);
-- node/9177831338
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Ahon Cafe$nm$,
  $ad$Calamba Street$ad$,
  14.6267177,
  120.9960053,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"closed"},"wed":{"kind":"open","open":"14:00","close":"20:30"},"thu":{"kind":"open","open":"14:00","close":"20:30"},"fri":{"kind":"open","open":"14:00","close":"20:30"},"sat":{"kind":"open","open":"14:00","close":"20:30"},"sun":{"kind":"open","open":"14:00","close":"20:30"}}$hr$::jsonb,
  $ph$+639175026115$ph$,
  'pending',
  'openstreetmap',
  'node',
  9177831338,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9177831338
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Ahon Cafe$dn$))
    and abs(s.latitude - 14.6267177) < 0.00045
    and abs(s.longitude - 120.9960053) < 0.00045
);
-- node/9358935574
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$SGD Coffee Bodega$nm$,
  $ad$45 Maalalahanin Street$ad$,
  14.643576,
  121.0593539,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"20:00"},"tue":{"kind":"open","open":"08:00","close":"20:00"},"wed":{"kind":"open","open":"08:00","close":"20:00"},"thu":{"kind":"open","open":"08:00","close":"20:00"},"fri":{"kind":"open","open":"08:00","close":"20:00"},"sat":{"kind":"open","open":"08:00","close":"20:00"},"sun":{"kind":"open","open":"08:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  9358935574,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9358935574
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$SGD Coffee Bodega$dn$))
    and abs(s.latitude - 14.643576) < 0.00045
    and abs(s.longitude - 121.0593539) < 0.00045
);
-- node/9504066217
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Kape Siklo$nm$,
  $ad$2387 Beata Street$ad$,
  14.5909497,
  121.0057308,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"23:00"},"tue":{"kind":"open","open":"11:00","close":"23:00"},"wed":{"kind":"open","open":"11:00","close":"23:00"},"thu":{"kind":"open","open":"11:00","close":"23:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  9504066217,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9504066217
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Kape Siklo$dn$))
    and abs(s.latitude - 14.5909497) < 0.00045
    and abs(s.longitude - 121.0057308) < 0.00045
);
-- node/9785549707
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Belfry Café$nm$,
  $ad$Cabildo Street$ad$,
  14.5919097,
  120.973632,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"09:00","close":"22:00"},"sun":{"kind":"open","open":"09:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 926 628 7133$ph$,
  'pending',
  'openstreetmap',
  'node',
  9785549707,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9785549707
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Belfry Café$dn$))
    and abs(s.latitude - 14.5919097) < 0.00045
    and abs(s.longitude - 120.973632) < 0.00045
);
-- node/9830199030
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Kape Etc.$nm$,
  $ad$Blk 32 L 4 Jasmine Street, Caloocan$ad$,
  14.7533598,
  121.0630387,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  9830199030,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9830199030
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Kape Etc.$dn$))
    and abs(s.latitude - 14.7533598) < 0.00045
    and abs(s.longitude - 121.0630387) < 0.00045
);
-- node/9985714832
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Nihon Café$nm$,
  $ad$Shaw Boulevard, Mandaluyong$ad$,
  14.5908889,
  121.0326863,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  9985714832,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9985714832
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Nihon Café$dn$))
    and abs(s.latitude - 14.5908889) < 0.00045
    and abs(s.longitude - 121.0326863) < 0.00045
);
-- node/10000733974
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Bizu Le Petit Café at MiraNila$nm$,
  $ad$26 Mariposa Street, Quezon City$ad$,
  14.6117448,
  121.049858,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10000733974,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10000733974
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Bizu Le Petit Café at MiraNila$dn$))
    and abs(s.latitude - 14.6117448) < 0.00045
    and abs(s.longitude - 121.049858) < 0.00045
);
-- node/10025843798
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Caffera Photo + Café$nm$,
  $ad$480 Boni Avenue$ad$,
  14.5817314,
  121.0289294,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:00","close":"00:00"},"tue":{"kind":"open","open":"12:00","close":"00:00"},"wed":{"kind":"open","open":"12:00","close":"00:00"},"thu":{"kind":"open","open":"12:00","close":"00:00"},"fri":{"kind":"open","open":"12:00","close":"00:00"},"sat":{"kind":"open","open":"12:00","close":"00:00"},"sun":{"kind":"open","open":"12:00","close":"00:00"}}$hr$::jsonb,
  $ph$+639088172013$ph$,
  'pending',
  'openstreetmap',
  'node',
  10025843798,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10025843798
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Caffera Photo + Café$dn$))
    and abs(s.latitude - 14.5817314) < 0.00045
    and abs(s.longitude - 121.0289294) < 0.00045
);
-- node/10056160307
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cafe Aroma$nm$,
  $ad$Pasig Boulevard, Pasig$ad$,
  14.5692634,
  121.0673931,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"open","open":"07:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10056160307,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10056160307
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cafe Aroma$dn$))
    and abs(s.latitude - 14.5692634) < 0.00045
    and abs(s.longitude - 121.0673931) < 0.00045
);
-- node/10070750512
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Coffee Bean & Tea Leaf$nm$,
  $ad$Doña Julia Vargas Avenue$ad$,
  14.584147,
  121.057652,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10070750512,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10070750512
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Coffee Bean & Tea Leaf$dn$))
    and abs(s.latitude - 14.584147) < 0.00045
    and abs(s.longitude - 121.057652) < 0.00045
);
-- node/10091501055
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Hilera Café$nm$,
  $ad$250 V. P. Ibañez Street$ad$,
  14.5998602,
  121.0406195,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"11:00","close":"00:00"},"wed":{"kind":"open","open":"11:00","close":"00:00"},"thu":{"kind":"open","open":"11:00","close":"00:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  $ph$+63 919 893 3445$ph$,
  'pending',
  'openstreetmap',
  'node',
  10091501055,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10091501055
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Hilera Café$dn$))
    and abs(s.latitude - 14.5998602) < 0.00045
    and abs(s.longitude - 121.0406195) < 0.00045
);
-- node/10099988517
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Gram Coffee$nm$,
  $ad$Primo Cruz Street$ad$,
  14.5803872,
  121.0286867,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10099988517,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10099988517
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Gram Coffee$dn$))
    and abs(s.latitude - 14.5803872) < 0.00045
    and abs(s.longitude - 121.0286867) < 0.00045
);
-- node/10168315476
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Kohi$nm$,
  $ad$200 Maginhawa Street, Quezon City$ad$,
  14.6366039,
  121.0613476,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"20:00"},"sun":{"kind":"open","open":"08:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10168315476,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10168315476
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Kohi$dn$))
    and abs(s.latitude - 14.6366039) < 0.00045
    and abs(s.longitude - 121.0613476) < 0.00045
);
-- node/10174259263
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$50 West Capitol Drive, Pasig$ad$,
  14.5729845,
  121.0596794,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"23:00"},"tue":{"kind":"open","open":"06:00","close":"23:00"},"wed":{"kind":"open","open":"06:00","close":"23:00"},"thu":{"kind":"open","open":"06:00","close":"23:00"},"fri":{"kind":"open","open":"06:00","close":"23:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10174259263,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10174259263
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5729845) < 0.00045
    and abs(s.longitude - 121.0596794) < 0.00045
);
-- node/10177459817
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Colobaba Cafe$nm$,
  $ad$Taft Avenue$ad$,
  14.5668294,
  120.9934561,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10177459817,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10177459817
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Colobaba Cafe$dn$))
    and abs(s.latitude - 14.5668294) < 0.00045
    and abs(s.longitude - 120.9934561) < 0.00045
);
-- node/10203040311
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Dot Coffee$nm$,
  $ad$Missouri Street, San Juan$ad$,
  14.6022594,
  121.0517049,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"23:00"},"tue":{"kind":"open","open":"07:00","close":"23:00"},"wed":{"kind":"open","open":"07:00","close":"23:00"},"thu":{"kind":"open","open":"07:00","close":"23:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10203040311,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10203040311
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Dot Coffee$dn$))
    and abs(s.latitude - 14.6022594) < 0.00045
    and abs(s.longitude - 121.0517049) < 0.00045
);
-- node/10279199461
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Duke's Castle Cafe$nm$,
  $ad$Padre Campa Street$ad$,
  14.608111,
  120.9861626,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"00:00"},"tue":{"kind":"open","open":"10:00","close":"00:00"},"wed":{"kind":"open","open":"10:00","close":"00:00"},"thu":{"kind":"open","open":"10:00","close":"00:00"},"fri":{"kind":"open","open":"10:00","close":"00:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+639976831545$ph$,
  'pending',
  'openstreetmap',
  'node',
  10279199461,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10279199461
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Duke's Castle Cafe$dn$))
    and abs(s.latitude - 14.608111) < 0.00045
    and abs(s.longitude - 120.9861626) < 0.00045
);
-- node/10564872609
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Fernando Poe Jr. Avenue$ad$,
  14.6491853,
  121.0174984,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:30"},"thu":{"kind":"open","open":"07:00","close":"00:30"},"fri":{"kind":"open","open":"07:00","close":"02:00"},"sat":{"kind":"open","open":"07:00","close":"02:00"},"sun":{"kind":"open","open":"07:00","close":"02:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10564872609,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10564872609
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.6491853) < 0.00045
    and abs(s.longitude - 121.0174984) < 0.00045
);
-- node/10750196407
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$BonApaTea Café$nm$,
  $ad$East Zamora Street$ad$,
  14.5883521,
  121.0020311,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"15:00","close":"23:00"},"tue":{"kind":"open","open":"15:00","close":"23:00"},"wed":{"kind":"open","open":"15:00","close":"23:00"},"thu":{"kind":"open","open":"15:00","close":"23:00"},"fri":{"kind":"open","open":"15:00","close":"23:00"},"sat":{"kind":"open","open":"15:00","close":"23:00"},"sun":{"kind":"open","open":"15:00","close":"23:00"}}$hr$::jsonb,
  $ph$09060588900$ph$,
  'pending',
  'openstreetmap',
  'node',
  10750196407,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10750196407
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$BonApaTea Café$dn$))
    and abs(s.latitude - 14.5883521) < 0.00045
    and abs(s.longitude - 121.0020311) < 0.00045
);
-- node/10915219174
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Relax & Brew$nm$,
  $ad$Katipunan Street$ad$,
  14.646247,
  121.1131869,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"00:00"},"tue":{"kind":"open","open":"09:00","close":"00:00"},"wed":{"kind":"open","open":"09:00","close":"00:00"},"thu":{"kind":"open","open":"09:00","close":"00:00"},"fri":{"kind":"open","open":"09:00","close":"00:00"},"sat":{"kind":"open","open":"09:00","close":"00:00"},"sun":{"kind":"open","open":"09:00","close":"00:00"}}$hr$::jsonb,
  $ph$+63 920 976 5644$ph$,
  'pending',
  'openstreetmap',
  'node',
  10915219174,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10915219174
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Relax & Brew$dn$))
    and abs(s.latitude - 14.646247) < 0.00045
    and abs(s.longitude - 121.1131869) < 0.00045
);
-- node/11043442654
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Bask$nm$,
  $ad$A. Mabini Street$ad$,
  14.5946088,
  121.0406001,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"21:00"},"sun":{"kind":"open","open":"08:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11043442654,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11043442654
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Bask$dn$))
    and abs(s.latitude - 14.5946088) < 0.00045
    and abs(s.longitude - 121.0406001) < 0.00045
);
-- node/11195167938
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Arts and Beans$nm$,
  $ad$51 West Capitol Drive$ad$,
  14.5719239,
  121.058888,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"20:00"},"tue":{"kind":"open","open":"07:00","close":"20:00"},"wed":{"kind":"open","open":"07:00","close":"20:00"},"thu":{"kind":"open","open":"07:00","close":"20:00"},"fri":{"kind":"open","open":"07:00","close":"20:00"},"sat":{"kind":"open","open":"07:00","close":"20:00"},"sun":{"kind":"open","open":"07:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11195167938,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11195167938
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Arts and Beans$dn$))
    and abs(s.latitude - 14.5719239) < 0.00045
    and abs(s.longitude - 121.058888) < 0.00045
);
-- node/11288583766
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Do Güd Cafe$nm$,
  $ad$9 E. Rodriguez Street$ad$,
  14.6596907,
  121.1108247,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"closed"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11288583766,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11288583766
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Do Güd Cafe$dn$))
    and abs(s.latitude - 14.6596907) < 0.00045
    and abs(s.longitude - 121.1108247) < 0.00045
);
-- node/11365165249
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Family Bean Garden Cafe$nm$,
  $ad$Union Drive$ad$,
  14.7622037,
  121.0279288,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11365165249,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11365165249
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Family Bean Garden Cafe$dn$))
    and abs(s.latitude - 14.7622037) < 0.00045
    and abs(s.longitude - 121.0279288) < 0.00045
);
-- node/11370725572
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Buttery & Co$nm$,
  $ad$104 Katipunan Avenue$ad$,
  14.6091945,
  121.0708176,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11370725572,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11370725572
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Buttery & Co$dn$))
    and abs(s.latitude - 14.6091945) < 0.00045
    and abs(s.longitude - 121.0708176) < 0.00045
);
-- node/11493728669
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Betty’s Sans Rival$nm$,
  $ad$M. Cuenco Sr. Street$ad$,
  14.6269346,
  121.0082506,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"19:00"},"tue":{"kind":"open","open":"10:00","close":"19:00"},"wed":{"kind":"open","open":"10:00","close":"19:00"},"thu":{"kind":"open","open":"10:00","close":"19:00"},"fri":{"kind":"open","open":"10:00","close":"19:00"},"sat":{"kind":"open","open":"10:00","close":"19:00"},"sun":{"kind":"open","open":"10:00","close":"19:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11493728669,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11493728669
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Betty’s Sans Rival$dn$))
    and abs(s.latitude - 14.6269346) < 0.00045
    and abs(s.longitude - 121.0082506) < 0.00045
);
-- node/11504852369
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Sound$nm$,
  $ad$East Capitol Drive$ad$,
  14.5677272,
  121.0585882,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"20:00"},"tue":{"kind":"open","open":"08:00","close":"20:00"},"wed":{"kind":"open","open":"08:00","close":"20:00"},"thu":{"kind":"open","open":"08:00","close":"20:00"},"fri":{"kind":"open","open":"08:00","close":"20:00"},"sat":{"kind":"open","open":"08:00","close":"20:00"},"sun":{"kind":"open","open":"08:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11504852369,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11504852369
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Sound$dn$))
    and abs(s.latitude - 14.5677272) < 0.00045
    and abs(s.longitude - 121.0585882) < 0.00045
);
-- node/11555491056
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$What About Coffee?$nm$,
  $ad$Gomburza Street$ad$,
  14.6611469,
  121.0728529,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"21:00"},"tue":{"kind":"open","open":"06:00","close":"21:00"},"wed":{"kind":"open","open":"06:00","close":"21:00"},"thu":{"kind":"open","open":"06:00","close":"21:00"},"fri":{"kind":"open","open":"06:00","close":"21:00"},"sat":{"kind":"open","open":"06:00","close":"21:00"},"sun":{"kind":"open","open":"06:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11555491056,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11555491056
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$What About Coffee?$dn$))
    and abs(s.latitude - 14.6611469) < 0.00045
    and abs(s.longitude - 121.0728529) < 0.00045
);
-- node/11696478092
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Sibs Coffee Roasters$nm$,
  $ad$306-A Barangka Drive$ad$,
  14.5700514,
  121.0365385,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11696478092,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11696478092
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Sibs Coffee Roasters$dn$))
    and abs(s.latitude - 14.5700514) < 0.00045
    and abs(s.longitude - 121.0365385) < 0.00045
);
-- node/11750288450
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$a. m. espresso$nm$,
  $ad$P. Guevarra Street$ad$,
  14.5963233,
  121.038595,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11750288450,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11750288450
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$a. m. espresso$dn$))
    and abs(s.latitude - 14.5963233) < 0.00045
    and abs(s.longitude - 121.038595) < 0.00045
);
-- node/11754618555
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Magdamag Market Café$nm$,
  $ad$14 Sergeant Esguerra Avenue, Quezon City$ad$,
  14.6351756,
  121.0406778,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"19:00"},"tue":{"kind":"open","open":"09:00","close":"19:00"},"wed":{"kind":"open","open":"09:00","close":"19:00"},"thu":{"kind":"open","open":"09:00","close":"19:00"},"fri":{"kind":"open","open":"09:00","close":"19:00"},"sat":{"kind":"open","open":"08:00","close":"19:00"},"sun":{"kind":"open","open":"08:00","close":"19:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11754618555,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11754618555
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Magdamag Market Café$dn$))
    and abs(s.latitude - 14.6351756) < 0.00045
    and abs(s.longitude - 121.0406778) < 0.00045
);
-- node/11778206072
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Homie's Cafe$nm$,
  $ad$77 Corregidor Street, Brgy. Ramon Magsaysay, Quezon City$ad$,
  14.6582125,
  121.0243156,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"17:00"},"tue":{"kind":"open","open":"10:00","close":"17:00"},"wed":{"kind":"open","open":"10:00","close":"17:00"},"thu":{"kind":"open","open":"10:00","close":"17:00"},"fri":{"kind":"open","open":"10:00","close":"17:00"},"sat":{"kind":"open","open":"10:00","close":"17:00"},"sun":{"kind":"open","open":"10:00","close":"17:00"}}$hr$::jsonb,
  $ph$+63756322902$ph$,
  'pending',
  'openstreetmap',
  'node',
  11778206072,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11778206072
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Homie's Cafe$dn$))
    and abs(s.latitude - 14.6582125) < 0.00045
    and abs(s.longitude - 121.0243156) < 0.00045
);
-- node/11919903254
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Silingan Coffee Shop$nm$,
  $ad$General Romulo Avenue$ad$,
  14.6223936,
  121.0565522,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:00"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"23:00"},"fri":{"kind":"open","open":"09:00","close":"23:00"},"sat":{"kind":"open","open":"09:00","close":"23:00"},"sun":{"kind":"open","open":"09:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11919903254,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11919903254
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Silingan Coffee Shop$dn$))
    and abs(s.latitude - 14.6223936) < 0.00045
    and abs(s.longitude - 121.0565522) < 0.00045
);
-- node/12014742795
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$RM Coffee & Tea$nm$,
  $ad$16 K-3rd Street, Quezon City$ad$,
  14.6282618,
  121.0413906,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"13:00","close":"21:00"},"tue":{"kind":"open","open":"13:00","close":"21:00"},"wed":{"kind":"open","open":"13:00","close":"21:00"},"thu":{"kind":"open","open":"13:00","close":"21:00"},"fri":{"kind":"open","open":"13:00","close":"21:00"},"sat":{"kind":"open","open":"13:00","close":"21:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12014742795,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12014742795
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$RM Coffee & Tea$dn$))
    and abs(s.latitude - 14.6282618) < 0.00045
    and abs(s.longitude - 121.0413906) < 0.00045
);
-- node/12039888563
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Sixteen Centigrado$nm$,
  $ad$421-A Constabulary Road, Quezon City$ad$,
  14.6826591,
  121.073459,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+639295549128$ph$,
  'pending',
  'openstreetmap',
  'node',
  12039888563,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12039888563
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Sixteen Centigrado$dn$))
    and abs(s.latitude - 14.6826591) < 0.00045
    and abs(s.longitude - 121.073459) < 0.00045
);
-- node/12047820209
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Zero Degree Espresso Bar$nm$,
  $ad$437 Calabash B Street, Sampaloc$ad$,
  14.6100843,
  121.0036909,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"14:00","close":"22:00"},"wed":{"kind":"open","open":"14:00","close":"22:00"},"thu":{"kind":"open","open":"14:00","close":"22:00"},"fri":{"kind":"open","open":"14:00","close":"22:00"},"sat":{"kind":"open","open":"14:00","close":"22:00"},"sun":{"kind":"open","open":"14:00","close":"22:00"}}$hr$::jsonb,
  $ph$+639266014693$ph$,
  'pending',
  'openstreetmap',
  'node',
  12047820209,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12047820209
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Zero Degree Espresso Bar$dn$))
    and abs(s.latitude - 14.6100843) < 0.00045
    and abs(s.longitude - 121.0036909) < 0.00045
);
-- node/12070158798
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cafe Oasis - Mercedes Ave$nm$,
  $ad$1407 Mercedes Avenue, Brgy. San Miguel, Pasig$ad$,
  14.5693021,
  121.084176,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"13:00","close":"22:30"},"tue":{"kind":"closed"},"wed":{"kind":"closed"},"thu":{"kind":"closed"},"fri":{"kind":"closed"},"sat":{"kind":"closed"},"sun":{"kind":"open","open":"13:00","close":"22:30"}}$hr$::jsonb,
  $ph$+639763197146$ph$,
  'pending',
  'openstreetmap',
  'node',
  12070158798,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12070158798
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cafe Oasis - Mercedes Ave$dn$))
    and abs(s.latitude - 14.5693021) < 0.00045
    and abs(s.longitude - 121.084176) < 0.00045
);
-- node/12075961103
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$lakbaypinas$nm$,
  $ad$30 Luzon Street, Malanday, Marikina$ad$,
  14.6493552,
  121.0950739,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12075961103,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12075961103
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$lakbaypinas$dn$))
    and abs(s.latitude - 14.6493552) < 0.00045
    and abs(s.longitude - 121.0950739) < 0.00045
);
-- node/12128146761
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Sumu Cafe & Creative Space$nm$,
  $ad$8010 España Boulevard, Sampaloc, Manila$ad$,
  14.6063928,
  120.98885,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"03:00"},"tue":{"kind":"open","open":"09:00","close":"03:00"},"wed":{"kind":"open","open":"09:00","close":"03:00"},"thu":{"kind":"open","open":"09:00","close":"03:00"},"fri":{"kind":"open","open":"09:00","close":"03:00"},"sat":{"kind":"open","open":"09:00","close":"03:00"},"sun":{"kind":"open","open":"09:00","close":"03:00"}}$hr$::jsonb,
  $ph$+639629732061$ph$,
  'pending',
  'openstreetmap',
  'node',
  12128146761,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12128146761
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Sumu Cafe & Creative Space$dn$))
    and abs(s.latitude - 14.6063928) < 0.00045
    and abs(s.longitude - 120.98885) < 0.00045
);
-- node/12174512308
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cole & Co. Studio Café$nm$,
  $ad$V. Cruz Street$ad$,
  14.598455,
  121.0378093,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"21:00"},"sun":{"kind":"open","open":"08:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12174512308,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12174512308
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cole & Co. Studio Café$dn$))
    and abs(s.latitude - 14.598455) < 0.00045
    and abs(s.longitude - 121.0378093) < 0.00045
);
-- node/12196286701
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Life Bowls$nm$,
  $ad$Mayflower Street$ad$,
  14.5770997,
  121.0526448,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"21:00"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"21:00"},"sat":{"kind":"open","open":"10:00","close":"21:00"},"sun":{"kind":"open","open":"10:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12196286701,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12196286701
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Life Bowls$dn$))
    and abs(s.latitude - 14.5770997) < 0.00045
    and abs(s.longitude - 121.0526448) < 0.00045
);
-- node/12414857139
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Tomoro Coffee$nm$,
  $ad$Nicanor Reyes Street$ad$,
  14.6043319,
  120.9878372,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"23:00"},"tue":{"kind":"open","open":"07:00","close":"23:00"},"wed":{"kind":"open","open":"07:00","close":"23:00"},"thu":{"kind":"open","open":"07:00","close":"23:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12414857139,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12414857139
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Tomoro Coffee$dn$))
    and abs(s.latitude - 14.6043319) < 0.00045
    and abs(s.longitude - 120.9878372) < 0.00045
);
-- node/12450628576
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Quezon City$ad$,
  14.6559154,
  121.0308324,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:30","close":"22:30"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:30"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12450628576,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12450628576
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.6559154) < 0.00045
    and abs(s.longitude - 121.0308324) < 0.00045
);
-- node/12642014301
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Good Mornings$nm$,
  $ad$Amang Rodriguez Avenue$ad$,
  14.6147053,
  121.0921545,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"22:00"},"tue":{"kind":"open","open":"06:00","close":"22:00"},"wed":{"kind":"open","open":"06:00","close":"22:00"},"thu":{"kind":"open","open":"06:00","close":"22:00"},"fri":{"kind":"open","open":"06:00","close":"22:00"},"sat":{"kind":"open","open":"06:00","close":"22:00"},"sun":{"kind":"open","open":"06:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12642014301,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12642014301
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Good Mornings$dn$))
    and abs(s.latitude - 14.6147053) < 0.00045
    and abs(s.longitude - 121.0921545) < 0.00045
);
-- node/12647066223
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Zus Coffee$nm$,
  $ad$Pedro Gil Steet cor. Paz Street, Barangay 681, Zone 74, District V, Paco$ad$,
  14.5786951,
  120.9957798,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"21:00"},"tue":{"kind":"open","open":"06:00","close":"21:00"},"wed":{"kind":"open","open":"06:00","close":"21:00"},"thu":{"kind":"open","open":"06:00","close":"21:00"},"fri":{"kind":"open","open":"06:00","close":"21:00"},"sat":{"kind":"open","open":"06:00","close":"21:00"},"sun":{"kind":"open","open":"06:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12647066223,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12647066223
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Zus Coffee$dn$))
    and abs(s.latitude - 14.5786951) < 0.00045
    and abs(s.longitude - 120.9957798) < 0.00045
);
-- node/12682572601
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Atmos Coffee Co$nm$,
  $ad$Tandang Sora Avenue$ad$,
  14.6800052,
  121.0202424,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12682572601,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12682572601
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Atmos Coffee Co$dn$))
    and abs(s.latitude - 14.6800052) < 0.00045
    and abs(s.longitude - 121.0202424) < 0.00045
);
-- node/12693333501
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Grounds Manila Beanery$nm$,
  $ad$Tandang Sora Avenue$ad$,
  14.6765828,
  121.0376876,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"14:00","close":"20:00"},"tue":{"kind":"open","open":"14:00","close":"20:00"},"wed":{"kind":"open","open":"14:00","close":"20:00"},"thu":{"kind":"open","open":"14:00","close":"20:00"},"fri":{"kind":"open","open":"14:00","close":"20:00"},"sat":{"kind":"open","open":"14:00","close":"20:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12693333501,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12693333501
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Grounds Manila Beanery$dn$))
    and abs(s.latitude - 14.6765828) < 0.00045
    and abs(s.longitude - 121.0376876) < 0.00045
);
-- node/12716380465
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cotti Coffee$nm$,
  $ad$Opal Road, Pasig$ad$,
  14.5871412,
  121.0601896,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12716380465,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12716380465
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cotti Coffee$dn$))
    and abs(s.latitude - 14.5871412) < 0.00045
    and abs(s.longitude - 121.0601896) < 0.00045
);
-- node/12759190601
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Dunkin'$nm$,
  $ad$Camarin Road$ad$,
  14.7475077,
  121.0363121,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12759190601,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12759190601
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Dunkin'$dn$))
    and abs(s.latitude - 14.7475077) < 0.00045
    and abs(s.longitude - 121.0363121) < 0.00045
);
-- node/12765860686
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$KOI Thé$nm$,
  $ad$1800 Eastwood Avenue, Quezon City$ad$,
  14.6102405,
  121.0793829,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 926 066 7731$ph$,
  'pending',
  'openstreetmap',
  'node',
  12765860686,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12765860686
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$KOI Thé$dn$))
    and abs(s.latitude - 14.6102405) < 0.00045
    and abs(s.longitude - 121.0793829) < 0.00045
);
-- node/12798119981
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Big Brew$nm$,
  $ad$Karuhatan Road, Valenzuela$ad$,
  14.6894162,
  120.9767307,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12798119981,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12798119981
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Big Brew$dn$))
    and abs(s.latitude - 14.6894162) < 0.00045
    and abs(s.longitude - 120.9767307) < 0.00045
);
-- node/12801684103
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cake Muncher Manila$nm$,
  $ad$44 Champaca Street, Quezon City$ad$,
  14.6907042,
  121.0325788,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:30","close":"22:00"},"tue":{"kind":"open","open":"12:30","close":"22:00"},"wed":{"kind":"open","open":"12:30","close":"22:00"},"thu":{"kind":"open","open":"12:30","close":"22:00"},"fri":{"kind":"open","open":"12:30","close":"22:00"},"sat":{"kind":"open","open":"12:30","close":"22:00"},"sun":{"kind":"open","open":"12:30","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12801684103,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12801684103
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cake Muncher Manila$dn$))
    and abs(s.latitude - 14.6907042) < 0.00045
    and abs(s.longitude - 121.0325788) < 0.00045
);
-- node/12803663501
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Grotto Hookah Lounge$nm$,
  $ad$398 Cabildo Street$ad$,
  14.5916991,
  120.974185,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"01:00"},"tue":{"kind":"open","open":"11:00","close":"01:00"},"wed":{"kind":"open","open":"11:00","close":"01:00"},"thu":{"kind":"open","open":"11:00","close":"01:00"},"fri":{"kind":"open","open":"11:00","close":"01:00"},"sat":{"kind":"open","open":"11:00","close":"01:00"},"sun":{"kind":"open","open":"11:00","close":"01:00"}}$hr$::jsonb,
  $ph$+639271702485$ph$,
  'pending',
  'openstreetmap',
  'node',
  12803663501,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12803663501
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Grotto Hookah Lounge$dn$))
    and abs(s.latitude - 14.5916991) < 0.00045
    and abs(s.longitude - 120.974185) < 0.00045
);
-- node/12815884501
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Espresso Studio$nm$,
  $ad$Williams Street$ad$,
  14.5762909,
  121.053406,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"22:00"},"tue":{"kind":"open","open":"06:00","close":"22:00"},"wed":{"kind":"open","open":"06:00","close":"22:00"},"thu":{"kind":"open","open":"06:00","close":"22:00"},"fri":{"kind":"open","open":"06:00","close":"22:00"},"sat":{"kind":"open","open":"06:00","close":"22:00"},"sun":{"kind":"open","open":"06:00","close":"22:00"}}$hr$::jsonb,
  $ph$+639165245624$ph$,
  'pending',
  'openstreetmap',
  'node',
  12815884501,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12815884501
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Espresso Studio$dn$))
    and abs(s.latitude - 14.5762909) < 0.00045
    and abs(s.longitude - 121.053406) < 0.00045
);
-- node/12830692363
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Quirino Highway, Quezon City$ad$,
  14.7342983,
  121.053661,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"00:00"},"tue":{"kind":"open","open":"06:00","close":"00:00"},"wed":{"kind":"open","open":"06:00","close":"00:00"},"thu":{"kind":"open","open":"06:00","close":"00:00"},"fri":{"kind":"open","open":"06:00","close":"00:00"},"sat":{"kind":"open","open":"06:00","close":"00:00"},"sun":{"kind":"open","open":"06:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12830692363,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12830692363
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.7342983) < 0.00045
    and abs(s.longitude - 121.053661) < 0.00045
);
-- node/12842140517
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Deja Brew by Brisbane Street Cafe$nm$,
  $ad$Barangay 180, Caloocan$ad$,
  14.7679139,
  121.080185,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:00"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"11:00","close":"21:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+63 969 239 8887$ph$,
  'pending',
  'openstreetmap',
  'node',
  12842140517,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12842140517
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Deja Brew by Brisbane Street Cafe$dn$))
    and abs(s.latitude - 14.7679139) < 0.00045
    and abs(s.longitude - 121.080185) < 0.00045
);
-- node/12849117101
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$NextGen Cafe$nm$,
  $ad$Mindanao Avenue$ad$,
  14.6834338,
  121.0322402,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12849117101,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12849117101
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$NextGen Cafe$dn$))
    and abs(s.latitude - 14.6834338) < 0.00045
    and abs(s.longitude - 121.0322402) < 0.00045
);
-- node/13013191320
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Beachhouse Sundries$nm$,
  $ad$11 East Capitol Drive$ad$,
  14.5720088,
  121.0607172,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13013191320,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13013191320
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Beachhouse Sundries$dn$))
    and abs(s.latitude - 14.5720088) < 0.00045
    and abs(s.longitude - 121.0607172) < 0.00045
);
-- node/13019012134
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$eskinita knl$nm$,
  $ad$B. Baluyot Street$ad$,
  14.6468794,
  121.0620704,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13019012134,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13019012134
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$eskinita knl$dn$))
    and abs(s.latitude - 14.6468794) < 0.00045
    and abs(s.longitude - 121.0620704) < 0.00045
);
-- node/13115927669
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Roundabout Bistro$nm$,
  $ad$Maysilo Circle$ad$,
  14.5783528,
  121.0342795,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"00:00"},"tue":{"kind":"open","open":"11:00","close":"00:00"},"wed":{"kind":"open","open":"11:00","close":"00:00"},"thu":{"kind":"open","open":"11:00","close":"00:00"},"fri":{"kind":"open","open":"11:00","close":"00:00"},"sat":{"kind":"open","open":"11:00","close":"00:00"},"sun":{"kind":"open","open":"11:00","close":"00:00"}}$hr$::jsonb,
  $ph$+63 939 912 3418$ph$,
  'pending',
  'openstreetmap',
  'node',
  13115927669,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13115927669
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Roundabout Bistro$dn$))
    and abs(s.latitude - 14.5783528) < 0.00045
    and abs(s.longitude - 121.0342795) < 0.00045
);
-- node/13142727623
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Kohi - Maginhawa$nm$,
  $ad$63 Maginhawa Street, Diliman, Quezon City$ad$,
  14.6480647,
  121.0572784,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13142727623,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13142727623
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Kohi - Maginhawa$dn$))
    and abs(s.latitude - 14.6480647) < 0.00045
    and abs(s.longitude - 121.0572784) < 0.00045
);
-- node/13333289740
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Ailo Coffee$nm$,
  $ad$2 V. P. Ibañez Street$ad$,
  14.5993398,
  121.0372644,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"10:00","close":"20:00"},"wed":{"kind":"open","open":"10:00","close":"20:00"},"thu":{"kind":"open","open":"10:00","close":"20:00"},"fri":{"kind":"open","open":"10:00","close":"20:00"},"sat":{"kind":"open","open":"10:00","close":"20:00"},"sun":{"kind":"open","open":"10:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13333289740,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13333289740
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Ailo Coffee$dn$))
    and abs(s.latitude - 14.5993398) < 0.00045
    and abs(s.longitude - 121.0372644) < 0.00045
);
-- node/13354763514
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$ZUS Coffee$nm$,
  $ad$City Hall Road, Marikina$ad$,
  14.6332371,
  121.0983235,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:40"},"tue":{"kind":"open","open":"07:00","close":"21:40"},"wed":{"kind":"open","open":"07:00","close":"21:40"},"thu":{"kind":"open","open":"07:00","close":"21:40"},"fri":{"kind":"open","open":"07:00","close":"21:40"},"sat":{"kind":"open","open":"07:00","close":"21:40"},"sun":{"kind":"open","open":"07:00","close":"21:40"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13354763514,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13354763514
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$ZUS Coffee$dn$))
    and abs(s.latitude - 14.6332371) < 0.00045
    and abs(s.longitude - 121.0983235) < 0.00045
);
-- node/13431454655
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Miko Seit$nm$,
  $ad$L19 Langit Road, Bagong Silang, Caloocan$ad$,
  14.7706822,
  121.0559673,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13431454655,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13431454655
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Miko Seit$dn$))
    and abs(s.latitude - 14.7706822) < 0.00045
    and abs(s.longitude - 121.0559673) < 0.00045
);
-- node/13502768463
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Coffee Tate$nm$,
  $ad$174 Villongco Street, Quezon City$ad$,
  14.697622,
  121.0838329,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"00:00"},"tue":{"kind":"open","open":"11:00","close":"00:00"},"wed":{"kind":"open","open":"11:00","close":"00:00"},"thu":{"kind":"open","open":"11:00","close":"00:00"},"fri":{"kind":"open","open":"11:00","close":"00:00"},"sat":{"kind":"open","open":"11:00","close":"00:00"},"sun":{"kind":"open","open":"11:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13502768463,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13502768463
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Coffee Tate$dn$))
    and abs(s.latitude - 14.697622) < 0.00045
    and abs(s.longitude - 121.0838329) < 0.00045
);
-- node/13581570765
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Mollie's World Cafè$nm$,
  $ad$Quezon Avenue, Quezon City$ad$,
  14.6424453,
  121.0401261,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"23:00"},"tue":{"kind":"open","open":"11:00","close":"23:00"},"wed":{"kind":"open","open":"11:00","close":"23:00"},"thu":{"kind":"open","open":"11:00","close":"23:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13581570765,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13581570765
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Mollie's World Cafè$dn$))
    and abs(s.latitude - 14.6424453) < 0.00045
    and abs(s.longitude - 121.0401261) < 0.00045
);
-- node/13612402711
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$ZUS Coffee$nm$,
  $ad$Sumulong Highway$ad$,
  14.6354272,
  121.1009484,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:40"},"tue":{"kind":"open","open":"07:00","close":"21:40"},"wed":{"kind":"open","open":"07:00","close":"21:40"},"thu":{"kind":"open","open":"07:00","close":"21:40"},"fri":{"kind":"open","open":"07:00","close":"21:40"},"sat":{"kind":"open","open":"07:00","close":"21:40"},"sun":{"kind":"open","open":"07:00","close":"21:40"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13612402711,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13612402711
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$ZUS Coffee$dn$))
    and abs(s.latitude - 14.6354272) < 0.00045
    and abs(s.longitude - 121.1009484) < 0.00045
);
-- node/13674119669
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Coffee & Vinyl$nm$,
  $ad$182 11th Avenue$ad$,
  14.6529792,
  120.9855229,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"14:00","close":"23:00"},"tue":{"kind":"open","open":"13:00","close":"23:00"},"wed":{"kind":"open","open":"13:00","close":"23:00"},"thu":{"kind":"open","open":"13:00","close":"23:00"},"fri":{"kind":"open","open":"13:00","close":"23:00"},"sat":{"kind":"open","open":"13:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13674119669,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13674119669
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Coffee & Vinyl$dn$))
    and abs(s.latitude - 14.6529792) < 0.00045
    and abs(s.longitude - 120.9855229) < 0.00045
);
-- node/13674455575
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$General Luna Street, Intramuros, Manila$ad$,
  14.5926425,
  120.9720046,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"20:00"},"sun":{"kind":"open","open":"08:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13674455575,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13674455575
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.5926425) < 0.00045
    and abs(s.longitude - 120.9720046) < 0.00045
);
-- node/13934962151
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$A.bode Space$nm$,
  $ad$2 Don E. Ejercito Street, Tibagan$ad$,
  14.5997114,
  121.0301469,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13934962151,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13934962151
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$A.bode Space$dn$))
    and abs(s.latitude - 14.5997114) < 0.00045
    and abs(s.longitude - 121.0301469) < 0.00045
);
-- node/13962054863
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Gringo's - Sampaloc Manila$nm$,
  $ad$J. Fajardo Street, Sampaloc, Manila$ad$,
  14.6112799,
  120.9991461,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"01:00"},"tue":{"kind":"open","open":"10:00","close":"01:00"},"wed":{"kind":"open","open":"10:00","close":"01:00"},"thu":{"kind":"open","open":"10:00","close":"01:00"},"fri":{"kind":"open","open":"10:00","close":"01:00"},"sat":{"kind":"open","open":"10:00","close":"01:00"},"sun":{"kind":"open","open":"10:00","close":"01:00"}}$hr$::jsonb,
  $ph$+639382925247$ph$,
  'pending',
  'openstreetmap',
  'node',
  13962054863,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13962054863
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Gringo's - Sampaloc Manila$dn$))
    and abs(s.latitude - 14.6112799) < 0.00045
    and abs(s.longitude - 120.9991461) < 0.00045
);
-- node/14049177801
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Type A - NBS Park$nm$,
  $ad$Pioneer Street$ad$,
  14.5723194,
  121.0532404,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"08:00","close":"18:00"},"wed":{"kind":"open","open":"08:00","close":"18:00"},"thu":{"kind":"open","open":"08:00","close":"18:00"},"fri":{"kind":"open","open":"08:00","close":"18:00"},"sat":{"kind":"open","open":"08:00","close":"18:00"},"sun":{"kind":"open","open":"08:00","close":"18:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  14049177801,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 14049177801
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Type A - NBS Park$dn$))
    and abs(s.latitude - 14.5723194) < 0.00045
    and abs(s.longitude - 121.0532404) < 0.00045
);
-- node/14050283776
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Zus Coffee$nm$,
  $ad$Quezon City$ad$,
  14.6561021,
  121.0304113,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  14050283776,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 14050283776
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Zus Coffee$dn$))
    and abs(s.latitude - 14.6561021) < 0.00045
    and abs(s.longitude - 121.0304113) < 0.00045
);
-- node/14050313102
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Craft Coffee Roastery$nm$,
  $ad$Quezon City$ad$,
  14.6554788,
  121.0322597,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  14050313102,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 14050313102
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Craft Coffee Roastery$dn$))
    and abs(s.latitude - 14.6554788) < 0.00045
    and abs(s.longitude - 121.0322597) < 0.00045
);
-- node/14050360017
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Soft Habit$nm$,
  $ad$Grass Residences Misamis Street$ad$,
  14.6591618,
  121.0286554,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"23:00"},"tue":{"kind":"open","open":"07:00","close":"23:00"},"wed":{"kind":"open","open":"07:00","close":"23:00"},"thu":{"kind":"open","open":"07:00","close":"23:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  14050360017,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 14050360017
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Soft Habit$dn$))
    and abs(s.latitude - 14.6591618) < 0.00045
    and abs(s.longitude - 121.0286554) < 0.00045
);
-- node/14072727738
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Nita Coffee Bar$nm$,
  $ad$Saint Thomas Street, Quezon City$ad$,
  14.702523,
  121.0469148,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"14:00","close":"00:00"},"tue":{"kind":"closed"},"wed":{"kind":"open","open":"14:00","close":"00:00"},"thu":{"kind":"open","open":"14:00","close":"00:00"},"fri":{"kind":"open","open":"14:00","close":"00:00"},"sat":{"kind":"open","open":"14:00","close":"00:00"},"sun":{"kind":"open","open":"14:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  14072727738,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 14072727738
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Nita Coffee Bar$dn$))
    and abs(s.latitude - 14.702523) < 0.00045
    and abs(s.longitude - 121.0469148) < 0.00045
);
-- node/14191085701
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Odd Cafe$nm$,
  $ad$San Miguel Avenue$ad$,
  14.5809532,
  121.0597168,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"23:00"},"tue":{"kind":"open","open":"08:00","close":"23:00"},"wed":{"kind":"open","open":"08:00","close":"23:00"},"thu":{"kind":"open","open":"08:00","close":"23:00"},"fri":{"kind":"open","open":"08:00","close":"23:00"},"sat":{"kind":"open","open":"08:00","close":"23:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  14191085701,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 14191085701
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Odd Cafe$dn$))
    and abs(s.latitude - 14.5809532) < 0.00045
    and abs(s.longitude - 121.0597168) < 0.00045
);
-- way/119756820
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Ligaya.$nm$,
  $ad$68 Olive Street, Marikina$ad$,
  14.6373356,
  121.1177162,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  119756820,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 119756820
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Ligaya.$dn$))
    and abs(s.latitude - 14.6373356) < 0.00045
    and abs(s.longitude - 121.1177162) < 0.00045
);
-- way/247960719
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Fancy Crepes$nm$,
  $ad$40 Matalino Street, Quezon City$ad$,
  14.6452208,
  121.0528372,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  247960719,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 247960719
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Fancy Crepes$dn$))
    and abs(s.latitude - 14.6452208) < 0.00045
    and abs(s.longitude - 121.0528372) < 0.00045
);
-- way/252253624
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Mindanao Avenue, Quezon City$ad$,
  14.6805775,
  121.0316769,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:30","close":"22:00"},"tue":{"kind":"open","open":"07:30","close":"22:00"},"wed":{"kind":"open","open":"07:30","close":"22:00"},"thu":{"kind":"open","open":"07:30","close":"22:00"},"fri":{"kind":"open","open":"07:30","close":"22:00"},"sat":{"kind":"open","open":"08:30","close":"22:00"},"sun":{"kind":"open","open":"08:30","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  252253624,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 252253624
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.6805775) < 0.00045
    and abs(s.longitude - 121.0316769) < 0.00045
);
-- way/354591605
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$2 West 4th Street, Quezon City$ad$,
  14.6402564,
  121.0302901,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"00:00"},"tue":{"kind":"open","open":"06:00","close":"00:00"},"wed":{"kind":"open","open":"06:00","close":"00:00"},"thu":{"kind":"open","open":"06:00","close":"00:00"},"fri":{"kind":"open","open":"06:00","close":"00:30"},"sat":{"kind":"open","open":"07:00","close":"01:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  $ph$+6384263975$ph$,
  'pending',
  'openstreetmap',
  'way',
  354591605,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 354591605
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.6402564) < 0.00045
    and abs(s.longitude - 121.0302901) < 0.00045
);
-- way/460351313
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Verse Cafe 3:16$nm$,
  $ad$P. Burgos Street$ad$,
  14.5926551,
  121.0385055,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  460351313,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 460351313
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Verse Cafe 3:16$dn$))
    and abs(s.latitude - 14.5926551) < 0.00045
    and abs(s.longitude - 121.0385055) < 0.00045
);
-- way/581457169
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$Santolan Road, San Juan$ad$,
  14.6048506,
  121.0339064,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  581457169,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 581457169
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.6048506) < 0.00045
    and abs(s.longitude - 121.0339064) < 0.00045
);
-- way/794638354
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Kopi Tiam$nm$,
  $ad$3 C. Benitez Street, Quezon City$ad$,
  14.6101035,
  121.0432145,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"21:00"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"21:00"},"sat":{"kind":"open","open":"10:00","close":"21:00"},"sun":{"kind":"open","open":"10:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  794638354,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 794638354
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Kopi Tiam$dn$))
    and abs(s.latitude - 14.6101035) < 0.00045
    and abs(s.longitude - 121.0432145) < 0.00045
);
-- way/797827685
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$TEATEA NI KAYE$nm$,
  $ad$Paquita Street$ad$,
  14.7140202,
  121.0440796,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  797827685,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 797827685
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$TEATEA NI KAYE$dn$))
    and abs(s.latitude - 14.7140202) < 0.00045
    and abs(s.longitude - 121.0440796) < 0.00045
);
-- way/872300358
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$BM Street Cafe$nm$,
  $ad$25 Bronze Street, Concepcion Dos, Marikina$ad$,
  14.6401523,
  121.1154272,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"16:00","close":"22:00"},"wed":{"kind":"open","open":"16:00","close":"22:00"},"thu":{"kind":"open","open":"16:00","close":"22:00"},"fri":{"kind":"open","open":"16:00","close":"22:00"},"sat":{"kind":"open","open":"16:00","close":"22:00"},"sun":{"kind":"open","open":"16:00","close":"22:00"}}$hr$::jsonb,
  $ph$0936 943 7956$ph$,
  'pending',
  'openstreetmap',
  'way',
  872300358,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 872300358
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$BM Street Cafe$dn$))
    and abs(s.latitude - 14.6401523) < 0.00045
    and abs(s.longitude - 121.1154272) < 0.00045
);
-- way/1396548805
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Sable$nm$,
  $ad$66 Broadway Avenue, Quezon City$ad$,
  14.6221186,
  121.026775,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  1396548805,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 1396548805
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Sable$dn$))
    and abs(s.latitude - 14.6221186) < 0.00045
    and abs(s.longitude - 121.026775) < 0.00045
);
-- way/1411743631
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Starbucks$nm$,
  $ad$J. P. Rizal Street, Marikina$ad$,
  14.6672685,
  121.1078506,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"02:00"},"tue":{"kind":"open","open":"06:00","close":"02:00"},"wed":{"kind":"open","open":"06:00","close":"02:00"},"thu":{"kind":"open","open":"06:00","close":"02:00"},"fri":{"kind":"open","open":"06:00","close":"02:00"},"sat":{"kind":"open","open":"06:00","close":"02:00"},"sun":{"kind":"open","open":"06:00","close":"02:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  1411743631,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 1411743631
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Starbucks$dn$))
    and abs(s.latitude - 14.6672685) < 0.00045
    and abs(s.longitude - 121.1078506) < 0.00045
);
-- way/1442775976
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Chapter Coffee Roastery & Cafe$nm$,
  $ad$365 P. Guevarra Street$ad$,
  14.5938583,
  121.0370216,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"21:00"},"sun":{"kind":"open","open":"08:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  1442775976,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 1442775976
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Chapter Coffee Roastery & Cafe$dn$))
    and abs(s.latitude - 14.5938583) < 0.00045
    and abs(s.longitude - 121.0370216) < 0.00045
);
-- node/4450956309
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Halovérs$nm$,
  $ad$Mabini Street, Cebu$ad$,
  10.2980228,
  123.903778,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"23:00"},"tue":{"kind":"open","open":"10:00","close":"23:00"},"wed":{"kind":"open","open":"10:00","close":"23:00"},"thu":{"kind":"open","open":"10:00","close":"23:00"},"fri":{"kind":"open","open":"10:00","close":"23:00"},"sat":{"kind":"open","open":"10:00","close":"23:00"},"sun":{"kind":"open","open":"10:00","close":"23:00"}}$hr$::jsonb,
  $ph$+63 917 707 0707$ph$,
  'pending',
  'openstreetmap',
  'node',
  4450956309,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4450956309
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Halovérs$dn$))
    and abs(s.latitude - 10.2980228) < 0.00045
    and abs(s.longitude - 123.903778) < 0.00045
);
-- node/4504342694
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Alejandra's Place$nm$,
  $ad$Abad Santos Street$ad$,
  10.3265182,
  123.9118332,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4504342694,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4504342694
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Alejandra's Place$dn$))
    and abs(s.latitude - 10.3265182) < 0.00045
    and abs(s.longitude - 123.9118332) < 0.00045
);
-- node/5308311523
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Kapel$nm$,
  $ad$Don Ramon Aboitiz Street$ad$,
  10.3124905,
  123.8955117,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"12:00"},"tue":{"kind":"open","open":"10:00","close":"12:00"},"wed":{"kind":"open","open":"10:00","close":"12:00"},"thu":{"kind":"open","open":"10:00","close":"12:00"},"fri":{"kind":"open","open":"10:00","close":"12:00"},"sat":{"kind":"open","open":"10:00","close":"12:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+63 32 255 6231$ph$,
  'pending',
  'openstreetmap',
  'node',
  5308311523,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5308311523
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Kapel$dn$))
    and abs(s.latitude - 10.3124905) < 0.00045
    and abs(s.longitude - 123.8955117) < 0.00045
);
-- node/5845289986
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Daily Grind Cafe$nm$,
  $ad$President Roxas Street$ad$,
  10.32435,
  123.9120724,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  $ph$+63 916 610 4801$ph$,
  'pending',
  'openstreetmap',
  'node',
  5845289986,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5845289986
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Daily Grind Cafe$dn$))
    and abs(s.latitude - 10.32435) < 0.00045
    and abs(s.longitude - 123.9120724) < 0.00045
);
-- node/7030903376
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Roadside Cafe$nm$,
  $ad$Junquera Street$ad$,
  10.3017992,
  123.8984578,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"09:00","close":"22:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  7030903376,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 7030903376
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Roadside Cafe$dn$))
    and abs(s.latitude - 10.3017992) < 0.00045
    and abs(s.longitude - 123.8984578) < 0.00045
);
-- node/8485796497
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$A Better Sip Milktea$nm$,
  $ad$Gorordo Avenue, Cebu$ad$,
  10.3158981,
  123.899918,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 947 430 6744$ph$,
  'pending',
  'openstreetmap',
  'node',
  8485796497,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 8485796497
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$A Better Sip Milktea$dn$))
    and abs(s.latitude - 10.3158981) < 0.00045
    and abs(s.longitude - 123.899918) < 0.00045
);
-- node/8609518617
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Foodfiesta.ph$nm$,
  $ad$30 F. Llamas Street$ad$,
  10.2948844,
  123.8699339,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"10:30","close":"19:00"},"wed":{"kind":"open","open":"10:30","close":"19:00"},"thu":{"kind":"open","open":"10:30","close":"19:00"},"fri":{"kind":"open","open":"10:30","close":"19:00"},"sat":{"kind":"open","open":"10:30","close":"19:00"},"sun":{"kind":"open","open":"10:30","close":"19:00"}}$hr$::jsonb,
  $ph$09511108030$ph$,
  'pending',
  'openstreetmap',
  'node',
  8609518617,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 8609518617
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Foodfiesta.ph$dn$))
    and abs(s.latitude - 10.2948844) < 0.00045
    and abs(s.longitude - 123.8699339) < 0.00045
);
-- node/8712203832
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Zhagu$nm$,
  $ad$Natalio Bacalso Avenue, Pardo$ad$,
  10.2803623,
  123.8561867,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  $ph$09254490762$ph$,
  'pending',
  'openstreetmap',
  'node',
  8712203832,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 8712203832
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Zhagu$dn$))
    and abs(s.latitude - 10.2803623) < 0.00045
    and abs(s.longitude - 123.8561867) < 0.00045
);
-- node/8849623247
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Shazzy Milktea Cafe$nm$,
  $ad$1711 Cebu Tops Road, Cebu$ad$,
  10.3776793,
  123.8729472,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"21:00"},"sat":{"kind":"open","open":"10:00","close":"21:00"},"sun":{"kind":"open","open":"10:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  8849623247,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 8849623247
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Shazzy Milktea Cafe$dn$))
    and abs(s.latitude - 10.3776793) < 0.00045
    and abs(s.longitude - 123.8729472) < 0.00045
);
-- node/9175542417
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Kuyang cafe$nm$,
  $ad$sitio ga-ang brgy paril$ad$,
  10.4605424,
  123.9152303,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"closed"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  9175542417,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9175542417
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Kuyang cafe$dn$))
    and abs(s.latitude - 10.4605424) < 0.00045
    and abs(s.longitude - 123.9152303) < 0.00045
);
-- node/10177526766
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Cake Me Home Cassava Cakes and Pies$nm$,
  $ad$626 Tres de Abril Street, Cebu$ad$,
  10.2974849,
  123.8831528,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"19:00"},"tue":{"kind":"open","open":"09:00","close":"19:00"},"wed":{"kind":"open","open":"09:00","close":"19:00"},"thu":{"kind":"open","open":"09:00","close":"19:00"},"fri":{"kind":"open","open":"09:00","close":"19:00"},"sat":{"kind":"open","open":"09:00","close":"19:00"},"sun":{"kind":"open","open":"09:00","close":"19:00"}}$hr$::jsonb,
  $ph$09985779442$ph$,
  'pending',
  'openstreetmap',
  'node',
  10177526766,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10177526766
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Cake Me Home Cassava Cakes and Pies$dn$))
    and abs(s.latitude - 10.2974849) < 0.00045
    and abs(s.longitude - 123.8831528) < 0.00045
);
-- node/11901564748
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Ctrl + tea$nm$,
  $ad$President Roxas, Cebu City$ad$,
  10.3238389,
  123.9131252,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11901564748,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11901564748
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Ctrl + tea$dn$))
    and abs(s.latitude - 10.3238389) < 0.00045
    and abs(s.longitude - 123.9131252) < 0.00045
);
-- node/12012843485
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Myths Coffee$nm$,
  $ad$Gorordo Avenue, Cebu City$ad$,
  10.3224381,
  123.8981844,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"17:00"},"tue":{"kind":"open","open":"08:00","close":"17:00"},"wed":{"kind":"open","open":"08:00","close":"17:00"},"thu":{"kind":"open","open":"08:00","close":"17:00"},"fri":{"kind":"open","open":"08:00","close":"17:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12012843485,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12012843485
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Myths Coffee$dn$))
    and abs(s.latitude - 10.3224381) < 0.00045
    and abs(s.longitude - 123.8981844) < 0.00045
);
-- node/12543760118
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Lorenzo's Cafe$nm$,
  $ad$Junquera Extension$ad$,
  10.3024582,
  123.8977566,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"20:00"},"tue":{"kind":"open","open":"10:00","close":"20:00"},"wed":{"kind":"open","open":"10:00","close":"20:00"},"thu":{"kind":"open","open":"10:00","close":"20:00"},"fri":{"kind":"open","open":"10:00","close":"20:00"},"sat":{"kind":"open","open":"10:00","close":"20:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12543760118,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12543760118
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Lorenzo's Cafe$dn$))
    and abs(s.latitude - 10.3024582) < 0.00045
    and abs(s.longitude - 123.8977566) < 0.00045
);
-- node/12546126936
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Quarter Café$nm$,
  $ad$Junquera Street$ad$,
  10.3020273,
  123.898305,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"19:00"},"tue":{"kind":"open","open":"10:00","close":"19:00"},"wed":{"kind":"open","open":"10:00","close":"19:00"},"thu":{"kind":"open","open":"10:00","close":"19:00"},"fri":{"kind":"open","open":"10:00","close":"19:00"},"sat":{"kind":"open","open":"11:00","close":"20:00"},"sun":{"kind":"open","open":"11:00","close":"20:00"}}$hr$::jsonb,
  $ph$+63 32 520 3532$ph$,
  'pending',
  'openstreetmap',
  'node',
  12546126936,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12546126936
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Quarter Café$dn$))
    and abs(s.latitude - 10.3020273) < 0.00045
    and abs(s.longitude - 123.898305) < 0.00045
);
-- node/12547944109
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$8th of September$nm$,
  $ad$Junquera Extension$ad$,
  10.3021373,
  123.8979896,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"20:00"},"tue":{"kind":"open","open":"08:00","close":"20:00"},"wed":{"kind":"open","open":"08:00","close":"20:00"},"thu":{"kind":"open","open":"08:00","close":"20:00"},"fri":{"kind":"open","open":"08:00","close":"20:00"},"sat":{"kind":"open","open":"08:00","close":"20:00"},"sun":{"kind":"open","open":"08:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12547944109,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12547944109
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$8th of September$dn$))
    and abs(s.latitude - 10.3021373) < 0.00045
    and abs(s.longitude - 123.8979896) < 0.00045
);
-- node/13265326001
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Luminous Espresso Industry Ph (IL Corso)$nm$,
  $ad$7V8H+PF3 Cebu South Coastal Road$ad$,
  10.2659707,
  123.8779552,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:30"},"tue":{"kind":"open","open":"08:00","close":"22:30"},"wed":{"kind":"open","open":"08:00","close":"22:30"},"thu":{"kind":"open","open":"08:00","close":"22:30"},"fri":{"kind":"open","open":"08:00","close":"22:30"},"sat":{"kind":"open","open":"07:00","close":"23:30"},"sun":{"kind":"open","open":"07:00","close":"23:30"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13265326001,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13265326001
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Luminous Espresso Industry Ph (IL Corso)$dn$))
    and abs(s.latitude - 10.2659707) < 0.00045
    and abs(s.longitude - 123.8779552) < 0.00045
);
-- node/13362921046
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Coffee First$nm$,
  $ad$Golam Drive$ad$,
  10.3240423,
  123.9099233,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"18:00"},"tue":{"kind":"open","open":"09:00","close":"18:00"},"wed":{"kind":"open","open":"09:00","close":"18:00"},"thu":{"kind":"open","open":"09:00","close":"18:00"},"fri":{"kind":"open","open":"09:00","close":"18:00"},"sat":{"kind":"open","open":"09:00","close":"18:00"},"sun":{"kind":"open","open":"09:00","close":"18:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13362921046,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13362921046
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Coffee First$dn$))
    and abs(s.latitude - 10.3240423) < 0.00045
    and abs(s.longitude - 123.9099233) < 0.00045
);
-- node/13461671201
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Dragonfly Cafe$nm$,
  $ad$Ground floor 8 Ramon Duterte Street$ad$,
  10.3108083,
  123.8762663,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"21:00"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  $ph$0917 706 9072$ph$,
  'pending',
  'openstreetmap',
  'node',
  13461671201,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13461671201
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Dragonfly Cafe$dn$))
    and abs(s.latitude - 10.3108083) < 0.00045
    and abs(s.longitude - 123.8762663) < 0.00045
);
-- node/13465417501
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Illuminati Cafe + Art Gallery$nm$,
  $ad$058 Salvador Extension$ad$,
  10.3015122,
  123.878133,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:00","close":"22:00"},"tue":{"kind":"open","open":"12:00","close":"22:00"},"wed":{"kind":"open","open":"12:00","close":"22:00"},"thu":{"kind":"open","open":"12:00","close":"22:00"},"fri":{"kind":"open","open":"12:00","close":"22:00"},"sat":{"kind":"open","open":"12:00","close":"22:00"},"sun":{"kind":"open","open":"12:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13465417501,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13465417501
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Illuminati Cafe + Art Gallery$dn$))
    and abs(s.latitude - 10.3015122) < 0.00045
    and abs(s.longitude - 123.878133) < 0.00045
);
-- node/13469495902
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Zero-x Cafe$nm$,
  $ad$757 Vicente Rama Avenue$ad$,
  10.3149272,
  123.88561,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:30","close":"22:00"},"tue":{"kind":"open","open":"08:30","close":"22:00"},"wed":{"kind":"open","open":"08:30","close":"22:00"},"thu":{"kind":"open","open":"08:30","close":"22:00"},"fri":{"kind":"open","open":"08:30","close":"22:00"},"sat":{"kind":"open","open":"08:30","close":"22:00"},"sun":{"kind":"open","open":"08:30","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13469495902,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13469495902
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Zero-x Cafe$dn$))
    and abs(s.latitude - 10.3149272) < 0.00045
    and abs(s.longitude - 123.88561) < 0.00045
);
-- node/13478224101
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$100 Percent Cafe$nm$,
  $ad$Salvador Street$ad$,
  10.3126371,
  123.8783667,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13478224101,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13478224101
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$100 Percent Cafe$dn$))
    and abs(s.latitude - 10.3126371) < 0.00045
    and abs(s.longitude - 123.8783667) < 0.00045
);
-- way/677254042
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Taas Cafe$nm$,
  $ad$Cebu City$ad$,
  10.3550944,
  123.9105804,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"18:00"},"tue":{"kind":"open","open":"09:00","close":"18:00"},"wed":{"kind":"open","open":"09:00","close":"18:00"},"thu":{"kind":"open","open":"09:00","close":"18:00"},"fri":{"kind":"open","open":"09:00","close":"18:00"},"sat":{"kind":"open","open":"09:00","close":"18:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  677254042,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 677254042
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Taas Cafe$dn$))
    and abs(s.latitude - 10.3550944) < 0.00045
    and abs(s.longitude - 123.9105804) < 0.00045
);
-- node/2162410823
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Keepsakes Cafe$nm$,
  $ad$MacArthur Highway, Talomo District, Davao City$ad$,
  7.0634783,
  125.5966798,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"19:00"},"tue":{"kind":"open","open":"09:00","close":"19:00"},"wed":{"kind":"open","open":"09:00","close":"19:00"},"thu":{"kind":"open","open":"09:00","close":"19:00"},"fri":{"kind":"open","open":"09:00","close":"19:00"},"sat":{"kind":"open","open":"09:00","close":"19:00"},"sun":{"kind":"open","open":"09:00","close":"19:00"}}$hr$::jsonb,
  $ph$+63 963 831 2000$ph$,
  'pending',
  'openstreetmap',
  'node',
  2162410823,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 2162410823
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Keepsakes Cafe$dn$))
    and abs(s.latitude - 7.0634783) < 0.00045
    and abs(s.longitude - 125.5966798) < 0.00045
);
-- node/4153298389
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Annipie$nm$,
  $ad$Quimpo Boulevard$ad$,
  7.0565311,
  125.6004287,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"09:00","close":"22:00"},"sun":{"kind":"open","open":"09:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4153298389,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4153298389
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Annipie$dn$))
    and abs(s.latitude - 7.0565311) < 0.00045
    and abs(s.longitude - 125.6004287) < 0.00045
);
-- node/4153298390
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Annipie$nm$,
  $ad$J. P. Laurel Avenue, Agdao District, Davao City$ad$,
  7.0989629,
  125.6315342,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  4153298390,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4153298390
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Annipie$dn$))
    and abs(s.latitude - 7.0989629) < 0.00045
    and abs(s.longitude - 125.6315342) < 0.00045
);
-- node/4212057091
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$EatCafe De Boerderij$nm$,
  $ad$106 MacArthur Highway, Talomo District, Davao City$ad$,
  7.0613308,
  125.5917606,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"01:00"},"tue":{"kind":"open","open":"11:00","close":"01:00"},"wed":{"kind":"open","open":"11:00","close":"01:00"},"thu":{"kind":"open","open":"11:00","close":"01:00"},"fri":{"kind":"open","open":"11:00","close":"01:00"},"sat":{"kind":"open","open":"11:00","close":"01:00"},"sun":{"kind":"open","open":"11:00","close":"01:00"}}$hr$::jsonb,
  $ph$+63 917 143 9690$ph$,
  'pending',
  'openstreetmap',
  'node',
  4212057091,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4212057091
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$EatCafe De Boerderij$dn$))
    and abs(s.latitude - 7.0613308) < 0.00045
    and abs(s.longitude - 125.5917606) < 0.00045
);
-- node/4326684735
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Coffee for Peace$nm$,
  $ad$MacArthur Highway, Talomo District, Davao City$ad$,
  7.0623739,
  125.596173,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"23:00"},"tue":{"kind":"open","open":"08:00","close":"23:00"},"wed":{"kind":"open","open":"08:00","close":"23:00"},"thu":{"kind":"open","open":"08:00","close":"23:00"},"fri":{"kind":"open","open":"08:00","close":"23:00"},"sat":{"kind":"open","open":"08:00","close":"23:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  $ph$+63 82 296 1053$ph$,
  'pending',
  'openstreetmap',
  'node',
  4326684735,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4326684735
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Coffee for Peace$dn$))
    and abs(s.latitude - 7.0623739) < 0.00045
    and abs(s.longitude - 125.596173) < 0.00045
);
-- node/4711780589
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$MyCoffee Time Bistro$nm$,
  $ad$Mount Mayon Street, Poblacion District, Davao City$ad$,
  7.0716827,
  125.6059309,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"23:00"},"tue":{"kind":"open","open":"11:00","close":"23:00"},"wed":{"kind":"open","open":"11:00","close":"23:00"},"thu":{"kind":"open","open":"11:00","close":"23:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+63 82 321 6475$ph$,
  'pending',
  'openstreetmap',
  'node',
  4711780589,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4711780589
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$MyCoffee Time Bistro$dn$))
    and abs(s.latitude - 7.0716827) < 0.00045
    and abs(s.longitude - 125.6059309) < 0.00045
);
-- node/4910992026
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Kawaii Cafe$nm$,
  $ad$F. Torres Street, Poblacion District, Davao City$ad$,
  7.0819915,
  125.6117143,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:00","close":"00:00"},"tue":{"kind":"open","open":"12:00","close":"00:00"},"wed":{"kind":"open","open":"12:00","close":"00:00"},"thu":{"kind":"open","open":"12:00","close":"00:00"},"fri":{"kind":"open","open":"12:00","close":"00:00"},"sat":{"kind":"open","open":"12:00","close":"00:00"},"sun":{"kind":"open","open":"12:00","close":"00:00"}}$hr$::jsonb,
  $ph$+63 999 007 7061$ph$,
  'pending',
  'openstreetmap',
  'node',
  4910992026,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 4910992026
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Kawaii Cafe$dn$))
    and abs(s.latitude - 7.0819915) < 0.00045
    and abs(s.longitude - 125.6117143) < 0.00045
);
-- node/5248945634
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Keepsakes$nm$,
  $ad$Jose Abad Santos Street, Poblacion District, Davao City$ad$,
  7.0718498,
  125.6054035,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"19:00"},"tue":{"kind":"open","open":"09:00","close":"19:00"},"wed":{"kind":"open","open":"09:00","close":"19:00"},"thu":{"kind":"open","open":"09:00","close":"19:00"},"fri":{"kind":"open","open":"09:00","close":"19:00"},"sat":{"kind":"open","open":"09:00","close":"19:00"},"sun":{"kind":"open","open":"09:00","close":"19:00"}}$hr$::jsonb,
  $ph$+63 963 831 2000$ph$,
  'pending',
  'openstreetmap',
  'node',
  5248945634,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 5248945634
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Keepsakes$dn$))
    and abs(s.latitude - 7.0718498) < 0.00045
    and abs(s.longitude - 125.6054035) < 0.00045
);
-- node/7623350890
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Hokkaido Milktea$nm$,
  $ad$Juan dela Cruz Street, Toril District, Davao City$ad$,
  7.0128123,
  125.5003062,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  7623350890,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 7623350890
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Hokkaido Milktea$dn$))
    and abs(s.latitude - 7.0128123) < 0.00045
    and abs(s.longitude - 125.5003062) < 0.00045
);
-- node/7966547928
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Teacup Time$nm$,
  $ad$Buhangin District, Davao City$ad$,
  7.1379646,
  125.6615877,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"20:00"},"tue":{"kind":"open","open":"08:00","close":"20:00"},"wed":{"kind":"open","open":"08:00","close":"20:00"},"thu":{"kind":"open","open":"08:00","close":"20:00"},"fri":{"kind":"open","open":"08:00","close":"20:00"},"sat":{"kind":"open","open":"08:00","close":"20:00"},"sun":{"kind":"open","open":"08:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  7966547928,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 7966547928
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Teacup Time$dn$))
    and abs(s.latitude - 7.1379646) < 0.00045
    and abs(s.longitude - 125.6615877) < 0.00045
);
-- node/8478233351
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Basic Tea Cafe$nm$,
  $ad$Golden Shower Street, Davao City$ad$,
  7.0890818,
  125.5050251,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:30","close":"21:00"},"tue":{"kind":"open","open":"11:30","close":"21:00"},"wed":{"kind":"open","open":"11:30","close":"21:00"},"thu":{"kind":"open","open":"11:30","close":"21:00"},"fri":{"kind":"open","open":"11:30","close":"21:00"},"sat":{"kind":"open","open":"11:30","close":"21:00"},"sun":{"kind":"open","open":"11:30","close":"21:00"}}$hr$::jsonb,
  $ph$0965-961-9196$ph$,
  'pending',
  'openstreetmap',
  'node',
  8478233351,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 8478233351
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Basic Tea Cafe$dn$))
    and abs(s.latitude - 7.0890818) < 0.00045
    and abs(s.longitude - 125.5050251) < 0.00045
);
-- node/9580735217
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Juice Cubi$nm$,
  $ad$Manuel Roxas Avenue, Poblacion District, Davao City$ad$,
  7.0683886,
  125.6148833,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"01:00"},"tue":{"kind":"open","open":"10:00","close":"01:00"},"wed":{"kind":"open","open":"10:00","close":"01:00"},"thu":{"kind":"open","open":"10:00","close":"01:00"},"fri":{"kind":"open","open":"10:00","close":"01:00"},"sat":{"kind":"open","open":"10:00","close":"01:00"},"sun":{"kind":"open","open":"10:00","close":"01:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  9580735217,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9580735217
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Juice Cubi$dn$))
    and abs(s.latitude - 7.0683886) < 0.00045
    and abs(s.longitude - 125.6148833) < 0.00045
);
-- node/9775082117
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Grind Coffee$nm$,
  $ad$Padre Gomez Street, Poblacion District, Davao City$ad$,
  7.0700573,
  125.6143132,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"20:00"},"tue":{"kind":"open","open":"06:00","close":"20:00"},"wed":{"kind":"open","open":"06:00","close":"20:00"},"thu":{"kind":"open","open":"06:00","close":"20:00"},"fri":{"kind":"open","open":"06:00","close":"20:00"},"sat":{"kind":"open","open":"06:00","close":"20:00"},"sun":{"kind":"open","open":"06:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  9775082117,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9775082117
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Grind Coffee$dn$))
    and abs(s.latitude - 7.0700573) < 0.00045
    and abs(s.longitude - 125.6143132) < 0.00045
);
-- node/9931428118
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Coffee Project$nm$,
  $ad$Davao-Bukidnon Road, Tugbok District, Davao City$ad$,
  7.0863874,
  125.5082426,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  9931428118,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 9931428118
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Coffee Project$dn$))
    and abs(s.latitude - 7.0863874) < 0.00045
    and abs(s.longitude - 125.5082426) < 0.00045
);
-- node/10094931217
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Bo's Coffee$nm$,
  $ad$C. Bangoy Street, Poblacion District, Davao City$ad$,
  7.0745622,
  125.6110546,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10094931217,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10094931217
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Bo's Coffee$dn$))
    and abs(s.latitude - 7.0745622) < 0.00045
    and abs(s.longitude - 125.6110546) < 0.00045
);
-- node/10196009662
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Chatime$nm$,
  $ad$MacArthur Highway, Bangkal, Davao City$ad$,
  7.0608908,
  125.554938,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"21:00"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"21:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10196009662,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10196009662
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Chatime$dn$))
    and abs(s.latitude - 7.0608908) < 0.00045
    and abs(s.longitude - 125.554938) < 0.00045
);
-- node/10219440917
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Café Prelaya$nm$,
  $ad$Sputnik Street, Poblacion District, Davao City$ad$,
  7.0809941,
  125.6077298,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"20:00"},"tue":{"kind":"open","open":"10:00","close":"20:00"},"wed":{"kind":"open","open":"10:00","close":"20:00"},"thu":{"kind":"open","open":"10:00","close":"20:00"},"fri":{"kind":"open","open":"10:00","close":"20:00"},"sat":{"kind":"open","open":"10:00","close":"20:00"},"sun":{"kind":"open","open":"10:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  10219440917,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10219440917
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Café Prelaya$dn$))
    and abs(s.latitude - 7.0809941) < 0.00045
    and abs(s.longitude - 125.6077298) < 0.00045
);
-- node/10656507105
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Mylk$nm$,
  $ad$Ruby Street, Poblacion District, Davao City$ad$,
  7.0817007,
  125.6016672,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"open","open":"07:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63 945 335 7411$ph$,
  'pending',
  'openstreetmap',
  'node',
  10656507105,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10656507105
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Mylk$dn$))
    and abs(s.latitude - 7.0817007) < 0.00045
    and abs(s.longitude - 125.6016672) < 0.00045
);
-- node/10760541777
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Kanto Coffee$nm$,
  $ad$Road 1, Poblacion District, Davao City$ad$,
  7.0842174,
  125.6100256,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63 966 288 5813$ph$,
  'pending',
  'openstreetmap',
  'node',
  10760541777,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10760541777
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Kanto Coffee$dn$))
    and abs(s.latitude - 7.0842174) < 0.00045
    and abs(s.longitude - 125.6100256) < 0.00045
);
-- node/10789137049
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Stash Coffee Co.$nm$,
  $ad$A. Iñigo Street, Poblacion District, Davao City$ad$,
  7.0854272,
  125.6139569,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:30","close":"21:30"},"tue":{"kind":"open","open":"08:30","close":"21:30"},"wed":{"kind":"open","open":"08:30","close":"21:30"},"thu":{"kind":"open","open":"08:30","close":"21:30"},"fri":{"kind":"open","open":"08:30","close":"21:30"},"sat":{"kind":"open","open":"08:30","close":"21:30"},"sun":{"kind":"open","open":"08:00","close":"21:30"}}$hr$::jsonb,
  $ph$+639063674762$ph$,
  'pending',
  'openstreetmap',
  'node',
  10789137049,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 10789137049
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Stash Coffee Co.$dn$))
    and abs(s.latitude - 7.0854272) < 0.00045
    and abs(s.longitude - 125.6139569) < 0.00045
);
-- node/11224062809
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Shake'NTea$nm$,
  $ad$Prosperity Street, Talomo District, Davao City$ad$,
  7.0778577,
  125.5256919,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"20:00"},"tue":{"kind":"open","open":"06:00","close":"20:00"},"wed":{"kind":"open","open":"06:00","close":"20:00"},"thu":{"kind":"open","open":"06:00","close":"20:00"},"fri":{"kind":"open","open":"06:00","close":"20:00"},"sat":{"kind":"open","open":"06:00","close":"20:00"},"sun":{"kind":"open","open":"13:00","close":"20:00"}}$hr$::jsonb,
  $ph$+639912094555$ph$,
  'pending',
  'openstreetmap',
  'node',
  11224062809,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11224062809
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Shake'NTea$dn$))
    and abs(s.latitude - 7.0778577) < 0.00045
    and abs(s.longitude - 125.5256919) < 0.00045
);
-- node/11234346845
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Espresso Nook: Live Life Coffee Shop$nm$,
  $ad$8 Davao-Agusan National Highway, Pampanga, Davao City$ad$,
  7.1114113,
  125.6512159,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+639369905259$ph$,
  'pending',
  'openstreetmap',
  'node',
  11234346845,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11234346845
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Espresso Nook: Live Life Coffee Shop$dn$))
    and abs(s.latitude - 7.1114113) < 0.00045
    and abs(s.longitude - 125.6512159) < 0.00045
);
-- node/11393159669
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Sikwatehan sa Dalan$nm$,
  $ad$Davao-Bukidnon Road, Tugbok District, Davao City$ad$,
  7.0843249,
  125.5097484,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"05:00","close":"09:00"},"tue":{"kind":"open","open":"05:00","close":"09:00"},"wed":{"kind":"open","open":"05:00","close":"09:00"},"thu":{"kind":"open","open":"05:00","close":"09:00"},"fri":{"kind":"open","open":"05:00","close":"09:00"},"sat":{"kind":"open","open":"05:00","close":"09:00"},"sun":{"kind":"open","open":"05:00","close":"09:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11393159669,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11393159669
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Sikwatehan sa Dalan$dn$))
    and abs(s.latitude - 7.0843249) < 0.00045
    and abs(s.longitude - 125.5097484) < 0.00045
);
-- node/11499749771
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Blooming Days$nm$,
  $ad$Loyola Street, Poblacion District, Davao City$ad$,
  7.0827071,
  125.6128923,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:30","close":"22:00"},"tue":{"kind":"open","open":"08:30","close":"22:00"},"wed":{"kind":"open","open":"08:30","close":"22:00"},"thu":{"kind":"open","open":"08:30","close":"22:00"},"fri":{"kind":"open","open":"08:30","close":"22:00"},"sat":{"kind":"open","open":"08:30","close":"22:00"},"sun":{"kind":"open","open":"13:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11499749771,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11499749771
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Blooming Days$dn$))
    and abs(s.latitude - 7.0827071) < 0.00045
    and abs(s.longitude - 125.6128923) < 0.00045
);
-- node/11726465934
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Verde Pianta$nm$,
  $ad$Ignacio Villamor Street, Poblacion District, Davao City$ad$,
  7.0770523,
  125.6113733,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11726465934,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11726465934
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Verde Pianta$dn$))
    and abs(s.latitude - 7.0770523) < 0.00045
    and abs(s.longitude - 125.6113733) < 0.00045
);
-- node/11738400123
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Lara Mia$nm$,
  $ad$University Avenue, Juna Subdivision, Davao City$ad$,
  7.0560114,
  125.5941349,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"21:00"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"21:00"},"sat":{"kind":"open","open":"10:00","close":"21:00"},"sun":{"kind":"open","open":"10:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63 932 828 3636$ph$,
  'pending',
  'openstreetmap',
  'node',
  11738400123,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11738400123
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Lara Mia$dn$))
    and abs(s.latitude - 7.0560114) < 0.00045
    and abs(s.longitude - 125.5941349) < 0.00045
);
-- node/11794999869
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Outlook Coffee$nm$,
  $ad$Talomo District, Davao City$ad$,
  7.0709687,
  125.5486279,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  $ph$+63 954 178 9238$ph$,
  'pending',
  'openstreetmap',
  'node',
  11794999869,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11794999869
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Outlook Coffee$dn$))
    and abs(s.latitude - 7.0709687) < 0.00045
    and abs(s.longitude - 125.5486279) < 0.00045
);
-- node/11914933460
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Thirty Third Café$nm$,
  $ad$Lapu-Lapu Street, Poblacion District, Davao City$ad$,
  7.0791196,
  125.6201261,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"23:00"},"tue":{"kind":"open","open":"11:00","close":"23:00"},"wed":{"kind":"open","open":"11:00","close":"23:00"},"thu":{"kind":"open","open":"11:00","close":"23:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  11914933460,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 11914933460
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Thirty Third Café$dn$))
    and abs(s.latitude - 7.0791196) < 0.00045
    and abs(s.longitude - 125.6201261) < 0.00045
);
-- node/12141670513
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$T'Brews Café$nm$,
  $ad$A. Lacson Street, Obrero, Davao City$ad$,
  7.0870334,
  125.6144439,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"20:00"},"tue":{"kind":"closed"},"wed":{"kind":"open","open":"11:00","close":"20:00"},"thu":{"kind":"open","open":"11:00","close":"20:00"},"fri":{"kind":"open","open":"11:00","close":"20:00"},"sat":{"kind":"open","open":"11:00","close":"20:00"},"sun":{"kind":"open","open":"11:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12141670513,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12141670513
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$T'Brews Café$dn$))
    and abs(s.latitude - 7.0870334) < 0.00045
    and abs(s.longitude - 125.6144439) < 0.00045
);
-- node/12143283018
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Green Coffee$nm$,
  $ad$F. S. Dizon Road, Poblacion District, Davao City$ad$,
  7.092733,
  125.6044797,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"02:00"},"tue":{"kind":"open","open":"07:00","close":"02:00"},"wed":{"kind":"open","open":"07:00","close":"02:00"},"thu":{"kind":"open","open":"07:00","close":"02:00"},"fri":{"kind":"open","open":"07:00","close":"02:00"},"sat":{"kind":"open","open":"07:00","close":"02:00"},"sun":{"kind":"open","open":"07:00","close":"02:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12143283018,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12143283018
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Green Coffee$dn$))
    and abs(s.latitude - 7.092733) < 0.00045
    and abs(s.longitude - 125.6044797) < 0.00045
);
-- node/12159689839
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$BeansTalk$nm$,
  $ad$Aklan Street, Poblacion District, Davao City$ad$,
  7.0746227,
  125.6181496,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12159689839,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12159689839
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$BeansTalk$dn$))
    and abs(s.latitude - 7.0746227) < 0.00045
    and abs(s.longitude - 125.6181496) < 0.00045
);
-- node/12256760301
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Mombakes$nm$,
  $ad$Calamansi Street$ad$,
  7.0526515,
  125.5919008,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12256760301,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12256760301
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Mombakes$dn$))
    and abs(s.latitude - 7.0526515) < 0.00045
    and abs(s.longitude - 125.5919008) < 0.00045
);
-- node/12406667517
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Jaeger's Cafe$nm$,
  $ad$MacArthur Highway, Davao City$ad$,
  7.0557612,
  125.5752769,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"00:00"},"tue":{"kind":"open","open":"11:00","close":"00:00"},"wed":{"kind":"open","open":"11:00","close":"00:00"},"thu":{"kind":"open","open":"11:00","close":"00:00"},"fri":{"kind":"open","open":"11:00","close":"00:00"},"sat":{"kind":"open","open":"11:00","close":"00:00"},"sun":{"kind":"open","open":"11:00","close":"00:00"}}$hr$::jsonb,
  $ph$09693822577$ph$,
  'pending',
  'openstreetmap',
  'node',
  12406667517,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12406667517
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Jaeger's Cafe$dn$))
    and abs(s.latitude - 7.0557612) < 0.00045
    and abs(s.longitude - 125.5752769) < 0.00045
);
-- node/12443763302
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Pinta Cafe$nm$,
  $ad$Tulip Drive$ad$,
  7.0495539,
  125.5907035,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12443763302,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12443763302
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Pinta Cafe$dn$))
    and abs(s.latitude - 7.0495539) < 0.00045
    and abs(s.longitude - 125.5907035) < 0.00045
);
-- node/12557868956
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Brownies and Co$nm$,
  $ad$Blk 17 Lot 9 Phoenix St., Catalunan Pequeño, Davao City$ad$,
  7.0705312,
  125.5331369,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"00:00"},"tue":{"kind":"open","open":"10:00","close":"00:00"},"wed":{"kind":"open","open":"10:00","close":"00:00"},"thu":{"kind":"open","open":"10:00","close":"00:00"},"fri":{"kind":"open","open":"10:00","close":"00:00"},"sat":{"kind":"open","open":"10:00","close":"00:00"},"sun":{"kind":"open","open":"10:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  12557868956,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 12557868956
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Brownies and Co$dn$))
    and abs(s.latitude - 7.0705312) < 0.00045
    and abs(s.longitude - 125.5331369) < 0.00045
);
-- node/13110148903
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Café Macario$nm$,
  $ad$Baguio District, Davao City$ad$,
  7.1279762,
  125.3627345,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"17:00"},"tue":{"kind":"open","open":"10:00","close":"17:00"},"wed":{"kind":"open","open":"10:00","close":"17:00"},"thu":{"kind":"open","open":"10:00","close":"17:00"},"fri":{"kind":"open","open":"10:00","close":"17:00"},"sat":{"kind":"open","open":"10:00","close":"17:00"},"sun":{"kind":"open","open":"10:00","close":"17:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13110148903,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13110148903
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Café Macario$dn$))
    and abs(s.latitude - 7.1279762) < 0.00045
    and abs(s.longitude - 125.3627345) < 0.00045
);
-- node/13119092087
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Sprinkles$nm$,
  $ad$115 P. Pelayo Street, Poblacion District, Davao City$ad$,
  7.0681288,
  125.6062399,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13119092087,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13119092087
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Sprinkles$dn$))
    and abs(s.latitude - 7.0681288) < 0.00045
    and abs(s.longitude - 125.6062399) < 0.00045
);
-- node/13179819334
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Meeting Grounds$nm$,
  $ad$C. Bangoy Street, Poblacion District, Davao City$ad$,
  7.0677947,
  125.609564,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"23:00"},"tue":{"kind":"open","open":"09:00","close":"23:00"},"wed":{"kind":"open","open":"09:00","close":"23:00"},"thu":{"kind":"open","open":"09:00","close":"23:00"},"fri":{"kind":"open","open":"09:00","close":"23:00"},"sat":{"kind":"open","open":"09:00","close":"23:00"},"sun":{"kind":"open","open":"09:00","close":"23:00"}}$hr$::jsonb,
  $ph$+63 921 518 8049$ph$,
  'pending',
  'openstreetmap',
  'node',
  13179819334,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13179819334
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Meeting Grounds$dn$))
    and abs(s.latitude - 7.0677947) < 0.00045
    and abs(s.longitude - 125.609564) < 0.00045
);
-- node/13187099317
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Daleachious Cafe$nm$,
  $ad$Carlos P. Garcia Highway, Buhangin District, Davao City$ad$,
  7.1281617,
  125.6366488,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13187099317,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13187099317
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Daleachious Cafe$dn$))
    and abs(s.latitude - 7.1281617) < 0.00045
    and abs(s.longitude - 125.6366488) < 0.00045
);
-- node/13279649301
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$StarBlack Cafe$nm$,
  $ad$King's Road, Bangkal, Davao City$ad$,
  7.0598084,
  125.5528814,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"15:00","close":"21:00"},"tue":{"kind":"open","open":"15:00","close":"21:00"},"wed":{"kind":"open","open":"15:00","close":"21:00"},"thu":{"kind":"open","open":"15:00","close":"21:00"},"fri":{"kind":"open","open":"15:00","close":"21:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13279649301,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13279649301
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$StarBlack Cafe$dn$))
    and abs(s.latitude - 7.0598084) < 0.00045
    and abs(s.longitude - 125.5528814) < 0.00045
);
-- node/13528930021
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$FLOURY CAFE$nm$,
  $ad$Padre Gomez Street, Poblacion District, Davao City$ad$,
  7.0683977,
  125.6127697,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$09987431212$ph$,
  'pending',
  'openstreetmap',
  'node',
  13528930021,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13528930021
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$FLOURY CAFE$dn$))
    and abs(s.latitude - 7.0683977) < 0.00045
    and abs(s.longitude - 125.6127697) < 0.00045
);
-- node/13886626901
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Bo’s coffee$nm$,
  $ad$Carlos Villa-Abrille Drive$ad$,
  7.0561953,
  125.5888363,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  13886626901,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 13886626901
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Bo’s coffee$dn$))
    and abs(s.latitude - 7.0561953) < 0.00045
    and abs(s.longitude - 125.5888363) < 0.00045
);
-- node/14022027578
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$The Foliage Cafe$nm$,
  $ad$Duhat Street$ad$,
  7.0604838,
  125.591292,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"02:00"},"tue":{"kind":"open","open":"08:00","close":"02:00"},"wed":{"kind":"open","open":"08:00","close":"02:00"},"thu":{"kind":"open","open":"08:00","close":"02:00"},"fri":{"kind":"open","open":"08:00","close":"02:00"},"sat":{"kind":"open","open":"08:00","close":"02:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'node',
  14022027578,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'node'
    and s.osm_id = 14022027578
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$The Foliage Cafe$dn$))
    and abs(s.latitude - 7.0604838) < 0.00045
    and abs(s.longitude - 125.591292) < 0.00045
);
-- way/339674874
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Green Coffee$nm$,
  $ad$Ruby Street, Poblacion District, Davao City$ad$,
  7.0820711,
  125.6017175,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  339674874,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 339674874
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Green Coffee$dn$))
    and abs(s.latitude - 7.0820711) < 0.00045
    and abs(s.longitude - 125.6017175) < 0.00045
);
-- way/1225348812
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Belviz Durian Farm$nm$,
  $ad$Calinan District, Davao City$ad$,
  7.178217,
  125.4445152,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"16:00"},"tue":{"kind":"open","open":"09:00","close":"16:00"},"wed":{"kind":"open","open":"09:00","close":"16:00"},"thu":{"kind":"open","open":"09:00","close":"16:00"},"fri":{"kind":"open","open":"09:00","close":"16:00"},"sat":{"kind":"open","open":"09:00","close":"16:00"},"sun":{"kind":"open","open":"09:00","close":"16:00"}}$hr$::jsonb,
  $ph$+63 917 717 2417$ph$,
  'pending',
  'openstreetmap',
  'way',
  1225348812,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 1225348812
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Belviz Durian Farm$dn$))
    and abs(s.latitude - 7.178217) < 0.00045
    and abs(s.longitude - 125.4445152) < 0.00045
);
-- way/1330073031
insert into public.shops (
  name, address, latitude, longitude, categories, hours, contact_number, status, source, osm_type, osm_id, imported_at
)
select
  $nm$Green Coffee$nm$,
  $ad$Carlos P. Garcia Highway, Talomo District, Davao City$ad$,
  7.0648517,
  125.5562397,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"04:00"},"tue":{"kind":"open","open":"07:00","close":"04:00"},"wed":{"kind":"open","open":"07:00","close":"04:00"},"thu":{"kind":"open","open":"07:00","close":"04:00"},"fri":{"kind":"open","open":"07:00","close":"04:00"},"sat":{"kind":"open","open":"07:00","close":"04:00"},"sun":{"kind":"open","open":"07:00","close":"04:00"}}$hr$::jsonb,
  null,
  'pending',
  'openstreetmap',
  'way',
  1330073031,
  now()
where not exists (
  select 1 from public.shops s
  where s.source = 'openstreetmap'
    and s.osm_type = 'way'
    and s.osm_id = 1330073031
)
and not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($dn$Green Coffee$dn$))
    and abs(s.latitude - 7.0648517) < 0.00045
    and abs(s.longitude - 125.5562397) < 0.00045
);

commit;
