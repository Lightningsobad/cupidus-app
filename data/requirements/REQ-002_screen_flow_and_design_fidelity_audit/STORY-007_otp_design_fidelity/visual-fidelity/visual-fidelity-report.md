# Visual Fidelity — STORY-007 `otp`

VISUAL_FIDELITY: FAIL

`FAIL` is the honest verdict, not a broken screen. Every deviation inside this
story's own surface was corrected in app code and is gone from the capture. Two
visible differences remain, and both live in shared app chrome (`CupidHeader`
and the app-shell background) that every screen in the app inherits. They are
listed below with named owners rather than silently fixed from a `trivial`
single-screen story mid-wave.

## Scope of this comparison

| | |
|---|---|
| Design screen id | `otp` |
| Design entry | `cupid-app-design-system/project/Cupid App.dc.html` (locked in `data/devops/system/design-fidelity-config.json`) |
| Design block | `Cupid Screens.dc.html:1495-1511` (`sc-if isOtp`) |
| Theme / locale | `dark` + `vi` |
| Platform / frame | Android, 412x915 |
| Design reference | `design-reference-otp-android.png` (406x900) |
| Implemented | `implemented-otp-emulator-5560.png` (405x900) |
| Device | `emulator-5560`, Android 16 (API 36), display forced to 824x1831 @ 320dpi so the app runs at the canvas's 412x915 viewport |
| Preview state | `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=otp`, seeded to the canvas's own composed frame (`email: minh@gmail.com`, `initialCode: '247'`, `resendSeconds: 42`) |

## How the screen id was resolved

The story carried no `Design-Screen:` line (`UX Design — SKIPPED:trivial`).
`render-design-canvas.js --list-screens` on the locked entry prints 37 ids; `otp`
is one of them. The render confirms it by content: the mail badge, the
`Kiểm tra hộp thư nhé` title, the six-cell code input and the `Gửi lại sau 00:42`
cooldown are exactly what this story's `## In Scope` and AC3 describe. Recorded
as `Design-Screen: otp` in `story_master.md`.

## Finding that reframes the story

The story is written as a fidelity *correction* of an existing screen
("the current otp screen, already reachable in the shipped app"). That premise
was false. No OTP screen existed anywhere in `mobile/lib`; `otp` was listed in
`main_preview.dart`'s `_notImplementedCanvasIds`, and
`data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md` §7 records
`otp` as one of ten canvas screens under an **approved REQ-001 scope cut**
(STORY-018 OQ-1).

The story was delivered rather than blocked, following the precedent set by
REQ-002 STORY-009: `permissions` sits on the same ten-screen scope-cut list and
was built from scratch, reviewed and marked DONE. Like `PermissionsScreen`, the
new `OtpScreen` is presentational and preview-only — referenced from
`main_preview.dart` and its test, with no route and no navigation entry point,
which is what this story's AC4 requires ("no new entry point is required — this
story does not change how the screen is reached"). `onVerify`/`onResend` are
left as callbacks for the story that owns the `register -> otp -> permissions`
flow; nothing is sent or verified here, because the app has no code-issuing
backend.

## Deltas found and fixed

| # | Delta | Design source | Fix |
|---|---|---|---|
| 1 | Screen did not exist | `Cupid Screens.dc.html:1495-1511` | New `mobile/lib/features/auth/presentation/screens/otp_screen.dart`, transcribed element by element |
| 2 | Not reachable for render or review | — | Registered `'otp'` in `main_preview.dart` and removed it from `_notImplementedCanvasIds` |
| 3 | Header title read `Xác thực OTP` / `Verify OTP` | `t_otp` maps at `Cupid Screens.dc.html:1769` and `:1781` are `Xác thực` / `Verify`. `Xác thực OTP` is the label of the prototype-only screen-index FAB (`:1860`), which `hide_selectors` removes from the reference | Corrected to `Xác thực` / `Verify`; test updated (the EN header and the EN CTA are both `Verify`, so the assertion is `findsNWidgets(2)`) |
| 4 | Code row painted `RIGHT OVERFLOWED BY 19 PIXELS` below 412dp | The canvas's own metrics (6 x 49 + 5 x 9 = 339, inside a 20px gutter = 379) exceed a 360dp phone | Wrapped the row in `FittedBox(fit: BoxFit.scaleDown)`: exact at the canvas's 412dp frame, scaled instead of clipped below it |
| 5 | Subtitle wrapped `minh@gmail.com` to a second line, pushing the code row, cooldown and CTA down ~27dp | `:1499` caps the block at `max-width:280px` and its own Roboto fits the sentence on one line with ~6px to spare; Android's Roboto renders it just over | Cap raised to 300 — still a narrow centred block, and the design's single line is reproduced |

