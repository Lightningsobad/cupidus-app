---
story_status_recommendation: "IN_PROGRESS"
implementation_status_recommendation: "KEEP_CHECKED"
reviewed_at: 2026-08-22
reviewed_by: Reviewer
---

# Review Report: REQ-006 Web frontend implementation from design system & production deploy — Requirement Integration Review

Outcome: PATCH_REQUIRED

## Reviewed Inputs

- Review gate: `requirement-integration-review`
- Scope Gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/integration-review/scope-gate.md`
- Requirements:
  - `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/req_master.md`
  - `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/requirements/requirements.md`
- Bug Report: `N/A`
- Diagnosis: `N/A`
- Fix Evidence: `N/A`
- UX: per-story `STORY-00N/ux/uiux-spec.md` (referenced through story evidence, not re-reviewed)
- Architecture: per-story `STORY-00N/architecture/solution.md` (referenced, not re-reviewed)
- Coding Plan: per-story `STORY-00N/coding-plan/master-plan.md` (referenced, not re-reviewed)
- Test Results: the 8 `STORY-00N/coding-plan/test-results.md` and 8
  `STORY-00N/visual-fidelity/visual-fidelity-report.md` files, plus this
  reviewer's own integration build/runtime run (see `## Integration Build & Runtime`)
- Previous review findings: the 8 story review reports, all `Outcome: DEFERRED_ONLY`
- Governing evidence standard:
  `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/design-fidelity-tooling-fix.md`
- Deployment/config source of truth:
  `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/deployment/configuration-guide.md`

## Reviewed Scope

- Story complexity: `N/A` (requirement-level integration review; all 8 member stories are `standard`)
- Bug status: `N/A`
- Integration branch: `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-integration`
- Diff baseline: `a648a5a..6459088` — 253 files changed, 24229 insertions, 92 deletions
- Merged stories verified present on this branch:

| Story | Screen | Merge commit | Story outcome |
|---|---|---|---|
| STORY-001 | home | `8c6f2fd` | DEFERRED_ONLY |
| STORY-002 | pets | `6459088` (supersedes `d0c5a04`) | DEFERRED_ONLY |
| STORY-003 | zodiac | `001f4c2` | DEFERRED_ONLY |
| STORY-004 | share | `619ad99` | DEFERRED_ONLY |
| STORY-005 | blog | `e93ca05` | DEFERRED_ONLY |
| STORY-006 | about | `74fd90f` | DEFERRED_ONLY |
| STORY-007 | support | `5bc6570` | DEFERRED_ONLY |
| STORY-008 | legal | `bb7dc56` | DEFERRED_ONLY |

- Code scope reviewed: requirement-level integration surfaces only, per the
  scope gate — `cupid-app-design-system/support.js`,
  `cupid-app-design-system/Cupid Web.dc.html` (targeted `dc-import` enumeration),
  `data/devops/system/design-fidelity-config.json`,
  `data/devops/system/runtime-command-registry.json`,
  `web/src/data/site-nav.ts`, `web/src/components/shell/*`,
  `web/src/layouts/SiteLayout.astro`, `web/src/scripts/theme-lang-boot.ts`,
  `web/src/styles/*`, `web/astro.config.mjs`, `web/package.json`,
  `scripts/build.sh`, `scripts/start-dev.sh`,
  `.github/workflows/deploy-web.yml`. Per-screen page bodies and per-screen
  components were NOT re-reviewed — they are covered by the 8 passing story
  reviews.
- Evidence reviewed: 8 story review reports, 8 visual-fidelity reports,
  `design-fidelity-tooling-fix.md`, `deployment/configuration-guide.md`,
  `scrum-master-checkpoint.md` (query-key reads only)
- Risk surfaces reviewed: shared design-canvas render tooling; shared
  design-fidelity config; shared app shell / cross-screen nav contract;
  requirement-level visual-fidelity standard; runtime/deploy configuration
  consistency
