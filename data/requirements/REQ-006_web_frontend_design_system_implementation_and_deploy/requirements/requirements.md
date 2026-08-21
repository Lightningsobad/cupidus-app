# Requirement Breakdown: REQ-006 Web frontend implementation from design system & production deploy

## Source Artifacts

- Requirement master: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/req_master.md`
- Additional input files: `cupid-app-design-system/Cupid Web.dc.html` (design source, read-only)
- Existing related requirement artifacts: REQ-005 (production domain + CI/CD standardization, DONE — reused deploy pattern)

## Context Summary

- Request summary: build a brand-new public marketing/informational website for
  Cupid from the existing `Cupid Web.dc.html` design comp, and deploy it at
  the apex domain `cupidus.app` on the REQ-005 VPS.
- Primary actors: prospective couples visiting the marketing site (download
  intent), existing users following a shared invite/pairing link, content
  readers (blog), press/partners (press kit), support seekers (FAQ),
  compliance reviewers (privacy/terms).
- Problem to solve: there is currently no web frontend app in this project's
  runnable foundation; the approved web design has no corresponding shipped
  site.
- Business outcome: a live, publicly reachable, visually-faithful web
  presence at `cupidus.app` that drives app downloads and supports
  press/support/legal needs.
- Success signal: `cupidus.app` resolves to the deployed site; every screen
  in the design source has a corresponding, navigable, visually-matching page.
- Notes on current project context: greenfield frontend — no existing
  repository, framework, or prior story seeds for this app. `Cupid
  Web.dc.html` is a single design-comp file that renders 8 client-routed
  "pages" behind one persistent header/nav/footer shell (`page` state:
  `home`, `pets`, `zodiac`, `share`, `blog`, `about`, `support`, `legal`),
  with a working dark/light theme toggle and VI/EN language toggle built
  into the header. Confirmed by reading the full file: it contains no
  `fetch`/API/backend calls anywhere — every "action" (download buttons,
  pairing code entry, newsletter signup, support email) is a static link,
  `mailto:`, or presentational-only control with no wired backend request.

## Scope Decision

### In Scope

- A new frontend web application (framework/stack chosen by Tech Lead during
  STORY-001) that renders the 8 pages from `Cupid Web.dc.html`: Home,
  Pet Universe, Zodiac, Invite/Pairing, Blog/Journal, About (incl. press
  kit), Support/FAQ, Privacy & Terms.
- The shared visual chrome common to every page: sticky header with logo,
  primary nav, mobile nav select, dark/light theme toggle, VI/EN language
  toggle, "Get the app" CTA, and the footer with link columns.
- Strict pixel/visual-fidelity to the design source on every page ("giống
  100%" — hard user acceptance requirement, not an approximate reskin).
- Production deployment of the built site to `cupidus.app` on the REQ-005
  VPS, reusing the REQ-005 GitHub Actions CI/CD pattern (requirement-level
  DevOps delivery concern, executed once stories are ready — not a PO story;
  see Coverage Map).

### Out of Scope

- Any live backend/API wiring for content that is presentational-only in the
  design source: pairing-code redemption, newsletter subscription, blog CMS,
  contact form submission. The design source has no such wiring, so v1 ships
  these as faithful static/presentational reproductions only. A future
  requirement is needed if any of these must become functional.
- `api.cupidus.app` dependency: not required by this requirement — this site
  does not call the backend API anywhere in the design source.
- Any new design screens not present in `Cupid Web.dc.html` (e.g. a
  dedicated pricing page, account/login pages) — none exist in the source.
- Restricting the theme or language toggle to a subset of the four
  combinations: both toggles are visible, always-rendered interactive
  elements in the design's own header chrome, so restricting them would
  itself violate the 100% visual-fidelity requirement. All four
  combinations (dark/light × VI/EN) ship as working toggles from STORY-001
  onward.

### Business Rules And Guardrails

- Every UI-facing story in this requirement must carry a `UI-Fidelity-AC`
  criterion referencing the design source screen it covers, per Product
  Owner quality bar 11b; none may rely on capability-only acceptance
  criteria for this requirement given the explicit "giống 100%" business
  requirement.
- The global chrome (header/nav/theme-toggle/language-toggle/footer) is
  built exactly once, in STORY-001, and reused unmodified by every later
  page story. Later stories add page body content behind the existing nav
  routes; they must not re-implement or fork the shell.
- Copy must match the design source's literal VI and EN strings for both
  locales; do not paraphrase.
- No story in this requirement may request a backend endpoint change or a
  new backend integration — the design source defines a static/informational
  site.

## Open Question Triage

> Central registry: `data/intake/bootstrap/conflicts_open_questions.md` has
> no `## OQ-to-REQ Index` and no OQ item that references REQ-006 or this web
> frontend scope. The two requirement-local open questions below come from
> `req_master.md`'s own `## Open Questions` section, not the central
> registry, and are given local IDs for traceability since the registry has
> none assigned.

