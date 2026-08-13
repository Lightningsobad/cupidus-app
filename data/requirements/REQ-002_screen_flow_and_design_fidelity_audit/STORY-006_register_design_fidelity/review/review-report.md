# Review Report — STORY-006 Design Fidelity: Register

Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-006 Design Fidelity — Register
Mode: compact-story-review (UI lane, rendered visual-fidelity comparison)
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-006`
BaseHead: `8396273e6a5e6a2798557aa68864f0ef24cd939b`
Reviewed commit: `9f008dc`

Outcome: PATCH_REQUIRED

## Scope Reviewed

- `mobile/lib/features/auth/presentation/screens/register_screen.dart` (392 +, 35 -)
- `mobile/test/features/auth/presentation/screens/register_screen_test.dart` (new)
- `visual-fidelity/visual-fidelity-report.md` (new)
- `story_master.md` (implementation checkbox only)

Design source re-read independently at
`cupid-app-design-system/project/Cupid Screens.dc.html`, `isRegister` block
(lines 1461-1492), token definitions (lines 23-27), OTP input reference
(lines 1500-1506), `NO_CHROME` / `BACK_TO` maps (lines 1853, 1951).

## Evidence Independently Re-Run

Not accepted from the report alone. Re-executed in the story worktree with
`/Users/alantravala/flutter/bin/flutter`:

| Command | Result |
| --- | --- |
| `flutter test test/features/auth/presentation/screens/register_screen_test.dart` | 5 tests, all passed |
| `flutter test test/design_system test/features/auth` | 55 tests, all passed (no regression) |
| `flutter analyze` on both changed files | No issues found (2.3s) |

Reported evidence matches re-run evidence exactly.

## Design-Source Fidelity Verification (AC1, AC3)

Each claimed fix was checked against the design source line-by-line, not
against the report's own summary:

| Item | Design source | Implementation | Verdict |
| --- | --- | --- | --- |
| Title | Nunito / 900 / 26px / 1.25 (l.1464) | `type.display.copyWith(fontSize: 26, height: 1.25)`; `display` token is Nunito/w900 (`cupid_typography_tokens.dart:31-35`) | MATCH |
| Subtitle | 13px `--tx2`, 7px gap (l.1465) | `caption.copyWith(13, colorTextMuted)` + 7px gap | MATCH |
| Field cards | `--surf` / `--r-card` / 13px 16px / `--shadow` (l.1467-1477) | `colorSurface`, `radiusCard`, `elevationShadow`, 13x16 | MATCH except F2 below |
| Micro-labels | 11px, `.06em`, uppercase, `--tx2` (l.1468) | 11px, `letterSpacing: 11 * 0.06`, `.toUpperCase()`, `colorTextMuted` — em-to-logical-px conversion is correct | MATCH |
| Input text | 16px `--tx`, `--fs-ui`, borderless (l.1469) | `body.copyWith(16, colorText)`, `isCollapsed`, `InputBorder.none` | MATCH |
| Strength meter | 4 x (flex/5px/r3), gap 5, top 11, 3 mint + 1 line (l.1478-1484) | identical geometry, `colorMint` / `colorLine` | MATCH |
| Strength caption | 11px `--mint` w600, top 7 (l.1484) | identical | MATCH |
| Consent row | gap 11, 24x24, r9, `--grad-hot`, 16px check, 12px/1.5 `--tx2` (l.1486-1489) | identical geometry and tokens | MATCH visually; see P1 |
| CTA copy/position | l.1490 | unchanged `CupidPrimaryButton` | see N1 |
| Footer | centered 13px `--tx2` + pink `<strong>` (l.1491) | `Text.rich`, `colorTextMuted` 13 + `colorAccentPink` w700 | MATCH |
| Padding / rhythm | `12px 20px 40px`, gap 14, header `6px 0` (l.1462-1463) | `fromLTRB(20,12,20,40)`, uniform 14, vertical 6 | MATCH |
| Copy `Tên gọi` | l.1468 | corrected from `Tên hiển thị` | MATCH |

Off-grid verbatim constants (12/20/40/14/13/11/7/6/5/3) are correctly declared
as cited named constants rather than snapped to `CupidSpacing`, following the
existing `_materialPrimaryCtaRadius` precedent. This is the right call: the
design values genuinely have no token equivalent.

Password scoring for the design source's own sample `loveyou247` yields exactly
3 (len>=6, len>=10, has digit; no symbol), reproducing the design's single
authored meter state. Verified against `_passwordStrength`, not just asserted.

## Findings

### P1 — REQUIRED: consent checkbox tap target is 24dp, below the `--tap` minimum

File: `mobile/lib/features/auth/presentation/screens/register_screen.dart`
Lines: 455-478 (`_TermsConsentRow`, the `GestureDetector` -> `Container`)

The `GestureDetector` wraps a bare `Container(width: 24, height: 24)`, so the
entire hit area of this control is 24 x 24 logical px. The surrounding text is
not tappable, so 24dp is the only way to toggle consent.

Governing artifact violated:
`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-003_auth/ux/uiux-spec.md`
section 7, first bullet:

> All new/changed interactive elements ... must meet the existing `--tap`
> minimum (44pt iOS / 48dp Material) already established in STORY-001 tokens —
> no new exemption.

`CupidPlatformTokens` confirms the values (`cupid_platform_tokens.dart:34`
iOS 44, `:55` Material 48). The consent checkbox is a new interactive element
introduced by this story, so the "no new exemption" clause applies directly.
The codebase already honours this rule elsewhere (`CupidTabBar` tapTarget
tests in `test/design_system/adaptive_widgets_test.dart`).

Required change: expand the hit area to at least `platform.tapTarget` while
keeping the painted box at exactly 24 x 24 / radius 9, so design fidelity is
unchanged. For example, keep the current `Container` as the visual, wrap it in
a `SizedBox(width: platform.tapTarget, height: platform.tapTarget)` with
`alignment: Alignment.center` inside the `GestureDetector`, set
`behavior: HitTestBehavior.opaque`, and offset the row so the 24px visual still
lands at the design's `gap:11` / `align-items:flex-start` position (a negative
`Padding` or `Align` on the oversized box keeps the visible layout identical).
Any equivalent approach is acceptable provided the rendered pixels do not move.

This is the only finding that gates CLEAN.

### P2 — RECOMMENDED in the same patch: focus ring adds 1.5dp of inset to every field card

File: `mobile/lib/features/auth/presentation/screens/register_screen.dart`
Lines: 320-333 (`_FieldCardState.build`, `decoration.border`)

`Container` adds `BoxDecoration.padding` (= `Border.dimensions`, here
`EdgeInsets.all(1.5)` at the default inside stroke alignment) on top of the
declared `padding`. Effective content inset is therefore 14.5 vertical /
17.5 horizontal against the design's `padding:13px 16px`, and each card is 3dp
taller than the design. The design's register cards carry no border at all
(l.1467), so this inset exists in the resting state as well as the focused one.

The dev's stated goal — "the card never changes size" between focused and
unfocused — is achieved, but at a constant 1.5dp offset from the design.
Cheapest fix with zero layout cost: move the ring to `foregroundDecoration`
(painted over the child, consumes no layout space) and drop the
`colorSurface`-coloured placeholder border from `decoration`. Not gating,
because 1.5dp is at the edge of visibility, but the file is already open.

### P3 — RECOMMENDED follow-up: field inputs lost their screen-reader label

File: `mobile/lib/features/auth/presentation/screens/register_screen.dart`
Lines: 344-360

Replacing `InputDecoration(labelText:)` with a sibling `Text` plus a collapsed
borderless `TextField` removes the semantic association between label and
input. A screen reader now announces the field with no name. The uppercase
`Text` is a separate semantics node, not the field's label.

Non-visual fix: wrap the `TextField` in `Semantics(label: widget.label,
textField: true, child: ...)` and `ExcludeSemantics` the visual label to avoid
a double announcement. Not gated here because no AC in this story covers input
semantics and section 7 of the auth UX spec does not name this case
explicitly, but it is a real regression introduced by this change and should
not be lost.

## Judgement On The Three Items mobile-dev Deliberately Deferred

### N1 — `CupidPrimaryButton` CTA mismatch: legitimately deferred, does not block

Design wants `height:54px`, `--grad-hot` fill, 16.5px/800, `--glow`
(l.1490). `CupidPrimaryButton` renders a solid `colorAccentPink` fill at
`tapTarget` height with `body` type and no glow. Confirmed the widget is
shared across the app and that its current shape is an approved adaptation
(`STORY-003_auth/ux/uiux-spec.md` section 8, and STORY-001 section 6). Fixing
it inside a single screen story would either fork the shared component or
silently restyle every screen. Correct call to defer.

Action for Scrum Master: this is now the recurring cross-story gap across the
auth fidelity stories. Raise one design-system story to reconcile
`CupidPrimaryButton` with `--grad-hot` / `--glow` / 54px, and make sure the
REQ-002 integration review does not close with this still unowned.

### N2 — `skyGradient` never painted: legitimately deferred, does not block

`CupidColorTokens.skyGradient` carries the verbatim `--sky` value (design
source l.26) and its own dartdoc defers rendering to "the story that first
paints this decoration". App-shell scope. Correct call.

### N3 — missing back header: legitimately out of scope, NOT a silently dropped AC

Verified both sides of the conflict:
- Design source does exclude `register` from `NO_CHROME` (l.1951) and does set
  `BACK_TO.register = 'welcome'` (l.1853).
- But the governing app UX artifact overrides it:
  `STORY-003_auth/ux/uiux-spec.md` section 1 lists `register` chrome as
  `none` and states "`NO_CHROME`/`NO_TABS` continues to apply to this whole
  group per system UX memory section 4."

So `story_master.md`'s `NO_CHROME` classification is backed by an approved UX
decision, not an authoring slip, and the developer followed the correct
authority. No AC was dropped. The design source's own chrome map is the
outlier here.

Action for Scrum Master: record this as a known, intentional divergence from
the design source's `NO_CHROME` map so Scope A (STORY-001/STORY-002) does not
"fix" it back the other way, and so a later reviewer does not re-litigate it.

## Additional Interpretation Notes (recorded, not gating)

- Focus ring semantics. The design source specifies no focus state for the
  register cards. The pink 1.5px border was borrowed from the OTP screen, but
  there pink marks a *filled* digit (l.1501) while the caret/empty boxes use
  `--line` (l.1504-1505) — so pink-means-focused is an interpretation, not a
  transcription. It is a reasonable one (it restores the focus affordance lost
  with the Material underline) and I would not remove it, but UX should
  confirm the mapping when the auth screens next get a UX pass.
- Terms link styling. The design source's `<a href="#">` elements have no CSS
  rule anywhere in the file (verified: the entire `<style>` block is lines
  14-42 and contains no anchor selector), so a browser would render them
  default blue underlined. Pink + w700 is an interpretation borrowed from the
  footer's `<strong style="color:var(--pink)">`. Defensible and clearly the
  intended reading; bold specifically is an addition.
- Check glyph uses `colorText` (#F7EEFB) where the design says `#fff`,
  consistent with how `CupidPrimaryButton` already resolves on-gradient white.
  Accepted.
