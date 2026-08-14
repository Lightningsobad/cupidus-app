# STORY-017 Visual Fidelity Report — Home Dashboard

VISUAL_FIDELITY: PASS
Design-Screen: home

- Story: `STORY-017_home_dashboard_design_fidelity`
- Requirement: `REQ-002_screen_flow_and_design_fidelity_audit`
- Lane: mobile
- Configuration audited: dark theme + `vi` locale
- Design source: `cupid-app-design-system/project/Cupid Screens.dc.html` (`isHome`
  block, lines 230-329; tab chrome `showTabs` block, lines 1611-1631); type scale
  from `cupid-app-design-system/project/Cupid App.dc.html` lines 104-105
- Implementation: `mobile/lib/features/home/presentation/home_screen.dart` and
  the shared `mobile/lib/design_system/adaptive/cupid_tab_bar.dart`
- Round: 3 (re-capture round; supersedes the round-2 evidence set)

`VISUAL_FIDELITY: PASS` is scoped by §0: the rendered implementation matches the
design source within this story's declared comparison region. Regions owned by
other stories are named and excluded there, not silently ignored.

## 0. Comparison region

Scrum Master decision on review round-2 finding B5, applied here verbatim. AC1's
"no visible deviation" is evaluated against the elements STORY-017 actually
implements, because the remaining surfaces on the design screen are owned by
other stories and are unreachable from this story's write scope (changing them
would violate AC5).

**In region — compared, and required to match:**

| # | Element | Where |
|---|---------|-------|
| R1 | Couple-presence header (avatar discs, couple name, couple-type label) | `home_screen.dart` `_PresenceRow` |
| R2 | Days counter + Dream Gradient treatment + trailing unit | `home_screen.dart` `_DaysCounter` |
| R3 | Next-milestone pill | `home_screen.dart` `_MilestonePill` |
| R4 | Hero caption line | `home_screen.dart` |
| R5 | Entry-card rhythm (column inset, uniform gaps, bottom padding) | `home_screen.dart` |
| R6 | Tab-bar **styling** per platform — *not* the tab set | `cupid_tab_bar.dart` |
| R7 | Hero decorative glow | `home_screen.dart` |

**Out of region — excluded, each owned elsewhere:**

| Excluded surface | Owner | Deferral |
|------------------|-------|----------|
| 5-tab set and its labels (Nhà / Trò chuyện / Pet / Ví chung / Tôi vs. the app's 3 tabs) | STORY-001 `app_shell.dart` | F7 |
| Vibe Check card | its own REQ-002 story | F6 |
| Bún pet card | its own REQ-002 story | F6 |
| Synced Alarm / Zodiac Red Flag grid | its own REQ-002 story | F6 |
| "Seen 5 phút rồi đấy" banner | later feature story (route absent) | F3 |
| Header share / notification actions | later feature story (routes absent) | F3 |

Two further out-of-region surfaces were **discovered by this round's rendered
comparison** and were not visible from source inspection alone. Both are global
chrome outside this story's `WriteScope`, i.e. the same class B5 excluded, but
they are new — `scrum-master` should confirm the exclusion rather than assume it:

| Excluded surface | Owner | Deferral |
|------------------|-------|----------|
| `--sky` screen backdrop (three-layer radial wash behind every screen) | theme (`cupid_theme.dart`) | F10 |
| Bottom-right person FAB present in the app, absent from the design | STORY-001 `app_shell.dart:199` | F11 |

## 1. Method

This round performs a real rendered comparison. The round-2 report described CSS
transcription only; that text now lives in §2 as the sourcing note for the code
constants, and is not offered as fidelity evidence.

**Capture harness.** `mobile/lib/main_preview.dart` renders one screen as the app
root with authored state, per the rule that a fidelity capture must fake the
state rather than navigate to it. Two compile-time defines drive this screen:

- `--dart-define=PREVIEW_HOME_FIXTURE=true` hands `HomeScreen` an authored
  `CupidProfile` (display name `Minh`, `SAME_CITY`, paired, relationship start
  247 days ago) instead of `GET /users/me`, reproducing the design's own state.
- `--dart-define=PREVIEW_PLATFORM=material|ios` drives `CupidPlatformOverride`
  so both AC4 tab-bar treatments are photographable on one Android emulator.

Both are `bool.fromEnvironment` / `String.fromEnvironment` behind omitted
defaults, so live app behaviour is unchanged when the defines are absent.

**Why round 2's capture was invalid, and what changed.** The round-2 image was
shot before the first real frame painted, so it recorded the Flutter launch
screen. This round gates the shutter on the frame actually being painted:
after a cold `am start`, the harness polls `adb exec-out screencap` once a
second and only proceeds once the frame bytes exceed a floor **and** stop
changing across three consecutive polls. Both captures settled at 4s; each
committed image was then opened and visually confirmed to show the dashboard
before this report was written.

**Device and configuration.** `emulator-5554` was in use by a concurrent story,
so this round ran on `emulator-5560` (sdk gphone64 arm64, Android 16 / API 36,
1080x2400). Captures are full-resolution `adb exec-out screencap`, downscaled by
`capture-mobile-screen.sh --max-edge` to 405x900; no device display resize was
used, so the layout in each image is the emulator's real layout. Locale is
pinned to `vi` and text scaling disabled by the preview harness, so a host font
override cannot move a measurement.

**States compared.** One screen state — the design's `home` canvas state (paired
couple, same city, day 247) — in dark theme + `vi`, rendered twice, once per
platform silhouette. That is the only state AC1/AC3/AC4 assert.

