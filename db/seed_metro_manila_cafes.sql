-- KapéDoko seed: Metro Manila cafes from OpenStreetMap
-- Source file: metro-manila-cafes.geojson
-- © OpenStreetMap contributors, ODbL. https://www.openstreetmap.org/copyright
--
-- Features in file: 2332
-- Inserted here: 266
-- Skipped, no usable address: 948
-- Skipped, hours missing: 773
-- Skipped, outside Metro Manila: 343
-- Skipped, hours split-shift: 1
-- Skipped, hours empty: 1
--
-- Each row starts as pending. shops_before_write rejects any other status on insert.
-- description = 'OpenStreetMap' marks this seed so it can be approved on its own:
--   update public.shops
--   set status = 'approved'
--   where status = 'pending' and description = 'OpenStreetMap';
--
-- Safe to run again. A shop with the same name within about 50 meters is left as-is.
-- Wi-Fi, plugs, photos, and reviews are not invented from the map data.

begin;

-- node/11955988333
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$% Arabica$nm$,
  'OpenStreetMap',
  $ad$5th Avenue, Shangri-La at the Fort, Taguig$ad$,
  14.5519351,
  121.0476719,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 917 109 1053$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$% Arabica$nm$))
    and abs(s.latitude - 14.5519351) < 0.00045
    and abs(s.longitude - 121.0476719) < 0.00045
);

-- node/9126140120
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$8065 Coffee$nm$,
  'OpenStreetMap',
  $ad$7700 Saint Paul Road, Metro Manila$ad$,
  14.5644767,
  121.0108821,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"23:00"},"tue":{"kind":"open","open":"09:00","close":"23:00"},"wed":{"kind":"open","open":"09:00","close":"23:00"},"thu":{"kind":"open","open":"09:00","close":"23:00"},"fri":{"kind":"open","open":"09:00","close":"23:00"},"sat":{"kind":"open","open":"09:00","close":"23:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+639774938$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$8065 Coffee$nm$))
    and abs(s.latitude - 14.5644767) < 0.00045
    and abs(s.longitude - 121.0108821) < 0.00045
);

-- node/10983530498
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$8680 Coffee$nm$,
  'OpenStreetMap',
  $ad$Finlandia Street, Metro Manila$ad$,
  14.5562059,
  121.0056771,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"11:30"},"tue":{"kind":"open","open":"08:00","close":"11:30"},"wed":{"kind":"open","open":"08:00","close":"11:30"},"thu":{"kind":"open","open":"08:00","close":"11:30"},"fri":{"kind":"open","open":"08:00","close":"11:30"},"sat":{"kind":"open","open":"08:00","close":"11:30"},"sun":{"kind":"open","open":"08:00","close":"11:30"}}$hr$::jsonb,
  $ph$+63917 463 4131$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$8680 Coffee$nm$))
    and abs(s.latitude - 14.5562059) < 0.00045
    and abs(s.longitude - 121.0056771) < 0.00045
);

-- node/11750288450
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$a. m. espresso$nm$,
  'OpenStreetMap',
  $ad$P. Guevarra Street, The Cornerhouse, Metro Manila$ad$,
  14.5963233,
  121.038595,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$a. m. espresso$nm$))
    and abs(s.latitude - 14.5963233) < 0.00045
    and abs(s.longitude - 121.038595) < 0.00045
);

-- node/13934962151
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$A.bode Space$nm$,
  'OpenStreetMap',
  $ad$2 Don E. Ejercito Street, Metro Manila$ad$,
  14.5997114,
  121.0301469,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$A.bode Space$nm$))
    and abs(s.latitude - 14.5997114) < 0.00045
    and abs(s.longitude - 121.0301469) < 0.00045
);

-- node/9177831338
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Ahon Cafe$nm$,
  'OpenStreetMap',
  $ad$Calamba Street, Metro Manila$ad$,
  14.6267177,
  120.9960053,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"closed"},"wed":{"kind":"open","open":"14:00","close":"20:30"},"thu":{"kind":"open","open":"14:00","close":"20:30"},"fri":{"kind":"open","open":"14:00","close":"20:30"},"sat":{"kind":"open","open":"14:00","close":"20:30"},"sun":{"kind":"open","open":"14:00","close":"20:30"}}$hr$::jsonb,
  $ph$+639175026115$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Ahon Cafe$nm$))
    and abs(s.latitude - 14.6267177) < 0.00045
    and abs(s.longitude - 120.9960053) < 0.00045
);

-- node/13333289740
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Ailo Coffee$nm$,
  'OpenStreetMap',
  $ad$2 V. P. Ibañez Street, Metro Manila$ad$,
  14.5993398,
  121.0372644,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"10:00","close":"20:00"},"wed":{"kind":"open","open":"10:00","close":"20:00"},"thu":{"kind":"open","open":"10:00","close":"20:00"},"fri":{"kind":"open","open":"10:00","close":"20:00"},"sat":{"kind":"open","open":"10:00","close":"20:00"},"sun":{"kind":"open","open":"10:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Ailo Coffee$nm$))
    and abs(s.latitude - 14.5993398) < 0.00045
    and abs(s.longitude - 121.0372644) < 0.00045
);

-- relation/14047762
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Alvarez Park Cafe$nm$,
  'OpenStreetMap',
  $ad$09 Tagalag Road, Valenzuela$ad$,
  14.715854,
  120.9434902,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"closed"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  $ph$+639171011008$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Alvarez Park Cafe$nm$))
    and abs(s.latitude - 14.715854) < 0.00045
    and abs(s.longitude - 120.9434902) < 0.00045
);

-- node/4158973791
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Amo Yamie Crib$nm$,
  'OpenStreetMap',
  $ad$Second Floor, Gordi Plaza, 2125 Legarda Street, Quiapo, Manila$ad$,
  14.6000056,
  120.9905635,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"12:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 9178335017$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Amo Yamie Crib$nm$))
    and abs(s.latitude - 14.6000056) < 0.00045
    and abs(s.longitude - 120.9905635) < 0.00045
);

-- node/4158776089
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Amo Yamie Crib$nm$,
  'OpenStreetMap',
  $ad$Third Floor, DB Building 1250, Padre Noval Street Corner España Boulevard, Sampaloc, Manila$ad$,
  14.6064279,
  120.9898192,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63 9178335017$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Amo Yamie Crib$nm$))
    and abs(s.latitude - 14.6064279) < 0.00045
    and abs(s.longitude - 120.9898192) < 0.00045
);

-- node/11195167938
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Arts and Beans$nm$,
  'OpenStreetMap',
  $ad$51 West Capitol Drive, Metro Manila$ad$,
  14.5719239,
  121.058888,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"20:00"},"tue":{"kind":"open","open":"07:00","close":"20:00"},"wed":{"kind":"open","open":"07:00","close":"20:00"},"thu":{"kind":"open","open":"07:00","close":"20:00"},"fri":{"kind":"open","open":"07:00","close":"20:00"},"sat":{"kind":"open","open":"07:00","close":"20:00"},"sun":{"kind":"open","open":"07:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Arts and Beans$nm$))
    and abs(s.latitude - 14.5719239) < 0.00045
    and abs(s.longitude - 121.058888) < 0.00045
);

-- node/13666254015
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Asterisko$nm$,
  'OpenStreetMap',
  $ad$2339 Taft Avenue, Metro Manila$ad$,
  14.5661241,
  120.9929937,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Asterisko$nm$))
    and abs(s.latitude - 14.5661241) < 0.00045
    and abs(s.longitude - 120.9929937) < 0.00045
);

-- node/12682572601
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Atmos Coffee Co$nm$,
  'OpenStreetMap',
  $ad$Tandang Sora Avenue, Metro Manila$ad$,
  14.6800052,
  121.0202424,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Atmos Coffee Co$nm$))
    and abs(s.latitude - 14.6800052) < 0.00045
    and abs(s.longitude - 121.0202424) < 0.00045
);

-- node/13575302301
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Auro Chocolate Café$nm$,
  'OpenStreetMap',
  $ad$27th Street, Metro Manila$ad$,
  14.548995,
  121.0500372,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"01:00"},"fri":{"kind":"open","open":"07:00","close":"01:00"},"sat":{"kind":"open","open":"07:00","close":"01:00"},"sun":{"kind":"open","open":"07:00","close":"01:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Auro Chocolate Café$nm$))
    and abs(s.latitude - 14.548995) < 0.00045
    and abs(s.longitude - 121.0500372) < 0.00045
);

-- way/979775042
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Baba's Cups and Bites$nm$,
  'OpenStreetMap',
  $ad$Victoria Avenue, Muntinlupa$ad$,
  14.3534374,
  121.0090686,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"18:00"},"tue":{"kind":"open","open":"06:00","close":"18:00"},"wed":{"kind":"open","open":"06:00","close":"18:00"},"thu":{"kind":"open","open":"06:00","close":"18:00"},"fri":{"kind":"open","open":"06:00","close":"18:00"},"sat":{"kind":"open","open":"06:00","close":"18:00"},"sun":{"kind":"open","open":"06:00","close":"18:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Baba's Cups and Bites$nm$))
    and abs(s.latitude - 14.3534374) < 0.00045
    and abs(s.longitude - 121.0090686) < 0.00045
);

-- node/6560111002
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Balai Pandesal$nm$,
  'OpenStreetMap',
  $ad$Escriva Drive, Metro Manila$ad$,
  14.5789877,
  121.0607089,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Balai Pandesal$nm$))
    and abs(s.latitude - 14.5789877) < 0.00045
    and abs(s.longitude - 121.0607089) < 0.00045
);

-- node/11043442654
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Bask$nm$,
  'OpenStreetMap',
  $ad$A. Mabini Street, Mabini180, Metro Manila$ad$,
  14.5946088,
  121.0406001,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"21:00"},"sun":{"kind":"open","open":"08:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Bask$nm$))
    and abs(s.latitude - 14.5946088) < 0.00045
    and abs(s.longitude - 121.0406001) < 0.00045
);

-- node/8370321692
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Basta Cafe$nm$,
  'OpenStreetMap',
  $ad$50 T. Gener Street, Quezon City$ad$,
  14.6273176,
  121.0364347,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"23:00"},"sat":{"kind":"open","open":"10:00","close":"23:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Basta Cafe$nm$))
    and abs(s.latitude - 14.6273176) < 0.00045
    and abs(s.longitude - 121.0364347) < 0.00045
);

-- node/9785549707
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Belfry Café$nm$,
  'OpenStreetMap',
  $ad$Cabildo Street, Metro Manila$ad$,
  14.5919097,
  120.973632,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"09:00","close":"22:00"},"sun":{"kind":"open","open":"09:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 926 628 7133$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Belfry Café$nm$))
    and abs(s.latitude - 14.5919097) < 0.00045
    and abs(s.longitude - 120.973632) < 0.00045
);

-- node/11493728669
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Betty’s Sans Rival$nm$,
  'OpenStreetMap',
  $ad$M. Cuenco Sr. Street, Metro Manila$ad$,
  14.6269346,
  121.0082506,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"19:00"},"tue":{"kind":"open","open":"10:00","close":"19:00"},"wed":{"kind":"open","open":"10:00","close":"19:00"},"thu":{"kind":"open","open":"10:00","close":"19:00"},"fri":{"kind":"open","open":"10:00","close":"19:00"},"sat":{"kind":"open","open":"10:00","close":"19:00"},"sun":{"kind":"open","open":"10:00","close":"19:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Betty’s Sans Rival$nm$))
    and abs(s.latitude - 14.6269346) < 0.00045
    and abs(s.longitude - 121.0082506) < 0.00045
);

-- node/12798119981
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Big Brew$nm$,
  'OpenStreetMap',
  $ad$Karuhatan Road, Valenzuela$ad$,
  14.6894162,
  120.9767307,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Big Brew$nm$))
    and abs(s.latitude - 14.6894162) < 0.00045
    and abs(s.longitude - 120.9767307) < 0.00045
);

-- node/12193962243
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Big Brew Malabon$nm$,
  'OpenStreetMap',
  $ad$Rizal Avenue Extension, Malabon$ad$,
  14.658738,
  120.9524701,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Big Brew Malabon$nm$))
    and abs(s.latitude - 14.658738) < 0.00045
    and abs(s.longitude - 120.9524701) < 0.00045
);

-- node/12175836139
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Bikes & Coffee Manila$nm$,
  'OpenStreetMap',
  $ad$Uptown Parade, Metro Manila$ad$,
  14.5573215,
  121.0547104,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"18:00"},"tue":{"kind":"open","open":"09:00","close":"18:00"},"wed":{"kind":"open","open":"09:00","close":"18:00"},"thu":{"kind":"open","open":"09:00","close":"18:00"},"fri":{"kind":"open","open":"09:00","close":"19:00"},"sat":{"kind":"open","open":"08:00","close":"19:00"},"sun":{"kind":"open","open":"08:00","close":"19:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Bikes & Coffee Manila$nm$))
    and abs(s.latitude - 14.5573215) < 0.00045
    and abs(s.longitude - 121.0547104) < 0.00045
);

-- node/1324283411
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Bistro Ravioli$nm$,
  'OpenStreetMap',
  $ad$Ocean Drive, North Wing, Pasay$ad$,
  14.5363466,
  120.9812592,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 2 8040577$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Bistro Ravioli$nm$))
    and abs(s.latitude - 14.5363466) < 0.00045
    and abs(s.longitude - 120.9812592) < 0.00045
);

-- node/10000733974
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Bizu Le Petit Café at MiraNila$nm$,
  'OpenStreetMap',
  $ad$26 Mariposa Street, Quezon City$ad$,
  14.6117448,
  121.049858,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 2 8562 5098$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Bizu Le Petit Café at MiraNila$nm$))
    and abs(s.latitude - 14.6117448) < 0.00045
    and abs(s.longitude - 121.049858) < 0.00045
);

-- node/3361731193
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Black Scoop Cafe$nm$,
  'OpenStreetMap',
  $ad$BF Resort Drive, Las Piñas$ad$,
  14.4328061,
  120.9901463,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"00:00"},"tue":{"kind":"open","open":"10:00","close":"00:00"},"wed":{"kind":"open","open":"10:00","close":"00:00"},"thu":{"kind":"open","open":"10:00","close":"00:00"},"fri":{"kind":"open","open":"10:00","close":"00:00"},"sat":{"kind":"open","open":"10:00","close":"00:00"},"sun":{"kind":"open","open":"10:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Black Scoop Cafe$nm$))
    and abs(s.latitude - 14.4328061) < 0.00045
    and abs(s.longitude - 120.9901463) < 0.00045
);

-- way/872300358
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$BM Street Cafe$nm$,
  'OpenStreetMap',
  $ad$25 Bronze Street, Marikina$ad$,
  14.6401523,
  121.1154272,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"16:00","close":"22:00"},"wed":{"kind":"open","open":"16:00","close":"22:00"},"thu":{"kind":"open","open":"16:00","close":"22:00"},"fri":{"kind":"open","open":"16:00","close":"22:00"},"sat":{"kind":"open","open":"16:00","close":"22:00"},"sun":{"kind":"open","open":"16:00","close":"22:00"}}$hr$::jsonb,
  $ph$0936 943 7956$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$BM Street Cafe$nm$))
    and abs(s.latitude - 14.6401523) < 0.00045
    and abs(s.longitude - 121.1154272) < 0.00045
);

-- node/13666251287
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$BoardBrew$nm$,
  'OpenStreetMap',
  $ad$5 2353 Taft Avenue, Manila$ad$,
  14.565842,
  120.9932047,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"02:00"},"tue":{"kind":"open","open":"09:00","close":"02:00"},"wed":{"kind":"open","open":"09:00","close":"02:00"},"thu":{"kind":"open","open":"09:00","close":"02:00"},"fri":{"kind":"open","open":"09:00","close":"02:00"},"sat":{"kind":"open","open":"09:00","close":"02:00"},"sun":{"kind":"open","open":"09:00","close":"02:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$BoardBrew$nm$))
    and abs(s.latitude - 14.565842) < 0.00045
    and abs(s.longitude - 120.9932047) < 0.00045
);

-- node/11747395869
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Brioso Coffee$nm$,
  'OpenStreetMap',
  $ad$A. Arnaiz Avenue, The Beacon, Makati City$ad$,
  14.5516534,
  121.0138417,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:30","close":"00:30"},"tue":{"kind":"open","open":"08:30","close":"00:30"},"wed":{"kind":"open","open":"08:30","close":"00:30"},"thu":{"kind":"open","open":"08:30","close":"00:30"},"fri":{"kind":"open","open":"08:30","close":"00:30"},"sat":{"kind":"open","open":"08:30","close":"00:30"},"sun":{"kind":"open","open":"08:30","close":"00:30"}}$hr$::jsonb,
  $ph$+63 927 365 1307$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Brioso Coffee$nm$))
    and abs(s.latitude - 14.5516534) < 0.00045
    and abs(s.longitude - 121.0138417) < 0.00045
);

-- node/11370725572
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Buttery & Co$nm$,
  'OpenStreetMap',
  $ad$104 Katipunan Avenue, Metro Manila$ad$,
  14.6091945,
  121.0708176,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Buttery & Co$nm$))
    and abs(s.latitude - 14.6091945) < 0.00045
    and abs(s.longitude - 121.0708176) < 0.00045
);

-- way/1086829026
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cafe 1911$nm$,
  'OpenStreetMap',
  $ad$1911 Captain M. Reyes Street, Makati$ad$,
  14.5420104,
  121.010968,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cafe 1911$nm$))
    and abs(s.latitude - 14.5420104) < 0.00045
    and abs(s.longitude - 121.010968) < 0.00045
);

-- node/10056160307
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cafe Aroma$nm$,
  'OpenStreetMap',
  $ad$Pasig Boulevard, East Tower, Pasig$ad$,
  14.5692634,
  121.0673931,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"open","open":"07:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cafe Aroma$nm$))
    and abs(s.latitude - 14.5692634) < 0.00045
    and abs(s.longitude - 121.0673931) < 0.00045
);

-- node/1236157657
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cafe Bonjour$nm$,
  'OpenStreetMap',
  $ad$Commerce Avenue, Muntinlupa$ad$,
  14.4212866,
  121.0334873,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cafe Bonjour$nm$))
    and abs(s.latitude - 14.4212866) < 0.00045
    and abs(s.longitude - 121.0334873) < 0.00045
);

-- node/10121140046
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cafe Oasis$nm$,
  'OpenStreetMap',
  $ad$Pasig Boulevard Extension, Pasig$ad$,
  14.5661772,
  121.07635,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"23:00"},"tue":{"kind":"open","open":"11:00","close":"23:00"},"wed":{"kind":"open","open":"11:00","close":"23:00"},"thu":{"kind":"open","open":"11:00","close":"23:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  $ph$+63 9763197146$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cafe Oasis$nm$))
    and abs(s.latitude - 14.5661772) < 0.00045
    and abs(s.longitude - 121.07635) < 0.00045
);

