# STORY-009 Review — Scoped Slice B (P2 schedule screen/widgets + P3 firing cubit/overlay)

- Reviewer: Iris-QC (reviewer, `scoped-slice` mode)
- Diff baseline: `BaseHead 0a467d03babf1ed4102c3fab09c61b2dec941a0b` → worktree HEAD
  `386310249f35e8d84a12b763ec2923935de7b160`
- Files reviewed (11): `reminder_strings.dart`, `screens/reminder_schedule_screen.dart`,
  `widgets/reminder_time_stepper.dart`, `widgets/reminder_weekday_chips.dart`,
  `design_system/icons/cupid_icons.dart`, `test/.../reminder_schedule_screen_test.dart`,
  `reminder_firing_cubit.dart`, `widgets/reminder_firing_overlay.dart`,
  `reminder_overlay_host.dart`, `test/.../reminder_firing_cubit_test.dart`,
  `test/.../reminder_firing_overlay_test.dart`
- Scope note: only P0/P1/P4/P5 were excluded per handoff; this slice does not
  cover those files or the overall story outcome.

## AC1 — overlay opens for the receiving viewer

**PASS.** `ReminderFiringCubit._onEvent` opens on `ReminderWireEvents.triggerAlarm`
(`reminder_firing_cubit.dart:114-136`) and `ReminderOverlayHost`/`_ReminderOverlayHostView`
mounts `ReminderFiringOverlay` via `BlocBuilder` whenever state is `ReminderFiringOpen`
(`reminder_overlay_host.dart:320-338`).

Evidence, both present and matching the handoff's named tests:
- `reminder_firing_cubit_test.dart` — `"opens on triggerAlarm and re-derives
  partner-dismissed from GET /alarms stopperIds"` (group `ReminderFiringCubit
  open (D5)`) — asserts the cubit emits `ReminderFiringOpen` with the correct
  `reminder.id` after a live `triggerAlarm` event.
- `reminder_firing_overlay_test.dart` — `"ReminderOverlayHost mounts the
  overlay above the child once the cubit is open"` — asserts the overlay
  widget is absent while closed and present (with the child still rendered
  underneath) once the stub cubit emits open.

## AC2 — copy compliance ("nhắc nhở đồng bộ", never "báo thức")

**PASS.** Grepped all 7 non-test diffed source files for `báo thức`, `Báo Thức`,
`Synced Alarm`, `alarm-clock`: the only 2 hits are doc-comments *describing the
forbidden wording as forbidden* (`reminder_strings.dart:10` — the file-header
comment enumerating banned terms; `reminder_firing_overlay.dart:10` — a
comment noting the badge is never the "alarm-clock glyph"). No live string
literal contains banned wording. `reminder_strings.dart` is checked directly
per the handoff:
- Schedule-screen strings match `ux/uiux-spec.md` §2 verbatim: hero eyebrow
  "Nhắc nhở đồng bộ mỗi sáng"/"Shared morning reminder", confirm CTA "Xác nhận
  giờ này"/"Confirm this time", waiting-pill copy, "Thử nhắc ngay
  (demo)"/"Try it now (demo)" (exact match to spec's required rewrite), and
  the rule card VI/EN copy is a byte-for-byte match to spec §2's required
  rewrite (including the 5-minute timeout caveat).
- Firing-overlay strings match §3: body copy, dismiss CTA "Vuốt để dậy"/"Swipe
  to wake", per-partner labels "đã dậy ✓"/"còn ngủ" etc., all unchanged from
  spec (no alarm wording ever present there).
- `reminder_copy_guard_test.dart` (P4, out of this slice) is the enforcing
  static gate per `test-results.md` §3 AC2 — not re-verified here, consistent
  with the handoff's slice boundary.

## D4 — client-side 5-minute timeout must not emit `stopAlarm`

**PASS.** `_onTimeout()` (`reminder_firing_cubit.dart:142-147`) only calls
`_localPrefs.setPendingTimeoutNotice(true)` and emits `ReminderFiringClosed`;
it never calls `_repository.dismiss()` or otherwise touches
`RealtimeCoordinator.emit`. Matches `architecture/solution.md` §4 D4 exactly
("must not emit `stopAlarm` on expiry").

Evidence: `reminder_firing_cubit_test.dart` — `"D4 client-side timeout ...
timeout expiry clears the overlay with zero outbound emits and sets the
pending notice"` — asserts `realtime.emitted` is empty and the pending-notice
flag is set after the injected timer fires. Test logic is sound: it uses a
`_TimerRecorder` seam to trigger expiry synchronously rather than waiting 5
real minutes.

## D5 — partner-dismissed re-derivation from `GET /alarms`

**PASS.** On `ReminderWireEvents.alarmStoppedByPartner`, the cubit calls
`refreshFromForeground()` rather than trusting the event's `{stopperId}`
payload directly (`reminder_firing_cubit.dart:118-122`, comment explicitly
cites D5). `refreshFromForeground()` re-fetches via `_repository.load()` (GET
/alarms) and re-emits `ReminderFiringOpen` with the fresh `stopperIds`-derived
`partnerDismissed`/`viewerDismissed` getters (`reminder_firing_cubit.dart:64-82,
189-196`). `_open()` also calls `refreshFromForeground()` immediately after
opening, so a stale `triggerAlarm` payload's `stopperIds` is corrected before
the viewer relies on it.

