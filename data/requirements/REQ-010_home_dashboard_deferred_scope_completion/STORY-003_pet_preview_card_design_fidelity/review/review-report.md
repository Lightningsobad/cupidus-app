# Review Report — STORY-003 Pet Preview Card Design Fidelity

Outcome: DEFERRED_ONLY

- Review type: `compact-story-review`
- Requirement: REQ-010_home_dashboard_deferred_scope_completion
- Story: STORY-003_pet_preview_card_design_fidelity (Complexity `standard`, Lane `mobile`)
- Worktree: `.ai-team-worktrees/cupid-apps/story-REQ-010_home_dashboard_deferred_scope_completion-STORY-003`
- Diff baseline: `52bf752cf46ba18f1e47f3185522e9b16a77b8dc` → HEAD `11190e80c99498166cc4ee2124a08b87afffe65a`
- Reviewer: Iris-QC, 2026-08-25
- Blocking findings: 0 · Deferred findings: 2

## Scope Gate

Phase: SCOPE_GATE — SCOPE_GATE_COMPLETE: YES

- Source/test files in scope (6, within the compact budget of 8):
  - `mobile/lib/features/pet/presentation/widgets/pet_preview_card.dart`
  - `mobile/lib/features/home/presentation/home_screen.dart`
  - `mobile/lib/main_preview.dart`
  - `mobile/test/features/pet/presentation/widgets/pet_preview_card_design_fidelity_test.dart`
  - `mobile/test/features/home/home_screen_test.dart`
  - `mobile/test/features/pet/presentation/pet_entry_point_test.dart`
- Evidence files in scope: `story_master.md`, `coding-plan/test-results.md`,
  `coding-plan/phase-P1-...md`, `visual-fidelity/visual-fidelity-report.md` and both
  capture PNGs, `data/runtime/parallel-runs/...-STORY-003-mobile-dev.json`,
  `data/devops/system/design-fidelity-config.json`,
  `cupid-app-design-system/Cupid Screens.dc.html` lines 288-305.
- Query keys: AC1-AC4, `_PreviewReadyShell`, `_PreviewReady`, `_PreviewTapTarget`,
  `_PreviewPetRepository`, `PREVIEW_PET_FIXTURE`, `isHome`, `Design-Screen: home`.
- Retro gate: `data/retro-audit/rework-backlog.md` holds no `PENDING`/`IN_PROGRESS`
  item — ordinary story review permitted.
- Not read (deliberately): STORY-004/005 changes absent from this worktree, per the
  handoff's explicit instruction; the broader requirement backlog.

## Acceptance Criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC1 — card matches the design source (dark + `vi`, fixture active) | PASS | 17-row per-property table re-verified by me against `Cupid Screens.dc.html:291-303`; rendered capture compared against the design reference |
| AC2 — deviations corrected in the app, not merely documented | PASS | `pet_preview_card.dart` rewritten (gradient wash, border, clip, glow, baseline row, chip, caption, XP bar); the XP-bar placement regression was caught by the render and fixed in both widget and assertion |
| AC3 — capture shows the real fixture-backed state, not the auth failure | PASS | `_PreviewPetRepository` behind `--dart-define=PREVIEW_PET_FIXTURE`; capture shows a populated `PetReady` card, not "Không thể tải Bún" |
| AC4 — tap still reaches the pet feature, no new entry point | PASS | `_PreviewTapTarget` wraps both chrome variants with one `Semantics(button: true)` + `PetRoute.push`; asserted by 3 tests; no route/nav registration added |

## Risk surfaces and critical gates

| Surface | Gate | Result |
|---|---|---|
| Mobile interaction / widget layout | `flutter test test/features/pet/ test/features/home/` | PASS — re-run by me: `+142: All tests passed!` |
| Mobile static analysis | `flutter analyze` on the 3 changed lib files | PASS — re-run by me: `No issues found! (ran in 2.1s)` |
| Mobile build | registry `buildCommand` `flutter build apk --debug` | PASS — re-run by me: `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` |
| Mobile navigation / discoverability (12e1) | Entry point verified in code | PASS — `home_screen.dart` mounts `PetPreviewCard(repository: _petRepository)` in the Home card column; `_PreviewTapTarget` → `PetRoute.push(context)`. Discoverable surface, not URL-only |
| App lifecycle / runtime startup (12g) | `## Story Runtime Startup Smoke` | PASS — recorded launch on `emulator-5554`, no crash/red screen, corroborated by the capture. Device lifecycle deliberately not re-run (12e3) |
| Design fidelity (12e2 / 12e3, mobile lane) | Implementer capture + compare, reviewer verifies | PASS — see below |
| Setup/configuration (12a) | Configuration guide | NOT REQUIRED — the only new flag is the capture-harness-only `PREVIEW_PET_FIXTURE` dart-define; no production runtime, env, or deployment surface changed |

