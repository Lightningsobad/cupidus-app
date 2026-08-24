# Review Report — STORY-002 Pairing-Choice Navigation Restore

Outcome: BLOCKED

Review type: `compact-story-review` · Reviewer gate · re-review after PATCH_REQUIRED cycle · 2026-08-24
Scope: REQ-009 / STORY-002_pairing_choice_navigation_restore
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-009_invite_couple_type_and_pairing_navigation-STORY-002_pairing_choice_navigation_restore`
BaseHead: `90f531f1ec7e1b0960e000c2e27d45d1be7ad1ef`

## Scope Gate

Mirrored to `review/scope-gate.md` because `validate-reviewer-two-phase.sh` requires
that file even for `compact-story-review` (skill rule 5a says inline only). Same
divergence as the prior pass; still flagged to Scrum Master, still not a story defect.

- Review report path: `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-002_pairing_choice_navigation_restore/review/review-report.md`
- Source/test files in scope (6, within the 8-file compact budget):
  - `cupid-app-design-system/Cupid App.dc.html`
  - `cupid-app-design-system/Cupid Screens.dc.html`
  - `mobile/test/core/navigation/post_code_navigation_guard_test.dart`
  - `mobile/test/features/pairing/presentation/invite_screen_test.dart`
  - `mobile/test/features/pairing/presentation/joincode_screen_test.dart`
  - `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
  - read-only cross-checks (not changed by this story): `mobile/lib/core/navigation/pair_gate_shell.dart`,
    `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`
- Evidence files in scope: `story_master.md`, `coding-plan/test-results.md`,
  `visual-fidelity/` (report + PNG), `architecture/solution.md` (ranged),
  `requirements/requirements.md` (ranged), `req_master.md` (ranged), prior `review-report.md`
- Touched risk surfaces: mobile navigation/discoverability, mobile interaction, design-source asset
- Critical gates: targeted/regression tests, static analysis, entry-point reachability (12e1),
  rendered design fidelity (12e2/12e3), mobile runtime startup smoke (12g)
- Query keys: `AC1`-`AC7`, prior findings `F1`-`F5`, `Locked Navigation Decisions`,
  `pairingchoice`, `Reachable:`, `Runtime-Smoke`, `Design-Surface`, `VISUAL_FIDELITY`

## Prior Findings — Re-verification

| Prior | Claim | Reviewer verdict |
| --- | --- | --- |
| F1 (design half) | reference rendered | **RESOLVED** — `visual-fidelity/design-reference-pairingchoice-android.png` opened and read: it depicts the pairing-choice screen (title `Ghép đôi để mở khoá Cupid`, gradient primary CTA `Ghép đôi với người ấy`, secondary link `Tôi đã có mã`, no chrome), android frame, dark, `vi`. Correct screen, not a placeholder or error frame |
| F1 (implemented half) | `DEVICE_CAPTURE_BLOCKED`, not retried | **NOT RESOLVED** — see B2 |
| F2 | Entry Point Reachability added | **RESOLVED** — section present with `Reachable: YES`; independently verified in app code, not on trust: `pair_gate_shell.dart:139` (`PairGateUnpaired() => PairingChoiceScreen(...)`) and `pairing_choice_screen.dart:64` (`Key('pairing_stack')`). Real discoverable entry, no direct-URL dependence |
| F3 | `Runtime-Smoke: WAIVED` recorded | **RESOLVED** — `story_master.md:14-16`. Waiver basis independently re-confirmed: `git diff 90f531f1 -- mobile/lib/` is empty |
| F4 | AC3 amended by Product Owner | **NOT RESOLVED — escalated** — see B1 |
| F5 | `Design-Surface: cupid-app` | **RESOLVED** — `story_master.md:6`; matches the `cupid-app` / `surface: mobile` locked design source |
| D2 label fix | EN deviation belongs to primary CTA | **CONFIRMED** — canvas `Cupid Screens.dc.html:124` (`goInvite`) EN = `Pair up with them` vs `pairing_choice_screen.dart:101` `Pair with your partner`; canvas `:125` (`goJoinCode`) EN = `I already have a code` matches `:108`. Correction is right |

## Acceptance Criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 | PASS | `OnboardingChain.next(invite) == waiting`, `isNot(vow)`; invite copy action lands on `WaitingScreen` |
| AC2 | PASS | `pairingChoice` asserted as branching node; invite forward edge `waiting`, vow excluded |
| AC3 | BLOCKED | Implementation asserts `joinCode -> paired`. Story AC3 was amended to match; the governing requirement was not. See B1 |
| AC4 | PASS | `pairing_choice_screen_test.dart` mounts real `PairGateShell`; invite pops to `Key('pairing_stack')` |
| AC5 | PASS | same suite; join-code pops to `Key('pairing_stack')` |
| AC6 | FAIL | Design half now present; implemented half absent and no `VISUAL_FIDELITY:` verdict line exists. See B2 |
| AC7 | PASS | `post_code_navigation_guard_test.dart` source-scans invite/joincode for `VowScreen` / `OnboardingNode.vow` / `features/vow/` |

