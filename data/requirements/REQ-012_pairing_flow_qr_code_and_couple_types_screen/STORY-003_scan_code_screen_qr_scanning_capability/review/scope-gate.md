# Review Scope Gate: STORY-003 Scan-Code Screen QR Scanning — VF Rework Re-review

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `compact-story-review`, bounded to one rework diff. This is not
  the original story gate: that ran as three `scoped-slice` reviews plus a
  `final-synthesis` pass and is recorded in §1-§10 of the review report. This
  gate covers only the visual-fidelity rework appended as §11.
- Review report path: `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-003_scan_code_screen_qr_scanning_capability/review/review-report.md`
- Scope gate path: `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-003_scan_code_screen_qr_scanning_capability/review/scope-gate.md`
- Reviewer run: `RUN-REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-003_scan_code_screen_qr_scanning_capability-reviewer-rework2`

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget: the rework diff is 9 files — 2 source/test,
  2 evidence artifacts, 5 re-captured PNGs — against a 12-file normal story
  budget. The earlier `REVIEW_SCOPE_TOO_BROAD` gate (16 files) does not recur,
  because the handoff explicitly forbids re-reviewing AC1-AC4 or reopening the
  three original slices, and no cubit, parser, gate, route, manifest, plist,
  pubspec, or lock file is in the diff.
- `visual-fidelity-report.md` is 24.8 KB, over the 20 KB full-read ceiling. It
  was read through its rework diff plus targeted ranged reads, never whole.
- Current story status: implementation and rework complete on the story branch
  at `bb089dc84f86e02002c60cf4db47fe25bc20e1d3`; awaiting this re-review gate.

## Governing Inputs

- Primary artifact: `../story_master.md` AC5 only (layout, spacing, colour/token
  usage, typography against the design reference). AC1-AC4 are out of scope for
  this pass by handoff.
- Existing review findings: `review/review-report.md` §1-§10 from the prior
  `final-synthesis` pass (`Outcome: CLEAN` at BaseHead `d32f02f3` / patch
  `e3a204bf`). Extended in place, not replaced. DF-1..DF-4 and UV-1 are
  carry-forward and were not reopened.
- Test evidence: `../coding-plan/test-results.md` §`P4 Re-run —
  Visual-Fidelity Rework (VF-1..VF-6)`.
- Visual evidence: `../visual-fidelity/visual-fidelity-report.md` §1, §4.6,
  §4.7, §5, §6.
- Prior triage carried in as a decision, not re-litigated: Scrum Master accepted
  VF-7 as deferred and non-blocking.

## Source/Test Files In Scope

- `mobile/lib/features/pairing/presentation/screens/scan_code_screen.dart`
- `mobile/test/features/pairing/presentation/screens/scan_code_screen_test.dart`

Confirmed by `git -C <Worktree> diff --stat ea58d0f bb089dc`: no other
`mobile/` file is in the diff.

## Evidence Files In Scope

- `../coding-plan/test-results.md` (rework section only)
- `../visual-fidelity/visual-fidelity-report.md` (§1, §4.6, §4.7, §5, §6)
- `../visual-fidelity/implemented-scan-live-emulator-5554.png` (read)
- `../visual-fidelity/implemented-scan-invalid-emulator-5554.png` (read)
- `../visual-fidelity/implemented-scan-{denied,blocked,unavailable}-emulator-5554.png`
  (re-captured in the diff; verdict rests on the two read above plus the widget
  tests for States 5/6/7, which assert the same VF-5/VF-6 properties)
- `../visual-fidelity/design-reference-scan{live,invalid,denied,blocked,unavailable}-android.png`
  — confirmed ABSENT from the diff, i.e. the comparison surface is unchanged

## Risk Surfaces And Critical Gates

- Touched risk surfaces:
  - State 2 viewfinder composition and a newly introduced repeating
    `AnimationController` (test-harness settling risk)
  - State 4 invalid-card width and viewfinder dimming
  - States 5/6/7 message typography and CTA width
  - Widget-test harness change: `pumpAndSettle` replaced by `_pumpScanning` at
    three sites — checked for weakened or deleted assertions
- Source-of-truth artifacts: `story_master.md` AC5; the rendered
  `design-reference-scan*-android.png` set (authoritative, since the `.dc.html`
  canvas was edited by the UX lane after the findings were written)
- Critical gates to verify:
  - `flutter test test/features/pairing` → `+223: All tests passed!`
  - `flutter test .../scan_code_screen_test.dart --plain-name "design fidelity"`
    → the six VF cases enumerated by name
  - `flutter analyze lib/features/pairing lib/main_preview.dart test/features/pairing`
    → 8 info `prefer_initializing_formals`, unchanged baseline
  - paired-image comparison of re-captured vs unchanged references
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE` — no frontend (web)
  participation in this story
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `REQUIRED when requirement had mobile
  participation` — REQ-012 has mobile participation, so this is required at
  requirement closure and is tracked by the requirement integration review, not
  by this story gate
- Missing gate evidence or blocker: none. Build gate and runtime startup smoke
  were satisfied in the prior pass (report §8) and are unaffected: this diff
  touches one screen widget and its test, no dependency, manifest, or entry
  point.

## Query Keys

- AC ids: AC5
- Finding ids: VF-1, VF-2, VF-3, VF-4, VF-5, VF-6, VF-7 (→ DF-5)
- Symbols: `_ScanningFrame`, `_Viewfinder`, `_ViewfinderState`, `_ScanLine`,
  `_ManualEntryFooter` (was `_ScanningChrome`), `_InvalidCard`, `_MessageState`,
  `_CameraStates`, `_pumpScanning`, `_frameAlpha`
- Constants: `_scanLineHeight`, `_scanLineInsetFraction`, `_scanLineGlowBlur`,
  `_scanLineFadeFraction`, `_scanLinePeriod`, `_viewfinderHelperGap`,
  `_dimmedViewfinderOpacity`, `_invalidCardInset`, `_messageInset`,
  `_messageFontSize`, `_messageLineHeight`, `_messageMaxWidth`,
  `_primaryActionMaxWidth`; removed: `_cardMaxWidth`
- Keys: `Key('scan_viewfinder')`, `Key('scan_line')`
- Test group: `group('design fidelity')`
- Invariants: no assertion weakened or removed for the animation; no cubit,
  parser, gate, route, manifest, plist, pubspec, or lock change; design
  references unchanged
- Diff baseline: `git -C <Worktree> diff ea58d0fb8edd1421f58aefd40ca31f97eaf57258 bb089dc84f86e02002c60cf4db47fe25bc20e1d3`

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: N/A — Phase 2 proceeded.
- If `NO`, exact blocker or re-scope instruction: N/A
