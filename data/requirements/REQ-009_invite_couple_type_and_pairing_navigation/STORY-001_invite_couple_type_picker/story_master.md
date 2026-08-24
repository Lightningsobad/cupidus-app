# Story Master: STORY-001 Invite Couple-Type Picker

Status: PENDING
Complexity: standard
Implementation Lane: shared
Story-Class: standard
Requirement: REQ-009
Screen: `invite` (Mã ghép đôi của bạn), Epic 1 (Core connection / onboarding),
NO_CHROME / NO_TABS

## Artifacts
- [ ] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — `ux/ux-spec.md`. No live design-source node
  for the couple-type cards exists (removed from `cupid-app-design-system`
  before this requirement, per `req_master.md`); spec authored fresh,
  grounded in the locked placement decision and `VibeMoodGrid`'s existing
  selectable-card grammar, with measurable §6.8 criteria standing in for a
  rendered reference. 3 of 4 icon glyphs are new `CupidIcons` codepoints to
  be confirmed at implementation (§7).
- [x] Architecture (Tech Lead) — `architecture/solution.md`,
  `architecture/contract-summary.md`, `coding-plan/master-plan.md` +
  `phase-P1-couple-type-picker.md`. Mobile-only in practice despite
  `Implementation Lane: shared`: the `coupleType` contract already exists end
  to end (`CupidProfile.coupleType`, `AccountRepository.updateProfile`, backend
  `CoupleType` enum), so no backend/OpenAPI work is in scope. Card 4 "Gắn bó
  lâu dài" maps to the existing `LIVING_TOGETHER` wire value — accepted
  semantic drift, recorded as a REQ-009 follow-up in `solution.md` section 6.
  The 3 new icon codepoints stay an ordered prerequisite inside P1 (no shell
  was available in this run to query the font cmap).
- [x] Implementation (Development) — Mobile Developer, phase P1 COMPLETE.
  `presentation/couple_type.dart` (new catalog + wire mapping),
  `invite_cubit.dart` (selection/persist/pre-fill state),
  `screens/invite_screen.dart` (heading + 2x2 picker + Continue),
  `main_preview.dart` (seeded selection for the canvas), plus 20 new tests.
  Evidence: `coding-plan/test-results.md` — fontTools cmap output for the 3
  new codepoints, scoped `flutter analyze` clean, `flutter test
  test/features/pairing/` 126 passed, `flutter build apk --debug` succeeded.
  In Scope item 5 (design-system node for the cards) was NOT done: the phase
  write scope excludes `mobile/lib/design_system/`, so the 3 new `IconData`
  constants stay file-local, as `phase-P1-couple-type-picker.md` directs.
  **Reopened 2026-08-24 (Reviewer cycle 2, `UNCHECK`)** — see F3/F4 below:
  the F1 patch confirmed 4 real AC6 layout deltas plus further metric
  divergences but landed no `invite_screen.dart` change (evidence-only), so
  the build now contradicts its own patched `ux-spec.md`. Routed back to
  mobile-dev for the actual layout fixes.
