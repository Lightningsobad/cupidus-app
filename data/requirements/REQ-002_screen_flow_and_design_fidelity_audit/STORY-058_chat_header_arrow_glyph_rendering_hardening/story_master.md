# STORY-058: Chat Header Arrow Glyph Rendering Hardening

Status: IN_PROGRESS
Retro-Type: RED-PATCH
Fixes: STORY-018_chat_typing_ghost_design_fidelity
Complexity: standard
Story-Class: standard
Implementation Lane: shared (ui-ux-designer typography/glyph-rendering
decision, then tech-lead component-contract/font-fallback decision, then
mobile-dev implementation — no backend surface is involved)
Requirement: REQ-002
Scope: Retro-hardening (RWB-20260816-026)
Screens: `chat` only — the header's pairing-title separator glyph named by
D-1/F3. No other screen is in scope.
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`). The design source's header title is a hardcoded
static demo literal (`t_chat: 'Minh ↔ Linh'`,
`Cupid Screens.dc.html:1773/1785`) rendered as a monochrome arrow; no new
design-canvas render of a different screen state is required — a fresh
`chat` header capture on the same audited configuration (Android, dark
theme, `vi` locale) is required to re-prove the fix (see AC4).
Write scope: this story's own directory (`story_master.md`,
`requirements/requirements.md`, `ux/`, `architecture/`, and its own
`visual-fidelity/` evidence directory); the shared header widget
`mobile/lib/design_system/adaptive/cupid_header.dart`; the title-composition
source `mobile/lib/features/chat/presentation/chat_strings.dart`
(`headerPairingTitle`/`headerPairingSemanticLabel`/`_joinPair`, currently
lines 46-78); the header call site in
`mobile/lib/features/chat/presentation/screens/chat_screen.dart` (currently
lines 166-183) — touched only if the chosen remedy changes `CupidHeader`'s
`title` contract from a plain `String`; the matching literals/assertions in
`mobile/test/features/chat/presentation/chat_design_fidelity_test.dart`
(currently lines 521-526, 653, 667, 677); and
`mobile/test/design_system/adaptive_widgets_test.dart` — touched only if the
`CupidHeader` title contract changes and the other 16 consumers need a
regression assertion equivalent to STORY-052's Material tree-identity check.
One narrow, explicitly authorized exception to "no other story's files": the
single stale line at
`STORY-052_chat_header_partner_presence_hardening/visual-fidelity/visual-fidelity-report.md`
section 7 (currently line 317), for the D-S1 doc-correction folded into AC6
below — no other line, section, or file in STORY-052's directory is write
scope. No other `mobile/lib/**` file, and no other requirement/story
directory, is write scope.

## Artifacts
- [x] Requirements (Product Owner) — this file, `## Product Owner Triage`
- [x] UX Design (UI/UX Designer)
- [x] Architecture (Tech Lead) — `architecture/solution.md`,
      `coding-plan/master-plan.md`
- [ ] Implementation (Development) — Path A executed (separator glyph swap
      U+2194 → U+27F7 in `chat_strings.dart`; Path B correctly skipped, not
      reverted — Step-0 `cmap` check proved bundled Roboto also lacks
      U+2194). Reopened by `Iris-QC-26`'s `PATCH_REQUIRED` review
      (`review/review-report.md`, 2026-08-19): implementation substance and
      all named ACs pass, but three evidence/gate-record findings remain
      open — B-1 (story runtime startup smoke gate not satisfied; the
      recorded `NOT_APPLICABLE` cites a phase file, which cannot waive a
      story-level gate), B-2 (`visual-fidelity-report.md` is missing the
      literal `VISUAL_FIDELITY: PASS` token the DONE/visual gates read), B-3
      (`test-results.md` is missing the `## Entry Point Reachability`
      section required for a UI-facing story). No source code change is
      required; see the review report's `State Recommendation` for the
      bundled rework pass.
- [ ] Review (Reviewer)

## Background (Rework Item)

Source: `data/retro-audit/rework-backlog.md` — RWB-20260816-026, split out of
`STORY-052_chat_header_partner_presence_hardening`'s reviewer finding D-1/F3
(`review/review-report.md` §4, "Disposition of D-1 / F3 — the `↔` Emoji
Tile") while verifying that story's own AC2.

Finding: STORY-052 delivered the pairing text `Minh ↔ Linh` and an
online-presence chip in the shared `CupidHeader` widget, sourcing both names
from real backend data and closing RWB-20260816-017. On the audited Android
device/font stack, the pairing title's U+2194 (`↔`, LEFT RIGHT ARROW)
renders through the emoji font as a filled colour tile, where the locked
design source paints a thin monochrome arrow. Root cause: U+2194 carries an
emoji-presentation default. STORY-052's implementer attempted an in-story
fix — appending U+FE0E (VARIATION SELECTOR-15, text presentation) to the
string in `ChatStrings.headerPairingTitle` — built it, installed it,
re-captured the device, confirmed the emoji tile persisted unchanged
(Flutter's Android font fallback still resolves the emoji font ahead of the
text-presentation request), and **fully reverted** the attempt: the
production constant removed, both test literals restored to `'Minh ↔
Linh'`, the chat suite re-run green, and the delivered evidence capture
taken from the reverted build. The dead end is recorded in-code as a
dartdoc on `ChatStrings.headerPairingTitle`
(`mobile/lib/features/chat/presentation/chat_strings.dart:46-57`) so this
story's implementer does not repeat the same experiment without a new
reason.

Constraint: the header's own `ux/uiux-spec.md` §1.2 (STORY-052's own
artifact) explicitly fences the existing title style block — "Text content
only; do not touch this existing style block" — so STORY-052 could not
reach into `cupid_header.dart`'s title `TextStyle`/`titleTextStyle` or
restructure the title from a plain `String` into something that could carry
a glyph-scoped style. That fence is exactly why this is a separate story
with its own UI/UX Designer + Tech Lead scoping rather than an in-story
patch — the reviewer's own words: "Both remaining remedies — declaring a
text-presentation font on the title style, or replacing the separator
glyph — breach either that fence or the locked design source's literal
string. Demanding a patch here would be ordering the lane to violate its
own spec."

Reviewer verdict on STORY-052 was `DEFERRED_ONLY` specifically because of
this finding — not `CLEAN`, since the delta is real and clearly visible on
both slice reviewers' independently opened PNGs; not `PATCH_REQUIRED`
in-story, since no remedy was available inside that story's own governing
spec; not `BLOCKED`, since STORY-052's own AC2 pairing-text/real-data
requirement and AC3/AC4 presence-chip requirements were otherwise fully
met (AC2 verdict: "PASS (glyph presentation deferred as D-1)"). The
reviewer required, as a precondition of marking STORY-052 `DONE`, that this
deferral be given "a durable carrier beyond story-artifact prose" — this
story (via RWB-20260816-026) is that carrier.

Tracking anchor for the `chat` screen's fidelity scope (not reopened here):
`STORY-018_chat_typing_ghost_design_fidelity` — remains DONE/unmodified.
`STORY-040_chat_typing_ghost_design_fidelity_hardening` and
`STORY-052_chat_header_partner_presence_hardening` are also not reopened;
their closed git boundaries stay closed.

### D-S1 (secondary, LOW-severity, folded into this story — see AC6)

STORY-052's own reviewer also carried forward D-S1: that story's
`visual-fidelity/visual-fidelity-report.md` §7 (currently line 317) records
`Runtime startup smoke | — | NOT_APPLICABLE per
data/devops/system/runtime-command-registry.json (mobile-app)`, which the
reviewer found stale/false — the registry documents no such
`NOT_APPLICABLE` exemption for `mobile-app`, and STORY-052's own
`coding-plan/test-results.md` (currently line 428, `## Story Runtime
Startup Smoke`) was separately patched same-cycle to add a real production
runtime-smoke section. D-S1 does not gate any `DONE` decision and is not a
defect in shipped app behavior — it is a one-line documentation correction
in an already-DONE story's own evidence file. Folded into this story as
AC6 rather than filed as a separate trivial doc-fix pass, since this story
already re-touches the D-1 evidence trail in the same neighborhood and a
second standalone story for one stale line would be disproportionate
process overhead.

## Product Owner Triage

Complexity: standard — not trivial. This is a shared-component typography/
font-rendering defect with a real, already-tested constraint (STORY-052's
`ux/uiux-spec.md` §1.2 fence blocked one in-story remedy already) and at
least two live open design decisions (does the remedy touch the header's
title style contract at all; does it change the separator glyph itself).
Per `.claude/skills/product-owner/references/complexity-routing.md`, any
story needing a new UX decision or a new architecture decision must be
`standard` with `Implementation Lane: shared`, and a single-lane story that
bypasses UX/Architecture must not be classified `trivial` when those
decisions are live — both conditions apply here, so UX Design and Tech
Lead stay **active**, not `SKIPPED:trivial`.

`CupidHeader` (`mobile/lib/design_system/adaptive/cupid_header.dart`) is
the same shared component STORY-052 confirmed has 17 `lib/` call sites
(`chat_screen.dart` plus 16 others). Any remedy that changes its `title`
contract shape (not just the string content) must keep every one of those
16 other consumers rendering unchanged — the same backward-compatibility
guarantee STORY-052's Tech Lead already had to reason about for the
`trailing`/`titleSemanticLabel` slots.

### Investigation questions for UI/UX Designer + Tech Lead

This story does not resolve which remedy is correct — that is UX/Tech
Lead's decision, informed by the concrete findings below. Captured here as
scope, not as a preset answer:

1. **Why did VS15 fail, specifically?** STORY-052 disproved appending
   U+FE0E on the string alone. Is that because Flutter/Android resolves
   `fontFamilyFallback` (or the platform's default emoji-capable font, e.g.
   Noto Color Emoji) ahead of the text-presentation request regardless of
   the variation selector, or some other mechanism? Would an explicit
   `fontFamilyFallback` on the title's `TextStyle` that excludes
   emoji-capable fonts (paired with, or without, VS15) actually change the
   glyph presentation — this has not been tried, only the bare-string VS15
   attempt was.
2. **Would a different Unicode separator glyph render as plain text on the
   audited font stack without carrying an emoji-presentation default** (for
   example U+2194 has one, but not every arrow-like code point does), while
   still reading as a faithful "between two names" pairing indicator
   consistent with the design source's visual intent? If so, does swapping
   the glyph still count as "matching the design source" given the design
   source's own literal string is `'Minh ↔ Linh'` — this is a design-fidelity
   judgment call, not a mechanical one.
3. **Would an icon-asset/glyph replacement be simpler and more reliable than
   any text-based fix?** The project already bundles a custom icon font
   (`Material Symbols Rounded`, `mobile/pubspec.yaml:114-115`, consumed via
   `CupidIcons`) for exactly this kind of guaranteed-monochrome-glyph need.
   Replacing the inline `↔` character with a small `Icon`/`CupidIcons` glyph
   inside the title row is a structural option worth scoping — but note it
   would require restructuring `CupidHeader.title` from a single `String`
   into something that can host a mixed text+icon composition (a `Row` or
   `RichText`/`InlineSpan`-based title), which is a real component-contract
   change requiring Tech Lead's explicit design, not a content-only edit.
4. **Does changing the title-rendering approach require touching
   `ux/uiux-spec.md` §1.2's fenced style block, or not?** If the remedy is
   confined to the string/glyph choice inside `chat_strings.dart` (no
   `TextStyle` or `Text`-widget-shape change in `cupid_header.dart`), the
   fence is not touched. If the remedy requires a `fontFamilyFallback`
   addition to the title's `TextStyle`, or restructuring `title` into a
   widget/mixed-content shape, the fence *is* touched, and per this story's
   AC2 that requires an explicit, reviewed exception recorded in this
   story's own `ux/uiux-spec.md` — not a silent edit.
5. **Is this an Android-only concern, or does iOS need checking too?** The
   audited device/config for this REQ's fidelity evidence is Android, dark
   theme, `vi` locale (`design-fidelity-config.json`). `CupidHeader` renders
   the same `title` string through both `_IosHeader` and `_MaterialHeader`
   branches (`cupid_header.dart:164-169` and `:242`), so whatever remedy is
   chosen must not be verified on Android alone while silently changing (or
   leaving broken) the iOS rendering path — Tech Lead should note whether
   iOS is known-affected, known-unaffected, or unverified, and UI/UX
   Designer should decide whether iOS verification is in this story's scope
   or a documented follow-up.

## Acceptance Criteria

See `requirements/requirements.md` for the numbered AC set.

## Next Valid Step

Route to UI/UX Designer (active, not `SKIPPED:trivial`), then Tech Lead
(active, not `SKIPPED:trivial`), then Mobile Developer for implementation
and evidence capture, then Reviewer at the standard tier.

Do Not Re-read: `rework-backlog.md` RWB-20260816-026 detail section (already
captured verbatim above); STORY-052's `review/review-report.md` §4 and §5
D-1/D-S1 rows (already summarized above); STORY-018/STORY-040/STORY-052's
own artifacts beyond what's summarized here.
