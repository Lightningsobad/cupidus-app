# STORY-007 Reviewer Slice Report — slice "db-foundation"

- Reviewer: Iris-QC (scoped-slice)
- Scope: `db-foundation` slice only (Drift/`CupidDatabase` foundation)
- BaseHead: `0a467d03babf1ed4102c3fab09c61b2dec941a0b`
- Worktree HEAD: `656ff52d389723699786afb911d182f021650955`
- Files reviewed (diff against BaseHead only):
  - `data/architecture/system/system_architecture_memory.md`
  - `mobile/lib/core/database/cupid_database.dart`
  - `mobile/lib/core/database/cupid_database.g.dart`
  - `mobile/lib/core/database/daos/message_dao.dart`
  - `mobile/lib/core/database/daos/message_dao.g.dart`
  - `mobile/lib/core/database/tables/messages_table.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/pubspec.lock`
  - `mobile/pubspec.yaml`
  - `mobile/test/core/database/message_dao_test.dart`

## 1. Schema/DAO/table match the documented chat message contract — PASS

- `mobile/lib/core/database/tables/messages_table.dart` declares exactly the
  9 columns specified in `architecture/solution.md` §4 Data model contract
  and phase file `coding-plan/phase-P0-drift-foundation.md` §3/§4: `id` (PK),
  `senderId`, `receiverId`, `content`, `type`, `status`, `readAt` (nullable),
  `createdAt`, `cachedAt`. No `localId`/`pending`/`queued`/`outbox`/
  `retryCount`/`sendState` column exists — required by AC4/OQ4/ADR-007.
- `mobile/lib/core/database/cupid_database.dart`: `CupidDatabase` is
  `@DriftDatabase(tables: [Messages], daos: [MessageDao])`, `schemaVersion
  => 1`, injectable `QueryExecutor` (test seam), default `NativeDatabase`
  opened from `path_provider`'s app-documents dir.
- `mobile/lib/core/database/daos/message_dao.dart`: `MessageDao` exposes
  `upsertAll` (`insertAllOnConflictUpdate`, dedupe by server `id`),
  `pageForPartner`/`watchForPartner` (ascending `createdAt`, both
  sender/receiver directions via `_forPartner`), `markSeenLocally`,
  `clearAll`. Matches `phase-P0-drift-foundation.md` §3 task list exactly.
- Test evidence (`mobile/test/core/database/message_dao_test.dart`, read in
  full): 6 tests —
  `MessageDao.upsertAll` double-upsert-one-row-second-values,
  `MessageDao.pageForPartner` ascending + limit/offset + cross-conversation
  isolation, `MessageDao.markSeenLocally`, `MessageDao.clearAll`, and the
  `messages schema (AC4/OQ4/ADR-007 gate)` column-name-fragment-absence
  assertion (`pending`/`queued`/`outbox`/`retry`/`local`/`sendState`).
  `coding-plan/test-results.md` P0 evidence and P5 final gate both record
  `flutter test` passing (P5 final: 174/174) and `flutter analyze` clean for
  this path (P0: `flutter analyze lib/core/database test/core/database` ->
  "No issues found!"; P5 final: `flutter analyze lib test` 0 errors/0
  warnings, 32 pre-existing info-level items unrelated to this slice).

## 2. `service_locator.dart` registers exactly one Drift database class — PASS

- Diff adds exactly one registration: `getIt.registerLazySingleton<CupidDatabase>(CupidDatabase.new)`,
  plus `MessageDao` resolved via `getIt<CupidDatabase>().messageDao` (not a
  second database instance).
- Repo-wide check: `git ls-files mobile/lib | xargs grep -l "DriftDatabase\|extends _\$"`
  returns only `mobile/lib/core/database/cupid_database.dart` — no second
  `@DriftDatabase`-annotated class exists anywhere in `mobile/lib/`.
- `_MessageDaoScopedStore` (new, in the same diff) only adapts the existing
  `MessageDao` to `SessionScopedStore` for sign-out teardown; it does not
  introduce a second store/database.

## 3. ADR §7 update to `system_architecture_memory.md` — FAIL (as specified) / handoff citation is stale

