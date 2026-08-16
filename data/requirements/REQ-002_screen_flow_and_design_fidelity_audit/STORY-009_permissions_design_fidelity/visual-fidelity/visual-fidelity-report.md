# Visual Fidelity Report — STORY-009 Permissions

VISUAL_FIDELITY: PASS

Scope: design canvas id `permissions`, Android, enabled dark theme, `vi`
locale. Every element the design source's `isPermissions` block defines is
rendered to its declared CSS value. Three cross-screen chrome deltas remain
and are recorded as DEFERRED below — all three live in
`mobile/lib/design_system/**`, outside this story's write scope, and all
three reproduce identically on every other screen in the app.

## Design source resolution

| Field | Value | How it was confirmed |
|---|---|---|
| Source | `cupid-app-design-system` (locked) | `data/devops/system/design-fidelity-config.json` → `design_source.locked: true` |
| Entry | `cupid-app-design-system/project/Cupid App.dc.html` | `design_source.entry`; passing `--entry` is required, otherwise `render-design-canvas.js` exits `DESIGN_CANVAS_ENTRY_AMBIGUOUS` |
| Canvas id | `permissions` | `render-design-canvas.js --list-screens` returned 37 ids; `permissions` rendered and confirmed by looking at the PNG, not by name-matching alone |
| Markup | `cupid-app-design-system/project/Cupid Screens.dc.html` lines 1532-1548 (`isPermissions`) + its `permList` fixture | ranged read of the entry's included screen file |

## Artifacts

| Artifact | Path (relative to this directory) | Size |
|---|---|---|
| Design reference | `design-reference-permissions-android.png` | 406x900 |
| Implemented | `implemented-permissions-emulator-5554.png` | 405x900 |

Both frames are 412 logical px wide, so design CSS px and Flutter dp are 1:1
and every measurement below is directly comparable.

## Commands

```
# design reference
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location=cupid-app-design-system \
  --entry="Cupid App.dc.html" \
  --screen=permissions --platform=android \
  --out=<story>/visual-fidelity

# implemented (single exclusive device window)
.ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
  --lease-exec --device=emulator-5554 --lock-timeout=600 -- \
  bash -c 'adb -s emulator-5554 install -t app-debug.apk;
           adb -s emulator-5554 shell monkey -p com.snapsofts.cupid \
             -c android.intent.category.LAUNCHER 1;
           adb -s emulator-5554 shell am start -a android.intent.action.VIEW \
             -d "cupidpreview://screen/permissions";
           .ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
             --out=<story>/visual-fidelity --label=permissions \
             --device=emulator-5554 --width=412 --density=160 --settle-ms=3000'
```

The APK is the preview entrypoint,
`flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=permissions`.
`--density=160` pairs with `--width=412` deliberately: `--width` alone leaves
the emulator at 440 dpi, which collapses the logical width to ~150 dp and
renders every glyph at ~3x scale. That is the capture artifact STORY-018
recorded as a systemic "oversized text scale" defect across 12 screens
(`REQ-001/STORY-018_design_fidelity_capture/visual-fidelity/visual-fidelity-report.md`,
cross-cutting finding 1) — it is a measurement bug in that pass, not an app
bug, and pairing the two flags avoids reproducing it here.

The captured state is authored, not driven: `main_preview.dart`'s
`_buildPermissions` seeds `notifications` + `biometric` as granted and leaves
`photos` not-yet-decided, so both card states AC3 cares about are in one
frame, exactly as the design's `permList` fixture composes them.

## Per-state verdicts

### State 1 — granted permission card (`notifications`, `biometric`)

VISUAL_FIDELITY: PASS

| Property | Design source | Implemented | Match |
|---|---|---|---|
| Track | `background:{{ p.sw }}` = `var(--grad-hot)`, `50x30`, `border-radius:999px`, `padding:3px` | `colors.gradientHot`, `50x30`, radius 999, padding 3 | yes |
| Knob | `24x24`, `border-radius:50%`, `#fff` | 24x24 circle, `colors.colorText` | yes |
| Knob position | `justify-content:{{ p.j }}` = `flex-end` | `Alignment.centerRight` | yes |

### State 2 — not-yet-decided permission card (`photos`)

VISUAL_FIDELITY: PASS

