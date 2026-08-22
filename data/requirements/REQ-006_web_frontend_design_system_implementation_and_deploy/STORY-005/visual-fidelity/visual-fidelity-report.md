# Visual Fidelity — REQ-006 / STORY-005 Cupid Journal Blog Page

VISUAL_FIDELITY: PASS

Assessed under the standard recorded in
`data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/design-fidelity-tooling-fix.md`,
"User decision (2026-08-21, second decision on this doc)": implementation-side
`render-running-app.js` capture is REQUIRED; for every non-`home` screen the
design-reference side is satisfied by the story's `ux/uiux-spec.md`, because
`render-design-canvas.js` is structurally unable to drive this canvas to a
non-default `startPage`. This report supersedes the prior `FAIL`, which was
"the comparison could not be performed" under the pre-decision standard.

## Implementation half — real `render-running-app.js` capture

```
AI_TEAM_RUNTIME_STATE=<main>/.ai-team-bundle/runtime-state.json \
node .ai-team-bundle/runtime/tools/render-running-app.js \
  --out=<story>/visual-fidelity --label=blog --route=/blog --full-page \
  --project=<scratch-root>
→ {"ok":true,"screenshots":[implemented-blog-375.png, implemented-blog-768.png,
                            implemented-blog-1280.png]}   exit=0
```

The orchestrator auto-started the server itself (`render-running-app: starting
dev server: cd <STORY-005 worktree>/web && npm run build && npm run preview --
--port 22004 --host 127.0.0.1`), which also reproduces the story's build gate
independently, then captured and tore the server back down
(`lsof -nP -iTCP:22004 -sTCP:LISTEN` → no listener afterwards).

| File | Breakpoint | Source |
|---|---|---|
| `implemented-blog-375.png` | 375 | `render-running-app.js`, this pass |
| `implemented-blog-768.png` | 768 | `render-running-app.js`, this pass |
| `implemented-blog-1280.png` | 1280 | `render-running-app.js`, this pass |

`implemented-blog-1400.png` is the prior pass's `visual-capture.js` capture at a
breakpoint the config does not declare. It is superseded and kept only as
history; `app_render.breakpoints` is `[375, 768, 1280]`.

`dev-server.log` in this directory is the renderer's own captured server output
(build + preview), written by the tool into `--out`.

### Two config deviations, both measured, both recorded

1. **`--project` pointed at a scratch root, not the worktree.** The STORY-005
   worktree's `data/devops/system/design-fidelity-config.json` has **no
   `app_render` block** — Fix 1 landed on `codex/REQ-006_..._-integration`
   (`5a075f2`) and on `main`, but this story's `BaseHead`
   (`2e72902`) predates it. Measured from the worktree:
   `APP_RENDER_NOT_CONFIGURED … exit=4`. The scratch root holds a verbatim copy
   of the integration branch's `app_render` block.
2. **Port 21021 → 22004.** The configured `base_url` port `21021` was already
   bound, and `lsof`/`lsof -d cwd` identified the listener as the **STORY-002
   worktree's** preview (`.../story-REQ-006_..._-STORY-002/web`, PID 8740,
   `GET /blog` → 200). `render-running-app.js` reuses an already-running server
   at `ready_url` rather than starting one, so running it unchanged would have
   captured STORY-002's build and certified STORY-005 against it. The port was
   changed to a devstack lease (`devstack port lease --project cupid-apps
   --slot story-005-review2 --role preview` → `22004`), released after the run.
   The config note itself anticipates a port change.

No `design_source` value was written, invented, or altered anywhere, and no
bundle tooling was edited.

## Design-reference half — uiux-spec, per the governing decision

`design-reference-blog-<bp>.png` is not producible: on this canvas the Blog view
is a non-default component prop state (`Cupid Web.dc.html:679` `startPage` enum
default `"home"`; `:709`; `:453` `<sc-if value="{{ isBlog }}">`), reachable only
through header buttons that carry no `[data-screen-btn]`, which is the only
selector `render-design-canvas.js` clicks. Confirmed permanently blocked in
`design-fidelity-tooling-fix.md` "Fix 2 — BLOCKED, pushed back with evidence".
Recorded once as DEF-A in the review report; not re-opened.

The reference is therefore `ux/uiux-spec.md` §6.2.1-§6.2.5, §6.6, §6.7, whose
values are line-cited to `Cupid Web.dc.html:453-509` and `:780-792`. Those
design-source line ranges were also read directly this pass and the ported
markup is character-for-character identical.

## Per-breakpoint verdict

