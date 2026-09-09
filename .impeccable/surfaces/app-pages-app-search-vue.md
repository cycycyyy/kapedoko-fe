---
version: 1
slug: "app-pages-app-search-vue"
primary_target: "app/pages/app/search.vue"
related_targets: ["app/pages/app/index.vue"]
---

# Search shops

## Scope and visitor mode

Operate. A dedicated search-results stack reached from Home search. Job is to scan matching cafes and go back, not to browse featured content or switch tabs.

## Audience, job, action, constraints

People already out or about to leave, searching a shop by name or area. They type, submit, scan cards (photo, rating, open/closed, address, WiFi/plug), and return Home. Constraints: match the pinned Search shops mockup; reuse Home placeholder cafes; no tab bar; do not change shared components; empty submit still opens this page; “No coffee beans left” covers both end-of-list and zero matches.

## Direction and memorable moment

A coffee-brown search header with back + live query, then a quiet white list. The memorable close is the coffee-cup end marker, not another carousel or filter row.

## Unresolved decisions

None for this build. Shop detail navigation is out of scope.

## Direction contract

THESIS: A focused search stack for picking a work-ready cafe, not a second Home with filters and featured slides. The page is query, list, and done.

OWN-WORLD: Coffee-brown header with the existing watermark, white 8px search field and search button, white content well, ambient-shadow cafe cards, sage/blush status, Lucide amenity icons, Satoshi at the compact Home scale.

STORY: The visitor arrives with a query from Home (or submits empty to see everything), scans work-readiness facts, revises the query in place, and leaves with back. Zero matches and the end of a list share the same “No coffee beans left” close.

FIRST VIEWPORT: Brown header (safe-area, back chevron, “Search shops”, watermark). Below: white search field (no leading icon) plus square search button. White list of cards: 90×100 photo, four outlined stars, Open/Closed, truncated name, truncated address, amenity icons. After the list (or alone when empty): outlined coffee cup and “No coffee beans left.” No tab bar. Signature interaction: submitting search replaces the query and crossfades the list; cards press-scale; back returns to Home.

FORM: Mockup-pinned focused list (seed skipped: precisely specified request with an attached Search shops comp). Code-led; the attached mockup is the critique reference.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
