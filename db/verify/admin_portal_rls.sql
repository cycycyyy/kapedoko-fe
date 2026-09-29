-- =========================================================
-- KapéDoko — Admin portal RLS checks (manual)
-- =========================================================
-- Run in the SQL editor as the table owner, then repeat
-- selected statements with an anon key and a normal user
-- JWT. Expected outcomes are in comments.
-- =========================================================

-- Anonymous / normal user: admin RPCs must fail.
-- select public.create_admin_shop('Ab', '123 Street', 14.6, 121.0, '{}'::jsonb);
-- Expected: Admin only  OR hours/name validation — never a row for anon.

-- Anonymous insert into shops as approved must fail (trigger + RLS).
-- insert into public.shops (name, address, latitude, longitude, hours, status)
-- values ('Nope', 'Not allowed street', 14.55, 121.02, '{}'::jsonb, 'approved');
-- Expected: New shops must start as pending  and/or RLS.

-- Coverage still blocks ordinary inserts outside Metro Manila.
-- (Use a pending insert as a signed-in non-admin near Antipolo.)
-- Expected: shops_in_coverage.

-- Non-admin cannot read admin_audit_log.
-- select count(*) from public.admin_audit_log;
-- Expected: 0 rows for anon/user; admins see their writes.

-- Non-admin cannot change another profile role.
-- select public.admin_set_profile_role('00000000-0000-0000-0000-000000000000', 'admin');
-- Expected: Admin only.

-- Public ad reads hide inactive campaigns.
-- insert (as admin) a campaign with ends_at in the past, then:
-- select * from public.active_ad_campaigns;
-- Expected: only enabled, in-window, non-cancelled rows.

-- Admin can create an approved cafe outside coverage via RPC.
-- select public.create_admin_shop(
--   'Admin Cafe',
--   '1 Example Street Cebu',
--   10.3157,
--   123.8854,
--   '{"mon":{"kind":"all_day"},"tue":{"kind":"all_day"},"wed":{"kind":"all_day"},"thu":{"kind":"all_day"},"fri":{"kind":"all_day"},"sat":{"kind":"all_day"},"sun":{"kind":"all_day"}}'::jsonb
-- );
-- Expected: status = approved.

-- Direct approved → rejected is still illegal.
-- update public.shops set status = 'rejected' where status = 'approved' limit 1;
-- Expected: Illegal shop status transition.
