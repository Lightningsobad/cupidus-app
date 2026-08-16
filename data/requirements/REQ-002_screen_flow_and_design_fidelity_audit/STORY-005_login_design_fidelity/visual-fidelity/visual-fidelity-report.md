VISUAL_FIDELITY: PASS

# Visual Fidelity Report: STORY-005 Login

Scope: REQ-002 / STORY-005_login_design_fidelity
Screen: `login` (Epic 1, NO_CHROME / NO_TABS)
Implementation: `mobile/lib/features/auth/presentation/screens/login_screen.dart`
Configuration audited: dark theme + `vi` locale (the only user-facing
combination per OQ5), both platform silhouettes (`CupidPlatform.ios` and
`CupidPlatform.material`).

---

# Visual Fidelity Audit — Android Runtime Capture

Everything from `## Design Source` downward is the original static
source-to-code audit and the record of the D-01..D-12 fixes that shipped. This
section is the later pixel audit of the *rendered* Android build against a
rendered image of the same design block, and it is the section that carries the
`VISUAL_FIDELITY` verdict.

## Verdict

`PASS` (re-verified 2026-08-16 against the post-patch captures).

The first pass of this audit returned `FAIL` on VF-02, VF-03 and VF-04. All
three were then fixed in code (commit `1ca0320`) and re-captured on device
(commit `51f60db`). This section's verdict is now based on the post-patch
frames, re-measured from the PNGs in this run — see
`## Patch Round 3 Re-Verification` for the measurements and
`## Findings` for the per-finding outcome.

Colour tokens, radii, screen padding, field gap, CTA geometry, the CTA
gradient, typography scale and social-button ordering matched at pixel level in
the first pass and still do. On top of that, the password visibility toggle
(VF-02) and both social brand marks (VF-04) are now present and match the
design source, and both field cards now measure the design's exact card height
(VF-03), so the three defects that produced the original `FAIL` are closed.
AC 3 is now `VERIFIED` on runtime evidence rather than a static reading.

The one authored element still missing from the render is the biometric
quick-unlock row (VF-01). That is an explicit user scope cut of 2026-08-15
recorded in `story_master.md` `## Out of Scope`, which states BF-01 "does not
block AC 1/AC 2 for this story" and routes real biometric login to a new,
properly scoped backlog story. VF-01 is therefore carried as `Excluded —
deferred by scope cut`, not as a fidelity failure of this story, and not
silently dropped. It is the only reason this screen is not a
whole-design-block match, and the follow-up story must close it.

Scope reminder: this verdict covers the Android render only. The iOS half stays
deferred under `## iOS Capture Deferred` (`IOS_NO_SIMULATOR`).

## Artifacts

| File | What it is |
|---|---|
| `implemented-login-android.png` | Canonical name for the runtime capture (byte-identical copy of `raw-capture/login-android.png`) |
| `design-reference-login-android.png` | The design source's `isLogin` block rendered at the capture's exact device metrics |
| `design-reference-login-android.html` | Standalone input used to produce that reference, so it is reproducible |
| `side-by-side-login-android.png` | Labelled comparison sheet; the reference panel is nudged down by the status-bar inset so both content columns align |
| `raw-capture/login-android.png` | Post-patch full-screen re-capture (overwritten at commit `51f60db`); the frame this verdict is measured from |
| `raw-capture/login-android-focused.png` | AC 3 focused state — EMAIL field focused |
| `raw-capture/login-android-filled.png` | AC 3 filled state — the design source's own `minh@gmail.com` / `loveyou247` values typed in |
| `raw-capture/login-android-error.png` | AC 3 error/validation state — `SignInFailed` from the live backend |

Note on staleness: `implemented-login-android.png`,
`side-by-side-login-android.png` and the first-pass rows of
`## Measured Comparison` were produced from the **pre-patch** frame.
`design-reference-login-android.png` is still current (it renders the design,
which did not change). Everything under `## Patch Round 3 Re-Verification` is
measured from the post-patch `raw-capture/*.png` files listed above.

## Method

`design-reference-login-android.png` is `Cupid Screens.dc.html` lines 1425-1458
(the `isLogin` block) plus its root screen container (line 44), decorations
(lines 45-47), content wrapper (line 66) and token blocks (lines 15-27),
transcribed verbatim with `data-plat="md"`, `data-theme="dark"`,
`data-lang="vi"`, and `bioLabel` resolved to its authored Android/`vi` value
(line 2438). It was rendered in headless Chromium at 1080x2400 with the layout
viewport scaled to 411.4x914.3 dp, which is the capture's own device pixel
ratio of 2.625 — measured from the capture itself, not assumed, by dividing the
rendered 11 dp inter-card gap (29 px) by its authored value.

