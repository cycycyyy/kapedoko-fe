---
name: KapeDoko
description: A warm, practical cafe guide for finding work-ready coffee shops in the Philippines.
colors:
  coffee-brown: "#372d25"
  rice-paper: "#ece6db"
  forest-open: "#3f6a50"
  brick-closed: "#a45d5d"
  ink: "#1e1e1e"
  white: "#ffffff"
  black: "#000000"
  soft-gray: "#cccccc"
  placeholder-gray: "#d9d9d9"
typography:
  display:
    fontFamily: "Satoshi, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
    fontSize: "24px"
    fontWeight: 700
    lineHeight: 1.2
  headline:
    fontFamily: "Satoshi, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
    fontSize: "20px"
    fontWeight: 700
    lineHeight: 1.2
  title:
    fontFamily: "Satoshi, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
    fontSize: "16px"
    fontWeight: 700
    lineHeight: 1.375
  body:
    fontFamily: "Satoshi, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
    fontSize: "12px"
    fontWeight: 400
    lineHeight: 1.35
  label:
    fontFamily: "Satoshi, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
    fontSize: "10px"
    fontWeight: 700
    lineHeight: 1.2
rounded:
  sm: "4px"
  chrome: "5px"
  md: "6px"
  lg: "8px"
  pill: "999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "14px"
  lg: "20px"
  xl: "24px"
components:
  button-primary:
    backgroundColor: "{colors.coffee-brown}"
    textColor: "{colors.white}"
    typography: "{typography.title}"
    rounded: "{rounded.lg}"
    height: "45px"
    padding: "0 20px"
  button-primary-android:
    backgroundColor: "{colors.coffee-brown}"
    textColor: "{colors.white}"
    typography: "{typography.title}"
    rounded: "{rounded.lg}"
    height: "48px"
    padding: "0 20px"
  button-secondary:
    backgroundColor: "{colors.white}"
    textColor: "{colors.coffee-brown}"
    typography: "{typography.title}"
    rounded: "{rounded.lg}"
    height: "45px"
    padding: "0 20px"
  filter-chip-active:
    backgroundColor: "{colors.coffee-brown}"
    textColor: "{colors.white}"
    typography: "{typography.body}"
    rounded: "{rounded.sm}"
    height: "27px"
    width: "97px"
  cafe-pin:
    backgroundColor: "{colors.coffee-brown}"
    textColor: "{colors.white}"
    width: "36px"
    height: "36px"
  cafe-pin-selected:
    backgroundColor: "{colors.coffee-brown}"
    textColor: "{colors.white}"
    width: "44px"
    height: "44px"
  input-search:
    backgroundColor: "{colors.white}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    height: "50px"
    padding: "0 16px"
  input-sheet-field:
    backgroundColor: "{colors.rice-paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    height: "50px"
    padding: "0 16px"
  logo-stamp:
    backgroundColor: "{colors.rice-paper}"
    textColor: "{colors.coffee-brown}"
    rounded: "{rounded.lg}"
    width: "96px"
    height: "96px"
  submit-ticks:
    backgroundColor: "{colors.coffee-brown}"
    rounded: "{rounded.pill}"
    height: "5px"
    width: "64px"
  button-outline:
    backgroundColor: "{colors.white}"
    textColor: "{colors.coffee-brown}"
    typography: "{typography.title}"
    rounded: "{rounded.lg}"
    height: "45px"
    padding: "0 20px"
  status-chip-open:
    backgroundColor: "{colors.forest-open}"
    textColor: "{colors.white}"
    rounded: "{rounded.sm}"
    height: "28px"
    padding: "6px 10px"
  status-chip-closed:
    backgroundColor: "{colors.brick-closed}"
    textColor: "{colors.white}"
    rounded: "{rounded.sm}"
    height: "28px"
    padding: "6px 10px"
---

# Design System: KapeDoko

## Overview

**Creative North Star: "The Neighborhood Coffee Counter"**

KapeDoko’s current visual system feels like a dependable neighborhood counter: warm, familiar, and immediately useful. A dark coffee-brown anchor gives the interface a recognizable home, while white content surfaces keep practical cafe information easy to scan. The system is compact and phone-first, with a little editorial warmth in cafe imagery and the logo-led onboarding.

