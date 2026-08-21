# Story Requirements: STORY-008 Privacy & Terms Page

## Identity

- Parent requirement: REQ-006 Web frontend implementation from design
  system & production deploy
- Story master: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-008/story_master.md`
- Design source of truth: `cupid-app-design-system/Cupid Web.dc.html`,
  `isLegal` page block (lines 639-653), nav-triggered footer links (lines
  844-847), and `legal` data array (lines 823-829)
- Depends on: STORY-001 (Frontend App Foundation & Home Landing Page) —
  DONE, MERGE_COMPLETE. Reuses the shared shell (header/nav, theme toggle,
  language toggle, footer) and framework decision (Astro static site, per
  OQ-REQ006-1 resolution recorded in STORY-001) unmodified. This story adds
  only the `legal` page body behind the existing nav route.

## Actor And Capability

- Actor: visitor, or a compliance/legal reviewer, wanting to read the
  privacy policy and terms of service.
- Capability: reach a "Legal" page — via the footer "Legal" column links
  ("Privacy" / "Terms", both routing to the same page in the design source)
  and via a direct URL — showing an "Updated <date>" line followed by the
  five legal sections defined in the design source, each with a title and
  body, in both Vietnamese and English per the active language toggle.
- Business value: legal/compliance transparency required for any public
  consumer app; a prerequisite for app-store listing and production launch.

## Acceptance Criteria

- AC-1 (Route & discoverability): The page is reachable at the "legal" nav
  route used by the design source's `nav("legal")` handler, and via both
  footer links labeled "Quyền riêng tư" / "Privacy" and "Điều khoản" /
  "Terms" in the "Pháp lý" / "Legal" footer column established in STORY-001.
  Both links navigate to the same single page (the design source does not
  split Privacy and Terms into separate pages).
- AC-2 (Header content): The page renders the eyebrow label "Legal", the
  heading "Quyền riêng tư & Điều khoản" (VI) / "Privacy & Terms" (EN), and
  the updated-date line "Cập nhật 29.07.2026" (VI) / "Updated 29 Jul 2026"
  (EN), exactly matching the design source's literal strings for the active
  locale.
- AC-3 (Legal sections — verbatim content): The page renders all five legal
  sections from the design source's `legal` array, in source order, each
  with its title and body text reproduced verbatim (no paraphrasing, no
  added/removed sections) in both VI and EN:
  1. "Chúng mình lưu gì" / "What we store"
  2. "Ai xem được" / "Who can see it"
  3. "Không bán dữ liệu" / "No data sales"
  4. "Tài khoản đôi" / "Paired accounts"
  5. "Điều khoản ngắn gọn" / "Terms, briefly"
- AC-4 (Locale and theme parity): The page respects the shared language
  toggle (VI/EN) and theme toggle (dark/light) established in STORY-001
  without introducing a page-local toggle implementation.
- AC-5 (Per-page `<title>` — carried forward from STORY-001 review DEF-2):
  The page sets its own descriptive `<title>` tag (for example "Privacy &
  Terms — Cupid"), distinct from the shared shell's default title, so each
  page is independently identifiable in browser tabs, history, and search
  results.
- UI-Fidelity-AC: The rendered Legal page must be visually identical
  ("giống 100%") to the `isLegal` block of `Cupid Web.dc.html` — layout,
  spacing, typography, and section order match the design source pixel for
  pixel, per the requirement-level 100%-visual-fidelity acceptance
  requirement (`req_master.md` Business Scope; `requirements/requirements.md`
  Business Rules And Guardrails). This story therefore uses the full
  UI-lane review gate, not the Tier 0 lightweight gate.

## Content Placeholder Note

- This story's legal copy is reproduced exactly as authored in the design
  source (`Cupid Web.dc.html` `legal` array) — see AC-3. It is placeholder
  business copy from the design comp, not reviewed or authored by counsel
  in this delivery workflow. Reproducing it verbatim is in scope; authoring,
  editing, or legally validating the policy content itself is out of scope
  for this story (per `story_brief.md` guardrails). If the user later
  supplies counsel-reviewed legal text, that is a separate content-update
  scope, not a rework of this story's acceptance criteria.

## Scope

### In Scope

- The `legal` page route and its content block (heading, updated-date line,
  five legal sections) per AC-1 through AC-4.
- Per-page `<title>` tag per AC-5 (DEF-2 carry-forward from STORY-001).
- Footer "Legal" column links routing to this page (both already declared
  in the shared footer data from STORY-001; this story only needs the
  target route/page to exist).

### Out of Scope

- Authoring or legally reviewing the policy content itself — content is
  reproduced verbatim from the design source (see Content Placeholder Note).
- Any backend/API integration — this is a fully static page, consistent
  with OQ-REQ006-2's resolution (no live API dependency in v1).
- Splitting Privacy and Terms into two separate pages/routes — the design
  source defines one combined "Legal" page.
- Any change to the shared shell, nav, theme toggle, or language toggle
  built in STORY-001.

## Open Question Impact

Requirement-level open questions re-checked against this story's scope:

- OQ-REQ006-1 (frontend framework/stack) — RESOLVED by STORY-001 Tech
  Lead: Astro static site. This story reuses that decision; no impact on
  this story's business scope or acceptance criteria.
- OQ-REQ006-2 (backend API dependency) — RESOLVED (2026-08-21, Product
  Owner): static/marketing site, no live API dependency. Directly
  applicable to this story: the Legal page has zero backend calls.

### Scope Items BLOCKED in this story

- None. Both requirement-level open questions are resolved and neither
  blocks any acceptance criterion above.

### Scope Items NOT BLOCKED in this story

- AC-1 (route & discoverability) — depends only on STORY-001's shared nav
  and footer, already DONE.
- AC-2 (header content) — static content, no dependency on open questions.
- AC-3 (legal sections, verbatim) — static content, no dependency on open
  questions.
- AC-4 (locale/theme parity) — reuses STORY-001's shared toggles, already
  DONE.
- AC-5 (per-page `<title>`) — implementation detail independent of both
  open questions.
- UI-Fidelity-AC — independent of both open questions; verified against the
  static design source.

## Traceability

- Requirement-level Coverage Map row: "Privacy & Terms page" → STORY-008
  (`requirements/requirements.md` Coverage Map).
- Requirement-level Story Index row: STORY-008 → `story_brief.md` → "Legal
  page" → "Depends on STORY-001" (`requirements/requirements.md` Story
  Index).
