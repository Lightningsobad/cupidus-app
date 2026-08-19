# Visual Fidelity Report: STORY-055 Design System FAB/CTA Shape and Sizing Fidelity

VISUAL_FIDELITY: PASS

Scope: RWB-20260816-021 — D-1 (`CupidAddAction` Material FAB) and D-2
(`CupidPrimaryButton` height/font-size/leading glyph). Both are shared
`design_system/adaptive/**` components; the Expense History screen is the
rendered anchor because it is the only screen carrying both in the exact
configuration STORY-043 already rendered.

Design-Screen: `expense` — reused from STORY-043, not re-resolved. Per this
story's `## Out of Scope`, `design-reference-expense-android.png` and
`design-reference-expense-ios.png` were **not** re-rendered; they are
byte-identical copies of STORY-043's pair
(`sha256 f8f5873ae8a6391141d95736e3e2af4496fb20471c0080f8b0e4f21f13a6ae69`
for the Android reference, verified against the source file after copy).

## Evidence

| File | What it is |
|---|---|
| `implemented-expense-emulator-5560.png` | Material silhouette, dark + `vi`, top of scroll (AC1, AC5) |
| `implemented-expense-fab-overlap-emulator-5560.png` | Material silhouette at maximum scroll (AC4 / M-1) |
| `implemented-expense-ios-emulator-5560.png` | iOS silhouette, dark + `vi`, top of scroll (AC5) |
| `implemented-expense-ios-cta-emulator-5560.png` | iOS silhouette scrolled to the full-width CTA (AC2, AC5) |
| `design-reference-expense-android.png` | STORY-043's existing Android reference, reused as-is |
| `design-reference-expense-ios.png` | STORY-043's existing iOS reference, reused as-is |
| `implemented-jarlist-emulator-5560.png` | Dream Jar List — full-screen non-anchor consumer (AC3, review F-1) |
| `implemented-addexpense-sheet-emulator-5560.png` | Add Expense Sheet — modal-sheet non-anchor consumer, open over the anchor (AC3, review F-1) |
| `implemented-jarnew-sheet-emulator-5560.png` | Create Dream Jar sheet — extra `CupidPrimaryButton` data point; renders as a full-page route here, not a modal sheet (AC3, review F-1) |

All paths are relative to this file's directory.

**Provenance.** All four `implemented-*` captures come from post-fix builds of
the same source tree (D-1 + D-2 landed). The two Material captures come from one
build (`--dart-define=PREVIEW=expense --dart-define=PREVIEW_EXPENSE_FIXTURE=true`)
and the two iOS captures from the same build plus
`--dart-define=PREVIEW_PLATFORM=ios`. No capture predates the fix.

### Capture setup

```
flutter build apk --debug -t lib/main_preview.dart \
  --dart-define=PREVIEW=expense --dart-define=PREVIEW_EXPENSE_FIXTURE=true
adb -s emulator-5560 install -r -t build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5560 shell am start -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
.ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
  --out=<this directory> --device=emulator-5560 --settle-ms=25000 --label=expense
```

The iOS silhouette adds `--dart-define=PREVIEW_PLATFORM=ios`. Theme and locale
are the app's shipped dark + `vi` configuration (OQ5 RESOLVED), not overridden.
`emulator-5560` was already running and was reused; no device was created,
booted, wiped, or repaired.

## AC1 — D-1 `CupidAddAction` Material FAB

Design source, `cupid-app-design-system/project/Cupid Screens.dc.html` line 881
(`isMD` add-action block), read directly rather than taken from the registry
paraphrase:

```
width:60px;height:60px;border-radius:20px;background:var(--grad-hot);
box-shadow:0 8px 24px rgba(255,127,182,.45)
```

with the glyph at `font-size:27px`.

