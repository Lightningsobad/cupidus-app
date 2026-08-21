# Visual Fidelity — REQ-006 / STORY-005 Cupid Journal Blog Page

VISUAL_FIDELITY: FAIL

The FAIL is "the comparison could not be performed", not "the implementation
visibly deviates". Only the implementation half of the pair exists. No
`design-reference-blog-*.png` was produced for this story, and the Reviewer
could not produce one with the sanctioned bundle renderers — see
"Reference half: blocked" below. A PASS cannot be certified against a reference
that does not exist, so the gate reads FAIL.

## Resolved design screen

Design-Screen: **NOT RECORDED** — no `Design-Screen: <id>` appears in
`story_master.md`, `ux/uiux-spec.md`, `architecture/solution.md`, or
`coding-plan/`. Per reviewer skill 12e2 the absence is itself a finding: nobody
can re-check which design screen this story was built against.

Design source (`data/devops/system/design-fidelity-config.json`):
`type: claude-design`, `location: cupid-app-design-system`,
`entry: Cupid Web.dc.html`, `locked: true`, `ui_surface: true`. A design source
IS configured, so the rendered check is mandatory and the no-design-source
exemption does not apply.

## Implementation half: captured

| File | Breakpoint | Command |
|---|---|---|
| `implemented-blog-375.png` | 375 | see below |
| `implemented-blog-768.png` | 768 | see below |
| `implemented-blog-1400.png` | 1400 | see below |

```
node .ai-team-bundle/runtime/tools/visual-capture.js --mode=url \
  --url=http://127.0.0.1:22003/blog --label=blog \
  --breakpoints=375,768,1400 --full-page --out=<story>/visual-fidelity
```

`render-running-app.js` could not be used. Measured this run:

```
APP_RENDER_NOT_CONFIGURED: data/devops/system/design-fidelity-config.json has no
app_render.base_url. Configure app_render.{start_cmd,ready_url,base_url} so the
running app can be auto-served and rendered.
exit=4
```

This is the same gap STORY-001 recorded as its DEF-1; it was never actioned, so
every UI story in REQ-006 still has to hand-start a server. The app was served
with `npx astro preview --port 22003 --host 127.0.0.1` under Node v22.17.1
(devstack lease `DEVSTACK_LEASE_PREVIEW=22003`, role `preview`), reached
`HTTP 200` on `/blog`, and `npm run build` was reproduced independently by the
Reviewer (8 pages, exit 0).

The 1400 capture was read and shows the real Blog screen of the built app — not
a blank, error, or wrong screen: eyebrow `CUPID JOURNAL`, H1 `Viết về chuyện yêu
nhau lâu dài`, intro paragraph, 4 topic pills, the featured panel with the Sua
sprite and `BÀI NỔI BẬT` label, 6 article cards in a 3-column grid, the
newsletter block, and the STORY-001 shell with the `Blog` nav pill active.

## Reference half: blocked

`design-reference-blog-<bp>.png` does not exist and is not obtainable with the
sanctioned renderers (`render-design-canvas.js` / `visual-capture.js`).

Measured:

```
$ render-design-canvas.js --location=<worktree>/cupid-app-design-system \
    --entry="Cupid Web.dc.html" --list-screens
{ "entry": "Cupid Web.dc.html", "screens": [], "toggles": [], "platforms": [] }

$ render-design-canvas.js ... --screen=blog --label=blog --out=<tmp>
DESIGN_CANVAS_SCREEN_MISSING: 'blog' is not a screen on this canvas.
Run --list-screens. Available: (none)
exit=1
```

Why: on this canvas the Blog view is a **non-default component prop state**, not
a selectable screen.

- `Cupid Web.dc.html:679` declares `startPage` as an editor enum
  (`home|pets|zodiac|share|blog|about|support|legal`) with `"default":"home"`.
- `:709` `const p = this.state.page || this.props.startPage || "home"`.
- `:453` `<sc-if value="{{ isBlog }}" hint-placeholder-val="{{ false }}">` — the
  Blog body only renders when `p === "blog"`.
- The only in-canvas way to set it is clicking a header `<button onClick="{{ it.go }}">`
  emitted by `<sc-for list="{{ navItems }}">` (`:52-57`). Those buttons carry no
  `[data-screen-btn]`, which is the only selector `render-design-canvas.js`
  clicks (`:349-358`).
- The canvas exposes no URL, query-param, hash, or localStorage hook for
  `startPage` (only `cupid-web-theme` is persisted, `:686`/`:702`), so
  `visual-capture.js --mode=design` always renders the Home state.

STORY-001 did not hit this: Home IS the canvas default, so its reference came
back for free. STORY-005 is the first story in REQ-006 whose design screen is
not the default state, and this is where that stops working.

The Reviewer did NOT improvise a workaround: no hand-rolled Playwright/Puppeteer
script, no `playwright test`, no authored wrapper HTML, and no edit to
`design-fidelity-config.json`.

## Per-breakpoint verdict

| Breakpoint | Verdict | Reason |
|---|---|---|
| 375 | UNVERIFIED | implementation captured; no reference to compare against |
| 768 | UNVERIFIED | implementation captured; no reference to compare against |
| 1400 | UNVERIFIED | implementation captured; no reference to compare against |

## What closes this

1. `ui-ux-designer`: produce `design-reference-blog-375/768/1400.png` in this
   directory for the canvas `startPage: "blog"` state, and record the resolved
   `Design-Screen: <id>` in the story so the choice is re-checkable.
2. `devops`: add the `app_render.{start_cmd,ready_url,base_url}` block to
   `data/devops/system/design-fidelity-config.json` (STORY-001 DEF-1) so
   `render-running-app.js` works for the rest of REQ-006.
3. Reviewer re-runs the compare and replaces this FAIL with a per-breakpoint
   PASS/FAIL verdict.
