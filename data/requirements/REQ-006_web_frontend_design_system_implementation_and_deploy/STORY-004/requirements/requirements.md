# Story Requirements: STORY-004 Pairing Invite Landing Page

Parent requirement: REQ-006 Web frontend implementation from design system &
production deploy (`req_master.md`).

## Context Summary

- Actor: a person who received a pairing/invite code from their partner and
  lands on this page from a shared link, before opening the app. This page
  is also the most likely direct-URL entry point of any REQ-006 page (shared
  invite links point straight here); both nav discovery and direct URL are
  acceptable entry paths.
- Capability: an "Invite" page reachable from the shared header nav
  (`share`/"Invite" nav item established by STORY-001), explaining the
  pairing-code flow: a code-cell display, an "Open Cupid" CTA, a
  before/after phone-mockup pairing illustration, a three-step explainer
  (get a code / both confirm / pick a pet), and a keepsake-card concept
  section with sample card previews.
- Business outcome: converts an invite recipient into an app download and
  explains the dual-confirmation pairing model that differentiates the
  product.
- Source of truth: `cupid-app-design-system/Cupid Web.dc.html`, `isShare`
  page-state section (approx. lines 387-451): eyebrow "Invite"/"Lời mời",
  headline "Someone just called you home", subcopy, 6-cell code display,
  "Open Cupid" CTA, dual phone-mockup ("Enter code" state and "Paired" state
  showing pet "Mochi"), three explainer cards, and a keepsake-cards section
  with 3 sample card previews.
- Depends on STORY-001 (shared-foundation, DONE/MERGE_COMPLETE) for the app
  shell, shared header/nav/footer chrome, framework scaffold, and
  theme/language toggle infrastructure. This story reuses that foundation
  unmodified and does not re-litigate the framework choice.
- Confirmed by direct inspection of the design source (requirement-level
  `OQ-REQ006-2`, RESOLVED): zero `fetch`/API/backend calls anywhere in
  `Cupid Web.dc.html` — the pairing-code cells and "Open Cupid" CTA are
  static, presentational-only elements with no functional redemption logic.
- Carried-forward finding: STORY-001 review recorded deferred finding DEF-2
  — each new page needs a proper per-page `<title>` tag. This story must
  address DEF-2 for the Invite page (see AC-8).

## Scope Decision

### In Scope

- A new page/route reachable via the existing "Invite" nav item (STORY-001
  shared header nav) and via direct URL, rendering the `isShare` page-state
  content of `Cupid Web.dc.html`.
- Eyebrow label + headline + subcopy matching the design source's literal VI
  and EN strings.
- Pairing-code cell display: 6 illustrative code cells, non-functional (no
  input capture, no validation, no redemption).
- "Open Cupid" CTA: a presentational link/button styled per the design
  source; it is not wired to any real deep-link redemption or backend call.
- Before/after phone-mockup pairing sequence: left mockup shows the "Enter
  code" / code-entry state; right mockup shows the "Paired" state with pet
  name "Mochi", "your day one" caption, and member/pet stat chips.
- Three-step explainer section: "Get a code", "Both confirm", "Pick a pet"
  cards with icon, heading, and body copy per the design source.
- Keepsake-card concept section: heading, description copy, and 3 sample
  card previews (tag, big value, sub-copy, "Cupid" heart mark) matching the
  design source's card layout.
- Proper per-page `<title>` tag for this page (addresses carried-forward
  DEF-2 from STORY-001 review).
- Copy must match the design source's literal VI and EN strings; no
  paraphrasing.

### Out of Scope

- Real pairing-code input, validation, or redemption against any backend —
  not present in the design source (`OQ-REQ006-2`, RESOLVED at requirement
  level).
- Any backend/API integration for this page.
- Functional deep-linking to the native app from the "Open Cupid" CTA
  beyond a presentational link, since no such wiring exists in the design
  source.
- Shared header/nav/footer chrome, theme/language toggle behavior, and
  framework scaffold — already built by STORY-001; reused unmodified.
- Any new design screens not present in `Cupid Web.dc.html`'s `isShare`
  state.

