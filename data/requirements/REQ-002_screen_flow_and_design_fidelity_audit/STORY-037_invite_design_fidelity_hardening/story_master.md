# Story Master: STORY-037 Hardening - Invite Screen Visual Fidelity Evidence

Status: DONE
Complexity: trivial
Story-Class: trivial
Implementation Lane: mobile
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-011_invite_code_design_fidelity
Scope: Retro-hardening (RWB-20260816-004)
Screen: invite (tạo mã), Epic 1 (Core connection / onboarding), NO_CHROME /
NO_TABS
Design-Screen: invite
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) (SKIPPED:trivial)
- [x] Architecture (Tech Lead) (SKIPPED:trivial)
- [x] Implementation (Development)
- [x] Review (Reviewer)

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-004 (source: REQ-002
audit report, `retro-audit/audit-report.md`) found
STORY-011_invite_code_design_fidelity's Design Fidelity evidence pair
missing both sides: its own `visual-fidelity/` directory holds only
`visual-fidelity-report.md`, no images either side — the same IF-7-class gap
already remediated for `welcome` (STORY-035) and `register` (STORY-036).

Note: a `design-reference-invite-android.png` already exists in STORY-002's
own `visual-fidelity/` folder, confirming the `invite` canvas screen renders
fine and tooling is not the blocker here — the capture was simply never
produced for STORY-011's own directory.

Note also: STORY-011's own `story_master.md` currently records
`Status: PENDING` with the `Review (Reviewer)` artifact unchecked, even
though `req_master.md`'s `## User Stories` table and the retro audit both
treat it as a completed/DONE screen (same discrepancy pattern already found
and left undisturbed for STORY-006/STORY-036) — Product Owner should
reconcile this discrepancy as part of scoping this hardening story, not
assume it away.

Reconciliation decision (Product Owner): left as documented, not resolved,
in STORY-011's own `story_master.md` — same disposition as the
STORY-006/STORY-036 precedent. This is a stale-checklist/status-field data
hygiene gap on STORY-011's own record, not evidence that the invite screen's
implementation or original AC1-4 audit was incomplete; `req_master.md`'s
`## User Stories` table and the retro audit both independently corroborate
the screen as delivered. Does not block STORY-037's own scope, and this
story must not reopen or edit STORY-011's own closed git boundary/branch to
fix that field.

Exact remediation needed (per `rework-backlog.md`):
1. Capture `implemented-invite-<device>.png` from the running app (dark
   theme + `vi` locale, per STORY-011's own configuration).
2. Render/obtain `design-reference-invite-android.png` via
   `render-design-canvas.js --screen=invite` (or reuse/verify the copy
   already rendered into STORY-002's own `visual-fidelity/` directory,
   confirming it depicts the same screen/state before reusing it).
3. Re-compare both renders against STORY-011's existing AC scope (layout,
   spacing, color/token usage, typography, code-display/share component
   styling); if any deviation is found by the rendered comparison, correct
   it in the app code — this is a fix, not merely a re-documentation.
4. Place the matched, same-screen evidence pair
   (`implemented-invite-<device>.png` and
   `design-reference-invite-android.png`) in this story's own
   `visual-fidelity/` directory, with a `visual-fidelity-report.md` that
   records `VISUAL_FIDELITY: PASS` once both images match.

## Depends On
- NONE. Independent of every other REQ-002 hardening item; must not reopen
  STORY-002's, STORY-011's, STORY-034's, STORY-035's, or STORY-036's closed
  git boundary/branch.

## User Story
As a Product Owner verifying REQ-002's design fidelity claims, I want the
invite/create-code screen's fidelity evidence to be a real
rendered-to-rendered comparison (implemented app screenshot vs. rendered
design canvas), so that STORY-011's `PASS` claim for this screen is backed
by proof instead of a literal CSS/HTML-vs-widget-tree reading.

## In Scope
1. Capture `implemented-invite-<device>.png` from the running app in the
   enabled dark theme + `vi` locale configuration (STORY-011's own
   configuration), and render/obtain
   `design-reference-invite-android.png` via
   `render-design-canvas.js --screen=invite` (or reuse/verify the copy
   already rendered into STORY-002's own `visual-fidelity/` directory,
   confirming it depicts the same screen/state before reusing it).
2. Re-compare the two rendered images against STORY-011's existing AC1-4
   scope: layout, spacing, color/token usage, typography, and code
   display/share component styling (including mono type treatment if
   specified in the source).
3. If the rendered-to-rendered comparison surfaces any deviation not caught
   by STORY-011's original literal-code audit, correct it directly in the
   app code — this is a fix, not a re-documentation exercise.
4. Place the matched, same-screen evidence pair
   (`implemented-invite-<device>.png` and
   `design-reference-invite-android.png`) in this story's own
   `visual-fidelity/` directory, with a `visual-fidelity-report.md` that
   records `VISUAL_FIDELITY: PASS` once both images match.

