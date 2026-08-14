# Requirement Integration Review: REQ-002 Screen Flow And Design Fidelity Audit

Outcome: PATCH_REQUIRED

Review type: `requirement-integration-review`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
BaseHead: `239b2116b4d4b793e2a635fb79fa3e579448ad81`
HEAD reviewed: `fbc30dae7b0ac7da12915095ca4e1f106de36e8e`
Scope gate: `integration-review/scope-gate.md` (SCOPE_GATE_COMPLETE: YES)

## Summary

All 33 story branches are merged and the merged branch compiles, builds a debug
APK, and boots to a resumed activity. It does not pass its own test suite. Nine
tests fail on the integrated branch, and the failures are not a random tail of
flaky assertions: they cluster into cross-story collisions that no single-story
review could have caught, because each story was green in isolation and only
conflicts once merged. Two of the failures are architectural contract guards
(ADR-004 design tokens, ADR-002 copy) that one story owns and other stories
violate. Two more are shared design-token drift, where a late design-system
consolidation moved values that earlier approved stories assert against. Two
more are the end-to-end boot path failing to reach the home screen.

Separately, requirement state is internally contradictory. `STORY-005` is DONE
in `req_master.md`, `PENDING` in its own `story_master.md`, and its canonical
review report carries `Outcome: PATCH_REQUIRED` with no later passing review.
Three further stories are still `PENDING` in `req_master.md` despite merged
work. The handoff Stop rule names contradictory story state explicitly, so this
review does not record a passing outcome.

## Integration Build & Runtime

Toolchain resolved from `data/devops/system/runtime-command-registry.json`
(`mobile-app`). The Flutter SDK is not on PATH on this machine and was invoked
from `/Users/alantravala/flutter/bin` as the registry records.

| Step | Command | Result |
|---|---|---|
| Deps | `flutter pub get` | PASS (exit 0) |
| Analyze | `flutter analyze lib test` | 81 issues, **0 errors**, 1 warning (exit 1 on warning) |
| Test | `flutter test` | **FAIL** — `+1231 ~2 -9`, exit 1 |
| Build | `flutter build apk --debug` | **PASS** (exit 0) |
| Runtime | registry readiness command on `emulator-5560` | **PASS** |

Build: PASS — `flutter build apk --debug` produced
`mobile/build/app/outputs/flutter-apk/app-debug.apk`, exit 0.