- Critical gates reviewed: G1-G7 from the scope gate
- Backend targeted verification gates: `NOT_APPLICABLE` (static site, no backend change — OQ-REQ006-2 RESOLVED)
- Story runtime startup smoke: `PASS` (re-run at requirement level, see below)
- Frontend targeted verification gates: `PASS`
- Frontend discoverability/navigation integration: `PASS`
- Requirement frontend visual audit: `PATCH_REQUIRED` (never run — see INT-2 and INT-3)
- Mobile targeted verification gates: `NOT_APPLICABLE`
- Mobile discoverability/navigation integration: `NOT_APPLICABLE`
- Requirement mobile visual audit: `NOT_APPLICABLE` (no mobile participation in REQ-006)
- Story artifacts reviewed: `STORY-001..STORY-008` review reports and visual-fidelity reports
- Bug artifacts reviewed: `N/A`
- OQ context reviewed: OQ-REQ006-1 (stack choice — resolved by STORY-001: Astro static), OQ-REQ006-2 (RESOLVED: no API dependency)

## Integration Build & Runtime

Run by Reviewer against the merged integration branch at HEAD `6459088`, in the
integration worktree, with Node v22.17.1 (the version `web/package.json`
`engines` and the runtime registry require; the machine default `node` is
v20.20.2 and cannot run `astro@6`).

- Build: PASS — `cd web && npm ci && npm run check && npm run build` → `npm ci` added 331 packages; `astro check` on 52 files reported `0 errors, 0 warnings, 0 hints`; `astro build` reported `8 page(s) built`, `output: "static"`, exit 0.
- Runtime/Smoke: PASS — `cd web && npm run preview -- --port 21521 --host 127.0.0.1`, then `curl -s -o /dev/null -w "%{http_code}"` against all 8 requirement routes: `/` 200, `/pets/` 200, `/zodiac/` 200, `/share/` 200, `/blog/` 200, `/about/` 200, `/support/` 200, `/legal/` 200. Server stopped after capture.

Port note: the reserved local web port is `DEVSTACK_PORT_WEB` = 21021
(`sharedInfra.reservedPorts.web`). This review used a private port 21521 for
smoke capture because 21021 is shared with other worktrees in this wave; the
production/dev contract itself is unchanged and still reads 21021 from
`.env.devstack`.

## Outcome Summary

- Review outcome: PATCH_REQUIRED
- Rationale: the merged tree is technically sound — it builds clean, all 8
  routes boot and return 200, the shared shell contract was honored exactly
  (built once in STORY-001, never forked), and the shared `support.js` change
  is provably safe for the other 7 screens (INT-CLEAN-1 below). What blocks
  requirement closure is evidence integrity, not code: three of the four
  requirement-level gates that this requirement's own governing artifacts
  declare mandatory are either missing or resting on a premise that the
  merged evidence itself falsifies. The requirement carries a hard user
  acceptance requirement of "giống 100%" visual fidelity, and 6 of 8 screens
  currently certify that with no rendered design reference at all, on the
  stated grounds that such a render is impossible — while STORY-002's merged
  evidence shows the exact command producing it successfully. That
  contradiction must be resolved before the requirement can be called done.
- Blocking findings: 4
- Deferred findings: 3
- Dismissed observations: 2

## Traceability Summary

