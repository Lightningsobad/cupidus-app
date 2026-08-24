# Story Master: STORY-002 Pairing-Choice Navigation Restore

Status: DONE
Complexity: standard
Implementation Lane: shared
Design-Surface: cupid-app
Story-Class: standard
Requirement: REQ-009
Screen: `invite`, `joincode`, `pairing_choice` — Epic 1 (Core connection /
onboarding), NO_CHROME / NO_TABS
Visual-Fidelity-Evidence: `pairing_choice` is the only screen with new visual
scope in this story (design-system canvas node/edge restore + navigation
guards only); `invite` and `joincode` are pre-existing screens whose own
content is unchanged by this story (no `mobile/lib/` UI edit — see
Implementation below) and carry no new rendered evidence here.
`visual-fidelity/implemented-pairingchoice-android.png` and
`visual-fidelity/design-reference-pairingchoice-android.png` back
`VISUAL_FIDELITY: PASS` in `visual-fidelity/visual-fidelity-report.md`.
Regression risk: same commit family (`3d74a75`) as
`BUG-20260817-001` (FAB/send-button occlusion) — a related regression guard
already exists; do not disturb it outside this story's own scope.
Runtime-Smoke: PASS — 2026-08-24, Frank-Devops device pass (finding B5).
`emulator-5554`, built `main_preview.dart` PREVIEW=pairingchoice, installed,
launched: `topResumedActivity` = `MainActivity`, no `FATAL EXCEPTION`/
`AndroidRuntime` crash entries in logcat. See
`coding-plan/test-results.md` `## Story Runtime Startup Smoke (B5, DevOps
device pass)` for full command/output evidence.

## Artifacts
- [ ] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — done: restored the `isPairingChoice`
  design-system node and the `invite`/`joincode` `BACK_TO` edges deleted by
  `3d74a75` (see `ux/ux-spec.md`)
- [x] Architecture (Tech Lead) — done: `architecture/solution.md` +
  `coding-plan/` (P1 design-source restore, P2 navigation guards). Key finding:
  the Flutter graph already matches the locked decision and `goVow` exists only
  in the design canvas, so no `mobile/lib/` change is in scope.