-- node/12070158798
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cafe Oasis - Mercedes Ave$nm$,
  'OpenStreetMap',
  $ad$4 1407 Mercedes Avenue, Casa Enrica, Pasig$ad$,
  14.5693021,
  121.084176,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"13:00","close":"22:30"},"tue":{"kind":"closed"},"wed":{"kind":"closed"},"thu":{"kind":"closed"},"fri":{"kind":"closed"},"sat":{"kind":"closed"},"sun":{"kind":"open","open":"13:00","close":"22:30"}}$hr$::jsonb,
  $ph$+639763197146$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cafe Oasis - Mercedes Ave$nm$))
    and abs(s.latitude - 14.5693021) < 0.00045
    and abs(s.longitude - 121.084176) < 0.00045
);

-- node/5869715985
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cafe Oley$nm$,
  'OpenStreetMap',
  $ad$Malakas Street, Metro Manila$ad$,
  14.6384116,
  121.0484412,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"20:00"},"sun":{"kind":"open","open":"11:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cafe Oley$nm$))
    and abs(s.latitude - 14.6384116) < 0.00045
    and abs(s.longitude - 121.0484412) < 0.00045
);

-- node/10025843798
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Caffera Photo + Café$nm$,
  'OpenStreetMap',
  $ad$480 Boni Avenue, Metro Manila$ad$,
  14.5817314,
  121.0289294,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:00","close":"00:00"},"tue":{"kind":"open","open":"12:00","close":"00:00"},"wed":{"kind":"open","open":"12:00","close":"00:00"},"thu":{"kind":"open","open":"12:00","close":"00:00"},"fri":{"kind":"open","open":"12:00","close":"00:00"},"sat":{"kind":"open","open":"12:00","close":"00:00"},"sun":{"kind":"open","open":"12:00","close":"00:00"}}$hr$::jsonb,
  $ph$+639088172013$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Caffera Photo + Café$nm$))
    and abs(s.latitude - 14.5817314) < 0.00045
    and abs(s.longitude - 121.0289294) < 0.00045
);

-- node/12663629207
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Café Arabella$nm$,
  'OpenStreetMap',
  $ad$A 27 Alcalde Jose Street, Metro Manila$ad$,
  14.5615192,
  121.0745754,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"09:00","close":"22:00"},"sun":{"kind":"open","open":"09:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Café Arabella$nm$))
    and abs(s.latitude - 14.5615192) < 0.00045
    and abs(s.longitude - 121.0745754) < 0.00045
);

-- node/12000028363
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Café Belmont$nm$,
  'OpenStreetMap',
  $ad$Belmont Hotel, Metro Manila$ad$,
  14.5206824,
  121.0165292,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"22:00"},"tue":{"kind":"open","open":"06:00","close":"22:00"},"wed":{"kind":"open","open":"06:00","close":"22:00"},"thu":{"kind":"open","open":"06:00","close":"22:00"},"fri":{"kind":"open","open":"06:00","close":"22:00"},"sat":{"kind":"open","open":"06:00","close":"22:00"},"sun":{"kind":"open","open":"06:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Café Belmont$nm$))
    and abs(s.latitude - 14.5206824) < 0.00045
    and abs(s.longitude - 121.0165292) < 0.00045
);

-- node/6585457387
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Café France$nm$,
  'OpenStreetMap',
  $ad$United Nations Avenue, Metro Manila$ad$,
  14.5835668,
  120.9872371,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"open","open":"07:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Café France$nm$))
    and abs(s.latitude - 14.5835668) < 0.00045
    and abs(s.longitude - 120.9872371) < 0.00045
);

-- node/8911345746
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Café Mabini$nm$,
  'OpenStreetMap',
  $ad$A. Mabini Street, Francesco's Kitchen, Metro Manila$ad$,
  14.5929125,
  121.0412249,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"21:00"},"sun":{"kind":"open","open":"08:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Café Mabini$nm$))
    and abs(s.latitude - 14.5929125) < 0.00045
    and abs(s.longitude - 121.0412249) < 0.00045
);

-- node/12801684103
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cake Muncher Manila$nm$,
  'OpenStreetMap',
  $ad$5415 44 Champaca Street, Spazio Bernardo, Quezon City$ad$,
  14.6907042,
  121.0325788,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:30","close":"22:00"},"tue":{"kind":"open","open":"12:30","close":"22:00"},"wed":{"kind":"open","open":"12:30","close":"22:00"},"thu":{"kind":"open","open":"12:30","close":"22:00"},"fri":{"kind":"open","open":"12:30","close":"22:00"},"sat":{"kind":"open","open":"12:30","close":"22:00"},"sun":{"kind":"open","open":"12:30","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cake Muncher Manila$nm$))
    and abs(s.latitude - 14.6907042) < 0.00045
    and abs(s.longitude - 121.0325788) < 0.00045
);

-- node/1398950211
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cassalu$nm$,
  'OpenStreetMap',
  $ad$262 Alabang-Zapote Road, South Park Highs Commercial Complex, Las Piñas$ad$,
  14.4481059,
  120.984144,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"23:00"},"tue":{"kind":"open","open":"08:00","close":"23:00"},"wed":{"kind":"open","open":"08:00","close":"23:00"},"thu":{"kind":"open","open":"08:00","close":"23:00"},"fri":{"kind":"open","open":"08:00","close":"23:00"},"sat":{"kind":"open","open":"08:00","close":"23:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cassalu$nm$))
    and abs(s.latitude - 14.4481059) < 0.00045
    and abs(s.longitude - 120.984144) < 0.00045
);

-- node/13666254846
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cha Tien Tang$nm$,
  'OpenStreetMap',
  $ad$2339 Taft Avenue, Metro Manila$ad$,
  14.5660199,
  120.9931085,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:00"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"11:00","close":"21:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cha Tien Tang$nm$))
    and abs(s.latitude - 14.5660199) < 0.00045
    and abs(s.longitude - 120.9931085) < 0.00045
);

-- node/7866991828
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Chachago$nm$,
  'OpenStreetMap',
  $ad$330 Aguirre Avenue, Metro Manila$ad$,
  14.4563107,
  121.0083931,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:30"},"tue":{"kind":"open","open":"11:00","close":"21:30"},"wed":{"kind":"open","open":"11:00","close":"21:30"},"thu":{"kind":"open","open":"11:00","close":"21:30"},"fri":{"kind":"open","open":"11:00","close":"21:30"},"sat":{"kind":"open","open":"11:00","close":"21:30"},"sun":{"kind":"open","open":"11:00","close":"21:30"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Chachago$nm$))
    and abs(s.latitude - 14.4563107) < 0.00045
    and abs(s.longitude - 121.0083931) < 0.00045
);

-- way/1442775976
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Chapter Coffee Roastery & Cafe$nm$,
  'OpenStreetMap',
  $ad$365 P. Guevarra Street, Chapter Coffee Roastery & Cafe, Metro Manila$ad$,
  14.5938583,
  121.0370216,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"21:00"},"sun":{"kind":"open","open":"08:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Chapter Coffee Roastery & Cafe$nm$))
    and abs(s.latitude - 14.5938583) < 0.00045
    and abs(s.longitude - 121.0370216) < 0.00045
);

-- node/4420026882
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Chatime$nm$,
  'OpenStreetMap',
  $ad$Marcos Highway, SM City Marikina, Marikina$ad$,
  14.6259237,
  121.0840797,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"21:00"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"21:00"},"sat":{"kind":"open","open":"10:00","close":"21:00"},"sun":{"kind":"open","open":"10:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Chatime$nm$))
    and abs(s.latitude - 14.6259237) < 0.00045
    and abs(s.longitude - 121.0840797) < 0.00045
);

-- node/3239090332
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Chemistea Milk Tea + Cafe$nm$,
  'OpenStreetMap',
  $ad$44 Short Horn Street, Quezon City$ad$,
  14.6669941,
  121.0212523,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 2 455 2541$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Chemistea Milk Tea + Cafe$nm$))
    and abs(s.latitude - 14.6669941) < 0.00045
    and abs(s.longitude - 121.0212523) < 0.00045
);

-- node/4463061289
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Claudine's Homemade Classics$nm$,
  'OpenStreetMap',
  $ad$33 Hamburg, Metro Manila$ad$,
  14.4916239,
  121.0233406,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"09:00","close":"22:00"},"sun":{"kind":"open","open":"09:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 917 532 2300$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Claudine's Homemade Classics$nm$))
    and abs(s.latitude - 14.4916239) < 0.00045
    and abs(s.longitude - 121.0233406) < 0.00045
);

-- node/5313870163
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$CoCo Fresh Tea & Juice$nm$,
  'OpenStreetMap',
  $ad$Unit 14A, Cluster 2 Madrigal Avenue, Molito Lifestyle Center, Building 5, Muntinlupa$ad$,
  14.4242796,
  121.0266918,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$CoCo Fresh Tea & Juice$nm$))
    and abs(s.latitude - 14.4242796) < 0.00045
    and abs(s.longitude - 121.0266918) < 0.00045
);

-- node/13674119669
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Coffee & Vinyl$nm$,
  'OpenStreetMap',
  $ad$GoodLife Bldg 182 11th Avenue, Metro Manila$ad$,
  14.6529792,
  120.9855229,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"14:00","close":"23:00"},"tue":{"kind":"open","open":"13:00","close":"23:00"},"wed":{"kind":"open","open":"13:00","close":"23:00"},"thu":{"kind":"open","open":"13:00","close":"23:00"},"fri":{"kind":"open","open":"13:00","close":"23:00"},"sat":{"kind":"open","open":"13:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Coffee & Vinyl$nm$))
    and abs(s.latitude - 14.6529792) < 0.00045
    and abs(s.longitude - 120.9855229) < 0.00045
);

-- node/14133671677
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Coffee : Life @32nd$nm$,
  'OpenStreetMap',
  $ad$32nd Street, Ecoprime Tower, Taguig$ad$,
  14.5531272,
  121.0526006,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Coffee : Life @32nd$nm$))
    and abs(s.latitude - 14.5531272) < 0.00045
    and abs(s.longitude - 121.0526006) < 0.00045
);

-- node/12924971709
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Coffee Blanc$nm$,
  'OpenStreetMap',
  $ad$The Portal, Metro Manila$ad$,
  14.5790496,
  121.053742,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"00:00"},"tue":{"kind":"open","open":"08:00","close":"00:00"},"wed":{"kind":"open","open":"08:00","close":"00:00"},"thu":{"kind":"open","open":"08:00","close":"00:00"},"fri":{"kind":"open","open":"08:00","close":"00:00"},"sat":{"kind":"open","open":"08:00","close":"02:30"},"sun":{"kind":"open","open":"08:00","close":"02:30"}}$hr$::jsonb,
  $ph$+639171362986$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Coffee Blanc$nm$))
    and abs(s.latitude - 14.5790496) < 0.00045
    and abs(s.longitude - 121.053742) < 0.00045
);

-- node/3159878101
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Coffee Project$nm$,
  'OpenStreetMap',
  $ad$Daang Hari, Evia Lifestyle Center, Las Piñas$ad$,
  14.3760001,
  121.0120245,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Coffee Project$nm$))
    and abs(s.latitude - 14.3760001) < 0.00045
    and abs(s.longitude - 121.0120245) < 0.00045
);

-- node/6000718206
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Coffee Project$nm$,
  'OpenStreetMap',
  $ad$East Service Road, Muntinlupa$ad$,
  14.456818,
  121.0457712,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  $ph$+639099416381$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Coffee Project$nm$))
    and abs(s.latitude - 14.456818) < 0.00045
    and abs(s.longitude - 121.0457712) < 0.00045
);

-- node/5805323853
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Coffee Project$nm$,
  'OpenStreetMap',
  $ad$Sergeant Esguerra Avenue, Quezon City$ad$,
  14.6340159,
  121.0415444,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"open","open":"07:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Coffee Project$nm$))
    and abs(s.latitude - 14.6340159) < 0.00045
    and abs(s.longitude - 121.0415444) < 0.00045
);

-- node/10951681908
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Coffee Spot$nm$,
  'OpenStreetMap',
  $ad$BF Resort Drive corner Gemma Cruz Street, Las Piñas$ad$,
  14.4431138,
  120.9925055,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"23:00"},"tue":{"kind":"open","open":"08:00","close":"23:00"},"wed":{"kind":"open","open":"08:00","close":"23:00"},"thu":{"kind":"open","open":"08:00","close":"23:00"},"fri":{"kind":"open","open":"08:00","close":"23:00"},"sat":{"kind":"open","open":"08:00","close":"23:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  $ph$+63 2 7005 8347$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Coffee Spot$nm$))
    and abs(s.latitude - 14.4431138) < 0.00045
    and abs(s.longitude - 120.9925055) < 0.00045
);

-- node/6215504585
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Coffee Spot$nm$,
  'OpenStreetMap',
  $ad$144 Ilocos Norte Street, Metro Manila$ad$,
  14.6608838,
  121.0249723,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Coffee Spot$nm$))
    and abs(s.latitude - 14.6608838) < 0.00045
    and abs(s.longitude - 121.0249723) < 0.00045
);

-- node/13502768463
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Coffee Tate$nm$,
  'OpenStreetMap',
  $ad$174 Villongco Street, Quezon City$ad$,
  14.697622,
  121.0838329,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"00:00"},"tue":{"kind":"open","open":"11:00","close":"00:00"},"wed":{"kind":"open","open":"11:00","close":"00:00"},"thu":{"kind":"open","open":"11:00","close":"00:00"},"fri":{"kind":"open","open":"11:00","close":"00:00"},"sat":{"kind":"open","open":"11:00","close":"00:00"},"sun":{"kind":"open","open":"11:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Coffee Tate$nm$))
    and abs(s.latitude - 14.697622) < 0.00045
    and abs(s.longitude - 121.0838329) < 0.00045
);

-- node/9776257231
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Coffee Tonya$nm$,
  'OpenStreetMap',
  $ad$4970 P. Guanzon Street, Makati City$ad$,
  14.5657635,
  121.0305475,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"21:00"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"00:00"},"sat":{"kind":"open","open":"10:00","close":"00:00"},"sun":{"kind":"open","open":"11:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63288995410$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Coffee Tonya$nm$))
    and abs(s.latitude - 14.5657635) < 0.00045
    and abs(s.longitude - 121.0305475) < 0.00045
);

-- node/12174512308
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cole & Co. Studio Café$nm$,
  'OpenStreetMap',
  $ad$V. Cruz Street, Twelve, Metro Manila$ad$,
  14.598455,
  121.0378093,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"21:00"},"sun":{"kind":"open","open":"08:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cole & Co. Studio Café$nm$))
    and abs(s.latitude - 14.598455) < 0.00045
    and abs(s.longitude - 121.0378093) < 0.00045
);

-- node/10177459817
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Colobaba Cafe$nm$,
  'OpenStreetMap',
  $ad$Taft Avenue, Metro Manila$ad$,
  14.5668294,
  120.9934561,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Colobaba Cafe$nm$))
    and abs(s.latitude - 14.5668294) < 0.00045
    and abs(s.longitude - 120.9934561) < 0.00045
);

-- node/1068757292
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Common Man Coffee Roasters$nm$,
  'OpenStreetMap',
  $ad$Makati Avenue, Ayala Triangle Gardens, Makati$ad$,
  14.5565372,
  121.0235931,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 927 139 5304$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Common Man Coffee Roasters$nm$))
    and abs(s.latitude - 14.5565372) < 0.00045
    and abs(s.longitude - 121.0235931) < 0.00045
);

-- node/5040106327
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$communeph$nm$,
  'OpenStreetMap',
  $ad$36 Polaris Street, Makati$ad$,
  14.5626377,
  121.0301249,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"00:00"},"tue":{"kind":"open","open":"08:00","close":"00:00"},"wed":{"kind":"open","open":"08:00","close":"00:00"},"thu":{"kind":"open","open":"08:00","close":"00:00"},"fri":{"kind":"open","open":"08:00","close":"01:00"},"sat":{"kind":"open","open":"08:00","close":"01:00"},"sun":{"kind":"open","open":"09:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 9198595848$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$communeph$nm$))
    and abs(s.latitude - 14.5626377) < 0.00045
    and abs(s.longitude - 121.0301249) < 0.00045
);

-- node/2794011157
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cool Beans Café$nm$,
  'OpenStreetMap',
  $ad$67-A Maginhawa Street, Metro Manila$ad$,
  14.647719,
  121.0573901,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"23:00"},"tue":{"kind":"open","open":"11:00","close":"23:00"},"wed":{"kind":"open","open":"11:00","close":"23:00"},"thu":{"kind":"open","open":"11:00","close":"23:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  $ph$+639177064711$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cool Beans Café$nm$))
    and abs(s.latitude - 14.647719) < 0.00045
    and abs(s.longitude - 121.0573901) < 0.00045
);

-- node/6148928387
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cool-In Coffee Shop$nm$,
  'OpenStreetMap',
  $ad$287 San Vicente Street, Metro Manila$ad$,
  14.5980411,
  120.9776668,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:30","close":"18:00"},"tue":{"kind":"open","open":"07:30","close":"18:00"},"wed":{"kind":"open","open":"07:30","close":"18:00"},"thu":{"kind":"open","open":"07:30","close":"18:00"},"fri":{"kind":"open","open":"07:30","close":"18:00"},"sat":{"kind":"open","open":"07:30","close":"18:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cool-In Coffee Shop$nm$))
    and abs(s.latitude - 14.5980411) < 0.00045
    and abs(s.longitude - 120.9776668) < 0.00045
);

-- node/14142181831
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Coopers Coffee Haus$nm$,
  'OpenStreetMap',
  $ad$Bonifacio South Street, Taguig$ad$,
  14.5479842,
  121.0518468,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  $ph$09692713319$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Coopers Coffee Haus$nm$))
    and abs(s.latitude - 14.5479842) < 0.00045
    and abs(s.longitude - 121.0518468) < 0.00045
);

-- node/5625878661
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Costa Coffee$nm$,
  'OpenStreetMap',
  $ad$2447 ADB Avenue, Robinsons Galleria, Quezon City$ad$,
  14.590274,
  121.06049,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"23:00"},"tue":{"kind":"open","open":"08:00","close":"23:00"},"wed":{"kind":"open","open":"08:00","close":"23:00"},"thu":{"kind":"open","open":"08:00","close":"23:00"},"fri":{"kind":"open","open":"08:00","close":"23:00"},"sat":{"kind":"open","open":"08:00","close":"23:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  $ph$+63 2 631 8604$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Costa Coffee$nm$))
    and abs(s.latitude - 14.590274) < 0.00045
    and abs(s.longitude - 121.06049) < 0.00045
);

