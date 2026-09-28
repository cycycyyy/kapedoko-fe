# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

Primary users are people in the Philippines, especially Metro Manila, who need a cafe to sit and work. They open the app to find a place with WiFi, power outlets, and usable open hours—not to browse coffee as a hobby.

## Product Purpose

KapeDoko helps someone choose a coffee shop they can actually work from: search and scan nearby cafes, see WiFi and outlet availability, check hours, and get to the exact location. Success is picking a cafe with confidence and arriving without discovering too late that there is no WiFi, no plug, or that the shop is closed.

## Positioning

KapeDoko is a Philippines-specific cafe guide whose job is work-readiness, not generic discovery. A maps app or worldwide cafe directory could list shops; it could not truthfully claim local coverage plus WiFi, outlets, and hours as the reason to choose one cafe over another.

## Operating Context

Used on a phone, often while already out or about to leave: search a shop by name or area, filter by Near You / Popular / WiFi / Plugs, scan a list of cards (photo, rating, open/closed, address, amenity icons), and use maps for the exact location. Cafe submissions and public listings currently cover Metro Manila (NCR) only; pins outside that boundary are blocked. First-run onboarding teaches the WiFi and plug icons, then maps. A bottom bar opens Home, saved cafes, Map, and Profile. Accounts use Supabase email and password, including registration, password reset, and sign-out. Guests can browse and save cafes on the device; signing in syncs those saves to the account. The same UI ships as a web app and as Capacitor iOS/Android shells.

## Capabilities and Constraints

- Confirmed in product intent: cafe search, amenity-aware listing (WiFi, power outlets), open/closed status, filters, maps for location, saved cafes, profile, first-run onboarding.
- One shared UI across web and Capacitor iOS/Android. Do not split into separate iOS vs Android design languages.
- Current coverage is Metro Manila (NCR). Expansion outside Metro Manila is later work; do not pretend nationwide coverage.
- Cafe submissions outside Metro Manila are blocked until a later region is activated.
- Home and Search list approved shops. WiFi and outlet claims appear only after enough reviews; until then the app says they are not confirmed. Do not treat sample shop names, ratings, or stock images as real product evidence.
- Auth implementation (Supabase) is present in the repo; keeping that vendor is not a confirmed product commitment.
- Push notifications are not part of the current app. Featured placements are later work and are not shown as live cafes.

## Brand Commitments

Name is **KapeDoko**, also styled **kapé DOKO** in the wordmark. Keep existing logo and wordmark assets (dark/light marks, horizontal text, stacked text, SVG lockup, home watermark). Do not invent a different product name.

## Evidence on Hand

Brand assets live under `public/assets/` and `app/assets/css/logos/`. Onboarding copy and home UI copy are real product language. Cafe listings, ratings, and photography currently in the home screen are mock. Do not fabricate testimonials, press, real cafe coverage claims, or user counts.

## Product Principles

- Choose a cafe to work, not to window-shop coffee.
- Amenity truth (WiFi, outlets, hours, location) outranks atmosphere copy.
- Stay local: current service area is Metro Manila; do not pretend nationwide or worldwide coverage.
- Treat placeholder data as scaffolding; never present it as proof.
- Ship one interface people can learn once, on phone or in a native wrapper.

## Accessibility & Inclusion

Aim for WCAG 2.2 AA. Respect reduced motion. Keep amenity and status information available as text or accessible names, not icons alone.
