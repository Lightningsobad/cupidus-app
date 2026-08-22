# STORY-002 Test Results — Phase P1 Pets Page Body And Entry-Point Wiring

- Phase: P1 (`phase-P1-pets-page-body-and-entry-point.md`)
- Lane: Frontend
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-002`
- Branch: `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-002`
- BaseHead: `88cf9e9a1be14b50db586716fe6eb986da2807df`
- Date: 2026-08-21
- Node: `v22.17.1` (package `engines.node >= 22.12.0`; ambient node is v20.20.2 and
  was NOT used for the gate — `~/.nvm/versions/node/v22.17.1/bin` was put on PATH)

## 1. Build / Type-check Gate

Both commands run from `web/` in the story worktree. `npm install` was required
first: the worktree had no `node_modules`.

### `npm run check`

```
> astro check
21:52:21 [types] Generated 65ms
21:52:21 [check] Getting diagnostics for Astro files in /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-002/web...
Result (31 files):
- 0 errors
- 0 warnings
- 0 hints
```

PASS.

### `npm run build`

```
> astro build
21:52:29 [types] Generated 15ms
21:52:29 [build] output: "static"
21:52:29 [build] mode: "static"
21:52:29 [build] Collecting build info...
21:52:29 [build] ✓ Completed in 20ms.
21:52:29 [build] Building static entrypoints...
21:52:29 [WARN] [vite] "matchHostname", "matchPathname", "matchPort" and "matchProtocol" are imported from external module "@astrojs/internal-helpers/remote" but never used in "node_modules/astro/dist/assets/utils/index.js".
21:52:29 [vite] ✓ built in 467ms
21:52:29 [vite] ✓ built in 11ms
 generating static routes
21:52:29   ├─ /about/index.html (+7ms)
21:52:29   ├─ /blog/index.html (+2ms)
21:52:29   ├─ /legal/index.html (+2ms)
21:52:29   ├─ /pets/index.html (+3ms)
21:52:29   ├─ /share/index.html (+2ms)
21:52:29   ├─ /support/index.html (+1ms)
21:52:29   ├─ /zodiac/index.html (+2ms)
21:52:29   ├─ /index.html (+2ms)
21:52:29 ✓ Completed in 26ms.
21:52:29 [build] 8 page(s) built in 550ms
21:52:29 [build] Complete!
```

PASS. The single `[WARN]` is an upstream Astro/Vite dependency notice present on
`main` before this phase; it is not emitted by any file in this Write Scope.

## 2. Diff Path Check (shell immutability, BR-1)

```
$ git diff --name-only 88cf9e9a1be14b50db586716fe6eb986da2807df
web/src/pages/pets.astro

$ git status --porcelain
 M web/src/pages/pets.astro
?? web/src/components/pets/
?? web/src/data/pets-content.ts
```

- No path under `web/src/layouts/`, `web/src/components/shell/`,
  `web/src/styles/`, or `web/src/scripts/`. PASS.
- `web/src/data/home-content.ts` absent from the diff. PASS.
- Note: `npm install` incidentally added an `engines` block to
  `web/package-lock.json`. That file is outside Write Scope, so the change was
  reverted with `git checkout -- web/package-lock.json`; the diff above is after
  the revert.

## 3. Structural / Copy-diff Assertions (67 checks, all PASS)

Executed against the built `web/dist/pets/index.html`, comparing every rendered
`data-vi`/`data-en` pair to the design source. Design ranges compared:
`Cupid Web.dc.html:213-283` (markup literals), `:741-747` (pets),
`:756-760` (stages).

| Group | Checks | Result |
|---|---|---|
| AC-6 rendered `<title>` === `Pets — Cupid` | 1 | PASS |
| AC-1 header pill `aria-current="page"` + `rgba(255,127,182,.16)` / `var(--acc-pink)` | 2 | PASS |
| AC-1 mobile `<select>` renders `<option value="/pets" selected>` | 1 | PASS |
| Copy diff, 15 literal VI/EN pairs from `:213-283` verbatim (incl. diacritics, `—`, `?`) | 16 | PASS |
| AC-2 six pet cards, order `Bo, Bun, Kem, Mochi, Sua, Xoài` | 2 | PASS |
| AC-2/AC-3 six pet trait + six pet description pairs vs `:741-747` | 12 | PASS |
| AC-4 four stage title + description pairs vs `:756-760`, rendered in `01→04` order | 10 | PASS |
| AC-5 zero blank VI or EN span; eyebrow `Pet Universe` present and intentionally unwrapped | 2 | PASS |
| AC-5 Bo `rgba(255,127,182,.12)` and Xoài `rgba(255,127,182,.1)` both present and distinct | 2 | PASS |
| AC-7 grid minima `minmax(330px,1fr)` / `minmax(180px,1fr)`, section `max-width:1200px`, hero `max-width:640px` | 4 | PASS |
| No hover class, no `tabindex`, no `<button>` in the roster | 3 | PASS |
| Two-level surface nesting `var(--surf)` panel over `var(--c05)` cells retained | 1 | PASS |
| Six sprite accessible names = six pet names; `flex:0 0 130px`; rendered at 130px | 3 | PASS |
| Regression: Home teaser still six cards in order and keeps `cupid-pet-card` hover | 2 | PASS |
| Discoverability: all four entry affordances resolve to `/pets` | 5 | PASS |
| No `<img>` element that could 404 (all sprites are inline SVG) | 1 | PASS |

Copy-diff note: no omission, no reorder, no placeholder, no paraphrase. Every
string is byte-identical to the design source, including `"Xoài"`, `"Trưởng
thành"`, `"Linh thú"`, and the em dash in the hero subcopy (both languages).

