# Review Scope Gate: BUG-20260801-006 Pair Gate Cubit Test Stale AppShell Seam

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `bugfix-review`
- Review report path: `data/bugs/BUG-20260801-006_pair_gate_cubit_test_stale_app_shell_seam/review/review-report.md`
- Scope gate path: `data/bugs/BUG-20260801-006_pair_gate_cubit_test_stale_app_shell_seam/review/scope-gate.md`

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget or why it must stop: The claimed fix is a
  single-file, test-only change (`+68 -5`) on `main` in the control checkout,
  with no dedicated worktree. `git diff --stat HEAD` confirms only two tracked
  files changed: this bug's `bug_master.md` and one test file. That is far
  below the full-review cap, so a single focused Phase 2 pass is sufficient —
  no slicing needed.
- Current story or bug status: `FIXED_AWAITING_REVIEW` (`bug_master.md`)

## Governing Inputs

- Primary artifacts: `bug_master.md`, `diagnosis.md`, `fix-evidence.md`
- Existing review findings: `N/A` (first review of this bug)
- Test evidence: `fix-evidence.md` § Target test / Static analysis / Build Gate
  / Runtime Startup Gate / Full mobile suite
- Extra artifacts required beyond the default minimum:
  `data/devops/system/runtime-command-registry.json` (`runtimes.mobile-app`)
  for the authoritative build and readiness commands
- Explicitly excluded per handoff `Do Not Re-read`:
  `data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md`,
  `deployment/deployment-log.md`, the merge commit message, and the five prior
  REQ-001 bug artifacts (`BUG-20260801-001`..`-005`)

## Source/Test Files In Scope

- `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart` (the
  only changed file — full read plus diff against `HEAD` version)
- `mobile/lib/core/navigation/pair_gate_shell.dart` (verify the three
  `create*Cubit` constructor seams and the gate-state switch actually exist as
  the diagnosis claims — read-only, must be unmodified)
- `mobile/test/features/reminders/reminder_copy_guard_test.dart` (verify
  untouched; `BUG-20260801-007` scope)
- `mobile/lib/**` and `mobile/**/*.arb` (verify untouched as a class, via
  scoped `git status --porcelain`, not by reading each file)

## Evidence Files In Scope

- `diagnosis.md`, `fix-evidence.md`, `bug_master.md` § Fix Evidence
- `data/devops/system/runtime-command-registry.json` (`runtimes.mobile-app`
  `buildCommand`, `testCommand`, `readiness`, `notes`)

## Risk Surfaces And Critical Gates

- Touched risk surfaces: test-harness integrity only (assertion strength,
  widget-under-test correctness, `getIt` registration lifecycle, locale
  determinism). No production surface is claimed to be touched — verifying that
  claim is itself a critical gate.
- Source-of-truth artifacts or contracts: `PairGateShell` constructor contract
  (`pair_gate_shell.dart`), AC4 pair-gate behavior encoded in the test group,
  `runtimes.mobile-app` registry entry for gate commands
- Critical gates to verify:
  1. Fix is genuinely test-only (no `mobile/lib/`, no ARB, no `-007` file)
  2. `PairGateShell` really preserves `createPairGateCubit` /
     `createInviteCubit` / `createJoincodeCubit`
  3. Rewritten harness is a faithful equivalent, not weakened or tautological
     (assertion count, test names, removed lines)
  4. Target test re-run by Reviewer: 9/9 pass
  5. Build Gate re-run: `flutter build apk --debug` exit 0
  6. Runtime Startup Gate re-verified per registry (`home_screen_ready_signal`
     widget-test readiness, scoped to `mobile-app`)
  7. Full-suite regression: confirm `+889 -1` with the sole failure being the
     separately queued `BUG-20260801-007`
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE` (mobile-only,
  bugfix flow)
- Requirement visual audit evidence: `NOT_APPLICABLE` (no frontend lane, no
  production UI change)
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in bugfix
  flow` (registry readiness for `mobile-app` is a widget-test signal, not a
  device launch; registry `notes` state root scripts do not launch `flutter
  run` headlessly)
- Requirement mobile visual audit evidence: `NOT_APPLICABLE at bug level`
- Missing gate evidence or blocker: `N/A`

## Query Keys

- `createPairGateCubit`, `createInviteCubit`, `createJoincodeCubit` (seam
  preservation in `pair_gate_shell.dart`)
- `PairGateChecking` / `PairGateUnpaired` / `PairGatePaired` (gate-state switch
  ownership)
- `Key('pairing_stack')`, `HomeScreen`, `BottomNavigationBar` (assertion
  strength in the widget group)
- `expect(` count and `test(`/`testWidgets(` names, current vs `HEAD` (weakened
  assertion detection)
- `getIt.registerSingleton<CouplePairingStore>` / `getIt.reset()` (registration
  lifecycle, leak check)
- `pumpAndSettle` (justification for the single changed pump)
- `home_screen_ready_signal` (runtime startup gate)
- `reminder_copy_guard_test.dart`, `"synced alarm"` (out-of-scope `-007`
  failure attribution)

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: N/A
- If `NO`, exact blocker or re-scope instruction: N/A