-- node/950619451
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Costa Coffee$nm$,
  'OpenStreetMap',
  $ad$Eastwood Avenue, Eastwood City Walk 1, Quezon City$ad$,
  14.6088494,
  121.0804572,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"23:00"},"tue":{"kind":"open","open":"07:00","close":"23:00"},"wed":{"kind":"open","open":"07:00","close":"23:00"},"thu":{"kind":"open","open":"07:00","close":"23:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"open","open":"08:00","close":"00:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Costa Coffee$nm$))
    and abs(s.latitude - 14.6088494) < 0.00045
    and abs(s.longitude - 121.0804572) < 0.00045
);

-- node/12716380465
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cotti Coffee$nm$,
  'OpenStreetMap',
  $ad$Opal Road, Pasig$ad$,
  14.5871412,
  121.0601896,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cotti Coffee$nm$))
    and abs(s.latitude - 14.5871412) < 0.00045
    and abs(s.longitude - 121.0601896) < 0.00045
);

-- node/14050313102
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Craft Coffee Roastery$nm$,
  'OpenStreetMap',
  $ad$SM North EDSA, Quezon City$ad$,
  14.6554788,
  121.0322597,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Craft Coffee Roastery$nm$))
    and abs(s.latitude - 14.6554788) < 0.00045
    and abs(s.longitude - 121.0322597) < 0.00045
);

-- node/4212325392
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Cristopiy$nm$,
  'OpenStreetMap',
  $ad$1100 R. S. Cristobal Street, Metro Manila$ad$,
  14.6145351,
  120.9934886,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:00","close":"23:00"},"tue":{"kind":"open","open":"12:00","close":"23:00"},"wed":{"kind":"open","open":"12:00","close":"23:00"},"thu":{"kind":"open","open":"12:00","close":"23:00"},"fri":{"kind":"open","open":"12:00","close":"23:00"},"sat":{"kind":"open","open":"12:00","close":"23:00"},"sun":{"kind":"open","open":"12:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Cristopiy$nm$))
    and abs(s.latitude - 14.6145351) < 0.00045
    and abs(s.longitude - 120.9934886) < 0.00045
);

-- node/12185993775
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Curious Coffee Co$nm$,
  'OpenStreetMap',
  $ad$2nd Floor 330 Aguirre Avenue, Metro Manila$ad$,
  14.4564003,
  121.0080899,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"09:00","close":"22:00"},"sun":{"kind":"open","open":"09:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Curious Coffee Co$nm$))
    and abs(s.latitude - 14.4564003) < 0.00045
    and abs(s.longitude - 121.0080899) < 0.00045
);

-- node/4755621644
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Dakasi$nm$,
  'OpenStreetMap',
  $ad$Leon Guinto Street, Metro Manila$ad$,
  14.5651517,
  120.9950889,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:00"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"11:00","close":"21:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"open","open":"11:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Dakasi$nm$))
    and abs(s.latitude - 14.5651517) < 0.00045
    and abs(s.longitude - 120.9950889) < 0.00045
);

-- node/11534210700
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Degree C$nm$,
  'OpenStreetMap',
  $ad$10, BSA Commercial Building, Metro Manila$ad$,
  14.5912531,
  121.0324421,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"20:00"},"tue":{"kind":"open","open":"11:00","close":"20:00"},"wed":{"kind":"open","open":"11:00","close":"20:00"},"thu":{"kind":"open","open":"11:00","close":"20:00"},"fri":{"kind":"open","open":"11:00","close":"20:00"},"sat":{"kind":"open","open":"11:00","close":"20:00"},"sun":{"kind":"open","open":"11:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Degree C$nm$))
    and abs(s.latitude - 14.5912531) < 0.00045
    and abs(s.longitude - 121.0324421) < 0.00045
);

-- node/12842140517
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Deja Brew by Brisbane Street Cafe$nm$,
  'OpenStreetMap',
  $ad$B1 L1, Caloocan$ad$,
  14.7679139,
  121.080185,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:00"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"11:00","close":"21:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+63 969 239 8887$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Deja Brew by Brisbane Street Cafe$nm$))
    and abs(s.latitude - 14.7679139) < 0.00045
    and abs(s.longitude - 121.080185) < 0.00045
);

-- node/11288583766
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Do Güd Cafe$nm$,
  'OpenStreetMap',
  $ad$9 E. Rodriguez Street, Metro Manila$ad$,
  14.6596907,
  121.1108247,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"closed"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Do Güd Cafe$nm$))
    and abs(s.latitude - 14.6596907) < 0.00045
    and abs(s.longitude - 121.1108247) < 0.00045
);

-- node/10203040311
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Dot Coffee$nm$,
  'OpenStreetMap',
  $ad$Missouri Street, San Juan$ad$,
  14.6022594,
  121.0517049,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"23:00"},"tue":{"kind":"open","open":"07:00","close":"23:00"},"wed":{"kind":"open","open":"07:00","close":"23:00"},"thu":{"kind":"open","open":"07:00","close":"23:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Dot Coffee$nm$))
    and abs(s.latitude - 14.6022594) < 0.00045
    and abs(s.longitude - 121.0517049) < 0.00045
);

-- node/8354027252
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Dough Days$nm$,
  'OpenStreetMap',
  $ad$344 Tullahan Road, Santa Quiteria/Talipapa$ad$,
  14.6835228,
  121.0059665,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"14:00","close":"17:00"},"tue":{"kind":"open","open":"14:00","close":"17:00"},"wed":{"kind":"open","open":"14:00","close":"17:00"},"thu":{"kind":"open","open":"14:00","close":"17:00"},"fri":{"kind":"open","open":"14:00","close":"17:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Dough Days$nm$))
    and abs(s.latitude - 14.6835228) < 0.00045
    and abs(s.longitude - 121.0059665) < 0.00045
);

-- node/11365940489
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Drip Kofi$nm$,
  'OpenStreetMap',
  $ad$Taft Avenue, Burgundy Transpacific Place, Metro Manila$ad$,
  14.565191,
  120.9943866,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"00:00"},"tue":{"kind":"open","open":"08:00","close":"00:00"},"wed":{"kind":"open","open":"08:00","close":"00:00"},"thu":{"kind":"open","open":"08:00","close":"00:00"},"fri":{"kind":"open","open":"08:00","close":"00:00"},"sat":{"kind":"open","open":"08:00","close":"00:00"},"sun":{"kind":"open","open":"08:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Drip Kofi$nm$))
    and abs(s.latitude - 14.565191) < 0.00045
    and abs(s.longitude - 120.9943866) < 0.00045
);

-- node/10279199461
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Duke's Castle Cafe$nm$,
  'OpenStreetMap',
  $ad$Padre Campa Street, Metro Manila$ad$,
  14.608111,
  120.9861626,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"00:00"},"tue":{"kind":"open","open":"10:00","close":"00:00"},"wed":{"kind":"open","open":"10:00","close":"00:00"},"thu":{"kind":"open","open":"10:00","close":"00:00"},"fri":{"kind":"open","open":"10:00","close":"00:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+639976831545$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Duke's Castle Cafe$nm$))
    and abs(s.latitude - 14.608111) < 0.00045
    and abs(s.longitude - 120.9861626) < 0.00045
);

-- node/12759190601
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Dunkin'$nm$,
  'OpenStreetMap',
  $ad$Camarin Road, Metro Manila$ad$,
  14.7475077,
  121.0363121,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Dunkin'$nm$))
    and abs(s.latitude - 14.7475077) < 0.00045
    and abs(s.longitude - 121.0363121) < 0.00045
);

-- node/13681259558
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Dunkin’$nm$,
  'OpenStreetMap',
  $ad$Evacom Avenue, Parañaque$ad$,
  14.4747285,
  121.0004116,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Dunkin’$nm$))
    and abs(s.latitude - 14.4747285) < 0.00045
    and abs(s.longitude - 121.0004116) < 0.00045
);

-- node/7574592374
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Eng Ho Cafe & Deli$nm$,
  'OpenStreetMap',
  $ad$629 T. Alonzo Street, Metro Manila$ad$,
  14.6023647,
  120.9787674,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"19:00"},"tue":{"kind":"open","open":"08:00","close":"19:00"},"wed":{"kind":"open","open":"08:00","close":"19:00"},"thu":{"kind":"open","open":"08:00","close":"19:00"},"fri":{"kind":"open","open":"08:00","close":"19:00"},"sat":{"kind":"open","open":"08:00","close":"19:00"},"sun":{"kind":"open","open":"08:00","close":"19:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Eng Ho Cafe & Deli$nm$))
    and abs(s.latitude - 14.6023647) < 0.00045
    and abs(s.longitude - 120.9787674) < 0.00045
);

-- node/13019012134
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$eskinita knl$nm$,
  'OpenStreetMap',
  $ad$39 B B. Baluyot Street, Metro Manila$ad$,
  14.6468794,
  121.0620704,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$eskinita knl$nm$))
    and abs(s.latitude - 14.6468794) < 0.00045
    and abs(s.longitude - 121.0620704) < 0.00045
);

-- node/12815884501
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Espresso Studio$nm$,
  'OpenStreetMap',
  $ad$Williams Street, Metro Manila$ad$,
  14.5762909,
  121.053406,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"22:00"},"tue":{"kind":"open","open":"06:00","close":"22:00"},"wed":{"kind":"open","open":"06:00","close":"22:00"},"thu":{"kind":"open","open":"06:00","close":"22:00"},"fri":{"kind":"open","open":"06:00","close":"22:00"},"sat":{"kind":"open","open":"06:00","close":"22:00"},"sun":{"kind":"open","open":"06:00","close":"22:00"}}$hr$::jsonb,
  $ph$+639165245624$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Espresso Studio$nm$))
    and abs(s.latitude - 14.5762909) < 0.00045
    and abs(s.longitude - 121.053406) < 0.00045
);

-- way/315599050
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Estratto Manila Coffee Shop$nm$,
  'OpenStreetMap',
  $ad$811 G. de Borja Street, Pateros$ad$,
  14.5420588,
  121.063057,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:00","close":"21:00"},"tue":{"kind":"open","open":"12:00","close":"21:00"},"wed":{"kind":"open","open":"12:00","close":"21:00"},"thu":{"kind":"open","open":"12:00","close":"21:00"},"fri":{"kind":"open","open":"12:00","close":"21:00"},"sat":{"kind":"open","open":"12:00","close":"21:00"},"sun":{"kind":"open","open":"12:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Estratto Manila Coffee Shop$nm$))
    and abs(s.latitude - 14.5420588) < 0.00045
    and abs(s.longitude - 121.063057) < 0.00045
);

-- node/11365165249
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Family Bean Garden Cafe$nm$,
  'OpenStreetMap',
  $ad$Union Drive, Metro Manila$ad$,
  14.7622037,
  121.0279288,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Family Bean Garden Cafe$nm$))
    and abs(s.latitude - 14.7622037) < 0.00045
    and abs(s.longitude - 121.0279288) < 0.00045
);

-- way/247960719
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Fancy Crepes$nm$,
  'OpenStreetMap',
  $ad$40 Matalino Street, Quezon City$ad$,
  14.6452208,
  121.0528372,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"22:00"}}$hr$::jsonb,
  $ph$+632 990 4327$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Fancy Crepes$nm$))
    and abs(s.latitude - 14.6452208) < 0.00045
    and abs(s.longitude - 121.0528372) < 0.00045
);

-- node/3084081180
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Figaro$nm$,
  'OpenStreetMap',
  $ad$847 Banawe Street, Metro Manila$ad$,
  14.6375291,
  121.0009309,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Figaro$nm$))
    and abs(s.latitude - 14.6375291) < 0.00045
    and abs(s.longitude - 121.0009309) < 0.00045
);

-- node/3591122817
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$FILC Coffee + Pastries$nm$,
  'OpenStreetMap',
  $ad$130 GF Sunrise Drive, Sea Residences, Pasay$ad$,
  14.5344352,
  120.9857721,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"23:00"},"tue":{"kind":"open","open":"06:00","close":"23:00"},"wed":{"kind":"open","open":"06:00","close":"23:00"},"thu":{"kind":"open","open":"06:00","close":"23:00"},"fri":{"kind":"open","open":"06:00","close":"23:00"},"sat":{"kind":"open","open":"06:00","close":"23:00"},"sun":{"kind":"open","open":"06:00","close":"23:00"}}$hr$::jsonb,
  $ph$+639674398673$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$FILC Coffee + Pastries$nm$))
    and abs(s.latitude - 14.5344352) < 0.00045
    and abs(s.longitude - 120.9857721) < 0.00045
);

-- node/10170284060
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Founders Donut$nm$,
  'OpenStreetMap',
  $ad$Zobel Roxas Street, Makati$ad$,
  14.5646854,
  121.00192,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"20:00"},"tue":{"kind":"open","open":"09:00","close":"20:00"},"wed":{"kind":"open","open":"09:00","close":"20:00"},"thu":{"kind":"open","open":"09:00","close":"20:00"},"fri":{"kind":"open","open":"09:00","close":"20:00"},"sat":{"kind":"open","open":"09:00","close":"20:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+63945 882 5167$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Founders Donut$nm$))
    and abs(s.latitude - 14.5646854) < 0.00045
    and abs(s.longitude - 121.00192) < 0.00045
);

-- node/9372713533
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Four50 Café$nm$,
  'OpenStreetMap',
  $ad$450 General Vicente Lim Street, Metro Manila$ad$,
  14.6025423,
  121.0393954,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"10:00","close":"19:00"},"wed":{"kind":"open","open":"10:00","close":"19:00"},"thu":{"kind":"open","open":"10:00","close":"19:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+639661586915$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Four50 Café$nm$))
    and abs(s.latitude - 14.6025423) < 0.00045
    and abs(s.longitude - 121.0393954) < 0.00045
);

-- node/6581321331
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Gong Thai$nm$,
  'OpenStreetMap',
  $ad$69 M. H. del Pilar Road, Valenzuela$ad$,
  14.7158662,
  120.9533301,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 905 513 2572$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Gong Thai$nm$))
    and abs(s.latitude - 14.7158662) < 0.00045
    and abs(s.longitude - 120.9533301) < 0.00045
);

-- node/12642014301
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Good Mornings$nm$,
  'OpenStreetMap',
  $ad$Amang Rodriguez Avenue, Metro Manila$ad$,
  14.6147053,
  121.0921545,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"22:00"},"tue":{"kind":"open","open":"06:00","close":"22:00"},"wed":{"kind":"open","open":"06:00","close":"22:00"},"thu":{"kind":"open","open":"06:00","close":"22:00"},"fri":{"kind":"open","open":"06:00","close":"22:00"},"sat":{"kind":"open","open":"06:00","close":"22:00"},"sun":{"kind":"open","open":"06:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Good Mornings$nm$))
    and abs(s.latitude - 14.6147053) < 0.00045
    and abs(s.longitude - 121.0921545) < 0.00045
);

-- node/10201106917
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Good Sh*t Coffee$nm$,
  'OpenStreetMap',
  $ad$5872 Enriquez Street, Metro Manila$ad$,
  14.5642082,
  121.0319094,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"22:00"},"tue":{"kind":"open","open":"06:00","close":"22:00"},"wed":{"kind":"open","open":"06:00","close":"22:00"},"thu":{"kind":"open","open":"06:00","close":"22:00"},"fri":{"kind":"open","open":"06:00","close":"00:00"},"sat":{"kind":"open","open":"06:00","close":"00:00"},"sun":{"kind":"open","open":"06:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Good Sh*t Coffee$nm$))
    and abs(s.latitude - 14.5642082) < 0.00045
    and abs(s.longitude - 121.0319094) < 0.00045
);

-- node/12019776580
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Good Thing Coffee Company$nm$,
  'OpenStreetMap',
  $ad$MG Tower Ⅱ, Metro Manila$ad$,
  14.5904365,
  121.0336697,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:30","close":"23:30"},"tue":{"kind":"open","open":"08:30","close":"23:30"},"wed":{"kind":"open","open":"08:30","close":"23:30"},"thu":{"kind":"open","open":"08:30","close":"23:30"},"fri":{"kind":"open","open":"08:30","close":"23:30"},"sat":{"kind":"open","open":"06:30","close":"23:30"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+63976 407 7351$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Good Thing Coffee Company$nm$))
    and abs(s.latitude - 14.5904365) < 0.00045
    and abs(s.longitude - 121.0336697) < 0.00045
);

-- node/10075888065
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$GoodGood$nm$,
  'OpenStreetMap',
  $ad$Vatican City Drive, Las Piñas$ad$,
  14.4301586,
  120.9897609,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:00","close":"20:30"},"tue":{"kind":"open","open":"12:00","close":"20:30"},"wed":{"kind":"open","open":"12:00","close":"20:30"},"thu":{"kind":"open","open":"12:00","close":"20:30"},"fri":{"kind":"open","open":"12:00","close":"21:00"},"sat":{"kind":"open","open":"12:00","close":"21:00"},"sun":{"kind":"open","open":"12:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63 977 655 9513$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$GoodGood$nm$))
    and abs(s.latitude - 14.4301586) < 0.00045
    and abs(s.longitude - 120.9897609) < 0.00045
);

-- node/13962054863
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Gringo's - Sampaloc Manila$nm$,
  'OpenStreetMap',
  $ad$1902 J. Fajardo Street, Manila$ad$,
  14.6112799,
  120.9991461,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"01:00"},"tue":{"kind":"open","open":"10:00","close":"01:00"},"wed":{"kind":"open","open":"10:00","close":"01:00"},"thu":{"kind":"open","open":"10:00","close":"01:00"},"fri":{"kind":"open","open":"10:00","close":"01:00"},"sat":{"kind":"open","open":"10:00","close":"01:00"},"sun":{"kind":"open","open":"10:00","close":"01:00"}}$hr$::jsonb,
  $ph$+639382925247$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Gringo's - Sampaloc Manila$nm$))
    and abs(s.latitude - 14.6112799) < 0.00045
    and abs(s.longitude - 120.9991461) < 0.00045
);

-- node/12803663501
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Grotto Hookah Lounge$nm$,
  'OpenStreetMap',
  $ad$398 Cabildo Street, Metro Manila$ad$,
  14.5916991,
  120.974185,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"01:00"},"tue":{"kind":"open","open":"11:00","close":"01:00"},"wed":{"kind":"open","open":"11:00","close":"01:00"},"thu":{"kind":"open","open":"11:00","close":"01:00"},"fri":{"kind":"open","open":"11:00","close":"01:00"},"sat":{"kind":"open","open":"11:00","close":"01:00"},"sun":{"kind":"open","open":"11:00","close":"01:00"}}$hr$::jsonb,
  $ph$+639271702485$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Grotto Hookah Lounge$nm$))
    and abs(s.latitude - 14.5916991) < 0.00045
    and abs(s.longitude - 120.974185) < 0.00045
);

-- node/12693333501
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Grounds Manila Beanery$nm$,
  'OpenStreetMap',
  $ad$C Tandang Sora Avenue, Cayman Square Building, Metro Manila$ad$,
  14.6765828,
  121.0376876,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"14:00","close":"20:00"},"tue":{"kind":"open","open":"14:00","close":"20:00"},"wed":{"kind":"open","open":"14:00","close":"20:00"},"thu":{"kind":"open","open":"14:00","close":"20:00"},"fri":{"kind":"open","open":"14:00","close":"20:00"},"sat":{"kind":"open","open":"14:00","close":"20:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Grounds Manila Beanery$nm$))
    and abs(s.latitude - 14.6765828) < 0.00045
    and abs(s.longitude - 121.0376876) < 0.00045
);

