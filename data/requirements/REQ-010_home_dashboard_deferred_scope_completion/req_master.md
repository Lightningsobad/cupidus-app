# Requirement Master: REQ-010 Home dashboard deferred scope completion
Status: IN_PROGRESS

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

## Source

Escalated from
`BUG-20260825-001_home_screen_design_mismatch`
(`data/bugs/BUG-20260825-001_home_screen_design_mismatch/bug_master.md`),
`ESCALATED_TO_BACKLOG` — Bug Fixer reproduced the report visually (rendered
design source vs. emulator capture) and confirmed the region owned by
`REQ-002/STORY-017_home_dashboard_design_fidelity` (presence row, counter,
hero caption, milestone pill, card rhythm, tab-bar styling, hero glow) still
matches the design; this is not a regression. The remaining "completely
wrong" perception comes from out-of-region surfaces that STORY-017's own
review gate already excluded and recorded as deferrals (finding `B5`,
`Outcome: DEFERRED_ONLY`). Closing these needs new product/UX/backend scope
beyond a narrow bugfix budget — same disposition as
`BUG-20260824-001_pairing_code_screen_missing_design`
(`REQ-009_invite_couple_type_and_pairing_navigation`).

## Scope For Product Owner / UI-UX / Tech Lead

Recommended backlog scope, ordered by visual impact (from the bug's
Escalation Reason):

1. Home dashboard feature cards — anti-ghost alert banner, vibe-check
   two-tile card, pet preview card (STORY-017 deferrals F3/F6).
2. Home dashboard 2-column quick grid (STORY-017 deferral F6) — depends on
   `STORY-023 Zodiac Red Flag` (currently `DEFERRED`); Product Owner must
   confirm/re-sequence this dependency before story splitting.
3. Header share/notification actions (STORY-017 deferral F3) — needs target
   routes/screens for both actions defined.
4. Partner name / couple title (currently shows a single name, not
   "Minh & Linh") (STORY-017 deferral F4) — needs a backend partner-profile
   story to supply the paired partner's name.
5. `--sky` global backdrop theme token (STORY-017 deferral F10) — this is a
   cross-cutting visual theme change reported to span roughly 37 screens; UI-UX
   and Tech Lead must scope it as its own story/rollout, not bundled silently
   into a Home-only story.

Non-blocking implementation notes carried from the bug (see
`data/bugs/BUG-20260825-001_home_screen_design_mismatch/scrum-master-checkpoint.md`
Escalation Reason section for full detail):
- Recapture Home screen evidence with
  `--dart-define=PREVIEW_HOME_FIXTURE=true`; the bug's first (withdrawn)
  capture omitted this and produced a false "catastrophic" render.
- `PetPreviewCard` shows a load-failure state under the preview harness
  (no authenticated backend) — a capture-state gap, not a rendering defect.
  Consider a `PREVIEW_PET_FIXTURE` define mirroring `PREVIEW_HOME_FIXTURE` so
  this item's own story can capture real rendered evidence.

## Out of Scope

- Any change to the presence row, `247` counter, hero caption, milestone
  pill, card rhythm, or tab-bar styling already delivered and design-matched
  by `STORY-017_home_dashboard_design_fidelity`.
- Re-litigating STORY-023 Zodiac Red Flag's own deferred scope beyond the
  dependency this requirement's item 2 needs from it.
- The 2-column quick grid's `Zodiac Red Flag` tile — see Product Owner Story
  Breakdown Decision below. `Synced Alarm` alone does not reproduce the
  design's 2-column grid, and no story is opened for a single-tile
  substitute.

## Product Owner Story Breakdown Decision

Applying the standalone-value gate (each story must give a stakeholder
something new to observe once it alone merges) to the 5 recommended scope
items above:

- Item 1 ("feature cards") is not one story: the anti-ghost alert banner,
  vibe-check card, and pet preview card are three already-mounted,
  independent Home-dashboard widgets (`AntiGhostEntryCard`,
  `VibeEntryCard`, `PetPreviewCard` — confirmed present in
  `home_screen.dart`) belonging to three distinct product capabilities
  (anti-ghosting, vibe-check, pet). Each gets its own design-fidelity story
  (STORY-001, STORY-002, STORY-003), consistent with how STORY-017's own
  visual-fidelity report already labels each "its own REQ-002 story" (F6).
- Item 3 ("header share/notification actions") is not one story: the
  design source (`Cupid Screens.dc.html` lines 249-250) defines two
  distinct header icons — `goShareDays` (share the days-together milestone,
  reusing the share-sheet pattern already integrated in
  `pairing/presentation/screens/invite_screen.dart`) and `goNotifs` (open
  the existing Notifications/preferences screen already shipped by
  REQ-002 `STORY-031_notifications_design_fidelity`, `Status: DONE`).
  These are different business capabilities (growth/sharing vs.
  engagement/notifications), so they are split into STORY-004 and
  STORY-005. STORY-005 is a new entry point to an existing screen, not a
  new notifications feature/inbox — no such feed exists in the shipped app
  or in the governing design source.
- Item 4 ("partner name / couple title") stays one story (STORY-006) per
  the producer/consumer rule: the backend partner-profile API and the
  mobile display of "Minh & Linh" are ordered phases of one outcome, not
  two stories — nothing is observable until both phases ship.
- Item 5 (`--sky` backdrop) stays one story (STORY-007), scoped as its own
  cross-cutting rollout per the requirement's own instruction; not bundled
  into any Home-only story.
- Item 2 (2-column quick grid: `Synced Alarm` + `Zodiac Red Flag` tiles,
  per STORY-017 visual-fidelity report line "Synced Alarm / Zodiac Red Flag
  grid") is **parked, not opened as a story this pass**. `STORY-023 Zodiac
  Red Flag` (`REQ-002`) is `Status: DEFERRED` with no scheduled resumption:
  its own story master states building the screen needs new product/content
  decisions (per-sign-pair "conflict index" authoring, daily-tip content
  source, personalization) that are out of any current requirement's remit,
  and explicitly recommends a *future* requirement, not a near-term
  re-sequencing. Shipping only the `Synced Alarm` tile would not reproduce
  the design's 2-column grid and would itself require a new product
  decision (what a single-tile grid looks like, or what the `Zodiac Red
  Flag` tile should do when tapped) that is not this requirement's to
  invent. Blocker: needs a future requirement to scope and build the
  Zodiac Red Flag screen (content/personalization model) before this grid
  can be built as designed.

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
| STORY-001 | Anti-ghost alert banner design fidelity | trivial | PENDING | data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-001_antighost_alert_banner_design_fidelity/story_master.md |
| STORY-002 | Vibe-check card design fidelity | trivial | PENDING | data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-002_vibe_check_card_design_fidelity/story_master.md |
| STORY-003 | Pet preview card design fidelity | standard | PENDING | data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-003_pet_preview_card_design_fidelity/story_master.md |
| STORY-004 | Home header — share days-together action | standard | PENDING | data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-004_home_header_share_days_action/story_master.md |
| STORY-005 | Home header — notifications quick access | trivial | PENDING | data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-005_home_header_notifications_entry_point/story_master.md |
| STORY-006 | Couple title shows both partner names | standard | PENDING | data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-006_couple_title_partner_names/story_master.md |
| STORY-007 | `--sky` global screen backdrop rollout | complex | PENDING | data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-007_sky_backdrop_theme_rollout/story_master.md |
