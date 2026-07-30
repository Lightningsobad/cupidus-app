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

## P4 Result — DONE
- `Alex-Mobile-Dev-11` produced all four required outputs plus the screens
  from solution.md's Affected Components list (verified on disk before
  trusting RunState): `auth_repository.dart`, `firebase_sign_in_gateway.dart`
  (new — resolves the flagged §4 boundary ambiguity by isolating the
  firebase_auth/google_sign_in/sign_in_with_apple/flutter_facebook_auth
  imports behind a gateway so `auth_repository.dart` itself doesn't import
  those packages directly), `sign_in_cubit.dart`, `register_cubit.dart`,
  `session_gate_cubit.dart`, `auth_failure_text.dart`, `auth_strings.dart`,
  and screens `welcome_screen.dart`/`login_screen.dart`/
  `register_screen.dart`/`forgot_screen.dart`/`splash_screen.dart`, plus
  widget/unit tests. `pubspec.yaml` gained `google_sign_in`,
  `sign_in_with_apple`, `flutter_facebook_auth`, `flutter_bloc` as
  pre-authorized (no scope-gap repeat this time). Committed by Scrum
  Master: `43dc1f2`. No `COMPLETION_INVALID` recurrence.

## STORY-003 Status — 4 of 5 phases DONE; P5 blocked pending user decision
- P1 (DevOps, Firebase config): BLOCKED FOR USER DECISION — no Firebase
  console/service-account access in this environment (see "P1 Final State").
- P2 (Mobile, auth core): DONE, committed `c21d8a2`.
- P3 (Mobile, interceptor + DI): DONE, committed `9c053f5`.
- P4 (Mobile, repository/cubits/screens): DONE, committed `43dc1f2`.
- P5 (Mobile, final verification incl. `flutter build apk --debug` + one
  real sign-in path): depends on P1 AND P4. P4 is done but P1 is not, so
  P5's full gate cannot pass. NOT dispatched — this needs the user's
  decision (resolve P1's Firebase access, or explicitly accept a reduced P5
  gate with build/real-sign-in deferred), per AGENTS.md "push unresolved
  ambiguity... stop for a user decision" — Scrum Master does not make this
  tradeoff call unilaterally.

## User Decision — Firebase Config Files Provided
- User (Vietnamese): "2 files firebases cho 2 nền tảng đã được thêm vào thư
  mục fb/ Hãy kiểm tra và tiếp tục" ("2 Firebase files for the 2 platforms
  have been added to the `fb/` folder. Please check and continue.").
- Verified files at main control checkout root (outside this worktree):
  `fb/google-services.json`, `fb/GoogleService-Info.plist`.
- Cross-checked `project_id` match across all three sources per solution.md
  §3 Assumption (b): `google-services.json` `project_info.project_id`,
  `GoogleService-Info.plist` `PROJECT_ID` key, and
  `backend/service-account.json` `project_id` — all three equal
  `gen-lang-client-0644970375`. Match confirmed before dispatch.

## Current State (P1-retry dispatch)
- P1-retry dispatched: `Frank-Devops` (agent_id
  `Frank-Devops-2@session-e4c382c0`), RunId
  `RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-devops-retry` (NEW RunId,
  original terminal `...-devops` run left untouched per the STORY-002
  disk-space-blocker precedent), `Mode: story-implementation`, WriteScope
  `mobile/android/app/build.gradle.kts,mobile/android/app/src,
  mobile/ios/Runner/AppDelegate.swift,mobile/ios/Runner/Assets.xcassets,
  mobile/ios/Runner/Base.lproj,mobile/ios/Runner/GeneratedPluginRegistrant.h,
  mobile/ios/Runner/GeneratedPluginRegistrant.m,mobile/ios/Runner/Info.plist,
  mobile/ios/Runner/Runner-Bridging-Header.h,
  mobile/ios/Runner/SceneDelegate.swift,mobile/lib/firebase_options.dart,
  mobile/android/app/google-services.json,
  mobile/ios/Runner/GoogleService-Info.plist,
  data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`,
  BaseHead `96ec0fb27f0121e3b7c66aaf1c2ce9c61dfea06c` (post-P4 commit).
  Instructed to: copy the two user-provided config files from the main
  checkout's `fb/` folder into their platform-correct paths, generate/derive
  `firebase_options.dart`, update `deployment/configuration-guide.md`, and
  run the `flutter build apk --debug` gate. project_id match already
  pre-verified by Scrum Master (see above), not re-delegated as new work.
  Handoff `Checkpoint:` field corrected from `handoff-build.sh`'s mis-derived
  `STORY-003/scrum-master-checkpoint.md` to the real
  `STORY-003_auth/scrum-master-checkpoint.md` path (recurring builder quirk).
  Status: dispatched, awaiting result.