-- node/6006451997
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Habitual Coffee$nm$,
  'OpenStreetMap',
  $ad$136 L. P. Leviste Street, Makati$ad$,
  14.559398,
  121.0226688,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"open","open":"11:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Habitual Coffee$nm$))
    and abs(s.latitude - 14.559398) < 0.00045
    and abs(s.longitude - 121.0226688) < 0.00045
);

-- node/2440067731
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Harlan + Holden Coffee$nm$,
  'OpenStreetMap',
  $ad$Alabang-Zapote Road, Alabang Town Center, Muntinlupa$ad$,
  14.4229662,
  121.0294739,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"23:00"},"tue":{"kind":"open","open":"07:00","close":"23:00"},"wed":{"kind":"open","open":"07:00","close":"23:00"},"thu":{"kind":"open","open":"07:00","close":"23:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Harlan + Holden Coffee$nm$))
    and abs(s.latitude - 14.4229662) < 0.00045
    and abs(s.longitude - 121.0294739) < 0.00045
);

-- node/10091501055
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Hilera Café$nm$,
  'OpenStreetMap',
  $ad$250 V. P. Ibañez Street, Metro Manila$ad$,
  14.5998602,
  121.0406195,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"11:00","close":"00:00"},"wed":{"kind":"open","open":"11:00","close":"00:00"},"thu":{"kind":"open","open":"11:00","close":"00:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  $ph$+63 919 893 3445$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Hilera Café$nm$))
    and abs(s.latitude - 14.5998602) < 0.00045
    and abs(s.longitude - 121.0406195) < 0.00045
);

-- node/11778206072
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Homie's Cafe$nm$,
  'OpenStreetMap',
  $ad$77 Corregidor Street, Quezon City$ad$,
  14.6582125,
  121.0243156,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"17:00"},"tue":{"kind":"open","open":"10:00","close":"17:00"},"wed":{"kind":"open","open":"10:00","close":"17:00"},"thu":{"kind":"open","open":"10:00","close":"17:00"},"fri":{"kind":"open","open":"10:00","close":"17:00"},"sat":{"kind":"open","open":"10:00","close":"17:00"},"sun":{"kind":"open","open":"10:00","close":"17:00"}}$hr$::jsonb,
  $ph$+63756322902$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Homie's Cafe$nm$))
    and abs(s.latitude - 14.6582125) < 0.00045
    and abs(s.longitude - 121.0243156) < 0.00045
);

-- node/4140147322
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$I Love Milktea$nm$,
  'OpenStreetMap',
  $ad$Greenheights Avenue, Metro Manila$ad$,
  14.468104,
  121.0143889,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$I Love Milktea$nm$))
    and abs(s.latitude - 14.468104) < 0.00045
    and abs(s.longitude - 121.0143889) < 0.00045
);

-- node/7466528447
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$I Love Milktea$nm$,
  'OpenStreetMap',
  $ad$Victoneta Avenue, Metro Manila$ad$,
  14.6704254,
  120.9992825,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"18:00"},"tue":{"kind":"open","open":"09:00","close":"18:00"},"wed":{"kind":"open","open":"09:00","close":"18:00"},"thu":{"kind":"open","open":"09:00","close":"18:00"},"fri":{"kind":"open","open":"09:00","close":"18:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$I Love Milktea$nm$))
    and abs(s.latitude - 14.6704254) < 0.00045
    and abs(s.longitude - 120.9992825) < 0.00045
);

-- node/13385968567
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Ice Cream Shop ni Dors$nm$,
  'OpenStreetMap',
  $ad$ML. Quezon corner General Luna Street, Taguig$ad$,
  14.5025288,
  121.0527021,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"17:00"},"tue":{"kind":"open","open":"09:00","close":"17:00"},"wed":{"kind":"open","open":"09:00","close":"17:00"},"thu":{"kind":"open","open":"09:00","close":"17:00"},"fri":{"kind":"open","open":"09:00","close":"17:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Ice Cream Shop ni Dors$nm$))
    and abs(s.latitude - 14.5025288) < 0.00045
    and abs(s.longitude - 121.0527021) < 0.00045
);

-- node/4314383089
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Infinitea$nm$,
  'OpenStreetMap',
  $ad$F. P. Felix Avenue, Metro Manila$ad$,
  14.6050387,
  121.104716,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"23:00"},"tue":{"kind":"open","open":"10:00","close":"23:00"},"wed":{"kind":"open","open":"10:00","close":"23:00"},"thu":{"kind":"open","open":"10:00","close":"23:00"},"fri":{"kind":"open","open":"10:00","close":"23:00"},"sat":{"kind":"open","open":"10:00","close":"23:00"},"sun":{"kind":"open","open":"10:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Infinitea$nm$))
    and abs(s.latitude - 14.6050387) < 0.00045
    and abs(s.longitude - 121.104716) < 0.00045
);

-- node/3601536646
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$It's Caffeine$nm$,
  'OpenStreetMap',
  $ad$Nicanor Reyes Street, Metro Manila$ad$,
  14.6044866,
  120.9878943,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"00:00"},"tue":{"kind":"open","open":"08:00","close":"00:00"},"wed":{"kind":"open","open":"08:00","close":"00:00"},"thu":{"kind":"open","open":"08:00","close":"00:00"},"fri":{"kind":"open","open":"08:00","close":"00:00"},"sat":{"kind":"open","open":"08:30","close":"00:00"},"sun":{"kind":"open","open":"09:30","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$It's Caffeine$nm$))
    and abs(s.latitude - 14.6044866) < 0.00045
    and abs(s.longitude - 120.9878943) < 0.00045
);

-- node/3506924047
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Jipan Café and Bakeshop$nm$,
  'OpenStreetMap',
  $ad$Pilar Street, Metro Manila$ad$,
  14.5907951,
  121.0411927,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"18:00"},"tue":{"kind":"open","open":"06:00","close":"18:00"},"wed":{"kind":"open","open":"06:00","close":"18:00"},"thu":{"kind":"open","open":"06:00","close":"18:00"},"fri":{"kind":"open","open":"06:00","close":"18:00"},"sat":{"kind":"open","open":"06:00","close":"18:00"},"sun":{"kind":"open","open":"06:00","close":"18:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Jipan Café and Bakeshop$nm$))
    and abs(s.latitude - 14.5907951) < 0.00045
    and abs(s.longitude - 121.0411927) < 0.00045
);

-- node/9830199030
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Kape Etc.$nm$,
  'OpenStreetMap',
  $ad$Blk 32 L 4 Jasmine Street, Caloocan$ad$,
  14.7533598,
  121.0630387,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Kape Etc.$nm$))
    and abs(s.latitude - 14.7533598) < 0.00045
    and abs(s.longitude - 121.0630387) < 0.00045
);

-- node/9504066217
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Kape Siklo$nm$,
  'OpenStreetMap',
  $ad$2387 Beata Street, Metro Manila$ad$,
  14.5909497,
  121.0057308,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"23:00"},"tue":{"kind":"open","open":"11:00","close":"23:00"},"wed":{"kind":"open","open":"11:00","close":"23:00"},"thu":{"kind":"open","open":"11:00","close":"23:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Kape Siklo$nm$))
    and abs(s.latitude - 14.5909497) < 0.00045
    and abs(s.longitude - 121.0057308) < 0.00045
);

-- node/10168315476
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Kohi$nm$,
  'OpenStreetMap',
  $ad$200 Maginhawa Street, Quezon City$ad$,
  14.6366039,
  121.0613476,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"20:00"},"sun":{"kind":"open","open":"08:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Kohi$nm$))
    and abs(s.latitude - 14.6366039) < 0.00045
    and abs(s.longitude - 121.0613476) < 0.00045
);

-- node/13142727623
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Kohi - Maginhawa$nm$,
  'OpenStreetMap',
  $ad$63 Maginhawa Street, Quezon City$ad$,
  14.6480647,
  121.0572784,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Kohi - Maginhawa$nm$))
    and abs(s.latitude - 14.6480647) < 0.00045
    and abs(s.longitude - 121.0572784) < 0.00045
);

-- node/12765860686
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$KOI Thé$nm$,
  'OpenStreetMap',
  $ad$Unit 1800-3A 1800 Eastwood Avenue, Quezon City$ad$,
  14.6102405,
  121.0793829,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 926 066 7731$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$KOI Thé$nm$))
    and abs(s.latitude - 14.6102405) < 0.00045
    and abs(s.longitude - 121.0793829) < 0.00045
);

-- way/794638354
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Kopi Tiam$nm$,
  'OpenStreetMap',
  $ad$3 C. Benitez Street, Quezon City$ad$,
  14.6101035,
  121.0432145,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"21:00"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"21:00"},"sat":{"kind":"open","open":"10:00","close":"21:00"},"sun":{"kind":"open","open":"10:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Kopi Tiam$nm$))
    and abs(s.latitude - 14.6101035) < 0.00045
    and abs(s.longitude - 121.0432145) < 0.00045
);

-- node/1074549761
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$KopiRoti$nm$,
  'OpenStreetMap',
  $ad$Katipunan Avenue, Quezon City$ad$,
  14.6205474,
  121.0730451,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"01:00"},"tue":{"kind":"open","open":"07:00","close":"01:00"},"wed":{"kind":"open","open":"07:00","close":"01:00"},"thu":{"kind":"open","open":"07:00","close":"01:00"},"fri":{"kind":"open","open":"07:00","close":"01:00"},"sat":{"kind":"open","open":"07:00","close":"01:00"},"sun":{"kind":"open","open":"07:00","close":"01:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$KopiRoti$nm$))
    and abs(s.latitude - 14.6205474) < 0.00045
    and abs(s.longitude - 121.0730451) < 0.00045
);

-- node/6539218605
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Kuya Orlee Computer Shop$nm$,
  'OpenStreetMap',
  $ad$Phase One Pasillo Dos 536 Calbayog Street, Mandaluyong$ad$,
  14.5772993,
  121.0479239,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"20:00"},"tue":{"kind":"open","open":"08:00","close":"20:00"},"wed":{"kind":"open","open":"08:00","close":"20:00"},"thu":{"kind":"open","open":"08:00","close":"20:00"},"fri":{"kind":"open","open":"08:00","close":"20:00"},"sat":{"kind":"open","open":"08:00","close":"20:00"},"sun":{"kind":"open","open":"08:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Kuya Orlee Computer Shop$nm$))
    and abs(s.latitude - 14.5772993) < 0.00045
    and abs(s.longitude - 121.0479239) < 0.00045
);

-- node/11850186369
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Kāffēī Diàn$nm$,
  'OpenStreetMap',
  $ad$Gladiola Street, Metro Manila$ad$,
  14.4611117,
  121.0385167,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"open","open":"07:00","close":"21:00"}}$hr$::jsonb,
  $ph$+639625581886$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Kāffēī Diàn$nm$))
    and abs(s.latitude - 14.4611117) < 0.00045
    and abs(s.longitude - 121.0385167) < 0.00045
);

-- node/12075961103
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$lakbaypinas$nm$,
  'OpenStreetMap',
  $ad$30 Luzon Street, Marikina$ad$,
  14.6493552,
  121.0950739,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$lakbaypinas$nm$))
    and abs(s.latitude - 14.6493552) < 0.00045
    and abs(s.longitude - 121.0950739) < 0.00045
);

-- node/2187192141
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Larry's Café Bar$nm$,
  'OpenStreetMap',
  $ad$11th Avenue, Serendra, Taguig$ad$,
  14.5497937,
  121.0538987,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"23:00"},"tue":{"kind":"open","open":"07:00","close":"23:00"},"wed":{"kind":"open","open":"07:00","close":"23:00"},"thu":{"kind":"open","open":"07:00","close":"23:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  $ph$+632 856 0527$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Larry's Café Bar$nm$))
    and abs(s.latitude - 14.5497937) < 0.00045
    and abs(s.longitude - 121.0538987) < 0.00045
);

-- node/12196286701
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Life Bowls$nm$,
  'OpenStreetMap',
  $ad$Mayflower Street, Metro Manila$ad$,
  14.5770997,
  121.0526448,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"21:00"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"21:00"},"sat":{"kind":"open","open":"10:00","close":"21:00"},"sun":{"kind":"open","open":"10:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Life Bowls$nm$))
    and abs(s.latitude - 14.5770997) < 0.00045
    and abs(s.longitude - 121.0526448) < 0.00045
);

-- way/119756820
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Ligaya.$nm$,
  'OpenStreetMap',
  $ad$68 Olive Street, Marikina$ad$,
  14.6373356,
  121.1177162,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Ligaya.$nm$))
    and abs(s.latitude - 14.6373356) < 0.00045
    and abs(s.longitude - 121.1177162) < 0.00045
);

-- node/13282377194
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Lobby Cafe$nm$,
  'OpenStreetMap',
  $ad$Amorsolo Street, Seda Residences Hotel, Makati$ad$,
  14.5598318,
  121.0151124,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"21:00"},"sun":{"kind":"open","open":"08:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63 917 875 1871$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Lobby Cafe$nm$))
    and abs(s.latitude - 14.5598318) < 0.00045
    and abs(s.longitude - 121.0151124) < 0.00045
);

-- node/8366928603
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$MA+D Manila$nm$,
  'OpenStreetMap',
  $ad$118 Matahimik Street, Quezon City$ad$,
  14.6453584,
  121.0539248,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"02:00"},"tue":{"kind":"open","open":"10:00","close":"02:00"},"wed":{"kind":"open","open":"10:00","close":"02:00"},"thu":{"kind":"open","open":"10:00","close":"02:00"},"fri":{"kind":"open","open":"10:00","close":"02:00"},"sat":{"kind":"open","open":"10:00","close":"02:00"},"sun":{"kind":"open","open":"10:00","close":"02:00"}}$hr$::jsonb,
  $ph$+639179942479$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$MA+D Manila$nm$))
    and abs(s.latitude - 14.6453584) < 0.00045
    and abs(s.longitude - 121.0539248) < 0.00045
);

-- node/9685460904
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Macao Imperial Tea$nm$,
  'OpenStreetMap',
  $ad$Daang Hari, Alabang West Parade, Las Piñas$ad$,
  14.4136273,
  121.0165535,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Macao Imperial Tea$nm$))
    and abs(s.latitude - 14.4136273) < 0.00045
    and abs(s.longitude - 121.0165535) < 0.00045
);

-- node/11754618555
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Magdamag Market Café$nm$,
  'OpenStreetMap',
  $ad$14 Sergeant Esguerra Avenue, Quezon City$ad$,
  14.6351756,
  121.0406778,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"19:00"},"tue":{"kind":"open","open":"09:00","close":"19:00"},"wed":{"kind":"open","open":"09:00","close":"19:00"},"thu":{"kind":"open","open":"09:00","close":"19:00"},"fri":{"kind":"open","open":"09:00","close":"19:00"},"sat":{"kind":"open","open":"08:00","close":"19:00"},"sun":{"kind":"open","open":"08:00","close":"19:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Magdamag Market Café$nm$))
    and abs(s.latitude - 14.6351756) < 0.00045
    and abs(s.longitude - 121.0406778) < 0.00045
);

-- node/3711963875
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Martabak Cafe$nm$,
  'OpenStreetMap',
  $ad$Pacific Drive, North Wing, Pasay$ad$,
  14.5363456,
  120.9826402,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 (917) 5300875$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Martabak Cafe$nm$))
    and abs(s.latitude - 14.5363456) < 0.00045
    and abs(s.longitude - 120.9826402) < 0.00045
);

-- node/13431454655
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Miko Seit$nm$,
  'OpenStreetMap',
  $ad$L19 Langit Road, Caloocan$ad$,
  14.7706822,
  121.0559673,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Miko Seit$nm$))
    and abs(s.latitude - 14.7706822) < 0.00045
    and abs(s.longitude - 121.0559673) < 0.00045
);

-- node/11757381694
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Mixue$nm$,
  'OpenStreetMap',
  $ad$2024-2032 Taft Avenue, Metro Manila$ad$,
  14.5552741,
  120.9970254,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"open","open":"09:00","close":"22:00"},"sun":{"kind":"open","open":"09:00","close":"22:00"}}$hr$::jsonb,
  $ph$09156536208$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Mixue$nm$))
    and abs(s.latitude - 14.5552741) < 0.00045
    and abs(s.longitude - 120.9970254) < 0.00045
);

-- node/13581570765
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Mollie's World Cafè$nm$,
  'OpenStreetMap',
  $ad$Quezon Avenue, Centris Walk, Quezon City$ad$,
  14.6424453,
  121.0401261,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"23:00"},"tue":{"kind":"open","open":"11:00","close":"23:00"},"wed":{"kind":"open","open":"11:00","close":"23:00"},"thu":{"kind":"open","open":"11:00","close":"23:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Mollie's World Cafè$nm$))
    and abs(s.latitude - 14.6424453) < 0.00045
    and abs(s.longitude - 121.0401261) < 0.00045
);

-- node/12366464426
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$My Dream of Flavors$nm$,
  'OpenStreetMap',
  $ad$340 Aguirre Avenue, Metro Manila$ad$,
  14.4565547,
  121.0073628,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$My Dream of Flavors$nm$))
    and abs(s.latitude - 14.4565547) < 0.00045
    and abs(s.longitude - 121.0073628) < 0.00045
);

-- node/13738956561
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Narrafé$nm$,
  'OpenStreetMap',
  $ad$2156 Narra Street, Metro Manila$ad$,
  14.5022485,
  121.0386537,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Narrafé$nm$))
    and abs(s.latitude - 14.5022485) < 0.00045
    and abs(s.longitude - 121.0386537) < 0.00045
);

-- node/4260451394
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Net Galore$nm$,
  'OpenStreetMap',
  $ad$133 Sampaloc Street, Metro Manila$ad$,
  14.6933604,
  121.0577438,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:30","close":"22:00"},"tue":{"kind":"open","open":"08:30","close":"22:00"},"wed":{"kind":"open","open":"08:30","close":"22:00"},"thu":{"kind":"open","open":"08:30","close":"22:00"},"fri":{"kind":"open","open":"08:30","close":"22:00"},"sat":{"kind":"open","open":"08:30","close":"22:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+63 922 370 8616$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Net Galore$nm$))
    and abs(s.latitude - 14.6933604) < 0.00045
    and abs(s.longitude - 121.0577438) < 0.00045
);

-- node/12849117101
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$NextGen Cafe$nm$,
  'OpenStreetMap',
  $ad$Mindanao Avenue, Metro Manila$ad$,
  14.6834338,
  121.0322402,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$NextGen Cafe$nm$))
    and abs(s.latitude - 14.6834338) < 0.00045
    and abs(s.longitude - 121.0322402) < 0.00045
);