Evidence:
- `reminder_firing_cubit_test.dart` — `"opens on triggerAlarm and re-derives
  partner-dismissed from GET /alarms stopperIds"` — the live `triggerAlarm`
  payload carries no `stopperIds`; only the REST body (queued in the fake
  transport) does, and the assertion (`state.partnerDismissed &&
  !state.viewerDismissed`) only passes if the REST-derived row was used.
- `"refreshFromForeground re-derives partner dismissal from stopperIds"` —
  isolates the same behavior by calling `refreshFromForeground()` directly
  with a second queued REST body.
- `ReminderOverlayHost._onForeground()` (`reminder_overlay_host.dart:304-309`)
  calls `cubit.refreshFromForeground()` on mount and on every
  `AppLifecycleState.resumed` transition, satisfying "re-derived ... on every
  foreground rehydration" from the architecture doc. This wiring itself isn't
  covered by a dedicated lifecycle test in this slice's test files, but it is
  a direct, easily-inspectable call and not a behavioral risk surface beyond
  what `refreshFromForeground()` itself already tests.

## Overlay accessibility (ux/uiux-spec.md §7)

**PASS**, with one minor spec-fidelity note (non-blocking).

- **Alert-level announcement + focus**: `_announceOnce()`
  (`reminder_firing_overlay.dart:1020-1030`) calls
  `SemanticsService.announce(message, textDirection)` once per mount and
  moves focus to `_dismissFocusNode` via a post-frame callback. Test
  `"announces the firing body as an alert-level interruption on open and
  focuses the dismiss action"` confirms both the announcement text and that
  the `Focus` widget holds primary focus. **Note**: the call does not pass an
  explicit `assertiveness: Assertiveness.assertive` argument (defaults to
  `Assertiveness.polite` in current Flutter `SemanticsService.announce`), so
  strictly speaking the announcement is not marked at OS-level "alert"
  priority even though the spec's functional requirement (announce + focus
  move) is met and tested. Flagging as a minor advisory, not a fail — the
  observable behavior (announcement fires, focus moves) satisfies the
  testable substance of §7.
- **Non-gesture dismiss button**: `Semantics(label: ..., button: true, ...)`
  wraps a `Focus` + `CupidPrimaryButton` with `onPressed: widget.onDismiss`
  independent of the gesture handler (`reminder_firing_overlay.dart:1085-1097`).
  Tests confirm both `find.bySemanticsLabel('Dismiss reminder')` exists and
  that tapping the button text (not swiping) triggers dismiss, plus a
  separate test confirms the swipe gesture is an equivalent, not exclusive,
  path. PASS.
- **Safe-area insets**: `Material > SafeArea > Center > SingleChildScrollView`
  (`reminder_firing_overlay.dart:1039-1042`). Test `"honors safe-area insets"`
  confirms a `SafeArea` ancestor renders under an injected `MediaQueryData`
  padding. PASS.
- **Icon-glyph placement discrepancy (non-blocking, worth tracking)**:
  `ux/uiux-spec.md` §7 says "Reference this story's own icon-swap: the CTA
  icon (`swipe_right`) should carry an accessible label describing the
  action..., not just the icon glyph" — implying the overlay's dismiss CTA
  itself renders the `swipe_right` glyph. In the implementation,
  `CupidIcons.swipeRight` is used only as a decorative icon on the **schedule
  screen's Rule Card** (`reminder_schedule_screen.dart` `_RuleCard`, P2); the
  overlay's dismiss button (P3) has no icon at all, just a text label wrapped
  in `Semantics`. The functional accessibility outcome (labeled,
  non-gesture-activatable dismiss control) is still satisfied and tested, so
  this is a copy/asset-placement deviation from the UX spec's icon mapping,
  not an accessibility regression. Recommend a follow-up note to UI/UX
  Designer or Product Owner if pixel/asset-level UX-spec conformance is being
  tracked separately from a11y outcomes.

## Icon glyph regression gate (architecture §7 risk: "Material Symbols
codepoints guessed wrong")

**PASS.** `reminder_schedule_screen_test.dart` — `"the added glyph constants
render (no blank glyph box)"` asserts `CupidIcons.remove`, `CupidIcons.add`,
`CupidIcons.swipeRight` all render via `find.byIcon`. `notificationsActive` is
separately confirmed to render in
`reminder_firing_overlay_test.dart` — `"renders the never-alarm-clock
notificationsActive glyph, body copy and dismiss CTA"`.

## Test evidence cross-check against `coding-plan/test-results.md`

All required-input test names in the handoff are present verbatim in both the
test files and `test-results.md` §3 (AC1 block) and §4 (risk-surface rows for
"Client-side 5-minute timeout" and "Overlay mount + a11y"). No discrepancy
found between claimed and actual test names/assertions for this slice's
scope.

## Summary

| Item | Result |
|---|---|
| AC1 (overlay opens for receiving viewer) | PASS |
| AC2 (copy compliance in this slice's files) | PASS |
| D4 (no `stopAlarm` on client timeout) | PASS |
| D5 (partner-dismissed re-derivation) | PASS |
| Overlay a11y (announce+focus, non-gesture dismiss, safe-area) | PASS (1 minor advisory note on `assertiveness` + icon placement, non-blocking) |

No FAIL or UNVERIFIED items in this slice. No blocking findings. This slice
report does not render a story-level outcome — that is reserved for
final-synthesis per the handoff.

REVIEW_SLICE_COMPLETE: YES