### 1.1 Captured artifacts

| File | Role | Platform |
|------|------|----------|
| `design-reference-home-android.png` | design source render | Material |
| `implemented-home-android-emulator-5560.png` | this round's implementation capture | Material |
| `design-reference-home-ios.png` | design source render | iOS |
| `implemented-home-ios-emulator-5560.png` | this round's implementation capture | iOS |

Round 2's `implemented-home-emulator-5554.png` is deleted in this round. It
contained the launch screen, not this story's screen, and keeping it would leave
an invalid artifact in the evidence set.

### 1.2 In-region comparison result

Matching, confirmed against the opened images:

- **R1** — two overlapping 42px gradient discs with the `colorBackground` ring
  and the `-13` overlap; self disc carries the `M` initial; couple-type label
  reads `Cùng thành phố`, matching the source's `SAME_CITY` copy.
- **R2** — `247` renders under the Dream Gradient (pink → violet → mint sweep
  visible across the glyphs), with `ngày bên nhau` on the number's baseline.
- **R3** — pill on `colorSurface` with the full-round radius and the source's
  copy, `Còn 53 ngày nữa tới mốc 300`, with `53 ngày` bolded in `colorText`.
- **R4** — caption reads `Chịu đựng nhau được 247 ngày rồi, giỏi quá 🎀`,
  character-for-character the source's `data-vi` string (line 251).
- **R5** — entry cards run at a uniform gap with the 16px column inset; no card
  in the run breaks the rhythm.
- **R6** — the two platform captures are visibly different in exactly the way
  AC4 requires: Material paints the pink pill indicator behind the active icon
  with an opaque bar; iOS paints no pill, a smaller label, and a bar that reads
  as the background rather than an opaque surface.
- **R7** — the 180px pink radial sits at the top-right, fading out well before
  the screen edge, matching source line 233
  (`top:-30px;right:-40px;width:180px;height:180px;radial-gradient(circle,rgba(255,127,182,.42),transparent 70%)`).

Three in-region differences remain visible against the reference. None is an
uncorrected layout, spacing, token, or typography defect; each is a governed
decision or an availability gap already accepted as a deferral in review round 2
("F1-F9 ... remain legitimate out-of-scope deferrals and are not re-raised"):

| Δ | What differs | Why it is not a fidelity defect |
|---|--------------|---------------------------------|
| Δ1 | The counter number is smaller than the prototype's | Authority conflict, resolved by the story text: the `isHome` prototype paints `66px`, but AC3 and `Cupid App.dc.html` §2 name the **Display** role (`Nunito 900 · 34pt`). AC3 is the binding acceptance criterion and wins. Asserted in test. |
| Δ2 | Couple title reads `Minh`, not `Minh & Linh`; partner disc has no `L` initial | F4. `GET /users/me` returns only the signed-in user's `displayName` plus an opaque `partnerId`. Closing this needs a partner-profile API — a backend change excluded by this story's stop rule. The screen degrades honestly rather than inventing a name. |
| Δ3 | Milestone pill has no leading `bedtime` glyph | F2. `CupidIcons` carries no verified codepoint for it, and that file's sourcing rule forbids inventing one. |

## 2. Deviations found and corrected

