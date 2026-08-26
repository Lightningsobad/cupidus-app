# STORY-002 Test Results — P0 + P1 (Mobile)

- Lane: `mobile-dev`
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-012_pairing_flow_qr_code_and_couple_types_screen-STORY-002_create_code_couple_types_screen_qr_display`
- BaseHead: `94600f32cbf4c38d67184889331f03756aa22090`
- All commands run from `mobile/` with `PATH="$HOME/flutter/bin:$PATH"`.
- Date: 2026-08-25

## 1. Dependency Resolution (P0 task 1)

`flutter pub add qr_flutter` → exit 0.

Resolved: `qr_flutter 4.1.0`, transitive `qr 3.0.2`. `QR_DEPENDENCY_UNRESOLVABLE`
did not trigger.

API surface confirmed by reading
`~/.pub-cache/hosted/pub.dev/qr_flutter-4.1.0/lib/src/qr_image_view.dart` before
writing against it, rather than assumed:

- `QrImageView({required String data, double? size, EdgeInsets padding,
  Color backgroundColor, int errorCorrectionLevel, QrEyeStyle eyeStyle,
  QrDataModuleStyle dataModuleStyle, ...})`
- `QrErrorCorrectLevel.H`
- `QrEyeStyle(eyeShape: QrEyeShape.square, color: ...)`
- `QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: ...)`
- `QrPainter` / `QrPainter.withQr`, `QrPainter.toImageData(double size)`

Note for reviewers: `QrImageView._data` is private and `QrCode` has no
`operator ==`, so neither the widget field nor `shouldRepaint` can witness the
real payload. `PAYLOAD_IDENTITY_UNVERIFIABLE` was avoided by comparing the
mounted `QrPainter`'s rasterized bytes against an independently constructed
reference painter (see AC2 below).

## 2. Required Checks

| Command | Exit | Result |
| --- | --- | --- |
| `flutter test test/features/pairing/presentation/widgets/invite_qr_frame_test.dart` | 0 | 6/6 passed |
| `flutter test test/features/pairing/presentation/invite_screen_test.dart` | 0 | 21/21 passed |
| `flutter test test/core/navigation/post_code_navigation_guard_test.dart` | 0 | 4/4 passed |
| `flutter test test/design_system/no_fork_guard_test.dart` | 1 | RED — pre-existing, see §5 |
| `flutter analyze lib/features/pairing/presentation/widgets/invite_qr_frame.dart lib/design_system/tokens/qr_palette.dart lib/design_system/design_system.dart` | 0 | `No issues found!` |
| `flutter analyze lib/features/pairing/presentation/screens/invite_screen.dart` | 0 | `No issues found!` |
| `flutter analyze lib test` | 1 | 75 findings, all `info`-level lints, all in pre-existing files; zero in this story's files. See §5. |
| `flutter test` (full mobile suite) | 1 | `+1494 ~3 -2` — both failures pre-existing, see §5 |

## 3. P0 Assertion Names (`invite_qr_frame_test.dart`)

- `AC2: the art encodes the bare code, never an upper-cased or URL-wrapped
  variant` — rasterizes the mounted painter via `QrPainter.toImageData(154)`
  inside `tester.runAsync` and byte-compares it against reference painters for
  the bare code, `code.toUpperCase()`, and
  `https://cupid.app/pair?code=<code>`. Fixture code is lower-case on purpose
  so an alphanumeric-mode upper-casing encoder cannot pass.
- `AC2: the configured error correction level is H` — asserted on both the
  `QrImageView` argument and the resolved `QrPainter.errorCorrectionLevel`, so
  `EC_LEVEL_UNASSERTABLE` does not apply.
- `the badge box stays inside the 50px occlusion budget`
- `the accessible label names the code it carries` (vi and en)
- `the animated frame disposes its clock with the widget`
- `the frame source carries no raw color literal`

## 4. P1 Assertion Names (`invite_screen_test.dart`)

Added:

- `AC1/AC2: the card carries one QR frame, above the text code, encoding that
  same code` — reads `InviteQrFrame.code` and the card's code `Text.data` out
  of the same mounted tree (not two literals), then asserts the frame's centre
  is above the code's.
- `AC1: the loading and error states render no QR`
- `AC4: Continue advances to waiting on a successful save` — asserts
  `WaitingScreen` is pushed and `VowScreen` is not (AC4/INV-1).

Extended:

- `a failed write keeps the selection and offers a retry` — now also asserts
  `find.byType(WaitingScreen), findsNothing`.

Still passing unmodified: `renders the code and a live expiresAt countdown`,
`the code card matches the design source treatment`, `AC1: the picker sits
between the code card and the CTA, in catalog order`, `D1: the two grid columns
are equal width, split by one gutter`, `AC2: the CTA is disabled until a card is
chosen`, `AC3: choosing a second card swaps the selection`, `AC5: a persisted
couple type is selected on the first paint`, `AC7: joincode carries no
couple-type card`, and the copy/share advance-to-waiting cases.

### 4a. Two documented deviations from P1 §6 "must still pass unmodified"

