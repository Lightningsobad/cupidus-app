# Story Requirements: STORY-055 Hardening - Design System FAB/CTA Shape and Sizing Fidelity

## Source Artifacts

- Requirement master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/req_master.md`
- Story master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-055_design_system_fab_cta_hardening/story_master.md`
- Additional input files: `data/retro-audit/rework-backlog.md` `## RWB-20260816-021`; `STORY-043_shared_expenses_design_fidelity_hardening/visual-fidelity/visual-fidelity-report.md` lines 190-230 (source of the corrected D-1/D-2/M-1 detail, already transcribed and independently verified into this story's own `story_master.md` `## Background`); `STORY-043.../visual-fidelity/design-reference-expense-android.png` and `design-reference-expense-ios.png` (reused as-is, no new render).

## Business Summary

- Primary actor: any user viewing a screen that renders the shared `CupidAddAction` (Material FAB) or `CupidPrimaryButton` (full-width CTA) design-system components.
- Problem to solve: two shared, widely-consumed design-system components render with confirmed visual defects against the locked design source — `CupidAddAction`'s Material FAB uses the wrong corner-radius token (renders as a flat pink circle instead of a 20px rounded square) and is also missing its gradient fill, glow, correct size, and glyph size; `CupidPrimaryButton`'s shared height/font-size are slightly off (54 vs 52, 16.5 vs 15.5) and the Expense History screen's iOS "add" CTA is missing its leading `add` glyph.
- Business outcome: both shared components render to the design source's exact visual spec, so every screen consuming them (not just the screen where the gap was first observed) inherits the fix.
- Success signal: a fresh implementation-side capture of the Expense History screen (Material FAB + iOS CTA in one screen, STORY-043's existing anchor) matches STORY-043's existing `design-reference-expense-android.png` / `design-reference-expense-ios.png` pair with no visible FAB-shape or CTA-sizing deviation, and every other real consumer of both widgets still compiles and renders without regression.
- Complexity: trivial
- Why this complexity: single implementation lane (mobile), both fixes are existing-pattern token/value corrections inside two already-shared components (no new widget, no new screen, no new architecture decision — `gradientHot`/`glowShadow` are already-established tokens reused from the sibling widget), and the exact target values are already known from STORY-043's rendered evidence, not something this story needs to design.
- Primary implementation lane: mobile

## Scope Decision

### In Scope

1. **D-1 — `CupidAddAction` (Material FAB) shape and visual-treatment correction.** In `mobile/lib/design_system/adaptive/cupid_add_action.dart`, the Material branch's `FloatingActionButton` must render: a 20px corner-radius rounded square (replacing the current `BorderRadius.circular(platformTokens.radiusButton)`, which resolves to a 999 pill/circle on a square FAB); a `gradientHot` gradient background (replacing the current flat `backgroundColor: colors.colorAccentPink`); a glow shadow using the same token treatment `CupidPrimaryButton` already applies (`colors.glowShadow`) (replacing the current no-shadow render); an explicit 60x60 size (replacing the current unset Material default of 56x56); and a 27px glyph size for the `add` icon (replacing the current default icon size). This is the full, code-and-source-verified D-1 gap — wider than the rework registry's one-line "only the shape is wrong" summary; see `story_master.md` `## Background` for the verification.
2. **D-2 — `CupidPrimaryButton` height/font-size/leading-glyph correction.** In `mobile/lib/design_system/adaptive/cupid_primary_button.dart`: change `_primaryCtaHeight` from `54` to `52`; change the label's `fontSize` from `16.5` to `15.5` (both are shared, non-platform-branched properties, so this applies uniformly to every consumer on both iOS and Material). Additionally, extend the widget with an optional, backward-compatible leading-icon capability (default: no icon, so all other call sites render unchanged), and apply it — with an 8px gap before the label — only at `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart:225-228` (the iOS "add action" CTA, label `ExpenseStrings.addActionLabel`), using `CupidIcons.add`. No other `CupidPrimaryButton` call site gains a leading icon in this story.
3. **No-regression verification across every real consumer of both components**, enumerated by direct source grep (not by re-deriving the rework registry's paraphrase):
   - `CupidAddAction` (3 call sites): `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart`, `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart`, `mobile/lib/features/gallery/presentation/widgets/gallery_empty_view.dart`.
   - `CupidPrimaryButton` (22 call sites): `mobile/lib/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart`, `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`, `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart`, `mobile/lib/features/timeline/presentation/screens/timeline_screen.dart`, `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`, `mobile/lib/features/auth/presentation/screens/register_screen.dart`, `mobile/lib/features/pet/presentation/pet_screen.dart`, `mobile/lib/features/expenses/presentation/widgets/pairing_required_gate.dart`, `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart`, `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart`, `mobile/lib/features/dream_jar/presentation/screens/dream_jar_detail_screen.dart`, `mobile/lib/features/dream_jar/presentation/screens/contribution_history_screen.dart`, `mobile/lib/features/auth/presentation/screens/login_screen.dart`, `mobile/lib/features/auth/presentation/screens/forgot_screen.dart`, `mobile/lib/features/timeline/presentation/widgets/create_memory_sheet.dart`, `mobile/lib/features/pet/presentation/widgets/pet_guard_states.dart`, `mobile/lib/features/pet/presentation/widgets/adopt_sheet.dart`, `mobile/lib/features/love_contracts/presentation/widgets/add_clause_sheet.dart`, `mobile/lib/features/gallery/presentation/widgets/gallery_upload_sheet.dart`, `mobile/lib/features/gallery/presentation/widgets/gallery_locked_view.dart`, `mobile/lib/features/expenses/presentation/widgets/add_expense_sheet.dart`, `mobile/lib/features/dream_jar/presentation/widgets/create_dream_jar_sheet.dart`.
4. **M-1 (FAB overlap) disposition — confirm and document only, no code change.** Re-confirm, on the Expense History screen (Material), whether the last-row clipping behavior STORY-043 captured (`implemented-expense-fab-overlap-emulator-5560.png`) is unchanged after the D-1 fix, and record its disposition (still present, Material-only, root cause is `expense_history_screen.dart`'s scroll-view bottom padding — a screen-level property outside this story's `design_system/adaptive/**` write scope, not a `CupidAddAction` defect). No edit to `expense_history_screen.dart` or any other screen file is in scope for M-1.
5. Produce fresh implementation-side captures of the Expense History screen (Material and iOS) after the D-1/D-2 fixes, paired against STORY-043's existing `design-reference-expense-android.png` / `design-reference-expense-ios.png`, in this story's own `visual-fidelity/` directory, with a `visual-fidelity-report.md` recording the result.

### Out of Scope

- Any design-system component other than `CupidAddAction` and `CupidPrimaryButton`.
- Any screen-level code change (all 25 consumer files above are read/verify-only; none is write scope).
- A code fix for M-1 — confirm/document only, per `## In Scope` item 4.
- Adding a leading icon to any `CupidPrimaryButton` call site other than `expense_history_screen.dart`'s iOS add-action CTA.
- Re-rendering `design-reference-expense-android.png` / `design-reference-expense-ios.png` — both already exist (STORY-043) and are reused as-is.
- Reopening `STORY-028_shared_expenses_design_fidelity` or `STORY-043_shared_expenses_design_fidelity_hardening`'s closed git boundary/branch.
- Any other `RWB-20260816-*` item — each is tracked and worked separately.
- Light theme / `en` locale visual QA (OQ5 — not enabled for users yet).

## System Integration And Discoverability

- UI-facing story: YES.
- Existing user-visible surface, workflow, or state where the actor starts: any existing screen that already renders `CupidAddAction` or `CupidPrimaryButton` (25 real call sites, listed above) — all already reachable through their own existing navigation paths, unchanged by this story.
- Required entry point, navigation item, CTA, or in-flow discovery path: none new; this story changes the visual rendering of existing, already-reachable components only.
- Direct URL only acceptable: NO — not applicable, these are existing reachable surfaces.
- Which screen of the design source this story covers: the Expense History screen's canvas block (already resolved and rendered by STORY-043 as `design-reference-expense-android.png` / `design-reference-expense-ios.png`, Design-Screen: `expense`) is the only screen whose design source has been directly checked against these two components' exact values; this story reuses that existing, already-confirmed pair and does not re-resolve or re-render a new design-source screen id.
- Existing user journey affected: none — visual/styling only, no behavior, navigation, or content change on any consumer screen.
- Out-of-scope integration surfaces: none.

## Business Rules And Guardrails

- Only the two named shared components' visual properties (FAB shape/gradient/glow/size/glyph size; CTA height/font-size; one CTA's leading icon) may change. No consumer screen file may be edited.
- The leading-icon capability added to `CupidPrimaryButton` must be optional and default to no icon, so every existing call site other than `expense_history_screen.dart`'s add-action CTA renders with an unchanged visual structure (only the height/font-size correction applies to them).
- M-1 must not be "fixed" by inference from the D-1 change; its disposition must be re-confirmed by direct observation (a fresh capture at the same scroll extent STORY-043 used) and documented, not assumed.
- Do not modify `STORY-028_shared_expenses_design_fidelity`'s or `STORY-043_shared_expenses_design_fidelity_hardening`'s business logic, and do not reopen their closed git boundaries/branches.

## User Story

As a user viewing any screen in the app that renders the shared add-action FAB or primary CTA button,
I want those shared components to match the locked design system's exact shape, fill, glow, size, and typography,
So that the app's visual polish is consistent everywhere those components appear, not just on the screen where the gap was first observed.

## Edge Cases And Failure Behavior

- Not applicable to the visual corrections themselves — both are static, always-visible styling properties with no new interactive state or failure path.
- The one behavioral edge case is scope discipline: if implementation finds any additional `CupidAddAction` or `CupidPrimaryButton` call site beyond the 25 enumerated here (e.g. added by work landing concurrently with this story), that site must still compile against the widgets' unchanged public constructor signatures — the no-regression AC's intent is signature/behavior stability, not a frozen call-site count.

## Acceptance Criteria

1. **D-1 — `CupidAddAction` Material FAB shape and visual treatment.** Given the Material FAB rendered by `CupidAddAction` (observed on Expense History, Dream Jar List, and Gallery Empty View), when its rendered shape, fill, shadow, size, and glyph are compared against the design source, then it renders: a 20px corner-radius rounded square (not the current pill/circle from `radiusButton`); a `gradientHot` gradient background (not the current flat `colorAccentPink` fill); a glow shadow using the same treatment `CupidPrimaryButton` already applies via `colors.glowShadow` (not the current no-shadow render); a 60x60 size (not the current unset 56x56 Material default); and a 27px `add` glyph (not the current default icon size). This closes the full D-1 gap re-measured by STORY-043's round-2 render (visual-fidelity-report.md lines 194-205), not only the shape sub-defect the rework registry's summary line named.
2. **D-2 — `CupidPrimaryButton` height, font size, and one scoped leading glyph.** Given any `CupidPrimaryButton` instance on either platform, when its rendered height and label size are measured, then the button height is 52 (not the current 54) and the label font size is 15.5 (not the current 16.5). Given specifically the Expense History screen's iOS "add action" CTA (`expense_history_screen.dart:225-228`), when it is rendered, then it additionally shows a leading `add` glyph with an 8px gap before the label. No other `CupidPrimaryButton` call site gains a leading icon.
3. **No regression across every real consumer.** Given the corrected `CupidAddAction` (3 call sites) and `CupidPrimaryButton` (22 call sites) listed in `## In Scope` item 3, when the mobile app is rebuilt, then it compiles with zero analyzer/build errors; every existing call site's constructor invocation (`CupidAddAction(onPressed: ...)`, `CupidPrimaryButton(label: ..., onPressed: ...)`) compiles unchanged (the leading-icon parameter is additive and optional); and a rendered spot-check across at least one full-screen consumer and one modal-sheet consumer other than the Expense History anchor (e.g. Dream Jar List and Add Expense Sheet) shows no overflow, clipping, or layout breakage introduced by the height/font-size change.
4. **M-1 (FAB overlap) is re-confirmed and documented, not fixed.** Given the Material Expense History screen scrolled to the same extent STORY-043 captured in `implemented-expense-fab-overlap-emulator-5560.png`, when a fresh capture is taken after the D-1/D-2 fixes, then this story's evidence records whether the last row's amount is still clipped by the FAB, states that the behavior is Material-only (confirmed by the existing iOS capture showing no clipping), and states explicitly that the root cause (the screen's scroll-view bottom padding) is outside this story's `design_system/adaptive/**` write scope and was not changed. No `expense_history_screen.dart` edit is made or claimed under this AC.
5. **Rendered visual-fidelity evidence.** Given AC1 and AC2 are implemented, when fresh `implemented-expense-<device>-android.png` and `implemented-expense-<device>-ios.png` captures are taken and paired against STORY-043's existing `design-reference-expense-android.png` and `design-reference-expense-ios.png`, then this story's own `visual-fidelity/` directory holds the matched evidence pair plus a `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS` for D-1 and D-2, and includes the AC4 capture and disposition note for M-1.

## Dependencies

- Depends on: NONE — `STORY-043_shared_expenses_design_fidelity_hardening`'s reference images already exist and are DONE/merged; this story only reads them.
- Must not require any future story: confirmed for D-1 and D-2. M-1 is explicitly left open for a future, separate, screen-level item if the team chooses to close it (see `## In Scope` item 4 and `story_master.md` `## Background`) — this story does not claim to resolve M-1.
- Must not reopen `STORY-028_shared_expenses_design_fidelity`'s or `STORY-043_shared_expenses_design_fidelity_hardening`'s closed git boundary/branch.

## Assumptions (only if needed)

- `colors.gradientHot` and `colors.glowShadow` (already used by `CupidPrimaryButton`) are assumed to be the correct source tokens for `CupidAddAction`'s gradient and glow, since the design source specifies the same `--grad-hot` gradient family and a comparable glow treatment, and no new token is introduced elsewhere in this design system for FAB-specific gradient/glow. If implementation finds the FAB's exact glow `rgba` value diverges materially from the existing `glowShadow` token, that is an implementation-phase escalation, not a scope change.

## Open Question Impact

### OQs affecting this story

None — no unresolved open question directly blocks any scope item in this story.

### Scope Items BLOCKED in this story

- None.

### Scope Items NOT BLOCKED in this story

- All acceptance criteria (1-5) are unblocked.

### OQs resolved before this story

| OQ ID | Resolved Date | Resolution | Scope unlocked |
|-------|---------------|------------|----------------|
| OQ5 | 2026-08-12 (REQ-001 STORY-001) | Enable dark theme + `vi` locale only for v1; build token/ARB infrastructure for all 4 combinations but only enable dark + `vi` | Scope B design-fidelity fixes for the enabled dark + `vi` configuration are unblocked, including this story's D-1/D-2 corrections (both measured against the enabled dark + `vi` rendering) |

### OQs not applicable to this story

- R8 (Backend Socket.IO auth gap): not applicable — a backend-only security decision with no overlap with these two shared UI components' visual properties.
