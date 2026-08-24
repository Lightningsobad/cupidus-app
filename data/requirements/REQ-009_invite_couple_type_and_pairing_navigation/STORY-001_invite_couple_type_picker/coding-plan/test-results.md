# Test Results — STORY-001 Phase P1 (Couple-Type Picker)

- Role: Mobile Developer
- Date: 2026-08-24
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-009_invite_couple_type_and_pairing_navigation-STORY-001_invite_couple_type_picker`
- Branch: `codex/REQ-009_invite_couple_type_and_pairing_navigation-STORY-001_invite_couple_type_picker`
- BaseHead: `f30a17ac6488a999751605e70944bd923015bd4e`
- Flutter SDK: not on PATH; every command below was run with
  `PATH="$HOME/flutter/bin:$PATH"` from the worktree's `mobile/` directory.

## 1. Icon Codepoint Resolution (ordered prerequisite, task 1)

Codepoints were read from the bundled variable font's `cmap`, never from
memory. Command (run from the worktree `mobile/` directory):

```bash
python3 -c "
from fontTools.ttLib import TTFont
font = TTFont('assets/fonts/MaterialSymbolsRounded-Variable.ttf')
reverse = {}
for codepoint, name in font.getBestCmap().items():
    reverse[name] = codepoint
for name in ['location_city', 'auto_awesome', 'all_inclusive', 'flight_takeoff']:
    print(name, hex(reverse[name]))
"
```

Output:

```text
location_city 0xe7f1
auto_awesome 0xe65f
all_inclusive 0xeb3d
flight_takeoff 0xe905
```

`flight_takeoff` is the control: it resolves to `0xe905`, which matches the
already-confirmed `CupidIcons.flightTakeoff`, so the lookup method itself is
verified against a known-good value. The three new codepoints are declared as
file-local `IconData` constants in
`mobile/lib/features/pairing/presentation/couple_type.dart`; `flight_takeoff`
reuses `CupidIcons.flightTakeoff` rather than redeclaring it, and
`mobile/lib/design_system/` was not touched.

## 2. Static Analysis

Scoped run over exactly the files this phase changed (the project convention
established in `REQ-008_android_build_variants_local_prod/STORY-001`: a bare
`flutter analyze` surfaces thousands of pre-existing issues from the generated
`openapi/cupid_api` client and vendored sources, so the scoped run is the gate):

```bash
flutter analyze \
  lib/features/pairing/presentation/couple_type.dart \
  lib/features/pairing/presentation/invite_cubit.dart \
  lib/features/pairing/presentation/screens/invite_screen.dart \
  lib/main_preview.dart \
  test/features/pairing/presentation/invite_cubit_test.dart \
  test/features/pairing/presentation/invite_screen_test.dart
```

Result:

```text
Analyzing 6 items...
No issues found! (ran in 1.9s)
```

PASS — 0 errors, 0 warnings, 0 infos.

### Lint note (why two files gained an `ignore_for_file`)

The first scoped run reported 7 `prefer_initializing_formals` infos — 5 on
pre-existing lines and 2 on the new `fetchCoupleType` / `saveCoupleType`
constructor seams:

```text
   info • ... ('this._generateInvitation') ... • lib/features/pairing/presentation/invite_cubit.dart:59:8 • prefer_initializing_formals
   info • ... ('this._fetchCoupleType') ...    • lib/features/pairing/presentation/invite_cubit.dart:60:8 • prefer_initializing_formals
   info • ... ('this._saveCoupleType') ...     • lib/features/pairing/presentation/invite_cubit.dart:61:8 • prefer_initializing_formals
   info • ... ('this._now') ...                • lib/features/pairing/presentation/invite_cubit.dart:62:8 • prefer_initializing_formals
   info • ... ('this._createInviteCubit') ...  • lib/features/pairing/presentation/screens/invite_screen.dart:98:8 • prefer_initializing_formals
   info • ... ('this._createWaitingCubit') ... • lib/features/pairing/presentation/screens/invite_screen.dart:99:8 • prefer_initializing_formals
   info • ... ('this._createWaitingCubit') ... • lib/features/pairing/presentation/screens/invite_screen.dart:137:8 • prefer_initializing_formals

7 issues found. (ran in 1.8s)
```

Every one is the same inapplicable suggestion: these are private fields fed by
public named parameters, and the lint's own fix (`this._field`) is not
expressible in Dart because a named parameter cannot start with `_`. The
codebase already suppresses exactly this pattern
(`lib/core/navigation/app_shell.dart:4` uses `// ignore_for_file:`, and
`features/expenses/`, `features/home/`, `features/timeline/` use per-line
`// ignore:`), so the same one-line `ignore_for_file` was added to both files
with the reason recorded in the comment. No behavior change.

`dart format` was deliberately NOT run: the files are already non-conformant at
`BaseHead` (verified by formatting the `git show f30a17ac…:<path>` copies in a
scratch directory — `invite_cubit.dart`, `invite_cubit_test.dart`, and
`main_preview.dart` all report "Changed"), so the repository does not enforce
`dart format` and running it would produce a large unrelated diff.

Out-of-scope baseline, unchanged by this phase: a wider
`flutter analyze lib/features/pairing lib/main_preview.dart` reports the same
lint on files this story never touched (`joincode_cubit.dart:40`,
`pair_gate_cubit.dart:45`, `waiting_screen.dart:28`,
`pairing_choice_screen.dart:28-29`). They were left alone.

## 3. Targeted Tests

```bash
flutter test test/features/pairing/ --reporter compact
```

Result:

```text
00:04 +126: All tests passed!
```

