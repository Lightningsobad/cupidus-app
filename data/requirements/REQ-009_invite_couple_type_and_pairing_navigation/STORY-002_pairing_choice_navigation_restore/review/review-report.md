# Review Report — STORY-002 Pairing-Choice Navigation Restore

Outcome: PATCH_REQUIRED

Review type: `compact-story-review` · Reviewer gate · 2026-08-24
Scope: REQ-009 / STORY-002_pairing_choice_navigation_restore
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-009_invite_couple_type_and_pairing_navigation-STORY-002_pairing_choice_navigation_restore`
BaseHead: `90f531f1ec7e1b0960e000c2e27d45d1be7ad1ef`

## Scope Gate

Also mirrored to `review/scope-gate.md` because the `validate-reviewer-two-phase.sh`
stop guard requires that file even for `compact-story-review`, which reviewer skill
rule 5a says should use this inline section only. Flagged to Scrum Master.

- Review report path: `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-002_pairing_choice_navigation_restore/review/review-report.md`
- Source/test files in scope (6, within the 8-file compact budget):
  - `cupid-app-design-system/Cupid App.dc.html`
  - `cupid-app-design-system/Cupid Screens.dc.html`
  - `mobile/test/core/navigation/post_code_navigation_guard_test.dart`
  - `mobile/test/features/pairing/presentation/invite_screen_test.dart`
  - `mobile/test/features/pairing/presentation/joincode_screen_test.dart`
  - `mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
- Evidence files in scope: `story_master.md`, `architecture/solution.md` (ranged), `ux/ux-spec.md` (queried), `coding-plan/test-results.md`, `data/devops/system/design-fidelity-config.json`
- Touched risk surfaces: mobile navigation/discoverability, mobile interaction, design-source asset
- Critical gates: targeted/regression widget+unit tests, static analysis, entry-point reachability (12e1), rendered design fidelity (12e2/12e3), mobile runtime startup smoke (12g)
- Query keys: `AC1`-`AC7`, `INV-1`, `A2`/`ADR-4`, `pairingchoice`, `BACK_TO`, `goVow`, `design_source`, `Design-Screen`

## Acceptance Criteria

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC1 | PASS | `OnboardingChain.next(invite) == waiting` + `isNot(vow)`; `invite_screen_test.dart:412` copy action lands on `WaitingScreen`, `VowScreen` findsNothing |
| AC2 | PASS | `pairingChoice` asserted as a branching node (`next == null`); invite forward edge is `waiting`, vow excluded |
| AC3 | FAIL (deviation, unratified) | Tests assert `joinCode -> paired`, not the AC's literal `-> Waiting-for-partner`. See F4 |
| AC4 | PASS | `pairing_choice_screen_test.dart` mounts real `PairGateShell`; invite pops back to `Key('pairing_stack')` |
| AC5 | PASS | same suite; join-code pops back to `Key('pairing_stack')` |
| AC6 | FAIL | No rendered comparison exists; no `visual-fidelity/` directory. See F1 |
| AC7 | PASS | `post_code_navigation_guard_test.dart` source-scans invite/joincode for `VowScreen`, `OnboardingNode.vow`, `features/vow/`; repo-wide `mobile/test` vow grep shows only the two new negative assertions |

## Independently Verified

- Targeted suite re-run by Reviewer (not trusted from the report):
  `flutter test --no-pub` over the four named files → `+38: All tests passed!`, `TEST_EXIT=0`.
  The assertions are real edge assertions, not tautologies: `joincode_screen_test.dart`
  registers a `vow` builder (`Key('routed_vow')`) precisely so `findsNothing` is a
  positive claim, and `pairing_choice_screen_test.dart` drives the real `PairGateShell`
  rather than `PairingChoiceScreen` in isolation.
- `git -C <Worktree> diff 90f531f1 -- mobile/lib/` is **empty**. Confirmed: no
  `mobile/lib/` change, matching Tech Lead's finding and the implementer's claim.
