# Test Results — REQ-006 / STORY-007 Support FAQ Page (Phase P1)

FRONTEND_COMPLETE: YES

- Lane: Frontend
- Phase: P1 (`phase-P1-support-faq-page.md`)
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-007`
- Branch: `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-007`
- BaseHead: `205c38356a6fb91c4e884a7fde5cbc20b63dbb5c`
- Date: 2026-08-21

## 0. Design-source fidelity lock

`req_master.md:37-40` records `Design-Source: UPDATED 2026-08-21T10:18:35Z
(applied)` — the lock was re-detected and re-locked from REQ-001's mobile canvas
onto this requirement's web canvas `cupid-app-design-system/Cupid Web.dc.html`.
The phase file's Source Of Truth (`phase-P1:47-50`) and the UX spec (§1, §6.8)
both cite `Cupid Web.dc.html` lines 614-637 / 814-821. The audit below was run
against that web canvas. No stop condition.

## 1. Build / type-check gate

Toolchain: Node `v25.2.1` (Homebrew, `/opt/homebrew/bin/node`), npm `11.6.2` —
satisfies `web/package.json` `engines.node >= 22.12.0`. The default shell Node
(`v20.20.2`, nvm) does not, and was used only for the Playwright capture
scripts, not for the build.

Commands, run from `web/`, full output read (not filtered):

```
npm run check
> astro check
Result (27 files):
- 0 errors
- 0 warnings
- 0 hints

npm run build
> astro build
[build] output: "static"
generating static routes
  ├─ /about/index.html   ├─ /blog/index.html    ├─ /legal/index.html
  ├─ /pets/index.html    ├─ /share/index.html   ├─ /support/index.html
  ├─ /zodiac/index.html  ├─ /index.html
[build] 8 page(s) built in 579ms
[build] Complete!
```

PASS. The only build warning is the pre-existing upstream Vite notice about
unused re-exports inside `node_modules/astro`; it is not produced by this page.

## 2. Rendered-DOM check (AC-2, AC-3/BR-3)

Against `web/dist/support/index.html` and against the live DOM at 1440/dark/vi:

| Check | Result |
|---|---|
| `<details>` count | **6** |
| `<details>` carrying a `name` attribute | **0** |
| `<summary>` count | 6 |
| computed `list-style-type` on every `<summary>` | `none` |
| `expand_more` icons carrying `aria-hidden="true"` | 6 |

PASS — six independent native disclosures, no `name` grouping, native marker
suppressed. No JS manages open state; the page ships no script of its own.

## 3. Bilingual pairing check (AC-5)

- `data-vi` spans: **37**; `data-en` spans: **37** — paired 1:1.
- Blank `<span data-vi>`/`<span data-en>` elements in the built HTML: **0**.
- Blank *visible* spans under `main`, measured in-browser across all 16
  width × theme × language combinations: **0**.

Verbatim-copy proof against `Cupid Web.dc.html:814-821`, comparing rendered
`textContent` (all six entries force-opened) to the source `faq` array:

```
--- lang=vi ---            --- lang=en ---
VERBATIM 1..6              VERBATIM 1..6
=== PROBLEMS ===
none — all 24 strings render verbatim
```

Header/contact strings (`Câu hỏi thường gặp`, `Frequently asked`,
`Vẫn cần người thật?`, `Still need a human?`, both subtext strings,
`hi@cupid.app`, `Support`, `expand_more`): 9 of 9 present, 0 missing.

Note: a raw `grep` of the built HTML reports the EN answer for entry 5 as
"missing" only because Astro escapes its apostrophe to `&#39;`
(`Yes — that&#39;s why it exists.`). The DOM `textContent` comparison above
resolves the entity and matches the source byte-for-byte.

## 4. `href` check (AC-4 / BR-2)

Exactly one `mailto:` anchor in `main`:

```html
<a class="cupid-support-mail" href="mailto:hi@cupid.app"
   style="background:var(--ink90);color:var(--bg);padding:13px 24px;border-radius:999px;font-family:Nunito;font-weight:800;font-size:14px">
```

`href` is exactly `mailto:hi@cupid.app`. PASS. Plain static anchor — no form,
no handler, no `fetch`.

