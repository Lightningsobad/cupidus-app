# Story Review Report: STORY-003 Scan-Code Screen QR Scanning Capability

Requirement: REQ-012_pairing_flow_qr_code_and_couple_types_screen
Story: STORY-003_scan_code_screen_qr_scanning_capability
Review type requested: `compact-story-review` (first pass, parallel story review)
Reviewer run: RUN-REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-003_scan_code_screen_qr_scanning_capability-reviewer
Branch: `codex/REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-003_scan_code_screen_qr_scanning_capability`
BaseHead: `d32f02f3c5fdeb0572c2ac2e8fb4831289d9142b`

Outcome: BLOCKED

Blocker: `REVIEW_SCOPE_TOO_BROAD`

## Scope Gate

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES
Review report path: `data/requirements/REQ-012_pairing_flow_qr_code_and_couple_types_screen/STORY-003_scan_code_screen_qr_scanning_capability/review/review-report.md`
Phase 2 may proceed: NO — stop at the scope gate and re-dispatch as scoped slices.

### Gate checks that PASSED (do not redo these)

| Check | Result | Evidence |
|-------|--------|----------|
| Retro gate (skill rule 1a) | PASS | `data/retro-audit/rework-backlog.md` exists but has 0 `Status: PENDING` and 0 `Status: IN_PROGRESS` items. `Retro-Bypass: NO` is correct and no bypass is needed. |
| Governing artifacts >20 KB | PASS (1 of max 1) | Only `coding-plan/test-results.md` (28 033 B) exceeds ~20 KB. `architecture/solution.md` 14 228 B, `visual-fidelity/visual-fidelity-report.md` 12 650 B, `ux/ux-spec.md` 11 936 B, `coding-plan/master-plan.md` 4 193 B are all under. |
| Story artifacts present | PASS | `story_master.md`, `ux/ux-spec.md`, `architecture/solution.md`, `coding-plan/master-plan.md` + P1–P4 phase files, `coding-plan/test-results.md`, `visual-fidelity/` (6 PNGs + report), `deployment/configuration-guide.md` all exist on the branch. |
| Git boundary usable | PASS | `git -C <Worktree> diff <BaseHead>` resolves; 4 commits ahead of BaseHead; worktree clean. |

### Gate check that FAILED

| Check | Budget | Actual | Result |
|-------|--------|--------|--------|
| Touched source/test/config file count | 8 (`compact-story-review`) / 12 (`full-story-review`, the absolute ceiling for any normal mode) | **16** | FAIL |

The 16 touched files under `mobile/` (from `git -C <Worktree> diff --name-only <BaseHead> -- mobile/`):

Source (7)
1. `mobile/lib/features/pairing/presentation/camera_permission_gate.dart`
2. `mobile/lib/features/pairing/presentation/pairing_code_parser.dart`
3. `mobile/lib/features/pairing/presentation/scan_code_cubit.dart`
4. `mobile/lib/features/pairing/presentation/scan_code_route.dart`
5. `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart`
6. `mobile/lib/features/pairing/presentation/screens/scan_code_screen.dart` (590 added lines)
7. `mobile/lib/main_preview.dart`

Test (5)
8. `mobile/test/features/pairing/presentation/camera_permission_gate_test.dart`
9. `mobile/test/features/pairing/presentation/joincode_screen_test.dart`
10. `mobile/test/features/pairing/presentation/pairing_code_parser_test.dart`
11. `mobile/test/features/pairing/presentation/scan_code_cubit_test.dart`
12. `mobile/test/features/pairing/presentation/screens/scan_code_screen_test.dart`

Config (4)
13. `mobile/android/app/src/main/AndroidManifest.xml`
14. `mobile/ios/Runner/Info.plist`
15. `mobile/pubspec.yaml`
16. `mobile/pubspec.lock`

## Rationale

Two independent mode problems, either of which alone requires a re-dispatch:

1. **File count exceeds every normal-mode budget.** `reviewer/SKILL.md` rule 1c
   caps `compact-story-review` at 8 touched source/test/config files and
   `full-story-review` at 12; `references/scope-and-evidence.md:20` repeats the
   12-file ceiling and names `BLOCKER: REVIEW_SCOPE_TOO_BROAD` with a
   scoped-slice re-dispatch as the prescribed remedy. This story touches 16.
   Even discounting the 4 low-content config files (~14 diff lines total), the
   12 remaining source+test files sit exactly at the full-review ceiling and are
   still 50% over the compact budget that was actually requested.

2. **Mode does not match story complexity.** `story_master.md:4` records
   `Complexity: complex`. `compact-story-review` is defined as "default for
   bounded standard stories"; complex/higher-risk stories map to
   `full-story-review` (which also requires a separate `scope-gate.md`, not
   requested here) or to scoped slices. The requested mode is the wrong
   instrument for this story even before the file count is considered.