| Property | Before | After | Design source | Verdict |
|---|---|---|---|---|
| Shape | `BorderRadius.circular(radiusButton)` → pill/circle | `BorderRadius.circular(20)` rounded square | `border-radius:20px` | MATCH |
| Fill | flat `colors.colorAccentPink` | `colors.gradientHot` | `var(--grad-hot)` | MATCH |
| Shadow | none | `colors.glowShadow` | `0 8px 24px rgba(255,127,182,.45)` | MATCH (see note) |
| Size | unset → Material default 56x56 | explicit 60x60 | `60px`/`60px` | MATCH |
| Glyph | default icon size | `27` | `font-size:27px` | MATCH |

Confirmed in `implemented-expense-emulator-5560.png`: the FAB renders as a
gradient (pink→purple) rounded square with a visible glow, matching the FAB in
`design-reference-expense-android.png`. Asserted in code by
`test/design_system/adaptive_widgets_test.dart`, "Material FAB is a 60pt rounded
square on the hot gradient" (size, gradient, boxShadow, borderRadius, glyph
size).

**Note on the glow token (requirements.md `## Assumptions`).** AC1 mandates
`colors.glowShadow`, and that is what is implemented. For the record, the FAB
block in the design source hardcodes `0 8px 24px rgba(255,127,182,.45)` rather
than referencing `var(--glow)` (which the iOS CTA block on line 884 does use).
Against the dark-theme `glowShadow` token
(`0 8px 28px rgba(255,107,168,.34)`) that is a blur difference of 4px and a
slightly warmer, more opaque colour. The divergence is not visually material at
the rendered size and does not change this story's verdict; it is recorded here
rather than silently substituted, so a future token decision has the measurement
if the team ever wants a FAB-specific glow token.

## AC2 — D-2 `CupidPrimaryButton`

Design source line 884 (`isIOS` CTA block):

```
height:52px;border-radius:var(--r-btn);background:var(--grad-hot);color:#fff;
display:flex;align-items:center;justify-content:center;gap:8px;
font-size:15.5px;font-weight:800;box-shadow:var(--glow)
```

with the leading glyph at `font-size:21px`.

| Property | Before | After | Design source | Verdict |
|---|---|---|---|---|
| Height | `54` | `52` | `height:52px` | MATCH |
| Label size | `16.5` | `15.5` | `font-size:15.5px` | MATCH |
| Label weight | `w800` | `w800` (unchanged) | `font-weight:800` | MATCH |
| Leading glyph | absent | `CupidIcons.add` at `21`, opt-in | `font-size:21px` | MATCH |
| Gap before label | n/a | `8` | `gap:8px` | MATCH |

The leading glyph size (21) was read from the design source directly; it is not
stated in the requirements and was not invented.

Confirmed in `implemented-expense-ios-cta-emulator-5560.png`: the CTA renders
the `+` glyph followed by a gap and the label "Ghi một khoản" on the gradient
pill with its glow. Asserted in code by the "opts in to a leading glyph with an
8pt gap" test (glyph size, and the measured 8pt gap between the glyph's right
edge and the label's left edge, on both platforms).

`leadingIcon` is optional and defaults to `null`, so the Expense History iOS
add-action CTA is the only call site that gains a glyph. The "paints the hot
gradient, the glow and the 52pt CTA band" test now also asserts that a
`CupidPrimaryButton` built without `leadingIcon` contains no `Icon` descendant,
so a future accidental default cannot slip in unnoticed.

## AC3 — No regression across every real consumer

- `flutter analyze lib test`: 0 errors, 0 warnings. 80 pre-existing `info`
  lints, none in any file this story touched.
- `flutter analyze` on the three touched files: `No issues found!`
- `flutter test`: `+1313 ~2: All other tests passed!` (1313 passed, 2 skipped,
  0 failures).

All 25 enumerated call sites compile unchanged: `leadingIcon` is an additive
optional parameter, so `CupidPrimaryButton(label:, onPressed:)` and
`CupidAddAction(onPressed:)` keep their existing signatures.

### Rendered spot-check on non-anchor consumers (review F-1)

