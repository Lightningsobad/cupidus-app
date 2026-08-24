# REQ-009 Integration Regression Fix — Mobile Notes

Scope: STORY-003_integration_regression_fix
Land path: story branch off `main` -> merged to `main` -> carried onto
`codex/REQ-009_invite_couple_type_and_pairing_navigation-integration` via
`git-story-boundary.sh sync-integration` (see `story_master.md` for why this
detour was required instead of a direct integration-branch commit).
Role: mobile-dev
Date: 2026-08-24

## Regression

`mobile/test/features/expenses/pairing_gate_test.dart` →
`PairingRequiredGate (ux/uiux-spec.md §6) tapping the primary action navigates
into InviteScreen` failed after STORY-001 and STORY-002 were combined on the
integration branch. 1 of 1385 tests.

```
Bad state: GetIt: Object/factory with type AccountRepository is not registered inside GetIt.
#5  InviteScreen._defaultInviteCubit (invite_screen.dart:127:44)
#6  InviteScreen.build.<anonymous closure> (invite_screen.dart:139:65)
```

## Diagnosis — test fixture gap, not a production defect

Fix shape (1) from the handoff was selected after reading the code. Evidence:

- `mobile/lib/core/di/service_locator.dart:122-124` already registers
  `AccountRepository` as a lazy singleton in `setupServiceLocator()`. In a real
  app build `getIt<AccountRepository>()` at `InviteScreen` build time always
  resolves.
- `InviteScreen._defaultInviteCubit`
  (`mobile/lib/features/pairing/presentation/screens/invite_screen.dart:126-134`)
  is the composition-root default and follows the same eager-resolve shape it
  already uses for `getIt<PairingRepository>()` on the adjacent line. Nothing
  about it is defective.
- `PairingRequiredGate._openPairingFlow`
  (`mobile/lib/features/expenses/presentation/widgets/pairing_required_gate.dart:19-23`)
  pushes `const InviteScreen()` with no `createInviteCubit` seam, so the gate
  test necessarily goes through the GetIt-backed default. Its `setUp` registered
  only `PairingRepository`, which was sufficient before STORY-001 added the
  couple-type profile read.
- STORY-001's own `invite_screen_test.dart` never registers `AccountRepository`
  either — it bypasses the composition root entirely by always passing
  `createInviteCubit`. So there was no pre-existing GetIt registration pattern to
  copy; the pattern copied instead is the same file's own
  `_NeverReadyPairingRepository`.

Deferring the `getIt<AccountRepository>()` lookup into the `fetchCoupleType`
closure was explicitly rejected as a production "fix": `InviteCubit`
`_loadPersistedCoupleType` (`invite_cubit.dart:140-157`) wraps the fetch in a
best-effort `catch (_)`, so a lazy lookup would have silently swallowed a real
DI misconfiguration instead of surfacing it. That is precisely the
paper-over the handoff warned against.

## Fix applied

`mobile/test/features/expenses/pairing_gate_test.dart` only. No production file
was changed.

- Added `_NeverReadyAccountRepository extends AccountRepository`, whose
  `fetchProfile()` returns a never-completing `Completer<CupidProfile>.future`.
  This mirrors the file's existing `_NeverReadyPairingRepository` precedent
  verbatim (same `super(api: CupidApiClient.create())` construction, same
  never-resolve rationale) and avoids depending on `CupidProfile`'s JSON shape.
- Registered it in the `PairingRequiredGate` group's `setUp` alongside the
  existing `PairingRepository` registration. The existing
  `tearDown(() => getIt.reset())` already covers teardown.
- Added the two matching imports (`account_repository.dart`,
  `cupid_profile.dart`).

The suite only asserts that the CTA lands on `InviteScreen`; the screen stays in
its `InviteLoading` state throughout, so neither repository ever needs to
resolve.

## Verification

Original commands run by Alex-Mobile-Dev-3 in
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-009_invite_couple_type_and_pairing_navigation/mobile`,
independently re-verified by Scrum Master.

### 1. The failing test — PASS

`flutter test --no-pub test/features/expenses/pairing_gate_test.dart`

```
00:00 +0: loading .../test/features/expenses/pairing_gate_test.dart
00:00 +0: PairingStateReader.isPaired (ADR-015.7) true when CouplePairingStore resolves paired
00:00 +1: PairingStateReader.isPaired (ADR-015.7) false when CouplePairingStore resolves unpaired
00:00 +2: PairingStateReader.isPaired (ADR-015.7) false (never optimistic) when CouplePairingStore cannot confirm a status
00:00 +3: PairingRequiredGate (ux/uiux-spec.md §6) shows the dedicated pairing-required message and action, never a generic error or empty state
00:00 +4: PairingRequiredGate (ux/uiux-spec.md §6) tapping the primary action navigates into InviteScreen
00:00 +5: All tests passed!
```

(Dio `*** Request ***` / `*** Response ***` interceptor logging from the three
`PairingStateReader` cases is elided above; it is that suite's normal stubbed
`_FakeHttpClientAdapter` output, not a live network call.)

### 2. STORY-001 + STORY-002 navigation/pairing suites — PASS

`flutter test --no-pub test/core/navigation test/features/pairing`

```
00:04 +191: .../test/features/pairing/presentation/joincode_screen_test.dart: the invite cross-link pushes invite instead of resetting the chain
00:04 +192: .../test/features/pairing/presentation/joincode_screen_test.dart: AC3: the continue path resolves to paired, never vow
00:04 +193: All tests passed!
```

193 tests, 0 failures.

### 3. Expenses suite — PASS

`flutter test --no-pub test/features/expenses`

```
00:01 +59: All tests passed!
```

59 tests, 0 failures.

### 4. Static analysis — clean

`flutter analyze test/features/expenses/pairing_gate_test.dart`

```
Analyzing pairing_gate_test.dart...
No issues found! (ran in 1.5s)
```

Per the handoff's "Do Not Re-read" constraint, the full 1385-test suite was not
re-run; Scrum Master holds that baseline.

## Files changed

- `mobile/test/features/expenses/pairing_gate_test.dart`

`mobile/lib/features/pairing/presentation/screens/invite_screen.dart` was in
write scope but deliberately left unchanged — see diagnosis above.

## Git-boundary note (Scrum Master)

The original parallel-run handoff (`RUN-REQ-009_invite_couple_type_and_pairing_navigation-STORY-003_integration_regression_fix-mobile-dev.json`)
targeted the integration branch directly via `handoff-build.sh spawn` override
fields, without a prior `git-story-boundary.sh start`. That is valid for the
run-state/scheduler bookkeeping, but committing the result hit two guards:

- `guard-orphan-commit.sh [EPHEMERAL_BRANCH_COMMIT]` blocks raw
  `git add`/`git commit` on any `codex/*` branch, including the integration
  branch itself, even for Scrum-Master-owned orchestration commits.
- `git-story-boundary.sh start` (the required route) creates a fresh
  worktree/branch off `main` by default when the story id has no prior
  boundary and the target worktree is not already clean; the integration
  worktree could not be reused in place while this fix sat there uncommitted.

Resolution: the identical, already-verified diff was re-applied cleanly onto a
dedicated `main`-based story worktree/branch
(`codex/REQ-009_invite_couple_type_and_pairing_navigation-STORY-003_integration_regression_fix`),
committed and merged to `main` through `git-story-boundary.sh`, then carried
onto the integration branch via `git-story-boundary.sh sync-integration`. No
behavior differs from the original fix; only the commit path changed.