-- node/11803939644
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Nihon Cafe$nm$,
  'OpenStreetMap',
  $ad$Estrella Street, Metro Manila$ad$,
  14.5603382,
  121.0401542,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  $ph$+63995 447 1107$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Nihon Cafe$nm$))
    and abs(s.latitude - 14.5603382) < 0.00045
    and abs(s.longitude - 121.0401542) < 0.00045
);

-- node/9985714832
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Nihon Café$nm$,
  'OpenStreetMap',
  $ad$Shaw Boulevard, Mandaluyong$ad$,
  14.5908889,
  121.0326863,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Nihon Café$nm$))
    and abs(s.latitude - 14.5908889) < 0.00045
    and abs(s.longitude - 121.0326863) < 0.00045
);

-- node/14072727738
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Nita Coffee Bar$nm$,
  'OpenStreetMap',
  $ad$B3 L19 Saint Thomas Street, Quezon City$ad$,
  14.702523,
  121.0469148,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"14:00","close":"00:00"},"tue":{"kind":"closed"},"wed":{"kind":"open","open":"14:00","close":"00:00"},"thu":{"kind":"open","open":"14:00","close":"00:00"},"fri":{"kind":"open","open":"14:00","close":"00:00"},"sat":{"kind":"open","open":"14:00","close":"00:00"},"sun":{"kind":"open","open":"14:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Nita Coffee Bar$nm$))
    and abs(s.latitude - 14.702523) < 0.00045
    and abs(s.longitude - 121.0469148) < 0.00045
);

-- node/10752396505
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Nitro 7 Coffee Bar$nm$,
  'OpenStreetMap',
  $ad$Fidel A. Reyes Street, Metro Manila$ad$,
  14.5658193,
  120.9930943,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"20:00"},"tue":{"kind":"open","open":"07:00","close":"20:00"},"wed":{"kind":"open","open":"07:00","close":"20:00"},"thu":{"kind":"open","open":"07:00","close":"20:00"},"fri":{"kind":"open","open":"07:00","close":"20:00"},"sat":{"kind":"open","open":"07:00","close":"20:00"},"sun":{"kind":"open","open":"07:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Nitro 7 Coffee Bar$nm$))
    and abs(s.latitude - 14.5658193) < 0.00045
    and abs(s.longitude - 120.9930943) < 0.00045
);

-- node/3909460065
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Nono's$nm$,
  'OpenStreetMap',
  $ad$117 Gamboa Street, KL Tower, Makati$ad$,
  14.5534787,
  121.0168339,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"22:00"},"tue":{"kind":"open","open":"06:00","close":"22:00"},"wed":{"kind":"open","open":"06:00","close":"22:00"},"thu":{"kind":"open","open":"06:00","close":"22:00"},"fri":{"kind":"open","open":"06:00","close":"22:00"},"sat":{"kind":"open","open":"06:00","close":"22:00"},"sun":{"kind":"open","open":"06:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 955-451-6373$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Nono's$nm$))
    and abs(s.latitude - 14.5534787) < 0.00045
    and abs(s.longitude - 121.0168339) < 0.00045
);

-- node/14191085701
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Odd Cafe$nm$,
  'OpenStreetMap',
  $ad$San Miguel Avenue, Metro Manila$ad$,
  14.5809532,
  121.0597168,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"23:00"},"tue":{"kind":"open","open":"08:00","close":"23:00"},"wed":{"kind":"open","open":"08:00","close":"23:00"},"thu":{"kind":"open","open":"08:00","close":"23:00"},"fri":{"kind":"open","open":"08:00","close":"23:00"},"sat":{"kind":"open","open":"08:00","close":"23:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Odd Cafe$nm$))
    and abs(s.latitude - 14.5809532) < 0.00045
    and abs(s.longitude - 121.0597168) < 0.00045
);

-- node/13979692477
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Oltre Specialty Coffee$nm$,
  'OpenStreetMap',
  $ad$5343 General Luna Street corner Salamanca Street, Makati City$ad$,
  14.5656108,
  121.0289444,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  $ph$+63 917 794 1130$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Oltre Specialty Coffee$nm$))
    and abs(s.latitude - 14.5656108) < 0.00045
    and abs(s.longitude - 121.0289444) < 0.00045
);

-- node/14143802278
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Omotesando Koffee$nm$,
  'OpenStreetMap',
  $ad$Retail 2 & 3 Valero Street, Dowell Tower Residences, Metro Manila$ad$,
  14.5593121,
  121.0248864,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"19:00"},"tue":{"kind":"open","open":"07:00","close":"19:00"},"wed":{"kind":"open","open":"07:00","close":"19:00"},"thu":{"kind":"open","open":"07:00","close":"19:00"},"fri":{"kind":"open","open":"07:00","close":"19:00"},"sat":{"kind":"open","open":"07:00","close":"16:00"},"sun":{"kind":"open","open":"07:00","close":"16:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Omotesando Koffee$nm$))
    and abs(s.latitude - 14.5593121) < 0.00045
    and abs(s.longitude - 121.0248864) < 0.00045
);

-- node/13722481514
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Pancho Cafe$nm$,
  'OpenStreetMap',
  $ad$102 Benavidez Street corner Trasierra Street, Makati$ad$,
  14.5517733,
  121.0184415,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Pancho Cafe$nm$))
    and abs(s.latitude - 14.5517733) < 0.00045
    and abs(s.longitude - 121.0184415) < 0.00045
);

-- node/5712864416
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Paper + Cup$nm$,
  'OpenStreetMap',
  $ad$Muralla Street corner Recoletos Street, Manila Bulletin, Manila$ad$,
  14.5882658,
  120.9784939,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"20:00"},"tue":{"kind":"open","open":"08:00","close":"20:00"},"wed":{"kind":"open","open":"08:00","close":"20:00"},"thu":{"kind":"open","open":"08:00","close":"20:00"},"fri":{"kind":"open","open":"08:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"17:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Paper + Cup$nm$))
    and abs(s.latitude - 14.5882658) < 0.00045
    and abs(s.longitude - 120.9784939) < 0.00045
);

-- node/3610397239
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Pegi Waffles$nm$,
  'OpenStreetMap',
  $ad$433A-433C P. Guevarra Street, Metro Manila$ad$,
  14.5978949,
  121.0377445,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"19:00"},"tue":{"kind":"open","open":"10:00","close":"19:00"},"wed":{"kind":"open","open":"10:00","close":"19:00"},"thu":{"kind":"open","open":"10:00","close":"19:00"},"fri":{"kind":"open","open":"10:00","close":"19:00"},"sat":{"kind":"open","open":"10:00","close":"19:00"},"sun":{"kind":"open","open":"10:00","close":"19:00"}}$hr$::jsonb,
  $ph$+6327248363$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Pegi Waffles$nm$))
    and abs(s.latitude - 14.5978949) < 0.00045
    and abs(s.longitude - 121.0377445) < 0.00045
);

-- node/10177462917
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Projuice$nm$,
  'OpenStreetMap',
  $ad$Taft Avenue, Metro Manila$ad$,
  14.5653511,
  120.9947375,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"00:00"},"tue":{"kind":"open","open":"08:00","close":"00:00"},"wed":{"kind":"open","open":"08:00","close":"00:00"},"thu":{"kind":"open","open":"08:00","close":"00:00"},"fri":{"kind":"open","open":"08:00","close":"00:00"},"sat":{"kind":"open","open":"08:00","close":"00:00"},"sun":{"kind":"open","open":"08:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Projuice$nm$))
    and abs(s.latitude - 14.5653511) < 0.00045
    and abs(s.longitude - 120.9947375) < 0.00045
);

-- node/10239331309
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$RebecCafé$nm$,
  'OpenStreetMap',
  $ad$Blk8 Lot13 Iris Street, Metro Manila$ad$,
  14.3962753,
  121.0350962,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"15:00","close":"22:00"},"tue":{"kind":"open","open":"15:00","close":"22:00"},"wed":{"kind":"open","open":"15:00","close":"22:00"},"thu":{"kind":"open","open":"15:00","close":"22:00"},"fri":{"kind":"open","open":"15:00","close":"22:00"},"sat":{"kind":"open","open":"15:00","close":"22:00"},"sun":{"kind":"open","open":"15:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$RebecCafé$nm$))
    and abs(s.latitude - 14.3962753) < 0.00045
    and abs(s.longitude - 121.0350962) < 0.00045
);

-- node/7057748985
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Red Monster Cafe$nm$,
  'OpenStreetMap',
  $ad$107 Maginhawa Street, Metro Manila$ad$,
  14.646248,
  121.0605021,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:00"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"closed"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"open","open":"11:00","close":"21:00"}}$hr$::jsonb,
  $ph$+639178580987$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Red Monster Cafe$nm$))
    and abs(s.latitude - 14.646248) < 0.00045
    and abs(s.longitude - 121.0605021) < 0.00045
);

-- node/10915219174
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Relax & Brew$nm$,
  'OpenStreetMap',
  $ad$Katipunan Street, Metro Manila$ad$,
  14.646247,
  121.1131869,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"00:00"},"tue":{"kind":"open","open":"09:00","close":"00:00"},"wed":{"kind":"open","open":"09:00","close":"00:00"},"thu":{"kind":"open","open":"09:00","close":"00:00"},"fri":{"kind":"open","open":"09:00","close":"00:00"},"sat":{"kind":"open","open":"09:00","close":"00:00"},"sun":{"kind":"open","open":"09:00","close":"00:00"}}$hr$::jsonb,
  $ph$+63 920 976 5644$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Relax & Brew$nm$))
    and abs(s.latitude - 14.646247) < 0.00045
    and abs(s.longitude - 121.1131869) < 0.00045
);

-- node/3711963878
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Rivera Cafe$nm$,
  'OpenStreetMap',
  $ad$EDSA corner Roxas Boulevard, Heritage Hotel, Pasay$ad$,
  14.5367896,
  120.9937559,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"23:00"},"tue":{"kind":"open","open":"06:00","close":"23:00"},"wed":{"kind":"open","open":"06:00","close":"23:00"},"thu":{"kind":"open","open":"06:00","close":"23:00"},"fri":{"kind":"open","open":"06:00","close":"23:00"},"sat":{"kind":"open","open":"06:00","close":"23:00"},"sun":{"kind":"open","open":"06:00","close":"23:00"}}$hr$::jsonb,
  $ph$+63 2 854 8888$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Rivera Cafe$nm$))
    and abs(s.latitude - 14.5367896) < 0.00045
    and abs(s.longitude - 120.9937559) < 0.00045
);

-- node/12014742795
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$RM Coffee & Tea$nm$,
  'OpenStreetMap',
  $ad$16 K-3rd Street, Quezon City$ad$,
  14.6282618,
  121.0413906,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"13:00","close":"21:00"},"tue":{"kind":"open","open":"13:00","close":"21:00"},"wed":{"kind":"open","open":"13:00","close":"21:00"},"thu":{"kind":"open","open":"13:00","close":"21:00"},"fri":{"kind":"open","open":"13:00","close":"21:00"},"sat":{"kind":"open","open":"13:00","close":"21:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$RM Coffee & Tea$nm$))
    and abs(s.latitude - 14.6282618) < 0.00045
    and abs(s.longitude - 121.0413906) < 0.00045
);

-- node/13115927669
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Roundabout Bistro$nm$,
  'OpenStreetMap',
  $ad$Maysilo Circle, Metro Manila$ad$,
  14.5783528,
  121.0342795,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"00:00"},"tue":{"kind":"open","open":"11:00","close":"00:00"},"wed":{"kind":"open","open":"11:00","close":"00:00"},"thu":{"kind":"open","open":"11:00","close":"00:00"},"fri":{"kind":"open","open":"11:00","close":"00:00"},"sat":{"kind":"open","open":"11:00","close":"00:00"},"sun":{"kind":"open","open":"11:00","close":"00:00"}}$hr$::jsonb,
  $ph$+63 939 912 3418$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Roundabout Bistro$nm$))
    and abs(s.latitude - 14.5783528) < 0.00045
    and abs(s.longitude - 121.0342795) < 0.00045
);

-- way/1396548805
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Sable$nm$,
  'OpenStreetMap',
  $ad$B 66 Broadway Avenue, Quezon City$ad$,
  14.6221186,
  121.026775,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Sable$nm$))
    and abs(s.latitude - 14.6221186) < 0.00045
    and abs(s.longitude - 121.026775) < 0.00045
);

-- node/6494164485
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Savoy Cafe$nm$,
  'OpenStreetMap',
  $ad$101 Andrews Avenue, Metro Manila$ad$,
  14.5237537,
  121.0125853,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"22:00"},"tue":{"kind":"open","open":"06:00","close":"22:00"},"wed":{"kind":"open","open":"06:00","close":"22:00"},"thu":{"kind":"open","open":"06:00","close":"22:00"},"fri":{"kind":"open","open":"06:00","close":"22:00"},"sat":{"kind":"open","open":"06:00","close":"22:00"},"sun":{"kind":"open","open":"06:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Savoy Cafe$nm$))
    and abs(s.latitude - 14.5237537) < 0.00045
    and abs(s.longitude - 121.0125853) < 0.00045
);

-- node/13942729301
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Scratch$nm$,
  'OpenStreetMap',
  $ad$106 Aguirre Street, Metro Manila$ad$,
  14.5526495,
  121.0175659,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"closed"},"wed":{"kind":"open","open":"09:00","close":"16:00"},"thu":{"kind":"open","open":"09:00","close":"16:00"},"fri":{"kind":"open","open":"09:00","close":"16:00"},"sat":{"kind":"open","open":"09:00","close":"16:00"},"sun":{"kind":"open","open":"09:00","close":"16:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Scratch$nm$))
    and abs(s.latitude - 14.5526495) < 0.00045
    and abs(s.longitude - 121.0175659) < 0.00045
);

-- way/165297828
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Seattle's Best Coffee$nm$,
  'OpenStreetMap',
  $ad$Alabang-Zapote Road, Las Piñas$ad$,
  14.447373,
  120.9859732,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Seattle's Best Coffee$nm$))
    and abs(s.latitude - 14.447373) < 0.00045
    and abs(s.longitude - 120.9859732) < 0.00045
);

-- node/6583366543
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Sekretong hardin$nm$,
  'OpenStreetMap',
  $ad$8760 Santol Street corner Sampaloc, 8760 Residences, Makati$ad$,
  14.5639584,
  121.007971,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  $ph$02 86711978$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Sekretong hardin$nm$))
    and abs(s.latitude - 14.5639584) < 0.00045
    and abs(s.longitude - 121.007971) < 0.00045
);

-- node/9591509511
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Sentro Fortis Café$nm$,
  'OpenStreetMap',
  $ad$Victoria Avenue, Muntinlupa$ad$,
  14.3533661,
  121.0098598,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:30","close":"20:00"},"tue":{"kind":"open","open":"07:30","close":"20:00"},"wed":{"kind":"open","open":"07:30","close":"20:00"},"thu":{"kind":"open","open":"07:30","close":"20:00"},"fri":{"kind":"open","open":"07:30","close":"20:00"},"sat":{"kind":"open","open":"07:30","close":"20:00"},"sun":{"kind":"open","open":"07:30","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Sentro Fortis Café$nm$))
    and abs(s.latitude - 14.3533661) < 0.00045
    and abs(s.longitude - 121.0098598) < 0.00045
);

-- node/9358935574
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$SGD Coffee Bodega$nm$,
  'OpenStreetMap',
  $ad$45 Maalalahanin Street, Metro Manila$ad$,
  14.643576,
  121.0593539,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"20:00"},"tue":{"kind":"open","open":"08:00","close":"20:00"},"wed":{"kind":"open","open":"08:00","close":"20:00"},"thu":{"kind":"open","open":"08:00","close":"20:00"},"fri":{"kind":"open","open":"08:00","close":"20:00"},"sat":{"kind":"open","open":"08:00","close":"20:00"},"sun":{"kind":"open","open":"08:00","close":"20:00"}}$hr$::jsonb,
  $ph$+639065518255$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$SGD Coffee Bodega$nm$))
    and abs(s.latitude - 14.643576) < 0.00045
    and abs(s.longitude - 121.0593539) < 0.00045
);

-- node/11696478092
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Sibs Coffee Roasters$nm$,
  'OpenStreetMap',
  $ad$306-A Barangka Drive, Metro Manila$ad$,
  14.5700514,
  121.0365385,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Sibs Coffee Roasters$nm$))
    and abs(s.latitude - 14.5700514) < 0.00045
    and abs(s.longitude - 121.0365385) < 0.00045
);

-- node/8633822972
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Sicilian Roast$nm$,
  'OpenStreetMap',
  $ad$Katipunan Avenue, Arton Strip, Metro Manila$ad$,
  14.6209861,
  121.0733703,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"22:00"},"tue":{"kind":"open","open":"11:00","close":"22:00"},"wed":{"kind":"open","open":"11:00","close":"22:00"},"thu":{"kind":"open","open":"11:00","close":"22:00"},"fri":{"kind":"open","open":"11:00","close":"22:00"},"sat":{"kind":"open","open":"11:00","close":"22:00"},"sun":{"kind":"open","open":"11:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Sicilian Roast$nm$))
    and abs(s.latitude - 14.6209861) < 0.00045
    and abs(s.longitude - 121.0733703) < 0.00045
);

-- node/11919903254
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Silingan Coffee Shop$nm$,
  'OpenStreetMap',
  $ad$General Romulo Avenue, Cubao Expo, Metro Manila$ad$,
  14.6223936,
  121.0565522,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:00"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"23:00"},"fri":{"kind":"open","open":"09:00","close":"23:00"},"sat":{"kind":"open","open":"09:00","close":"23:00"},"sun":{"kind":"open","open":"09:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Silingan Coffee Shop$nm$))
    and abs(s.latitude - 14.6223936) < 0.00045
    and abs(s.longitude - 121.0565522) < 0.00045
);

-- node/13461706510
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Single Origin$nm$,
  'OpenStreetMap',
  $ad$Legazpi Street, Greenbelt 5, Metro Manila$ad$,
  14.5531619,
  121.0223198,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Single Origin$nm$))
    and abs(s.latitude - 14.5531619) < 0.00045
    and abs(s.longitude - 121.0223198) < 0.00045
);

-- node/12039888563
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Sixteen Centigrado$nm$,
  'OpenStreetMap',
  $ad$421-A Constabulary Road, Quezon City$ad$,
  14.6826591,
  121.073459,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  $ph$+639295549128$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Sixteen Centigrado$nm$))
    and abs(s.latitude - 14.6826591) < 0.00045
    and abs(s.longitude - 121.073459) < 0.00045
);

