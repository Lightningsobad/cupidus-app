# Review Report: STORY-025 Design Fidelity — Love Timeline

Reviewer: Iris-QC
Mode: compact-story-review
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Story: STORY-025 (`love_timeline_design_fidelity`)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-025`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
Reviewed commit: `6e8e9ababa8c0ea3b201fea13ca83ae7f25535cf`
Round: 1

## Outcome

Outcome: PATCH_REQUIRED

The visual transcription is accurate and unusually thorough — every one of the
20 claimed deviation fixes was re-checked against `Cupid Screens.dc.html`
L691-722 and holds. The story is blocked by one non-visual defect it
introduced: the new countdown card displays a relationship duration derived
from an invented anchor while the app already models the real
`relationshipStartDate`, so the screen will show a factually wrong number for
most couples. See B-1.

## Scope reviewed

`git -C <worktree> diff 8396273 HEAD`, 8 files, +999 / -159:

- `mobile/lib/features/timeline/presentation/screens/timeline_screen.dart`
- `mobile/lib/features/timeline/presentation/widgets/timeline_entry_card.dart`
- `mobile/lib/features/timeline/presentation/widgets/timeline_countdown_card.dart` (new)
- `mobile/lib/features/timeline/presentation/widgets/timeline_dashed_border.dart` (new)
- `mobile/lib/features/timeline/presentation/widgets/timeline_strings.dart` (new)
- `mobile/test/features/timeline/presentation/timeline_design_fidelity_test.dart` (new)
- `.../STORY-025_love_timeline_design_fidelity/visual-fidelity/visual-fidelity-report.md` (new)
- `.../STORY-025_love_timeline_design_fidelity/story_master.md` (artifact checkbox)

Every changed path falls inside the mobile-dev run's declared WriteScope
(`data/runtime/parallel-runs/RUN-REQ-002_screen_flow_and_design_fidelity_audit-STORY-025-mobile-dev.json`).
No out-of-scope write occurred; `mobile/lib/design_system/**` is untouched.

## Design-source cross-check

Authoritative sources re-read independently by the reviewer, not taken from the
implementer's report:

- `cupid-app-design-system/project/Cupid Screens.dc.html` L691-722 (`isTimeline`)
- `cupid-app-design-system/project/Cupid Screens.dc.html` L2269-2275 (sample rows)
- `cupid-app-design-system/project/Cupid App.dc.html` L27-30 (tokens, dark)
- `cupid-app-design-system/project/image-slot.js` L291-295, L324-337 (empty state)

| Area | Design source | Implementation | Verdict |
|---|---|---|---|
| Screen container | `padding:10px 16px 40px` (L692) | `ListView(padding: EdgeInsets.fromLTRB(16, 10, 16, 40))` | match |
| Countdown box | `padding:18px 20px`, `--r-card`, `1px solid var(--line)` (L693) | `EdgeInsets.symmetric(h:20, v:18)`, `radiusCard`, `Border.all(colorLine)` | match |
| Countdown gradient | `linear-gradient(140deg,rgba(255,127,182,.2),rgba(183,140,245,.18))` | `colorAccentPink@.2 -> colorAccentPurple@.18`, alignments `(∓0.6428, ∓0.7660)` | match — `sin140=0.6428`, `cos140=-0.7660` under the repo's existing 120deg convention |
| Countdown layout | `align-items:center;gap:14` | `Row` (default center) + `SizedBox(width: 14)` | match |
| Headline | Nunito 900 / 20px / inherited `--tx` (L694) | `type.display.copyWith(fontSize: 20)` + `colorText`; `display` is Nunito w900 with no baked `height` | match |
| Subtitle | 12.5px / `--tx2` / `margin-top:4` | `type.caption.copyWith(fontSize: 12.5)`, `colorTextMuted`, `SizedBox(4)` | match |
| Progress ring | 56x56 `conic-gradient(--pink 82%, --surf2 0)`, inner 44x44 `--bg`, Nunito 900 / 13px (L695) | `SweepGradient` stops `[0, f, f, 1]` with `GradientRotation(-pi/2)`, `colorAccentPink`/`colorSurfaceAlt`, inner `colorBackground`, `type.display` @13 | match — the `-pi/2` rotation is required, CSS conic starts at 12 o'clock and `SweepGradient` at 3 |
| Rail | ONE absolute `left:7;top:6;bottom:6;width:2` line, `linear-gradient(180deg,--pink,--purple,transparent)` (L699) | single `Positioned` behind the whole entry column, same insets, third stop `colorAccentPurple@0` | match — the premultiplied-vs-straight-alpha note is correct; a literal transparent stop would fade through black |
| Gutter | `padding-left:26` (L698) | `EdgeInsets.only(left: 26)` | match |
| Dot | 16x16, per-row `t.dot`, `3px solid var(--bg)`, `left:-26;top:16` (L702) | 16x16 `Container`, `accents[i%5]`, `Border.all(colorBackground, 3)`, `Positioned(left:-26, top:16)` | match — border-box centring puts dot centre at x=8 on the rail centre x=8 |
| Accent sequence | pink, mint, peach, butter, purple (L2270-2274) | `[colorAccentPink, colorMint, colorPeach, colorButter, colorAccentPurple]` | match |
| Entry card box | `padding:15px 16px`, `--r-card`, `--surf`, `box-shadow:var(--shadow)` (L703) | `EdgeInsets.symmetric(h:16, v:15)`, `radiusCard`, `colorSurface`, `platformTokens.elevationShadow` | match |
| Card header row | `align-items:center;gap:9` (L704) | `Row` default center, `SizedBox(9)` on both sides of the title | match |
| Leading icon | 18px, per-row `t.iconColor` (L705) | `CupidIcon(size: 18, color: accent)` | match |
| Title | 14.5px / weight 800 / inherited `--tx` (L706) | `type.body.copyWith(fontSize: 14.5, w800, colorText)` | match |
| Date format | `18/01/26` (L2270) | `DateFormat('dd/MM/yy')` | match |
| Glyphs | rows use `celebration`, `savings`, `favorite`, `pets`, `draw` | `savings 0xe2eb`, `draw 0xe746`, `image 0xe3f4` added to `TimelineGlyphs` | match — previously `savings`/`draw` fell through to the per-type fallback |
| Body text | 12.5px / `--tx2` / `margin-top:7` / `line-height:1.5` (L709) | `type.caption.copyWith(fontSize: 12.5, height: 1.5)`, `colorTextMuted`, `SizedBox(7)` | match |
| Photo frame | `margin-top:11;height:112;border-radius:var(--r-sm)` (L711) | `SizedBox(11)`, `_photoHeight = 112`, `ClipRRect(radiusSmall)`; `radiusSmall = 16 = --r-sm` | match |
| Photo placeholder | `image-slot`: `.ring` `1.5px dashed currentColor` @`.35`, `.empty svg` 28px @`.45`, `.empty .cap` 13px/w500 @`.75`, `gap:6`, caption "Ảnh kỷ niệm" | `TimelineDashedBorder` 1.5px @`colorText.35`, 28px `image` glyph @`.45`, 13px/w500 @`.75`, `SizedBox(6)`, `Ảnh kỷ niệm` | match on every transcribed value; fill deviation noted as M-1 |
| Auto-added pill | `margin-top:10`, `padding:4px 9px`, `999px`, `--surf2`, 10px `--tx2`, `gap:5`, leading `auto_awesome` @12px (L714) | `SizedBox(10)`, `EdgeInsets.symmetric(h:9, v:4)`, `radiusButton (999)`, `colorSurfaceAlt`, `fontSize: 10`, `SizedBox(5)`, 12px glyph, `Align.centerLeft` for `inline-flex` | match |
| Add-memory pill | `height:52`, `--r-btn`, `1.5px dashed var(--line)`, `gap:8`, 15px/w800 `--pink`, `add_circle` @20px (L720) | `SizedBox(height: 52)`, `radiusButton`, `TimelineDashedBorder(colorLine)`, `SizedBox(8)`, 15/w800 `colorAccentPink`, 20px glyph | match |
| Rail-to-list gap | `margin-top:18` on the entries container (L698) | `SizedBox(height: 18)` after the countdown card | match |
| List-to-CTA gap | last row's `margin-bottom:16`, no `margin-top` on the CTA | trailing `EdgeInsets.only(bottom: 16)` on the last row, CTA follows with no spacer | match |

Dark tokens verified directly in
`mobile/lib/design_system/tokens/cupid_color_tokens.dart`: `colorBackground
= 0xFF171129` (`--bg`), `colorSurface = 0xFF241B42` (`--surf`),
`colorSurfaceAlt = 0xFF2E2456` (`--surf2`), `colorLine =
rgba(247,238,251,.11)` (`--line`), `colorText = 0xFFF7EEFB` (`--tx`),
`colorTextMuted = 0xFFB4A6CE` (`--tx2`), plus pink/mint/peach/butter/purple —
all exact. `radiusCard` 26/24, `radiusSmall` 16, `radiusButton` 999 match
`--r-card`/`--r-sm`/`--r-btn`. No raw colour literal was introduced.

New `vi`/`en` copy in `timeline_strings.dart` reproduces the design strings
verbatim, including the `en` "until the 300-day mark · 20 Sep 2026" form via
`DateFormat('d MMM yyyy')`.

## Blocking findings

### B-1 — the countdown displays a relationship duration derived from the wrong anchor, and the stated justification is false

`mobile/lib/features/timeline/presentation/widgets/timeline_countdown_card.dart:34-67`
anchors day 1 on the **earliest timeline entry**:

```dart
DateTime start = entries.first.createdAt.toLocal();
for (final TimelineEntry entry in entries) {
  final DateTime candidate = entry.createdAt.toLocal();
  if (candidate.isBefore(start)) start = candidate;
}
```

`visual-fidelity/visual-fidelity-report.md` L69-71 justifies this with "The API
exposes no relationship-start or milestone value". That claim is incorrect. The
field exists and is already modelled end to end:

- `backend/src/modules/users/entities/user.entity.ts:24` — `relationshipStartDate: Date`
- `backend/src/modules/users/dto/update-profile.dto.ts:25` — user-editable
- `mobile/lib/features/account/domain/cupid_profile.dart:47` — `final DateTime? relationshipStartDate;`, parsed from `GET /users/me` at `cupid_profile.dart:32`
- `mobile/lib/core/di/service_locator.dart:96` — `AccountRepository` is a registered lazy singleton exposing `fetchProfile()`

Consequences of the invented anchor:

1. **Wrong number for the normal case.** Timeline entries are memories created
   after pairing, so the earliest entry is later than the relationship start for
   virtually every real couple. The card then under-reports "days together" and
   asserts a wrong milestone, date and percentage — e.g. a couple 400 days in
   whose first memory is 30 days old sees "Còn 70 ngày tới mốc 100 ngày"
   instead of counting toward 500. This is user-visible misinformation on a
   shipped screen, newly introduced by this diff.
2. **The value mutates retroactively.** Adding one older memory re-anchors day
   1, so the headline, milestone, percentage and ring all jump. `CreateMemorySheet`
   is reachable from this very screen, so the jump is one interaction away.
3. **The wrong behaviour is now pinned by a test.**
   `mobile/test/features/timeline/presentation/timeline_design_fidelity_test.dart:107-127`
   asserts the earliest-entry anchor as "the design source countdown". The
   247/300/53/82%/20-09-2026 replay is arithmetically correct, but it only
   matches the design because the mock's earliest row *is* the relationship
   start ("Ký Love Contract … Ngày thứ 1", L2274) — a coincidence of the sample
   data, not a rule.

This is fixable inside the declared WriteScope: `timeline_screen.dart` is
writable and already resolves `getIt<TimelineRepository>()` lazily at the call
site, so `getIt<AccountRepository>()` can be reached the same way without
touching `timeline_cubit.dart` or `mobile/lib/l10n/**`.

Required patch (implementer's choice of shape):

- Drive `TimelineCountdown` from `CupidProfile.relationshipStartDate` when it is
  available, and
- when it is `null`, either suppress the countdown card or make the fallback
  explicit rather than presenting a derived guess as fact; do not silently
  substitute the earliest entry, and
- correct the false "API exposes no relationship-start field" claim in
  `visual-fidelity-report.md`, and
- retarget the unit test so it pins the profile-backed anchor.

Nothing else in the story needs rework. Every visual assertion above stands
independently of B-1.

## Deferred findings (out of this story's reach, carried forward)

| Id | Gap | Detail | Owner |
|---|---|---|---|
| D-1 | App-shell `--sky` gradient + star-particle background is not painted behind this screen | `CupidColorTokens.skyGradient` is declared as a documentation-only Dart `String` (`cupid_color_tokens.dart:200-209`), explicitly deferring the rendering decision to "the story that first paints this decoration". `TimelineScreen`'s `Scaffold` therefore renders on the flat theme background, not `--sky`. Cross-screen requirement-level gap, independently confirmed here | consolidated STORY-032 — do not patch per-screen |

## Minor findings (non-blocking)

- **M-1 — photo placeholder fill is a near-match, not exact.** `image-slot.js:295`
  specifies `.frame{background:rgba(127,127,127,.08)}`, which over `--surf`
  (#241B42) composites to ≈#2B2347. The implementation uses `colorSurfaceAlt`
  (#2E2456), off by ≈15 on blue. The deviation is correctly recorded and the
  reasoning is sound: `test/design_system/no_fork_guard_test.dart` forbids raw
  colour literals in `lib/features` and no neutral-grey-overlay token exists.
  Upheld as an accepted deviation.
- **M-2 — dash pattern is invented.** `_DashedBorderPainter._dashPattern = [6, 4]`
  (`timeline_dashed_border.dart:36`). CSS `dashed` is UA-defined; Chrome renders
  a 1.5px dashed border at roughly 4.5px dash / 3px gap. Visually similar,
  measurably different. No design token exists to pin it.
- **M-3 — dashed stroke straddles the box edge.** The painter strokes the RRect
  at `Offset.zero & size`, so 0.75px of the 1.5px line falls outside the box,
  where a CSS border is drawn inside it. Sub-pixel; inside `ClipRRect` for the
  photo placeholder the outer half is clipped.
- **M-4 — cross-story inconsistency on the 9.5px floor (not this story's defect).**
  The entry date holds at 12px against the design's 9.5px, citing an 11pt
  accessibility minimum. The diff confirms both the size and the justifying
  comment are pre-existing at BaseHead and were correctly left alone. However,
  STORY-028 in this same wave shipped its 9.5px `labelMono` weekday labels
  verbatim and its review recorded that as a match. One of the two readings of
  the floor is wrong. Flag for requirement integration review; it should not be
  resolved unilaterally inside either story.
- **M-5 — countdown copy bypasses the ARB pipeline.** "Còn N ngày", "tới mốc N
  ngày · date" and "Ảnh kỷ niệm" live in a feature-local `viEn` helper because
  `mobile/lib/l10n/**` is outside WriteScope. This follows the existing
  `expense_strings.dart` / `auth_strings.dart` / `chat_strings.dart` precedent
  and was the right call here, but the debt is now four features deep and wants
  a consolidation story.
- **M-6 — `milestoneDate` day arithmetic is not DST-safe.** `daysTogether` is
  computed in UTC (correct), but `milestoneDate` uses local
  `DateTime(...).add(Duration(days: n))` (`timeline_countdown_card.dart:61-65`),
  which can shift by an hour across a DST transition and, at a midnight-adjacent
  start time, by a day. Latent only for the `vi` market (Vietnam has no DST).
- **M-7 — the countdown never refreshes while mounted.** `_ReadyView` calls
  `TimelineCountdown.forEntries(entries, now: DateTime.now())` inside `build`
  (`timeline_screen.dart:137-140`), so a day rollover on a screen left open
  shows a stale count until the next rebuild. Cosmetic.

## Judgement calls checked and upheld

- One continuous rail behind the whole column instead of a per-row gradient
  segment. The design has exactly one absolutely-positioned line (L699); the
  previous per-row repeat was the actual deviation.
- `colorAccentPurple.withValues(alpha: 0)` as the rail's terminal stop instead
  of a literal transparent. CSS interpolates in premultiplied space, Flutter's
  `Color.lerp` in straight alpha, so a transparent stop would fade through
  black. Correct reasoning, correct fix.
- `GradientRotation(-math.pi / 2)` on the ring's `SweepGradient`. Required, and
  the four-stop `[0, f, f, 1]` form reproduces the conic hard edge.
- `Align(centerLeft)` for the auto-added pill's `display:inline-flex`, so the
  pill hugs its content rather than filling the card width.
- The `<image-slot>` empty state transcribed as real app UI rather than dropped
  as authoring-tool chrome. The design source sets `placeholder="Ảnh kỷ niệm"`
  (app copy, not the component default "Drop an image") and AC4 names the
  treatment explicitly, so treating it as intended UI is right.
- Placeholder reused for `loadingBuilder` as well as `errorBuilder`, replacing a
  bare `broken_image` glyph. Strictly better than the previous state and
  consistent with the slot's own empty rendering.
- `maxLines: 2` + ellipsis on the title retained from BaseHead. The design has
  no clamp, but removing it would risk unbounded row growth; unchanged by this
  story either way.

## Verification reproduced by the reviewer

Independently re-run at the reviewed commit, not taken on the implementer's
word. SDK confirmed Flutter 3.44.1 stable / Dart 3.12.1.

| Command | Reviewer result | Report claim | Match |
|---|---|---|---|
| `flutter gen-l10n` | succeeded (required in a fresh worktree, as the report notes) | same note | yes |
| `flutter analyze lib/features/timeline test/features/timeline` | `No issues found!` (2.9s) | No issues found | yes |
| `flutter test test/design_system test/features/timeline` | `00:03 +106: All tests passed!` | +106, all passed | yes |

The new fidelity assertions are substantive rather than tautological: they pin
the ListView padding box, the card padding/surface/shadow triple, the five-step
accent cycle at 18px, the `dd/MM/yy` format, the `--line` dashed CTA border, and
the placeholder caption behind an unreachable photo URL. The pre-existing
12 `timeline_screen_test.dart` cases are still green after the layout rewrite.

## Acceptance criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC1 — layout / spacing / colour-token / typography match in dark + `vi` | MET with deferral D-1 | Cross-check table above; every measurement traced to `Cupid Screens.dc.html` L691-722 and `Cupid App.dc.html` L27-30 |
| AC2 — deviations corrected in the app, not merely documented | MET | All 20 deviations landed as code across 5 Dart files; the report is evidence, not the deliverable |
| AC3 — countdown and progress ring visual treatment | NOT MET | The ring and the card's box, gradient, type and spacing all match exactly, but the countdown's *numerals* — the headline, milestone, date and percentage the AC names — are derived from a wrong anchor (B-1) |
| AC4 — `<image-slot>` placeholder treatment, no real upload behaviour | MET | Every `image-slot.js` value transcribed correctly (M-1 is the single near-match); no upload path added |
| AC5 — no new entry point | MET | No routing file in the diff; `TimelineScreen`'s constructor and its `HomeScreen` call site are unchanged |

## Residual risks

- No on-device, emulator or rendered-PNG capture backs this review; the fidelity
  evidence is source-to-source plus widget tests, consistent with every other
  per-screen review in this REQ-002 wave. The conic-ring seam, the dashed
  pattern (M-2) and the rail gradient terminator are the three items most likely
  to differ from the browser once actually rendered.
- Light theme and `en` locale received no dedicated visual pass, per the story's
  Out of Scope and OQ5. All new values resolve through shared tokens and
  `theme_matrix_test.dart` / `contrast_test.dart` are green, so the risk is low
  but not zero. Note that the placeholder's `colorText @ .35/.45/.75` and the
  ring's `colorSurfaceAlt` track are untested for light-theme contrast.

REVIEW_COMPLETE: YES
