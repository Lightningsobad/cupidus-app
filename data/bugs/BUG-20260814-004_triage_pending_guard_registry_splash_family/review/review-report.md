# Bugfix Review: BUG-20260814-004_triage_pending_guard_registry_splash_family

Reviewer: Iris-QC (`Mode: bugfix-review`)
Flow: bugfix
Scope: BUG-20260814-004_triage_pending_guard_registry_splash_family
Work location: REQ-002 integration worktree
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Diff basis: uncommitted worktree diff — 1 modified file (`+2 -2`) plus 2
untracked bug-record files. No committed BaseHead range for this patch.
Scope gate: `review/scope-gate.md` (Phase 1, `SCOPE_GATE_COMPLETE: YES`)

Verdict summary: DEFERRED_ONLY (verdict section at the end of this report).

## Reviewed Inputs And Code Scope

| Input | Use |
| --- | --- |
| `bug_master.md` (control checkout) | 3 reported anchors + expected behavior |
| `diagnosis.md` | triage verdict, `## Pre-Fix Reproduction Gate`, `## Anchor (b) Evidence` |
| `fix-evidence.md` | all five gate sections |
| `scrum-master-checkpoint.md` | anchors, triage mandate |
| `permissions_screen.dart:60-99` | anchor (a) patch site |
| `reminder_strings.dart:8-25`, `:140-151` | canonical-copy-reuse claim |
| `reminder_copy_guard_test.dart` | guard contract for the independent re-run |
| `main_preview.dart:186-251` | anchor (b) negative claim |
| `home_screen.dart` / `splash_screen.dart` | anchor (c) negative claim (`git grep`, no full read) |

## Independently Verified (not taken on trust)

**1. Patch scope is exactly 1 file / 2 lines.** `git status --porcelain
--untracked-files=all` shows only `permissions_screen.dart` modified plus the
two new bug-record files. No test file, no ARB, no widget-tree or API change.
Confirms the copy-only claim.

