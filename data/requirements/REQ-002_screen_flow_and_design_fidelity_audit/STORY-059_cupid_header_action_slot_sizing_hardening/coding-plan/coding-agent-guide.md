# STORY-059 — Coding Agent Guide

Story: STORY-059_cupid_header_action_slot_sizing_hardening
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Lane: mobile-dev (single lane, single phase)

## Read Order

1. `phase-P1-cupid-header-oversized-action-contract.md` — the executable steps.
2. `../architecture/solution.md` §1-§3 only if a step's rationale is unclear.
3. `master-plan.md` for the AC coverage map.

Do not full-read `../requirements/requirements.md` or `../ux/uiux-spec.md`; the
ACs and the UX decision are already transcribed into the phase file and the
solution. Query them by AC id only if you need to confirm exact wording.

## Path Warning

The upstream handoff referenced
`mobile/lib/features/design_system/widgets/cupid_header.dart`, which does not
exist. The real paths are:

- `mobile/lib/design_system/adaptive/cupid_header.dart`
- `mobile/lib/design_system/adaptive/cupid_add_action.dart`

## The One Decision Already Made For You

`CupidHeader` gets an explicit `bool hasOversizedAction` opt-in parameter. It
does **not** inspect the `actions` list for a `CupidAddAction` marker/type. The
real Dream Jar call site wraps the FAB in `Semantics`, so type inspection
returns false there while the unwrapped AC2 test would still pass — a guard that
green-lights its own regression test and fails in production. If you find
yourself writing `actions.any((w) => w is ...)`, stop; that is the rejected
design.

## Non-Negotiables

- Band value is exactly `60`. Larger values render the FAB 60xN — a new
  deviation, because `AppBar` stretches actions to a tight `toolbarHeight`.
- `preferredSize` and `AppBar.toolbarHeight` must move together in the same
  edit, or the `Scaffold` slot clips the taller bar.
- `cupid_add_action.dart` stays untouched (AC3).
- `profile_edit_screen.dart` and its test stay untouched and must still pass
  (AC4).
- The default (`hasOversizedAction: false`) path must render byte-identically to
  today.
- No e2e / emulator / Playwright gate.

## Stop And Report Instead Of Improvising

- A test outside the declared write scope fails.
- `flutter analyze` reports a new issue you cannot fix inside write scope.
- The AC2 assertion lands on anything other than `const Size(60, 60)`.

Report back with the AC1-AC4 evidence table and the exact `flutter test` result
lines.
