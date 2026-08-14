# Review Slice P2 — Session Termination Signal (AC5 / AC6)

Outcome: PARTIAL_SLICE_ONLY — slice P2 of 5; NOT a story verdict; does not
satisfy the DONE gate.

Reviewer: Iris-QC | Date: 2026-08-14
Story: STORY-002 | Requirement: REQ-002_screen_flow_and_design_fidelity_audit
BaseHead: 2c9d1f06643234bbf0533d0e1f80e4e5d695ca6e
Branch: codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-002
Slice scope: P2 only (`coding-plan/phase-P2-session-termination-signal.md`)

## Slice verdict

| AC | Verdict | Basis |
|---|---|---|
| AC5 — deliberate sign-out: teardown first, then route to `welcome` | PASS | Ordering enforced in `SignOutCubit`, destination mapped in `SessionTerminationListener`, both directly tested |
| AC6 — mid-session refresh failure routes to `login`, not `welcome` | PASS (mechanism) with one HIGH residual on coverage surface | Publisher/consumer wiring correct and tested; listener mount point does not span every authenticated screen the UX spec names |

No blocking defect found in P2's own mechanism. One HIGH and two MEDIUM
residuals are handed to final synthesis; one of the three is a wider instance
of the gap Scrum Master already disclosed, and is flagged as such rather than
as a new independent defect.

## Files reviewed (P2 write scope, at HEAD)

Sources:
- `mobile/lib/core/auth/session_termination.dart` (new, 29 lines)
- `mobile/lib/core/navigation/session_termination_listener.dart` (new, 78 lines)
- `mobile/lib/core/auth/cupid_auth_interceptor.dart` (+13)
- `mobile/lib/core/di/service_locator.dart` (P2 hunks only)
- `mobile/lib/features/auth/presentation/sign_out_cubit.dart` (+15 -5)
- `mobile/lib/features/auth/presentation/sign_out_action.dart` (+29 -20)
- `mobile/lib/core/navigation/pair_gate_shell.dart` (listener mount only)

Tests:
- `mobile/test/core/auth/session_termination_test.dart` (new, 122 lines)
- `mobile/test/core/auth/cupid_auth_interceptor_test.dart` (+76)
- `mobile/test/core/navigation/session_termination_listener_test.dart` (new, 171 lines)
- `mobile/test/features/auth/presentation/sign_out_action_test.dart` (+28 -6)

Cross-phase amendment check
(`git log 2c9d1f0..HEAD -- <P2 files>`): P2's own new files, the interceptor,
the cubit and the action were touched by exactly one commit (`e199646`, P2).
Only `service_locator.dart` (P3/P4/P5) and `pair_gate_shell.dart` (P4) were
touched later; both were re-read at HEAD and the P2 mechanism survives intact
in each — see finding OBS-1. No silent amendment of P2's signal path.

## Evidence — independently re-run by reviewer

Toolchain resolution note: `flutter` is not on the default `PATH` in this
session; commands were run with `PATH=/Users/alantravala/flutter/bin:$PATH`
from the story worktree's `mobile/` directory.

- `flutter test test/core/auth/session_termination_test.dart
  test/core/auth/cupid_auth_interceptor_test.dart
  test/core/navigation/session_termination_listener_test.dart
  test/features/auth/presentation/sign_out_action_test.dart`
  → **21/21 passed, "All tests passed!"** (4 notifier/cubit + 9 interceptor +
  6 listener + 2 sign-out action). This independently confirms mobile-dev's
  per-file counts in the phase doc's evidence section.
- `flutter analyze` over the P2 file list → **17 issues, all `info`, zero
  `error`, zero `warning`**. Every one is `prefer_initializing_formals` on
  `pair_gate_shell.dart:59-67` and `:116-123`, i.e. the pre-existing
  constructor style of P4's rewritten file. **Zero issues in any file P2
  created**, and zero on the mount P2 added. Non-zero exit is `flutter
  analyze`'s normal behaviour when any `info` exists.

## AC5 — deliberate sign-out → teardown, then `welcome`

Spec (`ux/uiux-spec.md` §"Sign-out (any authenticated screen)"): "session torn
down → `welcome`. Ordering is fixed: teardown happens before navigation fires
(AC5). Do not route to `welcome` first and teardown after."

Verified:
1. Ordering is structurally enforced, not incidental
   (`sign_out_cubit.dart:43-58`): `await _repository.signOut()` runs inside
   `try`; the `catch` emits `SignOutFailed` and **returns**; only past that
   point does the method emit `SignOutSuccess` and then
   `_sessionTermination?.emit(userInitiated)`. The signal is therefore
   unreachable unless teardown already completed. The inline comment marks the
   invariant ("Do not move this above the await").
2. Destination is correct and centralised
   (`session_termination_listener.dart:67-70`): `userInitiated` →
   `OnboardingNode.welcome` via an exhaustive `switch` expression, so a future
   enum member is a compile error rather than a silent fall-through.
