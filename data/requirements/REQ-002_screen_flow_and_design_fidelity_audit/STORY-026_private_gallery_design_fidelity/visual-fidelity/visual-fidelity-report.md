# STORY-026 — Visual Fidelity Report: Private Gallery

```text
VISUAL_FIDELITY: FAIL
Design-Screen: gallery
Design-Source: cupid-app-design-system/project/Cupid Screens.dc.html
Design-Block: <sc-if value="{{ galleryOpen }}"> L736-751
Platform: Android (material), dark theme, locale vi
Device: emulator-5560 (sdk gphone64 arm64, 1080x2400, dpr 2.75)
Date: 2026-08-13
```

`FAIL` is **not** caused by an unfixed pixel deviation. Every deviation in the
audited surface was corrected in code and is verified in the rendered capture
(sections 2, 3). The verdict is `FAIL` because **AC3 cannot be satisfied as
written**: the story asks for a Level-1 lock / re-auth affordance that two
authoritative REQ-001 artifacts explicitly forbid, and the design-reference PNG
for this screen captures exactly that forbidden state. This needs a Product
Owner / Scrum Master ruling, not a mobile-dev decision. See section 5.

---

## 1. Comparison Basis

| Axis | Value |
| --- | --- |
| Canvas screen id | `gallery` (registry entry L1885: `{ id: 'gallery', icon: 'photo_library', vi: 'Private Gallery' }`) |
| Screen predicate | `isGallery: sc === 'gallery'` (L2251) |
| Audited state block | `<sc-if value="{{ galleryOpen }}">` L736-751 |
| Non-audited state block | `<sc-if value="{{ galleryLocked }}" hint-placeholder-val="{{ true }}">` L725-735 |
| App screen under audit | `mobile/lib/features/gallery/presentation/screens/gallery_screen.dart` → `GalleryGridView` → `GalleryTile` |
| Token block | `Cupid Screens.dc.html` L23-26 |

### CSS variable → Flutter token map used for this screen

| Design source | Flutter token | Value |
| --- | --- | --- |
| `var(--r-sm)` / `image-slot radius="16"` | `CupidPlatformTokens.radiusSmall` | 16 |
| `border-radius:999px` | `CupidPlatformTokens.radiusButton` | 999 |
| `box-shadow:var(--shadow)` | `CupidPlatformTokens.elevationShadow` | `rgba(80,30,110,.16) 0/6/18` |
| `var(--line)` | `CupidColorTokens.colorLine` | dashed add-tile border |
| `var(--pink)` | `CupidColorTokens.colorAccentPink` | add-tile glyph |
| `var(--tx2)` | `CupidColorTokens.colorTextMuted` | add-tile label |
| `#fff` (caption chip) | `CupidColorTokens.dark().colorText` | caption text |
| `'Roboto Mono' 9px` | `CupidTypographyTokens.labelMono.copyWith(fontSize: 9)` | see note below |
| `rgba(23,17,41,.6)` | literal `Color.fromRGBO(23, 17, 41, 0.6)` | no token exists; already the pre-existing app value |

`labelMono` carries no `fontSize` by design — `cupid_typography_tokens.dart`
L51-56 states the role is documented without a point size and that "callers
size it per context". Sizing it at the use site is the sanctioned pattern, not
a fork.

### Spacing values that snap to the token scale

`CupidSpacing` is `xs 4 / sm 8 / md 16 / lg 24 / xl 32`. The design source uses
raw CSS pixels; each was snapped to its nearest token rather than forked into a
literal, per the no-fork guard (`mobile/test/design_system/no_fork_guard_test.dart`).

