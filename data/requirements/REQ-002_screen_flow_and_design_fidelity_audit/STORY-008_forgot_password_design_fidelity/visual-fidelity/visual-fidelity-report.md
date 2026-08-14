# Visual Fidelity Report — STORY-008 `forgot`

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-008_forgot_password_design_fidelity
- Design screen id: `forgot`
- Theme / locale audited: dark theme, `vi` locale (the enabled combination)
- Implementation: `mobile/lib/features/auth/presentation/screens/forgot_screen.dart`
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-008`
- BaseHead: `12761f5b4a542a92df779b3687acd3808d44ed99`
- Date: 2026-08-13

This pass is a **re-audit**. The prior pass (commit `625cb09`) closed with
`Outcome: DEFERRED_ONLY` because two deviations sat outside that pass's
WriteScope. This pass has `mobile/lib` + `mobile/test` in scope, so the
screen-local half of that backlog is now fixed in app code rather than
re-documented.

## Locked design source

`cupid-app-design-system/project/Cupid Screens.dc.html` (`locked: true` in
`data/devops/system/design-fidelity-config.json`).

| Concern | Design source location |
| --- | --- |
| `isForgot` screen body | lines 1513-1530 |
| Shared header block | lines 49-64 |
| `NO_CHROME` map | line 1951 |
| `NO_TABS` map | line 1952 |
| `t_forgot` title strings | lines 1769 / 1781 |
| `BACK_TO` map | line 1853 |
| Screen frame background | line 44 |

## Evidence

| Artifact | Detail |
| --- | --- |
| `design-reference-forgot-android.png` | 406x900, rendered from the locked canvas |
| `implemented-forgot-emulator-5554.png` | 405x900, captured from `emulator-5554` |

Both live beside this report in `visual-fidelity/`.

Scale parity is native, not forced: the emulator reports `wm size 1080x2400`
and `wm density 420`, i.e. 411.4 x 914.3 dp, which already equals the design
canvas's Android frame (412x915). No display override was applied — an earlier
attempt to pass `--width=412` without a matching density produced a zoomed,
non-comparable render and was discarded.

Exact commands:

```
# design reference (run from the control checkout, which owns .ai-team-bundle)
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --entry="Cupid App.dc.html" --screen=forgot --platform=android \
  --out=<visual-fidelity dir> --label=forgot

# implemented screen, under an exclusive device lease because six sibling
# mobile-dev agents share emulator-5554 and overwrite com.snapsofts.cupid
flutter build apk --release -t lib/main_preview.dart \
  --dart-define=PREVIEW=forgot --dart-define=PREVIEW_BRIGHTNESS=dark
bash .ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
  --device=emulator-5554 --lock-timeout=900 --lease-exec -- <relaunch+capture>
