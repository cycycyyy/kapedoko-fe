---
version: 1
slug: "app-pages-app-map-vue"
primary_target: "app/pages/app/map.vue"
related_targets: ["app/components/map/KapeMap.client.vue","app/components/map/NearbyCafesSheet.vue","app/components/map/CafeDetailSheet.vue"]
---

# Map

Visitor mode: Operate
Audience: People already out in the Philippines who need a work-ready cafe nearby.
Job: See cafes within walking or short-trip range, confirm amenities, and pick one.
Primary action: Grant location, scan the map, open “Show cafes near me,” choose a cafe.

## Direction contract

THESIS: A full-bleed neighborhood map where work-ready cafes appear as pins you pull into a list — not a dashboard of filters over a tiny map pane.
OWN-WORLD: Coffee-brown chrome on rice-paper map light, compact Satoshi, 8px cafe cards with 90px photos, white header fade, floating search, coffee-brown CTA, peek sheet using the same cards as Home.
STORY: Someone already out opens Map, shares location, sees nearby work cafes within 3 km, taps Show cafes near me, and leaves knowing where to go.
FIRST VIEWPORT: Full-screen OSM map fitted to a 3 km radius; white top fade; back, dark lockup, MAPS; 50px search; coffee-brown “Show cafes near me” above the home indicator; tab bar only until tiles resolve.
FORM: Figma Map Selection overlay plus peek sheet; user-pinned frames 47:1261 and 67:653; Operate + pinned Figma, concept-seed skipped; code-led.
FINISH: finish review shipped; DESIGN.md records overlay chrome, forest/brick status, amenity text, 45/48px CTAs, rice-paper tiles, and demo fixture labeling
