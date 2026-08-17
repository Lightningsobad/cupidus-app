# Story Requirements: STORY-045 Hardening - Pairing Choice Surface/CTA Styling Fidelity

## Source Artifacts

- Requirement master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/req_master.md`
- Story master: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-045_pairing_choice_design_fidelity_hardening/story_master.md`
- Additional input files: STORY-034's `review/review-report.md` finding D1 (source of the four deviations below, already transcribed into this story's own `story_master.md` `## Background`)

## Business Summary

- Primary actor: a user progressing through onboarding who reaches the Pairing Choice screen.
- Problem to solve: the shipped Pairing Choice screen's content and structure already match `cupid-app-design-system`, but its surface and CTA styling does not apply the design system's tokens — a pre-existing gap in `STORY-002_onboarding_pairing_navigation` (DONE/merged) that only became visible once STORY-034 produced the first `pairing_choice` design-reference render.
- Business outcome: the Pairing Choice screen's visual styling matches the locked design reference exactly, closing retro-audit finding D1 (RWB-20260816-012).
- Success signal: a fresh implementation capture of the Pairing Choice screen matches the existing `design-reference-pairingchoice-android.png` with no visible deviation in background, CTA styling, type scale, or title position.
- Complexity: trivial
- Why this complexity: single existing screen, four token-level style deltas, no new screen/flow/persistence/integration surface. All four deviations reuse design-system primitives already established and already used elsewhere in the codebase (a shared gradient+glow primary-button treatment and a shared particle-field background decoration already exist and are already used on at least one other onboarding screen) — no new shared token or architecture decision is required, matching the trivial bar of "existing patterns, no new architecture decisions."
- Primary implementation lane: mobile

## Scope Decision

### In Scope

1. Background: replace the flat dark navy background with the design's purple→magenta gradient surface plus its particle accents.
2. Primary pill CTA: replace the current flat solid pink fill (no gradient, no glow) with the design's pink→purple gradient fill and glow treatment.
3. Type scale: bring the title and pill label down to the design's type scale so the pill label renders on one line (not two) and the title wraps at the same word as the reference.
4. Title vertical offset: reposition the title to the design's ~23%-down vertical offset (currently ~32% down).
5. Produce a fresh `implemented-pairingchoice-<device>.png` capture after the fix and pair it against the existing `design-reference-pairingchoice-android.png` in this story's own `visual-fidelity/` directory, with a `visual-fidelity-report.md` recording the result.

### Out of Scope

- Any screen other than Pairing Choice.
- Re-rendering `design-reference-pairingchoice-android.png` — it already exists (rendered by STORY-034) and is reusable as-is, unless the post-fix implementation capture needs a fresh pairing image to pair cleanly (same state/device/theme/locale).
- Content, copy, layout structure, or navigation/routing behavior on this screen — STORY-034's reviewer already confirmed content and structure MATCH the design; this story is a styling-only fix.
- `STORY-002_onboarding_pairing_navigation`'s business/navigation logic — untouched, and its closed git boundary/branch must not be reopened.
- Light theme / `en` locale visual QA (OQ5 — not enabled for users yet; see `## Open Question Impact`).
- Any other `RWB-20260816-*` item — each is tracked and worked separately.

## System Integration And Discoverability

- UI-facing story: YES.
- Existing user-visible surface, workflow, or state where the actor starts: the Pairing Choice screen, already reachable via the existing onboarding/pairing navigation flow (`STORY-002`, DONE/merged) — unchanged by this story.
- Required entry point, navigation item, CTA, or in-flow discovery path: existing onboarding/pairing navigation path only; no new entry point.
- Direct URL only acceptable: NO — not applicable, this is an existing reachable screen.
- Which screen of the design source this story covers: the same screen already resolved and rendered by STORY-034 as `design-reference-pairingchoice-android.png` — this story reuses that existing, already-confirmed reference image and does not re-resolve or re-render a new design-source screen id.
- Existing user journey affected: onboarding/pairing navigation flow — visual styling only, no behavior change.
- Out-of-scope integration surfaces: none.

## Business Rules And Guardrails

