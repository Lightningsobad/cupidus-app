# Visual Fidelity Report: STORY-025 Love Timeline

Story: STORY-025 Design Fidelity — Love Timeline
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Lane: mobile
Audited configuration: dark theme + `vi` locale
Round: 2 (round 1 was PATCH_REQUIRED on review finding B-1)
Verdict: FIXED — all deviations corrected in code and re-verified, and the
round-1 countdown anchor defect corrected (see "Notes On Non-Obvious Mappings")

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

- **Countdown anchor comes from the profile, not from the entries.** Round 1 of
  this report claimed "the API exposes no relationship-start or milestone
  value" and anchored day 1 on the earliest timeline entry. That claim was
  **wrong**, and review finding B-1 rejected it. The field exists and is
  modelled end to end: `backend/src/modules/users/entities/user.entity.ts:23`
  (`@Column({ type: 'date' }) relationshipStartDate`),
  `backend/src/modules/users/dto/update-profile.dto.ts:25`,
  `mobile/lib/features/account/domain/cupid_profile.dart:47`, reachable through
  `AccountRepository.fetchProfile()` (`GET /users/me`), registered at
  `mobile/lib/core/di/service_locator.dart:96`.

  The earliest-entry anchor only matched the design because the sample data's
  first row *is* the relationship start ("Ký Love Contract … Ngày thứ 1",
  `Cupid Screens.dc.html` L2274). For a real couple it under-reports "days
  together" and asserts a wrong milestone, date and percentage, and it
  re-anchors retroactively as soon as an older memory is added through
  `CreateMemorySheet`.

  Now: `TimelineCountdown.since(relationshipStartDate, now:)` takes the profile
  date, and `TimelineScreen` reaches `AccountRepository` through an optional
  constructor parameter defaulting to the composition-root singleton — the same
  shape as its existing `TimelineRepository` parameter. Milestone logic (next
  100-day multiple) is unchanged. Replaying the design's own numbers from the
  profile anchor 25/11/2025 with "today" 29/07/2026 still yields 247 days
  together, milestone 300, 53 remaining, 82%, 20/09/2026; that is asserted as a
  unit test. No backend change was needed, so the stop rule did not trigger.
- **No invented fallback when the anchor is missing.** When
  `relationshipStartDate` is `null` (or the profile fetch fails), the countdown
  card is not rendered at all. Substituting a derived guess would present the
  same misinformation B-1 rejected, so absence is shown as absence.
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
| `flutter test test/features/timeline/presentation/timeline_design_fidelity_test.dart` | +9, All tests passed |
| `flutter test test/design_system test/features/timeline` | +107, All tests passed |
| `flutter test test/features/home test/widget_test.dart test/app` | +11, All tests passed |

Not run: `dart format`. The Dart 3.12.1 formatter rewrites 9 pre-existing
timeline files this story never touches (`timeline_repository.dart`,
`timeline_cubit_test.dart`, and 7 others), so this package is not maintained at
that formatter version and running it would bury the B-1 fix in ~600 lines of
unrelated churn. The changed and added files are hand-matched to the
surrounding style instead. Repo-wide reformatting belongs in its own story.

Regression slice detail for `flutter test test/design_system test/features/timeline`:
107 tests passed, 0 failed, 0 skipped. This includes the 12 pre-existing
`timeline_screen_test.dart` cases (still green; their harness now injects a
`StubAccountRepository` with no relationship start date, so those state-surface
cases render without the countdown hero) and `no_fork_guard_test.dart`.

