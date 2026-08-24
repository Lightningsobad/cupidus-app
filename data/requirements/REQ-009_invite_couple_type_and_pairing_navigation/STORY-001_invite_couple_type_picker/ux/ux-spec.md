# UI/UX Specification - Invite Couple-Type Picker

## 1. Metadata

- Related Story: `STORY-001_invite_couple_type_picker` (REQ-009)
- Source Requirement Paths:
  - `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/req_master.md` `## Locked Navigation Decisions` item 1, `## Scope For Product Owner / UI-UX / Tech Lead`
  - `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/story_master.md`
  - `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/story_brief.md`
  - `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/requirements/requirements.md` `## Business Rules And Guardrails` (authored vi/en catalog — reused verbatim, not re-authored here)
- Target Directory: `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/ux/`
- Mode: Brownfield
- Status: Final
- System UX Memory Path: `data/ux/system/ui_ux_system_memory.md`
- System UX Memory Action: Read Only — no shared-pattern change; this story extends the existing selectable-card grammar already recorded there (see §6.2), it does not introduce a new one.

## 2. Context Summary

- User goal: after seeing my pairing code, tell the app what kind of couple we are, in one tap, before continuing.
- Primary user mode: First-time (this is a one-time onboarding step; a user only sees this screen again via back-navigation before pairing completes — see AC5).
- Business outcome: captures relationship-type context at the moment it is cheapest to ask, closing the content gap STORY-011 explicitly excluded.
- Existing specs reviewed: none exist yet for this screen's couple-type section — `ux/uiux-spec.md` referenced in `invite_screen.dart`'s own doc comments predates this story and only covers the code-display + share/copy card (see design debt below).
- Existing UI patterns found:
  - `mobile/lib/features/pairing/presentation/screens/invite_screen.dart` — the current `_InviteCodeCard`: `colorSurface` container, `radiusCard`, `elevationShadow`, `_cardPadding` (20h/22v), inside a `SingleChildScrollView` with `_screenPadding` (20/18/20/40).
  - `mobile/lib/features/vibes/presentation/widgets/vibe_mood_grid.dart` (`VibeMoodGrid`/`_MoodCell`) — the repo's established single-select icon-card grid: unselected = `colorSurface` fill + `colorSurface`-colored 1.5px border (so selecting never resizes the cell) + `elevationShadow`; selected = 140deg translucent pink→purple gradient fill (`colorAccentPink`@0.3 → `colorAccentPurple`@0.26) + solid `colorAccentPink` border + `glowShadow`; label weight steps 600→800 and color `colorTextMuted`→`colorText` on selection. `Semantics(button: true, selected: isSelected)` wraps an `ExcludeSemantics` gesture target sized to `platform.tapTarget`.
  - `mobile/lib/features/pet/presentation/widgets/species_picker.dart` (`SpeciesPicker`) — a lighter single-select card (horizontal scroll, `inMutuallyExclusiveGroup: true` semantics), used in a bottom sheet, not a full-width in-flow grid.
- Existing components reused or extended: `VibeMoodGrid`'s selected/unselected visual treatment is reused (extended to a 4-cell 2x2 grid with icon+label+subtext instead of face+label) because it is the closer precedent for a full-width, in-flow, mandatory single-select card grid — `SpeciesPicker`'s treatment belongs to a lighter, non-mandatory, horizontally-scrolling sheet context that does not fit this screen. `CupidPrimaryButton` is reused unmodified for Continue (disabled/enabled states already built in).
- Current UX debt or consistency risks: `invite_screen.dart`'s own doc comment states it is "Scoped to only the code-display + share/copy card ... no couple-type picker" — this was a deliberate prior-story exclusion, not organic debt, and this story is the story that closes it.
- Current organization or hierarchy issues in the affected area: none introduced by this story; the screen currently ends abruptly at the share/copy actions with no couple-context capture, which is exactly the gap this story closes.
- Stable shared patterns vs local debt: the selectable-card visual grammar (gradient-fill selected state, `glowShadow`, `colorAccentPink` border) is a stable shared pattern (`VibeMoodGrid`) — reused, not reinvented. The screen-local layout (code card → couple-type section → Continue, inside one `SingleChildScrollView`) is new to this screen but composes existing shared primitives.
- Open Question Impact source: `story_master.md` `## Open Question Impact` (OQ5).
- Open assumptions: none — `CupidProfile.coupleType` persistence mechanics (API call shape, offline/error handling) are explicitly Tech Lead's confirmation per the story brief; this spec specifies the UI-visible states only (selected/unselected, mandatory-disabled, pre-filled-on-return), not the wire format.