## Out of Scope
- Where invite/create-code navigates to next (waiting) — remains Scope A
  (STORY-001/STORY-002) territory, unchanged from STORY-011.
- Any new feature, new screen state, or new interaction not already present
  in the locked design source.
- Light theme / `en` locale user-facing visual QA (OQ5 — infra-only, not
  enabled for users yet). Confirmed still unresolved-but-non-blocking in
  `conflicts_open_questions.md`; consistent with STORY-011's and
  STORY-036's own precedent, no dedicated light/`en` rendered pass is
  required for this hardening story.
- Re-litigating STORY-011's original AC1-4 scope framing (no Review Rework
  Patch exists for STORY-011, unlike STORY-006's for STORY-036 — see the
  reconciliation decision in `## Background` above) — this story only adds
  the missing rendered evidence and fixes anything the rendered comparison
  newly surfaces.

## Acceptance Criteria
1. Given the invite/create-code screen rendered in the enabled dark theme +
   `vi` locale, when `implemented-invite-<device>.png` is compared against
   `design-reference-invite-android.png` (rendered via
   `render-design-canvas.js --screen=invite`, or the reused/verified copy
   from STORY-002's own `visual-fidelity/` directory), then layout,
   spacing, color/token usage, and typography match exactly with no visible
   deviation.
2. Given any deviation is found by this rendered-to-rendered comparison,
   when the story is delivered, then the deviation is corrected in the
   app code (not merely documented) and re-verified with a fresh render
   pair.
3. Given the code display/share component on this screen, when rendered,
   then its styling (including mono type treatment if specified in the
   source) matches the design source exactly.
4. Given the comparison is complete and passing, when the story is
   delivered, then this story's own `visual-fidelity/` directory contains
   the matched `implemented-invite-<device>.png` and
   `design-reference-invite-android.png` image pair plus a
   `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS`.
5. Given the screen is reached through its existing normal navigation path,
   when a user arrives at it, then no new entry point is required — this
   story does not change how the screen is reached.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current invite/create-code screen,
  already reachable in the shipped app via its existing navigation path —
  unchanged by this story.
- Direct URL only acceptable: N/A — existing reachable screen, not new.

## Dependencies
- Depends on: NONE (confirms `## Depends On` above).
- Must not require any future story: confirmed.
- Must not reopen STORY-002's, STORY-011's, STORY-034's, STORY-035's, or
  STORY-036's closed git boundary/branch: confirmed.

## Open Question Impact
Re-checked against `data/intake/bootstrap/conflicts_open_questions.md`: OQ5
(light theme / `en` locale) is the only open question touching this
screen's scope. It remains unresolved-but-non-blocking there, deferred to
Product Owner story breakdown per its own working assumption, and is
already excluded from this story's Out of Scope for the same reason
STORY-011 and STORY-036 excluded it — dark + `vi` is the only enabled
user-facing configuration in v1. No other open item in the registry touches
the invite screen or this story's evidence-pairing scope.

### Scope Items BLOCKED in this story
- None. No open question blocks any in-scope acceptance criterion.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-5) are unblocked.

## Review Record
Reviewer: Iris-QC. Two cycles:
- Cycle 1: `Outcome: PATCH_REQUIRED` — 1 blocking (B1, HIGH): the Scaffold's
  opaque `backgroundColor: colors.colorBackground` override at
  `invite_screen.dart:176-177` occluded the shared `CupidAppBackground`
  `--sky` gradient wash + star layer mounted at `cupid_app.dart:59`; AC1/AC2/
  AC4 FAIL. 2 deferred (DEF-1: 6 sibling screens carry the same override,
  out of this story's single-screen scope; DEF-2: report's G4 CTA label
  wrong, fix opportunistically).
- mobile-dev rework: removed the override (+ unused `colors` local) per the
  `forgot_screen.dart:103-106` precedent from STORY-032 AC1; re-captured
  `implemented-invite-emulator-5560.png`; added 4 screen-backdrop probe rows
  to the measured table; fixed DEF-2.
- Cycle 2: `Outcome: DEFERRED_ONLY` — 0 blocking, AC1-5 all PASS,
  independently re-derived (7 self-chosen backdrop probes, 5 exact + 2 within
  1 unit of blue; `flutter analyze`/`flutter test` re-run independently). 1
  deferred remains: DEF-1 (6 sibling screens with the same override —
  `otp_screen.dart:79`, `love_contract_screen.dart:109`,
  `onboarding_profile_setup_screen.dart:85`, `permissions_screen.dart:107`,
  `joincode_screen.dart:125`, `vow_screen.dart:169` — tracked separately as
  RWB-20260816-013, requirement-level sweep, mobile lane).
Full detail: `review/review-report.md`.
