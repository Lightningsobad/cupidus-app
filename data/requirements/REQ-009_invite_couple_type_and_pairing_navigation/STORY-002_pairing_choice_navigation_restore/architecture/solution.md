# STORY-002_pairing_choice_navigation_restore-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-24

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: REQ-009 Locked Navigation Decision 2 — post-code
  navigation must reach Waiting-for-partner through the pairing-choice screen,
  and Fingerprint Vow must never be the immediate post-code destination.
- Architectural invariants / non-goals:
  - INV-1: `vow` is never the successor of `invite` or `joinCode`. It stays
    reachable only on the post-pairing tail `paired -> loveContract -> vow -> home`.
  - INV-2: `PairingChoiceScreen` is the pairing-stack root for an unpaired user
    and the only pusher of `InviteScreen` / `JoincodeScreen`, so both back edges
    resolve to it structurally rather than by a hard-coded back target.
  - INV-3: ADR-4 (`joinCode -> paired`, no waiting step for the invitee) is
    preserved. Non-goal: re-routing the invitee through `waiting`.
  - Non-goal: editing `invite_screen.dart` / `joincode_screen.dart` at all.
- Proposed technical direction: this is a **design-source restore plus runtime
  regression-guard** story, not a Flutter navigation rewrite. Apply the seven
  exact design-canvas edits already specified by `../ux/ux-spec.md` sections 1-2,
  then pin the already-correct Flutter graph with navigation guard tests so a
  later change (notably STORY-001's Continue CTA) cannot silently re-introduce
  a vow target.
- Why this fits the current system: the pairing stack already encodes the target
  graph in `onboarding_chain.dart` and `pair_gate_shell.dart`; the cheapest safe
  change is to stop the two artifacts from diverging again, not to move edges
  that are already where the locked decision wants them.

### Key Discovery

Direct source inspection contradicts the requirement's premise that the app was
rewired to `goVow` and that `pairing_choice_screen.dart` is orphaned. Neither is
true in the Flutter app at `BaseHead b4b481e`:

- `goVow` / `goWaiting` do not exist in **any** `.dart` file (repo-wide grep,
  zero matches). The `goVow` symbol exists only in the design canvas.
- `mobile/lib/core/navigation/pair_gate_shell.dart:139` mounts
  `PairingChoiceScreen` for `PairGateUnpaired()` — it is the live pairing-stack
  root, not orphaned. Andy-PO's flag is confirmed correct.
- `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart:35-53`
  pushes `InviteScreen` and `JoincodeScreen`.
- `mobile/lib/core/navigation/onboarding_chain.dart:37-45` already encodes
  `profileSetup -> pairingChoice`, `invite -> waiting`, `waiting -> paired`,
  `joinCode -> paired`, and confines `vow` to the tail.
- `mobile/lib/features/pairing/presentation/screens/invite_screen.dart:157-166`
  advances to `WaitingScreen` on share/copy; `joincode_screen.dart:164` calls
  `resetTo(OnboardingNode.paired)`.
- Both back actions are `Navigator.maybePop()`
  (`invite_screen.dart:182`, `joincode_screen.dart:200`); because
  `PairingChoiceScreen` is their only pusher, AC4/AC5 already hold.

The real divergence is design-source-only: `cupid-app-design-system/Cupid
Screens.dc.html:201` still targets `{{ goVow }}` with copy "Tiếp tục →
Fingerprint Vow", the file has no `isPairingChoice` node, and `BACK_TO`
(line 1853) still reads `invite: 'profile'` / `joincode: 'invite'`. Pink-Designer-2
authored the exact restore script but did **not** apply it — the HTML is
unchanged. So AC6's design reference does not yet exist, and that is the only
part of this story that is genuinely broken.

AC7 is already satisfiable as-is: no test in `mobile/test/` pins a post-code
`vow` expectation. `test/core/navigation/chain_tail_edges_test.dart` asserts
`paired -> loveContract -> vow -> home`, which is the correct tail and must not
be disturbed. There is no `app_shell_test.dart` vow expectation to update.

## 3. Scope And Assumptions

- In Scope: the two `cupid-app-design-system/*.dc.html` files, and
  navigation-guard test files under `mobile/test/`.
- Out Of Scope: `invite_screen.dart`, `joincode_screen.dart`,
  `pairing_choice_screen.dart`, `onboarding_chain.dart`, `pair_gate_shell.dart`
  — all already satisfy the locked decision; changing them is regression risk
  with no AC behind it.
- Assumptions affecting design:
  - **A1 (AC1/AC3 wording reconciliation):** AC1's literal "Continue takes the
    user to the pairing-choice screen" is read as *pairing-choice is the parent
    stack root and back target*, with Continue advancing to Waiting. Basis: the
    locked decision's own `BACK_TO` clause (`invite -> pairingchoice`) puts
    pairing-choice **above** invite, and the handoff states the target
    explicitly as "the Waiting screen ... NOT `goVow`". Both readings cannot
    hold at once; this one is consistent with the decision text and the code.
  - **A2 (AC3 / ADR-4 conflict — flag for Reviewer and Product Owner):** the
    join-code branch resolves to `paired`, not `waiting`, because ADR-4 makes
    `acceptInvitation(code)` synchronous for the invitee — there is nothing to
    wait for. AC3's binding content ("not Fingerprint Vow") holds. Do **not**
    change ADR-4 inside this story; if Product Owner insists on a literal
    join-code -> waiting edge, that is a new requirement.
  - **A3 (parallel-story boundary):** STORY-001 owns the invite screen's
    couple-type picker and Continue CTA widget. STORY-002 owns the CTA's
    *target contract* and enforces it with a source-scanning guard test instead
    of editing the shared file, so the two branches merge without conflict.

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| OQ5 | UNRESOLVED, non-blocking | None | All of AC1-AC7 | Dark + `vi` is the only enabled configuration; no light/EN rendered pass required, same disposition as REQ-002 STORY-011/036/037. |

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile` (Flutter) navigation surface, plus the
  `cupid-app-design-system` design canvas as the fidelity reference.
- New or changed boundaries: none. The pairing stack boundary
  (`pair_gate_shell` -> `PairingChoiceScreen` -> {`InviteScreen`,
  `JoincodeScreen`} -> {`WaitingScreen`, `paired`}) is confirmed, not moved.
- Shared patterns reused: the repository's existing source-scanning guard-test
  pattern (`test/core/navigation/chain_chrome_guard_test.dart`,
  `test/core/navigation/onboarding_route_registry_guard_test.dart`) is the
  precedent for INV-1's enforcement.

### Affected Modules

- Mobile: `mobile/test/core/navigation`, `mobile/test/features/pairing`.
- Design source: `cupid-app-design-system`.

### Contracts And Integrations

- Back-edge semantics: `invite` and `joincode` keep `Navigator.maybePop()`.
  Do not replace this with an explicit `pairingChoice` route target — a hard
  target would break the alternate push order and duplicate INV-2 in three
  places. The guard test asserts the *resulting* screen, not the mechanism.
- Design-canvas edits are verbatim-apply-only. `../ux/ux-spec.md` sections 1-2
  (items a-g) is the authoritative edit script; re-deriving the HTML from the
  running app is forbidden, since the spec was already verified line-by-line
  against the current file.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Invite post-code target | `mobile/lib/features/pairing/presentation/screens/invite_screen.dart:157-166`; `onboarding_chain.dart:38` | Leave the direct `WaitingScreen` push intact; pin it with a widget test and a source scan that no vow symbol reaches the invite post-code path | `flutter test` on the pairing navigation guard suite is green | Flutter SDK off PATH — prefix `PATH="$HOME/flutter/bin:$PATH"` |
| Join-code post-code target | `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart:164`; ADR-4 | Assert the target is `OnboardingNode.paired` and never `vow`; preserve ADR-4 per assumption A2 | Same suite green | Same |
| Back edges to pairing-choice | `invite_screen.dart:182`, `joincode_screen.dart:200`, `pairing_choice_screen.dart:35-53` | Assert by popping from each pushed screen and finding `Key('pairing_stack')` | Same suite green | Same |
| Design reference existence (AC6) | `cupid-app-design-system/Cupid Screens.dc.html`, `Cupid App.dc.html`; `../ux/ux-spec.md` §1-2 | Apply items a-g verbatim | Grep proves `isPairingChoice`, `goWaiting`, `goJoinCode`, `BACK_TO invite/joincode -> pairingchoice`, `NO_CHROME`/`NO_TABS` entries exist and the `isInvite` CTA no longer targets `goVow`; then a mobile visual audit of `--screen=pairingchoice` vs `PairingChoiceScreen` | `render-design-canvas.js` is not present under this worktree — if it cannot be resolved, record `DESIGN_RENDER_TOOL_UNRESOLVED`, fall back to the structural grep evidence plus a `main_preview.dart --screen=pairingchoice` capture, and report it rather than skipping AC6 silently |
| Parallel write collision with STORY-001 | `../requirements/requirements.md` `INTEGRATION_VERIFICATION_REQUIRED: NO` note | Never write `invite_screen.dart` or `joincode_screen.dart` in this story | `git -C <Worktree> diff --name-only <BaseHead>` lists neither file | If a change to either file looks unavoidable, stop and escalate to Scrum Master; do not edit |
| BUG-20260817-001 regression guard | existing occlusion/app-shell guard tests | Scope new tests to the pairing navigation surface only; touch no existing guard | Existing suite still green | Same as Flutter SDK blocker |

### Lane Handoff

#### Mobile Lane

- Responsibilities: apply the design-canvas restore script; author the pairing
  navigation guard tests; produce the AC6 fidelity evidence.
- Authoritative inputs: `../ux/ux-spec.md` §1-2 (verbatim edit script),
  `../requirements/requirements.md` Business Rules, this document §4.
- Guardrails:
  - Do not modify any file under `mobile/lib/` — the runtime graph is already
    correct and every AC is provable from tests plus the design source.
  - Do not modify `test/core/navigation/chain_tail_edges_test.dart`; its
    `vow` assertions cover the correct post-pairing tail.
  - Do not re-derive the design HTML; apply `../ux/ux-spec.md` items a-g exactly.
  - Do not open, revert, or re-verify commit `3d74a75` or BUG-20260817-001.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Restore design source + pin runtime with guard tests | Source inspection shows the Flutter graph already matches the locked decision; only the design canvas diverged | ACCEPTED | Smallest change that makes every AC provable and blocks re-divergence from STORY-001's CTA. |
| Route the Continue CTA through an explicit `OnboardingRouter` edge in `invite_screen.dart` | Would make the target declarative rather than a direct push | REJECTED | `WaitingScreen` needs the invitation's `code`/`expiresAt`, which a registry `WidgetBuilder` cannot carry (`invite_screen.dart:152-156`), and the edit would collide with STORY-001's write scope on the same file. |
