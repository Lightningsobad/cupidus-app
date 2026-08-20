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

## Story Runtime Startup Smoke

Closes the reviewer's blocking finding: every prior visual-fidelity capture
was built with `-t lib/main_preview.dart` (the preview harness), so the
shipped entrypoint `lib/main.dart` (Firebase init, DI, routing) had never
actually been launched. This pass builds and launches that shipped
entrypoint directly, not the preview harness.

- Scoped app: `mobile-app`
- Runtime Id: `mobile-app`
- Registry: `data/devops/system/runtime-command-registry.json` (`runtimes.mobile-app`)
- Device: `emulator-5560` (already running and visible to `adb devices`; no boot needed)
- Build: `cd mobile && flutter build apk --debug` → `build/app/outputs/flutter-apk/app-debug.apk` (shipped entrypoint `lib/main.dart`, default build target — not `-t lib/main_preview.dart`)
- Install: `adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk` (installed the exact debug APK directly; `flutter install` without `--debug` silently rebuilds/installs a release variant, so plain `flutter install` was avoided)
- Command:
  ```
  adb -s "$MOBILE_DEVICE_SERIAL" shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity \
    && for _ in $(seq 1 30); do adb -s "$MOBILE_DEVICE_SERIAL" shell dumpsys activity activities \
    | grep -q "ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity" && exit 0; sleep 2; done; exit 1
  ```
- Ready Check: `am start -W` reported `Status: ok`, `LaunchState: COLD`, `TotalTime: 10712`ms; `dumpsys activity activities` confirmed `ResumedActivity` matched `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` on the first poll (exit 0, well inside the 90s `timeoutSecs`).
- Result: **PASS**
- Shutdown: `adb -s "$MOBILE_DEVICE_SERIAL" shell am force-stop com.snapsofts.cupid` (exit 0); re-checked `dumpsys activity activities` afterward and confirmed the app was no longer the `ResumedActivity`.
- Shutdown: **PASS**

This is a live-process launch check only (registry `readiness.type: command`,
devops/SKILL.md 14b1), not a network/API round-trip — the app reaching its
first resumed activity does not require a successful call to `backend-api`,
so the known-stale `CUPID_API_BASE_URL` compile-time default (see
`runtime-command-registry.json` `runtimes.mobile-app.dependsOnRationale`) does
not block this gate. That default's staleness against the shared-devstack api
port (21020) remains an out-of-scope mobile-dev follow-up.

## Entry Point Reachability

After this story's removal of `CupidHeader.actions` from the Dream Jar list
screen, the create-jar entry point is the `CupidPrimaryButton` CTA in the body
of `dream_jar_list_screen.dart`, present in both populated states:

- Empty state: `_EmptyJarsView`'s `CupidPrimaryButton` (label "New Dream Jar").
- Ready state: `_JarListBody`'s `CupidPrimaryButton` (same CTA, alongside the
  jar list).

Both are wired to the same `_openCreateSheet` handler that the removed
header action used to call. This preserves create-jar capability end-to-end
even though the header no longer carries an action slot. Already verified in
code, the AC1 widget tests, and the on-device visual-fidelity captures by the
reviewer (see "AC coverage" above); this section is documentation only, per
the reviewer's DEF-1 — no re-verification or re-capture was performed here.
