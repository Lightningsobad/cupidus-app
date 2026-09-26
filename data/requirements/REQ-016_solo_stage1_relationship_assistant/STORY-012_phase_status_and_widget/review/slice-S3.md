# Review Slice S3 — phase-P4 Android widget bridge + provider

REVIEW_SLICE_COMPLETE: YES

## Identity

- Slice: `S3` per `review/scope-gate.md` → "S3 `phase-P4` Android widget bridge
  + provider (7 files)"
- Story: `STORY-012_phase_status_and_widget` (REQ-016)
- Worktree:
  `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget`
- BaseHead: `b58afbe073eff4e1ebb9151735221532a9cf5a82`
- Verdict scope: this file records per-item verdicts for slice S3 only. No
  story-level decision is made here; that belongs to the `final-synthesis` pass.

## Files Reviewed (7, all inside the Worktree)

- `mobile/android/app/src/main/AndroidManifest.xml`
- `mobile/android/app/src/main/kotlin/com/snapsofts/cupid/CupidPhaseWidgetProvider.kt`
- `mobile/android/app/src/main/res/layout/cupid_phase_widget.xml`
- `mobile/android/app/src/main/res/xml/cupid_phase_widget_info.xml`
- `mobile/lib/features/phase_status/data/home_widget_bridge.dart`
- `mobile/test/features/phase_status/home_widget_bridge_test.dart`
- `mobile/test/features/phase_status/native_copy_scan_test.dart`

No file from S1, S2, S4, S5, S6a or S6b was opened.

## Governing Inputs

- `story_master.md` (AC-1..AC-8 only — see Correction C-1)
- `requirements/requirements.md` lines 139-158 (`### Nhóm C — SB-84 widget theo
  pha`, AC-9..AC-13), ranged read
- `architecture/solution.md:147` — the `WIDGET-STALE` risk row and its gate
- `architecture/contract-summary.md:69` — staleness is an accepted decision, not
  a native-side defect to compensate for

### Correction C-1 (AC citation in the handoff)

The handoff names `story_master.md` (AC-9..13 section) as the required input.
`story_master.md` carries AC-1..AC-8 and no Group C block. AC-9..AC-13 are in
the story-level `requirements/requirements.md` §"Nhóm C", lines 141-158, which
is what this review verified against. The requirement-level
`data/requirements/REQ-016_.../requirements/requirements.md` carries no numbered
AC at all. No AC text was reinterpreted; only the source file differs.

## Test Evidence

Command run from `<Worktree>/mobile`:

```
flutter test test/features/phase_status/home_widget_bridge_test.dart \
             test/features/phase_status/native_copy_scan_test.dart
```

Result: `00:00 +47: All tests passed!` (20 cases in `home_widget_bridge_test`,
27 in `native_copy_scan_test`). No skips, no retries, first run green.

Non-vacuity spot-checks on the two scanning tests:

- `native_copy_scan_test.dart:99-106` asserts the file walker actually reaches
  all four Android widget sources, and `:108-124` asserts the comment stripper
  still leaves code and still catches Vietnamese in it. The ASCII scan is
  therefore not vacuous.
- `home_widget_bridge_test.dart:34-36` loads the *shipped* pack off disk rather
  than a fixture, so the payload assertions bind to the copy that ships.

## Per-Item Verdicts

### AC-9 — widget content matches the latest card's phase, one of four — PASS

- `home_widget_bridge.dart:56-80` builds the payload from `resolution.phase`
  alone; `_widgetLineFor` (`:111-129`) filters pack items by
  `item.phaseId.wireValue == phase.wireValue` and `surface.allowsWidget`, so a
  phase can only ever draw its own item.
- `home_widget_bridge_test.dart:117-132` iterates all four `SoloPhase.values`
  and asserts a non-empty payload for each, i.e. the shipped pack really covers
  `waiting · upcoming · date_day · quiet`.
- `CupidPhaseWidgetProvider.kt:26-53` renders only `primary_line` /
  `secondary_line` out of the shared store, so the drawn surface cannot diverge
  from the pushed payload.
- Residual: the phase *selection* itself (`resolveSoloPhase`, "thẻ gần nhất")
  is S2 and is only exercised indirectly here
  (`home_widget_bridge_test.dart:303`).

