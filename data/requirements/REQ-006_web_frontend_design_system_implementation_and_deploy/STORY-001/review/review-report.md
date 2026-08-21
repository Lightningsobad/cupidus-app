# Review Report — REQ-006 / STORY-001 Frontend App Foundation & Home Landing Page

Outcome: DEFERRED_ONLY

Review type: `full-story-review` (parallel story review) + scoped re-review pass
Scope gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/review/scope-gate.md`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-001`
Diff baseline: `a648a5a1039752cb31891e657d9b47a165ba3579`
Story: `standard` / lane `shared` / class `shared-foundation`

Review history:
- Pass 1 (full-story-review, worktree HEAD `b116ffc`) — `PATCH_REQUIRED`, 3 blocking / 6 deferred.
- Pass 2 (scoped re-review, worktree HEAD `ed7fb95`) — all 3 blocking findings verified closed. **This report now records `DEFERRED_ONLY`.**

## Rationale

The implementation was already sound at pass 1: no correctness, security or
fidelity defect was found in the delivered code, and the visual-fidelity gate
passed at all three breakpoints. The story failed only on two absent mandatory
evidence sections and one missing static asset. All three are now supplied and
independently re-verified at pass 2. The six deferred items carry no blocking
weight, so the story is approvable.

## Pass 2 — scoped re-review of the three blocking findings

Patches under review: `b57bc03` (frontend-dev, BLK-1 + BLK-3) and `ed7fb95`
(devops, BLK-2). Verified scope containment first: across
`b116ffc..ed7fb95` the only changed file under `web/` is `web/public/favicon.svg`
(`git diff --name-only`). `SiteLayout.astro` and every other P1-P5 source file
are byte-unchanged, so pass 1's source review, the contract summary and the
visual-fidelity evidence all stand without re-running.

### BLK-1 — `## Entry Point Reachability` — CLOSED

`coding-plan/test-results.md:1187` now carries the `## Entry Point Reachability`
H2 with `Reachable: YES` at `:1189`, the `home → /` mapping, and a per-anchor
table asserted across all 8 routes.

Re-verified independently against the running app rather than accepted on
trust — every route fetched live, counting root anchors in the served HTML:

| Route | Status | `<a href="/">` | `<option value="/">` |
|---|---|---|---|
| `/` `/pets/` `/zodiac/` `/share/` `/blog/` `/about/` `/support/` `/legal/` | 200 (8/8) | **4** each | 1 each |

The evidence claims "at least 3" distinct anchors per route; the measured count
is 4 (logo, desktop nav item, header CTA, footer Product-column link) plus the
mobile `<select>` option. The claim is accurate and conservative. The 1024/1025
nav swap creates no gap, as the section states: the logo, CTA, select and footer
paths all survive below 1025px.

### BLK-2 — `## Story Runtime Startup Smoke` — CLOSED

`coding-plan/test-results.md:1146` now carries the `## Story Runtime Startup
Smoke` H2 with `Result: PASS | Shutdown: PASS`, the registry-backed command,
the readiness probe and the shutdown probe. Critically, the patch also
**corrected the source of the gate conflict** rather than leaving it to
contradict the new section: the P6 §8 `NOT_APPLICABLE` sentence at `:1120-1125`
was rewritten to point at the new section instead of declaring the smoke
inapplicable. There is no longer a `NOT_APPLICABLE` claim for `web-frontend`
startup smoke anywhere in the file, so gate 12g3 is satisfied on substance, not
just on heading presence.

Re-verified independently: dev server started from the registry contract
(`npm run dev -- --port 21021 --host 127.0.0.1`, Node v22.17.1 for the
`>=22.12.0` engine), `GET /` → **200** ready on the 3rd poll; `SIGTERM` alone
exited it, port 21021 released within 1s with no `SIGKILL`, and the
post-shutdown probe returned `000`/connection-refused. That reproduces the
recorded result exactly, including the clean-shutdown claim.

### BLK-3 — `/favicon.svg` 404 — CLOSED

