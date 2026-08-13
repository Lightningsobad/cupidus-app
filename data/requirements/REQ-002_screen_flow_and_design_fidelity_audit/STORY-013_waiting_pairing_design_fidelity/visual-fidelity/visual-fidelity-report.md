# Visual Fidelity Report: STORY-013 Waiting (Đợi Ghép) Screen

Story: STORY-013 Design Fidelity — Waiting For Pairing
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Lane: mobile
Configuration audited: dark theme + `vi` locale (the only combination enabled
for users; OQ5 keeps light/`en` visual QA out of scope)

## Design Source Of Truth

- File: `cupid-app-design-system/project/Cupid Screens.dc.html`
- Block: `<sc-if value="{{ isWaiting }}">`, lines 1572-1589
- Shared keyframes: line 29 (`pulseRing`), line 31 (`bob`)
- Dark palette variables: line 26 (`--bg`, `--surf`, `--line`, `--tx`, `--tx2`)
- Brand palette variables: line 23 (`--pink`, `--purple`)
- Screen chrome classification: line 1951/1952 confirm `waiting` is in both
  `NO_CHROME` and `NO_TABS`, matching the implementation (no header, no tab
  bar). No deviation.

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

## Deviations Found And NOT Fixed (out of this story's write scope)

### O1 — "Mã của bạn" code card is absent

- Design source (1581-1584): a `--surf` card (`padding:14px 26px`,
  `border-radius:20px`, `box-shadow:var(--shadow)`) holding an `11px` `--tx2`
  label and the pairing code in Roboto Mono `500` at `26px`,
  `letter-spacing:.14em`, painted with the `--grad-hot` gradient.
- Why not fixed here: `WaitingScreen` receives only `expiresAt`. The pairing
  code lives in `InviteScreen`'s `InviteReady.invitation.code`
  (`mobile/lib/features/pairing/presentation/screens/invite_screen.dart:102`,
  where `WaitingScreen` is constructed). Rendering the card requires threading
  `invitation.code` into the `WaitingScreen` constructor, and
  `invite_screen.dart` is outside this story's declared `WriteScope`. Adding
  an optional, never-populated parameter would ship dead UI instead.
- Recommended follow-up: a one-line change at `invite_screen.dart:102` passing
  `code: invitation.code` alongside a new required constructor parameter, plus
  the card widget in `waiting_screen.dart`. Both files must be in the same
  story's write scope.

### O2 — "Gửi lại" (share again) primary CTA is absent

- Design source (1586): the row's first button — `--grad-hot` fill, white
  text, `ios_share` icon at `19px`, `14.5px`/`w800`, `box-shadow:var(--glow)`.
- Why not fixed here: it is a share action over the pairing code, so it
  depends on the same code plumbing as O1 and on `InviteScreen`'s existing
  clipboard-share behavior. Out of write scope and out of this story's "no new
  interaction" boundary.
- Recommended follow-up: deliver together with O1.

### O3 — "Giả lập: Linh vào" (Simulate join) button is intentionally not built

- Design source (1587) wires this to `goPaired` purely so the prototype can
  jump screens. It is a mockup navigation aid, not product behavior, and the
  real app reaches `paired` through `WaitingCubit`'s poll. Not a deviation to
  fix; recorded so a later reviewer does not read its absence as a gap.

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
- Background: the design root (line 44) layers `var(--sky)` over `var(--bg)`.
  `CupidColorTokens.skyGradient` is currently a documentation-only `String`
  token that no screen renders, so this is app-shell scope shared by every
  screen, not a `waiting`-specific deviation. Left unchanged and not counted
  against this story.
- Copy: the source hardcodes the partner name ("Đang đợi Linh vào…"). The app
  has no partner name while waiting, so the existing spec-derived status copy
  ("Đang chờ người ấy…") is retained; only its typography was corrected. The
  timed-out and paired status variants are existing app states with no
  counterpart in the static mockup and were left as-is.

## Verification Evidence

All commands run in the story worktree
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-013/mobile`
with `flutter` on PATH from `$HOME/flutter/bin`.

1. `flutter gen-l10n` — regenerated `lib/l10n/generated/app_l10n.dart`, which
   is gitignored and was absent in the fresh worktree. Without it the whole
   project fails to analyze (pre-existing condition, unrelated to this story).
2. `flutter analyze lib/features/pairing/presentation/screens/waiting_screen.dart`
   — 1 issue: `prefer_initializing_formals` (info) at line 25, on the
   pre-existing `_createWaitingCubit` constructor seam this story did not
   touch. The same lint fires repo-wide on the identical pattern. No errors,
   no warnings from the changed code.
3. `dart format lib/features/pairing/presentation/screens/waiting_screen.dart`
   — formatted, no manual style drift.
4. `flutter test test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart`
   — 3/3 passed (new file).
5. `flutter test test/features/pairing test/design_system/no_fork_guard_test.dart`
   — 73/73 passed, including the four pre-existing `waiting_screen_test.dart`
   behavior tests (status text, poll-to-paired transition, timeout fallback,
   manual refresh) and the AC 4 no-fork guard that forbids raw color literals
   in `lib/features`.

New test file:
`mobile/test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart`
asserts, in dark theme + `vi` locale: the `150x150` field and `46px` pink
hourglass exist; the ring actually advances through the `pulseRing` scale ramp
between frames and no `CircularProgressIndicator` is present (AC 3); the title
is Nunito `w900` `24`/`1.25` in `colorText`; the subtitle is `13`/`1.6` in
`colorTextMuted`; and the refresh action is `50` tall with a `1.5px`
`colorLine` border and `14.5`/`w700` text rather than Material defaults.

## Acceptance Criteria Status

- AC 1 (layout, spacing, color/token, typography match): MET for every element
  the screen renders. The two source elements the screen does not render at
  all (O1, O2) are blocked by write scope, documented above with the exact
  follow-up.
- AC 2 (deviations corrected in the app, not just documented): MET — D1-D7 are
  code fixes in `waiting_screen.dart` and re-verified by tests 2-5.
- AC 3 (animation uses the source's own vocabulary): MET — `pulseRing` and
  `bob` reproduced from the source keyframes; the ad hoc scale/fade disc is
  gone.
- AC 4 (no new entry point): MET — no navigation, routing, or `WaitingCubit`
  polling code was touched; the screen is still reached only from
  `InviteScreen`'s existing push.
