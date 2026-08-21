# Test Results — REQ-006 / STORY-003 (Zodiac page)

- Lane: Frontend
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-003`
- Branch: `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-003`
- BaseHead: `6c39274be5faee3a7c329cd9dea4d760e6d69c1f`
- Runtime: Node `v22.17.1` (npm 10.9.2), satisfying `web/package.json` `engines.node >= 22.12.0`.
  The default `node` on this machine is v20.20.2, which does not; every command
  below was run with `PATH="$HOME/.nvm/versions/node/v22.17.1/bin:$PATH"`.
- Dependency install: `npm ci` from `web/` (no `npm install`). `web/package.json`
  and `web/package-lock.json` are unchanged — see the `git status` block at the end.
- Last updated: 2026-08-21

---

## Phase P1 — data module, sign icon, sign-directory sections

Files: `web/src/data/zodiac.ts`, `web/src/components/sprites/ZodiacIcon.astro`,
`web/src/components/zodiac/TwelveSignsGrid.astro`,
`web/src/components/zodiac/FourElementsGrid.astro`.

### Build / type-check

```
$ cd web && npm run check
> astro check
Result (31 files):
- 0 errors
- 0 warnings
- 0 hints
CHECK_EXIT=0

$ cd web && npm run build
> astro build
8 page(s) built in 691ms
[build] Complete!
BUILD_EXIT=0
```

### Fixed-count gate proven, not assumed

P1's acceptance criterion is that "changing a count breaks `npm run check`". Verified
by temporarily deleting the `pisces` entry from `SIGNS` and re-running the gate:

```
$ cd web && npm run check
src/data/zodiac.ts:51:12 - error ts(1360): Type 'readonly [...]' does not satisfy
  the expected type 'Twelve<Sign>'.
  Source has 11 element(s) but target requires 12.
Result (31 files):
- 1 error
COUNT_DRIFT_CHECK_EXIT=1
```

The entry was restored immediately and `npm run check` returned to 0 errors. The
same `as const satisfies` guard covers `ELEMENTS` (4), `DAILY_READ.metrics` (3),
`ELEMENTS[].signs` (3), and `IN_SYNC_PAIRS` (6).

### Glyph fidelity

All 12 `sc-if` branch bodies were copied verbatim from
`cupid-app-design-system/Zodiac Icon.dc.html:14-98`, including the two branches
that use `stroke-width="5.5"` instead of `6` (virgo, scorpio). Asserted against
the built page — the 12 sign cards produce 12 distinct path/circle geometry
signatures, so no branch is duplicated or missing:

```
PASS  12 sign cards render 12 distinct glyphs: [12,12]
```

Element-derived ink, counted across the whole page container (12-sign grid +
4-element grid + 2 in the daily card):

```
fire  ink #FF9576: 6 glyph group(s)
earth ink #5FD3BC: 7 glyph group(s)
air   ink #B78CF5: 6 glyph group(s)
water ink #FF7FB6: 7 glyph group(s)
```

(3 per element in the element grid + 3 per element in the 12-sign grid, plus the
daily card's `cancer` and `taurus` — water and earth therefore carry 7.)

Visual inspection at 1440px, dark/VI and light/EN: the 12 glyphs are visually
distinct and each carries its element group's stroke and disc colour.

### Accessibility split (uiux-spec §6.5)

```
icon roots total:            26   (12 sign grid + 12 element grid + 2 daily card)
aria-hidden="true" icons:    14   (12 sign grid + 2 daily card — visible name adjacent)
role="img" + aria-label:     12   (element grid only — no visible text fallback)
aria-labels: Aries, Leo, Sagittarius, Taurus, Virgo, Capricorn,
             Gemini, Libra, Aquarius, Cancer, Scorpio, Pisces
