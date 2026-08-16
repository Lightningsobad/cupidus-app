# Review Slice P1 — Navigation Core (STORY-002)

Slice: 1 of 5 (scoped-slice, Tier-3)
Reviewer: Iris-QC
Date: 2026-08-14
Story: STORY-002 Onboarding & Pairing Flow Navigation Correction
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Branch: codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-002
BaseHead: 2c9d1f06643234bbf0533d0e1f80e4e5d695ca6e
Worktree HEAD: 0d51e8031841bbaaf16be5c98a928b19495b61ba
Phase commit in scope: b623ff4 (`feat(STORY-002): Phase P1 ...`)

**This is a slice report. It records no story-level Outcome.**

## Slice Scope

Diff between BaseHead and Worktree HEAD, restricted to 6 files. All six are
net-new (0 deletions), 541 insertions total:

| File | Lines |
|---|---|
| `mobile/lib/core/navigation/onboarding_chain.dart` | +55 |
| `mobile/lib/core/navigation/onboarding_router.dart` | +81 |
| `mobile/lib/core/navigation/onboarding_progress_resolver.dart` | +50 |
| `mobile/test/core/navigation/onboarding_chain_test.dart` | +97 |
| `mobile/test/core/navigation/onboarding_router_test.dart` | +118 |
| `mobile/test/core/navigation/onboarding_progress_resolver_test.dart` | +140 |

`git log 2c9d1f0..HEAD` for these paths shows exactly one commit (`b623ff4`),
so the P1-time state is the HEAD state — no later phase silently amended it.

Out of slice: P2-P5 (session termination, auth/pairing leg screens, chrome,
post-pairing tail). `pair_gate_shell.dart` and `service_locator.dart` are
explicitly not reviewed here.

## Verification Evidence (re-run, not inherited)

Prior P1 evidence in `story_master.md` claimed analyze clean / full suite
939/939 / targeted 19/19. Spot-checked independently:

1. `flutter analyze lib/core/navigation test/core/navigation` — 17 issues, all
   severity `info`, all `prefer_initializing_formals`, all in
   `lib/core/navigation/pair_gate_shell.dart` (P2/P4 scope, not this slice).
   **Zero issues in any of the 6 files under review.** Confirms the P1 claim
   "analyze clean for the new files".
2. `flutter test test/core/navigation/onboarding_chain_test.dart
   onboarding_router_test.dart onboarding_progress_resolver_test.dart`
   — `+19: All tests passed!`. Confirms the "targeted 19/19" claim exactly.

The full-suite 939/939 figure was not re-run in this slice (it is a
story-level gate; P5's tracking entry supersedes it with +1221 ~2 -6 against
an identical pre-existing BaseHead failure set).

### Compile-validity check performed

`OnboardingProgressResolver`'s constructor declares private named initializing
formals (`required this._fetchProfile`) while
`onboarding_progress_resolver_test.dart` calls them as `fetchProfile:`. This
looks like a `private_optional_parameter` error under older Dart. Verified
against the toolchain actually in use: the analyzer reports **no diagnostic**
and the tests compile and pass, i.e. the private-named-parameter language
feature is available in this SDK. Not a finding.

## Cross-Reference: `ux/uiux-spec.md` § "Corrected Navigation Graph"

`OnboardingChain._forwardOrder` (`onboarding_chain.dart:26-42`) vs. the spec
table (`uiux-spec.md:27-47`):

| Spec edge | In `_forwardOrder` | Match |
|---|---|---|
| `register` → `otp` | `register: otp` | YES |
| `otp` → `permissions` | `otp: permissions` | YES |
| `permissions` → `onboarding_profile_setup` | `permissions: profileSetup` | YES |
| `onboarding_profile_setup` → `pairing_choice` | `profileSetup: pairingChoice` | YES |
| `invite` → `waiting` | `invite: waiting` | YES |
| `waiting` → `paired` | `waiting: paired` | YES |
| `join_code` → `paired` (synchronous confirm) | `joinCode: paired` | YES |
| `paired` → `love_contract` | `paired: loveContract` | YES |
| `love_contract` → `fingerprint_vow` | `loveContract: vow` | YES |
| `fingerprint_vow` → `home` | `vow: home` | YES |

