# STORY-006 Test Results

Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-006`
BaseHead: `c744eaf133fc0bd92bc57bf0c1f4e37d1f371c05`

## Phase P1 — About Core Sections And Page Entry Point (2026-08-21)

### Environment

- Node: `v22.17.1` (from `~/.nvm/versions/node/v22.17.1/bin`, satisfies
  `runtime-command-registry.json` `web-frontend.engines` `>=22.12.0`; ambient
  default is `v20.20.2` and was NOT used).
- `npm install --no-audit --no-fund` was required first — the worktree had no
  `node_modules`. It added an `engines` block to `web/package-lock.json`, which
  is outside this story's WriteScope; the lockfile was restored with
  `git checkout -- web/package-lock.json` and the final tree carries no lockfile
  change.

### Commands

| Command (cwd `web/`) | Exit code |
|---|---|
| `npm run check` (`astro check`) | `0` — 32 files, 0 errors, 0 warnings, 0 hints |
| `npm run build` (`astro build`) | `0` — 8 pages built in 787ms |

### Assertions on `web/dist/about/index.html`

| Assertion | Result |
|---|---|
| `<title>` (AC-9) | `Giới thiệu &amp; Bộ nhận diện thương hiệu — Cupid` |
| `<title>` is the `'Cupid'` default | `false` |
| `<span data-vi>` count | `39` |
| `<span data-en>` count | `39` (matched pairs, no orphan) |
| Principle cards (AC-3) | `4` |
| Stat cards (AC-4) | `3` |
| `48.000+` inside a `data-vi`/`data-en` span (AC-11) | `false` |
| `31.500` inside a `data-vi`/`data-en` span (AC-11) | `false` |
| `2,1 triệu` inside a `data-vi`/`data-en` span (AC-11) | `false` |
| Callout eyebrow present in both languages (AC-5) | `true` |

### Entry point reachability (AC-1)

3 anchors in the built page resolve to `/about`:

| # | Source | `aria-current="page"` | Text (vi+en) |
|---|---|---|---|
| 0 | header desktop nav pill | `true` | `Về chúng mình` / `About` |
| 1 | footer "Company" column | `false` | `Về chúng mình` / `About` |
| 2 | footer "Press kit" link | `false` | `Press kit` (unlocalized, unchanged) |

Direct URL entry renders the same document (it is a static `index.html`).

### Shell immutability (contract-summary §6)

```
git -C <worktree> diff --stat c744eaf133fc0bd92bc57bf0c1f4e37d1f371c05 -- \
  web/src/layouts web/src/components/shell web/src/styles web/src/scripts
