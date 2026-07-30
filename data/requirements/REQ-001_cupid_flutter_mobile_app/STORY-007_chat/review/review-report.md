# Review Report: STORY-007 Chat — Phase P0 (Drift Persistence Foundation)

Outcome: CLEAN

## Scope Gate

Full scope gate recorded separately: `review/scope-gate.md` (`Phase: SCOPE_GATE`, `SCOPE_GATE_COMPLETE: YES`).

- Review type: full Reviewer gate, scoped to Phase P0 only (persistence/schema-touching work per rule 6cc). P1-P5 are `NOT_STARTED` and explicitly out of scope for this pass.
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-001_cupid_flutter_mobile_app-STORY-007`
- BaseHead: `df8d5097f89ab6c556a7e5b7269f45929b42f6a5` -> Worktree HEAD `e2d05a737e555d0a404c0220f0f8073ee81dc4fe`
- Source files in scope (P0 write scope only):
  - `mobile/lib/core/database/cupid_database.dart`
  - `mobile/lib/core/database/cupid_database.g.dart` (generated, targeted read of `$MessagesTable` column block)
  - `mobile/lib/core/database/tables/messages_table.dart`
  - `mobile/lib/core/database/daos/message_dao.dart`
  - `mobile/lib/core/database/daos/message_dao.g.dart` (generated)
  - `mobile/test/core/database/message_dao_test.dart`
  - `mobile/pubspec.yaml` (Drift dependency additions only)
- Evidence files in scope: `coding-plan/phase-P0-drift-foundation.md` §7 Status
- Governing artifacts: `coding-plan/master-plan.md` (P0 row + §3A risk surface), `architecture/solution.md` §2/§4, `data/architecture/system/system_architecture_memory.md` §7/§9
- Explicitly excluded per handoff: the wider branch diff also carries STORY-004 realtime-coordinator files (`core/realtime/**`, `core/di/service_locator.dart`, `auth_repository.dart`, related tests) and other STORY-007 phase-plan/UX docs. None of these were reviewed or used to influence this outcome. STORY-012's competing `AppDatabase` (separate worktree) was not inspected and is not a factor here.

## Reviewed Inputs

- `story_master.md` (Role Completion records Mobile P0 done, 2026-07-30)
- `coding-plan/phase-P0-drift-foundation.md` (canonical P0 phase file, Status: DONE)
- `coding-plan/master-plan.md` §3, §3A, §5 (P0 row)
- `architecture/solution.md` §2 Downstream Contract Summary (data model / migration contract), §4 Boundaries And Ownership
- `system_architecture_memory.md` §7 ADR-007 (Drift read-through, no offline queue) — note: the handoff referenced an "ADR-010" tie-break for the canonical Drift owner, but this memory file (current worktree state) only contains ADR-001 through ADR-009; no ADR-010 exists yet. Not treated as blocking — the STORY-007 `architecture/solution.md` §4 already independently states `core/database/` is the single Drift owner and `core/` must never import `features/`, which is sufficient traceability for P0. The cross-story tie-break reconciliation is out of this review's scope per the handoff.
- Full diff of the five P0 source/test files plus the relevant `pubspec.yaml` hunk

## Traceability

| AC / Invariant | Requirement | Verified Against | Result |
|---|---|---|---|
| Data model contract | `solution.md` §2: `messages` table = `id`(PK), `senderId`, `receiverId`, `content`, `type`, `status`, `readAt`(nullable), `createdAt`, `cachedAt`; no other columns | `messages_table.dart`, generated `$MessagesTable` column list (`cupid_database.g.dart:6-113`) | PASS — exactly the 9 spec'd columns, `id` is the sole primary key |
| AC4 / OQ4 / ADR-007 (no offline queue) | No `pending`/`queued`/`outbox`/`retryCount`/`sendState`/`localId` column | Table + generated column list + `message_dao_test.dart` schema-absence test | PASS — no such column exists; test enumerates `database.messages.$columns` and asserts absence of `pending/queued/outbox/retry/local/sendState` fragments |
| Upsert dedupe | `upsertAll` must never duplicate a row for the same server `id` | `message_dao.dart:16-20` (`insertAllOnConflictUpdate` keyed on PK `id`) + test `MessageDao.upsertAll` | PASS — double-upsert test asserts 1 row with the second write's `content` |
| `pageForPartner` ascending, bidirectional, paged | Returns ascending `createdAt`, covers both sender/receiver directions, respects `limit`/`offset` | `message_dao.dart:26-37` (`_forPartner` OR-clause + `OrderingTerm.asc`) + test | PASS — 4-message fixture (incl. a distractor conversation) asserts correct ascending order and `limit:1/offset:1` isolation; distractor conversation confirmed not leaking in |
| `markSeenLocally` | Sets `status='seen'` and stamps `readAt` for messages the partner sent me | `message_dao.dart:55-71` + test | PASS |
| `clearAll` | Sign-out teardown wipes the cache | `message_dao.dart:74` + test | PASS |
| Single Drift owner / layering | `core/database/` is the only `@DriftDatabase`; `core/` must not import `features/` | `cupid_database.dart:12-23` (doc comment + single `@DriftDatabase` annotation over `Messages`); no `features/` import present | PASS |
| Dependency additions | `drift`, `sqlite3_flutter_libs`, `path_provider` (deps); `drift_dev`, `build_runner` (dev deps) | `pubspec.yaml` diff | PASS — exact match, existing pin style preserved |
| schemaVersion | `schemaVersion => 1`, no migration | `cupid_database.dart:21-22` | PASS |
| Injectable executor for tests | DB must accept an injectable `QueryExecutor` so tests can use in-memory DB | `cupid_database.dart:19` constructor + `message_dao_test.dart:9` (`NativeDatabase.memory()`) | PASS |

## Touched Risk Surfaces And Critical Gates

- Risk surface: Local persistence / schema (ADR-007), per `master-plan.md` §3A row 1.
- Critical gate: unit tests for double-upsert dedupe, ascending paged read (both directions), and schema-column-absence assertion; `flutter analyze` clean.
- Gate status: evidence recorded in `coding-plan/phase-P0-drift-foundation.md` §7 (`flutter test test/core/database/` -> `+5 All tests passed!`; `flutter analyze lib/core/database test/core/database` -> "No issues found!"). The `flutter`/`dart` toolchain is not available in this review sandbox to independently re-execute the commands; evidence was instead corroborated by direct code inspection — the test file's five assertions were traced line-by-line against the DAO implementation and the generated `$MessagesTable` column list, and all five are logically sound and consistent with the implementation (see Traceability table). Evidence is not stale, missing, or contradictory, so rerunning was not required per reviewer rule 18.
- Configuration guide impact (rule 12a): phase file records "Update Required: NO" for `deployment/configuration-guide.md` — correct, this phase adds no env var, secret, port, or external integration.
- Runtime startup smoke (rule 12g): not applicable — phase metadata records `Startup Smoke: NOT_APPLICABLE` for `mobile-app` at this phase (interactive, needs a connected device; no user-visible surface ships from P0).

## Deferred (non-blocking)

1. `coding-plan/master-plan.md` §5 Phases Overview still lists P0's `Status` column as `NOT_STARTED`, while the canonical `phase-P0-drift-foundation.md` §7 and `story_master.md` Role Completion both record P0 as done (2026-07-30). This is a documentation-sync gap, not a code defect — recommend Scrum Master update the master-plan phase table before routing P1 so phase-status tracking stays consistent.

## Outcome Rationale

All P0 acceptance criteria (schema shape, AC4 schema-absence gate, upsert dedupe, ascending paged bidirectional read, `markSeenLocally`, `clearAll`, single-Drift-owner layering, dependency set, schemaVersion, injectable executor) are implemented exactly as specified in `architecture/solution.md` §2 and `phase-P0-drift-foundation.md`, and are covered by passing, well-targeted tests. No blocking findings. One non-blocking documentation-sync deferred item recorded above.

## State Recommendation

- Keep `Implementation (Development)` checked for the P0 slice.
- Check `Review (Reviewer)` for P0.
- P0 phase can be considered closed; STORY-007 as a whole remains `IN_PROGRESS` pending P1-P5 (not reviewed in this pass).
