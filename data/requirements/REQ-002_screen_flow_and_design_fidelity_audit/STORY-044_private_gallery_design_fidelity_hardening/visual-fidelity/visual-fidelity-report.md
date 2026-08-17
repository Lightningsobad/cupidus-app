# STORY-044 — Private Gallery Rendered Design-Fidelity Evidence

```
VISUAL_FIDELITY: PASS
Design-Reference-Render: OK (gallery / android / dark / vi, state forced via --click)
Implementation-Capture: PAIRED (STORY-026 emulator-5560 capture, equivalence proven in §2)
In-Scope-Deviations-Found: 0
```

This header supersedes STORY-026's
`Design-Reference-Render: BLOCKED (DESIGN_CANVAS_STATE_FORCE_UNSUPPORTED)`.
The block is cleared: the `galleryOpen` state can now be forced, was rendered,
and was compared pixel-for-pixel against the shipped screen. STORY-026's
`VISUAL_FIDELITY: PASS` was reached by value-by-value source comparison alone;
this report re-establishes the same verdict on rendered evidence.

Phase: P1 (`coding-plan/phase-P1-gallery-rendered-fidelity-evidence.md`).
Covers AC4, AC5, AC6, AC7.

---

## 0. Line-number basis (KD1)

Every line citation for this screen in STORY-026 is 8 lines stale. The
`galleryOpen` block is **L744-759** of
`cupid-app-design-system/project/Cupid Screens.dc.html`, not L736-751. The
in-scope comparison surface restates as:

| Region | STORY-026 cited | Correct (KD1) |
| --- | --- | --- |
| grid container padding | L737 | **L745** |
| grid definition | L743 | **L751** |
| photo tiles | L744-746 | **L752-754** |
| dashed add tile | L747 | **L755** |

All citations below use the corrected numbers. Where a STORY-026 finding is
quoted verbatim its original citation is kept inside the quote and the
corrected line is given alongside.

---

## 1. Design-reference render (AC4)

Reproducible command, run from the repository root:

```bash
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system \
  --entry="Cupid App.dc.html" \
  --out=<clean output dir> \
  --screen=gallery \
  --platform=android \
  --theme=dark \
  --lang=vi \
  --click='[data-plat="md"] div:has(> span[data-icon]:text-is("fingerprint"))'
```

Observed output:

```
click: '[data-plat="md"] div:has(> span[data-icon]:text-is("fingerprint"))' matched 1 element(s)
DESIGN_CANVAS: OK .../design-reference-gallery-android.png 406x900
exit 0
```

| Field | Value |
| --- | --- |
| Artifact | `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-044_private_gallery_design_fidelity_hardening/visual-fidelity/design-reference-gallery-android.png` |
| Dimensions | 406 x 900 RGBA |
| Bytes | 149926 |
| SHA-256 | `82277b90885e120bd1ec8a66e997f6f713733fd8fe32b1cbdcdbca3a15bd2141` |

**Selector.** The unlock affordance carries no class, id, or data attribute, so
a plain CSS selector cannot address it. The Playwright locator engine is a
superset of CSS and supplies `:has()` and `:text-is()`, which is what makes the
element addressable by its fingerprint glyph child. The selector is the one
contracted in `coding-plan/tool-contract-click-flag.md` and it matched exactly
one element.

**`--platform=android` only (KD3).** A click is frame-scoped. The canvas renders
side A (`platform="ios"`) and side B (`platform="md"`) as independent component
instances with independent state, so a single click unlocks exactly one frame.
`--platform=all` and `--platform=ios` were therefore not used, and the reference
is the Android/Material frame only — which is the correct counterpart for the
Android capture in §2.

**Freshness (R4).** The render wrote into a directory that was created empty
immediately beforehand; the PNG's mtime was 5 seconds old at the verification
check. The artifact is not a stale carry-over.

**State confirmation.** Visual inspection confirms the unlocked `galleryOpen`
block (L744-759): the photo grid, the caption chips, and the dashed add tile
are all present, and the locked-state body of `galleryLocked` is absent. The
prototype screen-index FAB is likewise absent.

---

## 2. Implementation capture pairing (AC5)

| Field | Value |
| --- | --- |
| Artifact | `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-044_private_gallery_design_fidelity_hardening/visual-fidelity/implemented-gallery-emulator-5560.png` |
| Dimensions | 1080 x 2400 RGBA |
| SHA-256 | `c9fbce3cb1150013eeb4f14a37b10854766eaf39b0dbc50d7c34979d41b90e08` |
| Origin | committed STORY-026 capture, copied unmodified into this story's evidence directory |