- Requirements: `requirements/requirements.md` Coverage Map row "100% visual-fidelity acceptance requirement | STORY-001 through STORY-008" — every UI story carries its own `UI-Fidelity-AC`. All 8 stories recorded `VISUAL_FIDELITY: PASS`; INT-2 challenges the evidentiary basis for 6 of them.
- Business rule "global chrome built exactly once in STORY-001, reused unmodified" (`requirements.md:80-83`): **VERIFIED CLEAN.** `git log a648a5a..6459088 -- web/src/components/shell/ web/src/layouts/SiteLayout.astro web/src/data/site-nav.ts web/src/styles/ web/src/scripts/theme-lang-boot.ts` returns exactly two commits, both STORY-001 (`11590f5` P1 scaffold, `44a4151` P2 global shell). No later story forked or modified the shell.
- Business rule "no backend endpoint change" (`requirements.md:86-88`): **VERIFIED CLEAN.** The requirement diff touches no `backend/` path.
- Bug report: `N/A`
- Diagnosis: `N/A`
- Open Questions: OQ-REQ006-1 resolved by STORY-001 (Astro static, `output: 'static'`); OQ-REQ006-2 resolved and consistent with the shipped tree (no `fetch`/API call in `web/src`, no backend dependency in the runtime registry entry).
- Testing evidence: 8 per-story `test-results.md` + 8 `visual-fidelity-report.md` + this report's `## Integration Build & Runtime` section.

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|--------------|-----------------|---------------|--------|-------|
| Shared design-canvas render tooling (`support.js` `HOST_STYLE_PROPS`) | `cupid-app-design-system/Cupid Web.dc.html` | G1: mid-requirement shared-file change must not silently invalidate the 7 screens whose evidence predates it | PASS | See INT-CLEAN-1. Exhaustively verified, not sampled. |
| Shared design-fidelity config | `data/devops/system/design-fidelity-config.json` | G7: canvas entry re-locked to `Cupid Web.dc.html`, `app_render` block correct | PASS | `hide_selectors` removal verified correct — see Dismissed Observation 1. |
| Shared app shell / cross-screen nav contract | `requirements.md:80-83`, `Cupid Web.dc.html:715-718,831-848` | G3: 8-route completeness + shell built once, reused unmodified | PASS | 8 routes build and serve 200; header+footer nav present on all 8 pages; shell touched only by STORY-001. |
| Requirement-level visual-fidelity standard ("giống 100%") | `req_master.md` Business Scope, `design-fidelity-tooling-fix.md` | G2/G5: cross-story evidence consistency + requirement visual audit | **PATCH_REQUIRED** | INT-2 (falsified waiver premise) and INT-3 (audit never run). |
| Integration build + runtime | reviewer rule 12g3 | G4: `Build: PASS` and `Runtime/Smoke: PASS` in `integration-review/` | PASS | Produced by this review; see `## Integration Build & Runtime`. |
| Runtime/deploy configuration consistency | `runtime-command-registry.json`, `deployment/configuration-guide.md` | G7: registry/scripts/workflow/guide agree | PASS (code) / **PATCH_REQUIRED** (state) | Artifacts agree with each other; `req_master.md`'s Configuration Documentation block contradicts them — INT-4. |
| Requirement state consistency | `req_master.md` User Stories table | G6: table matches actual merged story status | **PATCH_REQUIRED** | INT-5. Scrum-Master-owned. |

## Blocking Finding Verification

`N/A` — this is a first-pass requirement integration review, not a re-review.
The 8 member stories' own previous blocking findings were closed at story
level; `BLK-VF-1` (STORY-002) is confirmed genuinely closed on this branch:
`support.js:456-459` carries the `flex`/`flex-shrink`/`flex-basis`/`flex-grow`
entries, and STORY-002's design references were re-rendered after that fix
(`d64feab`, then confirmed at `c2208b3`).

## Blocking Findings

### INT-CLEAN-1 (not a finding — the explicit cross-story question, answered)

The handoff asked whether the STORY-002 shared-file change to
`cupid-app-design-system/support.js` silently invalidated the already-recorded
`VISUAL_FIDELITY: PASS` for STORY-001 and STORY-003..008, whose design-reference
renders predate it. **It did not.** This was verified exhaustively rather than
spot-checked, because the search space is small enough to close completely:

`hostPositionStyle()` (`support.js:461-470`) copies a property onto the
`dc-import` host **only if that host's own inline `style` declares it**. So the
four added allowlist entries can only change rendered output for a `dc-import`
host that itself declares `flex`, `flex-shrink`, `flex-basis`, or `flex-grow`.
`git grep -n "dc-import" -- "cupid-app-design-system/Cupid Web.dc.html"` returns
all 22 hosts in the canvas. Exactly six declare a `flex*` property —
`:222`, `:230`, `:238`, `:246`, `:254`, `:262`, all
`style="width:130px;height:130px;flex:0 0 130px"` — and all six are the pets
roster, i.e. STORY-002, whose references were re-rendered after the fix.

The near-miss family worth naming explicitly, since it is the one that looks
like the same case and is not: the zodiac element cards at `:336`, `:340`,
`:344`, `:348` DO place `dc-import` hosts inside `display:flex` rows. But those
hosts declare only `width:46px;height:46px` — both already in `HOST_STYLE_PROPS`
before the fix — so `hostPositionStyle()` returns an identical object before and
after, and STORY-003's renders are bit-for-bit unaffected. Likewise `:411`'s
`flex:1` sits on a plain wrapper `<div>`, not on a `dc-import` host, so the
allowlist never sees it. Home (`:128`, `:164-189`) declares no flex property on
any host.

Conclusion: no re-render is required for STORY-001 or STORY-003..008 on account
of the `support.js` change. (INT-2 below asks for re-renders for a different and
unrelated reason.)

