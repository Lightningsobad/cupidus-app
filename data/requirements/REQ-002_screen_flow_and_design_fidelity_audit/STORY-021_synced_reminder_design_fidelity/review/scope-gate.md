# Scope Gate — STORY-021 (Round 2)

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

- Review type: `full-story-review` (Tier 2, round 2, supersedes round 1)
- Story: STORY-021 Design Fidelity — Synced Reminder
- Requirement: REQ-002_screen_flow_and_design_fidelity_audit
- Lane: mobile · Complexity: `trivial` (single-lane, so rule 15 is satisfied)
- Review report path:
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-021_synced_reminder_design_fidelity/review/review-report.md`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-021`
- Diff baseline: `bf808483223580df81b1fb951b141a6597cb82dd` → HEAD `51fb91dc`
  (round-1 HEAD was `d297cdfb`; commits `6aa77cb`, `a96c3d8`, `51fb91d` are new)

## Round-2 focus

Round 1 returned `PATCH_REQUIRED` on a single blocking finding: F-1, no rendered
visual-fidelity evidence existed. This round verifies whether that evidence now
exists, is genuine, and supports the claimed `VISUAL_FIDELITY: PASS` — by
opening the images, not by reading the verdict token (SKILL 12e3).

Round-1 items explicitly NOT re-derived: the per-property token-mapping and
deviation tables (F1-F29), already verified in round 1.

## Source/test files in scope (10 changed, within the 12-file Tier 2 cap)

| File | Why in scope |
| --- | --- |
| `mobile/lib/features/reminders/presentation/reminder_strings.dart` | AC3 copy |
| `mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart` | AC1/AC2 schedule surface, F34/F35 |
| `mobile/lib/features/reminders/presentation/widgets/reminder_firing_overlay.dart` | AC4 overlay, F30/F31/F32 |
| `mobile/lib/features/reminders/presentation/widgets/reminder_time_stepper.dart` | F33 (round-1 D-1) |
| `mobile/lib/features/reminders/presentation/widgets/reminder_weekday_chips.dart` | F36, D7 a11y trade-off |
| `mobile/lib/main_preview.dart` | NEW in `51fb91d`, after the fidelity report was written |
| `mobile/lib/preview/preview_reminder_fixture.dart` | NEW in `51fb91d`, undocumented in the fidelity report |
| `mobile/test/features/reminders/reminder_firing_overlay_test.dart` | capture generator + F29/F30 pins |
| `mobile/test/features/reminders/reminder_schedule_screen_test.dart` | capture generator + F11/F18/F23/F33 pins |
| `mobile/test/features/reminders/visual_capture_support.dart` | the capture harness itself — decides whether the evidence is a real render |

## Evidence files in scope

- `visual-fidelity/visual-fidelity-report.md` (32 KB — ranged reads only)
- `visual-fidelity/design-reference-alarm-android.png`
- `visual-fidelity/design-reference-alarm-ringing-android.png`
- `visual-fidelity/implemented-alarm-schedule-412x915.png`
- `visual-fidelity/implemented-alarm-ringing-412x915.png`
- `visual-fidelity/implemented-alarm-emulator-5554.png` (11.9 KB, added by
  `51fb91d` and NOT described anywhere in the fidelity report — must be opened)
- `review/review-report.md` (round 1, blocking finding F-1 only)
- `coding-plan/test-results.md` — checked for existence (entry-point + runtime
  smoke sections)

## Touched risk surfaces and critical gates

| Risk surface | Critical gate | Must verify |
| --- | --- | --- |
| Mobile interaction / UI layout | Rendered design fidelity (12e2 + 12e3) | Both images open, depict THIS screen, and do not contradict `PASS` |
| Mobile navigation / discoverability | Entry-point reachability (12e1) | `Reachable: YES` in test-results AND independently confirmed in code |
| Mobile lane, non-trivial-by-diff-size | Runtime startup smoke (12g) | App launches to first screen, or `Runtime-Smoke: WAIVED` recorded |
| Mobile build/static analysis | `flutter analyze` + `flutter test` | Evidence present and passing |
| App lifecycle / preview entrypoint | `main_preview.dart` change safety | New preview fixture must not alter production behaviour |

## Query keys for Phase 2

`captureAtReferenceViewport`, `CAPTURE_VISUALS`, `preview_reminder_fixture`,
`main_preview` alarm id, `Design-Screen: alarm`, `VISUAL_FIDELITY`,
`Entry Point Reachability`, `Runtime-Smoke`, `Story Runtime Startup Smoke`,
`_ConfirmCta`, `_DismissPill`, `_clockFontSize`, `_chipDiameter`.

## Gate decision

Phase 2 may proceed. Two pre-identified risks drive the round-2 verdict:
1. the implementation PNGs are described by the report as in-process widget
   renders, not device captures — genuineness must be judged from the images and
   the harness;
2. `implemented-alarm-emulator-5554.png` (11.9 KB) arrived in the final commit
   with no mention in the fidelity report — an undocumented capture of unknown
   content.
