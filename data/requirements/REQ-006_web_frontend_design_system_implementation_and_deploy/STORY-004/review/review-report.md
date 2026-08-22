# Review Report — REQ-006 / STORY-004 Pairing Invite Landing Page

Outcome: DEFERRED_ONLY

Review type: `compact-story-review` (parallel story review, cycle 3 — narrow
BLK-1/BLK-2 re-review)
Reviewer: Iris-QC
Date: 2026-08-22
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-004`
Diff baseline: `dfc9fc10f0a4c00f50eb9621e8c2ffd71dfdcc78` → HEAD `5df48f46b25e57100911ea3368d7d8afeeae4dc7`
Story: `standard` / lane `frontend` / class `standard`

## Scope Gate

Inline per the compact-story-review template; no separate `scope-gate.md` was
written for this cycle (the cycle-2 file remains on disk as the record of the
full review).

- **In scope this cycle:** exactly two evidence items — BLK-1 (registry-backed
  story runtime startup smoke, rule 12g) and BLK-2 (canonical
  `## Entry Point Reachability` heading with `Reachable:` line, rule 12e1).
- **Out of scope this cycle:** AC-1..AC-10, shared-contract immutability, the
  risk-surface gate table, the visual inspection, and DEF-1/DEF-2/DEF-3. Cycle 2
  approved all code as-is and stated the re-review scope is "BLK-1 and BLK-2
  only… if the patch touches nothing under `web/`, the source review above
  stands without re-running."
- **Precondition for that carry-forward, verified:**
  `git diff --name-only 0cd7ca7..HEAD` returns four files, all under
  `data/requirements/.../STORY-004/` (`coding-plan/phase-P1-...md`,
  `coding-plan/test-results.md`, `review/review-report.md`,
  `review/scope-gate.md`). **Nothing under `web/` changed.** The cycle-2 source
  review therefore stands unmodified and is not re-derived here.
- **Diff reviewed this cycle:** `dfc9fc1..HEAD` — 2 files, +40/-1 lines, both
  documentation.

## Blocking findings

None. Both cycle-2 blockers are closed.

## Closed findings

### BLK-1 — story runtime startup smoke — CLOSED

`coding-plan/test-results.md:134` now carries the canonical section
`## Story Runtime Startup Smoke` with `**Result: PASS** | **Shutdown: PASS**` on
`:136`, and a `### Re-verification 2026-08-22 (Chris-FE, independent re-run)`
subsection at `:197`.

The command is registry-backed, and I checked it against the registry rather
than accepting the claim. `data/devops/system/runtime-command-registry.json`
`runtimes.web-frontend` gives `devCommand: "npm run dev"`, `readiness` =
`GET /` with `expectStatus: 200` on `http://127.0.0.1:${DEVSTACK_PORT_WEB}/`,
`hostPortEnv: DEVSTACK_PORT_WEB`, and `notes` records the exact start-dev form
`npm run dev -- --port "$DEVSTACK_PORT_WEB" --host 127.0.0.1`. `sharedInfra.reservedPorts.web`
is `21021`. The evidence's
`DEVSTACK_PORT_WEB=21021 npm run dev -- --port 21021 --host 127.0.0.1`
(`test-results.md:156`) matches all of that exactly — reserved port, not a
scanned or default `4321`.

**Non-fabrication check: I re-ran the smoke myself** rather than reading the
recorded transcript, in the same worktree under nvm Node `v22.17.1` (ambient
default is `v20.20.2`, below `astro@6.0.5`'s `>=22.12.0` floor, exactly as the
evidence states). My independent run:

```
NODE=v22.17.1
PRE_START_PROBE / http=000 curl_exit=7
DEV_PID=71030
READINESS_ATTEMPT=1 / http=000
READINESS_ATTEMPT=2 / http=200
READINESS_RESULT http=200 ready=1
STORY_ROUTE_PROBE /share/ http=200
SHARE_HERO_H1=PRESENT
SIGTERM_SENT=yes
SHUTDOWN_WAIT_SECONDS=1 sigkill_needed=no
POST_SHUTDOWN_PROBE / http=000
ORPHAN_LISTENER=NO
```

