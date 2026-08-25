# Bug Master: BUG-20260825-001 Home Screen Design Mismatch
Status: ESCALATED_TO_BACKLOG
Severity: unknown
Source: user
Created: 2026-08-25
Linked Requirement: REQ-010_home_dashboard_deferred_scope_completion
Linked Story: N/A

## Report

Observed behavior:
User reports (Vietnamese): "Màn hình Home sai hoàn toàn so với thiết kế." (The
Home screen is completely wrong compared to the design.) No further detail
provided on which specific elements diverge.

Expected behavior (inferred from repository design-fidelity precedent — see
`BUG-20260814-001..004`, `BUG-20260815-001..002`, `BUG-20260816-001`,
`BUG-20260817-001`, `BUG-20260824-001`, all of which diagnose screens against
the governing UX spec):
Home screen should visually and structurally match the governing design
source (`ux/uiux-spec.md` and/or any Home-screen-specific story UX spec under
`data/requirements/*/*/ux/`) for layout, components, copy, and visual tokens.
Bug Fixer must confirm the exact design source during diagnosis and enumerate
the concrete divergences found, since the user report names no specific
element.

Reproduction steps or command:
Launch the mobile app (`mobile-app` runtime) and navigate to the Home screen
(`mobile/lib/features/home/presentation/home_screen.dart`).

Failure anchors:
- Stack trace: N/A
- Failing test: N/A (existing: `mobile/test/features/home/home_screen_test.dart`
  asserts only the `home_screen_ready_signal` readiness key, not visual
  fidelity)
- Route/endpoint/component/job: Home screen —
  `mobile/lib/features/home/presentation/home_screen.dart`
- Environment: mobile app (Flutter), runtime id `mobile-app`

## Artifacts

- [x] Diagnosis (Bug Fixer)
- [x] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer) — not applicable, no patch to review

## Routing Notes

- Current owner: scrum-master
- Next role: backlog conversion (Bug Fixer returned `ESCALATE_TO_BACKLOG`
  2026-08-25 — reproduced visually, no regression found, remaining divergences
  are `STORY-017` deferrals `F2`/`F3`/`F4`/`F6`/`F10`)
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md`
- Fix Evidence: `fix-evidence.md`
- Review Report: `review/review-report.md`
- Checkpoint: `scrum-master-checkpoint.md`

## Blockers

- `ESCALATE_TO_BACKLOG`: Bug Fixer reproduced the report visually (rendered
  design-source vs. emulator capture, same-modality) and confirmed the
  presence/counter/hero/milestone/card-rhythm/tab-bar region owned by
  `REQ-002/STORY-017_home_dashboard_design_fidelity` still matches the design
  — not a regression. The remaining "completely wrong" perception comes from
  out-of-region surfaces that STORY-017's review gate already excluded and
  recorded as deferrals (finding `B5`, `Outcome: DEFERRED_ONLY`): anti-ghost
  alert card, vibe-check two-tile card, pet card, 2-column quick grid, header
  share/notification actions, `--sky` theme backdrop, and the couple/partner
  title. Closing these needs new product scope (4+ dashboard widgets, header
  actions, a global theme change) beyond a narrow bugfix and beyond the
  12-file bugfix budget — same disposition as
  `BUG-20260824-001_pairing_code_screen_missing_design`. Needs a PO/UX-led
  REQ-002 (or new requirement) follow-up story, not a bug fix.