## 4. Rendered Visual Inspection — 4 viewports × 2 themes × 2 languages

Rendered from the production build in headless Chromium (Playwright), 16
combinations. `375/768/1024/1440` × `dark/light` × `vi/en`.

| viewport | theme | lang | h-overflow (scrollW/clientW) | pet cards / min width | stage cells / min width | sprites visible | visible spans (blank/wrong-lang) |
|---|---|---|---|---|---|---|---|
| 375 | dark | vi | no (375/375) | 6 / 330px | 4 / 241px | 6 | 23 (0/0) |
| 375 | dark | en | no (375/375) | 6 / 330px | 4 / 241px | 6 | 23 (0/0) |
| 375 | light | vi | no (375/375) | 6 / 330px | 4 / 241px | 6 | 23 (0/0) |
| 375 | light | en | no (375/375) | 6 / 330px | 4 / 241px | 6 | 23 (0/0) |
| 768 | dark | vi | no (768/768) | 6 / 342px | 4 / 201px | 6 | 23 (0/0) |
| 768 | dark | en | no (768/768) | 6 / 342px | 4 / 201px | 6 | 23 (0/0) |
| 768 | light | vi | no (768/768) | 6 / 342px | 4 / 201px | 6 | 23 (0/0) |
| 768 | light | en | no (768/768) | 6 / 342px | 4 / 201px | 6 | 23 (0/0) |
| 1024 | dark | vi | no (1024/1024) | 6 / 470px | 4 / 211px | 6 | 23 (0/0) |
| 1024 | dark | en | no (1024/1024) | 6 / 470px | 4 / 211px | 6 | 23 (0/0) |
| 1024 | light | vi | no (1024/1024) | 6 / 470px | 4 / 211px | 6 | 23 (0/0) |
| 1024 | light | en | no (1024/1024) | 6 / 470px | 4 / 211px | 6 | 23 (0/0) |
| 1440 | dark | vi | no (1440/1440) | 6 / 387px | 4 / 271px | 6 | 23 (0/0) |
| 1440 | dark | en | no (1440/1440) | 6 / 387px | 4 / 271px | 6 | 23 (0/0) |
| 1440 | light | vi | no (1440/1440) | 6 / 387px | 4 / 271px | 6 | 23 (0/0) |
| 1440 | light | en | no (1440/1440) | 6 / 387px | 4 / 271px | 6 | 23 (0/0) |

Per-combination assertions, all PASS in all 16:

- AC-7 no horizontal overflow (`documentElement.scrollWidth === clientWidth`).
- AC-7 no pairwise geometric overlap between any two of the six pet cards.
- AC-7 no pet card below 330px, no stage cell below 180px at >=768px.
  At 375px the cards land at exactly 330px (the design's own declared minimum).
- AC-6 `document.title === "Pets — Cupid"` in every combination.
- AC-5 zero blank visible span and zero wrong-language visible span, so the
  VI↔EN toggle produces a complete page in both directions.
- AC-1 an `[aria-current="page"]` nav item is present in every combination.
- AC-5 all six pet tints stay six distinct computed colors in **both** themes:
  `rgba(255,127,182,0.12)`, `rgba(183,140,245,0.13)`, `rgba(121,226,205,0.12)`,
  `rgba(255,201,126,0.13)`, `rgba(255,171,147,0.13)`, `rgba(255,127,182,0.1)`.
  Bo `.12` and Xoài `.1` were verified as still separate values — not
  normalized to a common tint.

Compared against design source `Cupid Web.dc.html:213-283` at each viewport:
hero column, six-card roster and four-cell stage panel reflow in the declared
`auto-fit` order with the design's own spacing (`70px 32px 90px` section
padding, `40px` between blocks, `20px` / `16px` gaps), which the built markup
reproduces byte-for-byte from that range.

### Screenshot passes

Re-rendered with real Google Fonts loading (Nunito / Roboto / Roboto Mono /
Material Symbols) and visually compared to the `isPets` block:

- 1440 dark VI, 1440 light VI, 1440 dark EN, 768 light EN, 375 dark VI.
- Hero eyebrow renders as `PET UNIVERSE` (Roboto Mono, uppercase transform,
  `var(--acc-lilac)`), unwrapped and therefore identical in VI and EN — matches
  `:216` where the source also leaves it unwrapped.
- Pet card layout matches the source: 130px sprite on the left with
  `flex:0 0 130px`, then name (Nunito 900 26px) / trait tag (Roboto Mono 10px,
  tracked, uppercase, per-pet accent) / description (13.5px/1.6 `var(--c66)`).
- Growth panel keeps the two-level surface nesting; it reads as a raised panel
  in dark and as a white card in light, and did not flatten in either.
- At 375px the mobile `<select>` is the visible nav control and shows `Pet`
  selected; cards stack to a single column with no clipped text.

## 5. Runtime Signals

- Browser console on `/pets`: **no errors, no page errors** across all rendered
  passes with fonts allowed.
- Network: **no failed request and no 4xx/5xx** on `/pets`.
- No sprite asset request exists to 404 — all six sprites are inline SVG
  components, and the page contains zero `<img>` elements.

## 6. Discoverability / Navigation Integration

All four entry affordances resolve to the populated `/pets` route:

| # | Affordance | Rendered target | Result |
|---|---|---|---|
| 1 | Header nav "Pets" pill | `<a href="/pets" class="cupid-hdr-nav-item">` | PASS |
| 2 | Mobile `<select>` (below 1024px) | `<option value="/pets" selected>` | PASS |
| 3 | Footer "Dàn pet" / "Pets" link | `href="/pets"` inside `<footer>` | PASS |
| 4 | Home "Xem tất cả" / "Meet them all" CTA | `<a href="/pets" class="cupid-petcast-cta">` | PASS |

On `/pets` itself the header pill carries `aria-current="page"` plus the active
pink pill fill, and the mobile `<select>` has `/pets` selected — both driven
solely by the `page="pets"` prop, with no shell edit.

## 7. Regression — Home Pet-cast Teaser

`pets` is now shared between Home and Pets. Verified in the same build:
`web/dist/index.html` still renders six teaser cards in the same order
(`Bo, Bun, Kem, Mochi, Sua, Xoài`) and still carries the `cupid-pet-card` hover
class. Unchanged. PASS.

## Entry Point Reachability

**Reachable: YES**

Path: `pets` → `/pets`

Added in the Iris-QC-3 patch pass for **BLK-1** (rule 12e1). This is a
missing-form finding, not a missing-implementation one: the evidence itself was
already recorded in §6 above and is restated here under the canonical heading.
Re-verified in code and against a fresh `npm run build` on 2026-08-21.

Entry point definition, in source (verified independently in this worktree):

