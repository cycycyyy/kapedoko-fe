# KapeDoko FE

Nuxt 4 frontend with Ionic app shell, shadcn-vue style components, and Capacitor mobile support.

## Setup

```bash
bun install
```

Create a `.env` file from `.env.example` and set the Supabase project URL and publishable key.

Apply the SQL files in `db/` in filename order in the Supabase SQL editor, including `20260929_admin_portal.sql` and `20260929_admin_portal_fix.sql`. The portal migration adds audit logging, approved cafe creation, placements RPC, ad campaigns, and role changes. The fix file casts shop status to the live `shop_status` enum and creates `content_reports` if that table is missing. Deploy the Edge Functions from `db/functions/` (`presign-upload` and `admin-users`) so banner uploads and user suspend/reactivate work. Deploy `admin-users` with `--no-verify-jwt` (auth is checked inside the function); include `db/functions/admin-users/config.toml` when copying into `supabase/functions`. Optional RLS checks live in `db/verify/admin_portal_rls.sql`. In Supabase Auth, allow redirects to `/confirm` and `/reset-password` on each origin you use. Mobile builds store the session in local storage (`NUXT_PUBLIC_AUTH_STORAGE=local` via `bun run build:mobile`) because Capacitor WebViews do not keep the web cookie session.

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
