# Master Coding Plan – STORY-044 Private Gallery Design Fidelity Hardening

## 1. Planning Metadata

- Story ID: STORY-044_private_gallery_design_fidelity_hardening
- Complexity: standard
- Story-Class: standard
- OQ Constraints Source: `data/intake/bootstrap/conflicts_open_questions.md`
  (OQ5 only; carried in `../architecture/solution.md` section 2)
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  port, or third-party integration change in either phase.

## 2. Planning Goal

- Shared contract owner: P0 (DevOps) owns the `--click` CLI contract that P1
  (Mobile) consumes. The contract surface is one flag on one Node CLI.
- Contract-first phase required: YES — P0 is the contract phase.
- Parallel execution possible: NO.
- Critical path: P0 (tool flag) → P1 (render → compare → conditional in-app fix
  → re-verify → evidence).
- Parallelism notes: P1's primary artifact is `design-reference-gallery-android.png`,
  which physically cannot be produced before P0 lands the flag. There is no
  useful P1 preparation work that does not depend on the rendered reference, so
  overlapping the phases would only produce analysis that P0's real output might
  invalidate.

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 3/4) | Required Dependency |
|-----------------------------------------------------|---------------------|
| Stale line citations, +8 offset (KD1) | P0 and P1 |
| Handler-only click target, no CSS identity (KD2) | P0 |
| Wrong-frame capture under `--platform=all` (KD3) | P1 |
| Ungitted tool change, not reviewable, installer-overwritten (KD4) | P0 |
| R1 prototype FAB returning after the click re-render | P0 |
| R2 hiding out-of-scope design content from the reference | P1 |
| R3 AC7 escalating into unimplemented feature work | P1 |
| R4 a stale PNG read as fresh output | P1 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - P0: NONE. `.ai-team-bundle/runtime/tools/render-design-canvas.js` is
    machine-local bundle tooling, not a registered runtime service. Startup
    smoke `NOT_APPLICABLE`; the tool's own invocation is its verification.
  - P1: `mobile-app` (`mobile`), registry
    `data/devops/system/runtime-command-registry.json`, type `flutter-app`,
    build command source runtime registry `buildCommand`
    (`flutter build apk --debug`). Startup smoke `NOT_APPLICABLE` — the app
    launch happens inside the mobile visual audit, not as a separate readiness
    gate. The build gate applies **only if** P1 edits Dart source.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P0 | DevOps | DevOps | None | NO | DONE |
| P1 | Mobile Developer | Mobile | P0 | NO | DONE |

P0 is a contract phase, not a trailing verification phase: it changes a shared
CLI that every design-fidelity story in this repo uses, so its own regression
proof (AC3) is part of the phase rather than deferred to P1.

P1 is not a pure evidence phase either: AC7 requires it to fix in app code any
in-scope deviation the rendered comparison surfaces, so it owns its own targeted
tests and build gate for the conditional-fix path.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-render-canvas-click-flag.md` |
| P1 | `phase-P1-gallery-rendered-fidelity-evidence.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file. No
  duplicates.
- P0 and P1 each fit one specialist lifecycle (roughly six source/test files
  max); no split required.
- The phases are **not** mergeable: different lanes, different toolchains
  (Node CLI vs Flutter), and a hard artifact dependency in one direction.
- Both phases' test scopes exclude backend e2e/test_e2e, Playwright/browser e2e
  suites, traces, scenario reruns, and repository-root local script gates.
  P0 drives Playwright only as an internal dependency of the tool it is fixing,
  which is not the same thing as running a browser e2e suite.

## 6. Notes

- `../architecture/solution.md` section 1 `Key Discovery` is mandatory reading
  for **both** phases before any edit. In particular KD1: every line number in
  `story_master.md`, `requirements/requirements.md`, and STORY-026's report is
  8 lines stale. The click target is `Cupid Screens.dc.html:741`, not L733, and
  the `galleryOpen` block is L744-759, not L736-751.
- AC1's phrase "before the hide/freeze/shutter capture sequence" cannot be
  satisfied literally — hide and freeze already run before the `--screen` click
  in the real code. The binding instruction is solution.md section 3
  (`P0 tool contract`): insert the click pass after L364 and before L366. P0
  must record this reconciliation so Reviewer does not score it as an AC1 miss.
- P1 must not treat the auto-lock banner (L746-750), the screenshot notice
  (L757), or app extensions E1-E3 as deviations. They are already adjudicated in
  solution.md section 2; re-raising them as findings is the failure mode this
  plan exists to prevent.
- Expected outcome for P1 is evidence-only with zero app code change: STORY-026
  already fixed its in-scope deviations value-by-value against the same source.
  A code change is justified only by a deviation visible in this story's own
  rendered pair, and only inside the section 2 comparison surface.
- KD4 is the one item that can outlive this story. `.gitignore:5` ignores
  `.ai-team-bundle/`, so P0's tool change is not committable here and the next
  `./install.sh` overwrites it. P0 delivers a committed patch artifact for
  reviewability and escalates upstream propagation to Scrum Master, where it
  joins the still-`PENDING` RWB-020 (STORY-042) which has the identical shape.
