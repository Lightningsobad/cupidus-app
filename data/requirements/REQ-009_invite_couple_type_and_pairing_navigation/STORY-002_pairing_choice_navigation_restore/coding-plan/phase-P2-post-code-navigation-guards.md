# Phase P2 – Post-Code Navigation Guards

## 1. Objective

Pin the already-correct pairing navigation graph with regression guards so
AC1-AC5 and AC7 are provable, and so no later change — notably STORY-001's
Continue CTA — can re-introduce Fingerprint Vow as the immediate post-code
destination.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-post-code-navigation-guards.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/test/core/navigation/post_code_navigation_guard_test.dart` (new)
  - `mobile/test/features/pairing/presentation/invite_screen_test.dart`
  - `mobile/test/features/pairing/presentation/joincode_screen_test.dart`
  - `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile` (Flutter app)
  - Runtime Registry Id: resolve from the registry before running commands;
    Tech Lead was forbidden to read it in this handoff.
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Readiness Check: N/A
  - Port Contract: N/A
- Risk Surfaces:
  - Invite post-code target
  - Join-code post-code target
  - Back edges to pairing-choice
  - Parallel write collision with STORY-001
  - BUG-20260817-001 regression guard
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §1 Key Discovery and
    §4 (invariants INV-1 to INV-3 and the risk table).
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` Business Rules And Guardrails
  - architecture: `../architecture/solution.md` §1, §3 assumptions A1-A3, §4
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one behavior cluster — post-code forward targets and back
    edges for the pairing stack
  - Source/Test File Count: up to 4 (all tests)
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §1 Key Discovery, §3 assumptions, §4
- `../requirements/requirements.md` Business Rules And Guardrails

## 3. Tasks

- Add `post_code_navigation_guard_test.dart` asserting, against
  `OnboardingChain`: `OnboardingChain.next(OnboardingNode.invite)` is
  `OnboardingNode.waiting`; `OnboardingChain.next(OnboardingNode.joinCode)` is
  `OnboardingNode.paired`; neither is `OnboardingNode.vow`; and
  `OnboardingNode.pairingChoice` has no forward successor because it is a
  branching node.
- In the same guard file, add a source-scanning assertion (same pattern as
  `test/core/navigation/chain_chrome_guard_test.dart` and the design-system
  no-fork guard) that the source of
  `mobile/lib/features/pairing/presentation/screens/invite_screen.dart` and
  `.../joincode_screen.dart` contains no `VowScreen`, `OnboardingNode.vow`, or
  `features/vow/` reference. State in a one-line comment why this scan exists:
  it is the only check that catches a future Continue CTA wired straight to vow
  with `Navigator.push`, which a chain-level assertion cannot see.
- Add a widget test proving the entry point and back edges: an unpaired
  pair-gate renders `PairingChoiceScreen` (`Key('pairing_stack')`); tapping
  "Ghép đôi với người ấy" pushes `InviteScreen`; popping returns to
  `Key('pairing_stack')`; tapping "Tôi đã có mã" pushes `JoincodeScreen`;
  popping returns to `Key('pairing_stack')`.
- Add a widget test proving the invite post-code target: with a fake invite
  cubit, invoking share or copy pushes `WaitingScreen` and no vow surface.
- Assert the join-code continue path resolves to `OnboardingNode.paired` using
  the existing router seam in `joincode_screen_test.dart`.
- AC7: confirm by repo-wide grep that no test expects vow as the immediate
  post-code destination, and record the result. Do **not** modify
  `test/core/navigation/chain_tail_edges_test.dart` — its vow assertions cover
  the correct `paired -> loveContract -> vow -> home` tail.
- Do not modify any file under `mobile/lib/`.

## 4. Acceptance Criteria

- AC1/AC2: a test proves the invite post-code action lands on `WaitingScreen`
  and that `invite`'s chain successor is `waiting`, never `vow`.
- AC3: a test proves the join-code continue path resolves to `paired`, never
  `vow` (assumption A2 in `../architecture/solution.md` §3 applies and must be
  cited in the test's own comment).
- AC4/AC5: a test proves popping from `InviteScreen` and from `JoincodeScreen`
  returns to `Key('pairing_stack')`.
- AC7: grep evidence shows no remaining post-code vow expectation, and the
  source scan fails if one is introduced.
- `flutter analyze` reports no new issue in the touched files.
- `git diff --name-only <BaseHead>` for this phase lists no file under
  `mobile/lib/`.

## 5. Planned Outputs

- Code directories or files: the four test files in Write Scope.
- Notes or evidence: pass/fail output and the AC7 grep recorded in
  `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter `mobile` widget + unit tests
- Required levels:
  - unit: `OnboardingChain` forward-edge assertions and the source scan
  - integration: widget tests for the pair-gate -> pairing-choice -> invite /
    join-code push and pop edges
  - mobile build/type-check/static-analysis: `flutter analyze` on `mobile`
- Required checks: no `mobile/lib/` file is written by this phase.
- Mobile discoverability / navigation integration: this phase is the story's
  entry-point verification — it proves `PairingChoiceScreen` is mounted by the
  unpaired pair-gate and reachable, not merely present in the codebase.
- Minimum gates by risk surface: `Invite post-code target`,
  `Join-code post-code target`, and `Back edges to pairing-choice` are each
  gated by their named test above being green.
- Required regression or contract coverage: the existing pairing, navigation,
  and occlusion guard suites must still pass unchanged.
- Evidence format: command, exit status, and assertion output in
  `coding-plan/test-results.md`.
- Verification strategy:
  - Targeted tests: run the new guard file and the touched pairing tests
    individually first, then the `test/core/navigation` and
    `test/features/pairing` directories.
  - Build/type-check command: `PATH="$HOME/flutter/bin:$PATH" flutter analyze`
    from `mobile/` — `flutter` is not on the default PATH.
  - Required assertion evidence: the pass line for each acceptance criterion
    above.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-24