## Design fidelity verification (12e3)

I opened both images rather than counting files.

- `implemented-home-android-emulator-5554.png` (405x900) shows this story's screen in
  the built app: a populated Bún card with the `Lv.3` chip, the status caption, the
  gradient XP bar at ~62%, the 74px sprite and the top-right glow. Not a placeholder,
  not an error frame, not a spinner, not another screen.
- `design-reference-home-android.png` (406x900) depicts the same Home screen of the
  design canvas, with the same pet card. `Design-Screen: home` is recorded and the
  reference I looked at is that screen.
- Design surface is unambiguous: `Implementation Lane: mobile` selects the
  `surface: mobile` source (`id: cupid-app`) out of the two configured canvases, so
  the web canvas cannot have been used by accident.
- The two images do not contradict `VISUAL_FIDELITY: PASS` for the compared
  component; I found no visible deviation in the pet-card region at capture scale.
  Differences outside the card are other stories' scope and are correctly excluded by
  the report.
- I independently re-read the design source itself (`Cupid Screens.dc.html:291-303`)
  and confirmed every row of the per-property table against the real CSS —
  the 130deg wash alphas (.2→51, .16→41), `1px solid var(--line)`, the
  `top:-14px right:12% 74x74` glow at `rgba(255,255,255,.26)`/`transparent 70%`,
  Nunito 17/900, the bare `Lv.3` chip at `rgba(255,127,182,.22)`/radius 6/10px
  Roboto Mono, the 12px `var(--tx2)` caption, and the 8px `var(--surf)` track with a
  `var(--grad)` fill nested in the `flex:1;min-width:0` column. The table is accurate.

## Traceability

- Scope change: the one-line edit to `pet_entry_point_test.dart` (outside the original
  write scope) is covered by a real `scrum_master_note` in the mobile-dev run file,
  and the applied diff matches the approved one-line fix exactly. Mood coverage was
  not lost — it moved to the caption assertion in the new fidelity suite.
- `phase-P1-...md` and `story_master.md` edits only append status and evidence; no
  acceptance criterion or plan task was rewritten to match the implementation.
- All 12 changed files fall inside the mobile-dev run's declared write scope.
- No `Open Question Impact` for this story; none over- or under-applied.

## Deferred findings

- **D1 — three token-rounding deltas are absent from the per-property table.** The
  design node uses `padding:17px` on the card, and `padding:2px 7px` on the level
  chip; the implementation uses `CupidSpacing.md` (16) and `CupidSpacing.xs`/`sm`
  (4/8). The table documents the analogous 15→16, 3→4 and 10→8 roundings but omits
  these three. They are ≤2px, on the same documented token scale, and not visible in
  the captures I compared, so they do not change the `PASS`. Worth recording so a
  future higher-DPI or pixel-diff audit knows they are intentional rather than drift.
  Owner: mobile-dev (evidence completeness only, no code change implied).
- **D2 — the configured mobile `design_source.entry` is not the canvas holding this
  screen.** `data/devops/system/design-fidelity-config.json` sets
  `entry: "Cupid App.dc.html"` for the `cupid-app` mobile source, but that file
  contains no `isHome`, `petLv`, `petXp` or `Bún` node; the Home screen this story was
  compared against lives in `Cupid Screens.dc.html`. The render nonetheless produced
  the correct screen, and I verified the correct node by hand, so this story's
  comparison is sound. I could not determine within the compact budget whether
  `render-design-canvas.js` resolves `--screen` across the whole bundle by design (in
  which case `entry` is only a default and nothing is wrong) or whether the `entry`
  field is stale. Flagging it because every mobile story in this requirement renders
  through the same config. Owner: ui-ux-designer / devops, requirement-level.

## State recommendation

- Keep `Implementation (Development)` checked.
- Check `Review (Reviewer)`.
- Story status: `DONE` — merge-eligible into
  `codex/REQ-010_home_dashboard_deferred_scope_completion-integration`.
- D1 and D2 carry forward as non-blocking notes; D2 belongs to the requirement
  integration review rather than to this story.
