# Bugfix Review: BUG-20260815-001_no_fork_guard_raw_color_violations

Reviewer: Iris-QC (`Mode: bugfix-review`)
Flow: bugfix
Scope: BUG-20260815-001_no_fork_guard_raw_color_violations
Work location: REQ-002 integration worktree
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Diff basis: uncommitted worktree diff (5 modified + 1 untracked file); no
committed BaseHead range exists for this patch.
Scope gate: `review/scope-gate.md` (Phase 1, `SCOPE_GATE_COMPLETE: YES`)

Verdict summary: DEFERRED_ONLY (verdict section at the end of this report).

## Reviewed Inputs And Code Scope

| Input | Use |
| --- | --- |
| `bug_master.md` (control checkout) | reported anchors + expected behavior |
| `diagnosis.md` | `## Pre-Fix Reproduction Gate`, root cause, fix strategy |
| `fix-evidence.md` | all five gate sections |
| `scrum-master-checkpoint.md` | anchors, named judgment calls |
| 6 changed files (diff + ranged reads) | patch verification |
| `mobile/test/design_system/no_fork_guard_test.dart` | guard contract |
| `add_clause_sheet.dart`, `splash_palette.dart` | claimed precedents |

## Independently Verified (not taken on trust)

1. **Patch scope is exactly the 6 declared files.** `git status --porcelain`
   plus `git diff --stat` show `+19 -7` across 5 modified files and one new
   untracked `on_accent_palette.dart`. No test file, no ARB, no unrelated
   screen. Reported anchors map 1:1 to diff hunks.
2. **Guard is genuinely green, re-run statically by the Reviewer.** Applying
   the guard's own contract (`_guardedDirs` = `lib/features`, `lib/app`,
   `lib/core`; `_forbiddenPatterns` = `Color(0x`, `Colors.`, `Platform.is`,
   `defaultTargetPlatform`) over the current working tree returns **zero**
   matches. The 7 reported violations are gone and no new one was introduced.
3. **Every substitution is value-identical.** `OnAccentPalette.foreground` is
   `Color(0xFFFFFFFF)` (`on_accent_palette.dart:16`) == the `Colors.white` /
   `Color(0xFFFFFFFF)` it replaces. `Color.fromARGB(0,0,0,0)` ==
   `Colors.transparent`. `Material(type: MaterialType.transparency)` replaces
   `Material(color: Colors.transparent)` on a Material carrying no elevation,
   shape, or shadow (`reminder_weekday_chips.dart:70-74`), and the InkWell keeps
   its own `customBorder: CircleBorder()`, so ink and clipping are unchanged.
   No rendered pixel changes; the value-identity claim holds by construction.
4. **`OnAccentPalette` is additive.** New file plus one barrel export line. No
   existing token file is modified, so no other consumer can be affected.

## Named Judgment Calls — Adjudication

**JC-1 — one shared `OnAccentPalette.foreground` vs 3 per-screen palettes:
CORRECT, endorsed.** `lib/design_system/tokens/` already holds 8 named
single-purpose palettes, and `splash_palette.dart:37` declares the identical
`static const Color foreground = Color(0xFFFFFFFF)` with the identical
documented rationale. The new file mirrors that shape exactly
(`abstract final class`, `static const`, design-source doc comment). Three
per-screen palettes would have triplicated `#FFFFFF` across three features,
which is precisely the fork ADR-004 exists to prevent. It was also correct
*not* to reuse `SplashPalette.foreground`: that file documents itself as
splash-screen-only, so reuse would have been semantic misuse.

**JC-2 — `Color.fromARGB(0,0,0,0)` / `MaterialType.transparency` for the 4 "no
paint" sites: accepted, but the two halves are not equally strong.**

- `MaterialType.transparency` (`reminder_weekday_chips.dart:71`) is
  unambiguously legitimate and is a strict improvement. Verified 15 call sites
  across 13 files in the guarded dirs — this is the repo's canonical
  transparent-ink-host idiom, and it removes a color value entirely rather than
  respelling one.
