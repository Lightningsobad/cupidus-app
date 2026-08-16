# Requirement Integration Review: REQ-002 Screen Flow And Design Fidelity Audit

Reviewer: Iris-QC
Review type: `requirement-integration-review`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Latest round: **2** (2026-08-16)
BaseHead for round 2: `24d2673c01d0183e4d4c883fb5e622927a6b43f2`
HEAD reviewed: `7b4f1310930b3dacc2ccb9cb21dee916352182d4` (worktree clean)
Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES
Scope gate: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/integration-review/scope-gate.md`
Scope gate (absolute): `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/integration-review/scope-gate.md`

Outcome: PATCH_REQUIRED

---

# Round 2 — Rework Re-Review (authoritative)

## Summary

Round 1's eight findings are all genuinely closed. I did not take that on
report: I re-ran both static gates myself in the integration worktree, and the
branch that failed 9 tests in Round 1 now passes 1247 with 0 failures and 0
analyzer warnings. Requirement state is consistent for the first time. The
missing SKILL 12g2 artifact exists and is a real audit, not a formality.

The requirement still cannot close, for a reason Round 1 could not have
reached. Round 1 blocked on a red branch; a red branch hides everything behind
it. With the suite green and a cross-screen visual audit finally in hand, the
first post-splash screen in the app is visibly wrong against its own locked
design — and REQ-002's acceptance bar for that is not "close", it is the user's
own words, `khớp 100%`.

Two blocking findings, both on `welcome`, both mobile lane, both fixable in one
patch round. Everything else clears or defers.

## Round 1 Finding Disposition

Verified against current branch state, not against the checkpoint's summary.

| Round 1 | Status | Evidence I checked myself |
|---|---|---|
| I-1 ADR-004 no-fork guard, 7 raw-colour violations | **CLOSED** | `flutter test` green; guard test passes in suite |
| I-2 ADR-002 copy guard, `permissions_screen.dart` | **CLOSED** | same run; `reminder_copy_guard_test.dart` passes |
| I-3 `_SkyBackdrop` orphaned dead code | **CLOSED** | `flutter analyze lib test` → 0 warnings (the `unused_element` warning was the only one) |
| I-4 boot never reaches `home_screen_ready_signal` | **CLOSED** | `widget_test.dart` "App boots to the home screen ready signal" passes; `app/feature_flags_test.dart` green |
| I-5 shared design-token drift (3 tests) | **CLOSED** | all three named tests green in the same run |
| I-6 STORY-005 three-way state contradiction | **CLOSED** | `req_master.md` DONE, `story_master.md:3` `Status: DONE`, `review/review-report.md:15` `Outcome: DEFERRED_ONLY` (round 4) — all three now agree |
| I-7 stale `req_master.md` story statuses | **CLOSED** | STORY-002/027/033 all `DONE` in the branch story table; STORY-023 `DEFERRED` |
| I-8 missing `mobile-visual-audit.md` | **CLOSED** | file present at `7b4f131`, `visual_fidelity_verdict: PASS_WITH_NOTES`, 31/38 canvas screens, real per-screen table and 31 committed PNGs |

## Critical Gates — Round 2

Static and unit gates re-run by me in the integration worktree
(`/Users/alantravala/flutter/bin`, per the runtime registry). Build, install,
and runtime were **not** re-run: they are covered by the DevOps Round 2 pass at
`integration-build-verification.md` (`db4e796`), which this review accepts as
the SKILL 12g3 evidence.

| Gate | Result |
|---|---|
| `flutter pub get` | PASS (exit 0) |
| `flutter analyze lib test` | **PASS** — 80 issues, **0 errors, 0 warnings** (all `info`) |
| `flutter test` | **PASS** — `All tests passed!`, `+1247 ~2`, exit 0 |
| `flutter build apk --debug` | PASS (DevOps Round 2) |
| Install + registry readiness on `emulator-5560` | PASS (DevOps Round 2) |
| SKILL 12g3 `## Integration Build & Runtime` | PRESENT and passing |
| SKILL 12g2 requirement mobile visual audit | PRESENT — `PASS_WITH_NOTES` |

On the DevOps `am start -W` `Status: timeout` note: the registry's pass
criterion is the compound readiness command's exit code, that was `0`, and
`dumpsys` found the resumed activity on the first poll with no `FATAL` /
`AndroidRuntime` / `E/flutter` in the launch window. Accepted as PASS.

