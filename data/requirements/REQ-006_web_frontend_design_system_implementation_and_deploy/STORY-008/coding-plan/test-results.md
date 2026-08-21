# Test Results — STORY-008 Phase P1 (Legal Page Body, Localized Title, Entry Point)

- Story: REQ-006 / STORY-008
- Phase: P1 (`phase-P1-legal-page-body-and-entry-point.md`)
- Lane: Frontend
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-008`
- BaseHead: `bc499987466ae3cbacf8f7b9157a6b9a3aab857c`
- Runtime service: `web-frontend` (`web/`), static Astro build
- Node: `v22.17.1` (package.json `engines.node >= 22.12.0`; the shell default
  `v20.20.2` fails the engine gate, so every command below was run with
  `PATH="$HOME/.nvm/versions/node/v22.17.1/bin:$PATH"`)
- Date: 2026-08-21

## 1. Build / Type-Check Gate

| # | Command (cwd `web/`) | Exit | Result |
|---|----------------------|------|--------|
| 1 | `npm ci` | 0 | 331 packages installed (`node_modules` was absent in this fresh worktree) |
| 2 | `npm run check` (`astro check`) | 0 | 27 files: **0 errors, 0 warnings, 0 hints** |
| 3 | `npm run build` (`astro build`) | 0 | 8 pages built in 811ms, incl. `/legal/index.html`; `Complete!` |
| 4 | `npm run check` (re-run after the BLOCK-2/BLOCK-3 evidence patch) | 0 | 27 files: **0 errors, 0 warnings, 0 hints** — no regression |
| 5 | `npm run build` (re-run after the BLOCK-2/BLOCK-3 evidence patch) | 0 | 8 pages built in 661ms, incl. `/legal/index.html`; `Complete!` — no regression |

Rows 4-5 were re-run after the review patch that added the two evidence
sections below. That patch touched no file under `web/`, so the build gate
result is unchanged; the re-run is a regression confirmation, not a new gate.

`npm run build` emitted one pre-existing upstream Vite warning about unused
`@astrojs/internal-helpers/remote` re-exports inside `node_modules/astro`. It is
not produced by this story's code and is present on every page build.

## 2. Diff Scope Check

```
git -C <worktree> diff --name-only bc499987466ae3cbacf8f7b9157a6b9a3aab857c
web/src/pages/legal.astro

git -C <worktree> status --porcelain
 M web/src/pages/legal.astro
