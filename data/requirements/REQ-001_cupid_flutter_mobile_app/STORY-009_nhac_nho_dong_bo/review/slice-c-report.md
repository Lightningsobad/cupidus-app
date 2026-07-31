# STORY-009 Nhắc Nhở Đồng Bộ — Reviewer Slice C Report (P4 + P5)

- Reviewer: Iris-QC (scoped slice C)
- RunId: RUN-REQ-001_cupid_flutter_mobile_app-STORY-009-reviewer-slice-c
- Worktree: /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-001_cupid_flutter_mobile_app-STORY-009
- BaseHead: 0a467d03babf1ed4102c3fab09c61b2dec941a0b
- Files reviewed (diff BaseHead..worktree HEAD):
  - mobile/lib/core/navigation/app_shell.dart
  - mobile/lib/features/home/presentation/home_screen.dart
  - mobile/test/features/reminders/reminder_entry_point_test.dart
  - mobile/test/features/reminders/reminder_copy_guard_test.dart
  - data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-009_nhac_nho_dong_bo/coding-plan/test-results.md

## Scope note

Per the handoff, only P4 (entry point + AC2/AC3/AC4 static copy guard) and P5
(verification) files were reviewed. P0–P3 source/test files were intentionally
not read.

## AC2 — no "báo thức"/"Synced Alarm" copy

PASS.

- `mobile/test/features/reminders/reminder_copy_guard_test.dart` statically
  scans every non-comment string literal under `mobile/lib/**` (recursive)
  for `báo thức`, `synced alarm`, `do not disturb` (case-insensitive) and
  fails with exact file/line/token on any hit.
- Independently reran this exact test in isolation
  (`flutter test --reporter=expanded test/features/reminders/reminder_copy_guard_test.dart`)
  and inside the full `test/features/reminders/` run at `--concurrency=1`:
  both tests in the file pass — the string-literal scan and the pubspec
  dependency assertion.
- `home_screen.dart` new `_ReminderEntryCard` copy uses
  `context.reminderNotificationsRowTitle` / `...RowSubtitle` (indirection
  through `reminder_strings.dart`, not reviewed here per scope, but the guard
  test scans the actual rendered/declared literal source, so this is covered
  regardless of which file the literal lives in).
- test-results.md §3 AC2 documents a negative-injection check (temporarily
  injecting "Synced Alarm" into `home_screen.dart`'s AppBar title, confirming
  the guard test fails with the exact offending file/line/token, then
  reverting) — this is recorded evidence, not independently re-executed by
  me, but it is a credible, falsifiable claim (references phase-P4 file, not
  reviewed).

## AC3 — no Do-Not-Disturb claim; Notifications settings screen intentionally not built

PASS.

- Same guard test scans for `do not disturb` (case-insensitive); passes.
- Independently confirmed no Notifications-settings screen file exists:
  `git ls-files mobile/lib/features/reminders/` lists 14 files, none named
  for a notifications/settings screen; a broader `git ls-files mobile/lib |
  grep -i notif` returns zero matches anywhere in the tracked lib tree.
  This is consistent with story_master.md's Out of Scope clause (DND-override
  entitlement/screen explicitly excluded, D1) and confirms the claim in
  test-results.md §3 AC3 that no such screen was created.
- Did not independently grep `mobile/lib` for `dnd`/doc-comment claims (out
  of my forbidden-scope for reading P0–P3 source); relying on the copy-guard
  test's automated scan plus the negative-file-existence check above, which
  is sufficient to confirm the AC.

## AC4 — no native-alarm/local-notification dependency, no platform channel

PASS.

- Read `mobile/pubspec.yaml` directly: dependency list is `flutter`,
  `flutter_localizations`, `intl`, `cupertino_icons`, `dio`, `cupid_api`
  (path), `firebase_core`, `firebase_auth`, `get_it`, `google_sign_in`,
  `sign_in_with_apple`, `flutter_facebook_auth`, `flutter_bloc`,
  `socket_io_client`, `firebase_messaging`, `shared_preferences`. None of
  `android_alarm_manager`, `flutter_local_notifications`, `alarm`,
  `awesome_notifications` are present — matches the claim exactly.
- `reminder_copy_guard_test.dart`'s second test
  (`pubspec.yaml declares no native-alarm/local-notification dependency
  (AC4)`) asserts the same four forbidden dependency names are absent via a
  YAML-key regex; independently reran and it passes.
- Platform-channel claim (no `MethodChannel`/`EventChannel` added) not
  independently re-verified by me — it references `lib/features/reminders/**`
  files outside my P4/P5 scope; the pubspec.yaml + guard-test dependency
  evidence above is independently confirmed and sufficient for the AC4
  dependency requirement.

