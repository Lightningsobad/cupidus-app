# Review Report — STORY-002 Pairing-Choice Navigation Restore

Outcome: PATCH_REQUIRED

Review type: `compact-story-review` · Reviewer gate · cycle 3, after the B1/B2/B3 dispositions · 2026-08-24
Scope: REQ-009 / STORY-002_pairing_choice_navigation_restore
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-009_invite_couple_type_and_pairing_navigation-STORY-002_pairing_choice_navigation_restore`
BaseHead: `90f531f1ec7e1b0960e000c2e27d45d1be7ad1ef`

Two of the three cycle-2 blockers are genuinely resolved and I re-verified both against the
artifacts rather than the summary. The story does not close this cycle because B3's fix changed
the very pixels AC6 exists to check, and the one gate that could confirm it was still not run —
and because that same fix silently invalidated the `Runtime-Smoke` waiver.

## Scope Gate

Mirrored to `review/scope-gate.md` because `validate-reviewer-two-phase.sh` requires that file
even for `compact-story-review` (skill rule 5a says inline only). Same divergence as the two
prior passes; still flagged to Scrum Master, still not a story defect.

- Review report path: `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-002_pairing_choice_navigation_restore/review/review-report.md`
- Source/test files in scope (7, within the 8-file compact budget):
  - `cupid-app-design-system/Cupid App.dc.html`
  - `cupid-app-design-system/Cupid Screens.dc.html`
  - `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart` (new this cycle)
  - `mobile/test/core/navigation/post_code_navigation_guard_test.dart`
  - `mobile/test/features/pairing/presentation/invite_screen_test.dart`
  - `mobile/test/features/pairing/presentation/joincode_screen_test.dart`
  - `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
  - read-only cross-check: `mobile/lib/core/navigation/pair_gate_shell.dart`
- Evidence files in scope: `story_master.md`, `coding-plan/test-results.md` (ranged, `:300-482`),
  `visual-fidelity/` (report + PNG), control-checkout `req_master.md` (ranged) and
  `git show 498bb85` for `requirements/requirements.md`, prior `review-report.md`
- Touched risk surfaces: mobile navigation/discoverability, mobile interaction, design-source
  asset, **mobile UI rendering (new this cycle — `mobile/lib/` is no longer untouched)**
- Critical gates: targeted/regression tests, static analysis, entry-point reachability (12e1),
  rendered design fidelity (12e2/12e3), mobile runtime startup smoke (12g)
- Query keys: `AC1`-`AC7`, `B1`-`B3`, `Locked Navigation Decisions`, `pairingchoice`,
  `Reachable:`, `Runtime-Smoke`, `VISUAL_FIDELITY`, `fontSize`

## Cycle-2 Blockers — Re-verification

| Prior | Reviewer verdict this cycle |
| --- | --- |
| **B1** — AC3 vs locked decision | **RESOLVED.** Verified in the control checkout, not from the summary. `req_master.md:31-49` locked decision #2 now reads asymmetric explicitly: invite → `goWaiting`, join-code → `paired`, with the `acceptInvitation` rationale and an `Amended 2026-08-24, user-confirmed` line. `git show 498bb85` shows all 7 `requirements.md` locations updated coherently (success signal, the `:43-46` "not a reason to reopen" paragraph, in-scope, acceptance, AC narrative, coverage map, story table). No stale symmetric statement survives. AC3 as written in `story_master.md:132-142` now derives from the governing text rather than contradicting it |
| **B2** — AC6 implemented capture | **NOT RESOLVED.** Storage remediation is real and well-evidenced (`test-results.md:313-385`: 93% / 425 MB → 8% / 9.0 GB, `pm install-create -S 300000000` succeeded). But the capture itself still does not exist, and the fallback it leans on no longer applies. See B4 |
| **B3** — title-size delta | **RESOLVED.** Verified in the diff itself, not the prose: `git diff 90f531f1 -- mobile/lib/` is exactly `fontSize: 27` → `fontSize: 24` at `pairing_choice_screen.dart:92`, 1 file / +1 −1. Matches canvas `Cupid Screens.dc.html:123` (`font-size:24px`). `line-height:1.3` already matched. The pre-edit `git grep` proving nothing pinned `27` is sound, and I re-ran the suite myself below |

## Acceptance Criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 | PASS | `post_code_navigation_guard_test.dart` — `OnboardingChain.next(invite) == waiting`, `isNot(vow)` |
| AC2 | PASS | invite forward edge `waiting`; `pairingChoice` asserted branching (`next() == null`) |
| AC3 | PASS | `next(joinCode) == paired`, `isNot(vow)` — and the governing requirement now says the same thing (B1) |
| AC4 | PASS | `pairing_choice_screen_test.dart` `_gateHarness()` mounts the real `PairGateShell`; invite pops to `Key('pairing_stack')` |
| AC5 | PASS | same suite; join-code pops to `Key('pairing_stack')` |
| AC6 | FAIL | Design half present and correct; implemented half absent; verdict token is `PARTIAL`, which is not a permitted value. See B4 |
| AC7 | PASS | source-scan guard over `invite_screen.dart` / `joincode_screen.dart` for `VowScreen` / `OnboardingNode.vow` / `features/vow/` |

