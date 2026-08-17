# Story Master: STORY-037 Hardening - Invite Screen Visual Fidelity Evidence

Status: RETRO_PENDING
Complexity: TBD (Product Owner to assign)
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-011_invite_code_design_fidelity
Scope: Retro-hardening (RWB-20260816-004)
Screen: invite (tạo mã), Epic 1 (Core connection / onboarding), NO_CHROME /
NO_TABS
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [ ] Requirements (Product Owner)
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-004 (source: REQ-002
audit report, `retro-audit/audit-report.md`) found
STORY-011_invite_code_design_fidelity's Design Fidelity evidence pair
missing both sides: its own `visual-fidelity/` directory holds only
`visual-fidelity-report.md`, no images either side — the same IF-7-class gap
already remediated for `welcome` (STORY-035) and `register` (STORY-036).

Note: a `design-reference-invite-android.png` already exists in STORY-002's
own `visual-fidelity/` folder, confirming the `invite` canvas screen renders
fine and tooling is not the blocker here — the capture was simply never
produced for STORY-011's own directory.

Note also: STORY-011's own `story_master.md` currently records
`Status: PENDING` with the `Review (Reviewer)` artifact unchecked, even
though `req_master.md`'s `## User Stories` table and the retro audit both
treat it as a completed/DONE screen (same discrepancy pattern already found
and left undisturbed for STORY-006/STORY-036) — Product Owner should
reconcile this discrepancy as part of scoping this hardening story, not
assume it away.

Exact remediation needed (per `rework-backlog.md`):
1. Capture `implemented-invite-<device>.png` from the running app (dark
   theme + `vi` locale, per STORY-011's own configuration).
2. Render/obtain `design-reference-invite-android.png` via
   `render-design-canvas.js --screen=invite` (or reuse/verify the copy
   already rendered into STORY-002's own `visual-fidelity/` directory,
   confirming it depicts the same screen/state before reusing it).
3. Re-compare both renders against STORY-011's existing AC scope (layout,
   spacing, color/token usage, typography, code-display/share component
   styling); if any deviation is found by the rendered comparison, correct
   it in the app code — this is a fix, not merely a re-documentation.
4. Place the matched, same-screen evidence pair
   (`implemented-invite-<device>.png` and
   `design-reference-invite-android.png`) in this story's own
   `visual-fidelity/` directory, with a `visual-fidelity-report.md` that
   records `VISUAL_FIDELITY: PASS` once both images match.

## Depends On
- NONE. Independent of every other REQ-002 hardening item; must not reopen
  STORY-002's, STORY-011's, STORY-034's, STORY-035's, or STORY-036's closed
  git boundary/branch.