`web/public/favicon.svg` now exists (928 bytes on disk, matching the recorded
`dist/favicon.svg` size exactly). `astro.config.mjs` sets only
`output: 'static'` and does not override `publicDir`, so the default
`public/ → dist/` copy applies.

Re-verified live on the same URL that returned 404 at pass 1:
`GET /favicon.svg` → **200**, `content-type: image/svg+xml`, and
`rel="icon" href="/favicon.svg"` present on 8/8 routes with the target
resolving. The asset is a well-formed standalone SVG whose gradient
(`#FF7FB6 → #B78CF5`) and white heart mirror the `SiteHeader.astro:18` brand
mark, so the added artwork is consistent with the shell it ships in. No design
source asset existed for it; the judgment call is reasonable and is documented
in `test-results.md:1233-1265`.

## Deferred findings

None of these blocks the story. DEF-1..DEF-6 carry over from pass 1 unchanged —
no patch touched their areas. DEF-7 is new, raised by the pass-2 patch itself.

- **DEF-1 — `app_render` is not configured in `design-fidelity-config.json`.**
  The file holds only `design_source` and `ui_surface`, so
  `render-running-app.js` exits `4 APP_RENDER_NOT_CONFIGURED` and the one-command
  render path is unavailable. This review worked around it using the runtime
  registry contract plus `visual-capture.js` (both sanctioned), so it did not
  block. Configuring `app_render.{start_cmd,ready_url,base_url,breakpoints}`
  once would give STORY-002..STORY-008 the intended single-command gate.
  Owner: `devops`.
- **DEF-2 — no per-page `<title>` (needs a PO/UX call, non-blocking).** The
  design source has no `<title>` element at all, so nothing was omitted from the
  port. `SiteLayout.astro:17` already accepts a `title` prop and defaults to
  `'Cupid'`; none of the 8 route files passes one, so all 8 pages ship the same
  title. Raised as an OQ for Product Owner / UI-UX rather than a defect, exactly
  as the handoff directed. Whoever answers it should decide per-page VI/EN titles
  and whether they follow the `data-vi`/`data-en` mechanism (which cannot apply
  to `<title>`).
- **DEF-3 — `vps-deploy-web.sh:85` swap is not atomic.**
  `rm -rf current && mv incoming current` leaves a sub-second window where the
  site root does not exist. It self-heals (the health gate at `:91-103` restores
  `previous` on failure), so this is a polish item: a symlink swap
  (`ln -sfn releases/<ts> current`) would make it zero-downtime.
  Owner: `devops`.
- **DEF-4 — `ssh_exec_stdin` (`vps-deploy-web.sh:66-68`) is byte-identical to
  `ssh_exec` (`:60-62`).** `ssh` forwards stdin by default, so the second
  function adds nothing but a second place to keep the `SSH_OPTS` contract in
  sync. Harmless today.
- **DEF-5 — storage keys are duplicated as string literals in
  `theme-lang-boot.ts:12,16`** rather than imported from
  `site-nav.ts:71-72`. The file's header comment justifies it (it is inlined via
  `?raw` and must stay import-free), and `contract-summary.md` §2 pins both key
  names, so the drift risk is documented rather than latent. No change required.
- **DEF-6 — review scope exceeded the nominal `full-story-review` budget.** 53
  changed files against a nominal 12. Handled by clustering (see `scope-gate.md`)
  rather than by widening file-by-file, because the diff is one greenfield
  scaffold: a 5771-line generated lockfile, 7 near-identical 5-line route stubs
  and 6 near-identical sprite components account for most of the count. Scrum
  Master may want to route future scaffold stories as `scoped-slice` passes.
- **DEF-7 (new, documentation hygiene) — a retracted claim remains inline in the
  P2-P5 sections.** `test-results.md:1267-1286` correctly retracts the earlier
  assertion that `render-design-canvas.js` / `render-running-app.js` "do not
  exist anywhere in this repo" (they are at
  `.ai-team-bundle/runtime/tools/`, and this review used them). Adding the
  retraction was the right call and it is credited. But the false sentences are
  still present verbatim in the P2, P3, P4 and P5 sections ~500-1000 lines
  above their correction, so a reader who stops at a phase section gets the
  wrong tooling picture. Non-blocking; worth a one-line pointer at each of the
  four sites next time the file is touched. Owner: `frontend-dev`.

