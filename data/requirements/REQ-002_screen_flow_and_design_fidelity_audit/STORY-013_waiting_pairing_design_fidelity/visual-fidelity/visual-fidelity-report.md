# Visual Fidelity Report: STORY-013 Waiting (Đợi Ghép) Screen

Story: STORY-013 Design Fidelity — Waiting For Pairing
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Lane: mobile
Configuration audited: dark theme + `vi` locale (the only combination enabled
for users; OQ5 keeps light/`en` visual QA out of scope)
Design-Screen: waiting
Round: 2 (patch for review findings B1, B2, B3)

VISUAL_FIDELITY: FAIL

The verdict is driven entirely by two residual deltas that are visible in the
rendered comparison and that this story cannot close from inside its own write
scope — the missing `--sky` root background (already accepted as a
requirement-level app-shell deferral by round 1's D1) and the missing `ios_share`
glyph on the resend CTA (needs a new `cupid_icons.dart` codepoint). Every
element `waiting_screen.dart` itself owns now matches the design source. See
"Rendered Comparison" for the per-element result and "Residual Visible Deltas"
for the two items and their owners.

## Design Source Of Truth

- File: `cupid-app-design-system/project/Cupid Screens.dc.html`
- Canvas screen id: `waiting`
- Block: `<sc-if value="{{ isWaiting }}">`, lines 1572-1589
- Shared keyframes: line 29 (`pulseRing`), line 31 (`bob`)
- Dark palette variables: line 26 (`--bg`, `--surf`, `--line`, `--tx`, `--tx2`)
- Brand palette variables: line 23 (`--pink`, `--purple`)
- Screen chrome classification: line 1951/1952 confirm `waiting` is in both
  `NO_CHROME` and `NO_TABS`, matching the implementation (no header, no tab
  bar). No deviation.

## Design Screen Resolution (review finding B2)

`data/devops/system/design-fidelity-config.json` declares this bundle as
`type: claude-design`, `screens_from: canvas`, so the screen identity is a
canvas state id, not a file path. Resolution:

1. `render-design-canvas.js --list-screens` against
   `cupid-app-design-system` / `Cupid App.dc.html` returns 37 ids; exactly one,
   `waiting`, is a candidate for this story's screen.
2. Rendering that id produced `design-reference-waiting-android.png`, and the
   render shows the hourglass pulse field, the "Đang đợi Linh vào…" status
   line, the "Mã của bạn" code card and the two-button row — the same block as
   `Cupid Screens.dc.html:1572-1589`, which is the markup this report audits
   against. The id and the line range therefore describe the same screen.
3. `waiting` is also the key this screen is registered under in
   `mobile/lib/main_preview.dart`'s `previewScreens` map, so the implementation
   capture and its design reference are named from the same id and cannot be
   mismatched.

Recorded as `Design-Screen: waiting` in `story_master.md`.

## Implementation Under Audit

`mobile/lib/features/pairing/presentation/screens/waiting_screen.dart`

## Deviations Found And Fixed

### D1 — Waiting animation was an ad hoc solid disc, not the source's `pulseRing`

- Design source (1574-1577): a `150x150` relative field containing two
  absolutely-positioned `pulseRing` rings (`1.5px` borders, staggered by
  `1.2s` on a `2.4s ease-out` loop) and a `bob`-animated inner disc inset by
  `24px` carrying an `hourglass` glyph at `46px` in `--pink`.
- Before: a single filled `64x64` pink circle scaling `0.85 -> 1.0` and fading
  `0.5 -> 1.0` on a `1200ms` reversing loop. This is neither `pulseRing` nor
  `bob` — it is an invented keyframe, which AC 3 forbids.
- Fix: replaced `_PulsingHold`'s body with the source's composition — a
  `SizedBox(150, 150)` `Stack` holding two `_PulseRing` widgets and the inset
  bobbing gradient disc with `CupidIcon(CupidIcons.hourglass, size: 46)`.
  `_PulseRing` reproduces the `pulseRing` keyframes exactly: `scale(.9)` at
  `opacity .7` expanding to `scale(1.5)` at `opacity 0` across the first 70%
  of the cycle, then held invisible for the remainder, on `Curves.easeOut`.
  Both rings read one `2400ms` controller; the second applies a `0.5` phase
  offset, which is the source's `1.2s` delay on a `2.4s` cycle. `bob`
  (`translateY(0 -> -7px -> 0)`, `3s ease-in-out`) is a separate `1500ms`
  reversing controller.
- Ring colors now come from tokens with the source's alpha:
  `colorAccentPink` at `.4` (source `rgba(255,127,182,.4)`, which is `--pink`
  at 40%) and `colorAccentPurple` at `.35` (source `rgba(183,140,245,.35)`,
  `--purple` at 35%). The inner disc uses the source's two-stop gradient of
  the same two tokens at `.24`.

### D2 — Status line used body typography instead of the source's title role

- Design source (1579): `font-family:Nunito;font-weight:900;font-size:24px;
  line-height:1.25`, color inherited from `--tx`.
- Before: `context.cupidType.body` (platform UI font, `w400`, `17px`) — wrong
  family, wrong weight, wrong size, no line height.
- Fix: `context.cupidType.display.copyWith(fontSize: 24, height: 1.25)` with
  `colors.colorText`. `display` is the design system's Nunito `w900` role, so
  only the size and line height are overridden to the source's values.

### D3 — Supporting subtitle line was missing entirely

- Design source (1580): `font-size:13px;line-height:1.6;color:var(--tx2);
  margin-top:10px;max-width:270px`, copy "Gửi mã rồi mà chưa thấy ai vào.
  Chọc Bae một cái đi." / "Code sent, nobody has joined yet. Go nudge Bae."
- Before: absent — the screen showed a single status line.
- Fix: added under the title using `context.cupidType.caption` (already
  `13px`) with `height: 1.6` and `colors.colorTextMuted` (`--tx2`), inside a
  `ConstrainedBox(maxWidth: 270)` and separated by `SizedBox(height: 10)`.
  The line is suppressed in the `WaitingPaired` state only: its copy asserts
  nobody has joined yet, which is false at that moment, and the screen is
  already navigating on to `paired`.

### D4 — Screen padding did not match the source

- Design source (1573): `padding:40px 26px`.
- Before: `EdgeInsets.all(CupidSpacing.lg)` = `24` on all sides.
- Fix: `EdgeInsets.symmetric(horizontal: 26, vertical: 40)`. Neither `26` nor
  `40` exists on the `CupidSpacing` 8pt scale (`4/8/16/24/32/48`), so the
  source's exact values are transcribed rather than rounded to the nearest
  token — AC 1 requires an exact match, and rounding to `24/32` would be a
  visible deviation.

### D5 — Gap between the animation and the title was wrong

- Design source (1579): the title carries `margin-top:32px`.
- Before: `CupidSpacing.lg` (`24`).
- Fix: `CupidSpacing.xl` (`32`), which is the token that equals the source
  value.

### D6 — Refresh action rendered with stock Material defaults

- Design source (1587), secondary action in the button row: `height:50px;
  border-radius:var(--r-btn)` (pill, `999`), `border:1.5px solid var(--line)`,
  `font-size:14.5px;font-weight:700`, text in `--tx`; the row is `width:100%`
  capped at `max-width:300px` with `margin-top:22px`.
- Before: a bare `OutlinedButton` with no style. `buildCupidTheme` defines no
  `outlinedButtonTheme`, so it inherited Material 3 defaults: ~`40px` height,
  a `1px` outline from the fallback `ColorScheme.outline` (not `--line`), and
  `labelLarge` text (`14px`, `w500`). Every one of those is a token-usage
  deviation.
- Fix: wrapped in `ConstrainedBox(maxWidth: 300)` + `SizedBox(width:
  double.infinity, height: 50)` with `SizedBox(height: 22)` above, and styled
  from tokens — `side: BorderSide(color: colors.colorLine, width: 1.5)`,
  `shape` radius from `context.cupidPlatform.radiusButton` (`999`, pill on
  both platforms), `textStyle` at `14.5` / `FontWeight.w700`, and
  `foregroundColor: colors.colorText`.

### D7 — Fixed-height column could clip on short viewports

- Before: `Center > Padding > Column`. With the taller `150px` animation
  field, the added subtitle, and the `40px` vertical padding, the content is
  now tall enough to overflow a small phone in landscape or at a large text
  scale.
- Fix: swapped `Padding` for `SingleChildScrollView` with the same padding,
  mirroring `invite_screen.dart`'s existing pattern. The design source's own
  container is `min-height:100%` with centered content, which this preserves.

### D8 — "Mã của bạn" code card was absent (round 1 O1, review finding B3)

- Design source (1581-1584): a `--surf` card (`padding:14px 26px`,
  `border-radius:20px`, `box-shadow:var(--shadow)`) holding an `11px` `--tx2`
  label and the pairing code in Roboto Mono `500` at `26px`,
  `letter-spacing:.14em`, painted with the `--grad-hot` gradient.
- Round 1 left this unbuilt because `WaitingScreen` received only `expiresAt`
  and the code lives in `InviteScreen`'s `InviteReady.invitation.code`, in a
  file outside the declared `WriteScope`.
- Fix (Scrum Master widened the write scope to the `invite_screen.dart` call
  site only): `WaitingScreen` gained a `String? code` parameter, threaded from
  `invite_screen.dart:101` (`code: invitation.code`) at the existing
  `WaitingScreen(...)` construction. Nothing else in `invite_screen.dart` was
  read, restyled or moved — that file's own fidelity pass is STORY-011.
- `_CodeCard` renders the source's composition from tokens: `colorSurface`
  fill, `context.cupidPlatform.elevationShadow` (`--shadow`),
  `EdgeInsets.symmetric(horizontal: 26, vertical: 14)`, an `11px`
  `colorTextMuted` label, and the code in `cupidType.labelMono` at `26`/`w500`
  with `letterSpacing: 26 * 0.14` (the source's `.14em` resolved at `26px`).
  The `--grad-hot` text fill is reproduced with
  `ShaderMask(blendMode: BlendMode.srcIn)` over `colors.gradientHot`, which is
  the Flutter equivalent of the source's `background-clip:text`.
- The `20px` corner radius is transcribed from the source: no shape token
  covers it (`radiusSmall` is `16`, `radiusCard` is `24`/`26`).
- `code` is nullable rather than required because `main_preview.dart`'s
  standalone `waiting` capture entry and the pre-existing
  `test/features/pairing/presentation/waiting_screen_test.dart` both construct
  the screen without an invitation. The real navigation path always supplies
  one, and the codeless path is covered by its own test.

### D9 — "Gửi lại" (share again) primary CTA was absent (round 1 O2, B3)

- Design source (1586): the row's first button — `flex:1`, `height:50px`,
  `border-radius:var(--r-btn)`, `--grad-hot` fill, `#fff` text at
  `14.5px`/`w800`, `box-shadow:var(--glow)`, with an `ios_share` glyph at
  `19px` and `gap:8px`.
- Fix: `_ResendButton` renders a `DecoratedBox` carrying `colors.gradientHot`,
  `colors.glowShadow` (`--glow`) and a `radiusButton` (`999`, pill) radius,
  over a transparent `Material` + `InkWell` so the whole pill is the hit area.
  Label at `14.5`/`w800` in `colors.colorText`. The row is
  `ConstrainedBox(maxWidth: 300) > SizedBox(height: 50) > Row` with two
  `Expanded` children and a `SizedBox(width: 10)` between them, matching the
  source's `flex:1` / `gap:10` / `max-width:300px` / `margin-top:22px`.
- Label colour: the source says `color:#fff`; the implementation uses
  `colors.colorText`. That is the house precedent for on-accent CTA text —
  `design_system/adaptive/cupid_primary_button.dart:49,55` does the same — and
  it keeps the button legible if the light theme is ever enabled, where a
  hardcoded `#fff` would not be. In the audited dark configuration
  `colorText` is `#F7EEFB`, which is not distinguishable from `#fff` at this
  size in the rendered capture.
- Action: re-shares the code through the same accessible clipboard +
  `SemanticsService.sendAnnouncement` + `SnackBar` mechanism
  `invite_screen.dart` already uses for its "Chia sẻ mã mời" action, with the
  same clipboard payload. No new dependency, no native share plugin, and no
  new navigation — the screen's entry path is unchanged (AC 4).

## Deviations Found And NOT Fixed

### O3 — "Giả lập: Linh vào" (Simulate join) button is intentionally not built

- Design source (1587) wires this to `goPaired` purely so the prototype can
  jump screens. It is a mockup navigation aid, not product behavior, and the
  real app reaches `paired` through `WaitingCubit`'s poll. Not a deviation to
  fix; recorded so a later reviewer does not read its absence as a gap.
- The screen keeps the real "Làm mới" / Refresh action in that slot, so the
  row's geometry (two `flex:1` children, `gap:10`, `max-width:300`,
  `height:50`, pill radius) is the source's, while the affordance is the
  product one. The visible difference is the label text only.

## Substitutions And Interpretation Notes

- Glyph: the source uses `hourglass_top`. The app ships
  `CupidIcons.hourglass` (`0xebff`), the hourglass codepoint confirmed present
  in the bundled Material Symbols Rounded subset. No `hourglass_top` entry
  exists in `cupid_icons.dart`, and inventing an unverified codepoint would
  render tofu. Used `CupidIcons.hourglass` at the source's `46px` in `--pink`.
- Gradient angle: the source's inner disc uses `linear-gradient(140deg, ...)`.
  Flutter's `LinearGradient(begin: topLeft, end: bottomRight)` is the closest
  standard equivalent (135deg); on a `102px` circle the 5-degree difference is
  not perceivable.
- Background: see R2 under "Residual Visible Deltas". App-shell scope shared by
  every screen, deferred to requirement level, and the dominant difference in
  the rendered comparison.
- Copy: the source hardcodes the partner name ("Đang đợi Linh vào…"). The app
  has no partner name while waiting, so the existing spec-derived status copy
  ("Đang chờ người ấy…") is retained; only its typography was corrected. The
  timed-out and paired status variants are existing app states with no
  counterpart in the static mockup and were left as-is.

## Rendered Comparison (review finding B1)

Round 1 shipped no images. Both now exist in this directory:

| Role | File | Produced by |
|---|---|---|
| Design reference | `design-reference-waiting-android.png` (406x900) | `render-design-canvas.js --location=cupid-app-design-system --entry="Cupid App.dc.html" --screen=waiting --platform=android --toggles=dark,vi` |
| Implemented | `implemented-waiting-emulator-5554.png` (405x900) | `capture-mobile-screen.sh --label=waiting --device=emulator-5554 --width=540 --density=240 --max-edge=900 --route=cupidpreview://screen/waiting --settle-ms=45000`, on a debug APK built from `-t lib/main_preview.dart --dart-define=PREVIEW=waiting` |

The implemented capture is the real app on a real Android emulator, not a
widget-test render: `540x1200` physical at density `240` = `360x800` logical dp,
downscaled to `405x900`, so `1dp` = `1.125` image px. The design reference is
rendered inside a device bezel, so the two images are not pixel-registerable
against each other; absolute geometry is asserted in dp by the widget tests
below, and the images are the check on composition, colour and typography.

Per-element result of reading the two images side by side:

| Element | Result |
|---|---|
| Pulse field + bob disc + hourglass | Match. Same 150dp field, same inset disc, same pink hourglass at the same optical size. Ring opacity differs between the two stills only because both are mid-animation at unsynchronised phases. |
| Status title | Match in role, weight, size and colour. Copy differs by design — see the copy note below. |
| Subtitle | Match. Same string, same muted colour, same two-line wrap inside the 270dp cap. |
| Code card | Match. Same `--surf` card, same 20dp corners, same `11px` muted label, same gradient mono code at the source's letter-spacing, same `CPD-8F2K` sample string. |
| Button row geometry | Match. Two equal-width pills, 10dp gap, 50dp tall, capped at 300dp, same offset below the card. |
| Primary CTA fill | Match. Same `--grad-hot` pink-to-purple sweep with the `--glow` bloom beneath it. |
| Primary CTA glyph | **Delta R1** — the source's `ios_share` glyph is missing. |
| Secondary CTA | Label differs by design (O3), styling matches. |
| Root background | **Delta R2** — flat `--bg` instead of the source's `--sky` gradient and its star particles. |

## Residual Visible Deltas

### R1 — `ios_share` glyph missing from the resend CTA

The source puts a `19px` `ios_share` icon before the "Gửi lại" label. No share
glyph exists in `mobile/lib/design_system/icons/cupid_icons.dart`. The
codepoint is verified present in the bundled font — `ios_share` is at `0xe6b8`
in `mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf`, read from the
font's cmap — so this is a one-line registry addition
(`static const IconData iosShare = IconData(0xe6b8, ...)`) plus the `Row` +
`SizedBox(width: 8)` + `CupidIcon(size: 19)` in `_ResendButton`. It was not
done here because `cupid_icons.dart` is outside this story's `WriteScope`, and
inlining a raw `IconData` in a feature file would fork the icon registry
contract that `no_fork_guard_test` exists to protect.

Owner: a design-system story, or a scope widen on re-review. One line of
registry plus three lines of layout.

### R2 — root `--sky` background gradient not rendered

Unchanged from round 1's D1 and already accepted as a deferral: the design
root (line 44) layers `var(--sky)` over `var(--bg)` for every screen, and
`CupidColorTokens.skyGradient` is still a documentation-only `String` token
that no screen paints. This is an app-shell gap shared by every Scope B
screen, not a `waiting`-specific deviation, and belongs at requirement level.
It is the largest visible difference between the two images and is the main
reason the verdict above is FAIL rather than PASS.

Owner: REQ-002 requirement integration, per round 1's D1 deferral.

## Verification Evidence

All commands run in the story worktree
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-013/mobile`
with `flutter` on PATH from `$HOME/flutter/bin`.

1. `flutter gen-l10n` — regenerated `lib/l10n/generated/app_l10n.dart`, which
   is gitignored and was absent in the fresh worktree. Without it the whole
   project fails to analyze (pre-existing condition, unrelated to this story).
2. `dart format` on `waiting_screen.dart`, `invite_screen.dart`,
   `main_preview.dart` and the design-fidelity test — no manual style drift.
3. `flutter analyze` on those same 4 files — 4 issues, all
   `prefer_initializing_formals` (info) on the pre-existing
   `_createInviteCubit`/`_createWaitingCubit` constructor seams this story did
   not touch (`invite_screen.dart:28,29,49`, `waiting_screen.dart:27`). The
   same lint fires repo-wide on the identical pattern. No errors and no
   warnings from the changed code.
4. `flutter test test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart`
   — 6/6 passed (3 pre-existing + 3 added this round).
5. `flutter test test/features/pairing test/design_system/no_fork_guard_test.dart`
   — 76/76 passed (was 73/73 in round 1; +3 is exactly the new cases, no
   regressions). Includes the pre-existing `waiting_screen_test.dart` behavior
   tests (status text, poll-to-paired transition, timeout fallback, manual
   refresh), the `invite_screen` "copy announces via a snackbar and advances to
   waiting" test that exercises the new `code:` argument on the real
   navigation path, and the AC 4 no-fork guard that forbids raw color literals
   in `lib/features`.
6. Real-device render: debug APK built with
   `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=waiting`,
   installed on `emulator-5554` under the device lease, captured through the
   `cupidpreview://screen/waiting` deep link. The first capture attempt at
   `--settle-ms=9000` and a second at `20000` both photographed the Flutter
   launch splash — this emulator needs longer than that to reach first frame
   after a cold install, not an app fault (`logcat` showed the Dart VM up and
   no exception, and a live screenshot taken afterwards showed the screen fully
   rendered). `--settle-ms=45000` produced the capture used above.

Test coverage added this round, in the same file:
`renders the design source code card for the invite code` asserts the card's
`colorSurface` fill, 20dp radius, `elevationShadow`, `26/14` padding, the
`11px` muted label, and the code at Roboto Mono `26`/`w500` with
`letterSpacing == 3.64`, plus the presence of the `ShaderMask` that clips
`--grad-hot` to the glyphs. `renders the resend CTA as the gradient primary of
the row` asserts `gradientHot`, `glowShadow`, the `radiusButton` pill, the
`14.5`/`w800` label, and — from the real laid-out boxes — that the two buttons
are equal width, exactly 10dp apart, 50dp tall and within the 300dp cap.
`omits the code card and resend CTA when no code is supplied` pins the
nullable-`code` fallback so the codeless path cannot silently start rendering
an empty card.

## Write-Scope Disclosure

`mobile/lib/main_preview.dart` was edited outside the declared `WriteScope`:
one line, adding `code: 'CPD-8F2K'` (the design canvas' own sample string) to
the existing standalone `waiting` preview entry so the implementation capture
and its design reference show the same code. Without it the capture would
render the codeless fallback and could not evidence D8/D9 at all. This is the
mechanism the mobile-dev `visual-fidelity` reference prescribes — "if a screen
can only be reached through a real runtime transition, add a dev-only trigger
… adding that trigger IS the fix" — and `capture-mobile-screen.sh` requires
the captured state to be faked rather than driven. It is dev-only scaffolding
that no release entrypoint imports, and it changes no product behaviour.
Flagging it explicitly for the reviewer rather than folding it into the diff
silently.

## Acceptance Criteria Status

- AC 1 (layout, spacing, color/token, typography match): MET for every element
  `waiting_screen.dart` owns, verified against a real rendered capture rather
  than widget metrics alone. Two visible deltas remain and are NOT counted as
  met — R1 (`ios_share` glyph, needs `cupid_icons.dart`) and R2 (`--sky` root
  background, requirement-level app-shell deferral carried over from round 1).
  Round 1's O1/O2 gap that made this criterion only partially met is now
  genuinely closed: the code card and resend CTA are built and rendered, see
  D8/D9 and the capture.
- AC 2 (deviations corrected in the app, not just documented): MET — D1-D9 are
  code fixes in `waiting_screen.dart` (plus the one-line `invite_screen.dart`
  call-site pass-through for D8/D9), re-verified by items 3-6 above.
- AC 3 (animation uses the source's own vocabulary): MET — `pulseRing` and
  `bob` reproduced from the source keyframes; the ad hoc scale/fade disc is
  gone. Confirmed in the capture, not only in the test.
- AC 4 (no new entry point): MET — no navigation, routing, or `WaitingCubit`
  polling code was touched. The screen is still reached only from
  `InviteScreen`'s existing push; the only change at that call site is one
  extra named argument on the `WaitingScreen` it already constructed.