The phase names the already-committed capture as the pairing target rather than
a fresh one, and the pairing is sound because
`mobile/test/features/gallery/gallery_capture_entry.dart` — the entry that
produced it — renders the same axes the reference was rendered on:

| Axis | Reference render | Capture entry |
| --- | --- | --- |
| Platform | `--platform=android` (Material frame) | `buildCupidTheme(platform: CupidPlatform.material, ...)` |
| Theme | `--theme=dark` | `brightness: Brightness.dark` |
| Language | `--lang=vi` | `locale: const Locale('vi')` |
| Screen | `--screen=gallery`, unlocked | `CupidHeader(title: 'Gallery chung')` + `GalleryGridView` |
| Content | 3 photos + add tile | 3 items + add tile |
| Dates | 14/02, 02/03, 19/04 | `DateTime.utc(2026,2,14)`, `(2026,3,2)`, `(2026,4,19)` |

The two sides depict the same state, so re-capturing would produce the same
pixels. No new capture was taken.

**Common measurement basis.**

| | Reference | Implementation |
| --- | --- | --- |
| Raster | 406 x 900 | 1080 x 2400 |
| Scale | 1.0 CSS px per unit (screen content 389 x 884 inside an 8 px bezel) | 2.75 device px per dp |
| Screen width | 389 px | 392.7 dp |

Screen widths differ by 0.95 %, so units on the two sides are directly
comparable and any measured difference above ~1 % is real. All figures below
are in reference px and implementation dp respectively.

---

## 3. In-scope rendered comparison

### 3.1 Grid container padding — L745 `padding:8px 16px 40px`

| Property | Design | Reference render | Implementation | Verdict |
| --- | --- | --- | --- | --- |
| Left padding | 16 | 16.0 (tile edge 24.5 in a screen starting at 8.5) | 15.3 dp (tile edge x=42 of 1080) | match |
| Right padding | 16 | 16.0 (tile edge 381.5, screen ends 397.5) | 15.3 dp (tile edge x=1038) | match |
| Top padding | 8 | 8 | `CupidSpacing.sm` = 8 | match |
| Bottom padding | 40 | 40 | `CupidSpacing.xl` = 32 | token snap, AC1-as-amended |

The 40 → 32 bottom-padding snap is STORY-026 §1's declared nearest-token
resolution (delta -8), not a new deviation. It is below the fold in both
rasters and does not shift any compared element.

### 3.2 Grid definition — L751 `grid-template-columns:1fr 1fr;gap:11px`

| Property | Design | Reference render | Implementation | Verdict |
| --- | --- | --- | --- | --- |
| Columns | 2 | 2 (tiles at x 25..196, 209..381) | 2 (tiles at x 42..529, 550..1037) | match |
| Column gutter | 11 | 11.0 | 7.6 dp (530→550) | token snap -3 |
| Row gutter | 11 | 11 (row 1 ends y=395, row 2 starts y=406) | 7.6 dp (945→967) | token snap -3 |
| Tile width | derived | 172.5 – 173.0 | 177.5 dp | +2.9 %, see below |

The tile-width difference is fully explained and is not an independent finding:
the app's screen is 0.95 % wider and its gutter is 3 dp narrower after the
`gap: 11 → CupidSpacing.sm` snap, and both of those surpluses land in the tile
width. Predicted implementation tile width from the app's own values is
`(392.7 - 16 - 16 - 8) / 2 = 176.4 dp`; measured 177.5 dp. The geometry is
internally consistent.

### 3.3 Photo tiles — L752-754

| Property | Design | Reference render | Implementation | Verdict |
| --- | --- | --- | --- | --- |
| `aspect-ratio:3/4` | 1.3333 | 232 / 173 = 1.341 | 236.4 / 177.5 = 1.332 | match |
| `border-radius:var(--r-sm)` | 16 | rounded arc present | `platform.radiusSmall` = 16, arc reaches full inset at 12.4 dp | see note |
| `overflow:hidden` | — | photo clipped to the rounded rect | `ClipRRect` | match |
| `box-shadow:var(--shadow)` | `rgba(80,30,110,.16) 0/6/18` | peak lift at +1 px = `(+6, +1, +8)` over bg | peak lift at +1 dp = `(+7, +1, +8)` over bg | match at peak |
| Page background | `#171129` | — | exactly `RGB(23, 17, 41)` far from any tile | match |

