# Scope Gate: BUG-20260814-003 Caption Typography Token Mismatch

Phase: SCOPE_GATE
Review type: bugfix-review
Bug id: BUG-20260814-003_caption_typography_token_mismatch
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Diff baseline: working tree vs `HEAD` (`7225b95`) — the fix is uncommitted; `git status --porcelain` shows exactly the 5 modified files claimed in `fix-evidence.md` plus the 2 new bug artifacts.
Review report path: `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/review/review-report.md`

## Readiness

| Required input | Present |
|---|---|
| `bug_master.md` | YES |
| `diagnosis.md` (incl. `## Pre-Fix Reproduction Gate`) | YES |
| `fix-evidence.md` (`BUG_FIX_COMPLETE` not `NO`, no `WAITING_FOR_USER_LOGS`) | YES |
| Exact changed files | YES (git diff, 5 files, `+57 -3`) |
| Verification evidence sections | YES (recheck / analyze / build / runtime / regression) |
| Pending retro rework (`data/retro-audit/rework-backlog.md`) | ABSENT — no `Retro-Bypass` needed |

## Source/Test Files In Scope

Implementation (all under the worktree):
1. `mobile/lib/design_system/tokens/cupid_typography_tokens.dart`
2. `mobile/lib/features/account/presentation/screens/profile_edit_screen.dart`
3. `mobile/lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart`
4. `mobile/test/design_system/theme_matrix_test.dart`
5. `mobile/test/features/onboarding/presentation/screens/onboarding_profile_setup_screen_test.dart`

Read-only corroboration (not changed by this patch, needed to falsify the four load-bearing claims):
6. `mobile/lib/features/pet/presentation/widgets/pet_reactions_card.dart` — eyebrow `letterSpacing` derivation
7. `mobile/test/features/pet/presentation/pet_design_fidelity_test.dart` — `:150` eyebrow assertion + its git history
8. `mobile/test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart` — anchor line `:188` vs reported `:238`

## Evidence Files In Scope

- `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/bug_master.md`
- `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/diagnosis.md`
- `data/bugs/BUG-20260814-003_caption_typography_token_mismatch/fix-evidence.md`
- `data/devops/system/runtime-command-registry.json` (`mobile-app` entry only — runtime gate backing + reported launcher-class defect)

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate | Verification plan |
|---|---|---|
| Shared design-token contract (`caption`, 179 call sites / 60 files) | Targeted design-fidelity assertions + full-suite regression | Rerun the Original Failure Recheck Gate command myself; accept the recorded full-suite run under rule 18 |
| Mobile interaction / rendering (two profile screens) | Widget assertions pinning the 11.5px helper | Rerun the two changed test files; read the new assertion for tautology |
| Mobile static analysis | `flutter analyze` on the 5 changed files | Rerun myself |
| Mobile build + app launch | Build gate + runtime startup gate | Accept recorded evidence under rule 18 (device/emulator lifecycle is not Reviewer-owned; see report) |
| Regression breadth | Full mobile suite | Accept recorded evidence under rule 18 (~1242 tests); cross-check the 2 residual failures are attributed and pre-existing |

Not applicable: 12e1 entry-point reachability, 12e2/12e3 per-story rendered design fidelity, 12g story runtime smoke — those are story-level gates; this is a `bugfix-review`, whose runtime gate is the `## Runtime Startup Gate` in `fix-evidence.md` (rule 16).

## Query Keys For Phase 2

- `fontSize: 13` / `fontSize: 11.5` / `_zodiacHelperFontSize` (token + both consumers)
- `0.575`, `0.65`, `0.05 *`, `letterSpacing` (claim 1: derived, not declared — must find NO literal under `mobile/lib`)
- `pet_design_fidelity_test.dart` `:150`, `uppercase muted eyebrow` + `git log -L` on that range (claim 2: pre-existing, genuinely RED)
- `waiting_screen_design_fidelity_test.dart` `:188`, `applies the design source typography and muted subtitle` (claim 3: anchor shift)
- `Cung hoàng đạo tính tự động` + `zodiac helper keeps the canvas 11.5px` (claim 4: AC3 preserved, assertion non-tautological)
- `mobile-app` in `runtime-command-registry.json` (registry launcher-class defect F-4)

## Phase 2 Decision

Phase 2 MAY PROCEED. Scope is within `bugfix-review` budget (5 changed files + 3 read-only corroboration files, no governing artifact over ~20 KB). No blocking input is missing.

SCOPE_GATE_COMPLETE: YES