3. The inline `pushAndRemoveUntil` to `WelcomeScreen` is genuinely gone from
   `sign_out_action.dart`; the `BlocConsumer` listener now handles only
   `SignOutFailed`, and the `SignOutFailed` snackbar plus focus-restore
   behaviour required by the phase doc are unchanged
   (`sign_out_action.dart:71-78`).
4. Route resolution cannot throw at the AC5 destination:
   `OnboardingRouter._routeFor` raises `OnboardingRouteNotRegistered` for an
   unregistered node, and `OnboardingNode.welcome` **is** registered
   (`service_locator.dart:380-382`), with its `getIt<AuthRepository>()`
   dependency registered at `service_locator.dart:346`.
5. Tests assert the ordering directly, not just the end state:
   `session_termination_test.dart:75-98` latches `teardownDone` at signal
   delivery and asserts `teardownDoneWhenSignalled isTrue`;
   `:100-120` asserts no reason is published when teardown throws.
   `session_termination_listener_test.dart:46-69` asserts `welcome` is found
   and `login`/`app-root` are not.

AC5 = **PASS**. See F2 for a reachability caveat that does not change this
verdict.

## AC6 — mid-session refresh failure → `login`, not `welcome`

Spec (`ux/uiux-spec.md` §"Mid-session forced re-auth (any authenticated
screen)"): "refresh-token failure detected during active use (not cold launch)
→ `login`. Must remain visually/behaviorally distinct from the sign-out target
(`login`, not `welcome`)."

Verified:
1. The publisher fires on exactly the right branch
   (`cupid_auth_interceptor.dart:61-78`): only after a 401 that is not already
   a retry, and only when `_refreshToken()` returned `null` (which
   `_forceRefresh` also produces for a *thrown* refresh, per ADR-011c). A
   successful refresh takes the retry path and publishes nothing.
2. The interceptor's existing contract is preserved: the emit is a
   null-safe call to a method that no-ops when the controller is closed, so
   the interceptor still never throws; `handler.next(err)` still forwards the
   **original** 401 unchanged.
3. Emission precedes teardown, which is the whole point of D6 — once
   `_onSessionExpired()` runs, the path is indistinguishable from a deliberate
   sign-out in `CupidSession`. The test proves ordering by overriding `emit`
   rather than by observing the stream, correctly noting that the broadcast
   controller's async delivery cannot establish ordering
   (`cupid_auth_interceptor_test.dart`, `_RecordingNotifier`); it asserts
   `order == ['emit:refreshFailed', 'teardown']` and
   `handler.forwardedError same(err)`.
4. Injection is real in production, not just in tests:
   `service_locator.dart` registers `SessionTerminationNotifier` as a lazy
   singleton and passes it into `CupidAuthInterceptor(sessionTermination: ...)`.
   Without this the AC6 path would be silently dead; it is wired.
5. Destination is correct and registered: `refreshFailed` →
   `OnboardingNode.login` (`session_termination_listener.dart:69`), and `login`
   is present in the router registry (`service_locator.dart:382-384`).
6. AC6's "not at cold launch" qualifier is respected by construction — this
   publisher only fires on an in-flight HTTP 401, never on the splash/session-
   gate path.
7. The inverted-pair guard demanded by `master-plan.md` §6.4 is satisfied:
   `session_termination_listener_test.dart:46-92` asserts **both** directions
   with mutual negative assertions, so swapping the two arms fails two tests.

AC6 = **PASS on the P2 mechanism**, with residual F1 below on how much of the
app that mechanism can actually cover.

## Findings

### F1 (HIGH, residual — wider instance of the disclosed gap; for synthesis)

`SessionTerminationListener` is mounted only inside `PairGateShell`
(`pair_gate_shell.dart:86`). The UX spec scopes **both** AC5 and AC6 to "any
authenticated screen". Several authenticated screens are reached through
`OnboardingRouter.resetTo`, which is `pushAndRemoveUntil(..., (route) => false)`
(`onboarding_router.dart:65-69`) and therefore destroys the `PairGateShell`
route and unmounts the listener with it. On those screens a published reason
lands on a broadcast stream with no subscriber and is dropped, so neither AC5
nor AC6 navigates.

