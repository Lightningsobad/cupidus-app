# Story Requirements: STORY-043 Hardening - Shared Expenses Visual Fidelity Evidence

## Source Artifacts

- Requirement master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/req_master.md`
- Story master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-043_shared_expenses_design_fidelity_hardening/story_master.md`
- Additional input files: `data/retro-audit/rework-backlog.md` (RWB-20260816-011); STORY-028's own `review/review-report.md` and `visual-fidelity/visual-fidelity-report.md`, as summarized in `story_master.md`'s `## Background` section (not re-derived here)

## Business Summary

- Primary actor: Product/QA stakeholder relying on REQ-002's design-fidelity audit
- Problem to solve: STORY-028's Shared Expenses design fidelity review closed `DEFERRED_ONLY` with zero rendered evidence either side — its 25 fixed deviations are source-to-source verified only, never confirmed against an actual on-device/emulator render (RWB-20260816-011).
- Business outcome: The Shared Expenses screen's design-fidelity claim is backed by real rendered evidence, closing the requirement's last open IF-7-class evidence gap for this screen (same class already remediated for `welcome`, `register`, `invite`, `paired`, `contract`, `chat`, `antighost`, `timeline`).
- Success signal: `implemented-expense-<device>.png` and `design-reference-expense-<platform>.png` exist and confirm all 25 previously source-verified deviations still match under an actual render; D-1/D-2/M-1..M-4 dispositions are explicitly re-confirmed against that evidence.
- Complexity: trivial
- Why this complexity: Single existing screen, no new business logic or navigation — capturing and comparing render evidence for already-landed code fixes, same pattern as STORY-035 through STORY-042's identical hardening precedent.
- Primary implementation lane: mobile

## Scope Decision

### In Scope

- Capture `implemented-expense-<device>.png` from the running `expense_history_screen.dart` in the enabled dark theme + `vi` locale configuration.
- Render `design-reference-expense-<platform>.png` via `render-design-canvas.js --screen=expense` for both Android and iOS variants (confirm the exact screen id via `--list-screens` if `expense` does not resolve; do not guess).
- Re-verify all 25 deviations STORY-028 already fixed and source-verified (padding, summary card, total typography, delta, chart bars, weekday labels, chips, list card, row, icon tile, row text, amount) against the actual captured render, not just against source.
- Re-confirm the AC3 platform split (FAB on Android vs. full-width CTA on iOS) against a real dual-platform render.
- Re-confirm M-2 (empty filtered result cosmetic) and M-4 (1px gap) against the actual render, with an explicit disposition for each.
- Re-confirm M-3 (docs-only inaccurate justification) needs no code change.
- Re-confirm D-1/D-2 stay out of scope (shared-component exclusion), and that M-1 travels with D-1's disposition.

### Out of Scope

- D-1: `CupidAddAction` FAB shared-component visual detail (`60x60`, `border-radius:20px`, `grad-hot`, glow, `27px` glyph) — shared with Dream Jar, Gallery, and Home; stays deferred to a design-system-scoped story, same exclusion class as RWB-012/RWB-018. If still open, it should route to its own split-out rework item rather than being pulled into this screen-scoped story.
- D-2: `CupidPrimaryButton` iOS full-width CTA shared-component visual detail (`height:52px`, `grad-hot`, glow, `15.5px w800` label, leading `add` glyph) — same shared-component deferral as D-1.
- M-1: FAB overlap risk — not independently fixable without D-1; travels with D-1's disposition and does not get its own remediation in this story.
- Any new business logic, data model change, or non-visual behavior change to Shared Expenses.
- Any screen other than Shared Expenses (`expense_history_screen.dart` / `expense_list_item.dart`).

## System Integration And Discoverability

- UI-facing story: YES
- Existing user-visible surface, workflow, or state where the actor starts: Shared Expenses screen, Epic 5 (Shared money goals) — already shipped and reachable through existing in-app navigation.
- Required entry point, navigation item, CTA, or in-flow discovery path: unchanged existing navigation into Shared Expenses; this story adds no new entry point.
- Direct URL only acceptable: NO
- If direct URL only is acceptable, business reason: n/a
- Which screen of the design source this story covers: The Shared Expenses / expense history screen implemented by `expense_history_screen.dart` and `expense_list_item.dart` (Epic 5, "Shared money goals"), matched against `cupid-app-design-system` (`Cupid Screens.dc.html` lines 835-879). Exactly one screen; no other screen in this requirement corresponds to this scope.
- Existing user journey affected: None — this story captures verification evidence only, it does not change the journey.
- Out-of-scope integration surfaces: None.

## Business Rules And Guardrails