`SKILL.md:372` is explicit that the response to a too-broad handoff is an inline
scope gate naming the blocking reason plus a `BLOCKED` report — "Do not widen the
review just to avoid a scope decision." Proceeding would mean carrying ~2 500
lines of new code and tests plus a 28 KB evidence artifact through one pass,
which is the exact condition the budget exists to prevent: a thin read producing
a confident `CLEAN` on the gate that lets a story be marked `DONE`.

Nothing here is a finding against the implementation. No defect was assessed, and
none is implied — the story's evidence set looks complete and well-formed at the
gate. This blocks the **review handoff**, not the story's health.

## Action items

Owner: `scrum-master` — re-dispatch as three `Reviewer: scoped-slice` passes plus
one `Reviewer: final-synthesis`. The slices below are aligned to the existing
P1–P4 plan phases so each maps onto per-phase evidence already in
`coding-plan/test-results.md` and nothing has to be re-derived. Each slice is
within the 8-file compact budget.

**Slice 1 — permission foundation + platform config (P1)** — 6 files
- `camera_permission_gate.dart`, `camera_permission_gate_test.dart`
- `AndroidManifest.xml`, `Info.plist`, `pubspec.yaml`, `pubspec.lock`
- ACs: AC1, AC3 (permission-denied half)
- Also resolves handoff focus item 4: `permission_handler` `^12.0.1` pin
  consistency across `pubspec.yaml`, `deployment/configuration-guide.md`, and
  `test-results.md` (rationale: `compileSdk=37` build failure, `master-plan.md`
  §6 note A1)
- Query keys: `permission_handler`, `CAMERA`, `NSCameraUsageDescription`,
  `permanentlyDenied`, `configuration-guide`

**Slice 2 — decode + state logic (P2)** — 4 files
- `pairing_code_parser.dart`, `pairing_code_parser_test.dart`
- `scan_code_cubit.dart`, `scan_code_cubit_test.dart`
- ACs: AC2, AC4
- Query keys: `parse`, `accept-invitation`, `expired`, `malformed`, cubit state
  names

**Slice 3 — screen states, entry point, preview (P3+P4)** — 6 files
- `scan_code_screen.dart`, `scan_code_screen_test.dart`
- `joincode_screen.dart`, `joincode_screen_test.dart`
- `scan_code_route.dart`, `main_preview.dart`
- ACs: AC3, AC4 (UI half), AC5
- Carries the one large artifact: `coding-plan/test-results.md` (28 KB,
  query-first) and `visual-fidelity/visual-fidelity-report.md` + its 6 PNGs
- Must cover: entry-point reachability (rule 12e1, `## Entry Point Reachability`
  verified independently in route/CTA code), mobile-lane design fidelity by
  READING the images (rules 12e2/12e3), and the flagged `_InvalidCard` radius
  deviation decision below

**Final synthesis** — fresh agent, from the three slice reports only.

### Carry-forward instructions for the slice dispatches

Two items from this handoff must be restated verbatim in the relevant slice, or
they will be re-litigated by a fresh reviewer:

- **Runtime smoke is closed.** `coding-plan/test-results.md`
  `## Story Runtime Startup Smoke` was run and recorded by Scrum Master per
  `master-plan.md` §4, because ordinary mobile-dev handoffs are guard-blocked
  from emulator/device runtime work. Slice 3 verifies the evidence is genuine and
  sufficient; it must NOT re-request it or route it back to mobile-dev.
- **The `_InvalidCard` radius deviation needs an explicit verdict, not more
  evidence.** `ux-spec.md:104-106,175` specify `var(--r-btn)` (999px stadium);
  `scan_code_screen.dart:388` deliberately uses `radiusCard`. See
  `test-results.md` "Requirement mobile visual audit" §4.1 and
  `visual-fidelity-report.md` §4.1. Slice 3 must call it either CLEAN (intentional,
  documented, non-regressive) or PATCH_REQUIRED (match the literal spec token) and
  say so in its report rather than leaving it open.

## Traceability

- Requirements: `story_master.md` AC1–AC5, In/Out of Scope, OQ1 `RESOLVED` —
  read at the gate; AC verification deferred to the slices.
- UX / architecture / coding plan / test evidence / visual fidelity /
  configuration guide: located and size-checked at the gate, **not** opened for
  verification. No AC was assessed in this run.
- Risk surfaces identified for the slices to cover: permissions/device API,
  mobile interaction, mobile navigation/discoverability, runtime/configuration,
  package-dependency pin, app lifecycle.

## State recommendation

- Do NOT mark STORY-003 `DONE`. The review gate has not passed.
- Leave `Review (Reviewer)` unchecked.
- The block is on review-handoff scope, not on implementation quality, so the
  story does not need to return to `mobile-dev` and no rework is requested.
  Keep it at its current implementation-complete state pending the slice reviews.
- Blocking findings against implementation: 0 (none assessed).
- Deferred findings: 0.

REVIEW_COMPLETE: YES