| Property | Design source | Implemented | Match |
|---|---|---|---|
| Track | `{{ p.sw }}` = `var(--line)` (flat, no gradient) | `colors.colorLine`, `gradient: null` | yes |
| Knob position | `{{ p.j }}` = `flex-start` | `Alignment.centerLeft` | yes |

The two states are visually distinct in the capture and structurally pinned
by `test/features/onboarding/permissions_screen_test.dart` → "granted and
not-yet-decided cards use distinct track styling", which asserts
`gradient == gradientHot / color == null` against `gradient == null / color
== colorLine`. No golden file was added: the repository has no golden-test
infrastructure at all (`git ls-files mobile/test | grep golden` is empty), and
establishing the first one is a repo-wide convention decision, not a trivial
story's call. The structural assertions pin the same property a golden would.

### State 3 — screen body (shared by both card states)

VISUAL_FIDELITY: PASS

| Element | Design source (`Cupid Screens.dc.html`) | Implemented | Match |
|---|---|---|---|
| Column padding / gap | `padding:16px 20px 40px`, `gap:13px` | `EdgeInsets.fromLTRB(20, 16, 20, 40)`, `_gap = 13` | yes |
| Title block | `padding:4px 0 6px` | `EdgeInsets.only(top: 4, bottom: 6)` | yes |
| Title | Nunito 900, 25px, `line-height:1.25` | `type.display` + `fontSize: 25, height: 1.25` | yes |
| Subtitle | 13px, `var(--tx2)`, `margin-top:8px` | `type.caption` + `colorTextMuted`, `SizedBox(height: 8)` | yes |
| Card | `padding:16px`, `var(--r-card)`, `var(--surf)`, `var(--shadow)`, `gap:13px`, `align-items:flex-start` | `EdgeInsets.all(16)`, `radiusCard`, `colorSurface`, `elevationShadow`, `_gap`, `CrossAxisAlignment.start` | yes |
| Icon tile | `44x44`, `border-radius:15px`, `{{ p.bg }}` = accent at `.2` alpha | 44x44, radius 15, `accent.withValues(alpha: 0.2)` | yes |
| Icon glyph | `<span data-icon style="font-size:23px;color:{{ p.color }}">` | `CupidIcon(..., size: 23, color: accent)` | yes |
| Card title | 15px, `font-weight:800`, default `--tx` | `fontSize: 15, FontWeight.w800`, `colorText` | yes |
| Card body | 12px, `line-height:1.5`, `var(--tx2)`, `margin-top:4px` | `fontSize: 12, height: 1.5`, `colorTextMuted`, `SizedBox(height: 4)` | yes |
| CTA | `margin-top:4px` (on top of the 13px gap), `height:54px`, `var(--r-btn)`, `var(--grad-hot)`, 16.5px/800, `var(--glow)` | `SizedBox(height: _gap + 4)`, height 54, `radiusButton`, `gradientHot`, `fontSize: 16.5, w800`, `glowShadow` | yes |
| Footer link | centered, 13px, `font-weight:700`, `var(--tx2)`, `padding:4px` | centered `TextButton`, `type.caption` + `w700` + `colorTextMuted` | yes |

### AC3 — iconography

VISUAL_FIDELITY: PASS

All three glyphs are Material Symbols Rounded, no emoji anywhere on the
screen. `permissions_screen_test.dart` → "AC3: every permission icon is a
Material Symbols Rounded glyph" asserts `fontFamily == CupidIcons.fontFamily`,
`variant == CupidIconVariant.filled` and `size == 23` for all three.

`CupidIcons` exposes `notificationsActive` but not `fingerprint` or
`photo_library`, and `design_system/icons/cupid_icons.dart` is outside this
story's write scope, so those two are declared locally in
`permissions_screen.dart`. Their codepoints (`0xe90d`, `0xe413`) were read out
of the bundled `assets/fonts/MaterialSymbolsRounded-Variable.ttf` cmap with
fontTools — not recalled from another icon font's PUA range, which is the
usual way a wrong-but-plausible glyph gets shipped. Both render correctly in
the capture.

Follow-up worth doing outside this story: promote `fingerprint` and
`photo_library` into `CupidIcons` so the next screen that needs them does not
redeclare the constants.

### Locale and platform copy