## 5. Title check (AC-7)

`web/dist/support/index.html` `<title>`:
`Hỗ trợ &amp; FAQ · Support &amp; FAQ — Cupid` (renders as
`Hỗ trợ & FAQ · Support & FAQ — Cupid`). Not the bare `Cupid` default. PASS.

A matching `<meta name="description">` is passed through the same `SiteLayout`
props. `SiteLayout`'s own default (`title = 'Cupid'`) was not changed.

## 6. Shell-immutability check (STORY-001 contract §6)

```
git -C <worktree> diff --name-only 205c38356a6fb91c4e884a7fde5cbc20b63dbb5c
web/src/pages/support.astro
```

Exactly one tracked file. Nothing under `web/src/layouts/`,
`web/src/components/`, or `web/src/styles/`. PASS.

`npm install` (needed because the worktree had no `node_modules`) rewrote
`web/package-lock.json` with npm-11 metadata drift only (`engines` mirror plus
`"peer": true` markers, +9 lines, no dependency change). That file is outside
this phase's Write Scope, so it was reverted with `git checkout --` and the diff
re-verified clean.

## 7. Disclosure independence (AC-3 / BR-3)

Open flags read as a 6-bit string, entry 1 leftmost, measured in-browser:

| Action | Open flags | Expected |
|---|---|---|
| click entry 3 @375 / @768 / @1024 / @1440 | `001000` | `001000` |
| keyboard **Enter** on focused entry 1 | `100000` | `100000` |
| keyboard **Space** on focused entry 1 | `000000` | `000000` |
| click entry 2, then entry 5 | `010010` | `010010` |

PASS — opening one entry never changes another, two entries stay open
simultaneously (so it is not a single-open accordion), and Enter/Space both
toggle via native `<details>` behaviour.

## 8. Focus visibility (UX §6.6)

Measured under real `Tab` traversal (an earlier run using programmatic
`.focus()` reported a false negative — Chromium does not set `:focus-visible`
for scripted focus on these elements):

| Target | Tab presses | `:focus-visible` | computed outline |
|---|---|---|---|
| first `<summary>` | 13 | `true` | `solid 2px rgb(255, 127, 182)`, offset `2px` |
| `mailto:` pill | 6 | `true` | `solid 2px rgb(255, 127, 182)`, offset `2px` |

`rgb(255,127,182)` is `var(--acc-pink)`. Matches the sitewide ring pattern
STORY-001 established in `SiteHeader.astro:87-92` and `SiteFooter.astro:35`.
Screenshots: `visual-fidelity/implemented-support-focus-summary.png`,
`visual-fidelity/implemented-support-focus-mailto.png`.

## 9. Mailto pill hover (UX §6.6)

| State | computed `color` |
|---|---|
| default | `rgb(23, 17, 41)` |
| hovered | `rgb(23, 17, 41)` |
| `--bg` token (dark) | `#171129` = `rgb(23,17,41)` |

PASS — the pill label stays `var(--bg)` and does not pick up the sitewide
`a:hover{color:#FFA9CD}` pink. The inline `color:var(--bg)` outranks the
non-`!important` global rule, so no extra CSS was needed and none was added.
Screenshot: `visual-fidelity/implemented-support-mailto-pill-hover.png`.

## 10. Overflow / summary-row check

At 375, 768, 1024 and 1440, in both themes and both languages (16 runs):

- `documentElement.scrollWidth > clientWidth`: **0 occurrences** — no
  horizontal overflow.
- Summary rows where the `expand_more` icon wrapped below the question text
  (`icon.top >= question.bottom`): **0 occurrences** at any width. The question
  span takes the remaining width and wraps within its own flex item, exactly as
  UX §6.6 requires.

## 11. Runtime signals

Rendered via `astro preview` on `127.0.0.1:22003` (port obtained with
`devstack port lease --slot story-007-audit --role web`, released afterwards).
Across all 16 capture runs:

- console errors: **0**
- failed requests / HTTP >= 400 (including the Material Symbols icon font):
  **0**

## 12. Entry-point reachability (AC-1)

