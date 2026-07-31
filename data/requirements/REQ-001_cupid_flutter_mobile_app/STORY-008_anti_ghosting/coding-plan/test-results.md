# STORY-008 P4 Verification — Test Results

- Verification date: 2026-07-30
- Flutter: 3.44.1 / Dart 3.12.1 (`${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter`)
- BaseHead / P3 commit: `3018e979a0fcd239892815e46c7d3f148a96488f`
- Worktree: `story-REQ-001_cupid_flutter_mobile_app-STORY-008`

## 1. Phase Overview / File Hygiene

- `master-plan.md` §5 Phases Overview uses the required table schema. Confirmed.
- Exactly one canonical `phase-Px-*.md` file per phase id (P0-P4); no
  duplicates found (`git ls-files coding-plan/` lists 7 files: 5 phase files +
  `master-plan.md` + `coding-agent-guide.md`).
- `master-plan.md`'s P1/P2/P3 status cells were stale (`NOT_STARTED`) despite
  each phase's own `## 7. Status` section already recording `DONE` with full
  evidence, and despite P0-P3 all being present at BaseHead. Corrected in this
  pass so the table matches the individual phase files (see this file's
  update to `master-plan.md`).

## 2. `flutter test` — PASS (181/181, after fix)

Initial full suite run: **179 passed, 1 failed** (exit 1). Root cause
diagnosed below; a narrow test-harness fix was authorized by Scrum Master
(this run's `WriteScope` was expanded by exactly one file:
`mobile/test/features/auth/presentation/splash_screen_test.dart`) and
applied. Re-run of the full suite after the fix: **181 passed, 0 failed —
"All tests passed!"** (exit 0).

Originally-failing test (now fixed):
`test/features/auth/presentation/splash_screen_test.dart` —
`CupidSessionSignedIn with a resolving token routes to HomeScreen`

Root cause (critical regression, not part of the known AC2/STORY-007
deferral):
- P2 mounted `AntiGhostEntryCard` into `HomeScreen` (additive change, ADR/UX
  compliant on its own).
- `AntiGhostEntryCard`'s `_AntiGhostEntryCardChrome.build` calls
  `AppL10n.of(context)` (`Localizations.of<AppL10n>(context, AppL10n)!`)
  unconditionally.
- `splash_screen_test.dart`'s own `_harness()` builds a bare `MaterialApp`
  that supplies a `theme` but never sets
  `localizationsDelegates: AppL10n.localizationsDelegates`. This is a
  pre-existing gap in that auth-owned test file (STORY-001-003 lane), never
  triggered before because nothing reachable from `SplashScreen` used
  `AppL10n`.
- Now that the same test drives `CupidSessionSignedIn` through to
  `HomeScreen`, `HomeScreen` builds `AntiGhostEntryCard`, which throws
  `Null check operator used on a null value` inside `AppL10n.of`. A cascading
  `RenderFlex overflowed by 99488 pixels` error is a secondary symptom of the
  same crash (Flutter substituting an error subtree), not an independent
  layout bug — the `Column`/`Expanded` structure itself is correct per P2's
  own `anti_ghost_entry_card_test.dart` and `widget_test.dart` (both of which
  wire real localization via `CupidApp`/`AppL10n.localizationsDelegates` and
  pass).
- This is a genuine, deterministic regression against the existing test
  suite, not a flake and not the known/accepted AC2 end-to-end mount
  deferral (ADR-3). It is outside this phase's write scope to fix (P4 write
  scope is lane-owned test files + this document; `splash_screen_test.dart`
  is an auth-lane file from a prior story, and this run's declared
  `WriteScope` restricts writes to `coding-plan/test-results.md`,
  `coding-plan/phase-P4-verification.md`, and `coding-plan/master-plan.md`
  only).
- Fix applied: added `localizationsDelegates: AppL10n.localizationsDelegates`
  and `supportedLocales: AppL10n.supportedLocales` to
  `splash_screen_test.dart`'s `_harness()` `MaterialApp`, matching the pattern
  already used in `test/widget_test.dart` (via `CupidApp`) and
  `anti_ghost_entry_card_test.dart`. This was a one-line test-harness change,
  not a production-code change — `CupidApp`'s real boot path already wires
  `AppL10n.localizationsDelegates` at the root, so production was never
  affected. Full suite re-run confirmed 181/181 passing.

All other suites pass, including full anti_ghosting coverage:
- `flutter test test/features/anti_ghosting/` — 62 passed (unchanged from P3
  evidence: `ghost_config_repository_test.dart`, `anti_ghost_cubit_test.dart`,
  `anti_ghost_screen_test.dart`, `anti_ghost_entry_card_test.dart`,
  `ghost_storm_cubit_test.dart`, `ghost_state_row_test.dart`).
- `test/l10n/arb_parity_test.dart` — passes (part of the 179).
- `test/design_system/no_fork_guard_test.dart` — passes (part of the 179).
- `test/widget_test.dart` ("App boots to the home screen ready signal") —
  passes; `Key('home_screen_ready_signal')` still resolves via the real
  `CupidApp` boot path.

