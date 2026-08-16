# Bug Master: BUG-20260816-001 Welcome Screen Backdrop Gradient + Google CTA Brand Mark

Status: IN_PROGRESS
Severity: HIGH (R2-1) + MEDIUM (R2-2), one patch round
Source: REQ-002 Round 2 requirement integration review (Iris-QC), findings
R2-1 and R2-2, upholding/extending Round 2 requirement mobile visual audit
finding IF-1
Created: 2026-08-16
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Linked Story: STORY-004 (welcome design fidelity, DONE — this bug does not
reopen that story's gate; it is an integration-scope defect on a merged
screen, same handling as BUG-20260815-001/002 and BUG-20260814-002/003/004)

## Report

Observed behavior (R2-1 — background gradient):
`mobile/lib/features/auth/presentation/screens/welcome_screen.dart:150-158`
paints the full-screen backdrop with
`colors.gradientHot.colors.reversed.toList(growable: false)`. `gradientHot`
is the two-stop **button** gradient `[#FF7FB6, #B78CF5]`
(`mobile/lib/design_system/tokens/cupid_color_tokens.dart:99-103`). Reversed,
it renders a pale lavender→pale pink backdrop.

Expected behavior (R2-1):
The locked design source's welcome-screen backdrop is the three-stop brand
gradient `#7B2FBE 0% → #FF4B8C 58% → #FF3366 100%`
(`linear-gradient(165deg, ...)`).

Consequence: every foreground element on the screen is white or
white-at-alpha (sub-copy at 78% alpha, legal footnote at 65% alpha/11.5px,
the accent rule, the outlined "Dùng email" CTA at 50% alpha border) — all at
or past the edge of legibility against the pale backdrop. Compare
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/integration-review/mobile-screenshots/implemented-welcome-emulator-5560.png`
against
`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-033_app_shell_design_system_deltas/visual-fidelity/design-reference-welcome-android.png`.

Observed behavior (R2-2 — Google CTA brand mark):
`welcome_screen.dart:300-313` constructs the Google CTA as a `_FilledCta`
with only `label`/`background`/`foreground`/`elevation`/`radius`/`labelStyle`
params — no leading-icon parameter, so no brand mark renders.

Expected behavior (R2-2):
The locked design shows the multicolour Google "G" glyph before the "Tiếp
tục với Google" label — the same defect class STORY-005 BF-04 already fixed
on the `login` screen's Google/Facebook CTAs.

Why not reopening STORY-004: `lib/design_system/` was outside STORY-004's
WriteScope when it ran (D13 in that story's evidence), so the backdrop
gradient was an accepted deferral at the time. STORY-032/033 have since
merged and made the design system writable; the deferral's stated cause has
expired. R2-2 was never checked at all — STORY-004 shipped with no rendered
visual-fidelity evidence (see `req_master.md` deferred item IF-7), so this
comparison never happened until this review round.

Reproduction steps or command:
Not run by Scrum Master (intake only, per this bug's routing notes).
Candidate: render `welcome` via the preview entrypoint/deep link
(`cupidpreview://screen/welcome`) on `emulator-5560` and compare against the
design reference screenshot named above.

Failure anchors:
- Stack trace: N/A (design-fidelity defect, not a crash)
- File: `mobile/lib/features/auth/presentation/screens/welcome_screen.dart`
  (lines 150-158 for R2-1, lines 300-313 for R2-2)
- Design tokens: `mobile/lib/design_system/tokens/cupid_color_tokens.dart`
  (`gradientHot`, lines 99-103) — R2-1 needs a NEW token for the three-stop
  brand backdrop gradient, added here, not an inline hex at the call site
  (ADR-004 no-fork guard is green again; ensure this fix keeps it green)
- Reference fix pattern for R2-2: `login_screen.dart`'s Google/Facebook CTA
  brand-mark wiring from STORY-005 BF-04 (round 3 patch,
  `STORY-005_login_design_fidelity/coding-plan/test-results.md` § Patch
  Round 3)
- Environment: mobile (Flutter), Android, `emulator-5560`

## Artifacts

- [ ] Diagnosis (Bug Fixer)
- [ ] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Routing Notes

- Current owner: Justin-BugFixer-2 (dispatched 2026-08-16, `Mode: fix-bug`)
- BUG-20260814-001 is DONE, freeing the bug-fixer cap-1 slot for this bug.
- Work location: fix directly in the REQ-002 integration worktree
  (`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`,
  branch `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`),
  not a fresh story worktree — this defect is only observable once
  STORY-004/032/033 are merged together.
- After fix + Reviewer `DEFERRED_ONLY`/`CLEAN`: re-capture
  `implemented-welcome-*.png` (one screen only, not the full 31-screen audit)
  and compare against the design reference, per Round 2 review "Required To
  Clear" item 3.
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md`
- Fix Evidence: `fix-evidence.md`
- Review Report: `review/review-report.md`
- Checkpoint: `scrum-master-checkpoint.md`
- Origin: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/integration-review/review-report.md`
  Round 2, findings R2-1/R2-2 (commit `83d456f` in the integration worktree)

## Blockers

- N/A