### INT-1 — Integration build and runtime evidence was absent (RESOLVED BY THIS REVIEW, recorded for the audit trail)

Before this review, `data/requirements/REQ-006_.../integration-review/`
contained no tracked files at all, so the requirement carried neither the
`- Build: PASS` nor the `- Runtime/Smoke: PASS` line that reviewer rule 12g3
requires, and `req_master.md` records no `Integration-Verify: WAIVED`. Rather
than return `PATCH_REQUIRED` for missing evidence that the Reviewer can itself
produce, this review ran the gate directly and recorded the result in
`## Integration Build & Runtime` above. Both lines are PASS. **No action
required** — this entry exists so the gap is visible in the audit trail rather
than silently backfilled.

### INT-2 — The design-reference waiver governing 6 of 8 screens rests on a premise the merged evidence falsifies (BLOCKING)

The user-decision standard recorded in
`design-fidelity-tooling-fix.md:112-116` and `:133-137` states, as fact, that
driving the design canvas to a non-`home` screen is impossible in this
repository:

> **Net effect**: the design-reference-side render (Claude Design canvas driven
> to a non-`home` `startPage`) remains impossible in this repo.

> Design-reference side: `render-design-canvas.js` render is available only
> for `home`. For every other screen, the design-reference side is satisfied
> by the story's `uiux-spec.md` [...] not a screen-specific rendered canvas image.

STORY-002's merged visual-fidelity evidence contradicts this directly.
`STORY-002/visual-fidelity/visual-fidelity-report.md:104-114` records:

> Design reference — real `render-design-canvas.js` captures (exit 0):
> `node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=web --screen=pets --out=<story>/visual-fidelity/design-reference`

with three real files committed on this branch —
`design-reference/design-reference-pets-375.png` (375x600),
`-768.png` (768x1229), `-1280.png` (1280x2048). `pets` is not `home`.

