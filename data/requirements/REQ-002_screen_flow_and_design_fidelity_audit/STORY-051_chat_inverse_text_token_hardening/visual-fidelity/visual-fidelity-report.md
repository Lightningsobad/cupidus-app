# STORY-051 — `colorOnAccent` Visual Fidelity Report

VISUAL_FIDELITY: PASS

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-051 (RED-PATCH hardening of STORY-018, RWB-20260816-016)
- Role: mobile-dev
- Date: 2026-08-18
- Branch: `main`
- BaseHead: `7d8fc626295323e9d75531cd9649cfbc1d89df1b`
- Worktree: `/Users/alantravala/workspace/snapsofts/cupid-apps`
- Audited configuration: dark theme, `vi` locale, Material platform axis,
  Epic 2 (Communication), chat tab active — the only v1-enabled configuration
  (OQ5). Same single-axis precedent as STORY-018 and STORY-035..040.

This story's visual claim is unusual: AC3 asserts the render is **unchanged**,
not improved. So the evidence below is a before/after equality proof, not a
design-reference deviation sweep. STORY-040's captures — taken on the same
emulator, same fixture, same capture command, one story earlier — are the
"before"; this story's captures are the "after".

## Evidence set

| Artifact | Size | What it shows |
| --- | --- | --- |
| `implemented-chat-emulator-5560.png` | 405x900 | AFTER. Live app on `emulator-5560`, dark + `vi`, shell chrome on, full thread with three own/partner bubbles and the Typing Ghost bubble live. |
| `implemented-chat-composer-draft-emulator-5560.png` | 405x900 | AFTER. Same app/state, non-empty draft (`A`), so the **enabled** send button is on screen; captured without the shell so the account-hub FAB does not occlude it (STORY-040 N2, still unfixed — see below). |
| `design-reference-chat-android.png` | 406x900 | Design reference, reused verbatim from STORY-040. |
| STORY-040's `implemented-chat-emulator-5560.png` and `implemented-chat-composer-draft-emulator-5560.png` | 405x900 | BEFORE. The pixel baseline for the AC3 equality proof. |

Capture command (both AFTER captures):
`.ai-team-bundle/runtime/tools/capture-mobile-screen.sh --label=<label>
--device=emulator-5560 --width=406 --density=160`

### Design reference reuse is valid

`git log e1e6f01..HEAD -- cupid-app-design-system/` is **empty** — the locked
design source has not changed since STORY-040 rendered
`design-reference-chat-android.png` (`render-design-canvas.js --screen=chat`).
The reference is therefore reused byte-identically rather than re-rendered.
Copied into this story's folder so the evidence set is self-contained.

## AC3 — dark-theme render unchanged. PROVEN BY PIXEL EQUALITY.

`colorOnAccent`'s dark value is a verbatim copy of `colorText`'s dark value
(`Color(0xFFF7EEFB)`), so AC3 should hold by construction. It was still
verified against real renders rather than asserted from the token values,
because "by construction" is exactly the kind of claim RWB-20260816-007 was
raised about.

Method: full-image `PIL.ImageChops.difference` between each STORY-040 capture
and its STORY-051 counterpart, then per-row max channel delta to locate every
differing band.

### Primary capture (shell-wrapped)

Differing row bands (`y0, y1, max channel delta`), everything else delta 0:

| Band | Max delta | Cause |
| --- | --- | --- |
| 17-29 | 225 | Android status-bar clock (`4:45` -> `3:03`). |
| 125-132 | 113 | Animated background particle (`CupidAppBackground`). |
| 233-239 | 125 | Animated background particle. |
| 692-710 | 41 | Typing Ghost `ghostFade` animation phase — the struck tail is mid-fade at a different point in its 5.55 s replay cycle. |

**Every message-bubble row is delta 0.** Brightest glyph pixel, sampled per
region in both captures:

| Region | BEFORE | AFTER | Verdict |
| --- | --- | --- | --- |
| Own bubble 1 text (`Anh ăn cơm chưa?`, box 240,445-385,472) | `(247,238,251)` | `(247,238,251)` | IDENTICAL |
| Own bubble 3 text (`Lại bug. Bug với em, chọn một 🔪`, box 130,588-385,618) | `(246,237,251)` | `(246,237,251)` | IDENTICAL |
| Partner bubble 2 text (box 24,518-200,545) | `(246,237,250)` | `(246,237,250)` | IDENTICAL |

`(247,238,251)` is `#F7EEFB` exactly.

### Correction (Reviewer B1) — the partner bubble was NOT a valid control

This report's first revision described the partner-bubble row as a "control —
not touched by this story", and read its delta-0 result as evidence that the
edit "did not leak past the `isMine` branch". **That inference was wrong and
is withdrawn.** The measurements in the table above stand; only the conclusion
drawn from the third row was invalid.

`MessageBubble` renders own and partner bubbles from **one** `Text`, so the
first revision's unconditional `color: colors.colorOnAccent` did repaint the
partner bubble too — it was inside the changed code path, not outside it. It
measured delta 0 only because dark-theme `colorOnAccent` and `colorText` are
byte-identical (`#F7EEFB` both), so the leak was invisible in the only
configuration these captures cover. In light theme the same code rendered the
partner bubble `#FFFFFF` on a `colorSurface` `#FFFFFF` fill — 1.00:1, fully
invisible text.

Fixed under B1: `message_bubble.dart:99` is now
`color: isMine ? colors.colorOnAccent : colors.colorText`. The `isMine`
scoping is now enforced by the light-theme widget tests described under
"Regression guard" below, which is where that guarantee belongs — a
dark-theme pixel capture is structurally incapable of proving it.

The four differing bands are all clock, background animation, or ghost-fade
animation phase — none of them are surfaces this story touched, and none of
them are deterministic between two runs of the same build. There is no
differing band anywhere in the thread region.

### Composer capture (send glyph) — the strongest single result

Send-button region, box `(348,823)-(390,865)` covering the whole gradient
circle plus margin:

- `ImageChops.difference(...).crop(SEND).getbbox()` -> **`None`**
- max channel delta over the region -> **`0`**
- raw bytes equal -> **`True`**
- brightest pixel BEFORE and AFTER -> `(247,238,251)` = `#F7EEFB`
- near-white glyph pixel count (`min channel > 200`) BEFORE and AFTER -> `33`

The enabled send glyph is **byte-identical** across the change. Same four
non-deterministic bands elsewhere in this capture (clock 18-29, particles
126-132 and 233-239, ghost fade 743-762); the composer region itself,
including the pill, the ghost toggle, the typing-warning row and the send
button, is delta 0.

**AC3 is satisfied**, and satisfied on measured pixels rather than on the
token-value argument alone. AC3 covers the dark-theme render only; the
`isMine` scoping AC2 requires is covered by the tests below, not by AC3.

## Regression guard (Reviewer B1 action item 2)

Two `testWidgets` cases added to
`mobile/test/features/chat/presentation/chat_design_fidelity_test.dart`, in
the existing `chat thread bubbles match the locked design source` group:

1. `partner bubble text is never its own fill colour` — loops both
   `Brightness` values; asserts the partner bubble's rendered text colour is
   `colorText` and is **not** the bubble's own `BoxDecoration.color`.
2. `light theme keeps the two on-fill text roles distinct` — asserts
   `_light.colorOnAccent != _light.colorText` up front, then that the own
   bubble renders `colorOnAccent` and the partner bubble renders `colorText`
   in light theme.

`_hostOn` gained an optional `brightness` parameter (default `Brightness.dark`,
so every pre-existing call site is unchanged) to host a light-theme pump.

**Confirmed to be a real guard, not a tautology.** Reverting
`message_bubble.dart:99` to the unconditional `color: colors.colorOnAccent`
fails case 1 with:

