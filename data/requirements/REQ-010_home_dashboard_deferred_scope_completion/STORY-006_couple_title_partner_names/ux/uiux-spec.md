# UI/UX Specification - Couple Title Shows Both Partner Names

## 1. Metadata

- Related Story: `STORY-006_couple_title_partner_names` (REQ-010)
- Source Requirement Paths:
  `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/req_master.md`,
  `data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-006_couple_title_partner_names/story_master.md`
- Target Directory: `mobile/lib/features/home/presentation/home_screen.dart`
  (`_CoupleHero`, `_PresenceRow`, `_Avatar`)
- Mode: Brownfield
- Status: Final
- System UX Memory Path: N/A — this story extends an already-specified,
  already-shipped component (`STORY-017`) with new data, it does not
  introduce or change a shared cross-screen pattern.
- System UX Memory Action: None

## 2. Context Summary

- User goal: a paired user sees the couple title correctly show both
  partners' names on the Home dashboard, matching the pairing they set up.
- Primary user mode: Recurring — every paired user sees this on every Home
  visit.
- Business outcome: the couple-presence header reads "Minh & Linh" instead
  of just "Minh", closing `STORY-017` deferral finding F4.
- Existing specs reviewed: `STORY-017_home_dashboard_design_fidelity`
  visual-fidelity report (finding Δ2/F4) and its `_CoupleHero`/`_PresenceRow`
  implementation in `home_screen.dart`.
- Existing UI patterns found: `_PresenceRow` already renders two overlapping
  42px avatar discs (self left, partner right, `-13px` overlap) and a
  name/couple-type label column, in the exact spacing/typography the design
  source specifies. Only the partner's *data* is missing today — the layout
  primitive is already correct and design-matched.
- Existing components reused or extended: `_Avatar` (extended — partner
  instance currently hard-codes `initial: null`), `_PresenceRow` (extended —
  currently takes only the self `displayName`).
- Current UX debt or consistency risks: none introduced; this closes an
  existing, already-documented debt item (F4) rather than adding a new one.
- Current organization or hierarchy issues in the affected area: none — the
  presence row's visual hierarchy (avatars → name → couple-type label) is
  unchanged.
- Stable shared patterns vs local debt: the "degrade honestly, never
  fabricate data" pattern is a stable rule already used by this same
  component for the couple-type label (F5) and by `STORY-017`'s partner
  avatar; this story continues that pattern for the partner name rather than
  introducing a new one.
- Open Question Impact source: story's own `## Open Question Impact` = NONE.
- Open assumptions: none — AC1-AC3 fully determine the design.

## 3. Open Question Impact

N/A — story's `## Open Question Impact` is NONE.

## 4. Requirement-To-Design Traceability

- **AC1 (couple title shows both names in "A & B" format)**:
  - UX Response: `_PresenceRow`'s name `Text` renders `"$selfName & $partnerName"`
    (see §6.4) once both names are known, reusing the existing Nunito
    800/15px style unchanged.
  - Affected Screen / Component / Flow: Home dashboard → couple-presence
    header → `_PresenceRow` name label.
- **AC2 (partner avatar disc shows partner's initial)**:
  - UX Response: the second `_Avatar` (currently `initial: null`) receives
    the partner name's first character, uppercased, styled identically to
    the self avatar's initial (14px/800/white, per the already-shipped
    `_Avatar` widget).
  - Affected Screen / Component / Flow: Home dashboard → couple-presence
    header → partner `_Avatar`.
- **AC3 (honest degradation when partner data is unavailable)**:
  - UX Response: when partner name data is null/empty, the title shows the
    self name alone (no `"& "` suffix, no placeholder text), and the partner
    avatar keeps rendering its gradient disc with no initial — i.e. exactly
    today's shipped fallback stays the fallback, it is not replaced by an
    error or empty state.
  - Affected Screen / Component / Flow: Home dashboard → couple-presence
    header, degraded/loading-failure case.

## 5. Critical User Tasks And Success Criteria