### AC-10 — upcoming → date_day flips the widget to the fourth phase — PASS

- Phase-driven build plus per-phase pack filtering (see AC-9) means a phase
  change necessarily changes the selected item; `writeHomeWidgetPayload`
  (`:198-217`) rewrites all five contract keys and then calls
  `HomeWidget.updateWidget(androidName:, iOSName:)`, asserted at
  `home_widget_bridge_test.dart:417-440` to carry
  `CupidPhaseWidgetProvider` / `CupidPhaseWidget`.
- Every key is written on every push, absent ones as `null`
  (`:382-415`), so a `secondary_line` or `card_id` belonging to the previous
  phase cannot survive into the new drawing.
- Residual R-1: whether the `date_day` pack copy actually mirrors the "Trước
  giờ đi" block is pack semantics (S1), and the caller that fires the push on
  the transition is S2/S6b. Both are out of this slice.

### AC-11 — nothing from journal or notebook, no judgement about the partner — PASS

- `buildWidgetPayload` never takes an `ActivityCard`
  (`home_widget_bridge.dart:43-56`, signature takes `PhaseResolution` +
  `ContentPackage` only), so title, note, keywords and location have no path to
  the payload. Every readable character comes from the pack.
- `home_widget_bridge_test.dart:283-317` builds cards whose title, note,
  keywords and location are distinctive nonsense tokens, resolves a phase on
  three different days, and asserts no token reaches any payload value.
- The layout (`cupid_phase_widget.xml`) declares no `android:text`,
  `android:hint`, `android:contentDescription` or `@string/`, asserted at
  `native_copy_scan_test.dart:140-146`; the provider's every string literal is
  forced to match `^[a-z0-9_]*$` (`:155-166`).
- Residual: the pack copy itself (S1) is where a judgement sentence could still
  hide; this slice proves only that nothing *else* can reach the surface.

### AC-12 — reflects the user's own card only, no partner-behaviour indicator — PASS

- The only number a phase may publish is bounded by `_numberFor`
  (`home_widget_bridge.dart:89-102`): `upcoming` → days until a date the user
  chose, `quiet` → memory count, `waiting`/`date_day` → `null`.
- `_widgetLineFor:120-125` skips any pack item containing `{n}` when no number
  is available, so a "waiting N days" line is unrenderable rather than merely
  unwritten — asserted twice
  (`home_widget_bridge_test.dart:319-335` and `:337-353`).
- `CupidPhaseWidgetProvider.kt:182-194` (test) confirms the provider derives
  nothing from `computed_on`, `Calendar`, `LocalDate`,
  `System.currentTimeMillis`, `AlarmManager`, `WorkManager` or `Handler`, and
  `:208-217` that it never reads the card store — so the native side cannot
  invent an elapsed-time indicator of its own.

### AC-13 — no widget installed, the app is still complete — PASS

- `writeHomeWidgetPayload:212-216` swallows `PlatformException` and
  `MissingPluginException`; `pushWidgetPayload:175-181` swallows a store or pack
  read failure and returns.
- `pushWidgetPayload:187` leaves the platform write `unawaited`, so a push that
  never completes cannot hold the caller open — asserted directly at
  `home_widget_bridge_test.dart:480-500` with a writer that returns a
  never-completing `Completer`, and at `:442-450` for a missing platform.
- The manifest adds no permission for the widget (`native_copy_scan_test.dart:235-242`
  pins the count at exactly the three pre-existing ones), so installing the app
  without ever adding the widget costs the user no prompt.