- No source code behavior change is implied by this story unless the actual render surfaces a genuine new visible deviation not among the 25 already-fixed items — if that happens, log it as a newly discovered finding rather than silently folding it into this trivial story's scope.
- Verification must target the enabled dark theme + `vi` locale configuration (per REQ-002's resolved OQ5), not light theme / `en` locale.
- D-1, D-2, and M-1 stay deferred; the shared components under `mobile/lib/design_system/adaptive/**` must not be forked into local copies to satisfy this story.

## User Story

As a product/QA stakeholder relying on REQ-002's design-fidelity audit,
I want the Shared Expenses screen's already-landed fidelity fixes re-verified against an actual rendered capture (implemented + design-reference) instead of source-to-source comparison alone,
So that STORY-028's `DEFERRED_ONLY` evidence gap (RWB-20260816-011) is closed with real evidence and the requirement's fidelity claim for this screen is trustworthy.

## Edge Cases And Failure Behavior

- If `render-design-canvas.js --screen=expense` does not resolve, the implementer must run `--list-screens`, resolve the correct id, and record it as `Design-Screen: <id>` — an unconfirmed guess is not acceptable and is treated as settled downstream.
- If the actual render surfaces a new visible deviation not among the 25 already-fixed items, it must be logged as a new finding with its own disposition, not silently absorbed into this story's acceptance criteria.
- If M-2's empty-filtered-result cosmetic issue is visible in the actual render, the default disposition is: log it and do not block story completion on it unless it is a material, visible deviation from the design source.

## Acceptance Criteria

1. Given the running `expense_history_screen.dart` in the enabled dark theme + `vi` locale configuration, when a real device/emulator capture is taken, then `implemented-expense-<device>.png` exists showing the actual rendered Shared Expenses screen.
2. Given the locked `cupid-app-design-system` design source, when `render-design-canvas.js` is run against the resolved Shared Expenses screen id (confirmed via `--list-screens` if `expense` does not resolve), then `design-reference-expense-<platform>.png` exists for both the Android and iOS platform variants (AC3 platform split).
3. Given the 25 deviations STORY-028 already fixed and source-verified (padding, summary card, total typography, delta, chart bars, weekday labels, chips, list card, row, icon tile, row text, amount), when the actual implemented and design-reference renders are compared side by side, then every one of the 25 items is confirmed MATCH against the real render, not merely against source.
4. Given D-1 (FAB shared-component detail) and D-2 (iOS full-width CTA shared-component detail), when this story's evidence is reviewed, then both remain explicitly out of scope with their shared-component-exclusion disposition re-confirmed (same class as RWB-012/RWB-018), and M-1 (FAB overlap, tied to D-1) is recorded as traveling with D-1's disposition rather than independently resolved.
5. Given M-2 (empty filtered result, cosmetic) and M-4 (1px gap) checked against the actual render, when the evidence is captured, then each is explicitly re-confirmed as either non-blocking/deferred or logged as an observable deviation with a stated disposition — neither is left unaddressed.
6. Given M-3 (docs-only inaccurate justification in the visual-fidelity report), when this story closes, then it is re-confirmed as requiring no code change, only a documentation correction if the inaccuracy still exists.
7. Given a user already on the existing Shared Expenses screen (no new navigation added by this story), the actor can reach the verified screen through the existing unchanged in-app entry point.

## Dependencies

- Depends on: STORY-028_shared_expenses_design_fidelity (its code fixes are the subject of this story's re-verification; this story does not modify fixes outside STORY-028's scope)
- Must not require any future story: Correct — no downstream story is required for this story to be verifiable and complete.

## Assumptions (only if needed)

- None beyond the facts already established in `story_master.md`'s `## Background` section.

## Open Question Impact

### OQs affecting this story

| OQ ID | Status | Scope Items BLOCKED | Scope Items NOT BLOCKED | Decision |
|-------|--------|---------------------|------------------------|----------|
| OQ5 | RESOLVED (REQ-001 STORY-001, 2026-08-12) | None | All of this story's evidence capture and re-verification, which targets the enabled dark theme + `vi` locale configuration | Deliver — this story's scope is already the resolved, enabled configuration; no light/`en`-only work is added |

### Scope Items BLOCKED in this story

- None.

### Scope Items NOT BLOCKED in this story

- All acceptance criteria (AC1-AC7): none are blocked by any unresolved open question.

### Scope decisions driven by OQs

- OQ5 RESOLVED → this story's render capture and comparison target the enabled dark + `vi` configuration only, consistent with the requirement-wide resolution; no separate light/`en` evidence is required.

### OQs resolved before this story

| OQ ID | Resolved Date | Resolution | Scope unlocked |
|-------|---------------|------------|----------------|
| OQ5 | 2026-08-12 | Light theme / `en` locale are not enabled for end users | Confirms this story's dark + `vi` render scope is the correct and complete target |

### OQs not applicable to this story

- None found beyond OQ5 above.
