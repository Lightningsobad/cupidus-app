# Scrum Master Checkpoint — STORY-003 Auth

Scope: REQ-001 / STORY-003
Status: IN_PROGRESS (parallel wave) — UX-Spec DONE, Architecture+Plan DONE, P1/P2 next
Story Master: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-003_auth/story_master.md`

## Story Git Boundary
Git-Boundary: REQUIRED
Story-Class: standard
Depends-On: NONE
Worktree: /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-001_cupid_flutter_mobile_app-STORY-003
Branch: codex/REQ-001_cupid_flutter_mobile_app-STORY-003
MergeTarget: main
BaseHead: 42997a3019e3d5df3bd6c4d44d1dc354ca6dcc4a
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

## Tech Lead Architecture + Plan (DONE)
- `Alan-Techlead-3` (agent_id `Alan-Techlead-3@session-e4c382c0`, RunId
  `RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-tech-lead`, `Mode:
  compact-story-plan`) returned `status: COMPLETED`,
  `TECH_LEAD_COMPLETE: YES`. Output: `architecture/solution.md` (178 lines,
  committed `44fcc8f`). Covers: frozen backend contract (no refresh/exchange
  endpoint -> refresh is `getIdToken(forceRefresh: true)`, not HTTP), the
  `auth`-slot-only interceptor change (STORY-002's 4-slot order untouched),
  R8 Socket.IO forward-compat via `CupidSession.idToken`/`idTokenStream`
  (STORY-004 inherits this, must re-handshake on token rotation), and both
  UX ADR inputs resolved: ADR-011e (OTP screen -> link-based inbox-wait,
  option b) and ADR-011f (`bioLabel` confirmed local app-lock gate only,
  implementation deferred to STORY-016).
- Run first surfaced `status: COMPLETION_INVALID`
  (`completion_error: "Missing completion marker in SubagentStop
  transcript"`) even though the artifact was already complete on disk;
  resolved via a `SendMessage` continuation to the same agent (not a
  respawn), which produced the literal `TECH_LEAD_COMPLETE: YES` marker and
  flipped run status to `COMPLETED`.
- Scrum Master decision (flagged by the run's own `next_step`, since its
  WriteScope was `architecture/**` only): standard-story gate DOES require
  a separate `coding-plan/master-plan.md` (`AGENTS.md`: "Standard and
  complex stories require shared implementation planning through
  `coding-plan/master-plan.md`"). Lifted solution.md §8's embedded Phase
  Overview table verbatim into
  `coding-plan/master-plan.md` (committed `caabfcb`) — no new Tech Lead run
  performed; phase detail stays inline in `architecture/solution.md`
  (ADR-011a..h) per that file's own "Phase file mapping" table, matching
  the STORY-002 `compact-story-plan` precedent.
- Plan: 5 phases, P1 (DevOps) + P2 (Mobile) parallelizable with no
  dependency and non-overlapping write scopes; P3 depends on P2; P4 depends
  on P3; P5 (final verification, Mobile) depends on P1 and P4.

## Do Not Re-read
- Do not re-read STORY-001/STORY-002 implementation history; only their
  DONE status and merge SHAs matter as dependency confirmation.
- Do not re-run Product Owner breakdown (16 stories already seeded).
- Do not re-read `ux/uiux-spec.md` in full for phase handoffs (UX_COMPLETE,
  all 4 ACs mapped, both ADR inputs already resolved in solution.md).
- Do not re-run Tech Lead's `compact-story-plan` (COMPLETE, both outputs
  exist and are committed).

## Current State (P1/P2 dispatch)
- P1 dispatched: `Frank-Devops` (agent_id `Frank-Devops@session-e4c382c0`),
  RunId `RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-devops`,
  `Mode: story-implementation`, WriteScope `mobile/android/app/**`,
  `mobile/ios/Runner/**`, `mobile/lib/firebase_options.dart`,
  `deployment/configuration-guide.md`. Status: ACTIVE.