-- node/4352511505
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Smynoshery$nm$,
  'OpenStreetMap',
  $ad$863 Galicia Street, Metro Manila$ad$,
  14.6066775,
  120.990337,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:30","close":"22:00"},"tue":{"kind":"open","open":"10:30","close":"22:00"},"wed":{"kind":"open","open":"10:30","close":"22:00"},"thu":{"kind":"open","open":"10:30","close":"22:00"},"fri":{"kind":"open","open":"10:30","close":"22:00"},"sat":{"kind":"open","open":"10:30","close":"22:00"},"sun":{"kind":"open","open":"10:30","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Smynoshery$nm$))
    and abs(s.latitude - 14.6066775) < 0.00045
    and abs(s.longitude - 120.990337) < 0.00045
);

-- node/14050360017
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Soft Habit$nm$,
  'OpenStreetMap',
  $ad$Grass Residences Misamis Street, Metro Manila$ad$,
  14.6591618,
  121.0286554,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"23:00"},"tue":{"kind":"open","open":"07:00","close":"23:00"},"wed":{"kind":"open","open":"07:00","close":"23:00"},"thu":{"kind":"open","open":"07:00","close":"23:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Soft Habit$nm$))
    and abs(s.latitude - 14.6591618) < 0.00045
    and abs(s.longitude - 121.0286554) < 0.00045
);

-- node/11504852369
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Sound$nm$,
  'OpenStreetMap',
  $ad$East Capitol Drive, Metro Manila$ad$,
  14.5677272,
  121.0585882,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"20:00"},"tue":{"kind":"open","open":"08:00","close":"20:00"},"wed":{"kind":"open","open":"08:00","close":"20:00"},"thu":{"kind":"open","open":"08:00","close":"20:00"},"fri":{"kind":"open","open":"08:00","close":"20:00"},"sat":{"kind":"open","open":"08:00","close":"20:00"},"sun":{"kind":"open","open":"08:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Sound$nm$))
    and abs(s.latitude - 14.5677272) < 0.00045
    and abs(s.longitude - 121.0585882) < 0.00045
);

-- node/2189235012
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Daang Hari, Evia Lifestyle Center, Las Piñas$ad$,
  14.3761615,
  121.0125265,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"00:00"},"tue":{"kind":"open","open":"06:00","close":"00:00"},"wed":{"kind":"open","open":"06:00","close":"00:00"},"thu":{"kind":"open","open":"06:00","close":"00:00"},"fri":{"kind":"open","open":"06:00","close":"00:00"},"sat":{"kind":"open","open":"06:00","close":"00:00"},"sun":{"kind":"open","open":"06:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.3761615) < 0.00045
    and abs(s.longitude - 121.0125265) < 0.00045
);

-- node/6747119139
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Commerce Avenue corner Spectrum Midway, One Griffinstone, Muntinlupa$ad$,
  14.4190106,
  121.0368078,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:30","close":"00:00"},"tue":{"kind":"open","open":"06:30","close":"00:00"},"wed":{"kind":"open","open":"06:30","close":"00:00"},"thu":{"kind":"open","open":"06:30","close":"00:00"},"fri":{"kind":"open","open":"06:30","close":"00:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.4190106) < 0.00045
    and abs(s.longitude - 121.0368078) < 0.00045
);

-- node/12079464090
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$BF Resort Drive corner Cynthia Ugalde Street, J Studio HQ Building, Las Piñas$ad$,
  14.4406582,
  120.9910129,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.4406582) < 0.00045
    and abs(s.longitude - 120.9910129) < 0.00045
);

-- node/1728952937
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Alabang-Zapote Road, SM Center Las Piñas, Las Piñas$ad$,
  14.449243,
  120.9809741,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.449243) < 0.00045
    and abs(s.longitude - 120.9809741) < 0.00045
);

-- node/683285920
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Alabang-Zapote Road, Las Piñas$ad$,
  14.4517477,
  120.9772429,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"00:00"},"tue":{"kind":"open","open":"08:00","close":"00:00"},"wed":{"kind":"open","open":"08:00","close":"00:00"},"thu":{"kind":"open","open":"08:00","close":"00:00"},"fri":{"kind":"open","open":"08:00","close":"00:00"},"sat":{"kind":"open","open":"08:00","close":"00:00"},"sun":{"kind":"open","open":"08:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.4517477) < 0.00045
    and abs(s.longitude - 120.9772429) < 0.00045
);

-- node/5981243991
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Doña Soledad Avenue, Metro Manila$ad$,
  14.4857819,
  121.0425637,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"21:00"},"tue":{"kind":"open","open":"08:00","close":"21:00"},"wed":{"kind":"open","open":"08:00","close":"21:00"},"thu":{"kind":"open","open":"08:00","close":"21:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.4857819) < 0.00045
    and abs(s.longitude - 121.0425637) < 0.00045
);

-- node/5552580597
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Seaside Drive, Okada Manila, Parañaque$ad$,
  14.5121877,
  120.9801539,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"00:00"},"tue":{"kind":"open","open":"08:00","close":"00:00"},"wed":{"kind":"open","open":"08:00","close":"00:00"},"thu":{"kind":"open","open":"08:00","close":"00:00"},"fri":{"kind":"open","open":"08:00","close":"00:00"},"sat":{"kind":"open","open":"08:00","close":"00:00"},"sun":{"kind":"open","open":"08:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5121877) < 0.00045
    and abs(s.longitude - 120.9801539) < 0.00045
);

-- node/12450696952
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$ASEAN Avenue, City of Dreams Manila, Metro Manila$ad$,
  14.5236134,
  120.991957,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"03:00"},"tue":{"kind":"open","open":"06:00","close":"03:00"},"wed":{"kind":"open","open":"06:00","close":"03:00"},"thu":{"kind":"open","open":"06:00","close":"03:00"},"fri":{"kind":"open","open":"06:00","close":"03:00"},"sat":{"kind":"open","open":"07:00","close":"02:00"},"sun":{"kind":"open","open":"07:00","close":"02:00"}}$hr$::jsonb,
  $ph$+63 279788900$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5236134) < 0.00045
    and abs(s.longitude - 120.991957) < 0.00045
);

-- node/2930421999
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Campus Avenue, Taguig$ad$,
  14.5306457,
  121.0527215,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"01:30"},"tue":{"kind":"open","open":"07:00","close":"01:30"},"wed":{"kind":"open","open":"07:00","close":"01:30"},"thu":{"kind":"open","open":"07:00","close":"01:30"},"fri":{"kind":"open","open":"07:00","close":"01:30"},"sat":{"kind":"open","open":"07:00","close":"01:30"},"sun":{"kind":"open","open":"07:00","close":"01:30"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5306457) < 0.00045
    and abs(s.longitude - 121.0527215) < 0.00045
);

-- node/1324283503
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Ocean Drive, SM Mall of Asia, Pasay$ad$,
  14.5362478,
  120.9807446,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"23:00"},"tue":{"kind":"open","open":"11:00","close":"23:00"},"wed":{"kind":"open","open":"11:00","close":"23:00"},"thu":{"kind":"open","open":"11:00","close":"23:00"},"fri":{"kind":"open","open":"11:00","close":"23:00"},"sat":{"kind":"open","open":"11:00","close":"23:00"},"sun":{"kind":"open","open":"11:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5362478) < 0.00045
    and abs(s.longitude - 120.9807446) < 0.00045
);

-- node/4435497559
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Harbor Drive corner Bayshore Avenue, Five E-com Center, Pasay$ad$,
  14.5398731,
  120.9824605,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5398731) < 0.00045
    and abs(s.longitude - 120.9824605) < 0.00045
);

-- node/4524696230
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$EDSA corner Chino Roces Avenue Extension, Southgate Mall, Makati$ad$,
  14.541127,
  121.0191042,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:30","close":"22:30"},"tue":{"kind":"open","open":"06:30","close":"22:30"},"wed":{"kind":"open","open":"06:30","close":"22:30"},"thu":{"kind":"open","open":"06:30","close":"22:30"},"fri":{"kind":"open","open":"06:30","close":"22:30"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.541127) < 0.00045
    and abs(s.longitude - 121.0191042) < 0.00045
);

-- node/2139050708
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$5th Avenue corner Rizal Drive, Sun Life Center, Taguig$ad$,
  14.5481436,
  121.0463648,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"20:00"},"tue":{"kind":"open","open":"06:00","close":"20:00"},"wed":{"kind":"open","open":"06:00","close":"20:00"},"thu":{"kind":"open","open":"06:00","close":"20:00"},"fri":{"kind":"open","open":"06:00","close":"20:00"},"sat":{"kind":"open","open":"06:00","close":"20:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5481436) < 0.00045
    and abs(s.longitude - 121.0463648) < 0.00045
);

-- node/12421394611
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$GF5, Metro Manila$ad$,
  14.5522743,
  121.0462297,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5522743) < 0.00045
    and abs(s.longitude - 121.0462297) < 0.00045
);

-- node/11971794118
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$6754 Ayala Avenue, Allied Bank Center, Makati$ad$,
  14.5552605,
  121.0230457,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"06:30","close":"02:00"},"fri":{"kind":"open","open":"06:30","close":"02:00"},"sat":{"kind":"open","open":"06:30","close":"02:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5552605) < 0.00045
    and abs(s.longitude - 121.0230457) < 0.00045
);

-- way/613886957
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$9th Avenue corner 36th Street, Uptown Mall, Uptown Place, Taguig$ad$,
  14.5567565,
  121.0541309,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5567565) < 0.00045
    and abs(s.longitude - 121.0541309) < 0.00045
);

-- node/4707778190
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$14 Jupiter Street, Makati$ad$,
  14.5572875,
  121.0341054,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"00:00"},"tue":{"kind":"open","open":"06:00","close":"00:00"},"wed":{"kind":"open","open":"06:00","close":"00:00"},"thu":{"kind":"open","open":"06:00","close":"00:00"},"fri":{"kind":"open","open":"06:00","close":"00:00"},"sat":{"kind":"open","open":"06:00","close":"00:00"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+63 2 8896 2755$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5572875) < 0.00045
    and abs(s.longitude - 121.0341054) < 0.00045
);

-- node/1243320289
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$143 Dela Rosa Street corner Adelantado Street, Keyland Centre, Makati$ad$,
  14.5585898,
  121.0149221,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5585898) < 0.00045
    and abs(s.longitude - 121.0149221) < 0.00045
);

-- node/444395107
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Senator Gil J. Puyat Avenue corner Makati Avenue, Pacific Star Building, Makati$ad$,
  14.5611547,
  121.0272048,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:30","close":"20:00"},"tue":{"kind":"open","open":"06:30","close":"20:00"},"wed":{"kind":"open","open":"06:30","close":"20:00"},"thu":{"kind":"open","open":"06:30","close":"20:00"},"fri":{"kind":"open","open":"06:30","close":"20:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  $ph$+63 2 8670 7648$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5611547) < 0.00045
    and abs(s.longitude - 121.0272048) < 0.00045
);

-- node/655184597
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Taft Avenue corner Pablo Ocampo Sr. Avenue, Torre Lorenzo Plaza, Manila$ad$,
  14.562763,
  120.9949152,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"00:00"},"tue":{"kind":"open","open":"06:00","close":"00:00"},"wed":{"kind":"open","open":"06:00","close":"00:00"},"thu":{"kind":"open","open":"06:00","close":"00:00"},"fri":{"kind":"open","open":"06:00","close":"00:00"},"sat":{"kind":"open","open":"06:30","close":"00:00"},"sun":{"kind":"open","open":"06:30","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.562763) < 0.00045
    and abs(s.longitude - 120.9949152) < 0.00045
);

-- node/9610284748
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$8445 Kalayaan Avenue, Zentro Building, Makati$ad$,
  14.5639498,
  121.0299432,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"00:00"},"tue":{"kind":"open","open":"06:00","close":"00:00"},"wed":{"kind":"open","open":"06:00","close":"00:00"},"thu":{"kind":"open","open":"06:00","close":"00:00"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  $ph$+63 2 7211 8761$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5639498) < 0.00045
    and abs(s.longitude - 121.0299432) < 0.00045
);

-- node/1740306401
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Taft Avenue, Manila$ad$,
  14.5642099,
  120.9946136,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"01:00"},"tue":{"kind":"open","open":"07:00","close":"01:00"},"wed":{"kind":"open","open":"07:00","close":"01:00"},"thu":{"kind":"open","open":"07:00","close":"01:00"},"fri":{"kind":"open","open":"07:00","close":"01:00"},"sat":{"kind":"open","open":"08:00","close":"00:00"},"sun":{"kind":"open","open":"08:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5642099) < 0.00045
    and abs(s.longitude - 120.9946136) < 0.00045
);

-- node/10174259263
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$50 West Capitol Drive corner United Street, The Vantage at Kapitolyo, Pasig$ad$,
  14.5729845,
  121.0596794,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"23:00"},"tue":{"kind":"open","open":"06:00","close":"23:00"},"wed":{"kind":"open","open":"06:00","close":"23:00"},"thu":{"kind":"open","open":"06:00","close":"23:00"},"fri":{"kind":"open","open":"06:00","close":"23:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5729845) < 0.00045
    and abs(s.longitude - 121.0596794) < 0.00045
);

-- node/1618316700
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Pioneer Street corner United Avenue, Pioneer Center, Pasig$ad$,
  14.5739989,
  121.0575405,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"open","open":"07:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5739989) < 0.00045
    and abs(s.longitude - 121.0575405) < 0.00045
);

-- way/430001447
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Camino Verde Road, Pasig$ad$,
  14.5744149,
  121.0624361,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"02:30"},"tue":{"kind":"open","open":"06:00","close":"02:30"},"wed":{"kind":"open","open":"06:00","close":"02:30"},"thu":{"kind":"open","open":"06:00","close":"02:30"},"fri":{"kind":"open","open":"06:00","close":"02:30"},"sat":{"kind":"open","open":"06:00","close":"02:30"},"sun":{"kind":"open","open":"06:00","close":"02:30"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5744149) < 0.00045
    and abs(s.longitude - 121.0624361) < 0.00045
);

-- node/10651347447
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Fame Mall, Metro Manila$ad$,
  14.5768396,
  121.0526228,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5768396) < 0.00045
    and abs(s.longitude - 121.0526228) < 0.00045
);

-- node/2062630221
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Mayflower Street, The Portal, Mandaluyong$ad$,
  14.5787388,
  121.0540786,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"00:00"},"tue":{"kind":"open","open":"08:00","close":"00:00"},"wed":{"kind":"open","open":"08:00","close":"00:00"},"thu":{"kind":"open","open":"08:00","close":"00:00"},"fri":{"kind":"open","open":"08:00","close":"01:00"},"sat":{"kind":"open","open":"08:00","close":"01:00"},"sun":{"kind":"open","open":"08:00","close":"01:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5787388) < 0.00045
    and abs(s.longitude - 121.0540786) < 0.00045
);

-- node/26032673
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Manila 1 Roxas Boulevard Service Road corner United Nations Avenue, Manila$ad$,
  14.5789093,
  120.9783098,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:30","close":"00:30"},"tue":{"kind":"open","open":"12:30","close":"00:30"},"wed":{"kind":"open","open":"12:30","close":"00:30"},"thu":{"kind":"open","open":"12:30","close":"00:30"},"fri":{"kind":"open","open":"12:30","close":"00:30"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5789093) < 0.00045
    and abs(s.longitude - 120.9783098) < 0.00045
);

-- node/1413649980
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$17 San Miguel Avenue, Hanston Square, Pasig$ad$,
  14.5795139,
  121.0586435,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:00"},"tue":{"kind":"open","open":"09:00","close":"22:00"},"wed":{"kind":"open","open":"09:00","close":"22:00"},"thu":{"kind":"open","open":"09:00","close":"22:00"},"fri":{"kind":"open","open":"09:00","close":"22:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5795139) < 0.00045
    and abs(s.longitude - 121.0586435) < 0.00045
);

-- node/5625878631
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Meralco Avenue, Ayala Malls the 30th, Pasig$ad$,
  14.580386,
  121.0640604,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:30","close":"22:30"},"tue":{"kind":"open","open":"06:30","close":"22:30"},"wed":{"kind":"open","open":"06:30","close":"22:30"},"thu":{"kind":"open","open":"06:30","close":"22:30"},"fri":{"kind":"open","open":"06:30","close":"22:30"},"sat":{"kind":"open","open":"08:00","close":"22:30"},"sun":{"kind":"open","open":"08:00","close":"22:30"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.580386) < 0.00045
    and abs(s.longitude - 121.0640604) < 0.00045
);

-- node/7878520308
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$2445 Pedro Gil Street, Manila$ad$,
  14.5818947,
  121.0126915,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"23:00"},"tue":{"kind":"open","open":"06:00","close":"23:00"},"wed":{"kind":"open","open":"06:00","close":"23:00"},"thu":{"kind":"open","open":"06:00","close":"23:00"},"fri":{"kind":"open","open":"06:00","close":"23:00"},"sat":{"kind":"open","open":"06:00","close":"23:00"},"sun":{"kind":"open","open":"06:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5818947) < 0.00045
    and abs(s.longitude - 121.0126915) < 0.00045
);

-- node/748626037
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$23 ADB Avenue, Anson's, Pasig$ad$,
  14.5861656,
  121.0599638,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"21:00"},"tue":{"kind":"open","open":"06:00","close":"21:00"},"wed":{"kind":"open","open":"06:00","close":"21:00"},"thu":{"kind":"open","open":"06:00","close":"21:00"},"fri":{"kind":"open","open":"06:00","close":"21:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5861656) < 0.00045
    and abs(s.longitude - 121.0599638) < 0.00045
);

-- node/746921285
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Meralco Avenue, Metrowalk, Pasig$ad$,
  14.587683,
  121.0641887,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.587683) < 0.00045
    and abs(s.longitude - 121.0641887) < 0.00045
);

-- node/13674455575
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$General Luna Street corner Santa Clara Street, Manila$ad$,
  14.5926425,
  120.9720046,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"08:00","close":"20:00"},"sun":{"kind":"open","open":"08:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5926425) < 0.00045
    and abs(s.longitude - 120.9720046) < 0.00045
);

-- node/6212730482
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$GF2 Muralla Street, Herald Building, Manila$ad$,
  14.5929756,
  120.977702,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"21:00"},"tue":{"kind":"open","open":"06:00","close":"21:00"},"wed":{"kind":"open","open":"06:00","close":"21:00"},"thu":{"kind":"open","open":"06:00","close":"21:00"},"fri":{"kind":"open","open":"06:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"20:00"},"sun":{"kind":"open","open":"07:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.5929756) < 0.00045
    and abs(s.longitude - 120.977702) < 0.00045
);

-- node/282388201
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Temple Drive, The Clubhouse, Quezon City$ad$,
  14.6001183,
  121.0691917,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:30","close":"00:30"},"tue":{"kind":"open","open":"06:30","close":"00:30"},"wed":{"kind":"open","open":"06:30","close":"00:30"},"thu":{"kind":"open","open":"06:30","close":"00:30"},"fri":{"kind":"open","open":"06:30","close":"00:30"},"sat":{"kind":"open","open":"06:30","close":"20:30"},"sun":{"kind":"open","open":"10:00","close":"01:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6001183) < 0.00045
    and abs(s.longitude - 121.0691917) < 0.00045
);

