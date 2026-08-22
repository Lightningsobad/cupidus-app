# STORY-001 Test Results

## Phase P1 — App Scaffold And Design Token Foundation

- Date: 2026-08-21
- Lane: Frontend
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-001`
- Result: PASS

### Runtime note (input for P6 / DevOps)

The scaffold resolved `astro@6.0.5`, which enforces `node >=22.12.0`. The
machine default `node` is `v20.20.2`, and Astro refuses to run on it:

```
$ npm run build          # under node v20.20.2
> astro build
Node.js v20.20.2 is not supported by Astro!
Please upgrade Node.js to a supported version: ">=22.12.0"
EXIT=1
```

All gates below were therefore run under `node v22.17.1` (already installed at
`~/.nvm/versions/node/v22.17.1`). The floor is recorded as `engines.node:
">=22.12.0"` in `web/package.json`, taken from Astro's own error message rather
than asserted from memory. P6 must pin the same floor in the CI workflow and the
runtime registry entry for `web-frontend`.

### Gate 1 — frontend build (`cd web && npm run build`)

```
> astro build
17:25:55 [types] Generated 16ms
17:25:55 [build] output: "static"
17:25:55 [build] mode: "static"
17:25:55 [build] directory: .../web/dist/
17:25:55 [build] Collecting build info...
17:25:55 [build] ✓ Completed in 19ms.
17:25:55 [build] Building static entrypoints...
17:25:55 [WARN] [vite] "matchHostname", "matchPathname", "matchPort" and "matchProtocol" are imported from external module "@astrojs/internal-helpers/remote" but never used in "node_modules/astro/dist/assets/utils/index.js".
17:25:56 [vite] ✓ built in 403ms
17:25:56 [vite] ✓ built in 3ms
17:25:56 [build] Rearranging server assets...
17:25:56 [build] ✓ Completed in 431ms.
17:25:56 [build] 0 page(s) built in 451ms
17:25:56 [build] Complete!
BUILD_EXIT=0
```

Exit code 0. `output: "static"` / `mode: "static"` confirmed. `0 page(s) built`
and an empty `dist/` are expected at P1: route files are P3's write scope, so no
HTML entrypoint exists yet. The one `[WARN]` is an unused-export notice emitted
from inside `node_modules/astro`, not from this workspace.

### Gate 2 — type check (`npx astro check`)

```
17:25:57 [types] Generated 19ms
17:25:57 [check] Getting diagnostics for Astro files in .../web...
Result (2 files):
- 0 errors
- 0 warnings
- 0 hints
CHECK_EXIT=0
```

Exit code 0.

### Gate 3 — token-parity diff (risk surface: Design token parity)

Method: split each rule body on top-level `;` (parenthesis-aware, so the
multi-stop `--nebula` gradients stay intact), then `diff` the source
declaration list against the ported one in order.

| Block | Source | Ported | Src decls | Ported decls | Order-sensitive diff |
|-------|--------|--------|-----------|--------------|----------------------|
| Dark base | `Cupid Web.dc.html:16` | `tokens.css` `body{}` | 58 | 58 | IDENTICAL |
| Light override | `Cupid Web.dc.html:17` | `tokens.css` `body[data-theme="light"]{}` | 52 | 52 | IDENTICAL |

```
== diff dark (order-sensitive, name+value) ==
IDENTICAL
== diff light (order-sensitive, name+value) ==
IDENTICAL
```

Zero missing, zero added, zero altered, zero reordered declarations in either
block. The dark block's 58 declarations are 52 custom properties plus the 6
non-custom declarations the source's `body` rule carries (`margin`,
`background`, `color`, `font-family`, `-webkit-font-smoothing`, `transition`).

Light-vs-dark custom-property name sets:

```
custom props dark: 52  light: 52
-- names in light but NOT in dark (must be empty):
-- names in dark but NOT overridden in light:
```

Both comparisons are empty: the light block overrides exactly the property-name
set the dark block defines — no more, no fewer.

### Gate 4 — no `:root` indirection, exact selectors

```
== tokens.css selectors ==
body
body[data-theme="light"]
== grep ':root' in tokens.css (must be empty) ==
grep-exit=1 (1 = no match, expected)
```

`tokens.css` contains exactly the two required selectors and no `:root` rule, so
a page with no JavaScript renders the dark theme from the bare `body` rule
(AC-2, and Key Discovery #3 in `architecture/solution.md`).

### Gate 5 — `global.css` port (risk surface: Nav breakpoint hard swap)

Byte-diff of source lines 18–27 against `global.css` (excluding the one-line
provenance comment):

```
== global.css byte-diff vs source lines 18-27 (skip provenance comment) ==
IDENTICAL
== nav media queries verbatim ==
@media (max-width:1024px)  -> 1 occurrence
@media (min-width:1025px)  -> 1 occurrence
== bilingual rules ==
3 [data-vi]/[data-en] rules
```

Both nav media queries carry the exact 1024px/1025px boundaries with no extra
breakpoint, and the three bilingual visibility rules are unchanged (AC-4,
`architecture/contract-summary.md` §3).

### Gate 6 — no client framework / CSS framework in the dependency tree

```
== direct deps ==
cupid-web@0.0.1 .../web
├── @astrojs/check@0.9.10
├── astro@6.0.5
└── typescript@5.9.3

== client/CSS framework scan over the full installed tree (expect 'not found') ==
cupid-web@0.0.1 .../web
└── (empty)
```

`npm ls react react-dom vue svelte solid-js preact tailwindcss bootstrap --all`
returned `(empty)`: none of them is present anywhere in the installed tree, not
just absent from direct dependencies. Direct dependencies are Astro and its
TypeScript tooling only. All three versions were resolved by the installer and
recorded in `web/package-lock.json`; none was hand-pinned (AC-1,
`architecture/solution.md` §6).

### Acceptance criteria status

| AC | Statement | Evidence | Status |
|----|-----------|----------|--------|
| AC-1 | `web/` builds to static HTML with no client framework in the dependency tree | Gate 1, Gate 6 | PASS |
| AC-2 | `tokens.css` selectors are exactly `body` and `body[data-theme="light"]` | Gate 4 | PASS |
| AC-3 | Every custom property in `Cupid Web.dc.html:16` exists in `tokens.css`, identical value, none added/renamed/reordered | Gate 3 | PASS |
| AC-4 | `global.css` has both nav media queries at exact boundaries and the three `[data-vi]`/`[data-en]` rules unchanged | Gate 5 | PASS |

No blockers. `DESIGN_TOKEN_PARITY_UNVERIFIABLE` did not trigger.

## Phase P2 — Global Shell

- Date: 2026-08-21
- Lane: Frontend
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-001`
- Result: PASS (37/37 shell assertions, build and type-check green)

### Gate 1 — Build and type-check

