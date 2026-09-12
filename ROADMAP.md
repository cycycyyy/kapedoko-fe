# KapeDoko Roadmap

KapeDoko helps people in Metro Manila choose a cafe where they can actually work. The roadmap prioritizes trustworthy WiFi, power, hours, location, and structured community feedback over generic cafe discovery. Coverage later expands beyond Metro Manila without changing the shop-submission model.

## Launch scope

- **Launch geography:** Metro Manila (NCR) only; submissions outside NCR are blocked
- **Platforms:** Nuxt web app plus Capacitor iOS and Android shells
- **Seed data:** Manually curated cafe list; no scraping
- **Guest experience:** Browse, search, filter, view cafe details, and use map/navigation without an account
- **Authenticated experience:** Favorites, reviews, and shop submissions
- **Admin experience:** A minimal `/admin` route for submissions and moderation
- **Design reference:** Existing Figma onboarding and the current KapeDoko design system

## Phase 0 — Foundation and data model

Establish the shared contracts before building feature-specific screens.

- Configure Supabase project environments, Auth, database migrations, and Row Level Security.
- Define the cafe schema and category/tag system for work amenities:
  - WiFi availability, quality/speed, and time limit
  - Power outlet availability and reliability
  - Opening hours, location, contact details, and photos
  - Cafe categories, including future Matcha Cafe tagging
- Define review, `shop_review_stats` view, favorites, shop-submission, moderation, and admin-role models.
- Add seed-data import for the manually curated Metro Manila launch list.
- Set up Cloudflare R2 and a presigned-upload Supabase Edge Function.
- Establish image validation, resizing/thumbnail conventions, and ownership rules.
- Add route/auth guards and a consistent guest-versus-authenticated capability model.

**Exit criteria**

- A seeded cafe can be queried with its aggregated review stats and work-amenity attributes.
- RLS prevents unauthorized writes and users cannot modify another user’s content.
- An approved image can be uploaded to R2 through the presigned-upload flow.
- The same data contracts work in web and Capacitor builds.

## Phase 1 — Core MVP

### 1. Map directory

- Build the Leaflet map with OpenStreetMap tiles.
- Use the current device location when permission is granted, with a manual Metro Manila fallback.
- Show cafe markers, selected-marker state, map attribution, and a nearby-cafes result sheet.
- Add a navigation action that opens the platform’s preferred maps application.
- Handle location denied, unavailable, loading, and stale-location states clearly.

No map API key is required. OSM attribution and reasonable tile usage are required for launch.

### 2. Listing, search, and work filters

- Provide cafe listing cards with name, image, open/closed status, distance, address, rating, WiFi, and outlet facts.
- Support search by cafe name and area.
- Add filter modes:
  - Near You
  - Popular
  - WiFi Access
  - Plug Access
  - Long-stay WiFi
- Add detailed work-friendly filters for WiFi availability, speed, time limit, outlet availability, and outlet reliability.
- Support grid/list view switching where it improves browsing, including Favorites.
- Keep empty, loading, error, and no-location states usable without authentication.

### 3. Cafe detail

- Show hours, current open/closed state, address, photos, work-amenity attributes, aggregated review stats, and structured reviews.
- Add call and navigate actions when contact/location data exists.
- Make uncertain or unavailable amenity data explicit instead of implying a positive result.
- Keep photos and user-generated content attributable and moderation-ready.

### 4. Structured reviews and KapéBeans

- Create structured review inputs for work-readiness attributes rather than relying only on free text.
- Aggregate review data automatically through the `shop_review_stats` view.
- Display the resulting KapéBeans summary on listing cards and cafe detail pages.
- Allow authenticated users to submit reviews and flag inappropriate reviews or photos.
- Do not manually curate card ratings once the aggregation pipeline is live.

### 5. Favorites

- Allow authenticated users to save and remove cafes.
- Provide a Favorites destination with grid/list toggle.
- Handle sign-in prompts without losing the user’s intended action.
- Include empty, loading, and offline/error states.

### 6. User-submitted shops and moderation

- Allow authenticated users to submit a shop with required Metro Manila location, basic details, and optional photos.
- Track submission status as `pending`, `approved`, or `rejected`.
- Keep pending and rejected shops out of public listings and map results.
- Add an admin-only `/admin` route to:
  - Review submission details and photos
  - Approve or reject submissions
  - Moderate flagged reviews and photos
  - Record moderation outcome and timestamp
