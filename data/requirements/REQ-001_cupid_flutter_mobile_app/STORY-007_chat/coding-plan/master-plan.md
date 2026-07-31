# Master Coding Plan – STORY-007 Chat (2-way typing-ghost, realtime)

## 1. Planning Metadata

- Story ID: STORY-007
- Complexity: L (Story-Class `standard`)
- Planning Owner: Tech Lead
- Source Requirements: `../story_master.md`
- Source UX: `../ux/uiux-spec.md` (§3a-§3e, §4, §5, §6, §7, §8)
- Source Architecture: `../architecture/solution.md` (§2 Downstream Contract Summary, §4 ADR-013a-f, §4 Risk Surfaces)
- OQ Constraints Source: `../architecture/solution.md` §3 Open Question Constraints (OQ4/ADR-007, R8)
- Review Input: none yet
- Requirement Configuration Guide: `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md` — **NOT_APPLICABLE** for this story (no env var, secret, port, or third-party credential change)

## 2. Planning Goal

- Shared contract owner: Tech Lead (`core/database/` `MessageDao` seam + the ADR-013b timing constants)
- Contract-first phase required: YES — P0 produces the Drift seam every later phase consumes
- Parallel execution possible: NO — single mobile lane, strictly sequential P0 -> P5
- Critical path: P0 -> P1 -> P2 -> P3 -> P4 -> P5
- Parallelism notes: only one implementation lane exists (mobile). P3 and P4 both depend only on P2 and are logically independent, but they are kept sequential because P3 edits `chat_composer.dart` which P2 creates, and running two mobile specialists on the same feature directory has no safe write-scope split.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Connection Pattern | Producer Phase | Consumer Phase | Example Artifact / Payload |
|---|---|---|---|---|---|
| `CupidDatabase` + `MessageDao` (Drift, schemaVersion 1) | Tech Lead | direct call, `features/ -> core/` only | P0 | P1, P2, P5 | `messagesForPartner(partnerId, limit, offset)` -> ascending `List<MessageRow>` |
| `ChatRepository` | Tech Lead | `get_it` lazy singleton | P1 | P2, P3, P4 | `send(text)`, `watchThread()`, `loadOlder()`, `resyncPageOne()`, `markSeen()` |
| `RealtimeCoordinator` (frozen, STORY-004 §2) | Tech Lead (STORY-004) | barrel `core/realtime/cupid_realtime.dart` | consumed as-is | P1, P3 | `events(names: {'newMessage','ghostTyping','ghostStopTyping','messageSeen'})`; `emit('sendMessage', {...})` |
| `ResyncFetcher` closure wiring (ADR-013f) | Tech Lead | `getIt`-deferred closure in `service_locator.dart` | P1 | P1 | `resyncFetcher: () => getIt<ChatRepository>().resyncPageOne()` |
| Ghost timing constants (ADR-013b) | Tech Lead | shared const file | P3 | P3, P5 | throttle 120 ms; flush-on-delete; idle 1200 ms; receiver expiry 6000 ms |
| `ChatPartnerStore` (`partnerId`, `displayName`, `isGhostModeEnabled`) | Tech Lead | `SessionScopedStore` in `get_it` | P1 | P2, P3, P4 | populated from `GET /users/me` via raw `CupidApi.dio` |
| `CHAT_EVENTS` client mirror | Tech Lead | single constants file | P1 | P2, P3 | literal strings mirrored from `backend/src/modules/messages/chat.constants.ts` |

## 3A. Risk Surfaces And Verification Contract

| Risk Surface | Source Of Truth | Consumer Contract | Minimum Gate | Required Dependency | Blocker If Gate Cannot Run |
|---|---|---|---|---|---|
| Local persistence (ADR-007) | `core/database/cupid_database.dart` | `MessageDao` | Unit: double-upsert of the same server `id` yields one row; paged read returns ascending; schema grep proves no pending/queued/outbox column | P0 | AC3/AC4 unverified — stop and escalate |
| Realtime send/receive | `../architecture/solution.md` §2 | `emit()` / `events(names:)` | `bloc_test`: send-while-live appends from the `emit()` ack; send-while-offline throws `RealtimeNotLiveFailure`, draft retained, no queue written; `newMessage` appends and dedupes | P1, P2 | AC1/AC4 unverified — stop |
| Typing-ghost timing (AC2) | `../architecture/solution.md` §4 ADR-013b table | `GhostCubit` constants | Unit with fake clock: 120 ms throttle; immediate flush on content-length decrease; 1200 ms idle `stopTyping`; 6000 ms receiver stale expiry | P3 | AC2 unverified — stop |
| Read-receipt correctness | ADR-013d | `markSeen` only | Unit asserting `markDelivered` is never emitted | P2 | Receipt regression risk — stop |
| Ghost consent + privacy | ADR-013e | `GhostConsentStore` | Unit: composer ghost stays `off` until explicit local opt-in even when the server flag is `true`; ghost content never written to Drift or prefs | P3 | Privacy invariant unverified — stop |
| Pairing gate (AC5) | `GET /users/me`.`partnerId` | `ChatEntryGate` | Widget: `partnerId == null` -> chat destination absent and route unreachable | P4 | AC5 unverified — stop |
| Discoverability | `core/navigation/app_shell.dart` | `CupidTabBar` destination + chat-header `ghostset` action | Widget: chat reachable from the shell; `ghostset` reachable from the chat header; `Key('home_screen_ready_signal')` still pumps | P4 | Orphaned feature — stop |

