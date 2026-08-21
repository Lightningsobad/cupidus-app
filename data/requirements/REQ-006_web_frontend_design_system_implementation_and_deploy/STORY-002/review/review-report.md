# Review Report — REQ-006 / STORY-002 Pet Universe Showcase Page

Outcome: DEFERRED_ONLY

- Review type: `full-story-review` (fresh re-review; supersedes the
  2026-08-21 `PATCH_REQUIRED` pass by Iris-QC-3)
- Scope gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-002/review/scope-gate.md`
- Reviewed at: 2026-08-21
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-002`
- Diff: `git diff 2e72902de51910c18ca1c6e8ca31faeedc14d823` (20 files; 5 under `web/`, +100/−2)
- Complexity `standard`, lane `frontend`, UI-bearing, `design_source` configured and locked

## Rationale

All three blocking findings from the previous pass are closed. BLK-1 and BLK-2
were evidence-form gaps and the lane added both canonical sections with real
runs. BLK-3 (rendered design-fidelity comparison) is resolved under the
governing standard now recorded in `design-fidelity-tooling-fix.md`: a genuine
`render-running-app.js` capture of the built app at 375/768/1280 was produced
this pass and compared against the story's `uiux-spec.md`, and it matches with
no visible deviation. The remaining items are deferred notes, one of which
(DEF-5) is an operational risk for the rest of the parallel wave rather than a
defect in this story.

## Reviewed inputs and code scope

| Kind | Files |
|---|---|
| Changed source | `web/src/pages/pets.astro`, `web/src/components/pets/{PetsHero,PetRoster,GrowthStages}.astro`, `web/src/data/pets-content.ts` |
| Read for verification | `web/src/data/site-nav.ts`, `web/src/components/shell/SiteHeader.astro`, `web/src/layouts/SiteLayout.astro`, `web/src/data/home-content.ts`, `web/src/components/sprites/BoSprite.astro` |
| Governing | `requirements/requirements.md`, `ux/uiux-spec.md` §6.1–§6.8, `REQ-006/design-fidelity-tooling-fix.md` |
| Evidence | `coding-plan/test-results.md` (`## Entry Point Reachability`, `## Story Runtime Startup Smoke`, §9), `visual-fidelity/visual-fidelity-report.md` |
| Prior review | `review/review-report.md` (previous pass, read-only context) |

Independently re-run by Reviewer, not taken on trust: `npm run build` PASS
(8 static pages, Node v22.17.1); `astro preview` serving this worktree's `dist`;
`render-running-app.js --route=/pets --breakpoints=375,768,1280 --full-page`
exit 0 with three real PNGs; all three images read at full size.

## Acceptance criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 navigation & active state | PASS | `site-nav.ts:31` `{key:'pets',href:hrefFor('pets')}`; `SiteHeader.astro:26` `aria-current={page===it.key?'page':undefined}` with `:12-13` pink pill / `var(--acc-pink)`; `:33` `<option value={it.href} selected={page===it.key}>`; driven by `pets.astro` `page="pets"`. Confirmed visually: active pill at 1280, `Pet` selected in the `<select>` at 375/768. Footer repeat at `site-nav.ts:46`. |
| AC-2 hero content | PASS | `PetsHero.astro` reproduces uiux-spec §6.2.1 verbatim in both languages; eyebrow correctly left unwrapped (no `data-vi`/`data-en`), as the spec requires. |
| AC-3 pet roster | PASS | Six cards mapped from the single shared `pets` array (`home-content.ts:45-52`), design order Bo/Bun/Kem/Mochi/Sua/Xoài; every `name`/`bg`/`color`/`tvi`/`ten`/`dvi`/`den` is character-identical to uiux-spec §6.2.2. All six visible in the render with sprite, name, trait tag and description. |
| AC-4 growth stages | PASS | `pets-content.ts` `stages` is character-identical to uiux-spec §6.2.3; `01→04` render in order at all three breakpoints. |
| AC-5 theme & language parity | PASS | Every VI/EN pair ships both spans in the diff; per-pet tints are theme-independent `rgba()` literals as the spec requires, with Bo `.12` and Xoài `.1` kept distinct. No new toggle logic added; shell mechanism reused. |
| AC-6 per-page title | PASS | `pets.astro` `title="Pets — Cupid"` → `SiteLayout.astro:17` default `'Cupid'`, `:25` `<title>{title}</title>`. Genuinely per-page. |
| AC-7 responsive layout | PASS | Full-page captures at 375/768/1280: roster reflows 1/2/3 columns, stage grid 1/3+1/4, no overlap, nothing cut vertically, no column below its `minmax` floor. See DEF-2 for the gutter note. |
| UI-Fidelity-AC | PASS | `visual-fidelity/visual-fidelity-report.md` → `VISUAL_FIDELITY: PASS`, with a per-aspect comparison of the three rendered captures against uiux-spec §6.2/§6.7/§6.8. Design-reference side per the standard in `design-fidelity-tooling-fix.md`; see DEF-1. |

