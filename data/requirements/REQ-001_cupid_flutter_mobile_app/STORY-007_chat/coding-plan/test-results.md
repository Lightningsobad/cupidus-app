# STORY-007 Test Results

## P1 — Chat Data Layer

| Command | Result |
| --- | --- |
| `flutter test test/features/chat/data/ test/core/realtime/` | PASS — 65/65 tests (17 new/extended in `chat_repository_test.dart`, 4 in `chat_message_mapper_test.dart`, 3 new + 1 modified in `realtime_coordinator_test.dart`; existing `test/core/realtime/` suites unchanged and passing) |
| `flutter analyze` (scoped: `lib/features/chat`, `lib/core/realtime`, `lib/core/di`, `test/features/chat`, `test/core/realtime`) | PASS — 0 errors, 0 warnings; 22 pre-existing `prefer_initializing_formals` info-level items, consistent with the established constructor style already present in frozen `fcm_transport.dart`/`socket_transport.dart` — no new issues |

### AC verification

- `send` on a live coordinator upserts exactly the ack payload; on a non-live coordinator throws `RealtimeNotLiveFailure` and writes nothing — covered by `ChatRepository.send` group (3 tests).
- The literal string `markDelivered` appears nowhere under `lib/features/chat`, and no `markDelivered` emit is ever recorded — covered by `markDelivered guard (ADR-013d)` group (string-scan + emit-list assertions).
- No `socket_io_client` or `firebase_messaging` import appears anywhere under `features/chat/` — covered by the same guard group.
- `loadOlder` reverses newest-first to ascending before upsert; a failing REST call leaves cached rows intact — covered by `ChatRepository.loadOlder` group (2 tests).
- `resyncPageOne` upserts and returns events, returns `const []` when `partnerId` is null — covered by `ChatRepository.resyncPageOne` group (2 tests).
- `ChatPartnerStore.clearOnSignOut()` clears `partnerId`, `displayName`, and the ghost flag — covered by `ChatPartnerStore` group (2 tests).
- `emit` returns the ack payload / resolves to `null` on timeout without hanging / still throws `RealtimeNotLiveFailure` when not live — covered by `emit ack (ADR-013g)` group in `realtime_coordinator_test.dart` (3 tests).
- Existing `test/core/realtime/` suite passes unchanged after the `service_locator.dart` edit — confirmed by the full combined run above.

### Notes

- One genuine `flutter analyze` finding was fixed during verification: `_eventsSubscription` in `chat_repository.dart` was write-only (unused_field warning). Added a `dispose()` method that cancels the subscription, resolving the warning with no behavior change.
- No `socket_transport.dart`, `pending_event_store.dart`, or `fcm_transport.dart` edits were made, per the ADR-013g WriteScope extension boundary.
