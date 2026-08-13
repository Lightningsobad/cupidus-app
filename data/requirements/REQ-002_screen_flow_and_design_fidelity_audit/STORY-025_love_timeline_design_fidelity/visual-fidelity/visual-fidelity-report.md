# Visual Fidelity Report: STORY-025 Love Timeline

Story: STORY-025 Design Fidelity — Love Timeline
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Lane: mobile
Audited configuration: dark theme + `vi` locale
Verdict: FIXED — all deviations corrected in code and re-verified

## Design Source Of Truth

- `cupid-app-design-system/project/Cupid Screens.dc.html`, block
  `<sc-if value="{{ isTimeline }}">` (lines 691-722)
- Sample data establishing the per-entry accent sequence:
  `Cupid Screens.dc.html` lines 2269-2275
- Token values: `cupid-app-design-system/project/Cupid App.dc.html` lines
  28-31 (`--r-card`, `--r-sm`, `--r-btn`, `--shadow`, dark palette)
- `<image-slot>` empty-state treatment:
  `cupid-app-design-system/project/image-slot.js`

## Implementation Under Audit

- `mobile/lib/features/timeline/presentation/screens/timeline_screen.dart`
- `mobile/lib/features/timeline/presentation/widgets/timeline_entry_card.dart`
- `mobile/lib/features/timeline/presentation/widgets/timeline_countdown_card.dart` (new)
- `mobile/lib/features/timeline/presentation/widgets/timeline_dashed_border.dart` (new)
- `mobile/lib/features/timeline/presentation/widgets/timeline_strings.dart` (new)

## Deviations Found And Fixed

| # | Element | Design source | Was | Now |
|---|---------|---------------|-----|-----|
| 1 | Screen container | `padding:10px 16px 40px` | `EdgeInsets.all(16)` | `EdgeInsets.fromLTRB(16, 10, 16, 40)` |
| 2 | Countdown card | `padding:18px 20px`, `--r-card`, `1px solid var(--line)`, `linear-gradient(140deg, rgba(255,127,182,.2), rgba(183,140,245,.18))`, `gap:14` | absent | `TimelineCountdownCard` with the same box, border, and gradient from tokens |
| 3 | Countdown headline | Nunito 900 / 20px / `--tx` | absent | `type.display.copyWith(fontSize: 20)`, `colorText` |
| 4 | Countdown subtitle | 12.5px / `--tx2` / `margin-top:4` | absent | `type.caption.copyWith(fontSize: 12.5)`, `colorTextMuted`, gap 4 |
| 5 | Progress ring | 56x56 `conic-gradient(var(--pink) 82%, var(--surf2) 0)`, inner 44x44 `var(--bg)`, Nunito 900 / 13px | absent | `TimelineProgressRing` using `SweepGradient` + `GradientRotation(-pi/2)` |
| 6 | Connector rail | ONE absolute 2px line, `left:7`, `top:6`, `bottom:6`, `linear-gradient(180deg, --pink, --purple, transparent)` | one gradient segment repeated per row | single `Positioned` rail behind the whole entry column |
| 7 | Gutter | `padding-left:26` | `SizedBox(24)` + `SizedBox(8)` = 32 | `EdgeInsets.only(left: 26)` |
| 8 | Dot | 16x16, fill = per-entry `t.dot` accent, `3px solid var(--bg)` | fill `--surf`, 3px pink ring on every row | fill = per-entry accent, 3px `colorBackground` ring |
| 9 | Entry card padding | `15px 16px` | `EdgeInsets.all(16)` | `EdgeInsets.symmetric(horizontal: 16, vertical: 15)` |
| 10 | Entry card shadow | `box-shadow:var(--shadow)` | none | `platformTokens.elevationShadow` |
| 11 | Card header row | `align-items:center`, `gap:9` | `CrossAxisAlignment.start`, gap 8 | center alignment, gap 9 |
| 12 | Entry icon colour | per-entry `t.iconColor` (pink, mint, peach, butter, purple) | always pink | index-cycled accent list |
| 13 | Entry icon glyphs | design rows use `savings` and `draw` | not in `TimelineGlyphs`, silently fell back | added `savings 0xe2eb`, `draw 0xe746`, `image 0xe3f4` |
| 14 | Entry date format | `18/01/26` | `DateFormat.yMMMd()` -> `Jan 18, 2026` | `DateFormat('dd/MM/yy')` |
| 15 | Body spacing | `margin-top:7` | 4 | 7 |
| 16 | Photo spacing | `margin-top:11` | 8 | 11 |
| 17 | Photo placeholder | `<image-slot>`: rounded 16 frame, neutral fill, `1.5px dashed currentColor @ .35`, 28px image glyph `@ .45`, 13px/500 caption `@ .75` = "Ảnh kỷ niệm" | bare `broken_image` glyph on `--surf2`, no ring, no caption | `TimelinePhotoPlaceholder` reproducing the full image-slot empty state (AC 4) |
| 18 | Auto-added pill | `margin-top:10`, `padding:4px 9px`, `--r-btn`, `--surf2`, 10px `--tx2`, `gap:5`, leading `auto_awesome` at 12px | `margin-top:8`, `padding:8/4`, 13px, no icon | exact design box + 12px `auto_awesome` icon + 5px gap + 10px text |
| 19 | Add-memory pill border | `1.5px dashed var(--line)` | dashed `--pink` | dashed `colorLine` |
| 20 | Add-memory label | 15px / weight 800, `gap:8`, icon 20px `--pink` | 17px / weight 600, gap 4 | 15px / w800, gap 8 |

