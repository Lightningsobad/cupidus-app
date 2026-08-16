# STORY-005 Test Results

## Story Runtime Startup Smoke

Locale/theme toggle mechanism used: none required. `mobile/lib/app/cupid_app.dart`
reads `CupidFeatureFlags.enableLightTheme` / `enableEnLocale`
(`mobile/lib/core/config/cupid_feature_flags.dart`), both `bool.fromEnvironment`
with `defaultValue: false`. With no `--dart-define` overrides, `themeMode` is
`ThemeMode.dark` and `locale` is hard-coded `Locale('vi')` — the app's
build-time default already IS the dark theme + `vi` locale configuration this
story audits, so no device-level or in-app toggle was set.

### Android (emulator-5560)
- `backend-api` dependency: already reachable, `GET /api-docs-json` → 200,
  no start needed.
- Device: reused existing running emulator `emulator-5560` (adb state
  `device`), per `launch.subcommands.android` reuse rule.
- Build/install: `flutter build apk --debug --dart-define=CUPID_API_BASE_URL=http://10.0.2.2:3000`
  → `build/app/outputs/flutter-apk/app-debug.apk`, installed via
  `adb -s emulator-5560 install -r`.
- Readiness probe (registry `mobile-app.readiness.command`): `am start -W`
  reported `Status: timeout` (first-frame wait quirk, not a failure signal)
  but the subsequent `dumpsys activity activities` poll confirmed
  `ResumedActivity` for `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
  within the 90s timeout.
- **Result: PASS**
- **Correction (this run):** the readiness launch lands on `WelcomeScreen`
  (correct app entry point), not `LoginScreen`. Navigated
  `WelcomeScreen -> LoginScreen` via the "Dùng email" affordance
  (`mobile/lib/features/auth/presentation/screens/welcome_screen.dart:318`,
  `_openLogin` -> `OnboardingNode.login`): dumped the UI tree with
  `adb -s emulator-5560 shell uiautomator dump`, located the "Dùng email"
  `Button` node at bounds `[53,2088][1028,2224]`, and tapped its center with
  `adb -s emulator-5560 shell input tap 540 2156`. A second `uiautomator
  dump` after the tap confirmed `LoginScreen` content-desc nodes "Mừng bạn
  quay lại", "Quên mật khẩu?", "Đăng nhập", "hoặc", "Chưa có tài khoản?
  Đăng ký" — confirming the navigation reached `LoginScreen` before capture.
- Raw capture: `adb -s emulator-5560 exec-out screencap -p` →
  `visual-fidelity/raw-capture/login-android.png` (overwritten; confirmed
  via image read: "Mừng bạn quay lại" heading, EMAIL/MẬT KHẨU fields,
  "Quên mật khẩu?", "Đăng nhập" button, "hoặc" divider, Google/Facebook
  buttons, "Chưa có tài khoản? Đăng ký" — matches `LoginScreen`, not
  `WelcomeScreen`).
- Shutdown: `adb -s emulator-5560 shell am force-stop com.snapsofts.cupid`
  → exit 0.
- **Shutdown: PASS**

### iOS
- `xcode-select -p` resolves (`/Applications/Xcode.app/Contents/Developer`),
  but `xcrun simctl list devices available` and
  `xcrun simctl list runtimes` both returned no entries — no iOS Simulator
  runtime/device is installed on this machine, so
  `launch.subcommands.ios` has no device to reuse or boot.
- **Result: BLOCKED — typed blocker `IOS_NO_SIMULATOR`** (from
  `runtimes.mobile-app.launch.typedBlockers` in
  `data/devops/system/runtime-command-registry.json`).
- No iOS capture was taken; no shutdown applicable.

## Entry Point Reachability

`LoginScreen` is reachable from the app's launch entry point. This evidence was
already produced during the Android runtime smoke above and is recorded here
under its own heading (review finding BF-06 was a missing heading, not missing
evidence — no re-verification was performed for it).

- **Static wiring:** `mobile/lib/features/auth/presentation/screens/welcome_screen.dart:317-333`
  renders the "Dùng email" affordance, which invokes `onUseEmail` -> `_openLogin`
  -> `OnboardingNode.login`.
- **Runtime confirmation:** see *Android (emulator-5560)* above. The readiness
  launch lands on `WelcomeScreen`; `adb ... shell uiautomator dump` located the
  "Dùng email" `Button` node at bounds `[53,2088][1028,2224]`, `adb ... shell
  input tap 540 2156` activated it, and a second `uiautomator dump` confirmed
  `LoginScreen` content-desc nodes ("Mừng bạn quay lại", "Quên mật khẩu?",
  "Đăng nhập", "hoặc", "Chưa có tài khoản? Đăng ký").
- **iOS:** not covered — blocked by `IOS_NO_SIMULATOR` (accepted deferral).

## Patch Round 3 — Static + Widget Evidence

Scope: review findings BF-02, BF-03, BF-04, BF-06. Static and widget-test
evidence only; no device/simulator interaction was performed in this round.

### Commands

- `flutter analyze lib/features/auth/presentation/screens/login_screen.dart
  lib/design_system/icons/cupid_icons.dart
  test/features/auth/presentation/screens/login_screen_test.dart`
  → `No issues found! (ran in 1.6s)`
- `flutter test test/features/auth test/design_system`
  → `00:03 +156: All tests passed!`

Run from the story worktree's `mobile/` package. Whole-package
`flutter analyze` is not a usable gate here: it exits 1 on pre-existing errors
in the vendored `build/ios/SourcePackages/checkouts/flutterfire/**` tree, and
`flutter analyze lib test` reports 81 pre-existing `info` lints in files this
story does not touch. Both conditions predate this round.

### BF-02 — password show/hide toggle

`login_screen.dart` now renders `_PasswordVisibilityToggle` in the password
`_FieldCard`'s trailing slot, driven by `_LoginViewState._passwordObscured`.
Covered by `password field carries a real show/hide toggle` in
`test/features/auth/presentation/screens/login_screen_test.dart`, which asserts
the `CupidIcons.visibilityOff` glyph at size 21 in `colorTextMuted` with
`CupidIconVariant.line` axes, then taps it and asserts both that
`TextField.obscureText` flips and that the glyph becomes `CupidIcons.visibility`
— i.e. a functional toggle, not a decorative glyph.

A second per-platform test asserts the toggle's ancestor `GestureDetector` hit
box meets `CupidPlatformTokens.tapTarget` in both axes (44 iOS / 48 Material)
while the card still measures 63.6dp, and that the glyph lands exactly 16dp from
the card's right edge and 13dp above its bottom, matching the design source's
`align-items:flex-end` + `gap:12px`.

Both `visibilityOff` (0xe8f5) and `visibility` (0xe8f4) codepoints were
confirmed present in the bundled `MaterialSymbolsRounded-Variable.ttf` cmap
before being added to `CupidIcons`.

### BF-03 — field card height 72.0dp -> 63.6dp

Root cause was `TextField`/`InputDecorator` intrinsic line-box metrics, which
survive `isDense: true` + `contentPadding: EdgeInsets.zero`. The fix is in the
height constraint and the text line boxes, not in the spacing constants (which
were already correct):

- `_FieldCard` is wrapped in `SizedBox(height: _fieldCardHeight /* 63.6 */)`.
- The label and input both carry an explicit `TextStyle.height`
  (`_fieldLabelLineHeight`, `_fieldInputLineHeight`), derived from the design
  card height minus padding and gap, so the input's strut is pinned rather than
  inherited from whatever the platform UI font declares.
- Both fields set `isDense: true, isCollapsed: true,
  contentPadding: EdgeInsets.zero`.

The pinned `SizedBox` is required, not redundant: the engine rounds each text
line box up to a whole pixel, so the authored 13.2 + 18.4 boxes lay out as
13.0 + 18.0 and the summed card measured 63.0 — 0.6dp short. Covered by
`both field cards measure the design-source 63.6dp` over both the `EMAIL` and
`MẬT KHẨU` cards.

### BF-04 — Google/Facebook brand marks

Both social buttons now draw a brand mark before the label. The bundled Material
Symbols font has no `facebook` glyph and Google's mark is four-color, so neither
could be a `CupidIcons` entry; there is also no `flutter_svg` dependency in the
package. The marks are therefore vector paths transcribed from the design
source's inline SVG and painted by `CupidBrandMarkIcon` in
`design_system/icons/cupid_icons.dart` — asset-free, resolution-independent, and
it keeps the brand color literals inside `design_system/`, which is the only
tree the AC-4 no-fork guard permits them in.

Covered by the brand-mark test, which asserts sizes 19 (Google) / 18
(Facebook), label gaps 8 / 7, vertical centering against each label, and — via
the `paints` matcher — that all four Google brand colors (`0xFF4285F4`,
`0xFF34A853`, `0xFFFBBC05`, `0xFFEA4335`) are painted in order and that Facebook
paints `0xFF1877F2`. `test/design_system/no_fork_guard_test.dart` passes in the
same run, confirming no color literal leaked into `lib/features`.

Apple's button remains text-only: it was not flagged by the review and is
outside this dispatch's scope.

### BF-06 — entry point reachability heading

Added above as `## Entry Point Reachability`.

