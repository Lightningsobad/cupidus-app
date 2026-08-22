# Test Results – STORY-004 Phase P1 (Invite Page Body And Entry Point)

- Lane: Frontend
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-004`
- Branch: `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-004`
- BaseHead: `41b82520c7499662e42075bc1bb8a91fe084fe3b`
- Node: `v22.17.1` (nvm; the ambient default `v20.20.2` does not satisfy
  `engines.note` `>=22.12.0`)
- Date: 2026-08-21

## 1. Build And Type-Check Gates

| Command | Cwd | Exit | Result |
|---|---|---|---|
| `npm install --no-audit --no-fund` | `web/` | 0 | 331 packages (no lockfile change kept, see §6) |
| `npm run check` (`astro check`) | `web/` | 0 | Result (32 files): 0 errors, 0 warnings, 0 hints |
| `npm run build` (`astro build`) | `web/` | 0 | 8 page(s) built in 551ms, incl. `/share/index.html` |

`npm run check` output:

```
21:53:31 [types] Generated 351ms
21:53:31 [check] Getting diagnostics for Astro files in .../web...
Result (32 files):
- 0 errors
- 0 warnings
- 0 hints
```

`npm run build` route list included `├─ /share/index.html (+3ms)`; build
completed with `[build] Complete!`.

## 2. Shell Freeze

`git diff --name-only 41b82520c7499662e42075bc1bb8a91fe084fe3b` plus
`git status --porcelain`:

```
 M web/src/pages/share.astro
?? web/src/components/share/
?? web/src/data/share-content.ts
```

Changed/added source files (all six inside Write Scope, nothing else):

- `web/src/pages/share.astro` (modified)
- `web/src/components/share/InviteHero.astro` (new)
- `web/src/components/share/PairingSequence.astro` (new)
- `web/src/components/share/InviteSteps.astro` (new)
- `web/src/components/share/KeepsakeCards.astro` (new)
- `web/src/data/share-content.ts` (new)

Nothing under `web/src/layouts/`, `web/src/components/shell/`,
`web/src/styles/`, or `web/src/scripts/` is touched. PASS.

## 3. Built-Output Assertions (`web/dist/share/index.html`)

Measured with `node -e` over the built HTML:

| Check | Value | Verdict |
|---|---|---|
| `data-vi` occurrences | 44 | — |
| `data-en` occurrences | 44 | PASS (equal, AC-10) |
| `<input` occurrences | 0 | PASS (AC-3) |
| `tabindex` occurrences | 0 | PASS (AC-3/AC-4) |
| `<title>` | `Cupid — Ghép đôi` | PASS (AC-8) |
| `dist/index.html` `<title>` | `Cupid` | — |
| titles distinct | `true` | PASS (AC-8, closes DEF-2) |
| `font-size:54px` (H1) | 1 | PASS (fidelity, not Home's 66px) |
| `font-size:66px` | 0 | PASS |
| hero code cells `width:56px;height:68px` | 6 | PASS (AC-3) |
| left-mockup filled cells (pink `.4` border, 52px) | 3 | PASS (AC-5) |
| left-mockup empty cells (`var(--c14)` border, 52px) | 3 | PASS (AC-5) |
| left-mockup label color | `var(--c5)` (neutral) | PASS |
| right-mockup label color | `var(--acc-mint)` | PASS (status signal preserved) |
| `<main>` landmark | 1 | PASS (a11y) |
| Mochi sprite `aria-label="Mochi"` | 1 | PASS (a11y, meaningful content) |

### No new custom property

Inline custom-property *definitions* (`--name:` not inside `var(...)`) in the
built HTML:

```
dist/share/index.html inline custom-property definitions = 0 []
dist/index.html       inline custom-property definitions = 0 []
```

Combined with §2 (no file under `web/src/styles/` changed), the diff defines
zero new custom properties. PASS.

## Entry Point Reachability

**Reachable: YES**

Path: `share` → `/share`

(Formerly numbered "4. Entry Point Reachability (AC-1)"; renamed to the
canonical rule-12e1 heading and given the `Reachable:` line in the Iris-QC-5
patch pass for **BLK-2**. The evidence below is unchanged — BLK-2 was a
missing-form finding, not a missing-implementation one, and Reviewer confirmed
the entry point independently in code.)

Entry point definition, in source:

| Fact | Evidence |
|------|----------|
| The `share` key maps to `/share` | `web/src/data/site-nav.ts:33` — `{ key: 'share', href: '/share', vi: 'Ghép đôi', en: 'Invite' }` in `navItems` |
| The `/share` route exists | `web/src/pages/share.astro`; `astro build` emits `dist/share/index.html` |
| `/share` serves the real Invite body | live `GET /share/` → **200** (see `## Story Runtime Startup Smoke`); response carries the hero H1 "Có người vừa gọi bạn về nhà" |
| `share` is a first-class nav entry | `web/src/components/shell/SiteHeader.astro:21-30` (desktop pill nav) and `:31-35` (mobile `<select>`) render every `navItems` entry |
| Footer repeats the path | `web/src/data/site-nav.ts:48` — Product column `/share` link |

