# Story Master: STORY-002 Pairing-Choice Navigation Restore

Status: PENDING
Complexity: standard
Implementation Lane: shared
Story-Class: standard
Requirement: REQ-009
Screen: `invite`, `joincode`, `pairing_choice` — Epic 1 (Core connection /
onboarding), NO_CHROME / NO_TABS
Regression risk: same commit family (`3d74a75`) as
`BUG-20260817-001` (FAB/send-button occlusion) — a related regression guard
already exists; do not disturb it outside this story's own scope.

## Artifacts
- [ ] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer) — done: restored the `isPairingChoice`
  design-system node and the `invite`/`joincode` `BACK_TO` edges deleted by
  `3d74a75` (see `ux/ux-spec.md`)
- [x] Architecture (Tech Lead) — done: `architecture/solution.md` +
  `coding-plan/` (P1 design-source restore, P2 navigation guards). Key finding:
  the Flutter graph already matches the locked decision and `goVow` exists only
  in the design canvas, so no `mobile/lib/` change is in scope.
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE. Independent of STORY-001 — see `requirements/requirements.md`
  `## Recommended Story Sequence`.

## User Story
As a user who has just created or joined a pairing code, I want continuing to
take me through the pairing-choice screen to Waiting-for-partner — not to
Fingerprint Vow — so the app doesn't show me a post-pairing surface before
pairing has actually completed.

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
   continues, when navigation resolves, then the same restored path applies
   (join-code -> pairing-choice -> Waiting-for-partner), not Fingerprint Vow.
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