Controls are quietly tactile rather than decorative. Small rounded corners, short labels, focused status colors, and restrained card shadows help people make a decision while they are already out in the city. The same counter language continues onto the map: rice-paper-warmed tiles sit under white overlay chrome, cafe markers are coffee-brown circles with a cup mark, and nearby cafes pull into a white peek sheet that reuses Home’s cafe cards. Add a cafe is the same overlay to fill: rice-paper ground, white fade chrome, a floating white sheet, and a sticky coffee-brown Continue — not a coffee-brown campaign hero over a stacked form. The product’s visual language supports the work-readiness mission: amenities, open status, and location remain more actionable than atmosphere.

**Key Characteristics:**
- Coffee-brown brand anchor with warm cream support
- Compact mobile density with generous touch targets
- Rounded 4–8px surfaces and pill-shaped progress indicators
- Tonal depth through white surfaces and subtle ambient shadows
- Logo and amenity iconography used as recognizable product cues
- Full-bleed map overlay: white header fade, floating search, coffee-brown circle markers, coffee-brown CTA, white peek and cafe-detail sheets
- Add a cafe overlay: rice-paper ground, white fade chrome with three ticks, floating 8px white sheet, rice-paper 50px fields, sticky 45/48px Continue; pin step is full-bleed warmed OSM with a sheet-lift peek

## Colors

The palette is material and grounded: coffee-brown establishes identity, rice-paper adds warmth, and quieter forest and brick communicate availability without competing with the content.

### Primary
- **Coffee Brown** (`{colors.coffee-brown}`): The brand anchor for the home hero, primary actions, active filters, headings, selected navigation, cafe pins, the map’s bottom CTA, Add a cafe chrome, step ticks, and pending-review status.

### Secondary
- **Rice Paper** (`{colors.rice-paper}`): A warm supporting surface for secondary UI, map placeholders, the Add a cafe page ground, and the fill of fields inside white submit sheets. On the map, OSM tiles are warmed toward this paper rather than left as raw cartography.

### Tertiary
- **Forest Open** (`{colors.forest-open}`): Open status on cafe cards (Home and Map) and the cafe-detail status chip.
- **Brick Closed** (`{colors.brick-closed}`): Closed status on cafe cards (Home and Map), the cafe-detail status chip, and Add a cafe field errors.

### Neutral
- **Ink** (`{colors.ink}`): Default readable text and dark content details.
- **White** (`{colors.white}`): Primary content surface, input surface, map and Add a cafe header fade, peek sheets, floating submit sheets, and reversed text on coffee-brown.
- **Black** (`{colors.black}`): Strongest icon and onboarding text treatment.
- **Soft Gray** (`{colors.soft-gray}`): Muted controls, borders, and inactive UI.
- **Placeholder Gray** (`{colors.placeholder-gray}`): Inactive carousel dots, Add a cafe ticks at rest, and low-emphasis placeholder treatment.

**The Coffee-Brown Anchor Rule.** Coffee-brown anchors primary actions and major branded surfaces; status colors communicate state rather than replacing the brand color.

**The Status Contrast Rule.** Cafe open/closed uses forest and brick only: 12px bold text on white cards, or a filled chip with white text on the cafe-detail sheet. Do not restyle status with unused paler Brand Guide greens and pinks.

## Typography

**Display and Body Font:** Satoshi (`Satoshi`, `-apple-system`, `BlinkMacSystemFont`, `Segoe UI`).

**Character:** Satoshi gives the interface a distinctive, friendly geometric voice while staying direct, legible, and compact. Bold 16px titles and labels carry hierarchy while 12px body text keeps cafe metadata scannable on small screens.

### Hierarchy
- **Display** (700, 24px, 1.2): Completion moments and prominent onboarding statements.
- **Headline** (700, 20px, 1.2): Sheet titles on nearby cafes, cafe detail, and Add a cafe questions.
- **Title** (700, 16px, 1.375): Cafe names, key copy, and prominent controls including the map CTA and the Add a cafe header.
- **Body** (400, 12px, 1.35): Addresses, search text, distances, amenity labels, supporting metadata, and submit step labels.
- **Label** (700, 10px, 1.2): Tiny annotations such as map attribution and compact sheet actions. Cafe open/closed status uses body size (12px) at label weight (700) in forest or brick.

