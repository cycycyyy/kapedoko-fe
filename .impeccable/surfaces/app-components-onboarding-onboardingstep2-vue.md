---
version: 1
slug: "app-components-onboarding-onboardingstep2-vue"
primary_target: "app/components/onboarding/OnboardingStep2.vue"
related_targets: ["app/components/onboarding/OnboardingTeachMap.client.vue","app/pages/app/onboarding.vue"]
---

# Onboarding maps lesson

## Scope and visitor mode

Operate. First-run step two. Job is to show that KapeDoko maps pin a shop on real streets, then let them go Next. Not a second Map tab.

## Audience, job, action, constraints

Someone new to the app, on a phone in the Philippines. They already learned WiFi and outlet icons. Constraints: inherit bag-label world and OSM tiles; keep Skip, ticks, and Next; do not invent a cafe; horizontal onboarding swipe must still work over the map.

## Direction and memorable moment

A real Poblacion street map in a stock frame. Neighborhood to corner, then the bean pin drops with an Exact location ticket. Same pin they will see on cafe detail.

## Unresolved decisions

None. Copy stays the existing maps sentence.

## Direction contract

THESIS: The maps lesson is a real Manila street with one bean pin — not a four-line diagram of a map.

OWN-WORLD: Cool shelf, 16px stock frame, ink hairline, rice-paper OSM tiles, Kumbh Sans, bean pin, orange ticket.

STORY: They watch the map find a corner, read that maps give the exact shop location, and tap Next.

FIRST VIEWPORT: Wordmark, Skip. 240px rounded map, then the maps sentence. Ticks and Next stay put while the map flies.

FORM: Local extension of onboarding; cafe-detail pin map as topology. Code-led.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
