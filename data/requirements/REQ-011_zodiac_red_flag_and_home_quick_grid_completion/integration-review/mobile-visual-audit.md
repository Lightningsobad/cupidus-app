# REQ-011 — Requirement-Level Cross-Screen Mobile Visual Audit

Scope: `REQ-011_zodiac_red_flag_and_home_quick_grid_completion`, both stories merged.
Branch: `codex/REQ-011_zodiac_red_flag_and_home_quick_grid_completion-integration`
HEAD: `da4f60c74a2323d8652c66c1f86c44d689486319` (clean apart from this directory)
Device: `emulator-5554`, Android 16, 1080x2400 @ 420dpi (411dp logical)
Date: 2026-08-25

**Result: PASS — no blocking visual breakage.** One new deferred finding (F-5,
light-theme contrast), one coverage gap (F-2, runtime navigation not
observable in the sanctioned harness). Everything the shipping configuration
(dark theme, `vi`) actually renders is correct.

---

## Method

STORY-001 built a new screen and STORY-002 rebuilt the Home list position that
links to it. Neither story's per-story evidence shows the two together in one
running app, and STORY-002's own capture predates the merge, so this pass drives
the merged build directly.

Both screens were reached through the project's own preview entrypoint
(`mobile/lib/main_preview.dart`) rather than by navigating a live app — the real
app sits behind auth, pairing, and a running backend. The `zodiac` and `home`
canvases are registered there (`main_preview.dart:274-283`, `:1489-1495`), served
by `_PreviewZodiacRepository` and the Home fixture, so no capture depends on a
seeded couple or a live `GET /zodiac/red-flag/today`. Screens were switched at
runtime with the registered `cupidpreview://screen/<id>` deep link and captured
with `.ai-team-bundle/runtime/tools/capture-mobile-screen.sh`.

Builds run in this session (all green, real `flutter build apk --debug -t
lib/main_preview.dart --target-platform android-arm64`):

| Build | Defines | Result |
| --- | --- | --- |
| dark #1 | `PREVIEW=home`, `PREVIEW_HOME_FIXTURE=true`, `PREVIEW_BRIGHTNESS=dark` | `✓ Built app-local-debug.apk` |
| light | `PREVIEW=home`, `PREVIEW_HOME_FIXTURE=true`, `PREVIEW_BRIGHTNESS=light` | `✓ Built app-local-debug.apk` |
| dark #2 | `PREVIEW=zodiac`, `PREVIEW_HOME_FIXTURE=true`, `PREVIEW_BRIGHTNESS=dark` | `✓ Built app-local-debug.apk` |
| dark #3 | `PREVIEW=zodiac`, `PREVIEW_ZODIAC_STATE=incomplete`, `PREVIEW_BRIGHTNESS=dark` | `✓ Built app-local-debug.apk` |

Test run in this session, to close F-2's runtime gap with automated evidence:

```
flutter test test/features/home/home_quick_grid_test.dart
00:00 +7 ~1: All tests passed!
```

Runtime hygiene: DevOps's installed `base.apk` was pulled and backed up before
the first preview install (sha1 `92d9b5576c6d4be56ee51b77aab061420e9ad86f`) and
**reinstalled afterwards**; the restored app was relaunched and confirmed to boot
to its normal unpaired pair-gate route ("Ghép đôi để mở khoá Cupid"). Device
display size and density were returned to 1080x2400 @ 420dpi. No device was
created, booted, wiped, or repaired.

Contrast figures are measured from captured pixels (WCAG 2.1 relative
luminance). Both the hero card and the app-wide backdrop are gradients, so
"background under glyphs" is the modal **non-glyph** colour inside the text run's
bounding box — not a sample taken from a clean band above the text, which on a
gradient reads a different colour than the one behind the glyphs and understates
contrast by up to 0.4.

---

## Screens covered