## Layout

The layout is mobile-first and edge-aware. Content uses 20px horizontal gutters, with stacked cafe cards separated by 14px and compact horizontal scrolling for filters. The home hero owns the top of the screen with a dark branded surface, a watermark, logo bar, and search field. The primary navigation is a four-column bottom bar with safe-area padding for native shells. Profile is an account screen, not a second directory.

Interaction surfaces use 36–50px controls in the home shell, 45px full-width onboarding actions, and a 45px iOS / 48px Android full-width primary CTA on the map overlay and Add a cafe. Horizontal carousels use scroll snapping and hide their scrollbar; reduced-motion users receive immediate rather than smooth scrolling. Expanded web layouts should preserve the compact content rhythm instead of stretching cards into a desktop dashboard; map chrome, map sheets, and Add a cafe cap at 480px from 540px.

**The Overlay Chrome Rule.** A full-bleed map keeps rice-paper-warmed tiles under a white header fade, a floating 50px search field, and a coffee-brown bottom CTA above the home indicator. Nearby results and cafe detail open as white Ionic peek sheets; the nearby sheet reuses Home’s cafe cards.

**The Submit Overlay Rule.** Add a cafe sits on rice-paper under a white fade that holds back, title, and three ticks. Name, hours, and check float in an 8px white sheet; Continue stays sticky at 45px (48px on Android) above the home indicator. The pin step collapses the sheet to a 50px search strip over full-bleed warmed OSM, with a Map sheet-lift peek holding the shop street line.

## Elevation & Depth

Depth is tonal and light. White cards sit on white content surfaces but are separated with a small shadow rather than strong borders. Featured home cards keep a diffuse ambient glow; cafe cards, floating map chrome, and the Add a cafe sheet use a short graphic lift. The translucent bottom bar uses a small blur to remain visually connected to the content beneath it. Coffee-brown surfaces provide the strongest separation through contrast. Map sheets and the pin-step peek lift over the tiles with a modest upward shadow, not a heavy dashboard panel.

### Shadow Vocabulary
- **Ambient card shadow** (`0 0 8px var(--kd-shadow)`): Featured cards at rest.
- **Graphic shadow** (`0 2px 8px var(--kd-shadow)`): Cafe cards, floating map and pin search, status banners, the locate control, the onboarding illustration, and the Add a cafe sheet.
- **Sheet lift** (`0 -2px 16px var(--kd-shadow)`): Nearby cafes, cafe-detail sheets, and the Add a cafe pin peek over the map.
- **Marker drop shadow** (`drop-shadow(0 3px 5px var(--kd-shadow))`): Cafe markers at rest; selected markers use `drop-shadow(0 4px 8px var(--kd-shadow))`.
- **Focus ring** (`0 0 0 2px var(--kd-white), 0 0 0 4px var(--kd-primary)`): Search field focus against the dark hero and over map tiles; rice-paper submit fields use the same ring.
- **Selected card lift** (`0 4px 12px var(--kd-shadow)`): Selected cafe card in the nearby list sits on rice-paper with a stronger graphic shadow, not a coffee-brown ring.

**The Quiet Depth Rule.** Use tonal contrast and small ambient or graphic shadows to separate surfaces. Overlay chrome and map sheets may lift slightly; do not add heavy dashboard panels.

## Shapes

The form language is gently rounded and compact. Standard controls use 8px corners, filters use a tighter 4px corner, and carousel indicators and Add a cafe ticks are fully pill-shaped. Borders are sparse; focus is communicated with a visible two-tone outline. Images clip to their parent card radius and use `object-fit: cover`. Map sheets and the Add a cafe sheet share the 8px corner language of cafe cards and primary actions. The pin peek rounds only its top corners (8px). Sheet handles and the active tab well use a 5px chrome radius. Cafe markers are coffee-brown circles with a white halo, not teardrop pins.

## Components