- Send the submitter an understandable status result; push delivery comes later.

### 7. Onboarding and guest access

- Implement the already-designed swipeable intro flow.
- Explain the product’s work-friendly value and WiFi/power concepts.
- Allow users to skip or complete onboarding and avoid showing it repeatedly.
- Guests can browse/search/filter/view details and use the map.
- Gate Favorites, Reviews, and Shop Submission behind authentication.

**MVP release criteria**

- A guest can find a Metro Manila cafe from search or map, filter it by work needs, inspect its details, and navigate there.
- A signed-in user can favorite a cafe, submit a structured review, and submit a new shop.
- An admin can approve/reject shops and moderate flagged content.
- Approved shop data and aggregated KapéBeans stats appear consistently on cards, map results, and detail pages.
- Core flows work on current iOS, Android, and mobile web layouts, including permission-denied and empty states.
- No mock cafe, rating, or photo is presented as live launch coverage.

## Phase 2 — Near-term, before monetization

### Matcha Cafe filtering

- Reuse the category/tag system created in Phase 0.
- Add Matcha Cafe as a filter and browse label.
- No schema change should be needed.

### Featured shop slot

- Add one manually curated featured-shop slot on Home.
- Keep the slot clearly separate from organic ranking and ordinary search results.
- Define the content contract, start/end dates, and admin edit path.
- Design the data model so the slot can later become a paid advertising placement without changing the listing model.

### Push notifications

- Add Capacitor push notification integration with FCM.
- Use Supabase Edge Function triggers for:
  - Shop submission approved or rejected
  - New cafe near a user
  - Other explicitly opted-in product events
- Add permission onboarding, device-token management, opt-out handling, and deep links.

### Personalization

- Rank the Home feed using existing favorites and filter history.
- Support simple explanations such as “because you liked X.”
- Start with deterministic queries and rules; no ML infrastructure is required.
- Keep personalization optional and avoid hiding the full browse/search experience.

## Phase 3 — Monetization readiness

This phase begins only after the Metro Manila directory and moderation workflow are reliable.

- Convert the featured-shop slot into a paid placement with explicit sponsored labeling.
- Define partner onboarding, placement duration, billing metadata, and content approval.
- Preserve organic ranking integrity and keep sponsored content out of “Popular” unless explicitly labeled and separately modeled.
- Add basic reporting for placement impressions and actions only after privacy and consent requirements are reviewed.

## Locked architecture decisions

| Area | Decision |
| --- | --- |
| Backend | Supabase free tier: Postgres, Auth, and Edge Functions |
| Image storage | Cloudflare R2, using a presigned-upload Edge Function |
| Frontend | Nuxt + Capacitor |
| UI components | shadcn-vue + Ionic Vue |
| Map | Leaflet + OpenStreetMap; no API key |
| Geography | Metro Manila (NCR) launch; later regions activate without rewriting submissions |
| Initial catalog | Manually curated seed list; no scraping |
| Reviews | Structured inputs aggregated by the `shop_review_stats` view |
| Auth policy | Guest discovery; auth required for Favorites, Reviews, and Shop Submission |

## Cross-cutting quality requirements

- Follow WCAG 2.2 AA targets for contrast, keyboard access, focus states, labels, and touch targets.
- Respect reduced-motion settings and native safe-area insets.
- Keep WiFi, outlets, hours, open status, and location available as readable text, not icon-only signals.
- Validate and sanitize user-submitted text and images.
- Monitor Supabase, R2, map-tile, push-token, and notification failures.
- Use realistic loading, empty, rejected, permission-denied, and error states in every core flow.
- Keep mobile-first density and the existing KapeDoko visual language across web and native shells.

## Suggested delivery order

1. Foundation, schema, RLS, roles, seed data, and R2 uploads
2. Guest listing/search/filter experience
3. Leaflet map, location handling, and navigation
4. Cafe detail and structured KapéBeans aggregation
5. Auth, Favorites, onboarding, and gated actions
6. Shop submission queue and admin moderation
7. MVP hardening, accessibility, device testing, and Metro Manila launch
8. Matcha filtering, featured slot, push notifications, and personalization
9. Paid featured placements and monetization reporting

## Out of scope for the initial launch

- Nationwide or worldwide coverage
- Automated scraping or unverified third-party cafe data
- ML-based recommendations
- Paid advertising before the organic directory and moderation process are stable
- Replacing OSM/Leaflet with a paid map provider
- Separate product experiences or design systems for iOS and Android