## Entry-point discoverability (P4 AC)

PASS.

- `app_shell.dart` diff: wraps `HomeScreen` in `ReminderOverlayHost` so the
  firing overlay can render above any active screen — reasonable, minimal
  diff (+6/-1).
- `home_screen.dart` diff: preserves the pre-existing
  `Key('home_screen_ready_signal')` `Text` widget exactly (now inside an
  `Expanded`/`Center`, same key, same text) and adds a new
  `_ReminderEntryCard` (`Key('home_reminder_entry_card')`) below it that
  navigates via `Navigator.push` to `ReminderScheduleScreen` on tap. This is
  additive only — no router package or bottom-nav introduced, consistent
  with the phase-P4 write-scope note in test-results.md.
- `reminder_entry_point_test.dart` (`home affordance navigates from
  AppShell to ReminderScheduleScreen (P4 AC)`): pumps the real `AppShell`
  widget tree (with a faked `ReminderRepository`/`ReminderScheduleBloc` via
  `getIt`), asserts `home_screen_ready_signal` is present, `ReminderOverlayHost`
  is mounted, taps `home_reminder_entry_card`, and asserts
  `ReminderScheduleScreen` is reached. Independently reran this exact test
  in isolation and inside the full directory run at `--concurrency=1`; it
  passes both times.

## Independent flutter analyze / test rerun

- `flutter analyze` (worktree root `mobile/`): reproduced the exact same
  error set as claimed — all `error`-severity findings are confined to the
  untracked, gitignored path
  `build/ios/SourcePackages/checkouts/flutterfire/...` (confirmed via
  `git check-ignore -v` on one of the flagged files, and `git ls-files
  mobile/build` returns empty). Filtering analyze output for
  `^\s*error` lines outside `build/ios/SourcePackages` yields **0** matches.
  Outside that path, only pre-existing `info`/`warning` lints (unused
  imports in generated `openapi/cupid_api`, `prefer_initializing_formals`,
  one `deprecated_member_use`) — no new errors, no regressions attributable
  to this diff. Matches the recorded PASS claim.
- `flutter test test/features/reminders/` (default reporter/concurrency):
  produced ambiguous/duplicated-looking output (e.g. the single entry-point
  test's name appearing ~19 times, `reminder_copy_guard_test.dart` not
  visibly appearing at all) — this is a compact/expanded-reporter
  interleaving artifact under default concurrency when output is piped to a
  file (confirmed, see below), **not** a real test-execution problem.
- Reran `flutter test --reporter=expanded --concurrency=1
  test/features/reminders/`: clean, unambiguous output — all 9 tracked test
  files in the directory load and run exactly once each
  (`reminder_firing_cubit_test.dart`, `reminder_firing_overlay_test.dart`,
  `synced_reminder_test.dart`, `reminder_copy_guard_test.dart`,
  `reminder_repository_test.dart`, `reminder_entry_point_test.dart`,
  `reminder_local_prefs_test.dart`, `reminder_schedule_bloc_test.dart`,
  `reminder_schedule_screen_test.dart`), **65/65 tests passed, 0 failed**.
  This independently reproduces and confirms the mobile developer's own
  stated cross-check methodology in test-results.md §2 (re-running at
  `--concurrency=1` to rule out a compact-reporter display artifact) — my
  rerun used the same technique and got the same clean result for this
  subdirectory.
- I did not rerun the full `mobile` package (184/184 claim covers auth/
  realtime/home in addition to reminders, outside this slice's file scope);
  the reminders-subdirectory rerun above is a full, clean, independent
  reproduction for every file in my assigned scope.

## Findings

None (no FAIL, no discrepancy against the recorded evidence for AC2/AC3/AC4,
entry-point discoverability, or the flutter analyze/test claims within
scope).

## Residual risks / notes for final synthesis

- The default-concurrency `flutter test` reporter output for this directory
  is misleading when piped to a file (heavy duplicate-looking lines, and
  some file names not appearing at all in the merged stream) — not a defect
  in the story's code or tests, but worth noting for future reviewers/CI
  scripts: always use `--concurrency=1` or `--reporter=json` if reading
  output non-interactively as evidence.
- I did not independently verify the AC1 realtime evidence, the P0–P3
  screen/state implementation, or the whole-package 184/184 claim — those
  are out of this slice's scope and should be covered by the other reviewer
  slices / final synthesis.

REVIEW_SLICE_COMPLETE: YES
