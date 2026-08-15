# Diagnosis: BUG-20260814-002 `waiting` Screen Used As Login-Resume Target

Bug id: BUG-20260814-002_waiting_screen_not_valid_login_resume_target
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Diagnosed by: Bug Fixer (Justin-BugFixer)
Work location: REQ-002 integration worktree, branch
`codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`, from HEAD `2da7d19`.

## Pre-Fix Reproduction Gate

Command:

```
/Users/alantravala/flutter/bin/flutter test test/widget_test.dart test/app/feature_flags_test.dart
```

Result: REPRODUCED — both tests RED, identical assertion failure.

- `test/widget_test.dart:85` — `Found 0 widgets with key [<'home_screen_ready_signal'>]`
- `test/app/feature_flags_test.dart:100` — same

Both harnesses seed a signed-in + paired session
(`CupidSessionSignedIn(uid: 'u1', ...)` + `PartnerLink(partnerId: 'partner-1')`),
so the failure is reproduced under exactly the state named in the report.

## Headline: The Reported Framing Is Contradicted By Evidence

The intake framing — "login-resume logic can resolve to the `waiting` screen,
so the routing logic itself is the cause" — does **not** hold. `waiting` is
never reached, and no resolver can return it.

This correction is reported per the handoff's explicit instruction to report a
contradicting finding rather than force a routing-logic fix.

The two RED tests are real and were correctly flagged as blocking by
integration review finding I-4. Their cause is a **lost frame in the test pump
sequence, introduced by an integration merge**, not a defect in the resolver.

### Evidence 1 — runtime probe: routing resolves correctly to `home`

A temporary probe pumped the exact `widget_test.dart` harness and dumped the
mounted screens at each step (probe deleted after diagnosis; it was scratch,
not a deliverable):

```
PROBE[after pumpWidget]:  SplashScreen=1
PROBE[after pump()]:      SplashScreen=1
PROBE[after pump(3s)  <-- widget_test.dart asserts HERE]: SplashScreen=1
PROBE[after +200ms]: SplashScreen=1, PairGateShell=1, AppShell=1, HomeScreen=1, READY_KEY=1
PROBE[after +400ms]: SplashScreen=1, PairGateShell=1, AppShell=1, HomeScreen=1, READY_KEY=1
PROBE[after +600ms]: PairGateShell=1, AppShell=1, HomeScreen=1, READY_KEY=1
```

`WaitingScreen` is **never mounted**. `PairingChoiceScreen` is **never
mounted**. The seeded signed-in + paired boot reaches `HomeScreen` with
`home_screen_ready_signal` present — it just needs one more frame than the
test gives it.

### Evidence 2 — `waiting` is structurally unreachable as a resume target

- `mobile/lib/core/navigation/onboarding_progress_resolver.dart` — the class
  dartdoc states outright: "`waiting` and `permissions` are deliberately absent
  from the outcomes: the backend exposes no read for an outstanding invitation
  the user created, and `permissions` is a first-run-only OS prompt step
  (ADR-2)." Its `resolve()` returns only `home`, `loveContract`, `otp`,
  `profileSetup`, or `pairingChoice`.
- `mobile/lib/features/auth/presentation/screens/splash_screen.dart` — the
  destination switch has four arms (`SizedBox.shrink`, `WelcomeScreen`,
  `PairGateShell`, `LoginScreen`). No `waiting` arm.
- `mobile/lib/core/navigation/pair_gate_shell.dart` — the state switch has
  three arms (`_PairGateChecking`, `PairingChoiceScreen`, `AppShell`). No
  `waiting` arm.
- `OnboardingNode.waiting` exists in `onboarding_chain.dart`, but only as a
  *forward* chain edge (`invite -> waiting -> paired`), which is the
  invite-sender flow, not a login-resume destination.

Tech Lead finding P1-F3 ("`waiting` is not a valid login-resume target") is
therefore a **pre-disclosed constraint that the implementation already
honours** — and documents honouring, in the resolver dartdoc. It is not an
outstanding defect. Integration review I-4 correctly observed 2 RED tests but
attributed them to P1-F3 by proximity; the two are unrelated.

## Actual Root Cause: A Merge Lost The Post-Navigation Frame

Both failing tests were last touched by exactly two REQ-002 commits, and
**each was individually correct**:

| Commit | Story | Pump sequence it left behind |
| --- | --- | --- |
| `a23f018` | STORY-001 (splash entry gate) | `pump(3s)` then `pumpAndSettle()` |
| `d43d9f2` | STORY-032 (`CupidAppBackground`) | `pump()` then `pump(1s)` |

`git merge-base --is-ancestor a23f018 d43d9f2` returns false: **STORY-032
branched before STORY-001**, so STORY-032 never saw the splash's 2s dwell. Its
two-pump sequence was correct for its own base (no splash, so nothing to
advance past), and it replaced `pumpAndSettle()` only because STORY-032's new
`CupidAppBackground` twinkles forever at the composition root, so the tree
never settles.

The integration merge combined STORY-001's session-gate seam with STORY-032's
two-pump structure and reconciled the dwell by bumping `pump(1s)` to
`pump(3s)` — producing:

```dart
await tester.pump();                            // still on splash; does nothing useful
await tester.pump(const Duration(seconds: 3));  // fires dwell -> pushReplacement
expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
```

The bare `pump()` ended up **before** the dwell instead of after it. So the
frame that would build the route `pushReplacement` just scheduled was spent
early, and the assertion runs with the pushed route not yet built. Both
stories' contributions survived the merge individually; their *ordering*
requirement did not.

This also explains why `git log -S` on `home_screen_ready_signal` found no
REQ-002 commit touching it: the key was never renamed or moved. Nothing about
the key, the resolver, or the routing changed — only the pump ordering in the
two harnesses.

## Impacted Surface

- `mobile/test/widget_test.dart`
- `mobile/test/app/feature_flags_test.dart`

No production code is implicated. `home_screen_ready_signal` remains the
runtime registry's declared `inAppFirstScreenSignal` and is emitted correctly.

## Fix Direction

Restore the ordering both parent commits required: clear the dwell first so
`pushReplacement` is called, then pump the frame that builds the pushed route
plus its 300ms `MaterialPageRoute` transition. This preserves STORY-032's
"never use `pumpAndSettle` at the composition root" constraint.

## Out-Of-Scope Findings

- **F-1 (runtime registry defect, DevOps).**
  `data/devops/system/runtime-command-registry.json` declares the launcher
  activity as `com.snapsofts.cupid/com.snapsofts.cupid.MainActivity`, which
  does not exist — `am start` fails with
  `Error: Activity class {...} does not exist`. The real activity is
  `com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
  (`adb shell cmd package resolve-activity --brief com.snapsofts.cupid`).
  Not changed here: the registry is outside this bug's write scope. Also
  reported during BUG-20260814-003.
- **F-2 (registry readiness check, DevOps).** The registry's `am start -W`
  readiness step reports `Status: timeout` for this app because
  `CupidAppBackground` animates forever, so the activity never goes idle. The
  `dumpsys activity activities` ResumedActivity poll is the reliable signal and
  did pass. `am start -W` alone will always look like a failure here.