```

Output: empty (zero changed files). `git status --porcelain` after the lockfile
restore lists only `web/src/pages/about.astro`, `web/src/components/about/`, and
`web/src/data/about-content.ts`.

### Rendered inspection — 4 widths × 2 themes × 2 languages (16 runs)

Rendered headless Chromium (Playwright) against the built `dist/`, served by
request interception so no port was claimed (`.env.devstack` does not exist in
this worktree). `data-theme` / `data-lang` were set on `<body>` per run.

| Width | Principles grid | Stats grid | `minmax` floor | Horizontal overflow |
|---|---|---|---|---|
| 375 | 1 col / 311px | 1 col / 311px | ok (>=240 / >=200) | none |
| 768 | 2 col / 343px | 3 col / 224px | ok | none |
| 1024 | 3 col / 308px | 3 col / 309.3px | ok | none |
| 1440 | 4 col / 286.5px | 3 col / 389.3px | ok | none |

Identical at `dark` and `light` (layout is theme-independent). Language toggle:
every run showed exactly one language — `vi` runs render 17 visible `[data-vi]`
and 0 `[data-en]`; `en` runs render 0 / 17. The three stat numbers were byte
identical in all 16 runs: `["48.000+","31.500","2,1 triệu"]`.

Render-harness note: Google Fonts and Material Symbols are external and were not
loaded by the offline harness, so the screenshots show fallback faces and literal
icon ligature names. That is a harness artifact, not a page defect — the font
links live in `SiteLayout.astro` (untouched shell) and are unchanged from the
other 7 routes.

### Not decided here

- **AC-10 (visual fidelity)**: not self-certified. No rendered
  `design-reference-*.png` exists; per uiux-spec §6.8 the interim anchor is
  §6.2.1–§6.2.4's line-cited values, all of which were copied verbatim. The
  fidelity verdict belongs to the requirement UI-lane review gate with
  `design_source` and `ui_surface` configured.
- **EN `<title>`**: only the VI title ships. The site's bilingual mechanism is
  CSS visibility over `data-vi`/`data-en` spans, which cannot operate inside
  `<head>` (solution.md Key Discovery 1). Carried as a deferred finding.

**P1 verdict: PASS.**

## Phase P2 — Timeline, Team, And Press Kit (2026-08-21)

### Environment

- Node: `v22.17.1` (same pinned toolchain as P1; ambient `v20.20.2` not used).
- `web/package-lock.json` unchanged (verified again after this phase).

### Commands

| Command (cwd `web/`) | Exit code |
|---|---|
| `npm run check` (`astro check`) | `0` — 35 files, 0 errors, 0 warnings, 0 hints |
| `npm run build` (`astro build`) | `0` — 8 pages built in 600ms |

Asset bundle built with
`zip -X -q cupid-press-kit.zip cupid-lockup-dark.svg cupid-lockup-light.svg palette.txt README.txt`
(exit `0`, 4 entries, 2380 bytes uncompressed).

### Assertions on `web/dist/about/index.html`

| Assertion | Result |
|---|---|
| `<title>` unchanged from P1 | `Giới thiệu &amp; Bộ nhận diện thương hiệu — Cupid` |
| `<span data-vi>` / `<span data-en>` counts | `56` / `56` (matched pairs) |
| Timeline `<li>` (AC-6) | `5` |
| Timeline wrapper is a semantic `<ol>` | `true` |
| Team cards (AC-7) | `3` |
| Palette swatches (AC-8) | `8` |
| `id="press-kit"` on the section root | `true` |
| CTA `href` | `/press-kit/cupid-press-kit.zip` |
| CTA has `download` attribute | `true` |
| `href="#"` anywhere in the built page | `false` |
| `web/dist/press-kit/cupid-press-kit.zip` exists | `true` |
| Dark lockup has a `border:` declaration | `true` |
| Light lockup has a `border:` declaration (must be false) | `false` |
| Light lockup has a `box-shadow` (must be false) | `false` |
| `data-theme` referenced inside the press-kit markup (must be false) | `false` |

Built asset parity — `web/public/press-kit/` and `web/dist/press-kit/` both hold
`README.txt` (588B), `cupid-lockup-dark.svg` (824B), `cupid-lockup-light.svg`
(824B), `cupid-press-kit.zip` (1825B), `palette.txt` (144B).

### The two localization-format facts, asserted together (AC-11)

| Fact | Result |
|---|---|
| `48.000+`, `31.500`, `2,1 triệu` outside any `data-vi`/`data-en` span | `true` (all three) |
| Timeline entry 4 ships both `48.000 cặp đôi` (vi) and `48,000 couples` (en) | `true` |
| `Press kit`, `Dark lockup`, `Light lockup`, `Palette` unwrapped | `true` (all four) |
| `Minh Khôi`, `Linh Đàm`, `Thu Hà` unwrapped | `true` (all three) |

The 8 swatch names (`Pink`…`Cotton`) are rendered from `palette[].name`, which is
an unlocalized field — they ship as plain text by construction.

### Shell immutability (contract-summary §6)

```
git -C <worktree> diff --stat c744eaf133fc0bd92bc57bf0c1f4e37d1f371c05 -- \
  web/src/layouts web/src/components/shell web/src/styles web/src/scripts
