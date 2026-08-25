# Requirement Master: REQ-010 Home dashboard deferred scope completion
Status: PENDING

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

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
