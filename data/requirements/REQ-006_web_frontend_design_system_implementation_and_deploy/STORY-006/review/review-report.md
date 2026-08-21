# Review Report — REQ-006 / STORY-006 About & Press Kit Page

Outcome: PATCH_REQUIRED

Review type: `full-story-review`
Scope gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-006/review/scope-gate.md`
Reviewer diff baseline: `c744eaf1..8c5a907c` (worktree
`story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-006`)
Story class `standard` · lane `frontend` · complexity `standard`

## Rationale

The **code is clean**. Every functional acceptance criterion passes against the
design source read line-by-line, copy is verbatim, the shell contract is intact,
and both deferrals the implementer flagged are legitimate on the merits (one is
literally the fallback the UX spec prescribes).

The story is nonetheless returned for **two missing mandatory evidence
sections** in `coding-plan/test-results.md`. Neither is a code defect and both
are cheap — but they are non-waivable gates, `STORY-001` of this same
requirement already carries both, and the DONE gate enforces them independently,
so approving now would only relocate the failure to story closure.

## Acceptance criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 route reachability | PASS | verified in code, not on trust: `web/src/pages/about.astro` (file-based route `/about`), `web/src/data/site-nav.ts:35` header nav item, `:56`/`:57` footer Company column + "Press kit" — a discoverable nav item, not direct-URL-only |
| AC-2 mission | PASS | verbatim vs `Cupid Web.dc.html:514-516` |
| AC-3 principles ×4 | PASS | `about-content.ts` `principles` character-identical to source `:800-805`; 4 entries |
| AC-4 stat counters ×3 | PASS | `48.000+` / `31.500` / `2,1 triệu` verbatim vs `:528`,`:531`,`:534`, correctly rendered OUTSIDE any `data-vi`/`data-en` pair, exactly as the source does |
| AC-5 "Why a pet?" callout | PASS | verbatim vs `:539-542` |
| AC-6 timeline ×5 | PASS | 5 entries verbatim vs `:546-565`, chronological 2024/2025/2025/2026/2026; wrapper is a semantic `<ol>`/`<li>` |
| AC-7 team ×3 | PASS | 3 cards verbatim vs `:569-580`, gradients included; avatars `aria-hidden` (decorative) |
| AC-8 press kit always visible | PASS | `showPressKit` `<sc-if>` deliberately not ported; 8 palette swatches verbatim vs `:803-812`; CTA is `href="/press-kit/cupid-press-kit.zip" download`, replacing the source's dead `href="#"` as AC-8 requires; `web/public/press-kit/cupid-press-kit.zip` independently opened — valid archive, 4 entries, 2380 B uncompressed |
| AC-9 per-page `<title>` | PASS | `about.astro` passes `title="Giới thiệu & Bộ nhận diện thương hiệu — Cupid"`; `SiteLayout.astro:17` default `'Cupid'` is not used. Closes STORY-001 `DEF-2` for this route |
| AC-10 visual fidelity | UNVERIFIED | see DEF-3 — the design-reference render is not reachable with sanctioned tooling |
| AC-11 copy fidelity | PASS | every VI/EN string compared against `:511-610` and the `principles`/`palette` arrays; no paraphrase found |

Deliberate localization asymmetry confirmed **correct and left alone**: the three
stat numerals are unlocalized literals (source `:528`/`:531`/`:534` places them
outside any `data-*` span), while timeline entry 4's separator IS localized
(`48.000 cặp đôi` / `48,000 couples`, source `:561`) because it sits inside
translated prose. These are the design source's own two different treatments,
not an inconsistency to normalize.

## Touched risk surfaces and critical gates

| Risk surface | Gate | Status |
|---|---|---|
| Frontend interaction / static render | `astro check` + `astro build` exit `0` | PASS (evidence P1 + P2 command tables; 35 files 0 errors, 8 pages) |
| Frontend discoverability / nav integration | reachable entry point verified in code | PASS in code — **evidence section missing, see BLK-2** |
| Shared contract (STORY-001 shell) | zero diff under `layouts`/`components/shell`/`styles`/`scripts` | PASS — independently re-run at review time, also clean for `web/src/data/site-nav.ts` and `web/package-lock.json` |
| Static asset delivery (press-kit zip) | asset ships, CTA resolves, `download` present, keyboard-reachable | PASS |
| Runtime/operational | `## Story Runtime Startup Smoke` | **MISSING — BLK-1** |
| UI design fidelity | per-story rendered `visual-fidelity/` | NOT ACHIEVABLE — see DEF-3 |