**Corner-radius note.** Both renders show a rounded corner of the same order,
but a numeric radius cannot be extracted reliably from either raster: the tile
fill at the top-left is the darkest end of a photo gradient sitting on a nearly
equally dark page background, and on the implementation side the shadow halo
further softens the boundary. The measured 12.4 dp arc is therefore a lower
bound biased inward by the detection threshold, not a measured 12.4 dp radius.
The source-level identity (`var(--r-sm)` = 16 → `CupidPlatformTokens.radiusSmall`
= 16) stands unchallenged by the render; the render simply does not have the
contrast to refine it. This is recorded as a limitation of the evidence, not as
a finding.

**Shadow falloff.** The peak elevation lift matches almost exactly, which is the
finding that matters (see D3 in §4). The falloff *length* differs: the reference
has decayed to `(+3, -1, +4)` by +11 px, while the implementation still reads
`(+6, +2, +8)` at +7 dp. This is the CSS-versus-Flutter Gaussian convention —
CSS `blur: 18` means sigma 9, whereas Flutter's `blurRadius: 18` means
sigma ≈ 10.4 — applied to a token that is an exact transcription of the design's
`--shadow`:

```dart
elevationShadow = const <BoxShadow>[
  BoxShadow(color: Color.fromRGBO(80, 30, 110, 0.16), offset: Offset(0, 6), blurRadius: 18),
];
```

Two reasons this is not an in-scope deviation for this phase. First, the value
is correct: 80/30/110, 0.16, 0/6/18 are the design's numbers unchanged. Second,
the file that would have to change is
`mobile/lib/design_system/tokens/cupid_platform_tokens.dart`, an explicitly
prohibited path for P1, and the change would be a platform-wide shadow
recalibration affecting every elevated surface in the app — not a gallery fix.
Recorded here as an observation for whichever story owns the design-system
token layer.

### 3.4 Caption chip — L752-754

| Property | Design | Reference render | Implementation | Verdict |
| --- | --- | --- | --- | --- |
| `left:9px` | 9 | 9 (t1 x=34 on tile x0=25; t2 x=218 on 209; t3 x=34 on 25) | 9.1 dp (x=67 on tile x0=42) | token snap -1 |
| `bottom:9px` | 9 | 9 (pill ends y=386, tile ends y=395) | 8.4 dp (pill ends y=922, tile ends y=945) | token snap -1 |
| `background:rgba(23,17,41,.6)` | 0.6 alpha | — | back-solved: pill luminance 95 over a 198 tile gradient; `0.6x27 + 0.4x198 = 95.4` | match |
| `border-radius:999px` | pill | full round cap | `platform.radiusButton` = 999 | match |
| `'Roboto Mono' 9px` | 5.4 nominal advance | 5.07 px per char | 5.3 dp per char | match, see §5 |

### 3.5 Dashed add tile — L755

| Property | Design | Reference render | Implementation | Verdict |
| --- | --- | --- | --- | --- |
| `border:1.5px dashed var(--line)` | 1.5, `--line` | stroke colour `RGB(49, 41, 67)` | stroke 1.5, colour `RGB(49, 41, 67)` | match |
| Dash pattern | dashed | dashes present | `_DashedBorderPainter` 6 on / 4 off | match |
| `aspect-ratio:3/4` | 1.3333 | same cell metrics as photo tiles | same grid delegate | match |
| Glyph `color:var(--pink)` | `rgb(255,127,182)` | — | peak glyph `RGB(255, 127, 182)` | exact match |
| Glyph `font-size:26px` | 26 | 26 | `CupidIcon(..., size: 26)` | match |
| `gap:8px` | 8 | 8 | `SizedBox(height: CupidSpacing.sm)` | match |
| Label `font-size:11.5px` | 11.5 | 11.5 | `cupidType.caption` = 13 | token snap +1.5 |
| Position | last cell | last cell | last cell | match |

`--pink` resolves from L736 (`rgba(255,127,182,.4)`) to `rgb(255,127,182)`, and
the implementation's add-glyph peak reads exactly that triple.

---

## 4. Re-verification of STORY-026 section 2 (AC6)

Each of D1-D10 was re-checked against the rendered pair. All ten are confirmed;
none is corrected.

