# STORY-058: Chat Header Arrow Glyph Rendering Hardening — UX Spec

Scope: the `chat` screen header's pairing-title separator glyph only. No
other visual, copy, or interaction change. This spec answers the five
investigation questions from `story_master.md` `## Product Owner Triage`
and the AC2 style-block-fence decision.

## 1. Recommended remedy: direction (b) — swap the separator glyph

Recommendation: replace the pairing-title separator character in
`ChatStrings.headerPairingTitle` (`mobile/lib/features/chat/presentation/chat_strings.dart:58-61`)
from **U+2194 (`↔`, LEFT RIGHT ARROW)** to **U+27F7 (`⟷`, LONG LEFT RIGHT
ARROW, Supplemental Arrows-A block)**.

Why this glyph, specifically:

- U+27F7 is outside the Unicode emoji character repertoire entirely (the
  only bidirectional/diagonal arrows with an emoji-eligible codepoint are
  U+2194/U+2195/U+2196–U+2199 and the double-headed U+21A9/U+21AA in the
  base Arrows block — Supplemental Arrows-A, where U+27F7 lives, has no
  emoji-table entries at all). Android's font-fallback resolver only routes
  a codepoint to the colour emoji font when that codepoint has an
  emoji-table entry, so U+27F7 has no path into `Noto Color Emoji` the way
  U+2194 does — this is a structurally different situation from the VS15
  attempt, not a repeat of it.
- Visually it is the closest available substitute to the design source's
  intent: both U+2194 and U+27F7 are single-stroke, symmetric,
  double-headed horizontal arrows — the only difference most typefaces
  render is a slightly longer shaft on U+27F7. It preserves the "two names,
  mutually connected" reading the design source's literal `'Minh ↔ Linh'`
  is going for, unlike a single-direction arrow (`→`/`←`, which would wrongly
  imply direction) or a non-arrow separator (`×`, bullet, dash, which would
  drop the "connection" reading entirely).
- The header title's `TextStyle` uses `fontFamily: 'Nunito'`
  (`mobile/lib/design_system/tokens/cupid_typography_tokens.dart:32`), which
  does not itself carry Arrows-block glyphs for either code point — both
  already depend on Flutter's platform font-fallback chain to resolve a
  glyph. The defect is that for U+2194 that chain lands on the colour emoji
  font; for a non-emoji-eligible code point it should land on a plain
  symbol-capable fallback font instead. This is Tech Lead's mechanism to
  confirm on-device (see §3), not something I can verify from source alone.

### Fallback if U+27F7 proves infeasible

If Tech Lead/mobile-dev's on-device check finds U+27F7 is missing from the
audited device's available fallback fonts (renders as a tofu/missing-glyph
box rather than a monochrome arrow), the fallback path is **direction
(a)**: keep `↔` (U+2194) and add an explicit `fontFamilyFallback` to the
title `TextStyle` that lists only non-colour, symbol-capable fonts and
excludes `Noto Color Emoji` (or the platform's equivalent colour-emoji
font). This is a materially new mechanism versus the disproven bare-string
VS15 attempt — VS15 asked for text presentation without changing which
fonts are eligible to supply the glyph; an explicit `fontFamilyFallback`
changes which font supplies it. If direction (a) is needed, it touches the
fenced style block — see §2's exception clause, which is pre-authorized to
cover this fallback so a second UX pass is not required to invoke it.

I am not choosing direction (c) (structural icon-asset title). It requires
restructuring `CupidHeader.title` from a `String` into a mixed text/icon
composition, which is a real component-contract change across 17 call
sites for a defect that a string-literal-only fix should resolve. Direction
(b) is simpler, lower-risk, and sufficient; reserve (c) only if both (b) and
its (a) fallback are proven infeasible on-device, in which case Tech Lead
should return to Scrum Master rather than silently escalating scope.

## 2. AC2 fence decision: style block left untouched (path (a) of AC2)

Direction (b) is a change to a string literal in `chat_strings.dart` only.
It does not touch `cupid_header.dart`'s title `TextStyle`/`titleTextStyle`
blocks (the `type.display.copyWith(...)` in `_IosHeader` at
`cupid_header.dart:164-169`, or the `titleTextStyle`/`title: Text(...)` in
`_MaterialHeader` at `cupid_header.dart:223-228,242`) at all — those blocks
stay byte-unchanged. This satisfies AC2(a): "that style block is left
byte-unchanged because the fix is glyph-choice ... only." STORY-052's own
`ux/uiux-spec.md` §1.2 fence remains fully intact for this story.