Runtime: PASS — debug APK installed on `emulator-5560`, then
`am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
returned `Status: ok`, `LaunchState: COLD`, `TotalTime: 7839`.
`dumpsys activity activities` confirmed
`ResumedActivity: ActivityRecord{... com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity ...}`.
`logcat` showed no `FATAL`, no `AndroidRuntime` crash, and no `E/flutter`
during the launch window. Shutdown ran `am force-stop com.snapsofts.cupid` per
the registry.

Smoke: PASS (process-level launch/readiness only).

The runtime gate proves the app boots. It does not clear the requirement,
because the integrated **test** gate fails and that suite is the primary proof
of the changed behavior this requirement is about. Under reviewer rule 12c a
failing critical gate that is the primary proof of changed behavior cannot be
recorded `DEFERRED_ONLY`.

Note the discrepancy the runtime gate itself exposes: the process reaches a
resumed activity, but two widget tests that seed a signed-in, paired session
cannot reach `home_screen_ready_signal`. Booting is not the same as routing
correctly, and only the test gate covers the second claim.

## Blocking Findings

### I-1 — ADR-004 no-fork guard fails across three stories

`mobile/test/design_system/no_fork_guard_test.dart` — "AC 4 no-fork guard:
features/app/core never fork on a raw color literal or
`Platform.is*`/`defaultTargetPlatform`". Expected empty, actual 7 violations:

```
lib/features/chat/presentation/screens/ghost_settings_screen.dart:211  "Colors."
lib/features/chat/presentation/screens/ghost_settings_screen.dart:411  "Colors."
lib/features/account/presentation/screens/notification_settings_screen.dart:359  "Color(0x"
lib/features/reminders/presentation/screens/reminder_schedule_screen.dart:448  "Colors."
lib/features/reminders/presentation/screens/reminder_schedule_screen.dart:449  "Colors."
lib/features/reminders/presentation/screens/reminder_schedule_screen.dart:452  "Colors."
lib/features/reminders/presentation/widgets/reminder_weekday_chips.dart:71     "Colors."
```

The violations span STORY-019 (ghost settings), STORY-031 (notification
settings), and STORY-021 (reminder schedule and weekday chips). This is a
requirement-wide architectural invariant, and it is red on the merged branch.
This is exactly the class of defect that only appears at integration: the guard
lives in one story's test tree and the offending code lives in three others.

### I-2 — ADR-002 copy contract violated by a different story's screen

`mobile/test/features/reminders/reminder_copy_guard_test.dart` — expected empty,
actual:

```
lib/features/onboarding/presentation/screens/permissions_screen.dart:80  forbidden token "synced alarm"
lib/features/onboarding/presentation/screens/permissions_screen.dart:81  forbidden token "synced alarm"
```

STORY-021 owns the ADR-002 copy contract (`báo thức` / `Synced Alarm` /
`Do Not Disturb` must never appear in `mobile/lib` strings). STORY-009 owns
`permissions_screen.dart` and ships copy that breaks it. Both stories passed
their own reviews; the contract only breaks when both are on one branch.

### I-3 — `waiting_sky_backdrop` is orphaned dead code (cross-story regression)

`waiting_screen_design_fidelity_test.dart` — "paints the `--sky` wash and
twinkle stars over `--bg`": found 0 widgets with key `waiting_sky_backdrop`.

`_SkyBackdrop` was introduced only by `2a92f37 fix(STORY-013)` as the
reviewer-approved fix for that story. Later commits `d43d9f2 feat(STORY-032)`
and `0807fd1 feat(STORY-002)` touched `waiting_screen.dart`, and STORY-032's
`CupidAppBackground` superseded the local backdrop at the composition root. The
result on the merged branch:
`mobile/lib/features/pairing/presentation/screens/waiting_screen.dart:337`
declares `_SkyBackdrop` and nothing references it. The analyzer's single
`warning` is this `unused_element`. STORY-013's approved fix is now dead code
and its regression test is red. The sibling assertion "applies the design source
typography and muted subtitle" in the same file fails with it.

Whether the correct resolution is deleting `_SkyBackdrop` and retargeting the
test at `CupidAppBackground`, or restoring the local backdrop, is a design
decision for Scrum Master to route — but the branch cannot ship with an
approved story's fix silently deleted by a later story.

### I-4 — Integrated boot path never reaches the home screen

Two independent tests fail on `find.byKey(const Key('home_screen_ready_signal'))`
returning 0 widgets:

- `mobile/test/widget_test.dart` — "App boots to the home screen ready signal"
- `mobile/test/app/feature_flags_test.dart` — "CupidApp resolves dark theme mode
  and vi locale with flags off, and the runtime readiness key still resolves"

`git log -S"home_screen_ready_signal"` shows no REQ-002 commit touched the key,
so the widget still exists in
`mobile/lib/features/home/presentation/home_screen.dart`. The integrated routing
no longer arrives there even with a seeded `CupidSessionSignedIn` plus a
resolved `PartnerLink`. This is the same symptom family as the already-filed
**BUG-20260814-002** (login resume landing on `waiting`), and that bug remains
reproducible on this branch. `home_screen_ready_signal` is also the registry's
declared `inAppFirstScreenSignal`, so the requirement has broken its own
runtime-readiness contract.

### I-5 — Shared design-token drift breaks three approved stories

Three failures are value drift on shared tokens, not logic bugs:

| Test | Expected | Actual |
|---|---|---|
| `joincode_screen_design_test.dart` — heading/sub-copy display+caption roles | `13` | `11.5` |
| `login_screen_test.dart` — design-source subtext slot below heading | `13` | `11.5` |
| `pet_design_fidelity_test.dart` — uppercase muted eyebrow | `0.65` | `0.575` |

`mobile/lib/design_system/` received 14 commits from 14 different stories on
this branch, ending with `d43d9f2 (STORY-032)` and `bf01450 (STORY-033)`. The
caption size and muted alpha moved after STORY-012, STORY-005, and STORY-024
were reviewed and approved against the older values. The caption case is
already filed as **BUG-20260814-003**, but that bug was scoped to the join-code
caption; the login screen shows the same 13→11.5 drift, so the filed scope is
narrower than the actual blast radius. The muted-alpha drift (0.65→0.575) on
the Love Pet eyebrow is not covered by any filed bug.

### I-6 — STORY-005 is in contradictory state

Three sources disagree on the same story:

- `req_master.md` story table: **DONE**
- `STORY-005_login_design_fidelity/story_master.md:3`: **`Status: PENDING`**
- `STORY-005_login_design_fidelity/review/review-report.md:11`:
  **`Outcome: PATCH_REQUIRED`** (Round 2), no Round 3 review exists

The Round-2 report accepts the code and blocks only on PATCH-03, a
documentation-only sync of `visual-fidelity/visual-fidelity-report.md`. Commit
`174072b docs(...): sync visual-fidelity-report.md with round-2 ...` appears to
do that work, but no re-review was recorded, so the canonical gate for STORY-005
is still `PATCH_REQUIRED`. Additionally that story's
`visual-fidelity-report.md` contains no `VISUAL_FIDELITY:` verdict token at all,
so the rendered verdict for the login screen is absent from the merged evidence.

Per AGENTS.md a story may be DONE only after a review gate records `CLEAN` or
`DEFERRED_ONLY`. STORY-005 does not meet that bar and is nonetheless marked DONE
at requirement level.

### I-7 — Requirement registry state is stale on the branch

`req_master.md` on this branch still lists **STORY-002 PENDING**,
**STORY-027 PENDING**, and **STORY-033 PENDING**, although all three merged and
have passing story reviews (`main` carries 3 lines of later reconciliation that
this branch does not). A requirement cannot close while its own master artifact
disagrees with its merged content.

### I-8 — SKILL 12g2 mobile visual audit is missing

`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/integration-review/mobile-visual-audit.md`
does not exist. REQ-002 is a mobile-participation, design-fidelity requirement,
so the cross-screen visual audit is a separate blocking check before closure.
Producing it is Mobile Developer scope, not Reviewer scope; it is recorded here
as a missing prerequisite for Scrum Master to route.

## Deferred Findings

These do not block the requirement and are recorded for triage. Under reviewer
rule 7 they are pre-existing or out-of-scope relative to the merged work.

- **D-1** — `flutter analyze lib test` reports 80 `info` diagnostics in
  `lib`/`test` beyond the one blocking warning in I-3. No errors.
- **D-2** — Four stories with `VISUAL_FIDELITY: FAIL` in their rendered evidence
  (STORY-001, STORY-007, STORY-012) closed via documented accepted exceptions.
  The requirement's "100% design match" framing is therefore not uniformly
  proven. Not re-adjudicated here; per-story gates are out of scope.
- **D-3** — Ten stories (STORY-004, 005, 006, 011, 014, 015, 018, 022, 025, 028)
  have a `visual-fidelity-report.md` with no committed rendered image alongside
  it. Their per-story gates already passed; flagged only because it weakens the
  evidence base for D-2.
- **D-4** — Four story reports (STORY-010, 015, 024, 029) wrap their verdict in
  markup rather than emitting a bare `Outcome:` line. A strict `^Outcome:` gate
  would not match them. Cosmetic, but it makes automated DONE-gating fragile.
- **D-5** — `scrum-master-checkpoint.md` is stale (`2026-08-14T02:35Z`, mid-wave,
  10 active runs, no `BUG-20260814-*` ids). Its Cross-Story Findings #11
  (STORY-008 merged without ever running Reviewer), #12/#13 (skyGradient
  app-shell background, "re-verify all 5" once STORY-032 lands), and #14 remain
  unrouted. Finding #12/#13 is directly implicated by I-3.
- **D-6** — Tech Lead finding **P1-F2** stays open pending a PO/UX framing
  ruling. Carried forward per the handoff; no live regression found for it
  during this pass.

## Filed Bug Cross-Reference

| Bug | Still visible on this branch | Note |
|---|---|---|
| BUG-20260814-001 (chrome header breach) | yes | unchanged |
| BUG-20260814-002 (waiting not a valid login-resume target) | yes | same family as I-4 |
| BUG-20260814-003 (caption typography 13 vs 11.5) | yes | scope narrower than actual — see I-5 |
| BUG-20260814-004 (triage-pending guard/registry/splash) | yes | overlaps I-1 |

No new bug rows were filed by this review. I-1 through I-8 and the uncovered
portions of I-5 are handed to Scrum Master for triage.

## Scope Exclusion Confirmed

STORY-023 is a Product Owner-accepted scope exclusion. Merge `11de886` touches
documentation only and no `mobile/lib` file. Its `VISUAL_FIDELITY: FAIL` is
consistent with nothing being implemented. Treated as excluded scope, not a
missing review.

## Required To Clear

1. Fix the 7 ADR-004 raw-color violations (I-1) or record an approved exception.
2. Fix the 2 ADR-002 copy violations in `permissions_screen.dart` (I-2).
3. Resolve `_SkyBackdrop` / `waiting_sky_backdrop` (I-3) — delete-and-retarget or
   restore, with a decision recorded.
4. Restore the integrated route to `home_screen_ready_signal` (I-4).
5. Reconcile the shared design-token drift against the affected stories (I-5).
6. Resolve STORY-005's three-way state contradiction (I-6).
7. Sync `req_master.md` story statuses on the branch (I-7).
8. Produce `integration-review/mobile-visual-audit.md` via Mobile Developer (I-8).
9. Re-run `flutter test` to green, then re-request integration review.

REVIEW_COMPLETE