## 4. Lane Summary

- Backend required: NO
- Frontend required: NO
- Mobile required: YES
- DevOps required: NO
- Initial implementation owner: Mobile Developer (P0)
- Final verification owner: Mobile Developer (P5)
- Shared contract owner: Tech Lead
- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (registry notes that `flutter run` needs a connected device and is interactive, so it is not started headlessly; readiness is the `Key('home_screen_ready_signal')` widget-test signal, which P4 must preserve), command/source runtime registry `mobile-app.buildCommand` = `flutter build apk --debug`, `testCommand` = `flutter test`

## 5. Phases Overview

The following table is mandatory. Keep all columns exactly as shown so Scrum
Master and implementation agents can route phases without guessing.

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P0 | Mobile Developer | Mobile | None | NO | `mobile/pubspec.yaml`, `mobile/lib/core/database/**`, `mobile/test/core/database/**` | `../architecture/solution.md` §2 (data model contract), §4 Risk Surfaces (Local persistence) | Drift dependency set + `CupidDatabase` (schemaVersion 1) + `messages` table + `MessageDao` with paged read and id-keyed upsert | unit (DAO paging + double-upsert dedupe + schema-absence assertion); `flutter analyze` | NOT_STARTED |
| P1 | Mobile Developer | Mobile | P0 | NO | `mobile/lib/features/chat/data/**`, `mobile/lib/core/di/service_locator.dart`, `mobile/test/features/chat/data/**` | `../architecture/solution.md` §2, §4 ADR-013d/ADR-013f, §4 Contracts And Integrations | `ChatPartnerStore`, `chat_events.dart` mirror, `ChatMessageMapper`, `ChatRepository` (Drift read-through + socket send + page-1 resync + `markSeen`), `ResyncFetcher` wiring | unit (mapper newest-first reversal, repository read-through, resync dedupe, no `markDelivered`); `flutter analyze` | NOT_STARTED |
| P2 | Mobile Developer | Mobile | P1 | NO | `mobile/lib/features/chat/presentation/chat_cubit.dart`, `mobile/lib/features/chat/presentation/chat_strings.dart`, `mobile/lib/features/chat/presentation/screens/chat_screen.dart`, `mobile/lib/features/chat/presentation/widgets/message_bubble.dart`, `mobile/lib/features/chat/presentation/widgets/chat_composer.dart`, `mobile/test/features/chat/presentation/chat_cubit_test.dart` | `../architecture/solution.md` §2; `../ux/uiux-spec.md` §3a, §3b, §3c, §3e, §5, §8 | Chat screen: thread, 2-state read-receipt tick, Drift-first history load with background reconcile and older-page paging, composer send, no-connectivity fail-fast, no attachment icon | unit + `bloc_test` (send live/offline, history reconcile, seen transition); widget (thread render, composer disabled on empty draft); `flutter analyze` | DONE (10/10 unit tests passed; `flutter analyze` scoped to touched files: 2 pre-existing-pattern info notices only, no new issue class) |
| P3 | Mobile Developer | Mobile | P2 | NO | `mobile/lib/features/chat/presentation/ghost_cubit.dart`, `mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart`, `mobile/lib/features/chat/presentation/widgets/ghost_bubble.dart`, `mobile/lib/features/chat/data/ghost_consent_store.dart`, `mobile/lib/features/chat/presentation/widgets/chat_composer.dart` (edit, created by P2), `mobile/test/features/chat/presentation/ghost_cubit_test.dart` | `../architecture/solution.md` §4 ADR-013b, ADR-013e; `../ux/uiux-spec.md` §3d, §4, §8 | 2-way typing ghost (throttle, delete-flush, idle, receiver stale expiry, struck-through deleted runs), 3-state ghost toggle, local opt-in consent gate, `ghostset` screen | unit + `bloc_test` with fake clock (all four ADR-013b constants); unit (consent gate blocks server-default-true); widget (`ghostset` three states); `flutter analyze` | DONE (43/43 `flutter test test/features/chat/` passed; `flutter analyze` scoped to touched files: 14 pre-existing `prefer_initializing_formals` info notices only, no new issue class) |
| P4 | Mobile Developer | Mobile | P2 | NO | `mobile/lib/core/navigation/app_shell.dart`, `mobile/lib/features/chat/presentation/chat_entry_gate.dart`, `mobile/test/core/navigation/app_shell_test.dart` | `../architecture/solution.md` §4 Risk Surfaces (Pairing gate, Discoverability); `../ux/uiux-spec.md` §2, §7 | `CupidTabBar` chat destination gated on `partnerId != null`, `ghostset` reachable from the chat header, `home_screen_ready_signal` preserved | widget (chat reachable, chat absent when unpaired, `ghostset` reachable, readiness key pumps); `flutter analyze` | DONE (4/4 `flutter test test/core/navigation/` passed; `test/features/home/` named in §6 verification command does not exist in this worktree, so only the existing `test/core/navigation/` suite ran; `flutter analyze` scoped to touched files: no issues found) |
| P5 | Mobile Developer | Mobile Verification | P0, P1, P2, P3, P4 | NO | `mobile/test/**` (lane-owned test files), `coding-plan/test-results.md` | phases P0-P4 `## 6. Test Scope`; `../architecture/solution.md` §4 Risk Surfaces | `coding-plan/test-results.md` with one row per risk-surface gate and per AC | full `flutter test`, `flutter analyze`, `flutter build apk --debug`; AC1-AC5 verification | NOT_STARTED |