1. `AC4: Continue persists the chosen card as its wire value` carried
   `expect(find.byType(WaitingScreen), findsNothing)` with the comment
   "STORY-002 owns where Continue goes next; this phase must not navigate."
   That assertion is the exact behaviour P1 task 2 replaces, so it could not be
   kept. Its wire-value assertions are untouched; the navigation half moved to
   the new `AC4: Continue advances to waiting on a successful save` case.
2. `pumpAndSettle` → bounded pumps wherever `InviteScreen` is mounted. The UX
   spec mandates two infinite loops (`breathe 4.5s`, `qrScan 3.4s`), so no
   frame is ever quiet once the card is on screen and `pumpAndSettle` times
   out by construction. Same treatment the repo already applies to
   `PairedScreen`'s bob (`pair_gate_cubit_test.dart`) and the chain screens
   (`chain_chrome_guard_test.dart`).

### 4b. Test-only edits outside the declared phase write scope

Three tests in other suites reach `InviteScreen` through navigation and used
`pumpAndSettle`. They went red the moment the QR mounted, and were repaired
with the same bounded-pump pattern. No production code outside the phase write
scope was touched.

- `test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
  — `the primary action opens invite`, `invite pops back to the pairing stack`
- `test/features/pairing/presentation/pair_gate_cubit_test.dart` — `unpaired
  routes into the pairing stack with no tab bar and a reachable "Pair with your
  partner" entry action`

Verified after the repair:
`flutter test test/core/navigation/chain_chrome_guard_test.dart
test/features/pairing/presentation/pair_gate_cubit_test.dart
test/features/pairing/presentation/screens/pairing_choice_screen_test.dart
test/features/expenses/pairing_gate_test.dart` → exit 0, 38/38 passed.

## 5. Pre-Existing Red Inherited From BaseHead (not caused by this story)

### 5a. `no_fork_guard_test.dart` — deferred, tracked as `BUG-20260825-002`

Disposition (Scrum Master ruling, 2026-08-25): tracked as
`BUG-20260825-002_no_fork_guard_pet_preview_card_color_literal` (Status
`PENDING`, origin commit `11190e8` / REQ-010 STORY-003), confirmed pre-existing
at this story's BaseHead `94600f32` and outside STORY-002's write scope.
Deferred to the normal bug-queue workflow — not a STORY-002 regression and not
fixed here. Detail below.


`flutter test test/design_system/no_fork_guard_test.dart` fails with exactly:

```
'lib/features/pet/presentation/widgets/pet_preview_card.dart:229: forbidden pattern "Colors."',
'lib/features/pet/presentation/widgets/pet_preview_card.dart:230: forbidden pattern "Colors."'
```

Evidence that it predates this story:

- `git diff --stat 94600f32 -- mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`
  is empty — the file is byte-identical to BaseHead.
- Its last commit is `11190e8
  feat(REQ-010_home_dashboard_deferred_scope_completion/STORY-003)`.
- The violations are `Colors.white.withAlpha(_readyGlowAlpha)` and
  `Colors.white.withAlpha(0)` in the pet preview card's ready-glow
  `RadialGradient`.
- Zero violations are reported for any file this story adds or edits.

`lib/features/pet/**` is outside this story's write scope, so the repair was
not attempted here. Routed by Scrum Master to `BUG-20260825-002` in the bug
queue; a design-system token decision is needed first, since no existing
pure-white token reproduces the pet card's pixels.

### 5b. Gallery destination tap — pre-existing, unrelated

`test/features/gallery/gallery_cubit_test.dart:276` (`exposes a labelled
gallery destination reachable by tap, opening GalleryScreen`) fails in
isolation as well as in the full suite, with `Offset(132.4, 611.0) is outside
the bounds of the root of the render tree, Size(800.0, 600.0)` — the AppShell
nav destination is off-screen on the default test surface. No pairing, QR, or
design-system file is involved, and none of the files in its path were touched
by this story.

### 5c. `flutter analyze` scope

A bare `flutter analyze` from `mobile/` also walks
`build/ios/SourcePackages/checkouts/flutterfire/**`, generated Xcode
checkout artifacts that are not project source and report hundreds of
`uri_does_not_exist` errors. `flutter analyze lib test` is the meaningful
run; it reports 75 `info`-level lints, every one of them in a pre-existing
file (`pair_gate_shell.dart`, `ghost_cubit.dart`, `gallery_api.dart`, etc.)
and none in this story's files.

## 6. Visual Inspection (P1 §6)

Card top-to-bottom order confirmed against `../ux/ux-spec.md` "Screen
Structure": QR frame → "Mã ghép đôi của bạn" label → gradient mono code →
"Mã 6 ký tự" caption → expiry countdown → Share/Copy row. The picker and CTA
below are unchanged.

The card gained `ClipRRect` at its own radius, matching the design source's
`overflow:hidden` on the same container: the QR's 290×290 ambient glow is
wider than the card and has to stop at the card edge.