Six screens — zodiac (STORY-003), share (STORY-004), blog (STORY-005), about
(STORY-006), support (STORY-007), legal (STORY-008) — hold
`VISUAL_FIDELITY: PASS` whose design-reference side is satisfied *solely* by
this now-falsified waiver. STORY-003's report states it in as many words at
`:50-55` ("a rendered `design-reference-zodiac-*.png` is structurally
unproducible in this repository") and again at `:105-111`; STORY-005 carries
the same construction at `:9` and `:68`. The requirement diff confirms it
materially: only STORY-001 (home) and STORY-002 (pets) committed any
`design-reference-*.png`; the other six committed implementation captures only.

Why this is blocking rather than deferrable, given the waiver came from a user
decision: the user's decision was *"proceed with best-available evidence"*,
taken on 2026-08-21 on the explicit factual premise that a non-home canvas
render could not be obtained. On 2026-08-22 that premise was disproven inside
this same requirement. A decision whose stated basis has been falsified cannot
carry a strict "giống 100%" pixel-fidelity acceptance requirement
(`req_master.md` Business Scope) through to closure without being put back to
the decision-maker. And the difference is not academic: the rendered-vs-rendered
comparison is precisely what caught `BLK-VF-1` on pets — a sprite rendering at
76px against the design's 132px — a defect the uiux-spec-transcription path had
already passed. Six screens have not had that check.

Note the residual uncertainty honestly: this review did **not** re-run
`render-design-canvas.js --screen=zodiac` (etc.) to prove the other six screens
render. The tool is gitignored bundle output (`design-fidelity-tooling-fix.md:102-108`)
and running it is frontend-dev/DevOps work, not reviewer work. What is proven is
that the blanket claim "available only for `home`" is false, so the waiver can no
longer be applied to the remaining six screens without per-screen re-testing.

### INT-3 — Requirement-level frontend visual audit was never run (BLOCKING)

`req_master.md` Technical Constraints names this gate explicitly as a
precondition for closure:

> it needs the full UI-lane review gate with `design_source` and `ui_surface`
> configured, plus the requirement-level `frontend-dev`
> `Mode: requirement-visual-audit` before this requirement can be marked DONE.

`scrum-master-checkpoint.md:206-207` and `:327` also carry it as an outstanding
next step. No `visual-audit.md` (or equivalent) exists anywhere in
`data/requirements/REQ-006_.../integration-review/`. This gate is independent of
INT-2: it is the cross-screen consistency pass (navigation, shell, theme/lang
behavior, token drift between screens) that no per-story capture can substitute
for. Multiple stories also routed deferred findings *to* this audit — STORY-003's
`V-1` (design-source-inherited icon clipping at 375px,
`STORY-003/visual-fidelity/visual-fidelity-report.md:86-101`) is explicitly
"routed to UI/UX Designer at the requirement-level visual audit", so those
deferrals currently have no landing point.

### INT-4 — `req_master.md` Configuration Documentation block contradicts the merged configuration guide, hiding required pre-deploy user setup (BLOCKING)

`req_master.md:9-13` records:

```
## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:
```

The merged `deployment/configuration-guide.md` says otherwise, in detail. It
documents two manual setup steps that must happen before the first production
deploy can succeed, plus one unverified authentication risk:

1. **VPS Caddy site block** (`:82-98`) — a `cupidus.app, www.cupidus.app` block
   with `try_files` + `file_server` must be appended to `/etc/caddy/Caddyfile`
   by hand, "the same manual/SSH operational step REQ-005 §1 performed for
   `api.cupidus.app`, to be [applied]".
2. **New GitHub Actions secret `VPS_WEB_DEPLOY_PATH`** (`:110`) — marked
   "**NEW — placeholder only, not provisioned by this phase**". `deploy-web.yml`
   reads it; without it the deploy job cannot resolve its target directory.
3. **Unverified SSH forced-command scope** (`:115-131`) — REQ-005's
   `VPS_SSH_PRIVATE_KEY` is restricted server-side to commands prefixed with
   the literal `cd /var/www/backend && `, and REQ-005's own guide says "do not
   reuse for a second deploy unit". `vps-deploy-web.sh` prefixes every remote
   command with `cd ${VPS_WEB_DEPLOY_PATH} && ` instead, which that wrapper
   will refuse. Not verified against the live wrapper because this phase was
   instructed not to SSH to the VPS.

This matters concretely because `req_master.md:7` records
`Production: REQUESTED (direct user instruction)`. `Pending User Setup: NONE`
is the field a deploy route reads to decide there is nothing to ask the user
for; acting on it here produces a red pipeline at best, and at worst an SSH
attempt with a key that is not authorized for that path. The configuration
guide itself is good work — the defect is purely that the requirement-level
state block was never updated to point at it.

### INT-5 — `req_master.md` story table shows STORY-002..008 as `PENDING` although all 8 are TERMINAL and merged (BLOCKING, state-only)

`req_master.md:81-88` lists STORY-001 `DONE` and STORY-002 through STORY-008 all
`PENDING`, on a branch where all 8 story merges are present and all 8 story
review reports record `DEFERRED_ONLY`. This is Scrum-Master-owned state and the
Reviewer must not edit it, but the requirement cannot be closed against a table
that misreports 7 of its 8 stories.

## Deferred Findings

- **D-INT-1 — `<title>` pattern is inconsistent across the 8 screens.** Measured
  from the live smoke run: `Cupid` (home), `Pets — Cupid`, `Hoàng đạo — Cupid`,
  `Cupid — Ghép đôi` (reversed order), `Cupid Journal — Cupid` (brand twice),
  `Giới thiệu & Bộ nhận diện thương hiệu — Cupid`,
  `Hỗ trợ & FAQ · Support & FAQ — Cupid` (both locales concatenated into one
  tab title), `Quyền riêng tư & Điều khoản — Cupid`. Each story chose its own
  pattern in isolation, which is the expected cost of 8 parallel branches. It is
  user-visible (browser tabs, search results, link previews) but no story's AC
  covers it and the design source does not specify titles. Route to the
  requirement visual audit (INT-3) rather than patching blind.
- **D-INT-2 — STORY-002 evidence was captured on port 21023, which the runtime
  registry reserves for `docs`.** `STORY-002/visual-fidelity/visual-fidelity-report.md:127-131`
  documents the reasoning honestly (reserved web port 21021 was held by the
  STORY-003 worktree, and server identity was verified with
  `lsof -a -p <pid> -d cwd` before capture), so the evidence itself is sound.
  The habit is not: 21023 is another role's reserved port, not a free one. A
  future parallel wave should lease a private port rather than borrow a
  reserved one. Evidence hygiene only; no impact on this requirement's
  correctness.
- **D-INT-3 — per-story deferred findings have no landing point until INT-3
  runs.** At minimum STORY-003's `V-1` (design-source-inherited 375px icon
  clipping in the daily compatibility card, correctly reproduced from
  `Cupid Web.dc.html:293`) was explicitly routed to the requirement-level
  visual audit. Carry these forward into that audit rather than closing them
  here.

