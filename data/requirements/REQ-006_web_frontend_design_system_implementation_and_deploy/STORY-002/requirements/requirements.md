# Story Requirements: STORY-002 Pet Universe Showcase Page

## Identity

- Parent requirement: REQ-006 Web frontend implementation from design system
  & production deploy
- Depends on: STORY-001 (Frontend App Foundation & Home Landing Page) —
  DONE, MERGE_COMPLETE. Reuses its framework choice (Astro static site),
  shared header/nav (desktop nav + mobile nav `<select>`), theme toggle,
  language toggle, footer, and page-shell routing convention. This story
  adds exactly one new page behind the existing "Pets" nav item.
- Design source of truth: `cupid-app-design-system/Cupid Web.dc.html`,
  `isPets` conditional block (source lines ~213-283) and its bound data:
  `pets` array (line ~741) and `stages` array (line ~756).

## Actor & Business Value

- Actor: a visitor evaluating the app who wants to know what the pet
  characters are like before downloading.
- Value: helps visitors emotionally connect with the core "raise a pet
  together" mechanic, supporting download conversion.

## Scope

### In Scope

- New "Pets" page reachable from the shared header nav (desktop) and mobile
  nav `<select>` established in STORY-001.
- Hero block: eyebrow label "Pet Universe", H1 heading, supporting
  paragraph — VI and EN copy per design source.
- All 6 pet cards, each with: sprite/character art, name, trait tag, and
  description — VI and EN copy per design source. Pets, in design order:
  Bo (Loyal / Trung thành), Bun (Shy / Nhút nhát), Kem (Calm / Bình tĩnh),
  Mochi (Playful / Nghịch ngợm), Sua (Clingy / Nhõng nhẽo), Xoài (Stubborn /
  Lì lợm).
- Four-stage growth explainer block, with stage number, title, and
  description for each of the 4 stages — VI and EN copy per design source:
  01 Egg/Trứng, 02 Baby/Bé con, 03 Grown/Trưởng thành, 04 Spirit/Linh thú.
- Page participates in the existing dark/light theme toggle and VI/EN
  language toggle from STORY-001's shared chrome (no new toggle logic).
- Page has its own descriptive `<title>` tag (carried-forward finding
  DEF-2 from STORY-001 review — see AC-6).

### Out of Scope

- Any pet-selection, pairing, or account-linked functionality — the design
  source has no interactive selection state on this page; it is a static
  showcase only.
- Any backend/API integration (per requirement-level OQ-REQ006-2
  resolution — this is a static/informational marketing site).
- Any other page's content (Zodiac, Invite, Blog, About, Support, Legal —
  separate stories).

## Acceptance Criteria

- **AC-1 (Navigation & routing):** From any page, a visitor can reach the
  Pets page via the "Pets" item in the shared header nav (desktop) and the
  mobile nav `<select>`; the Pets nav item is visually marked as active
  while on this page, consistent with STORY-001's active-nav-state pattern.
- **AC-2 (Hero content):** The Pets page renders the hero eyebrow label
  ("Pet Universe"), H1 heading ("Which one is yours?" / "Bé nào là bé của
  hai bạn?"), and supporting paragraph, matching the design source copy
  exactly in both VI and EN.
- **AC-3 (Pet roster):** The page renders all 6 pet cards, in design order,
  each showing the character sprite/art, name, trait tag, and description,
  matching the design source copy exactly in both VI and EN. No pet is
  omitted, reordered, or has placeholder/lorem content.
- **AC-4 (Growth stages):** The page renders the four-stage growth
  explainer with all 4 stages in order (Egg, Baby, Grown, Spirit), each
  showing its stage number, title, and description, matching the design
  source copy exactly in both VI and EN.
- **AC-5 (Theme & language parity):** Toggling dark/light theme or VI/EN
  language (via the shared STORY-001 controls) updates this page's content
  and styling consistently with the rest of the site; no untranslated or
  broken content in either language or theme state.
- **AC-6 (Per-page title — DEF-2 carry-forward):** The Pets page has a
  distinct, descriptive `<title>` tag (not the site-wide default/home
  title), reflecting the page's content (e.g. references "Pets" / the pet
  universe).
- **AC-7 (Responsive layout):** The pet-card grid and stage-explainer grid
  reflow correctly at mobile, tablet, and desktop breakpoints consistent
  with STORY-001's established responsive behavior (no horizontal overflow,
  no overlapping content).
- **UI-Fidelity-AC (cross-cutting, per `req_master.md` Technical
  Constraints):** The deployed Pets page is visually identical ("giống
  100%") to the `isPets` block of `Cupid Web.dc.html` at matching viewport
  sizes — layout, spacing, colors, typography, and imagery match the design
  source. This is a strict pixel/visual-fidelity requirement and drives the
  full UI-lane review gate for this story (not the Tier 0 lightweight
  gate).

## Business Rules

- BR-1: This page is presentational only — no backend/API calls, no
  client-side persistence of a "selected" pet.
- BR-2: Pet names, trait tags, and descriptions must match the design
  source verbatim in both VI and EN; no paraphrasing or summarizing of
  copy.
- BR-3: Growth-stage copy (numbers, titles, descriptions) must match the
  design source verbatim in both VI and EN.

## Edge Cases

- None beyond standard responsive layout — content is static and always
  fully populated (6 pets, 4 stages); there is no empty/loading/error state
  for this page.

## Open Question Impact

Requirement-level OQ triage as of this story: OQ-REQ006-1 (frontend
framework/stack) RESOLVED by STORY-001 Tech Lead — Astro static site.
OQ-REQ006-2 (API dependency) RESOLVED by Product Owner — static/marketing
site, no live `api.cupidus.app` dependency in v1.

### Scope Items BLOCKED in this story

- None. Both requirement-level open questions are resolved, and this
  story's entire scope (a static showcase page reusing STORY-001's shell)
  depends only on already-DONE STORY-001 output.

### Scope Items NOT BLOCKED in this story

- AC-1 through AC-7 and UI-Fidelity-AC — all in-scope items proceed
  unblocked: framework choice is settled (Astro, from STORY-001), and no
  scope item on this page requires a live backend API.

## Traceability

- Coverage Map row: `requirements/requirements.md` → "Pet Universe showcase
  page" → STORY-002.
- Design source anchor: `cupid-app-design-system/Cupid Web.dc.html`,
  `isPets` conditional (~line 213), `pets` data array (~line 741), `stages`
  data array (~line 756).
- Carried-forward finding: DEF-2 from STORY-001 review (per-page `<title>`
  tag) — addressed by AC-6.
