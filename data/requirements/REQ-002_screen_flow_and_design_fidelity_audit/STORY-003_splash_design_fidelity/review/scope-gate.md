# Scope Gate: STORY-003 Design Fidelity — Splash (Round 2)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: compact-story-review (re-review)
Story: STORY-003 (REQ-002 Scope B) — Implementation Lane `mobile`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-003`
Diff baseline: `5502c134cdbd299bef4a859e1daf584ff183879c` → `d7a17e5`

Review report path:
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-003_splash_design_fidelity/review/review-report.md`

## Round Context

Round 1 returned `PATCH_REQUIRED` for F-1 only (design-fidelity evidence was
prose, not rendered images). BaseHead above is the commit immediately after the
round-1 report, so the diff isolates exactly the F-1 closing work. This gate
scopes a re-review of F-1 closure, not a re-litigation of the round-1 pass.

## Source / Test Files In Scope

Derived from `git -C <Worktree> diff --name-only <BaseHead>` — 5 changed files,
**zero source/test files**, well within the 8-file compact budget:

- `data/.../STORY-003_splash_design_fidelity/story_master.md`
- `data/.../visual-fidelity/visual-fidelity-report.md`
- `data/.../visual-fidelity/design-reference-splash-android.png` (new)
- `data/.../visual-fidelity/implemented-splash-emulator-5554.png` (new)
- `data/.../visual-fidelity/implemented-splash-popin-emulator-5554.png` (new)

No Dart file changed in this round. The implementation cleared in round 1 is
byte-identical, so the round-1 source verdicts (analyze, no-fork guard,
write-scope ruling, routing untouched) carry forward without re-review.

## Evidence Files In Scope

- `visual-fidelity/visual-fidelity-report.md` — the F-1 deliverable
- the three PNGs above, opened and pixel-analysed (not merely presence-checked)
- `story_master.md` — artifact checklist and acceptance criteria

## Corroborating Reads (verification-driven, not speculative)

Each opened only after the primary evidence raised a specific question:

- `data/devops/system/design-fidelity-config.json` — confirm the 12e2/12e3
  rendered check is mandatory and non-waivable (`ui_surface: true`, `locked`)
- `mobile/lib/main_preview.dart` — verify the capture harness genuinely pins the
  audited configuration (dark + `vi`) claimed by the report
- round-1 `review-report.md` — confirm no prior non-blocking finding was
  silently dropped or contradicted

## Touched Risk Surfaces And Critical Gates To Verify

| Risk surface | Critical gate |
|---|---|
| Mobile design fidelity (the reopened surface) | Rendered device capture vs design reference, quantitatively compared (12e2/12e3) |
| Evidence integrity | PNGs committed, non-empty, genuine renders; report numbers independently reproducible |
| Mobile interaction / rendering | Targeted widget tests re-run, not accepted on record |
| Regression from the patch | Confirm the patch added evidence only and touched no code |
| Carry-forward discipline | Round-1 F-2 / D-1 / write-scope items still tracked |

Runtime startup smoke (12g) stays out of gate scope: `story_master.md` records
`Complexity: trivial`. The handoff's `Story-Class: standard` still disagrees with
the artifact; carried as a deferred finding rather than silently choosing the
stricter or looser reading.

## Query Keys For Phase 2

- `Design-Screen`, `VISUAL_FIDELITY` verdict lines
- `design-reference-splash-*.png`, `implemented-splash-*.png`
- gradient ramp, element geometry table, two-state (settled vs pop-in) claims
- AC 1 (the criterion round 1 left UNVERIFIED), AC 2, AC 3, AC 4
- `splash_design_fidelity_test.dart`, `splash_screen_test.dart`,
  `no_fork_guard_test.dart`
- `flutter build apk --debug -t lib/main_preview.dart`

## Gate Decision

Phase 2 focused verification MAY PROCEED. The diff is evidence-only and inside
the compact budget, every governing artifact exists, and no input is missing in
a way that would force a `BLOCKED` outcome before verification.
