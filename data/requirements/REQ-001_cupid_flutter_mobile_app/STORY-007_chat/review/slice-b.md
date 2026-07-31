# STORY-007 Reviewer Slice Report — slice "P1-P5 remaining diff"

- Reviewer: Iris-QC (scoped-slice)
- Scope: full remaining diff not covered by `review/slice-a.md` — P1 (chat
  data layer), P2 (chat screen), P3 (typing ghost / consent), P4 (app_shell
  wiring, chat entry gate), P5 (verification + DI-bootstrap/no-fork-guard
  follow-up fix).
- Worktree HEAD: `8a6704450f45b8a951e9f33bcecf60c58d443855`

## 0. BaseHead discrepancy (process note, not a code defect)

The handoff's declared `BaseHead`/`RunState.review_base_head` is
`e888fe23b0ca0d382a8b8c76c6525ba08227d354`. That commit already sits *after*
P0-P4 (`git log e888fe23..HEAD` shows only the final P5 follow-up commit
`656ff52`), so a literal `git diff e888fe23 HEAD` would show almost none of
this slice's assigned scope (P1-P4 would be invisible). The actual
merge-base with the integration branch — and the `BaseHead` slice-a
genuinely used — is `0a467d03babf1ed4102c3fab09c61b2dec941a0b`
(`git merge-base HEAD codex/REQ-001_cupid_flutter_mobile_app-integration`).
I used `0a467d03` as the effective baseline so this review actually covers
P1-P5 as instructed. Recommend Scrum Master correct the `BaseHead` field
convention for story-review handoffs (or the run-file generator) so it
always resolves to the story's true merge-base, not an intermediate
in-story commit.

## 1. P1 — Chat data layer — PASS

Files: `chat_repository.dart`, `chat_partner_store.dart`, `chat_events.dart`,
`chat_message_mapper.dart`, `service_locator.dart` (resyncFetcher wiring),
`core/realtime/cupid_realtime.dart`, `core/realtime/realtime_coordinator.dart`
(ADR-013g), plus their tests.

- `ChatRepository.send()` awaits `coordinator.emit(sendMessage, ...)`; a
  `Map` ack is mapped and upserted directly (sender's own bubble, since
  `newMessage` only fans out to `receiverId`); a non-`Map`/`null` ack
  triggers exactly one `resyncPageOne()` and writes no fabricated row —
  matches ADR-013g consumer rules and AC1/AC4 exactly.
- `markSeen()` only ever emits `ChatEvents.markSeen`; grepped/read
  `chat_events.dart` and `chat_repository.dart` in full — no `markDelivered`
  literal anywhere (ADR-013d).
- `ChatPartnerStore` uses raw `Dio` (documented, matches the
  `auth_repository.dart` precedent) and implements `clearOnSignOut`
  (AC4-adjacent sign-out teardown).
- `RealtimeCoordinator.emit`/`RealtimeCoordinatorImpl.emit` diff exactly
  matches ADR-013g §"Amended" text: return type widened `Future<void>` ->
  `Future<Object?>`, a bounded `realtimeAckTimeout` (5s) wraps
  `_socket.emit(...)`, `TimeoutException` is caught and logged (not
  rethrown), `RealtimeNotLiveFailure` still throws first. `SocketTransport`,
  `fcm_transport.dart`, `pending_event_store.dart` are untouched — the
  ADR-013g write-scope extension (`architecture/solution.md` §4) was
  respected exactly (no writes to files outside its explicit list).
