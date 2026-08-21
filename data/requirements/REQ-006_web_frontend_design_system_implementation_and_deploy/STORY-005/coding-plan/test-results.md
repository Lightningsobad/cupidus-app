# STORY-005 Test Results — Phase P1 Blog Page Body

- Lane: Frontend
- Phase: P1 (`phase-P1-blog-page-body.md`)
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-005`
- Branch: `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-005`
- BaseHead: `15af9b1d99e10cfdcaf7f6b1862d898c35906ee9`
- Node runtime used: `v22.17.1` (machine default `v20.20.2` is below the `>=22.12.0` engine floor)
- Date: 2026-08-21

## 1. Build And Type-Check Gate

Command (from `web/`): `npm run check && npm run build`

```
> astro check
21:53:48 [types] Generated 341ms
21:53:48 [check] Getting diagnostics for Astro files in .../web...
Result (29 files):
- 0 errors
- 0 warnings
- 0 hints

> astro build
21:53:53 [build] output: "static"
21:53:53 [build] mode: "static"
21:53:53 [vite] ✓ built in 485ms
 generating static routes
   ├─ /about/index.html (+9ms)
   ├─ /blog/index.html (+5ms)
   ├─ /legal/index.html (+3ms)
   ├─ /pets/index.html (+2ms)
   ├─ /share/index.html (+2ms)
   ├─ /support/index.html (+3ms)
   ├─ /zodiac/index.html (+4ms)
   ├─ /index.html (+4ms)
