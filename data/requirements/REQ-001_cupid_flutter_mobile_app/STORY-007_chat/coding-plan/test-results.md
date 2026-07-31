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

## P5 — Mobile Verification (Final)

- Date: 2026-07-31
- Status: BLOCKED (see §Blockers)

### Build/Test/Analyze Gate Commands

| Command | Result |
|---|---|
| `flutter test` | 168/171 passed, 3 failed (see §Blockers) |
| `flutter analyze` (unscoped, includes vendored `build/ios/SourcePackages/**` checkouts unrelated to this app) | not meaningful as run — see scoped result below |
| `flutter analyze lib test` (scoped to this app's own source, matching the "scoped to touched files" precedent set by P2/P3/P4) | 32 issues, all `info`-level `prefer_initializing_formals`; 0 errors, 0 warnings; same pre-existing pattern already accepted in P2-P4 evidence, no new issue class |
| `flutter build apk --debug` | Succeeded — `build/app/outputs/flutter-apk/app-debug.apk` built |
| `dart run build_runner build --delete-conflicting-outputs` | Ran; 206 outputs written; `git status --porcelain` empty afterward — confirmed no-op against committed generated code |

### Risk Surfaces (`master-plan.md` §3A)

| Risk Surface | Gate | Result |
|---|---|---|
| Local persistence (ADR-007) | Schema-absence assertion (no pending/queued/outbox column); double-upsert dedupe; ascending paged read | PASS — `test/core/database/message_dao_test.dart` |
| Realtime send/receive | send-while-live appends from `emit()` ack; send-while-offline throws `RealtimeNotLiveFailure`, no queue write; `newMessage` dedupe | PASS — `test/features/chat/data/chat_repository_test.dart`, `test/features/chat/presentation/chat_cubit_test.dart` |
| Typing-ghost timing (AC2) | Fake-clock unit tests: 120ms throttle, immediate flush on delete, 1200ms idle, 6000ms receiver stale expiry | PASS — `test/features/chat/presentation/ghost_cubit_test.dart` |
| Read-receipt correctness | `markDelivered` never emitted, 2-state receipt only | PASS — `test/features/chat/data/chat_repository_test.dart` (string-scan guard) + `test/features/chat/presentation/chat_cubit_test.dart` |
| Ghost consent + privacy | Composer ghost stays off until explicit local opt-in even when server flag is `true`; ghost content never persisted | PASS — `test/features/chat/presentation/ghost_cubit_test.dart` (no-persistence guard tests) |
| Pairing gate (AC5) | `partnerId == null` -> chat destination absent, route unreachable | PASS — `test/core/navigation/app_shell_test.dart` |
| Discoverability | Chat reachable from shell; `ghostset` reachable from chat header; `Key('home_screen_ready_signal')` still pumps | **BLOCKED** — the `home_screen_ready_signal` key is confirmed reachable through `AppShell` directly in `test/core/navigation/app_shell_test.dart` (test-injected dependencies), but fails when reached through the real app composition root (`CupidApp`/`main.dart`) in `test/widget_test.dart` and `test/app/feature_flags_test.dart`. See §Blockers item 1. |

### Acceptance Criteria (`story_master.md`)

| AC | Text | Result | Asserting Test(s) |
|---|---|---|---|
| AC1 | Paired users can send and receive text messages in real time | PASS | `test/features/chat/data/chat_repository_test.dart`, `test/features/chat/presentation/chat_cubit_test.dart` |
| AC2 | Typing-ghost indicator appears/disappears correctly in both directions within threshold (ADR-013b: throttle 120ms, idle 1200ms, receiver stale expiry 6000ms) | PASS | `test/features/chat/presentation/ghost_cubit_test.dart` (fake-clock deterministic timing) |
| AC3 | Message history available on reopening the app (Drift-backed read-through, server-authoritative) | PASS | `test/core/database/message_dao_test.dart`, `test/features/chat/data/chat_repository_test.dart` |
| AC4 | No local queued/offline message send exists; sends require connectivity | PASS | `test/core/database/message_dao_test.dart` (schema-absence guard), `test/features/chat/data/chat_repository_test.dart` (send-while-offline throws, no queue write) |
| AC5 | Chat is inaccessible to unpaired users | PASS | `test/core/navigation/app_shell_test.dart` (unpaired: Chat tab absent) |

All 5 ACs pass on their own asserting tests. AC5/Discoverability's "still pumps" clause in `master-plan.md` §3A additionally requires the readiness key to survive when reached through the real `CupidApp` composition root, which fails — see Blocker 1.

### ADR-Guard Checks (`phase-P5-verification.md` §3)

All six verified manually (Read-tool file inspection, substituting for shell grep per the query-first-guard workaround) and cross-confirmed by existing automated test assertions:

| Guard | Result | Evidence |
|---|---|---|
| No `pending`/`queued`/`outbox`/`retry`/`local`/`sendState` column in Drift `messages` schema (ADR-007) | PASS | `lib/core/database/tables/messages_table.dart`; `test/core/database/message_dao_test.dart` schema-absence assertion |
| `markDelivered` appears nowhere under `mobile/lib/features/chat/` (ADR-013d) | PASS | `test/features/chat/data/chat_repository_test.dart` file-scan assertion |
| No attachment/image control in `chat_composer.dart` (ADR-013a) | PASS | manual read — only ghost toggle, TextField, send button |
| No `socket_io_client`/`firebase_messaging` import under `mobile/lib/features/chat/` (STORY-004 §2) | PASS | `test/features/chat/data/chat_repository_test.dart` import-scan assertion |
| No ghost `content` written to Drift/`shared_preferences`/log (ADR-013b) | PASS | `test/features/chat/presentation/ghost_cubit_test.dart` no-persistence guard tests |
| No STORY-005 pairing source file imported under `mobile/lib/features/chat/` | PASS | `test/core/navigation/app_shell_test.dart` `'STORY-005 pairing-source isolation guard'` group |

### Blockers

Both blockers are `mobile/lib/**` defects, outside this phase's `mobile/test/**`-only write scope. They cannot be fixed within P5.

#### Blocker 1 — `AppShell` boots unregistered when reached through the real app composition root

- **Failing tests**: `test/widget_test.dart` ("App boots to the home screen ready signal"), `test/app/feature_flags_test.dart` ("CupidApp resolves dark theme mode and vi locale with flags off, and the runtime readiness key still resolves")
- **Root cause**: `lib/main.dart` calls `runApp(const CupidApp())` without ever calling `setupServiceLocator()` (`lib/core/di/service_locator.dart`). `CupidApp` composes `home: const AppShell()` (`lib/app/cupid_app.dart:38`), and `_AppShellState`'s late finals eagerly resolve `getIt<ChatPartnerStore>()` on first build (`lib/core/navigation/app_shell.dart:55`). With no prior `setupServiceLocator()` call, this throws `Bad state: GetIt: Object/factory with type ChatPartnerStore is not registered inside GetIt.` This reproduces identically for a real device boot, not only under `flutter test` — `main.dart`'s boot path is unconditional and unchanged by test doubles.
- **Scope**: introduced when P4 wired `AppShell`'s chat-feature `getIt` calls into the shell that `CupidApp.home` always mounts; `lib/main.dart` was never updated to call `setupServiceLocator()` before `runApp()`.
- **Fix location**: `lib/main.dart` (add `setupServiceLocator();` before `runApp(const CupidApp())`) — outside P5 write scope (`mobile/lib/**`).

#### Blocker 2 — Raw `Colors.` literals in three STORY-007 chat presentation files violate the design-system no-fork guard

- **Failing test**: `test/design_system/no_fork_guard_test.dart` ("AC 4 no-fork guard: features/app/core never fork on a raw color literal or Platform.is*/defaultTargetPlatform"), asserting `lib/features`, `lib/app`, `lib/core` never use a raw `Colors.`/`Color(0x` literal outside `design_system/` (`architecture/solution.md` D3/ADR-004).
- **Violations found**:
  - `lib/features/chat/presentation/screens/ghost_settings_screen.dart:112,116,121`
  - `lib/features/chat/presentation/widgets/chat_composer.dart:196`
  - `lib/features/chat/presentation/widgets/message_bubble.dart:80,91,106`
- **Scope**: these files were produced by P2/P3 (already committed, marked DONE). This is the first full, repo-wide `flutter test` run against them; P2/P3's own local verification runs were scoped to `test/features/chat/` and never exercised this cross-cutting design-system guard test.
- **Fix location**: the three files above under `mobile/lib/features/chat/` — outside P5 write scope (`mobile/test/**` only).

### Recommendation

`flutter analyze`, `flutter build apk --debug`, and the `build_runner` no-op check all pass cleanly. All ADR-guard checks and all 5 ACs pass on their own asserting tests. However, the full `flutter test` suite has 2 real, reproducible failures rooted in `mobile/lib/**` code from already-committed P2/P3/P4 phases, one of which (`main.dart` missing `setupServiceLocator()`) is a genuine app-boot defect, not merely a test-harness gap. Both require `mobile/lib/**` edits outside this phase's write scope. Recommend a small follow-up fix (Mobile Developer, `mobile/lib/**` write scope) before this story proceeds to the Reviewer gate.

## P5 — Follow-up Fix (Session Recovery)

- Date: 2026-07-31
- Status: RESOLVED — `flutter test` 174/174 passed, `flutter analyze lib test` 0 errors/0 warnings (32 pre-existing info notices, unchanged), `flutter build apk --debug` succeeded, `build_runner` no-op confirmed.

### Blockers §Resolution

#### Blocker 1 — `AppShell` boots unregistered through the real app composition root — RESOLVED

- **Fix**: `mobile/lib/main.dart` now calls `setupServiceLocator()` before `runApp(const CupidApp())`, matching every other correct DI-bootstrap entrypoint in this codebase.
- **Test-harness gap uncovered by the same fix**: `test/widget_test.dart` and `test/app/feature_flags_test.dart` pump `CupidApp()` directly (never through `main()`), so they must register their own GetIt dependencies rather than relying on `setupServiceLocator()`, which would otherwise reach a real (unmocked) Firebase/`CupidApi`/Dio chain in a bare widget test. Both files now register a real `ChatPartnerStore` backed by a fake `HttpClientAdapter` (mirroring the existing pattern in `test/core/navigation/app_shell_test.dart`) in `setUp`, and reset GetIt in `tearDown`. `ChatRepository`/`RealtimeCoordinator`/`BackendUserIdStore` do not need registration for these two tests: `AppShell` only force-resolves those `late final` fields when the Chat tab (not Home, index 0) is actually built, which neither test reaches.
- **`getIt.reset()` ordering pitfall found while fixing**: `GetIt.reset()` returns a `Future`; calling it without `await` inside `setUp` let the reset complete asynchronously *after* the subsequent `registerSingleton` call in the same `setUp`, silently wiping the just-added registration and reproducing the original "not registered" failure. Fixed by making both `setUp` callbacks `async` and awaiting `getIt.reset()`.
- **Pending-timer pitfall found while fixing**: `ChatEntryGate.initState()` fires an unawaited `refreshFromServer()` network call. A single `tester.pump()` after `pumpWidget` did not reliably flush the fake Dio adapter's internal zero-duration `Timer` before test teardown, tripping flutter_test's `!timersPending` invariant. Fixed by using `await tester.pumpAndSettle();` instead of a single `pump()` in both tests.
- **Verifying tests**: `test/widget_test.dart` ("App boots to the home screen ready signal"), `test/app/feature_flags_test.dart` ("CupidApp resolves dark theme mode and vi locale with flags off, and the runtime readiness key still resolves") — both pass; confirmed via `flutter test test/widget_test.dart test/app/feature_flags_test.dart` (exit 0) and via the full suite (174/174).

#### Blocker 2 — Raw `Colors.` literals in three STORY-007 chat presentation files — RESOLVED

- **Fix**: replaced every raw `Colors.white` / `Colors.white.withValues(alpha: ...)` literal at the 5 flagged locations with `colors.colorText` / `colors.colorText.withValues(alpha: ...)`, matching the established `colors.<token>` pattern already used elsewhere in the same three files (`CupidColorTokens` obtained via `context.cupidColors`, already in scope in each build method).
  - `lib/features/chat/presentation/screens/ghost_settings_screen.dart:112,116,118-120` (formerly 112,116,121)
  - `lib/features/chat/presentation/widgets/chat_composer.dart:194-197` (formerly 196)
  - `lib/features/chat/presentation/widgets/message_bubble.dart:79,90,106` (formerly 80,91,106)
- **Design-token note (not a new gap, informational only)**: `gradientDream`/`gradientHot` are identical in both light and dark theme (never theme-overridden), while `colorText` flips between near-white (dark theme) and dark purple (light theme). `colorText` was chosen because it is the only existing exported token usable here without modifying `lib/design_system/**` (out of this phase's write scope), and it is visually identical to the prior `Colors.white` in the app's current default `ThemeMode.dark` (colorText dark = `0xFFF7EEFB`, near-white). Light theme is gated off by `CupidFeatureFlags.enableLightTheme` (default `false`) and not yet reachable in production. If light theme ships later, a dedicated theme-invariant "on-gradient" token in `CupidColorTokens` would be the correct long-term fix — flagged for the UI/UX Designer or Tech Lead, not actioned here (outside this phase's scope).
- **Verifying test**: `test/design_system/no_fork_guard_test.dart` ("AC 4 no-fork guard...") — passes; confirmed via the full suite (174/174) and via `flutter analyze lib test` (0 errors, 0 warnings).

### Final Gate Commands (re-run)

| Command | Result |
|---|---|
| `flutter test` | 174/174 passed |
| `flutter analyze lib test` | 32 issues, all `info`-level `prefer_initializing_formals`; 0 errors, 0 warnings — identical pre-existing pattern/count to the prior P5 pass |
| `flutter build apk --debug` | Succeeded — `build/app/outputs/flutter-apk/app-debug.apk` |
| `dart run build_runner build --delete-conflicting-outputs` | Ran; `git status --porcelain` afterward shows only this fix's own edited files (`main.dart`, the 3 chat files, `widget_test.dart`, `feature_flags_test.dart`) — no generated-code drift |

### Recommendation (updated)

All gates are green with no open blockers. Ready for the Reviewer gate.
