# Retro-Audit: STORY-009 Nhắc Nhở Đồng Bộ (synced reminders)

- Reviewer: Iris-QC (reviewer, `retro-audit` mode)
- Run Key: 2026-08-12:REQ-001:STORY-009:retro-audit
- BaseHead independently re-verified against: `f7d06fd4737cc7edbe6f6e33c205bf77fdf26f67` (current `main`)
- Prior recorded review (`review/review-report.md`, Outcome: CLEAN, 2026-07-31) treated as context only, not
  trusted as-is. Independently re-read `story_master.md`, `ux/uiux-spec.md`, `architecture/solution.md`,
  `coding-plan/master-plan.md`, `coding-plan/test-results.md`, the central OQ registry
  (`data/intake/bootstrap/conflicts_open_questions.md`), `req_master.md`, `design-fidelity-config.json`, the
  reused `mobile-visual-audit.md`, and the current source implementing this story (`mobile/lib/features/reminders/**`,
  `mobile/lib/main_preview.dart`).

## Acceptance Criteria (independently re-verified against current source)

| AC | Requirement | Evidence (file:line / test) | Result |
|---|---|---|---|
| AC1 | Paired user can create/trigger a synced reminder both partners receive | `reminder_schedule_screen.dart` submits `ReminderScheduleTimeSubmitted` → bloc emits `setAlarm`/`confirmAlarm` over `RealtimeCoordinator` (D1); `reminder_firing_cubit.dart` opens on inbound `triggerAlarm` and re-derives dismissal from `GET /alarms` `stopperIds` (D5). Named tests: `reminder_repository_test.dart` (3 outbound emits + 5-event inbound filter), `reminder_firing_cubit_test.dart` (`open (D5) opens on triggerAlarm...`), `reminder_firing_overlay_test.dart` (`ReminderOverlayHost mounts... once the cubit is open`). All PASS per `test-results.md` (184/184 `flutter test`). | PASS |
| AC2 | All in-app copy/localized strings use "nhắc nhở đồng bộ", never "báo thức" | Direct read of `mobile/lib/features/reminders/presentation/reminder_strings.dart`: every user-facing string uses "nhắc nhở đồng bộ" / "synced reminder"; file's own doc comment states the "never báo thức/Synced Alarm/reo-ring" rule. `reminder_copy_guard_test.dart` static-scans all of `mobile/lib/**` for forbidden tokens — PASS, independently confirmed by prior slice-c rerun in `test-results.md`. | PASS |
| AC3 | Notifications screen copy contains no Do-Not-Disturb-override claim | No Notifications settings screen exists under `mobile/lib` (confirmed absent — deliberate, per `story_master.md` Open Items and `architecture/solution.md` §3 Out Of Scope/D9). `reminder_copy_guard_test.dart` scans for "do not disturb" case-insensitive across `mobile/lib/**`, only hit is a doc-comment noting the clause was deleted, not a live string. | PASS |
| AC4 | No native/system alarm integration | Direct read of `mobile/pubspec.yaml`: none of `android_alarm_manager`, `flutter_local_notifications`, `alarm`, `awesome_notifications` present. No `MethodChannel`/`EventChannel` under `lib/features/reminders/**`. Guard test's pubspec dependency assertion PASS. | PASS |

## OQ Discipline