```

PASS — `web/src/pages/legal.astro` is the only changed file. No shell file
(`SiteLayout.astro`, `SiteHeader.astro`, `SiteFooter.astro`, `tokens.css`,
`global.css`, `theme-lang-boot.ts`, `site-nav.ts`) appears in the diff, so the
STORY-001 shell contract (`contract-summary.md` §6) is intact and the other
seven pages' fidelity evidence is not invalidated. `dist/` and `node_modules/`
are gitignored and do not enter the diff.

## 3. Static Build-Output Checks (48 assertions, 48 PASS / 0 FAIL)

Run against `web/dist/legal/index.html` and `web/dist/index.html`.

### 3.1 Ten VI/EN Section-String Checklist (AC-3)

Every string below was asserted present, character-for-character, in the built
HTML, against `../ux/uiux-spec.md` §6.2 (source data `Cupid Web.dc.html:823-829`).
Order is source order.

| # | Field | Locale | String | Present |
|---|-------|--------|--------|---------|
| 1 | Section 1 title | VI | `Chúng mình lưu gì` | PASS |
| 2 | Section 1 title | EN | `What we store` | PASS |
| 3 | Section 2 title | VI | `Ai xem được` | PASS |
| 4 | Section 2 title | EN | `Who can see it` | PASS |
| 5 | Section 3 title | VI | `Không bán dữ liệu` | PASS |
| 6 | Section 3 title | EN | `No data sales` | PASS |
| 7 | Section 4 title | VI | `Tài khoản đôi` | PASS |
| 8 | Section 4 title | EN | `Paired accounts` | PASS |
| 9 | Section 5 title | VI | `Điều khoản ngắn gọn` | PASS |
| 10 | Section 5 title | EN | `Terms, briefly` | PASS |
| 11 | Section 1 body | VI | `Tên hiển thị, ngày sinh (để tính hoàng đạo), tâm trạng check-in, ảnh bạn tự tải lên. Không danh bạ, không vị trí liên tục.` | PASS |
| 12 | Section 1 body | EN | `Display name, birthday (for zodiac), mood check-ins, and photos you upload. No contacts, no continuous location.` | PASS |
| 13 | Section 2 body | VI | `Chỉ bạn và người ghép đôi với bạn. Nhân sự của chúng mình không đọc nội dung riêng tư trừ khi bạn gửi báo lỗi kèm ảnh.` | PASS |
| 14 | Section 2 body | EN | `Only you and your partner. Our staff never read private content unless you attach it to a bug report.` | PASS |
| 15 | Section 3 body | VI | `Chúng mình không bán, không cho thuê, không dùng dữ liệu của bạn để huấn luyện mô hình quảng cáo.` | PASS |
| 16 | Section 3 body | EN | `We do not sell, rent, or use your data to train advertising models.` | PASS |
| 17 | Section 4 body | VI | `Một số dữ liệu thuộc về cả hai (bé pet, album chung). Xoá tài khoản của bạn không xoá phần của người kia.` | PASS |
| 18 | Section 4 body | EN | `Some data belongs to both of you (the pet, the shared album). Deleting your account does not delete their half.` | PASS |
| 19 | Section 5 body | VI | `Từ 16 tuổi. Đừng dùng Cupid để làm tổn thương người khác. Chúng mình có thể đóng tài khoản vi phạm.` | PASS |
| 20 | Section 5 body | EN | `16 and over. Don't use Cupid to hurt anyone. We may close accounts that break this.` | PASS |

That is 10 titles + 10 bodies = the ten VI and ten EN strings required by the
phase file's "ten VI/EN section-string checklist" (5 sections x title+body x 2
locales). Every one ships both a `data-vi` and a `data-en` span, so no string
can silently blank out in the other locale (`contract-summary.md` §3).

### 3.2 Structure And Fidelity Checks

| Check | Result |
|-------|--------|
| exactly one `<main>` in the document | PASS (1) |
| exactly one `<h1>` | PASS (1) |
| exactly five `<h2>` | PASS (5) |
| `<title>` = `Quyền riêng tư & Điều khoản — Cupid` (VI default) | PASS |
| eyebrow renders as the literal `Legal`, no `data-vi`/`data-en` pair | PASS |
| `padding-top:22px` occurs exactly 5x (one per section) | PASS |
| `margin:0 0 9px` occurs exactly 5x (one per section title) | PASS |
| no `var(--surf)` inside `<main>` | PASS |
| no `border-radius` inside `<main>` | PASS |
| no accent token (`--acc-pink/lilac/mint/butter/peach`) inside `<main>` | PASS |
| no `<details>` accordion inside `<main>` | PASS |
| no `@media` query inside `<main>` | PASS |
| title script is `is:inline` (emitted in-document, no `src=`, not bundled/deferred) | PASS |
| home page footer contains `/legal` links | PASS (2 occurrences) |

## 4. Measured-Layout-Value Checklist (UX §6.8, rendered `getComputedStyle`)

Measured in Chromium at 1440x900 on the previewed build, not read back from the
source string.