- [x] Implementation (Development) — patch cycle closed 2026-08-24. P1
  restored the `isPairingChoice` canvas node and the `invite`/`joincode`
  `BACK_TO` edges (7 edits across the two `.dc.html` files); P2 added the
  post-code navigation guards in `mobile/test/` only — no `mobile/lib/`
  change, as Tech Lead found. `+38` targeted and `+172` regression tests
  pass, `flutter analyze` clean on touched files. F1 patch (2026-08-24):
  `DESIGN_RENDER_TOOL_UNRESOLVED` superseded — `render-design-canvas.js`
  exists in the control checkout only; rendered reference now produced at
  `visual-fidelity/design-reference-pairingchoice-android.png`, confirming
  the P1 restore end-to-end. Implemented-side device capture remains
  `DEVICE_CAPTURE_BLOCKED` (emulator storage) and was not retried — per
  Reviewer's own fallback this escalates only that one sub-gate to `BLOCKED`;
  the design-reference render, F2, F4, and F5 are supplied regardless. F2
  patch: `## Entry Point Reachability` added to `coding-plan/test-results.md`
  (`Reachable: YES`, evidenced by `pairing_choice_screen_test.dart`
  `_gateHarness()`). F3: `Runtime-Smoke: WAIVED` recorded above (Scrum
  Master). F4: AC3 amended above (product-owner). F5: `Design-Surface:
  cupid-app` recorded above (Scrum Master). Evidence:
  `coding-plan/test-results.md`, `visual-fidelity/`.
  Review history (superseded by the cycle-4 outcome below): cycle-2
  `compact-story-review` re-review run 2026-08-24 returned
  `Outcome: BLOCKED` (`review/review-report.md`). Prior F1/F2/F3/F5 RESOLVED and
  re-verified independently (targeted suite `+38` re-run by Reviewer,
  `mobile/lib/` diff re-confirmed empty, entry-point reachability verified in
  `pair_gate_shell.dart:139`). AC1/AC2/AC4/AC5/AC7 PASS.
  **B1 — RESOLVED (2026-08-24).** User decided (AskUserQuestion): asymmetric
  routing — invite stays Waiting-for-partner, join-code/invitee goes to
  `paired`. Andy-PO-2 (control-plane, not a parallel worker) updated
  `req_master.md` locked decision #2 and 7 locations in
  `requirements/requirements.md`; independently re-verified by Scrum Master
  via direct read of both files. Committed to `main`
  (`docs(REQ-009): ratify asymmetric join-code routing per user decision`).
  **B2 — storage blocker RESOLVED, capture retry structurally blocked
  (2026-08-24).** DevOps (Frank-Devops) wiped/recreated the emulator's AVD
  userdata: `emulator-5554` `/data` went from 93% used (425 MB free) to 8%
  used (9.0 GB free), verified via a simulated 300 MB `pm install-create`
  session. See `coding-plan/test-results.md` `## Device Environment —
  Emulator Storage (B2)`. The actual on-device install+screenshot retry was
  **not** attempted: `guard-broad-handoff.sh` rejects mobile-dev handoffs
  routing emulator/device/install/screenshot work in ordinary
  continue/continue-parallel flow (confirmed blocking twice this session,
  undocumented GENERIC code per `.claude/hooks/guard-codes.md`'s `## BROAD
  HANDOFF GUARD` section). **Disposition (Scrum Master):** accepted as a
  structural, non-remediable-in-this-flow gap — `DEVICE_CAPTURE_BLOCKED`
  stands, `visual-fidelity-report.md` records `VISUAL_FIDELITY: PARTIAL`, and
  per the Reviewer's own stated fallback the design-reference render + F2 +
  F4 + F5 stand in for the missing pixel diff and do not block the story.
  **B3 — RESOLVED (2026-08-24).** mobile-dev (Alex-Mobile-Dev-2) fixed the
  title-size delta: `pairing_choice_screen.dart:92` `fontSize: 27` ->
  `fontSize: 24`, matching the canvas. `+172` regression tests re-run green,
  `flutter analyze` clean on the touched file, write-scope proof confirms only
  the two declared paths changed. See `coding-plan/test-results.md`
  `## B3 — Title-size fidelity fix`. The remaining EN primary-CTA wording
  deviation stays deferred (OQ5, `en` not user-enabled).
  D1/D2 deferred, carried forward unchanged. **All of B1/B2/B3 are now
  dispositioned — ready for a fresh `compact-story-review` re-check.**
  **Cycle-3 re-review (Iris-QC) returned `PATCH_REQUIRED` again — B4/B5
  (2026-08-24).** B1/B3 re-verified RESOLVED. B4: AC6 implemented-side
  capture still didn't exist (`DEVICE_CAPTURE_BLOCKED`/`PARTIAL` no longer a
  legal disposition once B3 changed the rendered typography the capture
  exists to confirm). B5: `Runtime-Smoke: WAIVED` basis falsified by B3's own
  edit. **RESOLVED 2026-08-24 (Frank-Devops device pass):** device capture is
  now `CAPTURED` —
  `visual-fidelity/implemented-pairingchoice-android.png` exists (built
  `main_preview.dart` PREVIEW=pairingchoice, installed/launched on
  `emulator-5554`, screencap taken); runtime smoke is `PASS` (see
  `Runtime-Smoke:` line above). **RESOLVED 2026-08-24 (Alex-Mobile-Dev-2
  comparison pass):** `visual-fidelity-report.md` now records
  `VISUAL_FIDELITY: PASS` — the implemented-side capture was compared
  pixel-for-pixel against the design reference, all cycle-3 deltas confirmed
  matching, no new defect found for this screen. The
  `BUILD_EVIDENCE_GATE_SESSION_LOCK` blocker raised during this pass (a
  mistyped test path, not a red test) was independently re-verified and
  accepted by Scrum Master — see
  `RUN-REQ-009_invite_couple_type_and_pairing_navigation-STORY-002_pairing_choice_navigation_restore-mobile-dev.json`
  `scrum_master_acceptance`.
- [x] Review (Reviewer) — cycle-4 `compact-story-review` (Iris-QC, 2026-08-24,
  `review/review-report.md`, `BaseHead: 90f531f1`): **`Outcome: DEFERRED_ONLY`,
  0 blocking findings, 3 deferred.** B1/B3 (cycle-2) re-confirmed still
  resolved and non-regressed. B4/B5 (cycle-3) both re-verified RESOLVED with
  independent evidence: both PNGs opened and confirmed distinct/real content
  matching screen elements; `Runtime-Smoke: PASS` cross-corroborated against
  logcat timestamps. All AC1-AC7: PASS. Carried-forward/new deferred findings:
  D2 (EN CTA wording, OQ5, non-blocking), D3 (new — two stale rows in
  `coding-plan/test-results.md`, non-blocking, owner mobile-dev,
  opportunistic), D4 (new — runtime smoke used `main_preview.dart`, not the
  release entrypoint; correct for this story's scope but flagged as an input
  for REQ-009 integration review, referencing `BUG-20260823-001`'s failure
  class). `story_status_recommendation: DONE`. **Merge-ordering
  precondition (carried from cycle 3, still open):** bring `main`'s commit
  `498bb85` (B1 ratification) into
  `codex/REQ-009_invite_couple_type_and_pairing_navigation-integration` before
  or during this story's merge — it is not yet on the integration branch.

## Story Runtime Startup Smoke

Full evidence: `coding-plan/test-results.md` `## Story Runtime Startup Smoke
(B5, DevOps device pass)`. Frank-Devops device pass, 2026-08-24:
`emulator-5554`, built `main_preview.dart` PREVIEW=pairingchoice,
installed/launched, `topResumedActivity` = `MainActivity`, no `FATAL
EXCEPTION`/`AndroidRuntime` crash entries in logcat.

Result: PASS

## Entry Point Reachability

