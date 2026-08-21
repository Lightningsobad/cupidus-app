# REQ-006 Design-Fidelity Rendering Tooling Fix

## Decision (Scrum Master, user-confirmed 2026-08-21)

Four independent full-story-review passes on REQ-006 (STORY-002 / Iris-QC-3,
STORY-005 / Iris-QC-4, STORY-007 / Iris-QC-6, STORY-008 / Iris-QC-7) all
returned `PATCH_REQUIRED` or `BLOCKED` on the same root cause: reviewer rule
12e2's mandatory rendered design-reference comparison cannot be produced for
any REQ-006 page except the canvas's default `home` state.

User decision when asked: **fix tooling first, then re-review** — pause story
merges on the visual-fidelity axis, fix the two tooling/config gaps below,
then re-run full reviews (including a genuine rendered comparison) for every
pending story before any of them can reach `CLEAN`/`DEFERRED_ONLY` on
UI-Fidelity-AC / AC-6 / AC-9 / AC-10 (whichever AC id each story's
`requirements.md` uses for visual parity).

## Root cause (confirmed independently by 4 reviewers)

1. `render-design-canvas.js --list-screens` against
   `cupid-app-design-system/Cupid Web.dc.html` returns
   `{"screens":[],"toggles":[],"platforms":[]}` — this canvas selects its
   visible page through a React prop (`startPage`, declared
   `Cupid Web.dc.html:679`, consumed `:709,721`), not through the
   `[data-screen-btn]`/`[data-tog]`/`[data-plat]` DOM-attribute contract the
   tool implements. Only the default `startPage: "home"` is reachable, which
   is why STORY-001 (home) never hit this.
2. `render-running-app.js` (the alternate path — render the actual built app
   instead of the design canvas) also fails:
   `data/devops/system/design-fidelity-config.json` has no `app_render` block
   at all, so every attempt exits `4 APP_RENDER_NOT_CONFIGURED`. This is
   STORY-001's DEF-1, raised at that story's review and never actioned.

## Required fixes

### Fix 1 — DevOps: configure `app_render` (unblocks the running-app render path)

Add an `app_render` block to
`data/devops/system/design-fidelity-config.json` for the `web` app:
`app_render.{start_cmd, ready_url, base_url}`, using the reserved
`DEVSTACK_PORT_WEB` value from `.env.devstack` (never Astro's default 4321).
This alone does not solve the design-reference side (still needs Fix 2), but
several reviewers used `render-running-app.js` as their fallback path for the
*implementation*-side capture and it should be config-driven, not a
hand-started `astro preview`/`npm run dev` process per reviewer run.

### Fix 2 — extend `render-design-canvas.js` with a prop/state selector

Add a sanctioned way to drive the canvas to a non-default `startPage` value,
e.g. `--prop=startPage=<screen>` (screen ids: `pets`, `zodiac`, `share`,
`blog`, `about`, `support`, `legal`), so
`design-reference-<screen>-<bp>.png` becomes producible for every REQ-006
page, not just `home`.

`render-design-canvas.js` ships from `.ai-team-bundle/runtime/tools/` in this
installed target repo, projected from the bundle source
(`.bundle-runtime/` per `.agent-contract/runtime-layout.md`) — it is
generated tooling, not a second editable source tree, so an in-place edit
here will not propagate back to the bundle and may be overwritten by a future
`install.sh` re-run. If DevOps determines this edit cannot be made safely or
durably in this repo, it should push back with that evidence to Scrum Master
rather than silently patching the generated copy, and Scrum Master will
record the caveat for the user (upstream bundle-repo fix vs. accepted local
divergence).

## Stories paused on the visual-fidelity axis pending this fix

STORY-002, STORY-003 (review in flight), STORY-004 (patch done for the other
two evidence-form findings; visual-fidelity re-review held), STORY-005,
STORY-006 (review in flight), STORY-007, STORY-008. None of these may reach
`CLEAN`/`DEFERRED_ONLY` on the rendered visual-fidelity finding, and none may
merge into `codex/REQ-006_..._-integration`, until this fix lands and each
story gets one comprehensive re-review with a real rendered comparison.

Non-visual-fidelity evidence-form findings (entry-point reachability heading,
story runtime startup smoke section) are NOT paused — frontend-dev may
continue closing those independently so only the visual-fidelity axis remains
open per story once this fix lands.

## Status

- Status: IN_PROGRESS
- Owner: Frank-Devops (Fix 1 + attempt Fix 2, push back with evidence if Fix 2
  is unsafe to apply in this installed target repo)
- Opened: 2026-08-21