- Only surface/CTA styling changes (background, CTA fill, type scale, title position) are in scope; content, copy, layout structure, and navigation/routing logic must remain exactly as STORY-034's reviewer already confirmed (MATCH).
- Reuse the existing `design-reference-pairingchoice-android.png` design reference as-is; only produce a new implementation-side capture, not a new reference render, unless the post-fix implementation capture cannot pair cleanly with the existing reference (same state/device/theme/locale).
- Do not modify `STORY-002_onboarding_pairing_navigation`'s business or navigation logic, and do not reopen its closed git boundary/branch.

## User Story

As a user progressing through onboarding,
I want the Pairing Choice screen's background, CTA, and typography to match the locked design system exactly,
So that the screen's visual polish is consistent with the rest of the design-fidelity-audited app.

## Edge Cases And Failure Behavior

- Not applicable — this is a static, always-visible screen; the fix is styling-only and introduces no new interactive state, error path, or failure behavior.

## Acceptance Criteria

1. Given the Pairing Choice screen rendered in the enabled dark theme + `vi` locale, when its background is compared against `design-reference-pairingchoice-android.png`, then it renders the design's purple→magenta gradient surface with the design's particle accents, replacing the current flat dark navy background that has no gradient and no particles.
2. Given the primary pill CTA on the Pairing Choice screen, when its rendered styling is compared against the design reference, then it renders the design's pink→purple gradient fill with glow (the same gradient+glow treatment the design system already specifies via its hot-gradient and glow tokens), replacing the current flat solid pink fill that has no gradient and no glow.
3. Given the screen's title and primary pill CTA label, when their rendered size is compared against the design reference, then both render at the design's type scale — the pill label fits on one line instead of wrapping to two, and the title wraps at the same word as the design reference.
4. Given the screen's title, when its rendered vertical position is compared against the design reference, then it sits at the design's vertical offset (~23% down), not the implementation's current ~32% down.
5. Given Acceptance Criteria 1-4 are satisfied, when a fresh `implemented-pairingchoice-<device>.png` is captured from the running app and compared against the existing `design-reference-pairingchoice-android.png`, then this story's own `visual-fidelity/` directory holds the matched, same-state evidence pair plus a `visual-fidelity-report.md` recording `VISUAL_FIDELITY: PASS`.
6. Given STORY-034's reviewer already confirmed the screen's content and structure MATCH the design, when this story's styling fixes are delivered, then content, structure, and the existing onboarding/pairing navigation behavior remain unchanged — no content, layout-structure, or navigation change is introduced.

## Dependencies

- Depends on: NONE.
- Must not require any future story: confirmed — all four deviations are fixable within this story's own mobile lane.
- Must not reopen `STORY-002_onboarding_pairing_navigation`'s or `STORY-034_pairing_choice_canvas_addition`'s closed git boundary/branch.

## Assumptions (only if needed)

- The design system's existing gradient+glow primary-CTA treatment and existing particle-field background decoration (already used elsewhere in the app) are assumed to be the correct source primitives to apply here, since both already exist in the codebase and this story introduces no new shared component. Confirming the precise cause of why the Pairing Choice screen does not currently pick them up is implementation-phase work, not a scope decision.

## Open Question Impact

### OQs affecting this story

None — no unresolved open question directly blocks any scope item in this story.

### Scope Items BLOCKED in this story

- None.

### Scope Items NOT BLOCKED in this story

- All acceptance criteria (1-6) are unblocked.

### OQs resolved before this story

| OQ ID | Resolved Date | Resolution | Scope unlocked |
|-------|---------------|------------|----------------|
| OQ5 | 2026-08-12 (REQ-001 STORY-001) | Enable dark theme + `vi` locale only for v1; build token/ARB infrastructure for all 4 combinations but only enable dark + `vi` | Scope B design-fidelity fixes for the enabled dark + `vi` configuration are unblocked, including this story's four deviations (all measured against the enabled dark + `vi` rendering) |

### OQs not applicable to this story

- R8 (Backend Socket.IO auth gap): not applicable — a backend-only security decision with no overlap with this screen's surface/CTA styling scope.