The `test/features/home` / `widget_test.dart` / `test/app` slice was added in
round 2 to confirm that `HomeScreen`'s unchanged `TimelineScreen(createCubit:
...)` call site still works with the new optional `accountRepository`
parameter.

Note: `flutter gen-l10n` must be run once in a fresh worktree before
analyze/test, because `lib/l10n/generated/` is generated output and not
committed.

## New Test Coverage

`mobile/test/features/timeline/presentation/timeline_design_fidelity_test.dart`
(dark theme + `vi` locale harness):

1. `TimelineCountdown` derives the design source countdown from the
   relationship start date (247 / 300 / 53 / 82% / 20-09-2026)
2. `TimelineCountdown` counts the start day itself as day one
3. countdown card renders the `vi` headline, subtitle, and progress ring from
   the profile anchor while the only timeline entry is 12 days old — this is
   the B-1 regression test: an entries-derived anchor cannot produce 247 days
4. no countdown is rendered when the profile has no relationship start date
5. entry cards cycle the design source per-entry accent (pink, mint, peach,
   butter, purple) at 18px
6. entry card matches the design card box (padding 16/15, `--surf`,
   `--shadow`) and the `dd/MM/yy` date format
7. scroll padding matches the design container box (`10px 16px 40px`)
8. an unreachable photo renders the `<image-slot>` placeholder including the
   "Ảnh kỷ niệm" caption (AC 4)
9. the add-memory pill uses the design `--line` dashed border

Supporting fixture:
`mobile/test/features/timeline/presentation/stub_account_repository.dart` — an
`AccountRepository` subclass answering `fetchProfile()` from memory, following
the `_StubTimelineCubit` "cheap-but-real, never-invoked dependency" pattern
already used in these files.

## Acceptance Criteria Coverage

- AC 1 — layout/spacing/colour/typography match: deviations 1-20 fixed;
  covered by tests 3-9.
- AC 2 — corrected in the app, not merely documented: all fixes are code
  changes; re-verified by analyze + 107 passing tests.
- AC 3 — countdown and progress ring: deviations 2-5; covered by tests 1-4.
  Round 2 additionally fixes the countdown's numerals, which round 1 derived
  from the wrong anchor (review finding B-1).
- AC 4 — `<image-slot>` placeholder treatment, no real upload behavior:
  deviation 17; covered by test 8. No upload path was added.
- AC 5 — no new entry point: navigation into the screen is unchanged.
  `TimelineScreen` gained an optional `accountRepository` parameter that
  defaults to the composition-root singleton, so its `HomeScreen` call site is
  untouched.

## Round 2 Fix Evidence

Against `review/review-report.md` (round 1, `Outcome: PATCH_REQUIRED`,
reviewed commit `6e8e9ab`, BaseHead `8396273`).

### B-1 (blocking) — countdown anchored on the earliest timeline entry

Reviewer verdict: `timeline_countdown_card.dart:34-67` scanned entries for the
earliest `createdAt` instead of using `CupidProfile.relationshipStartDate`,
producing a wrong day count, milestone, date and percentage for real couples
and re-anchoring retroactively when an older memory is added. AC 3 NOT MET.

| Change | File |
|--------|------|
| `TimelineCountdown.forEntries` replaced by `TimelineCountdown.since(relationshipStartDate, now:)`; UTC day arithmetic; `timeline_entry.dart` import dropped | `mobile/lib/features/timeline/presentation/widgets/timeline_countdown_card.dart` |
| Optional `accountRepository` parameter (defaults to the `getIt` singleton, mirroring the existing `repository` parameter); new `_CountdownSection` resolves the anchor via `AccountRepository.fetchProfile()` and renders nothing when it is absent | `mobile/lib/features/timeline/presentation/screens/timeline_screen.dart` |
| New in-memory `AccountRepository` stub so widget tests can pin the anchor | `mobile/test/features/timeline/presentation/stub_account_repository.dart` |
| Unit tests retargeted to the profile-backed anchor; countdown widget test now uses a 12-day-old entry against a 246-day-old anchor; added the null-anchor case | `mobile/test/features/timeline/presentation/timeline_design_fidelity_test.dart` |
| Harness injects a no-start-date stub so the 12 state-surface cases stay unchanged | `mobile/test/features/timeline/presentation/timeline_screen_test.dart` |
| False round-1 claim "the API exposes no relationship-start or milestone value" retracted and replaced with the real field chain | this report, "Notes On Non-Obvious Mappings" |

Null anchor is rendered as absence, not as a derived guess — see "No invented
fallback when the anchor is missing". Re-verified by the four command runs in
"Verification"; test 3 is the regression guard (an entries-derived anchor
cannot yield 247 days from a 12-day-old entry).

### Findings deliberately not touched

- D-1 (shared background gradient) — routed to consolidated STORY-032 by the
  reviewer; not patched here.
- M-1 … M-7 (minor, non-blocking) — left as recorded, including M-6 (DST in
  `milestoneDate`) and M-7 (no refresh while mounted). M-6 is unaffected by
  this patch: the day *count* now uses UTC arithmetic, while `milestoneDate` is
  deliberately kept local so it formats as a local calendar date.
- All 20 round-1 visual deviations were verified MET by the reviewer and are
  unchanged.

### Handoff discrepancy for Scrum Master

The run's declared `output_paths` was
`…/STORY-025_love_timeline_design_fidelity/visual-fidelity-report.md`, but this
report has lived at
`…/STORY-025_love_timeline_design_fidelity/visual-fidelity/visual-fidelity-report.md`
since round 1 (the path the reviewer read). The run state was corrected to the
real path rather than duplicating the artifact.