| Anchor | Expected | Measured | Result |
|--------|----------|----------|--------|
| page section `max-width` | `820px` | `820px` | PASS |
| page section `padding` | `70px 32px 90px` | `70px 32px 90px 32px` | PASS |
| H1 `margin` | `10px 0 0` | `10px 0px 0px 0px` | PASS |
| H1 font | Nunito 900 / 48px | `48px` / `900` | PASS |
| updated-date `margin` | `12px 0 0` | `12px 0px 0px 0px` | PASS |
| sections container `margin-top` | `34px` | `34px` | PASS |
| sections container `gap` | `26px` | `26px` | PASS |
| section item `padding-top` | `22px` | `22px` | PASS |
| section item `border-top` | `1px solid var(--c1)` | `1px solid` | PASS |
| section title `margin-bottom` | `9px` | `9px` | PASS |
| section title `margin-top` | `0px` (no UA h2 gap) | `0px` | PASS |
| section title font | Nunito 800 / 19px | `19px` / `800` | PASS |
| section body font | 14.5px / line-height 1.7 | `14.5px` / `24.65px` | PASS |
| section border-box width at 1440 | `884px` (820 content + 2x32 padding) | `884px` | PASS |

Note on `max-width` semantics: neither `tokens.css` nor `global.css` (both
verbatim ports of `Cupid Web.dc.html:16-27`) defines a `box-sizing` reset, so
`max-width:820px` bounds the **content** box exactly as it does in the design
source prototype. The 820px reading measure is therefore the text column width,
with the 32px side padding outside it — the intended §6.2 behavior, not a
regression.

Note on the `<h2>` margin: the design source uses a styled `<div>` for the
section title (`Cupid Web.dc.html:647`), which has no UA margin. UX §6.6 requires
a real `<h2>` for screen-reader navigation, and a bare `<h2>` would inherit a UA
top+bottom margin that breaks the 22px/9px rhythm. The style is therefore written
as `margin:0 0 9px`, which yields the specified `margin-bottom:9px` with
`margin-top:0` — identical rendered geometry to the source `<div>`.

## 5. `document.title` On-Load / On-Toggle Check (AC-5)

Chromium, previewed build at `http://127.0.0.1:21021/legal`.

| Step | Expectation | Observed | Result |
|------|-------------|----------|--------|
| initial load | `body[data-lang]` = `vi` | `vi` | PASS |
| initial load | `document.title` = `Quyền riêng tư & Điều khoản — Cupid` | exact match | PASS |
| click header `EN` | `document.title` = `Privacy & Terms — Cupid` | exact match | PASS |
| click header `EN` | no page reload | `performance.getEntriesByType('navigation').length` = 1 | PASS |
| click header `VI` | `document.title` back to the VI title | exact match | PASS |
| all 16 theme x lang x width loads | title matches the loaded locale | 16/16 exact match | PASS |

The title is driven by a page-local `<script is:inline>` that reads
`document.body.dataset.lang` on parse and re-applies on a `MutationObserver`
watching `data-lang` on `<body>`. It does not import from, call into, or modify
the shell boot script; the shell's own `setLang()` is untouched and the observer
simply reacts to the attribute it already writes.

## 6. Rendered Visual Inspection — 4 Widths x 4 Theme/Language Combinations

Served from the built output (`npm run preview -- --port 21021 --host 127.0.0.1`,
`DEVSTACK_PORT_WEB=21021` from `.env.devstack`; Astro's default 4321 was not
used). 16 combinations, each asserted in Chromium.

| theme x lang | width | horizontal scroll | clipping past viewport | content width (32px padding held) | 5 titles visible (1 locale) | 5 bodies visible (1 locale) | title |
|--------------|-------|-------------------|------------------------|-----------------------------------|------------------------------|------------------------------|-------|
| dark x vi | 375 | none | none | 311px | PASS | PASS | VI |
| dark x vi | 768 | none | none | 704px | PASS | PASS | VI |
| dark x vi | 1024 | none | none | 820px | PASS | PASS | VI |
| dark x vi | 1440 | none | none | 820px | PASS | PASS | VI |
| dark x en | 375 | none | none | 311px | PASS | PASS | EN |
| dark x en | 768 | none | none | 704px | PASS | PASS | EN |
| dark x en | 1024 | none | none | 820px | PASS | PASS | EN |
| dark x en | 1440 | none | none | 820px | PASS | PASS | EN |
| light x vi | 375 | none | none | 311px | PASS | PASS | VI |
| light x vi | 768 | none | none | 704px | PASS | PASS | VI |
| light x vi | 1024 | none | none | 820px | PASS | PASS | VI |
| light x vi | 1440 | none | none | 820px | PASS | PASS | VI |
| light x en | 375 | none | none | 311px | PASS | PASS | EN |
| light x en | 768 | none | none | 704px | PASS | PASS | EN |
| light x en | 1024 | none | none | 820px | PASS | PASS | EN |
| light x en | 1440 | none | none | 820px | PASS | PASS | EN |