Measured over built HTML:

- `dist/index.html` contains 2 anchors to `/share` (header pill nav + footer
  link) — reachable from Home without a direct URL.
- `dist/index.html` mobile `<select>` carries
  `<option value="/share" data-label-vi="Ghép đôi" data-label-en="Invite" ...>`.
- `dist/share/index.html` header nav item renders **active**:
  `<a href="/share" class="cupid-hdr-nav-item" aria-current="page"
  style="background:rgba(255,127,182,.16);...;color:var(--acc-pink);...">`,
  versus the inactive sibling `<a href="/pets" ... style="background:transparent;...;color:var(--c68);...">`.
- `dist/share/index.html` mobile `<select>` option for `/share` carries
  `selected`.
- Direct URL load of `/share` renders the same page (all §3 assertions were
  measured on that direct render).

PASS — reachable by desktop nav item, by mobile `<select>`, and by footer link,
not only by typing a URL. No shell file was modified to achieve this: the nav
item already existed from STORY-001, and no implementation change was required
for BLK-2.

## Story Runtime Startup Smoke

**Result: PASS** | **Shutdown: PASS**

Date: 2026-08-21. Patch pass for Iris-QC-5 finding **BLK-1** (full-story review,
`review/review-report.md`). Supersedes the `Startup Smoke: NOT_APPLICABLE`
declaration that `phase-P1-invite-page-body-and-entry-point.md:33` previously
carried; that line has been corrected in the same patch so the plan no longer
contradicts this evidence. `story_master.md` carries no
`Runtime-Smoke: WAIVED` line, so rule 12g applies to this `frontend`-lane,
`standard`-complexity story.

Runtime id: `web-frontend`
(`data/devops/system/runtime-command-registry.json`). `astro@6.0.5` requires
Node `>=22.12.0`; this machine's ambient default is `v20.20.2`, so the smoke was
run under nvm `v22.17.1`.

Commands run (`web/` as working directory):

```
$ node --version
v22.17.1
$ DEVSTACK_PORT_WEB=21021 npm run dev -- --port 21021 --host 127.0.0.1
> cupid-web@0.0.1 dev
> astro dev --port 21021 --host 127.0.0.1
 astro  v6.0.5 ready in 778 ms
┃ Local    http://127.0.0.1:21021/
22:19:49 watching for file changes...
```

Pre-start probe confirmed the port was free before launch:
`GET http://127.0.0.1:21021/` → `000`, `curl` exit `7` (connection refused).

Readiness probe (registry `web-frontend.readiness`, `GET /` on the reserved
`DEVSTACK_PORT_WEB` port 21021, `expectStatus: 200`):

| Attempt | `GET http://127.0.0.1:21021/` |
|---|---|
| 1 | `000` (not yet listening) |
| 2 | `000` (not yet listening) |
| 3 | `200` — ready |

Story-route probe on the same running server: `GET http://127.0.0.1:21021/share/`
→ **200**. Server-side log confirms both: `[200] / 14ms` and `[200] /share/ 5ms`.

Shutdown: sent `SIGTERM` to the `npm run dev` process; it exited within 2s
without needing `SIGKILL` (`sigkill_needed=no`). Post-shutdown probe against the
same URL returned `000` with `curl` exit `7` (connection refused), and
`lsof -nP -iTCP:21021 -sTCP:LISTEN` found no listener
(`orphan_listener=NO`) — the port was released and no orphaned process remained.

