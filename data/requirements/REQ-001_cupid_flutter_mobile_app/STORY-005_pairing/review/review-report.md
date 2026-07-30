---
story_status_recommendation: "IN_PROGRESS"
implementation_status_recommendation: "UNCHECK"
reviewed_at: 2026-07-30
reviewed_by: Reviewer
---

# Review Report: STORY-005 Pairing / 1:1 Connection

Outcome: PATCH_REQUIRED

## Scope Gate (inline — compact-story-review)

- Review gate: `compact-story-review`
- Scope Gate: inline (WriteScope for this run authorizes only `review/review-report.md`, no separate `scope-gate.md`)
- Governing artifacts: `story_master.md`, `ux/uiux-spec.md`, `coding-plan/master-plan.md`, `coding-plan/test-results.md`
- Diff baseline: `git -C <Worktree> diff 0a467d03babf1ed4102c3fab09c61b2dec941a0b` (commits aad1705..b9cba43)
- Source/test files read in full: `mobile/lib/features/pairing/data/pairing_repository.dart`, `pairing_failure.dart`, `partner_link_poller.dart`, `mobile/lib/core/navigation/app_shell.dart`, `mobile/lib/app/cupid_app.dart`, `mobile/lib/features/pairing/presentation/invite_cubit.dart`, `screens/invite_screen.dart`, `screens/joincode_screen.dart`, `screens/waiting_screen.dart`, `screens/paired_screen.dart`, `mobile/lib/core/di/service_locator.dart`, `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart`
- Query keys used: D1 poll contract (interval/hard-stop/dispose/background), D4 hand-constructed Dio + 409 mapping, AC4 shell gating, entry-point wiring, screen-to-screen navigation seams (`onPaired`)
- Not read (not needed to resolve this review's blocking finding): remaining cubit/screen test files, `pairing_strings.dart`, `pairing_failure_text.dart`, `joincode_cubit.dart`, `waiting_cubit.dart` bodies — behavior already evidenced by `test-results.md`'s AC-traceability table and not implicated in the finding below.

## Reviewed Scope

- Story complexity: `standard`
- Code scope reviewed: mobile-only vertical slice (P0 data/poller, P1 shell gate, P2 invite/waiting, P3 joincode, P4 paired, P5 verification) — 26 `mobile/lib` + `mobile/test` files per the Git-boundary diff, plus 3 story doc updates
- Evidence reviewed: `coding-plan/test-results.md` (185 tests pass, `flutter analyze` clean, AC-traceability table, regression-fix narrative)
- Risk surfaces reviewed: mobile interaction, mobile navigation/discoverability, app lifecycle (poll pause/resume)
- Critical gates reviewed:
- Mobile targeted verification gates: PASS (unit/widget coverage matches master-plan §5's verification contract; D1 poll contract, D4 body-parse/409-mapping, and AC4 shell-level gate all independently verified in code)
- Mobile discoverability/navigation integration: **PATCH_REQUIRED** (see Blocking Findings)
- Requirement mobile visual audit: `N/A` (per-story gate, not requirement-level; see 12e2 note below)
- Story runtime startup smoke: `NOT_APPLICABLE` — implementation lane is mobile-only, no configuration/runtime impact (master-plan §0 confirms `Configuration impact: none`)

## Outcome Summary

- Review outcome: PATCH_REQUIRED
- Rationale: The pairing feature's data/logic layer (P0), poll lifecycle (D1), and shell-level paired/unpaired gate (P1/AC4) are correctly implemented and covered by targeted tests. However, the four pairing screens are never stitched together into a real, user-reachable flow in production code: the `AppShell` "Pair with your partner" entry action is a literal no-op (`onPressed: () {}`), and `WaitingScreen`/`JoincodeScreen`'s `onPaired` navigation to `PairedScreen` is never wired outside test harnesses. This means AC1 and AC2 cannot actually be exercised by a user running the app, and rule 12e1 (mandatory, independently-verified reachable entry point) fails. `test-results.md` also has no `## Entry Point Reachability` section, and no per-story `visual-fidelity/` evidence exists (rule 12e2).
- Blocking findings: 2
- Deferred findings: 0
- Dismissed observations: 0

## Traceability Summary

- Requirements: AC1 (FAIL — invite screen unreachable), AC2 (FAIL — no screen-to-screen path to `paired`), AC3 (PASS — verified in `pairing_repository.dart`/`joincode_screen.dart`, all 409/404/400 cases mapped to distinct sealed failures, never a raw backend string), AC4 (PASS for the paired/unpaired shell gate itself — `AppShell`/`PairGateCubit` correctly route `HomeScreen` only when paired and never expose the tab shell while unresolved; but the "gates access to paired-only features" outcome cannot be reached in practice because there is no way to progress from unpaired to paired through the shipped UI)
- Open Questions: D1-D4 all implemented as decided in `master-plan.md` §1 — poll-based waiting (D1), no couple-type picker/CTA (D2, confirmed absent from `invite_screen.dart`), no unpair UI (D3), hand-constructed Dio calls via `pairing_repository.dart` rather than the generated client (D4). No deviation found.
- UX: `ux/uiux-spec.md` §2's flow map requires an entry point into `invite`, a toggle/entry into `joincode`, and `waiting`→`paired` / `joincode`→`paired` transitions — none of these connections exist in production code (see Blocking Finding 1).
- Testing evidence: `test-results.md` reports 185/185 passing and traces AC1-AC4 to specific unit/widget tests — accurate for each screen/cubit *in isolation*, but the tests exercise screens by direct construction (e.g. `pair_gate_cubit_test.dart`'s own comment: "Reachable: tappable without throwing" — it asserts tapping the entry button leaves the user on the pairing stack, not that it navigates anywhere). No test exercises the full navigation chain because that chain does not exist in `lib/`.

## Risk Surface Gate Summary

| Risk Surface | Source Of Truth | Critical Gate | Result | Notes |
|---|---|---|---|---|
| Invitation body parse / typing gap (D4) | `pairing_repository.dart`, `pairing_repository_test.dart` | P0 unit tests over recorded response bodies | PASS | Hand-constructed `_api.dio` calls per plan; generated client never used |
| Couple-only enforcement (AC3) | `pairing_repository.dart`, `joincode_screen.dart` | P3 widget test per 409 case | PASS | All 3 distinct 409 messages + 404/400 mapped to sealed failures, rendered inline, never raw |
| Poll lifecycle (D1) | `partner_link_poller.dart` | P0 unit + P2 widget test | PASS | 3s/60s→10s, hard stop at 10min/`expiresAt`, dispose/background/foreground-resume all implemented as specified |
| Shell gating (AC4, gate mechanics only) | `app_shell.dart`, `pair_gate_cubit_test.dart` | P1 widget test | PASS | Paired/unpaired/checking routing itself is correct |
| Mobile discoverability/navigation integration (AC1, AC2, rule 12e1) | `app_shell.dart`, `invite_screen.dart`, `joincode_screen.dart`, `waiting_screen.dart` | Independently-verified reachable entry point into the delivered capability | **FAIL** | See Blocking Finding 1 |
| Rendered design-fidelity check (rule 12e2) | `visual-fidelity/` | Per-screen rendered screenshot vs. design reference | **MISSING** | See Blocking Finding 2 |

## Blocking Findings

1. **No wired navigation into or through the pairing flow (AC1, AC2, rule 12e1).**
   - `mobile/lib/core/navigation/app_shell.dart` `_PairingStack`'s "Pair with your partner" `CupidPrimaryButton` has `onPressed: () {}` — a literal no-op. The class doc comment even states: "the `invite`/`joincode` destinations it will lead to are STORY-005 P2/P3 (not yet built), so the action has no navigation target wired in this phase" — but P2 (`invite_screen.dart`) and P3 (`joincode_screen.dart`) are both complete in this same diff, and the wiring was never added in P2-P5.
   - `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart:85-88` explicitly asserts this: it taps the button and only checks the pairing stack is still shown ("Reachable: tappable without throwing") — the test encodes the no-op as expected, rather than catching it.
   - Beyond the shell entry point, `WaitingScreen.onPaired` (`waiting_screen.dart:14-18`) and `JoincodeScreen.onPaired` (`joincode_screen.dart:14-19`) both default to `null` and are only supplied by test harnesses — no production code constructs `PairedScreen()` or wires either callback to it. `ux/uiux-spec.md` §2's flow map requires both `waiting → paired` and `joincode → paired` transitions; neither exists outside tests.
   - Net effect: a real user cannot generate an invitation (AC1) or accept one (AC2) through the running app — every pairing screen is fully implemented and independently tested, but none of them are reachable from the app's actual navigation graph. This is not a pre-existing/deferred issue; it is scope this story's own phases (P1's "pairing-stack routes" output, P2/P3/P4) were supposed to deliver.

2. **Missing mandatory reviewer-gate evidence (rules 12e1, 12e2).**
   - `coding-plan/test-results.md` has no `## Entry Point Reachability` section with `Reachable: YES` and a concrete path (rule 12e1's required evidence section is absent entirely, independent of Finding 1's code-level failure).
   - No `visual-fidelity/` directory exists under this story (rule 12e2's mandatory per-story rendered screenshot vs. design-reference comparison for a UI-bearing story). This gate cannot be completed by the reviewer this run since it depends on Finding 1's navigation fix first (the screens must be reachable to route+screenshot them in their real context), but it remains an open requirement before this story can pass.

## Implementation Action Items

- `[mobile-dev] mobile/lib/core/navigation/app_shell.dart`: wire the "Pair with your partner" entry action to a real navigation target (e.g. push `InviteScreen`, or present an inviter/invitee choice per `ux/uiux-spec.md` §2's flow map, since `joincode` also needs a direct entry point for a user who already has a code).
- `[mobile-dev] mobile/lib/features/pairing/presentation/screens/waiting_screen.dart` and `joincode_screen.dart` (via their call sites): wire `onPaired` in production to navigate to `PairedScreen` — currently only test fakes supply this callback.
- `[mobile-dev] coding-plan/test-results.md`: add `## Entry Point Reachability` with `Reachable: YES` and the concrete path once the above wiring exists, and update the AppShell/entry-point test so it asserts real navigation instead of "tappable without throwing."
- `[mobile-dev / reviewer]`: after the navigation fix, produce the per-story rendered visual-fidelity check (rule 12e2) for `invite`/`joincode`/`waiting`/`paired` before the next review pass.

## Workflow State Recommendation

- Story status: IN_PROGRESS
- `Implementation (Development)`: UNCHECK
- `Review (Reviewer)`: LEAVE_UNCHECKED
- Next step: return to `mobile-dev` (same lane, no re-plan needed) to wire the navigation chain described above, then re-request `compact-story-review` with the updated diff and `test-results.md` entry-point section.
- State update owner: `scrum-master` only. Reviewer does not edit story or requirement status files.