`Face ID` on iOS vs `Vân tay` on Android is the design source's own
`{{ p.title }}` split, driven here by `CupidPlatform.of(context)` and covered
by two tests. `vi` copy is transcribed verbatim from the `permList` fixture;
`en` is the fixture's `data-en` span. `mobile/lib/l10n/**` is outside this
story's write scope, so the copy resolves through a local `viEn(vi, en)`
`BuildContext` extension, following the existing
`features/auth/presentation/auth_strings.dart` precedent rather than
inventing a second pattern.

## DEFERRED — cross-screen chrome, outside this story's write scope

These three are visible when the two PNGs are placed side by side. None of
them is specific to `permissions`; each is a property of shared app chrome
that renders the same way on all 37 screens, and each lives in
`mobile/lib/design_system/**`, which this story's `WriteScope` excludes.
Fixing any of them inside `features/onboarding` would mean forking a shared
widget for one screen — the exact thing `test/design_system/no_fork_guard_test.dart`
exists to prevent.

1. **Backdrop gradient absent.** Design root is
   `background:var(--sky),var(--bg)` (`Cupid Screens.dc.html:44`) — a radial
   sky gradient layered over the flat background, clearly visible as the
   magenta/purple bloom at the top of the reference PNG. The app paints flat
   `colorBackground` only. `CupidColorTokens.skyGradient` exists but holds the
   raw CSS string; nothing parses or paints it, and the token's own dartdoc
   defers the rendering approach to "the story that first paints this
   decoration". Owner: a design-system story. Affects: every screen.

2. **Header back arrow tint.** Design is
   `font-size:26px;color:var(--pink)` on a `background:transparent` bar with a
   Nunito 800 21px title (`Cupid Screens.dc.html:50-55`). `CupidHeader`'s
   Material variant renders `colorSurface` background, a `colorText` (white)
   arrow, and a Roboto w600 22px title. `CupidHeader` takes no tint or style
   parameter, so this is not reachable from the call site. Owner: a
   design-system story. Affects: every screen with a back affordance.

3. **Decorative twinkle dots absent.** Three animated star dots at
   `top:14%/left:8%`, `top:9%/right:16%`, `top:26%/right:7%`
   (`Cupid Screens.dc.html:45-47`) are part of the app-wide backdrop, not the
   `isPermissions` block. Visible as three small light dots in the reference
   PNG. Owner: same as item 1. Affects: every screen.

Also noted, not a capture delta: `CupidPrimaryButton` renders a flat
`colorAccentPink` fill, while this screen's design source specifies
`background:var(--grad-hot)` plus `box-shadow:var(--glow)`. Correcting the
shared widget would change every CTA in the app and is out of scope, so
`_GradientCta` in `permissions_screen.dart` builds the design-accurate
treatment locally from the same tokens. That local build is why the CTA
matches in the capture; the shared widget is still wrong for every other
screen and should be reconciled by the same design-system story.

## Verification commands and results

| Command (run from `mobile/`) | Result |
|---|---|
| `flutter gen-l10n` | ran; `l10n.yaml` drives it. Required first — a clean worktree has no `lib/l10n/generated/`, so a whole-tree analyze reports pre-existing `AppL10n` errors until it is generated |
| `flutter analyze lib/features/onboarding lib/main_preview.dart test/features/onboarding` | `No issues found! (ran in 2.4s)` |
| `flutter test test/features/onboarding test/design_system` | `00:00 +39: All tests passed!` |
| `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=permissions` | `✓ Built build/app/outputs/flutter-apk/app-debug.apk` (44.4s) |
| capture (above) | `MOBILE_CAPTURE: OK implemented-permissions-emulator-5554.png 405x900` |

The 39 tests are this story's 6 new widget tests plus the 33 existing
`test/design_system` tests, including `no_fork_guard_test.dart` — the new
feature code introduces no `Color(0x`, `Colors.`, `Platform.is`, or
`defaultTargetPlatform`.

Device note: the first `adb install -r -t` failed with
`INSTALL_FAILED_INSUFFICIENT_STORAGE` on the shared emulator (611 MB free vs a
171 MB debug APK); `pm trim-caches` freed nothing, so the previous build of
the same package was uninstalled and reinstalled inside the device lease. No
device was created, booted, wiped, or repaired.