- `android:exported="false"` on the receiver matches current Android AppWidget
  guidance (the system's AppWidgetService binds privileged); it does not hide
  the widget from the picker.

### WIDGET-STALE — the widget must not show stale data — PASS (in-slice half)

`solution.md:147` defines this invariant as two halves: (a) nothing wakes the
widget on a schedule, (b) a refresh runs on `AppLifecycleState.resumed` and
after every card mutation. Half (a) is in this slice and passes. Half (b) lives
in `PhaseStatusCubit` (S2) and `_ActivityCardHubBodyState` (S6b) and is
**UNVERIFIED here** — see residual R-2.

Evidence for (a):

- `cupid_phase_widget_info.xml:16` — `android:updatePeriodMillis="0"`, pinned by
  `native_copy_scan_test.dart:244-247`. The system never polls the provider, so
  the widget can never advance a day on its own.
- `home_widget_bridge_test.dart:502-517` scans the bridge source for `Timer`,
  `Isolate`, `compute(`, `periodic`, `scheduleWidgetUpdates`,
  `registerBackgroundCallback` and `listen(` and requires all absent. The push
  path is the only mover.
- Each push rewrites the full contract key set, `null` for absent keys
  (`home_widget_bridge.dart:28-37`, `:198-211`, asserted at test `:382-415`), so
  no key left over from an earlier phase can survive — the failure mode this
  invariant most often takes.
- An empty pack result is pushed as-is (`:68-70`), clearing the widget to a
  textless frame (both `TextView`s go `GONE`,
  `CupidPhaseWidgetProvider.kt:37-46`) rather than leaving the previous
  sentence on screen.

## Findings

### F-1 — MINOR — concurrent pushes are unordered, so a torn payload is possible

`pushWidgetPayload` fires `_writer` without awaiting
(`home_widget_bridge.dart:187`) and `writeHomeWidgetPayload` then awaits five
`saveWidgetData` calls in sequence (`:201-207`). Two pushes close together — the
documented resume and card-mutation triggers can coincide — may interleave, so
the store can briefly hold `primary_line` from one push and `card_id` or
`secondary_line` from the other, and the later `updateWidget` draws that mix.
The user-visible worst case is a deep link pointing at the previous card for one
redraw. There is no sequencing, debounce or in-flight-drop guard.

No AC mandates push ordering and the surface self-corrects on the next push, so
this is recorded as a minor finding for the final synthesis to accept or defer,
not a slice failure.

### F-2 — INFO — a read failure deliberately leaves the previous payload on screen

`pushWidgetPayload:175-181` returns without writing when the pack or the card
store throws, which by construction leaves whatever the home screen already
shows. That is stale data in the literal sense, but it is the explicit AC-13
trade-off documented in the code and matches
`contract-summary.md:69` ("chấp nhận có chủ đích ... không phải lỗi cần native
bù"). Recorded so the synthesis pass does not rediscover it as a defect.

### F-3 — INFO — the widget tap deep link has no in-slice consumer

`CupidPhaseWidgetProvider.kt:48-51` builds an explicit `HomeWidgetLaunchIntent`
to `MainActivity` carrying `cupidapp://card/<id>` (or `cupidapp://home`). The
intent is explicit, so no manifest `intent-filter` is required and none is
missing. Whether Dart consumes it (`HomeWidget.initiallyLaunchedFromHomeWidget`
/ `widgetClicked`) is outside S3 and outside AC-9..AC-13; flagged only so the
synthesis pass can confirm the tap target is not a dead end (SC-5).

## Residual Risks Carried Out Of This Slice

- R-1 — AC-10's "phản chiếu khối Trước giờ đi" is pack copy (S1) plus the
  transition trigger (S2/S6b). S3 proves only that the payload is phase-driven
  and that a redraw is requested.
- R-2 — `WIDGET-STALE` half (b), the refresh on `AppLifecycleState.resumed` and
  after each card mutation, is not evidenced by either S3 test file.
  `coding-plan/test-results.md:335` attributes it to
  `_ActivityCardHubBodyState with WidgetsBindingObserver`, which is S6b. The
  final synthesis must confirm that S2/S6b actually carries that assertion
  before treating `WIDGET-STALE` as closed at story level.
- R-3 — AC-11/AC-12 hold for everything except the shipped pack's own wording,
  which is S1's `phase_content.v1.json`.
- R-4 — No Android build, install or on-device widget-placement evidence exists
  for this slice; the provider, layout and manifest are verified by source scan
  and unit test only. Runtime/build gate evidence stays a story-level obligation.

## Slice Summary

All six required items are recorded: AC-9 PASS, AC-10 PASS, AC-11 PASS,
AC-12 PASS, AC-13 PASS, `WIDGET-STALE` PASS for the half this slice owns with
half (b) explicitly unverified and carried out as R-2. Three findings, all
MINOR or INFO, none blocking at slice level.

REVIEW_SLICE_COMPLETE: YES
