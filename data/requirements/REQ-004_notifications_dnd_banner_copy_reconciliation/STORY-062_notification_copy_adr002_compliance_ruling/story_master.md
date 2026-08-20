# Story Master: STORY-062 Notification Copy ADR-002 Compliance Ruling
Status: DONE
Complexity: trivial
Implementation Lane: mobile
Story-Class: standard
Visual-Fidelity-Evidence: NOT_APPLICABLE — the entire story diff is one test file (`mobile/test/features/reminders/reminder_copy_guard_test.dart`); zero production screens or UI changed, so there is no rendered state to capture and nothing to compare it against.

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — SKIPPED:trivial
- [x] Architecture (Tech Lead) — SKIPPED:trivial
- [x] Implementation (Development)
- [x] Review (Reviewer) — Outcome: DEFERRED_ONLY (0 blocking, 1 deferred: D-1
  LOW, ARB-coverage gap, pre-existing, not a condition of closing this story).
  See `review/review-report.md`.

## Blocker Cleared: MOBILE_VISUAL_AUDIT_STATE_MISSING (2026-08-21)

Recorded 2026-08-20 because `guard-story-done-evidence.sh` refused `Status: DONE`
without rendered visual evidence, while this story's entire diff is one test file
(`mobile/test/features/reminders/reminder_copy_guard_test.dart`) with zero
production screens changed — verified independently by the Reviewer's
`git diff --stat` check (review-report.md AC2/AC3) and its risk-surface verdict:
"Design fidelity (12e2/12e3) | Not applicable | The story delivers zero
production UI change; there is no implemented screen state to render or compare."

That finding stands. The blocker TOKEN was wrong, and is withdrawn for two
reasons:

  * `MOBILE_VISUAL_AUDIT_STATE_MISSING` means "the canvas holds no screen for
    this story — the design never covered it", and its documented remedy is to
    dispatch ui-ux-designer to obtain the missing canvas export. That would put a
    designer to work drawing a screen this story neither has nor needs.
  * Its own precondition does not hold: the token is documented to leave the
    story with an `implemented-*.png` and no matching reference. This story has
    no screenshots at all, because it renders nothing.

The token was the closest thing the guard's refusal named, so recording it was
reasonable at the time. The refusal had no other route to offer: the zero-UI
exemption existed in `visual_fidelity.py` but required three fields, two of which
appeared in no documentation anywhere in the system, and the third belonged to a
different gate owned by a different role.

Resolution (operator decision, 2026-08-20): that exemption is now ONE line with a
mandatory reason, `Visual-Fidelity-Evidence: NOT_APPLICABLE — <why>`, declared in
the story header above. The hooks and the product-owner skill were updated and
reinstalled; the refusal now names this route itself.

Status was moved off `BLOCKED` because nothing is blocking. `DONE` is
deliberately NOT set here — closing the story belongs to the wave and its own
DONE gate, not to the session that cleared this record.