PASS — 126 passed, 0 failed. This includes every pre-existing pairing test
(code card, countdown, share/copy, error/retry, joincode, waiting, paired,
pair-gate, repository, poller), all still passing unmodified in intent.

Per-file runs used while iterating:

```text
flutter test test/features/pairing/presentation/invite_cubit_test.dart
  -> 00:00 +17: All tests passed!
flutter test test/features/pairing/presentation/invite_screen_test.dart
  -> 00:01 +16: All tests passed!
```

### New unit cases (`invite_cubit_test.dart`, 13 added)

| Case | Covers |
| --- | --- |
| `exposes the 4 backend literals in catalog order` | wire literals + card order |
| `parses every wire value and degrades unknown ones to null` | all 4 mappings, `LONG_TERM`, `''`, `null` |
| `every wire value exists in the generated client enum` | guards `_wireCoupleType`'s `firstWhere` against a `StateError` at tap time |
| `pre-fills the selection from the profile on the first ready state` | AC5, asserted on the *first* emitted `InviteReady`, not the settled state |
| `a profile read resolving after the code still pre-fills` | late profile read re-emits once |
| `a failing profile read still reaches InviteReady unselected` | profile failure never becomes `InviteFailed` |
| `an unknown persisted value leaves every card unselected` | legacy/unknown inbound value |
| `the selection replaces the previous one instead of adding` | AC3 at cubit level |
| `the selection survives a countdown tick` | the solution.md "most likely defect" row — injected `timerFactory` tick keeps the selection and still advances `remaining` to 23h40m |
| `submitCoupleType persists the selection once and returns true` | AC4, captured argument asserted as `LIVING_TOGETHER` |
| `a second submit while the write is in flight is ignored` | `isSaving` latch, save seam called exactly once |
| `submitCoupleType keeps the selection when the write fails` | failure is retryable in place |
| `submitCoupleType is a no-op with nothing selected` | AC2 at cubit level |

### New widget cases (`invite_screen_test.dart`, 7 added)

All mount the real `InviteScreen` (not the section widget in isolation) in the
`vi` locale named by the phase test scope, on a 600x1400 surface so the CTA is
inside the viewport and `tester.tap` cannot silently miss.

| Case | Covers |
| --- | --- |
| `AC1: the picker sits between the code card and the CTA, in catalog order` | 4 cards present, code card above them, catalog order by dx/dy, CTA last |
| `AC2: the CTA is disabled until a card is chosen` | `CupidPrimaryButton.onPressed == null` at 0 selections, non-null after one tap |
| `AC3: choosing a second card swaps the selection` | exactly one card reports `selected: true` before and after the swap |
| `AC4: Continue persists the chosen card as its wire value` | save seam called once with `SAME_CITY`; screen does not navigate (STORY-002 owns that) |
| `AC5: a persisted couple type is selected on the first paint` | pre-selection visible on the first pump, CTA already enabled |
| `a failed write keeps the selection and offers a retry` | vi snackbar copy, selection kept, CTA re-enabled |
| `AC7: joincode carries no couple-type card` | `JoincodeScreen` renders no heading, no card label, and no card semantics |

Required assertion evidence from the phase test scope:

- Save seam captured its argument as the expected wire literal —
  `expect(saved.single.wireValue, 'LIVING_TOGETHER')` (unit) and
  `expect(saved, <CoupleType>[CoupleType.sameCity])` with
  `expect(saved.single.wireValue, 'SAME_CITY')` (widget).
- Exactly one card reports `selected: true` after a selection change —
  `expect(_coupleCardSemantics(tester).where((p) => p.selected == true), hasLength(1))`,
  asserted after both the first and the second tap.

Harness note: `_harness` now attaches `AppL10n.localizationsDelegates` /
`AppL10n.supportedLocales` and takes an optional `locale`. The pre-REQ-009
cases pass no locale and still resolve to the binding's `en-US`, so their
English assertions are unchanged (confirmed by the 9 pre-existing cases in that
file passing).

## 4. Build

```bash
flutter build apk --debug
```

Result:

```text
Running Gradle task 'assembleLocalDebug'...                        40.7s
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
```

PASS. The `local` flavor is REQ-008's default debug variant, so the plain
`--debug` invocation resolves to `assembleLocalDebug`. Gradle emitted only
pre-existing warnings (JDK restricted-method notice, the `sign_in_with_apple`
KGP deprecation notice, and Java deprecation notes) — none from this change.

## 5. Coverage Of The Phase Acceptance Criteria

| AC | Gate | Result |
| --- | --- | --- |
| AC1 four cards in catalog order below the code card | widget `AC1:` case | PASS |
| AC2 Continue disabled with nothing selected | widget `AC2:` + unit no-op case | PASS |
| AC3 single-select, second tap swaps | widget `AC3:` + unit replace case | PASS |
| AC4 Continue persists the mapped wire value | widget `AC4:` + unit submit case | PASS |
| AC5 persisted value pre-selected on first paint | widget `AC5:` + unit first-ready case | PASS |
| AC7 joincode unaffected | widget `AC7:` case | PASS |
| Selection survives a countdown tick | unit tick case | PASS |
| `flutter analyze` clean, `flutter build apk --debug` succeeds | sections 2 and 4 | PASS |

## 6. Files Changed

- `mobile/lib/features/pairing/presentation/couple_type.dart` (new)
- `mobile/lib/features/pairing/presentation/invite_cubit.dart`
- `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`
- `mobile/lib/main_preview.dart`
- `mobile/test/features/pairing/presentation/invite_cubit_test.dart`
- `mobile/test/features/pairing/presentation/invite_screen_test.dart`