## Independently Verified This Pass

- Targeted suite re-run by Reviewer (unfiltered, all four files):
  `flutter test --no-pub --reporter failures-only <4 files>` → `+38: All tests passed!`, `TEST_EXIT=0`
- `git -C <Worktree> diff 90f531f1 -- mobile/lib/` → empty. No app-code change, as claimed
- Diff is 18 files; only non-artifact paths are the two `.dc.html` canvas files and the four
  `mobile/test/` files. All inside WriteScope
- Canvas restore is real: `Cupid Screens.dc.html:121-126` carries the `isPairingChoice` node,
  and the renderer enumerates `pairingchoice` only with `--location=<worktree>/...`

## Blocking Findings

**B1 — AC3 was amended at story level away from a user-confirmed locked decision that still stands unchanged at requirement level.**
This is why the outcome is `BLOCKED` rather than `PATCH_REQUIRED`: the governing inputs now
contradict each other and the disagreement is over a decision no agent owns.

- `req_master.md:24` `## Locked Navigation Decisions (user-confirmed)`, item 2 (`:31-39`):
  "Continuing from the **invite/join-code** screen goes to `pairing_choice_screen.dart` ...
  which then leads to the **Waiting-for-partner** screen (`goWaiting`)". Join-code is named
  explicitly, and the decision is marked user-confirmed.
- `requirements/requirements.md` repeats it as binding in five places — success signal
  (`:31-33`), in-scope (`:58-59`), acceptance (`:106-107`), AC narrative (`:134`), traceability
  and story table (`:145`, `:156`) — and at `:43-46` states the wiring question is
  "an implementation-verification question ... **not a reason to reopen the locked decision itself**".
- The F4 patch changed only `story_master.md:107-117`. `req_master.md` and `requirements.md`
  are unchanged: I grepped both for `AC3` / `amend` / `ratif` / `paired` and got no match.
- So the story now asserts `join-code -> paired` while the requirement it derives from
  asserts `join-code -> pairing-choice -> waiting`.

Tech Lead's A2 (`architecture/solution.md:86-91`) and ADR-4 (`:20`) are a sound *argument* that
the invitee has nothing to wait for — I am not disputing the engineering. But reviewer rule 14
requires a governing approved scope change, and rule 8 requires me to stop on contradictory
critical inputs. A Product Owner edit to a story AC does not amend a decision the user locked
at requirement level, and the requirement text pre-emptively forbids exactly this move. Note
also that the amendment as written would silently make the requirement-level success signal
untestable for the invitee side.