- Content width follows `min(820, viewport - 64)` at every width, i.e. the 32px
  side padding holds and the column simply centers — no breakpoint was added and
  none is needed (UX §6.6).
- 375px: no horizontal scroll and no element extends past the viewport edge, so
  no clipping of the long VI paragraphs.
- Exactly one locale's spans are visible per combination (the other locale's
  spans are `display:none` via `global.css`), and all five titles and all five
  bodies are non-empty in the visible locale.

### Body-text legibility over full paragraphs, both themes (UX §6.4)

| Theme | `--c64` body color resolved | `--ink` H1 color resolved | Reading |
|-------|-----------------------------|---------------------------|---------|
| dark | `rgba(247, 238, 251, 0.64)` on `#171129` | `rgb(255, 255, 255)` | body copy stays clearly readable across full 1.7-line-height paragraphs; the divider (`--c1`) is visible but subordinate to the title |
| light | `rgba(46, 22, 52, 0.74)` on `#FFF1F7` | `rgb(58, 33, 64)` | same — dark ink at 74% over the pale background keeps long paragraphs legible; title/body contrast separation is preserved |

Both are the shell's existing token values, unmodified; no new token was
introduced and no token was redefined (`contract-summary.md` §4).

## 7. Entry-Point Reachability From The Rendered Site (AC-1)

Started from the rendered home page, clicked the real footer link, followed the
navigation.

| Locale | Footer "Legal" column link clicked | Landed path | H1 on landing | `<h2>` count | Document title | Result |
|--------|-----------------------------------|-------------|---------------|--------------|----------------|--------|
| VI | `Quyền riêng tư` | `/legal` | `Quyền riêng tư & Điều khoản` | 5 | `Quyền riêng tư & Điều khoản — Cupid` | PASS |
| VI | `Điều khoản` | `/legal` | `Quyền riêng tư & Điều khoản` | 5 | `Quyền riêng tư & Điều khoản — Cupid` | PASS |
| EN | `Privacy` | `/legal` | `Privacy & Terms` | 5 | `Privacy & Terms — Cupid` | PASS |
| EN | `Terms` | `/legal` | `Privacy & Terms` | 5 | `Privacy & Terms — Cupid` | PASS |

All four footer links land on the **populated** page (5 sections present), not
the previously empty route.

## 8. Shell Diff / Regression Check

| Check | Result |
|-------|--------|
| header primary nav item count on `/legal` | PASS — exactly **7** `<a>` items, no 8th "Legal" entry added |
| theme toggle still switches `body[data-theme]` on this route | PASS — verified across the 8 light-theme combinations in §6 |
| language toggle still switches `body[data-lang]` on this route | PASS — verified in §5 and across the 8 EN combinations in §6 |
| footer renders identically on `/legal` (same Legal column links present) | PASS |
| no shell source file in the story diff | PASS (§2) |
| no second `<main>` introduced | PASS (§3.2, one `<main>`) |

## 9. Totals

| Suite | Checks | Failed |
|-------|--------|--------|
| Static build-output assertions | 48 | 0 |
| Rendered Chromium assertions (title, structure, measured layout, 16 combinations, 4 entry points) | 147 | 0 |
| **Total** | **195** | **0** |