21:53:53 [build] 8 page(s) built in 596ms
21:53:53 [build] Complete!
```

Both commands exited 0. The one build warning (`"matchHostname" … imported from
external module … but never used in node_modules/astro/dist/assets/utils/index.js`)
originates inside `node_modules/astro`, not this story's code, and is present on
the unmodified baseline.

## 2. Forbidden-Token Grep Over The Story Diff

Checked tokens: `fetch(`, `href="#"`, `tabindex`, `action=`, `localStorage`.

| File | Forbidden tokens | Interactive elements present |
|------|------------------|------------------------------|
| `web/src/pages/blog.astro` | ABSENT (all 5) | `<button>` ×1 — the newsletter Subscribe control required by AC-6 |
| `web/src/components/blog/ArticleCard.astro` | ABSENT (all 5) | none |
| `web/src/data/blog-content.ts` | ABSENT (all 5) | none |
| built `web/dist/blog/index.html`, `<main>` slice | ABSENT (all 5) | `<button>` ×1 (same Subscribe control) |

The whole-document build output does contain `localStorage` and `<a `, but only
outside `<main>`: they come from the STORY-001 shell (theme/lang boot script,
header nav, footer links), which this story does not modify. Scoping the check to
the `<main>` slice isolates this story's own body, which is clean.

No `<form>` element exists on the page, so there is no submit path to prevent and
no `preventDefault()` handler is needed. The Subscribe control is
`<button type="button">` with no listener.

## 3. Write-Scope Containment

`git status --porcelain` in the worktree after the run:

```
 M web/src/pages/blog.astro
?? web/src/components/blog/
?? web/src/data/blog-content.ts
```

`git diff 15af9b1d99e10cfdcaf7f6b1862d898c35906ee9 --stat -- web/`:

```
 web/src/pages/blog.astro | 61 ++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 59 insertions(+), 2 deletions(-)
```

Exactly the three declared Write Scope files. No shell, token, or global-style
file is touched.

Note: `npm install` (needed to provision `node_modules` under Node 22) added an
`engines` block to `web/package-lock.json`, a file outside Write Scope. That
side effect was reverted with `git checkout -- web/package-lock.json`; the
`git status` above confirms the lockfile is back to its committed state.

## 4. Built Output Assertions

From `web/dist/blog/index.html`:

| Check | Result |
|-------|--------|
| `<title>` | `Cupid Journal — Cupid` — Blog-specific, not the `'Cupid'` shell default (AC-9) |
| `data-vi` / `data-en` spans inside `<main>` | 60 total document-wide, 38 / 38 inside `<main>` — perfectly balanced, every localized string ships both halves |
| Heading levels inside `<main>` | `h1`=1, `h2`=1, `h3`=6 — no skipped level |
| `aria-hidden="true"` inside `<main>` | 8 — 6 card avatar swatches + featured avatar swatch + the Sua sprite wrapper |
| `aria-current="page"` | 1, on the header "Blog" nav item |

The 38 localized pairs decompose as: 2 intro (H1, paragraph) + 4 topic pills +
5 featured panel (eyebrow, category, H2, excerpt, read-time unit) + 24 grid
(6 cards × category/title/excerpt/read-time unit) + 3 newsletter (heading,
subcopy, button label).

## 5. Browser Behavioral Checks

Runtime: `astro preview` on `127.0.0.1:22004` (devstack worktree lease
`slot=story-005-blog role=preview`, released after the run), driven headless with
Playwright/Chromium. Full harness output below.

### 5.1 Entry-Point Reachability (AC-1)

Reached `/blog` by activating the nav control, not by typing the URL.

| Path | Result |
|------|--------|
| Desktop 1440px: click header nav "Blog" | navigated to `http://127.0.0.1:22004/blog` |
| Active pill treatment | `background: rgba(255, 127, 182, 0.16)`, `color: rgb(255, 127, 182)` — matches the §6.1 active-item rule |
| `aria-current="page"` | present on the "Blog" nav item |
| Mobile 375px: header `<select data-navm>` → option "Blog" | navigated to `http://127.0.0.1:22004/blog`; the mobile select is visible and the desktop nav is hidden at 375px |
| Mobile select value while on `/blog` | `/blog` — the correct option is preselected |
| `document.title` | `Cupid Journal — Cupid` |

### 5.2 Responsive Reflow (AC-5, §6.6)

Measured computed `grid-template-columns` and document overflow per viewport.

| Viewport | Featured panel columns | Article grid columns (card width) | Horizontal overflow |
|----------|------------------------|-----------------------------------|---------------------|
| 375px | `293px` (1 column) | `311px` (1 column, 311px card) | 0px |
| 768px | `339px 339px` | `343px 343px` (343px card) | 0px |
| 1024px | `467px 467px` | `308px 308px 308px` (308px card) | 0px |
| 1440px | `587px 587px 0px` | `388px 388px 388px` (388px card) | 0px |

Neither grid drops below its `minmax` floor. At 375px the floor resolves through
`min(320px,100%)` / `min(300px,100%)` to the container width, which is exactly
why both collapse cleanly to one column with zero overflow instead of
overflowing at a fixed 320/300px. The trailing `0px` track at 1440px is standard
`auto-fit` empty-track collapsing for the featured panel's two cells; both cells
still fill the panel, and the declaration is verbatim from
`Cupid Web.dc.html:466`.

### 5.3 Element Counts (AC-3, AC-4, AC-5)

| Check | Result |
|-------|--------|
| Topic pills rendered | 4, in source order (AC-3) |
| Article cards rendered | 6, from the `posts` seed array (AC-5) |
| Featured panels (`<h2>` in `<main>`) | 1, built from the design source's hardcoded content, not from `posts` (AC-4) |

### 5.4 VI ↔ EN Toggle (AC-8)

Toggled via the real header `[data-set-lang]` buttons.

| Locale | Visible localized spans in `<main>` | Blank or unpaired strings |
|--------|------------------------------------|---------------------------|
| `vi` | 38 | none |
| `en` | 38 | none |

The check asserts two things per locale: no visible `[data-vi]`/`[data-en]`
element has empty text content, and every `[data-vi]` span has an immediately
following `[data-en]` sibling. Both pass in both locales — no string disappears
on toggle.

### 5.5 Tab Order And Focus (AC-3, AC-6, §6.6)

| Check | Result |
|-------|--------|
| Tabbable elements inside `<main>` | `["input[email]", "button[button]"]` — exactly the two newsletter controls |
| Real Tab walk from the newsletter input | `input[email] (in main)` → `button[button] (in main)` → `a (outside main)` — Tab leaves `<main>` immediately after Subscribe |
| Topic pills / article cards that are tabbable | 0 — none is an `<a>`/`<button>` and none carries `tabindex` |
| Focus ring, email input | `outline: solid 2px rgb(255, 127, 182)`, `outline-offset: 2px`, `:focus-visible` matched |
| Focus ring, Subscribe button | `outline: solid 2px rgb(255, 127, 182)`, `outline-offset: 2px`, `:focus-visible` matched |

The prototype ships `outline:none` inline on the input and no focus style on
either control; the scoped `.cupid-newsletter-field:focus-visible` rule restores
the ring uiux-spec §6.6 requires, using `!important` only because the inline
`outline:none` would otherwise outrank it.

### 5.6 Subscribe Is Inert (AC-6)

Clicked the Subscribe button and pressed Enter on it while instrumenting
navigation and network traffic.

| Check | Result |
|-------|--------|
| URL after click + Enter | unchanged |
| Page reload | none — a `window.__navMarker` set before the interaction survived it |
| Network requests fired | 0 |

### 5.7 Hover States (§6.2.2, §6.2.4)

| Element | Before hover | After hover |
|---------|--------------|-------------|
| Topic pill border | `rgba(247, 238, 251, 0.14)` | `rgba(255, 127, 182, 0.5)` |
| Article card border / transform | `rgba(247, 238, 251, 0.1)` / `none` | `rgba(255, 127, 182, 0.36)` / `matrix(1, 0, 0, 1, 0, -4)` (`translateY(-4px)`) |

Both match the design source's `style-hover` declarations at `:462` and `:485`.

### 5.8 Anchor Values Spot-Check (UI-Fidelity-AC-7)

Computed styles against the §6.7 anchor list.

| Property | Measured | §6.7 anchor |
|----------|----------|-------------|
| Page container padding | `70px 32px 90px` | `70px 32px 90px` |
| Page container max-width | `1200px` | `1200px` |
| H1 | `52px` / `900` / `-1.56px` | Nunito 900 52px, `letter-spacing:-.03em` (= -1.56px at 52px) |
| Featured H2 | `32px` / `900` | Nunito 900 32px |
| Card title | `20px` / `800` | Nunito 800 20px |
| Card border-radius | `26px` | `26px` |
| Card padding | `26px` | `26px` |

Full pixel fidelity remains the requirement-level visual audit's gate, not this
phase's.

### 5.9 Runtime Signals

| Signal | Result |
|--------|--------|
| Console errors and warnings on `/blog` | none |
| Failed network requests | none |

## 6. Acceptance Criteria Coverage

| AC | Evidence |
|----|----------|
| AC-1 Page reachable | §5.1 — desktop nav click and mobile `<select>` both land on `/blog`; active pill treatment and `aria-current="page"` confirmed; console clean per §5.9 |
| AC-2 Page intro | §4 — eyebrow, `<h1>`, and paragraph render with the literal VI/EN copy transcribed verbatim from `Cupid Web.dc.html:456-458` |
| AC-3 Topic pills presentational | §5.3 (4 pills, source order), §5.5 (0 tabbable), §5.7 (hover styling preserved) |
| AC-4 Featured panel hardcoded | §5.3 — 1 panel, authored inline in `blog.astro` from `:466-481`, not derived from `posts`; Sua sprite mounted at 180×180 |
| AC-5 Article grid | §5.3 (6 cards), §5.2 (`auto-fit` never below `minmax` floor at any of the four viewports) |
| AC-6 Newsletter presentational | §5.5 (real `<input type="email">` + `<button>`, both keyboard-reachable with visible focus rings), §5.6 (no navigation, no reload, 0 requests) |
| UI-Fidelity-AC-7 | §5.8 anchor spot-check; full audit deferred to the requirement visual-audit gate |
| AC-8 Copy fidelity | §4 (38/38 balanced pairs), §5.4 (no blank or unpaired string in either locale) |
| AC-9 Blog-specific `<title>` | §4 — `Cupid Journal — Cupid` |
| Diff touches only the three phase files | §3 |

## 7. Deviations And Judgment Calls

- **No `<form>` wrapper.** The phase allows a `<form>` whose submit handler calls
  `preventDefault()`. Omitting the form entirely reaches the same AC-6 outcome
  with no script at all, and keeps `action=` out of the diff by construction.
  `<input type="email">` still gives the visitor the native email keyboard and
  autofill, which is what §6.3 asks for.
- **`aria-label="Email"` on the newsletter input.** The design source has no
  `<label>` and no accessible name for the field; the placeholder alone is not an
  accessible name. This adds no visible markup and no behavior.
- **`margin:0` on the card `<h3>`.** The design source's card title is a `<div>`
  with no margin; promoting it to a real heading for §6.6's level requirement
  reintroduces the UA default margin, which `margin:0` removes to keep the
  card's `gap:12px` rhythm byte-identical to the source.
- **`aria-hidden="true"` on the Sua sprite wrapper.** `SuaSprite.astro` sets its
  own `role="img" aria-label="Sua"`; the illustration is decorative in this
  panel, so the wrapper hides it from the accessibility tree without editing the
  shared sprite component.

## 8. Status

All required gates pass. No blockers.