Measurements for the code constants were transcribed from the `isHome` CSS
rather than re-derived, and are declared as named file-level constants in
`home_screen.dart` so the sourcing stays auditable. This is how the values were
*authored*; §1 is how the result was *verified*.

| # | AC | Deviation (before) | Correction (after) |
|---|----|--------------------|--------------------|
| D1 | AC1 | Screen painted a Material `AppBar` titled "Cupid". The design source's `NO_CHROME` map (`Cupid Screens.dc.html` line 1951) lists `home`, so the dashboard has no app bar at all. | `AppBar` removed; `Scaffold.body` is a `SafeArea` + `SingleChildScrollView`. Regression-locked by the "paints no AppBar" test. |
| D2 | AC1 | A bootstrap placeholder `Text` sat at the top of the screen where the design has the couple-presence block. | Placeholder deleted. The `home_screen_ready_signal` key (referenced by 10+ out-of-scope test files) was moved onto the real entry-card `Column` so no out-of-scope test breaks. |
| D3 | AC1 | No couple-presence signal existed. | `_PresenceRow`: two overlapping 42px gradient avatar discs (`-13` overlap, `2.5px` `colorBackground` ring, `elevationShadow`), self disc carrying the display-name initial, then the couple name (Nunito 15/w800 `colorText`) over the couple-type label (11.5 `colorTextMuted`). |
| D4 | AC1 | No decorative hero glow. | 180px radial `colorAccentPink` glow at `top:-30 / right:-40`, alpha 107 (`rgba(255,127,182,.42)`) fading to alpha 0 at stop 0.7, wrapped in `IgnorePointer` and clipped by a `ClipRect` that honours the source's `overflow:hidden`. |
| D5 | AC3 | No days counter existed. | `_DaysCounter` renders the day count in `CupidTypographyTokens.display` (Nunito 900, 34pt) under a `ShaderMask` with `BlendMode.srcIn` fed by `CupidColorTokens.gradientDream`, i.e. the Dream Gradient. Asserted directly in test (`fontFamily`, `fontWeight.w900`, `fontSize 34`, `blendMode`). |
| D6 | AC3 | — | Trailing unit "ngày bên nhau" at 19/w800 `colorTextMuted`, baseline-lifted 9px so it sits on the number's baseline as in the source. |
| D7 | AC1 | No hero caption. | Caption line at 13.5 `colorTextMuted`, 10px below the counter, carrying the source's vi/en copy. |
| D8 | AC1 | No next-milestone pill. | `_MilestonePill` on `colorSurface` with `radiusButton` + `elevationShadow`, 15/10 padding, `Text.rich` with the remaining-day span in `colorText` bold. Milestone = next multiple of 100 (source shows `247 → 300`). |
| D9 | AC1 | Entry cards used ad-hoc `CupidSpacing` gaps and no column inset. | Card column inset to 16 horizontal with uniform 13px gaps and 30px bottom padding, matching the source's card rhythm. `_TimelineEntryPointGate` switched from `CupidSpacing.md` to the same 13px gap so the run stays even. |

### 2.1 Tab-bar deviations (AC4)

The first pass judged AC4 already-correct because `CupidTabBar` did branch on
platform. Re-auditing it line-by-line against the source's `showTabs` block
(iOS lines 1613-1620, Material lines 1623-1630) instead of against the summary
row in `ux/uiux-spec.md` §6 found the branch present but eight of its measured
values wrong. All are corrected in
`mobile/lib/design_system/adaptive/cupid_tab_bar.dart`.

