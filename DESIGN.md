---
name: KapeDoko
description: A warm, practical cafe guide for finding work-ready coffee shops in the Philippines.
colors:
  coffee-brown: "#372d25"
  rice-paper: "#ece6db"
  sage-green: "#7b9e87"
  blush-red: "#cb8e8e"
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
---

# Design System: KapeDoko

## Overview

**Creative North Star: "The Neighborhood Coffee Counter"**

KapeDoko’s current visual system feels like a dependable neighborhood counter: warm, familiar, and immediately useful. A dark coffee-brown anchor gives the interface a recognizable home, while white content surfaces keep practical cafe information easy to scan. The system is compact and phone-first, with a little editorial warmth in featured cafe imagery and the logo-led onboarding.

Controls are quietly tactile rather than decorative. Small rounded corners, short labels, focused status colors, and restrained card shadows help people make a decision while they are already out in the city. The product’s visual language supports the work-readiness mission: amenities, open status, and location remain more actionable than atmosphere.

**Key Characteristics:**
- Coffee-brown brand anchor with warm cream support
- Compact mobile density with generous touch targets
- Rounded 4–8px surfaces and pill-shaped progress indicators
- Tonal depth through white surfaces and subtle ambient shadows
- Logo and amenity iconography used as recognizable product cues

## Colors

The palette is material and grounded: coffee-brown establishes identity, rice-paper adds warmth, and quiet status colors communicate availability without competing with the content.

### Primary
- **Coffee Brown** (`{colors.coffee-brown}`): The brand anchor for the home hero, primary actions, active filters, headings, and selected navigation.

### Secondary
- **Rice Paper** (`{colors.rice-paper}`): A warm supporting surface for secondary UI and the lighter side of the brand palette.

### Tertiary
- **Sage Green** (`{colors.sage-green}`): The positive state for open cafes and available information.
- **Blush Red** (`{colors.blush-red}`): The restrained negative state for closed cafes and destructive feedback.

### Neutral
- **Ink** (`{colors.ink}`): Default readable text and dark content details.
- **White** (`{colors.white}`): Primary content surface, input surface, and reversed text on coffee-brown.
- **Black** (`{colors.black}`): Strongest icon and onboarding text treatment.
- **Soft Gray** (`{colors.soft-gray}`): Muted controls, borders, and inactive UI.
- **Placeholder Gray** (`{colors.placeholder-gray}`): Inactive carousel dots and low-emphasis placeholder treatment.

**The Coffee-Brown Anchor Rule.** Coffee-brown anchors primary actions and major branded surfaces; status colors communicate state rather than replacing the brand color.

## Typography

**Display and Body Font:** Satoshi (`Satoshi`, `-apple-system`, `BlinkMacSystemFont`, `Segoe UI`).

**Character:** Satoshi gives the interface a distinctive, friendly geometric voice while staying direct, legible, and compact. Bold 16px titles and labels carry hierarchy while 12px body text keeps cafe metadata scannable on small screens.

### Hierarchy
- **Display** (700, 24px, 1.2): Completion moments and prominent onboarding statements.
- **Title** (700, 16px, 1.375): Cafe names, key copy, and prominent controls.
- **Body** (400, 12px, 1.35): Addresses, search text, and supporting metadata.
- **Label** (700, 10px, 1.2): Open/closed status and small state annotations.

## Layout

The layout is mobile-first and edge-aware. Content uses 20px horizontal gutters, with stacked cafe cards separated by 14px and compact horizontal scrolling for featured content and filters. The home hero owns the top of the screen with a dark branded surface, a watermark, logo bar, search field, and featured carousel. The primary navigation is a four-column bottom bar with safe-area padding for native shells.

Interaction surfaces use 36–50px controls in the home shell and 45px full-width onboarding actions. Horizontal carousels use scroll snapping and hide their scrollbar; reduced-motion users receive immediate rather than smooth scrolling. Expanded web layouts should preserve the compact content rhythm instead of stretching cards into a desktop dashboard.

