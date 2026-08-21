# Review Report — REQ-006 / STORY-001 Frontend App Foundation & Home Landing Page

Outcome: PATCH_REQUIRED

Review type: `full-story-review` (parallel story review)
Scope gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/review/scope-gate.md`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-001`
Diff baseline: `a648a5a1039752cb31891e657d9b47a165ba3579` (53 files)
Story: `standard` / lane `shared` / class `shared-foundation`

## Rationale

The implementation itself is strong and I found no correctness, security or
fidelity defect in the delivered code. The story does not pass only because two
mandatory evidence gates are absent from `coding-plan/test-results.md`. Both are
independently enforced by the DONE gate, so approving here would only move the
rejection later; and both are cheap for the implementation lane to supply,
because I confirmed during this review that the underlying behaviour genuinely
works. This is a bookkeeping patch, not rework.

## Blocking findings

### BLK-1 — `## Entry Point Reachability` evidence section is missing (reviewer skill 12e1)

`coding-plan/test-results.md` has no `## Entry Point Reachability` section and
no `Reachable: YES` line anywhere (verified against the file's full `##`/`###`
heading index — 6 phase headings, 52 gate headings, none of them this one). The
rule is mandatory and non-waivable for UI-facing stories.

The capability itself IS reachable — I verified it in code independently rather
than on trust:

- `web/src/pages/index.astro:9` mounts the Home body at route `/` via
  `<SiteLayout page="home">`.
- `web/src/data/site-nav.ts:29-37` lists `home` as the first nav item with
  `href: '/'` (`hrefFor('home')` returns `'/'`).
- `web/src/components/shell/SiteHeader.astro:21-29` renders that list as real
  `<a href>` elements in the desktop nav, `:31-35` as `<option>` values in the
  mobile `<select>` (navigated by the `change` handler at `:158-160`), and
  `:17` makes the logo a second `<a href="/">`.
- `web/src/data/site-nav.ts:45` repeats it as a footer link.

So this is a missing *record*, not a missing entry point.

Owner: `frontend-dev`.
Action: add `## Entry Point Reachability` to `coding-plan/test-results.md` with
`Reachable: YES` and the concrete path (header nav `Trang chủ` → `/`, plus logo
and footer `Trang chủ`).

### BLK-2 — no `## Story Runtime Startup Smoke`; P6 recorded `NOT_APPLICABLE` (reviewer skill 12g)

Registry-backed runtime startup smoke is mandatory for a non-trivial `shared`
lane story. `test-results.md:1119-1125` instead records the `web-frontend`
startup smoke as explicitly `NOT_APPLICABLE`, deferring it to the DevOps
runnable-foundation gate. `story_master.md` carries no
`Runtime-Smoke: WAIVED — <reason>` line, and `NOT_APPLICABLE` is not a pass.

The smoke does pass. While producing this review's fidelity evidence I started
the server from the registry contract (`runtimes.web-frontend.devCommand`, port
`DEVSTACK_PORT_WEB` = 21021, Node v22.17.1 for the `>=22.12.0` engine pin) and
`GET http://127.0.0.1:21021/` returned **200**, matching
`runtimes.web-frontend.readiness`. Server was torn down after. That observation
is mine, not the lane's evidence, so it does not close the gate — but it does
make this `PATCH_REQUIRED` rather than `BLOCKED`.

Owner: `devops` (or `frontend-dev`, whichever holds `test-results.md` P6).
Action: add `## Story Runtime Startup Smoke` with the registry command, the
readiness probe, the 200 result and the shutdown step — or have Scrum Master
record an explicit `Runtime-Smoke: WAIVED — <reason>` in `story_master.md`.

### BLK-3 — `/favicon.svg` 404s on all 8 pages

`web/src/layouts/SiteLayout.astro:24` emits
`<link rel="icon" href="/favicon.svg" type="image/svg+xml" />`, but `web/public/`
does not exist in the worktree and no favicon asset is in the diff. Verified
live against the running dev server: `GET /favicon.svg` → **404**.

This is self-inflicted, not a port: the design source has no `rel="icon"` and no
favicon reference at all (grep over `Cupid Web.dc.html` returns no match). Since
`SiteLayout` is the shared shell this story contracts to STORY-002..STORY-008,
the 404 would ship on all eight pages.

Owner: `frontend-dev`.
Action: add `web/public/favicon.svg`, or drop the `<link rel="icon">` line.

## Deferred findings

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

## Verified against governing inputs

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 framework foundation | PASS | Astro 6.0.5, `output: 'static'`, zero client framework (`web/package.json`, `astro.config.mjs`); resolves OQ-REQ006-1 per `architecture/solution.md` |
| AC-2 shared header | PASS | `SiteHeader.astro` — logo, 7-item desktop nav, `<select>` collapse restored at the design's own 1024/1025 boundary, theme toggle, VI/EN, `Tải app`; rendered at 375/768/1400 |
| AC-3 shared footer | PASS | `SiteFooter.astro` + `site-nav.ts:40-69`, 3 link columns + brand + copyright; visible in all three captures |
| AC-4 theme + language persistence | PASS | `theme-lang-boot.ts` (render-blocking, first child of `<body>`, try/catch per source `:686`), `SiteHeader.astro:131-146` writes `cupid-web-theme`/`cupid-web-lang`; P2 Gate 5 + P3 Gate 6 cross-route persistence |
| AC-5 nav routing, no dead links | PASS | 8 route files present; P6 build emits exactly 8 `index.html`; P3 Gate 2/3 link resolution |
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
| Frontend discoverability / navigation integration | entry-point evidence + independent code read | **FAIL (evidence) / PASS (code)** — BLK-1 |
| Local storage / persistence | boot-script correctness + cross-route assertions | PASS — P2 Gate 4 (FOUC) / Gate 5, P3 Gate 6 |
| Runtime / configuration | registry-backed startup smoke | **FAIL** — BLK-2 |
| Operational command / deploy | configuration-guide accuracy | PASS — see above |
| UI-bearing, `design_source` set, `ui_surface: true` | rendered `VISUAL_FIDELITY` verdict | PASS — `visual-fidelity/visual-fidelity-report.md` |
| Security (CI credential path) | secret hygiene in `vps-deploy-web.sh` | PASS — `StrictHostKeyChecking=yes`, pinned `UserKnownHostsFile`, `BatchMode=yes`, `umask 077` + `chmod 600`, `trap cleanup EXIT`, no secret echoed, runner-owned OpenSSH (no marketplace action in the credential path) |

## Cross-story contract note

`architecture/contract-summary.md` is accurate against the delivered code
(route keys, `share` not renamed to `/invite`, `about` serving Press kit,
`legal` serving both Privacy and Terms, the two `localStorage` keys, the
`data-vi`/`data-en` mechanism, the six sprite components). STORY-002..STORY-008
can rely on it as written — subject to BLK-3, which changes `SiteLayout.astro`
and therefore should land before consumer stories branch off this shell.

## State recommendation

- Leave `Implementation (Development)` **unchecked**.
- Leave `Review (Reviewer)` **unchecked**.
- Story status: `IN_PROGRESS`.
- Return to `frontend-dev` for BLK-1 and BLK-3, and to `devops` for BLK-2
  (or record `Runtime-Smoke: WAIVED — <reason>` in `story_master.md`).
- Re-review can be `Reviewer: completion/resume` scoped to BLK-1, BLK-2, BLK-3
  only. The visual-fidelity evidence in this run stands and does not need
  re-rendering unless `SiteLayout.astro` changes beyond the favicon line.
