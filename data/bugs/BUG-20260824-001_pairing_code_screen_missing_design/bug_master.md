# Bug Master: BUG-20260824-001 pairing_code_screen_missing_design
Status: ESCALATED_TO_BACKLOG
Severity: unknown
Source: user
Created: 2026-08-24
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Linked Story: STORY-011_invite_code_design_fidelity (superseding fix landed via STORY-037_invite_design_fidelity_hardening)

## Report

Observed behavior:
User reports (Vietnamese): "màn hình `Mã ghép đôi của bạn` đang bị sai design, đúng hơn là thiếu, hãy kiểm tra." Translation: the "Your pairing code" screen has incorrect design — more precisely, design elements appear to be missing. No screenshot or further detail was provided in the report.

Expected behavior: The invite/create-pairing-code screen ("Mã ghép đôi của bạn") must match the locked design source `cupid-app-design-system` exactly for the enabled dark theme + `vi` locale: layout, spacing, color/design-token usage, typography, and the code display/share component styling (mono type treatment if specified in the source) — per `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-011_invite_code_design_fidelity/story_master.md` Acceptance Criteria 1-3, last delivered via `STORY-037_invite_design_fidelity_hardening`.

Design-source drift note: `python3 .claude/hooks/lib/detect_design_source.py --project "$CLAUDE_PROJECT_DIR"` reports `DESIGN_SOURCE_DRIFTED` for both `cupid-app` and `cupid-web` (design system `cupid-app-design-system`) — content changed since 2026-08-22T02:17:06Z (sha256:ac2cd52...  -> sha256:a430b91...). STORY-011/STORY-037's rendered visual-fidelity evidence for this screen predates this content change and should be re-verified against the current design source content as part of diagnosis.

Reproduction steps or command:
Navigate to the "Mã ghép đôi của bạn" (your pairing code / invite-create-code) screen in the app and compare rendered UI against the current `cupid-app-design-system` content.

Failure anchors:
- Stack trace: N/A (visual/design defect, not a crash)
- Failing test: N/A (not yet identified)
- Route/endpoint/component/job: invite/create-pairing-code screen ("Mã ghép đôi của bạn"), governed by STORY-011 (`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-011_invite_code_design_fidelity/`) and its fix STORY-037 (`data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-037_invite_design_fidelity_hardening/`) — exact widget/component id not yet identified
- Environment: not specified by user

## Artifacts

- [x] Diagnosis (Bug Fixer)
- [x] Fix Evidence (Bug Fixer) — no patch; reproduction + escalation evidence only
- [ ] Review (Reviewer) — not applicable, no patch to review

## Routing Notes

- Current owner: scrum-master
- Next role: ESCALATED_TO_BACKLOG — route through ordinary REQ-002 follow-up requirement/story flow, not Bug Fixer
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md`
- Fix Evidence: `fix-evidence.md`
- Review Report: `review/review-report.md` (not produced — no patch exists)
- Checkpoint: `scrum-master-checkpoint.md`

## Blockers

- Not a narrow bugfix. Bug Fixer reproduced the report (Pre-Fix Reproduction Gate: REPRODUCED, same-modality Android emulator capture, evidence at `evidence/reproduction-invite-emulator-5554.png`) but found the "missing" elements — a couple-type picker ("Tụi mình thuộc kiểu nào?", 4-card grid) and its continue CTA — were explicitly excluded from STORY-011/STORY-037 scope as approved, reviewer-waived product-scope exclusions (STORY-011 visual-fidelity report lines 27-30; STORY-037 Reviewer gate item G4). The app matches its own approved delivery state.
- A separate, later divergence (commit `3d74a75`, 2026-08-20, after STORY-037's 2026-08-17 delivery) rewired the invite screen's post-code navigation from `goWaiting`/"Đợi ghép" to `goVow`/"Fingerprint Vow" and deleted the `isPairingChoice` design node entirely, orphaning `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart` (added by STORY-034), which now has no matching design node.
- Closing the real gap needs Product Owner + UI/UX Designer decisions: a couple-type content catalog (vi/en labels, hints, icons), `CupidProfile.coupleType` persistence semantics, a navigation decision for where the picker leads (STORY-011 explicitly assigns this to REQ-002 Scope A / STORY-001-STORY-002, not this screen), and a decision on the now-orphaned pairing-choice screen.
- `DESIGN_SOURCE_DRIFTED` (ac2cd52 -> a430b91) is a red herring for this bug: the only post-lock design-system commit (`9aa0aed`) touches `support.js` only; invite markup did not change.
- Device cleanup left for the operator: `emulator-5554` still has the `PREVIEW=invite` preview build installed as `com.snapsofts.cupid`; tear down with `adb -s emulator-5554 shell am force-stop com.snapsofts.cupid` then `adb -s emulator-5554 emu kill` before any run needing the real app.
- Recommendation: open a REQ-002 follow-up requirement (or new REQ) covering the whole divergence family — invite couple-type content, post-invite navigation, and the orphaned pairing-choice screen — through the ordinary Product Owner-led flow, not the bug queue.
