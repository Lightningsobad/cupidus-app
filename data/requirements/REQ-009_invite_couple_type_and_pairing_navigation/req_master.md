# Requirement Master: REQ-009 Invite couple-type picker & pairing navigation restore
Status: DONE

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

## Source

Escalated from `BUG-20260824-001_pairing_code_screen_missing_design`
(`data/bugs/BUG-20260824-001_pairing_code_screen_missing_design/bug_master.md`),
`ESCALATED_TO_BACKLOG` — reproduced but root cause is missing/diverged product
scope, not a defect. User confirmed the following navigation decisions
directly (2026-08-24); Product Owner/UI-UX must design and implement to these
locked decisions, not re-open them as open questions.

## Locked Navigation Decisions (user-confirmed)

1. **Couple-type picker placement**: on the invite/create-pairing-code screen
   ("Mã ghép đôi của bạn"), the couple-type picker ("Tụi mình thuộc kiểu nào?",
   4-card grid) goes AFTER the pairing code is already displayed — code shown
   first, couple-type picker below it, leading to the continue CTA. Do not
   place it before code creation.
2. **Post-code navigation**: restore the pre-`3d74a75` flow. Continuing from
   the invite/join-code screen goes to `pairing_choice_screen.dart` (STORY-034,
   currently orphaned — keep it, do not delete). From there the two sides are
   asymmetric by design, not both terminal at Waiting-for-partner:
   - **Invite (inviter)** continues to the Waiting-for-partner screen
     (`goWaiting`), since the inviter genuinely waits on their partner to join.
   - **Join-code (invitee)** continues to `paired`, not Waiting-for-partner.
     `acceptInvitation(code)` is synchronous for the invitee (Tech Lead A2 /
     ADR-4), so there is nothing left to wait for once the code is accepted; a
     join-code -> Waiting-for-partner edge would be new scope, not a restore.

   Neither side goes to `goVow`/"Fingerprint Vow". This reverts the divergence
   introduced in commit `3d74a75` (2026-08-20), which had rewired the CTA to
   `goVow` and deleted the `isPairingChoice` design node entirely. `BACK_TO`
   wiring must also revert: `invite -> pairingchoice` (not `invite ->
   profile`), `joincode -> pairingchoice` (not `joincode -> invite`).

   Amended 2026-08-24, user-confirmed asymmetric invitee routing, ratifying
   STORY-002 AC3 and resolving Reviewer finding B1.

## Scope For Product Owner / UI-UX / Tech Lead

- Couple-type content catalog: card labels, hints/subtext, icon per card,
  vi + en copy (STORY-011 explicitly excluded this catalog from its scope —
  it must be authored here).
- `CupidProfile.coupleType` (or equivalent) persistence semantics: where the
  selected couple-type is stored, whether it is required to continue, and how
  it surfaces later in the product.
- Design source re-baseline: the current locked design source
  (`cupid-app-design-system`) does not contain the `isPairingChoice` node or
  the invite-screen couple-type cards (both were removed by the design source
  itself, not by app code). UI-UX must restore/re-author these design nodes
  (or equivalent local spec) so the app has a design to be fidelity-checked
  against, since STORY-011/037's original fidelity evidence predates this
  removal.
- `pairing_choice_screen.dart` (STORY-034): reconnect it into the navigation
  graph per the locked decision above; confirm/update its own content and
  design match now that it is back in the active flow.
- Regression risk: `BUG-20260817-001` fixed a FAB/send-button occlusion
  regression guard added against the 5-tab shell introduced by the same
  commit family (`3d74a75`); revisit `app_shell_test.dart` and any other
  tests pinned to the `goVow` navigation target so they get updated to the
  restored `goWaiting` target rather than silently passing against stale
  expectations.

## Out of Scope

- Any change to the 5-tab shell / FAB consolidation delivered by
  `REQ-003_app_shell_five_tab_navigation_and_fab_consolidation` beyond what is
  strictly needed to restore the two navigation edges above.
- Redesigning "Fingerprint Vow" itself; this requirement only removes it as
  the immediate post-code navigation target for the invite/join-code flow. If
  "Fingerprint Vow" still needs a different entry point elsewhere in the
  product, that is separate scope.

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
| STORY-001 | Invite couple-type picker | standard | DONE | data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/story_master.md |
| STORY-002 | Pairing-choice navigation restore | standard | DONE | data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-002_pairing_choice_navigation_restore/story_master.md |
| STORY-003 | Integration regression fix (pairing_gate_test AccountRepository fixture) | standard | DONE | data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-003_integration_regression_fix/story_master.md |

Note (D1 fold-in, 2026-08-25): this table was stale — STORY-001/STORY-002
carried `MERGE_COMPLETE: true` in their Git story boundaries and `Status:
DONE` in their own `story_master.md` well before this correction; STORY-003
had no row at all. Corrected per Iris-QC's deferred finding D1 from the
requirement integration review.
