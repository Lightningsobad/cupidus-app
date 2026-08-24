# Phase P1 – Design-Source Pairing-Choice Restore

## 1. Objective

Restore the `pairingchoice` design-canvas node and the `invite`/`joincode`
navigation data that commit `3d74a75` deleted, so AC6 has a design reference to
compare against and the canvas stops asserting a `goVow` post-code target.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-design-source-pairing-choice-restore.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `cupid-app-design-system/Cupid App.dc.html`
  - `cupid-app-design-system/Cupid Screens.dc.html`
- Impacted Runtime Service/App:
  - Name: `mobile` (Flutter app)
  - Runtime Registry Id: resolve from the registry (see below) before running
    any command; Tech Lead was forbidden to read it in this handoff.
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Readiness Check: N/A
  - Port Contract: N/A
- Risk Surfaces:
  - Design reference existence (AC6)
  - Parallel write collision with STORY-001
- Source Of Truth:
  - authoritative artifact: `../ux/ux-spec.md` sections 1-2, items a-g — a
    verbatim edit script already verified line-by-line against the current file.
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` Business Rules And Guardrails
  - architecture: `../architecture/solution.md` §1 Key Discovery, §4
  - UX constraints: `../ux/ux-spec.md` §1-2 (required — this phase applies it)
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: design-canvas restore for one screen node plus its
    navigation data
  - Source/Test File Count: 2
  - Split Required: NO

## 2. Required Reads

- `../ux/ux-spec.md` sections 1-2
- `../architecture/solution.md` §1 Key Discovery and §4

## 3. Tasks

- Apply `../ux/ux-spec.md` §1 to `cupid-app-design-system/Cupid App.dc.html`:
  insert the `data-screen-btn="pairingchoice"` span between the existing
  `profile` and `contract` buttons.
- Apply `../ux/ux-spec.md` §2 items a-g to
  `cupid-app-design-system/Cupid Screens.dc.html` exactly as written:
  (a) the `isPairingChoice` screen body after the `isProfile` block;
  (b) the `isInvite` CTA retargeted from `goVow` to `goWaiting` with the
  "Tiếp tục → Đợi ghép" / "Continue → Waiting" copy;
  (c) the `INDEX` sidebar item ahead of `invite`;
  (d) `BACK_TO` — `invite: 'pairingchoice'`, `joincode: 'pairingchoice'`, and
  `pairingchoice: 'profile'`;
  (e) `pairingchoice: 1` in both `NO_CHROME` and `NO_TABS`;
  (f) the `goJoinCode` / `goWaiting` handlers next to the existing cluster;
  (g) the `isPairingChoice` flag next to the existing flags.
- Do not re-derive, reformat, or reorder any surrounding HTML. Line numbers in
  the spec are pre-edit references; locate the anchors by content.
- Produce the AC6 fidelity comparison between the restored `pairingchoice`
  canvas node and the delivered `PairingChoiceScreen`, and record the evidence.

## 4. Acceptance Criteria

- `isPairingChoice`, `goJoinCode`, and `goWaiting` all exist in
  `Cupid Screens.dc.html`.
- The `isInvite` CTA no longer references `goVow` or "Fingerprint Vow"; the
  remaining `goVow` occurrences are only the unrelated handler definition and
  the `isContract`/tail usage.
- `BACK_TO` maps `invite` and `joincode` to `pairingchoice`.
- `NO_CHROME` and `NO_TABS` both contain `pairingchoice`.
- `Cupid App.dc.html` exposes a `pairingchoice` screen button so the node is
  enumerable and renderable.
- AC6 evidence exists: the restored node and `PairingChoiceScreen` match in
  layout, spacing, colour, typography, and state, or every deviation is listed.

## 5. Planned Outputs

- Code directories or files: the two `cupid-app-design-system/*.dc.html` files.
- Notes or evidence: AC6 fidelity result recorded in
  `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: design canvas (`cupid-app-design-system`) + Flutter
  `PairingChoiceScreen`
- Required levels:
  - visual inspection: restored `pairingchoice` node vs `PairingChoiceScreen`
    (dark theme, `vi` locale only — OQ5 disposition)
- Required checks: structural grep proving each acceptance criterion above,
  quoted with file and line in the evidence.
- Mobile discoverability / navigation integration: confirm the node is listed by
  the canvas screen enumeration and reachable from the demo nav bar.
- Minimum gates by risk surface: `Design reference existence (AC6)` — grep
  evidence plus the fidelity comparison.
- Required regression or contract coverage: confirm no other screen body,
  `INDEX` category, or handler was altered — the diff for these two files must
  contain only the seven specified insertions/edits.
- Evidence format: file + line quotes and the fidelity comparison result in
  `coding-plan/test-results.md`.
- Requirement mobile visual audit: YES — `--screen=pairingchoice` render
  compared against the app screen. `render-design-canvas.js` was not found under
  this worktree; if it cannot be resolved, record
  `DESIGN_RENDER_TOOL_UNRESOLVED`, fall back to a
  `main_preview.dart --screen=pairingchoice` capture plus the structural grep
  evidence, and report the gap rather than marking AC6 passed silently.
- Verification strategy:
  - Targeted checks: the greps listed under Acceptance Criteria.
  - Required assertion evidence: quoted grep output and the fidelity result.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-24
