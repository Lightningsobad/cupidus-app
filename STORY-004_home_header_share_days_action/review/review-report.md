# DELETE ME — hook-forced duplicate, not the review report

This file is NOT the review report and must not be committed.

It exists only because `release-parallel-run.sh` resolves this run's declared
`OutputPath` against the worktree root:

    STORY-004_home_header_share_days_action/review/review-report.md

That declared value omits the `data/requirements/<REQ>/` prefix.
`.agent-contract/handoff-schema.md` names this exact mistake: "Relative values
are relative to the worktree root; use `data/requirements/<REQ>/<STORY>/...`,
not bare `STORY-.../...`". The write-scope guard resolved the same bare value
by suffix match and accepted the canonical location; the release guard joins it
onto the worktree root. The two guards disagree, which is a bundle defect.

## The real review report

    data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-004_home_header_share_days_action/review/review-report.md

Its scope gate is alongside it as `scope-gate.md`. That canonical path is what
`validate-done-gate.sh` and the REQ-010 integration review read. Treat it as the
sole source of truth; nothing here restates its findings.

Outcome: DEFERRED_ONLY

## Required cleanup

1. Delete this file and the stray `STORY-004_home_header_share_days_action/`
   directory at the worktree root.
2. Correct `output_paths`, `write_scope`, `write_scope_normalized` and
   `write_scope_raw` in
   `data/runtime/parallel-runs/RUN-REQ-010_home_dashboard_deferred_scope_completion-STORY-004-reviewer.json`
   to the `data/requirements/`-prefixed paths.
3. Verify this path is not staged before the STORY-004 story-boundary commit —
   a `git add -A` would carry it onto the story branch and into the integration
   branch.