### Still open after this round

- **BF-05** (AC3 field-state runtime evidence) — requires device capture,
  routed separately.
- Fresh runtime re-capture of the login screen to re-measure BF-02/03/04 on
  device; the `visual-fidelity/` report is updated by that separate dispatch.
- **BF-01** (biometric quick-unlock row) — deferred by user decision to a new
  future backlog story.

## Patch Round 3 Re-Capture + Field States

Scope: review finding BF-05 (AC3 field-state runtime evidence) plus a fresh
full-screen re-capture confirming BF-02/BF-03/BF-04 render correctly, on top
of the same mobile-dev code patch to `login_screen.dart` and
`cupid_icons.dart` covered statically above (`## Patch Round 3 — Static +
Widget Evidence`). Same device (`emulator-5560`) and navigation methodology
as the original *Android (emulator-5560)* section.

### Rebuild / reinstall / navigate

- Rebuilt: `flutter build apk --debug
  --dart-define=CUPID_API_BASE_URL=http://10.0.2.2:3000` ->
  `build/app/outputs/flutter-apk/app-debug.apk` (picks up the
  `login_screen.dart`/`cupid_icons.dart` patch).
- Reinstalled on the same reused `emulator-5560` (adb state `device`):
  `adb -s emulator-5560 install -r ...` -> `Success`.
