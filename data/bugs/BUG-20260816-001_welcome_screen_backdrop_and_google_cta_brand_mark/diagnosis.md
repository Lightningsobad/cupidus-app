# Diagnosis: BUG-20260816-001 Welcome Screen Backdrop Gradient + Google CTA Brand Mark

Bug id: BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark
Scope classification: mobile (Flutter)
Impacted Runtime Service/App: mobile-app
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
BaseHead: `10c05c3` (HEAD at dispatch — BUG-20260814-001 review commit)

## Input Anchors

- R2-1: `mobile/lib/features/auth/presentation/screens/welcome_screen.dart:150-158`
  — backdrop painted from `colors.gradientHot.colors.reversed`
- R2-2: `mobile/lib/features/auth/presentation/screens/welcome_screen.dart:300-313`
  — Google CTA `_FilledCta` has no leading-icon parameter
- Token source: `mobile/lib/design_system/tokens/cupid_color_tokens.dart:99-103`
  (`gradientHot`, the two-stop BUTTON token being misused as a backdrop)
- Reference fix pattern (R2-2): `login_screen.dart` Google/Facebook CTA brand
  marks from STORY-005 BF-04
- Design reference:
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-033_app_shell_design_system_deltas/visual-fidelity/design-reference-welcome-android.png`

## Pre-Fix Reproduction Gate

Original failure anchor: rendered `welcome` screen does not match the locked
design canvas — (R2-1) pale lavender/pale pink backdrop instead of the
three-stop brand gradient, and (R2-2) no Google brand mark on the
"Tiếp tục với Google" CTA.

Reproduction method and modality: **rendered visual on a real running app**
(same modality as the bug report, which is a design-fidelity finding raised
from a screenshot comparison). A code read alone is explicitly not sufficient
for this bug class.

Exact commands:

```
cd <worktree>/mobile
flutter pub get
flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=welcome
adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5560 shell am force-stop com.snapsofts.cupid
adb -s emulator-5560 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
adb -s emulator-5560 exec-out screencap -p > prefix-welcome-emulator-5560.png
```

Device: `emulator-5560`, 1080x2400. Preview harness: `lib/main_preview.dart`
(`--dart-define=PREVIEW=welcome`), the same harness BUG-20260814-001 used for
its Modality 2 recheck.

Expected failure: backdrop renders as the pale two-stop reversed button
gradient, and the Google CTA renders label-only.

Actual result: **both reproduced at HEAD `10c05c3`.**

- R2-1: backdrop runs pale lavender (top) to pale pink (bottom). No deep
  purple `#7B2FBE` anywhere, no `#FF3366` red at the bottom. Every white and
  white-at-alpha foreground element (sub-copy, legal footnote, accent rule,
  outlined "Dùng email" border) is at or past the legibility edge.
- R2-2: the "Tiếp tục với Google" CTA renders as a bare centred label with no
  leading multicolour "G" glyph. The design reference shows the glyph left of
  the label.

Result: REPRODUCED

The live capture matches the previously committed review screenshot
`integration-review/mobile-screenshots/implemented-welcome-emulator-5560.png`,
confirming `welcome_screen.dart` is unchanged since the Round 2 review commit
`83d456f` and the defect is still live at current HEAD.

## Expected vs Observed

| Aspect | Expected (locked design) | Observed |
|---|---|---|
| Backdrop | `linear-gradient(165deg, #7B2FBE 0%, #FF4B8C 58%, #FF3366 100%)` | reversed two-stop `gradientHot` = `#B78CF5` -> `#FF7FB6` |
| Google CTA | multicolour Google "G" glyph before the label | label only, no brand mark |

## Root Cause

**One root cause, two symptoms: the welcome screen was built against a design
system that had no token/parameter for what the design source actually asks
for, so both call sites approximated.**

### R2-1 — no backdrop gradient token existed

`CupidColorTokens` shipped exactly two `LinearGradient` tokens: `gradientDream`
(120deg, three-stop) and `gradientHot` (95deg, two-stop — the *button* fill).
The design source's welcome backdrop,
`linear-gradient(165deg,#7B2FBE 0%,#FF4B8C 58%,#FF3366 100%)`
(`cupid-app-design-system/project/Cupid Screens.dc.html:69`), matches neither.

STORY-004 could not add the missing token because `lib/design_system/` was
outside its WriteScope (D13), and the ADR-004 no-fork guard
(`test/design_system/no_fork_guard_test.dart`) forbids a raw `Color(0x...)`
literal anywhere under `lib/features`. With no legal way to express the real
value, the screen substituted the nearest existing token and reversed it to
get purple-on-top, then carried its own local `_gradient165Begin/End`
alignments to at least keep the correct 165deg sweep angle.

The substitution is not merely "slightly off". `gradientHot` is
`[#FF7FB6, #B78CF5]` — two *pale* tints intended to sit **behind dark label
text on a button**. Reversed and stretched over a full screen it becomes a
pale lavender-to-pale-pink wash, while the whole welcome foreground is white
or white-at-alpha (sub-copy, 65%-alpha 11.5px footnote, accent rule,
50%-alpha outlined CTA border). Measured on the pre-fix capture the sweep runs
`#B78CF5 -> #E184D0 -> #FF7FB6` against the required
`#7B2FBE -> #FF4B8C -> #FF3366`; the top stop alone is ~3 shades lighter than
spec, which is what pushed the alpha'd foreground past the legibility edge.