- P2 attempted in the same batch (`Alex-Mobile-Dev`, `Mode:
  mobile-implementation`) but was guard-blocked:
  `guard-parallel-spawn.sh [CAP_REACHED]: MAX_CODE_WRITERS_PER_STORY reached`.
  Even though `coding-plan/master-plan.md` §5 marks P1/P2
  `Parallelizable: yes (with P1/P2)` with non-overlapping WriteScope, the
  scheduler's global cap (`parallel-scheduler.json` `caps.
  MAX_CODE_WRITERS_PER_STORY: 1`) serializes code-writers per story to
  exactly one concurrent run regardless of declared parallelizability. P2 is
  NOT blocked by any dependency (`Depends On: —`) — only by capacity.
- Both P1 and P2 mode values were confirmed against prior terminal run files
  in this repo (`RUN-...-STORY-002-mobile-p2.json` -> `mode:
  "mobile-implementation"`; other devops runs -> `mode:
  "story-implementation"`), since guard-codes.md does not enumerate role
  Mode lists and `story-implementation` alone was rejected for `mobile-dev`
  by `guard-broad-handoff.sh`.

## P1 Result — BLOCKED (user decision needed)
- `Frank-Devops` returned a genuine external blocker, not a code defect:
  `DEVOPS_BLOCKED_NO_FIREBASE_ACCESS` — no `backend/service-account.json` and
  no firebase/flutterfire CLI in this environment, so the Firebase
  `project_id` match (solution.md §3 Assumption b, §7 risk) could not be
  confirmed and no config was stubbed/faked. This matches the exact risk
  Tech Lead flagged in solution.md §7: "escalate to Scrum Master/DevOps; do
  not stub or fake auth to get a green build."
- Real, WriteScope-compliant output produced despite the blocker:
  `deployment/configuration-guide.md` updated (+45 lines, Firebase project
  setup procedure documented) — committed by Scrum Master `42997a3`.
  `mobile/lib/firebase_options.dart` and the two platform config files were
  correctly NOT created (cannot fabricate them without real access).
- Run again hit the recurring `completion_error: "Missing completion marker
  in SubagentStop transcript"` quirk (status `COMPLETION_INVALID` despite a
  valid `completion_marker` field in RunState). Sent a `SendMessage`
  continuation to the same agent (`Frank-Devops`, msg_id
  `1e3c506d-78b0-402b-b4c0-342ffb75eb2d`) asking only for the literal marker
  text `DEVOPS_BLOCKED_NO_FIREBASE_ACCESS: YES` in its final response — no
  re-attempt of Firebase setup requested.
- **P1 is BLOCKED FOR USER DECISION**: someone with Firebase console/
  service-account access must run the documented setup procedure. Do not
  re-dispatch P1 until the user provides that access or explicitly defers it
  — same pattern as STORY-002's P4 disk-space blocker (dispatch a NEW RunId
  when retried, never resume this terminal run).

## P1 Final State
- `Frank-Devops`'s run reached a clean terminal state: `status: BLOCKED`,
  `completion_marker: "DEVOPS_COMPLETE: NO"` (the SendMessage continuation
  resolved the earlier `COMPLETION_INVALID` transcript-marker gap). Scheduler
  `parallel-scheduler.json` confirms `active_runs: []`,
  `blocked_runs: ["RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-devops"]` —
  slot released, P1 is a durable, correctly-recorded BLOCKED terminal run.
  No further action on this run; re-dispatch only after the user resolves
  Firebase console/service-account access (new RunId, e.g. `...-devops-retry`).

## Current State (P2 dispatch)
- P2 dispatched: `Alex-Mobile-Dev` (agent_id
  `Alex-Mobile-Dev-9@session-e4c382c0`), RunId
  `RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-mobile-dev`,
  `Mode: mobile-implementation`, WriteScope
  `mobile/lib/core/auth/**,mobile/pubspec.yaml`, BaseHead `21eb0ae`
  (post P1-blocker-record commit). Status: dispatched, awaiting result.
  Handoff `Checkpoint:` field was corrected from `handoff-build.sh`'s
  mis-derived `STORY-003/scrum-master-checkpoint.md` to the real
  `STORY-003_auth/scrum-master-checkpoint.md` path (recurring builder quirk).

