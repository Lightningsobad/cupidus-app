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

---

# Round 2

Reviewer: Iris-QC
Mode: compact-story-review
BaseHead (round-2 diff baseline): `6e8e9ababa8c0ea3b201fea13ca83ae7f25535cf`
Reviewed commit: `f3eb936983863f36932a84ac11171a6d65018d7b`
("fix(REQ-002/STORY-025): round-2 fix — countdown numeral anchor (B-1)")
Round: 2

## Outcome

Outcome: DEFERRED_ONLY

B-1 is genuinely resolved, not papered over. The countdown now reads its day-one
anchor from `CupidProfile.relationshipStartDate` and renders nothing when that
anchor is absent, so the screen no longer presents a derived guess as fact. AC3
is now MET. AC1, AC2, AC4 and AC5 are not regressed — the round-2 diff does not
touch a single visual widget. The only finding carried past this gate is D-1,
which round 1 already routed to consolidated STORY-032 and which is outside this
story's reach.

For the DONE gate this is equivalent to CLEAN: no blocking finding remains and
no rework is owed by this story. The story is merge-eligible into
`codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`.

## Scope reviewed

`git -C <worktree> diff 6e8e9ab..f3eb936`, 7 files, +558 / -85. Five are code:

- `mobile/lib/features/timeline/presentation/screens/timeline_screen.dart` (+69 / -11)
- `mobile/lib/features/timeline/presentation/widgets/timeline_countdown_card.dart` (+16 / -20)
- `mobile/test/features/timeline/presentation/stub_account_repository.dart` (new, +28)
- `mobile/test/features/timeline/presentation/timeline_design_fidelity_test.dart` (+48 / -24)
- `mobile/test/features/timeline/presentation/timeline_screen_test.dart` (+6)

Plus this report (round-1 body) and `visual-fidelity/visual-fidelity-report.md`.
Working tree is clean at `f3eb936`. No design-system, l10n, routing, or backend
file is in the diff, so the patch stayed inside the declared WriteScope.

## B-1 verification — RESOLVED

Each of the four required patch elements from round 1 was checked against source,
not against the implementer's summary.

**1. The anchor is now the profile's `relationshipStartDate`.**
`TimelineCountdown.forEntries(List<TimelineEntry>)` is gone; the entry-scanning
loop and the `timeline_entry.dart` import are both deleted. The replacement is
`TimelineCountdown.since(DateTime relationshipStartDate, {required DateTime now})`
(`timeline_countdown_card.dart:34-63`), which reads year/month/day off the passed
date and never looks at entries. `timeline_screen.dart:181-193` resolves the date
through `AccountRepository.fetchProfile()`.

The field chain the round-1 report denied is confirmed to exist exactly as B-1
described:

| Claim | Verified at |
|---|---|
| Backend column | `backend/src/modules/users/entities/user.entity.ts:23-24` — `@Column({ type: 'date', nullable: true }) relationshipStartDate: Date` |
| Mobile read model | `mobile/lib/features/account/domain/cupid_profile.dart` — `final DateTime? relationshipStartDate`, parsed by `_parseDate` in `fromJson` |
| Repository | `mobile/lib/features/account/data/account_repository.dart` — `Future<CupidProfile> fetchProfile()` over `GET /users/me` |
| DI | `mobile/lib/core/di/service_locator.dart:96-97` — `registerLazySingleton<AccountRepository>` |

The `since()` doc comment's date-vs-instant reasoning is correct and matters. The
column is `type: 'date'`, so the JSON value is a plain calendar date; reading
`.year/.month/.day` without `toLocal()` yields the right day whether the payload
arrives as `2025-11-25` (parsed local) or `2025-11-25T00:00:00.000Z` (parsed UTC).
An intervening `toLocal()` would have been the bug here, and it is absent.

**2. A null anchor is rendered as absence, not as a substitute.**
`timeline_screen.dart:197-211` returns `SizedBox.shrink()` whenever
`snapshot.data == null`. There is no fallback to entries, to "today", or to any
other derived value. This is one of the two shapes round 1 explicitly permitted.

**3. The false claim is retracted.** `visual-fidelity-report.md` now opens the
relevant bullet with "Round 1 of this report claimed … That claim was **wrong**,
and review finding B-1 rejected it", then states the real field chain with file
and line references, and explains why the earliest-entry anchor only appeared
correct against the sample data. The retraction is explicit rather than a silent
edit, which is the right handling.

