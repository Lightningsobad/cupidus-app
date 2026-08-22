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

- Status: FIX_1_DONE_FIX_2_DONE — real screen-specific design-reference
  rendering is now available for all REQ-006 web screens; the
  best-available-evidence standard below is SUPERSEDED (see 2026-08-22
  decision) and re-review of the visual-fidelity AC is required across all 7
  previously-affected stories
- Opened: 2026-08-21
- Closed (Fix 1): 2026-08-21
- Closed (Fix 2): 2026-08-22

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

### Fix 2 — RESOLVED 2026-08-22 (supersedes the BLOCKED entry above)

User report (2026-08-22): "DEF-2 đã lỗi thời và yêu cầu re-review AC-9" (DEF-2
is outdated and requires re-review of AC-9). Clarified via `AskUserQuestion`:
reason = "the tool has been fixed" (Công cụ đã được sửa); scope = whole
REQ-006 (Toàn bộ REQ-006), not just the story that raised it.

Verified directly by Scrum Master before acting on the claim (not taken on
trust):

1. `.ai-team-bundle/runtime/tools/render-design-canvas.js` now exists (845
   lines) and its inventory step now reads the bundle runtime's own prop
   registry (`window.__dcRegistry`/`__dcSetProps`), detecting a `startPage`-
   shaped enum prop as a screen selector in addition to the old
   `[data-screen-btn]` DOM contract. This directly targets the root cause in
   this doc's "Root cause" section (item 1).
2. `data/devops/system/design-fidelity-config.json` now carries a second
   `design_sources` entry (`id: cupid-web`, `surface: web`, `entry: Cupid
   Web.dc.html`, `screens_from: "prop:startPage"`, `screen_prop: "startPage"`),
   recorded by `ui-ux-designer` at `2026-08-22T02:17:06Z` — matches
   `req_master.md`'s `Design-Source: UPDATED 2026-08-22T02:17:06Z` note.
3. Empirical run, this session: `node
   .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=web
   --list-screens` returns `screens: ["home","pets","zodiac","share","blog",
   "about","support","legal"]`, `screens_from: "prop:startPage"` — no longer
   the empty `{"screens":[],...}` this doc originally diagnosed.
4. Empirical render, this session: `node
   .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=web
   --screen=share --out=<tmp>` produced real
   `design-reference-share-{375,768,1280}.png` files (exit 0, real PNG
   dimensions reported) — the exact artifact shape
   `hooks/lib/visual_fidelity.py` and reviewers require. Temp output was
   discarded after verification; each story's real re-review must render its
   own screen into that story's worktree/output path, not reuse this probe.

**Net effect**: the design-reference-side render is no longer limited to
`home`. All 7 non-home REQ-006 screens (`pets`, `zodiac`, `share`, `blog`,
`about`, `support`, `legal` — STORY-002, STORY-003, STORY-004, STORY-005,
STORY-006, STORY-007, STORY-008 respectively) can now get a genuine rendered
design-reference image, not a `uiux-spec.md` citation.

### User decision (2026-08-22, third decision on this doc) — supersedes the best-available-evidence standard

Because the blocker that produced the "best-available-evidence"/SPEC-CITED
standard (2026-08-21 decision, above) is resolved, that standard no longer
applies going forward. New effective standard for REQ-006 visual-fidelity
findings recorded under this doc's citation (`DEF-2`-pattern deferred
findings, and any story that substituted `Visual-Fidelity-Evidence:
SPEC-CITED` for a rendered design-reference):

- Design-reference side is now REQUIRED to be a genuine
  `render-design-canvas.js --surface=web --screen=<id>` capture (matching
  `design_sources[id=cupid-web].screen_prop`), not a `uiux-spec.md` citation.
- Implementation side stays as already established: `render-running-app.js`
  capture at 375/768/1280px (Fix 1, unchanged).
