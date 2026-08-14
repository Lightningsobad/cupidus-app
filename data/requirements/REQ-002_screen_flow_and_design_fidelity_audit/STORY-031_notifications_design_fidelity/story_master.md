# Story Master: STORY-031 Design Fidelity — Notifications

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: Notifications settings, Epic 6 (Account, privacy, notifications) —
DND/Critical-Alerts copy conflict resolution required
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)
Design-Screen: notifs

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development) — `visual-fidelity/visual-fidelity-report.md`
  `VISUAL_FIDELITY: PASS`
- [ ] Review (Reviewer)

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a paired user configuring notification preferences, I want the
Notifications screen to match the locked design source exactly and to
avoid claiming a Do Not Disturb bypass that does not exist in v1, so my
expectations about alert behavior are accurate.

## In Scope
1. Re-audit the current Notifications screen against
   `cupid-app-design-system` for the enabled dark theme + `vi` locale
   configuration: notification-category toggle list styling, spacing,
   color/design-token usage, and typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.
3. **Mandatory copy fix**: remove/replace any user-visible copy claiming
   "Chỉ Synced Alarm được phép phá Do Not Disturb" (or any equivalent
   DND-bypass claim). Per the PO scope decision resolving UX memory §7's
   flagged conflict for v1, DND-bypass behavior is out of scope; this
   screen must present only standard notification-priority copy, with no
   DND-override claim for any notification category including synced
   reminders.
4. Apply the epic-3 wording rule (§6) wherever this screen references the
   synced-reminder feature: use "nhắc nhở đồng bộ" (synced reminder), never
   "báo thức" / "alarm" / "Synced Alarm".

## Out of Scope
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Implementing an actual DND-bypass mechanism — the copy fix in this story
  removes an inaccurate claim; it does not add the capability described by
  that claim.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the Notifications screen rendered in the enabled dark theme + `vi`
   locale, when compared against `cupid-app-design-system`'s corresponding
   screen, then layout, spacing, color/token usage, and typography match
   exactly with no visible deviation.
2. Given any visual deviation was found during this story's audit, when
   the story is delivered, then the deviation is corrected in the rendered
   app (not merely documented) and re-verified against the design source.
3. Given any user-visible copy on this screen, when rendered, then it does
   not claim any notification category (including synced reminders) can
   bypass Do Not Disturb — the DND-bypass claim is removed or replaced with
   standard notification-priority copy.
4. Given any user-visible reference to the synced-reminder feature on this
   screen, when rendered, then it reads "nhắc nhở đồng bộ" and never
   "báo thức" / "alarm" / "Synced Alarm".
5. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current Notifications screen, already
  reachable in the shipped app.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed. Shares the epic-3 wording
  rule with STORY-021 (Synced Reminder), but has no delivery dependency on
  it — each story fixes its own screen's copy independently.

## Open Question Impact
OQ5 (light theme / `en` locale) only affects out-of-scope light/`en`
user-facing visual QA per this story's Out of Scope section; it does not
block any in-scope acceptance criterion. UX memory §7's DND/Critical-Alerts
conflict is resolved for v1 by this story's AC3 (remove the bypass claim,
per the PO scope decision consistent with D1); it does not block delivery.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-5) are unblocked.