- `service_locator.dart`'s `resyncFetcher: () => getIt<ChatRepository>()
  .resyncPageOne()` closure matches ADR-013f (deferred `getIt` resolution,
  breaking the `RealtimeCoordinator`<->`ChatRepository` circular
  dependency); `MessageDao`/`ChatPartnerStore` are registered as
  session-scoped stores for sign-out teardown.
- Spot-checked `chat_repository_test.dart`'s fake coordinator: its ack/
  not-live semantics mirror `RealtimeCoordinatorImpl` exactly (status
  checked before the emit call is recorded).

## 2. P2 — Chat screen — PASS

Files: `chat_cubit.dart`, `chat_strings.dart`, `screens/chat_screen.dart`,
`widgets/message_bubble.dart`, `widgets/chat_composer.dart`.

- `ChatState.showEmptyState` is gated on `hasCompletedInitialFetch &&
  messages.isEmpty` — matches `ux/uiux-spec.md` §3c's "never during the
  initial fetch itself" rule.
- Cold-open behavior renders whatever Drift already has via
  `watchThread()` immediately, with `resyncPageOne()` reconciling in the
  background — no spinner/empty-flash, matches §3c.
- Auto-scroll (`_maybeAutoScrollToBottom`) only jumps when the count grew
  and the user was already pinned to the bottom (within 48px) — matches
  §3c's "keep scroll offset unless already pinned" rule.
- `sendPressed` only clears the composer draft on `true` (success); a
  `RealtimeNotLiveFailure` keeps the draft and sets
  `showNetworkUnavailableError`, surfaced via the existing
  `NetworkUnavailableFailure`/`auth_failure_text.dart` copy, not new
  offline wording — matches §5 exactly (no optimistic bubble that later
  disappears, no queued-send affordance).
- `MessageBubble`'s read-receipt tick is strictly 2-state
  (`done`/`done_all` derived from `status == 'seen'`) — matches ADR-013d
  and §3b; no third "delivered" visual exists.
- `ChatComposer` has no attachment/image icon anywhere (ADR-013a §3e
  outcome 2, "removed, not shipped disabled") — confirmed by direct
  reading, not just the P5-cited grep.
- Accessibility: `MessageBubble` combines sender/content/timestamp/seen
  into one `Semantics` node with `excludeSemantics: true` on children
  (§8); ghost on/off transitions announce `assertive` via
  `BlocListener<GhostCubit>` gated on `consentLevel` changes excluding
  `pending` (§8's "meaningful transitions only" rule).

## 3. P3 — Typing ghost / consent — PASS

Files: `ghost_cubit.dart`, `screens/ghost_settings_screen.dart`,
`widgets/ghost_bubble.dart`, `data/ghost_consent_store.dart`,
`widgets/chat_composer.dart` (ghost toggle + warning row).

- All four ADR-013b constants are wired exactly as specified: 120ms
  trailing-edge throttle (`ghostOutboundThrottleDuration`), immediate flush
  on any content-length *decrease* (`isDeletion` branch bypasses the
  throttle), 1200ms sender idle -> `stopTyping`
  (`ghostSenderIdleDuration`), 6000ms receiver stale expiry
  (`ghostReceiverStaleExpiryDuration`). Verified directly against
  `ghost_cubit_test.dart`'s fake-clock assertions (all four groups present
  and asserting the exported constants, not duplicated literals).
- Deleted-run diffing (`_handleGhostTyping`) is receiver-side only, exactly
  as ADR-013b specifies (`content.length < previous.length &&
  previous.startsWith(content)` -> `struck` = removed tail) — no backend
  deletion signal is assumed.
- ADR-013e consent state machine: `_recomputeConsentLevel()` requires both
  `_hasLocalOptIn` (device-local, from `GhostConsentStore`) AND
  `_serverFlagEnabled` (from `ChatPartnerStore.isGhostModeEnabled`) to be
  true before considering `pending`/`on` — a server-default-`true` flag
  with no local opt-in stays `off`, matching the "informed consent cannot
  come from a server default" decision exactly. `toggleTapped()` is a
  no-op while already `on` (composer never re-toggles off in-place, per
  §3d "same button doubles as accept").
- Ghost content never touches Drift or `shared_preferences` — confirmed by
  reading `ghost_cubit.dart` in full (no Drift/Dao import, no prefs call)
  and `ghost_consent_store.dart` (only ever writes the boolean
  `cupid_ghost_local_opt_in_v1` key). `ghost_cubit_test.dart`'s
  no-persistence guard group independently confirms this via a real
  `SharedPreferences` fake.
- `GhostBubble`'s visual treatment matches §3d precisely: dashed purple
  border + tinted fill (not a plain message bubble), blinking cursor via
  `AnimationController`, struck-through tail fading 100%->45% opacity over
  `ghostBubbleFadeDuration` (1300ms, matches `ghostFade`). Declared
  `liveRegion: true` (polite, not assertive) on the per-keystroke draft —
  matches §8's "polite, not assertive" rule; on/off transitions are
  announced assertively elsewhere (`chat_screen.dart`), not by this
  widget, avoiding double-announcement.
- `ghost_settings_screen.dart`'s partner column always reads
  "waiting"/"unknown" copy, never a definite "off" — matches ADR-013e's
  "absence is ambiguous" rule and the phase file's own required check.
- No raw `Colors.`/`Color(0x` literal found in `ghost_settings_screen.dart`,
  `chat_composer.dart`, or `message_bubble.dart` on direct reading — the P5
  follow-up fix's token-based replacement (`colors.colorText`,
  `colors.colorAccentPurple`, etc.) is present exactly where
  `test-results.md` §Blocker 2 says it landed, and no other raw literal
  exists in any P1-P4 file I read in this slice.

## 4. P4 — Entry point + gate — PASS

Files: `chat_entry_gate.dart`, `app_shell.dart`, plus
`test/core/navigation/app_shell_test.dart`.

- `ChatEntryGate` depends only on `ChatPartnerStore` — no import of any
  pairing/STORY-005 source file (confirmed by direct reading, and
  independently re-asserted by `app_shell_test.dart`'s "STORY-005
  pairing-source isolation guard" group, which greps both
  `chat_entry_gate.dart` and `app_shell.dart` for `pairing`/`STORY-005`/
  `features/pairing`).
- `AppShell` gates the `Chat` tab item on `isUnlocked` (from
  `ChatEntryGate`); the tab bar shows exactly 1 item when unpaired, 2 when
  paired — matches AC5.
- `_AppShellState`'s `late final` `getIt<...>()` resolutions for
  `_chatRepository`/`_coordinator`/`_backendUserIdStore`/`_consentStore`
  are only forced when the Chat tab (`safeIndex != 0`) actually builds —
  confirmed by reading the `build()` method's `body` ternary. This is
  exactly the property `test-results.md`'s Blocker-1 fix relies on to keep
  `widget_test.dart`/`feature_flags_test.dart` passing while registering
  only `ChatPartnerStore` in `getIt`, since neither test navigates to the
  Chat tab.
- `Key('home_screen_ready_signal')` reachability (Discoverability risk
  surface) is preserved — confirmed present in `HomeScreen` usage path and
  asserted by both `app_shell_test.dart` (paired + unpaired) and the P5-fix
  `widget_test.dart`/`feature_flags_test.dart`.
- The `ghostset` entry action (`Key('ghost_settings_entry_action')`) is
  wired as a `Positioned` overlay atop `ChatScreen` inside the Chat tab's
  `Stack`, not literally inside `CupidHeader`. This is looser than the
  phrase "reachable from the chat header" in `master-plan.md` §6/§3A might
  suggest, but it is the explicit, documented Tech Lead exception in
  `master-plan.md` §6 ("P4 adds a ghostset entry point from the chat
  header... Revert to the Home tile when the real Home dashboard lands")
  and the risk-surface gate only requires *reachability*, which
  `app_shell_test.dart`'s tap-through assertion (`ghost_settings_entry_
  action` -> `GhostSettingsScreen`) directly verifies. Not a defect;
  flagging only so the documented follow-up (move to the real Home tile)
  isn't lost.

## 5. P5 — Verification + follow-up fix — PASS

Files: `main.dart`, `test/widget_test.dart`, `test/app/feature_flags_test.dart`
(already covered under P4 discoverability above), plus
`coding-plan/test-results.md` narrative cross-checked directly against the
diff.

- `main.dart` now calls `setupServiceLocator()` before `runApp(const
  CupidApp())` — confirmed by direct reading; matches every other
  DI-bootstrap entrypoint in the codebase, resolving Blocker 1 exactly as
  `test-results.md` describes.
- `test-results.md`'s narrative (174/174 `flutter test`, `flutter analyze
  lib test` 0 errors/0 warnings, `flutter build apk --debug` succeeded,
  `build_runner` no-op) is internally consistent with the diff actually
  present — I did not re-run the Flutter toolchain myself (out of this
  review's tool scope), but every specific code claim in the P5 sections
  (DI bootstrap fix, the 3 files' raw-`Colors.` replacements, the
  `getIt.reset()`/`pumpAndSettle()` pitfalls) matches what the diff
  actually shows.

## 6. Non-blocking observations (no fix required for this slice)

1. `GhostConsentStore.optIn()`/`optOut()` writes the local
   `shared_preferences` flag *before* the `PATCH /users/me` call. If the
   PATCH throws (e.g. `DioException`), the local flag and the server flag
   are left out of sync for that session (local says opted-in, server
   still `false`, or vice versa) until the next successful call. Neither
   ADR-013e nor any AC mandates transactional ordering here, and no test
   currently exercises the PATCH-failure path. Worth a follow-up test/fix
   if this proves to matter in practice, not a blocker.
2. The `ghostset` header action is a `Stack` overlay rather than a true
   `CupidHeader` action slot (see §4 above) — already flagged as a
   pre-existing, documented, intentional Tech Lead exception with its own
   revert-when-Home-lands note; restating here only so it stays visible
   at the review gate.

## Outcome

- P1 (chat data layer): PASS
- P2 (chat screen): PASS
- P3 (typing ghost / consent): PASS
- P4 (entry point + gate): PASS
- P5 (verification + follow-up fix): PASS
- No AC, ADR, or UX-spec violation found across the full P1-P5 diff. The
  two non-blocking observations in §6 do not block this slice.

Outcome: CLEAN

REVIEW_SLICE_COMPLETE: YES