| Runtime startup smoke assertions (boot, readiness, 4 routes, body sanity, landmarks, shutdown) | 8 | 0 |
| Entry-point reachability assertions (4 footer links + 7-item header nav) | 5 | 0 |

Build gate: `npm run check` exit 0, `npm run build` exit 0 (re-confirmed after
the evidence patch — §1 rows 4-5).
Startup smoke: executed and PASS — see `## Story Runtime Startup Smoke`. The
phase file marks it NOT_APPLICABLE for this static frontend, but the runtime
registry defines a real readiness contract, so the smoke was run rather than
waived.
Entry point: reachable — see `## Entry Point Reachability` (`Reachable: YES`,
path `/legal`).

## Entry Point Reachability

Reachable: YES

- Entry point path: `/legal` (route key `legal`, `web/src/pages/legal.astro`,
  built artifact `web/dist/legal/index.html`, served as
  `http://127.0.0.1:21021/legal` → HTTP 200)
- Entry point surface: shared site footer, "Pháp lý"/"Legal" column
  (`SiteFooter.astro`, link data `site-nav.ts`, ported from
  `Cupid Web.dc.html:844-847`). Deliberately **not** in the header nav — the
  header stays at exactly 7 items (verified below).
- Discovery method: user clicks either footer Legal-column link, in either
  locale; a direct URL to `/legal` is also supported per UX §5.1.

How it was verified (not asserted from source, but navigated in Chromium from
the rendered home page — full detail in §7):

| Locale | Footer link clicked | Landed path | Populated? | Result |
|--------|--------------------|-------------|------------|--------|
| VI | `Quyền riêng tư` | `/legal` | 5 sections, H1 present | PASS |
| VI | `Điều khoản` | `/legal` | 5 sections, H1 present | PASS |
| EN | `Privacy` | `/legal` | 5 sections, H1 present | PASS |
| EN | `Terms` | `/legal` | 5 sections, H1 present | PASS |

Supporting facts:

- All four footer links resolve to the **same** `/legal` page by design
  (`contract-summary.md` §2: "`legal` serves both footer Privacy and Terms
  links. Do not split it."). No route was added or split.
- The landed page is the populated one, not the previously empty route: 5
  `<h2>` sections and a non-empty `<h1>` were read off the live DOM at each
  landing.
- Header primary nav item count on `/legal` is **7** — no 8th "Legal" entry was
  introduced, per UX §6.3 and STORY-001's route map rule.
- No new nav surface, footer column, or footer link was created by this story
  (`contract-summary.md` §6); the entry point already existed from STORY-001 and
  this story made its destination non-empty.

## Story Runtime Startup Smoke

Executed: YES — result **PASS**.

The phase file lists `Startup Smoke: NOT_APPLICABLE` / `Readiness Check: N/A`
for this static frontend. A real bounded smoke was run anyway, because
`data/devops/system/runtime-command-registry.json` does define a concrete
readiness contract for this runtime id, so the stronger evidence was available
at no risk. This section records that executed smoke; it is not a waiver.

Command and contract sources (all from the runtime registry, none invented):

| Field | Value | Registry source |
|-------|-------|-----------------|
| Runtime id | `web-frontend` | `runtimes.web-frontend` |
| Path | `web` | `runtimes.web-frontend.path` |
| Type / framework | `frontend` / `astro` | `runtimes.web-frontend` |
| Startup command | `npm run preview` | `runtimes.web-frontend.prodCommand` |
| Readiness | `GET http://127.0.0.1:${DEVSTACK_PORT_WEB}/` expect `200` | `runtimes.web-frontend.readiness` |
| Port | `21021` from `DEVSTACK_PORT_WEB` in `.env.devstack` | `port.hostPortEnv`; Astro's default 4321 deliberately not used |
| Node | `v22.17.1` | `engines.node >= 22.12.0` |
| Depends on | none (no api/postgres/redis/worker) | `runtimes.web-frontend.dependsOn: []` |

Executed as:
`npm run preview -- --port 21021 --host 127.0.0.1` (cwd `web/`), polled for
readiness, exercised, then shut down.

| Step | Expected | Observed | Result |
|------|----------|----------|--------|
| server boot | process starts, no crash | `astro v6.0.5 ready in 6 ms`, `Local http://127.0.0.1:21021/` | PASS |
| readiness `GET /` | HTTP 200 | HTTP **200** after 5 polls (~1250 ms) | PASS |
| story route `GET /legal` | HTTP 200 | HTTP **200** | PASS |
| regression `GET /support` | HTTP 200 | HTTP **200** | PASS |
| regression `GET /about` | HTTP 200 | HTTP **200** | PASS |
| `/legal` served body non-trivial | populated page, not empty route | 19,705 bytes | PASS |
| `/legal` served landmarks | one `<main>`, one `<h1>`, five `<h2>` | `main=1`, `h1=1`, `h2=5` | PASS |
| shutdown | clean stop, port released | SIGTERM, server stopped, port 21021 released | PASS |

Scope note: the smoke stayed scoped to the impacted app (`web-frontend`). No
other service was started; this story's runtime has no dependencies to bring up,
and no `devstack` service was touched. The three extra routes were requested
only as a cheap same-process regression check that the new page did not break
sibling routes in the same build.

Server log (verbatim):

```
> cupid-web@0.0.1 preview
> astro preview --port 21021 --host 127.0.0.1

 astro  v6.0.5 ready in 6 ms
┃ Local    http://127.0.0.1:21021/
```

Measurement caveat recorded for honesty: the first smoke pass reported the
`<h2>` count via `grep -c`, which counts matching *lines*, and the built HTML is
minified onto few lines — it printed `1`. The count was re-taken with
`grep -o '<h2' | wc -l`, which counts occurrences and returned **5**, matching
the Chromium DOM count in §3.2 and §5. The `5` above is the corrected figure.

## 10. Deviations And Notes

1. `<h2>` section titles use `margin:0 0 9px` rather than a bare
   `margin-bottom:9px`, to cancel the UA `<h2>` top margin that the design
   source's `<div>` never had. Rendered geometry is identical to the source
   (§4).
2. The five sections are emitted from a frontmatter array that mirrors the design
   source's own `legal` data array (`Cupid Web.dc.html:823-829`), matching the
   source's `sc-for` loop rather than hand-duplicating markup five times. The
   emitted DOM is byte-equivalent in structure to the source template.
3. `npm ci` was required before the gate could run: this worktree had no
   `node_modules`. No dependency was added, removed, or upgraded —
   `package.json` and `package-lock.json` are unchanged (§2).
4. No design-reference image comparison was possible; UX §6.8 records the
   inherited STORY-001 `design_source` render blocker. The measured-value
   checklist in §4 is the interim visual anchor that section designates, and it
   passes in full. The requirement-level `Mode: requirement-visual-audit` remains
   the later REQ-006-scope gate and is not this phase's gate. This axis is now
   tracked requirement-wide in
   `../../design-fidelity-tooling-fix.md`; a separate re-review dispatch covers
   it once that tooling fix lands, so it is explicitly out of scope for this
   evidence patch.
5. Runtime startup smoke was **executed** even though the phase file marks it
   `NOT_APPLICABLE` for `web-frontend`. The runtime registry supplies a concrete
   `prodCommand` and an HTTP readiness contract for this runtime, so a bounded
   real smoke was cheaper and stronger than recording a waiver. This is a
   deviation toward more evidence, not less; no `story_master.md`
   `Runtime-Smoke: WAIVED` line was needed and none was added.
6. This patch round (review BLOCK-2 / BLOCK-3) changed evidence artifacts only.
   No file under `web/` was modified; `web/src/pages/legal.astro` is unchanged
   since implementation commit `8ce3e2f`, and the build gate was re-run purely
   to confirm no regression (§1 rows 4-5).