Both images therefore share one coordinate space and 1 px = 1 px. The reference
uses the same `Nunito-Variable.ttf`, `Roboto-Variable.ttf` and
`MaterialSymbolsRounded-Variable.ttf` files that `mobile/assets/fonts` ships, so
no font-source drift is folded into the comparison. All figures below are
measured from the two PNGs by colour-transition scanning, not estimated by eye.

Two environment differences are not defects and are excluded from every delta:

- The capture carries a 48 dp Android status-bar inset (measured: system ink
  spans y 28-93 px) that the static design mock does not author, so the capture's
  content column starts 126 px lower. All vertical comparisons are
  content-relative.
- The design mock's inputs carry the placeholder values `minh@gmail.com` and
  `loveyou247`; the capture is the empty state. Card chrome is comparable, the
  typed value glyphs are not.

## Measured Comparison

First-pass table, measured from the **pre-patch** capture. Rows marked
"superseded" were re-measured after the fix — see
`## Patch Round 3 Re-Verification` for the current numbers.

| Property | Design reference | Android capture | Delta |
|---|---|---|---|
| Screen padding left / right | 20.2 / 19.8 dp | 19.8 / 20.6 dp | <=0.8 dp — pass |
| Heading ink height | 27.4 dp | 27.0 dp | 0.4 dp — pass |
| Heading ink width | 237.3 dp | 240.8 dp | +3.5 dp (1.4%) — pass |
| Field card height | 63.6 dp | 72.0 dp | superseded — now 63.62 dp, 0.00 dp delta (VF-03 fixed) |
| Field card width | 371.4 dp | 371.4 dp | 0 — pass |
| Field card corner radius | 24 dp | 24.0 dp | curves track within 0.4 dp — pass |
| Gap between field cards | 11.0 dp | 11.4 dp | 0.4 dp — pass |
| Card surface colour | `#241B42` (`--surf`) | `#241B42` | exact — pass |
| Micro-label colour | `#B4A6CE` (`--tx2`) | `#B4A6CE` | exact — pass |
| Micro-label ink height | 8.0 dp | 8.0 dp | 0 — pass |
| Password visibility toggle | 21.0 dp icon present | **absent** | superseded — now present, same ink box and origin as the reference (VF-02 fixed) |
| Forgot-link colour | `#FF7FB6` (`--pink`) | `#FF7FB6` | exact — pass |
| CTA height | 54.0 dp | 54.1 dp | 0.1 dp — pass |
| CTA gradient (t=.125..875) | `#F481C0`..`#C28AEC` | `#F681BE`..`#C08AED` | <=2/255 per channel — pass |
| CTA gradient endpoints | pill-edge antialiased | `#FF7FB6` -> `#B78CF5` | exact `--grad-hot` — pass |
| CTA corner radius | 26.7 dp (`--r-btn` pill) | 20.2 dp | AC 4-mandated (VF-06) |
| Biometric quick-unlock row | 52.0 dp present | **absent** | still absent — excluded by the 2026-08-15 scope cut (VF-01) |
| Divider label colour | `#B4A6CE` | `#B4A6CE` | exact — pass |
| Social button outer height | 52.2 dp | 49.9 dp | -2.3 dp (VF-05) |
| Social brand marks | Google SVG + Facebook glyph | **absent** | superseded — both now painted (VF-04 fixed) |
| Social button order | Google, then Facebook | Google, then Facebook | pass |
| Register link emphasis | `#FF7FB6` on `--tx2` sentence | same | pass |
| Decorative twinkles | 3, at 14%/8%, 9%/16%, 26%/7% | all 3 present, positions match | pass |

Inter-element gaps below the field group measure 17.1 dp against an authored
16 dp (forgot band, both sides) and 19.8 dp against an authored 18 dp
(CTA-to-divider, 16 dp gap + 2 dp margin). Both sit inside text-metric
tolerance between Chromium line boxes and Flutter's, and neither is a token
error; they are recorded for completeness, not as findings.

## Patch Round 3 Re-Verification

Re-measured 2026-08-16 from the four post-patch PNGs under `raw-capture/`,
against `design-reference-login-android.png`. Same method as the first pass:
colour-transition scanning of the actual pixels, 1080x2400 at DPR 2.625, so
1 px = 1 px between capture and reference. Numbers below are this run's own
measurements, not a transcription of `coding-plan/test-results.md`.

Content offset between the two coordinate spaces, re-derived here rather than
assumed: the reference's field cards start at y 276 / y 472 and the capture's at
y 419 / y 615, so the capture's content column sits exactly 143 px lower in
both cases (the Android status-bar inset). All vertical figures below are
content-relative on that basis.

### VF-03 — field card height