- **A1 (backend freeze)**: respected. `test-results.md` §5 records `git diff <BaseHead> --stat -- backend/` empty; no backend file touched by this story's diff.
- **D1/ADR-002 (báo thức → nhắc nhở đồng bộ; DND-override claim removed)**: resolved correctly. Architecture (`solution.md` §3 Open Question Constraints) and UX spec (`ux/uiux-spec.md` §4/§9) both record the resolution, and the shipped `reminder_strings.dart` + guard test enforce it structurally, not just by convention.
- **ASSUMPTION-1 (no server-side recurrence field, so "mỗi sáng"/"every morning" eyebrow copy can't literally repeat)**: flagged non-blocking to Product Owner in `story_master.md` Open Items and `architecture/solution.md` §7/§8. Still shows no recorded PO ruling in `req_master.md` or `story_master.md`. Non-blocking per the original architecture decision (implementation correctly does not claim auto-repeat anywhere in `reminder_strings.dart`), but the PO ruling itself remains an open follow-up item, not something this audit can resolve.
- **ASSUMPTION-2/R9 (no backend FCM dispatch, so no background delivery)**: documented, implementation correctly avoids faking background delivery with a local-notification plugin (would have violated AC4). Non-blocking, consistent with accepted risk in the OQ registry.
- No unescalated architectural deviations found. The D1/Critical-Alerts central OQ (from `conflicts_open_questions.md`) is the same one already resolved in this story's own artifacts — no new conflict.

## Design Fidelity — FAIL, attributable to this story

Ownership confirmed directly: `mobile/lib/main_preview.dart:40` maps the design's raw `alarm` screen id to
`ReminderScheduleScreen()` (this story's P2 output, `reminder_schedule_screen.dart`), with no fixture override.
`mobile-visual-audit.md`'s `alarm` FAIL is therefore this story's Design Fidelity result, not another story's.

Independently checked each of the audit's three listed deltas against current source:

1. **"Dark translucent card with subtle glow" (design) vs. "Bright pink→green gradient fill" (implemented)** —
   `reminder_schedule_screen.dart:230-236` (`_HeroCard`) uses `decoration: BoxDecoration(gradient:
   colors.gradientDream, ...)`, a bright gradient fill. This matches the implementation's own governing
   `ux/uiux-spec.md` §2, which explicitly specifies a "gradient card ... floating radial glow" for this hero
   card — so the code correctly followed its own UX spec. The mismatch is between that UX spec's description
   of the raw design and the `mobile-visual-audit.md`'s re-render of the raw design as it exists today. The
   audit report itself notes the design source moved (`Cupid Screens.dc.html` 175 KB → 247 KB, ~1141 lines)
   after this story's 2026-07-31 implementation date. This delta is plausibly (not provably, since the audit
   did not diff the design source pre/post) **post-implementation design drift**, not a story-authored
   regression. Recorded here as a real fidelity gap against the *current* design either way — the Design
   Fidelity gate is about the current shipped state, not fault attribution — but the fault/regression
   distinction matters for whichever role picks this up next.
2. **"Day chips T2–CN in a horizontal row" (design) vs. "Vertical column" (implemented)** —
   `reminder_weekday_chips.dart:23-41` lays out 7 chips in a `Wrap`, each `ConstrainedBox`'d to a
   `platformTokens.tapTarget` minimum of 44–48dp (`cupid_platform_tokens.dart:34,55`), inside a hero card with
   `CupidSpacing.lg` padding applied twice (outer scroll view + card itself,
   `reminder_schedule_screen.dart:153,231`). Seven 44–48dp circular tap targets plus inter-chip spacing need
   roughly 320–360dp of row width; after two `lg` paddings are subtracted from a typical ~360–412dp phone
   width, the remaining space is materially less than that, so the `Wrap` cannot fit all seven chips on one
   line and stacks them into multiple/near-vertical rows instead of the design's single horizontal row. This
   is a genuine structural layout defect, independent of backend/environment state, and is the strongest of
   the three findings.
3. **"Partner confirmation cards (Minh ✓ / Linh)" and "CTA 'Xác nhận giờ này'" — reported "Absent, and not
   documented as scoped out"** — direct read of `reminder_schedule_screen.dart:176-186,257-333` shows both
   `_ConfirmationRow` (per-partner cards) and `_PrimaryAction` (the "Xác nhận giờ này" CTA via
   `context.reminderConfirmCta`) **are implemented** per `ux/uiux-spec.md` §2, but they are gated behind
   `if (state.reminder != null && state.stage != null)`. `mobile-visual-audit.md`'s own preamble excludes
   "Error banners and empty states ... The backend was not running. Environment, not design" as a non-defect
   class for this exact reason — with no backend running, `GET /alarms` never returns a reminder, `state.reminder`
   stays `null`, and these widgets correctly render nothing per their own conditional. This specific item in
   the audit's detail table looks like a **false positive**: it falls squarely inside the audit's own excluded
   empty-state category but was not filtered out before being recorded as a structural defect. Recommend this
   line item be re-verified with a seeded (non-empty) reminder fixture before being treated as a real gap.

Net assessment: (1) is likely drift not regression, (3) is likely a false positive from the audit's own stated
exclusion rule, but (2) is a real, code-level structural deviation from the design that this story is directly
responsible for. Design Fidelity for this story's owned screen (`alarm`) is **FAIL**, driven primarily by the
weekday-chip layout.

## Findings

- **Finding 1 (Design Fidelity, confirmed, attributable to STORY-009):** `reminder_weekday_chips.dart`'s 7-chip
  `Wrap` does not fit one horizontal row at typical phone widths given `tapTarget` sizing plus double `lg`
  padding, producing a multi-row/near-vertical layout instead of the design's single horizontal day-chip row.
  Not a functional break (AC1 unaffected — chip selection still works), but a real visual-fidelity defect.
- **Finding 2 (Audit-quality issue, not a code defect):** the `mobile-visual-audit.md` detail table for `alarm`
  records the missing partner-confirmation cards/CTA as a structural defect, but this is very likely the same
  "backend not running → empty state" condition the audit's own preamble already excludes elsewhere. Recommend
  re-capturing this screen with a seeded reminder fixture before counting this specific item against the story.
- **Finding 3 (non-blocking, carried forward, already known):** ASSUMPTION-1's "mỗi sáng / every morning" eyebrow
  copy still has no recorded PO ruling. Does not block this story (implementation makes no auto-repeat claim
  anywhere), but remains an open follow-up.

No AC-level functional defects found. No unescalated OQ/A1 violations found.

## Story-level Substantive Verdict: NEEDS_WORK
## Classification Impact: RED-PATCH
## REVIEW_COMPLETE: YES
