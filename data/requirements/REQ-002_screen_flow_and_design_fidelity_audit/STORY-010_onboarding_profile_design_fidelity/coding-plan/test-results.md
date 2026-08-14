# STORY-010 test results

Flutter is not on `PATH` on this machine; all commands below were run with
`$HOME/flutter/bin` prepended to `PATH`, from `<worktree>/mobile`.

Worktree:
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-010`

Flutter 3.44.1 stable • Dart 3.12.1

This file was created in round-4 rework to close review finding F3. Rounds 1-3
recorded their gate evidence in `../visual-fidelity/visual-fidelity-report.md`
§5; that section remains, and this file is now the canonical location.

## Round-4 rework — commands

Date: 2026-08-14
Owner: Mobile Developer

Round 4 reverted the superseded `ProfileEditScreen` commit range (review
finding F2) and added bookkeeping artifacts. It changed no source file that
this story authors.

| # | Command | Result |
|---|---------|--------|
| 1 | `git checkout bf80848 -- mobile/lib/features/account/presentation/screens/profile_edit_screen.dart mobile/test/features/account/presentation/screens/profile_edit_screen_test.dart` | Both files restored to the merge-base with `codex/REQ-002_…-integration`. `git diff bf80848 -- <both paths>` is now empty. |
| 2 | `flutter analyze lib/features/onboarding test/features/onboarding lib/main_preview.dart lib/features/account/presentation/screens/profile_edit_screen.dart test/features/account/presentation/screens/profile_edit_screen_test.dart` | `No issues found! (ran in 2.1s)` — all 5 branch-touched items, including both reverted files |
| 3 | `flutter analyze lib test` | `77 issues found. (ran in 2.9s)` — all `info` severity, all pre-existing (`prefer_initializing_formals`, `use_null_aware_elements`, one `deprecated_member_use`). None in any file this branch touches, confirmed by command 2. |
| 4 | `flutter test test/features/onboarding test/design_system/no_fork_guard_test.dart test/features/account/presentation/screens/profile_edit_screen_test.dart` | `+19: All tests passed!` |
| 5 | `flutter test test/features/account/presentation/screens/profile_edit_screen_test.dart` | `+3: All tests passed!` |
| 6 | `flutter test` (full suite) | `+935: All tests passed!`, exit 0 |

Bare `flutter analyze` (no path argument) is **not** a usable gate in this
repository: it walks `build/ios/SourcePackages/checkouts/flutterfire/**`, a
vendored checkout of `cloud_firestore` examples that are not part of this app
and do not resolve. Use `flutter analyze lib test`, as in command 3. This
matches STORY-001's finding in
`../../STORY-001_app_launch_entry_routing/coding-plan/test-results.md`.

### F2 revert — reconciliation

The counts above are the arithmetic proof that the revert removed the six
superseded tests and nothing else:

| Scope | Before revert (round 3) | After revert (round 4) | Delta |
|---|---|---|---|
| `profile_edit_screen_test.dart` | 9 | 3 | −6 — the `STORY-010 design fidelity against the 'profile' canvas` group |
| Targeted story scope | 25 | 19 | −6 |
| Full suite | 941 | 935 | −6 |

The remaining 3 tests in `profile_edit_screen_test.dart` (`renders fields
populated from the initial profile`, `Save is disabled until the draft becomes
dirty`, `shows an inline error and blocks submit when the name is cleared`) are
its pre-STORY-010 baseline, last authored by REQ-001/STORY-016 (`fb20d90`).
No STORY-010 test group remains in that file, and STORY-029 inherits the screen
and its test unencumbered.

`main_preview.dart` needed no follow-up edit: commit `a8d0fed` had already
repointed canvas `profile` to `OnboardingProfileSetupScreen` and dropped the
`profile_edit_screen.dart` import, so the revert left no dangling reference.
Command 2 is the proof — it analyzes `main_preview.dart` and both reverted
files together and reports clean.

### New tests owned by this story

15 tests across the three files added by `a8d0fed`, all under
`test/features/onboarding/`:

| File | Tests |
|---|---|
| `presentation/screens/onboarding_profile_setup_screen_test.dart` | 8 |
| `presentation/widgets/zodiac_glyph_test.dart` | 5 |
| `presentation/onboarding_profile_setup_route_test.dart` | 2 |

## Entry Point Reachability

Rule 12e1. Round-3 review finding F3.

Reachable: NO — by explicit product decision, not by omission.

**The code-level entry point for this screen belongs to STORY-002, not to this
story.** AC4 states this story "does not add or modify any live in-app
navigation transition itself", and the round-3 reviewer verified that no
navigation file appears in the diff.

Declared-but-unwired entry:
`mobile/lib/features/onboarding/presentation/onboarding_profile_setup_route.dart`
— `OnboardingProfileSetupRoute`, route name `/onboarding/profile`. It exposes
`route(...)` and `push(context, profile:, onContinue:)`, mirroring
`features/pet/presentation/pet_route.dart`. Nothing in the shipped app calls
`push` yet; STORY-002 owns wiring `permissions -> profile -> invite/join-code`,
and this class exists so that wiring is a one-line call.

What this story does prove instead is AC4's own bar — that the screen renders
correctly **on its own route, without live onboarding navigation**:

| Evidence | Result |
|---|---|
| `onboarding_profile_setup_route_test.dart` pushes the route directly and asserts the screen is built with the caller-supplied `CupidProfile` | Passing (2 tests) |
| The same test pins `RouteSettings.name` as `/onboarding/profile`, so the declared entry cannot silently drift before STORY-002 consumes it | Passing |
| `onboarding_profile_setup_screen_test.dart` builds the screen in a bare `MaterialApp` and asserts it pushes no route of its own | Passing (8 tests) |
| Device render via the preview harness on its own canvas id, with no navigation involved | See Story Runtime Startup Smoke below |
| No nav-graph, shell, or router file in `git diff bf80848..HEAD --name-only` | Confirmed; independently verified by the round-3 reviewer |

Nothing is gated behind a build flag. `PREVIEW_PROFILE=fixture` affects only
`main_preview.dart`'s capture harness and is inert in the shipped app.

**Consequence for the requirement, not for this story:** until STORY-002 lands
the `permissions -> profile` wiring, this screen ships unreachable. That is
review Action Item #6 and is tracked at requirement level.

## Story Runtime Startup Smoke

Rule 12g. Round-3 review finding F3.

Runtime-Smoke: PERFORMED — real device render of the screen on
`emulator-5554`.

Impacted runtime service/app: `mobile-app`
(`data/devops/system/runtime-command-registry.json`). No backend service is in
this story's change surface: the screen performs no I/O and takes its
`CupidProfile` from its caller.

The smoke was performed in round 3 and its artifact is the device capture. It
was recorded in `../visual-fidelity/visual-fidelity-report.md` §5 rather than
here, which is exactly what F3 flagged; it is restated here so the DONE gate
has it in the artifact it reads. Round 4 did not re-run it, because round 4
changed no file that the running app loads — the revert touches only
`ProfileEditScreen` and its test, neither of which this screen imports (command
2 above analyzes them together and is clean).

### Run

```
flutter run -d emulator-5554 -t lib/main_preview.dart \
  --dart-define=PREVIEW=profile \
  --dart-define=PREVIEW_PROFILE=fixture \
  --dart-define=PREVIEW_BRIGHTNESS=dark
adb -s emulator-5554 exec-out screencap -p    # 1080x2400, downscaled to 405x900
```

| Item | Result |
|---|---|
| App start | Booted, no crash, no Flutter red error screen |
| Screen rendered | `OnboardingProfileSetupScreen`, dark theme + `vi` locale |
| Capture | `../visual-fidelity/implemented-profile-emulator-5554.png` (405x900, 83853 B) |
| Genuine device render | Confirmed — Android status bar (10:28, wifi/signal/battery), gesture pill, real font rasterization; not a widget-test snapshot |
| Elements observed | Avatar + camera badge, crop caption, all three cards (TÊN GỌI / NGÀY SINH + `Song Ngư` chip / NGÔN NGỮ + chevron), gradient CTA — see the visual-fidelity report §3 |

The round-3 reviewer independently opened this frame and confirmed it is a real
device render of this story's screen.

### Registry conformance note

`runtime-command-registry.json` records `mobile-app.readiness.type:
widget-test` against `Key('home_screen_ready_signal')`. That signal is not
usable as this story's startup gate: the key lives on the home screen, which is
reachable only with a valid authenticated session, and this screen is not on
the authenticated path at all. The preview-harness entry point is the only
runtime path that reaches this screen today, which is a restatement of the
Entry Point Reachability finding above rather than a separate gap. The
registry's pre-existing non-conformance is outside this story's write scope and
is already carried as a DevOps finding by
`../../STORY-001_app_launch_entry_routing/coding-plan/test-results.md` D4.