Verified by real navigation from other pages, not by direct URL entry:

| # | Path | Result |
|---|---|---|
| 1 | `/` → desktop header nav item `Hỗ trợ` (1440, VI) | lands on `/support`, title correct, `h1` = `Câu hỏi thường gặp`, 6 `<details>`, 1 mailto anchor |
| 2 | `/about/` → footer Company-column `Support` (1440, EN) | lands on `/support`, `h1` = `Frequently asked`, 6 `<details>`, 1 mailto anchor |
| 3 | `/pets/` → mobile header `<select data-navm>` → `/support` (375, VI) | lands on `/support`, `h1` = `Câu hỏi thường gặp`, 6 `<details>`, 1 mailto anchor |

Active-state wiring on the rendered page: desktop nav pill carries
`aria-current="page"` with `background rgba(255,127,182,.16)` and
`color rgb(255,127,182)`; the mobile `<select>` value is `/support`.

PASS — the page renders full FAQ content from every entry point, not an empty
shell.

Screenshots: `visual-fidelity/entry-point-header-nav-1440.png`,
`visual-fidelity/entry-point-footer-link-1440.png`,
`visual-fidelity/entry-point-mobile-select-375.png`.

## 13. Visual audit (AC-6)

### 13.1 Markup / style equivalence against the design source

Inline `style="..."` attributes extracted in document order from
`Cupid Web.dc.html:615-635` (sc-for/sc-if wrappers dropped) and from `<main>`
in `web/dist/support/index.html` (duplicates collapsed, since the source's one
templated entry expands to six identical ones):

```
design inline styles (unique, in order): 12
built   inline styles (unique, in order): 12
MATCH [0] … MATCH [11]
inline-style mismatches: 0
```

All twelve declarations — the 860px/70-32-90 section, the mint eyebrow, the
Nunito 900 / 50px / -.03em heading, the `gap:10px` column, the
`--surf`/`--c09`/20px/`20px 24px` details, the `space-between` 16.5px summary,
the 20px `--acc-pink` icon, the 14px/1.65 `--c64` answer, the 34px-margin
gradient contact card, the 19px title, the 14px `--c62` subtext, and the
`--ink90`/`--bg` 999px pill — are byte-identical to the source. Nothing was
retyped, re-derived, or normalised.

Deliberate non-copies, all sanctioned by the phase/UX spec:
`aria-hidden="true"` on the decorative icon (UX §6.6), the two `class` hooks
used solely for the focus rings, and the two `:focus-visible` rules. No
`details[open]` icon rotation or other invented open-state treatment was added.

Marker suppression ships twice and both are the source's own rule: STORY-001's
verbatim `global.css:9` `summary::-webkit-details-marker{display:none}`, plus
this page's scoped `.cupid-faq-summary::-webkit-details-marker{display:none}`
as the phase task requires. Both confirmed present in the built HTML.

### 13.2 Rendered inspection

Screenshot matrix in
`data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-007/visual-fidelity/`:

- Closed state, 16 files:
  `implemented-support-{375,768,1024,1440}-{dark,light}-{vi,en}.png`
- Open state (entry 3), 4 files:
  `implemented-support-{375,768,1024,1440}-dark-vi-entry3-open.png`
- Component states: `implemented-support-focus-summary.png`,
  `implemented-support-focus-mailto.png`,
  `implemented-support-mailto-pill-hover.png`
- Entry points: `entry-point-header-nav-1440.png`,
  `entry-point-footer-link-1440.png`, `entry-point-mobile-select-375.png`

Findings:

- **1440, dark, VI** — mint `SUPPORT` eyebrow, 50px heading, six evenly spaced
  `--surf` cards with pink `expand_more` glyphs right-aligned, gradient contact
  card with the light solid pill. Matches §6.1-6.3 measurements.
- **1440, light, EN** — every token flips (light surfaces, dark `--ink` text,
  dark `--ink90` pill with light `--bg` label); all six questions and both
  contact strings render in English with no blanks.
- **Entry 3 open** — the answer reveals with the 12px top margin, the card
  grows, entries 1, 2, 4, 5, 6 stay closed and keep their geometry; layout does
  not break.