| OQ ID | Status | Scope Items BLOCKED | Scope Items NOT BLOCKED | Decision |
|-------|--------|---------------------|------------------------|----------|
| OQ-REQ006-1 (frontend framework/stack) | UNRESOLVED | Nothing at business-scope level; framework choice itself | All 8 page stories' business scope, acceptance criteria, and content — none depend on which framework is chosen | Deferred to Tech Lead technical solutioning inside STORY-001 (shared-foundation); assigned there in `## Open Question Impact` |
| OQ-REQ006-2 (backend API dependency) | RESOLVED (2026-08-21, Product Owner, evidence-based) | — | All scope | Resolved by direct inspection of `Cupid Web.dc.html`: zero `fetch`/API/backend references found. This is a static/informational marketing site with no live API dependency in v1. `req_master.md` Open Questions updated accordingly. |

### OQs reviewed but not applicable to this requirement

- OQ4 (offline storage strategy, ADR-007) → not applicable; scoped to the
  Flutter mobile app's chat/timeline/expenses data layer, not this static
  web frontend.
- OQ5 (light theme & EN locale enablement scope for the mobile design
  system's first shared-foundation story) → not applicable to REQ-006
  directly; it governs mobile app settings-gated theme/locale enablement.
  The analogous web question (whether to expose the theme/language toggles)
  is answered directly above under Business Rules And Guardrails: the web
  design source renders both toggles as always-visible header controls, so
  the mobile-style "build now, enable a subset at launch" gating does not
  apply — restricting them would itself break the visual-fidelity
  acceptance requirement.

## Seed To Story Mapping

> Not applicable: `req_master.md` carries no `## Story Seeds` table. This is
> a greenfield frontend app with no existing repository or discovery pass to
> seed from, so the story set below is derived directly from the design
> source's 8 pages (distinct user outcomes), not from any seed table.

### Distinct user outcomes in this requirement

1. A prospective couple visiting the site sees a compelling home/landing page
   and can act on download CTAs (App Store / Google Play).
2. A visitor explores the pet characters and growth-stage mechanic before
   deciding to download.
3. A visitor previews the daily zodiac-compatibility feature.
4. A visitor who received a pairing code understands and can start the
   pairing flow via the invite landing page.
5. A visitor reads relationship-focused editorial content and can subscribe
   to the newsletter (presentational).
6. A visitor, press contact, or partner learns the company story, meets the
   team, and downloads brand/press assets.
7. A visitor with a question self-serves via FAQ or finds the support email.
8. A visitor or compliance reviewer reads the privacy policy and terms.

## Coverage Map

| Requirement / Need | Planned Story ID(s) | Notes |
|--------------------|---------------------|-------|
| Frontend framework/stack decision + runnable app scaffold + CI wiring pattern | STORY-001 | Shared-foundation; Tech Lead resolves OQ-REQ006-1 here |
| Global chrome: header, nav (desktop + mobile select), theme toggle, language toggle, footer | STORY-001 | Built once, reused by every later story |
| Home / landing page (hero, features, download CTAs, stats) | STORY-001 | Bundled with foundation so the shared-foundation story itself is observable — see standalone-value gate below |
| Pet Universe showcase page | STORY-002 | |
| Zodiac compatibility preview page | STORY-003 | |
| Invite / pairing landing page | STORY-004 | |
| Blog / Journal page + newsletter signup (presentational) | STORY-005 | |
| About page (mission, stats, timeline, team) + press kit | STORY-006 | |
| Support / FAQ page | STORY-007 | |
| Privacy & Terms page | STORY-008 | |
| 100% visual-fidelity acceptance requirement | STORY-001 through STORY-008 | Cross-cutting; each story carries its own `UI-Fidelity-AC` and passes the full UI-lane review gate (not the Tier 0 lightweight gate), per `req_master.md` Technical Constraints |
| Production deployment to `cupidus.app` on the REQ-005 VPS, reusing REQ-005's GitHub Actions CI/CD pattern | Requirement-level DevOps/Scrum Master concern (not a PO story) | Provisioning/deploy-pipeline work is a requirement prerequisite/delivery-gate action, not a story with its own stakeholder-observable slice distinct from the pages themselves; `req_master.md` Deployment Status already records production as user-requested |

## Recommended Story Sequence

| Story ID | Title | Complexity | Depends On | Why This Order | Observable After This Story |
|----------|-------|------------|------------|----------------|-----------------------------|
| STORY-001 | Frontend App Foundation & Home Landing Page | standard | None | Establishes the framework choice, runnable app, and shared chrome that every other page reuses; ships with the highest-value page (home) so it is itself an observable, valuable slice | A visitor at the deployed site sees the branded Cupid home page — hero, feature highlights, App Store/Google Play download CTAs, stats — with working dark/light theme toggle, VI/EN language toggle, and full site navigation |
| STORY-002 | Pet Universe Showcase Page | standard | STORY-001 | Adds one page behind the existing "Pets" nav item | A visitor can navigate to the Pets page and see all 6 pet characters, their traits, and the four growth stages |
| STORY-003 | Zodiac Compatibility Preview Page | standard | STORY-001 | Adds one page behind the existing "Zodiac" nav item | A visitor can navigate to the Zodiac page and see the daily compatibility read, all 12 signs, the 4 elements, and the weekly top-pairs list |
| STORY-004 | Pairing Invite Landing Page | standard | STORY-001 | Adds one page behind the existing "Invite" nav item | A visitor with a pairing code sees the invite landing page explaining code entry, dual-confirmation, and the resulting keepsake-card preview |
| STORY-005 | Cupid Journal Blog Page | standard | STORY-001 | Adds one page behind the existing "Blog" nav item | A visitor can navigate to the Blog page, read the featured article and article list, and see the newsletter signup block |
| STORY-006 | About & Press Kit Page | standard | STORY-001 | Adds one page behind the existing "About" nav item | A visitor can navigate to the About page and see the mission statement, usage stats, company timeline, team, and download the press kit assets |
| STORY-007 | Support FAQ Page | standard | STORY-001 | Adds one page behind the existing "Support" nav item | A visitor can navigate to the Support page, expand FAQ entries, and find the support contact email |
| STORY-008 | Privacy & Terms Page | standard | STORY-001 | Adds one page behind the existing "Legal" nav item | A visitor can navigate to the Privacy & Terms page and read the current policy sections with their last-updated date |

INTEGRATION_VERIFICATION_REQUIRED: NO

Justification: every later story (STORY-002–STORY-008) adds exactly one page
behind a nav route that STORY-001 already wires up; by the time each later
story is reviewed, STORY-001's shell has already merged, so that story's own
review can directly verify "clicking the nav item renders this page
correctly" as part of its own UI-lane review and visual-fidelity gate. No
runtime interaction between two non-STORY-001 stories exists (the 8 pages do
not call or depend on each other), so no cross-story-only defect could
escape per-story review and code review.

## Story Index

| Story ID | Title | Brief File | Primary Scope | Key AC/OQ Anchors |
|----------|-------|------------|---------------|-------------------|
| STORY-001 | Frontend App Foundation & Home Landing Page | `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/story_brief.md` | App scaffold, framework decision, shared chrome, Home page | OQ-REQ006-1 (framework, resolved here by Tech Lead) |
| STORY-002 | Pet Universe Showcase Page | `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-002/story_brief.md` | Pets page | Depends on STORY-001 |
| STORY-003 | Zodiac Compatibility Preview Page | `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-003/story_brief.md` | Zodiac page | Depends on STORY-001 |
| STORY-004 | Pairing Invite Landing Page | `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-004/story_brief.md` | Invite/Share page | Depends on STORY-001 |
| STORY-005 | Cupid Journal Blog Page | `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-005/story_brief.md` | Blog page | Depends on STORY-001 |
| STORY-006 | About & Press Kit Page | `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-006/story_brief.md` | About page | Depends on STORY-001 |
| STORY-007 | Support FAQ Page | `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-007/story_brief.md` | Support page | Depends on STORY-001 |
| STORY-008 | Privacy & Terms Page | `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-008/story_brief.md` | Legal page | Depends on STORY-001 |
