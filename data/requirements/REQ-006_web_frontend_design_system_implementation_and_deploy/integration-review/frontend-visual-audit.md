# Frontend Requirement Visual Audit — REQ-006

Mode: `requirement-visual-audit` (audit-only, no code changed)
Scope: REQ-006 requirement level, INT-3 from
`integration-review/review-report.md` (`Outcome: PATCH_REQUIRED`)
Run: `RUN-REQ-006_web_frontend_design_system_implementation_and_deploy-NONE-frontend-dev`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-006_web_frontend_design_system_implementation_and_deploy`
BaseHead / worktree HEAD: `33e8e178d59d54da3a673811c59042c649ce2ed8`
App under test: `http://127.0.0.1:21522/` (Astro `preview` of this HEAD, started by
Scrum Master; not started, stopped, or restarted by this audit)
Date: 2026-08-22

Outcome: **PASS WITH ONE BLOCKING FINDING** — all 6 rendered-vs-rendered fidelity
comparisons PASS; one previously unrecorded cross-screen defect (`A-1`) is raised
for routing.

## Method

- Playwright (`.ai-team-bundle/tooling/playwright`) driving headless Chromium.
- 8 routes × 3 breakpoints (375 / 768 / 1280) = 24 bounded-viewport captures.
  Viewport height was set to `width × 1.6` so each capture is dimensionally
  identical to the matching design reference (375×600, 768×1229, 1280×2048).
  No full-page captures were taken.
- Per-page DOM probe: title, `<html lang>`, header/footer geometry, nav and
  footer link sets, visible controls, broken images, document scroll width,
  every element whose border box escapes the viewport, and heading outline.
- Pixel comparison against the 18 committed design references with a
  purpose-written PNG decoder (inflate + unfilter, no third-party image
  dependency): per-pixel max-channel delta, ink row/column profiles, content
  edge detection, and a vertical alignment search.
- Verification command run in this session (no source files were modified):
  `npm run check` (`astro check`) under Node v22.17.1 →
  **52 files, 0 errors, 0 warnings, 0 hints**.

Evidence rigor follows the `reviewer3` / `BLK-VF-1` cycle in
`STORY-002/review/review-report.md:21-43` — derived slot geometry and content
edge positions compared numerically between reference and implementation, not
impressionistic side-by-side viewing.

## Part A — Cross-screen audit (8 screens)

### Shared shell consistency: PASS

Measured identically on all 8 screens at every breakpoint:

- Header: `x=0 w=<viewport> h=72` at 375/768, `h=70` at 1280; `position: sticky`.
- Header nav: the same 7 destinations plus brand mark and CTA, in the same order,
  on all 8 screens.
- Footer: `h=281`, full-bleed, the same 10 links in the same order on all 8
  screens.
- Theme toggle and VI/EN language toggle present in the DOM on all 8 screens.
- Active-page marker: `aria-current="page"` set on the matching nav item.

### Runtime health: PASS

| Check | Result |
|---|---|
| HTTP status, all 8 routes | 200 |
| Horizontal page scroll (`scrollWidth − innerWidth`) | 0 at 375, 768 and 1280 on all 8 screens |
| Broken images (`complete && naturalWidth === 0`) | 0 (all art is inline SVG/CSS; `document.images.length === 0`) |
| Console errors / page errors | none on any of the 24 loads |

### Theme and language behaviour: PASS

Verified as a cross-screen flow (not re-testing per-screen behaviour already
covered by the story reviews):

- Clicking `EN` sets `<html lang="en">`, flips `aria-pressed` on both toggle
  buttons, swaps all 7 nav labels (`Trang chủ→Home`, `Hoàng đạo→Zodiac`, …) and
  the page `<h1>`, and persists `cupid-web-lang=en` to `localStorage`.
