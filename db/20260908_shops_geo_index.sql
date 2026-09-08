-- Viewport cafe queries filter approved shops by lat/lng as the map pans.
create index if not exists shops_approved_lat_lng_idx
  on public.shops (latitude, longitude)
  where status = 'approved';