- Diff totals 14 files / +1232 lines; the only non-artifact code paths are the two
  `.dc.html` design-canvas files and the four `mobile/test/` files. All inside WriteScope.

## Blocking Findings

**F1 — AC6 rendered design fidelity is missing, and its stated blocker is factually wrong.**
`data/devops/system/design-fidelity-config.json` has `ui_surface: true` and a **locked**
`design_source` (`cupid-app`, `type: claude-design`, `surface: mobile`), so reviewer rule
12e2/12e3 applies with no prose-waiver escape. `test-results.md` records
`DESIGN_RENDER_TOOL_UNRESOLVED` on the basis that `find . -name "render-design-canvas.js"`
returned 0 results. That search ran **inside the git worktree**, and `.ai-team-bundle/` is
gitignored (`.gitignore:5`), so it never materializes in a worktree. The renderer does exist:

    /Users/alantravala/workspace/snapsofts/cupid-apps/.ai-team-bundle/runtime/tools/render-design-canvas.js   (39.1K, mode 755)

`ux/ux-spec.md:172` already supplies the exact invocation
(`render-design-canvas.js --screen=pairingchoice --platform=android --theme=dark --lang=vi`),
and `ux/ux-spec.md:3` records the resolved screen id `pairingchoice`. The design-reference
half of AC6 is therefore fully supplyable today by calling the tool at its absolute path.
The implemented-capture half (`DEVICE_CAPTURE_BLOCKED`, `emulator-5554` at 93% used,
`adb install` → `Requested internal only, but not enough space`) is a genuine environment
fault, but it does not excuse the reference render, and it is remediable by DevOps
(free emulator storage) rather than intrinsic. The substituted source-vs-canvas text table
is prose, not rendered evidence — exactly what 12e2 refuses. Not `DEFERRED_ONLY`: this is
the primary proof of AC6's changed behaviour (rule 12c).
Owner: mobile-dev (render + capture + `visual-fidelity/visual-fidelity-report.md`),
with DevOps for emulator storage only if it still blocks after retry.

**F2 — `## Entry Point Reachability` evidence section is absent.**
`story_master.md` records `UI-facing story: YES`. Rule 12e1 makes this section mandatory and
non-waivable, with `Reachable: YES` and the concrete path. `coding-plan/test-results.md` has
no such section. The underlying reachability looks sound — `pairing_choice_screen_test.dart`
proves `PairGateShell` → `PairGateUnpaired` renders the pairing stack, which is the entry —
but the required evidence section must exist and name the path.
Owner: mobile-dev.

**F3 — `## Story Runtime Startup Smoke` evidence section is absent.**
Lane is `shared`, complexity `standard` (non-trivial), so rule 12g applies, and
`story_master.md` carries no `Runtime-Smoke: WAIVED — <reason>` line. The same emulator
storage exhaustion that blocked F1's capture also prevents the app-launch smoke. Either
supply the smoke after freeing emulator space, or have Scrum Master/PO record an explicit
`Runtime-Smoke: WAIVED — <reason>` in `story_master.md` (defensible here: the story changes
zero `mobile/lib/` bytes, so no runtime code path moved).
Owner: mobile-dev / DevOps, or Scrum Master for the waiver line.

**F4 — AC3's literal target is not what was implemented, and the deviation is unratified.**
AC3 states `join-code -> pairing-choice -> Waiting-for-partner`. The implementation and its
tests assert `OnboardingChain.next(joinCode) == paired`. Tech Lead did not hide this —
`architecture/solution.md:86-91` raises it as **"A2 (AC3 / ADR-4 conflict — flag for Reviewer
and Product Owner)"**, arguing `acceptInvitation(code)` is synchronous for the invitee so
there is nothing to wait for, and that a literal join-code → waiting edge would be a new
requirement. That is an escalation, not an approval. Reviewer rule 14 requires a governing
approved scope change, OQ triage decision, or explicit user override before a substituted
target passes; none exists. AC3's binding negative (not Fingerprint Vow) is satisfied, so the
regression this story exists to fix is genuinely closed — but the AC text and the code
disagree and someone must decide which moves.
Owner: product-owner — either amend AC3 to `join-code -> paired` citing ADR-4, or raise a new
requirement for a literal waiting step. No code change is requested pending that decision.

