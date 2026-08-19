# Review Report: STORY-055 Hardening - Design System FAB/CTA Shape and Sizing Fidelity

Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Story: STORY-055_design_system_fab_cta_hardening (Complexity: trivial, Lane: mobile, Retro-Type: RED-PATCH, RWB-20260816-021)
Review mode: compact-story-review
Reviewed commit: `72bf3dff2719b2122a1e2d44ea9124f199b7ccfc` (parent `029390757fc077eac20792996a1eb583b172cff5`)
Reviewer: Iris-QC
Date: 2026-08-19

Outcome: PATCH_REQUIRED

## Scope Gate

Phase: SCOPE_GATE (inline, per compact-story-review)

- Review type: compact-story-review, mobile lane, UI-bearing, design source configured.
- Report path: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-055_design_system_fab_cta_hardening/review/review-report.md`
- Source/test files in scope (4, from the single implementation commit):
  `mobile/lib/design_system/adaptive/cupid_add_action.dart`,
  `mobile/lib/design_system/adaptive/cupid_primary_button.dart`,
  `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart` (1 line),
  `mobile/test/design_system/adaptive_widgets_test.dart`
- Evidence files in scope: `visual-fidelity/visual-fidelity-report.md` and the 6 PNGs in `visual-fidelity/`
- Independent source check: `cupid-app-design-system/project/Cupid Screens.dc.html` lines 875-889
- Query keys: AC1-AC5, `_materialFabSize`/`_materialFabRadius`/`_materialFabGlyphSize`, `_primaryCtaHeight`, `_primaryCtaFontSize`, `leadingIcon`, `_leadingIconGap`, M-1
- Diff note: `BaseHead` equals current worktree HEAD, so the diff was taken from `git show 72bf3df` per the handoff instruction.
- Phase 2 proceeded; no scope blocker.

## Acceptance Criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC1 D-1 FAB shape/fill/glow/size/glyph | PASS | `cupid_add_action.dart` 60x60 `SizedBox` + `DecoratedBox(gradient: colors.gradientHot, borderRadius: 20, boxShadow: colors.glowShadow)`, transparent/zero-elevation FAB, `Icon(size: 27)`; matches design source line 881 verbatim (independently read); visible in `implemented-expense-emulator-5560.png` vs `design-reference-expense-android.png` |
| AC2 D-2 height/font/leading glyph | PASS | `_primaryCtaHeight` 54→52, `_primaryCtaFontSize` 15.5, `leadingIcon` optional (default `null`), glyph 21 + `SizedBox(width: 8)`; matches design source line 884 verbatim, including the 21px glyph the requirements left unspecified. Sole call site is `expense_history_screen.dart:227`, inside the existing `if (isIos)` branch (verified in code). Rendered in `implemented-expense-ios-cta-emulator-5560.png` |
| AC3 No regression across every real consumer | PARTIAL — see F-1 | Compile/analyze/test half PASS (`flutter analyze`: 0 errors/0 warnings, touched files `No issues found!`; `flutter test`: 1313 passed / 2 skipped / 0 failed). Rendered spot-check half has no evidence |
| AC4 M-1 re-confirmed, not fixed | PASS | `implemented-expense-fab-overlap-emulator-5560.png` shows the last row `Nồi chiên không đầu` amount clipped to `1.20`, matching the report's claim; iOS capture at the same row renders the full `1.200.000₫`, so Material-only is confirmed by observation, not inference. Only `expense_history_screen.dart` edit in the diff is the one-line `leadingIcon:` — no scroll/padding change, as AC4 requires |
| AC5 Rendered visual-fidelity evidence | PASS | 4 `implemented-*` + 2 reused reference PNGs present; `visual-fidelity-report.md` records `VISUAL_FIDELITY: PASS` with per-property tables and named states, not a bare token; `Design-Screen: expense` recorded |

## Touched Risk Surfaces And Critical Gates

| Surface | Critical gate | Result |
|---|---|---|
| Mobile interaction / shared design-system component (25 call sites) | Targeted widget tests on both platform silhouettes | PASS — new FAB test asserts size/gradient/glow/radius/glyph; CTA tests assert 52/15.5/w800, 21pt glyph, measured 8pt gap, and no `Icon` descendant when `leadingIcon` is omitted |
| Mobile static analysis / build | `flutter analyze`, `flutter test` | PASS (evidence in `visual-fidelity-report.md` AC3 section; not rerun per prefer-existing-evidence) |
| Mobile design fidelity (12e2/12e3) | Implementer capture + comparison, verified by reading the images | PASS — both images open, both depict this story's Expense History screen in the built app, no error/blank/wrong-screen frame, and what is visible does not contradict the `PASS` for D-1/D-2 |
| Mobile navigation / discoverability (12e1) | Reachable entry point | PASS — no new capability or entry point; both components sit on already-reachable existing screens. Verified in code: the CTA is inside the existing Expense History `if (isIos)` sliver and the FAB is that screen's `Scaffold.floatingActionButton`; the screen is behind the `Ví chung` bottom-nav tab |
| Runtime startup smoke (12g) | Not required | Story `Complexity: trivial`, so 12g does not apply. The captures independently show the app launching on `emulator-5560` and reaching the screen without a crash or error frame |
| Setup/configuration | Not required | No env, dependency, runtime-registry, or infra surface touched; `deployment/configuration-guide.md` needs no update |

OQ discipline: `requirements.md` `## Open Question Impact` records no blocking OQ, OQ5 as RESOLVED (dark + `vi` only), and R8 as not applicable. Captures were taken in the shipped dark + `vi` configuration, matching the OQ5 resolution. No scope was blocked or over-blocked.