### Buttons
- **Shape:** Gently rounded corners (8px).
- **Primary:** Coffee-brown fill, white text, bold 16px label, 45px height on iOS and onboarding, 48px height on Android overlay CTAs, full-width in onboarding, as the map’s “Show cafes near me” action, and as Add a cafe Continue / Review / Submit cafe.
- **Secondary:** White fill with coffee-brown text, used on the final dark onboarding screen.
- **Outline:** White fill, coffee-brown 1px stroke and 16px bold label, 45px (48px on Android). Used for “Leave a review” on cafe detail.
- **Compact sheet actions:** 10px bold labels on a 28px painted face inside a 44px hit area. Coffee-brown fill for Navigate; 10% ink fill for Call.
- **Hover / Focus:** Slight opacity reduction on hover, compact scale response on press, and a 2px visible focus outline.

### Chips
- **Style:** Compact 97px × 27px filter controls with a 4px radius, muted translucent ink at rest, and coffee-brown when active.
- **State:** Active chips use white bold text; inactive chips use coffee-brown regular text. The row scrolls horizontally.
- **Status chips:** Cafe-detail open/closed is a 4px chip with forest or brick fill and white 12px bold text, optically aligned with compact Call. Cards keep status as forest/brick text, not a chip.

### Cards / Containers
- **Corner Style:** 8px.
- **Background:** White content surface.
- **Shadow Strategy:** Graphic shadow on cafe cards.
- **Internal Padding:** Cafe metadata uses approximately 11px top, 13px right, 10px bottom, and 15px left.
- **Signature treatment:** Cafe cards pair a 90px × 100px cropped image with concise status, name, address, optional distance, and amenity information. Open/closed is 12px bold in forest or brick. WiFi and outlet availability appear as visible text beside their icons, not as icons alone. A selected card uses a rice-paper fill and a stronger graphic lift. The Add a cafe pending preview reuses that 90px × 100px topology without amenities or ratings.

### Inputs / Fields
- **Style:** White 50px search field with 16px horizontal padding, coffee-brown text, and an 8px radius. On Home it sits in the dark hero; on Map and the Add a cafe pin step it floats over tiles with the graphic shadow.
- **Sheet fields:** Inside the white submit sheet, 50px fields fill with rice-paper, not white. Name uses 16px horizontal padding; phone and time fields use 12px. The pin peek address is a rice-paper textarea (64–88px), not a 50px single line.
- **Logo stamp:** Optional 96px rice-paper square with an 8px radius beside text actions.
- **Focus:** Two-tone white and coffee-brown focus ring that remains visible on the dark hero, over the map, and on rice-paper fields.
- **Placeholder:** Search uses muted ink at 50% opacity. Rice-paper fields use a warmer brown (`#5c534c`).

### Navigation
- **Style:** Four-column bottom bar with a translucent white background, 4px blur, and safe-area padding.
- **Active:** Coffee-brown square icon container with a short coffee-brown underline; inactive icons use coffee-brown at reduced opacity.
- **Mobile treatment:** Home, saved cafes, map, and profile remain evenly distributed and touchable.

### Onboarding
- **Style:** Full-height horizontal snap carousel with centered dark-logo slides and a coffee-brown completion slide.
- **Progress:** Small pill dots use muted ink at rest and coffee-brown for the active step.
- **Imagery:** Existing KapeDoko logo and onboarding graphic assets are the identity-bearing elements; preserve them.

### Map Overlay
- **Style:** Full-bleed map with a white-to-transparent header fade, dark lockup, floating search, coffee-brown bottom CTA, and a white peek sheet of cafe cards.
- **Tiles:** OSM tiles are filtered toward rice-paper warmth (`sepia(0.32) saturate(0.62) hue-rotate(-12deg) brightness(1.03)`). Leaflet must own an inner canvas node so Vue class updates cannot strip `leaflet-container`.
- **Markers:** Unselected cafe markers are coffee-brown circles with a white halo and a side-view cup. The selected marker becomes the KapeDoko lockup icon. The user mark is a smaller white-ringed coffee-brown dot.
- **Demo labeling:** When fixture cafes are on screen, label them as demo (map note and sheet heading). Do not present mock listings as live coverage.