```

### Bilingual spans

Every prose string in both components emits a paired `data-vi` / `data-en` span
(see the P2 counts below, which cover the assembled page).

Deliberate exception: the sign-card date range is rendered unwrapped, exactly as
the source does (`Cupid Web.dc.html:328` renders `{{ z.date }}` with no spans).
The string is language-neutral (`21.3 – 19.4`), so it can never render blank in
either language — which is the failure mode the paired-span rule exists to
prevent. P1 §4 states the requirement as "icon, VI+EN name, and date range",
scoping the bilingual pair to the name. Numeric percentages (`92%`, `88%`, `96%`)
are unwrapped for the same reason and the same source precedent.

### Scope

`git status --porcelain` after P1 listed only the four P1 files (all new,
untracked). No tracked file was modified, so
`git diff --name-only 6c39274be5faee3a7c329cd9dea4d760e6d69c1f` was empty.

**P1 status: PASS**

---

## Phase P2 — page assembly, entry point, per-page title

Files: `web/src/components/zodiac/DailyCompatibilityCard.astro`,
`web/src/components/zodiac/InSyncLeaderboard.astro`, `web/src/pages/zodiac.astro`.

### Build / type-check

```
$ cd web && npm run check
> astro check
Result (33 files):
- 0 errors
- 0 warnings
- 0 hints
CHECK_EXIT=0

$ cd web && npm run build
> astro build
  ├─ /zodiac/index.html (+3ms)
8 page(s) built in 1.06s
[build] Complete!
BUILD_EXIT=0
```

### Static assertions against `web/dist/zodiac/index.html`

```
PASS  <title>: "Hoàng đạo — Cupid"
PASS  title !== shell default: false
PASS  12 sign cards: 12
PASS  4 element cards: 4
PASS  6 leaderboard rows: 6
PASS  12 sign-card date ranges (en dash): 12
PASS  paired data-vi/data-en spans (whole doc): true
      data-vi=58 data-en=58
PASS  paired data-vi/data-en spans (page container): true
      data-vi=36 data-en=36
PASS  no empty data-vi span: false
PASS  no empty data-en span: false
PASS  conic stop == second stop: "92"
PASS  conic stop == inner-disc text: "92"
      ring stop=92% disc="92%"
PASS  12 sign cards render 12 distinct glyphs: [12,12]
PASS  container has no <a: false
PASS  container has no <a>: false
PASS  container has no <button: false
PASS  container has no <input: false
PASS  container has no <progress: false
PASS  container has no <meter: false
PASS  container has no tabindex: false
PASS  header nav has /zodiac link: true
PASS  mobile select has /zodiac option: true
      active pill markup: <a href="/zodiac" class="cupid-hdr-nav-item" aria-current="page"
      style="background:rgba(255,127,182,.16);...;color:var(--acc-pink);...">