- Theme toggle persists `cupid-web-theme=light` and repaints the whole shell.
- Both selections survive full navigation to `/pets/`, `/zodiac/`, `/blog/` and
  `/legal/`: `lang=en` and the light palette were still applied on each, with the
  localised `<h1>` ("Which one is yours?", "Are the stars on your side today?",
  "Notes on loving someone for a long time", "Privacy & Terms").
- Evidence: `screenshots/shell-light-theme-en-1280.png`.

### A-1 — BLOCKING — header language toggle and app CTA are clipped and unreachable below 600px, on all 8 screens

At every viewport narrower than ~543px the header's right-hand control cluster is
laid out past the viewport edge and clipped, so the **VI/EN language toggle and
the "Tải app" CTA are not visible and cannot be reached with a pointer** on any
phone width, on all 8 screens.

Measured right edges of the four header controls, sweeping the viewport
(all values in CSS px, constant because the cluster does not reflow below 600px):

| Viewport | theme | VI | EN | CTA | clipped |
|---|---|---|---|---|---|
| 320 | 364 | 410 | 446 | 543 | theme, VI, EN, CTA |
| 360 | 364 | 410 | 446 | 543 | theme, VI, EN, CTA |
| 375 | 364 | 410 | 446 | 543 | VI, EN, CTA |
| 390 | 364 | 410 | 446 | 543 | VI, EN, CTA |
| 414 | 364 | 410 | 446 | 543 | EN, CTA |
| 430 | 364 | 410 | 446 | 543 | EN, CTA |
| 480 | 364 | 410 | 446 | 543 | CTA |
| 540 | 364 | 410 | 446 | 543 | CTA |
| 600 | 389 | 435 | 471 | 568 | — |
| 768 | 557 | 603 | 639 | 736 | — |

Mechanism, confirmed by computed style rather than inference:

- The cluster is a normal in-flow row inside the header; at 375 it occupies
  `x = 333 … 552`, i.e. 177px beyond the 375px viewport.
- The header's own `overflow` is `visible`, but its **parent `div` has
  `overflow-x: hidden`**. That container therefore clips the cluster and — because
  `overflow: hidden` cannot be scrolled by user gesture — there is no affordance
  to bring the controls back. Page-level `scrollWidth − innerWidth` is 0, which is
  why the existing smoke checks did not catch this.
- The controls are genuinely rendered, not suppressed: `display: block`,
  `visibility: visible`, `opacity: 1`, `pointer-events: auto`, no `inert`, no
  `aria-hidden`, `offsetParent !== null`.

This is not the codebase's intended mobile-collapse pattern. The desktop `<nav>`
is correctly removed at mobile (`display: none`, `offsetParent === null`, absent
from the tab order) and replaced by a `<select aria-label="Điều hướng">` carrying
all 7 destinations. The theme toggle is likewise correctly kept. Only the VI/EN
pair and the CTA were left overflowing — a gap in the mobile header, not a
deliberate hide.

Two secondary consequences:

- **Keyboard-only reachability with a layout side effect.** Tabbing from the theme
  toggle does move focus to `VI`, `EN` and the CTA, because the browser scrolls
  the clipped container programmatically. That shifts the whole header 177px left,
  pushing the brand mark and the nav `<select>` out of view. So the controls are
  reachable, but only via a transition that visibly breaks the header.
- **No mobile language switching.** With the toggle unreachable by pointer, a
  phone user cannot change language at all; `localStorage.cupid-web-lang` can only
  be set from ≥600px.

Evidence: `screenshots/finding-A1-header-clipped-375.png` (logo + `<select>` +
theme toggle only — VI/EN and CTA absent) versus
`screenshots/finding-A1-header-ok-768.png` (all controls present).

Relationship to the design source: the design canvas has no mobile header at all
(see Part B), and `design-reference-*-375.png` clips its own VI/EN and CTA the
same way. But the implementation already *added* a mobile header the design does
not have, so this is an incomplete implementation-side responsive design rather
than faithful reproduction. It needs a UI/UX decision on the intended mobile
placement before it is coded.

