# Review Report — STORY-012 Timeline, Phase P1 (Drift Persistence Foundation)

## Scope

Full Reviewer gate (persistence/schema-touching work, per rule 6cc), scoped
**only** to Phase P1 of STORY-012:

- `mobile/lib/core/database/app_database.dart`
- `mobile/lib/core/database/app_database.g.dart` (generated)
- `mobile/lib/core/di/service_locator.dart` (`AppDatabase` registration only)
- `mobile/pubspec.yaml` (Drift-related dependency additions only)
- `mobile/test/core/database/app_database_test.dart`

P2–P8 are `NOT_STARTED` per `coding-plan/master-plan.md` and are explicitly
out of scope for this review.

- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-001_cupid_flutter_mobile_app-STORY-012`
- BaseHead: `df8d5097f89ab6c556a7e5b7269f45929b42f6a5`
- Diff inspected: `git -C <Worktree> diff df8d5097f89ab6c556a7e5b7269f45929b42f6a5 -- mobile/lib/core/database/app_database.dart mobile/lib/core/di/service_locator.dart mobile/pubspec.yaml mobile/test/core/database/app_database_test.dart`

## Findings Against Phase P1 Acceptance Criteria

(`coding-plan/phase-P1-drift-foundation.md` §4)

1. **`AppDatabase` opens with schema version 1, both tables exist.** PASS.
   `schemaVersion => 1`; `TimelineEntries` (`id` PK text, `type`, `title`,
   `description`/`photoUrl`/`icon` nullable, `createdAt`) and
   `TimelineSyncState` (single-row `id` default `0`, nullable
   `lastSyncedAt`) are both defined and covered by a dedicated "both tables
   exist" test.
2. **`watchFirstPage()` emits on every `replaceFirstPage()` and returns
   newest-first order.** PASS. `orderBy` on `createdAt` descending; test
   inserts out-of-order rows and asserts emission order `[b, c, a]` by
   `createdAt`.
3. **`replaceFirstPage()` is atomic.** PASS. Delete + batch insert + sync-state
   upsert are wrapped in a single `transaction()`. Test forces a mid-batch PK
   conflict (duplicate `id: 'dup'` in the same batch) and asserts the prior
   row (`'a'`) survives — this is a real atomicity assertion, not just a
   happy-path check.
4. **`lastSyncedAt()` null before first replace, timestamp after.** PASS,
   directly tested.
5. **`clearOnSignOut()` empties both tables; registered as a session-scoped
   store.** PASS. `AppDatabase implements SessionScopedStore`;
   `service_locator.dart` calls `getIt<CupidSession>().registerScopedStore(database)`
   at registration time, matching the existing `registerScopedStore` pattern
   already used for `RealtimeCoordinator` in the same file. Verified
   `mobile/lib/core/auth/cupid_session.dart` is untouched by this diff (read-only
   input, per the phase's own guardrail) and that `SessionScopedStore` is the
   single-method interface `AppDatabase` correctly implements.
6. **No token/credential/auth material written to Drift.** PASS by inspection
   — schema only carries timeline content fields; no session/token type is
   imported into `app_database.dart`.
7. **`flutter analyze` clean.** Not independently re-run — `flutter`/`dart`
   are not present in this review sandbox (`command not found`). Relying on
   the phase file's recorded evidence (`coding-plan/phase-P1-drift-foundation.md`
   §7: 17 pre-existing unrelated `info`-level hints, zero issues in files this
   phase touched). Same caveat applies to the claimed `flutter test` 6/6 pass
   — evidence is documented in the phase file, not independently re-executed
   here. This is a tooling-availability limitation, not a code finding.

## Other Observations

- Constructor `AppDatabase([QueryExecutor? executor])` correctly allows
  injecting `NativeDatabase.memory()` in tests while defaulting to the real
  `_openConnection()` (file-backed `NativeDatabase.createInBackground`) in
  production — matches the phase's testability requirement.
- Generated `app_database.g.dart` is consistent with the hand-written table
  definitions (column names, nullability, types match on inspection); marked
  `// GENERATED CODE - DO NOT MODIFY BY HAND` and committed, per the phase's
  codegen-reproducibility risk note.
- `pubspec.yaml` additions are scoped to what the phase's Tasks section
  authorized (`drift`, `sqlite3_flutter_libs`, `path_provider`, `path`,
  `drift_dev`, `build_runner`) — no unrelated dependency was smuggled in.
  (Note: the same diff/pubspec also carries unrelated `socket_io_client` /
  `firebase_messaging` / `shared_preferences` additions from the sibling
  STORY-004 realtime work already merged ahead of this branch point — out of
  scope for this P1 review.)
- `service_locator.dart` edit is additive and contiguous as required (merge
  hotspot risk noted in the master plan); it does not disturb the
  `RealtimeCoordinator` registration block already present.

## ADR-010 / Canonical Drift Owner Pre-Merge Condition

Per the review handoff, I checked
`data/architecture/system/system_architecture_memory.md` at this worktree's
current HEAD (which reflects `BaseHead` plus this story's own edits — no
`ADR-010` entry exists in it). §7 of that file currently runs ADR-001 through
ADR-009, plus ADR-012 (refining ADR-008); there is no ADR-010, and no
occurrence of `CupidDatabase` anywhere in this worktree's tracked files
(checked via `git ls-files` + content scan). This is expected under parallel
delivery — a sibling story's worktree (plausibly a STORY-007-adjacent
backend/chat persistence lane) may have introduced `CupidDatabase` and an
ADR-010 canonical-Drift-owner decision on its own branch, not yet visible
here pre-merge.

I cannot independently confirm the specifics of ADR-010 or `CupidDatabase`'s
shape from this worktree, but I am flagging the condition exactly as
instructed: **this P1 output (`AppDatabase`) must not be assumed mergeable to
`main` as a second, independent Drift database owner without a Scrum
Master-tracked pre-merge fold/reconciliation into whatever the canonical
`CupidDatabase` owner turns out to be.** Two independent `DriftDatabase`
singletons opening two separate SQLite files on the same device is an
architecture-consistency risk (and, depending on the other side's table
names, a potential runtime conflict) that must be resolved before both
stories reach `main`, not after.

This condition does **not** block this phase's structural soundness — P1's
own AC1–AC4 (schema, DAO behaviour, atomicity, sign-out wipe) are fully met
in isolation, and the fold is correctly scoped by the handoff as a separate
pre-merge task, not part of P1 implementation scope.

## Outcome

**DEFERRED_ONLY**

P1 (Drift persistence foundation) is structurally sound and its acceptance
criteria are met by inspection and by the recorded/committed unit test
evidence. Merge to `main` is deferred pending the Scrum Master-tracked
ADR-010 canonical-Drift-owner fold (`AppDatabase` vs `CupidDatabase`) —
this is a pre-merge integration condition, not a defect in this phase's
implementation.

REVIEW_COMPLETE
Outcome: DEFERRED_ONLY
