# Master Coding Plan – Pairing-Choice Navigation Restore

## 1. Planning Metadata

- Story ID: STORY-002_pairing_choice_navigation_restore
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (single lane).
- Contract-first phase required: NO — one specialist owns the design source and
  the guard tests in sequence; there is no cross-lane or cross-repo consumer.
- Parallel execution possible: NO — both phases share one owner and one lane.
- Critical path: P1 -> P2 (order is preference, not a hard dependency; P2's
  assertions do not read the design source).
- Parallelism notes: this story runs on its own worktree branch in parallel with
  STORY-001. Cross-story safety comes from the write-scope guardrail
  (`invite_screen.dart` / `joincode_screen.dart` are never written here), not
  from phase ordering — see `../architecture/solution.md` §3 assumption A3.

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Invite post-code target | P2 |
| Join-code post-code target | P2 |
| Back edges to pairing-choice | P2 |
| Design reference existence (AC6) | P1 |
| Parallel write collision with STORY-001 | P1, P2 |
| BUG-20260817-001 regression guard | P2 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile` (Flutter app): `mobile`, startup smoke `NOT_APPLICABLE`,
    command/source — resolve the exact runtime registry id and analyze/test
    commands from `data/devops/system/runtime-command-registry.json`; the Tech
    Lead handoff forbade reading that registry, so the implementing phase owns
    the lookup. `flutter` is off the default PATH: prefix
    `PATH="$HOME/flutter/bin:$PATH"`.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | NOT_STARTED |
| P2 | Mobile Developer | Mobile | None | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-design-source-pairing-choice-restore.md` |
| P2 | `phase-P2-post-code-navigation-guards.md` |

Phase sizing: P1 writes 2 design-source files and produces fidelity evidence;
P2 writes at most 4 test files. Both fit one specialist lifecycle (roughly six
source/test files). They are kept separate because they are different behavior
clusters with different toolchains and evidence types — a design-canvas restore
verified by render/compare, versus Dart navigation guards verified by
`flutter test` — not because they would touch the same file.

Artifact hygiene: each phase id maps to exactly one canonical phase file; no
duplicates; no trailing verification phase (each phase owns its own tests and
records evidence in `coding-plan/test-results.md`); no phase test scope includes
e2e, Playwright, traces, scenario reruns, or runtime startup smoke.

## 6. Notes

- P2 is the story's entry-point/navigation-integration phase: it asserts that
  the unpaired pair-gate mounts `PairingChoiceScreen` and that both pushed
  screens return to it, so the capability is proven discoverable rather than
  merely present.
- Assumption A2 in `../architecture/solution.md` §3 (join-code resolves to
  `paired` per ADR-4, not to `waiting`) must be carried into the review gate as
  an explicit reviewer note, not silently absorbed.