The final phase must be a verification phase for `standard` and `complex`
stories. Tech Lead work is incomplete until that phase file exists.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-drift-foundation.md` |
| P1 | `phase-P1-chat-data-layer.md` |
| P2 | `phase-P2-chat-screen.md` |
| P3 | `phase-P3-typing-ghost.md` |
| P4 | `phase-P4-entry-point-and-gate.md` |
| P5 | `phase-P5-verification.md` |

Artifact hygiene:

- Each phase id in the table above maps to exactly one canonical
  `phase-Px-*.md` file.
- Do not leave duplicate files for the same phase id.
- Backend/frontend/mobile implementation phases must fit one specialist lifecycle
  (roughly six source/test files max) or be split.
- Implementation phase test scopes must not include backend e2e/test_e2e,
  Playwright/browser e2e, traces, or scenario reruns.

## 6. Risks And Notes

- Risks: see `../architecture/solution.md` §7. The three that most affect sequencing are (1) the sender never receives its own `newMessage`, so P2's bubble must come from the awaited `emit()` ack; (2) a lost `ghostStopTyping` requires P3's receiver stale expiry to be treated as mandatory, not polish; (3) `build_runner` codegen staleness, caught by `flutter analyze` in P5.
- OQ-driven constraints: OQ4/ADR-007 — **no offline write/outbox queue anywhere**. No phase may add a pending/queued/outbox/retry column, field, or code path. P0's schema-absence assertion is the enforcing gate.
- Scope decisions already made by Tech Lead that no phase may reopen:
  - Attachments are OUT (ADR-013a). P2 must **remove** the composer `image` icon rather than ship it disabled.
  - `markDelivered` is never emitted (ADR-013d). The read-receipt visual stays 2-state.
  - The header partner chip shows no presence dot or status line (ADR-013c).
  - The partner-unpaired-while-chatting edge case is dropped — the frozen `CHAT_EVENTS` set has no unpair event, so it can never fire.
  - P4 adds a `ghostset` entry point from the chat header. This is an explicit, documented Tech Lead exception to `../ux/uiux-spec.md` §2, which reserves that decision for Tech Lead/PO: the design source's Home dashboard `goGhostSet` tile does not exist yet (Home is still a placeholder screen), so without this action the `ghostset` screen would be orphaned. Revert to the Home tile when the real Home dashboard lands.
- Migration / rollout notes: Drift schemaVersion 1, no migration step. New dependencies require `flutter pub get` plus `build_runner`; commit the generated `*.g.dart`. Chat ships to non-production/private beta only while R8 stays open.
- Notes: `PendingEventStore` (`shared_preferences`) is deliberately left untouched even though Drift now exists — migrating it is STORY-004's deferred F5 item and would put already-verified realtime code back in scope.