```
Expected: Color(red: 0.2431, green: 0.1490, blue: 0.2706)   // #3E2645 colorText
  Actual: Color(red: 1.0000, green: 1.0000, blue: 1.0000)   // #FFFFFF
Brightness.light
```

— i.e. it reproduces the exact white-on-white defect B1 describes. The
`Brightness.dark` iteration passes in that same reverted run, which is the
direct demonstration of why the original dark-only suite (and the dark-only
pixel captures above) let this reach review: in dark theme the two tokens are
the same hex, so no dark-theme assertion can distinguish them. Restoring the
`isMine` guard makes both cases pass.

One harness note worth recording: the loop needs `await
tester.pumpAndSettle()` after each `pumpWidget`. Re-pumping the same tree with
a different theme leaves `AnimatedTheme` mid-lerp, so the first frame still
reports the previous brightness — without the settle the test fails against
`#F7EEFB` (the dark value) rather than against the real light-theme render.

### Note on the composer capture method (inherited constraint, not new)

STORY-040 N2 — `app_shell.dart`'s account-hub `FloatingActionButton` covers
the chat send button 100% — is **still present and still unfixed**;
`git log` shows no change to `mobile/lib/core/navigation/app_shell.dart` since
STORY-016. It remains out of this story's scope (design-system token story,
not a navigation/IA story). As in STORY-040, the composer capture was
therefore taken with the preview registry's `chat` entry temporarily set to
`wrapInShell: false`. **That flag is restored to `true` in the delivered
source** — `git diff -- mobile/lib/main_preview.dart` is empty, verified after
restore. The primary capture above is from the shell-wrapped build and shows
the FAB in place, unchanged.

## AC4 — light-theme value inspection. PASS (no rendered light-theme pass).

Light theme is not a v1-enabled surface (OQ5), so per the story ACs and
`ux/uiux-spec.md` this is explicitly a value-inspection check. No light-theme
screenshot was attempted.

`colorOnAccent` light = `Color(0xFFFFFFFF)`, matching the design source's
literal `color:#fff` intent for both call sites.

The UX spec's contrast figures were independently recomputed here (WCAG 2.x
relative luminance) and confirmed:

| Foreground | Background stop | Ratio | Source |
| --- | --- | --- | --- |
| `#FFFFFF` (new light value) | `#FF7FB6` | 2.34:1 | recomputed, matches spec |
| `#FFFFFF` (new light value) | `#B78CF5` | 2.60:1 | recomputed, matches spec |
| `#F7EEFB` (already-shipped dark value, same surface) | `#FF7FB6` | 2.07:1 | recomputed, matches spec |
| `#F7EEFB` (already-shipped dark value, same surface) | `#B78CF5` | 2.30:1 | recomputed, matches spec |

Verified against source, not just quoted: `gradientHot`'s two stops are
declared as **literal** `Color(0xFFFF7FB6)` / `Color(0xFFB78CF5)` in *both*
`CupidColorTokens.dark()` and `CupidColorTokens.light()`
(`cupid_color_tokens.dart`, `// Not theme-overridden in source` comment above
`gradientDream` in the light initializer). They are not references to
`colorAccentPink` / `colorAccentPurple`, whose light values are in fact
different (`#E8558F` / `#9A63E8`). The UX spec's parenthetical attribution
"per `CupidColorTokens.light()`" names the token identifiers loosely, but the
hex pair it used for the math is the correct one — the light-theme gradient
really is the same pink->purple pair as dark, so the comparison is
apples-to-apples and the arithmetic stands. Flagged here only so a reviewer
reading the spec's parenthetical does not have to re-derive it.

Neither white figure clears WCAG AA (4.5:1 body / 3:1 large-text-and-UI).
That is a knowing carry-forward under the ADR-004b/ADR-004c precedent already
recorded in this same file for brand/gradient/CTA-context values, and the new
value is strictly better than what this exact surface already ships. The
alternative — inventing a non-source color to clear AA on a gradient the
design deliberately keeps theme-invariant — would be a UX judgment call this
story is not scoped to make.

## Changes delivered