## Acceptance Criteria

- **AC-1 (Discoverability)**: the Invite page is reachable both via the
  "Invite" item in the shared header nav (STORY-001) and via a direct URL,
  without requiring prior navigation.
- **AC-2 (Hero content)**: the page renders the eyebrow label, headline
  ("Someone just called you home" / "Có người vừa gọi bạn về nhà"), and
  subcopy exactly matching the design source's literal VI and EN strings.
- **AC-3 (Code-cell display, non-functional)**: the page renders a 6-cell
  pairing-code display that is illustrative only — no input capture,
  client-side validation, or backend call is attached to it.
- **AC-4 (Open Cupid CTA, presentational only)**: the page renders an "Open
  Cupid" CTA styled per the design source; it must not perform or simulate
  real pairing-code redemption or a functional deep link, since none exists
  in the design source.
- **AC-5 (Phone-mockup pairing sequence)**: the page renders both
  phone-mockup states side by side — the "Enter code" state and the
  "Paired" state (pet name "Mochi", "your day one" caption, member/pet stat
  chips) — matching the design source's layout and copy.
- **AC-6 (Three-step explainer)**: the page renders the "Get a code" / "Both
  confirm" / "Pick a pet" explainer cards with their icons, headings, and
  body copy matching the design source's literal VI and EN strings.
- **AC-7 (Keepsake-card section)**: the page renders the keepsake-card
  heading, description copy, and 3 sample card previews matching the design
  source's card layout and content.
- **AC-8 (Per-page title tag)**: the page sets a distinct, descriptive
  per-page `<title>` tag (addresses carried-forward deferred finding DEF-2
  from the STORY-001 review).
- **UI-Fidelity-AC-9 (Visual fidelity)**: the deployed Invite page is
  visually identical ("giống 100%") to the `isShare` page state of
  `cupid-app-design-system/Cupid Web.dc.html`, per the requirement's hard
  pixel/visual-fidelity acceptance requirement. This story requires the full
  UI-lane review gate with `design_source` and `ui_surface` configured (not
  the Tier 0 lightweight gate), per `req_master.md` Technical Constraints.
- **AC-10 (Copy fidelity)**: all page copy matches the design source's
  literal VI and EN strings for both locales; no paraphrasing.

## Open Question Impact

### Scope Items BLOCKED in this story

- None. Both requirement-level open questions are resolved before this
  story starts: `OQ-REQ006-1` (framework/stack) was resolved by the
  STORY-001 Tech Lead pass (Astro static site), and this story reuses that
  foundation without re-litigating it; `OQ-REQ006-2` (backend API
  dependency) was resolved at requirement level as no live API dependency.

### Scope Items NOT BLOCKED in this story

- All scope items above: the page content, code-cell/CTA presentational
  treatment, phone-mockup sequence, explainer cards, and keepsake-card
  section are all static content decisions with no dependency on unresolved
  open questions.
- `OQ-REQ006-1` (framework/stack) — RESOLVED at STORY-001 (Astro static
  site); this story builds a page inside that established foundation.
- `OQ-REQ006-2` (backend API dependency) — RESOLVED at requirement level:
  no live `api.cupidus.app` dependency; the code cells and CTA are
  presentational-only per AC-3/AC-4, consistent with this resolution.

## Direct Anchors

- Requirement-level: `req_master.md` Business Scope, Technical Constraints
  (visual-fidelity requirement), Open Questions (`OQ-REQ006-1` RESOLVED via
  STORY-001, `OQ-REQ006-2` RESOLVED).
- Requirement-level `requirements/requirements.md`: Coverage Map row
  "Invite / pairing landing page" (STORY-004), Story Index row STORY-004.
- Story brief: `story_brief.md` Scope Seed (In Scope / Out of Scope).
- Design source: `cupid-app-design-system/Cupid Web.dc.html`, `isShare`
  page-state section (approx. lines 387-451).
- Carried-forward finding: STORY-001 review DEF-2 (per-page `<title>` tag),
  addressed by AC-8.