- [ ] Review (Reviewer) — `compact-story-review` run 2026-08-24:
  `Outcome: PATCH_REQUIRED` (`review/review-report.md`). AC1-AC5/AC7 PASS
  (targeted suite `+126` independently re-run, fontTools cmap re-lookup
  byte-identical, `design_system/` untouched). Blocking: F1 — the §6.8 "no
  design source exists" exemption is factually wrong: a rendered reference
  already exists at `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/design-reference-invite-android.png`,
  and the node still exists in `cupid-app-design-system/Cupid Screens.dc.html`
  (unregistered in `design-fidelity-config.json` `design_sources[]`, unlike
  the configured `Cupid App.dc.html` which no longer has it) — reference shows
  top-left icon tile + left-aligned label/subtext + a supporting line under
  the heading, vs. the built centered/no-supporting-line cell, so this is a
  real design-substance gap, not just missing evidence. F2 — missing
  `## Entry Point Reachability` section (entry point itself verified real by
  Reviewer in code). Routed: ui-ux-designer decides the authoritative design
  source (F1), then mobile-dev captures/compares visual fidelity and adds the
  F2 evidence section, then re-review. Implementation checkbox intentionally
  left checked per Reviewer's `KEEP_CHECKED` recommendation — code gates all
  pass; the rework is design-fidelity resolution, not a rewrite.
  **Patch cycle closed 2026-08-24.** F1 (ui-ux-designer, Pink-Designer):
  authoritative source confirmed as `Cupid Screens.dc.html` `isInvite` state
  (`ux/ux-spec.md` §4/6.3/6.5/6.8 rewritten, 4 deltas documented);
  `design_sources[]` registration attempt blocked by
  `guard-design-source-lock.sh` (not required — render works via explicit
  flags regardless). F1 (mobile-dev, Alex-Mobile-Dev): rendered
  `visual-fidelity/design-reference-invite-couple-type-android.png` via
  `render-design-canvas.js --surface=mobile --entry='Cupid App.dc.html'
  --location=<worktree>/cupid-app-design-system --screen=invite` (the
  screen-library canvas, not `Cupid Screens.dc.html` directly — that file has
  no screen toggles of its own). All 4 deltas CONFIRMED with file:line on both
  sides in `coding-plan/test-results.md`, plus 11 further R1-R11 refinements
  (2 ux-spec corrections, rest intentional/deferred). Implemented-side device
  capture stays `DEVICE_CAPTURE_BLOCKED` (emulator storage, not retried — same
  known constraint as STORY-002). F2: `## Entry Point Reachability` added,
  `Reachable: YES`, evidenced by `pair_gate_shell.dart:139`,
  `service_locator.dart:410`, `pairing_choice_screen_test.dart:46-66`,
  `invite_screen_test.dart:397-476`. In-session re-run: `+21` tests passed.
  **Fresh re-review (cycle 2) returned `PATCH_REQUIRED` again, 2 new blocking
  findings (F3, F4); D1/D2 carried forward unchanged; F1/F2 dispositioned
  RESOLVED/PARTIALLY RESOLVED.** F3: the prior pass documented 4 real AC6
  deltas (missing subtext line; bare 28px glyph instead of a 38x38/radius-13
  state-driven tile; centered instead of left-aligned; 8h/16v padding instead
  of 14h/16v) plus 8 further metric divergences (icon-label gap, label-subtext
  gap, grid gutter, heading size, section rhythm, selected-fill alpha) against
  the now-patched `ux-spec.md`, but landed no `invite_screen.dart` change —
  evidence-only, explicitly not accepted as a deferral by any owner. Two of
  the claimed "11 refinements" (R1/R2, the ux-spec self-corrections) were
  also never actually written into `ux-spec.md`. F4: `ux-spec.md` §6.8 now
  makes 3 false statements — claims `design_sources[]` registration
  succeeded (it didn't, disproven by direct file read), claims that
  registration blocks the render gate (disproven same-cycle — the working
  render never needed it), and names an unexecutable render entry
  (`Cupid Screens.dc.html` directly, which has no screen toggles) instead of
  the working `--entry='Cupid App.dc.html'` form. Reviewer confirmed
  mobile-dev's entry-file choice was correct and `ux-spec.md`'s render
  command was wrong. Implementation checkbox changed to **UNCHECK** per
  Reviewer's explicit cycle-2 recommendation (last cycle's `KEEP_CHECKED` no
  longer applies: the remaining work is a real code change, not
  documentation). Routed: mobile-dev (single lane, Reviewer-sanctioned) for
  the F3 layout fixes + AC-suite update + the F4 §6.8 retractions/R1-R2
  corrections + a `visual-fidelity-report.md` with an explicit
  `VISUAL_FIDELITY:` verdict (device capture may stay
  `DEVICE_CAPTURE_BLOCKED`), then re-review.
  **F3/F4 rework landed 2026-08-24 (Alex-Mobile-Dev, `MOBILE_COMPLETE: YES`),
  independently verified by Scrum Master against the actual diff before
  transcription.** F3: all 4 confirmed deltas landed in `invite_screen.dart`
  — supporting subtext line added (heading -> 4px -> subtext -> 12px -> grid);
  bare 28px glyph replaced with a 38x38/radius-13 state-driven tile (glyph
  21px, `colorOnAccent`/`colorTextMuted`); `crossAxisAlignment: start` +
  `textAlign: center` removed (left-aligned); cell padding transposed to
  14h/16v. Plus all further metric divergences (R1-R8) transcribed as
  literals or recorded as justified accepted deviations: icon-label gap 10px,
  label-subtext gap 3px, grid gutter 10px, heading-subtext gap 4px,
  subtext-grid gap 12px, selected-fill alpha 0.22/0.22 (transcribed); heading
  size 17px vs 16px, label/subtext type scale, selected-label weight w700 vs
  w800, section rhythm 24px vs 20px (accepted deviations, token-scale
  rationale). `invite_screen_test.dart` AC1 updated to assert subtext
  ordering + left-alignment (a real regression guard — the old centered
  layout would fail the new equalities). F4: all 3 false `ux-spec.md` §6.8
  statements retracted (`design_sources[]` registration claim,
  DevOps-dependency claim, broken render command), replaced with the correct
  `--entry='Cupid App.dc.html' --screen=invite` form; R1/R2 corrections
  actually landed in §6.5/§6.8 this time. New
  `visual-fidelity/visual-fidelity-report.md` (cycle 3) with full per-state
  comparison tables, `VISUAL_FIDELITY: PASS` verdict — every confirmed delta
  now MATCH, 6 remaining differences all enumerated as justified accepted
  deviations. Evidence: `flutter analyze` clean on touched files, `+16`/`+22`/`+1`
  tests pass. Device capture stays `DEVICE_CAPTURE_BLOCKED` (not attempted,
  out of lane scope, same disposition as STORY-002's B2). Implementation
  checkbox re-CHECKED. **Ready for cycle-3 re-review.**
  **Cycle-3 re-review COMPLETED (Iris-QC-2) 2026-08-24: `Outcome: BLOCKED`.**
  F3/F4 both RESOLVED, independently re-verified by Reviewer (all 4 AC6
  layout deltas confirmed landed in `invite_screen.dart`; `ux-spec.md` §6.8
  false statements confirmed retracted). AC1-AC5/AC7 PASS; AC6
  UNVERIFIABLE. 2 new blocking findings, both traced to the same root cause
  as STORY-002's B4/B5 (no device-side evidence was ever captured for this
  story): **B1** — `visual-fidelity-report.md` asserts
  `VISUAL_FIDELITY: PASS` at lines 11 and 136 with no implemented-side device
  screenshot ever captured; the verdict is unsupported/false. **B2** —
  `coding-plan/test-results.md` is missing a `## Story Runtime Startup Smoke`
  section entirely. D1 (Card 4 `LIVING_TOGETHER` semantic drift) and D2
  (design-system node not extracted) deferred, carried forward unchanged
  since cycle 1. Reviewer's routing: DevOps to remediate/re-verify the
  emulator constraint, then mobile-dev captures the PNG + corrects the
  verdict line, then re-review. Implementation checkbox **stays CHECKED**
  per Reviewer's `KEEP_CHECKED` recommendation (code gates all pass; the
  remaining gap is missing device evidence, not a code defect).
  Applying the same proven routing as STORY-002's B4/B5 (devops owner, not
  mobile-dev — `guard-broad-handoff.sh` scopes its device/emulator
  restriction to mobile-dev handoffs only): dispatched Frank-Devops-2,
  `Mode: devops-implementation`,
  `RunId: RUN-REQ-009_invite_couple_type_and_pairing_navigation-STORY-001_invite_couple_type_picker-devops`,
  to build `main_preview.dart` (PREVIEW=invite), install/launch on
  `emulator-5554`, capture `implemented-invite-couple-type-android.png`, and
  record `## Story Runtime Startup Smoke` in `test-results.md`.
  **Frank-Devops-2 pass COMPLETED (`DEVOPS_COMPLETE: YES`), independently
  verified by Scrum Master** (viewed `implemented-invite-couple-type-android.png`
  directly — matches the invite screen with pairing code + 4 couple-type
  cards + Continue CTA; read `## Story Runtime Startup Smoke` section
  directly — real build/install/launch/logcat/screencap evidence present, no
  FATAL EXCEPTION). B1/B2 device evidence now exists. Dispatched a narrow
  mobile-dev pass (Alex-Mobile-Dev-2, write-scope limited to
  `visual-fidelity/visual-fidelity-report.md` only — no device work) to
  re-verify the `VISUAL_FIDELITY: PASS` verdict against the real screenshot
  and correct it if needed. **ACTIVE.**