## Independently Verified This Cycle

- Full targeted + regression run by Reviewer: `flutter test --no-pub --reporter failures-only
  test/core/navigation test/features/pairing` → `+172: All tests passed!`, `TEST_EXIT=0`.
  Same count as the pre-B3 baseline, so the `fontSize` edit broke and skipped nothing
- `git diff 90f531f1 -- mobile/lib/` → the single `fontSize` hunk, nothing else
- Entry point (12e1) verified in code, not on trust: `pair_gate_shell.dart:139`
  `PairGateUnpaired() => PairingChoiceScreen(...)` — a real discoverable mount, no direct-URL
  dependence
- `design-reference-pairingchoice-android.png` opened and read: it depicts this story's screen
  (title `Ghép đôi để mở khoá Cupid`, gradient primary CTA `Ghép đôi với người ấy`, secondary
  link `Tôi đã có mã`, no chrome), android frame, dark, `vi`. Correct screen, not a placeholder
- Whole-diff scope: 19 files, only 7 non-artifact paths, all inside WriteScope

## Blocking Findings

**B4 — AC6's implemented-side capture is still missing, and B3 removed the reason it could be waived.**

The handoff asks directly whether my cycle-2 fallback still applies. It does not, and B3 is
precisely why. That fallback said the design-reference render "stands in" for the pixel diff
while the implemented side was blocked — it was written when `mobile/lib/` was untouched and the
only question was whether an unchanged screen still matched. B3 changed the rendered typography
of that screen specifically to close a fidelity delta. The story now asserts a visual correction
that no rendered image has ever confirmed. A render-vs-source table cannot confirm it either:
reading `fontSize: 24` next to `font-size:24px` is the same text comparison rule 12e2 exists to
refuse, and it cannot show what 24 logical px actually looks like against the canvas at 406×900.

Two further specifics:

- `visual-fidelity-report.md:124` records `VISUAL_FIDELITY: PARTIAL`. Rule 12e2 defines exactly
  two values, `PASS` and `FAIL`. `PARTIAL` is not a verdict the gate can read, and it is not one
  I can convert into a pass on the story's behalf. `verify-story-visual-fidelity-gate.sh` and
  `validate-done-gate.sh` enforce the rendered verdict independently, so a passing outcome from
  me would be rejected downstream anyway
- 12e3 requires **both** `implemented-pairingchoice-android.png` and
  `design-reference-pairingchoice-android.png` to exist and to be looked at. Only the reference
  exists (`ls` of `visual-fidelity/` shows two entries: the reference PNG and the report)

This is `PATCH_REQUIRED`, not `BLOCKED`, and that is a deliberate change from cycle 2. Cycle 2
blocked because the emulator physically could not accept an install. DevOps fixed that — 9.0 GB
free, `emulator-5554` booted, `sys.boot_completed=1`, install-session reservation proven. Per
rule 12c, an environment that *can* now supply the evidence makes this a rework item. The
remaining obstacle described in the evidence is a handoff-routing rejection, not an environment
one; I cannot verify that claim myself (reviewers must not read `.claude/hooks/**`), but a guard
named `guard-broad-handoff.sh` rejecting a *broad* handoff points at narrowing the handoff, not
at the work being impossible. A single-screen preview install and one `adb exec-out screencap`
against an already-booted emulator is about as narrow as a mobile-dev task gets.

Owner: mobile-dev. `flutter build apk --debug -t lib/main_preview.dart
--dart-define=PREVIEW=pairingchoice`, install to `emulator-5554`, capture
`implemented-pairingchoice-android.png`, compare against the reference, and replace `PARTIAL`
with a real `VISUAL_FIDELITY: PASS` or `FAIL` naming concrete deltas. If Scrum Master confirms
after an actual narrowed attempt that no sanctioned lane exists, that is a routing decision for
the user — not something to absorb into the story as an accepted gap.

**B5 — the `Runtime-Smoke: WAIVED` basis is now factually false, and it was falsified by B3.**

`story_master.md:14-16` reads: "WAIVED — zero mobile/lib/ bytes changed this story
(Reviewer-verified empty `git diff <base> -- mobile/lib/`)". I am the reviewer who verified that,
and it was true at the time. It is not true now: `mobile/lib/features/pairing/presentation/
screens/pairing_choice_screen.dart` changed on this branch. Rule 12g makes registry-backed
runtime startup smoke mandatory for a `mobile`-lane non-trivial story unless the story master
records a waiver — the token is present but its stated ground no longer exists, so nothing is
actually holding the gate up.

