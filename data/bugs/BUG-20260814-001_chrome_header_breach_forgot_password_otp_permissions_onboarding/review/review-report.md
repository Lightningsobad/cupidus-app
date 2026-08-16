# Bugfix Review: BUG-20260814-001 Chrome Header Breach (forgot_password/otp/permissions/onboarding_profile_setup)

Outcome: DEFERRED_ONLY

Review type: `bugfix-review`
Reviewer: Iris-QC
Date: 2026-08-16
Scope gate: `review/scope-gate.md`
Bug id: `BUG-20260814-001_chrome_header_breach_forgot_password_otp_permissions_onboarding`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Diff baseline: `83d456f90a9d5fe34851b6b8efa194f58945040c` → fix commit `f726e8c`

## Rationale

The fix is correct, minimal, and traceable to a locked spec. All four reported
call sites had their `appBar: CupidHeader(...)` removed and nothing else; no
shared or composition-layer code changed, so no screen outside the four
reported routes changes behavior. The guard suite's pin was removed before the
production fix, which is the right order — it converted a suite that was
*certifying* the defect into one that fails on it.

Blocking findings: 0. Deferred findings: 3.

## Verification Performed

| Check | Method | Result |
|---|---|---|
| All 4 `appBar:` removals, no collateral edits | `git diff 83d456f -- mobile/lib mobile/test` (10 files, +30/-79) | PASS |
| No orphaned imports after `CupidHeader` removal | `flutter analyze` on the 6 touched Dart files | PASS — "No issues found!" |
| Fix is green and regression is pinned | Reran all 6 touched suites | PASS — 62/62, incl. `forgot password back from forgot returns to login` |
| `SafeArea` retained on all 4 bodies | Diff context (otp/permissions/profile) + ranged read `forgot_screen.dart:99-119` | PASS |
| Test-count delta 1247 → 1246 | Diff-level count of test declarations | PASS — exactly one `test(` removed, none added |

## Bug-Fixer's Three Review-Focus Items

**1. Chrome Rules over design source — I would make the same call.**
`uiux-spec.md:62-68` is unconditional on its face: "Applies to every node in
this chain, `splash` through `fingerprint_vow` (AC4) … No header/app-bar chrome
on any screen in this list." It enumerates no exceptions, and all four routes
appear in that spec's own `## Screens/Nodes Touched` list (lines 12-15). The
design source's `NO_CHROME` map omitting `forgot` is a lower-precedence
artifact. `story_master.md:99-105` had already adjudicated exactly this —
"confirmed against `ux/uiux-spec.md`'s unconditional Chrome Rules, not a
design-intent question, so not routed to UI/UX" — and deferred only for write
scope, not for doubt. Correctly resolved without re-opening a settled question.

**2. `auth_leg_edges_test.dart` back-leg rewrite satisfies `uiux-spec.md:34`.**
Row 34 is `| forgot_password | back | login | |` — an empty Notes column. The
spec locks the *transition*, not the affordance, so driving it via
`handlePopRoute()` (the platform back button) tests the same contract the
header tap did. The rewrite is also strictly stronger than a rename: it adds
`expect(_canPop(tester), isTrue)` before the pop, so the test would now catch a
navigator stack that had no route to return to. Reran and confirmed green.

**3. The 1247 → 1246 delta is exactly the one pin-list test.**
Verified from the diff rather than by trusting the count. Exactly one test
declaration is deleted across all 10 files — `every tracked header breach is
still a chain node` — and zero are added. Every other test-file change is an
assertion edit or a rename inside a *kept* test (the guard suite's
`testWidgets` name ternary collapsed to a single string; it was not removed).
Nothing was skipped, weakened, or silenced: `otp_screen_test.dart` and
`permissions_screen_test.dart` dropped only the now-invalid header-title
assertions, while `forgot_screen_test.dart`,
`onboarding_profile_setup_screen_test.dart`, and the guard suite gained
stronger `findsNothing` assertions.

## Traceability

| Input | Verified |
|---|---|
| Bug report expected behavior | `uiux-spec.md:62-68` Chrome Rules — unconditional, all 4 routes in scope |
| `diagnosis.md` `## Pre-Fix Reproduction Gate` | Present; REPRODUCED via the named failure anchor |
| Deterministic red state | 4 failures, one per reported route, before the production fix |
| `fix-evidence.md` `## Original Failure Recheck Gate` | Present; `Same modality as original: YES` |
| `BUG_FIX_COMPLETE` | Not `NO`; no `WAITING_FOR_USER_LOGS`, no instrumentation-only handoff |
| Cluster boundary (rule 12d sibling sweep) | Guard suite now asserts unconditionally across **every** chromeless chain node and passes, which is the sweep — no further breach sites exist in the chain |
| `welcome_screen.dart` untouched | Confirmed absent from the diff (BUG-20260816-001) |

Same-modality recheck is satisfied on its strongest reading: the bug was
*reported* from the `chain_chrome_guard_test.dart` widget-render harness, and
the recheck is that same harness with the pin removed. For a "screen renders a
header" defect, a widget render asserting `find.byType(CupidHeader)` is
`findsNothing` exercises the exact observed-vs-expected mismatch — this is not
one of the indirect proxies (route compilation, HTTP probe, build, startup)
that rule 16 downgrades to supporting evidence. The emulator render pass
corroborates it through a second channel.

Configuration guide: not applicable — no setup, environment, dependency, or
runtime-configuration surface was touched.

## Deferred Findings

**D1 — Modality 2 emulator screenshots were not persisted.**
`fix-evidence.md` § "Modality 2" states all four routes were rendered and
screenshotted on `emulator-5560`, with concrete per-route observations, but no
image files exist under the bug directory. That channel is therefore not
re-auditable after the fact. Deferred rather than blocking because it is
corroborating, not primary, evidence: the primary proof is the unconditional
widget-render assertion, which is present and which I independently reran.
Worth tightening for future visual bugfixes — a claimed screenshot that was not
written to disk reads identically to one that was never taken.

**D2 — `forgot_password` back affordance is now platform-only.**
`CupidHeader` carried the only in-content back control on that screen. This is
spec-compliant (row 34 locks the transition, not the affordance) and matches
the sibling chromeless `register` leg, and both the widget test and the
on-device hardware-back check confirm the leg survives. Recording it because it
is a real user-facing change that no AC describes: if UI/UX later wants an
in-content back control on chromeless nodes, that is a new design decision, not
a regression of this fix.

**D3 — the four design sources still carry header blocks.**
A future design-fidelity pass that re-derives any of these screens from its
design source could reintroduce the header. Residual risk is low precisely
because this fix removed the exemption mechanism: the guard suite now fails by
route name, with no way to re-pin a breach.

## Recommendation

- Keep `Diagnosis (Bug Fixer)` and `Fix Evidence (Bug Fixer)` checked
- Check `Review (Reviewer)`
- Recommended bug status: `DONE`
- D1/D2/D3 need no follow-up bug; D2 is a UI/UX decision only if raised later
