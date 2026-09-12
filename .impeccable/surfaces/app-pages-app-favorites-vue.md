---
version: 1
slug: "app-pages-app-favorites-vue"
primary_target: "app/pages/app/favorites.vue"
related_targets: ["app/pages/app/index.vue","nuxt.config.ts"]
---

# Favorites

## Scope and visitor mode

Operate. A saved-cafes stack opened from the Home heart tab. Job is to review cafes already worth coming back to, switch between a single-shop card and a scan list, and remove a save — not to search, filter, or browse featured shops.

## Audience, job, action, constraints

People who already found a work-ready cafe and want it again. They open Favorites from Home, flip card/list, page through saves, unfavorite from the list, and go back. Constraints: match the attached card and list mockups; reuse placeholder cafe photos; no tab bar; do not change shared components; persist saves locally; empty state must teach what belongs here.

## Direction and memorable moment

A white sheet with a pale map-pin behind “Here are your favorite **coffee shops**.” The memorable object is the coffee-brown single-shop card you page through, not another Home list.

## Unresolved decisions

None for this build. Shop detail navigation is out of scope.

## Direction contract

THESIS: A saved-cafes stack for revisiting a work-ready shop, not a second Home with filters and featured slides. The page is pin, toggle, and the cafe in front of you.

OWN-WORLD: White sheet, pale gray map-pin, coffee-brown filled toggle and the large rounded favorite card, Satoshi at the compact Home scale, Lucide heart/list/columns, circular list thumbnails, white type on the brown card.

STORY: The visitor arrives from the Home heart, sees their saves as one shop at a time, switches to a list to scan or unsave, and leaves with back. Zero saves get a quiet empty that sends them Home.

FIRST VIEWPORT: White ground, safe-area back arrow, oversized pale map-pin with a heart and “Here are your favorite / coffee shops” on it, card/list toggle at the right. Default: a tall coffee-brown rounded card — inset photo, centered name and address, two outlined circular arrows. List: circle photo, name, wrapping address, outline heart. Signature interaction: the view toggle crossfades card and list; card arrows (and swipe) page saves.

FORM: Mockup-pinned card/list (seed skipped: precisely specified request with attached Favorites comps). Code-led; the attached mockups are the critique reference.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
