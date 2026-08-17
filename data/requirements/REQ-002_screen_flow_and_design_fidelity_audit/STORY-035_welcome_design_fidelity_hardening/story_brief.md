# Story Brief: STORY-035 Hardening - Welcome Screen Visual Fidelity Evidence

Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-004_welcome_design_fidelity
Rework item: RWB-20260816-002 (`data/retro-audit/rework-backlog.md`)

## Gap
STORY-004's `welcome` Design Fidelity row is `UNVERIFIED`: no rendered
evidence either side, only a text report that compared source literally
instead of rendered output (same class as IF-7 in `req_master.md`, root
cause of `BUG-20260816-001`).

## Outcome a stakeholder can observe
The `welcome` screen has a real rendered evidence pair proving it matches
`cupid-app-design-system`, and any deviation that pair surfaces is fixed in
the running app, not just documented.

## Reuse note
`STORY-033_app_shell_design_system_deltas/visual-fidelity/` already has a
`design-reference-welcome-android.png` / `implemented-welcome-emulator-5554.png`
pair for the same screen. Usable as a starting baseline only if `welcome` has
not changed since STORY-033; this story's own `visual-fidelity/` directory
still needs its own physical copy of the matched pair either way.

## Depends On
NONE.
