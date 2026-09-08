-- =========================================================
-- KapéDoko — Metro Manila coverage (follow-up)
-- =========================================================
-- Run this in the Supabase SQL editor AFTER 20260907_shop_submission_constraints.
--
-- Replaces shops_in_marikina with an OSM NCR polygon stored in
-- coverage_regions. Existing Marikina rows remain valid. Later
-- expansion is an insert into coverage_regions with is_active = true;
-- do not rewrite the shop submission model.
-- =========================================================

create table if not exists coverage_regions (
  id text primary key,
  name text not null,
  is_active boolean not null default true,
  polygon jsonb not null
);

comment on table coverage_regions is
  'Active launch geographies. Point-in-polygon checks use every row with is_active = true.';

insert into coverage_regions (id, name, is_active, polygon)
values (
  'metro-manila',
  'Metro Manila',
  true,
  '{"type":"Polygon","coordinates":[[[120.7917034,14.6011485],[120.7934641,14.58564],[120.8936218,14.5578053],[120.937761,14.5339666],[120.9469778,14.5011152],[120.9433528,14.4939136],[120.97014,14.4756081],[120.9715596,14.4715472],[120.9682878,14.4715325],[120.9695475,14.4682284],[120.9659993,14.4653505],[120.9704276,14.4548152],[120.9699028,14.4467146],[120.973923,14.4392814],[120.9840825,14.4335181],[120.9952789,14.4056846],[121.0021211,14.3992236],[121.0019281,14.3939918],[121.0078901,14.390569],[121.007725,14.3839103],[121.0115722,14.3801806],[121.0069491,14.3683762],[121.0051584,14.3508483],[121.0080065,14.348001],[121.0113193,14.3472554],[121.0194504,14.3530526],[121.0291461,14.365749],[121.0361407,14.3663565],[121.0432434,14.3719823],[121.0454856,14.3673093],[121.0485434,14.3673677],[121.0571723,14.3799196],[121.0931967,14.4009306],[121.1160277,14.4100751],[121.1343954,14.4114052],[121.122151,14.4513116],[121.1183452,14.4894504],[121.1070156,14.5085212],[121.1094993,14.5258455],[121.10605,14.5270866],[121.1040832,14.5338787],[121.1071439,14.5459515],[121.1097446,14.5465986],[121.0980692,14.5547713],[121.0946307,14.5690387],[121.1083613,14.5793694],[121.1110273,14.5910769],[121.1029354,14.5974769],[121.1057649,14.6034423],[121.0987248,14.6188825],[121.1062307,14.6198787],[121.1038137,14.62684],[121.1083412,14.6364917],[121.1237634,14.6378404],[121.1299934,14.6344123],[121.1284613,14.6426782],[121.1316676,14.6541782],[121.1346392,14.6548501],[121.1310755,14.6678996],[121.1255368,14.6700509],[121.1221297,14.6664537],[121.1159295,14.6740089],[121.1103497,14.6700263],[121.1066178,14.6757895],[121.1121169,14.6846502],[121.1114141,14.6957288],[121.1139464,14.6980592],[121.1184868,14.7307439],[121.1137369,14.7372321],[121.117859,14.739857],[121.1181479,14.7495936],[121.125776,14.7626983],[121.1237838,14.7653683],[121.1322758,14.771775],[121.1332033,14.7764137],[121.1204059,14.774863],[121.104773,14.7618357],[121.1016249,14.7655348],[121.0990606,14.7626015],[121.094936,14.7708776],[121.0920556,14.7674429],[121.086827,14.7680724],[121.0864917,14.7736372],[121.0822139,14.7748802],[121.080957,14.7711678],[121.0771212,14.7766514],[121.0719727,14.7718941],[121.0714861,14.775945],[121.066604,14.7738474],[121.0656548,14.7775688],[121.0628115,14.7749123],[121.0626847,14.7788023],[121.0594069,14.7775344],[121.0552245,14.7826606],[121.0498872,14.7831996],[121.0457145,14.7797552],[121.0383865,14.7852973],[121.0305199,14.7843271],[121.0304097,14.7814718],[121.0248451,14.7792655],[121.0280325,14.7779443],[121.0234885,14.7741564],[121.0271224,14.7723177],[121.0234359,14.7630988],[121.0009133,14.7534132],[120.99779,14.7583971],[120.9889395,14.7571511],[120.9810471,14.7359804],[120.9778053,14.7356309],[120.9832024,14.7256761],[120.9813459,14.7247459],[120.9755775,14.7257627],[120.959539,14.7199238],[120.9495509,14.7340427],[120.9442251,14.7337942],[120.9414571,14.7374023],[120.9367599,14.7370977],[120.9345981,14.7333934],[120.9266896,14.7365862],[120.9257944,14.7297406],[120.9524492,14.6942028],[120.9454556,14.6883685],[120.9188847,14.7128483],[120.9148085,14.7122529],[120.9114711,14.7041824],[120.8875279,14.687903],[120.8394927,14.6395473],[120.8208015,14.6166622],[120.7917034,14.6011485]]]}'::jsonb
)
on conflict (id) do update
set name = excluded.name,
    is_active = excluded.is_active,
    polygon = excluded.polygon;

