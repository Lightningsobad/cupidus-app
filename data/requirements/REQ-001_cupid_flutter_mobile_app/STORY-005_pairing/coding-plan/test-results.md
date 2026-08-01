# STORY-005 Pairing — P5 Verification Evidence

Scope: mobile-dev P5 (final verification phase). No new feature code; P0-P4
implementation is complete. This phase ran full `flutter analyze` and full
`flutter test`, confirmed AC1-AC4 traceability against master-plan §5's
risk-surface table, and fixed one cross-cutting regression surfaced by the
full-suite run (see "Regression found and fixed" below).

## Post-review patch (compact-story-review PATCH_REQUIRED)

The first `compact-story-review` pass (`review/review-report.md`) returned
`PATCH_REQUIRED`: P0/D1/P1's shell-gate mechanics were correct, but no
production code actually wired the four pairing screens together, so a real
user could not reach or complete pairing (rule 12e1, AC1/AC2 fail). This patch
wires the navigation chain; no D1-D4 decision, poll lifecycle, or `AppShell`
gating mechanic was touched.

Changes:
- `mobile/lib/core/navigation/app_shell.dart`: `_PairingStack`'s "Pair with
  your partner" button now pushes `InviteScreen` (real navigation, not
  `onPressed: () {}`). Added a second, literal reading of
  `ux/uiux-spec.md` §2's "OR as the direct entry point for a user who already
  has a code": a secondary "I already have a code" action that pushes
  `JoincodeScreen` directly from the shell, rather than adding an in-`invite`
  toggle. `AppShell` gained `createInviteCubit`/`createJoincodeCubit` test
  seams (mirroring the existing `createPairGateCubit` pattern) so widget
  tests can drive both screens without a live `getIt` registration.
- `mobile/lib/core/navigation/app_shell.dart`: `JoincodeScreen.onPaired`
  (pushed from the shell) now navigates to `PairedScreen` via
  `pushAndRemoveUntil`, clearing the pairing stack so back navigation cannot
  return into it.
- `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`: the
  `WaitingScreen` pushed from `_copyAndAdvance` now supplies `onPaired`,
  navigating to `PairedScreen` (same `pushAndRemoveUntil` clearing behavior)
  once `WaitingCubit`/`PartnerLinkPoller` detects the partner has joined.
- `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart`:
  replaced the `pair_gate_cubit_test.dart:85-88` assertion the review flagged
  ("Reachable: tappable without throwing" — it only checked the pairing stack
  was still shown after the tap) with an assertion that tapping "Pair with
  your partner" actually navigates to `InviteScreen`. Added two more tests:
  "I already have a code" navigates directly to `JoincodeScreen`, and
  accepting a code through that path navigates through to `PairedScreen`.
- `mobile/test/features/pairing/presentation/invite_screen_test.dart`: added
  a test proving `WaitingScreen`'s production `onPaired` wiring (added above)
  actually navigates to `PairedScreen` once the partner is detected, not just
  that the callback fires.

## Entry Point Reachability

Reachable: YES

Concrete navigation path (both AC1 and AC2, from the app's actual navigation
graph, no test-only seam required):

- Unpaired app root (`AppShell`'s `_PairingStack`, `ux/uiux-spec.md` §2's
  entry point) → tap "Pair with your partner" → `InviteScreen` (AC1: generate
  code, share/copy) → `WaitingScreen` (poll `partnerId`) → on poll success →
  `PairedScreen`.
- Unpaired app root → tap "I already have a code" → `JoincodeScreen` (AC2:
  enter code, "Pair up") → on `accept` success → `PairedScreen`.

Verified by (all exercise the real production call sites, not test-fake
navigation targets):
- `pair_gate_cubit_test.dart`: "unpaired routes into the pairing stack ... a
  reachable 'Pair with your partner' entry action" (now asserts
  `find.byType(InviteScreen)` after the tap); "'I already have a code'
  navigates directly to JoincodeScreen"; "accepting a code via 'I already
  have a code' navigates through to PairedScreen (onPaired production
  wiring)".
- `invite_screen_test.dart`: "detecting a partner on WaitingScreen navigates
  through to PairedScreen (onPaired production wiring)".

