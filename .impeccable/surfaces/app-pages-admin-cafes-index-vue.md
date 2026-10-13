---
version: 1
slug: "app-pages-admin-cafes-index-vue"
primary_target: "app/pages/admin/cafes/index.vue"
related_targets: ["app/components/admin/AdminShell.vue","app/pages/admin/index.vue","app/pages/admin/requests/index.vue","app/pages/admin/cafes/import.vue","app/components/admin/AdminCafeLogoDialog.vue","app/components/admin/AdminCafeLogoButton.vue"]
---

## Scope and visitor mode

Operate. The admin desk — shell, nav, and lists — is where cafes are found, edited, published, unpublished, and stamped with a shared logo.

## Audience, job, action, constraints

KapeDoko admins at a desk, often on a laptop. Find a cafe as fast as the old table. Search, filter, edit, unpublish, add. Pending work must be visible without slowing the catalog scan. Chain branches (Starbucks, etc.) share one mark without opening each row. Bag-label world stays; no new identity.

## Direction and memorable moment

Pending cafes sit on a short ticket rail. The catalog stays a dense ink ledger. Opening a logo turns the ledger into a stamp pad: tick the shops that should wear the same mark.

## Unresolved decisions

Cafe edit/new forms keep their current steps. Shared picker and location map inherit the restyled chrome only.

## Direction contract

THESIS: The admin desk is a pending ticket rail over a dense cafe ledger, refusing dashboard metric cards and a chain-manager wizard. One mark stamps onto ticked shops from the row you already opened.

OWN-WORLD: Shelf #F2F2F2, stock #FAF8F5, ink #1c1917, teal chrome, orange action fills. Kumbh Sans. 16px label corners, hairline borders, no lift shadows.

STORY: The admin searches a chain, opens one logo, ticks the branches that should wear it, and stamps once.

FIRST VIEWPORT: Stock nav rail, teal on Cafes, ghost Import CSV beside orange Add cafe. Pending tickets. Full-width find. Status tabs. Ledger of logo, name, status, address, updated, Edit. Opening a logo docks a stamp pad above the ledger — ticks stay on the list; no modal.

FORM: Pending rail + ledger, seed b24de6e1, dealt index 2. Signature interaction: ticks ink selected rows; the stamp press copies one object key onto every checked cafe.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
