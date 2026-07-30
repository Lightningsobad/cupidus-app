# Phase P5 – Verification And Spike Findings

## 1. Objective

Prove AC1-AC3 with the prototype harness, record the AC4 findings and the manual FCM operator procedure, and verify the mobile lane's build and static analysis.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-verification.md`
- Owner: Mobile Developer
- Lane: Mobile Verification

## 1B. Phase Metadata

- Depends On: P0, P1, P2, P3, P4
- Parallelizable: NO
- Write Scope:
  - `mobile/test/core/realtime/**` (harness and fakes)
  - `test-results.md`
  - `spike-findings.md`

## 2. Required Reads

- `../story_master.md` AC1-4
- `../architecture/solution.md` §2, §4 Risk Surfaces table, §7
- `master-plan.md` §3A
- the `## 6. Test Scope` sections of P0-P4
- P0-P4 implementation outputs

## 3. Verification Tasks

- Confirm `master-plan.md` uses the required Phase Overview table schema, every phase has exactly one canonical `phase-Px-*.md` file, and no duplicate phase files exist.
- Build the AC1 prototype harness: a fake socket transport and a fake FCM transport injecting the *same* durable event; assert `events()` yields it exactly once and that the consuming test code reads only `name`/`data` and never `transport`.
- Build the AC2 transition harness: drive the fake lifecycle source through `resumed -> paused -> (background injection) -> resumed`; assert no duplicate, no dropped durable event, and preserved order across the queue drain and resync.
- Assert AC3: the built handshake option map carries the current `idToken()` under `auth.token`, and no captured log or diagnostic string contains the token.
- Run the full mobile test suite, `flutter analyze`, and the registry build command.
- Record results concisely in `test-results.md`, one row per risk surface from `master-plan.md` §3A with pass / not-required / blocked.
- Write `spike-findings.md` for AC4: the validated API surface as the feature layer sees it (pointing at `../architecture/solution.md` §2 as authoritative rather than restating it), the measured harness results, and the two-tier dedup finding.
- In `spike-findings.md`, record the **manual operator procedure** for the real-device background leg (background the app, inject through FCM HTTP v1 per `../../deployment/configuration-guide.md`, foreground, observe exactly one event). Mark it as an operator-run step whose evidence is deferred, not a phase gate: R9 means there is no backend dispatch, and real-device/emulator lifecycle runs are outside this lane's test scope.
- Record the R8, R9, and ADR-012h escalations and the resolved room-key typing gap as follow-up items for epic-2/epic-3, with the note that none of them blocks this spike.

## 4. Acceptance Criteria

- All required automated checks pass; no critical regression remains.
- AC1, AC2, AC3 are each verified by a named harness test recorded in `test-results.md`.
- AC4 is satisfied by `spike-findings.md` plus `../architecture/solution.md`.
- Every risk surface in `master-plan.md` §3A is recorded as pass, not required, or blocked with a typed blocker.
- `spike-findings.md` states the deferred real-device confirmation and its R9 cause explicitly, so the reviewer does not read it as an untested claim.
- The next owner (STORY-007/008/009) can consume the coordinator without reading this plan.

## 4A. Verification Test Scope

- Source implementation phases: P0, P1, P2, P3, P4
- Platform / Surface: Flutter mobile, `mobile/`
- Required levels:
  - unit: full `mobile/test/core/realtime/` suite plus the AC1/AC2/AC3 harness
  - integration: coordinator + both fake transports + fake lifecycle, in-process only
  - backend e2e: `DO NOT PLAN for ordinary continue`
  - browser e2e: `DO NOT PLAN for ordinary continue`
  - mobile e2e: `DO NOT PLAN for ordinary continue`
  - mobile build/type-check/static-analysis: REQUIRED — `flutter analyze` and `flutter build apk --debug` (runtime registry `mobile-app.buildCommand`)
- Required runtime signals:
  - assertion evidence: emitted event count per injected durable id, status transition sequence, handshake auth map contents with the token redacted
- Evidence format:
  - concise `test-results.md` rows only
- Requirement mobile visual audit:
  - Required when requirement has mobile participation: NO for this story — it adds no screen or visual surface (UX WAIVED). The requirement-level mobile visual audit remains owned by the UI-bearing stories in REQ-001.
- Risk-surface gates:
  - touched risk surfaces: merged-stream dedup, foreground/background transition, socket subscription, token in handshake, room key correctness, session teardown
  - source-of-truth artifacts: `../architecture/solution.md` ADR-012b/c/d/g, §2
  - critical gates: dedup exactly-once; transition no-duplicate/no-drop; ack-before-`live`; token present and never logged; room key is the backend `User.id`
  - blocked gates: real-device background push confirmation — blocked by R9 (no backend FCM dispatch); recorded as a deferred manual operator procedure, not a failure
- Story-level runtime startup smoke: NOT REQUIRED — no runtime command, port, service boot path, or app entry point changes; the `mobile-app` registry readiness signal is a widget test already covered by `flutter test`.
- Local runtime/port safety gate: NOT REQUIRED — no Docker, Compose, root script, or registry entry changes.
- Backend e2e gate: not added.

## 5. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