Resolution needed (one user decision, not an agent decision):
- **Owner: user, routed by Scrum Master.** Ask: does locked decision #2 apply to the join-code
  (invitee) side, given `acceptInvitation(code)` is synchronous so there is no waiting state to
  show? Then either (a) the user confirms the asymmetry → Product Owner updates `req_master.md`
  locked decision #2 and the five `requirements.md` statements to record `invite -> waiting`,
  `join-code -> paired`, and the story AC3 amendment becomes ratified; or (b) the user holds the
  literal decision → the join-code → Waiting-for-partner edge is real scope, AC3 reverts, and
  implementation changes (a new story if it exceeds this one's boundary).
- No code change is requested pending that decision. The story's binding negative — Fingerprint
  Vow is not the immediate post-code destination — is satisfied either way and is proven green.

**B2 — AC6 still has no implemented-side capture, and `visual-fidelity-report.md` carries no `VISUAL_FIDELITY:` verdict line at all.**
The design half is genuinely delivered and I confirmed it by opening the PNG. The other half
is not, so rule 12e3's requirement that **both** images exist is unmet, and the report is
missing the top-level `VISUAL_FIDELITY: PASS|FAIL` token that 12e2 requires (I read the whole
104-line file; the token is absent, not merely unclear). The render-vs-Flutter-source table is
a text comparison, which is what 12e2 refuses as a substitute.

On "not retried, per the Reviewer's own fallback": my prior report's fallback was explicitly
conditional — "*if, after retry*, emulator storage genuinely cannot be freed" — and named
"DevOps for emulator storage" as the owner. Neither the retry nor the DevOps routing happened,
so the `DEVICE_CAPTURE_BLOCKED` state is carried forward as an assertion rather than a
re-measured fact. The recorded cause (`emulator-5554`, `adb shell df /data` → 93% used,
`adb install` → `Requested internal only, but not enough space`) is remediable inside this
project by DevOps; it is not an external dependency.
Owner: DevOps (free/resize emulator storage on `emulator-5554`), then mobile-dev (capture
`implemented-pairingchoice-android.png`, compare, and record an explicit
`VISUAL_FIDELITY: PASS` or `FAIL` with concrete deltas). This work is independent of B1 and
can run in parallel with the user decision.

**B3 — the "this story is forbidden to touch `mobile/lib/`" premise used to defer the fidelity deltas is not what the story says.**
`visual-fidelity-report.md:87` and `test-results.md:143` both defer the two deltas on the
grounds that `mobile/lib/` is out of bounds. `story_master.md` `## In Scope` item 3 says the
opposite: "Confirm/**update** `pairing_choice_screen.dart`'s own content and design match now
that it is (or remains) part of the active flow." Tech Lead's finding was that no `mobile/lib/`
change is needed *for the navigation graph* — a different question from the design-match item.

This matters for one delta specifically: canvas title `font-size:24px`
(`Cupid Screens.dc.html:123`) vs Flutter `fontSize: 27` (`pairing_choice_screen.dart:92`).
Unlike the EN CTA wording, this one is in the **only user-enabled configuration** (dark + `vi`,
OQ5), so it cannot be deferred as "not user-enabled". Whether 27 is a real visible deviation or
a deliberate canvas→device scale conversion is not decidable from source text — which is
precisely what B2's missing capture would settle. Resolve B2 first, then either correct the
value under In-Scope item 3 or record why 27 is correct.
Owner: mobile-dev, after B2.

## Deferred Findings

- **D1** — `mobile/lib/main_preview.dart` (~:219) still says `pairingchoice` has "No canvas
  counterpart"; P1 restored it, so the note is stale. Carried forward unchanged.
- **D2** — EN primary CTA wording (`Pair up with them` vs `Pair with your partner`). Correctly
  re-attributed this pass. `en` is not a user-enabled configuration (OQ5), so this stays
  deferred even under B3's corrected scope reading.

## Context (not a defect in this story)

STORY-001 also writes `mobile/test/features/pairing/presentation/invite_screen_test.dart` on a
sibling branch; Scrum Master resolves that overlap at merge. Tech Lead anticipated it
(`solution.md:92-95`, A3) and kept STORY-002's change to appended test blocks.

## Traceability

- Requirements: `story_master.md` AC1-AC7; `req_master.md:24-39` locked decisions;
  `requirements/requirements.md:31-33, 43-46, 58-59, 106-107, 134, 145, 156`
- Architecture: `architecture/solution.md` INV-1, INV-3/ADR-4, A2, A3
- UX: `ux/ux-spec.md` — restored `isPairingChoice` node, `BACK_TO` edges, `Design-Screen: pairingchoice`
- Evidence: `coding-plan/test-results.md`; `visual-fidelity/`; targeted suite independently re-run
- Design config: `data/devops/system/design-fidelity-config.json` (`ui_surface: true`, locked `design_source`)

## Gate Summary

| Gate | Status |
| --- | --- |
| Targeted tests (4 files, +38) | PASS — re-run by Reviewer this pass |
| Regression suites (+172) | PASS — per evidence |
| `flutter analyze` on touched files | PASS — `No issues found!` |
| `mobile/lib/` exclusion claim | PASS — empty diff re-verified |
| Entry-point reachability (12e1) | PASS — evidence section present AND verified in `pair_gate_shell.dart:139` |
| Rendered design fidelity — design half (12e2) | PASS — reference PNG opened, correct screen |
| Rendered design fidelity — implemented half (12e3) | MISSING — B2 |
| Mobile runtime startup smoke (12g) | WAIVED — `story_master.md:14-16`, waiver basis verified |
| Requirement/AC consistency (rule 8/14) | CONTRADICTORY — B1 |
| Configuration-guide impact (12a) | NOT REQUIRED — no setup/config surface touched |

## State Recommendation

- Leave `Review (Reviewer)` unchecked
- Story status: `BLOCKED`
- Route B1 to the **user** via Scrum Master (one question: does locked decision #2 apply to the
  invitee side?), then Product Owner reconciles `req_master.md` + `requirements.md` with AC3
- Route B2 to DevOps (emulator storage) then mobile-dev (capture + `VISUAL_FIDELITY` verdict);
  independent of B1 and can start now
- Route B3 to mobile-dev after B2
- Do not merge to `codex/REQ-009_invite_couple_type_and_pairing_navigation-integration` until
  B1 is resolved: merging ratifies the requirement contradiction into the integration branch