- `const Color _transparent = Color.fromARGB(0,0,0,0)`
  (`reminder_schedule_screen.dart:33`) is **accepted as repo-consistent, not as
  architecturally ideal.** Correction to the handoff framing: the "~15 existing
  call sites" figure belongs to the ink-host idiom above and is *not* support
  for this literal. In the guarded dirs there is exactly **one** precedent —
  `add_clause_sheet.dart:21` — which is committed on this branch and carries
  the same rationale verbatim ("no design-system token exists for a transparent
  value, and raw named/hex colour literals are forbidden outside
  `design_system/`"). So this is an already-accepted repo decision being
  followed, not a dodge invented to defeat this guard.
- It is nonetheless a substring-level pass rather than a token-level
  resolution: the guard's doc comment states "Only `design_system/` itself may
  contain a raw color literal", and a file-private `Color.fromARGB` literal in
  `lib/features` satisfies the pattern list but not that sentence. It is only
  invisible to the guard because `_forbiddenPatterns` omits the
  `Color.fromARGB`/`Color.fromRGBO` spellings. Recorded as D-1 below.
- Not blocking, because: the value is the *absence* of a fill rather than a
  design color; there is no correctness, safety, UX, or rendering risk (proven
  value-identical and covered by the scoped regression); and fixing it properly
  means minting a design-system no-paint value and migrating the pre-existing
  `add_clause_sheet.dart` site too — scope this bug does not own.

## Risk Surfaces And Critical Gates

| Risk surface | Gate | Result |
| --- | --- | --- |
| Original reported failure | `## Original Failure Recheck Gate` — `no_fork_guard_test.dart`, `Same modality as original: YES` | PASS. Native modality: the reported bug *was* a failing test, so test execution is the reported failure's own modality, not a downgrade. Reviewer re-ran the guard's patterns statically: 0 violations. |
| Pre-fix reproduction | `## Pre-Fix Reproduction Gate` in `diagnosis.md` | PRESENT + REPRODUCED. Exit 1, all 7 anchors matched 1:1. |
| Shared design-system abstraction | repo-wide guard scan + sibling call sites | PASS. Guard scan is whole-repo; all 4 `OnAccentPalette` consumers verified in the diff. |
| Mobile rendering (4 screens/widgets) | scoped `## Regression Evidence` | PASS. `+82 ~1 -0`, exit 0, covering `test/design_system` and every test file for the 4 patched surfaces. |
| Mobile build | `## Build Gate` — `flutter build apk --debug` | PASS, exit 0, plus `flutter analyze` clean on all 6 changed files. Whole-package analyze exit 1 is pre-existing (vendor `flutterfire` checkout + 81 lints, none in changed files). |
| App lifecycle / runtime startup | `## Runtime Startup Gate` | PASS. `emulator-5560`, APK installed, registry readiness probe `READY_OK` exit 0 with MainActivity resumed; shutdown PASS. |

Not applicable: persistence/schema/migration, external integration, async job,
security/auth, deep link/push, operational commands. No setup/configuration
surface is touched, so `deployment/configuration-guide.md` needs no update.
Rules 12e2/12e3 rendered visual fidelity are not triggered: this is a bugfix
review, not a UI-bearing story review, and the patch is proven value-identical.

Note on the full-suite baseline: `fix-evidence.md` states the pre-fix full-suite
baseline for the 8 remaining failures was not measured. Accepted — each of the 8
is mapped to an existing bug (BUG-20260814-002/003/004, BUG-20260815-002) and
none exercises a file this patch touches, and the scoped run covers every test
that does. `no_fork_guard_test.dart` has left the failing set, so this bug's
contribution to the RED suite is cleared.

## Deferred Findings

**D-1 — guard pattern list does not cover all raw-literal spellings.**
`_forbiddenPatterns` in `mobile/test/design_system/no_fork_guard_test.dart:18`
catches `Color(0x` and `Colors.` but not `Color.fromARGB(` / `Color.fromRGBO(`,
so the invariant its own doc comment states ("Only `design_system/` itself may
contain a raw color literal") is enforceable for only some spellings. Two sites
now sit in that gap: `add_clause_sheet.dart:21` (pre-existing) and
`reminder_schedule_screen.dart:33` (added here). Proper follow-up is a
design-system no-paint value plus migration of both sites, *then* widening the
pattern list — widening it first would immediately re-red the branch. Not
routed to this bug: it needs a design-system decision and touches a file outside
this bug's anchors.

**D-2 — reminder confirm CTA hand-rolls a construction the design system already
owns.** `reminder_schedule_screen.dart` wraps an `ElevatedButton` in a
gradient-painting `DecoratedBox` and suppresses the button's own background and
shadow — the same construction as
`design_system/adaptive/cupid_primary_button.dart:63,65`, which is legal only
because it lives in the exempt directory. Consolidating onto the existing
adaptive primary button would remove the need for a feature-local transparent
constant entirely and would subsume D-1's second site. Pre-existing from
STORY-021, out of this bug's scope.

## Traceability

| Reported anchor | Patch | Verified |
| --- | --- | --- |
| `ghost_settings_screen.dart:211` | `Colors.white` -> `OnAccentPalette.foreground` | diff hunk |
| `ghost_settings_screen.dart:411` | `Colors.white` -> `OnAccentPalette.foreground` | diff hunk |
| `notification_settings_screen.dart:359` | `Color(0xFFFFFFFF)` -> `OnAccentPalette.foreground` | diff hunk |
| `reminder_schedule_screen.dart:448,449,452` | `Colors.transparent` -> file-private `_transparent` | diff hunk (now `:452,453,456`) |
| `reminder_weekday_chips.dart:71` | `Material(color:)` -> `Material(type: MaterialType.transparency)` | diff hunk + ranged read |

Expected behavior from `bug_master.md` is met: the guard passes with 0
violations (independently confirmed), and 4 of the 7 anchors now resolve through
the shared design-token system while the remaining 3 resolve to a documented
no-paint constant per the accepted repo precedent (see JC-2 / D-1).

## State Recommendation

- Bug status: `DONE` (Scrum Master applies; Reviewer does not edit state).
- `bug_master.md` artifact checklist: `Review (Reviewer)` -> checked.
- Two deferred items (D-1, D-2) to record for follow-up; neither blocks closure.
- Git note for Scrum Master: `bug_master.md` and `scrum-master-checkpoint.md`
  exist only in the control checkout, not in this integration worktree. The
  commit for this fix should carry the full bug folder alongside the 6 code
  files so the branch keeps the bug record intact.

## Verdict

Outcome: DEFERRED_ONLY

The reported failure is fixed at every reported anchor, the guard is
independently confirmed green, all five gates (pre-fix reproduction, same-
modality recheck, build, runtime startup, scoped regression) pass, and the patch
is value-identical so it carries no rendering or behavioral risk. JC-1 is the
right call. JC-2 is legitimate reuse of an already-merged repo idiom rather than
guard evasion, but it leaves a real architectural gap in the guard's coverage,
recorded as D-1 for a separate design-system decision.
