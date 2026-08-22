# Review Report — REQ-006 / STORY-002 Pet Universe Showcase Page

Outcome: BLOCKED

- Review type: `compact-story-review`, scoped re-review of the
  visual-fidelity axis only (2026-08-22). It amends the 2026-08-21
  `full-story-review` below, which remains authoritative for every other AC row
  and finding; those were not re-verified and are unchanged.
- Blocked on: BLK-VF-1 (new). Not blocked on any lane work — see the finding.
- Scope gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-002/review/scope-gate.md`
- Reviewed at: 2026-08-21, visual-fidelity axis re-reviewed 2026-08-22
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-002`
- Diff: `git diff 2e72902de51910c18ca1c6e8ca31faeedc14d823` (20 files; 5 under `web/`, +100/−2)
- Complexity `standard`, lane `frontend`, UI-bearing, `design_source` configured and locked

## Rationale (2026-08-22 re-review, visual-fidelity axis)

The `SPEC-CITED` substitution that closed the visual-fidelity axis on 2026-08-21
is abolished by the third user decision in
`REQ-006/design-fidelity-tooling-fix.md`, and the tooling blocker behind it is
resolved: `render-design-canvas.js --surface=web --screen=pets` now produces a
genuine design-reference image. The required rendered-vs-rendered comparison was
performed for the first time this pass, and **it does not match**.

The divergence was measured, not eyeballed: the pet-card sprite slot renders at
~76px in the design reference and 131px in the implementation, and the design
source declares 130px. The implementation is the side that matches the source;
the design-reference render is the side that does not honour its own markup. The
mismatch therefore cannot be closed as PASS, and equally must not be handed to
the frontend lane as a patch, because "fixing" it would move the page away from
the design source and break UI-Fidelity-AC and BR-2. It is escalated as
BLK-VF-1 for a Scrum Master / user decision.

DEF-1 from the 2026-08-21 pass is closed (the screen-specific canvas render now
exists) and replaced by BLK-VF-1. Everything else below is the 2026-08-21
`full-story-review` verbatim and was not re-verified this pass.

## Rationale (2026-08-21 full review, unchanged)

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
| UI-Fidelity-AC | **NOT CERTIFIED** (2026-08-22) | `visual-fidelity/visual-fidelity-report.md` → `VISUAL_FIDELITY: FAIL`. First genuine rendered-vs-rendered comparison: `design-reference/design-reference-pets-{375,768,1280}.png` vs `implemented/implemented-pets-{375,768,1280}.png`. Matches at 1280/768 on grid, gaps, radii, tints, type and copy; does **not** match on the sprite slot width, which cascades into a description rewrap. Measured divergence is renderer-side, not code-side — see BLK-VF-1. Supersedes the 2026-08-21 `PASS`, which rested on the now-abolished `SPEC-CITED` standard. |

## Touched risk surfaces and critical gates

| Risk surface | Gate | Result |
|---|---|---|
| Frontend static page body | `npm run check` / `npm run build` | PASS (build re-run by Reviewer) |
| Frontend discoverability / navigation integration | 12e1 `## Entry Point Reachability` + code verification | PASS — section present at `test-results.md:204` with `Reachable: YES` and the concrete path; independently verified in `site-nav.ts` and `SiteHeader.astro` |
| Design fidelity | 12e2 rendered comparison, under the 2026-08-22 standard (real canvas render required) | **NOT CERTIFIED** — three real `render-design-canvas.js` captures vs three real `render-running-app.js` captures; measured mismatch on the sprite slot. BLK-VF-1 |
| Runtime / configuration | 12g `## Story Runtime Startup Smoke` | PASS — section present at `test-results.md:244`, registry runtime `web-frontend` on reserved port 21021, `GET /` and `GET /pets/` → 200, clean SIGTERM shutdown, no orphan listener |
| Verbatim copy integrity (BR-2/BR-3) | Copy diff vs uiux-spec tables | PASS |
| Shell immutability (STORY-001 contract) | Diff path check | PASS — diff touches only the five in-scope files; no `layouts/`, `components/shell/`, `styles/`, `scripts/`, no `home-content.ts` |
| Accessibility (uiux-spec §6.6) | Sprite alt/label + `<main>` landmark | PASS — sprites carry `role="img" aria-label="<name>"`; `SiteLayout.astro:37` wraps the slot in `<main>` |

Configuration guide: the diff adds no env var, service, port, or manual setup
step, and phase metadata records `Update Required: NO`. No configuration-guide
change is owed.

## Blocking findings

### BLK-VF-1 — the design-reference render does not honour the design source's own sprite-slot size, so UI-Fidelity-AC cannot be certified either way

Severity: blocking the gate, **not** blocking the frontend lane. No patch is
requested from `frontend-dev`; acting on this belongs to Scrum Master / the
user, because the defect is in the design-reference renderer.

What was run (both exit 0, both re-run by Reviewer, nothing taken on trust):

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=web --screen=pets \
  --out=<story>/visual-fidelity/design-reference
node .ai-team-bundle/runtime/tools/render-running-app.js --route=/pets/ --label=pets \
  --breakpoints=375,768,1280 --full-page --out=<story>/visual-fidelity/implemented
