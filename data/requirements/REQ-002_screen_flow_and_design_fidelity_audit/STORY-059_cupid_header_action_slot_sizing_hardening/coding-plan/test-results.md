# Test Results: STORY-059 P1 — CupidHeader Oversized-Action Contract

Lane: mobile-dev | Phase: P1 | Worktree: `/Users/alantravala/workspace/snapsofts/cupid-apps`

Result: **PASS** — static analysis, tests, and visual fidelity all green.

## Static analysis

```
cd mobile && flutter analyze \
  lib/main_preview.dart \
  lib/design_system/adaptive/cupid_header.dart \
  lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart \
  test/design_system/adaptive_widgets_test.dart \
  test/features/dream_jar/presentation/dream_jar_list_screen_test.dart
```

```
Analyzing 5 items...
No issues found! (ran in 1.4s)
```

Scoped to the five touched files deliberately. A repo-wide `flutter analyze`
exits 1 on this checkout, but every error comes from vendored FlutterFire
sources under `build/ios/SourcePackages/checkouts/flutterfire/packages/
cloud_firestore/...`. That is pre-existing, unrelated to this phase, and outside
its write scope — it was verified as pre-existing rather than assumed.

## Tests

```
cd mobile && flutter test \
  test/design_system/adaptive_widgets_test.dart \
  test/features/dream_jar/ \
  test/features/account/presentation/screens/profile_edit_screen_test.dart
```

```
00:04 +115: All tests passed!
```

Result: PASS. 115 tests, 0 failures. Re-run after the `main_preview.dart`
extension landed, so this is the final tree, not a pre-extension run.

## AC coverage

| AC | Evidence | State |
|---|---|---|
| AC1 — Dream Jar list header carries no add action in either populated state | `dream_jar_list_screen_test.dart`: "empty state carries no header add action, only the body CTA (AC1)" and "ready state carries no header add action, only the body CTA (AC1)". Each asserts `find.byType(CupidAddAction)` is `findsNothing` **and** `find.text('New Dream Jar')` is `findsOneWidget`, so the capability is proven retained, not just the icon proven gone. | PASS — widget test **and** on-device capture of both states (`implemented-jarlist-empty-emulator-5560.png`, `implemented-jarlist-ready-emulator-5560.png`) |
| AC2 — a declared oversized action renders unclamped at its natural 60x60 | `adaptive_widgets_test.dart`: "Material FAB renders unclamped at 60x60 inside CupidHeader.actions when the header declares an oversized action" — `expect(size, const Size(60, 60))` plus `expect(size.height, greaterThan(kToolbarHeight))`. This replaces the former test that pinned the clamped `Size(60, 56)`; that pin encoded the defect and had to invert. | PASS |
| AC3 — `CupidAddAction` itself is unchanged | `cupid_add_action.dart` was not edited (it is outside this phase's write scope). Its existing tests at `adaptive_widgets_test.dart:554-612` pass unmodified. | PASS |
| AC4 — every existing header consumer keeps the 56pt band | `hasOversizedAction` defaults to `false`; new test "an ordinary action-bearing CupidHeader keeps the default 56pt band" asserts `preferredSize.height == kToolbarHeight`, the rendered `AppBar.toolbarHeight == kToolbarHeight`, and the laid-out `AppBar` height `== kToolbarHeight`. Corroborated by `profile_edit_screen_test.dart` — a real action-bearing consumer — passing **unmodified**. | PASS |

The AC4 signal is worth stating precisely: `profile_edit_screen_test.dart` was
not touched, so its passing is independent evidence that the default path is
byte-for-byte behaviour-compatible, not a test rewritten to match new output.

## Why the band is exactly 60 and not 64

`AppBar` lays `actions` into a `Row` with `CrossAxisAlignment.stretch`, which
gives each action a **tight** cross-axis constraint equal to the toolbar band.
The band value is therefore not a ceiling the FAB fits inside — it is the exact
height the FAB is forced to. That is the whole mechanism behind the original
60x56 clamp. A band of 64 would render the FAB 60x64, replacing one deviation
with another; only 60 makes the 60pt box square. The band constant is local to
`cupid_header.dart`; `kToolbarHeight` and the global theme toolbar height were
not touched.

## Changed files (4 in the original write scope + 1 authorized extension)

| File | Change |
|---|---|
| `mobile/lib/design_system/adaptive/cupid_header.dart` | Added `_oversizedActionToolbarHeight = 60`, the `hasOversizedAction` parameter/field, the `_bandHeight` getter, a non-`const` `preferredSize`, and `toolbarHeight` threading into `_MaterialHeader` → `AppBar`. `_IosHeader` untouched — iOS builds its own `Padding`/`Row` band and never consulted `kToolbarHeight`. |
| `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart` | Replaced the 12-line state-switched `actions` expression with `actions: const <Widget>[]`. `hasOversizedAction` is deliberately **not** set here: this screen no longer has an oversized action, so declaring one would raise the band for nothing. |
| `mobile/test/design_system/adaptive_widgets_test.dart` | Replaced the clamped-size test with the AC2 unclamped test and added the AC4 default-band test. |
| `mobile/test/features/dream_jar/presentation/dream_jar_list_screen_test.dart` | Added the two AC1 tests. |
| `mobile/lib/main_preview.dart` | **Authorized write-scope extension, not a scope violation** — granted explicitly by Scrum Master on 2026-08-19 to unblock the visual-fidelity gate, precedent STORY-020 `architecture/solution.md` §7 "Authorized Write-Scope Extension — Preview Harness". Adds `PREVIEW_JARLIST_FIXTURE=empty\|ready` and `_PreviewDreamJarListRepository` (overrides `fetchJars` only), mirroring the `PREVIEW_EXPENSE_FIXTURE` / `PREVIEW_JAR_FIXTURE` / `_PreviewDreamJarRepository` pattern already in that file. Preview-harness only: omitting the define leaves the live-repository path unchanged, and nothing in `lib/` outside the preview entrypoint reads it. |

Two notes on the removal, both verified rather than assumed: `flutter analyze`
reports no unused import after it (the `design_system` barrel is still needed for
`CupidHeader`/`CupidPrimaryButton`), and the ready-state AC1 test uses **two**
jars because a single non-archived jar takes the detail-screen bypass at
`dream_jar_list_screen.dart:59` and never mounts the list header at all.

## Visual fidelity

`VISUAL_FIDELITY: PASS` — see `../visual-fidelity/visual-fidelity-report.md`.

The earlier `MOBILE_VISUAL_AUDIT_SCREEN_UNREACHABLE` blocker is **resolved**.
Both AC1-bearing states now render from real builds on `emulator-5560` and both
show a header with no add action over a body that retains the create-jar CTA,
matching the design reference's own header. The ready capture reproduces the
design's three jars at the design's own percentages (78% / 30% / 3%).

Two things the PASS token does not cover, both stated in the report rather than
left to inference:

- The `hasOversizedAction: true` path has no consumer left in the app, so the
  60pt band is not exercisable on device. AC2 is widget-test evidence only.
- The `jarlist` screen carries 11 unrelated, pre-existing design deviations
  (missing summary pill, missing jar illustrations, missing deadline row,
  missing completed-jars row, CTA and title copy, shell tab-bar shape). This
  story's diff cannot have caused any of them, and no open story owns them. The
  report recommends a new RWB item rather than absorbing them into this PASS.