| Screen | Theme / state | Capture |
| --- | --- | --- |
| Home, cumulative quick grid | dark | `implemented-home-dark-vi-emulator-5554.png` |
| Home @ 320dp | dark | `implemented-home-dark-vi-320dp-emulator-5554.png` |
| Home @ 320dp, scrolled to the grid | dark | `implemented-home-dark-vi-320dp-scrolled-emulator-5554.png` |
| Home @ 260dp (width bound) | dark | `implemented-home-dark-vi-260dp-emulator-5554.png` |
| Home | light | `implemented-home-light-vi-emulator-5554.png` |
| Zodiac Red Flag, ready state | dark | `implemented-zodiac-dark-vi-emulator-5554.png` |
| Zodiac Red Flag @ 320dp | dark | `implemented-zodiac-dark-vi-320dp-emulator-5554.png` |
| Zodiac Red Flag @ 320dp, scrolled to end | dark | `implemented-zodiac-dark-vi-320dp-scrolled-emulator-5554.png` |
| Zodiac Red Flag, incomplete-profile (AC3) | dark | `implemented-zodiac-dark-vi-incomplete-emulator-5554.png` |
| Zodiac Red Flag, ready state | light | `implemented-zodiac-light-vi-emulator-5554.png` |

Region crops: `crop-home-dark-vi-quick-grid.png`,
`crop-home-light-vi-quick-grid.png`,
`crop-zodiac-dark-vi-hero-contrast.png`,
`crop-zodiac-light-vi-hero-contrast.png`,
`crop-home-dark-vi-zodiac-tile-ripple.png`.

---

## F-1 — Both screens in the shipping configuration: PASS

**Home.** The rebuilt list position renders as two equal-width tiles between the
daily-mood card and Dream Jar, at the same `_cardGap` rhythm as the full-width
cards above and below. Both tiles carry their rounded icon plate (amber bell,
peach `auto_awesome`), 14px/800 title and 11.5px subtitle, and both resolve to
the same height — `IntrinsicHeight` + `CrossAxisAlignment.stretch`
(`home_screen.dart:892-894`) is doing its job. Every pre-existing Home element
still renders in the same frame: paired avatar cluster, 247-day counter,
milestone chip, Anti-Ghosting entry, daily-mood card, Dream Jar, Pet card, and
the bottom tab bar with Home selected.