| File | Change |
| --- | --- |
| `mobile/lib/design_system/tokens/cupid_color_tokens.dart` | AC1 — new `colorOnAccent` field across all six `colorText` touch points: constructor param, `.dark()` = `Color(0xFFF7EEFB)`, `.light()` = `Color(0xFFFFFFFF)`, field decl (with scope dartdoc), `copyWith` param + assignment, and `lerp`. |
| `mobile/lib/features/chat/presentation/widgets/message_bubble.dart` | AC2 — bubble `Text.style.color` is now `isMine ? colors.colorOnAccent : colors.colorText`. One `Text` serves both bubble sides, so the `isMine` guard is what keeps `colorOnAccent` on the `gradientHot` fill only (Reviewer B1). |
| `mobile/lib/features/chat/presentation/widgets/chat_composer.dart` | AC2 — send `Icon.color` **enabled branch only**: `colors.colorText` -> `colors.colorOnAccent`. The disabled branch's `colors.colorTextMuted` is untouched. |
| `mobile/test/features/chat/presentation/chat_design_fidelity_test.dart` | B1 action item 2 — two light-theme regression cases (see "Regression guard"), plus an optional `brightness` parameter on the existing `_hostOn` helper. |

`lerp` is included deliberately, per the Tech Lead invariant in
`story_master.md`: `CupidColorTokens` is a `ThemeExtension`, so omitting the
field from `lerp` compiles cleanly but silently drops the token during theme
transitions.

No other token, call site, or screen was modified. No light-theme or
`en`-locale enablement work was done (OQ5 untouched) — the new tests assert
light-theme token *values*, they do not enable light theme as a surface.

## Verification

All commands run in this session from
`/Users/alantravala/workspace/snapsofts/cupid-apps/mobile` with
`PATH="$HOME/flutter/bin:$PATH"`.

| Gate | Command | Result |
| --- | --- | --- |
| Scoped analysis | `flutter analyze lib/design_system/tokens/cupid_color_tokens.dart lib/features/chat/presentation/widgets/message_bubble.dart lib/features/chat/presentation/widgets/chat_composer.dart` | `No issues found!` — PASS |
| Full static analysis | `flutter analyze --no-fatal-infos lib test` | `80 issues found.` — **0 errors, 0 warnings**, all `info`. Identical count to STORY-040's baseline; none in any file this story touched. PASS |
| Build | `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=chat --dart-define=PREVIEW_CHAT_GHOST=on` | `✓ Built build/app/outputs/flutter-apk/app-debug.apk`, installed to `emulator-5560` (`Success`) — PASS |
| Targeted tests | `flutter test test/features/chat/ test/design_system/` | `+133: All tests passed!` — PASS. Covers `chat_design_fidelity_test.dart` (incl. the two new B1 cases), `contrast_test.dart`, `theme_matrix_test.dart` and the ADR-004 no-fork guard. |
| Full suite | `flutter test --reporter failures-only` | `+1287 ~2: All other tests passed!` — 1287 passed, 2 skipped, 0 failed — PASS (1285 -> 1287, the two new B1 cases) |
| Guard is not a tautology | revert `message_bubble.dart:99` to unconditional `colorOnAccent`, re-run the B1 case | FAILS on `Brightness.light` with `#FFFFFF` vs expected `#3E2645`; passes on `Brightness.dark`. Fix restored, both pass. |
| Runtime smoke | cold launch via `am start -a android.intent.action.VIEW -d "cupidpreview://screen/chat"` | Chat renders cleanly, no ErrorWidget — PASS |

Blast-radius check confirmed before the edit: `CupidColorTokens(...)` is
constructed only inside `cupid_color_tokens.dart` itself (`copyWith`, `lerp`)
with no external construction site or test mock, so the new `required`
constructor parameter breaks nothing — consistent with the Tech Lead's
`SKIPPED:trivial` architecture disposition.

Device state left clean: `wm size` / `wm density` restored to
`1080x2400` / `420` after the captures.