## Blocking Findings

### F-1 (AC3) — the rendered spot-check on non-anchor consumers was substituted, not performed

AC3 requires, verbatim: "a rendered spot-check across at least one full-screen consumer and one modal-sheet consumer other than the Expense History anchor (e.g. Dream Jar List and Add Expense Sheet) shows no overflow, clipping, or layout breakage".

`visual-fidelity-report.md` lines 139-142 answer this with: "Rendered spot-check beyond the anchor is covered by the widget tests, which build both components on both platform silhouettes; the height/font-size change is a 2pt shrink inside an already-`SizedBox`-constrained band and introduces no overflow or clipping." All 6 evidence files are the Expense History anchor plus STORY-043's two reused references — there is no non-anchor capture.

A widget test that builds the component in isolation is not a rendered check of the component inside a real consumer's layout, so this is a substitution for the AC's stated evidence, not a form of it, and no approved scope change or waiver permits it.

This is not purely formal. The story's own AC4 evidence establishes the mechanism: growing the FAB from 56x56 to 60x60 measurably worsened the clipping on the one screen that was rendered ("marginally wider than STORY-043 recorded", `visual-fidelity-report.md` lines 152-156). The other two `CupidAddAction` consumers — `dream_jar_list_screen.dart` and `gallery_empty_view.dart` — inherited the same 4pt growth and were never rendered, so the exact defect class this story confirmed on the anchor is unexamined everywhere else it ships. The reasoning offered in place of the capture ("a 2pt shrink … introduces no overflow") also addresses only the D-2 shrink and not the D-1 growth.

Per rule 12c the gate is `PATCH_REQUIRED` rather than deferred, because implementation can still supply it: `emulator-5560` and the preview build/capture procedure recorded in `visual-fidelity-report.md` lines 39-51 are the same ones needed, and this is the primary proof of the changed behavior on the 24 consumers outside the anchor.

## Deferred Findings

- D-1 (deferred, non-blocking): the FAB's design-source glow is hardcoded `0 8px 24px rgba(255,127,182,.45)` while the implementation uses the `glowShadow` token (`0 8px 28px rgba(255,107,168,.34)`). AC1 mandates the token, the implementation follows AC1, and the divergence is measured and recorded rather than silently substituted (`visual-fidelity-report.md` lines 81-90). Leave for a future FAB-glow token decision; do not change under this story.
- D-2 (deferred, non-blocking): `design-reference-expense-ios.png` does not show the iOS CTA — it falls below the reference render's visible area — so AC2's CTA comparison rests on the design-source HTML at line 884 rather than on the reference image. I re-read that line independently and the report's transcription (`height:52px`, `gap:8px`, `font-size:15.5px`, `font-weight:800`, glyph `font-size:21px`) is exact, so the evidence chain holds. Worth noting for any future story that reuses this reference pair for CTA work.
- D-3 (deferred, pre-existing, out of scope): the anchor captures differ from the reference on several screen-level points unrelated to these two components (summary caption wording, category chip count, absent back arrow, and the preview harness rendering without the bottom nav shell). These belong to the Expense History screen's own scope from STORY-028/STORY-043, not to `design_system/adaptive/**`, and this story did not make them worse. The `VISUAL_FIDELITY: PASS` here should be read as component-scoped to D-1/D-2, which is what the report's own verdict section states.

## Action Items

1. `[owner: mobile-dev]` (F-1) Capture and record the AC3 rendered spot-check: one full-screen non-anchor consumer (Dream Jar List — it carries both `CupidAddAction` and `CupidPrimaryButton`) and one modal-sheet consumer (Add Expense Sheet), using the same preview build and `capture-mobile-screen.sh` procedure already recorded in `visual-fidelity-report.md`. Add the captures to this story's `visual-fidelity/` and a short AC3 subsection stating, per capture, whether any overflow, clipping, or layout breakage is present — including whether the 56→60 FAB growth clips the last content row on Dream Jar List the way it does on the anchor. If clipping is found on a non-anchor screen, record it as an M-1-class screen-level finding with its disposition; do not fix it here, since consumer screen files are out of this story's write scope.
2. No other rework is required. AC1, AC2, AC4, and AC5 are met; do not re-capture the Expense History anchor and do not re-render the reused STORY-043 references.

## Traceability

- Requirements: `requirements/requirements.md` AC1-AC5, `## In Scope` items 1-5, `## Business Rules And Guardrails`, `## Open Question Impact`
- Story master: `story_master.md` `## Background` (D-1 corrected scope, D-2 verification, M-1 non-goal), write scope `design_system/adaptive/**`
- UX / Architecture: `SKIPPED:trivial` per `story_master.md` `## Artifacts` — consistent with rule 9 for trivial stories
- Design source: `cupid-app-design-system/project/Cupid Screens.dc.html` lines 881 (`isMD` FAB) and 884 (`isIOS` CTA), read independently; both transcriptions in the evidence are exact
- Implementation: commit `72bf3df`, 4 source/test files
- Evidence: `visual-fidelity/visual-fidelity-report.md` and the 6 PNGs in that directory
- Write-scope discipline: honored. The only non-`design_system/adaptive/**` lib edit is the single `leadingIcon:` argument AC2 explicitly sanctions; no scroll, padding, or behavior change anywhere.

## State Recommendation

- Uncheck `Implementation (Development)` in `story_master.md`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Return to `mobile-dev` with action item 1 only; re-review should be a `completion/resume` pass against F-1, not a fresh full review.