Interpretation note (per the review's stop rule): `ux/uiux-spec.md` §2
documents `joincode` as reachable "via invite's 'I am the one with the code'
toggle, OR as the direct entry point for a user who already has a code". This
patch took the most literal reading of the second clause — a direct
shell-level entry point — rather than also adding an in-`invite` toggle,
since the direct entry point alone satisfies the documented alternate path
without inventing new UX beyond the spec.

Still open (not resolved by this patch, per the review's own scoping): rule
12e2's per-story rendered visual-fidelity check (`visual-fidelity/`) for
`invite`/`joincode`/`waiting`/`paired` — the review noted this depends on the
navigation fix landing first and remains a reviewer-side follow-up.

## `flutter analyze` (scoped to `lib/` `test/` — `build/` is a gitignored,
stale iOS pod-install artifact directory containing a vendored `flutterfire`
test fixture package that does not belong to this project's source tree and
is excluded from the scope of this verification)

- 0 errors, 0 warnings.
- 27 pre-existing `prefer_initializing_formals` info-level lints, spread
  across app-wide files (realtime, auth, pairing) predating this phase.
  Non-blocking, not introduced by STORY-005.

## `flutter test` (full suite, post-patch)

- 188 tests, 0 failures. `All tests passed!`
- Includes all 69 tests under `mobile/test/features/pairing/**` (66 from the
  initial P5 pass + 3 added by this patch for entry-point reachability) plus
  the rest of the app's test suite (auth, realtime, design system, app-boot).

## Regression found and fixed

Running the full suite (not just the pairing subtree) surfaced 3 pre-existing
failures caused by STORY-005 P1's `AppShell` change:

- `mobile/test/widget_test.dart`: "App boots to the home screen ready signal"
- `mobile/test/app/feature_flags_test.dart`: 2 tests asserting
  `home_screen_ready_signal` after a bare `pumpWidget(const CupidApp())`

Root cause: before STORY-005, `AppShell` rendered `HomeScreen` unconditionally
(no dependency). P1 changed `AppShell`'s default path to resolve
`PairGateCubit` via `getIt<PairingRepository>()`. These two test files pump
`CupidApp()` directly with no DI bootstrap (`setupServiceLocator()` is only
called from production `main()`), so the `BlocProvider.create` callback threw,
which `provider` surfaced as a `type 'Null' is not a subtype of type
'PairGateCubit'` cast error during widget-tree disposal. Separately, even with
DI fixed, a single un-pumped frame lands on `PairGateChecking` (spinner), not
`HomeScreen` — these tests' expectations were written against the pre-P1
unconditional-`HomeScreen` contract and needed updating for the new AC4 gate,
not just a crash fix.

Fix (smallest surface, mirrors `AppShell`'s existing test seam
`createPairGateCubit`): added the same optional
`PairGateCubit Function()? createPairGateCubit` parameter to `CupidApp`,
forwarded to `AppShell`, default `null` (no behavior change in production —
`main.dart` still boots the real `getIt`-backed cubit). Updated the two
failing tests to supply a fake resolving to `PairGatePaired` and to `pump()`
once before asserting the ready-signal key, matching the pattern already used
in `pair_gate_cubit_test.dart`.

Files touched beyond the declared pairing test tree (both were already listed
in master-plan §3 P1's Write Scope, and needed a one-line, backward-compatible
addition each):
- `mobile/lib/app/cupid_app.dart`
- `mobile/test/widget_test.dart`
- `mobile/test/app/feature_flags_test.dart`

No `mobile/lib/features/pairing/**` production code changed in this phase.

## AC → Test Traceability

| AC | Description | Covering tests |
|---|---|---|
| AC1 | Generate/send an invitation | `pairing_repository_test.dart` ("generateInvitation ..." ×3); `invite_cubit_test.dart`; `invite_screen_test.dart` ("renders the code and a live expiresAt countdown" ×9, "an idempotent refresh does not flash a spinner", "copy announces via a snackbar and advances to waiting", "share announces a distinct message and advances to waiting", "a generation failure shows an error with a retry action", "detecting a partner on WaitingScreen navigates through to PairedScreen (onPaired production wiring)"); `pair_gate_cubit_test.dart` (real navigation from `AppShell` into `InviteScreen`) |
| AC2 | Invited partner accepts, both sides reflect active pair | `pairing_repository_test.dart` ("acceptInvitation succeeds without throwing on 200", "getPartnerLink parses a non-null/null partnerId"); `joincode_cubit_test.dart`; `joincode_screen_test.dart` ("success calls onPaired" ×6); `partner_link_poller_test.dart` (poll → paired transition); `waiting_cubit_test.dart` / `waiting_screen_test.dart` ("a poll transition to paired updates the status text and invokes onPaired"); `paired_screen_test.dart` (both arrival paths converge, live-region announce); `pair_gate_cubit_test.dart` (real navigation from `AppShell` into `JoincodeScreen`, and through to `PairedScreen` on accept) |
| AC3 | Couple-only enforcement: reject a 3rd invite against an already-paired user, per-case UI | `pairing_repository_test.dart` (each 409 mapped to a distinct sealed failure: `AlreadyPairedFailure`, `SelfInviteFailure`, `InviterAlreadyPairedFailure`, `UnmappedPairingFailure`, plus 404/400/500 mapping); `joincode_screen_test.dart` ("disables the field and swaps the label for a spinner while submitting, with no layout shift") — each failure renders its own inline vi/en line, never a raw backend string, button re-enables, no modal |
| AC4 | Paired vs. unpaired state visually distinguishable; gates paired-only features | `pair_gate_cubit_test.dart`: `PairGateCubit` unit tests (Checking/Unpaired/Paired/fail-safe states) + `AppShell` gate widget tests ("unpaired routes into the pairing stack with no tab bar and a reachable 'Pair with your partner' entry action" ×10, "paired routes into the main tab shell", "a failed check falls back to the pairing stack, never exposing the tab shell while unresolved") — the entry action now asserts real navigation into `InviteScreen`, replacing the prior "tappable without throwing" assertion the review flagged |

## Verification Contract Risk Surfaces (master-plan §5)

| Risk surface | Gate | Result |
|---|---|---|
| Invitation body parse / typing gap (D4) | P0 unit tests over recorded response bodies | PASS — `pairing_repository_test.dart` covers code/expiresAt parse and malformed-body `UnexpectedFailure` |
| Couple-only enforcement (AC3) | P3 widget test per 409 case | PASS — each 409 message maps to a distinct sealed failure, never a raw string, in both repository and joincode-screen tests |
| Poll lifecycle (D1) | P0 unit + P2 widget test | PASS — `partner_link_poller_test.dart` covers 3s/10s interval switch, hard stop at 10 min/`expiresAt`, dispose/background/foreground-resume, silent-failure-reschedule; `waiting_screen_test.dart` covers the widget-level poll → paired transition and manual-refresh fallback |
| Shell gating (AC4) | P1 widget test | PASS — `pair_gate_cubit_test.dart` AppShell tests confirm no paired-only surface (`HomeScreen`, tab bar) is reachable while unpaired or unresolved |

## Excluded by policy (master-plan §5)

Backend e2e, Playwright/browser e2e, traces, scenario reruns,
repository-root script gates, and runtime startup smoke — none run in this
phase, per policy.

TEST_RESULTS_COMPLETE
