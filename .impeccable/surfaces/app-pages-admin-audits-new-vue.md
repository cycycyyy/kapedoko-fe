---
version: 1
slug: "app-pages-admin-audits-new-vue"
primary_target: "app/pages/admin/audits/new.vue"
related_targets: ["app/components/admin/AuditChoiceGroup.vue"]
---

# New audit

Visitor mode: Operate
Audience: Staff logging a cafe visit in the field, often on a phone, sometimes on a weak signal.
Job: Record WiFi, outlets, payment, and long-stay for one approved cafe in under three minutes.
Primary action: Save audit.
Constraints: Same fields and save payload. Menu stays. Choices are tappable answers. Validation sits with each group. The form uses the width on a wide screen and stacks on a phone.

## Direction contract

THESIS: A field audit feels like stamping a coffee-bag label — each amenity is a tappable mark you can see you've set, with five short ticks for progress.
OWN-WORLD: Shelf #F2F2F2, matte stock #FAF8F5, Kumbh Sans, 16px panels, 8px fields, ink hairline, orange fill with ink text on the selected answer and Save. No lift shadows.
STORY: The auditor picks a cafe, stamps WiFi, outlets, pay, and long-stay, adds notes, and saves. The answers stay on screen if the signal drops.
FIRST VIEWPORT: Menu, New audit, five ticks, cafe picker, then WiFi and outlets beside each other on a wide screen.