## Blocking Findings

### R2-1 — `welcome` backdrop paints the button gradient, not the brand backdrop — HIGH

Adopts and upholds the visual audit's IF-1. I confirmed it in source and in the
rendered capture independently.

`mobile/lib/features/auth/presentation/screens/welcome_screen.dart:150-158`:

```dart
gradient: LinearGradient(
  begin: _gradient165Begin,
  end: _gradient165End,
  colors: colors.gradientHot.colors.reversed.toList(growable: false),
),
```

`gradientHot` is the two-stop **button** gradient `[#FF7FB6, #B78CF5]`
(`mobile/lib/design_system/tokens/cupid_color_tokens.dart:99-103`). Reversed, it
paints the full-screen backdrop light purple → light pink. The locked design's
backdrop is the three-stop brand gradient
`#7B2FBE 0% → #FF4B8C 58% → #FF3366 100%`.

I opened both images. `mobile-screenshots/implemented-welcome-emulator-5560.png`
against `STORY-033_app_shell_design_system_deltas/visual-fidelity/design-reference-welcome-android.png`:
the reference is a deep saturated purple-to-hot-pink field carrying white text
cleanly. The build is a pale lavender-to-pale-pink wash. Every foreground
element on this screen is white or white-at-alpha, so the damage is systematic
rather than cosmetic — the sub-copy at 78% alpha
(`welcome_screen.dart:241-245`), the centred legal footnote at 65% alpha and
11.5px (`:343-347`), and the 52x4 accent rule are all at or past the edge of
legibility, and the outlined "Dùng email" CTA (`:317-333`, border at 50% alpha)
barely separates from its own background.

Why this is blocking now and was not before:

- It sits inside REQ-002 Scope B's literal acceptance bar. `req_master.md:53`
  states the bar is "exact match (`khớp 100%`) to the design source, not a
  best-effort approximation". Under reviewer rule 14 the exact AC text controls;
  a backdrop rendered in the wrong gradient family is not a near-miss.
- It is the app's first post-splash screen, so it is the highest-traffic
  surface in the requirement.
- The constraint that justified deferring it is gone. STORY-004 recorded this
  as D13 because `lib/design_system/` was outside that story's WriteScope.
  STORY-032 and STORY-033 are merged; the design system is writable now. A
  deferral whose stated cause has expired is not still a valid deferral.
- Nobody ever looked. See IF-7 — `STORY-004_welcome_design_fidelity/visual-fidelity/`
  holds a report and no images at all. The story gate certified this screen
  without a comparison ever happening.

Owner: **mobile-dev**. Fix: add the three-stop welcome/brand backdrop gradient
as a design-system token in `mobile/lib/design_system/tokens/` and consume it at
`welcome_screen.dart:150-158`. Do not inline the hexes at the call site — the
ADR-004 no-fork guard is green again as of I-1 and a raw literal in
`features/` would turn it red.

### R2-2 — `welcome` Google CTA is missing the Google brand mark — MEDIUM, blocking

New this round. I found it by doing the image comparison R2-1 required, which is
the comparison STORY-004 never performed.

The design reference shows the multicolour Google "G" glyph before the
"Tiếp tục với Google" label. The build renders a label-only button:
`welcome_screen.dart:300-313` constructs a `_FilledCta` that takes `label`,
`background`, `foreground`, `elevation`, `radius`, `labelStyle` — there is no
leading-icon parameter, so no brand mark can appear.

This is the same defect class STORY-005 already fixed one screen over: BF-04 in
that story's round-3 findings added the Google and Facebook brand marks to the
**login** screen, and Reviewer round 4 confirmed "a four-colour Google 'G' and a
blue Facebook roundel before their labels". Welcome was never checked because it
shipped without images.

I am classifying this as blocking rather than deferred for two reasons: it fails
the same `khớp 100%` bar as R2-1 on the same screen, and it costs nothing extra
to fix — the same lane is already opening this file for R2-1, and the reference
implementation exists in `login_screen.dart`. Deferring it would mean either
returning to `welcome` a third time or closing REQ-002 with a known,
already-solved-elsewhere delta on its most-seen screen.

Owner: **mobile-dev**, same patch round as R2-1.

## Decisions Required — Not Mine To Make