The map has exactly 10 entries; there is no extra, invented, or reordered
edge. Deliberately absent: `welcome`, `login`, `pairing_choice` (branching —
the spec gives them two outgoing triggers each) and `forgot_password`, `home`
(terminal). Encoding a default successor for those would fabricate an edge the
UX graph does not have; the code documents this at `onboarding_chain.dart:22-25`
and the test at `onboarding_chain_test.dart:71-85` pins all five to `null`.

Structural properties checked by hand against the map:
- **No loopback**: the value set is `{otp, permissions, profileSetup,
  pairingChoice, waiting, paired, loveContract, vow, home}`. Neither `welcome`
  nor `login` nor `register` is the target of any forward edge, so no chain
  edge can loop the user back to the auth entry (AC2's explicit prohibition).
- **No cycle / no self-edge**: the map is a DAG converging on `home`
  (`register`-leg terminates at `pairingChoice`; `invite`/`joinCode`-legs
  converge at `paired` → ... → `home`).
- **No orphan target**: every value is also a declared `OnboardingNode`, and
  every node that is not a branch-entry node has an incoming edge.

## `goNext` Semantics (explicitly requested check)

`onboarding_router.dart:44-50`:

```dart
Future<void> goNext(BuildContext context, OnboardingNode from) {
  final OnboardingNode? target = OnboardingChain.next(from);
  if (target == null) {
    throw OnboardingChainHasNoSuccessor(from);
  }
  return push(context, target);
}
```

**Confirmed correct.** `goNext` resolves `OnboardingChain.next(from)` — the
successor of the node the caller is leaving — and never `next(destination)`.
The `from` argument is the caller's own node; the resolved `target` is passed
to `push` without a second chain lookup. Behaviour is pinned by
`onboarding_router_test.dart` ("goNext pushes the chain successor": host `otp`,
asserts `permissions` renders). Verified from the code as it stands,
independent of the Scrum Master self-correction noted in the handoff.

Branching/terminal nodes throw `OnboardingChainHasNoSuccessor` rather than
silently no-opping (`onboarding_router.dart:46-48`), and an unregistered node
throws `OnboardingRouteNotRegistered` (`onboarding_router.dart:73-76`). Both
throws are synchronous — `goNext`/`push`/`replaceWith` are not `async`, so the
`expect(() => ..., throwsA(...))` assertions in the tests are valid and are not
silently passing on an unawaited future.

## Acceptance Criteria (navigation-core scope only)

### AC1 — welcome → login/register, each leading to its correct next screen: **PASS**

Navigation-core provides the correct primitives and no wrong edge.
`welcome` and `login` are correctly modelled as branching (no `_forwardOrder`
entry, `next()` → `null`), matching spec rows `welcome`→`login`,
`welcome`→`register`, `login`→`forgot_password`, `login`→`home`/resume.
`push` (`onboarding_router.dart:57-58`) is documented as the primitive for
exactly these edges and keeps the caller on the stack so the spec's
`forgot_password` → back → `login` (uiux-spec.md:34) works.
`register` → `otp` is present and correct.
The `login` → `home`-vs-resume decision is implemented by
`OnboardingProgressResolver.resolve()` (5 ordered rules, 9 tests green).
Caveat: the actual auth-screen call sites are P3 scope and are not evidence in
this slice.

### AC2 — otp → permissions → profileSetup → pairingChoice, no skip, no loop: **PASS**

The four-edge sequence matches the UX table exactly (table above).
`onboarding_chain_test.dart:31-51` walks the chain from `register` by repeated
`next()` until `null` and asserts the traversal is exactly
`[register, otp, permissions, profileSetup, pairingChoice]` — this is a
skip-proof assertion, not an edge-by-edge spot check: an inserted, dropped, or
reordered node changes the walked list. No-loop-to-welcome/login is proven
structurally: neither node appears in the map's value set.

### AC3 — pairing legs reach the correct next node, no unreachable/loopback: **PASS** (chain-graph portion)

`invite: waiting`, `waiting: paired`, `joinCode: paired`, `paired:
loveContract`, `loveContract: vow`, `vow: home` all match the spec.
`onboarding_chain_test.dart:53-69` walks the tail from `paired` and asserts
exactly `[paired, loveContract, vow, home]`. No cycle, no self-edge, no orphan
target (see structural checks above).
Scope caveat: reachability of the *branch-entry* nodes (`invite`, `joinCode`
from `pairingChoice`) is established at the call sites, which are P4 scope.
Within navigation-core the graph is correct; the P4 slice must confirm the
branch pushes exist.

## Findings

### F1 — `joinCode` collapses the spec's two-outcome node to one edge (INFO, justified)

`uiux-spec.md:42-43` gives `join_code` two outcomes (`waiting` if the backend
has not confirmed, `paired` if it confirms synchronously) and explicitly
delegates "which condition applies" to Tech Lead. `_forwardOrder` encodes only
`joinCode: paired`, citing ADR-4. `story_master.md:257-260` records ADR-4's
resolution: `acceptInvitation` confirms synchronously for the invitee, so the
invitee never needs `waiting`. Within the spec's own delegation — not a
deviation. Recorded so the story-level reviewer sees the single-edge choice was
deliberate and traceable.

### F2 — Resolver resumes a paired-but-unvowed user at `loveContract`, not `home` (INFO, refinement)

`uiux-spec.md:31` says an already-paired account at login goes to `home`,
"skips onboarding/pairing chain entirely". `onboarding_progress_resolver.dart:31-35`
returns `home` only when `vowTaken` is true, and `loveContract` otherwise.
This is stricter than the literal spec cell and is the behaviour AC3 requires
(`paired` → `loveContract` → `vow` → `home`) — sending an unvowed user
straight to `home` would skip two chain nodes. `uiux-spec.md:32` delegates
resume-node resolution to Tech Lead, so this sits inside the delegated
authority. Flagged for story-level confirmation that PO/UX accept the
refinement over the literal table row.

### F3 — `waiting` is not a login resume target (INFO, pre-disclosed, residual)

`uiux-spec.md:32` lists `waiting` among resume targets; the resolver's outcome
set is `{home, loveContract, otp, profileSetup, pairingChoice}`. Already
disclosed by Tech Lead as a deviation for Reviewer
(`story_master.md:261-263`, ADR-2): no backend read exists for an outstanding
self-created invitation. Reason accepted. Residual user-visible effect: an
inviter who creates a code and cold-restarts the app resumes at
`pairingChoice` rather than back at `waiting`, losing sight of the outstanding
invitation. Deferrable — candidate for a post-wave `add-bug` if the backend
later exposes that read; not a slice blocker.

### F4 — `goNext` pushes rather than replaces, so the chain accumulates a back stack (INFO, deferrable)

`goNext` delegates to `push` (`onboarding_router.dart:50`), keeping every
completed chain node on the navigator stack. A user on `pairingChoice` can
therefore Android-back into `profileSetup`, and from `otp` back into
`register`. The UX spec defines only one back edge for the whole chain
(`forgot_password` → `login`, uiux-spec.md:34) and is silent on the rest,
while story In-Scope item 1 (`story_master.md:124`) does claim "forward/back
navigation". `push` is the documented ADR-1 default and callers retain
`replaceWith`/`resetTo` for one-way steps (P4 already uses `resetTo(paired)`),
so whether this is correct is decided at the call sites in the P3-P5 slices,
not here. Raised so the story-level reviewer can close it across slices rather
than have each slice see only half the picture.

### F5 — Resolver checks `partnerId` before email verification (INFO, low risk)

`onboarding_progress_resolver.dart:31-39` returns `home`/`loveContract` for a
paired user without ever calling `_reloadEmailVerified()`, so a paired account
with an unverified email would never be sent to `otp`. ADR-2 specifies an
ordered "first match wins" table, and pairing in practice presupposes a
verified account, so the ordering is intentional and the state is not
reachable. No action.

No blocking defect found in this slice.

## Residual Risks Carried To Story Level

- F3: `waiting` resume gap (backend-limited, pre-disclosed).
- F4: chain back-stack semantics — must be judged against the P3/P4/P5 call
  sites, not resolvable inside navigation-core.
- F2: resume-to-`loveContract` refinement needs PO/UX acknowledgement against
  `uiux-spec.md:31`.

## Slice Result

REVIEW_SLICE_COMPLETE: YES
AC1 (navigation-core scope): PASS
AC2 (navigation-core scope): PASS
AC3 (navigation-core scope, chain-graph portion): PASS
Blocking defects: NONE
Findings: F1-F5, all INFO/deferrable
