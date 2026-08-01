# STORY-008 Review — Slice B (P2 home entry card + P3 chat ghost-state row)

Reviewer: Iris-QC (parallel slice review)
RunId: RUN-REQ-001_cupid_flutter_mobile_app-STORY-008-reviewer-slice-b
BaseHead: 0a467d03babf1ed4102c3fab09c61b2dec941a0b
Worktree HEAD reviewed: 737271322a83a736890e6af0b47af88839307b86
Scope: Phase P2 (home entry card) + Phase P3 (chat ghost-state row / storm cubit) only.
Slice A (contract/data layer, lifecycle settings screen) is out of scope for this
report; a separate reviewer covers it and a final-synthesis pass merges both.

## Files Reviewed (diff against BaseHead)

- `mobile/lib/features/anti_ghosting/presentation/widgets/anti_ghost_entry_card.dart`
- `mobile/lib/features/anti_ghosting/anti_ghosting.dart`
- `mobile/lib/features/home/presentation/home_screen.dart`
- `mobile/test/features/anti_ghosting/presentation/anti_ghost_entry_card_test.dart`
- `mobile/lib/features/anti_ghosting/presentation/ghost_storm_cubit.dart`
- `mobile/lib/features/anti_ghosting/presentation/widgets/ghost_state_row.dart`
- `mobile/test/features/anti_ghosting/presentation/ghost_storm_cubit_test.dart`
- `mobile/test/features/anti_ghosting/presentation/ghost_state_row_test.dart`
- `mobile/test/widget_test.dart` (regression check — confirmed unchanged, 0 diff
  against BaseHead)

## P2 — Home Entry Card Findings

- `home_screen.dart` diff is additive in effect: the pre-existing
  `Center(child: Text(key: Key('home_screen_ready_signal')))` subtree is
  preserved byte-for-byte, now wrapped in `Expanded` inside a new `Column`
  alongside the new `AntiGhostEntryCard`. No existing widget removed, renamed,
  or given different content. `widget_test.dart` itself has zero diff against
  BaseHead, consistent with the phase file's claim that it passes unchanged.
- `AntiGhostEntryCard` renders all four UX §2.1 subtitle states (not-set-up,
  active `{min} · {penalty}`, pending-mine, pending-partner), hides entirely
  for `AntiGhostPairingRequired` (AC3 defence in depth), and routes to
  `AntiGhostScreen()` on tap without itself branching on `proposedBy` — the
  card's own doc comment explains this is intentional (the screen resolves
  state A/B/C/D from the same live data), and
  `anti_ghost_entry_card_test.dart` proves the partner-proposed case lands on
  the Accept/Decline review UI end-to-end through the real tap, not by
  asserting the card's internal routing logic. This is consistent with the
  phase's stated design and is adequately covered.
- get_it guard (`isRegistered` check before building the cubit) is a
  documented, deliberate workaround for the pre-existing
  `setupServiceLocator()` boot-path gap, not silent scope creep; test covers
  both branches implicitly (repository always registered in test setup).
- Design-system no-fork guard: card uses `CupidIcon`, `context.cupidColors`,
  `context.cupidType`, `context.cupidPlatform.tapTarget` throughout — no
  `Icons.` reference, no raw `Color(...)` literal.
- Tap target uses `context.cupidPlatform.tapTarget` (platform token), not a
  conditional — matches AC.
- Barrel `anti_ghosting.dart` exports `AntiGhostEntryCard` and (added by P3)
  `GhostStormCubit`/`GhostStateRow`, matching the cross-story contract summary
  in master-plan.md §3.
- `anti_ghost_card_not_set_up_subtitle` ARB key (flagged in the phase file as
  a deviation from declared write scope) is present with both `en` and `vi`
  values — verified directly in `app_en.arb`/`app_vi.arb`.

## P3 — Chat Ghost-State Row / Storm Cubit Findings

- `GhostStormCubit` fetches on construction, exposes an external `refresh()`,
  and drives a single 60s periodic timer via an injectable
  `GhostStormPollTimerFactory` seam. `handleAppLifecycleState` restarts the
  timer + refetches only on `resumed`, cancels on any other state; `close()`
  cancels the timer. `ghost_storm_cubit_test.dart` covers fetch-on-start,
  timer-starts-at-60s, refresh() re-fetch, tick-triggers-fetch,
  background-cancels-timer, cancelled-timer-fire-is-no-op, resume-restarts,
  and close()-cancels — this fully satisfies the "Storm polling lifecycle"
  BLOCKER gate in master-plan.md §3A.
- `GhostStateRow` owns its `GhostStormCubit` via `get_it`, takes only
  `partnerId` in its constructor (no chat-module type dependency, matching
  the ADR-3 mount-seam contract), and registers a `WidgetsBindingObserver` to
  forward lifecycle events to the cubit.
- CTA branching matches AC exactly: renders only when `eligible: true`;
  neutral "seen, no reply" line always shows when eligible regardless of
  penalty; CTA itself shown only for `emoji_storm`/`noise`, suppressed for
  `none` and for not-eligible. `ghost_state_row_test.dart` exercises all five
  cases (emoji_storm, noise, none, not-eligible-no-config,
  not-eligible-with-active-config) plus a fetch-failure-renders-nothing case
  and a no-repository-registered case.
- Live-region announcement: `Semantics(liveRegion: true, ...)` wraps the CTA;
  test asserts the semantics node carries the live-region flag. The
  "announce once, not per rebuild" AC relies on Flutter's own semantics-diff
  behavior (unchanged label -> no repeat announcement) rather than
  app-level de-duplication logic; this is a reasonable and explained
  simplification (documented in the widget's doc comment) since there is no
  app-owned state to test for that behavior beyond what the framework already
  guarantees. Not a defect.
- Confirmed no file under `mobile/lib/features/chat/` appears in this slice's
  diff (AC requirement).
- l10n: `ghost_state_row_seen_no_reply`, `ghost_state_row_storm_cta`,
  `ghost_state_row_noise_cta` keys present in both `app_en.arb` and
  `app_vi.arb`; "Emoji Storm" stays untranslated inside the `vi` CTA string
  ("Bắn Emoji Storm") per the phase task requirement.
- AC2 end-to-end mount: per ADR-3 and master-plan.md §3A this is explicitly
  non-blocking for this phase/slice — STORY-007 or requirement integration
  owns mounting `GhostStateRow` into the real chat screen. `GhostStateRow`
  exports a widget-test-covered mount seam here (constructor takes only
  `partnerId`, doc comment records the mount instruction). Not treated as a
  blocker for this slice, consistent with the handoff instruction.
- No-fork guard: `CupidIcon`/token colors used throughout, no `Icons.` or raw
  `Color(...)` literal in either file.

## Cross-Cutting

- No file outside the assigned Slice B list was modified by these commits
  (confirmed via `git diff --stat` against BaseHead for the full assigned
  path set).
- No deviation found beyond the two already self-disclosed in the phase files
  (append-only ARB key addition in P2; static-copy simplification in P3),
  both of which are accounted for and justified above.

## Outcome

Outcome: CLEAN (slice-scoped — Slice B only; does not constitute a full-story
verdict, which requires the Slice A report and a synthesis pass)
