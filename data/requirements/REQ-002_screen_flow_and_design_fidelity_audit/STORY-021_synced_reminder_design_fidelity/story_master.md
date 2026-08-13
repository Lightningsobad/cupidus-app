# Story Master: STORY-021 Design Fidelity — Synced Reminder

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: Synced Alarm/Reminder (renamed per wording rule), Epic 3 (Daily
engagement)
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a paired user setting a shared reminder time with my partner, I want the
screen to match the locked design source's visual pattern exactly and use
the correct product wording, so the ritual is clearly an in-app synced
reminder, not a real device alarm.

## In Scope
1. Re-audit the current Synced Reminder screen against
   `cupid-app-design-system` for the enabled dark theme + `vi` locale
   configuration: shared-time-confirmation UI, dual-swipe-to-dismiss
   affordance styling, spacing, color/design-token usage, and typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source's visual pattern exactly — this is a
   fix, not an audit report.
3. **Mandatory wording fix**: replace every user-visible occurrence of
   "báo thức" / "alarm" / "Synced Alarm" in this screen's UI copy and icon
   label with "nhắc nhở đồng bộ" (synced reminder), per the epic-3 wording
   rule. This is a copy-only rename — the underlying dual-confirmation
   interaction (both partners confirm a time; a synchronized in-app prompt
   fires; both must swipe to dismiss together) is correct as designed and
   is not redesigned. Backend/transport naming (`alarms` module,
   `TRIGGER_ALARM` event) may keep its existing name; only user-visible
   copy changes.

## Out of Scope
- Any redesign of the underlying dual-confirmation interaction pattern
  itself — it is UX-legitimate as designed, only the wording is wrong.
- Any full-screen system alarm UI, DND-bypass behavior, or "keeps ringing
  indefinitely" implication — none of that is in scope to add; this story
  only corrects wording on the existing in-app synced-reminder pattern.
- The Anti-Ghosting / Emoji Storm settings screen — separate screen,
  separate story (STORY-022).
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the Synced Reminder screen rendered in the enabled dark theme +
   `vi` locale, when compared against `cupid-app-design-system`'s
   corresponding screen for layout, spacing, color/token usage, and
   typography, then it matches exactly with no visible deviation.
2. Given any visual deviation was found during this story's audit, when the
   story is delivered, then the deviation is corrected in the rendered app
   (not merely documented) and re-verified against the design source.
3. Given any user-visible text or icon label on this screen, when rendered,
   then it reads "nhắc nhở đồng bộ" (or its English equivalent "synced
   reminder" where `en` copy exists in code, per OQ5 infra scope) and never
   "báo thức" / "alarm" / "Synced Alarm".
4. Given the dual-swipe-to-dismiss confirmation affordance, when rendered,
   then its interaction visual (not its underlying logic) matches the
   design source exactly, reframed only as an in-app synced reminder — no
   full-screen system-alarm visual treatment is introduced.
5. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current Synced Reminder screen,
  already reachable in the shipped app.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
OQ5 (light theme / `en` locale) only affects out-of-scope light/`en`
user-facing visual QA per this story's Out of Scope section; it does not
block any in-scope acceptance criterion. The `en` copy variant of the
wording fix (AC3) is limited to the already-built infra strings, not a new
translation pass.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-5) are unblocked.
