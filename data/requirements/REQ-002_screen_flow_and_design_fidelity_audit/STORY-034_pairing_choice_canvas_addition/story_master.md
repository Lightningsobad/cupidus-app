# Story Master: STORY-034 Pairing Choice Canvas Addition (Retro-Hardening)

Status: IN_PROGRESS
Complexity: trivial
Story-Class: trivial
Implementation Lane: ui-ux-designer
Requirement: REQ-002
Scope: Retro-hardening (RWB-20260816-001)
Screen: `pairing_choice` (new canvas node) — pairs with STORY-002's existing
`implemented-pairingchoice-emulator-5560.png` capture
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner) — SKIPPED: fully specified by explicit
  user decision, scrum-master authored this story directly (see
  `req_master.md` § `## Retro Audit`, `retro-audit/audit-report.md`,
  `data/retro-audit/rework-backlog.md` RWB-20260816-001)
- [x] UX Design (UI/UX Designer) — done: added `pairingchoice` node to the
  design system and resolved finding F-B (see `ux/uiux-spec.md`)
- [x] Architecture (Tech Lead) — SKIPPED:trivial (design-asset content change
  only; no code/system-boundary impact)
- [x] Implementation (Development) — DONE (Scrum Master, deterministic
  tooling command): rendered
  `design-reference-pairingchoice-android.png` (406x900) via
  `render-design-canvas.js --screen=pairingchoice --platform=android
  --theme=dark --lang=vi --location=cupid-app-design-system
  --entry="Cupid App.dc.html"`, placed directly in
  `STORY-002_onboarding_pairing_navigation/visual-fidelity/`, pairing it
  with the existing `implemented-pairingchoice-emulator-5560.png`
- [ ] Review (Reviewer) — pending: Iris-QC (Tier 0 lightweight validation is
  forbidden — this story owes rendered visual-fidelity evidence)

## Depends On
- NONE structurally. This story adds a new design-system node and a new
  render; it must not reopen STORY-002's own closed git boundary/branch
  (STORY-002 is DONE/merged — its app code is not touched by this story).

## Background (Retro Audit Finding)

`retro-audit/audit-report.md` (2026-08-16) found
STORY-002_onboarding_pairing_navigation's `pairing_choice` screen
`UNVERIFIED` under the design-fidelity evidence-pairing rule: no
`design-reference-pairingchoice-*` exists anywhere in STORY-002's own
`visual-fidelity/` directory. STORY-002's own investigation (Step C, its
`visual-fidelity-report.md`) confirmed via `render-design-canvas.js
--list-screens` (37 ids enumerated) that no existing canvas screen
corresponds to this state — `invite`/`joincode`/`profile` were each
considered and rejected. That same investigation surfaced finding **F-B**:
the design canvas encodes a *shorter* pairing chain that appears to omit a
`pairing_choice`-equivalent node entirely.

**User decision (2026-08-16, RWB-20260816-001):** the design canvas is
missing this screen, not the app. Add a `pairing_choice` node to the design
system (`cupid-app-design-system`) and resolve F-B, then render
`design-reference-pairingchoice-*` and pair it with the existing
`implemented-pairingchoice-emulator-5560.png` capture already present in
STORY-002's `visual-fidelity/` directory.

## In Scope
1. Add a `pairing_choice` screen/state node to the locked design system
   source (`cupid-app-design-system/project/...`, entry `Cupid App.dc.html`
   / `Cupid Screens.dc.html` per `render-design-canvas.js --list-screens`
   conventions), positioned correctly in the pairing chain.
2. Resolve finding F-B: reconcile the canvas's pairing-chain node
   order/count with what the app actually implements (STORY-002's
   `chain_chrome_guard_test.dart` and its own AC4 chrome-rule verification
   define the app's real chain) so the canvas no longer omits this state.
3. Once the node exists and renders, produce
   `design-reference-pairingchoice-<platform>.png` via
   `render-design-canvas.js --screen=pairing_choice` (or the confirmed
   correct screen id, if it differs).
4. Place the new render in
   `STORY-002_onboarding_pairing_navigation/visual-fidelity/`, pairing it
   with the existing `implemented-pairingchoice-emulator-5560.png` so
   STORY-002's own Design Fidelity row becomes MATCH under the audit rule.

## Out of Scope
- Any change to STORY-002's own app code, navigation, or chrome behavior —
  that story is DONE/merged and is not being reopened for code changes.
- Any other RWB-20260816-* item (002 through 011) — each is tracked and
  worked separately.
- Re-litigating AC4's chrome rule or `chain_chrome_guard_test.dart` — those
  stay authoritative for what the app does; this story brings the canvas
  into alignment with them, not the reverse.

## Acceptance Criteria
1. Given the design system source, when inspected after this story, then a
   `pairing_choice` node/screen exists and is reachable via
   `render-design-canvas.js --list-screens`.
2. Given finding F-B (canvas chain shorter than the app's real chain), when
   this story completes, then the canvas's pairing-chain node order/count is
   reconciled with the app's actual chain (per STORY-002's chrome-rule
   verification) — F-B is closed, not just worked around.
3. Given the new `pairing_choice` canvas node, when rendered via
   `render-design-canvas.js --screen=pairing_choice`, then
   `design-reference-pairingchoice-<platform>.png` is produced and placed in
   `STORY-002_onboarding_pairing_navigation/visual-fidelity/`.
4. Given that render and the existing
   `implemented-pairingchoice-emulator-5560.png`, when both are compared,
   then STORY-002's `pairing_choice` Design Fidelity row reads MATCH under
   the retro-audit's same-screen-pair rule — RWB-20260816-001 can be marked
   RESOLVED.

## System Integration And Discoverability
- UI-facing story: design-asset only — no new app-facing surface, no new
  navigation path. The existing `pairingchoice` screen in the running app is
  unchanged by this story.

## Dependencies
- Depends on: NONE.
- Must not reopen STORY-002's closed git boundary.

## Open Question Impact
None. Not affected by OQ5 (light theme / `en` locale) — this story targets
the same dark+`vi` capture convention as the rest of REQ-002's evidence set.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-4) are unblocked.