An earlier revision of this section answered AC3's rendered half with widget
tests plus reasoning. Review finding F-1 correctly rejected that as a
substitution: a widget test builds the component in isolation, not inside a
real consumer's layout. The captures below replace it.

Procedure is the anchor's: preview build of `lib/main_preview.dart`, installed
on the already-running `emulator-5560`, then `capture-mobile-screen.sh`. Where
the preview registry exposes a key, the screen was reached with the harness'
own `cupidpreview://screen/<id>` deep link, so no extra build/install cycle was
needed. Dark + `vi`, Material silhouette, no theme or locale override.

| Capture | Consumer type | Component under test | Overflow / clipping / layout breakage |
|---|---|---|---|
| `implemented-jarlist-emulator-5560.png` | full-screen | `CupidPrimaryButton` ("Thử lại") | None |
| `implemented-addexpense-sheet-emulator-5560.png` | modal sheet | `CupidPrimaryButton` ("Lưu") | None |
| `implemented-jarnew-sheet-emulator-5560.png` | full-page route (not a modal sheet — see below) | `CupidPrimaryButton` ("Tạo Dream Jar") | None |

**Dream Jar List** (`--dart-define=PREVIEW=jarlist`). The preview session is
unauthenticated, so `DreamJarListCubit` resolves `DreamJarListFailed` and the
screen renders `_LoadErrorView`. Its `CupidPrimaryButton` draws the full 52pt
gradient pill with its glow inside the screen's own centred, `lg`-padded
column: label on one line, not truncated, no vertical overflow, no stripe.
`CupidAddAction` is **not** on screen in this state —
`dream_jar_list_screen.dart:70-81` supplies `CupidHeader.actions` only for
`DreamJarListEmpty` and `DreamJarListReady`. See the evidence gap below.

**Note (reviewer, non-blocking) — do not misread the flat-pink control in this
capture.** The flat-pink rounded square visible in this screenshot is **not** a
`CupidAddAction`, so it is not evidence for or against D-1: it carries no
gradient and no glow precisely because it is a different control, not because
the D-1 fix failed to apply. It is a separate screen-level element outside this
story's `design_system/adaptive/**` write scope and was not touched here.

**Add Expense Sheet** — the modal-sheet consumer the action item names. It has
no preview-registry key, so it was reached the way a user reaches it, by
opening it from the anchor's `CupidAddAction`; the capture is therefore a real
`showModalBottomSheet` route over Expense History, not a bare-`Scaffold`
stand-in. The "Lưu" CTA renders the full 52pt band, both rounded ends and the
glow below it, flush inside the sheet's horizontal padding and clear of the
gesture-nav inset. No leading glyph, which is correct: `leadingIcon` defaults
to `null` and AC2 scopes the opt-in to the anchor's iOS CTA alone.

**Create Dream Jar sheet** (`cupidpreview://screen/jarnew`). Captured as an
extra `CupidPrimaryButton` data point because the registry exposes it directly.
**Correction (reviewer, non-blocking):** despite the "sheet" in its name and
filename, this capture is *not* a modal sheet. The preview registry's
`_buildJarnew` wraps `CreateDreamJarSheet` in a bare `Scaffold`, so it renders
as a full-page route with no drag handle and nothing dimmed behind it. AC3's
modal-sheet consumer requirement is met by the Add Expense Sheet capture above,
which is a real `showModalBottomSheet` route; this one is a supplementary
full-screen data point. The "Tạo Dream Jar" CTA renders the same 52pt gradient
pill, full width inside the route's padding, with the form's three fields above
it intact. No leading glyph, again correct.

#### Does the 56→60 FAB growth clip content on Dream Jar List?

No, and it cannot, because Dream Jar List does not place `CupidAddAction` as an
overlay. All three call sites read directly:

| Call site | Placement | Overlays scrolling content? |
|---|---|---|
| `expense_history_screen.dart` | `Scaffold.floatingActionButton` | Yes — this is the M-1 mechanism |
| `dream_jar_list_screen.dart:75` | `CupidHeader.actions`, the app-bar action slot | No |
| `gallery_empty_view.dart:78` | inline, last child of a centred `Column(mainAxisSize: min)` | No |