## 3. Open Question Impact

- **OQ5 (light theme / EN locale in v1)**:
  - Status: UNRESOLVED, non-blocking (same disposition as REQ-002 STORY-011/036/037).
  - UX Scope Blocked: none.
  - UX Scope Still Designed: full dark-theme + `vi`-locale spec below; `en` copy is specified as data (§6.4/§6.5) so it is implementation-ready if/when OQ5 resolves, but only dark+`vi` gets a rendered fidelity pass.
  - UX Decision: no dedicated light/EN rendered fidelity pass required for this story.

## 4. Requirement-To-Design Traceability

- **Locked Navigation Decision 1 (`req_master.md`)** — couple-type picker placement:
  - UX Response: 4-card grid section titled "Tụi mình thuộc kiểu nào?" is placed inside the existing invite screen's scrollable body, directly below the existing `_InviteCodeCard`, above a new Continue CTA. Not a separate screen, not a modal — same scroll surface as the code card.
  - Affected Screen / Component / Flow: `invite` screen (`mobile/lib/features/pairing/presentation/screens/invite_screen.dart`), `_InviteView.build`'s `InviteReady` branch.
- **AC1 (story_master.md)** — code first, then 4-card section, then Continue:
  - UX Response: single-column stack inside the existing `SingleChildScrollView`: `_InviteCodeCard` → `CupidSpacing.lg` gap → couple-type section (heading + 2x2 grid) → `CupidSpacing.lg` gap → Continue CTA.
  - Affected Screen / Component / Flow: `invite` screen body.
- **AC2/AC3 (mandatory single-select, disabled/enabled Continue)**:
  - UX Response: Continue uses `CupidPrimaryButton`'s existing disabled visual state (see `_InviteError`'s own use of the same component for a precedent instance) gated on `selectedCoupleType != null`; selecting a new card always deselects the previous one (single `selected` value, not a set).
  - Affected Screen / Component / Flow: new `_CoupleTypeSection` + `_CoupleTypeGrid` widgets, existing `CupidPrimaryButton`.
- **AC4/AC5 (persist to `CupidProfile.coupleType`, pre-fill on return)**:
  - UX Response: the grid's `selected` value is driven by the ready state's existing selection (from a prior in-session pick or the persisted profile value) — a state/cubit concern, not new UI in this story, but the UI must render whichever card matches on first paint, with no flash-of-unselected state.
  - Affected Screen / Component / Flow: `invite` screen's `InviteReady` state shape (Tech Lead/mobile-dev to extend with a `coupleType` field mirroring `invitation`/`remaining`).
- **AC6 (design fidelity)**:
  - UX Response: see §6.8 (revised, PATCH_REQUIRED F1) — a rendered design source for this exact node DOES exist: `cupid-app-design-system/Cupid Screens.dc.html`, `isInvite` screen state (`sc === 'invite'`). The earlier "no design source exists" exemption only held for the sibling canvas `Cupid App.dc.html`, which never had this screen; it was wrongly generalized to "no design source" for the whole node. AC6 is satisfied by a real rendered comparison against this source (or the REQ-001-era `design-reference-invite-android.png` capture from the same canvas), not by finder-assertion substitution.
  - Affected Screen / Component / Flow: couple-type section only.
- **AC7 (no picker on join-code screen)**:
  - UX Response: out of scope for this spec by construction — this spec touches only `invite_screen.dart`; `join_code_screen.dart` is untouched.
  - Affected Screen / Component / Flow: N/A (negative assertion, no design needed).

## 5. Critical User Tasks And Success Criteria

