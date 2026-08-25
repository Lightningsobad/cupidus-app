# Scrum Master Checkpoint: BUG-20260825-001_home_screen_design_mismatch

Bug ID: BUG-20260825-001_home_screen_design_mismatch
Status: ESCALATED_TO_BACKLOG
Attempt Count: 1
Continuation Count: 0

## Canonical Artifact Paths

- Bug Master: `data/bugs/BUG-20260825-001_home_screen_design_mismatch/bug_master.md`
- Diagnosis: `data/bugs/BUG-20260825-001_home_screen_design_mismatch/diagnosis.md`
- Fix Evidence: `data/bugs/BUG-20260825-001_home_screen_design_mismatch/fix-evidence.md`
- Review Report: `data/bugs/BUG-20260825-001_home_screen_design_mismatch/review/review-report.md`
- Checkpoint: `data/bugs/BUG-20260825-001_home_screen_design_mismatch/scrum-master-checkpoint.md`

## Failure Anchors

- Observed: Home screen visually/structurally does not match design at all
  (user report in Vietnamese, no further detail).
- Expected Behavior: inferred from repository design-fidelity precedent —
  Home screen must match the governing UX spec/design source; Bug Fixer must
  confirm exact source and enumerate concrete divergences.
- Suspected impacted screen/component:
  `mobile/lib/features/home/presentation/home_screen.dart` (from runtime
  registry `inAppFirstScreenSignal.sourceFile`)
- Existing test (visual fidelity NOT covered):
  `mobile/test/features/home/home_screen_test.dart` (only asserts
  `home_screen_ready_signal` readiness key)

## Runtime

- Runtime registry path: `data/devops/system/runtime-command-registry.json`
- Runtime Id: `mobile-app` (Flutter, `flutter-app`, path `mobile`)

## Query Keys For Future Bug Fixer Handoff

- `home_screen.dart` — Home screen widget structure/composition
- Home screen governing UX spec / design source: query `ux/uiux-spec.md` (or
  requirement-specific design doc under `data/requirements/*/*/ux/`) for
  "Home" / "home_screen" heading
- Related prior bug (different screen, same general design-fidelity theme —
  NOT confirmed same root cause, do not merge without explicit user
  confirmation): `BUG-20260824-001_pairing_code_screen_missing_design`

## Bug Fixer State

- Active Bug Fixer Agent Id: Justin-BugFixer-2@session-f353b62a
- Bug Fixer Status: ESCALATE_TO_BACKLOG (returned `BUG_FIX_COMPLETE: NO`)
- Changed source/test files: NONE (no patch applied — by design)
- Evidence captured: `evidence/design/design-reference-home-android.png`,
  `evidence/implemented-home-emulator-5554.png`,
  `evidence/implemented-real-entrypoint-emulator-5554.png`
- Pre-Fix Reproduction Gate: `Result: REPRODUCED` (rendered design source vs.
  emulator capture, same modality as report)
- Build Gate: PASS (`cd mobile && flutter build apk --debug`)
- Runtime Startup Gate: PASS (`mobile-app`, `emulator-5554`), `Shutdown: PASS`

## Escalation Reason

STORY-017's owned comparison region (presence row, `247` counter, hero
caption, milestone pill, card rhythm, tab-bar styling, hero glow) still
matches the design — confirmed not a regression via git history
(`93165e4`, `3d74a75`). The "completely wrong" perception comes from
out-of-region widgets STORY-017's review gate already excluded as deferrals
(finding `B5`, `Outcome: DEFERRED_ONLY`): anti-ghost alert card, vibe-check
two-tile card, pet preview card, 2-column quick grid (blocked on
`STORY-023 Zodiac Red Flag`, `DEFERRED`), header share/notification actions,
`--sky` global backdrop, and `Minh` vs `Minh & Linh` couple title (needs a
partner-profile API). Same disposition as
`BUG-20260824-001_pairing_code_screen_missing_design`. Recommended backlog
scope (ordered by visual impact), for a PO/UX-led follow-up requirement/story:
1. Home dashboard feature cards (vibe two-tile, pet, anti-ghost banner) — F3/F6
2. Home dashboard 2-column quick grid — F6 (depends on STORY-023)
3. Header share/notification actions — F3 (needs target routes)
4. Partner name / couple title — F4 (needs backend partner-profile story)
5. `--sky` global backdrop — F10 (theme change across ~37 screens, own story)

Non-blocking notes for whoever picks this up:
- Bug Fixer's first capture omitted `--dart-define=PREVIEW_HOME_FIXTURE=true`,
  causing a harness-artifact false "catastrophic" render (documented and
  withdrawn in `diagnosis.md`). Read STORY-017's visual-fidelity report §1
  before recapturing this screen.
- `PetPreviewCard` shows "Không thể tải Bún" under the preview harness
  (no authenticated backend) — a capture-state gap, not a rendering defect.
  Consider a `PREVIEW_PET_FIXTURE` define mirroring `PREVIEW_HOME_FIXTURE`.

Do not route Reviewer — no patch exists to review.

## Backlog Conversion

Converted 2026-08-25 into `REQ-010_home_dashboard_deferred_scope_completion`
(`data/requirements/REQ-010_home_dashboard_deferred_scope_completion/req_master.md`),
`Status: PENDING`, registered in `master_requirements_list.md`. Product Owner
begins breakdown when ordinary `continue` picks up this requirement.
