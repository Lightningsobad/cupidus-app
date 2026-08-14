# Review Report — STORY-002 Onboarding & Pairing Flow Navigation Correction

Outcome: PARTIAL_SLICE_ONLY — 1 of 5 slices reviewed; NOT a story verdict; does NOT satisfy the DONE gate

> **DO NOT MARK STORY-002 DONE ON THIS FILE.** Per `AGENTS.md` the DONE gate
> requires an approving outcome value; `PARTIAL_SLICE_ONLY` is deliberately not
> one and fails closed. This file currently holds the results of slice P1
> (navigation core) only. Slices P2-P5 were reviewed by other agents and are not
> represented here. Scrum Master must replace this file with the aggregated
> story-level verdict once all 5 slice reports exist.

Reviewer (this slice): Iris-QC
Date: 2026-08-14
Mode: scoped-slice (Tier-3), slice 1 of 5
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
BaseHead: 2c9d1f06643234bbf0533d0e1f80e4e5d695ca6e
Worktree HEAD: 0d51e8031841bbaaf16be5c98a928b19495b61ba
Phase commit in scope: b623ff4

Detailed slice report: `slice-p1-navigation-core.md` (same directory)

## Why this file exists in this form

STORY-002 changes 45 files across 5 phases, over the Tier-2 review caps, so
Scrum Master split it into 5 phase slices. The P1 handoff explicitly forbade a
story-level Outcome line and pinned output to `slice-p1-navigation-core.md`.
The repository's reviewer guard (`validate-reviewer-handoff.sh`,
`NO_REVIEW_CONTEXT`) independently requires a `review-report.md` carrying an
`Outcome:` line. This file satisfies the guard while its non-approving value
keeps the DONE gate closed, which is the accurate state: no aggregate verdict
exists yet.

## Slice P1 Scope — Navigation Core

Six net-new files, 541 insertions, 0 deletions, between BaseHead and HEAD:

- `mobile/lib/core/navigation/onboarding_chain.dart` (+55)
- `mobile/lib/core/navigation/onboarding_router.dart` (+81)
- `mobile/lib/core/navigation/onboarding_progress_resolver.dart` (+50)
- `mobile/test/core/navigation/onboarding_chain_test.dart` (+97)
- `mobile/test/core/navigation/onboarding_router_test.dart` (+118)
- `mobile/test/core/navigation/onboarding_progress_resolver_test.dart` (+140)

Not covered by this slice: P2 session termination, P3 auth-leg screens, P4
pairing-leg screens & chrome, P5 post-pairing tail & chrome guard — including
`pair_gate_shell.dart` and `service_locator.dart`.

## Acceptance Criteria — navigation-core scope only

| AC | Verdict | Basis |
|---|---|---|
| AC1 — welcome to login/register, each leading to its correct next screen | PASS | Branching nodes correctly modelled with no successor; `register`→`otp` present; `push` retains the caller so `forgot_password`→back→`login` works; login resume handled by `OnboardingProgressResolver`. Auth call sites are P3 scope. |
| AC2 — otp → permissions → profileSetup → pairingChoice, no skip, no loop | PASS | Sequence matches the UX table exactly; the chain test walks from `register` to exhaustion and asserts the full traversal list, so an inserted, dropped or reordered node fails it; no-loopback holds structurally. |
| AC3 — pairing legs reach the correct next node, no unreachable/loopback | PASS (chain-graph portion) | `invite`→`waiting`→`paired`, `joinCode`→`paired`, `paired`→`loveContract`→`vow`→`home` all match spec; DAG with no cycle, self-edge or orphan target. Branch-entry reachability is P4 scope. |

AC4, AC5, AC6 are out of this slice's scope and are NOT assessed here.

Blocking defects in slice P1: NONE.

## Verification Evidence (independently re-run, not inherited)

1. `flutter analyze lib/core/navigation test/core/navigation` — 17 issues, all
   severity `info`, all `prefer_initializing_formals`, all in
   `lib/core/navigation/pair_gate_shell.dart` (P2/P4 scope). Zero issues in any
   of the 6 files under review.
2. Targeted suite over the 3 test files — `+19: All tests passed!`, matching the
   "targeted 19/19" figure recorded in the `story_master.md` P1 entry.
3. `git log 2c9d1f0..HEAD` over the 6 paths returns exactly one commit
   (`b623ff4`), confirming the P1-verified state is still the HEAD state and no
   later phase silently amended it.

Full-suite 939/939 was not re-run here; it is a story-level gate and P5's
tracking entry supersedes it (+1221 ~2 -6 against an identical pre-existing
BaseHead failure set).

## Key Confirmations

- `OnboardingChain._forwardOrder` holds exactly 10 entries matching
  `ux/uiux-spec.md` "Corrected Navigation Graph" row-for-row, with no invented,
  reordered or dropped edge. Branching (`welcome`, `login`, `pairingChoice`) and
  terminal (`forgotPassword`, `home`) nodes are deliberately absent so no fake
  successor is encoded.
- `OnboardingRouter.goNext` (`onboarding_router.dart:44-50`) resolves
  `OnboardingChain.next(from)` — the node being left — and passes that target to
  `push` with no second chain lookup. Confirmed correct from the code as it
  stands, independent of the Scrum Master self-correction recorded this session.
- Throws are synchronous (`goNext`/`push`/`replaceWith` are not `async`), so the
  `throwsA` assertions genuinely execute rather than passing on an unawaited
  future.
- No-loopback is structural, not merely asserted: `welcome`, `login` and
  `register` never appear in the map's value set.

## Findings — slice P1 (all INFO / deferrable)

- **F1** `joinCode` collapses the spec's two-outcome node to a single
  `joinCode`→`paired` edge. Justified by ADR-4 inside the spec's own explicit
  Tech Lead delegation.
- **F2** Resolver returns `loveContract`, not `home`, for a paired-but-unvowed
  user — stricter than `uiux-spec.md:31`'s literal wording and required by AC3's
  ordering. Needs PO/UX acknowledgement at story level.
- **F3** `waiting` is not a login resume target. Pre-disclosed by Tech Lead
  (`story_master.md:261-263`, ADR-2); backend-limited. Residual: an inviter who
  creates a code then cold-restarts resumes at `pairingChoice`, losing sight of
  the outstanding invite. Candidate post-wave `add-bug`.
- **F4** `goNext` delegates to `push`, so the chain accumulates a back stack — a
  user on `pairingChoice` can back into `profileSetup`. Correctness is decided at
  the P3-P5 call sites; must be closed across slices, not inside navigation core.
- **F5** Resolver checks `partnerId` before email verification, so a paired
  account with an unverified email would never route to `otp`. Intentional
  ordered rule table per ADR-2; state not reachable in practice.

## Checked And Cleared (do not re-open)

`OnboardingProgressResolver` declares private named initializing formals
(`required this._fetchProfile`) while its test calls them as `fetchProfile:`.
This resembles a Dart `private_optional_parameter` error, but the analyzer emits
no diagnostic and the tests compile and pass, so the private-named-parameter
language feature is available in this SDK. Not a defect.

## Required Follow-Up By Scrum Master

1. Collect the P2-P5 slice reports and replace this file with the aggregated
   story-level verdict. Do not derive that verdict from slice P1 alone.
2. Close F4 across slices; close F2 with PO/UX.
3. Consider a post-wave `add-bug` for F3 and for the 4 pre-existing `CupidHeader`
   breaches P5 pinned for AC4.

REVIEW_SLICE_COMPLETE: YES (slice P1 navigation core)