| # | Platform | Deviation (before) | Correction (after) |
|---|----------|--------------------|--------------------|
| D10 | iOS | Bar painted `colorSurface` at 85% alpha with no blur — opaque, not translucent. | Source line 1613 is `background:transparent; backdrop-filter:blur(26px) saturate(1.3)`. Bar color is now `Colors.transparent` behind a `ClipRect` + `BackdropFilter` composing `ImageFilter.blur(sigma 13)` (a CSS blur radius is twice its Gaussian sigma) with a `saturate(1.3)` `ColorFilter.matrix`. |
| D11 | both | Bar padding was `vertical: CupidSpacing.xs` only — no top/bottom asymmetry, no horizontal inset, no safe-area allowance. | `EdgeInsets.fromLTRB` per platform: `6/10/6/6` on iOS, `4/10/4/10` on Material. The source's `calc(var(--safe-bot) + Npx)` is reproduced by a `SafeArea(top: false)` **inside** that padding, so the real device inset stacks on the fixed value. |
| D12 | both | Items were content-sized under `MainAxisAlignment.spaceAround`, so tab widths drifted with label length. | Both source variants set `flex:1`; each entry is now wrapped in `Expanded`. Regression-locked by the equal-width test. |
| D13 | iOS | Icon-to-label gap was `CupidSpacing.xs` (4) on both platforms. | 3 on iOS (line 1615 `gap:3px`), 4 on Material (line 1625 `gap:4px`). |
| D14 | both | Labels inherited `caption`'s `w400`, and the Material label inherited caption's 13pt. | iOS 10 / `w700` / `letter-spacing:.01em`; Material 11 / `w700`. |
| D15 | Material | Active-pill padding was `CupidSpacing.md` x `CupidSpacing.xs` (16 x 4). | `19` horizontal / `5` vertical, per line 1626. |
| D16 | Material | Active-pill fill was `colorAccentPink.withAlpha(38)` (≈15%). | `rgba(255,127,182,.22)` → `colorAccentPink.withAlpha(56)`. |
| D17 | Material | Icon size relied on the ambient `IconTheme` default. | Set explicitly to the source's 24, so a theme change cannot silently move it. |

Two authority conflicts inside the tab bar resolve the same way AC3's counter
did — the locked spec beats the prototype:

- The prototype paints the iOS icon at `25px`; `ux/uiux-spec.md` §6 and AC4
  both name **26**. 26 kept.
- `radiusButton` is already `999` on both platforms, so the source's
  `border-radius:999px` pill needs no new constant.

The per-item minimum tap target is preserved as a `ConstrainedBox` `minHeight`
of `platformTokens.tapTarget`. Its former `minWidth` was dropped as dead:
`Expanded` now forces every slot to an equal share that is wider than the
44/48 minimum on any supported width.

## 3. Verified already-correct (no change needed)

- **AC5 — no new entry point.** The change adds a presence/counter header and
  restyles existing tab chrome only. The set of navigable destinations is
  byte-for-byte unchanged; asserted by the AC1/AC5 test.

## 4. Write-scope deviation (declared, first pass only)

Two files outside the **first pass's** `WriteScope` were touched, under the
no-fork-guard exception that handoff allowed. The re-dispatched handoff that
covers §2.1 adds `design_system/adaptive/cupid_tab_bar.dart` and
`test/design_system` to `WriteScope`, so the tab-bar work introduces no further
deviation:

- **Added** `mobile/lib/design_system/tokens/couple_presence_palette.dart`
- **Edited** `mobile/lib/design_system/design_system.dart` — one additive
  `export` line only

**Reason.** The presence avatars need `linear-gradient(135deg,#FFB1D3,#C79BF0)`,
`linear-gradient(135deg,#A8F0DF,#C79BF0)` and a `#fff` initial glyph. No
existing token carries these stops (`gradientDream`/`gradientHot` differ) and no
token exposes a pure-white on-accent foreground. Placing the literals in
`lib/features/**` would fail `test/design_system/no_fork_guard_test.dart`
(D3/ADR-004 forbids `Color(0x` there).

**Precedent followed** (as instructed, matching STORY-003/006):
`tokens/pet_hero_gradient.dart` and `tokens/bun_sprite_palette.dart` — additive,
single-consumer tokens. `CouplePresencePalette` is consumed only by
`HomeScreen`'s presence header. **No existing shared token was modified in
place**; the only first-pass edit to a pre-existing shared file is the additive
export line, which changes no existing symbol.

### 4.1 Shared-component blast radius (`cupid_tab_bar.dart`)

`CupidTabBar` is shared chrome. Its consumers are `app_shell.dart`,
`main_preview.dart`, `preview_app_shell_chrome.dart` and
`preview_screen_entry.dart`. The §2.1 fixes are rendering-only: the
`CupidTabBar` / `CupidTabBarItem` public API (`items`, `currentIndex`, `onTap`,
`icon`, `label`) is unchanged, so no call site needed an edit and neither
navigation shell was touched — both are STORY-001's files and explicitly out of
scope here. Verified empirically by the full 930-test suite in §6, which
includes `test/core/navigation/app_shell_test.dart`.

## 5. Deferrals (not fixed, with reason)