## Dismissed Observations

1. **`hide_selectors` removed from `design-fidelity-config.json` when the lock
   moved from `Cupid App.dc.html` to `Cupid Web.dc.html` — verified correct, not
   a regression.** The removed selector hid the mobile canvas's prototype
   screen-index FAB. `git grep -c -E "z-index: ?95|toggleIndex|pickScreen" -- "cupid-app-design-system/Cupid Web.dc.html"`
   returns no match: the web canvas has no such FAB, so there is nothing to hide
   and keeping the selector would only produce the renderer's "selector matched
   nothing" warning.
2. **253 changed files did not trigger a scoped-slice split.** The
   integration-review file budget applies to source/config files under review;
   ~30 of the 253 are source/config and the scope gate narrowed those to 16
   requirement-level integration surfaces, with per-screen implementation
   explicitly delegated to the 8 passing story reviews. The remainder are
   per-story artifacts and PNG evidence.

## Implementation Action Items

- `[scrum-master / user decision]` INT-2: put the falsified premise back to the
  user. `render-design-canvas.js --surface=web --screen=pets` demonstrably works
  (exit 0, three real captures on this branch), so the 2026-08-21 "proceed with
  best-available evidence" decision was made on a factual basis that no longer
  holds. Ask whether to re-render design references for the 6 remaining screens
  (`zodiac`, `share`, `blog`, `about`, `support`, `legal`) and re-run their
  visual-fidelity comparisons, or to re-affirm the waiver now that its stated
  reason is known to be wrong.
- `[frontend-dev] Mode: requirement-visual-audit` INT-3: run the requirement-level
  visual audit across all 8 screens and write it under
  `data/requirements/REQ-006_.../integration-review/`. If INT-2 is resolved in
  favor of re-rendering, fold the 6 design-reference renders into the same pass —
  `--screen=<id>` is the command STORY-002 used, and
  `design-fidelity-config.json` is already locked to `Cupid Web.dc.html` with a
  working `app_render` block. Take in STORY-003 `V-1` and D-INT-1.
- `[scrum-master] data/requirements/REQ-006_.../req_master.md` INT-4: update the
  Configuration Documentation block — `Status` is not `NOT_REQUIRED`,
  `Pending User Setup` is not `NONE` (VPS Caddy site block; new
  `VPS_WEB_DEPLOY_PATH` secret), and `Last Updated` is empty. Surface the SSH
  forced-command scope risk (`configuration-guide.md:115-131`) to the user
  before any production deploy is attempted.
- `[scrum-master] data/requirements/REQ-006_.../req_master.md` INT-5: set
  STORY-002..STORY-008 to `DONE` in the User Stories table to match their
  merged/TERMINAL state.
- `[devops or user, pre-deploy]` INT-4 item 3: confirm whether
  `/root/.ssh/deploy-wrapper.sh` accepts the `cd ${VPS_WEB_DEPLOY_PATH} && `
  prefix, widen it, or provision a separate `VPS_WEB_SSH_PRIVATE_KEY`. This is
  the item most likely to fail the first real `deploy-web.yml` run.

## Workflow State Recommendation

- Story status: `N/A` — all 8 member stories are correctly TERMINAL and merged;
  none of the findings above reopen a story.
- Requirement status: `IN_PROGRESS` — do not mark REQ-006 `DONE`.
- Bug status: `N/A`
- `Implementation (Development)`: `KEEP_CHECKED` — the code is sound; every
  blocking finding is evidence, gate, or state, not implementation defect.
- `Review (Reviewer)`: `LEAVE_UNCHECKED`
- Next step: resolve INT-2 with the user, then run the requirement visual audit
  (INT-3), then correct `req_master.md` (INT-4, INT-5), then re-run this
  requirement integration review. The `## Integration Build & Runtime` gate above
  is already satisfied and does not need re-running unless the tree changes.
- State update owner: `scrum-master` only. Reviewer does not edit story or
  requirement status files.
