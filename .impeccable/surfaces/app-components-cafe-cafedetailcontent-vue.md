---
version: 1
slug: "app-components-cafe-cafedetailcontent-vue"
primary_target: "app/components/cafe/CafeDetailContent.vue"
related_targets: ["app/components/map/CafePinMap.client.vue","app/pages/app/cafes/[id]/index.vue"]
---

# Cafe detail pin map

## Scope and visitor mode

Operate. A location pane on cafe detail, between Leave a review and KapéBean reviews. Job is to see where the shop sits in the neighborhood and get oriented, not to search or browse other cafes.

## Audience, job, action, constraints

Someone already reading a shop, often on a phone in the Philippines. They glance the pin, zoom a little, optionally find themselves, and already have Navigate above. Constraints: inherit bag-label world; reuse OSM tiles and the bean pin; no Google chrome, no address search, no nearby-cafe clutter; hide if coordinates are missing.

## Direction and memorable moment

Airbnb listing map as structure: rounded inset, one pin, stacked zoom, locate. KapeDoko materials: matte-stock frame, ink hairline, 16px corners, rice-paper tiles, bean drop-in. Memorable moment is the pin landing on the shop with a tiny name ticket.

## Unresolved decisions

None. Directions stay on the existing Navigate control.

## Direction contract

THESIS: A neighborhood slip with one cafe pinned — not a second Map tab and not a Google embed.

OWN-WORLD: Cool shelf around a 16px stock map frame, ink hairline, Kumbh Sans, bean pin, orange press on zoom/locate, quiet attribution.

STORY: The visitor sees the shop on the street grid, zooms or finds themselves, and leaves knowing where it is.

FIRST VIEWPORT: Place line from the address as the heading. Below: 240–260px rounded map, bean pin dropping onto the shop with a name ticket. Top-right: stacked +/− then locate. If they pan away, a “Back to the shop” orange chip. Signature interaction: one pin drop-in; map steals touch, not page scroll.

FORM: Local extension of cafe detail; Airbnb listing map as topology only (seed skipped: narrow specified request). Code-led.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