```

Measured at 1280 (both renders put the first card's left edge at `x=40`; the
source declares `padding:28px` and `gap:22px`, so the sprite slot starts at
`x=68` in both and the text column's left edge yields the slot width):

| | Design reference | Implementation | Source declares |
|---|---|---|---|
| Text column left edge | `x=166` | `x=221` | — |
| Derived sprite slot width | **76px** | **131px** | **130px** |
| Bo description lines | 2 | 3 | — |

`Cupid Web.dc.html:222` declares
`<dc-import name="Bo Sprite" hint-size="130px,130px" style="width:130px;height:130px;flex:0 0 130px">`.
`PetRoster.astro:30` declares
`<div style="width:130px;height:130px;flex:0 0 130px"><Sprite size={130} /></div>`.
These are equivalent, and a browser rendering the source markup directly yields
a 130px flex item. The implementation matches the source. The canvas render does
not: it loses the declared inline size when resolving `<dc-import>` and falls
back to the sprite's natural size, and the narrowed text column then rewraps
five of the six descriptions (2→3 lines at 1280, 3→4 at 768).

Calibration against `home` — certified CLEAN in STORY-001 with a real canvas
render — is consistent with this one mechanism and not with an implementation
defect. Home puts the same import in
`<div style="height:130px;display:grid;place-items:center">`
(`Cupid Web.dc.html:169` and siblings), where a slot that collapses to its
natural size is still centred, so home is unaffected. The pets cards put it in a
flex row, where a collapsed slot displaces everything after it. That is why this
never surfaced on `home`.

Why this is not `PATCH_REQUIRED`: the only change that would make the two images
agree is shrinking the sprite slot away from the source-declared 130px, which
would itself violate UI-Fidelity-AC ("visually identical to the `isPets` block
of `Cupid Web.dc.html`") and BR-2. Why this is not `DEFERRED_ONLY`: the
2026-08-22 user decision explicitly abolished the `SPEC-CITED` substitution, so
Reviewer may not fall back to "the markup matches the spec" in place of a
rendered comparison — that is precisely the pattern the user rejected.

Recommended routing (Scrum Master / user decision, not Reviewer's to take):

1. Treat this as **Fix 3** on `design-fidelity-tooling-fix.md` — same class as
   Fix 2, in the same out-of-repo bundle tooling: `render-design-canvas.js` must
   preserve the `dc-import` element's declared inline size when it resolves the
   import. It is requirement-wide, not STORY-002-specific: every REQ-006 screen
   whose layout places a sprite in a flex row is affected.
2. Until then, decide explicitly whether UI-Fidelity-AC for the affected stories
   is certified on markup equivalence against the design source. That is a user
   decision, because it partially re-opens the standard set on 2026-08-22.

Two further design-reference render limitations found this pass, recorded so
they are not later mistaken for implementation defects:

- The 375 and 768 canvas captures are not full page (375x600 and 768x1229), so
  there is no design-reference image of the roster or stage grid at 375 and the
  768 reference is truncated. The 375 comparison could not be performed at all.
- At 375 the canvas's own header overflows horizontally. The implementation uses
  STORY-001's mobile `<select>` chrome there; this story touches no shell file.

## Deferred findings

### DEF-1 — CLOSED 2026-08-22, superseded by BLK-VF-1

The original DEF-1 recorded that `design-reference-pets-*.png` could not be
produced at all. It can now:
`design-reference/design-reference-pets-{375,768,1280}.png` are real captures in
this story's `visual-fidelity/` directory. Fix 2 in
`REQ-006/design-fidelity-tooling-fix.md` is RESOLVED. The residual risk on this
axis is now BLK-VF-1, which is a different defect in the same tool.

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

- 2026-08-22 amendment: AC-1…AC-7 stand as recorded on 2026-08-21 and were not
  re-verified. UI-Fidelity-AC is NOT CERTIFIED (BLK-VF-1); the line below is the
  2026-08-21 wording, superseded on that AC only.
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

## Notes for Scrum Master (2026-08-22 re-review)

- DEF-5 reproduced during this pass and is real, not hypothetical: the reserved
  `DEVSTACK_PORT_WEB` (21021) was held by the **STORY-003** worktree's preview
  server, and 21022 was also taken. This story's build was served on 21023 and
  the listener's cwd was confirmed as `story-...-STORY-002/web` before
  capturing. Any REQ-006 visual evidence captured against 21021 while another
  worktree's server was up should be treated as unverified.
- This worktree's `data/devops/system/design-fidelity-config.json` predates the
  Fix 1 merge and still has no `app_render` block, so
  `render-running-app.js --project=<worktree>` exits `4
  APP_RENDER_NOT_CONFIGURED`. The capture was taken by pointing the tool at a
  reviewer-local config whose `base_url` is the verified 21023 server; the tool
  reported `reusing already-running server` and started nothing. Worth syncing
  the config onto the story branches, or the next reviewer hits the same wall.
- `WriteScope` again declared only `review/review-report.md`, while the handoff
  body instructed writing `visual-fidelity/`. Reviewer wrote
  `visual-fidelity/visual-fidelity-report.md`,
  `visual-fidelity/design-reference/*.png`, and
  `visual-fidelity/implemented/*.png`. The superseded 2026-08-21 captures remain
  as the flat `visual-fidelity/implemented-pets-*.png` files and were not
  deleted.
- BLK-VF-1 needs a user decision, not a lane patch. See its "Recommended
  routing" block.

## State recommendation

- Keep `Implementation (Development)` checked
- Do **not** check `Review (Reviewer)`
- Story status: stays out of `DONE` — `Outcome: BLOCKED`
- Story branch is **not** merge-eligible into
  `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-integration`
  until BLK-VF-1 is resolved or the user rules on how UI-Fidelity-AC is
  certified while the renderer defect stands
- No `frontend-dev` handoff is recommended: no defect was found in this story's
  code this pass

Blocking findings: 1 (BLK-VF-1). Deferred findings: 4 (DEF-1 closed; DEF-2…DEF-5
carried forward unchanged).