**F5 — `Design-Surface` is undecided for a `shared` lane.**
The project configures **two** design sources with overlapping screen namespaces
(`cupid-app`/`surface: mobile` and `cupid-web`/`surface: web`). Rule 12e2 resolves the
surface from `Implementation Lane` for `mobile`/`frontend`, but requires an explicit
`Design-Surface: <id>` when the lane is `shared` — which it is here. `story_master.md`
records none. Practically this story is `cupid-app`, and `ux/ux-spec.md` works against the
`Cupid App.dc.html` / `Cupid Screens.dc.html` canvas, but per 12e2 an undecided surface is
not mine to resolve on the story's behalf. Record `Design-Surface: cupid-app` in
`story_master.md` (or set the lane to `mobile`, which is what the diff actually is).
Owner: ui-ux-designer or Scrum Master.

## Deferred Findings

- **D1** — `mobile/lib/main_preview.dart` (~line 219) still carries the seed note "No canvas
  counterpart; compared against AC4 chrome rules, not a design reference." for `pairingchoice`.
  P1 restored that counterpart, so the note is now stale. Out of this story's write scope
  (`mobile/lib/`); fix opportunistically in a story that already touches the file.
- **D2** — Canvas/Flutter deltas recorded by the implementer: title `24px` vs `fontSize: 27`,
  and EN secondary label `Pair up with them` vs `Pair with your partner`. Both live in
  `mobile/lib/`, both pre-existing, and the EN one is outside the only enabled configuration
  (OQ5: dark + `vi`). Note that these were derived from text comparison, not a render — if
  F1's rendered pass surfaces further deltas, they supersede this list.

## Context (not a defect in this story)

STORY-001's mobile-dev run also writes
`mobile/test/features/pairing/presentation/invite_screen_test.dart` on a sibling branch.
A merge-time conflict on that file at integration is expected and is a scheduling artifact of
parallel delivery, not a defect here. Tech Lead anticipated it (`solution.md:92-95`, assumption
A3): STORY-002 deliberately enforces the CTA's *target contract* with a source-scanning guard
test instead of editing the shared widget, which keeps the conflict to appended test blocks.

## Traceability

- Requirements: `story_master.md` AC1-AC7, `## Open Question Impact` (OQ5 non-blocking, dark + `vi` only)
- Architecture: `architecture/solution.md` INV-1 (vow never succeeds invite/joinCode), INV-3/ADR-4, A2, A3
- UX: `ux/ux-spec.md` — restored `isPairingChoice` node, `BACK_TO` edges, `Design-Screen: pairingchoice`
- Evidence: `coding-plan/test-results.md`; targeted suite independently re-run by Reviewer
- Design config: `data/devops/system/design-fidelity-config.json` (`ui_surface: true`, locked `design_source`)

## Gate Summary

| Gate | Status |
| --- | --- |
| Targeted tests (4 files, +38) | PASS — re-run by Reviewer |
| Regression suites (+172) | PASS — per evidence, consistent with re-run |
| `flutter analyze` on touched files | PASS — `No issues found!` |
| `mobile/lib/` exclusion | PASS — verified empty diff |
| Entry-point reachability (12e1) | MISSING — F2 |
| Rendered design fidelity (12e2/12e3) | MISSING — F1 |
| Mobile runtime startup smoke (12g) | MISSING — F3 |
| Configuration-guide impact (12a) | NOT REQUIRED — no setup/config surface touched |

## State Recommendation

- Uncheck `Implementation (Development)`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Route F1/F2/F3 to mobile-dev (F1/F3 with DevOps for emulator storage if it persists),
  F4 to product-owner, F5 to ui-ux-designer or Scrum Master.
- If, after retry, emulator storage genuinely cannot be freed, F1's implemented-capture half
  escalates that single gate to `BLOCKED`; the design-reference render, F2, F4, and F5 remain
  supplyable regardless.