**4. The test now pins the profile-backed anchor, and pins it non-tautologically.**
The old `derives the design source countdown from the earliest entry` case is
replaced by `derives the design source countdown from the relationship start`,
feeding `DateTime(2025, 11, 25)` directly. More importantly, the widget test
(`timeline_design_fidelity_test.dart:147-160`) is now a real regression guard: the
single timeline entry is `_daysAgo(12)` while the profile anchor is `_daysAgo(246)`,
and the assertions still demand `Còn 53 ngày` / `mốc 300 ngày` / `82%`. An
entries-derived anchor cannot produce those numbers from a 12-day-old entry, so a
revert to the old behaviour fails this test rather than silently passing. The
added `no countdown is shown when the profile has no start date` case pins the
null branch by asserting both `TimelineCountdownCard` and `TimelineProgressRing`
are absent.

## AC1 / AC2 / AC4 / AC5 regression check

The round-2 diff touches no visual widget. `timeline_entry_card.dart`,
`timeline_dashed_border.dart` and `timeline_strings.dart` are byte-identical to
the round-1 reviewed commit. Within `timeline_countdown_card.dart`, all three
hunks land at lines 1-63 — imports, doc comment, and the factory; the
`TimelineCountdownCard.build` method (line 68 onward) that carries the gradient,
padding, typography and ring is untouched. The full round-1 design-source
cross-check table therefore still stands without re-derivation.

The one layout-relevant change is the 18px countdown-to-rail gap. Round 1 emitted
`SizedBox(height: 18)` as a sibling after the card; round 2 wraps the card in
`Padding(padding: EdgeInsets.only(bottom: 18))` (`timeline_screen.dart:203-208`).
Inside a `ListView` these are geometrically identical, and the gap correctly
disappears along with the card when there is no anchor.

AC5 re-checked directly: `TimelineScreen` gained an *optional* named parameter,
and its production call site `mobile/lib/features/home/presentation/home_screen.dart:316`
(`TimelineScreen(createCubit: widget.createTimelineCubit)`) is unchanged. The
only other construction site, `mobile/lib/main_preview.dart:196-198`, is also
unchanged and resolves fine because `main_preview.dart:458` calls
`setupServiceLocator()`, so `getIt<AccountRepository>()` is registered. No new
navigation edge, no routing file in the diff.

## Verification reproduced by the reviewer

Re-run independently at `f3eb936`. SDK confirmed Flutter 3.44.1 stable /
Dart 3.12.1.

| Command | Reviewer result | Report claim | Match |
|---|---|---|---|
| `flutter gen-l10n` | succeeded | required in a fresh worktree | yes |
| `flutter analyze lib/features/timeline lib/features/account test/features/timeline lib/main_preview.dart` | `No issues found! (ran in 5.6s)` | No issues found | yes (reviewer widened the scope to `features/account` and `main_preview.dart` to cover the new dependency edge) |
| `flutter test test/design_system test/features/timeline` | `00:09 +107: All tests passed!` | +107, all passed | yes |
| `flutter test test/features/home test/widget_test.dart test/app` | `00:02 +11: All tests passed!` | +11, all passed | yes |

The +107 is +1 against round 1's +106: two countdown unit tests were retargeted
in place, one null-anchor widget test was added.

## New minor findings (non-blocking)

- **M-8 — the countdown now appears asynchronously.** `_CountdownSection` is a
  `FutureBuilder` over a live `GET /users/me`, so the first painted frame has no
  hero card and the rail sits at the top of the list until the profile resolves,
  then everything below shifts down 18px + card height. Round 1 computed the
  countdown synchronously from data the screen already held. This is the
  unavoidable cost of using the correct anchor and is the right trade, but it is a
  visible layout shift on a cold open that the design source does not have. A
  reserved-height skeleton would remove it; not required for this AC.
- **M-9 — no caching; one extra profile fetch per Ready view.** The future is
  created in `_CountdownSectionState`'s field initializer, so the State's
  lifetime bounds it. That is correct while the view stays mounted, but every
  transition away from and back to `TimelineReady` (offline flip, retry, error
  recovery) rebuilds the State and issues another `GET /users/me`. Cheap and
  correct, just not free. Note that M-7 from round 1 still holds: the `now:`
  argument is still `DateTime.now()` evaluated in `build`, so a day rollover on a
  screen left open is still not picked up.
- **M-10 — the `on CupidApiFailure` catch is narrower than the actual throw
  surface, harmlessly.** `AccountRepository.fetchProfile` rethrows `e.error ??
  const UnexpectedFailure()` where `e.error` is `Object?`, and `response.data!
  as Map<String, dynamic>` can throw on a null or malformed body. Anything not a
  `CupidApiFailure` escapes the `try`. There is no crash path — `FutureBuilder`
  funnels every rejection into `snapshot.hasError`, leaving `snapshot.data` null
  and rendering the same empty state — so the behaviour is already correct for
  all errors. Flagging it so the narrow catch is not later mistaken for the thing
  that makes the error path safe; it is the `FutureBuilder` that does.
