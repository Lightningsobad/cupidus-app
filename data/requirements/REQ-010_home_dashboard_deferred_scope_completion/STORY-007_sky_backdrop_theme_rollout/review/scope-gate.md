# Review Scope Gate: STORY-007 `--sky` Global Screen Backdrop Rollout

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `full-story-review` (compact-story-review gate, complex story)
- Review report path:
  `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-007_sky_backdrop_theme_rollout/review/review-report.md`
- Scope gate path:
  `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-007_sky_backdrop_theme_rollout/review/scope-gate.md`

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget or why it must stop: the diff vs `BaseHead
  964fc65e8e474ea4befa1389fffca1c466ea6920` is 7 files / 1325 insertions, of
  which 2 are test files and 5 are evidence artifacts. `mobile/lib/**` is a
  zero-file change surface, so there is no production behaviour to trace. The
  whole review fits one pass: read two test files, re-run the three gates, and
  inspect four PNGs.
- Current story or bug status: `PENDING` in `story_master.md`; implementation
  lane reported `MOBILE_COMPLETE: YES` at commit `32ce531`.

## Governing Inputs

- Primary artifacts:
  - `../story_master.md` (`## Acceptance Criteria`, `## Open Question Impact`)
  - `../coding-plan/master-plan.md` (`## 2A`, `## 2B`, `## 3A`, `## 6`)
  - `../coding-plan/phase-P1-backdrop-occlusion-guard-and-probes.md`
    (`## 3 Tasks`, `## 4 Acceptance Criteria`, `## 6 Test Scope`)
- Existing review findings: `N/A` — first review of this story
- Test evidence: `../coding-plan/test-results.md`, `../visual-evidence/*.png`
- Extra artifacts required beyond the default minimum: none. `architecture/
  solution.md` was not loaded whole; its AD-3 allowlist basis is quoted verbatim
  in `story_master.md` OQ-1/OQ-3 and in the guard's `_allowlist` constant, which
  is the version that actually executes.

## Source/Test Files In Scope

- `mobile/test/design_system/shared_backdrop_occlusion_guard_test.dart` (new, 532 lines)
- `mobile/test/design_system/shared_backdrop_occlusion_test.dart` (extended, +302 lines)

Explicitly verified out of scope by measurement, not by assertion:
`git -C <worktree> diff --stat 964fc65e8e474ea4befa1389fffca1c466ea6920 HEAD --
mobile/lib` returns empty.

## Evidence Files In Scope

- `../coding-plan/test-results.md` (491 lines)
- `../visual-evidence/ad6-home-hero-glow-dark-vi.png`
- `../visual-evidence/ad6-pair-gate-shell-dark-vi.png`
- `../visual-evidence/ad6-timeline-dark-vi.png`
- `../visual-evidence/ad6-chat-dark-vi.png`

## Risk Surfaces And Critical Gates

- Touched risk surfaces: all six rows of `master-plan.md` `## 3A`.
- Source-of-truth artifacts or contracts: `story_master.md` AC1-AC3 as patched by
  OQ-1/OQ-2/OQ-3; the in-test `_allowlist` constant (single consumer: its own
  test file); no cross-lane contract exists.
- Critical gates to verify:
  1. `mobile/lib/**` diff is empty vs `BaseHead` (AC5, hard constraint).
  2. Guard flags zero production files and is provably non-vacuous.
  3. All three allowlist entries carry an inline rationale and still occlude.
  4. The four AD-5 probes pass with `_expectSharedBackdropShowsThrough`
     unweakened, and the six STORY-046 probes are unmodified.
  5. `flutter analyze` clean on the two story files.
  6. Full `flutter test` green (whole-inventory guard must not flag an unrelated
     existing screen).
  7. Both AD-6 visual intersections recorded with real capture evidence.
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE` — no frontend (web) lane
  participated in this story.
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `REQUIRED when requirement had mobile
  participation` — satisfied at story level by the four AD-6 captures; the
  requirement-level audit remains REQ-010 integration-review scope.
- Missing gate evidence or blocker: `N/A` — see review report Deferred Findings
  D3/D4 for two recorded-evidence gaps that were closed by direct re-measurement
  rather than left open.

## Query Keys

- AC ids: story AC1/AC2/AC3; phase AC1-AC6
- OQ ids: OQ-1, OQ-2, OQ-3
- Architecture decisions: AD-3 (allowlist), AD-4 (static guard), AD-5 (runtime
  probes), AD-6 (targeted visual pass)
- Symbols: `_allowlist`, `_violationsIn`, `_depthOneArguments`, `_alphaModulated`,
  `_expectSharedBackdropShowsThrough`, `_scaffoldCalls`, `CupidAppBackground`
- Anchors: `mobile/lib/app/cupid_app.dart:58-59`,
  `mobile/lib/design_system/theme/cupid_theme.dart:45`,
  `mobile/lib/features/home/presentation/home_screen.dart:310`
- Commands: `flutter test test/design_system/...`, `flutter analyze <2 files>`,
  `flutter test`, `git diff --stat <BaseHead> -- mobile/lib`
- Assertions: `occluded.g > 0.5`, `washed.g < 0.2`, `everyElement(isNull)`

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: N/A
- If `NO`, exact blocker or re-scope instruction: N/A
