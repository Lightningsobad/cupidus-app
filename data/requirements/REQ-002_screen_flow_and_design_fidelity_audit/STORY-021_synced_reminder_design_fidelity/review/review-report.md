# Review Report: STORY-021 Design Fidelity — Synced Reminder

Outcome: PATCH_REQUIRED

- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Story: STORY-021 (`Complexity: trivial`, `Implementation Lane: mobile`)
- Review type: `compact-story-review`
- Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-STORY-021`
- BaseHead: `bf808483223580df81b1fb951b141a6597cb82dd` → worktree HEAD `d297cdfb`
- Blocking findings: 1 · Deferred findings: 3

## Scope Gate

- Review type: compact-story-review (budget: 8 touched files, 1 large artifact).
  7 source/test files touched — within budget.
- Source/test files in scope (`git diff --name-only bf80848`):
  `mobile/lib/features/reminders/presentation/reminder_strings.dart`,
  `.../screens/reminder_schedule_screen.dart`,
  `.../widgets/reminder_firing_overlay.dart`,
  `.../widgets/reminder_time_stepper.dart`,
  `.../widgets/reminder_weekday_chips.dart`,
  `mobile/test/features/reminders/reminder_firing_overlay_test.dart`,
  `mobile/test/features/reminders/reminder_schedule_screen_test.dart`
- Evidence files in scope: `story_master.md`,
  `visual-fidelity/visual-fidelity-report.md`,
  `data/devops/system/design-fidelity-config.json`
- Query keys: AC1-AC5, `VISUAL_FIDELITY`, `Design-Screen`, `design_source`,
  `ReminderScheduleScreen` entry point, `báo thức`/`Synced Alarm` copy guard.
- Touched risk surfaces: mobile interaction, UI-lane design fidelity, i18n copy.
- Critical gates: rendered design-fidelity comparison (12e2/12e3), mobile
  targeted widget tests + static analysis (12e0), entry-point reachability
  (12e1), AC3 copy guard.
- Phase 2 proceeded; review completed with one blocking gate failure.

## Critical Gate Results

| Gate | Rule | Result |
| --- | --- | --- |
| Rendered design-fidelity comparison | 12e2 / 12e3 | **FAIL** — see F-1 |
| Mobile static analysis | 12e0 | PASS — `flutter analyze --no-fatal-infos lib/features/reminders test/features/reminders` = 6 info, all pre-existing at BaseHead, none from changed files |
| Mobile targeted widget tests | 12e0 | PASS — `flutter test test/features/reminders` = +69; all 4 claimed new fidelity tests verified present in the two changed test files |
| AC3 copy guard | story AC3 | PASS — `reminder_copy_guard_test.dart` = +2; scans for `báo thức` / `Synced Alarm` / `Do Not Disturb` |
| Entry-point reachability | 12e1 | PASS — independently verified: `mobile/lib/features/home/presentation/home_screen.dart:114` mounts `ReminderScheduleScreen` from a labelled tappable Home affordance (`:157`); the diff changes no route or navigation |
| Runtime startup smoke | 12g | Not required — story is `Complexity: trivial` |

## Blocking Finding

### F-1 — No rendered visual-fidelity evidence exists; the required verdict is absent

`visual-fidelity/visual-fidelity-report.md` is the only file in the story's
`visual-fidelity/` directory. There is no `implemented-<screen>-<device>.png`
and no `design-reference-<screen>-<device>.png`, and the report contains no
`VISUAL_FIDELITY: PASS|FAIL` line and no `Design-Screen: <id>` at all.

`data/devops/system/design-fidelity-config.json` has `ui_surface: true` and a
**locked** `design_source` (`claude-design`, `cupid-app-design-system/project`,
entry `Cupid App.dc.html`, `screens_from: canvas`). Neither audited scope-out
applies, so rule 12e2/12e3 requires the rendered comparison.

Report §8 justifies the omission as "this lane has no provisioned emulator or
simulator, and provisioning one is outside mobile-dev's authority". That is
contradicted by this requirement's own merged evidence:

- STORY-020 (same lane, same wave, merged): `design-reference-vibe-android.png`
  + `implemented-vibe-emulator-5554.png`, recording `Design-Screen: vibe`
- STORY-003: `design-reference-splash-android.png` +
  `implemented-splash-emulator-5554.png`
- STORY-024: `design-reference-pet-android.png` +
  `implemented-pet-emulator-5554.png`

`emulator-5554` and both bundle tools are demonstrably available here, and the
preview harness already exposes this exact screen: `mobile/lib/main_preview.dart:101`
registers `'alarm'` → `mobile/lib/main_preview.dart:235` `_buildAlarm` →
`ReminderScheduleScreen`. No new preview entrypoint is needed.

The per-property design-source trace in report §3 and the four geometry
assertions are supporting evidence, not a substitute: 12e3 states the rendered
comparison is exactly what "verified by source/code inspection" may not replace,
and AC1's "matches exactly with no visible deviation" is a rendered claim.

**Owner: mobile-dev.** Required to clear F-1:

1. Resolve and record `Design-Screen: alarm` — confirmed from the canvas:
   `Cupid Screens.dc.html:2215` `isAlarm: sc === 'alarm'` and the screen list
   entry `{ id: 'alarm', ... }` at `:1878`.
2. Render the reference:
   `render-design-canvas.js --entry="Cupid App.dc.html" --screen=alarm --platform=android --theme=dark --lang=vi --label=alarm`
3. Capture the implementation from the preview build
   (`-t lib/main_preview.dart --dart-define=PREVIEW=alarm`) on `emulator-5554`
   via `capture-mobile-screen.sh`, following the STORY-020 recipe.
4. Cover both AC-bearing states: the schedule screen and the firing overlay
   (`alarmRinging` is a forceable canvas state at `Cupid Screens.dc.html:2413`).
5. Compare and record a per-state `VISUAL_FIDELITY: PASS|FAIL` with concrete
   deltas, and fold in F-2 below.

## Deferred / Secondary Findings

- **D-1 (fold into the F-1 pass) — stepper button size substitutes `tapTarget`
  for the design's 44dp.** `reminder_time_stepper.dart` sizes `_StepperButton`
  at `platformTokens.tapTarget` (48 on Material); `Cupid Screens.dc.html:494,496`
  specifies `width:44px;height:44px`. Report F9 presents this as fixed without
  recording the substitution, and it is not in the deferred list — inconsistent
  with F11, where the design's 34dp chip diameter *was* honoured with a
  tap-target workaround. Either apply 44 or record it as an explicit deferral
  with rationale. Non-blocking on its own; the render will settle whether it is
  visible.
- **D-2 — weekday chip horizontal hit area regressed from 48dp to 34dp.**
  `reminder_weekday_chips.dart` now uses
  `SizedBox(width: _chipDiameter /* 34 */, height: platformTokens.tapTarget)`.
  Vertical tap target is preserved, horizontal is not (was 48×48 at BaseHead).
  Design-mandated and the row must fit 7 chips at 360dp, so accepted, but record
  it as a known a11y trade-off rather than leaving it implicit in a comment.
- **D-3 — design-source line citations in the fidelity report drift by ~2-4
  lines.** Cited "line 497/499" for the stepper and clock resolve to
  `Cupid Screens.dc.html:494,496` and `:495`. Every cited *value* I spot-checked
  (44×44, 56px/-.03em, 96×96 r34, 52px butter, max-width 250, 300×60,
  30×1 divider, 12.5px/1.55) matches the markup, so this is citation hygiene
  only. Also note the report names `Cupid Screens.dc.html` as the "design source
  (locked)" while the locked config entry is `Cupid App.dc.html`; the former is
  the screen markup the latter's canvas renders.

Report §5 deferrals D1-D6 are accepted as reasonable and in-scope-bounded, with
one caveat: **D3** (the overlay's 52px clock readout, `Cupid Screens.dc.html:1660`)
drops an element the design source carries, on the argument that it implies a
system-alarm treatment. That reading is defensible but unverified — resolve it
against the rendered overlay comparison in the F-1 pass rather than on prose.

## Traceability

| AC | Verdict | Basis |
| --- | --- | --- |
| AC1 — dark + `vi` matches the design source exactly | **UNVERIFIED** | Per-property trace only; no rendered comparison exists (F-1). D-1 is an open known deviation. |
| AC2 — deviations corrected in the app, not documented | MET | 442 insertions / 91 deletions across 5 `lib/` files; every §3 row lands in code, confirmed against `git diff bf80848` |
| AC3 — user-visible copy reads "nhắc nhở đồng bộ" / "synced reminder" | MET | Copy guard passes; the last three inline `viEn(...)` literals moved into `reminder_strings.dart`. Correctly diverges from the design source's own `báo thức` / `reo` copy (`Cupid Screens.dc.html:531`), which AC3 overrides. |
| AC4 — dual swipe-to-dismiss visual matches, no system-alarm treatment | **UNVERIFIED** | Overlay code matches the cited values and stays an in-app `Material` scrim, but the same rendered gate is missing; §5 D3/D4 remove source elements without a render to justify it |
| AC5 — no new entry point | MET | No route, navigation, or `AppShell` change in the diff; Home entry verified in code at `home_screen.dart:114` |

OQ discipline: `story_master.md` triages OQ5 explicitly (light theme / `en`
locale out of scope, no AC blocked). Implementation neither implemented blocked
scope nor omitted unblocked ACs. No OQ defect.

Configuration guide: not applicable — no setup, env, or runtime configuration
impact in the diff.

## Recommendation

- Uncheck `Implementation (Development)`; leave `Review (Reviewer)` unchecked.
- Story status: `IN_PROGRESS`. Return to **mobile-dev** for F-1 (with D-1/D-2/D-3
  folded into the same pass), then re-review.
- Code quality of the delivered fixes is sound and the non-visual gates all pass;
  the story is one evidence pass away from closing.