- **M-11 — the preview harness will render this screen without the hero.**
  `main_preview.dart`'s `timeline` entry reaches the live `AccountRepository`, so
  an unauthenticated preview session (or a fixture profile with no
  `relationshipStartDate`) shows no countdown. Any later story capturing
  preview-based screenshots of the Love Timeline needs a seeded start date, or
  its evidence will be missing the hero this story spent both rounds on. Relevant
  to the requirement-level screenshot work, not to this story's gate.
- **M-12 — the `dart format` justification is over-broad, and the new file is not
  format-clean.** The report states "Not run: `dart format`" because the Dart
  3.12.1 formatter would rewrite 9 pre-existing untouched files. Verified with
  `dart format --output=none --set-exit-if-changed` on the five round-2 files:
  two are not clean. For `timeline_screen_test.dart` the claim holds — the entire
  formatter delta sits in regions this round never touched, so it is genuinely
  pre-existing churn and leaving it alone was right. For the brand-new
  `stub_account_repository.dart` the claim does not hold: the delta is 3 lines in
  its own constructor, and round 1 had already formatted its own changed files.
  Cosmetic only (no analyzer or test impact, and no CI gate exists — the repo has
  no `.github/` workflows), but the blanket wording should have been scoped to
  the pre-existing file.

## Round-1 findings status

| Id | Status |
|---|---|
| B-1 | RESOLVED — see verification above; AC3 now MET |
| D-1 | Still deferred to consolidated STORY-032, unchanged and untouched, as instructed |
| M-1 | Unchanged (photo placeholder fill near-match); upheld as accepted deviation |
| M-2, M-3 | Unchanged (dash pattern, stroke straddle) |
| M-4 | Unchanged — the 9.5px-floor inconsistency with STORY-028 still needs requirement integration review; **not** resolvable inside either story |
| M-5 | Unchanged (feature-local `viEn` strings; ARB consolidation debt now four features deep) |
| M-6 | Unchanged. The patch did not make it worse: `daysTogether` still uses UTC arithmetic, and `milestoneDate` is still built locally, which the report now documents as deliberate so the milestone formats as a local calendar date |
| M-7 | Unchanged (no refresh while mounted); see M-9 |

## Acceptance criteria (round 2)

| AC | Verdict | Evidence |
|---|---|---|
| AC1 — layout / spacing / colour-token / typography match in dark + `vi` | MET with deferral D-1 | Round-1 cross-check table stands; no visual widget in the round-2 diff; the 18px gap moved from a sibling `SizedBox` to `Padding` with identical geometry |
| AC2 — deviations corrected in the app, not merely documented | MET | All 20 deviations remain code; the round-2 fix is likewise code, not a documentation change |
| AC3 — countdown and progress ring visual treatment | MET | Card box, gradient, typography and ring were already exact; the numerals now derive from `CupidProfile.relationshipStartDate`, with absence rendered as absence and a non-tautological regression test (246-day anchor vs 12-day-old entry) |
| AC4 — `<image-slot>` placeholder treatment, no real upload behaviour | MET | `timeline_entry_card.dart` and `timeline_dashed_border.dart` are byte-identical to `6e8e9ab`; M-1 remains the single accepted near-match |
| AC5 — no new entry point | MET | Optional constructor parameter only; `home_screen.dart:316` and `main_preview.dart:196` call sites unchanged; no routing file in the diff |

## Residual risks

- Unchanged from round 1: no on-device, emulator or rendered-PNG capture backs
  this review. The evidence is source-to-source plus widget tests, consistent
  with the rest of the REQ-002 wave. The conic-ring seam, the dash pattern (M-2)
  and the rail gradient terminator remain the three items most likely to differ
  once actually rendered.
- New in round 2: the countdown's real-world correctness now depends on couples
  actually having `relationshipStartDate` populated. Where it is null the hero
  silently does not render, which is correct-but-empty rather than wrong — a
  product question (should onboarding require the date?) rather than a fidelity
  defect. Worth raising at requirement integration review alongside M-11, since
  screenshot evidence for this screen will otherwise show an empty top.
- Light theme and `en` locale still received no dedicated visual pass, per the
  story's Out of Scope and OQ5.

## For Scrum Master

- Story review passes. STORY-025 is merge-eligible into
  `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`.
- Carry to requirement integration review: D-1 (STORY-032 shared background),
  M-4 (9.5px floor read differently by STORY-025 and STORY-028 — must be settled
  at the requirement level, not unilaterally), M-5 (ARB consolidation debt),
  and M-11 (preview screenshots of this screen need a seeded
  `relationshipStartDate`).
- The implementer's note about the run's `output_paths` pointing at
  `…/visual-fidelity-report.md` while the artifact lives at
  `…/visual-fidelity/visual-fidelity-report.md` is accurate; the reviewer read
  the nested path in both rounds.

REVIEW_COMPLETE: YES
