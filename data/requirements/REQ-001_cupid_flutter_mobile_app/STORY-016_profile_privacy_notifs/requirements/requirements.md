# Requirements Decision: STORY-016 — AC2 / AC3 Scope Ruling

Mode: story-requirements
Scope: REQ-001 / STORY-016_profile_privacy_notifs
Source: Tech Lead solution doc
`data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-016_profile_privacy_notifs/architecture/solution.md`
(worktree HEAD `59488814ea708d396d2fad845966e07a0939ecc4`), BLOCKER-1 and
BLOCKER-2.

## Decision: BLOCKER-1 (AC3, notification settings) — Option A adopted

AC3 is re-scoped to **device-local notification preferences**. Tech Lead's
Option B (add a backend endpoint) would break the A1 freeze; Option C (defer
entirely) removes all user-facing notification control from this story for no
compensating benefit, since system architecture memory §8/R9 already confirms
the backend performs no FCM dispatch — a server-stored preference would gate
nothing in v1 regardless. Device-local preferences are the only option that
ships real, honest user value now: users can turn categories on/off and the
client respects that choice immediately, with no invented backend surface and
no freeze violation.

**Revised AC3:**
> A user can view and change notification preferences, persisted device-local
> only (no backend endpoint, no cross-device sync in v1). These preferences
> gate client-side notification presentation only.

Known limitation to carry forward (not a blocker): preferences do not
propagate if the user reinstalls the app or switches devices, until a future
story adds a backend-synced preferences contract. This limitation must be
stated in-product only if UX/Reviewer judge it user-visible enough to warrant
a note; it is not a new AC.

## Decision: BLOCKER-2 (AC2, privacy settings) — Option A adopted

AC2 is re-scoped to **view-only**. The only editable privacy-shaped field in
the `users` contract, `isGhostModeEnabled`, is already owned by STORY-008's
ghost-mode ("Typing Ghost") screen per UX System Memory §6. Adding a second
PATCH surface for the same field here (Option B) creates two screens writing
one field with no shared state owner, which is a drift risk for zero added
user value — STORY-008 already delivers that control. View-only fully
satisfies the UX §4 three-tier explainer with zero invented fields.

**Revised AC2:**
> A user can view their privacy settings (the three-tier data-sharing
> explainer) as static, read-only content. This story does not add or own any
> editable privacy control; the Typing Ghost / ghost-mode toggle remains
> solely owned by STORY-008 and must not be duplicated here.

## Unchanged

- **AC1** (profile view/edit) — unchanged, fully solutioned.
- **AC4** (no admin/data-export surface) — unchanged. The data-export button
  carried conflict (UX §7.3 vs. system UX memory §8) is a separate PO decision
  already carried from UX and is not re-litigated here: AC4 is read literally
  and the export button stays excluded from this story's scope. System UX
  memory §8 should be corrected to match AC4 by whichever role next touches
  that memory file; that correction is not blocking for STORY-016.

## Not Decided Here (Scrum Master / DevOps scope, per handoff)

- GAP-1 (no 5-tab app shell owner) — routing/ownership call, out of PO scope.
- RISK-1 (`@IsUrl()` vs. bare `localhost` upload URL) — environment/config
  risk, out of PO scope.

PRODUCT_OWNER_COMPLETE: YES