**2. Anchor (a) is genuinely cleared — guard re-run independently.** I read the
guard's actual contract (`reminder_copy_guard_test.dart:18-22,39-64`: recursive
scan of `lib/`, skip lines starting with `//`, extract quoted-literal contents,
lowercase, match `báo thức` / `synced alarm` / `do not disturb`) and applied it
myself over `mobile/lib`. Exactly **two** hits remain repo-wide, and both are
`///` doc-comment lines the guard deliberately skips:
`reminder_strings.dart:10` (the rule's own documentation) and
`notification_settings_screen.dart:16` (a quoted design-source clause explaining
the deleted DND claim). Neither is shipped copy. Zero hits remain in
`permissions_screen.dart`. The guard is green for the right reason, not by
accident.

**3. The replacement wording is the branch's canonical string, not invented.**
Verified at both cited sites: `reminder_strings.dart:19`
(`reminderScreenTitle`) and `:145` (`reminderNotificationsRowTitle`) each read
`viEn('Nhắc nhở đồng bộ', 'Synced Reminder')`. The patch
(`permissions_screen.dart:80-81`) uses exactly that vi/en pair. Claim confirmed.

**4. Anchor (b) — NOT REPRODUCED, confirmed independently.** `main_preview.dart:192`
carries a real `'permissions': const PreviewScreenEntry(builder: _buildPermissions, ...)`
wired to the live screen, and the not-implemented set at `:244` contains only
`shareapprove`, `shareedit`, `shareok`, `sharepick`, `themedetail`, `themes`,
`zodiac` — `permissions` is absent. Registry and code agree. Closing this anchor
with no patch and no follow-up bug is correct. (Transcription nit, no impact:
`diagnosis.md` renders that declaration as `const Set<String>`; the source is
`const List<String>`.)

**5. Anchor (c) — NOT REPRODUCED, confirmed independently.** `git ls-files
"mobile/**splash*"` returns only `splash_palette.dart`,
`splash_screen.dart`, and `splash_screen_test.dart`; there is no
`splash_design_fidelity_test.dart` anywhere under `mobile/`, tracked or
untracked. And `resolvePairingStatus` occurs 10 times in `mobile/lib`, all in
`features/home/presentation/home_screen.dart` — zero occurrences in
`splash_screen.dart`. The anchor was transcribed against the wrong widget and a
filename that was never merged. Closing it with no patch and no follow-up bug is
correct.

**6. Triage discipline is sound.** The bug was filed explicitly untriaged ("one
bug vs three"). The diagnosis reaches three independent findings with per-anchor
evidence rather than assuming a shared root cause, and correctly declines to
raise `TRIAGE_SPLIT_REQUIRED` because neither closed anchor leaves a live defect
to carry. The scope correction is also right and I confirmed it: the report
paired `no_fork_guard_test.dart` with anchor (a), but that guard has no
`"Synced Alarm"` rule — its RED belonged to BUG-20260815-001 (DONE). Anchor (a)
is carried solely by `reminder_copy_guard_test.dart`.

## Risk Surfaces And Critical Gates

| Risk surface | Gate | Result |
| --- | --- | --- |
| Original reported failure | `## Original Failure Recheck Gate` — `reminder_copy_guard_test.dart`, `Same modality: YES` | PASS (`+2: All tests passed!`, exit 0). Native modality: the reported bug *was* a failing test, so test execution is its own modality, not a downgrade. Reviewer re-ran the guard's rule statically: 0 shipped-copy hits. |
| Pre-fix reproduction | `## Pre-Fix Reproduction Gate` in `diagnosis.md` | PRESENT + REPRODUCED for anchor (a) (exit 1, both lines `:80`, `:81` matched); explicit NOT-REPRODUCED evidence for (b) and (c), both re-verified above. |
| ADR-002 copy contract | independent banned-token sweep of `mobile/lib` | PASS — only two deliberate doc-comment hits, both skipped by the guard's own `//` rule. |
| Mobile build | `## Build Gate` — `flutter build apk --debug` | PASS, exit 0, plus `flutter analyze` clean on the changed file. |
| App lifecycle / runtime startup | `## Runtime Startup Gate` | PASS. `emulator-5560`, APK installed, registry readiness probe `READY_OK` with MainActivity resumed; shutdown PASS (0 resumed activities). |
| Mobile rendering (onboarding card copy) | `## Regression Evidence` | PASS — `+156 ~2`, exit 0, scoped to onboarding, core/navigation, reminders, the splash suite, and the no-fork guard, i.e. the changed screen's area plus every suite named in the three anchors. 2 skips pre-existing. |

Not applicable: persistence/schema/migration, external integration, async job,
security/auth, deep link/push, operational commands. No setup/configuration
surface is touched, so `deployment/configuration-guide.md` needs no update.
Rules 12e2/12e3 rendered visual fidelity are not triggered: this is a bugfix
review, not a UI-bearing story review, and no layout, token, widget structure,
or route changed — only two display strings.

## Deferred Findings

**D-1 — the feature name is duplicated outside its canonical source, and the
guard cannot catch drift to a *new* wrong name.** `reminder_strings.dart:8`
mandates canonical copy only for `features/reminders/presentation/`, so
`features/onboarding/.../permissions_screen.dart` sits outside that mandate and
hardcodes the feature name inline. That gap is exactly how this defect survived:
the onboarding card kept the pre-ADR-002 name while the reminders feature moved
on. The guard bans three specific legacy tokens, so a future drift to a third
non-canonical wording (e.g. "Sync Reminder") would pass silently in this file.
Durable follow-up is to source the name from `ReminderStrings` (interpolated
into the onboarding sentence) or to widen the canonical-copy mandate beyond
`features/reminders/presentation/`. Not routed to this bug: it is an ADR-002
architecture decision, not part of clearing the RED test.

Residual risk (no action): closing anchor (c) rests on this integration branch's
state. Since every REQ-002 story branch is already merged here, there is no
unmerged branch left that could reintroduce the missing test file.

## Traceability

| Anchor | Reported | Verdict | Independent verification |
| --- | --- | --- | --- |
| (a) `"Synced Alarm"` at `permissions_screen.dart:80-81` | guard RED | FIXED | patch site read; guard rule re-applied over `mobile/lib` → 0 shipped-copy hits |
| (b) `_notImplementedCanvasIds` lists `permissions` | registry mismatch | NOT REPRODUCED | `main_preview.dart:192` real entry; `:244` set excludes `permissions` |
| (c) `splash_design_fidelity_test.dart` compile error | missing `SplashScreen.resolvePairingStatus` | NOT REPRODUCED | file absent under `mobile/`; `resolvePairingStatus` declared only in `home_screen.dart` |

Expected behavior from `bug_master.md` is met on all three anchors: (a) the
guard tests pass with no banned copy string; (b) the registry already reflects
the implemented canvas; (c) the splash suite that actually exists compiles and
passes. No follow-up bug is warranted for (b) or (c).

## State Recommendation

- Bug status: `DONE` (Scrum Master applies; Reviewer does not edit state).
- `bug_master.md` artifact checklist: `Review (Reviewer)` -> checked.
- One deferred item (D-1) to record for follow-up; it does not block closure.
- Git note for Scrum Master: `bug_master.md` and `scrum-master-checkpoint.md`
  exist only in the control checkout, not in this integration worktree. The
  commit should carry the full bug folder alongside the single code file so the
  branch keeps the bug record intact.

## Verdict

Outcome: DEFERRED_ONLY

Anchor (a) is fixed with the branch's own canonical wording, and I re-ran the
guard's rule myself rather than trusting the recorded run. Both negative
reproduction claims were re-verified against the branch and hold, so closing (b)
and (c) without a patch or a follow-up bug is correct. All gates
(pre-fix reproduction, same-modality recheck, build, runtime startup, scoped
regression) pass, and the change is copy-only with no behavioral surface. D-1
records the structural gap that let the stale name survive.