- **Select a couple-type and continue**:
  - User Mode: First-time.
  - Entry Point: arriving at the `invite` screen's `InviteReady` state (code already generated and visible).
  - Success Signal: exactly one card shows the selected treatment, Continue becomes enabled, tapping Continue proceeds (destination owned by STORY-002).
  - Primary Risk: user does not notice the section requires a choice before Continue works (mitigated by Continue's visible-but-disabled state, not a hidden/absent CTA — see §6.4).

- First-use guidance or discoverability needs: none beyond the section heading itself ("Tụi mình thuộc kiểu nào?") — the 4 cards are visible immediately, no progressive disclosure needed for 4 items.
- Completion or post-completion state: Continue enabled + pressed → screen navigation is STORY-002's scope; this story's completion state is "exactly one card selected, Continue enabled."
- Retry, edit, undo, or next-action behavior: tapping a different card at any time before Continue is pressed re-selects (AC3) — this is the only "edit" affordance in scope; editing after Continue is explicitly out of scope (story_master.md `## Out of Scope`).
- What would make the task feel unfinished or unsafe to the user: a disabled Continue with no visible reason (mitigated — the section sits directly above Continue with an unmissable "choose one" framing via the heading + 4 always-visible options, no explanatory microcopy needed for a 4-option single-select).

### 5.1 System Entry And Discoverability

- Existing surface, workflow, or state where the actor starts: the existing `invite` screen, already reached via its existing navigation path (unchanged by this story per story_master.md).
- Required entry point, navigation item, CTA, or in-flow discovery path: none new — content is added to an already-reachable screen's existing scroll body.
- Direct URL only acceptable per PO scope: N/A — existing reachable screen.
- Entry point states: default (0 selected, Continue disabled) / one selected (Continue enabled) / pre-filled-on-return (one selected from prior session, Continue enabled on first paint). No loading/permission-limited state — the grid renders synchronously once `InviteReady` is reached; the code-fetch loading state is unchanged (`InviteLoading`/`InviteFailed` already exist and are untouched by this story).
- Surfaces intentionally not updated: `join_code_screen.dart` (AC7); `pairing_choice_screen.dart` (STORY-002's scope).

## 6. UX Design

### 6.1 Affected Screens / Areas

- **`invite` screen body (`InviteReady` branch)**:
  - Purpose: capture couple-type before the inviter continues past their pairing code.
  - Change Type: Extend (existing screen, existing scroll container, existing `CupidPrimaryButton`; new section + new grid component).
  - Notes: `NO_CHROME`/`NO_TABS` unchanged — this story adds body content only, no header/chrome change.

### 6.2 Design Progression

- Current issue in the affected area: the screen ends at "Share invite / Copy code" with no couple-context capture — a deliberate prior-story scope cut (`invite_screen.dart` doc comment), not organic debt, but still a gap relative to the product's actual data need.
- Why it hurts comprehension, consistency, or trust: relationship-type context has no capture point anywhere in the product once this screen is passed (story_master.md `## Out of Scope`: no editing later, no other surface) — skipping it here means it is lost for that inviter permanently.
- Design progression introduced by this story: the invite screen becomes a two-step in-flow capture (code → context) instead of a single-purpose code-display card, using the repo's own established selectable-card grammar (`VibeMoodGrid`'s gradient-selected treatment) so the addition reads as native to the design system rather than a bolted-on form.
- Shared rule preserved, clarified, or evolved: preserved — the selected/unselected card treatment, spacing rhythm (`CupidSpacing` scale, `_screenPadding`/`_cardPadding` precedent), and `CupidPrimaryButton` disabled/enabled contract are all reused unchanged.
- Deferred debt not solved in this story: promoting the transcribed `_iosShareIcon`/`_contentCopyIcon`-style local `IconData` constants and any new couple-type glyphs into `CupidIcons` proper is explicitly out of this story's write scope (mirrors the existing `invite_screen.dart` comment on `_iosShareIcon`/`_contentCopyIcon`) — new couple-type icon constants should follow the same local-first pattern until `design_system/` is in a story's write scope.

### 6.3 Page Anatomy And Visual Grouping

- Page or surface anatomy (top to bottom, inside the existing `SingleChildScrollView`, `_screenPadding`):
  1. In-chain back button (unchanged).
  2. `_InviteCodeCard` (unchanged) — code, share/copy actions.
  3. `CupidSpacing.lg` gap.
  4. New couple-type section: heading ("Tụi mình thuộc kiểu nào?") → supporting subtext line ("Cupid sẽ bật/tắt tính năng phù hợp cho kiểu của bạn." / "Cupid tunes default features to your type.") → `CupidSpacing.md` gap → 2x2 card grid. This subtext line was missing from the original spec/build (see §6.8 PATCH_REQUIRED F1) — it is present in the resolved design source directly under the heading, above the grid.
  5. `CupidSpacing.lg` gap.
  6. New Continue CTA (`CupidPrimaryButton`, full width).
- Primary visual groupings: the code card stays a single bounded surface (unchanged); the couple-type section is NOT wrapped in its own `colorSurface` card — it sits directly on the screen background (matching how `VibeMoodGrid` sits directly on `vibe_screen.dart`'s background, not inside a card), so the 4 cards themselves — not an outer container — read as the selectable unit.
- Primary action and supporting actions: Continue is the primary action for this section; the 4 cards are the required input, not actions in themselves (each is a toggle, not a navigating action) — Share/Copy remain the code card's own actions, subordinate to and visually separated from the couple-type section by the `CupidSpacing.lg` gap.
- Visual emphasis strategy: selected-card gradient fill + `glowShadow` gives the chosen card the same "hot" visual weight the design system already reserves for primary/active elements (`gradientHot` on Share invite), so a selected couple-type reads as confidently chosen, not just checked.
- What should be easier to scan than before: N/A — this is new content, not a reorganization of existing content.

### 6.4 Primary Flow, Hierarchy, And Key States

- Entry point: `InviteReady` state, scrolled or unscrolled position on the `invite` screen.
- Primary action and why it is primary: Continue — it is the only way to leave this screen going forward, and its enabled state is the direct signal that the required input is satisfied.
- Supporting actions and how they stay subordinate: the 4 cards are inputs, rendered without the pill/gradient-fill CTA treatment `CupidPrimaryButton`/`_ShareInviteButton` use, so Continue remains the single button-styled affordance in the section.
- Happy path: code shown → user scrolls to couple-type section → taps one card → card shows selected state → Continue enables → user taps Continue.
- Important alternative, error, loading, empty, completion, or post-completion states:
  - 0 selected (default/first visit): all 4 cards unselected, Continue rendered in `CupidPrimaryButton`'s disabled visual state (present, not hidden — a disabled-but-visible CTA is the existing pattern for "action gated on input," matching how the rest of this codebase gates CTAs, e.g. `_InviteError`'s Retry button being the only CTA shown in its state rather than a conditionally-hidden one).
  - 1 selected (any of the 4): that card shows selected treatment, the previously selected card (if any) reverts to unselected, Continue enables.
  - Pre-filled-on-return (AC5): on first paint of `InviteReady`, if a prior selection exists (in-session or persisted), that card renders already selected and Continue is already enabled — no re-tap required.
  - No loading/error state is introduced by this story: the couple-type section only renders once `InviteReady` is reached; `InviteLoading`/`InviteFailed` are unchanged.
- Recovery path when the user is blocked, unsure, or interrupted: tapping any other card always corrects the selection (single-select, no "confirm" step); there is no destructive action in this section to recover from.

### 6.5 Component Changes

- **`_CoupleTypeSection` (new, screen-local widget in `invite_screen.dart` or a co-located file in the same directory)**:
  - Reuse / Extend / New: New (thin wrapper: heading text + supporting subtext text + `_CoupleTypeGrid`).
  - Key Behavior / State Notes: heading uses `context.cupidType.body` weight `w700` (matching the code card's own use of `type.caption`/`type.body` sizing conventions), color `colors.colorText`, `context.viEn('Tụi mình thuộc kiểu nào?', 'What kind of couple are we?')`. **Added in PATCH_REQUIRED F1 (previously missing from spec and build):** a supporting subtext line directly below the heading, `context.cupidType.caption` weight `w400`, color `colors.colorTextMuted`, `context.viEn('Cupid sẽ bật/tắt tính năng phù hợp cho kiểu của bạn.', 'Cupid tunes default features to your type.')`, `2`px gap below the heading (matches the design source's `margin-bottom:4px` on the heading / stacked subtext), `CupidSpacing.md` gap between the subtext and the grid.
  - Accessibility Notes: heading is a plain `Text`, read by screen readers as a preceding label for the grid (no explicit `Semantics(header: true)` required — matches how `_InviteCodeCard`'s own "Mã ghép đôi của bạn" label is a plain caption `Text`, not a marked semantic header). Subtext is also a plain `Text`, read after the heading in document order.

- **`_CoupleTypeGrid` (new, modeled directly on `VibeMoodGrid`/`_MoodCell` — same visual contract, different content shape)**:
  - Reuse / Extend / New: Extend (same selected/unselected visual language as `_MoodCell`, applied to a 2x2 layout instead of 3+2, and to icon+label+subtext content instead of face+label).
  - Key Behavior / State Notes:
    - Layout: `Column` of 2 `Row`s, each `Row` holding 2 `Expanded` cells, `CupidSpacing.sm` gap between columns and between rows (mirrors `_gridGap`-style spacing in `VibeMoodGrid`, using the token scale here since this grid has no off-scale geometry to transcribe).
    - Card content, top to bottom, **left-aligned block layout (not centered)** — corrected in PATCH_REQUIRED F1; the earlier bare-centered-glyph description below was not grounded in the design source and does not match it:
      - Icon container: `38`x`38`px rounded tile, corner radius `13`px (transcribed value, no matching token step), NOT a bare glyph directly on the card. Fill: `colors.gradientHot` (selected) / `colors.colorSurface2`-equivalent muted fill (unselected) — matches the design source's `--grad-hot` selected / `--surf2` unselected tile treatment. Icon glyph (see §6.7 for glyph choices) centered inside the tile at `21`px, `#fff`/on-gradient color (selected) or `colors.colorTextMuted` (unselected).
      - `CupidSpacing.xs` gap → label (`context.cupidType.caption`, `fontWeight w700` selected / `w600` unselected, `colors.colorText` selected / `colors.colorTextMuted` unselected), left-aligned under the icon tile, not centered.
      - `2`px gap → subtext (`context.cupidType.caption` at a visually smaller weight, `fontWeight w400`, always `colors.colorTextMuted` regardless of selection — the subtext is descriptive, not a selection signal), left-aligned, same column as label.
    - Selected state: `colors.colorAccentPink`@0.3 → `colors.colorAccentPurple`@0.26 gradient fill at 140deg (verbatim reuse of `_MoodCell`'s `_gradient140Begin`/`_gradient140End` constants), `colors.colorAccentPink` border at `1.5`px, `colors.glowShadow`.
    - Unselected state: `colors.colorSurface` fill, `colors.colorSurface`-colored `1.5`px border (so the border never changes cell size on selection — same rationale as `_MoodCell`), `context.cupidPlatform.elevationShadow`.
    - Corner radius: `context.cupidPlatform.radiusCard` (matches `_MoodCell`, and matches the code card above it — consistent card language on one screen).
    - Tap target: `ConstrainedBox` with `minWidth`/`minHeight` = `context.cupidPlatform.tapTarget`, same as `_MoodCell`.
  - Accessibility Notes: each cell is `Semantics(button: true, selected: isSelected, label: '<vi/en label>, <vi/en subtext>')` wrapping an `ExcludeSemantics` `GestureDetector`, matching `_MoodCell`'s pattern exactly (subtext folded into the semantic label since it is not independently interactive). Do not use `SpeciesPicker`'s `inMutuallyExclusiveGroup: true` — `_MoodCell`'s plain `selected: isSelected` is the established pattern for this exact "always exactly one selected" grid shape on this screen family, and is what most recently shipped.

- **`CupidPrimaryButton` (Continue CTA)**:
  - Reuse / Extend / New: Reuse, unmodified.
  - Key Behavior / State Notes: `enabled: selectedCoupleType != null`; `label: context.viEn('Tiếp tục', 'Continue')`; `onPressed` wired to the screen's existing continue action once STORY-002 defines it — this story only needs the button to exist, be gated correctly, and be visually present in both disabled and enabled states.
  - Accessibility Notes: none beyond `CupidPrimaryButton`'s existing built-in disabled-state semantics (already used elsewhere, e.g. `_InviteError`'s Retry usage of the same component).

### 6.6 Responsive And Accessibility Notes

- Responsive behavior for affected screens: the grid is 2x2 at the story's only in-scope breakpoint (mobile, dark theme, `vi` — OQ5 non-blocking). No tablet/desktop breakpoint exists for this mobile-native screen; the existing `SingleChildScrollView` already handles content taller than the viewport (e.g. a smaller device or larger text scale pushing Continue below the fold).
- Content or action reprioritization on smaller surfaces: none needed — 4 fixed cards in a fixed 2x2 grid, no responsive reflow required at this single supported breakpoint.
- Keyboard and focus expectations: N/A — mobile touch-only screen family (matches the rest of `invite_screen.dart`, no keyboard-navigable controls present).
- Screen reader / semantics notes: each card announces as a button with its selected state and combined label+subtext (see §6.5); Continue announces its existing enabled/disabled semantics; no new live-region announcement is needed — selection change is a direct result of a direct tap, already perceivable via the visual state change and, for screen-reader users, via the updated `selected:` semantics on the tapped and previously-selected cells.
- Error / status communication expectations: none — there is no error state introduced by this story (selection cannot fail; persistence failure handling, if any, is Tech Lead/mobile-dev's implementation concern for the Continue action itself, outside this spec's UI-state scope per the story's persistence-semantics split).

### 6.7 Visual Direction Notes

- Typography, density, or spacing posture: matches the existing code card's density — `CupidSpacing` scale throughout, no off-scale custom values needed for this section (unlike the code card, which has documented off-scale transcriptions from a design source that no longer covers this new content).
- Surface and container treatment: cards use the same `radiusCard`/`elevationShadow`/`colorSurface` language as the code card above them, so the whole screen reads as one visual system despite the couple-type section not being a single bounded container.
- Color or status-semantics treatment: selection uses the repo's existing "hot" gradient + glow language (`colorAccentPink`/`colorAccentPurple`, `glowShadow`) already reserved for primary/chosen/active states elsewhere (Share invite button, `VibeMoodGrid` selected cell) — no new color role introduced.
- Anti-patterns explicitly avoided: no checkbox/radio-button iconography layered onto the cards (the whole card is the toggle, matching `VibeMoodGrid`/`SpeciesPicker` precedent); no hidden/absent Continue button while unselected (disabled-but-visible only); no wrapping the 4-card section in its own `colorSurface` card-within-card, which would visually compete with the code card above it.

Couple-type icon glyphs (Material Symbols Rounded, per `CupidIcons`' single-icon-family rule; the content catalog's icon hints are refined here to concrete, available glyph names per SKILL.md "UI/UX Designer may refine exact icon glyphs"):

| # | Category | Catalog hint | Chosen glyph | Source |
|---|----------|--------------|---------------|--------|
| 1 | Yêu xa / Long-distance | map-pin/flight | `flight_takeoff` | **Reuse** `CupidIcons.flightTakeoff` (0xe905, already confirmed in the bundled font's cmap) — no new glyph needed. |
| 2 | Cùng thành phố / Same city | location-city | `location_city` | New — not yet in `CupidIcons`. Implementer adds a `locationCity` constant following the file's existing pattern (confirm codepoint via `fontTools` against the bundled `MaterialSymbolsRounded-Variable.ttf` cmap; do not invent a codepoint from memory, per that file's own stated convention). |
| 3 | Mới hẹn hò / Just started dating | sparkle-heart | `auto_awesome` | New — substituted for the catalog's literal "sparkle-heart" because Material Symbols Rounded has no combined sparkle+heart glyph and this is a single-glyph icon font; `auto_awesome` (a sparkle) reads as "something new/fresh beginning" without colliding visually with card 4's heart-family glyph. Implementer adds an `autoAwesome` constant, codepoint confirmed the same way. |
| 4 | Gắn bó lâu dài / Long-term | infinity-heart | `all_inclusive` | New — substituted for "infinity-heart" for the same single-glyph reason; `all_inclusive` (the infinity symbol) is Material Symbols Rounded's actual glyph for this concept and keeps this card visually distinct from card 3. Implementer adds an `allInclusive` constant, codepoint confirmed the same way. |

Content catalog (authored by Product Owner in `requirements/requirements.md`, reused verbatim — not re-authored here):

| # | Category (vi / en) | Label copy | Subtext copy |
|---|---|---|---|
| 1 | Yêu xa / Long-distance | vi: "Yêu xa" — en: "Long-distance" | vi: "Tụi mình đang ở hai nơi khác nhau" — en: "We're in different places" |
| 2 | Cùng thành phố / Same city | vi: "Cùng thành phố" — en: "Same city" | vi: "Tụi mình ở cùng một thành phố" — en: "We live in the same city" |
| 3 | Mới hẹn hò / Just started dating | vi: "Mới hẹn hò" — en: "Just started dating" | vi: "Tụi mình mới bắt đầu tìm hiểu nhau" — en: "We just started getting to know each other" |
| 4 | Gắn bó lâu dài / Long-term | vi: "Gắn bó lâu dài" — en: "Long-term" | vi: "Tụi mình đã gắn bó với nhau lâu rồi" — en: "We've been together for a while" |

Grid order matches the catalog's numbering above (reading order: 1,2 top row; 3,4 bottom row) — no reordering.

### 6.8 Visual Acceptance Criteria / Design Anchor

> **Revised in PATCH_REQUIRED F1 (REQ-009/STORY-001_invite_couple_type_picker
> review).** The earlier version of this section claimed no rendered
> design-source reference exists for this node and exempted it from the
> rendered visual-fidelity gate. That premise was wrong: it was true only of
> the sibling canvas `Cupid App.dc.html` (which never had this screen), not of
> the design bundle as a whole. A live, rendered design node for this exact
> screen — including the couple-type section — exists in the same
> `cupid-app-design-system` bundle, in `Cupid Screens.dc.html`'s `isInvite`
> screen state (`sc === 'invite'`, source lines ~168-203). This is the same
> canvas REQ-001/STORY-018_design_fidelity_capture's
> `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/design-reference-invite-android.png`
> was captured from, and that PNG already shows this exact node (heading
> "Tụi mình thuộc kiểu nào?", 2x2 card grid, a selected-state card).
>
> This source has been registered as an additional entry in
> `design-fidelity-config.json`'s `design_sources[]` (`id: "cupid-screens"`)
> — **note:** at the time of this revision, an existing `guard-design-source-lock.sh`
> PreToolUse hook rejected that JSON edit even after including the
> `Design-Source: UPDATE — <reason>` trigger phrase this repo's own prior
> entries document as the unlock mechanism (3 identical rejections; the guard's
> own error text truncated before reaching a `fix:`/`cmd:` section this role has
> no visibility into and no Bash tool to run). **Scrum Master/DevOps must land
> the `design_sources[]` registration for `Cupid Screens.dc.html` (`id:
> "cupid-screens"`, `screens_from: "dom"`, screen state `invite`) before the
> rendered-fidelity gate below can run automated capture** — this spec update
> proceeds without it because the decision itself (which source is
> authoritative, and what it shows) does not depend on the config file being
> writable.
>
> AC6's "matches the design source" is satisfied by a real rendered
> comparison/capture against this node (via `render-design-canvas.js
> --screen=invite` once the source is registered, or directly against the
> already-existing `design-reference-invite-android.png`), not by the
> finder-assertion substitution the prior version of this section allowed.
>
> **Real deltas identified against the current build** (confirmed against the
> design source's markup, not stale — mobile-dev must patch layout, not just
> re-capture a screenshot):
> 1. A supporting subtext line ("Cupid sẽ bật/tắt tính năng phù hợp cho kiểu
>    của bạn." / "Cupid tunes default features to your type.") sits directly
>    below the section heading, above the grid. This line is present in the
>    design source and was missing from both this spec and the build. Added to
>    §6.3/§6.5 above.
> 2. Each card's icon renders inside a `38`x`38`px rounded tile (radius `13`px,
>    `gradientHot` fill selected / muted-surface fill unselected), not as a
>    bare centered glyph. Corrected in §6.5 above (was: bare `28`px glyph with
>    no container).
> 3. Card content (icon tile, label, subtext) is left-aligned in a top-to-bottom
>    block, not centered. Corrected in §6.5 above (the prior spec did not
>    specify alignment, and the build rendered a centered glyph with no
>    supporting line).
> 4. Cell internal padding is `16`px vertical / `14`px horizontal per the design
>    source, not the `8`px horizontal / `16`px vertical this section previously
>    stated (see corrected value below) — the two were transposed.

- Visual reference(s): `cupid-app-design-system/Cupid Screens.dc.html`
  (`isInvite` state) — authoritative; render via
  `render-design-canvas.js --screen=invite` once the `design_sources[]` entry
  lands. Interim/complementary reference:
  `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-018_design_fidelity_capture/visual-fidelity/design-reference-invite-android.png`
  (same canvas, already captured, shows this exact node).
- Layout & spacing (key paddings, gaps, sizes in px/rem):
  - Section sits below `_InviteCodeCard` with `CupidSpacing.lg` (24px) gap; heading to grid gap `CupidSpacing.md` (16px); grid row/column gap `CupidSpacing.sm` (8px); grid to Continue gap `CupidSpacing.lg` (24px).
  - 2x2 grid, each cell `Expanded` within its row (equal width, screen-width minus `_screenPadding` minus one `CupidSpacing.sm` gutter, split 2 ways).
  - Cell internal padding (**corrected in PATCH_REQUIRED F1** — previously transposed): `14`px horizontal, `16`px vertical (transcribed values from the design source; denser horizontally than `VibeMoodGrid`'s `17px`, since this content is 3 text/icon lines vs 2 — vertical stays generous for the icon tile).
  - Icon tile 38x38px, corner radius 13px (transcribed), icon glyph 21px centered inside the tile (**corrected in PATCH_REQUIRED F1** — was a bare 28px glyph with no tile); icon-tile-to-label gap `CupidSpacing.xs` (4px); label-to-subtext gap 2px (below the token scale's smallest step, matching the code card's own precedent of transcribing sub-token gaps when the scale has no matching step, e.g. its documented `9px` action-row gap).
  - Corner radius: `context.cupidPlatform.radiusCard` (26px iOS / 24px Material — theme-token driven, not a literal).
  - Border width 1.5px both states (selected and unselected), matching `_MoodCell`.
  - Tap target minimum: `context.cupidPlatform.tapTarget` (44px iOS / 48px Material).
- Color & status semantics (token names, not hex — theme-token driven per this codebase's convention):
  - Unselected cell: fill `colors.colorSurface`; border `colors.colorSurface` (invisible border, sizing-only); shadow `context.cupidPlatform.elevationShadow`.
  - Selected cell: fill 140deg linear gradient `colors.colorAccentPink@0.3` → `colors.colorAccentPurple@0.26`; border `colors.colorAccentPink` @ 1.5px; shadow `colors.glowShadow`.
  - Label text: `colors.colorTextMuted` unselected → `colors.colorText` selected.
  - Subtext text: `colors.colorTextMuted` in both states.
  - Icon tile fill (**corrected in PATCH_REQUIRED F1** — was: no tile, bare glyph): `colors.gradientHot` selected / muted-surface fill unselected. Icon glyph color: on-gradient `#fff`-equivalent selected / `colors.colorTextMuted` unselected — the tile's own fill now carries the selection signal, so the glyph itself follows the tile's contrast pair rather than staying fixed (supersedes the prior "icon does not dim" rule, which assumed a bare glyph with no tile background).
  - Section heading: `colors.colorText`.
- Typography (sizes, weights, line-height for key text):
  - Heading: `context.cupidType.body`, `fontWeight w700`.
  - Card label: `context.cupidType.caption`, `fontWeight w700` selected / `w600` unselected.
  - Card subtext: `context.cupidType.caption`, `fontWeight w400`, both states — visually the smallest-weight text in the cell so label stays the dominant read.
  - Continue label: `CupidPrimaryButton`'s existing built-in typography (unmodified).
- Component states to verify: default/unselected (all 4 cards) / one selected (each of the 4, individually) / pre-filled-on-return (any card pre-selected on first paint) / Continue disabled (0 selected) / Continue enabled (1 selected). No hover state (touch-only); no loading/error/empty state introduced by this story.
- Responsive checkpoints to verify: N/A — single supported breakpoint (mobile, dark, `vi`, OQ5 non-blocking); verify the section does not clip or overlap `_InviteCodeCard` or Continue at minimum supported device height when the on-screen keyboard is not a factor (no text input on this screen).

### 6.9 Usability Readiness Gate

- Can the target user complete the critical task without outside explanation? Yes — 4 clearly labeled cards with icon + label + one-line subtext, single tap to select, is self-explanatory with no instructional copy needed.
- Is the first action clear for the expected user mode? Yes — the heading directly asks the question ("Tụi mình thuộc kiểu nào?") immediately above 4 visibly tappable cards.
- Is success, failure, and partial progress visible in user language? Yes — selected state is visually unambiguous (gradient fill + glow + border), and Continue's enabled/disabled state directly communicates whether the required input is satisfied; there is no failure state in this story's scope (selection cannot fail).
- Are recovery, retry, edit, undo, or next-action paths explicit where needed? Yes for the only recovery need in scope — re-selecting a different card at any time before Continue is pressed (AC3); editing after Continue/pairing completion is explicitly out of scope per story_master.md, so no UI is designed for it.
- Remaining usability risks: none material — the one open item (final icon codepoints for 2 of 4 glyphs) is a build-time verification step, not a UX ambiguity; the chosen glyph names are unambiguous design decisions.

## 7. Handoff Notes

- Important implementation constraints:
  - New screen-local widgets (`_CoupleTypeSection`, `_CoupleTypeGrid`, per-cell widget) belong in `invite_screen.dart` or a co-located file in `mobile/lib/features/pairing/presentation/screens/`, following the existing file's pattern of screen-local private widgets rather than promoting to `design_system/` (out of this story's write scope, same rationale as the existing `_iosShareIcon`/`_contentCopyIcon` local constants).
  - `InviteReady`'s state shape needs a `coupleType`/`selectedCoupleType` field (Tech Lead to confirm exact cubit/state wiring) so the grid can render pre-filled-on-return (AC5) without a separate fetch.
  - Two of the four icon glyphs (`location_city`, `auto_awesome`, `all_inclusive` — three, not two; `flight_takeoff` is the only reused one) need codepoints confirmed against the bundled `MaterialSymbolsRounded-Variable.ttf` cmap before implementation, per this file's own established practice — do not guess codepoints.
- OQ-driven blocked UX sections, if any: none — OQ5 is non-blocking for all scope in this story (§3).
- Shared pattern changes requiring System UX Memory update: none — this story reuses `VibeMoodGrid`'s existing selectable-card grammar without changing it; no System UX Memory update performed (Action: Read Only, §1).
- Design-coherence checks downstream should preserve: selected-card treatment must match `_MoodCell`'s established gradient/glow/border language exactly (not a new selection treatment); card corner radius and shadow must match the code card above it (`radiusCard`/`elevationShadow`) so the screen reads as one system.
- Usability checks downstream should preserve: Continue must remain visible-but-disabled at 0 selections (never hidden); selection must always be single-value (never allow 2 cards selected simultaneously, even transiently during a rebuild).
- Questions or blockers: none — story is unblocked and ready for Tech Lead architecture.

## Optional Expansion

Not needed — this is a single-screen, single-new-component addition with no multi-step navigation, no new reusable design-system component (both card grids reuse an existing pattern), and no complex state matrix beyond the 5 states already enumerated in §6.4/§6.8.