**Zodiac Red Flag.** Hero card (`RED FLAG · 29/07` eyebrow, "Cự Giải và Song
Ngư", three-line body, decorative sparkles clipped correctly inside the card),
conflict-index card (`7/10`, the êm→drama gradient bar filled to 70%, both
partner discs with the lightning divider), the 3-row daily-tip list with its
tinted glyph plates and hairline dividers, and the disclaimer footer. Pushed
above the shell, so correctly no bottom tab bar
(`main_preview.dart:276`).

No `RenderFlex` overflow stripes on either screen at any width tested, no clipped
or overlapping content, no safe-area intrusion at the status bar or the gesture
bar, and no raster artwork at all on the new surfaces (both screens are vector
`CupidIcon` glyphs and painted gradients), so no wrong-density case exists.

## F-2 — Coverage gap: the tile→screen navigation is not observable in the sanctioned harness

This was the requirement-specific cross-screen check, and it cannot be completed
by capture. The result is honest rather than green: the tap fires, but the
transition cannot be photographed.

What was measured on-device: pressing the Zodiac tile produces the `InkWell`
splash centred on the touch point (`crop-home-dark-vi-zodiac-tile-ripple.png`),
so the tap target is live and correctly positioned. The screen then does not
change. The control tile next to it (Synced Alarm) *does* navigate from the same
build and the same gesture, which isolates the cause.

The cause is structural and lives in the harness, not the app:

- The Zodiac tile is the only `pushNamed` call site in the entire app
  (`home_screen.dart:923-925`; a repo-wide search finds no other).
- The real composition root registers that route —
  `cupid_app.dart:68-71` maps `ZodiacRedFlagScreen.routeName` to
  `const ZodiacRedFlagScreen()`.
- The preview harness's `MaterialApp` (`main_preview.dart:1681-1707`) declares
  no `routes:` and no `onGenerateRoute:` at all. Every other Home entry uses
  `MaterialPageRoute`, which needs no route table — which is exactly why no
  previous preview capture ever exposed this.

So the harness has never been able to resolve a named route, and this
requirement introduced the first one. The app's own navigation contract is
sound; the evidence tool cannot show it.

Closed with automated evidence instead of a capture: `flutter test
test/features/home/home_quick_grid_test.dart` was run in this session and passed
7/7, including *"AC2: tapping the zodiac tile resolves the named route to
ZodiacRedFlagScreen"* (`home_quick_grid_test.dart:309-312`), which mounts the
same route table the real app uses (`:92`).

**Residual risk: low.** The route table, the call site, and the tap target are
each verified; only their composition on a device is unwitnessed, and that
composition is what the AC2 test asserts.

**Recommendation (not this requirement's scope):** give `main_preview.dart`'s
`MaterialApp` the same `routes:` map as `cupid_app.dart`. It is a small
harness-only change, but it is a `mobile/lib/` edit outside this run's write
scope, and it should be queued so the next requirement that adds a named route
does not rediscover this.

## F-3 — Narrow-width behaviour of the new 2-up grid: verified to 260dp

The grid is the one genuinely new layout risk in this requirement: two tiles now
share a width that one full-width card used to own, and the tile title has no
`maxLines`/`overflow` guard (`home_screen.dart:1008-1015`), unlike the subtitle.

| Width | Grid behaviour |
| --- | --- |
| 411dp (native) | both titles on one line; both tiles equal height; clean |
| 320dp | "Nhắc nhở đồng bộ" wraps to 2 lines, "Zodiac Red Flag" stays on 1; tiles still equal height; clean |
| 260dp | both titles wrap to 2 lines; both subtitles ellipsize; tiles still equal height; clean |

No overflow stripe at any width. The unguarded title wraps rather than overflows
because it sits in a `Column` inside a stretched `Expanded`, so the missing
`maxLines` is not reachable as a defect here — it only means the tile grows
taller, and `IntrinsicHeight` keeps its neighbour in step.

Minor, non-blocking: at 320dp the two tiles' *subtitles* sit on different
baselines, because the left title took a second line and each tile's `Column` is
top-aligned with `MainAxisSize.min`. The tiles remain the same height, so
nothing clips or misaligns at the tile boundary; only the inner text rows
diverge, and they re-align at 260dp when both titles wrap. 260dp is below any
shipping device class and is recorded only to establish where the layout bottoms
out.

## F-4 — Not a defect: the Zodiac tile subtitle ellipsizes at every width

"Xem chỉ số xung đột hôm nay" renders as "Xem chỉ số xung đột hôm …" even at the
device's native 411dp, so the full string is never readable on this device class.
This is intended, not a regression: the subtitle is `maxLines: 1` +
`TextOverflow.ellipsis` by spec, the design source ellipsizes the same string,
and STORY-002's visual-fidelity report already scored the row "11.5px ellipsized
| match" (`visual-fidelity-report.md:124`). Recorded so integration review does
not re-raise it as a truncation bug.

## F-5 — NEW (deferred): light theme fails AA on four of this requirement's own surfaces

Neither story rendered light theme, so no per-story capture could have found
this. Measured on the merged build:

| Element | Dark (ships) | Light | AA body 4.5:1 | AA large 3.0:1 |
| --- | --- | --- | --- | --- |
| Zodiac screen eyebrow `RED FLAG · 29/07`, on the hero gradient | 6.68:1 | **1.51:1** | FAIL | FAIL |
| Home Zodiac tile subtitle (peach), on the card | 8.77:1 | **2.67:1** | FAIL | FAIL |
| Zodiac screen hero body text, on the hero gradient | 4.69:1 | **3.06:1** | FAIL | PASS |
| Zodiac screen disclaimer footer, on the backdrop | 8.08:1 | **4.21:1** | FAIL | PASS |
| Zodiac screen êm/drama scale labels, on the white card | 7.09:1 | 4.45:1 | FAIL (marginal) | PASS |
| Zodiac screen tip-row body, on the card | 14.18:1 | 13.39:1 | PASS | PASS |

Two of these are new in kind, not just new instances of REQ-010's F-6:

1. The **eyebrow at 1.51:1** is the worst text contrast measured anywhere in
   this app so far — amber on a light lavender hero gradient is nearly
   isoluminant. It is effectively invisible; see
   `crop-zodiac-light-vi-hero-contrast.png` next to its dark twin.
2. The **peach tile subtitle at 2.67:1** is a direct consequence of STORY-002's
   round-2 D1 fix, which added `subtitleColor: colors.colorPeach`
   (`home_screen.dart:922`) to match the design. That fix is correct for dark
   (8.77:1, the best subtitle in the grid) and is what pushes the light variant
   below even AA-large. The untouched Synced Alarm subtitle next to it measures
   4.45:1 — the same marginal `--tx2`-on-white value REQ-010's F-6 recorded, so
   the peach tile is 1.7x worse than the control, not merely equal to it.

The 4.45:1 and 4.21:1 rows are the already-known `--tx2` token issue and belong
with REQ-010's F-6.

**Severity qualifier:** `CupidFeatureFlags.enableLightTheme` still defaults to
`false` (`cupid_feature_flags.dart:7-10`) and `cupid_app.dart:50-52` therefore
pins `ThemeMode.dark`. The shipped app is dark-only, so **none of this is
user-reachable today**. Dark theme passes AA on every element in the table.

Route to UI/UX Designer alongside REQ-010's D1 and F-6 as one token/backdrop
decision that must land before `enableLightTheme` is ever flipped. Does not
block this requirement.

## F-6 — Not a defect: the grid holds 2 tiles, not the design's 4

`Cupid Screens.dc.html:305-326` draws a 2x2 grid of four tiles — Synced Alarm,
Zodiac Red Flag, Dream Jar, Anti-Ghosting. The merged Home renders the first two
as a grid row and keeps Dream Jar and Anti-Ghosting as full-width entry cards
above and below it, so the requirement-level Home does not match the design's
grid block as a whole.

This is ratified scope, not drift: STORY-002's UX spec explicitly puts the other
two out of scope — "Dream Jar and Anti-Ghosting already ship as their own
full-width entry cards and are explicitly out of scope for this story ... do not
touch them or fold them into a grid" (`ux/ux-spec.md:23-27`, restated at `:159`).
Recorded because a cross-screen pass is exactly where a half-converted grid would
otherwise read as an integration defect.

## F-7 — Not a defect: the incomplete-profile state offers no action

The AC3 degraded state renders a centred info card — icon, "Chưa đủ thông tin
cung hoàng đạo", and a two-line body asking both partners to fill in their birth
date — with no button to go and do that. Nothing is clipped or misaligned and
the copy is the specified non-alarming wording. The missing CTA is deliberate:
"No CTA button is required by this story's scope" (`STORY-001 ux/ux-spec.md:133`).

## F-8 — Not a defect: Home's Pet card shows its error state

Home renders "Không thể tải Bún" because no local backend is running in this
session; the app's own DevOps gate covered build and boot, not a running
backend, and standing one up is outside this lane. The card still paints its
surface and the shared backdrop correctly, which is the property this audit
checks. Same class as REQ-010's F-8, and unrelated to either story's diff.

---

## Coverage gaps

1. **Runtime navigation** — see F-2. Closed with the AC2 widget test rather than
   a capture.
2. **Text scaling** — the preview harness pins `MediaQuery.withNoTextScaling`
   (`main_preview.dart:1700`), so the quick grid's unguarded tile title
   (F-3) was never exercised against a system font-size override. That is the
   one configuration in which the missing `maxLines` could plausibly matter.
   Removing the pin is a `mobile/lib/` change outside this run's write scope.
3. **`en` locale** — the harness pins `locale: const Locale('vi')`
   (`main_preview.dart:1692`) and `CupidFeatureFlags.enableEnLocale` defaults to
   `false`, so `en` is not user-selectable in the shipped app either. All
   captures are `vi`, which matches what ships. The one string that differs by
   locale on these screens is the tile subtitle; the tile *title* is the same
   literal in both (`home_screen.dart:84-87`) and is pinned by
   `home_quick_grid_test.dart:293`, which passed.

---

## Verdict

No blocking visual breakage across the merged requirement. The new Zodiac Red
Flag screen and the rebuilt Home quick grid render correctly together in the
shipping configuration, in all three of the Zodiac screen's states, and down to
260dp.

F-2 is an evidence-tooling gap with low residual risk, closed by a passing AC2
navigation test and by the route registration in `cupid_app.dart:68-71`. F-5 is
genuine but sits entirely behind `enableLightTheme=false` and belongs with
REQ-010's D1/F-6 in the UI/UX Designer's token decision, not in this
requirement's completion path.

`MOBILE_VISUAL_AUDIT_COMPLETE: YES`