create or replace function point_in_ring(
  lat double precision,
  lng double precision,
  ring jsonb
)
returns boolean
language plpgsql
immutable
as $$
declare
  n int;
  i int;
  j int;
  xi double precision;
  yi double precision;
  xj double precision;
  yj double precision;
  inside boolean := false;
begin
  n := jsonb_array_length(ring);
  if n < 4 then
    return false;
  end if;

  j := n - 1;
  for i in 0 .. n - 1 loop
    xi := (ring -> i ->> 0)::double precision;
    yi := (ring -> i ->> 1)::double precision;
    xj := (ring -> j ->> 0)::double precision;
    yj := (ring -> j ->> 1)::double precision;
    if (yi > lat) <> (yj > lat)
       and lng < (xj - xi) * (lat - yi) / nullif(yj - yi, 0) + xi then
      inside := not inside;
    end if;
    j := i;
  end loop;

  return inside;
end;
$$;

create or replace function is_in_active_coverage(lat double precision, lng double precision)
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  region record;
  polygons jsonb;
  rings jsonb;
  hole_index int;
  inside boolean;
begin
  if lat is null or lng is null then
    return false;
  end if;

  for region in
    select polygon from coverage_regions where is_active
  loop
    if region.polygon ->> 'type' = 'Polygon' then
      polygons := jsonb_build_array(region.polygon -> 'coordinates');
    elsif region.polygon ->> 'type' = 'MultiPolygon' then
      polygons := region.polygon -> 'coordinates';
    else
      continue;
    end if;

    for rings in select value from jsonb_array_elements(polygons) loop
      if not point_in_ring(lat, lng, rings -> 0) then
        continue;
      end if;

      inside := true;
      for hole_index in 1 .. jsonb_array_length(rings) - 1 loop
        if point_in_ring(lat, lng, rings -> hole_index) then
          inside := false;
          exit;
        end if;
      end loop;

      if inside then
        return true;
      end if;
    end loop;
  end loop;

  return false;
end;
$$;

create or replace function shops_require_coverage()
returns trigger
language plpgsql
as $$
begin
  if not is_in_active_coverage(new.latitude, new.longitude) then
    raise exception 'shops_in_coverage'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

drop trigger if exists shops_require_coverage on shops;
create trigger shops_require_coverage
  before insert or update of latitude, longitude on shops
  for each row execute procedure shops_require_coverage();

alter table shops drop constraint if exists shops_in_marikina;

-- Supabase prompts to enable RLS on new tables. Do not enable it
-- from the dashboard with no policy — the submit trigger must read
-- this polygon. This block turns RLS on with public read, owner write.
alter table coverage_regions enable row level security;

drop policy if exists coverage_regions_read on coverage_regions;
create policy coverage_regions_read
  on coverage_regions
  for select
  to anon, authenticated
  using (true);

revoke insert, update, delete on coverage_regions from anon, authenticated;