Server log from my run: `astro v6.0.5 ready in 698 ms`,
`Local http://127.0.0.1:21021/`, `[200] / 12ms`, `[200] /share/ 3ms`, and the
same dev-only `[WARN] [content] Content config not loaded` line the evidence
discloses. Every marker reproduces: free port before start, readiness 200 on
`GET /`, story route `GET /share/` 200 with the hero H1 present, clean SIGTERM
shutdown with no SIGKILL, connection refused after shutdown, no orphan listener.
The only difference from the recorded run is the readiness attempt count (mine
2, theirs 3), which is start-time jitter, not a discrepancy. **The evidence is
genuine, not fabricated.**

The contradiction is also resolved.
`coding-plan/phase-P1-invite-page-body-and-entry-point.md:33-38` no longer reads
`Startup Smoke: NOT_APPLICABLE`; it now reads
`Startup Smoke: REQUIRED — supplied`, points at the `test-results.md` section,
restates `Result: PASS | Shutdown: PASS`, and explicitly records that the prior
`NOT_APPLICABLE` claim was wrong for a non-trivial `frontend`-lane story with no
`Runtime-Smoke: WAIVED` entry. Plan and evidence now agree.

### BLK-2 — entry-point evidence form — CLOSED

`coding-plan/test-results.md:92` now uses the canonical rule-12e1 heading
`## Entry Point Reachability` — the numbered `## 4. Entry Point Reachability
(AC-1)` form is gone. `:94` carries the explicit `**Reachable: YES**` line and
`:96` the path `` `share` → `/share` ``. The supporting evidence table
(`site-nav.ts:33`, `web/src/pages/share.astro`, `SiteHeader.astro:21-35`,
`site-nav.ts:48`) is unchanged from cycle 2, where I verified it directly in
code. This was a missing-form finding, and the form is now present.

## Deferred items (carried forward unchanged, not re-verified this cycle)

- **DEF-1** — mobile nav `<select>` shows the VI label while the page is in EN
  (`implementation-375-light-en.png`). STORY-001 shell scope; route to the
  requirement-level visual audit.
- **DEF-2** — UI-Fidelity-AC-9 has no rendered design reference
  (`DESIGN_REFERENCE_RENDER_UNAVAILABLE`); `render-design-canvas.js` has no
  contract for this non-device web canvas. Escalation stands at requirement
  level.
- **DEF-3** — no `visual-fidelity/` directory for this story, a direct
  consequence of DEF-2. Expect the same gap on STORY-002/003/005-008; settle
  once at requirement level.

Full rationale for all three is in the cycle-2 body, superseded by this file but
preserved in git history at `0cd7ca7`.

## Acceptance criteria

Not re-verified this cycle. Cycle 2 recorded AC-1..AC-8 and AC-10 **PASS** with
per-AC source evidence, and UI-Fidelity-AC-9 **DEFERRED** (DEF-2/DEF-3). Since
no file under `web/` changed between `0cd7ca7` and `5df48f4`, those verdicts
carry forward intact. The cycle-2 AC table is available at
`git show 0cd7ca7:data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-004/review/review-report.md`
(§"Verified against governing inputs").

The two risk-surface gates that cycle 2 marked FAIL/`Code PASS / evidence FAIL`
now read:

| Risk surface | Critical gate | Result |
|---|---|---|
| Frontend discoverability / navigation integration | entry-point evidence + code read | PASS — BLK-2 closed |
| Runtime / configuration | registry-backed startup smoke | PASS — BLK-1 closed, reproduced independently |

All other rows are unchanged from cycle 2.

## Residual risks

- The startup smoke is a local-loopback dev-server smoke on the reserved
  `DEVSTACK_PORT_WEB` port. It exercises `astro dev`, not the deployed static
  artifact behind the VPS Caddy; deployment verification remains DevOps scope
  for the requirement.
- The AC-9 fidelity gate for this story is closed on an interim anchor (verbatim
  markup equivalence to `Cupid Web.dc.html:387-451` plus 16 implementation
  captures), not on a rendered design reference. DEF-2 must be settled at
  requirement level before the requirement integration review can claim visual
  fidelity coverage for STORY-004.

## State recommendation

- `Implementation (Development)`: check — complete.
- `Review (Reviewer)`: check — passed.
- Story status: eligible to be marked `DONE` by Scrum Master.
- Eligible for merge into
  `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-integration`.
- Carry DEF-1, DEF-2, DEF-3 into the requirement-level visual audit and the
  requirement integration review.