## 3. `flutter analyze` — PASS (scoped); pre-existing noise (full)

- Full `flutter analyze` on `mobile/` exits non-zero, but every reported
  `error`/`uri_does_not_exist` is inside the untracked, gitignored
  `build/ios/SourcePackages/checkouts/flutterfire/...` CocoaPods checkout
  tree (10999 issues, none under `lib/`/`test/`), same pre-existing artifact
  noted in P1/P2/P3 evidence and unrelated to any file this story touches.
- Scoped re-run — `flutter analyze lib/features/anti_ghosting
  lib/features/home lib/design_system/icons/cupid_icons.dart
  lib/core/di/service_locator.dart test/features/anti_ghosting test/l10n
  test/design_system test/widget_test.dart` — **0 errors, 0 warnings**, 7
  `info`-level `prefer_initializing_formals` hints, all previously accepted
  in P1/P3 evidence (same tolerated codebase-wide style pattern, none new to
  this phase).

## 4. `flutter build apk --debug` — PASS

- `Running Gradle task 'assembleDebug'...` → `✓ Built
  build/app/outputs/flutter-apk/app-debug.apk`. Exit 0.

## 5. Risk Surface Gates (`master-plan.md` §3A / `architecture/solution.md` §4)

| Risk Surface | Gate | Result |
|---|---|---|
| Frozen wire contract | P0 repository unit test | PASS (part of 62/62 anti_ghosting) |
| Pairing gate (AC3) | P1 cubit + screen test, zero mutating calls | PASS |
| Approval-role derivation | P1 cubit test (mine/partner/unknown) | PASS |
| Design-system no-fork guard | `no_fork_guard_test.dart` | PASS |
| Runtime readiness key | `widget_test.dart` | PASS |
| l10n parity | `arb_parity_test.dart` | PASS |
| Storm polling lifecycle | P3 cubit test (cancel on close/background) | PASS |
| AC2 end-to-end mount | STORY-007 chat mount | Non-blocking, deferred per ADR-3 (see §6) |
| Cross-story merge surfaces (`home_screen.dart` et al.) | additive-only diff | PASS (see §7) — but see §2 for the regression this additive change exposed in an unrelated test harness |

## 6. AC Coverage

- **AC1** (view/set config): demonstrated by P1's `anti_ghost_cubit_test.dart`
  (13/13) and `anti_ghost_screen_test.dart` (5/5) — State A propose flow,
  1-120 timeout, single-select penalty.
- **AC3** (unpaired guard): demonstrated by P1's guard-state tests (zero
  mutating repository calls) and P2's `anti_ghost_entry_card_test.dart`
  (unpaired user sees no card).
- **AC2** (chat surfacing): `GhostStateRow`'s widget behaviour (neutral seen
  line, CTA branching by penalty, timer lifecycle) is demonstrated in-branch
  by P3's `ghost_state_row_test.dart` and `ghost_storm_cubit_test.dart`
  (62/62 total in `test/features/anti_ghosting/`). The end-to-end chat mount
  itself is explicitly **out of this story's BaseHead** (`mobile/lib/features/chat/`
  does not exist here) and is deferred to STORY-007 / requirement
  integration per ADR-3 (`architecture/solution.md` §6). This is a recorded,
  non-blocking cross-story deferral, not an AC2 failure.

## 7. Additive-Diff / Boundary Confirmations

- `git diff a07aa98 3018e97 --stat -- mobile/` shows 19 files changed, all
  inside the declared write scopes (P0-P3); no file under
  `mobile/lib/features/chat/` and no file under `mobile/openapi/` appears in
  the story diff.
- `pubspec.yaml` is unchanged (absent from the diff stat).
- `mobile/lib/features/home/presentation/home_screen.dart` diff: +20/-5.
  The pre-existing `Center`/`Text` carrying
  `Key('home_screen_ready_signal')` is preserved verbatim (now nested one
  level deeper inside `Expanded` so the new `AntiGhostEntryCard` can sit
  above it in the same `Column`); no widget was removed or renamed, and
  `widget_test.dart` (via the real `CupidApp` boot path) confirms the key
  still resolves. See §2 for the one place this additive change interacts
  badly with a pre-existing gap in an unrelated test harness.

## 8. Overall Verdict

- **DONE** — one deterministic regression was found in
  `test/features/auth/presentation/splash_screen_test.dart`, caused by this
  story's additive `HomeScreen` change combined with a pre-existing gap in
  that test's own harness (missing `AppL10n.localizationsDelegates`). This
  was not the known/accepted AC2 STORY-007 deferral and was not waved through
  as one. Scrum Master authorized a narrow, one-file test-harness fix, which
  was applied and verified.
- Full suite now passes: 181/181, "All tests passed!". Everything else
  required by this phase (full anti_ghosting suite, l10n parity, no-fork
  guard, readiness key, scoped `flutter analyze`, `flutter build apk
  --debug`) also passes.
- Story is ready to proceed to the review gate.