## Verified against governing inputs

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 framework foundation | PASS | Astro 6.0.5, `output: 'static'`, zero client framework (`web/package.json`, `astro.config.mjs`); resolves OQ-REQ006-1 per `architecture/solution.md` |
| AC-2 shared header | PASS | `SiteHeader.astro` — logo, 7-item desktop nav, `<select>` collapse restored at the design's own 1024/1025 boundary, theme toggle, VI/EN, `Tải app`; rendered at 375/768/1400 |
| AC-3 shared footer | PASS | `SiteFooter.astro` + `site-nav.ts:40-69`, 3 link columns + brand + copyright; visible in all three captures |
| AC-4 theme + language persistence | PASS | `theme-lang-boot.ts` (render-blocking, first child of `<body>`, try/catch per source `:686`), `SiteHeader.astro:131-146` writes `cupid-web-theme`/`cupid-web-lang`; P2 Gate 5 + P3 Gate 6 cross-route persistence |
| AC-5 nav routing, no dead links | PASS | 8 route files present; P6 build emits exactly 8 `index.html`; P3 Gate 2/3 link resolution; pass-2 live probe 200 on 8/8 routes |
| UI-Fidelity-AC-6 home visual fidelity | PASS | `visual-fidelity/visual-fidelity-report.md`, `VISUAL_FIDELITY: PASS`, rendered images at 375/768/1400 + full canvas |
| AC-7 copy fidelity | PASS | P5 Gate 3 (91/91 literals) + Gate 4 (37 paired `data-vi`/`data-en` spans); spot-verified against source `:110-114`, `:124-136`, `:157-192`, `:199-206` |
| AC-8 production deploy | PASS with DEF | `deploy-web.yml` + `vps-deploy-web.sh` authored and mirroring REQ-005; new secret `VPS_WEB_DEPLOY_PATH` reported by exact name; **not yet run live** — see configuration-guide check below |

### Handoff-requested spot checks against the design source

Both of Chris-FE's P5 clarifications are **confirmed correct** by direct reading
of `cupid-app-design-system/Cupid Web.dc.html`:

1. **One hero sprite, not two.** `:117-139` contains exactly one
   `<dc-import name="Bo Sprite" hint-size="170px,170px">` (`:128`). The value
   `130` appears only as the pet-card sprite *container* height at `:164`,
   `:169`, `:174`, `:179`, `:184`, `:189`. The handoff's "secondary sprite at
   130" has no counterpart in the source. Implemented as the source specifies.
2. **The 10 / 3 `style-hover` split.** The Home body block is
   `<sc-if value="{{ isHome }}">` at `:79` closing at `:211`. The file's 17
   `style-hover` attributes sit at 54, 65, 72, 95, 102, 145, 160, 163, 168, 173,
   178, 183, 188, 325, 462, 485, 669. Of the 13 cited, `:95 :102 :145 :160 :163
   :168 :173 :178 :183 :188` (10) are inside 79–211; `:325` (zodiac block
   285–385), `:462` and `:485` (blog block 453–509) are outside — exactly the 3
   Chris-FE reported. The header's own hovers (`:54 :65 :72`) are separately
   ported in `SiteHeader.astro:82-84`.

### Configuration guide (reviewer skill 12a)

`data/requirements/REQ-006_.../deployment/configuration-guide.md` exists and
matches the delivered setup. Cross-checked §1 against
`runtime-command-registry.json` `runtimes.web-frontend` (path, commands, port
`DEVSTACK_PORT_WEB`/21021, readiness, Node `>=22.12.0` pin — all agree), §2
against the `scripts/build.sh` and `scripts/start-dev.sh` diffs (agree), §5
secret list against `deploy-web.yml:70-77` (agree; exactly 6 env values, one new
`VPS_WEB_DEPLOY_PATH` reported by exact name and not invented), §6 trigger and
concurrency against `deploy-web.yml:3-15` (agree, no `paths` overlap with the
backend pipeline).