| Frame | Card 1 (EMAIL) | Card 2 (MẬT KHẨU) | Inter-card gap |
|---|---|---|---|
| Design reference | y 276..442 = 167 px = **63.62 dp** | y 472..638 = 167 px = **63.62 dp** | 29 px = 11.05 dp |
| Capture — empty | y 419..585 = 167 px = **63.62 dp** | y 615..781 = 167 px = **63.62 dp** | 29 px = 11.05 dp |
| Capture — focused | 167 px = 63.62 dp | 167 px = 63.62 dp | 29 px = 11.05 dp |
| Capture — filled | 167 px = 63.62 dp | 167 px = 63.62 dp | 29 px = 11.05 dp |
| Capture — error | 167 px = 63.62 dp | 167 px = 63.62 dp | 29 px = 11.05 dp |

Card height is now byte-for-byte the reference's 167 px in every state — a
0.00 dp delta against the design, down from +8.4 dp. Card width also matches:
975 px = 371.43 dp in both (capture x 52..1026, reference x 53..1027; the 1 px
origin shift is 0.38 dp and was already inside tolerance in the first pass).

Measurement note: on the filled and error frames a naive column scan through
the card centre is broken by the typed glyphs, which reads as a short card. The
figures above were taken on a text-free column (x 850) in every frame, so the
same card edges are compared across all four states.

### VF-02 — password visibility toggle

Present. Measured on the focused frame, which is free of the animated twinkle
that overlaps card 2's top-right corner on the empty and filled frames:

| Property | Design reference | Android capture |
|---|---|---|
| Glyph ink left edge | x 934 | x 934 — 0 px delta |
| Glyph ink top, relative to card top | 86 px | 86 px — 0 px delta |
| Glyph ink box | ~48 x 42 px (18.3 x 16.0 dp) | 48 x 42 px (18.3 x 16.0 dp) |
| Glyph ink colour | `--tx2` | `#B4A6CE` — exact |

The ink box is smaller than the authored 21 px because that is the font size,
not the glyph's inked extent; what matters is that both images ink the same box
at the same origin. `#B4A6CE` is `colorTextMuted` in
`mobile/lib/design_system/tokens/cupid_color_tokens.dart:64`, i.e. the mapped
`--tx2` token, not a literal.

A 3x magnified crop of the password card's right side in both images shows the
same `visibility_off` glyph — same eye outline, same slash angle, same stroke
weight, same position. This was read directly, not inferred from the numbers.

### VF-04 — social brand marks

Both marks are painted. Measured in the capture's social band:

| Mark | Design reference | Android capture |
|---|---|---|
| Google | x 198..241, y 1256..1300 = 44 x 45 px (16.8 x 17.1 dp) | x 197..241, y 1229..1274 = 45 x 46 px (17.1 x 17.5 dp) — <=1 px delta |
| Facebook | see caveat below | x 680..719, y 1232..1270 = 40 x 39 px (15.2 x 14.9 dp), `#1877F2` |

All four Google brand colours are present in the capture's social band
(`#4285F4`, `#34A853`, `#FBBC05`, `#EA4335`), and the mark sits before the
label with Google-first ordering preserved.

Caveat on the Facebook mark, found in this run: the reference PNG is **not**
pixel-truth for it. `design-reference-login-android.png` renders the design
HTML's Facebook glyph as a font-fallback artifact — a blue emoji face plus a
blue rectangle — because headless Chromium had no font covering that codepoint.
The capture renders a correct `#1877F2` "f" roundel. So for this one mark the
comparison basis is the authored source (`Cupid Screens.dc.html` line 1454:
18 px, `#1877F2`) plus the widget test asserting `0xFF1877F2`, not the
reference image. Flagging it so a later reader does not "fix" a correct
implementation to match a broken reference render.

### AC 3 — field states

All four states now have runtime evidence. The design source authors exactly
one static visual treatment per field card and no `:focus`, `:invalid` or
error styling anywhere (established in `coding-plan/test-results.md`
§ *Patch Round 3 Re-Capture + Field States*), so fidelity for the focused and
error states means the app must introduce **no** unauthored visual treatment.
That is what was tested here, by diffing the frames against each other:

| State | Evidence | Result |
|---|---|---|
| Empty | `login-android.png` | Card chrome matches the reference: `#241B42` surface, 24 dp radius, 63.62 dp height |
| Focused | `login-android-focused.png` diffed against the empty frame across the whole card band (y 400..800) | **12 pixels differ in the entire band**, all at x 997..1003 / y 624..628 — the decorative twinkle at a different animation phase. The focused EMAIL card is pixel-identical to its unfocused self |
| Filled | `login-android-filled.png` | Card geometry unchanged; differences confined to the input text ink rows. No chrome change |
| Error | `login-android-error.png` | Card geometry and chrome unchanged — no red border, no background shift on either card. Error message renders below the field group at y 820..854, ink `#FF6F91` |

