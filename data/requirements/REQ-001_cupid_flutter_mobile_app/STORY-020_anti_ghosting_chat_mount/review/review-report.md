# Review Report: STORY-020 — Anti-Ghosting Chat Mount

Reviewer: Iris-QC (compact story review, Tier 1)
BaseHead: 1bd16e41be61f307796ab79e80e2e89e03fc6bc0

## Scope Gate (inline)

- Changed files: `mobile/lib/features/chat/presentation/screens/chat_screen.dart`,
  `mobile/lib/preview/preview_session_bootstrap.dart`,
  `mobile/test/features/chat/presentation/chat_screen_ghost_state_row_mount_test.dart`
  (new). Exactly 3 files, matches the Tier 1 compact gate.
- No migration, auth-contract, payment, external-integration, prod-runtime,
  or multi-lane-contract risk present. `req_master.md` is unmodified at this
  `BaseHead` (its top-level `M` status predates this handoff). `story_master.md`
  untouched. Confirmed Tier 1 is the correct gate.

## 1. Diff vs. plan

`chat_screen.dart`: `GhostStateRow(partnerId: widget.partnerId!)` is inserted
as a new `Column` child guarded by `if (widget.partnerId != null)`, strictly
between the `GhostBubble` `BlocBuilder<GhostCubit, GhostState>` and the
`ChatComposer` `BlocBuilder<GhostCubit, GhostState>` (lines 198-221 of the
current file). `partnerId` is threaded as a new nullable field on `_ChatView`,
sourced from `partnerStore.partnerId` in `ChatScreen.build` — no other
`ChatScreen` call site changes. `MultiBlocProvider` (lines 47-64) still
declares only `ChatCubit` and `GhostCubit`; no `GhostStormCubit` provider was
added, satisfying the AC4/architecture §4 "duplicate storm poll" guardrail.
Import is via the barrel (`anti_ghosting.dart`), not the widget file directly,
per plan.

`preview_session_bootstrap.dart`: matches the §7 grant exactly. The new
`POST /auth/login` → `BackendUserIdStore.updateFromLoginResponse` →
`ChatPartnerStore.refreshFromServer()` sequence sits after the existing
Firebase sign-in and, critically, after the `email.isEmpty || password.isEmpty`
early return — i.e. inside the existing credential guard as required. It is
wrapped in `try`/`catch` with a non-fatal `debugPrint`, matching the
catch-and-continue requirement. No forbidden file was touched (diff confirmed
scoped to this one file only); no `/auth/register` fallback; no new `getIt`
registration; no new dependency.

## 2. Acceptance criteria vs. test evidence

Read the 5 test cases directly in `chat_screen_ghost_state_row_mount_test.dart`
rather than trusting the pass count:

- **AC1 (seam ordering)**: eligible storm body + fired `ghostTyping` event;
  asserts `GhostStateRow` height `> 0`, `row.top >= bubbleBottom`,
  `row.bottom <= composerTop`, plus the seen/no-reply text and CTA text are
  present. Assertions match the phase file's ordering requirement.
- **AC2 (idle zero-cost)**: two-harness comparison — an unpaired baseline
  (`partnerId: null`) captures the pre-row `ChatComposer` rect; the mounted,
  non-eligible harness asserts `GhostStateRow` is present but height `0`, both
  copy strings absent, and `ChatComposer`'s rect is unchanged from baseline.
  This is a legitimate proxy for "no layout cost when idle" given the row is
  conditionally mounted only on `partnerId`, not on storm state.
- **AC2 (unregistered locator)**: extra case beyond the phase's 4 baseline ACs,
  covering the architecture §4 "compatibility posture" — row mounts, zero
  height, no copy, zero storm requests, no exception. Correctly additive, not
  a substitute for the phase AC2 case above.
- **AC3 (unpaired leak)**: `partnerId: null` — `findsNothing` for
  `GhostStateRow` (absent from tree, not just collapsed) and zero storm
  requests. Matches.
- **AC4 (duplicate storm poll)**: exactly one `BlocProvider<GhostStormCubit>`
  found and exactly one `GET /ghost-config/storm-status/partner-1` request
  issued. This is the runtime counterpart to the static `MultiBlocProvider`
  check in §1 above. Matches.

All 4 phase acceptance criteria (`coding-plan/phase-P1-mobile-chat-ghost-state-mount.md`
§4) are each covered by an assertion whose wording matches the AC, not merely
by a passing test count. `test-results.md`'s assertion summary accurately
describes what the test file actually does.

## 3. Visual fidelity — independently verified against the PNGs

Viewed both captures directly.
`implemented-chat-eligibleStorm-emulator-5554.png` shows the amber timer icon,
"Đã xem, chưa trả lời" caption, and pink "Bắn Emoji Storm" pill in a single
band sitting between the last message bubble and the composer/input bar — no
other layout element moved.
`implemented-chat-noEligibleState-emulator-5554.png` shows the identical
message thread, privacy chip, and composer with no icon, caption, pill, or
extra spacing at that seam — the composer sits directly under the last bubble
in visually the same position as in the eligible capture. Both claims in
`visual-fidelity-report.md` (placement between message area and composer;
no row artifact when non-eligible) are confirmed by direct inspection, not
just the report's own pixel-diff table.

## 4. Story AC (story_master.md AC1)

The combined evidence closes the exact RED-PATCH gap: `GhostStateRow` is now
imported and referenced in `chat_screen.dart` (not merely built/tested in
isolation as STORY-008 left it), the mount is exercised by 5 passing widget
tests plus 110/110 unaffected regression tests, and two live-emulator captures
confirm the running-app rendering STORY-008's ADR-3 deferred. AC1 is fully
satisfied.

The STORY-018 chat-coverage follow-up noted in both `solution.md` §7 and
`visual-fidelity-report.md` is correctly flagged as out of this story's scope
and does not affect this verdict.

## Findings

None. No patch-required items identified.

## Outcome: CLEAN
