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
