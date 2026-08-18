# STORY-052 UX Spec — Chat header partner-pairing title + presence chip

## Design source

`cupid-app-design-system/project/Cupid Screens.dc.html`, the shared
`showHeader` block (lines 49-64), specifically the `showPartnerChip` node
(line 57-62), which the source's own JS demo-data wiring gates to
`showPartnerChip: sc === 'chat'` (line 2127) — i.e. this trailing chip is
chat-only in the design source itself, matching this story's scope. All
values below are transcribed verbatim from that block plus the shared
`:root`/`[data-plat]` CSS variables (lines 23, 26-27), not re-derived from the
compressed PNG capture at
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-040_chat_typing_ghost_design_fidelity_hardening/visual-fidelity/design-reference-chat-android.png`.
That PNG is still the right visual sanity-check image, but the HTML is pixel-
authoritative.

## Finding: the presence chip is about the partner, not the self

The design source's own variable names and demo-data wiring
(`partnerInitial: this.mine ? 'L' : 'M'`, `partnerName: this.mine ? 'Linh' :
'Minh'`, line 2118-2119) show the chip's avatar-initial and status text are
**the partner's**, driven by the same `partnerName` the app already sources
from `ChatPartnerStore.displayName` — not the self identity. (The captured
PNG happens to show a self-looking "M" only because that demo toggle was
`false` at capture time, i.e. viewed from "Linh"'s side, where the partner is
"Minh" — it is not evidence the chip is self-scoped.) The header **title**
string in the source is a hardcoded static demo literal (`t_chat: 'Minh ↔
Linh'`, line 1773/1785), not wired to either name variable at all, so it
carries no ordering evidence either way — `story_master.md`'s AC1 `<self> ↔
<partner>` ordering is the product decision and remains authoritative
independent of this demo hardcode.

**Implication for Tech Lead:** the presence chip's avatar-initial and status
text need only the partner's display name, which is already synchronous and
session-scoped via `ChatPartnerStore.displayName` today. The async self-
profile-sourcing problem flagged in Product Owner Triage applies to the
**pairing title's** self half only, not to the presence chip.

## 1. Populated state — visual spec

Layout, left to right, vertically centered within the existing header row
(`CupidHeader`'s current `Row`, `crossAxisAlignment` already effectively
centered):

1. Existing back affordance (untouched, out of scope).
2. Pairing title, in the position/flex behavior `title` already occupies
   today (`Expanded`/`flex:1`, single-line, `TextOverflow.ellipsis`) —
   **unchanged styling**: `type.display` copied with `fontSize: 21`,
   `fontWeight: FontWeight.w800`, `letterSpacing: -0.21`, `color:
   colors.colorText` (the Material variant's existing `titleTextStyle` in
   `cupid_header.dart:184-189` already matches the design source's `font-
   family:Nunito;font-weight:800;font-size:21px;letter-spacing:-.01em`
   exactly — no title-style change needed, only the string content changes to
   the `<self> ↔ <partner>` format per `story_master.md` AC1). Text content
   only; do not touch this existing style block.
3. A `10dp` gap between the title's trailing edge and the presence chip
   (design source's outer row `gap:10px`, line 50) — this is new spacing that
   does not exist today between `title` and `actions`; needed because the
   chip is a fixed-width trailing element like the existing `actions` slot,
   but nothing currently guarantees a gap in that trailing position.
4. The presence chip, a **non-interactive** (no tap target — the source node
   carries no `onClick`, unlike other chips unlike e.g. the Emoji Storm chip)
   pill:
   - Container: `Row`, `mainAxisSize: MainAxisSize.min`, gap `7dp` between
     avatar cluster and text (design source `gap:7px`).
   - Padding: top `5dp`, right `10dp`, bottom `5dp`, left `6dp` (design
     source `padding:5px 10px 5px 6px` — asymmetric; left is tighter because
     the avatar circle sits flush to the pill's rounded edge).
   - Background: `colors.colorSurface`, `borderRadius: BorderRadius.circular(999)`
     — **identical container recipe to the existing `_PrivacyChip` in
     `chat_screen.dart:284-331`** (`color: colors.colorSurface,
     borderRadius: BorderRadius.circular(999)`), confirmed by the design
     source's own `background:var(--surf)` on this node. Reuse that same
     pattern rather than inventing a new pill treatment.
   - Avatar: a `24dp x 24dp` circle (`border-radius:50%`), containing the
     partner display name's first character, **uppercased** (matches the
     existing avatar-initial precedent at
     `home_screen.dart:381-383`'s `displayName.substring(0,1).toUpperCase()`
     — the design source's own literal `'L'`/`'M'` values are already
     uppercase). Glyph: `fontSize: 10`, `fontWeight: FontWeight.w700`,
     color `#FFFFFF` — reuse the existing `CouplePresencePalette.avatarInitial`
     token (`design_system/tokens/couple_presence_palette.dart:42`, already
     declared as exactly this `#fff`-in-both-themes value) rather than a new
     literal.
   - Avatar fill: `linear-gradient(135deg, #00C9A7, #7B2FBE)` (design source
     line 59). **This is a new gradient pair, not present in any existing
     token** — it does not match `CupidColorTokens.colorMint`/`.colorGreen`
     (`#79E2CD`/`#22B398`) nor either stop pair in
     `CouplePresencePalette`/`CoupleAvatarGradients` (`#FFB1D3→#C79BF0` /
     `#A8F0DF→#C79BF0`). `#7B2FBE` does match
     `CupidColorTokens.gradientBrandBackdrop`'s first stop, but that token is
     documented as backdrop-only and must not be reused for a small fill
     (see its dartdoc: "Backdrops must not reuse it"). Tech Lead/design-
     system owner should add this as its own small additive token file
     (e.g. alongside `couple_avatar_gradients.dart`,
     `couple_presence_palette.dart`), not inline in `lib/features` (ADR-004 /
     `no_fork_guard_test.dart`) and not folded into `CupidColorTokens`. Use
     the same 135deg vector derivation already established in
     `couple_avatar_gradients.dart`/`couple_presence_palette.dart`
     (`Alignment(-0.7071067811865476, -0.7071067811865476)` →
     `Alignment(0.7071067811865476, 0.7071067811865476)`) since 135deg
     recurs verbatim.
   - Online dot: `8dp x 8dp` circle, positioned at the avatar circle's
     bottom-right corner overlapping by `1dp` (design source
     `position:absolute;right:-1px;bottom:-1px`) — in Flutter terms, a
     `Stack`/`Positioned(right: -1, bottom: -1)` over the `24x24` avatar,
     matching the same `Stack`-of-circle pattern already used for the
     overlapping avatars in `home_screen.dart:393-408`. Fill:
     `colors.colorGreen` (verbatim `var(--green)` match — dark `#79E2CD`,
     light `#22B398`, both exact hex matches to `CupidColorTokens`, no new
     token needed here). Ring: `2dp` solid border in `colors.colorSurface`
     — **note this differs from the Home avatar-stack ring**, which borders
     in `colors.colorBackground`
     (`home_screen.dart:458`, `Border.all(color: colors.colorBackground)`);
     the design source explicitly borders this dot in `var(--surf)` (the
     chip's own pill background color, not the screen background), because
     the dot sits on the chip pill, not directly on the screen. Do not copy
     the Home ring-color precedent here.
   - Status text: `fontSize: 11`, `color: colors.colorTextMuted` (verbatim
     `var(--tx2)` match). Use `context.cupidType.caption` as the base style
     (already the app's metadata/timestamp role) with `fontSize` overridden
     to `11` the same way `_PrivacyChip` overrides `caption`'s size for its
     own off-scale value (`chat_screen.dart:35,321-323` precedent for a
     caption-role override at a design-source-literal size not on the
     documented 13pt caption scale).
   - Copy: the design source's literal string is `đang online` (vi) /
     `online` (en) (`partnerStatus`, line 2128). `story_master.md` AC2
     confirms this ships as a fixed v1 stub label in the `vi` locale scope
     this story verifies; follow the app's existing `ChatStrings`/l10n ARB
     pattern for where this string lives (implementation detail, not a UX
     decision) rather than a bare literal, so an `en` string exists for
     parity even though only `vi` is in this story's AC scope.

## 2. Unset/default state

When the new slot is not passed (all 16 other existing `CupidHeader`
consumers), render nothing in its place — no reserved space, no gap. The
`10dp` gap in section 1.3 only exists when the slot is populated; it must not
appear as dead trailing space when the slot is absent. This preserves AC3/AC4
(pixel-identical render for the other 16 consumers) by construction: the
title keeps its full existing `Expanded` width and the row has the same
number of visible children as today.

## 3. Responsive / overflow behavior

- The presence chip has a fixed intrinsic width (`Row` with
  `mainAxisSize: MainAxisSize.min` inside the header's outer `Row`) and never
  shrinks or wraps.
- The pairing title keeps its already-existing `Expanded` + single-line
  `TextOverflow.ellipsis` behavior (already present in `_IosHeader`'s title
  `Text`, `cupid_header.dart:133-139`; `_MaterialHeader`'s `AppBar` title
  truncates by the same default single-line mechanism). When the combined
  `<self> ↔ <partner>` string plus the chip don't both fit, the title yields
  space and ellipsizes sooner than it does today (a strictly wider chip-free
  case) — no new truncation mechanism is being designed here, the existing
  one now has a fixed-width neighbor to share the row with.
- No minimum-width guarantee is defined for the title beyond what `Expanded`
  already provides; a title reduced to a single truncated character in an
  extreme case is accepted, matching how every other long single-string
  title in this header already degrades today.

## 4. Accessibility

- **Pairing title.** The `↔` glyph is a visual convention, not something a
  screen reader should read literally (VoiceOver/TalkBack render it as "left
  right arrow" or similar, which is not meaningful). Wrap the title text in
  a `Semantics` node with an explicit `label` that drops the glyph in favor
  of a natural phrase — e.g. `"<self> và <partner>"` (vi) — while the visible
  `Text` keeps the `↔` glyph unchanged. This mirrors the existing
  `paired_screen.dart` precedent of separating the visible decorative
  presentation from the accessible textual signal (`paired_screen.dart:70-87`:
  `ExcludeSemantics` on the decorative avatar cluster, a clean `Semantics`
  string carrying the real announcement).
- **Presence chip.** Wrap the whole avatar+dot+text cluster in one
  `Semantics` node with a single coherent `label` (e.g. `"<partner display
  name> đang online"`, matching the vi-locale copy) so assistive tech
  announces one phrase, not three disconnected fragments (a bare initial
  letter, a color swatch, a status string). Individually exclude the
  decorative avatar-initial glyph and dot from the semantics tree
  (`ExcludeSemantics` on that inner cluster), the same pattern as
  `paired_screen.dart`'s `_CoupleCelebration`.
- The chip is not a tap target (section 1, no `onClick` in the design
  source) — do not add a `button` semantic role to it.

## Out of scope (unchanged from story_master.md)

No change to `CupidHeader`'s existing `title`, `onBack`, `backLabel`, or
`actions` contract/styling beyond the new additive slot's own content and the
`10dp` trailing gap defined in section 1.3. No wiring into any of the other
16 consumers. No real presence computation — the online dot and `đang
online`/`online` copy are always-on static visuals per `story_master.md`
AC2, not conditionally rendered on any live signal.