## Touched risk surfaces and critical gates

| Risk surface | Gate | Result |
|---|---|---|
| Frontend static page body | `npm run check` / `npm run build` | PASS (build re-run by Reviewer) |
| Frontend discoverability / navigation integration | 12e1 `## Entry Point Reachability` + code verification | PASS — section present at `test-results.md:204` with `Reachable: YES` and the concrete path; independently verified in `site-nav.ts` and `SiteHeader.astro` |
| Design fidelity | 12e2 rendered comparison, as amended by `design-fidelity-tooling-fix.md` | PASS — three real `render-running-app.js` captures, compared against `uiux-spec.md` |
| Runtime / configuration | 12g `## Story Runtime Startup Smoke` | PASS — section present at `test-results.md:244`, registry runtime `web-frontend` on reserved port 21021, `GET /` and `GET /pets/` → 200, clean SIGTERM shutdown, no orphan listener |
| Verbatim copy integrity (BR-2/BR-3) | Copy diff vs uiux-spec tables | PASS |
| Shell immutability (STORY-001 contract) | Diff path check | PASS — diff touches only the five in-scope files; no `layouts/`, `components/shell/`, `styles/`, `scripts/`, no `home-content.ts` |
| Accessibility (uiux-spec §6.6) | Sprite alt/label + `<main>` landmark | PASS — sprites carry `role="img" aria-label="<name>"`; `SiteLayout.astro:37` wraps the slot in `<main>` |

Configuration guide: the diff adds no env var, service, port, or manual setup
step, and phase metadata records `Update Required: NO`. No configuration-guide
change is owed.

## Blocking findings

None.

## Deferred findings

### DEF-1 — no screen-specific design-reference canvas render (permanent, requirement-wide)

`design-reference-pets-*.png` does not exist and cannot be produced in this
repository: `render-design-canvas.js` drives `[data-screen-btn]`/`[data-tog]`/
`[data-plat]`, while this canvas selects its page through the `startPage` React
prop (`Cupid Web.dc.html:679`, consumed `:709`), so only the default `home`
state is reachable. Fix 2 in
`REQ-006/design-fidelity-tooling-fix.md` is BLOCKED because the renderer is
generated, gitignored, out-of-repo tooling. Per the user decision recorded in
that document, the design-reference side is satisfied by `ux/uiux-spec.md` and
this is recorded once per story as deferred, not re-opened. Closing it requires
a change in the separate bundle source repo.

### DEF-2 — asymmetric page gutter at ≤394px, inherited from the design

Below 394px the roster's `minmax(330px,1fr)` track exceeds the section content
box (`viewport − 2×32`), so the right gutter shrinks (~13px at 375) while the
left stays at 32px. Confirmed on the 375 full-page capture: nothing is clipped
and the document does not scroll horizontally, so AC-7 holds at its declared
375px floor. Reproducing `minmax(330px,1fr)` verbatim is what UI-Fidelity-AC and
BR-2 require; changing it is a design decision, not a page-body one. Carried
forward unchanged from the previous pass.

### DEF-3 — `test-results.md` §4 overflow assertion is structurally weak

The recorded check is `documentElement.scrollWidth === clientWidth`. The shell
sets `overflow-x:hidden` (`SiteLayout.astro:34`), which makes that comparison
true even when a child overhangs, so it cannot detect the DEF-2 class of issue.
Not blocking here — the rendered measurement independently confirms the page is
clean at 375 — but the assertion should not be reused as the overflow gate for
later REQ-006 page stories.