PASS  active pill: aria-current="page": true
PASS  active pill: pink fill: true
PASS  no other nav pill is active: 1
PASS  footer has /zodiac link: true
PASS  five sections in source order: true
PASS  scoped :hover rule emitted: true
      .cupid-sign-card[data-astro-cid-nmvb6tvt]:hover{border-color:#ffc97e66!important}
PASS  all 12 cards carry the scope attribute the rule selects: 12
PASS  exactly one page-local inline script (title sync): 1

ALL ASSERTIONS PASSED
ASSERT_EXIT=0
```

Notes on two assertions that had to be corrected before they were meaningful:

- Astro 6 scopes component styles with a `data-astro-cid-*` **attribute**, not an
  `astro-*` class, and inlines the rule into the page `<style>` rather than
  emitting it to `dist/_astro/*.css`. A first pass looked in the wrong place and
  reported a false negative. The rule is present and all 12 cards carry the
  attribute it selects, so the `border-color:rgba(255,201,126,.4)` hover from
  `Cupid Web.dc.html:325` is live (Astro minifies it to `#ffc97e66` — same colour).
- The naive `/<span data-vi>/` count under-reports, because spans inside a
  scoped component render as `<span data-vi data-astro-cid-...>`. Corrected to
  `/<span data-vi[ >]/`; the real page-container counts are 36 / 36.

### Runtime signals (headless Chromium, `web/dist` served over HTTP)

```
PASS  AC-1 start on home: "/"
PASS  AC-1 header nav pill navigates to /zodiac: "/zodiac"
PASS  AC-1 pill is active on arrival: "page"
PASS  AC-9 title (VI, default): "Hoàng đạo — Cupid"
PASS  AC-9 title follows EN toggle: "Zodiac — Cupid"
PASS  AC-9 title follows VI toggle back: "Hoàng đạo — Cupid"
PASS  VI: no blank visible bilingual span: [36,0]
PASS  EN: no blank visible bilingual span: [36,0]
PASS  ring paints a conic-gradient: true
PASS  ring disc text: "92%"
PASS  no focusable control inside the page container: 0
PASS  @375px: no h-overflow, bar 120px, value 38px
PASS  @768px: no h-overflow, bar 120px, value 38px
PASS  @1024px: no h-overflow, bar 120px, value 38px
PASS  @1440px: no h-overflow, bar 120px, value 38px
PASS  browser console clean: []
PASS  AC-9 title with JavaScript disabled: "Hoàng đạo — Cupid"
PASS  sections still render without JS: true

ALL RUNTIME CHECKS PASSED
RUNTIME_EXIT=0
```

AC-1 is verified as a real navigation, not a direct URL hit: the run loads `/`,
clicks the header nav pill, and asserts both the resulting path and the active
`aria-current="page"` state on arrival.

AC-9 is verified in both directions — the served HTML already carries the VI
title with JavaScript disabled (so the `<title>` never depends on the sync
script), and the `MutationObserver` on `body[data-lang]` keeps it in step with
the language toggle. `setLang` dispatches no event, so the observer is the only
available hook.

The ring passes the "one value, two derived outputs" rule: `DAILY_READ.score`
feeds both the `conic-gradient` stop and the inner-disc text, asserted equal in
the built HTML.

### Responsive / visual inspection

Full-page screenshots captured at dark/VI 1440, light/EN 1440, and dark/VI 375.
Five sections render in source order in all three, with no blank strings in
either language and no missing glyphs.

Leaderboard at 375px behaves as uiux-spec §6.5 requires: the `flex:1` pair label
wraps to multiple lines while the bar stays exactly 120px and the value column
exactly 38px (measured, not eyeballed).

### Finding (not fixed — inherited from the design source, needs a UX decision)

At 375px the daily card's **left cell** (sign icon 86 + ring 104 + sign icon 86
+ two 22px gaps = 320px) does not fit the 233px of inner width available, and the
right-hand sign icon is clipped by the card edge:

```
@375px  cardInner=233  children=[left:28 w:86, ring:136 w:104, right:262 w:86]
@1440px cardInner=543  children=[left:271 w:86, ring:379 w:104, right:505 w:86]
```

This is the design source's own behaviour, not something this port introduced —
`Cupid Web.dc.html:293` is a `display:flex` row with no `flex-wrap`, and its
children carry the same fixed 86/104/86 sizes and 22px gap, so the source clips
identically at that width. Page-level horizontal overflow is still zero (the
shell wrapper sets `overflow-x:hidden`), so nothing scrolls sideways.

Not fixed here because the port rule is verbatim inline styles from the source,
and adding `flex-wrap` or scaling the icons down would be a UX change rather
than an implementation choice. `uiux-spec` §6.5 and §6.7 only specify the outer
two-column collapse and the leaderboard's narrow-width behaviour; the inner
sign-pair row is unspecified. Raising for UI/UX Designer to decide at the
requirement-level visual audit.

### Deferred

AC-10 requirement-level visual fidelity is deferred to the `frontend-dev`
`Mode: requirement-visual-audit` gate, per P2 §6. `render-design-canvas.js` is
not present in this worktree and no `design-reference-zodiac-*.png` exists, so
`DESIGN_REFERENCE_MISSING` should be reported there if that is still true. Per
the handoff's stop rule, this does not block this phase.

**P2 status: PASS**

---

## Shell immutability / write scope

```
$ git diff --name-only 6c39274be5faee3a7c329cd9dea4d760e6d69c1f
web/src/pages/zodiac.astro

$ git status --porcelain
 M web/src/pages/zodiac.astro
?? web/src/components/sprites/ZodiacIcon.astro
?? web/src/components/zodiac/
?? web/src/data/zodiac.ts
```

Exactly the seven declared files (one modified route body, six new). Nothing
under `web/src/layouts/`, `web/src/components/shell/`, `web/src/styles/`, or
`web/src/scripts/` was touched, and `web/package.json`, `web/package-lock.json`,
and `web/astro.config.*` are unchanged. No dependency was added.

---

## Entry Point Reachability

Reachable: YES

Route: `/zodiac` (`web/dist/zodiac/index.html`, built static route).

The page is reachable from the running app without typing a URL. All three
entry paths were exercised in headless Chromium against the served `web/dist`,
each starting from `/` and asserting the resulting pathname after a real user
gesture:

| # | Entry point | Concrete path | Result |
|---|---|---|---|
| 1 | Header nav pill (desktop, 1440px) | `/` → click `[data-nav] a[href="/zodiac"]` ("Hoàng đạo") | lands on `/zodiac`, pill carries `aria-current="page"` |
| 2 | Mobile nav `<select>` (375px) | `/` → `select.cupid-hdr-navm` → choose option `value="/zodiac"` | lands on `/zodiac`, option preselected on arrival |
| 3 | Footer link (1440px) | `/` → click `footer a.cupid-ftr-link[href="/zodiac"]` | lands on `/zodiac` |

At 375px the desktop nav is confirmed hidden (`[data-nav]` visible = false), so
path 2 is the only header entry a phone user actually has — it is asserted, not
assumed.

```
$ node reachability-zodiac.mjs <worktree>
PASS  P1 header nav pill visible at 1440px: href=/zodiac
PASS  P1 lands on /zodiac: /zodiac
PASS  P1 active state on arrival: /zodiac
PASS  P1 zodiac page body rendered: "Hôm nay trời có ủng hộ hai bạn không?"
PASS  P2 mobile nav select visible at 375px: desktop nav visible=false
PASS  P2 select carries a /zodiac option: ["/","/pets","/zodiac","/share","/blog","/about","/support"]
PASS  P2 lands on /zodiac: /zodiac
PASS  P2 option preselected on arrival: /zodiac
PASS  P3 footer link present: count=1
PASS  P3 lands on /zodiac: /zodiac
REACH_EXIT=0
```

No new entry point was added by this story: `/zodiac` already exists in
`web/src/data/site-nav.ts` (nav item and footer link) and is rendered by the
STORY-001 shell. This section records that the existing wiring actually resolves
to the page this story built (AC-1); direct-URL access alone is not accepted as
evidence.

---

## Story Runtime Startup Smoke

Applicable: YES — surface `web` (runtime registry id `web-frontend`, type
`frontend`). Both phase files declare `Startup Smoke: NOT_APPLICABLE` for a
long-running process, because this is a static build with no server, port
contract, or readiness endpoint. The equivalent smoke for a static frontend is
the build gate plus serving the build output, both recorded below.

Build gate, re-run on the current worktree HEAD `e82a24ee` after this
evidence-only patch, on Node v22.17.1:

```
$ cd web && npm run check
Result (33 files):
- 0 errors
- 0 warnings
- 0 hints
CHECK_EXIT=0

$ cd web && npm run build
generating static routes
  ├─ /about/index.html
  ├─ /blog/index.html
  ├─ /legal/index.html
  ├─ /pets/index.html
  ├─ /share/index.html
  ├─ /support/index.html
  ├─ /zodiac/index.html
  ├─ /index.html
[build] 8 page(s) built in 612ms
[build] Complete!
BUILD_EXIT=0
```

Served-output smoke (`web/dist` over HTTP, headless Chromium):

```
PASS  SMOKE all 8 built routes serve 200: /=200 /about=200 /blog=200 /legal=200 /pets=200 /share=200 /support=200 /zodiac=200
PASS  SMOKE console/page errors across all routes: []
PASS  SMOKE zodiac route renders its sections: {"signCards":12,"elementCards":4,"ring":1,"title":"Hoàng đạo — Cupid"}
```

No regression: the counts, title, and clean console match the original P2 run,
and the seven implementation files are byte-identical to the reviewed commit —
this patch changed evidence artifacts only.

Startup smoke: PASS
