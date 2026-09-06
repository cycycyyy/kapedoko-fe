# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Primary users are people in the Philippines, especially Metro Manila, who need a cafe to sit and work. They open the app to find a place with WiFi, power outlets, and usable open hours—not to browse coffee as a hobby.

## Product Purpose

KapeDoko helps someone choose a coffee shop they can actually work from: search and scan nearby cafes, see WiFi and outlet availability, check hours, and get to the exact location. Success is picking a cafe with confidence and arriving without discovering too late that there is no WiFi, no plug, or that the shop is closed.

## Positioning

KapeDoko is a Philippines-specific cafe guide whose job is work-readiness, not generic discovery. A maps app or worldwide cafe directory could list shops; it could not truthfully claim local coverage plus WiFi, outlets, and hours as the reason to choose one cafe over another.

## Operating Context

Used on a phone, often while already out or about to leave: search a shop by name or area, filter by Near You / Popular / WiFi / Plugs, scan a list of cards (photo, rating, open/closed, address, amenity icons), and use maps for the exact location. First-run onboarding teaches the WiFi and plug icons, then maps. A bottom bar previews Home, saved cafes, Map, and Profile. Accounts exist in the current app (Supabase email/password login; registration is still incomplete). The same UI ships as a web app and as Capacitor iOS/Android shells.

## Capabilities and Constraints

- Confirmed in product intent: cafe search, amenity-aware listing (WiFi, power outlets), open/closed status, featured cafes, filters, maps for location, saved cafes, profile, notifications entry, first-run onboarding.
- One shared UI across web and Capacitor iOS/Android. Do not split into separate iOS vs Android design languages.
- Primary market is the Philippines, Metro Manila first.
- Home cafe lists, ratings, and Unsplash photos in the current app are placeholders. Do not treat sample shop names, ratings, or stock images as real product evidence.
- Auth implementation (Supabase) is present in the repo; keeping that vendor is not a confirmed product commitment.
- Tab destinations besides Home, map, saved lists, notifications, and profile are sketched in the shell, not fully built.

## Brand Commitments

Name is **KapeDoko**, also styled **kapé DOKO** in the wordmark. Keep existing logo and wordmark assets (dark/light marks, horizontal text, stacked text, SVG lockup, home watermark). Do not invent a different product name.

## Evidence on Hand

Brand assets live under `public/assets/` and `app/assets/css/logos/`. Onboarding copy and home UI copy are real product language. Cafe listings, ratings, and photography currently in the home screen are mock. Do not fabricate testimonials, press, real cafe coverage claims, or user counts.

## Product Principles

- Choose a cafe to work, not to window-shop coffee.
- Amenity truth (WiFi, outlets, hours, location) outranks atmosphere copy.
- Stay local: Philippines, Metro Manila first; do not pretend worldwide coverage.
- Treat placeholder data as scaffolding; never present it as proof.
- Ship one interface people can learn once, on phone or in a native wrapper.

## Accessibility & Inclusion

Aim for WCAG 2.2 AA. Respect reduced motion. Keep amenity and status information available as text or accessible names, not icons alone.
