-- =========================================================
-- KapéDoko — Philippines coverage
-- =========================================================
-- Run this in the Supabase SQL editor AFTER 20260929_admin_portal_fix.sql.
--
-- Public shop inserts still go through shops_require_coverage.
-- These island boxes let a pin land anywhere in the Philippines.
-- Metro Manila stays active; it already sits inside Luzon.
-- Admin writes continue to bypass coverage.
-- Keep the coordinates in sync with PHILIPPINES_REGIONS in
-- app/utils/geography.ts.
-- =========================================================

insert into coverage_regions (id, name, is_active, polygon)
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