- Readiness: same registry probe as before (`am start -W` +
  `dumpsys activity activities` poll) -> `ResumedActivity` for
  `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` confirmed.
- Navigation: same `WelcomeScreen -> LoginScreen` path via "Dùng email".
  `uiautomator dump` located the same content-desc "Dùng email" node at
  bounds `[53,2088][1028,2224]`, tapped its center (`540,2156`); a second
  dump confirmed `LoginScreen` content-desc nodes including the new "Hiện
  mật khẩu" toggle label (absent before this patch round).

### Fresh full-screen re-capture -> `login-android.png` (overwritten)

Confirms all three code fixes render on-device:

- **BF-02**: the password field's trailing slot now shows the
  `visibility_off` glyph (content-desc "Hiện mật khẩu").
- **BF-03**: both EMAIL and MẬT KHẨU field cards render at equal, visually
  matched height — no longer visibly taller than the other. (Precise pixel
  re-measurement against the design source's 63.6dp is
  `visual-fidelity-report.md`'s scope; this capture is on-device confirmation
  only, not a repeat of that measurement.)
- **BF-04**: both social buttons draw a brand mark before their label —
  Google's 4-color "G" and Facebook's blue "f" roundel.

### Field states (BF-05, AC3)

Design-source comparison basis: `cupid-app-design-system/project/Cupid
Screens.dc.html`'s `isLogin` block (lines 1425-1458) is the only
design-source authority for this screen's field styling. It authors exactly
one static visual treatment per field card
(`background:var(--surf)`, `border-radius:var(--r-card)`,
`box-shadow:var(--shadow)`, borderless `<input>`), pre-filled with
placeholder values `minh@gmail.com` / `loveyou247`. A full read of that block
plus a targeted search of the entire file (patterns
`:focus`, `:invalid`, `border-color`, `--error`, `--danger`, `invalid`,
`validation`) found no authored `:focus` state, no authored error/invalid
state, and no `--error`/`--danger` color token anywhere in the design
source. The file's only `@keyframes shake` (line 32) is unused elsewhere and
never attached to any field or validation element. So AC3's "focused" and
"error/validation" states have no authored design-source styling to match —
fidelity for those two states means the app must not introduce a visual
treatment (border/background/color change) the design source doesn't
specify, not that it must reproduce a specific undefined style.