Run under `node v22.17.1` (see the P1 runtime note; the machine default
`v20.20.2` is below Astro's floor).

```
$ npm run build
17:46:34 [build] output: "static"
17:46:34 [build] 0 page(s) built in 429ms
17:46:34 [build] Complete!
BUILD_EXIT=0

$ npx astro check
Result (8 files):
- 0 errors
- 0 warnings
- 0 hints
CHECK_EXIT=0
```

`0 page(s)` is the expected P2 end state. P2 owns the shell components only;
`web/src/pages/` is P3 scope, so at the P2 boundary the project has no routes.
A temporary `web/src/pages/index.astro` harness was used to exercise the shell
in a browser for the checks below and was removed before this phase closed — it
is not in the P2 write scope and is not committed. `git status --short` at the
close of P2 shows only the four new shell directories:

```
?? web/src/components/
?? web/src/data/
?? web/src/layouts/
?? web/src/scripts/
```

### Gate 2 — Shell assertion pass (37/37)

Executed against a static file server over `web/dist/` on `127.0.0.1:22000`
(port obtained with `devstack port lease --role web --slot p2-verify
--ttl-hours 1`, never hardcoded; released at the end of the phase). The driver
is a throwaway assertion script in the session scratchpad, **not** in `web/`,
so Playwright never enters the app's dependency tree — `npm ls` in Gate 6 of
P1 still holds.

Fidelity baseline state (1440x900):

| Check | Observed |
|-------|----------|
| dark/VI body background + text | `rgb(23, 17, 41)` / `rgb(247, 238, 251)` |
| dark/VI: VI spans shown, EN hidden | `vi=inline en=none` |
| dark: theme icon is `light_mode` | `light=block dark=none` |
| dark/VI theme button `title` | `Chuyển sang Hồng mơ mộng` |
| header `position` | `sticky` |
| active nav pill background / colour / `aria-current` | `rgba(255, 127, 182, 0.16)` / `rgb(255, 127, 182)` / `page` |
| VI active in lang toggle, EN transparent | `rgb(255, 127, 182)` / `rgba(0, 0, 0, 0)` |
| body transition from source line 16 is live | `background 0.4s, color 0.4s` |
| light/EN body background | `rgb(255, 241, 247)`, `theme=light lang=en` |
| light/EN: EN spans shown, VI hidden | `vi=none en=inline` |
| light: theme icon is `dark_mode` | `light=none dark=block` |
| light/EN theme button `title` + `aria-label` | `Switch to dark` |
| EN: select `aria-label` + option text swap | `Navigation` / `"Home"` |
| lang toggle `aria-pressed` inverts | `vi=false en=true` |
| `<html lang>` follows the toggle | `en` |
| console on load and on both toggles | no errors, no warnings |

The first reading of the light background initially returned `rgb(46, 39, 62)`.
That is not a defect: it is the body mid-way through the `background 0.4s`
transition ported verbatim from source line 16 (~10% along
`#171129` -> `#FFF1F7`). The assertion now waits for the transition to settle,
which also proves the transition itself survived the port.

### Gate 3 — Nav breakpoint hard swap at 1024/1025

| Viewport | `[data-nav]` | `[data-navm]` | Expected |
|----------|--------------|---------------|----------|
| 1023px | `none` | `flex` | mobile select |
| 1024px | `none` | `flex` | mobile select |
| 1025px | `flex` | `none` | desktop pills |
| 1440px | `flex` | `none` | desktop pills |

The swap lands exactly on the source boundaries, with no viewport where both
or neither nav is visible.

**Source defect found and worked around.** The design source's own nav media
queries (`global.css` lines ported in P1) are unreachable as authored:
`[data-nav]` carries an inline `display:flex` and `[data-navm]` an inline
`display:none`, and inline declarations outrank non-`!important` stylesheet
rules. The prototype only ever renders at its declared 1440px canvas, so the
mobile branch was never exercised and the dead rules went unnoticed. Fix:
three `!important` declarations at the *identical* 1024/1025 boundaries, added
in `SiteHeader.astro`'s `<style is:global>` block. No inline style byte was
edited and P1's `global.css` was not touched (it is out of P2 write scope), so
token/style parity with the source is preserved.

### Gate 4 — FOUC

`localStorage cupid-web-theme=light` seeded before navigation, then a cold
document load. Probe reads `document.body.dataset.theme` and the computed
background inside the **first** `requestAnimationFrame` callback, i.e. before
the first paint:

```
{"theme":"light","bg":"rgb(255, 241, 247)"}
```

No dark first frame. Structural proof of why:

```
{"isFirstElementChild":true,"inline":true,"hasDefer":false,"hasAsync":false,"type":"(classic)"}
```

The boot script is an inline classic script and the first element child of
`<body>`, so it is render-blocking and runs before any shell markup is parsed.
It cannot live in `<head>` because it writes `document.body.dataset`.

### Gate 5 — Persistence

Toggle to EN, then a full `reload()`:

```
vi -> en, localStorage cupid-web-lang=en
```

The EN state survives a real document load (AC-4). Storage hygiene: after a
lang-only session the only key present is `cupid-web-lang`
(`cupid-web-theme=null`) — an untouched toggle writes nothing, so the dark
default stays a genuine no-JS default rather than stored state.

### Gate 6 — Keyboard and focus

Desktop (1440px) tab order, 22 stops, all reached in visual order:

```
favorite Cupid > Trang chủ > Pet > Hoàng đạo > Ghép đôi > Blog > Về chúng mình
> Hỗ trợ > [theme] > VI > EN > Tải app > Trang chủ > Dàn pet > Hoàng đạo
> Ghép đôi > Blog > Về chúng mình > Press kit > Hỗ trợ > Quyền riêng tư
> Điều khoản
```

That is 1 logo + 7 nav pills + 1 theme button + 2 language buttons + 1 CTA +
10 footer links. The mobile `<select>` is correctly absent from the desktop
order because it is `display:none`. Every one of the 22 stops has a visible
ring (`2px solid rgb(255, 127, 182)`); none was missing.

At 1024px the relationship inverts as intended: the tab order is
`a > select[data-navm]` — the `<select>` is a tab stop and the hidden desktop
pills are not.

### Gate 7 — Hover rules beating inline styles

| Source line | Element | Before hover | After hover |
|-------------|---------|--------------|-------------|
| :54 | nav item | `rgba(0,0,0,0)` / `rgba(247,238,251,.68)` | `rgba(247,238,251,.09)` / `rgb(255,255,255)` |
| :65 | theme button border | `rgba(247,238,251,.1)` | `rgba(255,127,182,.5)` |
| :72 | CTA | — | `brightness(1.07)` |
| :669 | footer link | `rgba(247,238,251,.62)` | `rgb(255,127,182)` |

**Correction to the phase brief's hover count.** The phase file states "The
source contains 17 such attributes across the file". That total is correct —
`style-hover` appears on source lines 54, 65, 72, 95, 102, 145, 160, 163, 168,
173, 178, 183, 188, 325, 462, 485, 669 — but only **4** of them fall inside
P2's shell ranges (54, 65, 72 in the header; 669 in the footer). The other 13
(95 through 485) are all inside the Home page body, which is P5 scope. P2's
hover-rule target is therefore 4/4, not 17/17; the remaining 13 belong to P5.
Reviewer should not expect 17 `:hover` rules in the shell.

Because inline styles outrank stylesheet rules, each ported `:hover` that
overrides an inline declaration carries `!important`. `.cupid-hdr-cta:hover`
does not, since `filter` is not set inline.

### Gate 8 — Font and route contract

- All 4 `href` values from source lines 11-14 (2 `preconnect` + 2 stylesheet)
  are byte-identical in the built HTML, including `display=block` on Material
  Symbols and `display=swap` on the text faces. Both `preconnect` hints
  survive.
- All 19 shell `<a>` elements resolve to the 8 contract routes and nothing
  else: `/ /pets /zodiac /share /blog /about /support /legal`. All 7 mobile
  `<option value>` entries likewise.
- `/legal` is reachable from the footer (2 links) and never from the header
  nav, matching `site-nav.ts` where `legal` is deliberately absent from
  `navItems`.

### Visual-fidelity note (for the Reviewer gate)

A rendered "design comp vs built app" capture **pair** cannot be produced for
this story, and this is a property of the source, not a gap in this phase:
`cupid-app-design-system/Cupid Web.dc.html` is not runnable HTML. It is a
design-comp DSL export containing `{{ expr }}` interpolation, `<sc-for>`,
`<sc-if>`, `<dc-import>`, `<x-dc>`, and a `DCLogic` class (recorded as Key
Discovery #1 in `architecture/solution.md`). No browser can render it, so
there is no "design side" image to diff against.

The substitute evidence is stronger than a pixel diff for this phase: a
byte-level comparison of every ported inline style against the source lines,
plus the 37 computed-style assertions above, which read the *resolved* values
the browser actually applies.

Separately, an attempt to capture built-app screenshots was blocked by
`guard-visual-live-runtime.sh` [LIVE_RUNTIME_DRIVE], which requires screenshots
to be produced by `render-running-app.js`. That script does not exist anywhere
in this repository — the same missing-tooling class already tracked for
`render-design-canvas.js` and the blank `design_source.entry` in
`design-fidelity-config.json`. Both are Scrum-Master-owned blockers for the
Reviewer visual-fidelity gate, not for this phase; the verification above is
assertion-based and needs no image capture.

### Acceptance criteria status

Ids below are the story-level ACs from `requirements/requirements.md` §
Acceptance Criteria.

| AC | Statement (abbreviated) | Evidence | Status |
|----|-------------------------|----------|--------|
| AC-2 | Sticky header: logo, desktop nav, mobile select at the design breakpoint, theme toggle, VI/EN toggle, CTA | Gate 2 (sticky, pills, toggles, CTA), Gate 3 (breakpoint), Gate 6 | PASS |
| AC-3 | Footer: brand block, link columns, copyright line | Gate 2, Gate 6 (10 footer links), Gate 8 | PASS |
| AC-4 | Theme + language persist; all four dark/light x VI/EN combinations working, none gated | Gate 2 (all four combos asserted), Gate 4, Gate 5 | PASS |
| AC-5 | Nav items for all 8 pages link to a route that does not 404 | Gate 8 — all 19 `<a>` and all 7 `<option value>` resolve to the 8 contract routes | PARTIAL — link targets are correct and exhaustive; whether they 404 depends on `web/src/pages/`, which is P3 scope. Re-assert in P3. |
| AC-7 | Shared chrome copy matches the source's literal VI and EN strings | Gate 2 (both locales rendered from the ported paired spans; no paraphrase — strings are verbatim ports) | PASS for the shell; Home-page copy is P5 |

`UI-Fidelity-AC-6` is Home-page fidelity and belongs to P5, not this phase.
AC-1 was closed in P1; AC-8 is P6.

No blockers for P2. Shell contract (`architecture/contract-summary.md` §1-§3)
is published for STORY-002..008: `SiteLayout` `Props { page: PageKey; title?:
string; description?: string }`, the 8-key `PageKey` union, `hrefFor()`, and
the `cupid-web-theme` / `cupid-web-lang` storage keys.

## Phase P3 — Route Map And Entry Point

- Date: 2026-08-21
- Lane: Frontend
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-001`
- Result: PASS (14/14 route assertions, build and type-check green)

### Gate 1 — Build and type-check

Run under `node v22.17.1`.

```
$ npm run build
17:56:44 [build] output: "static"
 generating static routes
17:56:44   ├─ /about/index.html (+5ms)
17:56:44   ├─ /blog/index.html (+2ms)
17:56:44   ├─ /legal/index.html (+1ms)
17:56:44   ├─ /pets/index.html (+1ms)
17:56:44   ├─ /share/index.html (+1ms)
17:56:44   ├─ /support/index.html (+1ms)
17:56:44   ├─ /zodiac/index.html (+1ms)
17:56:44   ├─ /index.html (+2ms)
17:56:44 [build] 8 page(s) built in 489ms
17:56:44 [build] Complete!
BUILD_EXIT=0

$ npx astro check
Result (16 files):
- 0 errors
- 0 warnings
- 0 hints
CHECK_EXIT=0
```

### Gate 2 — Build output contains exactly the eight expected HTML files

```
dist/index.html
dist/about/index.html
dist/blog/index.html
dist/legal/index.html
dist/pets/index.html
dist/share/index.html
dist/support/index.html
dist/zodiac/index.html
```

8 files, no extras, none missing.

### Gate 3 — Link resolution

Every `<a href>` and every mobile `<option value>` on every route, enumerated
from the built HTML and matched against the emitted file set:

| Route | `<a>` hrefs | Distinct targets | `<option>` values | Unresolved |
|-------|-------------|------------------|-------------------|------------|
| `/` | 19 | 8 | 7 | 0 |
| `/pets` | 19 | 8 | 7 | 0 |
| `/zodiac` | 19 | 8 | 7 | 0 |
| `/share` | 19 | 8 | 7 | 0 |
| `/blog` | 19 | 8 | 7 | 0 |
| `/about` | 19 | 8 | 7 | 0 |
| `/support` | 19 | 8 | 7 | 0 |
| `/legal` | 19 | 8 | 7 | 0 |

**208 link targets checked, zero unresolved.** All 8 routes also direct-load
over HTTP:

```
/=200 /pets=200 /zodiac=200 /share=200 /blog=200 /about=200 /support=200 /legal=200
```

### Gate 4 — Active-nav state per route (substitutes for the screenshot check)

`## 6 Test Scope` asks for "active-nav state captured on two routes (one header
route, plus `/legal` reached from the footer)". No rendered screenshot is
possible here: `guard-visual-live-runtime.sh` [LIVE_RUNTIME_DRIVE] requires
`render-running-app.js`, which does not exist in this repository (the same
missing-tooling item recorded in the P2 section and tracked at Scrum Master
level). **Substitution, recorded explicitly rather than skipped:** the check was
performed as a markup assertion over the built HTML for *all eight* routes
rather than a capture of two, which is a strictly wider check than the phase
asked for.

| Route | header `aria-current="page"` | mobile `<option selected>` |
|-------|------------------------------|----------------------------|
| `/` | `/` | `/` |
| `/pets` | `/pets` | `/pets` |
| `/zodiac` | `/zodiac` | `/zodiac` |
| `/share` | `/share` | `/share` |
| `/blog` | `/blog` | `/blog` |
| `/about` | `/about` | `/about` |
| `/support` | `/support` | `/support` |
| `/legal` | (none) | (none) |

Exactly one active pill and one selected option per header route. `/legal`
correctly has neither, because it is not a header nav item — the active state
follows the `page` prop, and `legal` is absent from `navItems`.

The active pill is not only an attribute: at runtime it also carries the
source's active styling, verified in the P2 section Gate 2
(`background: rgba(255, 127, 182, 0.16)`, `color: rgb(255, 127, 182)`).

### Gate 5 — Empty bodies and shell stability

- All 8 `<main>` elements are genuinely empty. No placeholder heading, no
  "coming soon" copy, no skeleton, no redirect. Home is empty here too and is
  filled by P5.
- No per-page `<title>` was invented. The design source has no `<title>` at all
  (`Cupid Web.dc.html:3-7`), so every route uses `SiteLayout`'s default
  `Cupid`. Adding "Pets — Cupid" style titles would be copy the source does not
  contain; that is a Product Owner / UX decision, not a P3 one. Flagged rather
  than silently invented.
- Footer markup is byte-identical across all 8 routes (no shell drift).

### Gate 6 — Cross-route persistence

Set light + EN on `/`, then navigate using the real navigation surfaces — a
header link click and a footer link click, not a scripted `goto`:

| Step | Route | theme | lang | body background | active pill |
|------|-------|-------|------|-----------------|-------------|
| set state | `/` | `light` | `en` | `rgb(255, 241, 247)` | `/` |
| click header "Pets" | `/pets` | `light` | `en` | `rgb(255, 241, 247)` | `/pets` |
| click footer "Privacy" | `/legal` | `light` | `en` | `rgb(255, 241, 247)` | none (correct) |

On `/legal` the EN spans are visible and the VI spans hidden, confirming the
language survived two document loads. Browser console clean across all three
loads: no errors, no warnings.

Mobile `<select>` at 1024px navigates correctly and reflects the landed route:
`{"url":"/zodiac/","selected":"/zodiac"}`.

### Gate 7 — Negative type check

A page passing an invalid `page` value must fail `astro check`. `legal.astro`
was temporarily set to `page="privacy-and-terms"`:

```
src/pages/legal.astro:6:13 - error ts(2322): Type '"privacy-and-terms"' is not assignable to type 'PageKey'.
6 <SiteLayout page="privacy-and-terms" />
              ~~~~
Result (16 files):
- 1 error
NEGATIVE_CHECK_EXIT=1
```

Reverted immediately; the build and check above were re-run after the revert
and are both exit 0. Note for the Reviewer: `astro build` alone does **not**
catch this — Astro does not type-check during build. `npx astro check` is the
gate that enforces the `PageKey` union, so it must stay in CI (P6 input).

### Finding for P6 / DevOps — extensionless URLs

Astro's default `build.format: 'directory'` emits `/pets/index.html` while the
shell's hrefs are extensionless (`/pets`). A bare static file server answers
the extensionless form with a 301 to the trailing-slash form:

```
/=200 /pets=301 /zodiac=301 /share=301 /blog=301 /about=301 /support=301 /legal=301
```

That is correct and expected, but it means the production host for
`cupidus.app` must resolve a directory index (e.g. nginx
`try_files $uri $uri/index.html $uri/ =404`). If it does not, all seven
non-Home routes 404 in production while passing every check here. Reported as a
P6 input, not fixed in P3 — web server configuration is DevOps scope.

### Acceptance criteria status

| AC | Statement (abbreviated) | Evidence | Status |
|----|-------------------------|----------|--------|
| AC-5 | Nav items for all 8 pages link to a route that does not 404 | Gate 2 (8 files emitted), Gate 3 (208 targets, 0 unresolved, all 200), Gate 4 | PASS — the P2 `PARTIAL` on this AC is now closed |
| AC-2 | Header follows the current route on every page | Gate 4 (active pill + selected option on all 8) | PASS |
| AC-3 | Footer renders on every page | Gate 5 (footer byte-identical across all 8 routes) | PASS |
| AC-4 | Theme + language persist across navigation | Gate 6 (survive two real document loads via header and footer links) | PASS |

Phase-level AC from `phase-P3` §4, all met: 8 HTML files emitted; every header
item, logo, CTA and footer link resolves; correct nav item active with
`aria-current="page"` on each route; theme and language survive navigation; an
unknown `page` value fails `astro check`.

No blockers for P3.

---

## Phase P4 — Pet Sprite Components

Run on 2026-08-21, worktree
`story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-001`,
BaseHead `30ddba64d2dd915cb9156cbf33bb9a0545b0cdd2`, node `v22.17.1`.

Six components created, one per pet, each ported from the default
`state="happy"` `<sc-if>` branch of its `.dc.html` source:

| Component | Source file | Default branch | Source id | Namespaced id |
|-----------|-------------|----------------|-----------|---------------|
| `web/src/components/sprites/BoSprite.astro` | `Bo Sprite.dc.html` | lines 20-42 | `boFurA` | `cupid-bo-fur` |
| `web/src/components/sprites/BunSprite.astro` | `Bun Sprite.dc.html` | lines 19-40 | `bsFurA` | `cupid-bun-fur` |
| `web/src/components/sprites/KemSprite.astro` | `Kem Sprite.dc.html` | lines 19-40 | `keFurA` | `cupid-kem-fur` |
| `web/src/components/sprites/MochiSprite.astro` | `Mochi Sprite.dc.html` | lines 19-41 | `moFurA` | `cupid-mochi-fur` |
| `web/src/components/sprites/SuaSprite.astro` | `Sua Sprite.dc.html` | lines 19-42 | `ssFurA` | `cupid-sua-fur` |
| `web/src/components/sprites/XoaiSprite.astro` | `Xoai Sprite.dc.html` | lines 20-40 | `xoFurA` | `cupid-xoai-fur` |

All six `.dc.html` sources declare `"default":"happy"` in their
`data-props` enum, so `isHappy` is unambiguously the default state in each.

### Gate 1 — Build

`cd web && npm run build` → exit 0. 8 page(s) built in 514ms. Page count is
unchanged from P3 (sprites are components, not routes) and no build warning
was introduced by them.

### Gate 2 — Type check

`npx astro check` → exit 0. Result (22 files): 0 errors, 0 warnings, 0 hints.
File count rose 16 → 22: the six new sprite components.

### Gate 3 — Markup/attribute equivalence vs design source (substituted check)

**Substitution recorded per handoff instruction.** The phase's Test Scope asks
for a "per-sprite capture pair (design source vs component)" and an "all-six
capture". Those cannot be produced here: `render-design-canvas.js` and
`render-running-app.js` do not exist anywhere in this repo, and the `.dc.html`
sources are design-comp DSL exports (`<sc-if>`, `{{ expr }}`, `<helmet>`,
`DCLogic`), not runnable HTML — so there is no "design side" to screenshot.
This is the same gap flagged after P2 and P3 and is tracked at Scrum Master
level (checkpoint BLOCKER 2). Per the handoff, a markup/attribute equivalence
check was run instead of skipping or blocking.

Harness: `sprite-assertions.mjs` (scratchpad, not committed) — 106 assertions,
**106 passed, 0 failed**. Per sprite it asserts:

| Assertion | Bo | Bun | Kem | Mochi | Sua | Xoài |
|-----------|----|-----|-----|-------|-----|------|
| SVG subtree byte-identical to source default state after un-namespacing the id and de-indenting | PASS | PASS | PASS | PASS | PASS | PASS |
| `viewBox` preserved (`0 0 200 200` for all six) | PASS | PASS | PASS | PASS | PASS | PASS |
| every path `d=` value preserved (count) | 9 | 12 | 6 | 7 | 8 | 10 |
| every `fill`/`stroke`/`stroke-width`/`stroke-linecap`/`stroke-linejoin`/`opacity`/`transform` attr preserved (count) | 41 | 49 | 34 | 35 | 41 | 40 |
| `transform-origin` values preserved (count) | 1 | 0 | 0 | 0 | 0 | 2 |
| `animation:` shorthand declarations preserved (count) | 4 | 3 | 3 | 3 | 3 | 5 |
| every `@keyframes` copied verbatim from the source `<helmet><style>` | PASS | PASS | PASS | PASS | PASS | PASS |
| every `animation-name` used resolves to a `@keyframes` in the same file | PASS | PASS | PASS | PASS | PASS | PASS |
| accessible name is the pet name (`role="img"` + `aria-label`) | PASS | PASS | PASS | PASS | PASS | PASS |
| size accepted as a prop, 120px default | PASS | PASS | PASS | PASS | PASS | PASS |
| no file imported or copied from `cupid-app-design-system/` | PASS | PASS | PASS | PASS | PASS | PASS |

The byte-identity assertion is the strongest form available: it takes the
component's `<svg>…</svg>` subtree, substitutes the namespaced id back to the
source id, strips per-line indentation, and requires an exact string match
against the source's default-branch `<svg>` subtree. It passes for all six, so
the **only** intentional difference between source and component markup is the
id rename.

### Gate 4 — SVG id collision

Required check: "id-collision grep across the six files must return none."

All six ids across the six components: `cupid-bo-fur`, `cupid-bun-fur`,
`cupid-kem-fur`, `cupid-mochi-fur`, `cupid-sua-fur`, `cupid-xoai-fur` —
**6 ids, 0 duplicates**. Every generic source id (`boFurA`, `bsFurA`,
`keFurA`, `moFurA`, `ssFurA`, `xoFurA`) is absent from every component's SVG.

Keyframe names were checked for the same class of collision, since they share
one global namespace too: 14 names (`boBob`, `boDrift`, `boWag`, `bunBob`,
`bunDrift`, `keBob`, `keDrift`, `moBob`, `moDrift`, `suaBob`, `suaDrift`,
`xoBob`, `xoDrift`, `xoFlap`) — **0 duplicates**.

### Gate 5 — `url(#...)` resolution

Required check: "each `url(#...)` resolves to an id defined in the same file."
Six references, one per sprite, each `fill="url(#cupid-<pet>-fur)"` pointing at
the `<linearGradient>` in its own `<defs>`. **6/6 resolve in-file.**

Also verified in the live DOM (Gate 6) rather than only statically.

### Gate 6 — Runtime DOM verification (all six on one page)

A temporary route `web/src/pages/p4-sprite-check.astro` rendered all six
sprites in one container plus Bo at 120/130/170px. Built, served on devstack
lease `DEVSTACK_LEASE_PREVIEW=22000`, asserted with `sprite-runtime.mjs`
(scratchpad, not committed) — **17 passed, 0 failed** — then the temporary
route was deleted and the site rebuilt clean (8 pages).

| # | Check | Result |
|---|-------|--------|
| 1 | All six sprites render together on one page | PASS (6 wrappers) |
| 2 | Accessible name exposed per sprite, in order Bo/Bun/Kem/Mochi/Sua/Xoài | PASS |
| 3 | Each wrapper exposes `role="img"` | PASS |
| 4 | Every `url(#…)` resolves against the live DOM (6 refs) | PASS |
| 5 | No cross-sprite bleed: each referenced paint server lives inside its own `<svg>` | PASS |
| 6 | No duplicate SVG ids with all six on one page | PASS |
| 7 | Each gradient-filled body paints a non-zero box (a missing paint server would render it transparent) | PASS |
| 8 | Idle animation live at source timing: Bo/Bun/Kem/Mochi/Sua 3200ms, Xoài 3000ms | PASS (6/6, read from `getAnimations()`) |
| 9 | Nested animated elements resolve their keyframes: `boWag`×1, `xoFlap`×2, `*Drift`×2 each | PASS |
| 10 | Size prop renders 120/130/170px square | PASS |
| 11 | `<svg>` fills its wrapper at every size (aspect ratio held, no clipping) | PASS |
| 12 | Default size is the pet-cast grid's 120px | PASS |

Check 8 is the one that matters most for the `is:global` decision below: if a
keyframe name were unreachable from the inline `style` attribute,
`getAnimations()` would return no `CSSAnimation` for that element. It returns
one per sprite, at exactly the source duration.

### Deviations and decisions

1. **Keyframes live in `<style is:global>`, not a scoped `<style>`.** The phase
   file says "copy each sprite file's `@keyframes` … into the component's
   scoped `<style>` block". Scoped was not usable: every `animation:`
   declaration in these sprites sits in an **inline `style` attribute** on an
   SVG element (that is what "verbatim markup/styles" requires), and Astro's
   scoped-style transform never rewrites inline style attributes — so a scoped
   keyframe name could not be referenced from there. `is:global` is also the
   faithful port: the source keeps these in `<helmet><style>`, a document-level
   block. Safe because the 14 keyframe names are already globally unique
   (Gate 4), which is exactly the property the source relies on. Verified live
   in Gate 6 check 8.
2. **Only the keyframes the default state actually uses were ported.** Each
   source file also declares a `*Zzz` keyframe used solely by its `isSleep`
   branch (`boZzz`, `bunZzz`, `keZzz`, `moZzz`, `suaZzz`, `xoZzz`). Since P4
   ports the default state only, shipping those would be dead CSS on every
   page. The ported ones are byte-identical to the source declarations
   (Gate 3). If a later story ports the non-default states, it re-adds them.
3. **Capture-pair visual check substituted** by the markup/attribute
   equivalence check — see Gate 3. Recorded here per explicit handoff
   instruction; not skipped, not treated as a blocker.
4. **Accessible name is on the wrapper, not the `<svg>`.** `role="img"` +
   `aria-label` sit on the wrapper `<div>` so the `<svg>` subtree stays
   byte-identical to the source (Gate 3). `uiux-spec` §6.6 requires "meaningful
   `alt` text (pet name), not empty/decorative alt"; for inline SVG the
   equivalent is `role="img"` + accessible name, which Gate 6 checks 2-3 verify.
5. **`Xoài` carries its diacritic in the accessible name**, matching the pet
   name in `uiux-spec` §6.2.3 and the handoff. The component file is
   `XoaiSprite.astro` (ASCII) as named in the phase Write Scope and in
   `architecture/contract-summary.md` §4.

### Note for P5 and consumer stories

Rendering the *same* sprite twice on one page (the Home hero uses Bo at 170px
and the pet-cast grid uses Bo at 120px, per `uiux-spec` §6.2.1/§6.2.3) emits
the id `cupid-bo-fur` twice. That is harmless: the duplicated `<linearGradient>`
definitions are identical, so whichever one the browser resolves paints the
same result. Demonstrated in Gate 6 — the `#sizes` block rendered three Bo
instances at 120/130/170px and all three painted correctly (checks 10-11). No
per-instance id generator was added; it would break the byte-identity property
in Gate 3 for no visual gain.

### Acceptance criteria status

| AC | Statement (abbreviated) | Evidence | Status |
|----|-------------------------|----------|--------|
| Phase AC 1 | Each sprite renders identically to its design source at 120/130/170px | Gate 3 (byte-identical markup), Gate 6 checks 10-11 | PASS via substituted check (Gate 3 rationale) |
| Phase AC 2 | All six render together with no gradient/filter/clip-path bleeding | Gate 4, Gate 5, Gate 6 checks 4-7 | PASS |
| Phase AC 3 | Idle animation matches the source keyframe timing | Gate 3 (keyframes verbatim), Gate 6 checks 8-9 | PASS |
| Phase AC 4 | Accessible name exposed using the pet name | Gate 3, Gate 6 checks 2-3 | PASS |

Story-level ACs: P4 contributes no independent AC closure. It supplies the
sprite components that UI-Fidelity-AC-6 (Home page visual fidelity) will be
judged on in P5; that AC stays open until P5 and the UI-lane review gate.

No blockers for P4. The two pre-existing Reviewer-only blockers
(`design_source.entry` empty; `render-design-canvas.js` absent) are unchanged
and still do not gate implementation.

## Phase P5 — Home page body

Date: 2026-08-21. Node v22.17.1 (`astro@6.0.5` requires >=22.12.0; the machine
default v20.20.2 is too old — see the P6 carry-forward note in P1).

### Files produced

| File | Source of truth |
|------|-----------------|
| `web/src/components/home/Hero.astro` | `Cupid Web.dc.html` :80-140 |
| `web/src/components/home/FeatureGrid.astro` | `Cupid Web.dc.html` :142-152 |
| `web/src/components/home/PetCast.astro` | `Cupid Web.dc.html` :154-194 |
| `web/src/components/home/HowItWorks.astro` | `Cupid Web.dc.html` :196-210 |
| `web/src/data/home-content.ts` | `Cupid Web.dc.html` :734-754 |
| `web/src/pages/index.astro` | body wiring into the P2 `SiteLayout` |

### Gate 1 — build

`npm run build` → exit 0, 8 page(s) built in 574ms, output `static`, no errors.
The Home route is emitted as `dist/index.html`; the other 7 routes from P3 are
unchanged.

### Gate 2 — type check

`npx astro check` → 27 files, **0 errors / 0 warnings / 0 hints**. (File count
rose 22 → 27: the four new Home components plus `home-content.ts`.) `astro
build` alone does not type-check, so this gate stays separate — repeated for
P6/CI.

### Gate 3 — markup / style-attribute equivalence (substituted check)

**Substitution recorded explicitly.** The phase file's Test Scope asks for
per-section capture pairs, full-page pairs at theme/lang combos, and viewport
captures at 375/768/1024/1025/1440. Those cannot be produced: the "design side"
of a capture pair would have to come from `render-design-canvas.js`, which does
not exist anywhere in this repo, and `Cupid Web.dc.html` is a design-comp DSL
export (`<sc-if>`, `<sc-for>`, `<dc-import>`, `{{ }}`, `style-hover`), not
runnable HTML — there is nothing to point a renderer at. The same substitution
was used and recorded for P3 (nav active state) and P4 (sprite fidelity). In
place of the captures this phase ran a **byte-level markup equivalence diff**
plus **measured runtime geometry**, which is strictly more precise than a pixel
comparison for the property under test (verbatim inline styles).

Script: `home-assertions.mjs` — **264 assertions, 264 passed, 0 failed**.

Method: the design source's Home body (lines 80-210) is mechanically expanded —
`<sc-for>` blocks unrolled against the shipped `home-content.ts` arrays,
`<dc-import>` collapsed to a `@@SPRITE:name:size@@` marker, `style-hover`
attributes lifted out, the `<button onClick="{{ goPets }}">` rewritten to the
`<a href="/pets">` form P2 already established — then whitespace-normalised and
compared character-for-character against the same normalisation of
`dist/index.html`'s `<main>` region. Result: **exact string equality**.

Sub-results:

| Check | Result |
|-------|--------|
| Built Home body === expanded design source (:80-210) | identical after normalisation |
| Inline `style="…"` attributes, positional compare | 113/113 verbatim, same order |
| Content literals from :734-754 present verbatim in `home-content.ts` | 91/91 |
| Sprite instances match the source `dc-import` list | `Bo@170, Bo@120, Bun@120, Kem@120, Mochi@120, Sua@120, Xoai@120` |
| Section order hero → features → pet-cast → how-it-works | PASS |
| Stat counters are static literals (`6`, `12`, `0₫`) | PASS — no fetch, no computation |

### Gate 4 — copy fidelity and paired spans

- **37 localized strings** ship on Home, every one as an adjacent
  `<span data-vi>…</span><span data-en>…</span>` pair (12 hero + 8 features +
  9 pet-cast + 8 how-it-works). No empty VI or EN text.
- The `"sao thế?"` inner quotes and the `what's wrong` apostrophe survive
  character-for-character; the em dash in the `mood` EN description survives.
- The four store-badge labels (`Download on the`, `App Store`, `Get it on`,
  `Google Play`) ship **unlocalized in both languages**, matching the source,
  and are asserted to carry no `data-vi`/`data-en` wrapper.

### Gate 5 — hover conversion

The phase converts every `style-hover` attribute inside the Home body into a
scoped `:hover` rule. After `sc-for` expansion the source has **13 hover
instances** collapsing to **4 distinct declarations**:

| Source line(s) | Hook class | Rule shipped |
|----------------|-----------|--------------|
| :95, :102 | `.cupid-hero-store` | `border-color:rgba(255,127,182,.55) !important;background:#130D22 !important` |
| :145 (×4 after expansion) | `.cupid-feature-card` | `border-color:rgba(255,127,182,.4) !important;transform:translateY(-4px) !important` |
| :160 | `.cupid-petcast-cta` | `background:var(--c13) !important` |
| :163,:168,:173,:178,:183,:188 | `.cupid-pet-card` | `transform:translateY(-6px) !important` |

Verified statically (rule authored verbatim; selector present in the bundled
CSS; each property carries `!important`) and at runtime by hovering each
element and reading computed style — see Gate 6.

### Gate 6 — runtime DOM, theme/lang, hover, responsive geometry

Script: `home-runtime.mjs`, Chromium via Playwright against the built `dist/`
served on the devstack-leased preview port 22001
(`devstack port lease --role preview --slot p5-home`).
**60 assertions, 60 passed, 0 failed.**

- Structure: 4 body sections in source order, each with its source padding.
- Sprites: 7 live instances — hero `Bo` at 170px, cast Bo/Bun/Kem/Mochi/Sua/Xoài
  at 120px, all painted (non-zero SVG rect), all `role="img"` with the pet name.
  The duplicated Bo (hero + cast) resolves its keyframes in **both** instances,
  re-confirming P4's finding that the duplicate gradient id is harmless.
- Phone mockup runs `animation-name: floaty`.
- **dark/VI**: 37 VI spans visible, 0 EN visible; h1 = "Nuôi tình yêu như nuôi
  một bé pet.".
- **light/EN**: 37 EN spans visible, 0 VI visible; h1 = "Grow your love like a
  little pet."; `--ink` token flips and the `var(--surf)` feature-card
  background repaints. This is the substituted evidence for the
  "identical at 1440×900 in dark/VI and light/EN" capture pair.
- **Hover, computed style after `page.hover()`**: store badge →
  `rgba(255, 127, 182, 0.55)` border and `rgb(19, 13, 34)` background; feature
  card → `rgba(255, 127, 182, 0.4)` border and `matrix(1,0,0,1,0,-4)`; pet-cast
  CTA background changes; pet card → `matrix(1,0,0,1,0,-6)`.

Measured grid geometry (substituted evidence for the viewport captures — the
computed track list is the thing the AC actually constrains):

| Viewport | Hero halves (floor 420) | Feature cards (260) | Pet cards (170) | Step cells (230) | Nav swap | Doc overflow |
|----------|------------------------|---------------------|-----------------|------------------|----------|--------------|
| 375 | 1 × 311 | 1 × 311 | 1 × 311 | 1 × 230 | select | none (375/375) |
| 768 | 1 × 704 | 2 × 343 | 3 × 224 | 2 × 278 | select | none |
| 1024 | 2 × 456 | 3 × 308 | 5 × 179 | 3 × 259 | select | none |
| 1025 | 2 × 457 | 3 × 308 | 5 × 179 | 3 × 260 | nav | none |
| 1440 | 2 × 576 | 4 × 287 | 6 × 187 | 4 × 246 | nav | none |

No track ever falls below its `minmax` floor, the single-column cases are the
container being narrower than the floor (hero uses `min(420px,100%)` so it
clamps instead of overflowing), and `document.scrollWidth` never exceeds
`clientWidth` at any of the five widths. The 1024→1025 nav swap from P2/P3 still
holds with the Home body mounted.

### Gate 7 — network and links

- `fetch(`, `XMLHttpRequest`, `EventSource`, `WebSocket`: **absent** from all
  five P5 source files.
- Built page references only `fonts.googleapis.com` / `fonts.gstatic.com`
  externally; no third-party `<script src>`.
- At runtime the page issued exactly **2** `fonts.googleapis.com` stylesheet
  requests and no other cross-origin request. Closes the phase AC "no network
  request beyond the two Google Fonts stylesheets".
- Home body hrefs are exactly `#`, `#` (the two placeholder store badges, `#`
  verbatim from the source) and `/pets`. `/pets/` resolves **200** against the
  built output.

### Deviations

1. **Handoff said "BoSprite at 170 for the primary sprite and 130 for the
   secondary"; the source hero has only one sprite.** `Cupid Web.dc.html` :117-139
   contains exactly one `<dc-import name="Bo Sprite" hint-size="170px,170px">`
   (line 128), and `uiux-spec` §6.2.1 likewise describes a single Bo sprite in
   the phone mockup. The value `130` appears in the source only as the pet-card
   sprite **container height** (`height:130px`, lines 164/169/174/179/184/189),
   which is ported verbatim. Implemented as the source specifies: one hero
   sprite at 170px. Raised to Scrum Master rather than invented.
2. **The handoff's 13 `style-hover` line numbers include three that are not in
   the Home body.** Lines 325, 462 and 485 fall outside the
   `<sc-if value="{{ isHome }}">` block (which ends at :211) and belong to other
   pages' sections — out of P5's write scope. The 10 in-range attributes
   (:95, :102, :145, :160, :163, :168, :173, :178, :183, :188) expand to 13
   instances once the features `sc-for` is unrolled ×4, which is where the count
   of 13 is genuinely met.
3. **Pet-cast CTA `<button onClick="{{ goPets }}">` ships as `<a href="/pets">`.**
   Same conversion P2 applied to the header nav buttons: the prototype's route
   buttons are navigation, and a real link is required for the AC-5 "must not
   404" check and for keyboard/middle-click behaviour. Every inline style byte
   is preserved. Residual difference: `<a>` and `<button>` have slightly
   different UA defaults for `text-align`/`line-height`, both overridden here by
   the inline `font-family`/`font-size` and the flex parent.
4. **`!important` on `transform` even though `transform` is not set inline.**
   `border-color` and `background` genuinely need it (the elements set `border`
   and `background` inline, which outrank a stylesheet rule). `transform` does
   not, but carries it so that each converted `style-hover` declaration stays a
   single symmetric rule rather than a mixed one.
5. **HTML entity encoding on interpolated text.** Astro escapes interpolated
   strings, so `"sao thế?"` ships as `&quot;` ×2 and `what's` as `&#39;` ×1.
   These parse back to the identical characters; the assertion decodes them and
   asserts no other entity is introduced. Statically-authored text (for example
   `Today's quest`) is not affected.
6. **Focus rings added.** `.cupid-hero-store:focus-visible` and
   `.cupid-petcast-cta:focus-visible` get `outline:2px solid var(--acc-pink);
   outline-offset:2px`. Absent from the prototype, required by `uiux-spec` §6.6;
   same addition P2 made for the header controls. `:focus-visible` never paints
   on mouse interaction, so the fidelity captures are unaffected.
7. **P4 sprite wrapper markup is carried as-is.** Each sprite renders inside
   `<div class="cupid-sprite" style="width:Npx;height:Npx;display:flex;…">`
   rather than the source's bare `style="width:Npx;height:Npx"` on the
   `dc-import`. That is a P4-established, P4-verified deviation and out of P5's
   write scope; the equivalence diff collapses those subtrees to a marker and
   compares the marker list instead. Their authoring HTML comments (7 of them)
   are likewise dropped before the diff — comments are not rendered content.

### Observation (not a defect)

At 1440px the how-it-works grid auto-fits **4** tracks for **3** step cells, so
the last column is empty. This is exactly what the design source's own CSS does
(`repeat(auto-fit,minmax(230px,1fr))` inside a 1088px content box) — the
prototype has the identical gap at its declared canvas width. Preserved rather
than "fixed", per the phase rule that no breakpoint or track override may be
introduced.

### Acceptance criteria status

| AC | Statement (abbreviated) | Evidence | Status |
|----|-------------------------|----------|--------|
| Phase AC 1 | Home is visually identical to the source at 1440×900, dark/VI and light/EN | Gate 3 (byte-identical markup, 113/113 style attrs), Gate 6 (both theme/lang combos measured) | PASS via substituted check (Gate 3 rationale) |
| Phase AC 2 | At 375/768/1024/1025/1440 no grid column drops below its `minmax` floor | Gate 6 geometry table | PASS |
| Phase AC 3 | Every VI/EN string matches the source character for character | Gate 3 (91/91 literals), Gate 4 (37 pairs) | PASS |
| Phase AC 4 | Every hover matches the source `style-hover` | Gate 5 + Gate 6 computed-style probes | PASS |
| Phase AC 5 | Pet-cast CTA resolves to `/pets`, no 404 | Gate 7 (href `/pets`, 200) | PASS |
| Phase AC 6 | No network request beyond the two Google Fonts stylesheets | Gate 7 (2 requests, no other cross-origin) | PASS |

Story-level: **UI-Fidelity-AC-6 (Home page visual fidelity)** is now closed by
P5 to the extent the substituted evidence allows. Final sign-off stays with the
UI-lane review gate.

No blockers for P5. Two carry-forward items for Scrum Master:

1. The hero "secondary sprite at 130" instruction has no counterpart in the
   design source (Deviation 1) — confirm the single-sprite hero is intended.
2. The two pre-existing Reviewer-only blockers (`design_source.entry` empty;
   `render-design-canvas.js` / `render-running-app.js` absent) are unchanged and
   still do not gate implementation, but every visual-fidelity check across
   P2-P5 has now been served by a documented substitute.

## Phase P6 — Runtime registry, local scripts, and deploy

Owner: DevOps. Status: COMPLETE. Write scope: exactly the six files listed in
`phase-P6-runtime-registry-and-deploy.md` §1B (no `deployment/caddy/*` file
was created — that path is outside P6's write scope; the Caddy site block is
documented inline in the configuration guide instead, matching the "no live
VPS deploy" instruction for this phase).

### 1. Shell syntax, shellcheck, executable bit

```
$ bash -n .github/workflows/scripts/vps-deploy-web.sh && echo OK
vps-deploy-web.sh OK
$ bash -n scripts/build.sh && echo OK
build.sh OK
$ bash -n scripts/start-dev.sh && echo OK
start-dev.sh OK
$ command -v shellcheck
(not installed on this machine — skipped, same as every other phase's
evidence in this file)
$ stat -f "%Lp %N" .github/workflows/scripts/vps-deploy-web.sh scripts/build.sh scripts/start-dev.sh
755 .github/workflows/scripts/vps-deploy-web.sh
755 scripts/build.sh
755 scripts/start-dev.sh
```

### 2. Workflow YAML parses; no `paths` overlap with the backend pipeline

Parsed both `deploy-web.yml` and `deploy-backend.yml` with PyYAML (`on:` is a
reserved YAML 1.1 boolean key, handled explicitly):

```
web parsed OK
backend parsed OK
web paths: ['web/**', '.github/workflows/deploy-web.yml', '.github/workflows/scripts/vps-deploy-web.sh']
backend paths: ['backend/**', '.github/workflows/deploy-backend.yml', '.github/workflows/scripts/vps-deploy.sh']
overlap: []
```

### 3. Registry JSON parses; `web-frontend` shape matches `backend-api`

```
parsed OK
web-frontend keys: ['buildCommand','checkCommand','dependsOn','devCommand','engines','framework','installCommand','language','notes','path','port','prodCommand','readiness','requiredEnv','requiredSecrets','type']
backend-api keys: ['buildCommand','dependsOn','devCommand','framework','installCommand','language','notes','path','port','prodCommand','readiness','requiredEnv','requiredSecrets','type']
sharedInfra.reservedPorts: {"api":21020,"web":21021,"docs":21023,"mobile-metro":21025,"ws":21027}
```
`web-frontend` adds `checkCommand` (astro check has no backend-api analog) and
`engines` (documents the Node `>=22.12.0` requirement astro@6.0.5 imposes,
since this machine's ambient default node is v20.20.2); every other field
matches `backend-api`'s shape. `installCommand`/`buildCommand`/`devCommand`/
`prodCommand`/`port`/`readiness`/`requiredEnv`/`requiredSecrets`/`dependsOn`
are all present, `requiredEnv`/`requiredSecrets`/`dependsOn` are empty arrays
per the phase spec (no API/database dependency, OQ-REQ006-2).

`web` was claimed live via `devstack port claim --role web` (`ok
cupid-apps:web -> 21021`) and confirmed by `devstack use`'s reserved-ports
summary; `sharedInfra.reservedPorts.web` above matches.

### 4. Hardcoded/scanned port check

Read (not shell-grepped, per this session's source-file guard) every line of
`.github/workflows/deploy-web.yml`, `.github/workflows/scripts/vps-deploy-web.sh`,
`scripts/build.sh`, `scripts/start-dev.sh`, and the `web-frontend` registry
entry: no `find_free_port`-style scan, no `nc -z`/free-port probe, and the
only local port value used at runtime is `${DEVSTACK_PORT_WEB}` /
`"${WEB_HOST_PORT}"`, sourced from `.env.devstack`. The registry entry's
`port.containerPort: 4321` is documentation metadata (Astro's own default
listen port, mirroring `backend-api`'s pre-existing `containerPort: 3000`
field in the same file) — not a value used to bind or discover anything at
runtime; the actual host port is always `DEVSTACK_PORT_WEB`.

### 5. Literal secret value check

Read every line of `.github/workflows/deploy-web.yml` and
`.github/workflows/scripts/vps-deploy-web.sh`: every credential is read via
`${{ secrets.* }}` in the workflow and forwarded as an env var into the
script, which only ever reads it back from its own environment
(`${VPS_SSH_PRIVATE_KEY:?missing}` etc.) — no key material, token, or
password literal appears in either file.

### 6. Secret list (exact, new vs reused)

Reused (identical names to `deploy-backend.yml`): `VPS_SSH_HOST`,
`VPS_SSH_USER`, `VPS_SSH_PORT`, `VPS_SSH_PRIVATE_KEY`, `VPS_SSH_KNOWN_HOSTS`.

**New — exactly one, placeholder only, not provisioned by this phase:**
`VPS_WEB_DEPLOY_PATH` (the VPS-side deploy directory root for the web
release-swap layout). No value was invented; provisioning is a user action
(`gh secret set VPS_WEB_DEPLOY_PATH --body <path>`).

### 7. Build/check gate re-confirmation (this session, under the pinned Node)

Ran under the same Node version this phase pins in CI (`22.12.0`+; this
session used the already-installed `v22.17.1` via `nvm`, this machine's
ambient default is v20.20.2):

```
$ node --version
v22.17.1
$ npm run check
> astro check
Result (27 files):
- 0 errors
- 0 warnings
- 0 hints
$ npm run build
> astro build
[build] output: "static"
[build] 8 page(s) built in 546ms
  ├─ /about/index.html
  ├─ /blog/index.html
  ├─ /legal/index.html
  ├─ /pets/index.html
  ├─ /share/index.html
  ├─ /support/index.html
  ├─ /zodiac/index.html
  ├─ /index.html
```
Confirms the directory-format output the Caddy `try_files`/`file_server`
configuration guide section targets (`/pets` must resolve to
`/pets/index.html`, not a literal `pets` file). Also confirmed
`npx astro dev --help` on this Node: `--port` and `--host <custom-address>`
are real flags, matching exactly how `scripts/start-dev.sh` invokes
`npm run dev -- --port "${WEB_HOST_PORT}" --host 127.0.0.1`.

### 8. Deferred, not required by this phase

- No live deploy to `cupidus.app` was attempted; no VPS was reached; no
  Caddyfile was edited — the phase explicitly scopes this to repository
  configuration + CI authoring, and the handoff instructed no live
  deploy/no live secrets. (The `web-frontend` local runtime startup smoke
  itself is not out of scope; it is recorded below in
  `## Story Runtime Startup Smoke`, correcting an earlier `NOT_APPLICABLE`
  note here that the runtime-smoke gate correctly rejected.)
- `scripts/start-prod.sh` was not touched — out of P6's declared write scope;
  `web-frontend.prodCommand` (`npm run preview`) is registry-documented only.

### 9. Finding reported to Scrum Master (not fixed by this phase)

`VPS_SSH_PRIVATE_KEY` reuse across two deploy units may not work at the SSH
layer: REQ-005's `vps-deploy.sh` documents this key's server-side
`authorized_keys` forced-command wrapper as matching only the literal prefix
`cd /var/www/backend && `, and REQ-005's own configuration guide states the
key was "Scoped to this backend deploy unit only — do not reuse for a second
deploy unit." `vps-deploy-web.sh` prefixes its remote commands with
`cd ${VPS_WEB_DEPLOY_PATH} && ` instead, which that wrapper (as documented)
would reject. This phase was instructed to reuse the secret exactly and not
attempt a live deploy or SSH session, so it was not verified against the live
wrapper. Full detail and the two remediation options (widen the wrapper, or
provision a dedicated `VPS_WEB_SSH_PRIVATE_KEY`) are in
`../../deployment/configuration-guide.md` §5.

## Story Runtime Startup Smoke

Result: PASS

**Result: PASS** | **Shutdown: PASS**

Date: 2026-08-21. Patch pass for Iris-QC-3 finding **BLK-2** (full-story
review, `review/review-report.md`). Supersedes the earlier non-PASS
placeholder note in "8. Deferred, not required by this phase" above (that
note did not satisfy the runtime-smoke requirement for a `shared`-lane,
`standard`-complexity story lacking a `Runtime-Smoke: WAIVED` line in
`story_master.md`). Reviewer had already demonstrated the smoke passes;
this is DevOps' own re-run of that evidence, not a copy of Reviewer's
numbers.

Runtime id: `web-frontend` (`data/devops/system/runtime-command-registry.json`).
`astro@6.0.5` requires Node `>=22.12.0`; this machine's ambient default is
`v20.20.2`, so the smoke was run under `nvm use 22.17.1`.

Commands run (`web/` as working directory):

```
$ nvm use 22.17.1
Now using node v22.17.1 (npm v10.9.2)
$ DEVSTACK_PORT_WEB=21021 npm run dev -- --port 21021 --host 127.0.0.1
```

Readiness probe (registry `web-frontend.readiness`, `GET /` on the reserved
`DEVSTACK_PORT_WEB` port 21021, `expectStatus: 200`):

| Attempt | `GET http://127.0.0.1:21021/` |
|---|---|
| 1 | `200` (ready on first poll) |

Shutdown: sent `SIGTERM` to the `npm run dev` process; it exited cleanly
without needing `SIGKILL`. Post-shutdown probe against the same URL returned
connection-refused (`curl` exit code `000`, the expected no-response signal
once a server has stopped), confirming the port was released and no
orphaned process remained.

This confirms the `web-frontend` local dev runtime starts, serves `GET /`
with `200`, and shuts down cleanly on the registry-reserved port — closing
BLK-2. It does not re-run or supersede the build/check/visual-fidelity
evidence recorded elsewhere in this file.

## Entry Point Reachability

**Reachable: YES**

Date: 2026-08-21. Patch pass for Iris-QC-3 finding **BLK-1** (full-story review,
`review/review-report.md`). BLK-1 was a missing-evidence finding, not a missing
implementation — Reviewer independently confirmed in code that the entry point
exists. This section records that verification.

Verified with `patch-blk1-blk3.mjs` against the static build served over HTTP
(devstack-leased preview port 22002, `devstack port lease --role preview --slot
blk1-blk3`): **73 assertions, 73 passed, 0 failed** (this section and the BLK-3
section below share one run).

### The entry point itself

| Fact | Evidence |
|------|----------|
| The `/` route exists | `web/src/pages/index.astro`; `astro build` emits `dist/index.html` |
| `/` returns 200 | live `GET /` → **200** |
| `/` serves the real Home body, not an empty shell | response contains "Nuôi tình yêu" (hero h1) and "Sáu bé, sáu tính cách" (pet-cast h2) |
| The key `home` maps to `/` | `web/src/data/site-nav.ts:24-26` — `hrefFor()` returns `'/'` for `'home'`, `` `/${key}` `` otherwise |
| `home` is a first-class nav entry | `site-nav.ts:30` — `{ key: 'home', href: hrefFor('home'), vi: 'Trang chủ', en: 'Home' }`, first element of `navItems` |

### Navigation anchors back to `/`

Each of these was asserted present in the served HTML of **all 8 routes**
(`/`, `/pets/`, `/zodiac/`, `/share/`, `/blog/`, `/about/`, `/support/`,
`/legal/`), and the `/` target was re-fetched and returned **200**:

| Anchor | Source | Present on |
|--------|--------|-----------|
| Header logo link | `SiteHeader.astro:17` — `<a href="/" class="cupid-hdr-logo">` | 8/8 routes |
| Desktop nav Home item | `SiteHeader.astro:21-30` — `navItems.map(...)` emitting `<a href={it.href}>`, with `aria-current="page"` on the active key | 8/8 routes |
| Mobile select Home option | `SiteHeader.astro:31-35` — `<option value={it.href}>`, i.e. `value="/"` for the home item | 8/8 routes |
| Header CTA | `SiteHeader.astro:44` — `<a href="/" class="cupid-hdr-cta">` | 8/8 routes |
| Footer Product-column Home link | `SiteFooter.astro` rendering `footerCols`, whose Product column opens with `{ key: 'home', href: hrefFor('home'), … }` (`site-nav.ts:45`) | 8/8 routes |

Every route carries **at least 3** distinct `<a href="/">` anchors, so the entry
point is reachable from anywhere in the site without relying on any single
control. The 1024/1025 nav swap does not create a gap: below 1025px the desktop
nav is hidden but the logo link, the CTA, the mobile `<select>` and the footer
link all remain, and above 1025px the desktop nav is the additional path.

No implementation change was required for BLK-1.

## BLK-3 — Favicon asset

**Fixed.** `SiteLayout.astro:24` emits
`<link rel="icon" href="/favicon.svg" type="image/svg+xml" />`, but
`web/public/` did not exist, so `GET /favicon.svg` returned 404 on all 8 routes.
The design source has no favicon reference at all, so this `<link>` was
implementation-added in P2 and the missing asset was an oversight, not a
fidelity choice.

Fix: created `web/public/favicon.svg` (Astro copies `publicDir` verbatim into
`dist/`). The artwork mirrors the existing header logo mark at
`SiteHeader.astro:18` — a rounded square filled with the brand gradient
`#FF7FB6 → #B78CF5` at the same 140deg angle (resolved to SVG gradient
endpoints for a square box) carrying the white `favorite` heart. The gradient id
is namespaced `cupid-favicon-brand`, consistent with the P4 sprite id
convention, though a `public/` asset is fetched as its own document and cannot
collide with page ids in any case. No design-source asset exists for this, so it
is a judgment call as the handoff allowed.

Targeted re-check (no P1-P6 suite re-run):

| Check | Result |
|-------|--------|
| `npm run build` | exit 0, 8 page(s) built in 580ms, no errors |
| `dist/favicon.svg` emitted | yes, 928 bytes |
| `GET /favicon.svg` | **200** |
| Content type | `image/svg+xml` |
| Body parses as a well-formed SVG root | yes |
| `<link rel="icon" href="/favicon.svg">` present and resolving 200 | 8/8 routes |

`npx astro check` was not re-run for this item: the change adds a static asset
under `public/` and touches no TypeScript or `.astro` source, so it cannot
affect type diagnostics. The last full run (P6) remains current.

### Correction to the P2-P5 substitution rationale

The P2, P3, P4 and P5 sections above state that `render-design-canvas.js` and
`render-running-app.js` "do not exist anywhere in this repo" and use that as
part of the justification for substituting markup/DOM checks for capture pairs.
**That claim was wrong.** Both tools exist at
`.ai-team-bundle/runtime/tools/render-design-canvas.js` and
`.ai-team-bundle/runtime/tools/render-running-app.js`; they were never searched
for at that location. Iris-QC-3 used them successfully and the story's visual
fidelity gate **PASSED** (`visual-fidelity/visual-fidelity-report.md`, 7 renders
at 375/768/1400).

The substituted checks themselves still stand on their own merit — byte-level
markup equality and measured runtime geometry are more precise than a pixel
diff for verbatim-inline-style fidelity, and the design source is a design-comp
DSL export rather than runnable HTML — but the "tooling absent" half of the
rationale is retracted, and the earlier "Reviewer-only blocker" notes about
missing render tooling in the P2-P5 sections are superseded by this correction.
The `design_source.entry` observation is likewise superseded: it resolved
correctly for Reviewer's run.
