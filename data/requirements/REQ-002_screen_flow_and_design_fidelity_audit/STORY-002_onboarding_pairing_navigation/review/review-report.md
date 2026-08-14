# Review Report — STORY-002 Onboarding & Pairing Flow Navigation Correction

Outcome: PATCH_REQUIRED

Reviewer: Iris-QC
Date: 2026-08-14
Mode: Tier-3 scoped review, all 5 phases + synthesis
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Branch: codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-002
BaseHead: 2c9d1f06643234bbf0533d0e1f80e4e5d695ca6e
Worktree HEAD: 26e90e324b7138838cfd27494177cddcb6d87693
Phase commits: b623ff4 (P1), e199646 (P2), 3416466 (P3), 0807fd1 (P4), 0d51e80 (P5)

Phase evidence retained alongside this report:
`slice-p1-navigation-core.md`, `slice-p2-session-termination.md`.

## Acceptance Criteria

| AC | Verdict |
|---|---|
| AC1 — welcome → login/register, each leading to its correct next screen | **FAIL** — B1 |
| AC2 — otp → permissions → profileSetup → pairingChoice, no skip, no loopback | PASS |
| AC3 — waiting → paired → contract → vow → home, in order | PASS |
| AC4 — no header, no tab bar on every chain screen; 5-tab bar first on home | **PARTIAL** — R3 |
| AC5 — deliberate sign-out tears down session first, then routes to welcome | PASS |
| AC6 — mid-session refresh failure routes to login, not welcome | PASS on mechanism — R1 limits coverage |

One blocking defect (B1). The story cannot be marked DONE on this report.

## B1 (BLOCKING) — login resume to `profileSetup` throws and hard-locks the screen

`OnboardingProgressResolver.resolve()` returns `OnboardingNode.profileSetup`
for an account that is email-verified, unpaired, and has no display name
(`onboarding_progress_resolver.dart:41-43`). Both production callers pass that
result straight into `resetTo`:

- `login_screen.dart:154-160` (`_resolveAndRoute`, email sign-in)
- `welcome_screen.dart:88-94` (same method, social sign-in)

`service_locator.dart:366-421` deliberately does **not** register
`profileSetup` — the comment at :367 lists it with `invite`, `joinCode` and
`waiting` as nodes that need a runtime argument no `WidgetBuilder` can supply.
`OnboardingRouter._routeFor` (`onboarding_router.dart:71-75`) therefore throws
`OnboardingRouteNotRegistered`.

The throw is synchronous inside the non-async `resetTo`, so it surfaces as a
rejected future in `_resolveAndRoute`, which the `BlocConsumer` listener
(`login_screen.dart:170`) calls without `await` or `catchError` — an unhandled
zone error. `_resolving` is set at :156 and has no `finally`, so the sign-in
button stays in its busy state permanently. The user is hard-stuck on login
with no recovery path but reinstall; retrying reproduces it deterministically.

Reachability is ordinary, not exotic: any user who registers and verifies email
but leaves before finishing profile setup — or is simply killed by the OS at
that point — hits it on their next sign-in. This is exactly the resume scenario
ADR-2's rule table exists to serve.