Configuration-guide check: not applicable. This story ships no env var, no
service, no runtime command and no deploy step — only static page content plus
files under `web/public/`, which Astro copies verbatim.

## Blocking findings

### BLK-1 — `## Story Runtime Startup Smoke` section missing (owner: frontend-dev)

`coding-plan/test-results.md` has no `## Story Runtime Startup Smoke` section.
This is a non-trivial `frontend`-lane story and `story_master.md` carries no
`Runtime-Smoke: WAIVED — <reason>` line, so the gate is mandatory. `STORY-001`
of this requirement carries the section at its `test-results.md:1146` (added
after an earlier `NOT_APPLICABLE` was corrected), which is the format to match.

Action: start the app from the runtime command registry contract
(`runtimes.web-frontend`, reserved port, Node pinned to v22.17.1 for the
`>=22.12.0` engine), confirm `/about` serves, tear down, and record the command,
the port, and the result under that exact heading.

### BLK-2 — `## Entry Point Reachability` / `Reachable: YES` section missing (owner: frontend-dev)

The substance exists — `test-results.md` has a `### Entry point reachability
(AC-1)` subsection with a correct 3-anchor table — but not the mandated
`## Entry Point Reachability` heading with an explicit `Reachable: YES` line and
the concrete path. `STORY-001` carries it at `test-results.md:1187-1189`.

I independently confirmed the entry point is real (`site-nav.ts:35` header nav
item → `/about`, plus two footer links), so this is a format gap, not a missing
capability. Promote the existing subsection to the required heading and add
`Reachable: YES` with the path `/about` and the header-nav source line.

## Deferred findings

### DEF-1 — EN `<title>` not shipped (accepted; NOT an implementation shortcut)

Confirmed genuine. The bilingual mechanism is CSS visibility over
`data-vi`/`data-en` spans and cannot operate inside `<head>`; delivering an EN
title needs a `document.title` script in `SiteLayout.astro` or
`web/src/scripts/`, both named explicitly in `contract-summary.md` §6 as files a
consumer story must not modify (a shell edit silently re-renders the other seven
routes and invalidates their fidelity evidence).

Stronger than "allowed": `uiux-spec.md` §6.9 line 199 instructs exactly this —
"if not, default to the site's default language and flag that gap back rather
than silently shipping one hardcoded language." The implementer followed the UX
spec's own prescribed fallback. AC-9 requires a descriptive per-page title, not a
bilingual one. Route the site-wide fix with the remaining per-page title
decisions for STORY-002…STORY-008 (uiux-spec §6.9 explicitly scopes `DEF-2`'s
closure to this page only).

### DEF-2 — footer "Press kit" lands at page top, not `#press-kit` (accepted; rationale corrected)

Correctly deferred, but **the stated reason is factually wrong and must not be
inherited**. The implementer recorded that re-pointing the link is "a
`SiteFooter.astro` edit". It is not: the href comes from
`web/src/data/site-nav.ts:57`, a data file that `contract-summary.md` §6 does not
name and that the story's own shell-immutability check does not cover.