Scrum Master disclosed this for the `paired` → `loveContract` → `vow` tail
(P5's tracking entry), and that portion is explicitly **not** re-litigated
here. The reviewable addition is that the same mechanism leaves two further
authenticated nodes uncovered, on a path P5's disclosure does not name:

- `login_screen.dart:159` (`_resolveAndRoute`) and `welcome_screen.dart:93`
  both call `_router.resetTo(context, target)`.
- `OnboardingProgressResolver.resolve()` can return `otp`, `profileSetup`,
  `pairingChoice`, `loveContract` or `home`
  (`onboarding_progress_resolver.dart:27-49`).
- Of the registered ones, only `OnboardingNode.home` rebuilds
  `PairGateShell` (`service_locator.dart:420`). `otp` and `pairingChoice` are
  registered as **bare** screens (`service_locator.dart:390-392`), so an
  authenticated user resumed onto either has no listener mounted.

Both are screens that issue authenticated backend calls (pairing repository,
Firebase reload), so a mid-session 401 there is realistic rather than
theoretical — this is AC6's own scenario landing on an uncovered surface.

Why this is not raised as a P2 blocking defect: the mount point was mandated by
the phase plan ("mounted exactly once at the app root, inside `PairGateShell`
alongside the existing `ReminderOverlayHost` mount"), and at P2's commit
`PairGateShell` *was* the authenticated root (`splash_screen.dart:116`). The
uncovered surface was created afterwards by P3/P4/P5 introducing sibling
authenticated roots via `resetTo`. The fix — hoisting the listener above the
router, e.g. onto the `MaterialApp` in `mobile/lib/app/cupid_app.dart` — lies
outside P2's declared write scope and touches P1/P5 files, so it cannot be
resolved inside this slice. Recommend Scrum Master fold F1 into the final
synthesis alongside the already-disclosed tail gap and decide there whether the
combined surface is acceptable for `DONE` or needs a follow-up story.

### F2 (MEDIUM, pre-existing, not introduced by P2)

AC5's mechanism has no production-reachable trigger. `SignOutAction`'s only
non-preview call site is `me_screen.dart:265-268`, guarded by
`if (authRepository != null)`, and `AppShell` — per `me_screen.dart:63-64`,
"the only production caller" — passes nothing. So the sign-out row renders
nowhere in the shipped app. This predates STORY-002 and P2 explicitly did not
take the affordance into scope; P2 in fact improves the position, since routing
now works from any call site added later. Noted so that the final synthesis
does not record AC5 as demonstrated end-to-end on device when it is currently
demonstrable only at the widget/unit level.

### F3 (LOW / optional, design fidelity)

`LoginScreen` has a `sessionExpired` variant (§4b heading plus a one-shot
snackbar and email prefill, `login_screen.dart:53, 64, 127-128, 218`). The
cold-launch expiry path uses it (`splash_screen.dart:119-121,
sessionExpired: true`), but AC6's mid-session path routes through the router
registry entry `LoginScreen(authRepository: ...)`
(`service_locator.dart:382-384`), where `sessionExpired` defaults to `false`.
The two paths therefore present the identical condition differently, and the
mid-session user gets no explanation for the interruption.

This is **not** an AC6 violation: the spec's fidelity requirement is that the
target stay "visually/behaviorally distinct from the sign-out target (`login`,
not `welcome`)", which P2 satisfies. Raised only because REQ-002 is a design-
fidelity audit and the variant already exists at no build cost.

### OBS-1 (observation, no action)

`service_locator.dart:415-419`'s comment documents that the `home` node
rebuilds `PairGateShell` and thereby "remounts `SessionTerminationListener` and
`ReminderOverlayHost`, which the chain's earlier `resetTo` calls discard along
with the original shell root." P2's mechanism is intact at HEAD after P4's
115-line rewrite of `pair_gate_shell.dart` — the listener remains the outermost
wrapper in `build` (`pair_gate_shell.dart:86-102`), and the regression test
`session_termination_listener_test.dart:142-156` ("PairGateShell mounts the
listener exactly once") passes at HEAD, which is what makes this
verifiable rather than assumed.

### OBS-2 (observation, out of slice — for the P3 reviewer, no verdict here)

Not P2 scope and deliberately given no verdict, but surfaced because it is a
crash path on the same call site F1 analyses. `login_screen.dart:159` does
`await _router.resetTo(context, target)` with `target` straight from
`OnboardingProgressResolver.resolve()`, which can return
`OnboardingNode.profileSetup` (`onboarding_progress_resolver.dart:41-43`) for a
verified user with a null `displayName`. `profileSetup` is deliberately absent
from the router registry (`service_locator.dart` comment: it "needs a runtime
argument … that no `WidgetBuilder` can supply"), and `_routeFor` throws
`OnboardingRouteNotRegistered` for an unregistered node
(`onboarding_router.dart:71-75`). No guard sits between the two. The P3 slice
owns confirming or dismissing this.

## Residual risks carried to synthesis

1. F1 — AC5/AC6 coverage is narrower than the spec's "any authenticated
   screen", on a wider surface than the disclosed `paired`→`loveContract`→`vow`
   tail. Resolution requires a mount point above the router.
2. F2 — AC5 has no production-reachable trigger today.
3. F3 — mid-session re-auth does not reuse the existing §4b session-expired
   login variant.
4. OBS-2 — possible unregistered-route throw on the login resume path, owned
   by slice P3.

## Scope boundaries honoured

- `review/review-report.md` (story root) was not read for edit, not modified
  and not overwritten; the sibling-shared `PARTIAL_SLICE_ONLY` placeholder
  there is untouched.
- No P1, P3, P4 or P5 file scope was given a verdict. P1's
  `slice-p1-navigation-core.md` conclusions are taken as settled and its
  navigation-core files were not re-reviewed.
- No story-level `Outcome` for STORY-002 is produced by this slice.
- All writes stayed inside
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-002_onboarding_pairing_navigation/review/`.

REVIEW_SLICE_COMPLETE: YES (slice P2 session termination)
