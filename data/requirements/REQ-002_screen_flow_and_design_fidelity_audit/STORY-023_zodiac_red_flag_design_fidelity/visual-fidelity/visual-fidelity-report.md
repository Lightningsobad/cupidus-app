# STORY-023 — Zodiac Red Flag Visual Fidelity Report

VISUAL_FIDELITY: FAIL
Design-Screen: zodiac

## Verdict

FAIL — blocking, but **not** because the shipped screen deviates from the
design. It fails because **there is no shipped Zodiac Red Flag screen to audit**.
The story is written as a fidelity correction ("this is a fix, not an audit
report"), but its premise — that the screen exists and drifted — is false in
this worktree.

## Scope And Sources

| Item | Value |
| --- | --- |
| Story | STORY-023 Zodiac Red Flag design fidelity |
| Design canvas | `cupid-app-design-system/project/Cupid Screens.dc.html` lines 593-627 |
| Design component | `cupid-app-design-system/project/Zodiac Icon.dc.html` (12-sign SVG set) |
| Design reference frame | `visual-fidelity/design-reference-zodiac-android.png` |
| Theme / locale audited | dark + `vi` (light/`en` deferred by OQ5) |
| Worktree | `story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-023` |
| BaseHead | `e3fb5389cd84694ab7dc449e7b1ee01eb5ab3e25` |

## Primary Finding

**F-01 — The `zodiac` canvas has no implementation anywhere in the app.**

`mobile/lib/main_preview.dart` registers `zodiac` in `_notImplementedCanvasIds`,
alongside `otp`, `permissions`, `shareapprove`, `shareedit`, `shareok`,
`sharepick`, `themedetail`, `themes`, and `vow`. That list is defined as
"design canvas ids with no shipped screen anywhere in this worktree yet", and
each entry renders `PreviewNotImplementedScreen`.

Corroborating checks:

- There is no `mobile/lib/features/zodiac/` directory.
- The only zodiac code in the app is
  `mobile/lib/features/account/domain/zodiac.dart`, a 26-line pure function
  `String zodiacSignFor(DateTime birthday)`. It has no UI, no widget, no route.
- `mobile/lib/features/home/presentation/home_screen.dart` has no Zodiac entry
  card and no navigation to any zodiac destination.

So AC1-AC3 cannot be satisfied by correcting existing code. Satisfying them
means building the feature from nothing.

## Why This Cannot Be Delivered Under The Current Handoff

Building the screen faithfully requires edits to three files that are all
outside the declared `WriteScope`
(`mobile/lib/features`, `mobile/test/features`, and this story's artifact dir):

| Needed file | Why it is needed | In WriteScope |
| --- | --- | --- |
| `mobile/lib/main_preview.dart` | Remove `zodiac` from `_notImplementedCanvasIds` and register a real `PreviewScreenEntry`. Without this the mandated rendered screenshot is impossible — `--dart-define=PREVIEW=zodiac` renders the not-implemented placeholder. | No |
| `mobile/lib/l10n/arb/` | All `vi`/`en` copy on the screen (title, red-flag label, headline, conflict-index label, sign names, 3 tip strings, disclaimer). | No |
| `mobile/lib/design_system/icons/cupid_icons.dart` | 6 glyphs the canvas uses that the icon set does not expose: `warning`, `bolt`, `videocam`, `block`, `local_cafe`, `auto_awesome`. (All 6 codepoints do exist in the bundled `MaterialSymbolsRounded-Variable.ttf` — verified via fontTools — they are simply not surfaced as `CupidIcons` constants.) | No |

It also conflicts with the story's own text:

- **Out of Scope** excludes "any new feature, new screen state, or new
  interaction not already present in the locked design source".
- **AC4** states "no new entry point is required — this story does not change
  how the screen is reached". Building the screen necessarily adds one, since
  none exists.
- **Complexity: trivial** does not match a from-scratch screen that includes a
  hand-drawn 12-sign icon set.

## Second Blocker: The Screen Has No Data Contract

The design canvas is entirely static fixture content — conflict index `7/10`,
date `29/07`, signs `cancer`/`pisces`, names Minh/Linh, a fixed headline, and
3 fixed tips (fixture list at `Cupid Screens.dc.html` line 1803). There is no
backend contract, no repository, and no cubit for any of it.

Shipping that as hardcoded Vietnamese demo copy would be inventing product
semantics (how is a "conflict index" computed? are tips authored or derived?)
under the banner of a design-fidelity fix. That is a Product Owner + Tech Lead
decision, not a mobile-lane one, so it was deliberately not fabricated.

## Design Spec Captured For Whoever Builds It

The audit work is not wasted — the full spec was extracted and mapped onto
existing tokens. Every design CSS var already has a 1:1 Flutter token, so no new
tokens are required:

| Design var | Existing token |
| --- | --- |
| `--surf` / `--surf2` / `--line` | `colorSurface` / `colorSurfaceAlt` / `colorLine` |
| `--tx` / `--tx2` | `colorText` / `colorTextMuted` |
| `--pink` / `--purple` / `--mint` / `--butter` / `--peach` / `--amber` | `colorAccentPink` / `colorAccentPurple` / `colorMint` / `colorButter` / `colorPeach` / `colorAmber` |
| `--r-card: 24px` | `radiusCard` |
| `--shadow` | `elevationShadow` |
| Nunito 900 34px | `display` |
| `'Roboto Mono'` label | `labelMono` |

Structure: root `padding 8/16/40, column, gap 13`; gradient hero card
(`155deg rgba(183,140,245,.34) -> rgba(255,127,182,.16)`, 1px
`rgba(183,140,245,.4)` border, decorative 110px `auto_awesome` at 20% opacity);
conflict card (`34px` peach value + `/10` muted, two `46px` zodiac discs with
`bolt` between, `10px` bar with `mint -> butter 55% -> peach` fill at 70%);
3-row tips card with `36x36 r12` tinted tiles (mint `videocam`, pink `block`,
amber `local_cafe`); centered `11px` muted footnote.

The `Zodiac Icon` component (AC3) is a `viewBox 0 0 100 100` disc
(`circle cx50 cy50 r48` filled with the element disc colour) plus a per-sign
stroked path (`stroke-width 6`, `5.5` for virgo/scorpio, round caps/joins) and
two decorative dots. Element inks: fire `#FF9576`, earth `#5FD3BC`, air
`#B78CF5`, water `#FF7FB6`, each with a `.16`-`.18` alpha disc. In Flutter this
is a `CustomPainter`, not a Unicode glyph — AC3 explicitly forbids the glyph
substitute.

## Capture Attempt

A rendered capture was attempted and did not produce valid evidence:

1. Built `flutter build apk --debug -t lib/main_preview.dart
   --dart-define=PREVIEW=zodiac` from this worktree — succeeded.
2. Installed and launched on `emulator-5560` under the capture script's device
   lease. The frame returned was the Private Gallery screen, i.e. a concurrent
   sibling story's build overwriting the package between install and capture.
   Repeated with a 35s settle window, same result.
3. `emulator-5554` rejected the install with
   `INSTALL_FAILED_INSUFFICIENT_STORAGE`.
4. Deep-link fallback `--route=cupidpreview://screen/zodiac` failed with
   `MOBILE_VISUAL_AUDIT_SCREEN_UNREACHABLE` — the `cupidpreview://` scheme is
   not declared in the Android manifest, so the runtime deep-link path in
   `main_preview.dart` is unreachable from `adb`.

The capture produced in step 2 was **deleted rather than delivered**, because a
Private Gallery frame stored as `implemented-zodiac-*.png` would be false
evidence. Only `design-reference-zodiac-android.png` remains in this folder.

Note that even a clean capture would have shown `PreviewNotImplementedScreen`,
not the screen — which is the finding, not a fix.

## Baseline Verification

Run in `<worktree>/mobile` this session, to show the blocker is scope and not a
broken tree. No source files were modified, so this is the BaseHead state.

| # | Command | Result |
| --- | --- | --- |
| 1 | `flutter gen-l10n` | OK |
| 2 | `flutter analyze --no-fatal-infos lib test` | 77 issues, all info-level; 0 errors, 0 warnings |
| 3 | `flutter test --reporter failures-only` | `+920: All tests passed!` |
| 4 | `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=zodiac` | `✓ Built build/app/outputs/flutter-apk/app-debug.apk` |

## AC Status

| AC | Status | Note |
| --- | --- | --- |
| AC1 zodiac screen matches dark/`vi` design | FAIL | No screen exists |
| AC2 element colour-coding, spacing, tokens, typography | FAIL | No screen exists |
| AC3 custom 12-sign icon set, never Unicode glyphs | FAIL | No icon widget exists |
| AC4 reached via existing navigation, no new entry point | CONTRADICTORY | No entry point exists to preserve |

## Files Changed

None. The worktree is clean at BaseHead `e3fb5389`, apart from this report.

## Recommendation

Re-scope STORY-023. Two coherent options:

1. **Promote it to a build story.** Reclassify from `trivial` to `standard`,
   widen `WriteScope` to include `mobile/lib/main_preview.dart`,
   `mobile/lib/l10n/arb/`, and `mobile/lib/design_system/icons/cupid_icons.dart`,
   drop or rewrite AC4, and get a Product Owner decision on whether the
   conflict index and tips are static v1 fixtures or backed by real data.
2. **Defer it** with the other unimplemented canvases (`otp`, `permissions`,
   `vow`, `themes`, `themedetail`, `share*`), and let a later requirement build
   them as features rather than as fidelity fixes.

Option 2 is the more consistent call for REQ-002, whose remit is fidelity of
screens that already ship.