| Design px | Token used | Delta |
| --- | --- | --- |
| `padding: 8px` (grid top) | `CupidSpacing.sm` (8) | 0 |
| `padding: 16px` (grid sides) | `CupidSpacing.md` (16) | 0 |
| `padding: 40px` (grid bottom) | `CupidSpacing.xl` (32) | -8 (nearest available) |
| `gap: 11px` (grid gutters) | `CupidSpacing.sm` (8) | -3 (nearest available) |
| `left/bottom: 9px` (caption chip) | `CupidSpacing.sm` (8) | -1 |
| `padding: 3px 8px` (caption chip) | `xs` (4) / `sm` (8) | +1 / 0 |
| `font-size: 11.5px` (add-tile label) | `cupidType.caption` (13) | +1.5 (smallest UI-font role) |

---

## 2. Deviations Found And Fixed

| # | Design source | Was | Now |
| --- | --- | --- | --- |
| D1 | `padding:8px 16px 40px` (L737) | `EdgeInsets.all(CupidSpacing.md)` — uniform 16 on all sides | `EdgeInsets.fromLTRB(md, sm, md, xl)` |
| D2 | `box-shadow:var(--shadow)` (L744-746) | `colors.glowShadow` — wrong token (`--glow`, the pink CTA glow) | `platform.elevationShadow` (`--shadow`) |
| D3 | same | shadow `DecoratedBox` nested **inside** the corner `ClipRRect`, so the shadow was clipped away and never rendered at all | shadow `DecoratedBox` moved outside the clip; `ClipRRect` is now its child |
| D4 | `left:9px;bottom:9px;padding:3px 8px;border-radius:999px` (L744) | full-bleed bottom bar pinned `left:0 right:0 bottom:0`, square corners | inset pill at `left/bottom: sm`, `radiusButton` corners |
| D5 | `font-family:'Roboto Mono';font-size:9px` (L744) | `cupidType.caption` (platform UI font, 13) | `cupidType.labelMono.copyWith(fontSize: 9)`, `maxLines: 1` + ellipsis |
| D6 | `backdrop-filter:blur(6px)` (L744) | absent | `BackdropFilter(ImageFilter.blur(sigma 3))` inside a chip-shaped `ClipRRect` (CSS blur radius ≈ 2× Gaussian sigma) |
| D7 | `border:1.5px dashed var(--line)` (L747) | `strokeWidth: 2`, colour `colors.colorTextMuted` | `strokeWidth: 1.5`, colour `colors.colorLine` |
| D8 | `<span data-icon style="font-size:26px;color:var(--pink)">add_photo_alternate</span>` (L747) | `CupidIcons.add` (generic plus), `variant: line`, 32px, `colorTextMuted` | `add_photo_alternate` glyph (`0xe43e`), 26px, `colorAccentPink` |
| D9 | `<div style="font-size:11.5px;color:var(--tx2)">Thêm ảnh / Add photo</div>` (L747) | no label at all — icon only, vertically centred | label rendered under the glyph, `gap: 8px` → `SizedBox(height: CupidSpacing.sm)`, `Column` with `mainAxisAlignment.center` |
| D10 | uploader badge overlay inset (app addition, aligned to the design's 9px in-tile overlay inset) | `top/right: CupidSpacing.xs` (4) | `top/right: CupidSpacing.sm` (8) |

D3 is a genuine rendering bug, not only a token mismatch: because
`BoxShadow` was painted by a child of the clip, the gallery tiles shipped with
no elevation at all.

D8 note: `0xe43e` is the `add_photo_alternate` codepoint in the bundled
`MaterialSymbolsRounded-Variable.ttf` and is the same codepoint
`gallery_empty_view.dart` already resolves. It is declared as a file-local
`IconData` in `gallery_grid_view.dart` rather than added to `CupidIcons`
because this story's `WriteScope` does not include
`mobile/lib/design_system/icons/cupid_icons.dart`. Promoting it into
`CupidIcons` is a clean follow-up for whichever story owns the design-system
icon set.

---

## 3. Verified Correct (no change needed)

| Design source | App |
| --- | --- |
| `aspect-ratio:3/4` per tile | `AspectRatio(aspectRatio: 3 / 4)` in both `GalleryTile` and the grid delegate |
| `border-radius:var(--r-sm)` on the photo, `overflow:hidden` | `ClipRRect(borderRadius: circular(platform.radiusSmall))` |
| `background:rgba(23,17,41,.6)` caption chip fill | already exact |
| `color:#fff` caption text | `CupidColorTokens.dark().colorText` |
| dashed add tile is the **last** cell | `GalleryGridView` pins it at `index == totalCount - 1` |
| `grid-template-columns:1fr 1fr` | resolves to 2 columns at phone width via `galleryColumnCount()`; the responsive column count is mandated by `ux/uiux-spec.md` §4.6 and is a deliberate app extension of the fixed 2-up canvas |

---

## 4. Design-System Files Touched

None. All fixes consume existing `CupidSpacing`, `CupidColorTokens`,
`CupidPlatformTokens`, and `CupidTypographyTokens` values. No new token, no
literal colour, and no platform branch was introduced;
`mobile/test/design_system/no_fork_guard_test.dart` passes.

---

## 5. Deferred / Blocked, With Rationale

### 5.1 AC3 premise conflict — the reason this report reads FAIL

AC3 asks for the Level-1 lock / re-auth affordance, "present and styled per the
design source". Two authoritative REQ-001 artifacts rule that UI out of bounds:

- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-013_gallery/architecture/solution.md`
  — "No client-side encryption, biometric unlock, auto-lock, or screenshot
  detection"; "Level-1 device-only encryption / biometric / auto-lock /
  screenshot-detection UI is BLOCKED"; Open Item #1 "Resolved (Product
  Owner) … Shared model only"; R3 "Closed by this solution — NO".
- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-013_gallery/ux/uiux-spec.md`
  §2 — the lock/fingerprint-unlock gate, the "unlocked · auto-locks in 60s"
  countdown banner, and the "screenshots are detected" notice are
  "**explicitly not reused**" from the `gallery` canvas screen. §4.5 mandates
  `link_off` pairing-gate iconography, "not the `lock`/Secure-Enclave
  iconography".

The product has no re-auth mechanism, no client-side encryption, and no
screenshot detection. Rendering those cues would assert security properties the
app does not have — a user-facing false claim, not a styling choice. Mobile-dev
is also barred by the story's own Out of Scope line ("any change to the
underlying re-auth/PIN-gate logic").

Consequently the following design blocks are **not** implemented:

| Design source | Status |
| --- | --- |
| lock gate: pulsing ring, 58px `lock` glyph, "Chỉ mình bạn mở được", AES-256 / Secure Enclave copy, `fingerprint` unlock CTA (L726-734) | BLOCKED by REQ-001 architecture + UX spec |
| unlock banner: `lock_open`, "Đã mở · tự khoá lại sau 60 giây", `00:58` mono countdown (L738-742) | BLOCKED — asserts an auto-lock that does not exist |
| screenshot notice: `no_photography`, "Chụp màn hình sẽ bị phát hiện" (L749) | BLOCKED — asserts detection that does not exist |

What the app renders instead of the lock gate is the pairing gate in
`gallery_locked_view.dart`, per `uiux-spec.md` §4.5.

**Requested ruling:** amend or drop AC3, or open a separate requirement to
build real Level-1 protection first. Mobile-dev cannot resolve this.

### 5.2 Design-reference PNG captures the blocked state

`design-reference-gallery-android.png` (the only baseline PNG that exists for
`Design-Screen: gallery`) renders the `galleryLocked` branch — the canvas marks
it `hint-placeholder-val="{{ true }}"`, so the locked state is the canvas
default. A pixel-to-pixel comparison against the implemented open grid is
therefore not meaningful; the two images are different `<sc-if>` branches of the
same screen. The implemented capture was compared against the `galleryOpen`
source block (L736-751) value by value instead, as tabulated in sections 2-3.

### 5.3 Out of scope by the story's own terms

- Light theme and `en` locale visual QA — OQ5, out of scope; only dark + `vi`
  was audited and captured.
- No new entry point was added (AC4 holds).

---

## 6. Files Changed

| Path | Change |
| --- | --- |
| `mobile/lib/features/gallery/presentation/widgets/gallery_grid_view.dart` | D1, D7, D8, D9 |
| `mobile/lib/features/gallery/presentation/widgets/gallery_tile.dart` | D2, D3, D4, D5, D6, D10 |
| `mobile/test/features/gallery/gallery_design_fidelity_test.dart` | new — 6 widget tests pinning the corrected values to the design source |
| `mobile/test/features/gallery/gallery_capture_entry.dart` | new — `flutter run -t` capture harness (not a test; never runs in CI) |

Both touched `lib` files also carry three formatter-only hunks from
`dart format` (a `Tween` one-liner in `_GalleryShimmerTileState`, and two
statement reflows in `gallery_tile.dart`). They are canonical formatter output
for files this story already edits.

The capture harness sets `locale: const Locale('vi')` **with**
`GlobalMaterialLocalizations.delegates`. Those delegates are what initialize
`intl` date-symbol data for `vi`; without them `GalleryTile`'s
`DateFormat.yMMMd('vi')` throws and every tile renders as a bare release-mode
`ErrorWidget` (grey box). The shipping app is unaffected — it already installs
the global delegates — but the first capture attempt of this story hit exactly
that and is why the harness mirrors the real app's localization setup.

---

## 7. Rendered Evidence

| Role | Path | sha256 |
| --- | --- | --- |
| Implemented | `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-026_private_gallery_design_fidelity/visual-fidelity/implemented-gallery-emulator-5560.png` | `c9fbce3cb1150013eeb4f14a37b10854766eaf39b0dbc50d7c34979d41b90e08` |
| Design reference (locked state — see 5.2) | `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/design-reference-gallery-android.png` | `8e5d419f38ff1cc72a5d15e141abbe785ec2bd2ec35a7961e9cfd0e24a987db5` |

How the implemented capture was produced:

```bash
cd mobile
flutter run -d emulator-5560 \
  -t test/features/gallery/gallery_capture_entry.dart --release
adb -s emulator-5560 exec-out screencap -p \
  > ../data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-026_private_gallery_design_fidelity/visual-fidelity/implemented-gallery-emulator-5560.png
```

The harness renders `GalleryGridView` with three fake `GalleryItem`s and a
gradient image builder, so the tile chrome under audit (shadow, corner radius,
caption pill, uploader badge, dashed add tile) renders without a backend, a
paired couple, or the service locator. Photo bitmaps are not an audit
dimension; the chrome painted over them is.

Confirmed in the capture: rounded 16 corners, elevation shadow visible outside
the clip, bottom-left mono caption pill with blurred backdrop, top-right
uploader badges (pink `B` = self, purple `Đ` = partner), and the dashed add
tile with the pink `add_photo_alternate` glyph above a "Thêm ảnh" label.

---

## 8. Verification Run In This Session

| Command | Result |
| --- | --- |
| `flutter test test/features/gallery` | **45/45 passed** |
| `flutter test test/design_system` | **33/33 passed** (includes `no_fork_guard_test.dart`) |
| `flutter analyze lib/features/gallery test/features/gallery` | 1 issue: pre-existing `use_null_aware_elements` info at `gallery_api.dart:88`, a file this story does not touch. No error, no warning, nothing in the changed files. |

Repo-wide `flutter analyze` is not clean at baseline and is not a usable gate
here: it descends into the gitignored `mobile/build/` tree and reports hundreds
of errors from vendored `flutterfire` example sources, plus 77 pre-existing
`info` lints across `lib/`. Excluding `build/` from `analysis_options.yaml`
would fix that, but that file is outside this story's `WriteScope`.