These are the STORY-033 routed deltas that remain open. I am naming them as
scope/business decisions rather than silently ruling, per the handoff.

### E-1 — App-shell tab bar (routed deltas 2 and 3): 3 destinations vs the design's 5, plus the FAB

Both confirmed live in code. `mobile/lib/core/navigation/app_shell.dart:119-130`
builds at most three `CupidTabBarItem`s (Trang chủ, Trò chuyện when unlocked,
Thư viện ảnh); the design canvas specifies five (Nhà / Trò chuyện / Pet / Ví
chung / Tôi) with an active pill. The pink circular FAB is real at
`app_shell.dart:199-206` (`heroTag: 'account-hub-entry'`) and absent from the
canvas.

**These are one decision, not two.** The FAB is currently the only entry point
to the account hub (`_openAccountHub` → `MeScreen`, `app_shell.dart:105-111`).
The design's fifth tab is "Tôi" — the same destination. Removing the FAB to
match the canvas without adding that tab would orphan the account hub and
create exactly the entry-point regression reviewer rule 12e1 exists to catch.
Whoever resolves this must resolve both together.

The codebase already knows this is pending. `mobile/lib/features/expenses/expenses_route.dart:14-19`
documents `expensesRoute` as "the stable route identity the eventual Money-tab
entry point (§1C) will target **once the 5-tab shell lands**". So the 5-tab
shell is a recognised, unlanded architectural item, not an oversight.

I am not ruling this blocking, and I am not ruling it out-of-scope either.
Adding Pet, Ví chung and Tôi as shell destinations changes the app's information
architecture and creates new navigation entry points — that is Product Owner
scope and arguably Scope A (navigation correctness), not a design-token fix, and
no REQ-002 story owns it. But it is also a visible structural divergence from
the locked design on every shell-hosted screen, and REQ-002's stated bar is
100%.

**Recommendation to Scrum Master:** put this to the user/PO as an explicit
decision before REQ-002 is marked DONE, with two acceptable outcomes — (a)
accepted intended divergence, recorded in `req_master.md`
`## Deferred Follow-Up Items` with the reason, or (b) a new app-shell/navigation
story. What is *not* acceptable is closing REQ-002 silently, because the
requirement's own acceptance criterion says 100% and this is a known,
documented gap against it. Either recorded outcome clears the gate; the absence
of one does not.

### E-2 — Notifications banner copy (routed delta 4) conflicts with ADR-002

Not content-only. The audit records that the design's notifs banner carries a
Do Not Disturb sentence the build truncates away. The build cannot simply adopt
it: `mobile/test/features/reminders/reminder_copy_guard_test.dart:18-22` bans
the literal token `do not disturb` (alongside `báo thức` and `synced alarm`) in
every string literal under `mobile/lib`, as STORY-021's ADR-002 compliance gate,
with an explicit "do not delete this test to unblock a copy change" comment.

So the locked design and an approved ADR directly contradict each other. Note
the guard matches the English phrase and `báo thức` only, so a Vietnamese DND
phrasing may pass mechanically — but whether that honours ADR-002's *intent* is
a PO/UX ruling, not a reviewer call, and not something to settle by finding a
wording that slips past the regex.

**Recommendation:** route to Product Owner / UI-UX for a ruling on which source
wins. Defer to `req_master.md` `## Deferred Follow-Up Items` if the answer is
that ADR-002 stands. Do not fix by weakening or deleting the guard.

## Deferred Findings

Non-blocking. Recorded for `req_master.md` `## Deferred Follow-Up Items`.

- **IF-2 — inconsistent header affordances (MEDIUM → deferred).** `expense` and
  `jarnew` show no visible back control. I checked the worst case: `expense` is
  reached by `Navigator.push` from the Home entry affordance
  (`expenses_route.dart:14-19`), so a system/gesture back exists and this is a
  missing *visible affordance*, not a navigation dead-end. Not blocking. The
  audit's own caveat holds — it was observed in the preview harness, so confirm
  against the live navigation stack before changing code. No story owns the
  shared header contract.
- **IF-3 — `chat` has no partner header (LOW).** Possibly fixture-dependent.
- **IF-4 — `otp` backdrop flatter/darker than sibling auth screens (LOW).**
  Same token family as R2-1; worth re-checking after the R2-1 fix lands, since
  it may share a cause.
