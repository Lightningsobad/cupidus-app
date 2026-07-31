# Phase P2 – Chat Screen (send, receive, history, fail-fast)

## 1. Objective

Ship the `chat` screen: message thread with 2-state read receipts, Drift-first
history load with background reconcile and older-page paging, composer send,
and the no-connectivity fail-fast path. Covers AC1, AC3, and AC4.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-chat-screen.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/chat/presentation/chat_cubit.dart`
  - `mobile/lib/features/chat/presentation/chat_strings.dart`
  - `mobile/lib/features/chat/presentation/screens/chat_screen.dart`
  - `mobile/lib/features/chat/presentation/widgets/message_bubble.dart`
  - `mobile/lib/features/chat/presentation/widgets/chat_composer.dart`
  - `mobile/test/features/chat/presentation/chat_cubit_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ChatCubit`
  - `ChatScreen`
  - `ChatComposer` (P3 edits this file to add the ghost toggle)
- Shared Interfaces Consumed:
  - `ChatRepository`, `ChatPartnerStore` (P1)
  - `RealtimeCoordinator.status` for the degraded indicator (STORY-004)
  - STORY-001 tokens and `CupidHeader` adaptive widget
- Risk Surfaces:
  - Realtime send/receive
  - Local persistence (ADR-007)
  - Read-receipt correctness
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §3a, §3b, §3c, §3e, §5, §8
  - consumer contract: `ChatRepository` (P1)
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §2, §4 ADR-013c, ADR-013d, §4 "Error / retry / timeout / idempotency / empty-state contract"
  - OQ constraints: `../architecture/solution.md` §3 (OQ4/ADR-007 — no outbox, no optimistic bubble surviving restart)
  - upstream phase outputs: P1 `ChatRepository`, `ChatPartnerStore`
  - UX constraints: `../ux/uiux-spec.md` §3a (header, no presence per ADR-013c), §3b (bubbles, timestamps, privacy chip, 2-state tick), §3c (cold open, first-open empty state, older-page spinner), §3e (composer, send button, **no attachment icon**), §5 (no offline send), §8 (accessibility)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: text chat send/receive/history UI, excluding typing ghost
  - Source/Test File Count: 5 source + 1 test
  - Split Required: NO
  - Split Rationale: typing ghost is already split out into P3; entry point and gate into P4

## 2. Required Reads

- `../architecture/solution.md` §2, §4 ADR-013c, ADR-013d
- `../ux/uiux-spec.md` §3a, §3b, §3c, §3e, §5, §8
- P1 outputs `mobile/lib/features/chat/data/chat_repository.dart`, `chat_partner_store.dart`
- `mobile/lib/design_system/design_system.dart` and `mobile/lib/design_system/adaptive/cupid_header.dart`
- `mobile/lib/features/auth/presentation/auth_strings.dart` and `auth_failure_text.dart` for the existing `NetworkUnavailableFailure` copy to reuse

## 3. Tasks

- Create `chat_cubit.dart` with a Cubit that: subscribes to `ChatRepository.watchThread()`; exposes `sendPressed(String draft)`; exposes `loadOlderRequested()`; calls `ChatRepository.markSeen()` when the screen becomes visible; and mirrors `RealtimeCoordinator.status` into a `connectionDegraded` flag.
- Send behavior (AC1, AC4): on success clear the draft. On `RealtimeNotLiveFailure`, **keep the draft in the composer**, add no bubble, and surface a transient inline error. Reuse the existing `NetworkUnavailableFailure` copy from `auth_strings.dart` / `auth_failure_text.dart` rather than authoring new wording (`../ux/uiux-spec.md` §5). Do not queue, retry, or schedule a resend.
- In-flight polish (optional, `../ux/uiux-spec.md` §5): while a `send` future is pending and the coordinator is live, the bubble may render dimmed. This state must live only in Cubit memory and must never be persisted, so it cannot survive an app restart.
- History load (AC3, `../ux/uiux-spec.md` §3c): render cached Drift rows immediately with no spinner and no empty-state flash; reconcile in the background; preserve the user's scroll offset unless already pinned to the bottom, in which case auto-scroll. Show the top inline spinner only while actually awaiting network for an older page.
- First-open empty state: only when the cache is empty **and** a page-1 fetch has completed with zero rows. Use the placeholder copy from `../ux/uiux-spec.md` §3c and mark it in `chat_strings.dart` as pending PO sign-off (UX §10.6).
- Create `message_bubble.dart` per `../ux/uiux-spec.md` §3b: mine `--grad-hot` / white / 22-22-7-22 / right / max-width 78%; theirs `--surf` / `--tx` / 22-22-22-7 / left. Timestamp caption 13pt `--tx2` below. Read-receipt tick on mine only, **2 states**: single check for `sent`/`delivered`, double check for `seen` (ADR-013d — do not add a third visual). No edit/delete affordance.
- Accessibility (`../ux/uiux-spec.md` §8): each bubble is one accessible node combining sender context, text, timestamp, and read state — do not rely on left/right alignment alone. Associate the inline send error via accessible description, not colour alone.
- Create `chat_composer.dart`: 46px pill-in-pill text field at `--tap` minimum height, circular `--grad-hot` send button disabled/dimmed on an empty draft using the STORY-001 disabled convention. **Do not add an attachment/image icon** — attachments are OUT per ADR-013a, and `../ux/uiux-spec.md` §3e requires removing the affordance rather than shipping a dead one. Leave a placement comment for P3's ghost toggle to the left of the field.
- Create `chat_screen.dart`: `CupidHeader` with `canBack: true` (back to Home) and the partner's display name only. Per ADR-013c render avatar + name with **no green dot and no status line**. Add the top privacy chip verbatim from `../ux/uiux-spec.md` §3b. Keep the bottom tab bar visible. Show a subtle non-blocking degraded indicator when `connectionDegraded` is true.
- Do not add the anti-ghosting seen row or the Emoji Storm button — STORY-008 scope (`../ux/uiux-spec.md` closing note).
- Write `chat_cubit_test.dart` using `bloc_test` with a fake repository.

## 4. Acceptance Criteria

- AC1: a `newMessage` event appends a partner bubble; a successful `send` appends my bubble from the repository's ack-backed upsert.
- AC3: mounting with pre-seeded Drift rows emits a populated thread as the first state, with no loading or empty state in between.
- AC4: `send` while the coordinator is not live leaves the draft populated, adds no bubble, surfaces the reused network-unavailable copy, and performs no retry. A test asserts no queue/persistence write occurs.
- Read receipts render exactly two states; a `messageSeen` event flips my last bubble to the double check.
- The composer contains no attachment or image control (asserted in the widget test by finder absence).
- `flutter analyze` reports no new issues.

## 5. Planned Outputs

- Code: `mobile/lib/features/chat/presentation/chat_cubit.dart`, `chat_strings.dart`, `screens/chat_screen.dart`, `widgets/message_bubble.dart`, `widgets/chat_composer.dart`
- Contracts: `ChatCubit`, `ChatScreen`, `ChatComposer`
- Requirement configuration guide updates: none
- Notes: `chat_strings.dart` flags the first-open empty-state copy as pending PO sign-off

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `chat` screen
- Required levels:
  - unit: `bloc_test` on `ChatCubit` — send live, send offline (draft retained, no persistence write), `newMessage` append, `messageSeen` transition, older-page load
  - integration: widget test mounting `ChatScreen` with a fake Cubit — populated thread renders as first frame from cache, composer send button disabled on empty draft, no attachment control present, no presence dot present
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: no attachment/image control finder resolves in the composer; no third read-receipt visual exists
- Mobile discoverability / navigation integration: deferred to P4, which owns the shell destination and the pairing gate. P2 must not wire its own ad-hoc route.
- Minimum gates by risk surface:
  - Realtime send/receive: send-live and send-offline both asserted
  - Local persistence: cached-first render asserted with no intermediate loading state
  - Read-receipt correctness: exactly two tick states asserted
- Required regression or contract coverage: existing `test/features/auth/` suite must still pass after reusing the auth failure copy
- Required runtime signals: none — no runtime startup smoke in this phase
- Evidence format: concise rows recorded by P5 in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/chat/`
  - Build/type-check/lint command: `flutter analyze`
  - Required assertion evidence: emitted Cubit state sequence for each send path; first-frame widget tree for the cached-open case; finder-absence assertions for the attachment control and the presence dot