M-1 is an overlay-versus-scroll-padding defect: the FAB floats above the scroll
view while that view still reserves only the design's in-flow bottom padding.
Neither non-anchor consumer creates that geometry — one lays the action out
inside the header's action slot, the other inside a column that shrink-wraps
its children — so the 4pt growth consumes layout space on those screens instead
of covering a content row. **M-1 stays anchor-only**, which is consistent with
AC4's observation and now explains it rather than restating it.

#### Evidence gap — `CupidAddAction` was not rendered on a non-anchor consumer

Both non-anchor call sites are gated behind states this session cannot reach:
Dream Jar List shows the action only in `DreamJarListEmpty`/`DreamJarListReady`,
and `GalleryEmptyView` is mounted only on `GalleryEmpty`. Both require a
successful repository fetch; a probe of `cupidpreview://screen/gallery` landed
on "Không tải được gallery" for the same reason the jar list landed on its
error view.

Both therefore need an authenticated backend session, which
`preview_session_bootstrap.dart` raises only from
`--dart-define=PREVIEW_EMAIL`/`PREVIEW_PASSWORD` — credentials that are
deliberately uncommitted. The registry has no fixture standing in for either:
`_PreviewDreamJarRepository` overrides `fetchJar`/`fetchContributions` only, and
`_buildJarlist`/`_buildGallery` take the live `getIt` repository.

Adding such a fixture means editing `lib/main_preview.dart`, outside this
story's `design_system/adaptive/**` write scope. The harness has a named
precedent for exactly this case — `preview_session_bootstrap.dart` lines 18-19
cite STORY-020's "Authorized Write-Scope Extension — Preview Harness" — so the
gap is closable, but under an explicit scope extension rather than
unilaterally. It is recorded here for the review gate to dispose of, not
answered with reasoning in place of a capture.

**Scrum Master disposition:** accepted — the non-overlay placement at both
non-anchor call sites is source-verified (see placement table above) and
structurally rules out the M-1 overlay-clipping mechanism; no code change, and
no further capture is required to close AC3.

## AC4 — M-1 (FAB overlap): re-confirmed, NOT fixed

`implemented-expense-fab-overlap-emulator-5560.png`, taken at maximum scroll on
the Material silhouette after the D-1 fix, shows the last row
("Nồi chiên không đầu") with its amount still clipped — rendered as `1.20…`
where the full value is `1.200.000₫`. **M-1 is still present and unchanged in
kind after D-1.**

The clipping is marginally wider than STORY-043 recorded, which is the expected
consequence of D-1 growing the FAB from 56x56 to 60x60 without a compensating
change to the scroll view's bottom padding. This is exactly the outcome
`story_master.md` predicted, and is the reason no AC in this story claims M-1
"clears" once D-1 lands.

M-1 is **Material-only**, re-confirmed by direct observation rather than
inference: in `implemented-expense-ios-cta-emulator-5560.png` the same row at
the same scroll extent renders its full `1.200.000₫`, because the iOS silhouette
has no FAB overlay.

