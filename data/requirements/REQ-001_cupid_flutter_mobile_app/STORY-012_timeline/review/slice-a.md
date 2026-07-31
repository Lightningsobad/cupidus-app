# STORY-012 Review — Slice A (P1 Drift Foundation, P2 Timeline Remote Contract, P3 Timeline Repository + Pairing)

Reviewer: Iris-QC (scoped-slice, parallel-story)
BaseHead: 0a467d03babf1ed4102c3fab09c61b2dec941a0b
Worktree: /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-001_cupid_flutter_mobile_app-STORY-012

## Summary

| Point | Description | Result |
|-------|-------------|--------|
| 1 | `TimelineEventDto.fromJson` decodes the frozen backend shape correctly (absent/null optionals, unknown `type`), without reimplementing backend logic | PASS |
| 2 | Drift schema (`timeline_entries`, `timeline_sync_state`) + DAO is a pure read-through cache; no offline write queue/outbox/optimistic insert/client-generated id/automatic retry anywhere in P1-P3; `clearOnSignOut()` wipes all timeline rows | PASS |
| 3 | `TimelineRepository.createEntry()` fails fast (no local write, no queueing) under `NetworkUnavailableFailure` per ADR-007 | PASS |
| 4 | `CouplePairingStore.resolve()` distinguishes paired/unpaired/unknown and serves a cached value when offline | PASS |
| 5 | No dead/unused code; no new pub dependency beyond P1 Drift/sqlite3 setup | PASS |

## Evidence

**Point 1** (`mobile/lib/features/timeline/data/timeline_event_dto.dart:30-80`): `fromJson` requires `id`/`title`/`createdAt` and throws a typed `TimelineDecodeException` when any is missing or the wrong type; `description`/`photoUrl`/`icon` are read with nullable casts (`as String?`), correctly handling both an absent key and an explicit `null` value the same way. `_typeFromWire` maps `'milestone'`/`'system'` explicitly and falls back to `TimelineEventType.memory` for any other value (including an unrecognized string), matching the frozen contract's "unknown `type` falls back to memory" requirement — this is pure client-side decoding of the wire shape, not a reimplementation of backend business logic. Confirmed by `mobile/test/features/timeline/data/timeline_event_dto_test.dart`, which covers a full payload, absent optionals, explicit-null optionals, unknown type, milestone/system types, and four missing/malformed-field failure cases.

**Point 2**: `mobile/lib/core/database/app_database.dart:14-35` defines `TimelineEntries` and `TimelineSyncState` with no columns or indices suggesting queued/pending writes (no `status`, `pendingSync`, `localId`, or similar). `watchFirstPage()` (line 48) is read-only; `replaceFirstPage()` (line 59) always fully deletes and re-inserts inside one `transaction()`, i.e. server-authoritative overwrite, not a merge/queue. `lastSyncedAt()` (line 81) and `TimelineSyncState` implement the never-synced-vs-synced-empty distinction (D-012-6) without any write-queue semantics. `clearOnSignOut()` (line 90) deletes from both `timelineEntries` and `timelineSyncState` unconditionally — full wipe, no residual filter. Verified by `mobile/test/core/database/app_database_test.dart`: schema version, newest-first ordering, atomicity of `replaceFirstPage` under a mid-batch unique-constraint violation (duplicate `id`s roll back to the prior row set), `lastSyncedAt` null→non-null transition, and `clearOnSignOut` emptying both tables. `TimelineRepository.refresh()` (`timeline_repository.dart:53-67`) only ever calls `_database.replaceFirstPage` after a successful remote fetch; on `NetworkUnavailableFailure`/`TimeoutFailure` it reads `lastSyncedAt()` to pick `TimelineOfflineWithCache`/`TimelineOfflineNoCache` and never writes. No outbox table, no client-generated id path, and no automatic retry loop exist anywhere in the P1-P3 diff.

**Point 3**: `TimelineRepository.createEntry()` (`timeline_repository.dart:73-76`) calls `await _remote.createEntry(draft)` with no `try/catch` around it, so a `CupidApiFailure` (including `NetworkUnavailableFailure`) propagates directly to the caller and the method returns before reaching the `refresh()` call — no local Drift write is attempted on the failure path. `mobile/test/features/timeline/data/timeline_repository_test.dart:224-247` (`createEntry performs exactly one POST and no local insert on failure`) asserts exactly this: the thrown `NetworkUnavailableFailure` propagates, `postCount == 1` (no retry), and `timelineEntries` remains empty afterward.

**Point 4**: `CouplePairingStore.resolve()` (`couple_pairing_store.dart:34-47`) returns a cached value immediately when one exists (triggering only a fire-and-forget background refresh via `unawaited`), otherwise fetches from `GET /users/me` and persists the result, and returns `PairingStatus.unknown` (uncached) on any `CupidApiFailure` rather than guessing `paired`/`unpaired`. `_fetchFromNetwork` (line 68) correctly derives `paired` from a non-null `partnerId` and `unpaired` otherwise. Persistence keys are scoped per backend user id (`_resolveKey`, line 98) and `clearOnSignOut()` removes the key, with `_lastKnownUserId` retained so sign-out teardown still resolves the key even if `BackendUserIdStore` clears first (an ordering-safety detail called out in the source comment and exercised by its own test). `mobile/test/core/couple/couple_pairing_store_test.dart` covers paired, unpaired, cached-served-while-offline (with network-call count assertion), unknown-when-uncached-and-offline, clearOnSignOut removing the persisted value, and the teardown-ordering case.

**Point 5**: `mobile/lib/core/di/service_locator.dart` diff (lines 61-95 in the new file) is purely additive lazy-singleton registrations for `AppDatabase`, `TimelineRepository`, and `CouplePairingStore`, each wired to existing seams (`CupidSession.registerScopedStore`, `CupidApi`, `BackendUserIdStore`) with no unused imports or orphaned registrations. `mobile/pubspec.yaml` diff adds exactly `drift`, `sqlite3_flutter_libs`, `path_provider`, `path` (runtime) and `drift_dev`, `build_runner` (dev) — all required for the P1 Drift/codegen setup per master-plan §5 P1 row and none of the explicitly forbidden packages (`image_picker`, `connectivity_plus`, libsodium/FFI) from `architecture/solution.md` §4 "Mobile guardrails". `app_database.g.dart` is legitimate `build_runner`-generated output (`// GENERATED CODE - DO NOT MODIFY BY HAND` header, `part of 'app_database.dart'`), consistent with `app_database.dart`'s `part 'app_database.g.dart'` declaration and the committed-codegen risk note in the master plan. No dead code, unused variables, or unreferenced declarations found in the reviewed files.

## Notes (non-blocking)

- The generated Drift data class for the `TimelineEntries` table is named `TimelineEntry` (Drift's singularization convention), which collides with the hand-written domain model `TimelineEntry` in `mobile/lib/features/timeline/domain/timeline_entry.dart`. This is handled correctly everywhere it matters: `timeline_repository.dart` imports the database module with `as db` and consistently uses `db.TimelineEntry` for rows vs. bare `TimelineEntry` for the domain type, and the two test files that need both (`timeline_repository_test.dart`) use the same alias. No file in this slice imports both names unqualified. Flagging only so slice-b/slice-c reviewers are aware of the naming collision if any P4+ file needs to reference both types.

## Outcome

Outcome: CLEAN

REVIEW_SLICE_COMPLETE: YES
