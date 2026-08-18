# STORY-053: Anti-Ghosting Public-Countdown Penalty Row

Status: RETRO_PENDING
Retro-Type: RED-PATCH
Fixes: STORY-022_anti_ghosting_settings_design_fidelity
Complexity: standard
Story-Class: standard
Implementation Lane: shared (product-owner + tech-lead scope the new
persisted setting, then backend-dev field/API support, ui-ux-designer
confirms the amber-tile row spec, mobile-dev adds the row + l10n keys)

## Artifacts

- [ ] Requirements (Product Owner)
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Background (Rework Item)

Source: `data/retro-audit/rework-backlog.md` — RWB-20260816-018, split out
of `STORY-041_anti_ghosting_settings_design_fidelity_hardening`'s Product
Owner scoping (finding D-05, carried forward from STORY-022's own
`review/review-report.md`).

The design source's penalty card has three rows (design source lines
555-571); the app implements only two (Emoji Storm, sound) and omits the
first row entirely: `Đếm ngược công khai` / "Public countdown", an amber
tile (`rgba(255,201,126,.2)`, `var(--amber)` `timer` glyph). Reviewer
confirmed this needs a new persisted setting plus a backend field and new
l10n keys — the same blocker class as D-01. Not folded into STORY-041: it is
excluded by that story's own Out of Scope ("any new feature, new screen
state, or new interaction") and is not a pure rendering fix a screen-scoped
hardening story can absorb.

Exact remediation suggested by the surfacing reviewer: Product Owner/Tech
Lead to scope a new persisted anti-ghosting setting ("public countdown")
plus its backend field, then Backend Developer adds the field/API support,
UI/UX Designer confirms the amber-tile row spec, Mobile Developer adds the
row to `anti_ghost_screen.dart` with new l10n keys under
`mobile/lib/l10n/arb/`, scoped as its own story rather than folded into a
future anti-ghosting hardening pass.

Related, still-`PENDING` sibling item in the same screen family:
`RWB-20260816-019` (sound-penalty row label mismatch, l10n-only, no new
setting/backend needed) is a separate, smaller rework item — Product Owner
may evaluate whether it is efficient to fold RWB-019's l10n string fix into
this story's mobile-lane phase (same screen, same l10n file family) or keep
it fully separate; either is acceptable, record the decision here.

## In Scope
(Product Owner to complete)

## Out of Scope
(Product Owner to complete)

## Acceptance Criteria
(Product Owner to complete)