-- node/1707927638
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Missouri Street corner Nevada, San Juan$ad$,
  14.6018768,
  121.0529427,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:30","close":"00:00"},"tue":{"kind":"open","open":"06:30","close":"00:00"},"wed":{"kind":"open","open":"06:30","close":"00:00"},"thu":{"kind":"open","open":"06:30","close":"00:00"},"fri":{"kind":"open","open":"06:30","close":"00:00"},"sat":{"kind":"open","open":"06:30","close":"00:00"},"sun":{"kind":"open","open":"06:30","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6018768) < 0.00045
    and abs(s.longitude - 121.0529427) < 0.00045
);

-- way/581457169
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Santolan Road, Santolan Town Plaza, San Juan$ad$,
  14.6048506,
  121.0339064,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  $ph$+632 617 0887$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6048506) < 0.00045
    and abs(s.longitude - 121.0339064) < 0.00045
);

-- node/950619521
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Orchard Road, Eastwood City Walk 2, Quezon City$ad$,
  14.6096622,
  121.0814576,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"03:00"},"tue":{"kind":"open","open":"06:00","close":"03:00"},"wed":{"kind":"open","open":"06:00","close":"03:00"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"open","open":"06:00","close":"03:00"},"sun":{"kind":"open","open":"07:00","close":"01:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6096622) < 0.00045
    and abs(s.longitude - 121.0814576) < 0.00045
);

-- node/8633822978
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Katipunan Avenue, Arton Strip, Metro Manila$ad$,
  14.6208331,
  121.0732864,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"22:00"},"tue":{"kind":"open","open":"06:00","close":"22:00"},"wed":{"kind":"open","open":"06:00","close":"22:00"},"thu":{"kind":"open","open":"06:00","close":"22:00"},"fri":{"kind":"open","open":"06:00","close":"22:00"},"sat":{"kind":"open","open":"06:00","close":"22:00"},"sun":{"kind":"open","open":"06:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6208331) < 0.00045
    and abs(s.longitude - 121.0732864) < 0.00045
);

-- node/955522876
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$N. S. Amoranto Sr. Avenue, Quezon City$ad$,
  14.6312214,
  120.9981574,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:30","close":"00:30"},"tue":{"kind":"open","open":"06:30","close":"00:30"},"wed":{"kind":"open","open":"06:30","close":"00:30"},"thu":{"kind":"open","open":"06:30","close":"00:30"},"fri":{"kind":"open","open":"06:30","close":"00:30"},"sat":{"kind":"open","open":"06:30","close":"00:30"},"sun":{"kind":"open","open":"06:30","close":"00:30"}}$hr$::jsonb,
  $ph$+63 287492036$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6312214) < 0.00045
    and abs(s.longitude - 120.9981574) < 0.00045
);

-- node/457315783
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Timog Avenue, Imperial Palace Suites, Quezon City$ad$,
  14.6351832,
  121.0356066,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:30","close":"23:00"},"tue":{"kind":"open","open":"06:30","close":"23:00"},"wed":{"kind":"open","open":"06:30","close":"23:00"},"thu":{"kind":"open","open":"06:30","close":"23:00"},"fri":{"kind":"open","open":"06:30","close":"02:00"},"sat":{"kind":"open","open":"07:00","close":"02:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6351832) < 0.00045
    and abs(s.longitude - 121.0356066) < 0.00045
);

-- way/354591605
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$2 West 4th Street, Quezon City$ad$,
  14.6402564,
  121.0302901,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"00:00"},"tue":{"kind":"open","open":"06:00","close":"00:00"},"wed":{"kind":"open","open":"06:00","close":"00:00"},"thu":{"kind":"open","open":"06:00","close":"00:00"},"fri":{"kind":"open","open":"06:00","close":"00:30"},"sat":{"kind":"open","open":"07:00","close":"01:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  $ph$+6384263975$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6402564) < 0.00045
    and abs(s.longitude - 121.0302901) < 0.00045
);

-- node/10564872609
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Fernando Poe Jr. Avenue, Metro Manila$ad$,
  14.6491853,
  121.0174984,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:30"},"thu":{"kind":"open","open":"07:00","close":"00:30"},"fri":{"kind":"open","open":"07:00","close":"02:00"},"sat":{"kind":"open","open":"07:00","close":"02:00"},"sun":{"kind":"open","open":"07:00","close":"02:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6491853) < 0.00045
    and abs(s.longitude - 121.0174984) < 0.00045
);

-- node/7502513070
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$9th Street, Caloocan$ad$,
  14.6493153,
  120.990772,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"23:00"},"tue":{"kind":"open","open":"07:00","close":"23:00"},"wed":{"kind":"open","open":"07:00","close":"23:00"},"thu":{"kind":"open","open":"07:00","close":"23:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:30","close":"23:00"},"sun":{"kind":"open","open":"07:30","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6493153) < 0.00045
    and abs(s.longitude - 120.990772) < 0.00045
);

-- node/12450628576
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$SM North EDSA, Quezon City$ad$,
  14.6559154,
  121.0308324,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:30","close":"22:30"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:30"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6559154) < 0.00045
    and abs(s.longitude - 121.0308324) < 0.00045
);

-- node/6639869086
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$SM North EDSA, Quezon City$ad$,
  14.6563689,
  121.033064,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6563689) < 0.00045
    and abs(s.longitude - 121.033064) < 0.00045
);

-- way/1411743631
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$J. P. Rizal Street, Marikina$ad$,
  14.6672685,
  121.1078506,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"02:00"},"tue":{"kind":"open","open":"06:00","close":"02:00"},"wed":{"kind":"open","open":"06:00","close":"02:00"},"thu":{"kind":"open","open":"06:00","close":"02:00"},"fri":{"kind":"open","open":"06:00","close":"02:00"},"sat":{"kind":"open","open":"06:00","close":"02:00"},"sun":{"kind":"open","open":"06:00","close":"02:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6672685) < 0.00045
    and abs(s.longitude - 121.1078506) < 0.00045
);

-- way/252253624
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Mindanao Avenue, Quezon City$ad$,
  14.6805775,
  121.0316769,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:30","close":"22:00"},"tue":{"kind":"open","open":"07:30","close":"22:00"},"wed":{"kind":"open","open":"07:30","close":"22:00"},"thu":{"kind":"open","open":"07:30","close":"22:00"},"fri":{"kind":"open","open":"07:30","close":"22:00"},"sat":{"kind":"open","open":"08:30","close":"22:00"},"sun":{"kind":"open","open":"08:30","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.6805775) < 0.00045
    and abs(s.longitude - 121.0316769) < 0.00045
);

-- node/12830692363
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$Quirino Highway, Quezon City$ad$,
  14.7342983,
  121.053661,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"00:00"},"tue":{"kind":"open","open":"06:00","close":"00:00"},"wed":{"kind":"open","open":"06:00","close":"00:00"},"thu":{"kind":"open","open":"06:00","close":"00:00"},"fri":{"kind":"open","open":"06:00","close":"00:00"},"sat":{"kind":"open","open":"06:00","close":"00:00"},"sun":{"kind":"open","open":"06:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.7342983) < 0.00045
    and abs(s.longitude - 121.053661) < 0.00045
);

-- node/2857687134
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Starbucks$nm$,
  'OpenStreetMap',
  $ad$SM City Fairview, Metro Manila$ad$,
  14.7346756,
  121.0577131,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"22:30"},"tue":{"kind":"open","open":"09:00","close":"22:30"},"wed":{"kind":"open","open":"09:00","close":"22:30"},"thu":{"kind":"open","open":"09:00","close":"22:30"},"fri":{"kind":"open","open":"09:00","close":"22:30"},"sat":{"kind":"open","open":"09:00","close":"22:30"},"sun":{"kind":"open","open":"09:00","close":"22:30"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Starbucks$nm$))
    and abs(s.latitude - 14.7346756) < 0.00045
    and abs(s.longitude - 121.0577131) < 0.00045
);

-- node/12128146761
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Sumu Cafe & Creative Space$nm$,
  'OpenStreetMap',
  $ad$5, 6, 7 8010 España Boulevard, Grand Residences España 1, Manila$ad$,
  14.6063928,
  120.98885,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"03:00"},"tue":{"kind":"open","open":"09:00","close":"03:00"},"wed":{"kind":"open","open":"09:00","close":"03:00"},"thu":{"kind":"open","open":"09:00","close":"03:00"},"fri":{"kind":"open","open":"09:00","close":"03:00"},"sat":{"kind":"open","open":"09:00","close":"03:00"},"sun":{"kind":"open","open":"09:00","close":"03:00"}}$hr$::jsonb,
  $ph$+639629732061$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Sumu Cafe & Creative Space$nm$))
    and abs(s.latitude - 14.6063928) < 0.00045
    and abs(s.longitude - 120.98885) < 0.00045
);

-- node/10683777465
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Sweet Heart's Cafe and Events Place$nm$,
  'OpenStreetMap',
  $ad$203 Lexicor Building Alabang-Zapote Road, Las Piñas$ad$,
  14.4319081,
  121.0139705,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"02:00"},"tue":{"kind":"open","open":"11:00","close":"02:00"},"wed":{"kind":"open","open":"11:00","close":"02:00"},"thu":{"kind":"open","open":"11:00","close":"02:00"},"fri":{"kind":"open","open":"11:00","close":"02:00"},"sat":{"kind":"open","open":"11:00","close":"02:00"},"sun":{"kind":"open","open":"11:00","close":"02:00"}}$hr$::jsonb,
  $ph$+63 939 922 3239$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Sweet Heart's Cafe and Events Place$nm$))
    and abs(s.latitude - 14.4319081) < 0.00045
    and abs(s.longitude - 121.0139705) < 0.00045
);

-- node/13023110090
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Tealive$nm$,
  'OpenStreetMap',
  $ad$C. V. Starr Avenue corner Alabang-Zapote Road, Vista Mall Las Piñas, Las Piñas$ad$,
  14.4507081,
  120.9787946,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Tealive$nm$))
    and abs(s.latitude - 14.4507081) < 0.00045
    and abs(s.longitude - 120.9787946) < 0.00045
);

-- node/12498371768
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Tealive$nm$,
  'OpenStreetMap',
  $ad$Ayala Malls Manila Bay, Metro Manila$ad$,
  14.5222786,
  120.9885602,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Tealive$nm$))
    and abs(s.latitude - 14.5222786) < 0.00045
    and abs(s.longitude - 120.9885602) < 0.00045
);

-- node/2025925072
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Tealive$nm$,
  'OpenStreetMap',
  $ad$United Street corner EDSA, Mandaluyong$ad$,
  14.5789536,
  121.0525872,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Tealive$nm$))
    and abs(s.latitude - 14.5789536) < 0.00045
    and abs(s.longitude - 121.0525872) < 0.00045
);

-- way/797827685
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$TEATEA NI KAYE$nm$,
  'OpenStreetMap',
  $ad$Paquita Street, Metro Manila$ad$,
  14.7140202,
  121.0440796,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$TEATEA NI KAYE$nm$))
    and abs(s.latitude - 14.7140202) < 0.00045
    and abs(s.longitude - 121.0440796) < 0.00045
);

-- node/13013191320
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Beachhouse Sundries$nm$,
  'OpenStreetMap',
  $ad$C 11 East Capitol Drive, Metro Manila$ad$,
  14.5720088,
  121.0607172,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"21:00"},"tue":{"kind":"open","open":"09:00","close":"21:00"},"wed":{"kind":"open","open":"09:00","close":"21:00"},"thu":{"kind":"open","open":"09:00","close":"21:00"},"fri":{"kind":"open","open":"09:00","close":"21:00"},"sat":{"kind":"open","open":"09:00","close":"21:00"},"sun":{"kind":"open","open":"09:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Beachhouse Sundries$nm$))
    and abs(s.latitude - 14.5720088) < 0.00045
    and abs(s.longitude - 121.0607172) < 0.00045
);

-- node/4742597544
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Coffee Bean & Tea Leaf$nm$,
  'OpenStreetMap',
  $ad$National Road, Muntinlupa$ad$,
  14.4118382,
  121.0466842,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Coffee Bean & Tea Leaf$nm$))
    and abs(s.latitude - 14.4118382) < 0.00045
    and abs(s.longitude - 121.0466842) < 0.00045
);

-- node/4435497560
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Coffee Bean & Tea Leaf$nm$,
  'OpenStreetMap',
  $ad$Coral Way corner Jose W. Diokno Boulevard, MAAX Building, Pasay$ad$,
  14.5310438,
  120.9836621,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"00:00"},"tue":{"kind":"open","open":"10:00","close":"00:00"},"wed":{"kind":"open","open":"10:00","close":"00:00"},"thu":{"kind":"open","open":"10:00","close":"00:00"},"fri":{"kind":"open","open":"10:00","close":"00:00"},"sat":{"kind":"open","open":"10:00","close":"00:00"},"sun":{"kind":"open","open":"10:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Coffee Bean & Tea Leaf$nm$))
    and abs(s.latitude - 14.5310438) < 0.00045
    and abs(s.longitude - 120.9836621) < 0.00045
);

-- node/4551155224
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Coffee Bean & Tea Leaf$nm$,
  'OpenStreetMap',
  $ad$EDSA corner Shaw Boulevard, Shangri-La Plaza, Mandaluyong$ad$,
  14.5812895,
  121.0552592,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"11:00"},"tue":{"kind":"open","open":"07:00","close":"11:00"},"wed":{"kind":"open","open":"07:00","close":"11:00"},"thu":{"kind":"open","open":"07:00","close":"11:00"},"fri":{"kind":"open","open":"07:00","close":"11:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Coffee Bean & Tea Leaf$nm$))
    and abs(s.latitude - 14.5812895) < 0.00045
    and abs(s.longitude - 121.0552592) < 0.00045
);

-- node/10070750512
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Coffee Bean & Tea Leaf$nm$,
  'OpenStreetMap',
  $ad$Doña Julia Vargas Avenue, Metro Manila$ad$,
  14.584147,
  121.057652,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Coffee Bean & Tea Leaf$nm$))
    and abs(s.latitude - 14.584147) < 0.00045
    and abs(s.longitude - 121.057652) < 0.00045
);

-- node/795816573
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Coffee Bean & Tea Leaf$nm$,
  'OpenStreetMap',
  $ad$Orchard Road, 1800 Eastwood Avenue, Quezon City$ad$,
  14.6096674,
  121.0797462,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:30","close":"20:00"},"tue":{"kind":"open","open":"08:30","close":"20:00"},"wed":{"kind":"open","open":"08:30","close":"20:00"},"thu":{"kind":"open","open":"08:30","close":"20:00"},"fri":{"kind":"open","open":"08:30","close":"20:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Coffee Bean & Tea Leaf$nm$))
    and abs(s.latitude - 14.6096674) < 0.00045
    and abs(s.longitude - 121.0797462) < 0.00045
);

-- node/3678117064
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Curator$nm$,
  'OpenStreetMap',
  $ad$134 Legazpi Street, Makati$ad$,
  14.5543777,
  121.0181983,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"02:00"},"tue":{"kind":"open","open":"07:00","close":"02:00"},"wed":{"kind":"open","open":"07:00","close":"02:00"},"thu":{"kind":"open","open":"07:00","close":"02:00"},"fri":{"kind":"open","open":"07:00","close":"02:00"},"sat":{"kind":"open","open":"07:00","close":"02:00"},"sun":{"kind":"open","open":"07:00","close":"19:00"}}$hr$::jsonb,
  $ph$+63 916 3554129$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Curator$nm$))
    and abs(s.latitude - 14.5543777) < 0.00045
    and abs(s.longitude - 121.0181983) < 0.00045
);

-- node/5558725558
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Den$nm$,
  'OpenStreetMap',
  $ad$413 Escolta Street, First United Building, Manila$ad$,
  14.5987907,
  120.9792011,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"11:00","close":"21:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"open","open":"11:00","close":"19:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Den$nm$))
    and abs(s.latitude - 14.5987907) < 0.00045
    and abs(s.longitude - 120.9792011) < 0.00045
);

-- node/8326628617
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Fat Seed$nm$,
  'OpenStreetMap',
  $ad$1 27th Street, One Maridien, Metro Manila$ad$,
  14.5489376,
  121.0502061,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  $ph$0270011862$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Fat Seed$nm$))
    and abs(s.latitude - 14.5489376) < 0.00045
    and abs(s.longitude - 121.0502061) < 0.00045
);

-- node/6267552208
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Giving Café$nm$,
  'OpenStreetMap',
  $ad$Sheridan Street, Metro Manila$ad$,
  14.573233,
  121.0519403,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Giving Café$nm$))
    and abs(s.latitude - 14.573233) < 0.00045
    and abs(s.longitude - 121.0519403) < 0.00045
);

-- node/10099988517
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Gram Coffee$nm$,
  'OpenStreetMap',
  $ad$Primo Cruz Street, Metro Manila$ad$,
  14.5803872,
  121.0286867,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"22:00"},"tue":{"kind":"open","open":"08:00","close":"22:00"},"wed":{"kind":"open","open":"08:00","close":"22:00"},"thu":{"kind":"open","open":"08:00","close":"22:00"},"fri":{"kind":"open","open":"08:00","close":"22:00"},"sat":{"kind":"open","open":"08:00","close":"22:00"},"sun":{"kind":"open","open":"08:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Gram Coffee$nm$))
    and abs(s.latitude - 14.5803872) < 0.00045
    and abs(s.longitude - 121.0286867) < 0.00045
);

-- node/13469837233
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Lazy Cat$nm$,
  'OpenStreetMap',
  $ad$3425 General V. Lim Street, Makati$ad$,
  14.5437789,
  121.0116143,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"11:00","close":"21:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"11:00","close":"21:00"},"sun":{"kind":"open","open":"11:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Lazy Cat$nm$))
    and abs(s.latitude - 14.5437789) < 0.00045
    and abs(s.longitude - 121.0116143) < 0.00045
);

-- node/14019242862
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Ministry of Coffee$nm$,
  'OpenStreetMap',
  $ad$Taft Avenue, Manila$ad$,
  14.563338,
  120.9949367,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:30","close":"20:30"},"tue":{"kind":"open","open":"07:30","close":"20:30"},"wed":{"kind":"open","open":"07:30","close":"20:30"},"thu":{"kind":"open","open":"07:30","close":"20:30"},"fri":{"kind":"open","open":"07:30","close":"20:30"},"sat":{"kind":"open","open":"07:30","close":"20:30"},"sun":{"kind":"open","open":"07:30","close":"20:30"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Ministry of Coffee$nm$))
    and abs(s.latitude - 14.563338) < 0.00045
    and abs(s.longitude - 120.9949367) < 0.00045
);