- **Task: glance at the Home dashboard and confirm both partners are
  correctly paired**:
  - User Mode: Recurring.
  - Entry Point: Home dashboard, already-mounted couple-presence header (no
    new entry point — matches `req_master.md`'s "existing reachable
    surface").
  - Success Signal: title text reads "<self name> & <partner name>"; partner
    avatar shows the partner's initial letter.
  - Primary Risk: showing a wrong or fabricated partner name (for example,
    an empty-string placeholder like "&" with nothing after it, or literal
    text such as "Partner") would misrepresent the pairing and erode trust —
    explicitly forbidden, see §6.6.

- First-use guidance or discoverability needs: none — passive display, no
  interaction added.
- Completion or post-completion state: N/A — always-on display element, not
  a task with a completion state.
- Retry, edit, undo, or next-action behavior: none in this story's scope;
  partner data is read-only display, same as the self name today.
- What would make the task feel unfinished or unsafe to the user: a stray
  " & " with no partner name after it, or a partner initial that renders
  before the partner name is confirmed loaded (a flash of wrong data) — both
  addressed in §6.4/§6.6.

### 5.1 System Entry And Discoverability

- Existing surface, workflow, or state where the actor starts: Home
  dashboard, on load — the couple-presence header is always the first thing
  painted once the profile future resolves.
- Required entry point, navigation item, CTA, or in-flow discovery path:
  none — no new entry point, per this story's Out of Scope.
- Direct URL only acceptable per PO scope: N/A — existing reachable surface.
- Entry point states: default (both names known) / degraded (partner name
  unavailable) — see §6.4. No separate loading state for this data: the
  whole `_CoupleHeroHeader` already returns `SizedBox.shrink()` until the
  combined profile future resolves (existing behavior, unchanged), so
  partner-name loading is covered by that same single gate, not a second
  spinner.
- Surfaces intentionally not updated: avatar disc layout/overlap, couple-type
  label, days counter, milestone pill, hero caption, card rhythm, tab-bar —
  all out of scope per `story_master.md`.

## 6. UX Design

### 6.1 Affected Screens / Areas

- **Home dashboard — couple-presence header (`_CoupleHero` /
  `_PresenceRow`)**:
  - Purpose: identify the signed-in user's pairing at a glance.
  - Change Type: Extend.
  - Notes: only the name-text content and the partner avatar's `initial`
    value change; container sizing, spacing constants, colors, and font
    styles are already correct and untouched.

### 6.2 Design Progression

- Current issue in the affected area: the title shows only the self name
  ("Minh"), and the partner avatar disc is a plain gradient with no letter —
  both because `GET /users/me` today has no partner-profile data to render.
- Why it hurts comprehension, consistency, or trust: a couple app's home
  screen not naming both partners under-delivers the app's core "this is
  our shared space" promise, and looks unfinished next to the design.
- Design progression introduced by this story: once the new partner-profile
  field is available, the title becomes "<self name> & <partner name>" and
  the partner avatar shows the partner's initial — matching
  `Cupid Screens.dc.html` lines 243-246 exactly.
- Shared rule preserved, clarified, or evolved: preserves the existing
  "degrade honestly, never fabricate" rule this same component already
  applies to the couple-type label (F5) and to today's partner avatar (F4).
- Deferred debt not solved in this story: none remaining in this specific
  component after this story — F4 closes.

### 6.3 Page Anatomy And Visual Grouping

- Page or surface anatomy: unchanged. Presence row = [self avatar][partner
  avatar, `-13px` overlap] + 11px gap + [name text / couple-type label
  column], inside a `justify-content:space-between` header row that also
  hosts the share/notifications icons (`STORY-004`/`STORY-005`, separate
  stories, out of this story's scope).
- Primary visual groupings: unchanged — avatar pair as one visual unit, text
  column as a second unit.
- Primary action and supporting actions: N/A — no interactive elements in
  this story's scope.
- Visual emphasis strategy: unchanged — name text stays the dominant
  typographic element in the row (Nunito 800/15px vs. couple-type label's
  11.5px muted caption).
- What should be easier to scan than before: the pairing itself — a user can
  now confirm both partner names at a glance instead of just their own.

### 6.4 Primary Flow, Hierarchy, And Key States

- Entry point: Home dashboard load (existing, no change).
- Primary action and why it is primary: N/A — passive display.
- Supporting actions and how they stay subordinate: N/A.
- Happy path: partner-profile data resolves alongside the self profile →
  title renders `"<selfName> & <partnerName>"` → partner avatar renders the
  partner's first-letter initial, uppercased, in the same style as the self
  avatar's initial.
- Important alternative / error / loading / empty / completion states:
  - **Degraded (AC3)** — partner name is null or empty (partner-profile
    fetch failed, timed out, or the partner has no display name set): title
    renders `<selfName>` alone, with no `"& "` separator trailing it and no
    placeholder text in its place. Partner avatar keeps its existing
    gradient-only rendering (no initial) — this is the same fallback the
    component already ships today, not a new state to build.
  - **Self name also unavailable**: out of scope — `_PresenceRow` already
    omits the name `Text` entirely when `displayName` is null/empty; that
    existing guard is untouched by this story.
  - **Not paired (`isPaired == false`)**: out of scope for this story — no
    partner avatar or partner name is expected; the single-avatar,
    single-name layout already shipped stays as-is.
- Recovery path when the user is blocked, unsure, or interrupted: none
  needed — this is a read-only display value with an already-honest
  fallback; no retry affordance is introduced in this story's scope.

### 6.5 Component Changes

- **`_PresenceRow`**:
  - Reuse / Extend: Extend — add a `partnerDisplayName` input (nullable
    `String`) alongside the existing `displayName`. Do not change its
    existing `displayName`, `coupleTypeLabel`, or `isPaired` inputs' meaning.
  - Key Behavior / State Notes: build the title as
    `partnerDisplayName == null || partnerDisplayName.isEmpty ? selfName :
    '$selfName & $partnerDisplayName'`, self name first (matches the avatar
    stack's left-to-right self→partner order). Compute the partner initial
    the same way the self initial is already computed (`substring(0,
    1).toUpperCase()`), and pass it to the partner `_Avatar` only when
    `partnerDisplayName` is non-null/non-empty.
  - Accessibility Notes: the combined title remains one semantic text node
    read by screen readers as "<self name> & <partner name>" (or "<self
    name>" alone when degraded) — no separate accessible label needed for
    the "&" since it reads naturally in both `vi` and `en` (design source
    uses the literal "&" glyph in both locales, not a translated word).
- **`_Avatar` (partner instance)**:
  - Reuse / Extend: Extend usage only — pass the computed partner initial
    instead of the hard-coded `null`; the widget itself needs no code
    change.
  - Key Behavior / State Notes: initial shown only when partner data is
    known; falls back to the existing gradient-only disc otherwise (AC3).
  - Accessibility Notes: the initial letter is decorative relative to the
    adjacent name text — no separate semantic label needed beyond what the
    title text already conveys.

### 6.6 Responsive And Accessibility Notes

- Responsive behavior for affected screens: the presence row sits inside a
  `justify-content:space-between` header alongside the share/notification
  icons (separate stories). A combined "A & B" title is longer than today's
  single name and now shares that row's width budget with those icons —
  the name/couple-type text column must be allowed to shrink (e.g.
  `Flexible`/`Expanded` around the existing `Column`) with the title `Text`
  set to a single line and `TextOverflow.ellipsis`, so a long combined name
  truncates gracefully instead of overflowing into or being clipped behind
  the icon row. The couple-type label keeps its existing behavior.
- Content or action reprioritization on smaller surfaces: none beyond the
  ellipsis truncation above — no element is hidden or reordered.
- Keyboard and focus expectations: N/A — no focusable/interactive element
  added.
- Screen reader / semantics notes: see §6.5 — one combined text node, no new
  semantics widget needed.
- Error / status communication expectations: none — AC3's degraded state is
  silent (self name only), matching the existing shipped precedent for this
  component; no toast, banner, or inline error copy is introduced.

### 6.7 Visual Direction Notes

- Typography, density, or spacing posture: unchanged — reuse
  `type.display` at the existing 15px/800 for the title and the existing
  14px/800 white for avatar initials; no new type role introduced.
- Surface and container treatment: unchanged — avatar gradients
  (`CouplePresencePalette.selfAvatarGradient` /
  `partnerAvatarGradient`), ring, and shadow stay as shipped.
- Color or status-semantics treatment: unchanged — `colors.colorText` for
  the title, `colors.colorTextMuted` for the couple-type label.
- Anti-patterns explicitly avoided: no placeholder/fabricated partner name
  (e.g. "Partner", "...") in the degraded state; no separate error UI for a
  missing partner name; no new typography scale introduced for the longer
  combined string.

### 6.8 Visual Acceptance Criteria / Design Anchor

- Visual reference(s): `cupid-app-design-system/Cupid Screens.dc.html`
  lines 243-246 (`isHome` block, couple-presence header markup — self
  avatar "M", partner avatar "L", title `Minh & Linh`).
- Layout & spacing: unchanged from `STORY-017` — 42px avatar diameter,
  `-13px` overlap, 11px gap between avatar stack and text column. No new
  spacing constants for this story.
- Color & status semantics: title `colors.colorText`; couple-type label
  `colors.colorTextMuted`; avatar initials white (`#fff` per design source)
  on the existing self/partner gradients — all already-shipped tokens.
- Typography: title Nunito 800/15px (`_coupleNameFontSize`); avatar initial
  800/14px (`_avatarInitialFontSize`) — both already-shipped constants, no
  change.
- Component states to verify:
  - Paired, both names known → "<self> & <partner>" title, partner avatar
    shows partner initial.
  - Paired, partner name unavailable (AC3) → self name only, no trailing
    "&", partner avatar shows no initial.
  - Long combined name → single line, ellipsis truncation, no overflow into
    the header icon row.
- Responsive checkpoints to verify: standard mobile widths only (no new
  breakpoint) — confirm the title truncates rather than overflows on the
  narrowest supported device width when both partner names are long.

### 6.9 Usability Readiness Gate

- Can the target user complete the critical task without outside
  explanation? Yes — reading the title requires no instruction.
- Is the first action clear for the expected user mode? N/A — passive
  display, no action.
- Is success, failure, and partial progress visible in user language? Yes —
  success is both names shown; the AC3 fallback (self name only) is itself
  the honest "partial" state, requiring no additional messaging.
- Are recovery, retry, edit, undo, or next-action paths explicit where
  needed? N/A — no user-initiated action exists to recover; the next
  successful Home load simply re-attempts the fetch.
- Remaining usability risks: none identified within this story's scope.

## 7. Handoff Notes

- Important implementation constraints: do not touch avatar diameter/overlap,
  couple-type label, days counter, milestone pill, hero caption, card
  rhythm, or tab-bar styling — all out of scope per `story_master.md`. Keep
  the existing `_CoupleHeroHeader` combined-profile-future gate as the sole
  loading gate; do not add a second, partner-specific loading spinner.
- OQ-driven blocked UX sections, if any: none — story has no Open Question
  Impact.
- Shared pattern changes requiring System UX Memory update: none — this
  extends an existing, already-documented component pattern rather than
  introducing a new shared one.
- Design-coherence checks downstream should preserve: title stays one
  semantic text node; "&" stays untranslated/literal in both `vi` and `en`
  (matches design source); avatar initial styling stays identical between
  self and partner instances.
- Usability checks downstream should preserve: AC3's silent, no-fabrication
  degraded state — never render a placeholder partner name or a trailing
  "&" with nothing after it.
- Questions or blockers: none.