```

Output: empty. `SiteFooter.astro` is untouched and its "Press kit" link still
resolves to `/about` (confirmed in the built page — see the AC-1 table in P1).

### Rendered inspection — 4 widths × 2 themes × 2 languages (16 runs)

7 sections present in every run. External fonts (Google Fonts + Material
Symbols) were allowed through in this pass, so the rendering uses the real
typefaces and the `favorite` glyph.

| Width | Principles | Stats | Team | Swatch row | Press-kit CTA | Overflow-X |
|---|---|---|---|---|---|---|
| 375 | 1 col / 311px | 1 col / 311px | 1 col / 311px | 1 col / 241px | wraps below headline, visible | none |
| 768 | 2 col / 343px | 3 col / 224px | 3 col / 224px | 3 col / 200.7px | inline, right-aligned | none |
| 1024 | 3 col / 308px | 3 col / 309.3px | 3 col / 309.3px | 3 col / 286px | inline | none |
| 1440 | 4 col / 286.5px | 3 col / 389.3px | 3 col / 389.3px | 3 col / 366px | inline | none |

No column drops below its `minmax` floor at any width (240px principles; 200px
stat / team / swatch). The palette grid is `repeat(4,1fr)` — a fixed 4-up grid,
not an `auto-fit` grid — so its 43.8px columns at 375px are the specified
behaviour and carry no floor.

Language: every run rendered exactly one language (34 visible `[data-vi]` and 0
`[data-en]` in vi runs; 0 / 34 in en runs). The three stat numbers were byte
identical in all 16 runs. Layout is identical between `dark` and `light`.

Screenshot note: `fullPage` captures show the light-theme backdrop only in the
first viewport height. `NebulaBackdrop` is `position:fixed;inset:0`, so this is a
full-page-screenshot artifact, not a page defect — a scrolled real viewport at
1440×900 shows the backdrop behind the press-kit section normally. No shell
change was made or needed.

### Keyboard / focus (uiux-spec §6.6)

Real `Tab` navigation (not programmatic `.focus()`) on the built page:

| Check | Result |
|---|---|
| CTA reachable by `Tab` | `true` |
| `:focus-visible` matches when tab-focused | `true` |
| Computed outline | `rgb(255, 127, 182) solid 2px`, offset `2px` |
| `Enter` triggers a download | `true` — suggested filename `cupid-press-kit.zip` |

The ring value and the `filter:brightness(1.07)` hover both mirror
`SiteHeader.astro`'s existing `.cupid-hdr-cta` treatment, per uiux-spec §6.8.

### Not decided here

- **AC-10 (visual fidelity)**: not self-certified, same as P1. No rendered
  `design-reference-*.png` exists for the `about` screen; the interim anchor is
  uiux-spec §6.2.5–§6.2.7's line-cited values, copied verbatim from
  `Cupid Web.dc.html:544-610` and `:800-812`. The verdict belongs to the
  requirement UI-lane review gate with `design_source` and `ui_surface`
  configured.

### Deferred findings raised by this story

1. **EN `<title>` undeliverable** — the site's bilingual mechanism is CSS
   visibility over `data-vi`/`data-en` spans and cannot reach `<head>`. Only the
   VI title ships. Closing this needs a shell-level `document.title` script,
   which would re-render all 8 routes (contract-summary §6) — out of scope here.
2. **Footer "Press kit" link still lands at the page top**, not at
   `#press-kit`. The anchor now exists on this page's section, but re-pointing
   the footer link is a `SiteFooter.astro` edit, which contract-summary §6
   forbids a consumer story from making (uiux-spec §6.6 discoverability flag,
   solution.md Frontend Lane guardrail).

**P2 verdict: PASS.**

## Entry Point Reachability

**Reachable: YES**

Path: `about` → `/about`

