# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned phase file (`phase-P0-welcome-rendered-fidelity-evidence.md`
  or `phase-P1-gradient-axis-fix.md`)
- For P0: `../architecture/solution.md` section 1 `Key Discovery` — the current
  welcome screen already matches the UX match criteria; the UX spec's deviation
  list comes from a stale pre-fix capture.
- For P1: `../architecture/solution.md` section 4 `REVISION 2026-08-17`,
  `D1 root cause`, `D1 blast radius`, and section 6. P1's widened Write Scope
  exists only by explicit user approval and is defect-scoped, not a general
  design-system opening.

## 2. Context Loading Rule

Read only the artifacts named in the phase `Primary Inputs Summary`. Do not
load STORY-004's, STORY-033's, or BUG-20260816-001's artifacts — they are
closed, and their captures are not valid evidence for this story. OQ5 is
already resolved for this story in `../architecture/solution.md` section 3;
do not re-triage it.

## 3. Execution Rule

1. P0 is DONE and reviewed. P1 depends on P0 and is the actionable phase.
2. Evidence first: capture both rendered sides before deciding whether any code
   change is warranted. Zero code change is a valid outcome for P0.
3. A code change is justified only by a deviation visible in this story's own
   fresh rendered pair — never by the UX spec's hypothesis list alone.
4. Never write outside your phase's `Write Scope`. `mobile/assets/**` and
   `mobile/pubspec.yaml` are prohibited in both phases; escalate with
   `SCOPE_BOUNDARY_BLOCKED` instead of widening. P1's carve-out covers only the
   four named gradient-axis helpers — not `gradientDream`, not other tokens,
   not consumer widgets.
5. Stop and escalate rather than downgrading the comparison method. Reading the
   `.dc.html` source against the widget tree is the exact defect (IF-7) this
   story exists to remove; if the emulator or renderer cannot run, the story is
   blocked, not downgraded.
6. `VISUAL_FIDELITY: PASS` may only be recorded once D1 is actually fixed and
   re-measured. Do not flip the current `BLOCKED` verdict on any other basis.

## 4. Plan Update Rule

- Update `## 7. Status` in the phase file in place.
- Record every gate command, exit code, and count in
  `coding-plan/test-results.md`.
- Escalate if the plan is materially wrong; do not redesign it during
  implementation.