The §5 `VPS_SSH_PRIVATE_KEY` forced-command-wrapper caveat is **correctly
flagged and correctly left unfixed**: REQ-005 scoped that key's server-side
`authorized_keys` wrapper to the literal prefix `cd /var/www/backend && `, while
`vps-deploy-web.sh` prefixes `cd ${VPS_WEB_DEPLOY_PATH} && `, so the first real
run would likely be rejected server-side. It is VPS state this repository cannot
inspect, the phase was instructed not to SSH or deploy live, and both remediation
options (widen the wrapper, or provision `VPS_WEB_SSH_PRIVATE_KEY`) are recorded.
Not a review defect — it is a user/DevOps decision required **before the first
`deploy-web.yml` run**, and Scrum Master should surface it at the deploy gate.

### Touched risk surfaces and critical gates

| Risk surface | Critical gate | Result |
|---|---|---|
| Typed/generated contract (`PageKey` union, `SiteLayout` prop) | `astro check` type gate | PASS — P1/P2/P3 Gate 1-2, 0 errors over 27 files; P3 Gate 7 negative type check proves an unknown `page` is a build error |
| Frontend interaction (theme/lang toggles, hover) | build + type-check + runtime DOM assertions | PASS — P2 Gate 2 (37/37 shell assertions), P5 Gate 6 computed-style probes |
| Frontend discoverability / navigation integration | entry-point evidence + independent live probe | PASS — `test-results.md:1187`, re-verified 4 root anchors on 8/8 routes |
| Local storage / persistence | boot-script correctness + cross-route assertions | PASS — P2 Gate 4 (FOUC) / Gate 5, P3 Gate 6 |
| Runtime / configuration | registry-backed startup smoke | PASS — `test-results.md:1146`, re-verified 200 + clean SIGTERM shutdown |
| Static asset delivery | served-asset probe | PASS — `/favicon.svg` 200 `image/svg+xml`, icon link resolving on 8/8 routes |
| Operational command / deploy | configuration-guide accuracy | PASS — see above |
| UI-bearing, `design_source` set, `ui_surface: true` | rendered `VISUAL_FIDELITY` verdict | PASS — `visual-fidelity/visual-fidelity-report.md` |
| Security (CI credential path) | secret hygiene in `vps-deploy-web.sh` | PASS — `StrictHostKeyChecking=yes`, pinned `UserKnownHostsFile`, `BatchMode=yes`, `umask 077` + `chmod 600`, `trap cleanup EXIT`, no secret echoed, runner-owned OpenSSH (no marketplace action in the credential path) |

## Cross-story contract note

`architecture/contract-summary.md` is accurate against the delivered code
(route keys, `share` not renamed to `/invite`, `about` serving Press kit,
`legal` serving both Privacy and Terms, the two `localStorage` keys, the
`data-vi`/`data-en` mechanism, the six sprite components). STORY-002..STORY-008
can rely on it as written. The BLK-3 patch added `web/public/favicon.svg` only
and left `SiteLayout.astro` unchanged, so the shared shell consumer stories
inherit is exactly the one reviewed in pass 1.

## State recommendation

- `Implementation (Development)`: complete.
- `Review (Reviewer)`: complete — `Outcome: DEFERRED_ONLY`.
- Story eligible for `DONE` and for merge into
  `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-integration`,
  subject to Scrum Master's own boundary/merge steps.
- Carry DEF-1..DEF-7 forward. Two need routing outside this story before the
  requirement closes: **DEF-2** (`<title>` — needs a PO/UX decision) and the
  configuration-guide §5 `VPS_SSH_PRIVATE_KEY` scoping item plus the
  unprovisioned `VPS_WEB_DEPLOY_PATH` secret and unapplied Caddy site block,
  all of which must be settled **before the first live `deploy-web.yml` run**.
