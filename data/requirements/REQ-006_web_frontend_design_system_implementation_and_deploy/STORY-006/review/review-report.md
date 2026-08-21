# Review Report — REQ-006 / STORY-006 About & Press Kit Page

Outcome: DEFERRED_ONLY

Review type: `full-story-review` (fresh re-review, Iris-QC-9, supersedes the
earlier `PATCH_REQUIRED` pass)
Scope gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-006/review/scope-gate.md`
Reviewer diff baseline: `git -C <Worktree> diff 2e72902de51910c18ca1c6e8ca31faeedc14d823`
Worktree: `story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-006`
Story class `standard` · lane `frontend` · complexity `standard`

## Rationale

Every acceptance criterion passes, including AC-10, which the previous pass left
`UNVERIFIED`. The two blockers from that pass (`BLK-1` runtime startup smoke,
`BLK-2` entry-point reachability heading) are closed and were re-verified
independently rather than accepted on the evidence file's word. The rendered
implementation capture that was previously impossible now exists at all three
configured breakpoints and matches the UX spec with no visible deviation.

Three deferrals carry forward and one is new; none blocks closure.

## Acceptance criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 route reachability | PASS | `web/src/pages/about.astro` (file route `/about`); `web/src/data/site-nav.ts:35` header nav item, `:56`/`:57` footer Company column + "Press kit". Re-verified in the rendered 1280 capture: the header pill "Về chúng mình" renders `aria-current` active — discoverable, not direct-URL-only |
| AC-2 mission | PASS | verbatim vs `Cupid Web.dc.html:514-516`; visible in all three captures |
| AC-3 principles ×4 | PASS | `about-content.ts` `principles` character-identical to source `:800-805`; 4 cards render (4-up @1280, 2-up @768, 1-up @375) |
| AC-4 stat counters ×3 | PASS | `48.000+` / `31.500` / `2,1 triệu` verbatim vs `:528`/`:531`/`:534`, rendered outside any `data-vi`/`data-en` pair exactly as the source does |
| AC-5 "Why a pet?" callout | PASS | verbatim vs `:539-542` |
| AC-6 timeline ×5 | PASS | 5 entries verbatim vs `:546-565`, chronological 2024/2025/2025/2026/2026; wrapper promoted to semantic `<ol>`/`<li>` per uiux-spec §6.6 with the list reset keeping the render identical |
| AC-7 team ×3 | PASS | 3 cards verbatim vs `:569-580`; the three source gradients render as circular decorative avatars, `aria-hidden` |
| AC-8 press kit always visible | PASS | `showPressKit` `<sc-if>` deliberately not ported; 8 palette swatches verbatim vs `:807-812`; CTA `href="/press-kit/cupid-press-kit.zip" download` replaces the source's dead `href="#"`. Zip re-verified: valid archive, 4 entries, 2380 B uncompressed, served `200 application/zip` |
| AC-9 per-page `<title>` | PASS | served `<title>Giới thiệu & Bộ nhận diện thương hiệu — Cupid` measured on the running server, not read from source |
| AC-10 visual fidelity | PASS | `visual-fidelity/visual-fidelity-report.md`, `VISUAL_FIDELITY: PASS`, with real `implemented-about-{375,768,1280}.png` rendered by this reviewer. See the visual-fidelity gate row below |
| AC-11 copy fidelity | PASS | every VI/EN string compared against `:511-610` and the `principles`/`palette` arrays; no paraphrase |

The deliberate localization asymmetry is confirmed correct again and must not be
normalized: the three stat numerals are unlocalized literals (source
`:528`/`:531`/`:534` places them outside any `data-*` span) while timeline entry
4's separator IS localized (`48.000` / `48,000`, source `:561`) because it sits
inside translated prose.

## Touched risk surfaces and critical gates

| Risk surface | Gate | Status |
|---|---|---|
| Frontend interaction / static render | `astro check` + `astro build` | PASS — both re-run by the reviewer in this worktree: check 35 files 0/0/0, build 8 pages, exit 0 |
| Frontend discoverability / navigation integration | rule 12e1 `## Entry Point Reachability` + independent code check | PASS — `test-results.md:230-232` `Reachable: YES`, path `/about`; independently confirmed at `site-nav.ts:35`/`:56`/`:57` and in the rendered header |
| Runtime / operational | rule 12g `## Story Runtime Startup Smoke` | PASS — `test-results.md:279-362`: registry runtime `web-frontend`, reserved port 21021, pre-start free-port probe, `GET /` and `GET /about/` both 200, clean SIGTERM shutdown with no orphan listener. Reviewer independently booted the same runtime on the same port during the visual capture |
| UI design fidelity | rule 12e2 rendered check, under the REQ-006 amended standard | PASS (implementation side) / DEFERRED (reference side) — see DEF-3 |
| Shared contract (STORY-001 shell) | zero diff under shell/layout/style/script | PASS — `git diff --name-only <BaseHead>` touches only `web/src/pages/about.astro`, `web/src/data/about-content.ts`, `web/src/components/about/*`, and `web/public/press-kit/*`. `site-nav.ts` and `package-lock.json` unchanged |
| Static asset delivery | press-kit zip ships and CTA resolves | PASS |

