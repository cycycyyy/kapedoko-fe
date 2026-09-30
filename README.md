# KapeDoko FE

Nuxt 4 frontend with Ionic app shell, shadcn-vue style components, and Capacitor mobile support.

## Setup

```bash
bun install
```

Create a `.env` file from `.env.example` and set the Supabase project URL and publishable key.

Apply the SQL files in `db/` in filename order in the Supabase SQL editor, including `20260929_admin_portal.sql`, `20260929_admin_portal_fix.sql`, `20260929_philippines_coverage.sql`, `20260930_user_role_cafe_owner.sql`, `20260930_cafe_owners_catalog.sql`, `20260930_withdraw_shop_claim.sql`, `20260930_sync_cafe_owner_role_cast.sql`, `20260930_sync_cafe_owner_role_enum_assign.sql`, and `20260930_list_my_shop_claims.sql`. The role file adds `cafe-owner` to the live `user_role` enum; run it as its own query so the catalog file can use the new label. If `user_role` does not exist, skip that file. The Philippines file lets public cafe submissions be pinned anywhere in the country. The owners file adds the `cafe-owner` role, OSM provenance columns, and admin-reviewed cafe claims. The portal migration adds audit logging, approved cafe creation, placements RPC, ad campaigns, and role changes. The fix file casts shop status to the live `shop_status` enum and creates `content_reports` if that table is missing. Deploy the Edge Functions from `db/functions/` (`presign-upload` and `admin-users`) so banner uploads and user suspend/reactivate work. Deploy `admin-users` with `--no-verify-jwt` (auth is checked inside the function); include `db/functions/admin-users/config.toml` when copying into `supabase/functions`. Optional RLS checks live in `db/verify/admin_portal_rls.sql`. In Supabase Auth, allow redirects to `/confirm` and `/reset-password` on each origin you use. Mobile builds store the session in local storage (`NUXT_PUBLIC_AUTH_STORAGE=local` via `bun run build:mobile`) because Capacitor WebViews do not keep the web cookie session.

Cafe catalog imports come from OpenStreetMap Overpass (`amenity=cafe`) for Metro Manila, Cebu City, and Davao City. Run `bun run import:osm` to write `db/seed_osm_cafes.sql`, then apply that file in the SQL editor. The importer queries city bounding boxes in tiles, caches them in `.cache/osm-import/`, waits between tiles, and fails over across Overpass mirrors. Re-run the same command after a 429 or 504 — finished tiles are reused. If the public API is saturated, wait a minute and run it again. Rows start as pending and go through `/admin/requests`. Place data is © OpenStreetMap contributors (ODbL). The importer does not invent Wi-Fi, plugs, photos, or logos. Cafe owners claim a listed shop from its page; admins verify claims at `/admin/claims`. Verified owners can edit identity, hours, contact, and logo only.

## Development

```bash
bun dev
```

## Build and preview

```bash
bun run build
bun run preview
```

## Ionic + shadcn-vue notes

- Ionic is the primary app container (`IonApp` + `IonRouterOutlet`) and each page uses Ionic page primitives.
- shadcn-vue foundation is configured through `shadcn-nuxt` with UI components in `/home/runner/work/kapedoko-fe/kapedoko-fe/app/components/ui`.
- Tailwind config lives in `/home/runner/work/kapedoko-fe/kapedoko-fe/tailwind.config.ts`.
- CSS layering is explicit: Tailwind tokens/utilities first, then Ionic CSS (`app/assets/css/ionic.css`).

## Capacitor workflows

Generate a static web build for Capacitor:

```bash
bun run build:mobile
```

Sync web assets and plugins:

```bash
bun run cap:sync
```

Open native projects:

```bash
bun run cap:android
bun run cap:ios
```

## Platform prerequisites

- Android: Android Studio + Android SDK.
- iOS: macOS with Xcode and CocoaPods.
