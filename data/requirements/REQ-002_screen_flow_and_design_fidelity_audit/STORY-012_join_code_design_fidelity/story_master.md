# Story Master: STORY-012 Design Fidelity — Join / Enter Pairing Code

Status: PENDING
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: joincode (nhập mã), Epic 1 (Core connection / onboarding), NO_CHROME
/ NO_TABS
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development) — `visual-fidelity/visual-fidelity-report.md`
- [ ] Review (Reviewer)

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a user entering my partner's pairing code, I want the screen to match the
locked design source exactly, so the app feels visually consistent and
trustworthy while I complete pairing.

## In Scope
1. Re-audit the current join/enter-code screen (chromeless, no tab bar)
   against `cupid-app-design-system` for the enabled dark theme + `vi`
   locale configuration: code-entry input styling, primary CTA styling,
   spacing, color/design-token usage, and typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.
3. Audit code-entry states present in the design source (empty, partial,
   error/invalid code) for token/style fidelity.

## Out of Scope
- Where this screen navigates to next (waiting or paired) — Scope A
  (STORY-001/STORY-002) owns inter-screen navigation correctness.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the join/enter-code screen rendered in the enabled dark theme +
   `vi` locale, when compared against `cupid-app-design-system`'s
   corresponding screen for the elements within this story's authorized
   write scope — page background, hero badge (size, radius, color, icon),
   content-column layout/top-alignment, and the code-entry input row
   styling (5-slot layout as shipped) — then those elements match exactly
   with no visible deviation. The three items listed under
   "Follow-Up Scope (Deferred)" below are explicitly excluded from this
   criterion's bar.
2. Given any deviation was found during this story's audit within the
   scope defined by AC1, when the story is delivered, then the deviation
   is corrected in the rendered app (not merely documented) and
   re-verified against the design source. Deviations tied to the
   "Follow-Up Scope (Deferred)" items below are excluded from this
   criterion and tracked separately.
3. Given each code-entry state present in the design source (empty,
   partial, error/invalid), when rendered, then each state's styling
   matches the design source exactly.
4. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## Follow-Up Scope (Deferred)
The following items were identified during this story's design-fidelity
audit but are explicitly out of scope for AC1/AC2 above. They are
registered here as REQ-002 follow-up scope; Scrum Master owns the decision
on when/how to convert them into stories.
1. `Dán`/`Quét QR` row (scan/share QR affordance) on the join-code screen —
   requires clipboard + camera plugin integration, `pubspec.yaml` changes,
   and platform permission manifests. Genuine feature work, not a
   style/token fix.
2. `Tôi mới là người tạo mã →` cross-link ownership/placement on the
   join-code screen — owner story must be confirmed before implementation.
3. Code-entry row slot count/layout — 5-slot delivered vs. the design
   source's stated value; confirm the design source's actual slot count
   before deciding whether this is a real gap or a stale assumption. Spans
   `joincode`, `invite`, and `waiting` screens — Product Owner decision.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current join/enter-code screen,
  already reachable in the shipped app.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
OQ5 (light theme / `en` locale) only affects out-of-scope light/`en`
user-facing visual QA per this story's Out of Scope section; it does not
block any in-scope acceptance criterion.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-4) are unblocked.