- The handoff instructed verifying an "ADR-010 §7 update ... describing this
  story's own contribution (the canonical `CupidDatabase` foundation)".
  **No ADR-010 exists anywhere in `system_architecture_memory.md`** (current
  §7 runs ADR-001 through ADR-009, plus an inline "Refined by STORY-004
  ADR-012" note and an inline "Amended ... by STORY-007 ADR-013g" note — no
  ADR-010, ADR-011, or ADR-014 entry is present). This looks like a stale/
  incorrect citation in the handoff, not a slice defect — treating the
  underlying question literally, it cannot be verified because the cited
  update does not exist.
- The diff to `system_architecture_memory.md` in this slice (`git diff
  BaseHead -- data/architecture/system/system_architecture_memory.md`) is
  **17 insertions, entirely about ADR-013g** (the `RealtimeCoordinator.emit`
  ack-contract widening) plus its `Update History` row and a `§8` risk row
  ("Socket ack availability", "`joinRoom` ack assumption"). It contains
  **zero** content about `CupidDatabase`, Drift, or a single-Drift-owner
  rule.
- This is consistent with, not contradicted by, the story's own architecture
  record: `data/requirements/.../STORY-007_chat/architecture/solution.md`
  §8 Handoff Notes states explicitly: "Memory updates required: recommended
  but **out of this story's write scope**. After review, fold into
  `system_architecture_memory.md`: ... and the `core/database/`
  single-Drift-owner rule for timeline/expenses." So the omission is a
  **deliberate, documented deferral**, not an oversight — but it does mean
  the specific artifact the handoff asked me to check (an ADR §7 update
  describing the `CupidDatabase` foundation) does not exist in this diff,
  in this story, or anywhere in the current architecture memory file.
- Today the single-Drift-owner rule is documented only in two places: (a)
  code comments in `cupid_database.dart` ("The app's single Drift owner...")
  and `message_dao.dart`, and (b) `STORY-007/architecture/solution.md` §4
  Boundaries And Ownership / §8 Handoff Notes. Until a follow-up folds this
  into `system_architecture_memory.md`, the canonical shared memory the
  handoff cites for cross-story enforcement (blocking a second Drift
  database class, e.g. STORY-012's now-superseded `AppDatabase`) is not
  actually recorded there yet.
- Recommend: file/track the deferred memory-fold explicitly (Scrum Master)
  so it isn't lost before STORY-012's `AppDatabase` fold-in; it is not a
  blocking defect for this slice's own code, since `story_master.md`/
  `solution.md` already scoped it out of this story's write scope.

## 4. No dead/unused code; dependency additions match Drift foundation — PASS

- `mobile/pubspec.yaml`: added `drift: ^2.28.2`, `sqlite3_flutter_libs:
  ^0.5.35`, `path_provider: ^2.1.5` under `dependencies`; `drift_dev:
  ^2.28.2`, `build_runner: ^2.7.1` under `dev_dependencies`. All five are
  directly required by the Drift foundation (`@DriftDatabase` codegen,
  native sqlite engine, app-documents-dir file path); nothing unrelated was
  added. `mobile/pubspec.lock` diff is the expected transitive-dependency
  lock expansion for these five packages (270 lines, consistent with a
  first-time Drift toolchain addition); confirmed via `dart run build_runner
  build --delete-conflicting-outputs` re-run being a no-op per
  `test-results.md` P5 evidence ("`git status --porcelain` empty afterward").
- No unused imports, unused fields, or dead branches introduced in
  `cupid_database.dart`, `message_dao.dart`, or `messages_table.dart` —
  `flutter analyze lib/core/database test/core/database` reported "No issues
  found!" (P0 evidence) and the P5 final unscoped-to-lib/test run reports 0
  errors/0 warnings (only pre-existing `prefer_initializing_formals` info
  items elsewhere, none in this slice's files).
- `service_locator.dart`'s new `_MessageDaoScopedStore` class is used
  immediately (registered as a scoped store in the same diff) — not dead
  code.

## Outcome

- Point 1: PASS
- Point 2: PASS
- Point 3: FAIL (as literally specified — cited ADR-010 update does not
  exist in this diff or file; deferral is documented and intentional per
  `solution.md` §8, but the artifact requested for review is absent)
- Point 4: PASS

REVIEW_SLICE_COMPLETE: YES