### Add a cafe Overlay
- **Ground:** Rice-paper page, not a coffee-brown hero. A white-to-transparent header fade holds a 44px back control, a 16px “Add a cafe” title with a 12px step label, and three 5px pill ticks (64px row, placeholder-gray at rest, coffee-brown when on). Four copy steps (Name, Pin, Hours, Check) light three ticks; Check fills all three.
- **Sheet:** Floating white 8px card with 20px inset padding, 20px side gutters, and graphic shadow. Sheet questions are 20px coffee-brown; supporting copy is 12px ink.
- **Dock:** Sticky coffee-brown Continue at 45px (48px on Android) above the home indicator. On the pin step the dock sits on white, tight to the peek (4px top padding).
- **Pin step:** Full-bleed warmed OSM. Floating 50px white search. Selected lockup marker. White 48px locate control. White peek with sheet-lift shadow holds “Pin the cafe” at 16px and the rice-paper street line. Errors use 12px bold brick.
- **Pending listing:** Cafe-card topology — 90px × 100px rice-paper mark, 16px name, 12px address, hours, and phone — without amenities or ratings. Status is 12px bold coffee-brown “Pending review”, not forest or brick open/closed.

**The Rice-Paper Field Rule.** Fields inside the white submit sheet fill with rice-paper (50px, 8px, no stroke). Do not stack white fields on the white sheet.

**The Pending Card Rule.** The review listing reuses cafe-card topology without amenities or ratings. Pending status is coffee-brown, not forest or brick.

### Cafe Detail Sheet
- **Shape:** White Ionic sheet at 88% height, 8px top corners, sheet-lift shadow, 50×8 handle at 5px radius. Caps at 480px from 540px.
- **Header:** 20px coffee-brown cafe name with a compact Navigate action. WiFi and outlet labels sit beside their icons. Hours stay ink, not muted gray.
- **Status:** Forest or brick filled chip plus hours, with Call as a compact quiet action when a phone number exists.
- **Gallery:** 175px hero with selectable thumbs; the active thumb uses the same two-tone coffee-brown focus ring as search.
- **Insights:** KapéBean counts introduce WiFi and outlet facts as readable text, not icons alone.
- **Reviews:** Outlined “Leave a review” or a full-width coffee-brown “Review this cafe” when the list is empty. Preview builds may explain that leaving a review is not available yet.

**The Cafe Marker Rule.** Unselected cafe markers are coffee-brown circles with a white halo and a side-view cup. The selected marker uses the KapeDoko lockup icon. The user mark stays a smaller white-ringed coffee-brown dot. Leaflet must own an inner canvas node so Vue class updates cannot strip `leaflet-container`.

**The Demo Fixture Rule.** Sample cafe names, ratings, and photography stay labeled as demo whenever they appear; they are scaffolding, not proof of coverage.

## Do's and Don'ts

### Do:
- **Do** use coffee-brown as the visual anchor for branded surfaces, active states, and primary actions.
- **Do** keep cafe metadata short, legible, and easy to scan on a phone.
- **Do** preserve the existing KapeDoko logo, wordmark, watermark, and onboarding graphic assets.
- **Do** expose WiFi, power outlet, hours, and location information as visible text or accessible names alongside icons.
- **Do** respect safe-area insets and reduced-motion preferences across web and native shells.
- **Do** use 45px primary CTAs on iOS and 48px on Android for full-width overlay actions.
- **Do** keep Add a cafe on rice-paper with a floating white sheet and a sticky coffee-brown Continue.
- **Do** collapse the pin step to a 50px search over full-bleed warmed OSM, with a sheet-lift peek for the street line.
- **Do** reuse cafe-card topology for the pending preview without amenities or ratings.
- **Do** label fixture cafe lists as demo when mock data is on screen.
- **Do** draw unselected cafe markers as coffee-brown circles with a white halo and a side-view cup; the selected marker uses the KapeDoko lockup icon.

### Don't:
- **Don't** make atmosphere, stock photography, or placeholder cafe data more prominent than work-readiness facts.
- **Don't** replace the coffee-brown anchor with a new brand color without an explicit identity decision.
- **Don't** use icons alone to communicate amenities or status.
- **Don't** introduce heavy borders, dramatic shadows, or dense desktop-only layouts that break the compact mobile rhythm.
- **Don't** treat sample cafe names, ratings, or Unsplash photography as evidence of real coverage.
- **Don't** restyle cafe open/closed status with unused paler Brand Guide greens and pinks.
- **Don't** invent a new red accent for pins.
- **Don't** put Add a cafe on a coffee-brown campaign hero or stacked form over a branded header.
- **Don't** put amenities or ratings on the pending listing preview.
- **Don't** restyle pending status as forest or brick open/closed.
