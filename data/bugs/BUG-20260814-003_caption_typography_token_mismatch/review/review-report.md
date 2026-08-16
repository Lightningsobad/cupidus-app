# Bugfix Review: BUG-20260814-003 Caption Typography Token Mismatch

Outcome: DEFERRED_ONLY

Review type: bugfix-review
Bug id: BUG-20260814-003_caption_typography_token_mismatch
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Scope gate: `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/review/scope-gate.md`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Diff baseline: working tree vs `HEAD` (`7225b95`) — 5 modified files, `+57 -3`, matching `fix-evidence.md` exactly
Blocking findings: 0
Deferred findings: 4

## Rationale

The fix is correct, minimally scoped, and its root-cause analysis holds up under
independent re-derivation. All four load-bearing claims were re-checked from
source and git history rather than accepted from `diagnosis.md`; all four are
true. The two gates a Reviewer can cheaply own were rerun and reproduced the
recorded results exactly. The remaining findings are pre-existing role-split
deltas and one out-of-scope registry defect, none of which blocks closure.

## Independent Re-derivation Of The Four Load-Bearing Claims

| # | Claim | Verdict | Evidence I derived myself |
|---|---|---|---|
| 1 | One shared root cause, not two independent drifts | CONFIRMED | `mobile/lib/features/pet/presentation/widgets/pet_reactions_card.dart:41` is `letterSpacing: 0.05 * type.caption.fontSize!` — derived, never declared. `git grep '0\.575\|0\.65' -- mobile/lib` returns **no** `0.575` anywhere and only two `0.65` hits, both `alpha` values in unrelated files (`welcome_screen.dart:344`, `vibe_mood_face.dart:361`); none is a `letterSpacing`, none is under `design_system`. A sweep of every `letterSpacing` in `mobile/lib` shows `pet_reactions_card.dart:41` is the **only** site deriving from `type.caption.fontSize`. `0.05 × 11.5 = 0.575` and `0.05 × 13 = 0.65` reproduce both observed values from one token. |
| 2 | Already covered, not a new assertion dressed up as pre-existing | CONFIRMED | `git blame` on `pet_design_fidelity_test.dart:150` → `64a2defc alan 2026-08-13`, commit `64a2def` (STORY-024). The file is **not** in this patch's `git status` and its last two commits are both STORY-024. The token went `13 → 11.5` on **2026-08-14** (`bf01450`, STORY-033) — after the assertion existed. So the assertion was authored GREEN and turned RED by STORY-033, exactly as claimed. RED-ness is deterministic given claim 1, not merely reported. |
| 3 | Anchor shifted to `:188`, not `:238` | CONFIRMED | `waiting_screen_design_fidelity_test.dart:188` is `expect(subtitle.style?.fontSize, 13);` inside `applies the design source typography and muted subtitle`, on the subtitle `Gửi mã rồi mà chưa thấy ai vào. Chọc Bae một cái đi.` — the same assertion the bug report cited at `:238`. Correction is accurate. |
| 4 | STORY-033 AC3 preserved, not silently re-broken | CONFIRMED | STORY-033 `ux/ux-spec.md:154-159` names the **zodiac helper text** as AC3's acceptance-critical case (11.5px, fixing its 2-line wrap). `git show --name-only bf01450` shows STORY-033 changed only 3 source files, none of them a profile screen — so AC3 did ride entirely on the shared token, with no assertion of its own. Both consumers now state it locally: `onboarding_profile_setup_screen.dart:326-329` and `profile_edit_screen.dart:229-232` apply `fontSize: _zodiacHelperFontSize` (11.5) to that exact `Text`. The new test is **not** tautological: the token is now 13 and the test asserts 11.5, so it passes only because the local override does real work — remove the override and it reads 13 and fails. Confirmed executing and green. |

## Gate Verification

| Gate | How verified | Result |
|---|---|---|
| Pre-Fix Reproduction Gate (`diagnosis.md`) | Present, 4 assertions, pre-edit | PASS |
| Original Failure Recheck Gate | **Rerun by me** — same 4 test files, `--reporter failures-only` | `+36: All tests passed!` exit 0 — matches `fix-evidence.md` |
| Static Analysis Gate | **Rerun by me** — `flutter analyze` on the 5 changed files | `Analyzing 5 items... No issues found!` exit 0 — matches |
| New regression assertions | **Rerun by me** — `theme_matrix_test.dart` + `onboarding_profile_setup_screen_test.dart` | `+19: All tests passed!` exit 0; both new tests named in the output and green |
| Build Gate | Accepted from `fix-evidence.md` under rule 18 | PASS (recorded) |
| Runtime Startup Gate | Accepted from `fix-evidence.md` under rule 18 | PASS (recorded) |
| Full Regression (~1242 tests) | Accepted from `fix-evidence.md` under rule 18 | PASS (recorded): 1240 pass / 2 skip / 2 fail, both pre-existing |

Same modality as original: YES. The reported failures were design-fidelity
widget assertions and the recheck exercises those same assertions.

**Evidence accepted rather than re-run, and why** (stated explicitly as the
handoff requires): the Build, Runtime Startup, and full-suite Regression gates
were accepted from `fix-evidence.md` under Core Rule 18. Each is current (same
branch, same working tree I diffed), specific (exact commands, exact device
`emulator-5560`, exact counts and exit codes), registry-backed
(`data/devops/system/runtime-command-registry.json`, `mobile-app`), and
uncontradicted by anything I observed. Re-running an APK build, an
emulator install/launch/force-stop cycle, and ~1242 tests would have cost real
time for a near-certain duplicate of a recorded result. The two residual
failures are attributed to BUG-20260814-002 and are cross-checked as present in
two earlier bugs' baselines, so the "4 fixed, 0 introduced" net claim is
internally consistent.

