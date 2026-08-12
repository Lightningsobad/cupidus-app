# Retro-Audit: STORY-007 Chat (2-way typing-ghost, realtime)

Run Key: 2026-08-12:REQ-001:STORY-007:retro-audit
Independent requirement-authority audit against current `main`
(`f7d06fd4737cc7edbe6f6e33c205bf77fdf26f67`). Prior `review/review-report.md`
(`Outcome: CLEAN`) used as context only; all findings below are from direct
source/test inspection, not from re-reading and trusting that report.

## Method

Read `story_master.md`, `ux/uiux-spec.md` (§1-§6), `architecture/solution.md`
(§0-§6), `coding-plan/master-plan.md`, `coding-plan/test-results.md`,
`req_master.md`, `data/intake/bootstrap/conflicts_open_questions.md`,
`data/devops/system/design-fidelity-config.json`, and
`integration-review/mobile-visual-audit.md`. Cross-checked against current
source: `mobile/lib/features/chat/**`, `mobile/lib/core/database/tables/messages_table.dart`,
`mobile/lib/core/database/daos/message_dao.dart`, `mobile/lib/core/navigation/app_shell.dart`,
`backend/src/modules/messages/chat.gateway.ts`, and confirmed the claimed test
files exist: `mobile/test/features/chat/data/{chat_message_mapper_test.dart,chat_repository_test.dart}`,
`mobile/test/features/chat/presentation/{chat_cubit_test.dart,ghost_cubit_test.dart}`,
`mobile/test/core/database/message_dao_test.dart`, `mobile/test/core/navigation/app_shell_test.dart`.

**Limitation**: `flutter`/`dart` are not on `PATH` in this execution
environment, so the `174/174 flutter test` / `flutter analyze` / `flutter
build apk --debug` claims in `test-results.md` could not be re-run and
re-confirmed by direct execution here. Verification below is therefore
code-level (test file existence, assertion content, and source matching the
documented contract), not a fresh test-run confirmation.

## AC Verification

| AC | Text | Result | Evidence |
|---|---|---|---|
| AC1 | Send/receive text messages in real time | PASS | `chat_repository.dart:80-93` `send()` emits `sendMessage` over the socket only (never `POST /messages`), awaits the ack per ADR-013g, upserts the sender's own row from the ack or falls back to `resyncPageOne()`; `_handleInboundEvent`/`_handleNewMessage` (`chat_repository.dart:166-181`) upsert on `newMessage`. `chat.gateway.ts:29-37` confirms the backend contract this depends on (ack returns persisted `message`, fan-out to `receiverId` only, matching the "sender doesn't receive its own newMessage" architecture note). |
| AC2 | Typing-ghost indicator both directions within reasonable latency | PASS | `ghost_cubit.dart:26-28` declares `ghostOutboundThrottleDuration=120ms`, `ghostSenderIdleDuration=1200ms`, `ghostReceiverStaleExpiryDuration=6000ms`, matching `architecture/solution.md` ADR-013b table exactly. `draftChanged()` (`ghost_cubit.dart:186-210`) flushes immediately on any length decrease (deletion) and throttles otherwise; `_handleGhostTyping` (`:266-293`) re-arms the stale-expiry timer on every inbound event and derives struck-through content receiver-side via a length/prefix diff, matching the documented mechanic. Corresponding test file `test/features/chat/presentation/ghost_cubit_test.dart` exists. |
| AC3 | Message history on reopening (Drift read-through, server-authoritative) | PASS | `chat_repository.dart:66-70` `watchThread()` reads from `MessageDao.watchForPartner`. `message_dao_test.dart` (read directly) contains the exact assertions claimed: double-upsert-same-id leaves one row with the newer content (`:39-72`), ascending paged read across both conversation directions with correct limit/offset (`:76-129`). |
| AC4 | No local queued/offline send; sends require connectivity | PASS | `messages_table.dart:10-19` — schema has only `id/senderId/receiverId/content/type/status/readAt/createdAt/cachedAt`, no pending/queued/outbox/retry/sendState column. `message_dao_test.dart:186-209` asserts this programmatically by scanning `database.messages.$columns` for forbidden name fragments — a real regression gate, not just a doc claim. `chat_repository.dart` never retries or queues on `RealtimeNotLiveFailure`. |
| AC5 | Chat inaccessible to unpaired users | PASS | `chat_entry_gate.dart` gates `isUnlocked` on `partnerStore.partnerId != null`. `app_shell.dart:116-137` wraps the tab bar in `ChatEntryGate` and only inserts the Chat tab item `if (isUnlocked)`; `chatIndex` becomes `-1` when locked so the destination is unreachable, not merely hidden-but-routable. |

