# Scope Gate: BUG-20260816-001 Welcome Backdrop + Google CTA Brand Mark

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: bugfix-review
Reviewer: Iris-QC
Review report path: `data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/review/review-report.md`
Scope gate path: `data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/review/scope-gate.md`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Diff baseline: `git -C <worktree> diff 10c05c3 fe59592`

## Source / Test Files In Scope

| File | Read strategy |
|---|---|
| `mobile/lib/design_system/tokens/cupid_color_tokens.dart` | diff hunks only |
| `mobile/lib/features/auth/presentation/screens/welcome_screen.dart` | diff hunks only |
| `mobile/test/features/auth/presentation/screens/welcome_screen_test.dart` | diff hunks only |
| `mobile/lib/features/auth/presentation/screens/login_screen.dart` | grep for `markSize`/`markGap` only (reference pattern, 27 KB — no full read) |
| `cupid-app-design-system/project/Cupid Screens.dc.html` | ranged read lines 68-82 + grep line 84 (242 KB — no full read) |

3 changed files, well inside the bugfix budget.

## Evidence Files In Scope

- `data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/bug_master.md`
- `data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/diagnosis.md` (§ Pre-Fix Reproduction Gate, § Root Cause)
- `data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/fix-evidence.md` (§ Original Failure Recheck Gate, § Build Gate, § Runtime Startup Gate)
- `data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/visual-recheck/before-welcome-emulator-5560.png`
- `data/bugs/BUG-20260816-001_welcome_screen_backdrop_and_google_cta_brand_mark/visual-recheck/implemented-welcome-emulator-5560.png`
- `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-033_app_shell_design_system_deltas/visual-fidelity/design-reference-welcome-android.png`

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate |
|---|---|
| Typed design-token contract (`required` const-ctor param on a `ThemeExtension`) | full-suite compile + `flutter analyze`; independent construction-site sweep |
| Mobile interaction / rendered UI | same-modality rendered visual recheck vs the design reference |
| Design-system no-fork constraint (ADR-004) | `no_fork_guard_test.dart` + no raw hex / 165deg literals under `lib/features` |
| Mobile app lifecycle | registry readiness probe (`mobile-app`) |
| Regression coverage | `welcome_screen_test.dart` no longer pins the defect |

Not touched: persistence, schema/migration, auth flow, network, async job, payment, deep link, permissions, local storage, operational command, setup/configuration. Rule 12a configuration-guide verification is therefore not applicable.

## Focused Query Keys For Phase 2

- `gradientBrandBackdrop`, `gradientHot`, `_gradient165Begin`, `_gradient165End`
- `CupidColorTokens(` — external construction sites
- `_FilledCta`, `mark`, `markSize`, `markGap`, `CupidBrandMark.google`
- `linear-gradient(165deg` and `width:20px;height:20px` / `gap:9px` in the design source
- `0.25881904510252074` / `0.9659258262890683` residue under `lib/features`

## Gate Decision

Phase 2 may proceed. Scope is bounded, all governing artifacts exist, `BUG_FIX_COMPLETE: YES`, and the reproduction/recheck gates are present and same-modality.
