# Story Master: STORY-038 Hardening - Paired Success Screen Visual Fidelity Evidence

Status: RETRO_PENDING
Complexity: TBD
Story-Class: TBD
Implementation Lane: TBD
Requirement: REQ-002
Retro-Type: RED-PATCH
Fixes: STORY-014_paired_success_design_fidelity
Scope: Retro-hardening (RWB-20260816-005)
Screen: paired (ghép xong), Epic 1 (Core connection / onboarding), NO_CHROME /
NO_TABS
Design-Screen: paired
Design reference: `cupid-app-design-system` (locked, confirmed by
`detect_design_source.py`)

## Artifacts
- [ ] Requirements (Product Owner)
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Background (Rework Item)
`data/retro-audit/rework-backlog.md` item RWB-20260816-005 (source: REQ-002
audit report, `retro-audit/audit-report.md`) found
STORY-014_paired_success_design_fidelity's Design Fidelity evidence pair
missing both sides — same IF-7-class gap already remediated for `welcome`
(STORY-035), `register` (STORY-036), and `invite` (STORY-037).

The original audit report describes the pre-existing screen as "not a
partial match — it was a placeholder," recording 15 deviations found and 14
corrected directly in code, **none of it visually confirmed** with a
rendered image pair. This is a materially larger claimed-fix surface than
the welcome/register/invite hardening items, so this story's rendered
comparison must re-verify all 14 previously-claimed code fixes against the
locked design source, not just check for new deviations.

Note also: STORY-014's own `story_master.md` currently records
`Status: PENDING` with the `Review (Reviewer)` artifact unchecked, even
though `req_master.md`'s `## User Stories` table and the retro audit both
treat it as a completed/DONE screen (same discrepancy pattern already found
and left undisturbed for STORY-006/STORY-011, remediated via
STORY-036/STORY-037) — Product Owner should reconcile this discrepancy as
part of scoping this hardening story, not assume it away. STORY-014's own
`Implementation (Development)` checkbox is already checked with an evidence
path of `visual-fidelity/visual-fidelity-report.md` (report only, no images)
— confirming the code-level fix work happened but was never reviewed nor
visually confirmed.

Exact remediation needed (per `rework-backlog.md`):
1. Capture `implemented-paired-<device>.png` from the running app (dark
   theme + `vi` locale, post-pairing-success state, per STORY-014's own
   configuration).
2. Render `design-reference-paired-<platform>.png` via
   `render-design-canvas.js --screen=paired` (confirm the exact screen id
   via `--list-screens` if `paired` does not resolve).
3. Re-compare both renders against STORY-014's existing claimed scope
   (layout, spacing, color/token usage, typography, and every one of the 15
   originally-found deviations); if any deviation remains, was missed, or
   was newly introduced, correct it in the app code — this is a fix, not
   merely a re-documentation.
4. Place the matched, same-screen evidence pair
   (`implemented-paired-<device>.png` and
   `design-reference-paired-<platform>.png`) in this story's own
   `visual-fidelity/` directory, with a `visual-fidelity-report.md` that
   records `VISUAL_FIDELITY: PASS` once both images match.

## Depends On
- NONE. Independent of every other REQ-002 hardening item; must not reopen
  STORY-002's, STORY-011's, STORY-014's, STORY-034's, STORY-035's,
  STORY-036's, or STORY-037's closed git boundary/branch.