Focus-treatment probe, run separately because a whole-band diff could hide a
1 px outline inside a large changed region: sampling x 200..900 at each card
edge row and +/-1 and +/-3 px outside it, across all four edges of both cards,
the maximum per-channel difference between the empty and focused frames is
**0**. No focus ring, underline, border or background change is introduced
anywhere. This matches the design source, which authors none.

The error text colour `#FF6F91` is `colorRed` at
`cupid_color_tokens.dart:75`, the `--red` token in this report's own
`### Token mapping used` table — so the error state, although it is an app
addition beyond the static mock, is rendered through a design token rather
than a hand-picked literal. `test/design_system/no_fork_guard_test.dart`
passing in the run below confirms no colour literal leaked into
`lib/features`.

### Build gate for this run

This run wrote no Dart source — it is comparison-only, confined to
`visual-fidelity/`. The gate was still re-run in the story worktree to confirm
the branch carrying the patch is green. `flutter` 3.44.1 / Dart 3.12.1 from
`~/flutter/bin` (not on the default `PATH`; export it before reproducing).

| Command | Result |
|---|---|
| `flutter analyze lib/features/auth/presentation/screens/login_screen.dart lib/design_system/icons/cupid_icons.dart test/features/auth/presentation/screens/login_screen_test.dart` | `No issues found! (ran in 1.8s)` |
| `flutter test test/features/auth test/design_system` | `00:04 +156: All tests passed!` |

## Findings

Status column reflects the 2026-08-16 re-verification above.

| Id | Finding | Design source | Status |
|---|---|---|---|
| VF-01 | Biometric quick-unlock row is absent. The design places a 52 dp full-width `--surf` pill at `--r-btn` with `--shadow`, a 21 px `--pink` `fingerprint` glyph and "Đăng nhập bằng vân tay", directly between the CTA and the "hoặc" divider. The capture has no surface band anywhere between the CTA bottom edge and the divider. | line 1446 | **EXCLUDED — deferred by scope cut.** Confirmed still absent in the post-patch capture. Not a FAIL for this story: `story_master.md` `## Out of Scope` records the user decision of 2026-08-15 to defer real biometric login to a new story ("does not block AC 1/AC 2 for this story"). Not re-litigated here. The follow-up Product Owner story must close it |
| VF-02 | Password `visibility_off` toggle is absent. The design turns the password card into a flex row with a 12 px gap and a right-aligned 21 px `--tx2` glyph; measured at x 930-986 in the reference. The capture's password card carries no ink right of x 247. | line 1441 | **PASS — fixed.** The toggle is present in the post-patch capture, inking the same box at the same origin as the reference (left edge x 934, 86 px below the card top in both) in exact `--tx2` `#B4A6CE`. Verified by direct reading of the magnified crop as well as by measurement |
| VF-03 | Both field cards render 72.0 dp tall against the design's 63.6 dp, a 13% overshoot repeated twice. Not a wrong constant: `_fieldCardPaddingV` (13), `_fieldLabelGap` (6), `_fieldLabelFontSize` (11) and `_fieldInputFontSize` (16) at `login_screen.dart:33-38` all match the source. The design's `<input>` line box measures 18.7 dp; the implemented input row measures ~27.1 dp, so the whole delta is the intrinsic height of `TextField`/`InputDecorator` surviving `isDense: true` + `contentPadding: EdgeInsets.zero` at `login_screen.dart:287-291` and `304-308`. | lines 1432-1439 | **PASS — fixed.** Both cards now measure 167 px = 63.62 dp, identical to the reference's own 167 px, in all four captured states. 0.00 dp delta, down from +8.4 dp |
| VF-04 | Social buttons render text-only. The design draws a 19 px Google SVG and an 18 px `#1877F2` Facebook glyph before each label. | lines 1449, 1454 | **PASS — fixed.** Google's 4-colour mark measures 45 x 46 px against the reference's 44 x 45 px (<=1 px), with all four brand colours present; Facebook paints a `#1877F2` roundel at 40 x 39 px. See the Facebook caveat in `## Patch Round 3 Re-Verification` — the reference PNG's own Facebook glyph is a font-fallback artifact, so the authored source is the comparison basis for that mark |
| VF-05 | Social button outer height is 49.9 dp against the reference's 52.2 dp. The design authors `height:50px` in the browser's content-box model, so its 1.5 px borders sit outside and total 53 px; `_SocialButton` treats 50 as the outer height with the border inside. | lines 1449-1454 | Accept — the implementation reading is the sane one; flagged so it is a decision, not a silent drift |
| VF-06 | CTA corner radius is 20.2 dp; the design HTML authors `--r-btn` (999 px), which renders as a 26.7 dp full pill. | line 1445 | Not a defect — AC 4 and `uiux-spec.md` §6 require a Material filled button at 20 dp on Android and reserve the pill for iOS. `_materialPrimaryCtaRadius` at `cupid_primary_button.dart:14` is the authoritative value here. |