After these fixes the two images agree on every vertical landmark within a few
pixels: badge 128-192, title ~235, subtitle ~270, code row ~306-362, cooldown
~395, CTA ~432-480.

## Intentional deviations from the design source

- **Code cell painted at 49x59, not the literal 46x56.** The canvas has no
  global `box-sizing:border-box`, so `46 + 2 x 1.5px` of border paints a 49x59
  box. Flutter insets borders, so the outer size has to carry them. The painted
  result is identical; only the number in the source differs.
- **CTA label uses `colorText`, not the canvas's raw `#fff`.** The no-fork guard
  (`no_fork_guard_test.dart`, ADR-004) forbids raw colour literals in
  `features/`. `colorText` (`#F7EEFB`) is the token the design system maps that
  role to.
- **The cooldown does not tick.** `resendSeconds` renders the canvas's `00:42`
  frame. Ticking is flow behaviour owned by the navigation story, not screen
  fidelity.

## AC3 states with no design-source basis

AC3 lists five states. Three are composed in the canvas and are implemented and
tested: empty, partially entered, and resend-cooldown.

- **error/invalid code — N/A.** The canvas has no OTP error state: `isOtp` holds
  exactly one composed frame and no error styling, copy or colour for it. No
  error treatment was invented; there is nothing to be faithful to.
- **resend-available — extrapolated, flagged.** The canvas only composes the
  cooldown. The implemented available state reuses the canvas's own inline-action
  idiom, `<strong style="color:var(--pink)">` (the same treatment as `Đăng nhập`
  at `:1491`), rendering `Gửi lại mã` / `Resend code` in `colorAccentPink` at
  `w700`. This is an explicit extrapolation, not a match, and should be
  confirmed by ui-ux-designer if the design source ever gains the state.

## Remaining deltas, deferred with named owners

Both are shared chrome. Fixing either from this story would restyle every screen
in the app while ~10 sibling stories are capturing their own evidence in the same
wave.

| Delta | Design source | Owner |
|---|---|---|
| Header back arrow is white (`colorText`); the design paints it `var(--pink)` at 26px | `Cupid Screens.dc.html:52` | design-system / `CupidHeader` (`mobile/lib/design_system/adaptive/cupid_header.dart:168`, and the Cupertino variant). Affects every screen with a back affordance |
| Background is flat `colorBackground`; the design paints `var(--sky), var(--bg)` — three radial washes plus faint stars — behind the whole app shell, and the header is transparent over it rather than a `colorSurface` band | `Cupid Screens.dc.html:44` and `:26` | app-shell / design-system. `CupidColorTokens.skyGradient` already carries the value as an unrendered CSS string, and `waiting_screen.dart:270-317` has a private Flutter transcription of all three layers that should be promoted to a shared widget. Every screen shipped so far (`login`, `register`, `permissions`, `notifications`) has the same gap |

## Verification

Run in the story worktree, `mobile/`:

- `flutter analyze --no-fatal-infos lib/features/auth lib/main_preview.dart test/features/auth` — 5 issues, all pre-existing info-level `prefer_initializing_formals` in files this story does not touch (`auth_repository.dart`, `splash_screen.dart`, `session_gate_cubit.dart`).
- `flutter test test/features/auth/otp_screen_test.dart` — 9/9 pass.
- `flutter test test/features/auth/otp_screen_test.dart test/design_system/adaptive_widgets_test.dart` — 21/21 pass. `no_fork_guard_test.dart` is deliberately not part of this story's gate: it is already red at BaseHead over files this story does not touch (see below), so including it would report a pre-existing failure as this story's.
- `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=otp` — built.
- Capture: `capture-mobile-screen.sh --lease-exec` holding `emulator-5560`, install + launch + shutter in one leased window so a sibling story's build cannot land in the frame.

### Pre-existing red at BaseHead, not caused by this story

`4eadb3d871890a9a830d1e9ddb8a161e69a7d6a3` is already failing two guard tests.
Both were verified present at that commit with `git grep` before any file here
was written, and neither names a file this story touches.

- `no_fork_guard_test.dart` — raw colour literals in `ghost_settings_screen.dart:211,411`, `notification_settings_screen.dart:360`, `reminder_schedule_screen.dart:449,450,453`, `reminder_weekday_chips.dart:71`.
- `reminder_copy_guard_test.dart` — `permissions_screen.dart:80,81` ship the forbidden string `Synced Alarm`, which epic-3 bans in favour of `Nhắc nhở đồng bộ`.

The second is a product-rule violation on merged work and is worth a queued bug,
not a silent carry.