- **375** — single-column stack holds, the heading wraps to two lines at the
  spec-mandated 50px (no invented mobile downscale), question text wraps within
  its flex item with the icon staying at the row's top-right, and the contact
  card `flex-wrap`s to title/subtext above a full-height pill. No overflow.
- **768 / 1024** — same single-column behaviour; the 1024 capture also confirms
  the header is on STORY-001's mobile side of the 1024/1025 swap, unchanged by
  this page.

### 13.3 Scope note on the design-side render

The design-reference *render* half of the requirement-level visual audit is not
produced here. `Cupid Web.dc.html` is a `text/x-dc` component
(`:679-732`, `class Component extends DCLogic`) whose page state is driven by a
`startPage` prop through `<sc-if>` blocks; `isSupport` is `false` by default
(`:614`), so the canvas cannot be rendered into the Support state without the
DC preview runtime. STORY-001 produced its reference images with the sanctioned
bundle renderers `render-design-canvas.js` / `visual-capture.js`
(`STORY-001/visual-fidelity/visual-fidelity-report.md:26-42`); neither script is
present in this worktree or anywhere under `$HOME`, and this phase is explicitly
told not to author browser e2e specs. The implementation-side evidence above is
therefore paired with the byte-level style/string equivalence proof in §13.1
rather than with a design-side capture. The design-side render remains the
requirement-level `frontend-dev` `Mode: requirement-visual-audit` step, which
STORY-001's DEF-1 already flagged as needing an `app_render` block in
`data/devops/system/design-fidelity-config.json`.

## 14. Acceptance criteria summary

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 entry-point reachability | PASS | §12 |
| AC-2 six entries + heading | PASS | §2, §3 |
| AC-3 / BR-3 independent disclosure, no JS state | PASS | §7 |
| AC-4 / BR-2 contact block + exact `mailto:` | PASS | §4 |
| AC-5 bilingual completeness | PASS | §3 |
| AC-6 visual fidelity | PASS (implementation side; design-side render deferred, §13.3) | §13 |
| AC-7 per-page `<title>` | PASS | §5 |
| No file outside `web/src/pages/support.astro` modified | PASS | §6 |

## Entry Point Reachability

Reachable: YES

- Route path: `/support` (also served at `/support/`; both return HTTP 200)
- Built artifact: `web/dist/support/index.html`
- Source: `web/src/pages/support.astro`
- Route key: `support` (STORY-001 shared shell contract §2)

The route is reachable by real in-app navigation from three independent entry
points, each verified by clicking/selecting the control on another page and
asserting the resulting page, not by typing the URL:

| # | Entry control | Started from | Viewport / lang | Landed on | Rendered |
|---|---|---|---|---|---|
| 1 | header desktop nav item `Hỗ trợ` | `/` | 1440, VI | `/support` | `h1` = `Câu hỏi thường gặp`, 6 `<details>`, 1 `mailto:` anchor |
| 2 | footer Company-column link `Support` | `/about/` | 1440, EN | `/support` | `h1` = `Frequently asked`, 6 `<details>`, 1 `mailto:` anchor |
| 3 | header mobile `<select data-navm>` → option `/support` | `/pets/` | 375, VI | `/support` | `h1` = `Câu hỏi thường gặp`, 6 `<details>`, 1 `mailto:` anchor |

Active-state wiring on the landed page: the desktop nav pill carries
`aria-current="page"` with `background rgba(255,127,182,.16)` and
`color rgb(255,127,182)`; the mobile `<select>` reports value `/support`.

The page renders full FAQ content from every entry point — not an empty shell,
which is the specific failure AC-1 exists to exclude. Direct-URL entry was
additionally confirmed (`GET /support/` → 200) but is not relied on as the
evidence for this section.

Screenshots: `visual-fidelity/entry-point-header-nav-1440.png`,
`visual-fidelity/entry-point-footer-link-1440.png`,
`visual-fidelity/entry-point-mobile-select-375.png`.

Detail and method: §12.

## Story Runtime Startup Smoke

Runtime-Smoke: PASS