Routing: UI/UX Designer for a mobile header spec (where VI/EN and the CTA belong
below 600px), then Frontend Developer. Not fixed here — this mode is audit-only.

### Dismissed observation — dual-locale text is not duplicated

A raw `textContent` probe reports nav and footer labels as `"Trang chủHome"`,
`"Hoàng đạoZodiac"`, and the like, which looks like both locales rendering at
once. It is not a defect. Each label is two sibling `<span>`s, `data-vi` and
`data-en`, and the inactive one is `display: none` — confirmed on
`header nav a`: span 1 `{display: "inline", w: 62}`, span 2
`{display: "none", w: 0}`. `display: none` is excluded from the accessible name,
so the accessible name is `"Trang chủ"` alone. Only one locale is ever painted or
announced. Recorded here because the concatenated strings appear throughout the
raw probe data and would otherwise look alarming on re-inspection.

## Part B — Rendered-vs-rendered fidelity, 6 screens × 3 breakpoints

Compares the 18 committed `design-reference-<screen>-{375,768,1280}.png` against
implementation captures of identical dimensions. STORY-001 (home) and STORY-002
(pets) are out of scope here — both already carry real rendered-vs-rendered
evidence at story level.

### 1280 — all 6 PASS, essentially pixel-identical

| Screen | changed px (>24/255 max-channel) | mean delta | content edges ref → impl | ink bands ref/impl |
|---|---|---|---|---|
| zodiac | 0.00% | 0.03 | `39..1279` → `39..1279` | 27 / 27 |
| share | 0.15% | 0.22 | `27..1279` → `27..1279` | 23 / 23 |
| blog | 0.04% | 0.08 | `39..1279` → `39..1279` | 23 / 22 |
| about | 0.00% | 0.03 | `39..1279` → `39..1279` | 31 / 31 |
| support | 0.00% | 0.03 | `0..1279` → `0..1279` | 20 / 19 |
| legal | 0.01% | 0.04 | `0..1279` → `0..1279` | 24 / 24 |

Content column left/right edges match to the pixel on all six. Worst-case rows
peak at 1–2% changed pixels on zodiac/blog/about/support/legal (anti-aliasing on
decorative starfield glyphs) and 5–6% on `share` rows 778–823, which is a single
gradient band. No structural, spacing, wrapping, or sprite-slot deviation.

Specifically checked for the `BLK-VF-1` defect class (a `dc-import` sprite slot
collapsing under flex pressure): no sprite or icon slot on any of the six screens
differs in width or position from its reference at 1280.

### 768 — all 6 PASS, after a uniform +76px header offset

Raw diff at zero offset is 15–31%. A vertical alignment search finds that a single
constant shift of **exactly +76px, identical on all six screens**, collapses it:

| Screen | diff at 0px | best shift | residual diff |
|---|---|---|---|
| zodiac | 30.99% | +76px | 1.22% |
| share | 24.53% | +76px | 1.65% |
| blog | 27.43% | +76px | 1.32% |
| about | 19.33% | +76px | 1.29% |
| support | 23.56% | +76px | 1.45% |
| legal | 15.40% | +76px | 1.23% |

The offset is a defect in the reference, not the implementation. `Cupid Web.dc.html`
has no responsive breakpoint, so when the renderer narrows the canvas to 768 the
desktop nav simply wraps: `design-reference-support-768.png` shows the 7 nav links
reflowed onto 3 rows, making the reference header ~148px tall against the
implementation's 72px — a 76px delta that propagates to every element below it.
Once that single offset is removed, body content agrees to within 1.2–1.7%, which
is the same anti-aliasing floor seen at 1280.

That the identical 76px value recovers all six independent screens is itself the
proof: a real fidelity defect would produce screen-specific offsets, not one
constant.