## P1-retry Result — BLOCKED (genuine new blocker, user decision needed)
- `Frank-Devops-2` reached `status: BLOCKED`, `completion_marker:
  "DEVOPS_COMPLETE"`, `completion_result: "NO"` — a real product/config
  mismatch, not a recording gap and not something Scrum Master can resolve
  unilaterally:
  - The two user-provided files (`fb/google-services.json`,
    `fb/GoogleService-Info.plist`) register a Firebase app under package/
    bundle id `com.snapsofts.cupid`.
  - The actual mobile app identifiers do not match that:
    Android `applicationId` = `com.snapsofts.cupid_mobile`
    (`mobile/android/app/build.gradle.kts:19`); iOS
    `PRODUCT_BUNDLE_IDENTIFIER` = `com.snapsofts.cupidMobile`
    (`mobile/ios/Runner.xcodeproj/project.pbxproj:385`).
  - Wiring the files in as-is would fail Android's `google-services` Gradle
    task ("No matching client found for package name") and would not
    resolve correctly on iOS either. DevOps correctly declined to copy the
    files, derive `firebase_options.dart`, or run the build gate rather than
    fake a pass.
- Note: the earlier project_id cross-match Scrum Master verified
  (`gen-lang-client-0644970375` across `google-services.json`,
  `GoogleService-Info.plist`, `backend/service-account.json`) confirmed the
  files belong to the correct Firebase *project*; this new blocker is a
  different, narrower mismatch — the *app registration's package/bundle id*
  within that project does not match the Flutter app's actual identifiers.
- Scheduler reconciled: `parallel-scheduler.json` `active_runs: []`,
  `blocked_runs` now includes both `...-devops` and `...-devops-retry` (run
  file `status: BLOCKED` is authoritative; index pruned/updated to match, no
  fabricated resolution).
- **P1-retry is BLOCKED FOR USER DECISION**: the user must choose (a)
  register new Firebase apps under the real identifiers
  `com.snapsofts.cupid_mobile` (Android) / `com.snapsofts.cupidMobile` (iOS)
  and provide new config files, or (b) change the Flutter app's Android
  `applicationId`/iOS bundle id to `com.snapsofts.cupid` to match the
  provided files (a broader change with its own risk — store listing,
  existing installs, other STORY-002/001 assumptions). Do not re-dispatch
  P1 again until the user decides; use a new RunId (e.g. `...-devops-retry2`)
  when they do.

## User Decision — App Identifiers Will Change (not new Firebase apps)
- User chose: change the Flutter app's Android `applicationId` and iOS
  bundle id to `com.snapsofts.cupid` to match the provided Firebase config
  files, rather than registering new Firebase apps under the existing
  `com.snapsofts.cupid_mobile`/`com.snapsofts.cupidMobile` identifiers.
- Peer note: `Frank-Devops-2` also independently reported this same blocker
  plus a separate infra issue — its Stop hook (`release-parallel-run.sh`)
  couldn't release its slot because `parallel-scheduler.json` still listed
  both `...-devops` and `...-devops-retry` as unresolved devops runs
  (ambiguous match). This was already fixed moments earlier when Scrum
  Master reconciled the scheduler (moved both to `blocked_runs`, cleared
  `active_runs`) per the run-file-is-source-of-truth rule — no separate
  action needed beyond confirming it in the continuation message.
- Continued the SAME agent/run (no respawn — genuine blocker just got a
  user decision, agent was already live at Stop hook): `SendMessage` to
  `Frank-Devops-2` (msg_id `6c74ad3c-d6b3-407b-a5e8-f5342558f7f1`), built via
  `handoff-build.sh continue`. Run-state
  (`RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-devops-retry.json`)
  updated: `status` BLOCKED -> ACTIVE, `write_scope` expanded to add
  `mobile/ios/Runner.xcodeproj/project.pbxproj` (needed to edit
  `PRODUCT_BUNDLE_IDENTIFIER`), recorded as `scrum_master_scope_expansion`.
  Scheduler `active_runs` re-includes this RunId.
- Instructed: change `build.gradle.kts:19` applicationId and
  `project.pbxproj:385` (+ any other build-config entries)
  PRODUCT_BUNDLE_IDENTIFIER to `com.snapsofts.cupid`, then copy the two
  `fb/` files into place, derive `firebase_options.dart`, update
  `configuration-guide.md`, run `flutter build apk --debug`.

## Next Step
Wait for `RUN-REQ-001_cupid_flutter_mobile_app-STORY-003-devops-retry` to
reach a new terminal state via Monitor + blocking TaskOutput. If
`COMPLETION_INVALID` recurs (marker-only gap), resolve via same-agent
SendMessage for the literal marker text only — do not respawn. If a
genuinely new blocker appears (e.g. another file needs the old package id
changed), stop and report/decide. Once DONE, dispatch P5 (final
verification, depends on P1 AND P4, both done) with explicit
`--run-id ...-mobile-p5`, then route to Reviewer, then DONE + merge.
