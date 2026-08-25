# Requirement Breakdown: REQ-011 Zodiac Red Flag Content + Home Quick-Grid Completion

## Source Artifacts

- Requirement master: `data/requirements/REQ-011_zodiac_red_flag_and_home_quick_grid_completion/req_master.md`
- Source escalation chain: `data/bugs/BUG-20260825-001_home_screen_design_mismatch/bug_master.md`
  -> `REQ-010_home_dashboard_deferred_scope_completion/req_master.md` (DONE,
  parked Item 2) -> this requirement.
- Blocking prior story (deferred, read-only precedent, not modified here):
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-023_zodiac_red_flag_design_fidelity/story_master.md`
  (`Status: DEFERRED`) and its
  `visual-fidelity/visual-fidelity-report.md` (full token/layout/icon spec
  captured for reuse, per that story's own recommendation).
- Design source: `cupid-app-design-system/Cupid Screens.dc.html` lines
  601-635 (`isZodiac` block) — red-flag header card, conflict-index card
  (score + gradient bar + both partners' zodiac icons), 3-row daily-tip
  list, disclaimer footer. Home quick-grid layout: same file, Home node
  (2-column `Synced Alarm` + `Zodiac Red Flag` tiles).
- Already-shipped reuse targets read as context (not modified except where a
  story below extends them):
  `mobile/lib/features/account/domain/zodiac.dart` (`zodiacSignFor()` pure
  lookup), `mobile/lib/design_system/icons/cupid_zodiac_icon.dart` (custom
  `Zodiac Icon` painter, already built per STORY-023's report),
  `backend/src/modules/users/entities/user.entity.ts`,
  `backend/src/modules/users/dto/update-profile.dto.ts`,
  `backend/src/modules/users/dto/me-profile-response.dto.ts` (existing
  `zodiacSign` profile field, already collected during onboarding per
  `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart`),
  `mobile/lib/main_preview.dart` (`_notImplementedCanvasIds` still lists
  `zodiac` — confirms no shipped screen exists yet).

## Context Summary

- Request summary: REQ-010 shipped 6 of 7 deferred Home dashboard items but
  explicitly parked the 2-column quick grid because its second tile,
  `Zodiac Red Flag`, has no built screen to link to — `STORY-023` deferred
  building it because that is new-feature construction, not a
  design-fidelity fix. The user has now directly requested this as a
  complete, end-to-end feature (data + UI + backend).
- Primary actors: paired Cupid app end users.
- Problem to solve: (1) build the Zodiac Red Flag feature itself — a
  personalized conflict-index reading and daily tip for the couple's real
  sign pair — and (2) complete the Home dashboard's 2-column quick grid by
  adding the tile that reaches it.
- Business outcome: a shipped, personalized daily-engagement feature
  matching the locked design, plus a Home dashboard that visually matches
  the design's quick-grid layout.
- Success signal: a paired user can open the Zodiac Red Flag screen (via a
  direct route in STORY-001, and via the Home quick-grid tile once
  STORY-002 lands) and see content computed from their and their partner's
  real zodiac signs, not fixture values.

## Open Question Triage

### OQ1 — MVP content source for conflict-index and daily-tip content

**Decision: static curated content table shipped with backend seed data.**
Not an admin-authored content system for this MVP — this repository has no
existing admin/CMS content-authoring surface, so building one would be
scope disproportionate to the request, and the user's confirmation was
"complete... backend" (a working feature), not an authoring tool.

To keep curated-content authoring bounded given the pairing space (12 same
-sign pairs + 66 cross-sign pairs = 78 unordered sign-pair combinations, not
144 — sign-pair order does not change the compatibility reading):

- **Conflict-index reading** (numeric score + short compatibility blurb):
  one static curated entry per unordered sign-pair (78 entries total),
  authored once, not date-dependent — this matches the design's own framing
  of "conflict index" as a trait of the pair, not a daily-changing value.
- **Daily tip** (icon + title + description, matching the design's 3-row
  list): a smaller, fixed, static curated pool of tip entries. The design's
  own example tips ("video call before 9pm", "avoid money and exes",
  "milk tea peace treaty") read as generic relationship-dynamic advice, not
  sign-pair-specific narrative — so the tip pool is not authored per pair.
  Selection is deterministic per couple per calendar day (so content is
  stable within a day and varies across days/couples), keeping authoring at
  O(78 conflict-index entries) + O(small fixed tip pool) instead of O(78 x
  N tip variants).
- Exact rotation/selection algorithm, storage schema, and tip-pool sizing
  are Tech Lead / architecture decisions, not fixed by this breakdown.
- Content quality/localization iteration on the 78 entries beyond what is
  needed to ship is explicitly out of scope (see STORY-001 Out of Scope).

### OQ2 — Does this requirement need new profile-input collection for zodiac sign?

**Decision: NO.** Verified by direct repository check: `zodiacSign` already
exists end-to-end as a profile field —
`backend/src/modules/users/entities/user.entity.ts` (`zodiacSign: string`),
`backend/src/modules/users/dto/update-profile.dto.ts` (`zodiacSign?: string`,
example `Aries`), and
`backend/src/modules/users/dto/me-profile-response.dto.ts`
(`zodiacSign: string | null`). Mobile already computes/collects it —
`mobile/lib/features/account/domain/zodiac.dart` (`zodiacSignFor()`) and
onboarding profile setup
(`mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart`).
This requirement reads each paired user's existing `zodiacSign` and must
degrade honestly (no fabricated content) when a partner's sign is unset —
see STORY-001 AC3.

## Scope Decision

### In Scope

- The Zodiac Red Flag screen as a complete feature: backend content model +
  seed content + endpoint, and the mobile screen rendering it personalized
  to the couple's real sign pair (STORY-001).
- Completing the Home dashboard's 2-column quick grid by adding the
  `Zodiac Red Flag` tile alongside the existing `Synced Alarm` tile, wired
  to STORY-001's screen (STORY-002).

### Out of Scope

- Re-litigating any already-`DONE` REQ-010 scope (anti-ghost banner,
  vibe-check card, pet preview card, header actions, couple title, `--sky`
  backdrop).
- An admin-authored/CMS content-authoring pipeline for conflict-index or
  daily-tip content (OQ1 decision above).
- New profile-input collection for zodiac sign (OQ2 decision above).
- Light theme / `en` locale dedicated visual QA — matches the
  dark-theme + `vi`-locale-only precedent already set across every closed
  REQ-002 design-fidelity story, including STORY-023's own OQ5 carve-out.

### Business Rules And Guardrails

- Design source for both stories: `cupid-app-design-system` (locked),
  enabled dark theme + `vi` locale configuration only.
- STORY-001 must degrade honestly when either partner's `zodiacSign` is
  unset — no fabricated pairing content, matching the precedent already set
  by REQ-010 STORY-006 for missing partner data.
- STORY-001's content model and endpoint must be personalized to the
  couple's real, existing `zodiacSign` values — shipping the design's
  literal fixture values (fixed date, fixed names, fixed sign pair) as
  production content is explicitly disallowed (per `req_master.md` and
  STORY-023's own deferral reasoning).
- Zodiac icons must always use the existing custom-drawn `Zodiac Icon` set
  (`mobile/lib/design_system/icons/cupid_zodiac_icon.dart`), never Unicode
  glyph substitutes, color-coded by element (Fire = peach/orange, Earth =
  mint, Air = lilac, Water = pink) per the locked design source.

## Seed To Story Mapping

No discovery `## Story Seeds` table exists for this requirement — it
originates directly from a user-confirmed follow-up to a requirement
deferral (`req_master.md` "Source"), not from a repository-recon seed pass.

## Coverage Map

| Req scope item | Story | Disposition |
|---|---|---|
| 1. Zodiac Red Flag screen — full feature | STORY-001 | Story |
| 2. Home dashboard 2-column quick grid completion | STORY-002 | Story (depends on STORY-001) |

## Open Questions

NONE remaining for story-level scoping. OQ1 and OQ2 from `req_master.md` are
resolved above. Exact content-rotation algorithm, storage schema, and
tip-pool sizing are deferred to Tech Lead architecture for STORY-001, not
open product questions.