### 375 — reference is not a usable baseline; implementation independently verified

| Screen | diff at 0px | best shift | residual diff |
|---|---|---|---|
| zodiac | 53.53% | +100px | 42.95% |
| share | 50.97% | +120px | 42.49% |
| blog | 52.87% | +120px | 43.60% |
| about | 55.80% | +98px | 43.55% |
| support | 56.58% | +120px | 37.98% |
| legal | 50.09% | +120px | 38.96% |

No offset rescues 375, because at this width the design canvas degenerates. In
`design-reference-legal-375.png` the non-responsive desktop nav collapses into a
**vertical stack of 7 links** and the header consumes rows 0–432 (measured header
boundary: 432–462px across the six references, against 72px in the
implementation); the canvas also clips its own VI/EN and CTA at the right edge.
There is no mobile design in the source to be faithful *to*.

Verdict per screen at 375: **NOT COMPARABLE (reference invalid)** — recorded as
such rather than as PASS or FAIL, because scoring the implementation against a
degenerate reference would be meaningless in either direction. The implementation
was instead verified on its own terms at 375 and is sound: proper 72px mobile
header with a `<select>` nav, zero horizontal page overflow, no broken or
overlapping components, correct heading hierarchy and content order on all six
screens. The one exception is `A-1` above.

This is the same class of permanent gap already recorded in
`STORY-003/visual-fidelity/visual-fidelity-report.md:103-107` and
`design-fidelity-tooling-fix.md` (Fix 2, BLOCKED), now measured rather than
asserted.

### Part B verdict

| Screen | 375 | 768 | 1280 | Overall |
|---|---|---|---|---|
| zodiac | not comparable | PASS | PASS | **PASS** |
| share | not comparable | PASS | PASS | **PASS** |
| blog | not comparable | PASS | PASS | **PASS** |
| about | not comparable | PASS | PASS | **PASS** |
| support | not comparable | PASS | PASS | **PASS** |
| legal | not comparable | PASS | PASS | **PASS** |

The INT-2 evidence gap is closed: all six screens whose story-level evidence had
been spec-transcription only now have real rendered-vs-rendered comparison at the
two breakpoints where the reference is valid, and both are clean.

## Carried-forward findings

### V-1 (STORY-003) — CONFIRMED, reproduces at 375px only, stays deferred

`STORY-003/visual-fidelity/visual-fidelity-report.md:86-101` predicted that the
daily-compatibility card's inner sign row overflows at 375. It reproduces, and the
measurements match the report's arithmetic:

| Viewport | row box | available | cell boxes (86 / 104 / 86) | result |
|---|---|---|---|---|
| 375 | `x=71..304` (w=233) | 233px | `28..114`, `136..240`, `262..348` | **overflows both sides** |
| 768 | `x=71..697` (w=626) | 626px | `224..310`, `332..436`, `458..544` | fits |
| 1280 | `x=79..622` (w=543) | 543px | `191..277`, `299..403`, `425..511` | fits |

The row is `display: flex; gap: 22px; flex-wrap: nowrap`, so it requires
86 + 104 + 86 + 2×22 = **320px** against 233px available. Because the row is
centred, the 87px shortfall spills symmetrically: the right-hand `Kim Ngưu` cell
ends at `x=348` against the card's padding-box right edge of `343` (clipped by
5px), and the left `Cự Giải` cell starts at `x=28` against the card's left edge of
`32` (clipped by 4px). Page horizontal overflow remains 0, matching the story
report. Visible in `screenshots/finding-V1-zodiac-daily-card-375.png`: the right
sign icon's circle is cut by the card edge and its label sits flush against it.

Two refinements to the original record:
- Measured inner width is **233px**, not the 235px derived in the story report
  (the 2px is the card border) — the arithmetic and conclusion are unaffected.
- The clipping is **bilateral**, not right-side only. The report describes the
  right icon; the left cell is also clipped, by 4px.