All 5 ACs independently confirmed PASS from current source, not from the
prior review's narrative.

## ADR / Guard Spot-Checks (independent, not re-trusting `test-results.md`)

- ADR-013a (attachments OUT): `chat_composer.dart` has no image/attachment
  icon, control, or picker call anywhere in the file — confirmed by direct
  read, not just the file's own doc comment. Matches `ux/uiux-spec.md` §3e's
  "remove, don't disable" instruction.
- ADR-013d (`markDelivered` never emitted): `message_bubble.dart` and
  `chat_repository.dart` show only a 2-state `done`/`done_all` tick logic
  (`message.status == 'seen'`); `chat_repository.dart` emits `markSeen` only.
  No `markDelivered` string appears in the read files.
- OQ4/ADR-007 (no offline queue): confirmed above via the schema-absence
  test, which is a stronger gate than a documentation claim.
- R8 (Socket.IO auth gap): confirmed still live in current
  `backend/src/modules/messages/chat.gateway.ts:39-49` — `handleConnection`
  has no real auth check (`// MOCK AUTH`), and `handleJoinRoom` trusts
  whatever `userId` the client supplies (`:51-60`, "SECURITY: Verify token
  matches userId" comment left unimplemented). This is unchanged from the
  gap `conflicts_open_questions.md` R8 describes, and the disposition
  recorded there (client sends `handshake.auth.token` per STORY-004,
  private-beta-only ship pending a backend decision) is still the accurate
  status. Not a new finding, not a regression — reiterated because it is the
  one item in this story with a genuine open production-readiness gate.

## OQ Discipline

No AC scope reduction in this story lacks a traceable authority:
- Attachments were conditionally in scope from the start
  ("if the backend `messages`/`uploads` contract supports them... do not
  assume beyond what the frozen contract exposes" — `story_master.md` §In
  Scope). Tech Lead's ADR-013a finding that the contract does not support
  them is a technical determination inside that pre-authorized condition, not
  a silent scope cut requiring a new central OQ entry.
- `markDelivered` non-emission, presence-dot omission (ADR-013c), and the
  `ghostset` header-overlay exception are all implementation/UX decisions
  documented in `architecture/solution.md` under Tech Lead's ADR authority,
  none of which touch a numbered AC's scope.
- No new "Open Question Triage" or "Approved Scope Change" section exists in
  `req_master.md` for this story, and none was needed — checked directly, not
  assumed absent.

## Design Fidelity

**UNVERIFIED** — `integration-review/mobile-visual-audit.md` captured only 10
of 37 design screens (`alarm`, `antighost`, `gallery`, `home`, `invite`,
`joincode`, `paired`, `pet`, `privacy`, `vibe`); neither `chat` nor `ghostset`
(this story's two screens per `ux/uiux-spec.md` §1) is among the 10 captured
or the 8 "captured, not yet reviewed" pairs. Per the reuse instruction, this
is marked UNVERIFIED, not PASS — no visual evidence either confirms or
contradicts the implementation's fidelity to `cupid-mobile-design/`'s `chat`
and `ghostset` screens. Given the audit's finding that other screens in this
requirement (`home`, and several 5-10x size-ratio screens) diverge
substantially from design, an unverified chat/ghostset pairing is a genuine
residual risk, not a formality — but it is a requirement-wide capture-tooling
gap (27 of 37 screens are currently uncapturable per the audit's own
recommendation #4), not evidence of a STORY-007-specific defect.

## Non-Blocking Observations (carried from `review-report.md`, independently plausible from source read, not re-verified line-by-line)

- `GhostConsentStore.optIn()`/`optOut()` writes the local flag before the
  server `PATCH` — a desync risk on `PATCH` failure, not exercised by a test.
- The `ghostset` header entry action in `app_shell.dart` is a documented
  `Stack` overlay exception (`:152-181`) pending the real Home dashboard;
  confirmed present and commented as intentional/temporary in current source.

## Summary

All 5 acceptance criteria are independently confirmed PASS against current
`main` source and existing tests, with the schema-absence test for AC4 being
a notably strong regression gate rather than a documentation-only guarantee.
No OQ-discipline violation was found. The one open item, R8's production
auth gap, is a pre-existing, already-tracked, non-blocking-for-this-story
condition, confirmed still accurate against current gateway code. The sole
gap versus a full audit is Design Fidelity, which is UNVERIFIED rather than
PASS or FAIL because this story's two screens were never in the visual
audit's capture scope — a REQ-001-wide tooling gap, not a story-specific
implementation defect.

Story-level Substantive Verdict: CLEAN
Classification Impact: AMBER
REVIEW_COMPLETE: YES
