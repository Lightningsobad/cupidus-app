# Phase P1 – `galleryOpen` Rendered Evidence Pair And Re-Verification

## 1. Objective

Use P0's `--click` flag to render the `galleryOpen` design reference STORY-026
could not produce, pair it with a matched implemented capture, re-verify
STORY-026's value-by-value findings against the real pair, fix in app code any
in-scope deviation the rendered comparison newly surfaces, and record the
outcome in this story's own `visual-fidelity/visual-fidelity-report.md`.

Satisfies AC4, AC5, AC6, AC7.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-gallery-rendered-fidelity-evidence.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: NO
- Write Scope:
  - `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-044_private_gallery_design_fidelity_hardening/visual-fidelity/`
  - `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-044_private_gallery_design_fidelity_hardening/coding-plan/test-results.md`
  - `mobile/lib/features/gallery/presentation/widgets/gallery_grid_view.dart` —
    **only if** the rendered pair surfaces an in-scope deviation
  - `mobile/lib/features/gallery/presentation/widgets/gallery_tile.dart` —
    same condition
  - `mobile/test/features/gallery/gallery_capture_entry.dart` — **only if** AC5
    requires a re-capture
  - `mobile/test/features/gallery/gallery_design_fidelity_test.dart` — **only
    if** an in-scope fix lands and needs a guarding test
- Prohibited paths: `.ai-team-bundle/**` (P0 owns the tool; do not amend it);
  the whole `cupid-app-design-system/**` locked design bundle;
  `data/devops/system/design-fidelity-config.json`;
  `mobile/lib/design_system/**`; `mobile/lib/features/gallery/presentation/screens/**`;
  every other `mobile/lib/features/**` directory; all STORY-026 and
  STORY-035..043 artifacts.
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: flutter-app
  - Startup Smoke: NOT_APPLICABLE — the app launch happens inside the mobile
    visual audit, not as a separate readiness gate
  - Build Command Source: runtime registry `buildCommand`
    (`flutter build apk --debug`) — required **only if** Dart source changes
  - Readiness Check: N/A
  - Port Contract: N/A
- Risk Surfaces:
  - Stale line citations, +8 offset (KD1)
  - Wrong-frame capture under `--platform=all` (KD3)
  - Hiding out-of-scope design content from the reference (R2)
  - AC7 escalating into unimplemented feature work (R3)
  - A stale PNG read as fresh output (R4)