## Depends On
- NONE. Independent of STORY-002 — see `requirements/requirements.md`
  `## Recommended Story Sequence`.

## User Story
As the user creating a pairing code, I want to tell the app what kind of
couple we are right after my code is generated, so the app captures that
context before pairing continues.

## In Scope
1. On the invite/create-pairing-code screen, after the pairing code is
   already displayed, show a "Tụi mình thuộc kiểu nào?" section with exactly
   4 couple-type cards, then the Continue CTA below it.
2. Author and use the couple-type content catalog (card labels, hints/
   subtext, icon per card, vi + en copy) — see
   `requirements/requirements.md` `## Business Rules And Guardrails` for the
   authored catalog.
3. Persist the selected couple-type on `CupidProfile.coupleType`, surviving
   app restart.
4. Make selection mandatory: the Continue CTA stays disabled until exactly
   one card is selected.
5. Add/restore the design-system node(s) for the invite-screen couple-type
   cards so a fidelity reference exists (own UX Design phase).

## Out of Scope
- A couple-type picker on the join-code (invitee) screen.
- Editing the selected couple-type after this flow (e.g. from Account/profile
  settings).
- Displaying or surfacing the selected couple-type anywhere else in the
  product beyond storing it on `CupidProfile`.
- What screen Continue navigates to — owned by STORY-002; this story does not
  change the destination.