The deferral still stands on the merits, on two independent grounds:
`uiux-spec.md` §6.6 line 176 states the anchor is "a recommendation, not an AC,
since the source itself doesn't do it and the story's ACs don't require it" and
routes it to Tech Lead; and `site-nav.ts` is shared nav data consumed by all
eight routes, so changing it is a cross-story decision rather than a consumer
story's call. AC-1 is satisfied as written — the link reaches `/about` and does
not 404. The `id="press-kit"` anchor this story added means the follow-up is now
a one-line change whenever Tech Lead decides.

### DEF-3 — AC-10 design-reference render is not reachable with sanctioned tooling

`data/devops/system/design-fidelity-config.json` has `design_source` configured
and `ui_surface: true`, so the per-story rendered check is in force and is the
reviewer's to run for a non-mobile lane. I attempted it and it is blocked on the
**reference** side, not the implementation side:

- `Cupid Web.dc.html` selects its page state from a runtime `startPage` prop
  (`:679` props block, `:709`, `:721` — `isAbout: p === "about"`), whose default
  is `"home"`. The About state is a runtime state of the canvas, not a file.
- `render-design-canvas.js --screen=<id>` drives off a `[data-screen-btn]`
  inventory that is empty for this web canvas (STORY-001 recorded
  `--list-screens` → `{"screens":[],"toggles":[],"platforms":[]}`); it exposes
  `--theme`/`--lang` but no prop or start-page override.
- `visual-capture.js` offers `--storage-state`/`--fake-state`
  (cookies/localStorage/sessionStorage/mocks) and `--wait-selector`, none of
  which reach the canvas runtime's `startPage`; the runtime reads no query
  string. There is no click/eval hook.

The only remaining routes are a hand-rolled Playwright script or editing the
locked design source — both forbidden, and the second is precisely the
manufacture-a-reference failure mode the gate exists to catch. Recording
`VISUAL_STATE_NOT_FORCEABLE` (design-reference side) rather than a silent
deferral, because this is a **bundle-tooling capability gap that affects every
non-home page in REQ-006**, not a per-story omission: STORY-001 could render its
reference only because Home is the canvas default.

Route to Tech Lead / bundle tooling: add a sanctioned prop or start-state
override (e.g. `render-design-canvas.js --prop=startPage=about`, or a
`--click-selector` in `visual-capture.js`) so every non-default canvas state
gets a reference. Until then AC-10 stays UNVERIFIED for this story and for the
requirement-level UI gate.

Note for Scrum Master: this residual is NOT resolved by the two blockers above.
Fixing BLK-1/BLK-2 will make the story eligible again, but AC-10 will still be
UNVERIFIED at that point and must be closed at the requirement level or by the
tooling fix.

## Traceability

- Requirements: `requirements/requirements.md` AC-1…AC-11, Scope Decision, Open
  Question Impact (`OQ-REQ006-1`/`OQ-REQ006-2` both RESOLVED, nothing blocked —
  no over- or under-application found).
- UX: `ux/uiux-spec.md` §6.2.1–§6.2.7 (line-cited values), §6.6 (discoverability
  flag, keyboard/focus), §6.8, §6.9 (per-page title + prescribed language
  fallback).
- Architecture: `architecture/solution.md` Key Discovery 1 (head/bilingual
  limit); `STORY-001/architecture/contract-summary.md` §6 (consumer
  prohibitions) — no prohibition breached.
- Design source: `cupid-app-design-system/Cupid Web.dc.html:511-610`,
  `:800-805`, `:807-812`.
- Evidence: `coding-plan/test-results.md` P1 + P2 (build/type-check tables,
  assertion tables, 16-run rendered inspection, keyboard/focus table).
- Independently re-verified by the reviewer: shell-immutability diff, press-kit
  zip contents, nav wiring in `site-nav.ts`, `SiteLayout.astro` title prop, and
  all copy against the design source.

## State recommendation

- Uncheck `Implementation (Development)`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS` — return to `frontend-dev` for BLK-1 and BLK-2
  (evidence sections only; no code change is requested or wanted)
- Do not mark `DONE`