```

The leased step force-stops the package, `adb install -r -d` re-installs this
story's APK, launches `MainActivity`, waits for `ResumedActivity`, then captures
(nested captures inherit the lease). Without the lease the first capture showed
a sibling story's screen.

## Element-by-element comparison

| Element | Design source | Implementation | Verdict |
| --- | --- | --- | --- |
| Screen chrome / header | shared header, `t_forgot` = `Quên mật khẩu`, back to `login` | `CupidHeader` with the same title and `maybePop()` | MATCH (fixed this pass) |
| Tab bar | suppressed (`NO_TABS`) | none | MATCH |
| Screen padding | 20 / 20 / 20 / 40 | `_screenPadding` identical | MATCH |
| Hero badge box | 72x72, radius 26, purple @ 20% | `_heroBadgeSize/_heroBadgeRadius/_heroBadgeTint` | MATCH |
| Hero glyph | `lock_reset` | `CupidIcons.lockReset` | MATCH (fixed this pass) |
| Title | 25px, line-height 1.25, Nunito w900 | `type.display` + `_titleSize/_titleLineHeight` | MATCH |
| Lead paragraph | muted, line-height 1.6 | `type.caption` + `_leadLineHeight` | MATCH |
| Field card | 16/13 padding, surface, card radius | `_fieldCardPadding`, `colors.colorSurface` | MATCH |
| Field label | 11px, 6% tracking, uppercase, muted | `_fieldLabelSize/_fieldLabelTracking` | MATCH |
| Field input | 16px, borderless | `_fieldInputSize`, `InputBorder.none` | MATCH |
| Privacy note surface | mint @ 12% fill, mint @ 32% border | `_noteSurfaceTint/_noteBorderTint` | MATCH |
| Privacy note glyph | `shield_moon` | `CupidIcons.shieldMoon` | MATCH (fixed this pass) |
| Privacy note text | 12.5px, line-height 1.55, bold `không` | `_noteTextSize/_noteLineHeight`, `w700` span | MATCH |
| Success / error lines | mint / red tokens | `colors.colorMint` / `colors.colorRed` | MATCH |
| Primary CTA container | 54px, `--grad-hot`, `--glow`, 16.5px w800 | flat `colorAccentPink`, `tapTarget` height, `type.body` | DEVIATION — shared component (D-1) |
| Header styling | transparent + `blur(16px)`, 26px `--pink` back glyph, Nunito w800 21px / -.01em title | `AppBar` on `colorSurface`, `colorText` back glyph, `type.cardTitle` | DEVIATION — shared component (D-2) |
| Frame background | `var(--sky)` wash over `var(--bg)` | flat `colors.colorBackground` | DEVIATION — app-wide (D-3) |

The design reference shows `minh@gmail.com` prefilled in the email field; that
is canvas sample data, not a specified default. The implemented empty state is
correct and its filled/success/error states are covered by widget tests.

## Fixed in app code this pass

1. **Icon glyphs were substitutes.** Both slots rendered `CupidIcons.lock`.
   Added `lockReset` (`0xeade`) and `shieldMoon` (`0xeaa9`) to
   `mobile/lib/design_system/icons/cupid_icons.dart` and swapped both call
   sites. Codepoints were confirmed against the bundled Material Symbols
   Rounded cmap with fontTools, and contour-op counts confirm three distinct
   outlines — they were not guessed. Locked by a widget test that also asserts
   `CupidIcons.lock` no longer appears on this screen.

2. **The whole screen header was missing.** `forgot` is absent from the design
   source's `NO_CHROME` map (line 1951), so the canvas renders it with the
   shared header; only `NO_TABS` applies. The implementation had no `appBar` at
   all. Added `CupidHeader` with `t_forgot` (`Quên mật khẩu` / `Forgot
   password`) following the established per-screen wiring used by
   `invite_screen.dart` and `joincode_screen.dart`.

   Back behaviour uses `Navigator.of(context).maybePop()`, which already lands
   on `login` and therefore agrees with `BACK_TO.forgot`. This is deliberately a
   fidelity fix only — Scope A (STORY-001 / STORY-002) owns the inter-screen
   navigation contract, so no navigation target is redefined here.

   Note for the requirement owner: `story_master.md` line 9 classified this
   screen as `NO_CHROME / NO_TABS`. That label contradicts the locked source and
   has been corrected in the story record.

## Deferred — shared components, not screen-local

These three are reachable from this pass's WriteScope but are deliberately not
landed here. Each is a shared component consumed app-wide, six sibling
mobile-dev agents are merging into the same integration branch this wave, and
this story is classified `trivial`. Fixing them from one screen's story would
silently restyle every other screen mid-wave and break sibling assertions.

- **D-1 — `CupidPrimaryButton` does not use the design's CTA treatment.**
  `mobile/lib/design_system/adaptive/cupid_primary_button.dart` renders a flat
  `colorAccentPink` fill at `tapTarget` height with a `type.body` label. Design
  line 1524 specifies 54px height, `gradientHot` fill, `glowShadow`, and a
  16.5px / w800 label. The `gradientHot` and `glowShadow` tokens already exist
  and are used in 12 other places — the shared CTA is the outlier. Blast
  radius: 24 `lib` consumers, 7 test files, including
  `mobile/test/design_system/adaptive_widgets_test.dart`, which asserts the
  current 20dp radius and tap-target height. This is the same gap the prior
  reviewer flagged across sibling auth-screen stories.

- **D-2 — `CupidHeader` Material variant is off-spec.**
  `mobile/lib/design_system/adaptive/cupid_header.dart` returns an `AppBar` on
  an opaque `colorSurface` with a `colorText` back glyph and a `type.cardTitle`
  title. Design lines 49-64 specify a transparent header with
  `backdrop-filter: blur(16px)`, a 26px `--pink` back glyph, and a Nunito w800
  21px / -.01em title. Blast radius: 18 `lib` consumers. Visible in this
  screen's capture as the solid band behind `← Quên mật khẩu`.

- **D-3 — the `--sky` frame wash is never painted.**
  `skyGradient` is declared in `mobile/lib/design_system/tokens/cupid_color_tokens.dart`
  as a **`String`** holding raw CSS and has zero render-path consumers; only
  `contrast_test.dart` asserts it is non-empty. The design frame (line 44)
  layers `var(--sky)` over `var(--bg)` on every screen, which is why the
  reference render has a purple/magenta wash at the top that no screen in the
  app reproduces. This needs a typed Flutter gradient plus a shared screen
  scaffold, not a per-screen patch.

Recommendation to Scrum Master: raise D-1, D-2, and D-3 as **one tracked
REQ-002 design-system follow-up story** owned by mobile, sequenced after this
wave's per-screen stories merge. They are recurring wave-wide findings and
should stop being re-deferred screen by screen.

## Verification

Run in `mobile/` on this worktree.

| Gate | Command | Result |
| --- | --- | --- |
| Analyzer (touched files) | `flutter analyze --no-pub --no-fatal-infos lib/features/auth/presentation/screens/forgot_screen.dart lib/design_system/icons/cupid_icons.dart test/features/auth/presentation/screens/forgot_screen_test.dart` | `No issues found!` (exit 0) |
| Tests (touched + dependent) | `flutter test --no-pub test/features/auth/presentation/screens/forgot_screen_test.dart test/design_system/no_fork_guard_test.dart test/design_system/adaptive_widgets_test.dart test/design_system/contrast_test.dart` | `+25: All tests passed!` (exit 0) |
| Full suite | `flutter test --no-pub` | `+926: All tests passed!` (exit 0) |
| Release build | `flutter build apk --release -t lib/main_preview.dart --dart-define=PREVIEW=forgot --dart-define=PREVIEW_BRIGHTNESS=dark` | `✓ Built app-release.apk (68.5MB)` |

Analyzer caveat: an unscoped `flutter analyze` currently reports 11027 issues,
of which 10933 are inside `mobile/build/` — untracked, gitignored, generated
FlutterFire SwiftPM checkouts that appeared mid-session and are not repository
source. The remaining 77 (`lib/`) and 17 (`openapi/`) are pre-existing `info`
lints in files this story does not touch. Zero analyzer issues are attributable
to the three changed files, confirmed by the per-file run above.

## Verdict

`PASS` is scoped to what this story owns: every screen-local deviation on
`forgot` was found and fixed in app code. The three shared-component items
below are recorded as tracked deferrals against a separate design-system
story, not as open defects on this screen.

```
VISUAL_FIDELITY: PASS
Screen: forgot
Theme: dark
Locale: vi
Design-Source: cupid-app-design-system/project/Cupid Screens.dc.html (locked)
Design-Reference: visual-fidelity/design-reference-forgot-android.png
Implemented-Capture: visual-fidelity/implemented-forgot-emulator-5554.png
Screen-Local-Deviations-Found: 3
Screen-Local-Deviations-Fixed: 3
Screen-Local-Deviations-Open: 0
Shared-Component-Deviations-Deferred: 3 (D-1 CupidPrimaryButton, D-2 CupidHeader, D-3 skyGradient)
Deferral-Reason: shared components with app-wide blast radius during a six-agent parallel wave
Deferral-Route: one tracked REQ-002 design-system follow-up story
Analyze: PASS
Tests: PASS (926)
Build: PASS
```
