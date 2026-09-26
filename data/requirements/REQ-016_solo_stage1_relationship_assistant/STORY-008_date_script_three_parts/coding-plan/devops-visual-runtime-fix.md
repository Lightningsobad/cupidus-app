# DevOps Visual Runtime Fix — STORY-008 (cross-story VISUAL_RUNTIME_MISSING)

- Run: `RUN-REQ-016_solo_stage1_relationship_assistant-STORY-008_date_script_three_parts-devops`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-008_date_script_three_parts`
- WriteScope granted: `.ai-team-bundle/runtime/tools`

## What was actually broken (correcting the review's diagnosis)

The STORY-008 review report (`review/review-report.md` F-1) and the handoff
both locate the missing dependency under
`.ai-team-bundle/runtime/tools`/`.ai-team-bundle/runtime`. Reading
`render-design-canvas.js` itself (`resolvePlaywright()`, top of file) shows
that is not where it ever looks. It resolves the `playwright` package, in
order, from:

1. `state.providers.playwright.toolingDir` read from
   `.ai-team-bundle/runtime-state.json` (+ `/node_modules`)
2. that same `toolingDir` directly
3. `<worktree>/.ai-team-bundle/tooling/playwright/node_modules`
4. `<worktree>/node_modules`

`.ai-team-bundle/runtime/tools/` holds only the plain Node scripts
(`render-design-canvas.js`, `visual-capture.js`, `capture-mobile-screen.sh`,
`render-running-app.js`, `seed-auth-state.js`) and has no `package.json` of
its own — there was never a `node_modules` to install there. The provisioning
script that actually populates candidate 3 is
`.ai-team-bundle/runtime/ensure-runtime.sh` (writes into
`.ai-team-bundle/tooling/<provider>/`, machine-local, gitignored, one copy per
worktree).

## Current state of this worktree

`.ai-team-bundle/tooling/playwright/node_modules` **already contains a
working Playwright install** (`playwright`, `playwright-core`, `@playwright`,
chromium browser) — mtime ~2026-09-17T03:36 UTC, i.e. installed by some prior
`ensure-runtime.sh` run in this worktree, not by this task (I made no writes;
`.ai-team-bundle/runtime/tools` needed none).

`.ai-team-bundle/runtime-state.json` in this worktree does have a stale
`providers.playwright.toolingDir` pointing at a **different** worktree
(STORY-013's). That's outside my `.ai-team-bundle/runtime/tools` WriteScope to
edit, but it turned out to be harmless: `resolvePlaywright()` tries candidate
1 (stale path), fails, falls through to candidate 3 (this worktree's own
`.ai-team-bundle/tooling/playwright/node_modules`), and succeeds.

## Verification performed

- `node .ai-team-bundle/runtime/tools/render-design-canvas.js
  --location=cupid-app-design-system --surface=cupid-ch-ng-1 --list-screens`
  → exit 0, full screen list returned.
- `node .ai-team-bundle/runtime/tools/render-design-canvas.js
  --location=cupid-app-design-system --surface=cupid-ch-ng-1
  --screen=phut-1-kho-trong --platform=ios --out=/tmp/devops-visual-verify
  --label=verify-screen`
  → `DESIGN_CANVAS: OK /tmp/devops-visual-verify/design-reference-verify-screen-ios.png 415x900`,
  exit 0. Confirmed a real 276.9 KB PNG was produced (not a stub/error page).
  Scratch output removed from `/tmp` afterward; no story evidence files were
  touched, per instruction not to render STORY-008's real
  `design-reference-*.png`.
  (First attempt used `--surface=cupid-app`, which
  `.claude/hooks/guard-design-render-surface.sh` correctly blocked: this
  story's declared surface is `cupid-ch-ng-1`, not `cupid-app`. Re-ran with
  the correct surface.)

## Conclusion / next step

`VISUAL_RUNTIME_MISSING` is **not currently reproducible in this worktree** —
the render tool is fully functional end-to-end right now. F-1's root cause
(missing Playwright install) is resolved *for this worktree*. Since the
tooling directory is per-worktree and gitignored/machine-local, this fix does
**not** propagate to other worktrees (STORY-005/STORY-009/STORY-010 or any
other parallel worktree) — each would need its own
`.ai-team-bundle/runtime/ensure-runtime.sh --capability=visual-inspection` run
(or equivalent) checked independently; that is out of this run's WriteScope
and worktree.

Recommended next step: route STORY-008 back to Mobile Developer to render
`design-reference-<screen>-ios.png` for `Design-Screen: s1:datescript` and
write `visual-fidelity-report.md`, per the review's Required Actions #2 — the
environment blocker is cleared in this worktree.