**Pre-authorized exception (only if the §1 fallback is invoked):** if
Tech Lead/mobile-dev must fall back to direction (a) because U+27F7 is not
renderable on the audited device, that fallback is permitted to add a
`fontFamilyFallback` list to the two `type.display`-derived `TextStyle`
call sites named above — and only that: no other property of those
`TextStyle`s (font family of the primary face, size, weight, letter
spacing, color source) may change. This is safe for `CupidHeader`'s other
16 consumers because `fontFamilyFallback` only supplies glyphs the primary
font (`Nunito`) is missing — it does not change how any character that
`Nunito` already renders looks, so every other consumer's existing title
text (which `Nunito` already fully covers) renders pixel-identical to
today. Tech Lead must still record this exception explicitly in
`architecture/solution.md` if invoked (this UX pre-authorization does not
substitute for that record) and must exclude the platform's colour-emoji
font by name from the fallback list, not rely on ordering alone.

## 3. Semantic label: unaffected, holds as-is

`ChatStrings.headerPairingSemanticLabel` (`chat_strings.dart:66-71`) already
substitutes the visual separator with the localized conjunction word
(`'và'`/`'and'`) via a separate `_joinPair(..., context.viEn('và', 'and'))`
call — it never reads the visual glyph character at all, for either U+2194
today or U+27F7 after this change. No code change is required in
`headerPairingSemanticLabel` for this remedy, and assistive tech continues
to announce "`<self> và <partner>`" / "`<self> and <partner>`", never a
glyph name. This confirms the AC/business-rule requirement that the
accessible-substitution behavior still holds.

## 4. iOS scope: verification is a documented follow-up, not in this story's scope

This story's device-capture verification stays Android/dark/`vi` only,
matching this REQ's established audited configuration (AC4 only requires an
Android capture). I am not adding an iOS capture to this story's scope.

Reasoning for why this is safe to defer rather than a silent gap: the
chosen remedy is a single shared string literal
(`ChatStrings.headerPairingTitle`) consumed identically by both
`_IosHeader` and `_MaterialHeader` — `CupidHeader.build` passes the same
`title` string to both platform branches with no platform-conditional glyph
logic anywhere in this change. There is no platform-specific code path for
Tech Lead or mobile-dev to diverge on, so the fix cannot "work on Android
while silently leaving iOS broken" the way a platform-branching change
could. U+27F7 is not an emoji-eligible code point on iOS either (Apple
follows the same Unicode emoji-property table Android's font-fallback logic
keys off of), so the same reasoning that avoids Android's colour-emoji
substitution applies to iOS's — but this is inference from the shared
string path and Unicode's emoji properties, not a device observation.

Action: Tech Lead/mobile-dev should record in `architecture/solution.md`
(or `coding-plan/test-results.md`) that iOS was not device-verified in this
story and, per this story's `Dependencies` clause, flag a lightweight
follow-up note to Scrum Master for an iOS capture — not a new story, not a
blocking condition — the next time an iOS device/simulator capture is
already in flight for any other REQ-002 work, rather than leaving it
unrecorded the way STORY-052's D-1 originally was.

## 5. Design-fidelity judgment: glyph swap still matches the design source

The design source's own literal is the static demo string `'Minh ↔ Linh'`
(`Cupid Screens.dc.html:1773/1785`), rendered in the design tool as a thin,
single-weight, monochrome arrow — the design intent is a **visual and
semantic** one (a mutual, two-way connector between two names, in the
header's single typographic weight), not a pixel-exact Unicode-codepoint
requirement. AC4's comparison is a rendered-capture `MATCH`/`DEVIATION`
verdict, not a source-string diff. U+27F7 renders as the same thin
single-stroke double-headed horizontal arrow shape the design source shows
— visually indistinguishable from U+2194 in this header's typography at a
glance, and semantically identical (mutual pairing, not one-directional).
On that basis, direction (b) is design-fidelity-faithful: it corrects the
platform-rendering defect (colour emoji tile) without changing what the
design source is communicating. Record the fresh capture's `MATCH` verdict
in this story's own `visual-fidelity/visual-fidelity-report.md` against
this reasoning, per AC4.

## Decision summary for Tech Lead

- Primary mechanism: change the separator argument passed to `_joinPair` in
  `ChatStrings.headerPairingTitle` from `'↔'` (U+2194) to `'⟷'` (U+27F7).
  Confirm on the audited device that Nunito's fallback chain resolves
  U+27F7 to a monochrome symbol font, not a colour font.
  `headerPairingSemanticLabel` needs no change (§3).
- `cupid_header.dart`'s fenced title style block: untouched under the
  primary mechanism (§2, AC2(a)). If the fallback in §1 is invoked instead,
  the pre-authorized, narrowly-scoped `fontFamilyFallback` exception in §2
  applies (AC2(b)) — Tech Lead still records it explicitly.
  `CupidHeader.title`'s `String` contract is not restructured either way, so
  AC3 is satisfied by "the contract does not change" (no new regression
  test burden on the other 16 consumers) unless the §1 fallback's own
  `fontFamilyFallback` addition needs a lightweight rendering-parity check —
  Tech Lead's call.
- iOS: documented follow-up, not in this story's verification scope (§4).
- No change needed to `chat_screen.dart`'s header call site — direction (b)
  does not change `CupidHeader.title`'s contract shape.