Full evidence: `coding-plan/test-results.md` `## Entry Point Reachability`.
Invite, join-code, and pairing-choice are all already-shipped reachable
screens; this story corrects their navigation edges rather than adding a new
entry point. Evidenced by `pairing_choice_screen_test.dart` `_gateHarness()`.

Reachable: YES

## Depends On
- NONE. Independent of STORY-001 — see `requirements/requirements.md`
  `## Recommended Story Sequence`.

## User Story
As a user who has just created or joined a pairing code, I want continuing to
take me through the pairing-choice screen to the correct next step for my
side — Waiting-for-partner if I created the code, paired if I joined with a
partner's code — not to Fingerprint Vow — so the app doesn't show me a
post-pairing surface before pairing has actually completed.

## In Scope
1. Restore the post-code navigation target for both invite and join-code:
   continuing leads to the pairing-choice screen
   (`pairing_choice_screen.dart`, STORY-034 in REQ-002 — keep it, do not
   delete), which leads to Waiting-for-partner. Fingerprint Vow must not be
   reachable as the immediate next screen from either.
2. `BACK_TO` wiring: invite's back action returns to pairing-choice (not
   profile); join-code's back action returns to pairing-choice (not invite).
3. Confirm/update `pairing_choice_screen.dart`'s own content and design match
   now that it is (or remains) part of the active flow.
4. Restore/confirm the `pairing_choice`/`isPairingChoice` design-system node
   so a fidelity reference exists (own UX Design phase) — same underlying
   asset class as REQ-002's STORY-034.
5. Update any automated test currently pinned to the prior `goVow` post-code
   navigation expectation (e.g. `app_shell_test.dart`) to assert the restored
   Waiting-for-partner target; confirm no test in the suite still expects
   Fingerprint Vow as the immediate post-code destination.

## Out of Scope
- Redesigning Fingerprint Vow itself, or where it is reached from elsewhere
  in the product.
- Any 5-tab shell / FAB consolidation change
  (`REQ-003_app_shell_five_tab_navigation_and_fab_consolidation`) beyond
  what this story's two navigation edges strictly require.
- The couple-type picker itself (STORY-001's scope) — this story does not
  add or change screen content above the Continue CTA.
- `BUG-20260817-001`'s own regression guard/fix — already delivered;
  reference only, do not reopen.

## Acceptance Criteria
1. Given a user has just created a pairing code and presses Continue on the
   invite screen, when navigation resolves, then the user is taken to the
   pairing-choice screen, not directly to Fingerprint Vow.
2. Given the pairing-choice screen shown for this flow, when the user
   proceeds, then it leads to Waiting-for-partner — Fingerprint Vow is not
   reachable as the immediate next screen from invite.
3. Given a user has just entered a partner's code on the join-code screen and
   continues, when navigation resolves, then the restored path applies
   (join-code -> pairing-choice -> paired), not Fingerprint Vow. Amended
   2026-08-24 (Product Owner, F4 ratification) from a literal
   "Waiting-for-partner" target to `paired`, matching the implemented and
   independently re-tested behavior: per Tech Lead A2 (`architecture/solution.md`
   lines ~86-91) and ADR-4, `acceptInvitation(code)` is synchronous for the
   invitee — there is nothing to wait for once the join-code is accepted, so a
   join-code -> Waiting-for-partner edge would be new scope, not a restore. The
   inviter side (AC2) keeps Waiting-for-partner because the inviter genuinely
   waits on the partner; the two sides are asymmetric by design. This story's
   binding negative — Fingerprint Vow must not be the immediate post-code
   destination — is unaffected and remains satisfied.
4. Given the user is on the invite screen, when they use the back action,
   then they return to the pairing-choice screen, not the profile screen.
5. Given the user is on the join-code screen, when they use the back action,
   then they return to the pairing-choice screen, not the invite screen.
6. Given the pairing-choice screen as delivered by this story, when compared
   to the design reference, then it matches the design source with no
   visible deviation in layout, spacing, colour, typography, or state — the
   design source's pairing-choice node must exist for this comparison.
7. Given any existing automated test that asserted the prior `goVow`
   post-code navigation target, when this story is delivered, then that
   test is updated to assert the restored Waiting-for-partner target, and no
   test in the suite still expects Fingerprint Vow as the immediate
   post-code destination.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: invite, join-code, and pairing-choice
  screens are all already reachable in the shipped app — this story
  corrects/confirms their navigation edges, it does not add a new entry
  point.
- Direct URL only acceptable: N/A — existing reachable screens.

## Dependencies
- Depends on: NONE.
- Must not require any future story.
- Must not reopen any closed git boundary/branch for REQ-002's
  STORY-002/STORY-034/STORY-011/STORY-037 or BUG-20260817-001's fix.

## Open Question Impact
OQ5 (light theme / EN locale) is unresolved but non-blocking for this story,
same disposition as REQ-002's STORY-011/036/037 — dark + `vi` is the only
enabled user-facing configuration; no dedicated light/EN rendered pass is
required.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-7) are unblocked.