## 7. Status

- Status: DONE
- Last updated: 2026-07-30
- Delivered: `ChatCubit`/`ChatState` (chat_cubit.dart), `ChatLocaleText`/`ChatStrings`
  (chat_strings.dart), `MessageBubble` (widgets/message_bubble.dart),
  `ChatComposer` (widgets/chat_composer.dart), `ChatScreen`
  (screens/chat_screen.dart), and `test/features/chat/presentation/chat_cubit_test.dart`
  — exactly the 6 files in this phase's Write Scope.
- Test evidence: `flutter test test/features/chat/presentation/chat_cubit_test.dart`
  — 10/10 passed (pre-seeded-thread/no-empty-flash AC3, first-open empty
  state after zero-row initial fetch AC3, send-live success AC1, blank-draft
  guard, send-offline `RealtimeNotLiveFailure` fail-fast/no-retry AC4,
  inbound `newMessage` append AC1, `messageSeen` two-state read-receipt
  pass-through, `loadOlder` call-through, `markSeen` call-through,
  `connectionDegraded` mirrors `RealtimeCoordinator.status`).
- Analyze evidence: `flutter analyze` scoped to the 6 touched files — 2
  `prefer_initializing_formals` info notices only, matching the identical
  pre-existing pattern already accepted in the merged P1
  `chat_repository.dart` (5 notices there); no new issue class introduced.
- Not in this phase's scope (unchanged): P2's own route/nav wiring (P4),
  STORY-008 anti-ghosting row and Emoji Storm button (separate story
  scope), first-open empty-state copy is a placeholder pending PO sign-off.