One dev-only log line appeared and is not a defect in this story's scope:
`[WARN] [content] Content config not loaded`. It is Astro's notice that the
workspace defines no content collections; it is emitted by `astro dev` on every
route including `/`, is absent from the production build (§1), and does not
appear in the browser console (§5 recorded zero console errors/warnings across
all 16 runs).

This confirms the `web-frontend` local dev runtime starts, serves both `GET /`
and the story's own `GET /share/` with `200`, and shuts down cleanly on the
registry-reserved port — closing BLK-1. It does not re-run or supersede the
build/check/visual evidence recorded elsewhere in this file.

### Re-verification 2026-08-22 (Chris-FE, independent re-run)

The smoke above was re-executed from scratch on 2026-08-22 rather than carried
forward on trust. Same worktree, same Node `v22.17.1`, same port 21021,
identical outcome:

```
NODE=v22.17.1
PRE_START_PROBE / http=000 curl_exit=7
DEV_PID=37401
READINESS_ATTEMPT=1 / http=000
READINESS_ATTEMPT=2 / http=000
READINESS_ATTEMPT=3 / http=200
READINESS_RESULT http=200 attempts=3
STORY_ROUTE_PROBE /share/ http=200
SHARE_HERO_H1=PRESENT
SIGTERM_SENT=yes
SHUTDOWN_WAIT_SECONDS=1 sigkill_needed=no
POST_SHUTDOWN_PROBE / http=000 curl_exit=7
ORPHAN_LISTENER=NO
```

Server-side log for the same run: `astro v6.0.5 ready in 598 ms`,
`Local http://127.0.0.1:21021/`, `[200] / 12ms`, `[200] /share/ 3ms`, plus the
same dev-only `[WARN] [content] Content config not loaded` line noted above and
an unrelated `New version of Astro available: 7.2.4` notice.

Build gate re-run in the same session, `web/` under Node `v22.17.1`:

```
$ npm run check   → astro check: 32 files, 0 errors, 0 warnings, 0 hints   (exit 0)
$ npm run build   → 8 page(s) built in 1.03s, includes /share/index.html   (exit 0)
```

`Result: PASS | Shutdown: PASS` holds on re-run.

## 5. Visual / Responsive / Interactivity Verification

Headless Chromium (bundle Playwright 1.62.0) against the built `dist/`, served
over loopback, animations frozen. 16 runs = 4 widths x 2 themes x 2 languages.

| Width | Theme/Lang | H1 | Tab stops in `<main>` | `<input>` | Visible VI / EN spans | Blank visible spans | Step cards (min w) | Keepsake cards (min w) | Mockups stacked | Connector centered | H-overflow |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 375 | dark/vi | 54px | 1 (`A.cupid-invite-cta`) | 0 | 37 / 0 | 0 | 3 (311px) | 3 (241px) | YES | YES | no |
| 375 | dark/en | 54px | 1 | 0 | 0 / 37 | 0 | 3 (311px) | 3 (241px) | YES | YES | no |
| 375 | light/vi | 54px | 1 | 0 | 37 / 0 | 0 | 3 (311px) | 3 (241px) | YES | YES | no |
| 375 | light/en | 54px | 1 | 0 | 0 / 37 | 0 | 3 (311px) | 3 (241px) | YES | YES | no |
| 768 | dark/vi | 54px | 1 | 0 | 37 / 0 | 0 | 3 (344px) | 3 (201px) | no | YES | no |
| 768 | dark/en | 54px | 1 | 0 | 0 / 37 | 0 | 3 (344px) | 3 (201px) | no | YES | no |
| 768 | light/vi | 54px | 1 | 0 | 37 / 0 | 0 | 3 (344px) | 3 (201px) | no | YES | no |
| 768 | light/en | 54px | 1 | 0 | 0 / 37 | 0 | 3 (344px) | 3 (201px) | no | YES | no |
| 1024 | dark/vi | 54px | 1 | 0 | 37 / 0 | 0 | 3 (309px) | 3 (286px) | no | YES | no |
| 1024 | dark/en | 54px | 1 | 0 | 0 / 37 | 0 | 3 (309px) | 3 (286px) | no | YES | no |
| 1024 | light/vi | 54px | 1 | 0 | 37 / 0 | 0 | 3 (309px) | 3 (286px) | no | YES | no |
| 1024 | light/en | 54px | 1 | 0 | 0 / 37 | 0 | 3 (309px) | 3 (286px) | no | YES | no |
| 1440 | dark/vi | 54px | 1 | 0 | 44 / 0 | 0 | 3 (323px) | 3 (299px) | no | YES | no |
| 1440 | dark/en | 54px | 1 | 0 | 0 / 44 | 0 | 3 (323px) | 3 (299px) | no | YES | no |
| 1440 | light/vi | 54px | 1 | 0 | 44 / 0 | 0 | 3 (323px) | 3 (299px) | no | YES | no |
| 1440 | light/en | 54px | 1 | 0 | 0 / 44 | 0 | 3 (323px) | 3 (299px) | no | YES | no |