## Accepted Deviations

- **Entry date font size 12 instead of the design's 9.5px.** Pre-existing
  documented accessibility override (11pt minimum), kept unchanged and
  re-confirmed in this pass. Comment retained at
  `timeline_entry_card.dart` (leading-row date `Text`).
- **Photo placeholder fill uses `colorSurfaceAlt` instead of the literal
  `rgba(127,127,127,.08)`.** `test/design_system/no_fork_guard_test.dart`
  forbids raw colour literals in `lib/features`, and the design system has no
  neutral-grey-overlay token. `colorSurfaceAlt` (`#2E2456` dark) is the
  design's own placeholder-surface token and is the closest token-faithful
  match; the dashed ring, glyph, and caption opacities are transcribed exactly
  from `image-slot.js` off `colorText`.

## Notes On Non-Obvious Mappings

- **Countdown data has no backend field.** The API exposes no
  relationship-start or milestone value, so `TimelineCountdown.forEntries`
  anchors day 1 on the earliest entry and targets the next 100-day multiple.
  Replaying the design's own sample data (earliest entry `Ký Love Contract`
  25/11/2025, "today" 29/07/2026) reproduces the design's exact numbers:
  247 days together, milestone 300, 53 days remaining, 82%, 20/09/2026. This
  is asserted as a unit test rather than assumed. No backend change was
  needed, so the stop rule did not trigger.
- **Rail gradient terminator.** CSS `transparent` fades in premultiplied
  space; Flutter's `Color.lerp` uses straight alpha, so a literal transparent
  stop would fade through black. Used `colorAccentPurple.withValues(alpha: 0)`
  to reproduce the browser result.
- **140deg gradient mapping.** Followed the repo's existing 120deg token
  convention `begin = (-sin, cos)`, `end = (sin, -cos)`, giving
  `Alignment(-0.6427876096865393, -0.766044443118978)` ->
  `Alignment(0.6427876096865393, 0.766044443118978)`.
- **Dot/rail centring.** The design source has no global `box-sizing` reset,
  but only the border-box reading puts the dot centre (8) on the rail centre
  (8). Flutter's `Border.all` inside a fixed-size `Container` is border-box
  natively, so this needed no compensation.

## Shared Design-System Impact

None. No file under `mobile/lib/design_system/` was created, modified, or
forked. No new token was required — every value above resolves through
existing `CupidColorTokens` / `CupidTypographyTokens` / `CupidPlatformTokens`
members. `test/design_system/no_fork_guard_test.dart` passes.

New copy ("Còn N ngày", "tới mốc N ngày · date", "Ảnh kỷ niệm") lives in
`mobile/lib/features/timeline/presentation/widgets/timeline_strings.dart`
using the feature-local `viEn`-style locale helper, because
`mobile/lib/l10n/**` is outside this story's write scope — the same precedent
as `expense_strings.dart` / `auth_strings.dart` / `chat_strings.dart`.

## Verification

SDK: Flutter 3.44.1 (stable), Dart 3.12.1.
All commands run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-025/mobile`.

| Command | Result |
|---------|--------|
| `flutter analyze lib/features/timeline test/features/timeline` | No issues found (0 errors, 0 warnings, 0 infos) |
| `flutter test test/features/timeline/presentation/timeline_design_fidelity_test.dart` | +8, All tests passed |
| `flutter test test/design_system test/features/timeline` | +106, All tests passed |
| `dart format` on the 6 changed Dart files | 2 reformatted, re-verified clean by the analyze/test runs above |

Regression slice detail for `flutter test test/design_system test/features/timeline`:
106 tests passed, 0 failed, 0 skipped. This includes the 12 pre-existing
`timeline_screen_test.dart` cases (unchanged and still green after the layout
rewrite) and `no_fork_guard_test.dart`.

Note: `flutter gen-l10n` must be run once in a fresh worktree before
analyze/test, because `lib/l10n/generated/` is generated output and not
committed.

## New Test Coverage

`mobile/test/features/timeline/presentation/timeline_design_fidelity_test.dart`
(dark theme + `vi` locale harness):

1. `TimelineCountdown` derives the design source countdown from the earliest
   entry (247 / 300 / 53 / 82% / 20-09-2026)
2. `TimelineCountdown` returns null for an empty timeline
3. countdown card renders the `vi` headline, subtitle, and progress ring
4. entry cards cycle the design source per-entry accent (pink, mint, peach,
   butter, purple) at 18px
5. entry card matches the design card box (padding 16/15, `--surf`,
   `--shadow`) and the `dd/MM/yy` date format
6. scroll padding matches the design container box (`10px 16px 40px`)
7. an unreachable photo renders the `<image-slot>` placeholder including the
   "Ảnh kỷ niệm" caption (AC 4)
8. the add-memory pill uses the design `--line` dashed border

## Acceptance Criteria Coverage

- AC 1 — layout/spacing/colour/typography match: deviations 1-20 fixed;
  covered by tests 3-8.
- AC 2 — corrected in the app, not merely documented: all fixes are code
  changes; re-verified by analyze + 106 passing tests.
- AC 3 — countdown and progress ring: deviations 2-5; covered by tests 1-3.
- AC 4 — `<image-slot>` placeholder treatment, no real upload behavior:
  deviation 17; covered by test 7. No upload path was added.
- AC 5 — no new entry point: navigation into the screen is unchanged;
  `TimelineScreen`'s constructor and its `HomeScreen` call site are untouched.