## P2 Result — DONE
- `Alex-Mobile-Dev-9` produced all four required files (verified independently
  on disk before trusting RunState): `cupid_session.dart` (`CupidSession`,
  `CupidSessionState`, `SessionScopedStore`), `firebase_id_token_provider.dart`
  (`FirebaseIdTokenProvider implements CupidAuthTokenProvider`, no HTTP
  refresh per ADR-011a), `cupid_auth_failure.dart` (sealed failure types +
  `FirebaseAuthException` mapping per ADR-011c), `cupid_auth.dart` (barrel).
  `pubspec.yaml` gained only `firebase_core`/`firebase_auth`.
- Flagged scope note (not a violation): P2's declared WriteScope did not
  include `mobile/test/**` (that's P5's write scope in master-plan.md), so
  no new unit test files were added this phase; verified instead via
  `flutter analyze lib/core/auth` ("No issues found!") and the full existing
  `flutter test` suite (51 pass, no regression). Token read/refresh unit
  tests are deferred to P5 per the plan's own phase table — do not treat this
  as a missed AC; re-check at P5 review.
- Committed by Scrum Master: `c21d8a2` (4 new files + pubspec.yaml/lock; an
  incidental `mobile/ios/.../swiftpm/Package.resolved` generated file was
  also swept in — benign build metadata, not authored content, no conflict).
- Hit the same recurring `COMPLETION_INVALID` transcript-marker gap as P1;
  resolved via `SendMessage` continuation to the same agent (msg_id
  `bd2ed90f-cd01-4b49-8228-56a685eb9c2b`) asking only for the literal
  `MOBILE_COMPLETE: YES` text. Run reached `status: COMPLETED`.
- **Naming fix applied for future phases**: `handoff-build.sh spawn` derives
  a fixed `RunId` of `...-mobile-dev` regardless of phase, which would have
  collided with/overwritten P2's run file for P3. Fixed by passing
  `--run-id RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-mobile-p3`
  explicitly (STORY-002 precedent: `...-mobile-p2`, `...-mobile-p4`). Use an
  explicit `--run-id ...-mobile-pN` for every subsequent mobile-dev phase
  (P4, P5) too.

## Current State (P3 dispatch)
- P3 dispatched: `Alex-Mobile-Dev` (agent_id
  `Alex-Mobile-Dev-10@session-e4c382c0`), RunId
  `RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-mobile-p3`,
  `Mode: mobile-implementation`, WriteScope
  `mobile/lib/core/auth/cupid_auth_interceptor.dart`,
  `mobile/lib/core/network/cupid_interceptor_slots.dart`,
  `mobile/lib/core/di/service_locator.dart`, BaseHead `c21d8a2`. Status:
  dispatched, awaiting result.

## P3 Result — WriteScope gap (Scrum Master resolved, not a code defect)
- `Alex-Mobile-Dev-10` correctly finished and analyzed-clean
  `cupid_auth_interceptor.dart` + `cupid_interceptor_slots.dart`, but stopped
  before `service_locator.dart` because `get_it` (ADR-011g composition root)
  is not yet a `pubspec.yaml` dependency and `mobile/pubspec.yaml` was
  outside P3's declared WriteScope. Did not stub/fake the DI registration.
- Verified this is a genuine, already-approved scope gap (not new scope):
  `architecture/solution.md` line 58 and ADR-011g explicitly list `get_it`
  as landing in this story's pubspec, and the master-plan's P3 row names
  "`get_it` registrations" as a planned output — the Phases Overview table
  just omitted `pubspec.yaml` from P3's WriteScope column by oversight.