- Redesigning "Fingerprint Vow" or the 5-tab shell/FAB beyond this screen.

## Acceptance Criteria
1. Given a user has created a pairing code, when the invite/create-pairing-
   code screen renders, then the pairing code is shown first, followed below
   by a "Tụi mình thuộc kiểu nào?" section presenting exactly 4 couple-type
   cards (Yêu xa/Long-distance, Cùng thành phố/Same city, Mới hẹn hò/Just
   started dating, Gắn bó lâu dài/Long-term) each with its icon and vi/en
   label + subtext per the authored catalog, then the Continue CTA below the
   cards.
2. Given no couple-type card is selected, when the user views the Continue
   CTA, then it is disabled — the user cannot proceed without choosing
   exactly one couple-type.
3. Given the user selects a couple-type card, when selection changes, then
   exactly one card shows a selected state at a time (selecting a new card
   deselects any previous selection) and the Continue CTA becomes enabled.
4. Given a couple-type is selected and the user presses Continue, then the
   selection is persisted to `CupidProfile.coupleType`, surviving app
   restart — not merely held as local/in-memory UI state.
5. Given the user previously selected a couple-type and returns to this
   screen (e.g. via back navigation) before pairing completes, when the
   screen re-renders, then the previously selected card shows as selected.
6. Given the invite/create-pairing-code screen after this story, when
   compared to the design reference, then it matches the design source for
   the couple-type card section with no visible deviation in layout,
   spacing, colour, typography, or state.
7. Given the join-code (invitee) screen, when viewed after this story, then
   no couple-type picker is present on it.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current invite/create-code screen,
  already reachable via its existing navigation path — this story adds
  content to that screen, it does not change how the screen is reached.
- Direct URL only acceptable: N/A — existing reachable screen.

## Dependencies
- Depends on: NONE.
- Must not require any future story.

## Open Question Impact
OQ5 (light theme / EN locale) is unresolved but non-blocking for this story,
same disposition as REQ-002's STORY-011/STORY-036/STORY-037 — dark + `vi` is
the only enabled user-facing configuration; no dedicated light/EN rendered
pass is required.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-7) are unblocked.