## Elevation & Depth

Depth is tonal and light. White cards sit on white content surfaces but are separated with a subtle ambient shadow rather than strong borders. The translucent bottom bar uses a small blur to remain visually connected to the content beneath it. Coffee-brown surfaces provide the strongest separation through contrast.

### Shadow Vocabulary
- **Ambient card shadow** (`0 0 8px var(--kd-shadow)`): Featured cards and cafe cards at rest.
- **Graphic shadow** (`0 2px 8px var(--kd-shadow)`): Onboarding illustration lift.
- **Focus ring** (`0 0 0 2px var(--kd-white), 0 0 0 4px var(--kd-primary)`): Search field focus against the dark hero.

**The Quiet Depth Rule.** Use tonal contrast and small ambient shadows to separate surfaces; avoid heavy floating panels.

## Shapes

The form language is gently rounded and compact. Standard controls use 8px corners, filters use a tighter 4px corner, and carousel indicators are fully pill-shaped. Borders are sparse; focus is communicated with a visible two-tone outline. Images clip to their parent card radius and use `object-fit: cover`.

## Components

### Buttons
- **Shape:** Gently rounded corners (8px).
- **Primary:** Coffee-brown fill, white text, bold 16px label, 45px height, full-width in onboarding.
- **Secondary:** White fill with coffee-brown text, used on the final dark onboarding screen.
- **Hover / Focus:** Slight opacity reduction on hover, compact scale response on press, and a 2px visible focus outline.

### Chips
- **Style:** Compact 97px × 27px filter controls with a 4px radius, muted translucent ink at rest, and coffee-brown when active.
- **State:** Active chips use white bold text; inactive chips use coffee-brown regular text. The row scrolls horizontally.

### Cards / Containers
- **Corner Style:** 8px.
- **Background:** White content surface.
- **Shadow Strategy:** Subtle ambient shadow with no heavy border.
- **Internal Padding:** Cafe metadata uses approximately 11px top, 13px right, 10px bottom, and 15px left.
- **Signature treatment:** Cafe cards pair a 90px × 100px cropped image with concise status, name, address, and amenity information.

### Inputs / Fields
- **Style:** White 50px search field with 16px horizontal padding, coffee-brown text, and an 8px radius.
- **Focus:** Two-tone white and coffee-brown focus ring that remains visible on the dark hero.
- **Placeholder:** Muted ink at 50% opacity.

### Navigation
- **Style:** Four-column bottom bar with a translucent white background, 4px blur, and safe-area padding.
- **Active:** Coffee-brown square icon container with a short coffee-brown underline; inactive icons use coffee-brown at reduced opacity.
- **Mobile treatment:** Home, saved cafes, map, and profile remain evenly distributed and touchable.

### Onboarding
- **Style:** Full-height horizontal snap carousel with centered dark-logo slides and a coffee-brown completion slide.
- **Progress:** Small pill dots use muted ink at rest and coffee-brown for the active step.
- **Imagery:** Existing KapeDoko logo and onboarding graphic assets are the identity-bearing elements; preserve them.

## Do's and Don'ts

### Do:
- **Do** use coffee-brown as the visual anchor for branded surfaces, active states, and primary actions.
- **Do** keep cafe metadata short, legible, and easy to scan on a phone.
- **Do** preserve the existing KapeDoko logo, wordmark, watermark, and onboarding graphic assets.
- **Do** expose WiFi, power outlet, hours, and location information as text or accessible names alongside icons.
- **Do** respect safe-area insets and reduced-motion preferences across web and native shells.

### Don't:
- **Don't** make atmosphere, stock photography, or placeholder cafe data more prominent than work-readiness facts.
- **Don't** replace the coffee-brown anchor with a new brand color without an explicit identity decision.
- **Don't** use icons alone to communicate amenities or status.
- **Don't** introduce heavy borders, dramatic shadows, or dense desktop-only layouts that break the compact mobile rhythm.
- **Don't** treat sample cafe names, ratings, or Unsplash photography as evidence of real coverage.