- Impacted runtime service/app: `web` — runtime registry id **`web-frontend`**
- Registry: `data/devops/system/runtime-command-registry.json`
- Type: frontend (static Astro, `output: "static"`); `dependsOn: []`,
  `requiredEnv: []`, `requiredSecrets: []` — no backend, DB, queue or cache to
  bring up (OQ-REQ006-2 RESOLVED)
- Scope: this story's own service only. No other service was started.

Startup command, taken from the registry `devCommand` plus the
`scripts/start-dev.sh` port contract recorded in the registry `notes` — the
port is read from a devstack lease, never Astro's default 4321 and never a
scanned port:

```
devstack port lease --slot story-007-smoke --role web --ttl-hours 1
  -> DEVSTACK_LEASE_WEB=22004

cd web && DEVSTACK_PORT_WEB=22004 npm run dev -- --port 22004 --host 127.0.0.1
  -> astro dev, listening on 127.0.0.1:22004
```

Readiness check, exactly as the registry declares it
(`readiness: { type: http, method: GET, path: "/", expectStatus: 200 }`):

| Probe | Expected | Actual |
|---|---|---|
| `GET http://127.0.0.1:22004/` | 200 | **200** |

Ready 0 s after the listener came up (first poll succeeded). Story route and
served-content assertions on the running server:

| Probe | Result |
|---|---|
| `GET /support/` | **200** |
| `GET /support` | **200** |
| `<details>` in the served HTML | **6**, none with a `name` attribute |
| `<title>` | `Hỗ trợ & FAQ · Support & FAQ — Cupid` |
| `href="mailto:hi@cupid.app"` present | yes |
| both `h1` strings present (VI + EN) | yes |

Teardown: the dev server was stopped (SIGTERM, exit 143 as expected for a
terminated long-running server) and the leased port released
(`devstack port lease --slot story-007-smoke --role web --release`
→ `ok released worktree lease(s) for cupid-apps/story-007-smoke: [22004]`).
Port `22004` confirmed free afterwards.

Note on the phase file: `phase-P1-support-faq-page.md` §1B records
`Startup Smoke: NOT_APPLICABLE` / `Readiness Check: N/A`. That judgement was
made before the runtime registry entry for `web-frontend` was consulted; the
registry does declare a concrete HTTP readiness contract, so the smoke was run
for real rather than waived. No `Runtime-Smoke: WAIVED` line is needed in
`story_master.md`.

## Test scope levels not applicable

The `web/` workspace has no unit-test framework and this phase does not
introduce one (phase §6 Verification strategy). No unit, integration, contract
or e2e level applies. Browser interaction above was screenshot- and
assertion-based capture, not an authored e2e spec.

## Patch log

**2026-08-21 — evidence-only patch (ACT-1, ACT-2 from story review)**

Scope: this file only. No file under `web/` changed; `web/src/pages/support.astro`
is byte-identical to the reviewed commit `a0807a8`.

- ACT-1: added the canonical `## Entry Point Reachability` section above, with
  the `Reachable: YES` line and the concrete `/support` path. The underlying
  verification was already performed and recorded in §12; this patch puts it in
  the canonical form the gate reads.
- ACT-2: added the canonical `## Story Runtime Startup Smoke` section above.
  The smoke was **newly executed** for this patch (it was not part of the
  original run, which only started a preview server for the visual audit).

Regression re-check after the patch, run from `web/` with Node `v25.2.1`, full
output read:

```
npm run check
> astro check
Result (27 files):
- 0 errors
- 0 warnings
- 0 hints

npm run build
> astro build
[build] output: "static"
generating static routes
  ├─ /about/index.html   ├─ /blog/index.html    ├─ /legal/index.html
  ├─ /pets/index.html    ├─ /share/index.html   ├─ /support/index.html
  ├─ /zodiac/index.html  ├─ /index.html
[build] 8 page(s) built in 448ms
[build] Complete!
```

No regression.

Out of scope for this patch, by explicit Scrum Master instruction: the rendered
design-reference comparison for AC-6. That is a requirement-wide tooling gap
tracked in
`data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/design-fidelity-tooling-fix.md`,
to be re-reviewed separately once the tooling fix lands. §13.3 above states the
same limitation from the implementation side and still stands.