- `_termsAccepted` defaults to `true` and does not gate submission. The design
  shows only the checked state, so this is faithful, but a pre-ticked
  terms/privacy consent is a product and legal question, not a visual one.
  Flagged for Product Owner; explicitly out of this story's ACs.
- `_FieldCard` is a screen-private widget. STORY-005 (login) is reworking the
  same field pattern on its own branch, where `login_screen.dart` still uses
  `InputDecoration(labelText:)`. Two independent field-card implementations may
  land in the same requirement. Requirement integration review should check
  for divergence and decide whether to promote one into `design_system/`.

## Residual Risks

1. No golden/screenshot evidence exists for this screen; fidelity is verified
   by design-source-to-code reading plus property-level widget tests. That is
   the strongest evidence available in this repo's current setup, but it does
   not catch compositing or font-rendering differences.
2. Only dark theme + `vi` was verified, per the story's Out of Scope (OQ5).
   Light theme and `en` remain unverified by design.
3. N1 remains unowned at requirement level.

## Acceptance Criteria

| AC | Status | Note |
| --- | --- | --- |
| AC1 layout/spacing/token/typography | MET with P2 nit | 1.5dp card inset from the focus-ring border |
| AC2 deviations fixed in app, not documented | MET | D1-D8 are real code changes, re-verified |
| AC3 validation-state fidelity | MET | Design authors no error styling; existing `colorRed` treatment correctly retained rather than invented |
| AC4 no new entry point | MET | `_openLogin` and the `RegisterSuccess` route are byte-identical to base |

All four ACs pass on their own terms. The gate is held by P1, which is a
governing-artifact (auth UX spec section 7) violation on a control this story
newly introduced, not an AC failure.

## Required To Reach CLEAN

Fix P1 only. P2 and P3 are recommended in the same patch because the file is
open, but they do not gate. Re-run
`flutter test test/design_system test/features/auth` after the patch.

REVIEW_COMPLETE: PATCH_REQUIRED