- Source Of Truth:
  - corrected line numbers: `../architecture/solution.md` section 1, KD1 table
  - already-adjudicated differences: `../architecture/solution.md` section 2
    (`Already-adjudicated differences`)
  - AC7 boundary: `../architecture/solution.md` section 4, R3
  - verified click selector: `tool-contract-click-flag.md` (P0 output)
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` sections 1, 2, 4
  - acceptance criteria: `../requirements/requirements.md` AC4-AC7
  - upstream phase outputs: P0's `tool-contract-click-flag.md` verified selector
    and `--click` signature
  - prior findings to re-verify: STORY-026's
    `visual-fidelity/visual-fidelity-report.md` sections 2 and 3
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one screen state, one rendered pair, one report, plus a
    conditional in-scope fix confined to the grid and tile widgets.
  - Source/Test File Count: up to 6 (2 evidence PNGs + report, 1 test-results,
    and at most 2 Dart files if a fix is needed)
  - Split Required: NO
  - Split Rationale: the compare → fix → re-render → re-compare loop is
    inherently iterative against the same capture harness and the same two
    widgets; splitting it would cost a second emulator build/install/screencap
    cycle for no isolation benefit.

## 2. Required Reads

- `../architecture/solution.md` sections 1, 2, 4 — **before any comparison**
- `../requirements/requirements.md` AC4-AC7
- `tool-contract-click-flag.md` (P0's verified selector and flag signature)
- STORY-026's `visual-fidelity/visual-fidelity-report.md` sections 2 and 3 only
  (the findings table you are re-verifying). Its sections 1 and 3A are already
  summarized in solution.md section 2 — do not re-read them.

Do not read `data/retro-audit/rework-backlog.md` or any STORY-035..043 artifact.

## 3. Tasks

1. **Read solution.md section 1 KD1 first.** Every line number in
   `story_master.md`, `requirements/requirements.md`, and STORY-026's report is
   8 lines stale. The `galleryOpen` block is
   `cupid-app-design-system/project/Cupid Screens.dc.html:744-759`, not
   L736-751. Cite current line numbers in your report, not the stale ones.
2. **Read solution.md section 2's adjudication table before comparing anything.**
   Five differences are already ruled on and are not findings: the auto-lock
   banner (L746-750), the screenshot notice (L757), and app extensions E1
   (column count), E2 (caption format), E3 (uploader badge). Re-raising any of
   them as a deviation is the specific failure this plan exists to prevent.
3. **Render the design reference** using P0's verified selector from
   `tool-contract-click-flag.md`, into this story's `visual-fidelity/`:
   `--screen=gallery --platform=android --theme=dark --lang=vi` plus the
   `--click` argument. Use `--platform=android`, never `all` — each device frame
   holds independent unlock state, so an md-scoped click leaves the iOS frame in
   `galleryLocked` and `all` would write a wrong-state iOS PNG with no error
   (solution.md KD3).
4. **Confirm the output is genuinely new** (R4). A failed render writes nothing
   but deletes nothing, so a leftover PNG from an earlier attempt can read as
   success. Render into a clean directory or check mtime.
5. **Verify the reference shows the right state**: the mint `lock_open` banner
   with the `00:58` mono countdown, the 2-column photo grid with three tiles,
   and the dashed add tile — i.e. L744-759, not the lock/fingerprint screen at
   L733-743. Confirm the prototype screen-index FAB is absent.
6. **Do not `--hide` the banner or the screenshot notice** (R2). They are out of
   scope but they are real design content; `hide_selectors` exists for prototype
   affordances only, and suppressing design content would make the locked
   reference misrepresent the design. Capture the full frame and annotate the
   two regions in the report instead.
7. **Settle AC5's pairing question.** The existing
   `implemented-gallery-emulator-5560.png` came from
   `mobile/test/features/gallery/gallery_capture_entry.dart`, which renders
   `GalleryGridView` under a `CupidHeader`, dark theme, `vi` locale, Material
   platform — the same state/theme/locale as the new reference. Check that it is
   also dimensionally comparable against the new reference's `--max-edge`-bounded
   size. If it pairs, copy it into this story's `visual-fidelity/` and say so; if
   it does not, re-capture and say why.
8. **Re-verify STORY-026's sections 2-3 findings** one by one against the
   rendered pair, over the in-scope comparison surface only: grid container
   padding (L745), grid definition (L751), photo tiles (L752-754), dashed add
   tile (L755). Mark each finding confirmed or corrected. STORY-026's own report
   flags the caption pill's rendered width (E2 commentary) as the one composite
   property the value-by-value method could not settle — the rendered pair is
   exactly what settles it, so give it explicit attention.
9. **Fix in app code, not in prose** (AC7), any deviation the rendered
   comparison newly surfaces inside the section 2 comparison surface. Then
   re-render and re-compare to prove the fix. Keep the diff inside
   `gallery_grid_view.dart` / `gallery_tile.dart`.
10. **Stop and escalate rather than implement** if a deviation's fix would
    require new behavior — a 60s auto-lock timer, screenshot detection, or a
    biometric unlock gate (R3). The app's `GalleryLocked` is a *pairing* gate
    (`mobile/lib/features/gallery/presentation/screens/gallery_screen.dart:116`),
    semantically different from the design's biometric lock, and closing that
    gap is new functional scope, not hardening. Report it to Scrum Master.
11. **Write `visual-fidelity/visual-fidelity-report.md`** with a header
    recording `VISUAL_FIDELITY: PASS` or the corrected result, and a
    `Design-Reference-Render:` line that replaces STORY-026's
    `BLOCKED (DESIGN_CANVAS_STATE_FORCE_UNSUPPORTED)` with the render command
    actually used. Record the exact command, the selector, and both PNG paths so
    the render is reproducible.
12. **Run the gates only if Dart source changed**: targeted gallery tests,
    `flutter analyze`, and `flutter build apk --debug`. If the phase is
    evidence-only, say so explicitly in `test-results.md` rather than reporting
    gates that did not need to run.

## 4. Acceptance Criteria

- AC4: a real `design-reference-gallery-android.png` exists in this story's
  `visual-fidelity/`, showing `Cupid Screens.dc.html:744-759`, produced by the
  recorded `--screen=gallery --click=...` command.
- AC5: this story's `visual-fidelity/` holds a matched, same-state,
  same-device/theme/locale pair — either the reused STORY-026 capture with the
  pairing justified, or a fresh one with the reason recorded.
- AC6: every STORY-026 section 2-3 finding is marked confirmed or corrected
  against the rendered reference, and this story's report records the
  re-verified outcome.
- AC7: any newly surfaced in-scope deviation is fixed in app code and proven by
  a re-render, or the phase records that the comparison surfaced none.
- No item from solution.md section 2's adjudication table appears as a finding.

## 5. Planned Outputs

- `visual-fidelity/design-reference-gallery-android.png`
- `visual-fidelity/implemented-gallery-emulator-5560.png` (reused or refreshed)
- `visual-fidelity/visual-fidelity-report.md`
- `coding-plan/test-results.md`
- Conditional: `mobile/lib/features/gallery/presentation/widgets/gallery_grid_view.dart`,
  `gallery_tile.dart`, and a guarding test

## 6. Test Scope

- Targeted gallery widget tests and `gallery_design_fidelity_test.dart`, run
  only if Dart source changed.
- `flutter analyze` and `flutter build apk --debug`, same condition.
- Excluded: backend e2e/test_e2e, Playwright/browser e2e suites, traces,
  scenario reruns, repository-root local script gates, and any test outside
  `mobile/test/features/gallery/`.

## 7. Status

PENDING — blocked on P0.

## 8. Stop Rule

Stop and report to Scrum Master without proceeding if:

- P0's `--click` flag is not present or its contract note records no verified
  selector. This phase cannot produce its primary artifact without it.
- The rendered reference shows `galleryLocked` rather than `galleryOpen` and no
  selector adjustment fixes it — that is a P0 defect, not a P1 workaround.
- A deviation's fix would require new behavior (task 10, R3).
