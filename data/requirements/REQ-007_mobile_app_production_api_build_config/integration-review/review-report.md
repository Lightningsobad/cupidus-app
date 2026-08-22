# Requirement Integration Review: REQ-007 Mobile App Production API Build Config

Outcome: DEFERRED_ONLY

- Review type: `requirement-integration-review`
- Scope gate: `data/requirements/REQ-007_mobile_app_production_api_build_config/integration-review/scope-gate.md`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-007_mobile_app_production_api_build_config`
- Branch: `codex/REQ-007_mobile_app_production_api_build_config-integration`
- Diff reviewed: `beb1c551941fb902a872f4f2919f9451b25787f4..6470d8dd139e2ac60cdd1fb3e5015e3196c04c0d`
- Merged stories: STORY-001 (`STORY-001/review/review-report.md`, `Outcome: DEFERRED_ONLY`)
- Blocking findings: 0 · Deferred findings: 4 carried + 1 new · Pre-closure action items: 1

## Integration Build & Runtime

- Build: PASS — both flavors compiled on this integration branch during the audit session. Production: `flutter run -d emulator-5560 --debug --start-paused --dart-define=CUPID_ENV=production --dart-define=CUPID_API_BASE_URL=https://api.cupidus.app`; local-dev: same command with no defines. Both compiled and installed successfully (`verification/mobile-visual-audit.md` §2, §3, §6). Unit suite on the merged tree: `flutter test test/core/config/cupid_api_config_test.dart --reporter compact` exit `0`, 13/13 (§6).
- Runtime/Smoke: PASS — both flavors launched on `emulator-5560` (Android 16, API 36) from this integration worktree and reached the Welcome screen fully rendered, `FATAL EXCEPTION` 0 lines in both flavors' logcat (`verification/mobile-visual-audit.md` §4). This is a live startup smoke on the merged tree, not a rebuild of the story-level smoke.

Provenance note: the two lines above are recorded here because rule 12g3 requires
them in a file under `integration-review/`; the underlying evidence was produced
by the mobile lane in `verification/mobile-visual-audit.md` on this branch, and I
verified it rather than re-running it. `req_master.md` carries no
`Integration-Verify: WAIVED` line, so the gate applies in full and is met on
substance.

## Evidence Freshness

The audit records HEAD `3db285c3967784524988ca9065a411176f4bfc19` at audit time;
current HEAD is `6470d8dd`. Verified that `3db285c3` is an ancestor of HEAD and
that `git diff --name-only 3db285c3..HEAD` returns exactly one path — the audit
document itself. `git diff --name-only 3db285c3..HEAD -- mobile/` is empty. The
binaries that were launched and profiled were built from source byte-identical to
the current integration tip, so the evidence is not stale.

## D1 Closure — Verified

D1 was the one finding this gate had to decide. It required device-observed
REST **and** socket destinations for both flavors, with no local origin reached
by the production build. The audit supports its `D1 is CLOSED` claim.

| D1 claim | Verdict | Evidence |
|---|---|---|
| Production build reaches `api.cupidus.app` | PASS | REST `POST https://api.cupidus.app/auth/login` → HTTP 401 from peer `172.67.141.59:443`; socket handshake → HTTP 101 Switching Protocols (§2a, §2b) |
| Local-dev build still reaches local dev | PASS | Phase 1 (nothing listening): both transports refused at `localhost:3000`, no production host in the capture. Phase 2 (listener via `adb reverse`): REST 200 from `127.0.0.1:3000`, socket 101, full Engine.IO v4 + `joinRoom` exchange (§3a, §3b) |
| Zero local-origin attempts in the production build | PASS | Whole-lifetime capture: exactly 2 TCP sockets, both `172.67.141.59:443`. Needle scan `localhost` 0, `10.0.2.2` 0, `127.0.0.1` 0, `:3000` 0, `api.cupidus.app` 5 — reproduced in an independent second production run (§2c) |

**Method is legitimate.** Destinations were read from `dart:io`'s own profilers
(`ext.dart.io.getHttpProfile`, `ext.dart.io.getSocketProfile`) over the Dart VM
Service of the installed debug build, exercising the app's real DI singletons —
`getIt<CupidApi>().dio` (the shared `Dio` built by `CupidApiClient.create()` from
`CupidApiConfig.baseUrl`, with the real interceptor pipeline) and
`getIt<RealtimeCoordinator>()` (holding the real `SocketTransport`). No source
was modified or instrumented. These profilers record the request URI, the
*resolved peer address and port*, and the response status, so the destination
evidence is the runtime's own accounting rather than an inference from logs. The
audit additionally read the compiled-in config live from the running isolate
(`CupidApiConfig.baseUrl` and `dio.options.baseUrl` both `https://api.cupidus.app`),
which ties the observed traffic to the specific binary under test.

**The negative claim is properly earned.** A "zero occurrences" result is only
meaningful if the capture covers the window in which a violation could occur.
`--start-paused` with the profilers armed 221 ms after resume makes the capture
the whole process lifetime rather than a post-startup slice. The audit states
this explicitly as the reason the negative is real; that is the correct
methodological concern to have raised, and it is answered.