-- node/6130332285
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Northern Coffee Experience$nm$,
  'OpenStreetMap',
  $ad$General Araneta Avenue, Metro Manila$ad$,
  14.618846,
  121.052422,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"18:00"},"tue":{"kind":"open","open":"09:00","close":"18:00"},"wed":{"kind":"open","open":"09:00","close":"18:00"},"thu":{"kind":"open","open":"09:00","close":"18:00"},"fri":{"kind":"open","open":"09:00","close":"18:00"},"sat":{"kind":"open","open":"09:00","close":"18:00"},"sun":{"kind":"open","open":"09:00","close":"18:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Northern Coffee Experience$nm$))
    and abs(s.latitude - 14.618846) < 0.00045
    and abs(s.longitude - 121.052422) < 0.00045
);

-- node/10078637168
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$The Wallflower Café$nm$,
  'OpenStreetMap',
  $ad$Alabang-Zapote Road, Muntinlupa$ad$,
  14.4233625,
  121.0298278,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"11:00","close":"21:00"},"tue":{"kind":"open","open":"11:00","close":"21:00"},"wed":{"kind":"open","open":"11:00","close":"21:00"},"thu":{"kind":"open","open":"11:00","close":"21:00"},"fri":{"kind":"open","open":"11:00","close":"21:00"},"sat":{"kind":"open","open":"10:00","close":"21:00"},"sun":{"kind":"open","open":"10:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$The Wallflower Café$nm$))
    and abs(s.latitude - 14.4233625) < 0.00045
    and abs(s.longitude - 121.0298278) < 0.00045
);

-- node/7801248349
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Tim Hortons$nm$,
  'OpenStreetMap',
  $ad$Upper McKinley Road, Taguig$ad$,
  14.534558,
  121.0502969,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Tim Hortons$nm$))
    and abs(s.latitude - 14.534558) < 0.00045
    and abs(s.longitude - 121.0502969) < 0.00045
);

-- node/7798186085
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Tim Hortons$nm$,
  'OpenStreetMap',
  $ad$Burgos Circle, Taguig$ad$,
  14.552386,
  121.0440129,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"09:00","close":"18:00"},"tue":{"kind":"open","open":"09:00","close":"18:00"},"wed":{"kind":"open","open":"09:00","close":"18:00"},"thu":{"kind":"open","open":"09:00","close":"18:00"},"fri":{"kind":"open","open":"09:00","close":"18:00"},"sat":{"kind":"open","open":"09:00","close":"18:00"},"sun":{"kind":"open","open":"09:00","close":"18:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Tim Hortons$nm$))
    and abs(s.latitude - 14.552386) < 0.00045
    and abs(s.longitude - 121.0440129) < 0.00045
);

-- node/5807612430
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Tim Hortons$nm$,
  'OpenStreetMap',
  $ad$11th Drive, Taguig$ad$,
  14.5558262,
  121.054276,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Tim Hortons$nm$))
    and abs(s.latitude - 14.5558262) < 0.00045
    and abs(s.longitude - 121.054276) < 0.00045
);

-- node/7895964285
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Tim Hortons$nm$,
  'OpenStreetMap',
  $ad$Taft Avenue, Metro Manila$ad$,
  14.5623907,
  120.9953994,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:00"},"tue":{"kind":"open","open":"07:00","close":"21:00"},"wed":{"kind":"open","open":"07:00","close":"21:00"},"thu":{"kind":"open","open":"07:00","close":"21:00"},"fri":{"kind":"open","open":"07:00","close":"21:00"},"sat":{"kind":"open","open":"07:00","close":"21:00"},"sun":{"kind":"open","open":"07:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Tim Hortons$nm$))
    and abs(s.latitude - 14.5623907) < 0.00045
    and abs(s.longitude - 120.9953994) < 0.00045
);

-- node/5784147226
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$TNC$nm$,
  'OpenStreetMap',
  $ad$41 Aurora Boulevard, Quezon City$ad$,
  14.6086728,
  121.0213555,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$TNC$nm$))
    and abs(s.latitude - 14.6086728) < 0.00045
    and abs(s.longitude - 121.0213555) < 0.00045
);

-- node/5480890050
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Toby's Estate$nm$,
  'OpenStreetMap',
  $ad$Legazpi Street corner Rodriguez, Senta, Makati$ad$,
  14.5546813,
  121.0168619,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"20:00"},"tue":{"kind":"open","open":"07:00","close":"20:00"},"wed":{"kind":"open","open":"07:00","close":"20:00"},"thu":{"kind":"open","open":"07:00","close":"20:00"},"fri":{"kind":"open","open":"07:00","close":"20:00"},"sat":{"kind":"open","open":"07:00","close":"20:00"},"sun":{"kind":"open","open":"07:00","close":"20:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Toby's Estate$nm$))
    and abs(s.latitude - 14.5546813) < 0.00045
    and abs(s.longitude - 121.0168619) < 0.00045
);

-- node/3868535670
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Toby's Estate$nm$,
  'OpenStreetMap',
  $ad$Ruby Road, Robinsons Cyberscape Beta, Pasig$ad$,
  14.5879381,
  121.0608845,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"17:00"},"tue":{"kind":"open","open":"07:00","close":"17:00"},"wed":{"kind":"open","open":"07:00","close":"17:00"},"thu":{"kind":"open","open":"07:00","close":"17:00"},"fri":{"kind":"open","open":"07:00","close":"17:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Toby's Estate$nm$))
    and abs(s.latitude - 14.5879381) < 0.00045
    and abs(s.longitude - 121.0608845) < 0.00045
);

-- node/1682598400
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Tokyo Bubble Tea$nm$,
  'OpenStreetMap',
  $ad$229 Wilson Street, Wilson View, Metro Manila$ad$,
  14.597538,
  121.0412306,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"21:00"},"tue":{"kind":"open","open":"10:00","close":"21:00"},"wed":{"kind":"open","open":"10:00","close":"21:00"},"thu":{"kind":"open","open":"10:00","close":"21:00"},"fri":{"kind":"open","open":"10:00","close":"21:00"},"sat":{"kind":"open","open":"10:00","close":"21:00"},"sun":{"kind":"open","open":"10:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63 2 8584 1998$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Tokyo Bubble Tea$nm$))
    and abs(s.latitude - 14.597538) < 0.00045
    and abs(s.longitude - 121.0412306) < 0.00045
);

-- node/12414857139
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Tomoro Coffee$nm$,
  'OpenStreetMap',
  $ad$Nicanor Reyes Street, Metro Manila$ad$,
  14.6043319,
  120.9878372,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"23:00"},"tue":{"kind":"open","open":"07:00","close":"23:00"},"wed":{"kind":"open","open":"07:00","close":"23:00"},"thu":{"kind":"open","open":"07:00","close":"23:00"},"fri":{"kind":"open","open":"07:00","close":"23:00"},"sat":{"kind":"open","open":"07:00","close":"23:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Tomoro Coffee$nm$))
    and abs(s.latitude - 14.6043319) < 0.00045
    and abs(s.longitude - 120.9878372) < 0.00045
);

-- node/8620447455
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$TSA-GA Pinoy Milk Tea$nm$,
  'OpenStreetMap',
  $ad$2979 Jenny's Avenue, Pasig$ad$,
  14.5899998,
  121.091152,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"18:00"},"tue":{"kind":"open","open":"10:00","close":"18:00"},"wed":{"kind":"open","open":"10:00","close":"18:00"},"thu":{"kind":"open","open":"10:00","close":"18:00"},"fri":{"kind":"open","open":"10:00","close":"18:00"},"sat":{"kind":"open","open":"10:00","close":"18:00"},"sun":{"kind":"open","open":"10:00","close":"18:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$TSA-GA Pinoy Milk Tea$nm$))
    and abs(s.latitude - 14.5899998) < 0.00045
    and abs(s.longitude - 121.091152) < 0.00045
);

-- node/14049177801
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Type A - NBS Park$nm$,
  'OpenStreetMap',
  $ad$Pioneer Street, Metro Manila$ad$,
  14.5723194,
  121.0532404,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"08:00","close":"18:00"},"wed":{"kind":"open","open":"08:00","close":"18:00"},"thu":{"kind":"open","open":"08:00","close":"18:00"},"fri":{"kind":"open","open":"08:00","close":"18:00"},"sat":{"kind":"open","open":"08:00","close":"18:00"},"sun":{"kind":"open","open":"08:00","close":"18:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Type A - NBS Park$nm$))
    and abs(s.latitude - 14.5723194) < 0.00045
    and abs(s.longitude - 121.0532404) < 0.00045
);

-- node/1707923384
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$UCC Coffee Vienna Cafe$nm$,
  'OpenStreetMap',
  $ad$Temple Drive, The Clubhouse, Quezon City$ad$,
  14.5998934,
  121.0691495,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"00:00"},"sat":{"kind":"open","open":"07:00","close":"00:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$UCC Coffee Vienna Cafe$nm$))
    and abs(s.latitude - 14.5998934) < 0.00045
    and abs(s.longitude - 121.0691495) < 0.00045
);

-- node/12765860681
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$UCC Park Café$nm$,
  'OpenStreetMap',
  $ad$1 Eastwood Avenue, Tower 2, One Eastwood Avenue, Quezon City$ad$,
  14.6082266,
  121.0799849,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"00:00"},"tue":{"kind":"open","open":"07:00","close":"00:00"},"wed":{"kind":"open","open":"07:00","close":"00:00"},"thu":{"kind":"open","open":"07:00","close":"00:00"},"fri":{"kind":"open","open":"07:00","close":"01:00"},"sat":{"kind":"open","open":"07:00","close":"01:00"},"sun":{"kind":"open","open":"07:00","close":"00:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$UCC Park Café$nm$))
    and abs(s.latitude - 14.6082266) < 0.00045
    and abs(s.longitude - 121.0799849) < 0.00045
);

-- node/11757381698
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Unnie Cafe$nm$,
  'OpenStreetMap',
  $ad$1768-C Taft Avenue, Metro Manila$ad$,
  14.5593277,
  120.9960653,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"20:00"},"tue":{"kind":"open","open":"10:00","close":"20:00"},"wed":{"kind":"open","open":"10:00","close":"20:00"},"thu":{"kind":"open","open":"10:00","close":"20:00"},"fri":{"kind":"open","open":"10:00","close":"20:00"},"sat":{"kind":"closed"},"sun":{"kind":"closed"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Unnie Cafe$nm$))
    and abs(s.latitude - 14.5593277) < 0.00045
    and abs(s.longitude - 120.9960653) < 0.00045
);

-- node/3661058051
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Vanilla Bakery and Cafe$nm$,
  'OpenStreetMap',
  $ad$Ascencion Avenue, Quezon City$ad$,
  14.7239211,
  121.0672092,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Vanilla Bakery and Cafe$nm$))
    and abs(s.latitude - 14.7239211) < 0.00045
    and abs(s.longitude - 121.0672092) < 0.00045
);

-- way/460351313
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Verse Cafe 3:16$nm$,
  'OpenStreetMap',
  $ad$P. Burgos Street, Metro Manila$ad$,
  14.5926551,
  121.0385055,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"22:00"},"tue":{"kind":"open","open":"07:00","close":"22:00"},"wed":{"kind":"open","open":"07:00","close":"22:00"},"thu":{"kind":"open","open":"07:00","close":"22:00"},"fri":{"kind":"open","open":"07:00","close":"22:00"},"sat":{"kind":"open","open":"07:00","close":"22:00"},"sun":{"kind":"open","open":"07:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Verse Cafe 3:16$nm$))
    and abs(s.latitude - 14.5926551) < 0.00045
    and abs(s.longitude - 121.0385055) < 0.00045
);

-- node/11555491056
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$What About Coffee?$nm$,
  'OpenStreetMap',
  $ad$Gomburza Street, University Hotel, Metro Manila$ad$,
  14.6611469,
  121.0728529,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"21:00"},"tue":{"kind":"open","open":"06:00","close":"21:00"},"wed":{"kind":"open","open":"06:00","close":"21:00"},"thu":{"kind":"open","open":"06:00","close":"21:00"},"fri":{"kind":"open","open":"06:00","close":"21:00"},"sat":{"kind":"open","open":"06:00","close":"21:00"},"sun":{"kind":"open","open":"06:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$What About Coffee?$nm$))
    and abs(s.latitude - 14.6611469) < 0.00045
    and abs(s.longitude - 121.0728529) < 0.00045
);

-- node/10196122994
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Yani Café$nm$,
  'OpenStreetMap',
  $ad$9 A. Mabini Street, Metro Manila$ad$,
  14.564808,
  121.0756667,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"12:00","close":"21:00"},"tue":{"kind":"open","open":"12:00","close":"21:00"},"wed":{"kind":"open","open":"12:00","close":"21:00"},"thu":{"kind":"open","open":"12:00","close":"21:00"},"fri":{"kind":"open","open":"12:00","close":"21:00"},"sat":{"kind":"open","open":"12:00","close":"21:00"},"sun":{"kind":"open","open":"12:00","close":"21:00"}}$hr$::jsonb,
  $ph$+63277527533$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Yani Café$nm$))
    and abs(s.latitude - 14.564808) < 0.00045
    and abs(s.longitude - 121.0756667) < 0.00045
);

-- node/12047820209
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Zero Degree Espresso Bar$nm$,
  'OpenStreetMap',
  $ad$437 Calabash B Street, Sampaloc$ad$,
  14.6100843,
  121.0036909,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"closed"},"tue":{"kind":"open","open":"14:00","close":"22:00"},"wed":{"kind":"open","open":"14:00","close":"22:00"},"thu":{"kind":"open","open":"14:00","close":"22:00"},"fri":{"kind":"open","open":"14:00","close":"22:00"},"sat":{"kind":"open","open":"14:00","close":"22:00"},"sun":{"kind":"open","open":"14:00","close":"22:00"}}$hr$::jsonb,
  $ph$+639266014693$ph$,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Zero Degree Espresso Bar$nm$))
    and abs(s.latitude - 14.6100843) < 0.00045
    and abs(s.longitude - 121.0036909) < 0.00045
);

-- node/655184647
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$ZUS Coffee$nm$,
  'OpenStreetMap',
  $ad$Taft Avenue, Manila$ad$,
  14.5631444,
  120.9946482,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"21:45"},"tue":{"kind":"open","open":"06:00","close":"21:45"},"wed":{"kind":"open","open":"06:00","close":"21:45"},"thu":{"kind":"open","open":"06:00","close":"21:45"},"fri":{"kind":"open","open":"06:00","close":"21:45"},"sat":{"kind":"open","open":"06:00","close":"21:45"},"sun":{"kind":"open","open":"06:00","close":"21:45"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$ZUS Coffee$nm$))
    and abs(s.latitude - 14.5631444) < 0.00045
    and abs(s.longitude - 120.9946482) < 0.00045
);

-- node/12647066223
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Zus Coffee$nm$,
  'OpenStreetMap',
  $ad$Pedro Gil Steet cor. Paz Street, Barangay 681, Zone 74, District V, Paco$ad$,
  14.5786951,
  120.9957798,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"06:00","close":"21:00"},"tue":{"kind":"open","open":"06:00","close":"21:00"},"wed":{"kind":"open","open":"06:00","close":"21:00"},"thu":{"kind":"open","open":"06:00","close":"21:00"},"fri":{"kind":"open","open":"06:00","close":"21:00"},"sat":{"kind":"open","open":"06:00","close":"21:00"},"sun":{"kind":"open","open":"06:00","close":"21:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Zus Coffee$nm$))
    and abs(s.latitude - 14.5786951) < 0.00045
    and abs(s.longitude - 120.9957798) < 0.00045
);

-- node/13354763514
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$ZUS Coffee$nm$,
  'OpenStreetMap',
  $ad$City Hall Road, Marikina$ad$,
  14.6332371,
  121.0983235,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:40"},"tue":{"kind":"open","open":"07:00","close":"21:40"},"wed":{"kind":"open","open":"07:00","close":"21:40"},"thu":{"kind":"open","open":"07:00","close":"21:40"},"fri":{"kind":"open","open":"07:00","close":"21:40"},"sat":{"kind":"open","open":"07:00","close":"21:40"},"sun":{"kind":"open","open":"07:00","close":"21:40"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$ZUS Coffee$nm$))
    and abs(s.latitude - 14.6332371) < 0.00045
    and abs(s.longitude - 121.0983235) < 0.00045
);

-- node/13612402711
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$ZUS Coffee$nm$,
  'OpenStreetMap',
  $ad$Sumulong Highway, Metro Manila$ad$,
  14.6354272,
  121.1009484,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"07:00","close":"21:40"},"tue":{"kind":"open","open":"07:00","close":"21:40"},"wed":{"kind":"open","open":"07:00","close":"21:40"},"thu":{"kind":"open","open":"07:00","close":"21:40"},"fri":{"kind":"open","open":"07:00","close":"21:40"},"sat":{"kind":"open","open":"07:00","close":"21:40"},"sun":{"kind":"open","open":"07:00","close":"21:40"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$ZUS Coffee$nm$))
    and abs(s.latitude - 14.6354272) < 0.00045
    and abs(s.longitude - 121.1009484) < 0.00045
);

-- node/14050283776
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$Zus Coffee$nm$,
  'OpenStreetMap',
  $ad$SM North EDSA, Quezon City$ad$,
  14.6561021,
  121.0304113,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"10:00","close":"22:00"},"tue":{"kind":"open","open":"10:00","close":"22:00"},"wed":{"kind":"open","open":"10:00","close":"22:00"},"thu":{"kind":"open","open":"10:00","close":"22:00"},"fri":{"kind":"open","open":"10:00","close":"22:00"},"sat":{"kind":"open","open":"10:00","close":"22:00"},"sun":{"kind":"open","open":"10:00","close":"22:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$Zus Coffee$nm$))
    and abs(s.latitude - 14.6561021) < 0.00045
    and abs(s.longitude - 121.0304113) < 0.00045
);

-- node/12690311039
insert into public.shops (
  name, description, address, latitude, longitude, categories, hours, contact_number, status
)
select
  $nm$éllatte coffee$nm$,
  'OpenStreetMap',
  $ad$Taft Avenue, Burgundy Transpacific Place, Metro Manila$ad$,
  14.5652935,
  120.9943802,
  '{cafe}'::text[],
  $hr${"mon":{"kind":"open","open":"08:00","close":"23:00"},"tue":{"kind":"open","open":"08:00","close":"23:00"},"wed":{"kind":"open","open":"08:00","close":"23:00"},"thu":{"kind":"open","open":"08:00","close":"23:00"},"fri":{"kind":"open","open":"08:00","close":"23:00"},"sat":{"kind":"open","open":"08:00","close":"23:00"},"sun":{"kind":"open","open":"08:00","close":"23:00"}}$hr$::jsonb,
  null,
  'pending'
where not exists (
  select 1 from public.shops s
  where lower(trim(s.name)) = lower(trim($nm$éllatte coffee$nm$))
    and abs(s.latitude - 14.5652935) < 0.00045
    and abs(s.longitude - 120.9943802) < 0.00045
);

commit;