| # | Gap | Why deferred | Owner |
|---|-----|--------------|-------|
| F1 | Decorative animations (`float`, `shimmer`, `riseHeart`, `wiggle`) | Motion is not a static-fidelity concern and the story's ACs cover layout/spacing/color/typography. Adding implicit animations would also change the widget tree other tests pump. | Follow-up motion story |
| F2 | `bedtime` leading glyph on the milestone pill | `CupidIcons` carries no verified codepoint for it and that file's sourcing rule forbids inventing one. | Icon-set story |
| F3 | Header share / notifications actions | Their target routes do not exist in the app yet; adding them would violate AC5 (no new entry point). | Later feature story |
| F4 | Partner display name and the "Minh & Linh" couple title | `GET /users/me` returns only the signed-in user's `displayName` plus an opaque `partnerId`. Closing this needs a partner-profile API surface — a backend change, which the stop rule excludes. Implementation degrades honestly: partner disc renders the design's gradient without an initial. | Backend + follow-up story |
| F5 | `LIVING_TOGETHER` / `DATING` couple-type labels | Both exist in the API enum but carry no entry in the design source's `COUPLE_TYPES` table. The label line is omitted rather than given invented copy. Covered by the "degrades instead of inventing data" test. | Product copy |
| F6 | Design's vibe / pet / quick-grid / timeline cards | Each lives in its own feature widget file outside this story's `WriteScope`; several have their own REQ-002 stories. | Per-feature stories |
| F7 | 5-tab chrome (design: home/chat/pet/money/me; app: 3 tabs) | The tab *set* lives in `mobile/lib/core/navigation/app_shell.dart`, which this handoff names as out of scope, and adding tabs would create new entry points (AC5 violation). | STORY-001 |
| F8 | `t.fill` icon variant (source line 2125: filled glyph when active, outline when inactive) | `CupidTabBarItem` carries one `IconData`. Supporting a filled/outline pair changes the widget's public API and therefore every call site, including `app_shell.dart`. | STORY-001 + icon-set story |
| F9 | iOS backdrop blur samples the scaffold background, not scrolled content | The blur can only reveal content behind the bar once the host sets `Scaffold.extendBody: true`, which lives in `app_shell.dart`. Until then it samples `colorBackground` — which is exactly what the source's transparent bar shows over `--bg`, so the rendered result already matches. | STORY-001 |
| F10 | `--sky` screen backdrop not implemented (**new, found round 3**) | Dark theme defines `--sky` as three stacked radials (`Cupid Screens.dc.html` line 26) and applies it at line 44 to the root screen frame that wraps *every* screen. Flutter paints a flat `scaffoldBackgroundColor: colorBackground` (`cupid_theme.dart:43`). Implementing it is a theme change affecting all 37 screens; `cupid_theme.dart` is outside this story's `WriteScope`. | Theme / design-system story |
| F11 | Bottom-right person FAB present in the app, absent from the design (**new, found round 3**) | Painted by `core/navigation/app_shell.dart:199` (mirrored in `preview/preview_app_shell_chrome.dart:73`), not by `home_screen.dart`. Removing it changes the navigable destination set, which AC5 forbids in this story. | STORY-001 |

## 6. Verification evidence

All commands run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-017/mobile`
with `PATH` prefixed by `/Users/alantravala/flutter/bin`. Flutter 3.44.1 stable,
Dart 3.12.1.

### 6.1 First pass (home screen)

Preparatory (worktree had no generated l10n output):

```
flutter gen-l10n
```

Static analysis on every changed file:

```
flutter analyze lib/features/home/presentation/home_screen.dart \
  lib/design_system/tokens/couple_presence_palette.dart \
  lib/design_system/design_system.dart \
  test/features/home/home_screen_test.dart
```

Result: `Analyzing 4 items... No issues found! (ran in 1.1s)` — **0 errors, 0
warnings, 0 new infos**.

Targeted tests plus the design-system regression slice (which contains
`no_fork_guard_test.dart`):

```
flutter test test/features/home test/design_system
```

Result: **`00:01 +45: All tests passed!`** — 45 passed, 0 failed, 0 skipped.

### 6.2 Second pass (tab bar, §2.1)

```
flutter analyze lib/design_system/adaptive/cupid_tab_bar.dart \
  test/design_system/adaptive_widgets_test.dart \
  lib/features/home/presentation/home_screen.dart