Configuration-guide check: not applicable. The story ships no env var, no
service, no runtime command and no deploy step — only page content plus files
under `web/public/`, which Astro copies verbatim.

Prior blockers, re-verified rather than assumed closed: **BLK-1 CLOSED**,
**BLK-2 CLOSED**. Both were evidence-form gaps; the patch added the two sections
and changed zero files under `web/`, which the diff confirms.

## Deferred findings

### DEF-1 — EN `<title>` not shipped (carried forward, accepted)

The bilingual mechanism is CSS visibility over `data-vi`/`data-en` spans and
cannot operate inside `<head>`. Delivering the EN title needs a
`document.title` script in `SiteLayout.astro` or `web/src/scripts/`, both named
in `STORY-001/architecture/contract-summary.md` §6 as files a consumer story
must not modify. `uiux-spec.md` §6.9 line 199 prescribes exactly this fallback.
AC-9 requires a descriptive per-page title, not a bilingual one. Route the
site-wide fix with the remaining per-page title decisions for
STORY-002…STORY-008.

### DEF-2 — footer "Press kit" lands at page top, not `#press-kit` (carried forward, accepted)

`uiux-spec.md` §6.6 line 176 states the anchor is "a recommendation, not an AC,
since the source itself doesn't do it and the story's ACs don't require it" and
routes it to Tech Lead. The href comes from `web/src/data/site-nav.ts:57` —
shared nav data consumed by all eight routes, so changing it is a cross-story
decision, not a consumer story's call. (Note for whoever picks this up: it is
NOT a `SiteFooter.astro` edit, as an earlier evidence note claimed.) This story
added `id="press-kit"`, so the follow-up is now a one-line change.

### DEF-3 — no screen-specific design-reference canvas render (permanent, per requirement-level decision)

`render-design-canvas.js` can only drive the canvas to its default `home`
`startPage`; the About state is a runtime React prop, not a file or a
`[data-screen-btn]` target. Fix 2 in
`data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/design-fidelity-tooling-fix.md`
is BLOCKED because that tool is gitignored, generated output projected from a
separate bundle source repo. Per the user decision recorded in that document
(2026-08-21, second decision), the design-reference side for every non-`home`
REQ-006 screen is satisfied by `uiux-spec.md`, and this residual is recorded
once per story as DEFERRED — it is explicitly not grounds for
`PATCH_REQUIRED`/`BLOCKED`. The implementation-side render required by that same
decision WAS produced and passes.

### DEF-4 — the reserved web port is shared across parallel worktrees (new; owner: DevOps / Scrum Master)

Not a defect in this story's code, recorded because it can silently falsify
visual evidence across the whole requirement. `app_render.base_url` is pinned to
`http://127.0.0.1:21021`, and every REQ-006 story worktree builds a different
tree onto that same port. During this review the first capture attempt rendered
a foreign build: `/about/` answered `200` with a 15440-byte shell containing an
empty `<main>` and none of this story's content, while this worktree's own
`dist/about/index.html` was 31368 bytes and complete. The capture was redone
only because the served payload was byte-checked before rendering. A reviewer
who trusts a `200` would ship a confident PASS over another branch's build.
Recommend either a per-worktree port lease for `app_render` or a mandatory
served-payload assertion before capture.

## Traceability

- Requirements: `requirements/requirements.md` AC-1…AC-11, Scope Decision,
  Open Question Impact (`OQ-REQ006-1`/`OQ-REQ006-2` both RESOLVED, nothing
  blocked — no over- or under-application found).
- UX: `ux/uiux-spec.md` §6.2.1–§6.2.7 (line-cited values), §6.5 (fixed-colour
  lockup pair), §6.6 (fluid grids, semantic list, decorative avatars, focus
  ring), §6.7, §6.8 (layout/colour/type anchors), §6.9.
- Architecture: `architecture/solution.md` Key Discovery 1 (head/bilingual
  limit); `STORY-001/architecture/contract-summary.md` §6 — no prohibition
  breached.
- Design source: `cupid-app-design-system/Cupid Web.dc.html:511-611`,
  `:800-805`, `:807-812`.
- Evidence: `coding-plan/test-results.md` P1/P2, `## Entry Point Reachability`,
  `## Story Runtime Startup Smoke`, `## Post-Patch Regression Check`;
  `visual-fidelity/visual-fidelity-report.md`.
- Governing decision: `../design-fidelity-tooling-fix.md`.
- Independently re-run or re-measured by the reviewer: `astro check`,
  `astro build`, the served `/about/` payload and `<title>`, the press-kit zip
  contents and its HTTP delivery, the shell-immutability diff, the nav wiring in
  `site-nav.ts`, and the three rendered breakpoints.

## State recommendation

- Keep `Implementation (Development)` checked
- Check `Review (Reviewer)`
- Story status: `DONE`
- Story branch is merge-eligible into
  `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-integration`
- Carry DEF-1 and DEF-2 to the requirement level; DEF-3 is closed-as-accepted by
  the requirement-level decision; DEF-4 is an operational item for DevOps that
  affects the remaining REQ-006 story reviews