Assessment unchanged: this is verbatim design-source behaviour from
`Cupid Web.dc.html:293`, and the 375px design reference exhibits the same
degenerate header/no-mobile-design problem, so there is no mobile spec to fix it
against. Recommendation: keep deferred and fold it into the **same UI/UX mobile
pass as `A-1`** — both are the single root cause "the design source has no mobile
breakpoint". Fixing it in isolation (e.g. adding `flex-wrap` below 375) would be a
unilateral deviation from the locked design source and should not be done by a
developer without a UX decision.

### D-INT-1 — CONFIRMED and materially wider than recorded

`integration-review/review-report.md:320-329` recorded 8 inconsistent `<title>`
patterns. All 8 reproduce exactly as measured there. The audit adds a second,
unrecorded dimension: **the titles are only partially localised**, so the language
toggle leaves most browser tabs in the wrong language.

| Route | title @ `lang=vi` | title @ `lang=en` | localises? |
|---|---|---|---|
| `/` | `Cupid` | `Cupid` | n/a (brand only, no page name) |
| `/pets/` | `Pets — Cupid` | `Pets — Cupid` | no — English even in VI |
| `/zodiac/` | `Hoàng đạo — Cupid` | `Zodiac — Cupid` | **yes** |
| `/share/` | `Cupid — Ghép đôi` | `Cupid — Ghép đôi` | no — and order is reversed |
| `/blog/` | `Cupid Journal — Cupid` | `Cupid Journal — Cupid` | no — brand appears twice |
| `/about/` | `Giới thiệu & Bộ nhận diện thương hiệu — Cupid` | unchanged | no |
| `/support/` | `Hỗ trợ & FAQ · Support & FAQ — Cupid` | unchanged | no — both locales in one tab title |
| `/legal/` | `Quyền riêng tư & Điều khoản — Cupid` | `Privacy & Terms — Cupid` | **yes** |

Only 3 of 8 titles respond to the language toggle (`/zodiac/`, `/legal/`, and
trivially `/`), while every visible `<h1>` on all 8 does. A user browsing in
English sees English content under a Vietnamese tab title on 4 screens.

Still correctly classified as deferred — no story AC covers titles and the design
source does not specify them — but the recommended fix is now larger than a
cosmetic pattern sweep: it needs one localised title convention
(`<localised page name> — Cupid`) wired to the same locale state as the body copy.
Routing: Product Owner to set the convention, then a single small frontend story.

## Screenshots

All under `integration-review/screenshots/` (30 files, ~11MB, comparable to the
6.8MB/18-file design-reference set already committed):

- `impl-<screen>-{375,768,1280}.png` — 24 bounded-viewport captures, dimensionally
  matched to the design references.
- `finding-A1-header-clipped-375.png`, `finding-A1-header-ok-768.png` — `A-1`.
- `finding-V1-zodiac-daily-card-{375,1280}.png` — `V-1`.
- `shell-light-theme-en-1280.png` — theme + language cross-screen persistence.

## Summary for routing

| Id | Severity | Owner | Summary |
|---|---|---|---|
| `A-1` | **BLOCKING** | UI/UX Designer → Frontend Developer | Language toggle and app CTA clipped and pointer-unreachable below 600px on all 8 screens |
| `V-1` | Deferred (confirmed) | UI/UX Designer | Daily-compatibility sign row overflows its card by 5px right / 4px left at 375px; design-source-inherited |
| `D-INT-1` | Deferred (confirmed, widened) | Product Owner → Frontend Developer | 8 inconsistent `<title>` patterns; only 3 of 8 localise with the language toggle |

`V-1` and `A-1` share one root cause — the locked design source has no mobile
breakpoint — and should be handled in a single UI/UX mobile pass.

No other blocking visual breakage was found. No source file was modified by this
audit.

FRONTEND_VISUAL_AUDIT_COMPLETE: YES
