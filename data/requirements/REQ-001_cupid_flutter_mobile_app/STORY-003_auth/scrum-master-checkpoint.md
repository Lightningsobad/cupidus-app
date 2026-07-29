# Scrum Master Checkpoint — STORY-003 Auth

Scope: REQ-001 / STORY-003
Status: IN_PROGRESS (parallel wave) — UX-Spec DONE, Tech Lead next
Story Master: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-003_auth/story_master.md`

## Story Git Boundary
Git-Boundary: REQUIRED
Story-Class: standard
Depends-On: NONE
Worktree: /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-001_cupid_flutter_mobile_app-STORY-003
Branch: codex/REQ-001_cupid_flutter_mobile_app-STORY-003
MergeTarget: main
BaseHead: bb022cd0e0cb59e296d152c4cd54f590be926d4a
BoundaryState: /Users/alantravala/workspace/snapsofts/cupid-apps/.git/ai-team-story-boundaries/REQ-001_cupid_flutter_mobile_app/STORY-003.json

Note: `Depends-On` is `NONE` here because the handoff-schema `Depends-On`
field is reserved for `shared-foundation`-class blocking dependencies only.
STORY-002 is `Story-Class: standard`, not `shared-foundation`, so its
completion is already enforced by ready-job-selection (STORY-003 was only
scheduled because STORY-002 is DONE/merged), not by this field.

## Done
- Dependencies confirmed DONE: STORY-001 (design_system, merged `25fd967`),
  STORY-002 (api_client, merged `ff159b7`).
- Requirements (Product Owner): satisfied by initial 16-story breakdown;
  `story_master.md` already has User Story, In/Out of Scope, AC1-4, Open Items.
- Story has an operator-facing UI surface (Firebase sign-in screens per
  `cupid-mobile-design/` onboarding group), so UX-Spec is NOT waived.

## Current State
- `Pink-Designer` (agent_id `Pink-Designer@session-e4c382c0`, RunId
  `RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-ui-ux-designer`) returned
  `status: COMPLETE`, `UX_COMPLETE: YES`. Output committed:
  `ux/uiux-spec.md` (270 lines, commit `f1afa90`). All four ACs mapped:
  AC1 (existing welcome/login/register flow reused as-is), AC2 (§4,
  invisible + session-expired states for the refresh interceptor), AC3
  (§3, splash as auth-check gate), AC4 (§5, sign-out confirmation).
- Non-blocking notes from the spec for later roles:
  - Tech Lead ADR input: OTP/6-digit-code screen mechanism is ambiguous
    given A1 (backend contract frozen, no new endpoint) — spec recommends
    Tech Lead choose between (a) repurpose the digit-entry visual as a
    deep-link-resume screen polling `emailVerified`, or (b) drop manual
    entry and change copy to a "tap the link" flow. Does not block the
    rest of the spec.
  - Tech Lead ADR input: `login`'s `bioLabel` fingerprint row is a local
    app-lock quick-unlock gate on an already-persisted session, not a
    second Firebase auth method — flag if Tech Lead's architecture treats
    it as an alternate credential instead.
  - Scrum Master follow-up (post-review, NOT now — outside this story's
    `ux/**` WriteScope): after STORY-003 passes review, add a "§12 Auth
    Session UX Patterns" section to `data/ux/system/ui_ux_system_memory.md`
    covering the splash-as-auth-check-gate pattern (§3) and the
    session-expired-routes-to-login-not-welcome rule (§4b), sourced from
    this spec's §3/§4/§5.
- First two spawn attempts were guard-blocked before the successful one:
  (1) `guard-canonical-agent-name.sh` for using role alias `ui-ux-designer`
  as `subagent_type` instead of `Pink-Designer`; (2)
  `guard-parallel-spawn.sh [DEP_NOT_MERGED]` for declaring
  `Depends-On: STORY-002` when STORY-002 is `Story-Class: standard`, not
  `shared-foundation` — fixed by using `Depends-On: NONE` (see Story Git
  Boundary note above) and refreshing the boundary/handoff via
  `git-story-boundary.sh start --depends-on NONE` +
  `handoff-build.sh spawn --depends-on NONE`. That refresh also required
  committing this checkpoint file's earlier misplaced-then-relocated copy
  directly in this worktree (commit `bb022cd`) to clear a dirty-worktree
  block, which is why `BaseHead` above is `bb022cd...`, not the original
  story-boundary base.

## Do Not Re-read
- Do not re-read STORY-001/STORY-002 implementation history; only their
  DONE status and merge SHAs matter as dependency confirmation.
- Do not re-run Product Owner breakdown (16 stories already seeded).

## Next Step
Route `Alan-Techlead` (`Mode: compact-story-plan`, since Story-Class is
`standard` and scope is one lane) for the auth interceptor + Firebase wiring
architecture. Must cover: (1) STORY-002's frozen four-slot interceptor
contract (only the `auth` slot occupant changes, no reordering), (2)
Socket.IO `handshake.auth.token` forward-compat per this story's own Open
Items note, (3) the two UX-flagged ADR inputs above (OTP mechanism choice,
bioLabel quick-unlock scope).