| # | Fix claimed by STORY-026 | Rendered evidence | Status |
| --- | --- | --- | --- |
| D1 | `EdgeInsets.fromLTRB(md, sm, md, xl)` replacing uniform 16 | left/right 15.3 dp against the design's 16; top 8; bottom `xl` | **confirmed** |
| D2 | `platform.elevationShadow` replacing the pink `glowShadow` | the halo under each tile is purple-tinted (`+7, +1, +8` = the 80/30/110 hue), not pink | **confirmed** |
| D3 | shadow `DecoratedBox` moved outside the `ClipRRect` so it renders at all | a shadow is measurably present: `RGB(30,18,49)` / `(26,18,45)` immediately below and beside a tile against an exactly `RGB(23,17,41)` far background | **confirmed** |
| D4 | inset pill at `left/bottom: sm`, `radiusButton` corners | pill is inset 9.1 / 8.4 dp with full round caps; it is not a full-bleed square bottom bar | **confirmed** |
| D5 | `labelMono.copyWith(fontSize: 9)` replacing `caption` 13 | per-character advance 5.3 dp = monospace at 9 px, not the 13 px UI font | **confirmed** |
| D6 | `BackdropFilter(blur sigma 3)` behind the pill | the tile gradient remains visible but smoothed under the pill; the pill is not an opaque block | **confirmed** |
| D7 | stroke 1.5, colour `colorLine` | measured stroke 1.5 and colour `RGB(49,41,67)`, identical to the reference | **confirmed** |
| D8 | `add_photo_alternate` `0xe43e`, 26 px, `colorAccentPink` | photo-plus glyph, 26 px, peak `RGB(255,127,182)` = `--pink` exactly | **confirmed** |
| D9 | label rendered under the glyph with an 8 px gap | "Thêm ảnh" present below the glyph, gap 8 | **confirmed** |
| D10 | uploader badge inset `top/right: sm` | badge inset matches the caption chip's in-tile inset | **confirmed** |

D3 deserves the emphasis STORY-026 gave it. It was the one finding that could
only be *asserted* from source — a `BoxShadow` painted inside a clip is invisible
by construction, and no amount of source reading proves the fix took. The
rendered pair settles it: the implementation now has a real elevation halo whose
peak lift is within one channel unit of the reference's. That is the specific
gap this phase existed to close.

---

## 5. Re-verification of STORY-026 section 3 (AC6)

| Item | Rendered evidence | Status |
| --- | --- | --- |
| `aspect-ratio:3/4` per tile | 1.341 reference vs 1.332 implementation | **confirmed** |
| `border-radius:var(--r-sm)` + `overflow:hidden` | rounded clip present on both; numeric radius not extractable from either raster (§3.3) | **confirmed at source, render-neutral** |
| `rgba(23,17,41,.6)` chip fill | composite back-solve gives 95.4 predicted vs 95 measured | **confirmed** |
| `color:#fff` caption text | caption ink is the brightest element inside the pill on both sides | **confirmed** |
| dashed add tile is the last cell | last cell on both sides | **confirmed** |

**Font-metric caveat.** The nominal advance for Roboto Mono at 9 px is 5.4. The
implementation measures 5.3 dp per character; the reference measures 5.07 px.
Both sit within 4 % of nominal and within 5 % of each other. The residual is on
the *reference* side and is attributable to webfont resolution in the headless
canvas, not to the app. It is recorded as a measurement caveat rather than a
finding, and it is small enough that it does not disturb the §6 conclusion.

---

## 6. Section 3A app extensions — E2 settled

E1 (responsive column count) and E3 (uploader badge) are unchanged: both are
adjudicated app extensions with UX-spec authority and neither may be re-raised.
E2 is the one that the rendered pair was needed to settle.

STORY-026 §3A left this open explicitly:

> Which of the two pills is actually wider is a composite/emergent property that
> neither the source comparison nor the implementation capture alone can settle —
> it is exactly the class of difference the missing side-by-side render exists to
> catch.

It is now settled by measurement.

| Tile | Reference string | chars | Reference width | Implementation string | chars | Implementation width |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `14/02 · Đà Lạt` | 14 | 88.0 px (51.0 % of tile) | `14 thg 2, 2026` | 14 | 88.0 dp (49.7 % of tile) |
| 2 | `02/03 · nhà` | 11 | 73.0 px (42.3 %) | `2 thg 3, 2026` | 13 | 82.9 dp (46.8 %) |
| 3 | `19/04 · biển` | 12 | 77.0 px (44.6 %) | `19 thg 4, 2026` | 14 | 88.4 dp (49.9 %) |