- Scope, per explicit user decision: **all of REQ-006** — STORY-002,
  STORY-003, STORY-004, STORY-005, STORY-006, STORY-007, STORY-008 each need
  a fresh Reviewer pass on the visual-fidelity AC (UI-Fidelity-AC / AC-6 /
  AC-9 / AC-10, whichever id that story's `requirements.md` uses) comparing a
  real rendered design reference against a real rendered implementation
  screenshot at the same breakpoints. STORY-001 (home) already had a real
  canvas render and is not reopened by this decision.
- Any story previously marked `DONE`/merged on the strength of the superseded
  SPEC-CITED standard is provisionally reopened on the visual-fidelity axis
  only; other findings for that story are not reopened by this decision.
- This is Scrum-Master-tracked rework, not a new bug or new product scope:
  route it as re-review dispatches to `reviewer` per story, using each
  story's existing worktree/branch where still available, or a fresh
  worktree off `main` where the story worktree was already cleaned up.

## New defect found during STORY-002 re-review: `dc-import`-in-flex-row width loss (2026-08-22)

STORY-002's re-review (Iris-QC, `RUN-...-STORY-002-reviewer2`) found `BLK-VF-1`:
the design-reference render showed the Bo Sprite pet-card sprite at
~74-76px wide against a `flex:0 0 130px` declared box (`Cupid Web.dc.html:222`).
User rejected both of Scrum Master's initial theories (renderer bug /
markup-equivalence certification) without design-authority evidence and
directed: route the 74px-vs-130px call to `ui-ux-designer`, fix whichever side
is wrong, re-render to verify.

**Pink-Designer's finding** (`STORY-002/ux/uiux-spec.md` §6.2.2/§6.8, sealed
worktree commit `3269e1c1cb0e46f18487bb17fb86b1805ff4f269`,
`UX_COMPLETE: YES`): neither side is wrong. The `dc-import` target
(`Bo Sprite.dc.html`) uses a perfect 1:1 `viewBox="0 0 200 200"` across all 6
pet-state variants, and its own `$preview` metadata is square (`260x260`) —
there is no non-square ratio anywhere in the source asset to derive ~74px
from. **130px is the design-intended value; `PetRoster.astro:30` already
matches it.** The defect is `render-design-canvas.js` losing the declared
`style`/`hint-size` on a `<dc-import>` host node when that node sits inside a
flex-row ancestor (as opposed to Home's `display:grid;place-items:center`
wrapper, which does not exhibit this). Pink-Designer flags
`Zodiac Icon.dc.html` (STORY-003) as the same pattern (`viewBox="0 0 100 100"`,
also square, also flex-row-imported) and a likely same-family case, but has
not confirmed it directly — STORY-003 is already `TERMINAL`/`DEFERRED_ONLY`/
`PASS` from its own re-review and is not being reopened by this note alone.

**Tooling-ownership problem (same as the original Fix 2 blocker above):**
`render-design-canvas.js` ships from `.ai-team-bundle/runtime/tools/`,
projected/generated from the separate bundle source repo, gitignored in this
repo (`.gitignore:5`). Frank-Devops previously declined to hand-patch this
exact file in place (evidence above, "Fix 2 — BLOCKED") because an in-place
edit would not survive a future `install.sh` re-run and is invisible to other
worktrees. The same reasoning applies to this new `dc-import`-in-flex-row
defect: it should not be hand-patched locally by a story specialist.

**Net effect on STORY-002**: BLK-VF-1's underlying visual-delta question is
answered (130px is correct, no code/asset change needed) but the tool used to
produce the rendered design-reference comparison remains defective for this
specific layout shape (`dc-import` inside a flex row), so a corrected
side-by-side rendered comparison still cannot be produced in this repo without
an upstream bundle fix — this is a fresh instance of the exact
tool-ownership tradeoff the 2026-08-21 and 2026-08-22 decisions above already
covered once. Escalated to the user as a narrow decision (see
`scrum-master-checkpoint.md`) rather than resolved unilaterally, per the same
precedent.

**User rejected this closure path (2026-08-22, own re-measurement, verbatim
translated).** "Not a tool artifact: `sc-host` retains `width:130px`, but is
squeezed to 74.3px by the flex row — even at 1440px this is the component's
own `$preview.width`, not the real `/pets` page render. The declared style is
NOT lost. 130px is very likely the component's own standalone preview value,
not what the actual pets-page render shows. This is a real visual delta: the
implementation gives the sprite more room than the design. Do not close via
spec citation — have Pink-Designer cross-reference the actual rendered
`/pets` page (not the isolated component `$preview`), then decide: fix the
flex row in the design source, or fix `PetRoster.astro`."