## Acceptance Criteria

| AC | Result | Evidence |
|---|---|---|
| AC 1 — layout, spacing, colour/token usage and typography match exactly with no visible deviation | **PASS** (within the story's scope) | Every colour token, radius, gradient stop, padding and gap in `## Measured Comparison` matches, and the three visible deviations that failed the first pass are closed: VF-02 and VF-04 are present and matching, VF-03 is now a 0.00 dp delta. The only authored element still missing is VF-01, explicitly cut from this story's scope by the 2026-08-15 user decision, which `story_master.md` records as not blocking AC 1/AC 2. |
| AC 2 — deviations are corrected in the rendered app, not merely documented | **PASS** | D-01..D-12 plus VF-02, VF-03 and VF-04 are corrected in code (commit `1ca0320`) and confirmed *in the render* by the post-patch capture (commit `51f60db`), not merely documented. Nothing in scope remains documented-only. VF-01 is deferred by user decision, not left undone silently. |
| AC 3 — every form-field state present in the design source matches | **VERIFIED** | All four states captured at runtime: empty, focused, filled, error. Card geometry is 63.62 dp in every state. The focused frame differs from the empty frame by 12 pixels across the whole card band, all belonging to a decorative twinkle; the card-edge probe returns a maximum per-channel delta of 0. Since the design source authors no focus or error styling, the fidelity requirement is that the app add no unauthored treatment — and it adds none. Detail in `## Patch Round 3 Re-Verification`. |
| AC 4 — platform-adaptive CTA | **PARTIAL** | Android verified: 54.1 dp tall, exact `--grad-hot` fill, `--glow` shadow, 20.2 dp Material radius (VF-06). Ripple is not observable in a static frame. The iOS half is deferred — see `## iOS Capture Deferred`. |
| AC 5 — no new entry point | PASS | The capture was reached through the app's existing navigation; no entry point was added or changed. |

## iOS Capture Deferred

Blocker: `IOS_NO_SIMULATOR` — no iOS Simulator runtime is installed on this
machine, so no iOS frame of this screen can be produced here.

This is Android-only scope by the user's explicit "Android-only, defer iOS"
decision, not missing evidence and not a fidelity failure. The iOS half of AC 4
(full-width pill at `radiusButton`) and the iOS silhouette of every other
element stay unverified at runtime and carry only the widget-test coverage
listed under `## Verification`. Any later iOS pass should re-run this same
comparison with `data-plat="ios"` in `design-reference-login-android.html` and
the matching iOS device metrics.

## Verification For The First Audit Run

Historical — this is the gate as run during the first (pre-patch) audit pass.
The current run's gate is under
`## Patch Round 3 Re-Verification` -> `### Build gate for this run`.

That run changed no Dart source — it was comparison-only, and its writes were
confined to `visual-fidelity/`. The build gate was still re-run in the story
worktree to prove the branch is green, with `flutter` 3.44.1 / Dart 3.12.1 from
`~/flutter/bin` (not on the default `PATH`; export it before reproducing).

| Command | Result |
|---|---|
| `flutter pub get` | Got dependencies |
| `flutter analyze lib/features/auth/presentation/screens/login_screen.dart lib/design_system/adaptive/cupid_primary_button.dart` | `No issues found! (ran in 1.8s)` |
| `flutter test test/features/auth test/design_system` | `+151: All tests passed!` |
| `flutter test` | `+1242 ~2: All other tests passed!` (2 skipped) |

The counts are higher than the `## Verification` section further down because
that section records the story's own implementation round; this branch has since
taken in the wider REQ-002 work. At that point no test asserted field-card
height, which is why VF-03 survived a green suite and a CLEAN code review — it
was only observable in a render. That gap is now closed: the patch added
`both field cards measure the design-source 63.6dp` over both cards, so a
regression would fail the suite rather than needing another capture.

## Routing Note

**Superseded.** This note recorded that VF-02, VF-03 and VF-04 could not be
closed inside the comparison-only run's `WriteScope`. They were subsequently
routed to a code patch (commit `1ca0320`) and a re-capture (commit `51f60db`),
and all three are now closed — see `## Patch Round 3 Re-Verification`. The
"needs an asset/SVG pipeline" reading of VF-04 turned out to be avoidable:
`CupidBrandMarkIcon` paints the marks as vector paths, so no `assets:` section
or SVG renderer was required.

Still open for Scrum Master to route:

- **VF-01 / BF-01** — biometric quick-unlock row. Deferred by the 2026-08-15
  user decision; a new Product Owner story for real biometric login is
  required and, per `story_master.md`, has not been created yet.
- **iOS pass** — blocked on `IOS_NO_SIMULATOR`, see `## iOS Capture Deferred`.

`story_master.md` is again outside this run's declared `WriteScope`, so the
`[ ] Implementation` / `[ ] Review (Reviewer)` / `[ ] Patch round 3` lines are
left for Scrum Master to move.

---

## Design Source

Locked source: `cupid-app-design-system` (confirmed by `detect_design_source.py`).
Exact block audited: `cupid-app-design-system/project/Cupid Screens.dc.html`,
`<sc-if value="{{ isLogin }}">` block, lines 1425-1458.
CSS variable definitions: same file, lines 23-27.

Supporting spec (state behavior the static design source does not author):
`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-003_auth/ux/uiux-spec.md`
sections 4b, 6, 8.

### Token mapping used

| Design source | Flutter token |
|---|---|
| `--bg` | `CupidColorTokens.colorBackground` |
| `--surf` | `colorSurface` |
| `--line` | `colorLine` |
| `--tx` | `colorText` |
| `--tx2` | `colorTextMuted` |
| `--pink` | `colorAccentPink` |
| `--red` | `colorRed` |
| `--r-card` | `CupidPlatformTokens.radiusCard` |
| `--r-btn` | `CupidPlatformTokens.radiusButton` |
| `--shadow` | `CupidPlatformTokens.elevationShadow` |
| Nunito 900 | `CupidTypographyTokens.display` |
| `--fs-ui` | `CupidTypographyTokens.body` / `.caption` |

Values verified identical between `Cupid Screens.dc.html` lines 23-27 and
`mobile/lib/design_system/tokens/cupid_color_tokens.dart` /
`cupid_platform_tokens.dart` — no token drift found.

Point metrics on this screen (12/20/40 screen padding, 16 section gap, 11 field
gap, 13/16 card padding, 27 heading, 50/54 button heights) sit off the 8pt
`CupidSpacing` scale, so they are carried as named design-source constants at
the top of `login_screen.dart` rather than snapped to the nearest token. This
follows the existing `_materialPrimaryCtaRadius` precedent in
`mobile/lib/design_system/adaptive/cupid_primary_button.dart`.

## Deviations Found And Fixed

| Id | Deviation (before) | Design source | Fix applied |
|---|---|---|---|
| D-01 | Screen padding `EdgeInsets.all(24)` plus a leading `SizedBox(height: 32)` spacer | `padding:12px 20px 40px` (line 1426) | `EdgeInsets.fromLTRB(20, 12, 20, 40)`; leading spacer removed |
| D-02 | Heading used `cardTitle` (platform UI font, w600, 22px), left-aligned | `font-family:Nunito;font-weight:900;font-size:27px`, centered (lines 1427-1428) | `type.display.copyWith(fontSize: 27)`, `textAlign: TextAlign.center` |
| D-03 | Subtitle line absent entirely | `font-size:13px;color:var(--tx2);margin-top:7px` — "Bae đang đợi ở trong đấy" / "Bae is waiting inside" (line 1429) | Added as `caption` + `colorTextMuted`, 7px below the heading. Also satisfies STORY-003 §4b "same subtext slot below it" for the session-expired variant |
| D-04 | No header block padding | `padding:14px 0 4px` (line 1427) | `EdgeInsets.only(top: 14, bottom: 4)` around the heading/subtitle pair |
| D-05 | Both fields were stock Material `TextField`s with a floating `labelText` and the default underline border (pink focus underline) | `--surf` card at `--r-card` with `--shadow`, `padding:13px 16px`; static uppercase micro-label `font-size:11px;letter-spacing:.06em;color:var(--tx2);margin-bottom:6px`; input `border:none;outline:none;color:var(--tx);font-size:16px;padding:0` (lines 1432-1439) | New `_FieldCard`: `DecoratedBox` (`colorSurface`, `radiusCard`, `elevationShadow`) + 16/13 padding + uppercase 11px/0.66 letter-spacing `colorTextMuted` label + `InputBorder.none`, `contentPadding: EdgeInsets.zero`, 16px `colorText` input |
| D-06 | Gap between the two fields was `CupidSpacing.sm` (8) | `gap:11px` (line 1431) | 11 |
| D-07 | Forgot link was a stock `TextButton` (theme `labelLarge` 14/w500, 12px horizontal padding so it did not sit flush right) | `align-self:flex-end;font-size:12.5px;font-weight:700;color:var(--pink)` (line 1444) | 12.5px / `FontWeight.w700` / `colorAccentPink`, `padding: EdgeInsets.zero`, `MaterialTapTargetSize.shrinkWrap`, right-aligned, wrapped in `ConstrainedBox(constraints: BoxConstraints(minHeight: context.cupidPlatform.tapTarget))` so the tappable hit area meets the 44/48 `--tap` minimum with zero visible pixel movement; the surrounding `forgotBandGap = max(0, (16*2 + 12.5*1.2 - tapTarget) / 2)` compensates the band so the CTA position holds |
| D-08 | "hoặc" was a bare centered caption with no rules | `flex` row: 1px `--line` rule, 12px gap, 11.5px `--tx2` label, 12px gap, 1px rule; `margin:2px 0` (line 1447) | `Row` with two `Expanded` 1px `colorLine` rules flanking an 11.5px `colorTextMuted` label, 12px gaps, 2px vertical margin |
| D-09 | Social buttons stacked vertically, Apple/Facebook **above** Google, stock `OutlinedButton` height/border/typography | Single row `gap:10px`, **Google first**, each `flex:1;height:50px;border-radius:var(--r-btn);border:1.5px solid var(--line);font-size:14px;font-weight:700` (lines 1448-1456) | New `_SocialButton` in a `Row`: Google then Apple (iOS) / Facebook (Material), 10px gap, 50px tall, `radiusButton` pill, 1.5px `colorLine` border, 14px/w700 `colorText` label |
| D-10 | Register link was a stock `TextButton` with the whole sentence in `--tx2` | `text-align:center;font-size:13px;color:var(--tx2);margin-top:6px` with `<strong style="color:var(--pink)">Đăng ký</strong>` (line 1457) | Centered `Text.rich`: 13px `colorTextMuted` sentence with "Đăng ký" / "Sign up" in w700 `colorAccentPink`; +6px top margin |
| D-11 | Root vertical rhythm mixed `CupidSpacing.sm` (8), `.lg` (24) and `.xl` (32) | `gap:16px` uniformly between all direct children (line 1426) | Uniform 16px section gap between every root child |
| D-12 | Inline error gap was `CupidSpacing.sm` (8) and sat outside the field group | STORY-003 §6: `--red` inline message beneath the relevant field | 11px field gap, rendered inside the field group directly beneath the password card, `caption` + `colorRed` |

## Form Field States (AC 3)

Scope note: the table below is the static source-to-code reading and is
unchanged. It is no longer the only evidence for AC 3 — every row is now backed
by a runtime capture, and the runtime results agree with the static reading
throughout. See `### AC 3 — field states` under
`## Patch Round 3 Re-Verification` for the frames and the measurements.

The VF-03 caveat that used to apply to every row here is closed: the card
height is 63.62 dp in all four captured states.

| State | Design source | Rendered result |
|---|---|---|
| Empty | Card + uppercase micro-label, no placeholder text authored | Matches — the label is a static sibling, never a floating placeholder; no hint text invented |
| Focused | `outline:none` on the input, so the card shows **no** focus ring or underline | Matches after D-05 — `InputBorder.none` removes the Material focused underline that previously painted in `colorAccentPink`. Caret uses the theme primary (`colorAccentPink`), the only focus affordance |
| Filled | 16px `--tx` on `--surf` | Matches — `body.copyWith(fontSize: 16, color: colorText)` |
| Error / validation | Not authored in the design source | Follows STORY-003 §6: `--red` (`colorRed`) caption beneath the password field, label restored and button re-enabled. No design-source state was contradicted |

## Platform-Adaptive CTA (AC 4)

The primary CTA stays `CupidPrimaryButton`, the design system's adaptive
widget: iOS renders a full-width pill at `radiusButton`; Material renders a
filled button at 20dp with ripple. This is the pattern AC 4 requires and the
one STORY-001 §6 / STORY-003 §8 make authoritative for this screen. No
platform fork was introduced in feature code — the `no_fork_guard_test`
substring scan still passes.

## Deferred — Outside This Story's WriteScope

Each item below is a real design-source element that cannot be delivered by
editing `login_screen.dart` alone. None is a regression; all are recorded here
for Scrum Master to route.

Status after the 2026-08-16 re-verification: DEF-01 and DEF-03 are **resolved**
(they were VF-02 and VF-04, both now present in the render). DEF-02 is the
biometric row, now an explicit scope cut rather than a `WriteScope` limitation.
DEF-04 was already resolved. DEF-05 remains unobservable in a static frame.
Only DEF-02 and DEF-05 are still open.

| Id | Gap | Blocking file / change (outside WriteScope) |
|---|---|---|
| DEF-01 | ~~Password `visibility_off` toggle (21px, `--tx2`, right-aligned in the password card, line 1441)~~ **RESOLVED.** `CupidIcons.visibilityOff` was added with the codepoint read from the bundled font cmap, and the toggle renders correctly — see VF-02 | n/a — closed |
| DEF-02 | Biometric quick-unlock row (`fingerprint` + `bioLabel`, 52px `--surf` pill with `--shadow`, line 1446) | **Now a scope cut, not a `WriteScope` limitation.** Deferred to a new story by the 2026-08-15 user decision. Still needs a biometric capability (`local_auth` dependency + iOS/Android platform config); STORY-003 §9 flags the scope of this row as an open Tech Lead question |
| DEF-03 | ~~Brand marks inside the social buttons (Google 19px SVG, Apple glyph, Facebook 18px `#1877F2`)~~ **RESOLVED for Google and Facebook.** No SVG renderer or `assets:` section was needed after all: `CupidBrandMarkIcon` paints transcribed vector paths — see VF-04. Apple's button stays text-only; it was never flagged and is outside this story's scope | n/a — closed for the two flagged marks |
| DEF-04 | ~~CTA visual delta: design HTML is 54px tall, `--grad-hot` fill, `--glow` shadow, 16.5px/w800. `CupidPrimaryButton` renders a solid `--pink` fill at `tapTarget` height~~ **STALE — RESOLVED.** `cupid_primary_button.dart:20,53,55` now carry `_primaryCtaHeight = 54`, `gradient: colors.gradientHot` and `boxShadow: colors.glowShadow`. The Android capture measures 54.1 dp with endpoints `#FF7FB6` -> `#B78CF5`, i.e. exact `--grad-hot`, and a visible glow. No CTA delta remains | n/a — closed |
| DEF-05 | Inline spinner on CTA submit (STORY-003 §6) | Not authored in the design source (this story's Out of Scope) and needs a child slot on `CupidPrimaryButton` |

## Reviewer Note

Both the `--tap` 44/48 minimum from STORY-001 and AC 1 ("no visible
deviation") are satisfied for the "Quên mật khẩu?" / forgot-password link and
the register link: each is wrapped in a `ConstrainedBox` that raises the
tappable hit area to `context.cupidPlatform.tapTarget` without moving a single
rendered pixel. For the forgot link, the hit box grows upward into the
surrounding `gap:16` band, which the paired `forgotBandGap` compensation
keeps symmetric; for the register link, the hit box grows downward into the
already-unpainted 40pt of bottom screen padding. There is no remaining
tension between fidelity and the tap-target minimum on this screen, and no
open UX decision is needed. (Round-2 review, commit `8b19291`.)

## Out Of Scope Confirmed Untouched

- Credential-submission and post-sign-in navigation logic (`SignInCubit`
  wiring, `SignInSuccess` -> `HomeScreen`, `_openForgot`, `_openRegister`)
  is byte-for-byte unchanged — Scope A / STORY-001 / STORY-002 own it.
- No new screen, state, or interaction was added.
- No light theme / `en` locale visual pass was performed (OQ5). Every fix is
  token-driven, so it stays correct across all four combinations.

## Verification

Run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-005/mobile`
with `flutter` 3.44.1 / Dart 3.12.1 on PATH.

| Command | Result |
|---|---|
| `flutter pub get` | Got dependencies |
| `flutter analyze lib/features/auth/presentation/screens/login_screen.dart test/features/auth/presentation/screens/login_screen_test.dart` | `No issues found!` |
| `flutter analyze` | 94 issues, all pre-existing (`prefer_initializing_formals` infos across `lib/**` and `unused_import` warnings in generated `openapi/cupid_api/**`); none in the changed files |
| `flutter test test/features/auth test/design_system` | `+63: All tests passed!` |
| `flutter test` | `+933: All tests passed!` |

New suite:
`mobile/test/features/auth/presentation/screens/login_screen_test.dart`
(13 widget tests, dark theme + `vi` locale, both platform silhouettes) asserts
the heading typography, the subtext slot, the session-expired heading swap,
the uppercase-labelled borderless surface cards, the forgot-link style and
right alignment, the flanked "hoặc" divider, Google-first social ordering with
the platform-correct second provider, the 50px button height, the pink
"Đăng ký" emphasis, and (added in the round-2 patch) the 44/48 `--tap`
minimum hit area on both the forgot-password and register links, parameterised
over both `CupidPlatform` values and asserted against the real laid-out box
via `tester.getSize`.

Round-2 patch verification (commit `8b19291`, independently re-run by the
reviewer): `flutter analyze` on the two changed files — `No issues found!
(ran in 1.5s)`; `flutter test test/features/auth/presentation/screens/login_screen_test.dart`
— `+13: All tests passed!`; `flutter test test/features/auth test/design_system`
— `+63: All tests passed!`; `flutter test` (full suite) — `+933: All tests
passed!`. Counts moved 59 -> 63 and 929 -> 933, consistent with +4 additions
and no regressions.

Pre-existing coverage kept green: `splash_screen_test.dart`'s session-expired
assertion (`find.text('Sign in again to continue')`) and
`test/design_system/no_fork_guard_test.dart`.

No device install, emulator provisioning, toolchain setup, or release
configuration was performed — build verification only, per handoff scope.