- Resolved by expanding WriteScope in-place: edited
  `RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-mobile-p3.json`
  `write_scope`/`write_scope_normalized`/`write_scope_raw` to add
  `mobile/pubspec.yaml` (additive-only, single dependency line) and recorded
  a `scrum_master_scope_expansion` note in that run file for auditability.
  Sent a `SendMessage` continuation to the SAME agent (msg_id
  `b18c41d9-4443-4442-b68e-6d127f064868`) — no respawn.

## P3 Result — DONE
- `Alex-Mobile-Dev-10` finished after the WriteScope expansion: verified on
  disk before trusting RunState — `cupid_auth_interceptor.dart` (modified),
  `cupid_interceptor_slots.dart` (auth slot wired, other 3 slots untouched),
  `mobile/lib/core/di/service_locator.dart` (new, `get_it` registrations),
  `pubspec.yaml` gained `get_it: ^9.2.1` only. A scratch
  `mobile/test/dio_probe_test.dart` it had created was self-deleted before
  finishing (cleanup, not a loss). Committed by Scrum Master: `9c053f5`.
- Same recurring `COMPLETION_INVALID` transcript-marker quirk did NOT recur
  this time — run reached `status: COMPLETED` / `MOBILE_COMPLETE: YES`
  directly after the scope-expansion continuation.

## Current State (P4 dispatch)
- P4 dispatched: `Alex-Mobile-Dev` (agent_id
  `Alex-Mobile-Dev-11@session-e4c382c0`), RunId
  `RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-mobile-p4`,
  `Mode: mobile-implementation`, WriteScope
  `mobile/lib/features/auth/**,mobile/pubspec.yaml` (pubspec pre-included
  this time to avoid repeating P3's scope gap — P4 needs `google_sign_in`,
  `sign_in_with_apple`, `flutter_facebook_auth`, `flutter_bloc` per
  solution.md line 58), BaseHead `9c053f5`. Status: dispatched, awaiting
  result. Flagged a real ambiguity in solution.md §4 "Boundaries And
  Ownership" (only `core/auth/` may import `firebase_auth`/social packages,
  yet `AuthRepository` is placed under `features/auth/data/`) for the
  implementer to resolve via the core/auth barrel, or report as a genuine
  architecture conflict rather than silently violating either rule — this is
  implementation-detail resolution, not a Scrum Master architecture call.

## Next Step
1. Wait for `Alex-Mobile-Dev-11`'s P4 run to reach a terminal state (Monitor +
   `TaskOutput(block:true)` on
   `data/runtime/parallel-runs/RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-mobile-p4.json`,
   not manual polling). If `COMPLETION_INVALID` with artifacts already
   correct on disk, use a `SendMessage` continuation to the SAME agent for
   the literal `MOBILE_COMPLETE: YES` marker text only (no respawn). If it
   reports the boundary-ambiguity conflict as a genuine blocker, evaluate it
   directly (do not delegate a fresh Tech Lead run reflexively) and only
   escalate to Tech Lead if it truly cannot be resolved as implementation
   detail.
2. On genuine P4 completion, verify the four output files + screens exist,
   evidence is real, commit via `git-story-boundary.sh commit`, refresh
   BaseHead, then dispatch P5 (`Alex-Mobile-Dev`, explicit
   `--run-id ...-mobile-p5`, depends on P1 AND P4: final verification,
   WriteScope `mobile/test/**`).
3. P5 depends on P1 (Firebase access), which is currently BLOCKED FOR USER
   DECISION (see "P1 Final State" above). Once P4 is DONE, surface that
   narrower blocker to the user explicitly: P5's full AC1-4 gate
   (`flutter build apk --debug` + one real sign-in path) cannot fully pass
   without a resolved Firebase project; P2-P4 code/unit-test work does not
   require it. Do not dispatch P5 until either the user resolves P1 or
   explicitly accepts a reduced P5 gate (unit/widget tests only, build/
   real-sign-in deferred) — that tradeoff needs the user's call, not
   Scrum Master's.
