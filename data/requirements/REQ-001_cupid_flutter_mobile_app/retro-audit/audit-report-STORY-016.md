# Retro Audit Report — STORY-016 profile_privacy_notifs

Story: STORY-016 profile_privacy_notifs
Requirement: REQ-001_cupid_flutter_mobile_app
Run Key: 2026-08-12:REQ-001:STORY-016:retro-audit
Reviewer: Iris-QC-16 (retro-audit)

Note: the reviewer's own tooling did not write this file directly (stated
"per role rules I don't write report files"); this report transcribes the
reviewer's returned findings verbatim into the canonical artifact path so
Batch 3 has a consistent per-story report set. No review judgment below is
Scrum Master's own — all findings are the reviewer's.

## AC-by-AC Traceability

(Evaluated against `story_master.md`'s own unedited AC text, lines 44-50.)

| AC | Status | Evidence |
| --- | --- | --- |
| AC1 — profile view/edit | PASS | `me_screen.dart`/`profile_edit_screen.dart` verified — editable name/DOB/zodiac, avatar read-only (disclosed DEC-1 limitation). |
| AC2 — "view and change privacy... exposed by backend contract" (as literally written) | **FAIL** | `privacy_screen.dart` verified to have zero `Switch`/`PATCH`/editable control. `isGhostModeEnabled` confirmed the only privacy field on the `User` entity, owned by STORY-008. |
| AC3 — "view and change notification... exposed by backend contract" (as literally written) | **FAIL** | `notification_settings_screen.dart` verified device-local only (`SharedPreferences`, zero `Dio`/`CupidApi` import). Confirmed backend has no notification module/field at all. |
| AC4 — no admin/data-export surface | PASS | `me_screen.dart` verified to have exactly 4 forward-link rows, no Digital Divorce, no export button, no functional `role` mapping. |

F-1 nav-reachability patch (privacy/notifications `onTap` wiring) independently
re-verified fixed on current `main`, with real widget tests
(`me_screen_test.dart:147-194`).

## Design Fidelity

Reused `integration-review/mobile-visual-audit.md` verbatim, not recaptured.
Story owns 3 screens (`me`, `privacy`, `notifs`).

| Screen | Result | Evidence |
| --- | --- | --- |
| `privacy` | UNVERIFIED (weak) | Ratio-only evidence (1.6x, "captured, not yet reviewed"), never fully reviewed |
| `me` | UNVERIFIED | Not among the 10 captured screens |
| `notifs` | UNVERIFIED | Not among the 10 captured screens |

Per the audit's own rule, `UNVERIFIED`/weak rows block `GREEN`/`AMBER`
independent of AC findings.

## OQ Discipline Findings

Main issue: AC2/AC3 were substantively rescoped (change→view-only;
backend-exposed→device-local-only) solely via the story-level PO artifact
`requirements/requirements.md`. Checked both allowed authority sources:
`req_master.md` has no `## Open Question Triage`/`## Approved Scope Change`
section anywhere (confirmed full read); central registry
`data/intake/bootstrap/conflicts_open_questions.md` has no STORY-016 AC2/AC3
entry at all. A story-level PO artifact is a downstream artifact, not a valid
Scope Authority per the governing rule.

Compounding: `story_master.md`'s own canonical AC2/AC3 text was never amended
to match the rescope — it still reads the pre-rescope wording. The review
chain (slice-a) explicitly says it worked from "a worktree copy of
`story_master.md`, reworded," not the canonical text.

Secondary: the data-export-button conflict (system UX memory §8 vs AC4) was
flagged by both UX and PO but never escalated to the central registry or
resolved.

This is a governance/traceability gap; the underlying engineering call
(respecting the A1 backend freeze) is technically sound.

Story-level Substantive Verdict: SIGNIFICANT_GAPS
Classification Impact: RED-PATCH
REVIEW_COMPLETE: YES