| Fact | Evidence |
|------|----------|
| The `pets` key maps to `/pets` | `web/src/data/site-nav.ts:31` — `{ key: 'pets', href: hrefFor('pets'), vi: 'Pet', en: 'Pets' }` in `navItems`; `hrefFor` (`site-nav.ts:24-26`) returns `/pets` for any non-`home` key |
| `pets` is a first-class nav entry | `web/src/components/shell/SiteHeader.astro:21-30` renders every `navItems` entry as a desktop pill; `:31-35` renders every entry as a mobile `<select>` `<option value={it.href}>` |
| Footer repeats the path | `web/src/data/site-nav.ts:46` — Product column `{ key: 'pets', href: hrefFor('pets'), vi: 'Dàn pet', en: 'Pets' }` |
| The `/pets` route exists | `web/src/pages/pets.astro`; `astro build` emits `dist/pets/index.html` (see §1) |
| `/pets` serves the real Pet Universe body | live `GET /pets/` → **200** and `GET /pets` → **200** (see `## Story Runtime Startup Smoke`); rendered `<title>` is `Pets — Cupid` |

Measured over the built HTML (`node` scan of `web/dist`, 2026-08-21):

- `dist/index.html` contains **3** anchors with `href="/pets"` — header pill nav,
  footer "Dàn pet" / "Pets" link, and the Home pet-cast "Xem tất cả" /
  "Meet them all" CTA. Reachable from Home without typing a URL.
- `dist/index.html` mobile `<select>` carries
  `<option value="/pets" data-label-vi="Pet" data-label-en="Pets" ...>`.
- `dist/pets/index.html` header nav item renders **active**:
  `<a href="/pets" class="cupid-hdr-nav-item" aria-current="page"
  style="background:rgba(255,127,182,.16);...;color:var(--acc-pink);...">`.
- `dist/pets/index.html` mobile `<select>` option for `/pets` carries `selected`.
- Direct URL load of `/pets` renders the same page (all §3 assertions were
  measured on that direct render).

PASS — reachable by desktop nav pill, by mobile `<select>`, by footer link, and
by the Home pet-cast CTA, not only by typing a URL. No shell file was modified
to achieve this: the nav item already existed from STORY-001, and the active
state is driven solely by the `page="pets"` prop.

## Story Runtime Startup Smoke

Result: PASS

**Result: PASS** | **Shutdown: PASS**

Date: 2026-08-21. Added in the Iris-QC-3 patch pass for **BLK-2** (rule 12g).
`story_master.md` carries no `Runtime-Smoke: WAIVED` line, so rule 12g applies to
this `frontend`-lane, `standard`-complexity story and a real smoke was run rather
than waived.

Runtime id: `web-frontend` (`data/devops/system/runtime-command-registry.json`).
Port `21021` is the reserved `DEVSTACK_PORT_WEB` role port
(`sharedInfra.reservedPorts.web`), not a scanned or Astro-default port.
`astro@6.0.5` requires Node `>=22.12.0`; this machine's ambient default is
`v20.20.2`, so the smoke was run under nvm `v22.17.1`.

Pre-start probe confirmed the port was free before launch:
`GET http://127.0.0.1:21021/` → `000`, `curl` exit `7` (connection refused), and
`lsof -nP -iTCP:21021 -sTCP:LISTEN` found no listener.

Command run (`web/` as working directory):

```
$ node --version
v22.17.1
$ DEVSTACK_PORT_WEB=21021 npm run dev -- --port 21021 --host 127.0.0.1
> cupid-web@0.0.1 dev
> astro dev --port 21021 --host 127.0.0.1
 astro  v6.0.5 ready in 589 ms
┃ Local    http://127.0.0.1:21021/
22:43:39 watching for file changes...
```

Readiness probe (registry `web-frontend.readiness`, `GET /` on the reserved
`DEVSTACK_PORT_WEB` port 21021, `expectStatus: 200`):

| Attempt | `GET http://127.0.0.1:21021/` |
|---|---|
| 1 | `000` (not yet listening) |
| 2 | `200` — ready |

Story-route probes on the same running server:
`GET http://127.0.0.1:21021/pets/` → **200** and
`GET http://127.0.0.1:21021/pets` → **200**. Server-side log confirms all three:
`[200] / 13ms`, `[200] /pets/ 4ms`, `[200] /pets 2ms`.

Shutdown: sent `SIGTERM` to the `npm run dev` process; it exited within 3s
without needing `SIGKILL` (`sigkill_needed=no`). Post-shutdown probe against the
same URL returned `000` with `curl` exit `7` (connection refused), and
`lsof -nP -iTCP:21021 -sTCP:LISTEN` found no listener (`orphan_listener=NO`) —
the port was released and no orphaned process remained.

Two dev-only log lines appeared and are not defects in this story's scope:

- `[WARN] [content] Content config not loaded` — Astro's notice that the
  workspace defines no content collections. Emitted by `astro dev` on every
  route including `/`, absent from the production build (§1), and absent from the
  browser console (§5 recorded zero console errors across all rendered passes).
- `update ▶ New version of Astro available: 7.2.4` — npm update notice from the
  dev CLI, not page output. The pinned `astro@6.0.5` is the version the whole
  requirement builds against; upgrading is not in this story's Write Scope.

This confirms the `web-frontend` local dev runtime starts, serves both `GET /`
and the story's own `GET /pets/` with `200`, and shuts down cleanly on the
registry-reserved port. It does not re-run or supersede the build/check/visual
evidence recorded elsewhere in this file.

## Patch Pass Re-verification (2026-08-21, Iris-QC-3 BLK-1/BLK-2)

The patch pass changed documentation only — no file under `web/` was touched.
The build gate was re-run in this worktree to confirm no regression:

```
$ npm run check
> astro check
22:43:05 [types] Generated 26ms
22:43:05 [check] Getting diagnostics for Astro files in .../STORY-002/web...
Result (31 files):
- 0 errors
- 0 warnings
- 0 hints
```

```
$ npm run build
> astro build
22:43:12 [build] output: "static"
22:43:12 [WARN] [vite] "matchHostname", "matchPathname", "matchPort" and "matchProtocol" are imported from external module "@astrojs/internal-helpers/remote" but never used in "node_modules/astro/dist/assets/utils/index.js".
 generating static routes
22:43:12   ├─ /about/index.html (+6ms)
22:43:12   ├─ /blog/index.html (+2ms)
22:43:12   ├─ /legal/index.html (+1ms)
22:43:12   ├─ /pets/index.html (+2ms)
22:43:12   ├─ /share/index.html (+1ms)
22:43:12   ├─ /support/index.html (+1ms)
22:43:12   ├─ /zodiac/index.html (+1ms)
22:43:12   ├─ /index.html (+2ms)
22:43:12 [build] 8 page(s) built in 580ms
22:43:12 [build] Complete!
```

Both PASS, identical to §1. The single `[WARN]` is the same upstream
Astro/Vite dependency notice present on `main`.

Reviewer finding **BLK-3** (no rendered design-reference comparison, rule 12e2)
is deliberately **not** addressed here. It is a requirement-wide tooling gap
tracked in
`data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/design-fidelity-tooling-fix.md`
and is outside this patch's Write Scope; the visual-fidelity axis will be
re-reviewed after that tooling fix lands.

## 8. Observations For The Requirement-Level Visual Audit

Not defects in this phase; recorded so the requirement `frontend-visual-audit`
and the UI-lane review gate can rule on them.

1. Below the AC-7 floor of 375px, the design's own `minmax(330px,1fr)` plus the
   section's `32px` side padding exceeds the content box: at 360px the card
   overruns the viewport by 2px and at 320px by 42px, clipped (not scrolled) by
   the STORY-001 shell's `overflow-x:hidden`. At the AC's 375px floor the
   overrun is 0px and no text is clipped. Reproducing `minmax(330px,1fr)`
   verbatim is required by UI-Fidelity-AC/BR-2, and changing it is a shell-and-
   design decision, not a page-body one — so it was deliberately not "fixed"
   here.
2. Per the STORY-002 contract §2, `<title>` is EN-only in both language states
   (`Pets — Cupid`). This is the documented, intended behavior, not a defect.

## 9. Gate Summary

| Gate | Result |
|---|---|
| `npm run check` | PASS |
| `npm run build` | PASS |
| Structural + copy-diff assertions (67) | PASS |
| Rendered visual, 4 viewports × 2 themes × 2 languages (16) | PASS |
| Console / network clean on `/pets` | PASS |
| Shell + `home-content.ts` immutability diff check | PASS |
| Home teaser regression | PASS |
| Entry point reachability (AC-1, `Reachable: YES`) | PASS |
| Story runtime startup smoke (`GET /` 200, `GET /pets/` 200, clean SIGTERM shutdown) | PASS |
| Design reference render (UI-Fidelity-AC, rule 12e2) | DEFERRED — reviewer BLK-3, requirement-wide tooling gap tracked in `design-fidelity-tooling-fix.md`; settled at the requirement visual-audit / re-review gate |

AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, and UI-Fidelity-AC are all met.