I am not claiming a font-size constant can stop the app booting; the widget suite mounts the real
`PairGateShell` and passes. The defect is that the waiver now certifies something untrue, and I
am the last reader before DONE. The clean fix is also nearly free: B4 already requires installing
and launching this build on `emulator-5554`, so the launch-without-crash observation comes out of
the same session. Record it as `## Story Runtime Startup Smoke` evidence and drop the waiver, or
have Scrum Master restate the waiver on a ground that is actually true (e.g. the change is a
single presentational constant on an already-covered widget). Do not leave the current wording.

Owner: mobile-dev for the observation, Scrum Master for the `story_master.md` field (I must not
edit it).

## Deferred Findings

- **D1** — `mobile/lib/main_preview.dart` (~:219) still says `pairingchoice` has "No canvas
  counterpart"; P1 restored it, so the note is stale. Carried forward unchanged. Worth folding
  into the B4 pass since that file is being touched to build the preview anyway
- **D2** — EN primary CTA wording (`Pair up with them` canvas vs `Pair with your partner` in
  `pairing_choice_screen.dart:101`). `en` is not a user-enabled configuration (OQ5), so it stays
  deferred. Attribution to the primary control (not the secondary) is correct in the current report

## Merge-Ordering Note (Scrum Master, not a story defect)

The B1 ratification commit `498bb85` is on `main` only — `git branch --contains 498bb85` returns
`main`, and `codex/REQ-009_invite_couple_type_and_pairing_navigation-integration` is still at
`90f531f`. Merging this story branch into the integration branch as-is produces a tree whose
tests assert `joinCode -> paired` while the requirement text on that same branch still says
Waiting-for-partner — the cycle-2 contradiction, reintroduced at integration level. Bring `main`
into the integration branch (or rebase it) as part of the merge, so requirement integration
review sees the ratified text.

Separately, STORY-001 also writes
`mobile/test/features/pairing/presentation/invite_screen_test.dart` on a sibling branch; Tech Lead
anticipated the overlap (`solution.md:92-95`, A3) and kept this story's change to appended blocks.

## Traceability

- Requirements: `story_master.md` AC1-AC7; control-checkout `req_master.md:24-49` locked
  decisions (ratified); `requirements/requirements.md` via `498bb85` (7 locations)
- Architecture: `architecture/solution.md` INV-1, INV-3/ADR-4, A2, A3
- UX: `ux/ux-spec.md` — restored `isPairingChoice` node, `BACK_TO` edges, `Design-Screen: pairingchoice`
- Evidence: `coding-plan/test-results.md` (`## Device Environment — Emulator Storage (B2)`,
  `## B3 — Title-size fidelity fix`); `visual-fidelity/`; suites independently re-run
- Design config: `data/devops/system/design-fidelity-config.json` (`ui_surface: true`, locked
  `design_source` `cupid-app` / `surface: mobile`), `Design-Surface: cupid-app` at `story_master.md:6`

## Gate Summary

| Gate | Status |
| --- | --- |
| Targeted + regression suites (+172) | PASS — re-run by Reviewer this cycle, `TEST_EXIT=0` |
| `flutter analyze` on the touched file | PASS — 2 pre-existing `info` findings on lines 28-29, inside the known 78× `prefer_initializing_formals` baseline; none new |
| Entry-point reachability (12e1) | PASS — verified in `pair_gate_shell.dart:139` |
| Requirement/AC consistency (rules 8/14) | PASS — B1 ratified and re-verified |
| Rendered design fidelity — design half (12e2) | PASS — reference PNG opened, correct screen |
| Rendered design fidelity — implemented half (12e3) | FAIL — B4 |
| Mobile runtime startup smoke (12g) | UNSUPPORTED — B5, waiver ground void |
| Configuration-guide impact (12a) | NOT REQUIRED — no setup/config surface touched |

## State Recommendation

implementation_status_recommendation: IN_PROGRESS

- Uncheck `Implementation (Development)`; leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Route B4 and B5 together to mobile-dev as one narrow emulator pass on the already-booted
  `emulator-5554`: install the `pairingchoice` preview build, observe launch (B5), capture
  `implemented-pairingchoice-android.png`, compare, and record a real `VISUAL_FIDELITY: PASS|FAIL`
  (B4). Fold D1 in while `main_preview.dart` is open
- Scrum Master then updates or removes the `Runtime-Smoke` waiver line in `story_master.md`
- Before merging to `codex/REQ-009_invite_couple_type_and_pairing_navigation-integration`, bring
  `main` (commit `498bb85`) into the integration branch — see the merge-ordering note