### DEF-4 — shell header clips the language toggle and CTA at 375px

At 375 the header renders logo + mobile `<select>` + theme button only; the
VI/EN group and the `Tải app` CTA overflow and are hidden by the shell's
`overflow-x:hidden`. STORY-001's own `implemented-home-375.png` shows the
identical behaviour, and this story touches no shell file, so it is pre-existing
and not made worse here. Worth routing as a shell-level follow-up because it
affects every REQ-006 page equally.

### DEF-5 — the reserved web port is shared across parallel story worktrees, and a render silently captured the wrong build

Operational, and material to the rest of this wave. `app_render.base_url` pins
the single reserved `DEVSTACK_PORT_WEB` (21021). During this review that port
was held by a *different* parallel story worktree's preview server
(`...-STORY-006`, confirmed with `lsof -a -p <pid> -d cwd`).
`render-running-app.js` correctly reported `reusing already-running server` and
produced three screenshots — of the other worktree's build. They looked
plausible (correct header, correct footer, `Pet` selected in the nav) and were
only caught because the page body was empty. A story whose page body happened to
be non-empty would have produced a confident, wrong PASS.

The captures in this story were redone on a private port after verifying both
the served HTML and the listening process's cwd. Recommendation for Scrum
Master/DevOps: give each parallel worktree its own leased render port (or have
the renderer verify the served build's identity) before any further parallel
visual-fidelity gate runs; and re-check any REQ-006 story whose visual evidence
was captured against 21021 while another worktree's server was up.

## Traceability

- Requirements: AC-1…AC-7 and UI-Fidelity-AC all PASS above; BR-1
  (presentational only — no fetch, no storage write in the diff) PASS;
  BR-2/BR-3 (verbatim copy) PASS against the uiux-spec §6.2.2/§6.2.3 tables.
- UX: `uiux-spec.md` §6.1 (shell reuse, active-state only), §6.2 (hero/roster/
  stages), §6.6 (`<main>` landmark, sprite `aria-label`, per-page title), §6.7
  (no hover-lift anti-pattern), §6.8 (measurable layout/type/colour anchors) —
  all honoured; verified in code and in the rendered captures.
- Architecture: STORY-001 shell contract honoured — `SiteLayout` used as an
  envelope with `page`/`title` props only, no shell file touched,
  `home-content.ts` unmodified, `data-vi`/`data-en` mechanism reused.
- OQ discipline: OQ-REQ006-1 and OQ-REQ006-2 are both RESOLVED; the story
  records no blocked scope and none was omitted. No OQ defect.
- Prior findings: BLK-1 CLOSED (`## Entry Point Reachability`, `Reachable: YES`,
  re-verified in code); BLK-2 CLOSED (`## Story Runtime Startup Smoke`, real run
  with pre-start probe, readiness and clean shutdown); BLK-3 CLOSED under the
  amended standard, residual recorded as DEF-1. Old DEF-1/DEF-2/DEF-3 carried
  forward as DEF-2/DEF-3 and (Design-Screen) now recorded in the
  visual-fidelity report, so the old DEF-3 is closed.

## Notes for Scrum Master

- `story_master.md` still reads `Status: PENDING` with
  `- [ ] Implementation (Development)` unchecked despite the sealed
  implementation and patch commits. Reviewer does not edit workflow state;
  flagging it so the bookkeeping is corrected at closure.
- The handoff declared `WriteScope` as the `review/` directory only. Reviewer
  additionally wrote `visual-fidelity/visual-fidelity-report.md` and the three
  `implemented-pets-*.png` captures, because 12e2 assigns the render to Reviewer
  for non-mobile UI lanes. Future reviewer handoffs for UI-bearing stories should
  declare `visual-fidelity/` in `WriteScope`.
- DEF-5 is the one item worth acting on before the next parallel review wave.

## State recommendation

- Keep `Implementation (Development)` checked
- Check `Review (Reviewer)`
- Story status: `DONE`
- Story branch is merge-eligible into
  `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-integration`

Blocking findings: 0. Deferred findings: 5.