**§5 is honest scope, not a gap.** The two disclosures — no authenticated
end-user journey (no Firebase credential available; creating one would write a
real user into a live Firebase tenant, an external side effect outside audit
scope), and the local-dev round trip using a stub listener rather than the real
Nest backend — both sit outside what D1 asked. D1 is a question about *where the
transports go*, and both are answered with real observed traffic. Notably the
production side used no stub at all: the 401 and the 101 came from the live
Cloudflare-fronted origin. Neither disclosure weakens the destination evidence,
and disclosing them is what makes the report trustworthy on the parts it does
claim.

## Cross-Story Integration

Trivial by construction: REQ-007 contains exactly one story, so there is no
cross-story contract, no sibling call site, no shared migration or generated
client, and no merge-order interaction to verify. The integration branch log
`beb1c551..HEAD` is 9 commits, all REQ-007 state/evidence commits plus the single
story implementation. Nothing was merged from another requirement.

## Write Scope Containment

The full requirement diff touches 16 files: 13 under
`data/requirements/REQ-007_mobile_app_production_api_build_config/` and exactly 3
under `mobile/` — `lib/core/config/cupid_api_config.dart`, `lib/main.dart`,
`test/core/config/cupid_api_config_test.dart`, which are the three files declared
in the STORY-001 phase write scope and already verified in the story review.
Nothing outside REQ-007's declared scope was touched. The audit itself edited no
application source, consistent with its own statement in the header.

## Pre-Closure Action Item

- **A1 [scrum-master] — requirement mobile visual audit is filed off the contract path.** Rule 12g2 names `data/requirements/<REQ>/integration-review/mobile-visual-audit.md`; the artifact is at `data/requirements/<REQ>/verification/mobile-visual-audit.md`. The content is complete and verified — this is placement, not substance. Because the DONE gate enforces the requirement mobile visual audit independently and I cannot inspect the hook to confirm which path it reads, move or copy the file to `integration-review/mobile-visual-audit.md` before marking REQ-007 `DONE`, or confirm the gate accepts `verification/`. If closure is rejected, the fix is a file move, not rework. It is outside my `WriteScope` (`integration-review/` only), so I did not relocate it myself.

## Deferred Findings

New in this gate:

- **D5 — `flutter_facebook_auth` plugin fails to register on every launch.** `E/GeneratedPluginRegistrant: Error registering plugin flutter_facebook_auth ... The SDK has not been initialized, make sure to call FacebookSdk.sdkInitialize() first` appears at activity start in **both** flavors (audit §4). Flavor-independent, pre-existing, unrelated to the API origin, and it did not affect either transport's destination — correctly out of REQ-007 scope. Recording it so it is not lost: a plugin that fails registration on every launch is a real latent defect for whichever requirement next touches social auth. Suggest a bug-queue entry rather than a REQ-007 change.

Carried from the story review, still correctly deferred, not re-litigated here:

- **D2** — `flutter analyze` exits 1 on a pre-existing 80-issue `info` baseline, byte-identical to BaseHead, none in touched files.
- **D3** — unverified `21020` port literal in the local-dev examples of `deployment/configuration-guide.md`; the guide names `DEVSTACK_PORT_API` as source of truth.
- **D4** — the `mobile-app` readiness probe's `ResumedActivity` check cannot detect a Dart-level startup failure (an activity resumes even when the Dart entrypoint throws). DevOps-owned registry improvement.

The audit also records an observation, not a finding, that `CupidApiConfig`'s
local default `http://localhost:3000` is the *device's* loopback on an Android
emulator, so a local-dev build reaches a host dev server only via `adb reverse`.
This is pre-existing behavior frozen by AC2 and already cleared in the story
review; the audit correctly declined to change it. `deployment/configuration-guide.md`
already documents the `10.0.2.2` / `adb reverse` reality for local runs, so no
action.

## Traceability

- Business scope (`req_master.md`): item 1 (second build configuration alongside local) is delivered and story-reviewed; item 2 (validate the production-flavor build on an emulator, confirming it talks to `api.cupidus.app` rather than local dev) is exactly what the audit now demonstrates with observed traffic.
- Technical constraints: additive-only and standard `--dart-define` mechanism were verified at story level; the constraint that "validation must be a real emulator/simulator run of the production-flavor build, not just a successful compile" is satisfied by audit §2 and §4.
- REQ-005 dependency: exercised implicitly and successfully — `api.cupidus.app` answered a real TLS request (401) and completed a websocket upgrade (101), so the dependency is live.
- Open Questions: the single OQ (exact base-URL mechanism) was resolved by Tech Lead to `--dart-define` and verified at story level. No unresolved OQ remains.

## State Recommendation

- Requirement status: `DONE`, after action item A1 is settled.
- STORY-001 remains `DONE`; no story needs to be reopened.
- `req_master.md` Status is currently `IN_PROGRESS` and is Scrum Master's to update.
- D5 is worth a bug-queue entry; D2/D3/D4 stay deferred as recorded.