The user is pointing out a likely methodology gap in the prior Pink-Designer
pass: citing `Bo Sprite.dc.html`'s own `viewBox`/`$preview` metadata
(component-isolated) is not the same evidence as measuring the sprite's
*rendered* box inside the actual composed `Cupid Web.dc.html` `isPets` page
layout, where flex-row sibling/container constraints can still shrink a
130px-declared child below its declared size depending on the row's other
flex rules (e.g. missing `flex-shrink: 0`, a competing `flex-basis`, or
container width pressure) — a real CSS layout effect, not a renderer bug and
not an asset-ratio artifact. Re-dispatched to `Pink-Designer` (fresh spawn,
prior session task stopped) to redo the measurement against the actual
rendered `/pets` page (`render-design-canvas.js --surface=web --screen=pets`,
or direct inspection of `Cupid Web.dc.html`'s `isPets` block computed flex
context) and name which side is actually wrong.

## RESOLVED 2026-08-22: BLK-VF-1 root cause confirmed and fixed — `cupid-app-design-system/support.js`

Pink-Designer's composed-context re-measurement (worktree commit
`74a86c44516b3cdcba7757f21fea76f98d115769`) traced the shrink to code, not
asset ratio or renderer-vs-page discrepancy: `support.js`'s
`hostPositionStyle()` (`support.js:457-466`, called from `walkComponent()` at
`support.js:676`) builds each `<dc-import>` host node's inline style by
filtering through an allowlist `HOST_STYLE_PROPS` (`support.js:445-456`) =
`{position, left, right, top, bottom, inset, width, height, z-index,
transform}`. `flex`/`flex-shrink`/`flex-basis`/`flex-grow` were NOT in that
allowlist, so `Cupid Web.dc.html:222`'s `flex:0 0 130px` was silently dropped
while `width:130px;height:130px` survived — exactly matching the user's own
DevTools observation (`sc-host` retains `width:130px`, style not lost) and
explaining the shrink mechanism (flex-shrink reverts to its CSS default of 1
once the shorthand is stripped, so the sibling text block's `flex:0 1 auto`
content-based basis pulls free space from the now-shrinkable sprite host).
Composed evidence: `design-reference-pets-1280.png` measured the Bo card
sprite at ~73-74px inside a 330.7px content-box column with ~178px of slack
after a 130px sprite + 22px gap, ruling out legitimate container-width-driven
shrink and matching the user's 74.3px DevTools measurement.

**Verdict**: neither `Cupid Web.dc.html`'s flex-row CSS nor
`PetRoster.astro:30` need to change — both already declare/implement the
130px/flex-shrink:0 intent correctly. The wrong side is
`cupid-app-design-system/support.js` (the design-canvas preview renderer).

**Independently verified by Scrum Master against primary source** (not taken
on trust): read `support.js:440-479` and `:655-694` directly in the STORY-002
worktree, confirming the exact allowlist content, `hostPositionStyle()` body,
and the `walkComponent()` call site cited above. Also confirmed `support.js`
carries a `// GENERATED from dc-runtime/src/*.ts — do not edit. Rebuild with
\`cd dc-runtime && bun run build\`.` header, that `dc-runtime/src/` does not
exist anywhere in this repo (not tracked, not gitignored — simply absent),
and that `git log --follow` shows this file was last wholesale-replaced by
commit `5ea820c` ("chore(design): replace the design bundle with the current
Claude Design..."). This is the same ownership class as the original Fix 2
blocker (`render-design-canvas.js`) — generated tooling with no local source
to regenerate from — but unlike that file, `support.js` IS git-tracked in
this repo (not `.gitignore`d), so a direct edit here is at least visible to
git and every worktree, even though it risks being silently overwritten by a
future wholesale design-bundle replacement.

**User decision (`AskUserQuestion`, 2026-08-22): hand-patch `support.js`
directly** (chosen over routing to Frank-Devops, and over closing BLK-VF-1 as
a documented tool-limitation DEFERRED finding without a code change).

**Fix applied**: `hot-fix` added `"flex"`, `"flex-shrink"`, `"flex-basis"`,
`"flex-grow"` to `HOST_STYLE_PROPS` in `cupid-app-design-system/support.js`
(now lines 445-460). Verified `node --check` syntax-clean. Committed directly
to `main`: `9aa0aed` "fix(design-canvas): preserve flex shorthand on dc-import
host style".

**Status: DONE.** Next: re-render `design-reference-pets-*.png` with the
patched `support.js` and dispatch a fresh `compact-story-review` cycle for
STORY-002's visual-fidelity finding to confirm `VISUAL_FIDELITY: PASS` before
the story can become merge-eligible.