| Breakpoint | Verdict | What the render shows |
|---|---|---|
| 375 | **PASS** | Single column throughout. Featured panel stacks illustration cell above content cell (`minmax(min(320px,100%),1fr)` floor resolves to container width, §6.6). Article grid 1 column. Newsletter wraps to stacked heading/field. Mobile header `<select>` showing "Blog", desktop nav hidden — the inherited 1024/1025px swap (§6.1). No horizontal overflow, no clipped text. |
| 768 | **PASS** | Featured panel 2 cells side by side; article grid 2 columns; newsletter block still one row with the field group wrapped beneath. Mobile `<select>` still active. Matches §6.6's fluid `auto-fit` posture with no page-local fixed breakpoint. |
| 1280 | **PASS** | Featured panel 2 cells; article grid 3 columns; newsletter one row, heading left / field+button right (`justify-content:space-between`). Desktop nav visible with the "Blog" pill in its active treatment. |

## Element-by-element check against `uiux-spec.md`

| uiux-spec anchor | Rendered / implemented | Verdict |
|---|---|---|
| §6.2 page container `max-width:1200px; padding:70px 32px 90px` | verbatim, `blog.astro:9` | PASS |
| §6.2.1 intro wrapper `max-width:660px`; eyebrow Roboto Mono 11px `.14em` uppercase `--acc-pink`; H1 Nunito 900 52px `-.03em`; intro 16px/1.65 `--c64` | verbatim `:10-13`; render shows "CUPID JOURNAL" pink mono, H1 wrapping to 2 lines inside the 660px column, intro paragraph below | PASS |
| §6.2.2 4 pills in source order, `gap:9px`, `margin-top:26px`, `--c06`/`--c14`/999px/`8px 16px`, Nunito 700 13px `--c78` | verbatim `:15-19`; render shows exactly "Yêu xa / Giải quyết xung đột / Ngôn ngữ tình yêu / Hoàng đạo" in that order | PASS |
| §6.2.3 featured panel gradient border `padding:8px`, `border-radius:34px`, inner grid `gap:8px`; left cell `min-height:300px`, Sua sprite 180px `top:24/right:24 opacity:.9`, "Bài nổi bật" butter eyebrow pinned bottom-left; right cell `padding:34px 30px`, "Xung đột" tag, H2 Nunito 900 32px/1.15, excerpt 14.5px/1.65, author row 32px gradient avatar + "Linh Đàm" + "· 8 phút đọc" | verbatim `:21-36`; render matches, including the sprite pinned top-right of the illustration cell and the butter eyebrow bottom-left | PASS |
| §6.2.4 6 cards in source order with per-card accent/tint/author/read-time; card `--surf`/`--c1`/26px radius/26px padding/`gap:12px`; tag mono 9.5px `.12em`; title Nunito 800 20px/1.25; excerpt 13.5px/1.6 `flex:1`; footer `border-top --c09`, `padding-top:13px`, 26px avatar, read time `margin-left:auto` | verbatim `ArticleCard.astro:12-20` + `blog-content.ts:32-39`; render shows all 6 in source order with matching category tags, authors and read times | PASS |
| §6.2.5 newsletter `--surf`/`--c11`/30px radius/36px padding/`space-between`/`gap:24px`; left `max-width:420px`, Nunito 900 24px heading + 14px/1.6 subcopy; right pill input `email@cupid.app` `min-width:230px` + gradient "Đăng ký" button | verbatim `:42-51`; render matches at all three breakpoints | PASS |
| §6.7 typography anchors (H1 52/900/-.03em, H2 32/900, card title 20/800, radii 26/30/34) | matched; independently measured in `test-results.md` §5.8 | PASS |
| §6.7 color tokens (`--acc-pink/lilac/mint/butter/peach`, no new tokens) | only existing tokens used; per-card cycle matches source `:786-791` | PASS |
| §6.1 active nav treatment `rgba(255,127,182,.16)` + `aria-current="page"` | visible in the 1280 render; verified in `SiteHeader.astro:22-29` | PASS |

## Documented deviations from the raw prototype (all §6.3/§6.6-mandated, zero default-state visual delta)

- card title `<div>` → `<h3 style="…;margin:0">` (§6.6 heading levels; `margin:0` preserves the `gap:12px` rhythm)
- `type="email"` + `aria-label="Email"` on the newsletter input, `type="button"` on Subscribe (§6.3 real semantics, no implicit submit)
- `aria-hidden="true"` on avatar swatches and the Sua sprite wrapper (§6.3 decorative)
- `.cupid-newsletter-field:focus-visible` ring (§6.6 hard requirement absent from the prototype), `!important` only because the source's inline `outline:none`/`border` shorthands outrank it

None of these changes the default-state rendering; each is a gap the uiux-spec
explicitly asked implementation to close.
