# Story Requirements: STORY-007 Support FAQ Page

Parent requirement: REQ-006 Web frontend implementation from design system &
production deploy
Depends on: STORY-001 (Frontend App Foundation — shared chrome, nav route,
framework; DONE / MERGE_COMPLETE)

## User Story

As a visitor or existing user with a question or problem, I want a Support
page with an expandable FAQ list and a clear human-contact fallback, so I can
self-serve an answer or know how to reach a real person.

## Scope

### In Scope

- A "Support" page reachable via the existing "Support" nav item in the
  shared header nav (established in STORY-001).
- An expandable FAQ list rendered from the design source's `faq` data (6
  question/answer pairs), using native `<details>`/`<summary>` disclosure
  behavior so each entry expands/collapses independently.
- A "Still need a human?" contact block with a `mailto:hi@cupid.app` link.
- Both VI and EN content variants, consistent with the site-wide language
  toggle established in STORY-001.
- A page-specific `<title>` tag (carried-forward deferred finding DEF-2 from
  STORY-001 review — see AC-7).

### Out of Scope

- Live chat, ticketing system, or any support backend/API.
- FAQ search/filter, categorization, or CMS-driven content — content is
  static seed data from the design source.
- Any new nav/routing mechanism — this story reuses the nav route STORY-001
  already wires up.

## Acceptance Criteria

- AC-1: Given a visitor on any page, when they select "Support" (or
  "Hỗ trợ" in VI) in the header nav, then the app navigates to the Support
  page.
- AC-2: Given the Support page is loaded, then it renders a page heading
  ("Frequently asked" / "Câu hỏi thường gặp") and exactly 6 FAQ entries,
  matching the question/answer content in `Cupid Web.dc.html`'s `faq` array.
- AC-3: Given the Support page is loaded, when a visitor selects one FAQ
  entry's question, then only that entry's answer expands/collapses; other
  entries' expand/collapse state is unaffected.
- AC-4: Given the Support page is loaded, then a "Still need a human?" /
  "Vẫn cần người thật?" contact block is visible below the FAQ list, with a
  visible `hi@cupid.app` link using `mailto:hi@cupid.app` as its `href`.
- AC-5: Given the site-wide language toggle is set to VI or EN, then the
  Support page heading, all FAQ question/answer text, and the contact block
  copy render in the selected language, matching the `data-vi`/`data-en`
  pairs in the design source.
- AC-6 (UI-Fidelity-AC): Given the Support page rendered in the deployed app,
  when compared against the `isSupport` section of `Cupid Web.dc.html`, then
  layout, spacing, typography, color tokens, and the FAQ disclosure/contact
  block visuals are pixel/visually identical, per `req_master.md`'s strict
  100% visual-fidelity acceptance requirement — this story requires the full
  UI-lane review gate (`design_source` + `ui_surface` configured), not the
  Tier 0 lightweight gate.
- AC-7 (carried-forward DEF-2 from STORY-001 review): Given the Support page
  is loaded, then the document has a distinct, descriptive `<title>` tag for
  this page (not a generic/shared title reused unchanged from another page).

## Business Rules

- BR-1: FAQ entries are static seed content sourced from the design comp
  (`Cupid Web.dc.html`'s `faq` array); no dynamic content source, CMS, or API
  is introduced in v1.
- BR-2: The support contact control is a static `mailto:hi@cupid.app` link
  only — no live form, ticketing, or chat backend, consistent with
  OQ-REQ006-2's resolution that this is a static/marketing site with no API
  dependency.
- BR-3: FAQ disclosure behavior must be native (e.g. HTML `<details>`/
  `<summary>` or equivalent independent per-item expand/collapse state) —
  no accordion library that forces single-open-at-a-time unless the design
  source itself constrains it (it does not; each `<details>` is independent).

## Open Question Impact

Requirement-level OQ triage: OQ-REQ006-1 RESOLVED (STORY-001 Tech Lead chose
the frontend framework/stack; this story reuses that foundation without
re-litigating it). OQ-REQ006-2 RESOLVED (Product Owner, 2026-08-21): this is
a static/marketing site with no live `api.cupidus.app` dependency — every
design-source interaction, including this story's FAQ and support contact,
is a static link, `mailto:`, or presentational-only control.

### Scope Items BLOCKED in this story

- None. Both requirement-level OQs are resolved, and this story introduces no
  new open question of its own.

### Scope Items NOT BLOCKED in this story

- FAQ list rendering (AC-2, AC-3): resolved by OQ-REQ006-2 — static seed
  content, no backend dependency.
- Support contact block (AC-4): resolved by OQ-REQ006-2 — `mailto:` link
  only, no live form/ticketing backend.
- Page framework/scaffold/nav reuse (AC-1): resolved by OQ-REQ006-1 —
  STORY-001's Tech Lead framework decision applies unchanged.
- Per-page `<title>` tag (AC-7): not blocked by any OQ; carried forward as a
  direct AC from STORY-001 review's DEF-2 finding.

## Traceability

| AC/BR | Design Source Anchor | Notes |
|-------|----------------------|-------|
| AC-1 | `Cupid Web.dc.html` nav array (`isSupport` prop, "Hỗ trợ"/"Support" label) | Nav route already exists from STORY-001 |
| AC-2, AC-5 | `Cupid Web.dc.html` `isSupport` section + `faq` data array (6 entries) | Heading + FAQ content |
| AC-3, BR-3 | `Cupid Web.dc.html` `isSupport` section, `<details>`/`<summary>` markup | Independent expand/collapse |
| AC-4, BR-2 | `Cupid Web.dc.html` `isSupport` section, "Still need a human?" block, `mailto:hi@cupid.app` | Contact fallback |
| AC-6 | `Cupid Web.dc.html` `isSupport` section (full visual spec: spacing, colors, typography) | UI-lane review gate required |
| AC-7 | Carried-forward DEF-2, STORY-001 review | Not present in design comp markup (comp has no per-page `<title>`); an implementation-level requirement |

## Dependencies

- STORY-001 (DONE): shared chrome, header/footer, nav routing, language
  toggle, theme toggle, and the chosen frontend framework — this story reuses
  all of these without modification.