- **IF-5 — `gallery` tiles render empty (LOW).** Almost certainly seeded-data
  dependent. Re-check with a media fixture before routing anything.
- **IF-6 — `jarnew` uses bare Material underline fields (LOW).** Captured
  outside its normal modal-sheet host (`CreateDreamJarSheet`) and it has no
  canvas id, so it may have no locked design counterpart at all.
- **IF-7 — STORY-004 shipped with no image evidence (PROCESS).** Confirmed: its
  `visual-fidelity/` holds only the report. Non-blocking for closure but it is
  the direct cause of both R2-1 and R2-2 reaching integration undetected, and
  the strongest argument for the per-story capture rule (SKILL 12g2) being
  enforced rather than deferred.
- **IF-8 — stale claim in STORY-030's report (PROCESS).** It states
  `data/devops/system/design-fidelity-config.json` "does not exist anywhere in
  this repository"; the file is present at integration HEAD with
  `design_source.locked: true`. Documentation-only.
- **D-1 (Round 1) — 80 analyzer `info` diagnostics.** 0 errors, 0 warnings.
- **D-2/D-3/D-4 (Round 1)** — per-story visual-evidence gaps and non-bare
  `Outcome:` lines in four story reports. Unchanged; per-story gates are out of
  scope here. IF-7 is the concrete instance that mattered.
- **D-5 (Round 1) — `scrum-master-checkpoint.md` is stale.** It is dated
  `2026-08-15T12:10Z` and still describes STORY-005 as an open evidence gap and
  the mobile-visual-audit dispatch as BLOCKED; both are resolved at HEAD. Scrum
  Master owns this file — flagged so it is refreshed before it misroutes a
  later session, not as a defect in the delivered work.
- **D-6 (Round 1) — Tech Lead finding P1-F2** still open pending a PO/UX framing
  ruling. No live regression found for it this pass either.
- **RR-01 / ND-01 / biometric login / iOS login pass** — already recorded in
  `req_master.md` `## Deferred Follow-Up Items`; unchanged and still valid.

## Required To Clear

1. **R2-1** — add the three-stop brand backdrop gradient as a design-system
   token and consume it in `welcome_screen.dart:150-158`, replacing
   `colors.gradientHot.colors.reversed`. Owner: `mobile-dev`.
2. **R2-2** — add the Google brand mark to the welcome Google CTA, matching the
   pattern STORY-005 BF-04 established on `login`. Owner: `mobile-dev`, same
   round as R2-1.
3. Re-capture `implemented-welcome-*.png` after 1 and 2, and compare against
   `design-reference-welcome-android.png`. Owner: `mobile-dev`. One screen, not
   a re-run of the 31-screen audit.
4. Record an explicit decision for **E-1** (tab bar + FAB, coupled) and **E-2**
   (DND copy vs ADR-002) — either accepted divergence written into
   `req_master.md` `## Deferred Follow-Up Items`, or a new story. Owner: Scrum
   Master to route to Product Owner / user.
5. Append IF-2..IF-8 and the carried D-items to `req_master.md`
   `## Deferred Follow-Up Items`. Owner: Scrum Master.
6. Refresh `scrum-master-checkpoint.md` (D-5). Owner: Scrum Master.
7. Re-request integration review. Items 1-3 are the only code changes, so
   Round 3 can be scoped to the `welcome` screen plus a re-run of the static
   gates — the rest of this round's evidence stays valid unless the branch moves
   materially.

## State Recommendation

- Requirement `REQ-002_screen_flow_and_design_fidelity_audit`: **IN_PROGRESS**.
  Do not mark DONE.
- Route R2-1/R2-2/item 3 to the **mobile** lane as one patch round.
- No story returns to IN_PROGRESS: `welcome` design fidelity was STORY-004,
  which is DONE and whose gate cannot be reopened by this review. R2-1 and R2-2
  are integration-scope defects on a merged screen — file them as bug-registry
  rows against the integration worktree, consistent with how I-1..I-5 were
  handled this round.
- No new blocking finding exists outside the `welcome` screen.

Blocking findings: 2. Deferred findings: 11. Decisions required: 2.

REVIEW_COMPLETE

---

# Round 1 — superseded by Round 2

*Round 1 verdict (superseded): PATCH_REQUIRED. Findings I-1..I-8 are all
resolved; see the Round 2 disposition table above. Retained for traceability.*

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