This is an AC1 failure ("each of those in turn leads to its correct next
screen"). It is fixable inside this story: the resolver and both call sites are
STORY-002's own files. Note the fix is not a one-line registry addition — the
node was omitted for a real reason (`profileSetup` needs a resolved
`CupidProfile`), so the resume edge needs the same argument-carrying direct-push
treatment the other three unregistered nodes get, or an explicit guard.

### Why no test caught it

`auth_leg_edges_test.dart:99-110` builds its router from
`for (final OnboardingNode node in OnboardingNode.values)`, registering **every**
node. The test `login success for an account that is no display name resumes at
profileSetup` (:162, :269-288) passes against that harness and would pass
against any registry, including an empty production one. No test in the suite
asserts the production registry covers the nodes the resolver can return. See
R5.

## Verification Evidence (independently re-run, not inherited)

1. `flutter test test/core/navigation test/features/auth/.../auth_leg_edges_test.dart`
   — `+64: All tests passed!`, including the `profileSetup` resume case that B1
   shows is broken in production.
2. `flutter test test/features/pairing test/features/love_contracts` — `+175 -2`.
   Both failures are `waiting_screen_design_fidelity_test.dart:238` and
   `joincode_screen_design_test.dart:107`, each `Expected: <13> Actual: <11.5>`
   on a shared caption typography role. Both are in the pre-existing BaseHead
   failure set recorded by P5, and no STORY-002 commit touches a theme file, so
   they cannot have been introduced here. Out of scope per "Out of Scope" item 2.
3. `flutter analyze lib test` — 80 issues, all severity `info`, 0 errors,
   0 warnings, identical to the BaseHead baseline P5 recorded.
4. `git log 2c9d1f0..HEAD` — five phase commits, matching the tracking entries;
   `service_locator.dart` and `pair_gate_shell.dart` are the only files amended
   across phases, and both were re-read at HEAD.

## AC-by-AC basis

**AC1 — FAIL.** The branching edges themselves are correct: `welcome` → `login`
via `push` with welcome retained (`welcome_screen.dart:83-84`), `login` →
`forgotPassword`/`register` via `push` (`login_screen.dart:145-149`), `register`
success → `otp` via `replaceWith` (`register_screen.dart:137`), footer link
`register` → `login` via `replaceWith` (:127). The resume half fails on B1.

**AC2 — PASS.** `OnboardingChain._forwardOrder` encodes
`otp → permissions → profileSetup → pairingChoice` exactly as the UX table
states, and `onboarding_chain_test.dart` walks `register` to exhaustion and
asserts the full traversal list, so an inserted, dropped or reordered node fails
it. No-loopback is structural: `welcome`, `login` and `register` never appear in
the map's value set. The forward `permissions → profileSetup` edge is not
router-driven — no production caller invokes `goNext(permissions)` — so B1 does
not affect the forward path.

**AC3 — PASS.** Both pairing legs converge on `paired` through `resetTo`
(`joincode_screen.dart:83`, `waiting_screen.dart:90`), and `paired` is
registered (`service_locator.dart:396`). The tail then runs
`paired → loveContract` (`PairedScreen.onSignContract` → `goNext`, :398),
`loveContract → vow` (`love_contract_screen.dart:127` → `goNext`), and
`vow → home` via `resetTo` (:410-413). Every node on that path is registered.
`chain_tail_edges_test.dart` asserts the tail and a full `register → home`
traversal touching each node once.

**AC4 — PARTIAL.** The tab-bar half holds unconditionally, and
"first appears only on home" holds by construction: `home` maps to
`const PairGateShell()` (:420), the only place `CupidTabBar` mounts, and
`chain_chrome_guard_test.dart:262-270` asserts `home` is the sole chromed node.
The header half is breached on four screens — see R3.

**AC5 — PASS.** Ordering is structurally enforced, not incidental: the failure
path in `sign_out_cubit.dart:43-58` emits `SignOutFailed` and returns, so
`emit(userInitiated)` is unreachable unless teardown already completed. The
inline `pushAndRemoveUntil` to `WelcomeScreen` is gone from `sign_out_action.dart`,
with the `SignOutFailed` snackbar and focus-restore preserved.

**AC6 — PASS on the mechanism.** `cupid_auth_interceptor.dart:61-78` publishes
`refreshFailed` only on a genuinely failed refresh, before teardown, and still
forwards the original 401 unchanged without ever throwing. The two reasons map
to two different registered nodes through an exhaustive switch in
`session_termination_listener.dart`, and the inverted-pair guard required by
`master-plan.md` §6.4 is satisfied by mutual negative assertions. Coverage is
limited by R1.

## Findings disposition

All findings raised across the five phases are disposed here. Nothing is
carried forward unresolved except the deferrals listed as residual risks.

| id | Severity | Disposition |
|---|---|---|
| B1 | Blocking | Must fix before DONE. See above. |
| R1 | HIGH | Deferred — not fixable in this story's write scope. |
| R2 | MEDIUM | Deferred — pre-existing. |
| R3 | MEDIUM | Deferred — `add-bug`. |
| R4 | LOW | Deferred — optional polish. |
| R5 | LOW | Recommend fixing alongside B1. |
| P1-F1 `joinCode` two-outcome collapse | INFO | Closed — justified by ADR-4 inside the spec's own Tech Lead delegation. |
| P1-F2 resolver returns `loveContract` not `home` for paired-but-unvowed | INFO | Open question for PO/UX — stricter than `uiux-spec.md:31`'s literal wording and required by AC3's ordering. Needs acknowledgement, not code change. |
| P1-F3 `waiting` is not a login resume target | INFO | Closed as deferred — pre-disclosed by Tech Lead (ADR-2), backend-limited. Residual: an inviter who creates a code then cold-restarts resumes at `pairingChoice` and loses sight of the outstanding invite. Candidate post-wave `add-bug`. |
| P1-F4 `goNext` accumulates a back stack | INFO | **Closed.** Assessed across P3-P5 as P1 required. Back-stack accumulation survives only inside the post-pairing tail (`paired` → `loveContract` → `vow`), because both entries to `paired` use `resetTo` and clear everything before it. Backing up cannot reach `welcome`/`login`, so AC2's no-loopback rule holds. Not a defect. |
| P1-F5 resolver checks `partnerId` before email verification | INFO | Closed — intentional ordered rule table per ADR-2; a paired account with an unverified email is not reachable in practice. |
| P2-OBS-1 P2 mechanism intact after P4's rewrite | INFO | Closed — `SessionTerminationListener` is still the outermost wrapper at `pair_gate_shell.dart:86`, re-verified at HEAD. |
| P2-OBS-2 possible `OnboardingRouteNotRegistered` on the resume path | — | **Promoted to B1 and confirmed.** |

## Residual risks

- **R1 (HIGH) — session-termination listener covers fewer screens than AC5/AC6
  require.** `SessionTerminationListener` mounts only inside `PairGateShell`,
  but `ux/uiux-spec.md` scopes both ACs to "any authenticated screen", and
  `OnboardingRouter.resetTo` destroys that shell. The authenticated chain nodes
  `otp`, `pairingChoice`, `paired`, `loveContract` and `vow` are all uncovered:
  a sign-out or refresh failure on any of them produces no navigation at all.
  This is **the same defect** as the Cross-Story/Infra session-listener finding
  in the Scrum Master checkpoint and as P5 ratified deviation 2's disclosed
  `paired`→`loveContract`→`vow` gap — one defect, counted once, not three. It is
  not a regression (the single-root mount was mandated by the P2 phase plan, and
  `PairGateShell` was the authenticated root when P2 landed) and it is not
  fixable inside this story's write scope. Recommend a requirement-level
  follow-up that hoists the listener above the router, not another story patch.
- **R2 (MEDIUM, pre-existing) — AC5 has no production-reachable trigger.**
  `AppShell` passes no `authRepository` to `MeScreen`, and `SignOutAction` is
  gated behind `if (authRepository != null)`, so the sign-out affordance renders
  nowhere in the shipped app. AC5's mechanism is correct and fully tested; it is
  simply unreachable by a user today. Pre-dates this story.
- **R3 (MEDIUM) — four chain screens still render `CupidHeader`, breaching AC4.**
  `forgotPassword`, `otp`, `permissions` and `profileSetup`, pinned in
  `_trackedHeaderBreaches` (`chain_chrome_guard_test.dart:235-240`). The
  pin-and-defer design is sound and self-cleaning — a tracked breach is asserted
  `findsOneWidget`, so a screen that gets fixed fails the test and forces the set
  to shrink; it cannot rot into a blanket exemption. All four files belong to
  already-DONE stories and `master-plan.md` §5 forbids editing the bodies of
  `otp` and `permissions`, so STORY-002 genuinely cannot close this. Same defect
  as the checkpoint's CupidHeader/AC4 Cross-Story finding — counted once.
  Needs a post-wave `add-bug`; AC4 stays PARTIAL until then.
- **R4 (LOW) — mid-session re-auth does not reuse the §4b session-expired login
  variant** that the cold-launch path uses, so the user reaches login without the
  "your session has expired" affordance. Not an AC6 violation; AC6 only fixes the
  destination.
- **R5 (LOW) — router test harnesses register every node**, so no test can catch
  an unregistered-node regression. Recommend a guard test asserting the
  production `OnboardingRouter` registry contains every node
  `OnboardingProgressResolver.resolve()` can return. Cheap, and it would have
  caught B1.

## Required before DONE

1. Fix B1. Both `login_screen.dart:159` and `welcome_screen.dart:93` must
   handle a `profileSetup` resolver result without throwing.
2. Add the R5 guard test, or an equivalent assertion over the production
   registry, so the fix cannot silently regress.
3. Re-run `flutter analyze lib test` and the navigation/auth suites; confirm the
   pairing design-fidelity failures remain the pre-existing pair and no new
   failure appears.
4. Scrum Master: raise `add-bug` entries for R3 and P1-F3, and get PO/UX
   acknowledgement on P1-F2.

Outcome recorded above: PATCH_REQUIRED.

REVIEW_SLICE_COMPLETE: YES (all 5 slices)
REVIEW_COMPLETE: YES
