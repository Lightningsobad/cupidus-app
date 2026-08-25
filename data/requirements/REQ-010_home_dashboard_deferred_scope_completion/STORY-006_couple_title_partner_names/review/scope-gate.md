# Scope Gate — STORY-006 Couple Title Shows Both Partner Names

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review type: `compact-story-review` (parallel story gate, `Flow: parallel-story`)
- Review report path:
  `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-006_couple_title_partner_names/review/review-report.md`

> Mode note: `compact-story-review` normally carries its scope gate inline in
> `review-report.md` and does not emit a separate `scope-gate.md`. This file
> exists only because the handoff's `OutputPath` explicitly declared it, so the
> release hook can verify it. The same scope is also recorded inline in the
> report.

## Path Correction

The handoff declared `WriteScope`/`OutputPath` under
`STORY-006_account_screen_cupid_profile_summary`. No such directory exists.
The real STORY-006 directory on the story branch is
`STORY-006_couple_title_partner_names`. Review artifacts were written to the
real directory; creating the declared one would have produced a phantom story
folder.

## Diff Baseline

`BaseHead` supplied by the handoff was `d124f68`. That commit is itself a
story-boundary seal commit holding the story's own backend phase (P0), so
diffing from it hides half the story. Baselines used:

- Full story scope: `git -C <Worktree> diff 9e6f379 190f5c3` (story-breakdown
  commit → current Worktree HEAD). This is the baseline the findings rest on.
- Handoff baseline `d124f68..190f5c3` was also inspected; it isolates the
  mobile P1 phase only.

## Source / Test Files In Scope

| File | Phase |
| --- | --- |
| `backend/src/modules/users/dto/me-profile-response.dto.ts` (new) | P0 |
| `backend/src/modules/users/users.controller.ts` | P0 |
| `backend/src/modules/users/users.controller.spec.ts` (new) | P0 |
| `mobile/lib/features/account/domain/cupid_profile.dart` | P1 |
| `mobile/lib/features/home/presentation/home_screen.dart` | P1 |
| `mobile/test/features/account/domain/cupid_profile_test.dart` | P1 |
| `mobile/test/features/home/home_screen_test.dart` | P1 |

7 files — within the 8-file compact budget.

## Evidence Files In Scope

- `story_master.md` (governing artifact, 2.4 KB)
- `coding-plan/test-results.md` (9.4 KB)
- `visual-fidelity/visual-fidelity-report.md` (6.2 KB)
- `visual-fidelity/header-both-names.png`, `header-degraded.png`,
  `header-long-names.png` (read as images)
- `data/devops/system/design-fidelity-config.json`
- `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-017_home_dashboard_design_fidelity/visual-fidelity/design-reference-home-android.png`
  (cited cross-story anchor, read as image)

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate | Verified |
| --- | --- | --- |
| Typed/generated contract (Swagger DTO on `GET /users/me`) | backend targeted unit tests + build | evidence read |
| Mobile interaction / rendering (Home couple header) | targeted widget + unit tests | re-run independently |
| Mobile static analysis | `flutter analyze` on changed files | re-run independently |
| Mobile navigation / discoverability | `## Entry Point Reachability` + code check | gate MISSING |
| App lifecycle | `## Story Runtime Startup Smoke` | gate MISSING |
| Design fidelity (mobile lane, design source configured) | `VISUAL_FIDELITY: PASS` + `implemented-*`/`design-reference-*` images in this story's `visual-fidelity/` | gate MISSING (captures real, contract unmet) |

## Phase 2 Decision

Phase 2 proceeded. Outcome is `PATCH_REQUIRED` on missing critical gates, not
on the implementation.