**Root cause and why no fix is here.** The design keeps its add-action inside
the scrolling content flow (`position:sticky`, `margin-top:16px`, ahead of the
container's `padding-bottom:40px`), so no row can sit behind it. The
implementation uses `Scaffold.floatingActionButton`, a pure overlay, with the
scroll view's bottom padding still at the design's in-flow value of 40
(`_screenPadding` in `expense_history_screen.dart`). That padding is a
**screen-level property of `expense_history_screen.dart`**, not a property of
`CupidAddAction`, and therefore sits outside this story's
`design_system/adaptive/**` write scope. **No `expense_history_screen.dart`
scroll or padding logic was changed** (the only edit to that file in this story
is the one-argument `leadingIcon:` addition required by AC2). Closing M-1
requires a separate, screen-level item against the Expense History screen's own
bottom padding.

## F-2 — the enlarged FAB does not fit `CupidHeader.actions` (measured)

Review F-2 asked whether the 60x60 box AC1 mandates survives the slot it is
placed in at `dream_jar_list_screen.dart:75`. Measured by widget test rather
than by capture, since the state gating that call site is unreachable here (see
AC3 evidence gap) while the geometry is not:
`test/design_system/adaptive_widgets_test.dart`, case "Material FAB is clamped
to 60x56 inside `CupidHeader.actions`", pumps
`Scaffold(appBar: CupidHeader(title: …, actions: [CupidAddAction(…)]))` on
`CupidPlatform.material` and reads `tester.getSize`.

| Context | Measured | AC1 target | |
|---|---|---|---|
| Standalone — `Scaffold.body`, and the anchor's `floatingActionButton` | 60.0 x 60.0 | 60x60 | match |
| Inside `CupidHeader.actions` — Dream Jar List | **60.0 x 56.0** | 60x60 | **deviation** |

**F-2 is confirmed, not disproved.** The measured height is exactly
`kToolbarHeight`, and the test asserts that identity alongside the literal size,
so the mechanism is pinned rather than just the number.
`CupidHeader.preferredSize` is `Size.fromHeight(kToolbarHeight)` and its
Material branch passes `actions` straight into an `AppBar`, whose toolbar band
clamps the 60pt box on the cross axis. The visible result is a 60x56 rectangle
still carrying `BorderRadius.circular(20)` — a radius chosen for a square. Note
the pre-story control was an exact fit: the Material default 56x56 is square
and fits the band, so D-1's growth is what introduced the mismatch at this call
site.

`gallery_empty_view.dart:78` is unaffected — a shrink-wrapping `Column` passes
loose constraints, which is the standalone 60x60 row above.

**Not fixed here, by scope.** Every available fix edits `cupid_header.dart`
(raise the header's toolbar band, or let the action slot pass loose
constraints), which `story_master.md` excludes from this story's write scope
(`cupid_add_action.dart` and `cupid_primary_button.dart` only). No fix was
attempted. The test pins the current 60x56 so that a follow-up item against the
header has a ready assertion to flip back to `Size(60, 60)`. **Routed to Scrum
Master for a scope disposition** — this is a real AC1 deviation at one of three
call sites, not a closed finding.

**Scrum Master disposition (F-2):** accepted as a documented, test-pinned
deviation; not fixed under this story. The only available fixes touch
`cupid_header.dart` — a shared header component consumed by many screens
beyond this story's `design_system/adaptive/**` write scope, and correctly
fixing it may itself be a UX decision (should a header-slot "add" action
carry the full 60x60 gradient-glow FAB treatment, or a smaller
icon-button variant sized to the toolbar?) rather than a pure engineering
toolbar-height change. Split to `RWB-20260816-027`
(`data/retro-audit/rework-backlog.md`), owner UI/UX Designer + Tech Lead.
This matches the reviewer's own stated acceptable resolution:
"Documenting the deviation and raising a follow-up item against the
header's toolbar height is an acceptable resolution."

## Verdict

- D-1: PASS at the anchor and standalone (60x60); see F-2 for one call site
  where the shipped box is clamped to 60x56.
- D-2: PASS
- AC3 no-regression: PASS — `CupidPrimaryButton` rendered on 3 non-anchor
  consumers with no overflow/clipping; `CupidAddAction`'s non-anchor call sites
  are source-verified non-overlay, so M-1 cannot recur there (Scrum Master
  disposition, see AC3 section).
- M-1: confirmed still present, Material-only, out of write scope, documented
  only — as AC4 requires.
- F-2: confirmed deviation — 60.0 x 56.0 inside `CupidHeader.actions`, clamped
  by `kToolbarHeight`. Documented and pinned by test; fix needs
  `cupid_header.dart`, out of write scope. Accepted by Scrum Master as a
  documented deviation and split to `RWB-20260816-027`.

VISUAL_FIDELITY: PASS