Per `../architecture/solution.md` Key Discovery 2, the design's
"Giả lập: Linh vừa vào" (`Simulate: partner joined`) dashed link does not exist
in the app and was deliberately not added — the production-gating question is
resolved by absence, so no dev-only gating code was introduced.

Superseded as AC5 evidence: §6 is prose reasoning about widget order, not a
render. The rendered pair and its verdict now live in
`../visual-fidelity/visual-fidelity-report.md` (`VISUAL_FIDELITY: PASS`).

## Entry Point Reachability

Reachable: YES

- Path: `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart:39`
  pushes `InviteScreen(router: router, createInviteCubit: _createInviteCubit)`.
  Its enclosing `_openInvite` is wired to the screen's primary CTA at
  `pairing_choice_screen.dart:102` (`onPressed: () => _openInvite(context)`).
- Exercised by: `test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`,
  case `the primary action opens invite`. Re-run independently for this record
  rather than taken on trust: that suite is `+7: All tests passed!` (exit 0).
- `story_master.md` records "UI-facing story: YES" and "Direct URL only
  acceptable: NO", so this screen must be reachable by navigation, not only by
  deep link — it is. `pairing_choice_screen.dart` is itself the existing
  pairing-method choice screen the story names as the entry point, and
  STORY-001 changes that screen's layout, not its routing into `InviteScreen`.
- The `cupidpreview://screen/invite` deep link used for the visual-fidelity
  capture is dev-only preview scaffolding (`lib/main_preview.dart`) and is not
  the reachability path claimed above.

## 7. Rework Verification (2026-08-26, reviewer findings B1/B3/B4)

No production, test, or design-system source was modified in this rework — the
reviewer's first pass confirmed AC1-AC4 correct and well-tested, and the
findings were evidence gaps. Commands re-run in the story worktree from
`mobile/` with `PATH="$HOME/flutter/bin:$PATH"`:

| Command | Exit | Result |
| --- | --- | --- |
| `flutter build apk --debug -t lib/main_preview.dart --target-platform android-arm64` | 0 | `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` |
| `flutter analyze` on the 4 story files + `lib/main_preview.dart` | 0 | `No issues found!` |
| `flutter test invite_qr_frame_test.dart invite_screen_test.dart post_code_navigation_guard_test.dart` | 0 | `+31: All tests passed!` |

The two pre-existing red suites recorded in §5 are unchanged and were not
re-litigated: `no_fork_guard_test.dart` remains tracked as `BUG-20260825-002`
(`lib/features/pet/**`, outside this story's write scope) and the gallery
destination-tap case remains pre-existing and unrelated.

Runtime startup smoke (reviewer finding B2) was deliberately NOT recorded here:
it was out of scope for this rework handoff. Captured separately below, run
directly by Scrum Master on the shipped entrypoint (not the preview build).

## Story Runtime Startup Smoke

Scope: mobile-app (impacted service/app for this story).
Runtime Id: mobile-app
Registry: data/devops/system/runtime-command-registry.json (runtimes.mobile-app)
Command: `flutter build apk --debug` (build) + `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-local-debug.apk` (install) + registry-backed readiness command (launch/poll), all from `mobile/`
Ready Check: `runtimes.mobile-app.readiness.command` (adb shell am start -W then poll dumpsys activity activities for ResumedActivity), followed by `runtimes.mobile-app.readiness.shutdownCommand`
Result: PASS
Shutdown: PASS

Owner: Scrum Master, run directly (mobile-dev handoffs in
ordinary `continue` are restricted from emulator/device runtime work by
`guard-broad-handoff.sh [GENERIC]` — targeted unit/component/integration/build
evidence only for that lane; this closes reviewer pass-2 finding B2, the sole
remaining `PATCH_REQUIRED` item). This uses the real shipped entrypoint
(`lib/main.dart` via the standard `buildCommand`), not `lib/main_preview.dart`
used for the §6 visual-fidelity capture above.

Device: `emulator-5554`, already running (not booted by this smoke).

Steps, using the `mobile-app` runtime registry entry
(`data/devops/system/runtime-command-registry.json`):
1. `buildCommand`: `flutter build apk --debug` in `mobile/` (worktree HEAD
   `8a10f04f3cf6db75643aa31f199c89488d6f972c`) — built
   `build/app/outputs/flutter-apk/app-local-debug.apk` cleanly (Gradle
   `assembleLocalDebug`, KGP plugin warning only, no errors).
2. Installed the built debug APK via
   `adb -s emulator-5554 install -r <path-to-app-local-debug.apk>` (direct adb
   install used because `flutter install -d emulator-5554` defaults to the
   release flavor, which was not built here).
3. Ran the registry's exact `readiness.command` (launch `MainActivity` with
   `am start -W`, poll `dumpsys activity activities` for
   `ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
   up to 30 × 2s) — resumed/foreground within the first poll, exit 0.
4. Ran the registry's exact `readiness.shutdownCommand`
   (`am force-stop com.snapsofts.cupid`) to leave the device clean.

Result/Shutdown: PASS, app stopped cleanly, no process left running.