Added in the Iris-QC-8 patch pass for **BLK-2** (`review/review-report.md`). The
underlying facts were already proven in the P1/P2 sections above; BLK-2 was an
evidence-form gap, so this section restates them under the canonical rule-12e1
heading with the explicit `Reachable:` line and the concrete path. No file under
`web/` changed for this section.

Entry point definition, in source:

| Fact | Evidence |
|------|----------|
| The `about` key maps to `/about` | `web/src/data/site-nav.ts` — `{ key: 'about', href: '/about', … }` in the shared `navItems` (pre-existing from STORY-001, unchanged by this story) |
| The `/about` route exists | `web/src/pages/about.astro`; `astro build` emits `dist/about/index.html` (see the build log in the smoke section below: `├─ /about/index.html`) |
| `/about` serves the real About body | live `GET http://127.0.0.1:21021/about/` → **200** (see `## Story Runtime Startup Smoke`) |
| `about` is a first-class nav entry | `web/src/components/shell/SiteHeader.astro` renders every `navItems` entry as a desktop pill and as a mobile `<select>` option |
| Footer repeats the path twice | `SiteFooter.astro` "Company" column "About" link and the "Press kit" link, both `href="/about"` |

Measured over the built output (`web/dist`, this patch's rebuild):

- `dist/index.html` contains **3** anchors with `href="/about"` — one
  `a.cupid-hdr-nav-item` (desktop header pill) and two `a.cupid-ftr-link`
  (footer "About" and footer "Press kit"). Reachable from Home without typing a
  URL.
- `dist/index.html` mobile navigation `<select>` carries **1**
  `<option value="/about" …>`.
- `dist/about/index.html` renders the header nav item **active**:
  `<a href="/about" … aria-current="page" …>`, and its mobile `<select>` option
  for `/about` carries `selected`.
- `dist/about/index.html` contains exactly **1** `<main>` element, the
  story-specific `<title>` `Giới thiệu & Bộ nhận diện thương hiệu — Cupid`, the
  `id="press-kit"` section anchor, and the `href="/press-kit/cupid-press-kit.zip"`
  download CTA.
- Direct URL load of `/about` renders the same page — every assertion in the P1
  and P2 sections above was measured on that direct render.

PASS — reachable by desktop nav pill, by mobile `<select>`, and by two footer
links, not only by direct URL. No shell file was modified to achieve this.

Known related deferred finding, unchanged by this patch: the footer "Press kit"
link points at `/about`, not `/about#press-kit`, so it lands at the page top.
Re-pointing it is a `SiteFooter.astro` edit that contract-summary §6 forbids a
consumer story from making. This does not affect reachability of `/about`
itself.

## Story Runtime Startup Smoke

**Result: PASS** | **Shutdown: PASS**

Date: 2026-08-21. Patch pass for Iris-QC-8 finding **BLK-1** (`review/review-report.md`).
`story_master.md` carries no `Runtime-Smoke: WAIVED` line, so rule 12g applies to
this `frontend`-lane, `standard`-complexity story and a real runtime boot was
performed rather than a build-only substitute.

Scope note: `phase-P1-about-core-sections.md` and
`phase-P2-timeline-team-press-kit.md` both still record
`Startup Smoke: NOT_APPLICABLE`. That declaration is **superseded by the
measured evidence in this section**. Correcting those two lines is outside this
patch's declared WriteScope (`coding-plan/test-results.md` and
`story_master.md` only), so it is flagged here for Scrum Master rather than
edited silently. This matches the correction STORY-004 applied to its own phase
file for the same finding class.

Runtime id: `web-frontend`
(`data/devops/system/runtime-command-registry.json:120-154`): `type: frontend`,
`devCommand: npm run dev`, `port.hostPortEnv: DEVSTACK_PORT_WEB`,
`readiness: GET / expectStatus 200`, `engines.node: >=22.12.0`. `astro@6.0.5`
requires Node `>=22.12.0` and this machine's ambient default is `v20.20.2`, so
the smoke ran under nvm `v22.17.1`.