## Deferred Findings

**D-1 — STORY-033's merged visual-fidelity PASS on `notifs`/`alarm` is now stale.**
This one is not in `fix-evidence.md` § Residual Risk and should be. STORY-033's
`visual-fidelity/visual-fidelity-report.md:80-90` records `AC3 — PASS` on the
basis that, **at caption = 11.5**, the seven `notifs` caption sub-labels, the
three uppercase section labels, and four further `alarm` caption sites "match
the reference in size and in line count". Both screens do consume the token
(`notification_settings_screen.dart` 2 sites, `reminder_schedule_screen.dart`
5 sites), so restoring 13 moves them back off the value that comparison
certified. Non-blocking, for three reasons: (a) 13 is the value in place from
`eeaeeae` (REQ-001/STORY-001) until 2026-08-14, so this is a return to a
long-shipped state, not a novel one; (b) `ux/uiux-spec.md` §4 documents the
caption role as 13pt and the three RED sub-copy assertions transcribe real
13px design-source rows; (c) STORY-033's own call-site sweep
(`visual-fidelity-report.md:92-114`) concluded no layout is keyed to 13px —
every caption consumer sizes intrinsically with no fixed height and no
`maxLines` except one ellipsised site — so no wrap or overflow regression is
expected in either direction. Action: fold `notifs`/`alarm` into the follow-up
small-text-scale bug below, and re-validate them at the REQ-002 requirement
integration `mobile-visual-audit.md`, which is the cross-screen gate that
exists for exactly this.

**D-2 — F-1 / F-2 / F-3 are correctly deferred.** Verified rather than assumed:
STORY-033's `ux/ux-spec.md:161-171` explicitly declares the role split out of
its scope and asks for it to be raised as a follow-up, and independently flags
the 11px uppercase field label as a known residual micro-delta. That is the same
delta as F-2, now 2px instead of 0.5px. F-1 (12px card eyebrows) and F-3 (12.5px
avatar crop hint) are the same class. None is asserted RED and none is named by
this bug. Folding them in would have required the new-token split this bug
correctly refused. Recommend one new bug covering the small-text scale as a
whole — 11px labels / 11.5px inline helpers / 12px eyebrows / 12.5px hints /
13px sub-copy — with D-1 included in its scope.

**D-3 — the `0.65` eyebrow assertion transcribes the token, not the canvas.**
`pet_design_fidelity_test.dart:150` is now green, but per F-1 the canvas draws
that eyebrow at 12px (`letter-spacing:.05em` → 0.6). The test is self-consistent
with the token and is a valid regression guard; it is not an independent check
of the design source. Belongs with the D-2 follow-up.

**D-4 — runtime registry launcher-class defect (DevOps).** Independently
confirmed, not accepted on report: `mobile/android/app/src/main/AndroidManifest.xml:13`
declares `android:name=".MainActivity"`, which resolves against the Gradle
`namespace` (`com.snapsofts.cupid_mobile`), while `applicationId` is
`com.snapsofts.cupid`. So the real component is
`com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` and the registry's
`com.snapsofts.cupid/.MainActivity` cannot resolve. Correctly left unchanged —
the registry is outside this bug's write scope. Route to DevOps; it will break
any future automated mobile runtime smoke that trusts the registry entry.

## Traceability

| Input | Use |
|---|---|
| `bug_master.md` | Reported observed-vs-expected (13 vs 11.5), 3 named anchors |
| `diagnosis.md` | `## Pre-Fix Reproduction Gate` present; root cause, anchor correction, Not-In-Scope set |
| `fix-evidence.md` | 5 changed files, 5 gate sections; `BUG_FIX_COMPLETE` not `NO`, no `WAITING_FOR_USER_LOGS`, no instrumentation-only handoff |
| `git diff` / `git blame` / `git log -L` / `git show` | Independent confirmation of claims 1-4 and of the `13 → 11.5 → 13` token timeline |
| STORY-033 `ux/ux-spec.md`, `coding-plan/test-results.md`, `visual-fidelity/visual-fidelity-report.md` | AC3 intent, deferred role-split clause, and the stale-evidence surface in D-1 |
| `AndroidManifest.xml` | D-4 confirmation |

Risk surfaces touched: shared design-token contract (179 `caption` call sites
across 60 files), mobile interaction/rendering on two profile screens, mobile
static analysis, mobile build + app launch, suite-wide regression. Every one has
a passing critical gate; none is deferred.

Not applicable to a bugfix review: rules 12e1 (entry-point reachability), 12e2 /
12e3 (per-story rendered design fidelity), 12g (story runtime smoke). Those are
story-level gates. The bugfix runtime gate under rule 16 is
`fix-evidence.md` § Runtime Startup Gate, which passes.

No setup/configuration impact: the patch changes no env var, dependency, or
deployment step, so `deployment/configuration-guide.md` needs no update. The one
configuration-adjacent item (D-4) is a pre-existing registry defect the fix did
not introduce and correctly did not touch.

## State Recommendation

- Bug status: `DONE`
- Keep `Fix (Bug Fixer)` checked; check `Review (Reviewer)`
- Scrum Master to open one follow-up bug for the small-text scale role split,
  scoped to include D-1, D-2, and D-3
- Scrum Master to route D-4 to DevOps as a runtime-registry correction
- Re-validate `notifs` / `alarm` typography at the REQ-002 requirement
  integration `mobile-visual-audit.md`
