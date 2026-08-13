# STORY-017 Visual Fidelity Report — Home Dashboard

- Story: `STORY-017_home_dashboard_design_fidelity`
- Requirement: `REQ-002_screen_flow_and_design_fidelity_audit`
- Lane: mobile
- Configuration audited: dark theme + `vi` locale
- Design source: `cupid-app-design-system/project/Cupid Screens.dc.html` (`isHome`
  block, lines 230-329); type scale from
  `cupid-app-design-system/project/Cupid App.dc.html` lines 104-105
- Implementation: `mobile/lib/features/home/presentation/home_screen.dart`
- Verdict: **CORRECTED** — every in-scope deviation is fixed in code, not just
  documented (AC2). Out-of-scope gaps are listed as deferrals with the exact
  owner file.

## 1. Method

The design source is a Claude Design HTML/CSS handoff prototype and is treated
as the pixel authority. Measurements were transcribed from the `isHome` CSS
rather than re-derived, and are declared as named file-level constants in
`home_screen.dart` so the sourcing stays auditable.

Two authorities disagree on one value and the story text resolves it: the
`isHome` prototype paints the days number at `66px`, while the story's AC3 and
`Cupid App.dc.html` §2 name the **Display** role (`Nunito 900 · 34pt`,
line-height 1.1). AC3 wins; the counter uses `CupidTypographyTokens.display`.

## 2. Deviations found and corrected

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

## 3. Verified already-correct (no change needed)

- **AC4 — platform-adaptive tab bar.** The bottom chrome is owned by
  `AppShell`, which already mounts `CupidTabBar`; that widget already resolves
  the iOS treatment (translucent bar, 26pt icon, 10pt label) versus the Android
  pill active indicator through `CupidPlatformTokens`, and is covered by
  `test/design_system/adaptive_widgets_test.dart`. No change was required and
  none was made — see deferral F7 for the separate tab-*count* gap.
- **AC5 — no new entry point.** The change adds a presence/counter header only.
  The set of navigable destinations is byte-for-byte unchanged; asserted by the
  AC1/AC5 test.

## 4. Write-scope deviation (declared)

Two files outside the declared `WriteScope` were touched, under the
no-fork-guard exception the handoff allows:

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
`HomeScreen`'s presence header. **No existing shared token or shared adaptive
component was modified in place**; the only edit to a pre-existing shared file
is the additive export line, which changes no existing symbol.

## 5. Deferrals (not fixed, with reason)

| # | Gap | Why deferred | Owner |
|---|-----|--------------|-------|
| F1 | Decorative animations (`float`, `shimmer`, `riseHeart`, `wiggle`) | Motion is not a static-fidelity concern and the story's ACs cover layout/spacing/color/typography. Adding implicit animations would also change the widget tree other tests pump. | Follow-up motion story |
| F2 | `bedtime` leading glyph on the milestone pill | `CupidIcons` carries no verified codepoint for it and that file's sourcing rule forbids inventing one. | Icon-set story |
| F3 | Header share / notifications actions | Their target routes do not exist in the app yet; adding them would violate AC5 (no new entry point). | Later feature story |
| F4 | Partner display name and the "Minh & Linh" couple title | `GET /users/me` returns only the signed-in user's `displayName` plus an opaque `partnerId`. Closing this needs a partner-profile API surface — a backend change, which the stop rule excludes. Implementation degrades honestly: partner disc renders the design's gradient without an initial. | Backend + follow-up story |
| F5 | `LIVING_TOGETHER` / `DATING` couple-type labels | Both exist in the API enum but carry no entry in the design source's `COUPLE_TYPES` table. The label line is omitted rather than given invented copy. Covered by the "degrades instead of inventing data" test. | Product copy |
| F6 | Design's vibe / pet / quick-grid / timeline cards | Each lives in its own feature widget file outside this story's `WriteScope`; several have their own REQ-002 stories. | Per-feature stories |
| F7 | 5-tab chrome (design: home/chat/pet/money/me; app: 3 tabs) | `mobile/lib/core/navigation/app_shell.dart` is outside `WriteScope`, and adding tabs would create new entry points (AC5 violation). | Navigation story |

## 6. Verification evidence

All commands run in this session from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-017/mobile`
with `PATH` prefixed by `/Users/alantravala/flutter/bin`.

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

Six of those are new in `mobile/test/features/home/home_screen_test.dart`:

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

## 7. Changed files

- `mobile/lib/features/home/presentation/home_screen.dart` (rewritten layout)
- `mobile/lib/design_system/tokens/couple_presence_palette.dart` (added — see §4)
- `mobile/lib/design_system/design_system.dart` (one additive export — see §4)
- `mobile/test/features/home/home_screen_test.dart` (six added tests)