### R2-2 — `_FilledCta` had no leading-mark parameter

`welcome_screen.dart`'s private `_FilledCta` takes
`label/background/foreground/elevation/radius/labelStyle/onPressed` and renders
`child: Text(label, ...)` unconditionally. There is no slot for a leading
glyph, so the design source's inline four-path Google SVG
(`width:20px;height:20px`, row `gap:9px`, same line 84) had nowhere to go.

This is *not* a missing asset: `CupidBrandMark.google` and
`CupidBrandMarkIcon` already exist in
`lib/design_system/icons/cupid_icons.dart` (added by STORY-005 BF-04) and are
already exported from the `design_system.dart` barrel that `welcome_screen.dart`
imports. `login_screen.dart`'s `_SocialButton` consumes them through exactly
the `mark`/`markSize`/`markGap` + `Row(mainAxisSize: min)` shape. The welcome
screen simply never got the same wiring, because it was never visually
compared against its design reference (req_master.md deferred item IF-7).

## Root-Cause Family And Cluster Boundary

Same family (both fixed here): R2-1 and R2-2 are one cluster — a single screen
(`welcome`) that was implemented without the design-system affordances its
design source requires, and both are only observable through the same rendered
visual comparison. They share the screen, the design source block
(`isWelcome`, lines 69 and 84), the remediation pattern (consume an existing or
newly added design-system contract instead of approximating in the feature
layer), and the same verification modality.

Not in family (deliberately untouched):

- `login_screen.dart`'s own `_SocialButton` mark wiring — already correct,
  and its 19/8 mark geometry is a different design-source row.
- Any other screen reading `gradientHot`. The token's value is unchanged; this
  fix only *adds* `gradientBrandBackdrop`, so no existing button keeps or
  changes its fill. Verified by the full suite staying green.
- The welcome Apple CTA. The design source draws it as a bare label, so it
  correctly stays `mark: null` via the new parameter's default.

## Fix Applied

1. **New token** `CupidColorTokens.gradientBrandBackdrop` in
   `lib/design_system/tokens/cupid_color_tokens.dart` — the design source's
   three stops and 58% midpoint on a new `_gradient165Begin/_gradient165End`
   pair, wired through the const ctor, `.dark()`, `.light()`, the field list,
   `copyWith`, and `lerp`. Identical in both themes (design source has no
   theme override), matching how `gradientDream`/`gradientHot` are handled.
   Its dartdoc states the `gradientHot`-is-a-button-token boundary explicitly.
2. **`welcome_screen.dart`** now paints
   `BoxDecoration(gradient: colors.gradientBrandBackdrop)`. The local
   `_gradient165Begin/_gradient165End` constants moved into the token file
   (they would otherwise be dead code).
3. **`_FilledCta`** gained optional `mark`/`markSize`/`markGap`, mirroring
   `_SocialButton` exactly, and the Google call site passes
   `CupidBrandMark.google` at the design source's 20px/9px geometry.

The raw hex literals live only under `lib/design_system/`, so the ADR-004
no-fork guard stays green (re-run and passing).

## Risk Surfaces

- Frontend/mobile interaction and design-token contract. `CupidColorTokens` is
  a `ThemeExtension` with a `required` const-ctor parameter added, so any
  external construction site would fail to compile — the full suite compiling
  and passing proves there is no missed construction site.
- No persistence, auth, migration, job, payment, or network surface touched.

## Files And Ranges Inspected

| File | Range / query | Why |
|---|---|---|
| `bug_master.md` | full | canonical report |
| `scrum-master-checkpoint.md` | full | anchors, expected-behavior source |
| `runtime-command-registry.json` | full | build/test/readiness commands (`mobile-app`) |
| `BUG-20260814-001/fix-evidence.md` | full | prior preview-harness + readiness pattern |
| `lib/main_preview.dart` | 1-90 | preview activation for the reproduction gate |
| `welcome_screen.dart` | 1-70, 120-199, 255-384, 384-398 | both anchors + `_FilledCta` |
| `cupid_color_tokens.dart` | 1-70, 70-139, 139-268, 268-338 | token class shape for a new field |
| `cupid_icons.dart` | 215-294 | `CupidBrandMark` / `CupidBrandMarkIcon` contract |
| `login_screen.dart` | 408-457, 631-693 | reference `_SocialButton` mark pattern |
| `no_fork_guard_test.dart` | full (2.1 KB) | exact forbidden-pattern list |
| `welcome_screen_test.dart` | full (5.7 KB) | existing test pinned the defect |
| `Cupid Screens.dc.html` | git grep lines 69, 84 | design source values, verbatim |

No full read of a >20 KB file was performed; `main_preview.dart` (38 KB) and
`login_screen.dart` (27 KB) were read only in ranges located by `git grep`.

## Scope Classification

mobile — 2 production files, 1 test file. Well inside the 12-file budget. No
backlog escalation, no architecture decision required: the fix adds a token to
an existing token class and a parameter to an existing private widget, both
following patterns already established in this codebase.