Port: **21021**, the reserved `web` role port from the registry
`sharedInfra.reservedPorts.web` — claimed via devstack, never scanned and never
Astro's default 4321.

Pre-start probe confirmed the port was free before launch:
`GET http://127.0.0.1:21021/` → `000`, `curl` exit `7` (connection refused), and
`lsof -nP -iTCP:21021 -sTCP:LISTEN` found no listener.

Commands run (`web/` as working directory):

```
$ node --version
v22.17.1
$ DEVSTACK_PORT_WEB=21021 npm run dev -- --port 21021 --host 127.0.0.1
> cupid-web@0.0.1 dev
> astro dev --port 21021 --host 127.0.0.1
22:43:06 [types] Generated 0ms
22:43:06 [WARN] [content] Content config not loaded
 astro  v6.0.5 ready in 648 ms
┃ Local    http://127.0.0.1:21021/
22:43:06 watching for file changes...
```

Readiness probe (registry `web-frontend.readiness`, `GET /` on
`DEVSTACK_PORT_WEB`, `expectStatus: 200`):

| Attempt | `GET http://127.0.0.1:21021/` |
|---|---|
| 1 | `200` — ready |

Story-route probes on the same running server:

| Request | Status |
|---|---|
| `GET http://127.0.0.1:21021/about/` | **200** |
| `GET http://127.0.0.1:21021/press-kit/cupid-press-kit.zip` | **200** |

Server-side log confirms the route serve: `22:43:06 [200] / 13ms` and
`22:43:07 [200] /about/ 4ms`.

Shutdown: sent `SIGTERM` to the `npm run dev` process; it exited within **1s**
without needing `SIGKILL` (`sigkill_needed=no`). Post-shutdown probe against the
same URL returned `000` with `curl` exit `7` (connection refused), and
`lsof -nP -iTCP:21021 -sTCP:LISTEN` found no listener (`orphan_listener=NO`) —
the port was released and no orphaned process remained.

Two dev-only log lines appeared and are not defects in this story's scope:

- `[WARN] [content] Content config not loaded` — Astro's notice that the
  workspace defines no content collections. Emitted by `astro dev` on every
  route, absent from the production build, and absent from the browser console
  (the 16 rendered runs recorded above logged zero console errors/warnings).
- `New version of Astro available: 7.2.4` — an upgrade notice from the CLI, not
  a runtime signal. The pinned `astro@6.0.5` is the version the registry
  `engines` note is written against; upgrading is not this story's scope.

This confirms the `web-frontend` local dev runtime starts on its
registry-reserved port, serves both `GET /` and this story's own `GET /about/`
with `200`, serves the new press-kit asset, and shuts down cleanly.

## Post-Patch Regression Check (2026-08-21)

The BLK-1/BLK-2 patch touched only this evidence file — zero files under `web/`
changed. Both gates were re-run on Node `v22.17.1` from `web/` after the patch to
confirm no regression:

```
$ npm run check
> astro check
Result (35 files):
- 0 errors
- 0 warnings
- 0 hints
(exit 0)

$ npm run build
> astro build
[build] output: "static"
 generating static routes
  ├─ /about/index.html (+6ms)
  ├─ /blog/index.html (+2ms)
  ├─ /legal/index.html (+1ms)
  ├─ /pets/index.html (+1ms)
  ├─ /share/index.html (+1ms)
  ├─ /support/index.html (+1ms)
  ├─ /zodiac/index.html (+1ms)
  ├─ /index.html (+2ms)
[build] 8 page(s) built in 470ms
[build] Complete!
(exit 0)
```

Identical to the P2 results (35 files / 0-0-0; 8 pages). One pre-existing
`[vite]` warning about unused re-exports inside `node_modules/astro` is emitted
by the toolchain itself and is unchanged from the P1/P2 runs.

**Patch verdict: PASS.** BLK-1 and BLK-2 closed; no code change.
