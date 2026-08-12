# Story Master: STORY-018 Hardening - Design Fidelity Capture Coverage (Retro-Audit RED-PATCH)

Status: RETRO_PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-001
Retro-Type: RED-PATCH
Fixes: REQ-001 (Design Fidelity, requirement-wide — the reused
`integration-review/mobile-visual-audit.md` evidence captured only 10 of 37
design screens, with only 2 of those 10 fully reviewed; this gap is present
across STORY-001, STORY-003, STORY-005, STORY-007, STORY-009, STORY-011,
STORY-012, STORY-013, STORY-014, STORY-015, and STORY-016's Design Fidelity
rows)
Source: `data/requirements/REQ-001_cupid_flutter_mobile_app/retro-audit/audit-report.md`
(Audit Date 2026-08-12, Overall Verdict RED-PATCH — CONFIRMED, user-confirmed
2026-08-12)
Operational note: default `CupidApiConfig.baseUrl` is connection-refused in
this environment; use `--dart-define=CUPID_API_BASE_URL=http://localhost:3005`
(backend runs at `http://127.0.0.1:3005`).

## Depends On
- STORY-017 (informational only, not a hard blocker): STORY-017's
  AC-coverage-gap disposition may identify which screens must carry a
  design-conformance acceptance criterion, which should inform this story's
  MATCH/DEVIATION report structure. This story's capture work itself is not
  blocked by STORY-017 and may proceed in parallel or before it completes.

## User Story
As the Scrum Master / QA process, I need complete design-fidelity evidence
for all 37 design screens (not just 10, and not just 2 fully reviewed), so
that future RED-PATCH code-fix hardening stories are scoped from a complete,
harness-artifact-free deviation list instead of the current partial/ratio-only
evidence.

## In Scope
1. Wire all 37 design screens into the mobile preview harness
   (`mobile/lib/main_preview.dart`) — currently only 10 are wired.
2. Wrap preview entrypoints in the real `AppShell`/`CupidTabBar` chrome for
   every screen normally reached through it, so a missing-tab-bar harness
   artifact is not misread as an implementation deviation (the prior audit
   explicitly flagged this as a harness limitation already producing false
   findings).
3. Run every capture with the backend live at `http://127.0.0.1:3005`
   (`--dart-define=CUPID_API_BASE_URL=http://localhost:3005`), seeding
   paired/populated state where a screen needs it to render meaningfully, so
   empty/error states from a dead or unpaired backend are not misread as
   design deviations.
4. Render all 37 design references from the locked `cupid-app-design-system`
   bundle (via `render-design-canvas.js` or its current equivalent).
5. Produce one `design-reference-<screen>.png` and one
   `implemented-<screen>.png` pair per screen, and record a MATCH or
   DEVIATION verdict with concrete, specific deviation detail (not a
   PNG-size-ratio proxy) for every one of the 37 screens in an updated
   visual-fidelity report (successor to `mobile-visual-audit.md`).

## Out of Scope
- Fixing any deviation found by this story's capture pass — deviations found
  here feed future code-fix hardening stories, not this one.
- Re-litigating the two screens already fully reviewed by direct comparison
  (`alarm`, `home`, both confirmed FAIL) unless the AppShell/backend-live
  harness fix changes their rendered result — if it does, the report must
  say so explicitly rather than silently overwriting the prior finding.
- Any change to `mobile/lib` application/feature code outside the preview
  harness itself.

## Acceptance Criteria
1. 37/37 screens named in `Cupid App.dc.html` have both a
   `design-reference-*.png` and an `implemented-*.png` rendered and saved
   under this story's evidence path.
2. Every one of the 37 screens has a recorded MATCH or DEVIATION verdict
   with concrete, specific deviation detail written into an updated
   visual-fidelity report — a PNG-size-ratio proxy alone does not satisfy
   this AC for any screen.
3. All captures are taken with the backend live at `127.0.0.1:3005` (or the
   current equivalent); any screen requiring paired/populated state to
   render meaningfully has that state seeded before capture, and the report
   states what state was seeded per screen.
4. Every capture for a screen normally reached through app navigation
   includes the real `AppShell`/tab-bar chrome, so a missing-chrome harness
   artifact is not counted as an implementation deviation.
5. The final report replaces the current "2 screens fully reviewed (both
   FAIL) + 8 ratio-only + 27 uncaptured" evidence state with a complete
   37/37 MATCH/DEVIATION accounting — no screen remains in a ratio-only or
   zero-evidence bucket.
6. The AC in this story is judged by these outcomes, not by tooling
   existence — "the harness supports 37 screens" does not satisfy AC1/AC2;
   the rendered pairs and recorded verdicts must actually exist for all 37.

## Downstream Note
This story's MATCH/DEVIATION report is the authoritative scoping input for
any future Design-Fidelity-driven code-fix hardening stories. Do not scope
or create those stories from the current partial evidence.