```

Result: `Analyzing 3 items... No issues found! (ran in 3.6s)` — **0 errors, 0
warnings, 0 infos**. No `--no-fatal-infos` relaxation was needed.

Scoped slice — the changed design system, the audited screen, and the shared
widget's navigation consumer:

```
flutter test test/design_system test/features/home test/core/navigation
```

Result: **`00:03 +53: All tests passed!`** — 53 passed, 0 failed, 0 skipped.

Full-suite regression check, required because `cupid_tab_bar.dart` is shared
chrome (§4.1):

```
flutter test --reporter=failures-only
```

Result: **`+930: All tests passed!`** — 930 passed, 0 failed, 0 skipped, no
failure blocks emitted.

### 6.3 New tests

Six in `mobile/test/features/home/home_screen_test.dart` (first pass):

1. AC1/AC5 — no `AppBar`, entry-point set unchanged
2. AC1 — presence signal renders both discs, couple name, couple-type label
3. AC3 — days counter is Nunito 900 / 34pt under a `BlendMode.srcIn`
   Dream-Gradient `ShaderMask`
4. AC1 — milestone pill counts down to the next 100-day mark
5. Degradation — missing start date prints no counter; unlabelled couple type
   prints no label line
6. Degradation — an unresolved profile hides the hero without blocking the
   entry cards

The pre-existing Dream Jar navigation test in the same file still passes
unmodified, confirming D2 broke no out-of-scope consumer of
`home_screen_ready_signal`.

Four in `mobile/test/design_system/adaptive_widgets_test.dart` (second pass),
alongside the two pre-existing tap-target tests, which still pass unmodified:

1. AC4/D10 — the iOS bar is `Colors.transparent` behind a `BackdropFilter` and
   keeps the source's 1px `colorLine` top border
2. AC4/D13-D14 — the iOS item is a 26pt tinted icon over a 10pt `w700` label at
   `.01em` tracking, with no pill indicator present
3. AC4/D14-D17 — the Material item has no `BackdropFilter`, an opaque
   `colorSurface` bar, a 24dp icon inside a `999`-radius pill padded `19 x 5`
   whose selected fill is `colorAccentPink` at alpha 56 and whose unselected
   fill is transparent, over an 11pt `w700` label
4. AC4/D12 — every destination renders at an identical width (`flex:1`)

### 6.4 Third pass (re-capture round) — re-run in this round

Device builds, one per captured platform variant plus the real entrypoint:

```
flutter build apk --debug --target-platform=android-arm64 -t lib/main_preview.dart \
  --dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true \
  --dart-define=PREVIEW_PLATFORM=material

flutter build apk --debug --target-platform=android-arm64 -t lib/main_preview.dart \
  --dart-define=PREVIEW=home --dart-define=PREVIEW_HOME_FIXTURE=true \
  --dart-define=PREVIEW_PLATFORM=ios

flutter build apk --debug --target-platform=android-arm64
```

Result: all three `✓ Built build/app/outputs/flutter-apk/app-debug.apk`.

Static analysis over this story's files, including the preview entrypoint that
round 2 flagged as undeclared (DF1):

```
flutter analyze lib/features/home/presentation/home_screen.dart \
  lib/main_preview.dart \
  lib/design_system/adaptive/cupid_tab_bar.dart \
  test/features/home/home_screen_test.dart \
  test/design_system/adaptive_widgets_test.dart
```

Result: `Analyzing 5 items... No issues found! (ran in 2.0s)` — **0 errors, 0
warnings, 0 infos**.

Full suite re-run in this round (not carried over from round 1):

```
flutter test --reporter=failures-only
```

Result: **`+930: All tests passed!`** — 930 passed, 0 failed, 0 skipped.

Captures, each under an exclusive device lease so a concurrent story could not
interleave on the shared emulator:

```
capture-mobile-screen.sh --device=emulator-5560 --lease-exec -- \
  <install + cold start + wait-for-painted-frame> \
  && capture-mobile-screen.sh --out=<story>/visual-fidelity \
       --label=home-android|home-ios --device=emulator-5560 --settle-ms=1200