Notes on the table:

- **Tab stops**: exactly one focusable element inside `<main>` at every
  viewport/theme/language — the "Open Cupid" CTA (`A.cupid-invite-cta`). No hero
  code cell, no mockup code cell, and no mockup "Pair up" pill is focusable.
  Satisfies uiux-spec §6.6 and AC-3/AC-4.
- **Copy parity**: at each combination exactly one language's spans are visible
  and the other language's are fully hidden, and zero visible localized span is
  empty — switching to EN leaves no blank region. The 37-vs-44 difference between
  <=1024px and 1440px is the STORY-001 shell's own `[data-nav]`/`[data-navm]`
  media query swapping desktop pill nav for the mobile `<select>`; the page-body
  count is unchanged.
- **Reflow at 375px**: the two 250px mockups stack into a column and the
  connector badge stays horizontally centered between them (measured centre
  delta <= 4px), not orphaned to one side. Keepsake cards never drop below their
  200px `minmax` floor; explainer cards never drop below 240px.
- **No horizontal overflow** at any width.

### Console cleanliness

`console` error/warning listeners plus a `pageerror` listener were attached for
all 16 runs. Result: **none**. PASS (required runtime signal).

### Screenshots

`data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-004/coding-plan/screenshots/implementation-<width>-<theme>-<lang>.png`
(16 files). These are **implementation** captures, deliberately not named
`design-reference-*` so they cannot be mistaken for the design anchor.

### Fidelity spot-checks against `Cupid Web.dc.html:387-451`

Every inline style string in the four new components is a verbatim copy of the
corresponding source line. Confirmed visually in the 1440 dark/vi and 375
light/en captures: eyebrow (mint mono), 54px H1, 6 hero code cells `C U P 1 D 7`,
gradient pill CTA, left "Nhập mã" mockup with 3 filled + 3 empty cells and the
bottom "Ghép đôi" pill, floating heart connector with its two gradient hairlines,
right "Đã ghép đôi" mockup with the Mochi sprite at 150px, "Mochi", "Ngày thứ
nhất của hai bạn" and the 2-members / 1-pet chips, three explainer cards
(`qr_code_2` pink / `favorite` lilac / `pets` mint), and the keepsake panel with
Milestone 214 / Streak 30/30 / Zodiac 92%.

## 6. Lockfile Note

`npm install` in this worktree appended a 3-line `engines` block to
`web/package-lock.json`. That file is outside this phase's Write Scope, so the
change was reverted with `git checkout -- web/package-lock.json`; the final diff
contains only the six Write Scope files.

## 7. BLOCKER — Design Reference Render (UI-Fidelity-AC-9)

Status: **DESIGN_REFERENCE_RENDER_UNAVAILABLE**. Not resolvable inside this
phase's Write Scope.

Provisioning was completed successfully first, so this is not an install defect:

```
$ .ai-team-bundle/runtime/ensure-runtime.sh --capability=visual-inspection
Ensured runtime provider: playwright
Capabilities: visual-inspection
State: /Users/alantravala/workspace/snapsofts/cupid-apps/.ai-team-bundle/runtime-state.json
(exit 0)
```

The prescribed command then failed. Verbatim:

```
$ node .../.ai-team-bundle/runtime/tools/render-design-canvas.js \
    --location="<worktree>/cupid-app-design-system" \
    --entry="Cupid Web.dc.html" --screen=share --platform=all \
    --out="<worktree>/data/requirements/REQ-006.../STORY-004/coding-plan"
DESIGN_CANVAS_SCREEN_MISSING: 'share' is not a screen on this canvas. Run --list-screens. Available: (none)
(exit 1)
```

Root cause, measured not guessed:

```
$ node .../render-design-canvas.js --location=... --entry="Cupid Web.dc.html" --list-screens
{
  "entry": "Cupid Web.dc.html",
  "screens": [],
  "toggles": [],
  "platforms": []
}
```

`render-design-canvas.js` selects a screen by clicking
`[data-screen-btn="<id>"]` and captures a `[data-plat="ios"]` / `[data-plat="md"]`
device frame. `Cupid Web.dc.html` is a full-viewport **web** prototype, not a
mobile device canvas: it exposes no `data-screen-btn`, no `data-tog`, and no
`data-plat` frames. Its page state (`isShare`) is switched by DCLogic handlers on
the header nav (`<button onClick="{{ it.go }}">`, `Cupid Web.dc.html:52-58`), which
the tool has no contract for. So the tool cannot target `--screen=share` for this
entry at all — this is a tool/entry-shape incompatibility, not a missing runtime,
a bad path, or a wrong `design-fidelity-config.json` entry
(`data/devops/system/design-fidelity-config.json` in this worktree correctly reads
`entry: "Cupid Web.dc.html"`, `locked: true`).

Deliberately **not** worked around: the canvas defaults to the `isHome` state, so
the tool's full-page fallback would have produced a Home screenshot labelled as
the Share design reference. Hand-driving the prototype's nav to reach `isShare`
and naming the output `design-reference-share-*.png` would put an artifact of my
own construction in front of the fidelity gate. Per the phase's own instruction,
this is reported instead of guessing fidelity.

Interim visual anchor for the reviewer remains uiux-spec §6.2/§6.8 (every
measurement, token, gradient, and string cited to `Cupid Web.dc.html:387-451`),
which §3 and §5 above verify against.

Correction to an earlier claim in this file: I first wrote that no prior REQ-006
story had produced a `design-reference-*.png`. That was wrong, and I am
retracting it. STORY-001 does ship four, verified in this worktree:

```
$ git ls-files "data/requirements/REQ-006_.../**/design-reference-*"
data/requirements/REQ-006_.../STORY-001/visual-fidelity/design-reference-home-1400.png
data/requirements/REQ-006_.../STORY-001/visual-fidelity/design-reference-home-375.png
data/requirements/REQ-006_.../STORY-001/visual-fidelity/design-reference-home-768.png
data/requirements/REQ-006_.../STORY-001/visual-fidelity/design-reference-home-canvas.png
```

My original search ran against the control checkout, where REQ-006 had not yet
landed, so it returned nothing. The gap is therefore **not** requirement-wide:
the Home reference rendered because the canvas opens in its `isHome` state and
the tool's full-page fallback captured it directly. `share` is different only in
that it is a non-default state the tool has no contract to reach — which is
exactly the incompatibility described above, and does not change the escalation
below.

Escalation: needs a `render-design-canvas.js` capability for non-device web
canvases (or an agreed alternative anchor for UI-Fidelity-AC-9). That is DevOps /
Tech Lead / UX tooling scope, outside this phase's six-file Write Scope.

## 8. Summary

| Gate | Result |
|---|---|
| `npm run check` | PASS |
| `npm run build` | PASS |
| Shell freeze | PASS |
| Copy parity (VI/EN) | PASS |
| Interactivity (no input, no tabindex, single CTA tab stop) | PASS |
| Per-page title + distinctness | PASS |
| No new custom property | PASS |
| Entry point reachability (AC-1, `Reachable: YES`) | PASS |
| Story runtime startup smoke (`GET /` 200, clean SIGTERM shutdown) | PASS |
| Responsive reflow 375/768/1024/1440 | PASS |
| Theme x language (4 combinations) | PASS |
| Console clean | PASS |
| Design reference render (UI-Fidelity-AC-9 anchor) | DEFERRED — `DESIGN_REFERENCE_RENDER_UNAVAILABLE`, Reviewer DEF-2, non-blocking; settled at the requirement visual-audit gate |
