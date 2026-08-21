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

- Status: FIX_1_DONE_FIX_2_BLOCKED — awaiting Scrum Master/user decision on
  how to close the visual-fidelity gap for non-home pages
- Opened: 2026-08-21
- Closed (Fix 1): 2026-08-21

### Fix 1 — DONE, verified

Frank-Devops-5 added an `app_render` block to
`data/devops/system/design-fidelity-config.json`:
`start_cmd: cd web && npm run build && npm run preview -- --port 21021
--host 127.0.0.1`, `ready_url`/`base_url: http://127.0.0.1:21021`, using the
reserved `DEVSTACK_PORT_WEB` (21021). Verified end-to-end against the
`integration-REQ-006_...` worktree: `render-running-app.js
--route=/legal` exited 0 and produced real rendered screenshots (375/768/1280)
of the actual implementation — no longer `APP_RENDER_NOT_CONFIGURED`. Merged
to `main` (merge commit `1df5e6de83ea26e5741ce31edb2ff5c31c7d60a1`, story
boundary `NONE` completed).

### Fix 2 — BLOCKED, pushed back with evidence (not applied)

`.ai-team-bundle/runtime/tools/render-design-canvas.js` is untracked and
`.gitignore`d in this repo (`.ai-team-bundle/` matches `.gitignore:5`), does
not exist in ANY worktree (including the dedicated `-NONE` worktree), and is
confirmed generated/projected output from a separate bundle source repo
(`.agents/skills/`/`.bundle-runtime/`), not part of cupid-apps. Any in-place
edit here would be invisible to git, invisible to every other worktree/agent,
and would not survive a future `install.sh --platform=claudecode` re-run.
Frank-Devops correctly declined to patch it and recommends the fix land in
the bundle source repo instead.

**Net effect**: the design-reference-side render (Claude Design canvas driven
to a non-`home` `startPage`) remains impossible in this repo. The
implementation-side render (Fix 1) now works for every route. A true rendered
design-vs-implementation comparison for the 7 non-home REQ-006 pages is still
not achievable without an out-of-repo bundle fix.

This is now a fresh Scrum-Master/user decision point (see next update in
scrum-master-checkpoint.md for the options being escalated).

### User decision (2026-08-21, second decision on this doc)

Asked via `AskUserQuestion`: how should the 7 pending non-Home re-reviews
proceed given Fix 2 is structurally blocked. **Answer: proceed with
best-available evidence.**

Effective standard for all pending/future REQ-006 story reviews on the
visual-fidelity axis (UI-Fidelity-AC / AC-6 / AC-9 / AC-10, whichever id each
story's `requirements.md` uses):

- Implementation-side: a real `render-running-app.js` capture against the
  built app (Fix 1) is REQUIRED at 375/768/1280px for the story's route(s).
- Design-reference side: `render-design-canvas.js` render is available only
  for `home`. For every other screen, the design-reference side is satisfied
  by the story's `uiux-spec.md` (and any already-captured
  `design-reference-home-*.png` for shared components/tokens), not a
  screen-specific rendered canvas image.
- Reviewers certify CLEAN/DEFERRED_ONLY on the visual-fidelity finding when
  the implementation render matches the uiux-spec's documented layout,
  spacing, type, and color-token intent for that screen. The missing
  screen-specific canvas render itself is NOT a defect to keep re-opening; it
  is recorded once per story as a DEFERRED finding citing this document and
  is not grounds for `PATCH_REQUIRED`/`BLOCKED` on its own.
- Stories may now resume normal review-and-merge on the visual-fidelity axis
  under this standard. Story merges remain otherwise gated on their other
  findings (entry-point reachability, runtime startup smoke, etc.) as normal.
- Out of scope for this session: actually fixing `render-design-canvas.js` in
  the separate bundle source repo. If the user wants that pursued, it is a
  separate, non-cupid-apps task.