- **Empty** — already covered by the base full-screen capture above
  (`login-android.png`, captured before any input) and by the original
  Android runtime smoke section. Card chrome (`--surf` background, `--r-card`
  radius, `--shadow` elevation, uppercase `--tx2` label) matches the design
  source exactly; no separate capture needed.
- **Focused** — `visual-fidelity/raw-capture/login-android-focused.png`.
  Tapped into the EMAIL field (`uiautomator`-located bounds
  `[95,503][985,551]`, tap `540,527`). Card background/border/radius/shadow
  are unchanged from the empty state; no border or outline appears.
  **Matches design source**: it authors no `:focus` style, and
  `login_screen.dart`'s `InputDecoration(border: InputBorder.none, ...)`
  also suppresses Flutter's default Material focus underline, so the app
  correctly introduces no unauthored focus treatment. (The soft keyboard did
  not render in the emulator's `screencap` output — a known emulator/adb
  `screencap` limitation, not part of the app UI under audit — but the
  field-card chrome above the keyboard line is fully visible and
  unobstructed in this capture.)
- **Filled** — `visual-fidelity/raw-capture/login-android-filled.png`. Typed
  `minh@gmail.com` into EMAIL and `loveyou247` into MẬT KHẨU
  (`adb shell input text`) — the exact placeholder values the design source
  itself authors in its `<input value=...>` attributes. Rendered text
  color/weight/size and card chrome match the design source's filled
  treatment (same card, same borderless input, same uppercase label above);
  password glyphs render as bullets, consistent with `obscureText`.
  **Matches design source.**
- **Error/validation** —
  `visual-fidelity/raw-capture/login-android-error.png`. Tapped "Đăng nhập"
  with the filled (intentionally wrong) credentials against the live,
  already-reachable `backend-api`. `SignInCubit` transitioned to
  `SignInFailed`, and `login_screen.dart`'s `errorText != null` branch
  rendered "Email hoặc mật khẩu không đúng" in `colors.colorRed` below the
  two field cards (confirmed via both `uiautomator dump` content-desc and
  the capture). The field cards themselves keep their unchanged chrome — no
  red border or background shift on either card. **No design-source
  deviation to record**: since the design source authors no error/validation
  state at all for this screen, there is nothing for the app's error text to
  deviate from; the app's addition renders through the shared `colorRed`
  design token (not a hand-picked literal), so it stays inside token
  discipline even though the state itself is a build-only addition beyond
  the static mock.

### Shutdown

`adb -s emulator-5560 shell am force-stop com.snapsofts.cupid` -> exit 0.

**Result: PASS** — BF-05 field-state runtime evidence captured for all four
AC3 states (empty, focused, filled, error/validation); BF-02/BF-03/BF-04
confirmed rendering correctly on-device via the fresh full-screen
re-capture.