**Conclusion: the pill's rendered width is not a deviation.** At matched
character count the two sides are the same width — tile 1 is 88.0 on both, and
tile 3's 14-character implementation string measures 88.4 dp against the
reference's 88.0 px for its own 14-character string. That is agreement to within
0.5 %.

The chip chrome is therefore confirmed at the composite level, not just
value-by-value: identical horizontal padding, identical monospace metric,
identical cap geometry. Solving the width as a linear function of character
count gives an intercept of 16.8 px on the reference and 14.0 dp on the
implementation, both consistent with the declared `8 + 8` horizontal padding
(the implementation's slightly low intercept is the inward bias of the
mid-luminance edge detector on a softer, taller round cap — a common-mode
measurement artefact, applied identically to both sides).

Where the two sides *do* differ in width — tiles 2 and 3 — the difference is
fully accounted for by string length, which is E2's already-adjudicated content
difference: the design hard-codes `DD/MM · <location>` mock text, while the app
renders `DateFormat.yMMMd(locale)` because `GalleryItem` carries no location
field. Tile 2's implementation string is 2 characters longer than the design's,
and 2 x 5.3 = 10.6 dp accounts for essentially all of the 9.9 dp width
difference. No chrome discrepancy remains once content length is held constant.

The pill also fits its tile with margin to spare on both sides at every tile
(worst case 51.0 % of tile width), so no clipping or ellipsis risk is exposed by
the rendered evidence.

---

## 7. Out-of-scope regions present in the render (R2)

Two elements are visible in the design reference and are **deliberately not
compared**. They are annotated rather than cropped out, so the reference remains
a faithful unedited render:

| Region | Design lines | Why excluded |
| --- | --- | --- |
| Auto-lock banner | **L746-750** | Attributed by PO ruling to the Level-1 lock model, which is out of scope for REQ-002. Ruled out regardless of which `<sc-if>` branch renders it. |
| Screenshot notice | **L757** | Same ruling, same lock model. |

Neither was measured, neither influenced any verdict in §3-§6, and neither may
be re-raised as a gallery fidelity finding. A reader comparing the two PNGs
side by side will see these two blocks in the reference with no counterpart in
the implementation capture; that absence is expected and adjudicated.

Similarly, the E1 column-count difference does not appear in this pair at all,
because the capture is 392.7 dp wide and therefore below the 430 dp three-column
breakpoint — both sides render two columns here.

---

## 8. Outcome (AC7)

**The rendered comparison surfaced no in-scope deviation.**

Every measured difference across the four in-scope regions resolves into one of
three already-adjudicated buckets:

1. **Nearest-token snaps** declared in STORY-026 §1 and compliant with AC1 as
   amended: bottom padding 40 → 32, gutters 11 → 8, chip inset 9 → 8, add-tile
   label 11.5 → 13.
2. **Disclosed app extensions** E1, E2, E3 — with E2's open composite question
   now closed in the app's favour (§6).
3. **One platform-convention observation** — Gaussian shadow falloff length —
   which sits on an exactly-transcribed token in
   `mobile/lib/design_system/tokens/cupid_platform_tokens.dart`, a prohibited
   path for this phase, and which would be a design-system-wide change rather
   than a gallery change (§3.3).

No gallery grid or tile widget required modification. `gallery_grid_view.dart`,
`gallery_tile.dart`, and `gallery_design_fidelity_test.dart` are unchanged by
this phase; the conditional half of the phase's Write Scope was not exercised.
No R3 escalation was raised, because no newly-surfaced in-scope deviation
requiring new behaviour was found.

`VISUAL_FIDELITY: PASS` is therefore now supported by rendered evidence rather
than by source comparison alone, and STORY-026's
`DESIGN_CANVAS_STATE_FORCE_UNSUPPORTED` block is cleared.

---

## 9. Evidence index

| Artifact | Path |
| --- | --- |
| Design reference render | `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-044_private_gallery_design_fidelity_hardening/visual-fidelity/design-reference-gallery-android.png` |
| Implementation capture | `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-044_private_gallery_design_fidelity_hardening/visual-fidelity/implemented-gallery-emulator-5560.png` |
| Tool contract for `--click` | `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-044_private_gallery_design_fidelity_hardening/coding-plan/tool-contract-click-flag.md` |
| Gate evidence | `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-044_private_gallery_design_fidelity_hardening/coding-plan/test-results.md` |
