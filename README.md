# KapeDoko FE

Nuxt 4 frontend with Ionic app shell, shadcn-vue style components, and Capacitor mobile support.

## Setup

```bash
bun install
```

Create a `.env` file from `.env.example` and set the Supabase project URL and publishable key.

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
