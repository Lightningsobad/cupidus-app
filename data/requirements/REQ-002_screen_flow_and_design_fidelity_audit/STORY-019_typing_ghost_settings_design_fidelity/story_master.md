# Story Master: STORY-019 Design Fidelity — Typing Ghost Consent/Settings

Status: DONE
Complexity: standard
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-002
Scope: B (Full Design Fidelity Audit)
Screen: Typing Ghost consent/settings, Epic 2 (Communication)
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)
Design entry: `cupid-app-design-system/project/Cupid App.dc.html`
(`screens_from: "canvas"`, per `data/devops/system/design-fidelity-config.json`)
Design-Screen: `ghostset`

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development) — mobile lane; rendered evidence in
  `visual-fidelity/visual-fidelity-report.md` (`VISUAL_FIDELITY: PASS`)
- [x] Review (Reviewer) — Outcome: DEFERRED_ONLY (round 3, `review/review-report.md`,
  HEAD `cd5e3f244d78967df32281d06e0de698dfaa190b`). Deferred: D-1 (Material
  header back-arrow tint, `cupid_header.dart`, no per-screen tint hook —
  design-system story, same class of finding as STORY-031's D3; treat as
  BLOCKING at REQ-002 integration review even though non-blocking here); D-2
  (5 `chat_strings.dart` copy deviations — needs a new follow-up story since
  STORY-018, the prior owner, is already DONE/merged); D-3 (partner-consent
  tile `Chưa rõ` styling, accepted as-is per ADR-013e).

## Story Runtime Startup Smoke
Scoped to `cupid_mobile` on Android. `flutter build apk --debug` →
`adb install -r` → `am start -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
on `emulator-5560`. The real `lib/main.dart` entry point reaches its first
screen (the pairing gate) with no crash, ANR or error screen. Evidence:
`visual-fidelity/implemented-runtime-smoke-first-screen-emulator-5560.png` and
the "Story Runtime Startup Smoke" section of the visual fidelity report.

## Depends On
- NONE. Independent of every other Scope A/Scope B story; runs as part of
  the story-level-parallel wave for REQ-002 Scope B.

## User Story
As a paired user deciding whether to enable Typing Ghost, I want the
consent/settings screen to match the locked design source exactly, so the
decision feels clear, trustworthy, and on-brand.

## In Scope
1. Re-audit the current Typing Ghost consent/settings screen against
   `cupid-app-design-system` for the enabled dark theme + `vi` locale
   configuration: mutual-consent toggle styling and its pending state
   (awaiting the partner's acceptance), Level-1 device-only lock affordance
   (must be visible per §5/§8), spacing, color/design-token usage, and
   typography.
2. Correct every deviation found directly in the app code so the rendered
   screen matches the design source exactly — this is a fix, not an audit
   report.

## Out of Scope
- The chat screen itself where Typing Ghost renders — separate screen,
  separate story (STORY-018).
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet); token-level fixes should stay correct for all 4
  combinations since tokens are shared, but no dedicated light/`en` visual
  pass is required.

## Acceptance Criteria
1. Given the Typing Ghost consent/settings screen rendered in the enabled
   dark theme + `vi` locale, when compared against
   `cupid-app-design-system`'s corresponding screen, then layout, spacing,
   color/token usage, and typography match exactly with no visible
   deviation.
2. Given any deviation was found during this story's audit, when the story
   is delivered, then the deviation is corrected in the rendered app (not
   merely documented) and re-verified against the design source.
3. Given the mutual-consent toggle's states present in the design source
   (off, pending-partner-acceptance, on), when rendered, then each state's
   styling matches the design source exactly.
4. Given the Level-1 device-only lock affordance, when this screen is
   rendered, then it is visible, matching the design source's placement and
   styling.
5. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current Typing Ghost consent/settings
  screen, already reachable in the shipped app.
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
- All acceptance criteria (1-5) are unblocked.