```

Result: `MOBILE_CAPTURE: OK .../implemented-home-android-emulator-5560.png
405x900` and `MOBILE_CAPTURE: OK .../implemented-home-ios-emulator-5560.png
405x900`. Both frames settled 4s after cold start and were opened and confirmed
to show the dashboard before this report was written.

## 7. Changed files

First pass:

- `mobile/lib/features/home/presentation/home_screen.dart` (rewritten layout)
- `mobile/lib/design_system/tokens/couple_presence_palette.dart` (added — see §4)
- `mobile/lib/design_system/design_system.dart` (one additive export — see §4)
- `mobile/test/features/home/home_screen_test.dart` (six added tests)

Second pass (§2.1):

- `mobile/lib/design_system/adaptive/cupid_tab_bar.dart` (platform-adaptive
  rendering corrected against the `showTabs` block; public API unchanged)
- `mobile/test/design_system/adaptive_widgets_test.dart` (four added tests)

Capture entrypoint (round-2 DF1 — previously undeclared here):

- `mobile/lib/main_preview.dart` (+60/−21) — adds the `PREVIEW_HOME_FIXTURE`
  authored-profile fixture and the `PREVIEW_PLATFORM` silhouette override, both
  dev-only `bool.fromEnvironment` / `String.fromEnvironment` behind omitted
  defaults, so live app behaviour is unchanged. Declared in this story's
  `WriteScope`.

Third pass (this round) changes evidence only: the two new implementation
captures, the deletion of the invalid round-2 capture, and this report.

## 8. Acceptance-criteria verification

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 — dark + `vi` layout/spacing/token/typography match within §0's region | MET | D1-D4, D7-D9 corrected; §1.2 rendered comparison on `implemented-home-android-emulator-5560.png`; §6.3 tests 1, 2, 4 |
| AC2 — deviations corrected in the app, not just documented | MET | All 17 deviations in §2 and §2.1 are code changes in §7; no row is documentation-only; §1.2 re-verifies them against the design source in a rendered frame |
| AC3 — days counter is Nunito 900 / 34pt with Dream Gradient | MET | D5, D6; §6.3 first-pass test 3 asserts `fontFamily`, `w900`, `34`, `BlendMode.srcIn` over `gradientDream`; gradient visible in the rendered capture (§1.2 R2) |
| AC4 — platform-adaptive tab bar per §3 | MET | D10-D17; §6.3 second-pass tests 1-4; both treatments now have a real implemented capture and differ as specified (§1.2 R6) |
| AC5 — no new entry point | MET | §3; the destination set is unchanged and both navigation shells were left untouched |

Residual gaps are the F1-F11 deferrals in §5. F7-F11 are owned by STORY-001's
navigation work or the shared theme, and none is reachable from this story's
write scope.

## Story Runtime Startup Smoke

Rule 12g. `story_master.md` records `Complexity: standard` with no
`Runtime-Smoke: WAIVED` line, so this is mandatory.

- **Device:** `emulator-5560` (sdk gphone64 arm64, Android 16 / API 36) — the
  same emulator session as this round's captures.
- **Build under test:** the real application entrypoint (`lib/main.dart`, no
  preview defines), `flutter build apk --debug --target-platform=android-arm64`,
  installed with `adb install -r`.
- **Procedure:** `adb shell am force-stop`, `adb logcat -c`, then
  `adb shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`.

Result — **PASS**:

| Check | Observed |
|-------|----------|
| Cold start | `LaunchState: COLD` |
| Reached first screen | `ActivityTaskManager: Displayed com.snapsofts.cupid/...MainActivity for user 0: +6s931ms` and `Fully drawn ...: +6s931ms` |
| Process alive after launch | `pidof com.snapsofts.cupid` → live pid; `ResumedActivity: ActivityRecord{... com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity}` |
| Crash | `adb logcat -b crash` empty (0 lines) across three consecutive checks; no `FATAL EXCEPTION`, no `E/AndroidRuntime`, no `ANR in` |
| Flutter error screen | None. The rendered frame is real app UI (`Typing Ghost` route restored from the persisted session), not a red/grey error screen and not the launch screen |
| Renderer | `Using the Impeller rendering backend (OpenGLES)`; Dart VM service attached |

One non-fatal startup log is present and is **not** a story regression:
`E/GeneratedPluginRegistrant: Error registering plugin flutter_facebook_auth`.
Flutter isolates per-plugin registration failures, the engine continued to a
fully drawn frame, and the plugin is unrelated to this story's files (it is
missing Facebook app configuration on this emulator image).

The preview entrypoint used for the captures also cold-started cleanly twice in
this same session (once per platform variant), each reaching a painted dashboard
frame 4s after launch with an empty crash buffer.
